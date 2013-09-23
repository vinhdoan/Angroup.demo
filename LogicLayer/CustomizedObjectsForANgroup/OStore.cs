//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
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

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStore
    /// </summary>
    public partial class TStore : LogicLayerSchema<OStore>
    {
        public SchemaInt IsActiveForCheckIn;

        public TStoreBinItem StoreBinsWithEquipmentExpiring { get { return OneToMany<TStoreBinItem>("StoreID"); } }
    }


    /// <summary>
    /// Represents a physical inventory store.
    /// </summary>
    public abstract partial class OStore : LogicLayerPersistentObject
    {
        public abstract int? IsActiveForCheckIn { get; set; }

        public abstract DataList<OStoreBinItem> StoreBinsWithEquipmentExpiring { get; set; }

        /// <summary>
        /// Validates and checks to ensure that none of the 
        /// store bins are locked.
        /// <para></para>
        /// Returns a list of store bins that are currently
        /// locked.
        /// </summary>
        /// <returns></returns>
        public static string ValidateLocationStoreBinsNotLocked(List<Guid> storeBinIds)
        {
            List<OStoreBin> lockedStoreBins = TablesLogic.tStoreBin.LoadList(
                TablesLogic.tStoreBin.ObjectID.In(storeBinIds) &
                TablesLogic.tStoreBin.IsLocked == 1);

            string lockedBins = "";
            foreach (OStoreBin lockedStoreBin in lockedStoreBins)
                lockedBins += (lockedBins == "" ? "" : ", ") + lockedStoreBin.Store.Location.ObjectName;

            return lockedBins;
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Generate RFQ for low inventory items
        /// </summary>
        /// <returns> Returns a created RFQ object </returns>
        //---------------------------------------------------------------
        public ORequestForQuotation GenerateRFQForLowInventoryItems(Guid requestorId)
        {
            using (Connection c = new Connection())
            {
                OApplicationSetting applicationSetting = OApplicationSetting.Current;
                ORequestForQuotation rfq = TablesLogic.tRequestForQuotation.Create();

                rfq.StoreID = this.ObjectID;
                rfq.LocationID = this.LocationID;
                rfq.IsGroupWJ = 0;
                rfq.AutoCalculateReallocationTo = 1;

                DateTime today = DateTime.Today;
                switch (applicationSetting.DefaultRequiredUnit)
                {
                    case 0:
                        rfq.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value);
                        break;
                    case 1:
                        rfq.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value * 7);
                        break;
                    case 2:
                        rfq.DateRequired = today.AddMonths(applicationSetting.DefaultRequiredCount.Value);
                        break;
                    case 3:
                        rfq.DateRequired = today.AddYears(applicationSetting.DefaultRequiredCount.Value);
                        break;
                }

                switch (applicationSetting.DefaultEndUnit)
                {
                    case 0:
                        rfq.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value);
                        break;
                    case 1:
                        rfq.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value * 7);
                        break;
                    case 2:
                        rfq.DateEnd = today.AddMonths(applicationSetting.DefaultEndCount.Value);
                        break;
                    case 3:
                        rfq.DateEnd = today.AddYears(applicationSetting.DefaultEndCount.Value);
                        break;
                }

                int count = 1;
                foreach (OStoreItem storeItem in this.StoreItems)
                {
                    if (storeItem.ReorderThreshold != null &&
                        storeItem.ReorderDefault != null &&
                        storeItem.TotalAvailableQuantity <= storeItem.ReorderThreshold &&
                        storeItem.ItemType == StoreItemType.Stocked)
                    {
                        ORequestForQuotationItem pri = TablesLogic.tRequestForQuotationItem.Create();

                        pri.CatalogueID = storeItem.CatalogueID;
                        pri.ItemDescription = storeItem.Catalogue.ObjectName;
                        pri.ItemNumber = count++;
                        pri.ItemType = PurchaseItemType.Material;
                        pri.QuantityRequired = storeItem.ReorderDefault;
                        pri.UnitOfMeasureID = storeItem.Catalogue.UnitOfMeasureID;

                        rfq.RequestForQuotationItems.Add(pri);
                    }
                }
                rfq.SaveAndTransit("SaveAsDraft");
                c.Commit();

                return rfq;
            }
        }



        /// <summary>
        /// Gets a list of all stores.
        /// </summary>
        /// <returns></returns>
        public static List<OStore> GetAllPhysicalStorerooms()
        {
            return TablesLogic.tStore.LoadList(TablesLogic.tStore.StoreType == LogicLayer.StoreType.Storeroom);
        }

        /// <summary>
        /// Gets a list of all stores.
        /// </summary>
        /// <returns></returns>
        public static List<OStore> GetAllPhysicalStoreroomsActiveForCheckIns()
        {
            return TablesLogic.tStore.LoadList(
                TablesLogic.tStore.IsActiveForCheckIn == 1 &
                TablesLogic.tStore.StoreType == LogicLayer.StoreType.Storeroom);
        }


        // 2011.02.16
        // Kim Foong
        /// <summary>
        /// Gets a list of all stores.
        /// </summary>
        /// <returns></returns>
        public static List<OStore> GetAllPhysicalStoreroomsActiveForCheckIns(Guid? includingStoreId)
        {
            return TablesLogic.tStore.LoadList(
                (TablesLogic.tStore.IsActiveForCheckIn == 1 &
                TablesLogic.tStore.StoreType == LogicLayer.StoreType.Storeroom) |
                TablesLogic.tStore.ObjectID == includingStoreId, true);
        }

        /// <summary>
        /// Gets the text representing the store type of this store.
        /// </summary>
        public string IsActiveForCheckInText
        {
            get
            {
                return IsActiveForCheckIn == 1 ? "Yes" : "No";
            }       
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Returns a list of active stores accessible based on roleNameCode list.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static List<OStore> FindAccessibleStoresActiveForCheckIn(OUser user,
            string objectType,
            Guid? includingStoreId,
            bool includePhysicalStores,
            bool includeIssueLocations)
        {
            List<OStore> stores = new List<OStore>();
            ExpressionCondition condition = Query.False;
            ExpressionCondition storeCondition = Query.False;

            foreach (OPosition position in user.GetPositionsByObjectType(objectType))
            {
                foreach (OLocation location in position.LocationAccess)
                    condition = condition |
                        TablesLogic.tStore.Location.HierarchyPath.Like(location.HierarchyPath + "%");
            }

            if (includePhysicalStores)
                storeCondition = TablesLogic.tStore.StoreType == LogicLayer.StoreType.Storeroom;
            else
                storeCondition = TablesLogic.tStore.StoreType != LogicLayer.StoreType.Storeroom;
            if (includeIssueLocations)
                storeCondition = storeCondition | TablesLogic.tStore.StoreType == LogicLayer.StoreType.IssueLocation;
            else
                storeCondition = storeCondition | TablesLogic.tStore.StoreType != LogicLayer.StoreType.IssueLocation;

            return TablesLogic.tStore.LoadList(
                TablesLogic.tStore.IsActiveForCheckIn == 1 &
                (TablesLogic.tStore.IsDeleted == 0 & condition & storeCondition) |
                TablesLogic.tStore.ObjectID == includingStoreId, true);
        }

    }
  
}



