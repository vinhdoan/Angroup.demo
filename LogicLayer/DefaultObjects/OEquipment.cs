//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    [Database("#database"), Map("Equipment")]
    [Serializable] public partial class TEquipment : LogicLayerSchema<OEquipment>
    {
        public SchemaString RunningNumberCode;
        public SchemaGuid EquipmentTypeID;
        public SchemaGuid StoreBinItemID;
        public SchemaGuid LocationID;
        public SchemaGuid StoreID;
        [Default(0)]
        public SchemaInt IsInStore;
        public SchemaInt IsPhysicalEquipment;
        public SchemaInt LifeSpan;
        public SchemaDateTime DateOfManufacture;
        public SchemaDateTime DateOfOwnership;
        public SchemaDecimal PriceAtOwnership;
        public SchemaString SerialNumber;
        public SchemaString ModelNumber;
        public SchemaString Barcode;
        public SchemaDateTime WarrantyExpiryDate;

        public TEquipment Children { get { return OneToMany<TEquipment>("ParentID"); } }
        public TEquipment Parent { get { return OneToOne<TEquipment>("ParentID"); } }

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TPoint Point { get { return OneToMany<TPoint>("EquipmentID"); } }
        public TEquipmentType EquipmentType { get { return OneToOne<TEquipmentType>("EquipmentTypeID"); } }
        public TOPCAEEvent OPCAEEvents { get { return OneToMany<TOPCAEEvent>("EquipmentID"); } }
        public TStoreBinItem StoreBinItem { get { return OneToOne<TStoreBinItem>("StoreBinItemID"); } }

        /// <summary>
        /// Generates a condition that filters the equipment by the
        /// list of accessible equipment based on the the user's
        /// job code.
        /// </summary>
        /// <returns></returns>
        public ExpressionCondition GetAccessibleEquipmentCondition(OUser user, string objectType, List<string> roleCodes)
        {
            ExpressionCondition c = Query.False;
            foreach (OPosition position in user.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
            {
                foreach (OEquipment equipment in position.EquipmentAccess)
                    c = c | this.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            return c;
        }


        /// <summary>
        /// Generates a condition that filters the equipment by the
        /// list of accessible location.
        /// </summary>
        /// <returns></returns>
        public ExpressionCondition GetAccessibleEquipmentByAreaCondition(OUser user, string objectType, List<string> roleCodes)
        {
            ExpressionCondition c = this.IsPhysicalEquipment == 0;
            foreach (OPosition position in user.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
            {
                foreach (OLocation location in position.LocationAccess)
                    c = c | this.Location.HierarchyPath.Like(location.HierarchyPath + "%");
            }
            return c;
        }
    
    
        /// <summary>
        /// Generates a condition that filters the equipment by the
        /// list of accessible location, and including those equipment
        /// in the store.
        /// </summary>
        /// <returns></returns>
        public ExpressionCondition GetAccessibleEquipmentByAreaAndStoreCondition(OUser user, string objectType, List<string> roleCodes)
        {
            ExpressionCondition c = this.IsPhysicalEquipment == 0;
            foreach (OPosition position in user.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
            {
                foreach (OLocation location in position.LocationAccess)
                    c = c | 
                        this.Location.HierarchyPath.Like(location.HierarchyPath + "%") | 
                        (this.LocationID==null & this.StoreBinItem.StoreBin.Store.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
            }
            return c;
        }


    }


    /// <summary>
    /// Represents a equipment or a folder of equipment. 
    /// The equipment is a hierarchical structure that may
    /// contain the main equipment assembly and its sub-assemblies.
    /// Each equipment, regardless of its assembly structure,
    /// must be associated with a location.
    /// </summary>
    public abstract partial class OEquipment : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets the running number prefix
        /// of this location.
        /// </summary>
        public abstract string RunningNumberCode { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// EquipmentType table.
        /// </summary>
        public abstract Guid? EquipmentTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// StoreBinItem table that indicates the store
        /// batch that this equipment is currently parked
        /// under. 
        /// </summary>
        public abstract Guid? StoreBinItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Location table.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Store table.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag to indicate if the
        /// Equipment is current in the store or issued
        /// out to a location.
        /// </summary>
        public abstract int? IsInStore { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates
        /// whether this is a physical equipment.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 ?Equipment Folder (System)</item>
        /// 		<item>1 ?Physical Equipment</item>
        /// 	</list>
        /// </summary>
        public abstract int? IsPhysicalEquipment { get; set; }

        /// <summary>
        /// [Column] Gets or sets the life span in the
        /// number of years of this equipment.
        /// </summary>
        public abstract int? LifeSpan { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date of manufacture 
        /// of this equipment.
        /// </summary>
        public abstract DateTime? DateOfManufacture { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date of ownership of
        /// this equipment.
        /// </summary>
        public abstract DateTime? DateOfOwnership { get; set; }

        /// <summary>
        /// [Column] Gets or sets the price of ownership of this equipment.
        /// </summary>
        public abstract decimal? PriceAtOwnership { get; set; }

        /// <summary>
        /// [Column] Gets or sets the serial number of
        /// this equipment.
        /// </summary>
        public abstract string SerialNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the model number of
        /// this equipment.
        /// </summary>
        public abstract string ModelNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the barcode of this
        /// equipment.
        /// </summary>
        public abstract string Barcode { get; set; }

        /// <summary>
        /// [Column] Gets or sets the warranty expiry
        /// date of this equipment.
        /// </summary>
        public abstract DateTime? WarrantyExpiryDate { get; set; }

        /// <summary>
        /// Gets a list of OEquipment objects that represents
        /// the list of next level equipment below this current
        /// equipment.
        /// </summary>
        public abstract DataList<OEquipment> Children { get; }

        /// <summary>
        /// Gets the OEquipment object that represents
        /// the parent equipment that this current
        /// equipment belongs under.
        /// </summary>
        public abstract OEquipment Parent { get; }

        /// <summary>
        /// Gets the OLocation object that represents the
        /// location that this current equipment exists in.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets the OEquipmentType object that represents
        /// the equipment type this current equipment
        /// belongs to.
        /// </summary>
        public abstract OEquipmentType EquipmentType { get;set; }

        /// <summary>
        /// Disallow delete if:
        /// 1. There is at least one work tied to this equipment.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (TablesLogic.tWork.LoadList(
                TablesLogic.tWork.EquipmentID == this.ObjectID).Count > 0)
                return false;

            return base.IsDeactivatable();
        }


        // 2010.05.14
        // Kim Foong
        /// <summary>
        /// Deactivates the corresponding StoreBinItem.
        /// </summary>
        public override void Deactivating()
        {
            base.Deactivating();

            if (this.StoreBinItemID != null)
            {
                OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(this.StoreBinItemID);
                if (storeBinItem != null)
                    storeBinItem.Deactivate();
            }
        }
        


        //---------------------------------------------------------------
        /// <summary>
        /// Tests if the object's parent is a cyclical reference back
        /// to itself.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public bool IsCyclicalReference()
        {
            OEquipment Equipment = this;
            while (true)
            {
                Equipment = Equipment.Parent;
                if (Equipment == null)
                    return false;
                if (Equipment.ObjectID == this.ObjectID)
                    return true;
            }
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get root equipment.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static OEquipment GetRootEquipment()
        {
            OEquipment equipment = TablesLogic.tEquipment.Load(
                TablesLogic.tEquipment.ParentID == null);
            if (equipment != null)
                return equipment;
            else
                return null;
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Find equipment by name and whether it is a physical 
        /// equipment or not.
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OEquipment> FindEquipment(bool isPhysicalEquipment, string value)
        {
            return TablesLogic.tEquipment[
                TablesLogic.tEquipment.ObjectName.Like("%" + value + "%") &
                TablesLogic.tEquipment.IsPhysicalEquipment == (isPhysicalEquipment ? 1 : 0)];
        }


        

        //---------------------------------------------------------------
        /// <summary>
        /// Get a distinct list of equipmenttypes under the current 
        /// equipment/system .
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public List<OEquipmentType> GetEquipmentTypes()
        {
            return TablesLogic.tEquipmentType[
                TablesLogic.tEquipmentType.Equipment.IsPhysicalEquipment==1 &
                TablesLogic.tEquipmentType.Equipment.HierarchyPath.Like(this.HierarchyPath + "%")];
        }

        /// <summary>
        /// Gets a list of OPoint objects that exist in this 
        /// current equipment.
        /// </summary>
        public abstract DataList<OPoint> Point { get; }

        /// <summary>
        /// Gets or sets the OOPCAEEvent object representing 
        /// the type of this current location.
        /// </summary>
        public abstract DataList<OOPCAEEvent> OPCAEEvents { get; }

        public DataTable GetPointsAndReadings()
        {
            DataTable dt = new DataTable();
            TPoint p = TablesLogic.tPoint;
            TReading r = TablesLogic.tReading;

            dt =
                p.Select(
                    p.ObjectID,
                    p.ObjectName,
                    p.Description,
                    p.Equipment.ObjectName.As("Equipment"),
                    //p.EquipmentTypeParameter.ObjectName.As("EquipmentTypeParameter"),
                    p.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                    r.SelectTop(1, r.Reading)
                    .Where(r.PointID == p.ObjectID)
                    .OrderBy(r.DateOfReading.Desc).As("Reading"),
                    r.SelectTop(1, r.DateOfReading)
                    .Where(r.PointID == p.ObjectID)
                    .OrderBy(r.DateOfReading.Desc).As("DateOfReading")
                )
                .Where
                (TablesLogic.tPoint.EquipmentID == this.ObjectID &
                p.IsDeleted == 0);
                                 
            return dt;
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Get latest OPC AE Event  under the current equipment
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public DataTable GetOPCAEEvent()
        {
            DataTable dt = new DataTable();
            TOPCAEEventHistory h = TablesLogic.tOPCAEEventHistory;
            TOPCAEEvent e = TablesLogic.tOPCAEEvent;

            dt =
                e.Select(
                    e.ObjectID,
                    e.ObjectName.As("Source"),                    
                    h.SelectTop(1, h.ConditionName)
                    .Where(e.ObjectID == h.OPCAEEventID)
                    .OrderBy(h.DateOfEvent.Desc).As("ConditionName"),
                    h.SelectTop(1, h.SubConditionName)
                    .Where(e.ObjectID == h.OPCAEEventID)
                    .OrderBy(h.DateOfEvent.Desc).As("SubConditionName"),
                    h.SelectTop(1, h.Severity)
                    .Where(e.ObjectID == h.OPCAEEventID)
                    .OrderBy(h.DateOfEvent.Desc).As("Severity"),
                    h.SelectTop(1, h.DateOfEvent)
                    .Where(e.ObjectID == h.OPCAEEventID)
                    .OrderBy(h.DateOfEvent.Desc).As("DateOfEvent")
                )
                .Where
                (e.EquipmentID == this.ObjectID &
                e.IsDeleted == 0);

            return dt;
        }

        /// <summary>
        /// Extract EquipmentID from Equipment hierachy string
        /// </summary>
        /// <param name="path"></param>
        /// <returns>Guid</returns>
        public static Guid GetEquipmentByPath(String path)
        {
            String[] strList = path.Split('>');
            for (int i = 0; i < strList.Length; i++)
            strList[i] = strList[i].Trim();
            int eqpLevel = strList.Length - 1;

            List<OEquipment> eqpList = TablesLogic.tEquipment.LoadList(TablesLogic.tEquipment.ObjectName == strList[eqpLevel]);
            if (eqpList.Count == 1)
                return (Guid)eqpList[0].ObjectID;
            else
            {
                foreach (OEquipment eqp in eqpList)
                    if (IsEquipmentInList(eqp, strList, eqpLevel))
                        return (Guid)eqp.ObjectID;
                return Guid.Empty;
            }
        }

        /// <summary>
        /// Check if the equipment in the hierachy string
        /// </summary>
        /// <param name="eqp"></param>
        /// <param name="strList"></param>
        /// <param name="eqpLevel"></param>
        /// <returns></returns>
        private static Boolean IsEquipmentInList(OEquipment eqp, String[] strList, int eqpLevel)
        {
            // recersive call to check if the equipment name is in the list, start from bottom level
            // eqpLevel 0 is the top level of equipment tree
            if (eqpLevel == 0)
            return eqp.ObjectName == strList[eqpLevel];
            if (eqp.Parent.ObjectName != strList[eqpLevel - 1])
                return false;
            else
                return IsEquipmentInList(eqp.Parent, strList, eqpLevel - 1);
        }

        /// <summary>
        /// Validates that there is no other point with the same name and under here
        /// </summary>
        /// <returns></returns>
        public bool IsDuplicatePoint(OPoint pt)
        {
            foreach (OPoint i in this.Point)
                if (i.ObjectName == pt.ObjectName)
                    return true;
            return false;
        }

        /// <summary>
        /// Overrides the Saving method to automatically create
        /// the store batch tied to the equipment.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            if (this.IsPhysicalEquipment == 1)
            {
                // Finds the store catalog item for this
                // equipment type.
                //
                OCatalogue catalogue = TablesLogic.tCatalogue.Load(
                    TablesLogic.tCatalogue.EquipmentTypeID == this.EquipmentTypeID);

                OStoreBin currentStoreBin = TablesLogic.tStoreBin.Load(
                    TablesLogic.tStoreBin.StoreBinItems.ObjectID == this.StoreBinItemID);
                OStoreBin storeBin = null;

                if (this.IsInStore == 0)
                {
                    storeBin = TablesLogic.tStoreBin.Load(
                        TablesLogic.tStoreBin.Store.StoreType == StoreType.IssueLocation &
                        TablesLogic.tStoreBin.Store.LocationID == this.LocationID,
                        TablesLogic.tStoreBin.CreatedDateTime.Asc);
                    this.StoreID = null;
                }
                else
                {
                    storeBin = TablesLogic.tStoreBin.Load(
                        TablesLogic.tStoreBin.Store.StoreType == StoreType.Storeroom &
                        TablesLogic.tStoreBin.Store.ObjectID == this.StoreID,
                        TablesLogic.tStoreBin.CreatedDateTime.Asc);
                    this.LocationID = null;
                }

                // By right, for every location there will be
                // a store/store bin created and the 'storeBin' variable
                // will never be null.
                // 
                if (storeBin == null)
                    return;

                OStore store = storeBin.Store;

                if (this.StoreBinItemID == null)
                {
                    // If this is a newly created equipment, 
                    // create the StoreBinItem batch record
                    // and insert it into the issue location.
                    //

                    OStoreItem storeItem = store.FindStoreItem(catalogue);
                    if (storeItem == null)
                    {
                        // If the store catalog item does not
                        // exist, create a new one with default
                        // settings.
                        //
                        storeItem = store.CreateStoreItem(catalogue);
                        if (storeItem.CostingType == StoreItemCostingType.StandardCosting)
                            storeItem.StandardCostingUnitPrice = this.PriceAtOwnership.Value;
                        storeItem.StoreID = store.ObjectID;
                        storeItem.Save();
                    }

                    OStoreBinItem storeBinItem = storeBin.AddBinItem(
                        storeItem,
                        catalogue.ObjectID.Value,
                        this.ObjectID,
                        1,
                        null,
                        "",
                        this.PriceAtOwnership.Value,
                        null,
                        storeBin.StoreID,
                        this.ObjectID);

                    this.StoreBinItemID = storeBinItem.ObjectID;
                    storeBinItem.EquipmentID = this.ObjectID;
                    storeBinItem.Save();
                }
                else
                {
                    OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(this.StoreBinItemID);

                    if (storeBinItem != null)
                    {
                        if (storeBin.ObjectID != currentStoreBin.ObjectID ||
                            this.PriceAtOwnership != storeBinItem.UnitPrice ||
                            this.EquipmentTypeID != storeBinItem.Catalogue.EquipmentTypeID)
                        {
                            // If this is an existing equipment, then
                            // we check if the location has changed,
                            // and we do a transfer of the equipment from
                            // the previous location to the new location.
                            //
                            store.TransferEquipmentStoreBinItem(
                                this.StoreBinItemID.Value,
                                storeBin.ObjectID.Value,
                                this.PriceAtOwnership.Value,
                                catalogue,
                                this.ObjectID);
                        }
                    }
                }
            }
        }


        /// <summary>
        /// Automatically create and add points
        /// based on the point templates set up in the
        /// location type.
        /// </summary>
        public int CreatePoints()
        {
            int count = 0;
            DataList<OEquipmentTypePoint> etp = this.EquipmentType.EquipmentTypePoints;
            foreach (OEquipmentTypePoint i in etp)
            {
                OPoint pt = TablesLogic.tPoint.Create();
                pt.ObjectName = i.ObjectName;
                pt.IsApplicableForLocation = 0;
                pt.UnitOfMeasureID = i.UnitOfMeasureID;
                pt.IsIncreasingMeter = i.IsIncreasingMeter;
                pt.MaximumReading = i.MaximumReading;
                pt.Factor = i.Factor;
                pt.CreateWorkOnBreach = i.CreateWorkOnBreach;
                pt.NumberOfBreachesToTriggerAction = i.NumberOfBreachesToTriggerAction;
                pt.PointTriggerID = i.PointTriggerID;
                pt.MinimumAcceptableReading = i.MinimumAcceptableReading;
                pt.MaximumAcceptableReading = i.MaximumAcceptableReading;
                pt.TypeOfWorkID = i.TypeOfWorkID;
                pt.TypeOfServiceID = i.TypeOfServiceID;
                pt.TypeOfProblemID = i.TypeOfProblemID;
                pt.Priority = i.Priority;
                pt.WorkDescription = i.WorkDescription;
                if (!this.IsDuplicatePoint(pt))
                {
                    this.Point.Add(pt);
                    count++;
                }
            }
            return count;
        }


        /// <summary>
        /// Validates to ensure that the equipment is not moving
        /// into a locked bin.
        /// </summary>
        /// <returns></returns>
        public bool ValidateEquipmentNotMovingToLockedBin()
        {
            // 2010.06.23
            // Kim Foong
            // Do not validate if this Equipment is a folder.
            //
            if (this.IsPhysicalEquipment == 0)
                return true;

            OStoreBin currentStoreBin = TablesLogic.tStoreBin.Load(
                TablesLogic.tStoreBin.StoreBinItems.ObjectID == this.StoreBinItemID);

            OStoreBin newStoreBin = null;
            if (this.IsInStore == 0)
            {
                newStoreBin = TablesLogic.tStoreBin.Load(
                    TablesLogic.tStoreBin.Store.StoreType == StoreType.IssueLocation &
                    TablesLogic.tStoreBin.Store.LocationID == this.LocationID,
                    TablesLogic.tStoreBin.CreatedDateTime.Asc);
            }
            else
            {
                newStoreBin = TablesLogic.tStoreBin.Load(
                    TablesLogic.tStoreBin.Store.StoreType == StoreType.Storeroom &
                    TablesLogic.tStoreBin.Store.ObjectID == this.StoreID,
                    TablesLogic.tStoreBin.CreatedDateTime.Asc);
            }

            if(newStoreBin.ObjectID != currentStoreBin.ObjectID &&
                newStoreBin.IsLocked==1)
                return false;
            return true;
        }
    }
}
