//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework; //DataFramework

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStoreStockTake
    /// </summary>
    [Database("#database"), Map("LocationStockTake")]
    public partial class TLocationStockTake : LogicLayerSchema<OLocationStockTake>
    {
        [Size(255)]
        public SchemaString Reason;
        public SchemaInt IsIncludingToAllCatalogueTypes;
        public SchemaDateTime LocationStockTakeStartDateTime;
        public SchemaDateTime LocationStockTakeEndDateTime;

        public TLocation Locations { get { return ManyToMany<TLocation>("LocationStockTakeLocation", "LocationStockTakeID", "LocationID"); } }
        public TCatalogue Catalogues { get { return ManyToMany<TCatalogue>("LocationStockTakeCatalogue", "LocationStockTakeID", "CatalogueID"); } }
        public TLocationStockTakeItem LocationStockTakeItems { get { return OneToMany<TLocationStockTakeItem>("LocationStockTakeID"); } }
        public TLocationStockTakeReconciliationItem LocationStockTakeReconciliationItems { get { return OneToMany<TLocationStockTakeReconciliationItem>("LocationStockTakeID"); } }
        public SchemaInt IsApproved;
        public SchemaInt IsSubmittedForApproval;
        public SchemaInt HasItemsPendingReconciliation;
    }


    public abstract partial class OLocationStockTake : LogicLayerPersistentObject, IWorkflowEnabled, IAutoGenerateRunningNumber
    {
        public abstract string Reason { get; set; }
        public abstract int? IsIncludingToAllCatalogueTypes { get; set; }
        public abstract DateTime? LocationStockTakeStartDateTime { get; set; }
        public abstract DateTime? LocationStockTakeEndDateTime { get; set; }

        public abstract DataList<OLocation> Locations { get; set; }

        public abstract DataList<OCatalogue> Catalogues { get; set; }
        public abstract DataList<OLocationStockTakeItem> LocationStockTakeItems { get; set; }
        public abstract DataList<OLocationStockTakeReconciliationItem> LocationStockTakeReconciliationItems { get; set; }
        public abstract int? IsApproved { get; set; }
        public abstract int? IsSubmittedForApproval { get; set; }
        public abstract int? HasItemsPendingReconciliation { get; set; }

        public ArrayList PhysicalLocationIds
        {
            get
            {
                ArrayList list = new ArrayList();

                if (Locations == null)
                    return list;

                foreach (OLocation location in Locations)
                {
                    ArrayList l = (ArrayList) TablesLogic.tLocation.Select(TablesLogic.tLocation.ObjectID)
                        .Where(TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%") &
                        TablesLogic.tLocation.IsPhysicalLocation == 1);

                    list.AddRange(l);
                }

                return list;
            }
        }

        public ArrayList CatalogueItemIds
        {
            get
            {
                ArrayList list = new ArrayList();

                if (Catalogues == null)
                    return list;

                foreach (OCatalogue catalog in Catalogues)
                {
                    ArrayList l = (ArrayList)TablesLogic.tCatalogue.Select(TablesLogic.tCatalogue.ObjectID)
                        .Where(TablesLogic.tCatalogue.HierarchyPath.Like(catalog.HierarchyPath + "%") &
                        TablesLogic.tCatalogue.IsCatalogueItem == 1);

                    list.AddRange(l);
                }

                return list;
            }
        }

        public List<OStoreBin> StoreBins
        {
            get
            {
                List<OStoreBin> list = new List<OStoreBin>();

                if (PhysicalLocationIds == null || PhysicalLocationIds.Count == 0)
                    return list;

                list = TablesLogic.tStoreBin.LoadList(
                    TablesLogic.tStoreBin.Store.LocationID.In(PhysicalLocationIds));


                return list;
            }
        }

       

        public void LockRelatedStoreBins()
        {
            using (Connection c = new Connection())
            {
                foreach (OStoreBin storebin in StoreBins)
                {
                    if (storebin.IsLocked == 1)
                        throw new Exception("Store bin in location " + storebin.Store.Location.ObjectName + " is already locked.");
                    storebin.IsLocked = 1;
                    storebin.Save();
                }

                c.Commit();
            }
        }

        public string ValidateStoreBinsNotLocked()
        {
            List<Guid> storeBinIds = new List<Guid>();
            foreach (OStoreBin bin in this.StoreBins)
                storeBinIds.Add(bin.ObjectID.Value);

            return OStore.ValidateLocationStoreBinsNotLocked(storeBinIds);
        }

        public void PopulateLocationStockTakeItems()
        {
            DataTable dt = GetConsolidatedStoreBinItemsByLocationAndCatalogue(PhysicalLocationIds, CatalogueItemIds, this.IsIncludingToAllCatalogueTypes == 1);
            
            foreach (DataRow row in dt.Rows)
            {
                OLocationStockTakeItem item = TablesLogic.tLocationStockTakeItem.Create();
                item.LocationStockTakeID = this.ObjectID;
                item.CatalogueID = new Guid(row["CatalogueID"].ToString());
                item.LocationID = new Guid(row["LocationID"].ToString());

                if (row["InventoryCatalogType"].ToString() == "2")
                {
                    item.EquipmentID = new Guid(row["EquipmentID"].ToString());
                    item.StockTakeItemType = LocationStockTakeItemType.Equipment;
                    item.Barcode = row["Barcode"].ToString();
                }
                else
                    item.StockTakeItemType = LocationStockTakeItemType.NonConsumable;

                item.PhysicalQuantity = Convert.ToDecimal(row["PhysicalQuantity"]);
                item.ObservedQuantity = item.PhysicalQuantity;
                item.Save();
                this.LocationStockTakeItems.Add(item);                
            }
             
        }

       

        public void UnlockRelatedStoreBins()
        {
            using (Connection c = new Connection())
            {
                foreach (OStoreBin storebin in StoreBins)
                {
                    storebin.IsLocked = 0;
                    storebin.Save();
                }

                c.Commit();
            }
        }

        public void StartStockTake()
        {
            using (Connection c = new Connection())
            {
                LockRelatedStoreBins();
                LocationStockTakeStartDateTime = System.DateTime.Now;
                PopulateLocationStockTakeItems();

                this.Save();
                c.Commit();
            }
        }

       

        public override void Deactivating()
        {
            base.Deactivating();

            if (!this.CurrentActivity.ObjectName.Is("Start", "Draft", "Close"))
                UnlockRelatedStoreBins();
        }
        public bool ItemsPendingReconciliation()
        {
            if (this.LocationStockTakeReconciliationItems.Count >= 0)
                return true;
            else
                return false;
        }

        /// <summary>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void SubmitForApproval()
        {
            using (Connection c = new Connection())
            {
                if (this.IsSubmittedForApproval != 1)
                {
                    this.IsSubmittedForApproval = 1;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Reject()
        {
            using (Connection c = new Connection())
            {
                if (this.IsSubmittedForApproval != 0)
                {
                    this.IsSubmittedForApproval = 0;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Approve()
        {
            using (Connection c = new Connection())
            {
                if (this.IsApproved != 1)
                {
                    this.IsApproved = 1;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                this.Save();
                c.Commit();
            }
        }

        

        public DataTable GetConsolidatedStoreBinItemsByLocationAndCatalogue(ArrayList locations, ArrayList catalogues, bool allCatalogueTypes)
        {

            try
            {
                DataTable dt = new DataTable();

                if (allCatalogueTypes)
                {
                    dt = Query.Select(
                       TablesLogic.tStoreBinItem.CatalogueID,
                       TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType,
                       TablesLogic.tStoreBinItem.EquipmentID,
                       TablesLogic.tStoreBinItem.Equipment.Barcode,
                       TablesLogic.tStoreBinItem.Equipment.SerialNumber,
                       TablesLogic.tStoreBinItem.StoreBinID,
                       TablesLogic.tStoreBinItem.StoreBin.Store.LocationID,
                       TablesLogic.tStoreBinItem.PhysicalQuantity.Sum().As("PhysicalQuantity"))
                       .Where(
                       TablesLogic.tStoreBinItem.Catalogue.IsDeleted == 0 &
                       TablesLogic.tStoreBinItem.IsDeleted == 0 &
                       (TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment |
                       TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType == InventoryCatalogType.NonConsumable) &
                       TablesLogic.tStoreBinItem.StoreBin.Store.LocationID.In(locations)
                       )
                       .GroupBy(
                       TablesLogic.tStoreBinItem.CatalogueID,
                       TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType,
                       TablesLogic.tStoreBinItem.EquipmentID,
                       TablesLogic.tStoreBinItem.Equipment.Barcode,
                       TablesLogic.tStoreBinItem.Equipment.SerialNumber,
                       TablesLogic.tStoreBinItem.StoreBinID,
                       TablesLogic.tStoreBinItem.StoreBin.Store.LocationID);
                }
                else
                {
                    dt = Query.Select(
                       TablesLogic.tStoreBinItem.CatalogueID,
                       TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType,
                       TablesLogic.tStoreBinItem.EquipmentID,
                       TablesLogic.tStoreBinItem.Equipment.Barcode,
                       TablesLogic.tStoreBinItem.Equipment.SerialNumber,
                       TablesLogic.tStoreBinItem.StoreBinID,
                       TablesLogic.tStoreBinItem.StoreBin.Store.LocationID,
                       TablesLogic.tStoreBinItem.PhysicalQuantity.Sum().As("PhysicalQuantity"))
                       .Where(
                       TablesLogic.tStoreBinItem.Catalogue.IsDeleted == 0 &
                       TablesLogic.tStoreBinItem.IsDeleted == 0 &
                       (TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment |
                       TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType == InventoryCatalogType.NonConsumable) &
                       TablesLogic.tStoreBinItem.StoreBin.Store.LocationID.In(locations) &
                       TablesLogic.tStoreBinItem.Catalogue.ObjectID.In(catalogues)
                       )
                       .GroupBy(
                       TablesLogic.tStoreBinItem.CatalogueID,
                       TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType,
                       TablesLogic.tStoreBinItem.EquipmentID,
                       TablesLogic.tStoreBinItem.Equipment.Barcode,
                       TablesLogic.tStoreBinItem.Equipment.SerialNumber,
                       TablesLogic.tStoreBinItem.StoreBinID,
                       TablesLogic.tStoreBinItem.StoreBin.Store.LocationID);
                }
                return dt;
            }
            catch (Exception ex)
            {
                return new DataTable();
            }
        }

        public void CreateReconciliationItems()
        {
            using (Connection c = new Connection())
            {
                foreach (OLocationStockTakeItem item in this.LocationStockTakeItems)
                {
                    if (item.PhysicalQuantity.Value != item.ObservedQuantity.Value)
                    {
                        OLocationStockTakeReconciliationItem reconciliation = TablesLogic.tLocationStockTakeReconciliationItem.Create();
                        reconciliation.LocationStockTakeID = this.ObjectID;
                        reconciliation.CatalogueID = item.CatalogueID;
                        reconciliation.EquipmentID = item.EquipmentID;
                        reconciliation.LocationID = item.LocationID;
                        reconciliation.StockTakeItemType = item.StockTakeItemType;
                        reconciliation.IsManuallyAdded = item.IsManuallyAdded;
                        if (item.IsManuallyAdded == 1)
                        {
                            if (item.ScannedCode == null || item.ScannedCode == string.Empty)
                            {
                                reconciliation.ReconciliationType = ReconciliationType.ScannedCodeNotMatched;
                            }
                            else
                            {
                                int MatchingEquipmentCount = (int)TablesLogic.tEquipment.Select(TablesLogic.tEquipment.ObjectID.Count())
                                    .Where(TablesLogic.tEquipment.IsDeleted == 0 &
                                    (TablesLogic.tEquipment.Barcode == item.ScannedCode | TablesLogic.tEquipment.SerialNumber == item.ScannedCode)
                                    );

                                if (MatchingEquipmentCount > 0)
                                {
                                    reconciliation.ReconciliationType = ReconciliationType.ScannedCodeMatched;
                                }
                                else
                                {
                                    reconciliation.ReconciliationType = ReconciliationType.ScannedCodeNotMatched;
                                }
                            }
                        }
                        else
                        {
                            reconciliation.ReconciliationType = ReconciliationType.ExistingButNotFound;
                        }
                        reconciliation.Remarks = item.Remarks;
                        reconciliation.PhysicalQuantity = item.PhysicalQuantity;
                        reconciliation.ObservedQuantity = item.ObservedQuantity;
                        reconciliation.LocationStockTakeItemID = item.ObjectID;
                        reconciliation.Barcode = item.Barcode;
                        reconciliation.SerialNumber = item.SerialNumber;
                        reconciliation.ScannedCode = item.ScannedCode;
                        reconciliation.Action = 0;
                        this.LocationStockTakeReconciliationItems.Add(reconciliation);
                    }
                }
                this.Save();
                c.Commit();
            }
        }

        public void CloseStockTake()
        {
            using (Connection c = new Connection())
            {
                foreach (OLocationStockTakeReconciliationItem item in this.LocationStockTakeReconciliationItems)
                {
                    if (item.Action == LocationStockTakeReconciliationAction.MarkAsMissing
                        && item.EquipmentID != null)
                    {
                        OEquipment eqpt = TablesLogic.tEquipment.Load(item.EquipmentID);
                        if (eqpt != null)
                        {
                            eqpt.IsMissing = 1;
                            eqpt.Save();
                        }
                    }
                }

                foreach (OLocationStockTakeReconciliationItem item in this.LocationStockTakeReconciliationItems)
                {
                    if (item.Action == LocationStockTakeReconciliationAction.TransferToAnotherLocation
                        && item.EquipmentID != null)
                    {
                        OEquipment eqpt = TablesLogic.tEquipment.Load(item.EquipmentID);
                        if (eqpt != null)
                        {
                            eqpt.LocationID = item.LocationID;
                            eqpt.IsMissing = 0;
                            eqpt.Save();
                        }
                    }
                    else if (item.Action == LocationStockTakeReconciliationAction.CreateNewEquipment)
                    {
                        OEquipment eqpt = TablesLogic.tEquipment.Create();
                        eqpt.IsPhysicalEquipment = 1;
                        eqpt.ObjectName = item.EquipmentName;
                        eqpt.ParentID = item.EquipmentParentID;
                        eqpt.EquipmentTypeID = item.EquipmentTypeID;
                        eqpt.LocationID = item.LocationID;
                        eqpt.SerialNumber = item.SerialNumber;
                        eqpt.DateOfOwnership = item.DateOfOwnership;
                        eqpt.PriceAtOwnership = item.PriceAtOwnership;
                        eqpt.LocationStockTakeID = this.ObjectID;
                        eqpt.Status = EquipmentStatusType.PendingAcceptance;
                        eqpt.Save();
                        item.Equipment = eqpt;
                    }
                }

                LocationStockTakeEndDateTime = System.DateTime.Now;
                UnlockRelatedStoreBins();

                this.Save();
                c.Commit();
            }
        }

        
    }
}

