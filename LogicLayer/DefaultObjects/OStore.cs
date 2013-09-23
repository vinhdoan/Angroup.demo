//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStore
    /// </summary>
    [Database("#database"), Map("Store")]
    [Serializable]
    public partial class TStore : LogicLayerSchema<OStore>
    {
        public SchemaGuid LocationID;
        public SchemaGuid NotifyUser1ID;
        public SchemaGuid NotifyUser2ID;
        public SchemaGuid NotifyUser3ID;
        public SchemaGuid NotifyUser4ID;

        [Default(LogicLayer.StoreType.Storeroom)]
        public SchemaInt StoreType;

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }

        public TStoreBin StoreBins { get { return OneToMany<TStoreBin>("StoreID"); } }

        public TStoreItem StoreItems { get { return OneToMany<TStoreItem>("StoreID"); } }

        public TUser NotifyUser1 { get { return OneToOne<TUser>("NotifyUser1ID"); } }

        public TUser NotifyUser2 { get { return OneToOne<TUser>("NotifyUser2ID"); } }

        public TUser NotifyUser3 { get { return OneToOne<TUser>("NotifyUser3ID"); } }

        public TUser NotifyUser4 { get { return OneToOne<TUser>("NotifyUser4ID"); } }
    }

    /// <summary>
    /// Represents a physical inventory store.
    /// </summary>
    [Serializable]
    public abstract partial class OStore : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table that represents the location that this store serves.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser1ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser2ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser3ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser4ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the store type.
        /// <list>
        ///     <item>0 - Storeroom</item>
        ///     <item>1 - Issue Location</item>
        /// </list>
        /// </summary>
        public abstract int? StoreType { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents the location
        /// this store currently serves. In other words, only Works
        /// created at or under this location can consume items within this
        /// store.
        /// <para></para>
        /// Note that this does NOT indicate the physical location of the
        /// store.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OStoreBin objects that
        /// represents the bins in this store.
        /// </summary>
        public abstract DataList<OStoreBin> StoreBins { get; }

        /// <summary>
        /// Gets a one-to-many list of OStoreItem objects that
        /// represents the different catalogue items that this store
        /// can currently hold.
        /// </summary>
        public abstract DataList<OStoreItem> StoreItems { get; }

        /// <summary>
        /// Gets or sets the OUser object that represents the user who
        /// will receive notification when items in this store fall below
        /// their threshold level. The user may specify up to four users
        /// to notify.
        /// </summary>
        public abstract OUser NotifyUser1 { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the user who
        /// will receive notification when items in this store fall below
        /// their threshold level. The user may specify up to four users
        /// to notify.
        /// </summary>
        public abstract OUser NotifyUser2 { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the user who
        /// will receive notification when items in this store fall below
        /// their threshold level. The user may specify up to four users
        /// to notify.
        /// </summary>
        public abstract OUser NotifyUser3 { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the user who
        /// will receive notification when items in this store fall below
        /// their threshold level. The user may specify up to four users
        /// to notify.
        /// </summary>
        public abstract OUser NotifyUser4 { get; set; }

        /// <summary>
        /// Gets the text representing the store type of this store.
        /// </summary>
        public string StoreTypeText
        {
            get
            {
                if (StoreType == LogicLayer.StoreType.Storeroom)
                    return Resources.Strings.StoreType_Storeroom;
                else if (StoreType == LogicLayer.StoreType.IssueLocation)
                    return Resources.Strings.StoreType_IssueLocation;
                return "";
            }
        }

        /// <summary>
        /// Disallows delete if:
        /// 1. This store is an issue location.
        /// 2. There is at least one store item in this store.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (this.StoreType == LogicLayer.StoreType.IssueLocation)
                return false;

            if (this.StoreItems.Count > 0)
                return false;

            return base.IsDeactivatable();
        }

        /// <summary>
        /// Gets a list of low inventory store items.
        /// </summary>
        public List<OStoreItem> LowInventoryStoreItems
        {
            get
            {
                List<OStoreItem> items = new List<OStoreItem>();
                foreach (OStoreItem storeItem in this.StoreItems)
                    if (storeItem.IsLowInventory)
                        items.Add(storeItem);
                return items;
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Create a default bin everytime a store is created.
        /// </summary>
        //----------------------------------------------------------------
        public override void Created()
        {
            base.Created();

            OStoreBin storeBin = TablesLogic.tStoreBin.Create();

            storeBin.IsDefaultBin = 1;
            storeBin.ObjectName = "-";
            storeBin.Description = "-";
            this.StoreBins.Add(storeBin);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Returns a list of store accessible based on roleNameCode list.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static List<OStore> FindAccessibleStores(OUser user,
            string objectType,
            Guid? includingStoreId)
        {
            return FindAccessibleStores(user, objectType, includingStoreId, true, false);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Returns a list of store accessible based on roleNameCode list.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static List<OStore> FindAccessibleStores(OUser user,
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

            return TablesLogic.tStore.LoadList
                ((TablesLogic.tStore.IsDeleted == 0 & condition & storeCondition) |
                TablesLogic.tStore.ObjectID == includingStoreId, true);
        }

        //----------------------------------------------------------------
        /// <summary>
        ///
        /// </summary>
        /// <param name="work"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static List<OStore> FindAvailableStores(OWork work)
        {
            return TablesLogic.tStore[
                TablesLogic.tStore.StoreType == LogicLayer.StoreType.Storeroom &
                ((ExpressionDataString)work.Location.HierarchyPath).Like(TablesLogic.tStore.Location.HierarchyPath + "%")];
        }

        //----------------------------------------------------------------
        /// <summary>
        ///
        /// </summary>
        /// <param name="work"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static List<OStore> FindAvailableStores(OScheduledWork work)
        {
            return TablesLogic.tStore[
                TablesLogic.tStore.StoreType == LogicLayer.StoreType.Storeroom &
                ((ExpressionDataString)work.Location.HierarchyPath).Like(TablesLogic.tStore.Location.HierarchyPath + "%")];
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Finds and return the StoreItem object that corresponds to the catalogue.
        ///
        /// If none is found, return null.
        /// </summary>
        /// <param name="catalogue">The Catalogue object that the returned StoreItem corresponds to.</param>
        /// <returns></returns>
        //----------------------------------------------------------------
        internal OStoreItem FindStoreItem(OCatalogue catalogue)
        {
            List<OStoreItem> items = TablesLogic.tStoreItem[
                TablesLogic.tStoreItem.StoreID == this.ObjectID &
                TablesLogic.tStoreItem.CatalogueID == catalogue.ObjectID];

            if (items.Count > 0)
                return items[0];
            return null;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Checks if there is an existing store item with the
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public bool HasDuplicateStoreItem(OStoreItem itemToCheck)
        {
            foreach (OStoreItem item in StoreItems)
            {
                if (item.ObjectID != itemToCheck.ObjectID &&
                    item.CatalogueID == itemToCheck.CatalogueID)
                    return true;
            }
            return false;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Checks if there is an existing store item with the
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public bool HasDuplicateStoreBin(OStoreBin binToCheck)
        {
            foreach (OStoreBin bin in StoreBins)
            {
                if (bin.ObjectID != binToCheck.ObjectID &&
                    bin.ObjectName == binToCheck.ObjectName)
                    return true;
            }
            return false;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Create a StoreItem for the corresponding catalogue,
        /// with the following fields populated by default:
        /// - StoreItemType: Non-Stocked
        /// - CostingType: FIFO
        /// </summary>
        /// <param name="catalogue"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        internal OStoreItem CreateStoreItem(OCatalogue catalogue)
        {
            if (FindStoreItem(catalogue) != null)
                return null;

            OStoreItem storeItem = TablesLogic.tStoreItem.Create();

            storeItem.CatalogueID = catalogue.ObjectID;
            /*
            if (catalogue.InventoryCatalogType != InventoryCatalogType.Equipment)
            {
                storeItem.CostingType = OApplicationSetting.Current.InventoryDefaultCostingType;
                if (storeItem.CostingType == null)
                    storeItem.CostingType = StoreItemCostingType.FIFO;
                storeItem.ItemType = StoreItemType.NonStocked;
            }
             * */

            return storeItem;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Find the store bin corresponding to its ID. Returns
        /// null if not found.
        /// </summary>
        /// <param name="storeBinID"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public OStoreBin FindBin(Guid storeBinID)
        {
            foreach (OStoreBin storeBin in StoreBins)
                if (storeBin.ObjectID == storeBinID)
                    return storeBin;
            return null;
        }

        /// <summary>
        /// Find all bins with items of the specified catalogue and
        /// return a datatable.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        public static DataTable FindBinsByCatalogue(Guid? storeId, Guid? catalogueId, bool includeBinsWithZeroQuantity)
        {
            return FindBinsByCatalogue(storeId, catalogueId, includeBinsWithZeroQuantity, null);
        }

        /// <summary>
        /// Find all bins with items of the specified catalogue and
        /// return a datatable.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        public static DataTable FindBinsByCatalogue(Guid? storeId, Guid? catalogueId, bool includeBinsWithZeroQuantity, Guid? includingBinId)
        {
            DataTable dt = null;

            if (includeBinsWithZeroQuantity)
            {
                //dt = Data.LeftJoin(
                //    "ObjectID",
                //    Query.Select(
                //    TablesLogic.tStoreBin.ObjectID,
                //    TablesLogic.tStoreBin.ObjectName)
                //    .Where(
                //    TablesLogic.tStoreBin.StoreID == storeId |
                //    TablesLogic.tStoreBin.ObjectID == includingBinId)
                //    .GroupBy(
                //    TablesLogic.tStoreBin.ObjectID,
                //    TablesLogic.tStoreBin.ObjectName)
                //    .OrderBy(
                //    TablesLogic.tStoreBin.ObjectName.Asc),

                //Query.Select(
                //    TablesLogic.tStoreBin.ObjectID,
                //    TablesLogic.tStoreBin.ObjectName,
                //    TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                //    TablesLogic.tStoreBin.StoreBinItems.PhysicalQuantity.Sum().As("Qty"))
                //    .Where(
                //    (TablesLogic.tStoreBin.StoreID == storeId &
                //    TablesLogic.tStoreBin.StoreBinItems.CatalogueID == catalogueId) |
                //    TablesLogic.tStoreBin.ObjectID == includingBinId)
                //    .GroupBy(
                //    TablesLogic.tStoreBin.ObjectID,
                //    TablesLogic.tStoreBin.ObjectName,
                //    TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName)
                //    .OrderBy(
                //    TablesLogic.tStoreBin.ObjectName.Asc),

                //Query.Select(
                //    TablesLogic.tStoreBin.ObjectID,
                //    TablesLogic.tStoreBin.ObjectName,
                //    TablesLogic.tStoreBin.StoreBinReservations.BaseQuantityReserved.Sum().As("QuantityReserved"))
                //    .Where(
                //    (TablesLogic.tStoreBin.StoreID == storeId &
                //    TablesLogic.tStoreBin.StoreBinReservations.CatalogueID == catalogueId &
                //    TablesLogic.tStoreBin.StoreBinReservations.IsDeleted == 0) |
                //    TablesLogic.tStoreBin.ObjectID == includingBinId)
                //    .GroupBy(
                //    TablesLogic.tStoreBin.ObjectID,
                //    TablesLogic.tStoreBin.ObjectName)
                //    .OrderBy(
                //    TablesLogic.tStoreBin.ObjectName.Asc));

                // NX fix bug
                dt = Data.LeftJoin(
                   "ObjectID",
                   Query.Select(
                   TablesLogic.tStoreBin.ObjectID,
                   TablesLogic.tStoreBin.ObjectName)
                   .Where(
                   TablesLogic.tStoreBin.StoreID == storeId |
                   TablesLogic.tStoreBin.ObjectID == includingBinId)
                   .GroupBy(
                   TablesLogic.tStoreBin.ObjectID,
                   TablesLogic.tStoreBin.ObjectName)
                   .OrderBy(
                   TablesLogic.tStoreBin.ObjectName.Asc),

               Query.Select(
                   TablesLogic.tStoreBin.ObjectID,
                   TablesLogic.tStoreBin.ObjectName,
                   TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                   TablesLogic.tStoreBin.StoreBinItems.PhysicalQuantity.Sum().As("Qty"))
                   .Where(
                   (TablesLogic.tStoreBin.StoreID == storeId |
                   TablesLogic.tStoreBin.ObjectID == includingBinId) &
                   TablesLogic.tStoreBin.StoreBinItems.CatalogueID == catalogueId)
                   .GroupBy(
                   TablesLogic.tStoreBin.ObjectID,
                   TablesLogic.tStoreBin.ObjectName,
                   TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName,
                   TablesLogic.tStoreBin.StoreBinItems.Catalogue.ObjectName)
                   .OrderBy(
                   TablesLogic.tStoreBin.ObjectName.Asc),

               Query.Select(
                   TablesLogic.tStoreBin.ObjectID,
                   TablesLogic.tStoreBin.ObjectName,
                   TablesLogic.tStoreBin.StoreBinReservations.BaseQuantityReserved.Sum().As("QuantityReserved"))
                   .Where(
                   (TablesLogic.tStoreBin.StoreID == storeId |
                   TablesLogic.tStoreBin.ObjectID == includingBinId) &
                   TablesLogic.tStoreBin.StoreBinReservations.CatalogueID == catalogueId &
                   TablesLogic.tStoreBin.StoreBinReservations.IsDeleted == 0)
                   .GroupBy(
                   TablesLogic.tStoreBin.ObjectID,
                   TablesLogic.tStoreBin.ObjectName)
                   .OrderBy(
                   TablesLogic.tStoreBin.ObjectName.Asc));
            }
            else
            {
                dt = Data.LeftJoin(
                    "ObjectID",

                    //Query.Select(
                    //TablesLogic.tStoreBin.ObjectID,
                    //TablesLogic.tStoreBin.ObjectName,
                    //TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                    //TablesLogic.tStoreBin.StoreBinItems.PhysicalQuantity.Sum().As("Qty"))
                    //.Where(
                    //(TablesLogic.tStoreBin.StoreID == storeId &
                    //TablesLogic.tStoreBin.StoreBinItems.CatalogueID == catalogueId) |
                    //TablesLogic.tStoreBin.ObjectID == includingBinId)
                    //.GroupBy(
                    //TablesLogic.tStoreBin.ObjectID,
                    //TablesLogic.tStoreBin.ObjectName,
                    //TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName)
                    //.OrderBy(
                    //TablesLogic.tStoreBin.ObjectName.Asc),

                    //Query.Select(
                    //TablesLogic.tStoreBin.ObjectID,
                    //TablesLogic.tStoreBin.ObjectName,
                    //TablesLogic.tStoreBin.StoreBinReservations.BaseQuantityReserved.Sum().As("QuantityReserved"))
                    //.Where(
                    //((TablesLogic.tStoreBin.StoreID == storeId &
                    //TablesLogic.tStoreBin.StoreBinReservations.CatalogueID == catalogueId) |
                    //TablesLogic.tStoreBin.ObjectID == includingBinId) &
                    //TablesLogic.tStoreBin.StoreBinReservations.IsDeleted == 0)
                    //.GroupBy(
                    //TablesLogic.tStoreBin.ObjectID,
                    //TablesLogic.tStoreBin.ObjectName)
                    //.OrderBy(
                    //TablesLogic.tStoreBin.ObjectName.Asc));

                    Query.Select(
                    TablesLogic.tStoreBin.ObjectID,
                    TablesLogic.tStoreBin.ObjectName,
                    TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                    TablesLogic.tStoreBin.StoreBinItems.PhysicalQuantity.Sum().As("Qty"))
                    .Where(
                    (TablesLogic.tStoreBin.StoreID == storeId |
                    TablesLogic.tStoreBin.ObjectID == includingBinId) &
                    TablesLogic.tStoreBin.StoreBinItems.CatalogueID == catalogueId)
                    .GroupBy(
                    TablesLogic.tStoreBin.ObjectID,
                    TablesLogic.tStoreBin.ObjectName,
                    TablesLogic.tStoreBin.StoreBinItems.Catalogue.UnitOfMeasure.ObjectName)
                    .OrderBy(
                    TablesLogic.tStoreBin.ObjectName.Asc),

                    Query.Select(
                    TablesLogic.tStoreBin.ObjectID,
                    TablesLogic.tStoreBin.ObjectName,
                    TablesLogic.tStoreBin.StoreBinReservations.BaseQuantityReserved.Sum().As("QuantityReserved"))
                    .Where(
                    (TablesLogic.tStoreBin.StoreID == storeId |
                    TablesLogic.tStoreBin.ObjectID == includingBinId) &
                    TablesLogic.tStoreBin.StoreBinReservations.CatalogueID == catalogueId &
                    TablesLogic.tStoreBin.StoreBinReservations.IsDeleted == 0)
                    .GroupBy(
                    TablesLogic.tStoreBin.ObjectID,
                    TablesLogic.tStoreBin.ObjectName)
                    //20120222 why commented this? PTB
                    //Uncomment
                    //.Having(
                    //TablesLogic.tStoreBin.StoreBinItems.PhysicalQuantity.Sum() > 0)
                    //end
                    .OrderBy(
                    TablesLogic.tStoreBin.ObjectName.Asc));
            }

            foreach (DataRow dr in dt.Rows)
            {
                decimal a = (Data.SafeConvert<decimal>(dr["Qty"]) - Data.SafeConvert<decimal>(dr["QuantityReserved"]));
                if (a < 0) a = 0;

                dr["ObjectName"] = dr["ObjectName"] + " (" + a.ToString("#,##0.00##") + " " + dr["UnitOfMeasure"] + ")";
            }

            // 2011.12.01
            // Thai Binh
            // Remove all bins that does not contain the items, aka Qty <= 0
            //for (int i = 0; i <= dt.Rows.Count - 1; i++)
            //{
            //    DataRow dr = dt.Rows[i];
            //    decimal a = (Data.SafeConvert<decimal>(dr["Qty"]) - Data.SafeConvert<decimal>(dr["QuantityReserved"]));
            //    if (a <= 0)
            //        dt.Rows.Remove(dr);
            //    else
            //        dr["ObjectName"] = dr["ObjectName"] + " (" + a.ToString("#,##0.00##") + " " + dr["UnitOfMeasure"] + ")";
            //}

            return dt;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Gets the total cost of the physical stock for this store at this
        /// moment in time. The computation does not exclude reserved
        /// stock.
        /// </summary>
        //----------------------------------------------------------------
        public decimal TotalCostOfStock
        {
            get
            {
                return (decimal)Query.Select(
                    (TablesLogic.tStoreBinItem.UnitPrice *
                    TablesLogic.tStoreBinItem.PhysicalQuantity).Sum())
                    .Where(
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.StoreBin.StoreID == this.ObjectID &
                    TablesLogic.tStoreBinItem.PhysicalQuantity > 0);
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Removes all special order items, whose quantity of stock for that item
        /// in the entire store is zero.
        /// </summary>
        //----------------------------------------------------------------
        public void RemoveSpecialOrderItems()
        {
            for (int i = this.StoreItems.Count - 1; i >= 0; i--)
            {
                OStoreItem storeItem = this.StoreItems[i];
                if (storeItem.TotalPhysicalQuantity == 0 && storeItem.ItemType == StoreItemType.SpecialOrder)
                    this.StoreItems.Remove(storeItem);
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Convert actual quantity to base quantity.
        /// </summary>
        /// <param name="baseUnitOfMeasureId"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <param name="actualQuantity"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        /*
        public static decimal ConvertToBaseQuantity(Guid baseUnitOfMeasureId, Guid actualUnitOfMeasureId, decimal actualQuantity)
        {
            decimal conversionFactor = -1.0M;

            if (baseUnitOfMeasureId == actualUnitOfMeasureId)
                conversionFactor = 1.0M;
            else
            {
                OUnitConversionTo unitConversion = OUnitConversion.FindConversion(
                    baseUnitOfMeasureId, actualUnitOfMeasureId);
                if (unitConversion != null)
                    conversionFactor = (decimal)unitConversion.ConversionFactor;
            }
            if (conversionFactor <= 0)
                return 0;
            else
                return actualQuantity / conversionFactor;
        }
        */

        //----------------------------------------------------------------
        /// <summary>
        /// Reserves/Checks out items by adjusting their available quantity
        /// downwards. Item reservations do not create a transactional log of
        /// inventory movement.
        ///
        /// Application should avoid calling this method directly.
        /// </summary>
        /// <param name="binId">Bin from which to reserve items. Leave null if the reservation is across the entire store.</param>
        /// <param name="quantity">Quantity to reserve</param>
        /// <param name="unitOfMeasureId">Unit of Measure to reserve in.</param>
        //----------------------------------------------------------------
        protected List<StoreCheckOutItemDetail> AdjustItemsDownwards(
            int itemTransactionType,
            Guid binId, Guid catalogueId, decimal actualQuantity, Guid actualUnitOfMeasureId,
            int destinationType, Guid? workId, Guid? userId, Guid? locationId, Guid? equipmentId, Guid? fromStoreId, Guid? toStoreId, Guid? sourceObjectId)
        {
            List<StoreCheckOutItemDetail> details = new List<StoreCheckOutItemDetail>();
            OCatalogue catalogue = TablesLogic.tCatalogue[catalogueId];
            List<OStoreItem> storeItems =
                TablesLogic.tStoreItem[
                TablesLogic.tStoreItem.CatalogueID == catalogueId &
                TablesLogic.tStoreItem.StoreID == this.ObjectID];
            if (storeItems == null || storeItems.Count == 0)
                return details;
            OStoreItem storeItem = storeItems[0];

            List<OStoreBinItem> storeBinItems =
                OStoreBinItem.GetStoreBinItemsOrderByCostingType((int)storeItem.CostingType, binId, catalogueId);

            decimal baseQuantity = OUnitConversion.ConvertActualToBaseQuantity((Guid)catalogue.UnitOfMeasureID, actualUnitOfMeasureId, actualQuantity);
            decimal factor = actualQuantity / baseQuantity;
            if (baseQuantity > 0)
            {
                // adjust the quantities for each batch until there's no more to adjust
                //
                foreach (OStoreBinItem storeBinItem in storeBinItems)
                {
                    decimal quantityAdjusted =
                        storeBinItem.AdjustQuantity(
                            -baseQuantity, null, itemTransactionType, destinationType,
                            workId, userId, locationId, equipmentId, fromStoreId, toStoreId, sourceObjectId);

                    StoreCheckOutItemDetail detail = new StoreCheckOutItemDetail();
                    detail.UnitOfMeasureID = actualUnitOfMeasureId;
                    detail.StoreBinItemID = (Guid)storeBinItem.ObjectID;
                    detail.UnitPrice = (decimal)storeBinItem.UnitPrice;
                    detail.BaseQuantity = -quantityAdjusted;
                    detail.ActualQuantity = -quantityAdjusted * factor;
                    detail.LotNumber = storeBinItem.LotNumber;
                    detail.BatchDate = storeBinItem.BatchDate;
                    detail.ExpiryDate = storeBinItem.ExpiryDate;
                    details.Add(detail);

                    baseQuantity += quantityAdjusted;
                    if (baseQuantity <= 0)
                        break;
                }
            }

            if (catalogue.IsRemovedAfterExpended == 1)
            {
                // Counts the total items left in this store.
                // Deactivate the store catalog if none is left.
                //
                decimal totalLeftInThisStore = TablesLogic.tStoreBinItem.Select(
                    TablesLogic.tStoreBinItem.PhysicalQuantity.Sum())
                    .Where(
                    TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                    TablesLogic.tStoreBinItem.StoreBin.StoreID == this.ObjectID &
                    TablesLogic.tStoreBinItem.IsDeleted == 0);

                if (totalLeftInThisStore == 0)
                {
                    using (Connection c = new Connection())
                    {
                        storeItem.Deactivate();
                        storeItem.Save();
                        c.Commit();
                    }
                }

                // Makes sure we do not delete the catalog when
                // doing a store transfer!
                //
                if (itemTransactionType != StoreItemTransactionType.StoreTransfer)
                {
                    // Counts the total items left in all stores.
                    // Deactivate the catalog if none is left.
                    //
                    decimal totalLeftInAllStores = TablesLogic.tStoreBinItem.Select(
                        TablesLogic.tStoreBinItem.PhysicalQuantity.Sum())
                        .Where(
                        TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                        TablesLogic.tStoreBinItem.IsDeleted == 0);

                    if (totalLeftInAllStores == 0)
                    {
                        using (Connection c = new Connection())
                        {
                            catalogue.Deactivate();
                            catalogue.Save();
                            c.Commit();
                        }
                    }
                }
            }

            return details;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Takes a peek at the items that will be checked out but
        /// no check-out will performed.
        ///
        /// </summary>
        /// <param name="binId">Bin from which to reserve items. Leave null if the reservation is across the entire store.</param>
        /// <param name="quantity">Quantity to reserve</param>
        /// <param name="unitOfMeasureId">Unit of Measure to reserve in.</param>
        //----------------------------------------------------------------
        protected List<StoreCheckOutItemDetail> PeekItems(Guid binId, Guid catalogueId, decimal actualQuantity, Guid actualUnitOfMeasureId, out decimal retBaseQuantity)
        {
            retBaseQuantity = 0;

            List<StoreCheckOutItemDetail> details = new List<StoreCheckOutItemDetail>();
            OCatalogue catalogue = TablesLogic.tCatalogue[catalogueId];
            List<OStoreItem> storeItems =
                TablesLogic.tStoreItem[
                TablesLogic.tStoreItem.CatalogueID == catalogueId &
                TablesLogic.tStoreItem.StoreID == this.ObjectID];
            if (storeItems == null || storeItems.Count == 0)
                return details;
            OStoreItem storeItem = storeItems[0];

            List<OStoreBinItem> storeBinItems =
                OStoreBinItem.GetStoreBinItemsOrderByCostingType((int)storeItem.CostingType, binId, catalogueId);

            decimal baseQuantity = OUnitConversion.ConvertActualToBaseQuantity((Guid)catalogue.UnitOfMeasureID, actualUnitOfMeasureId, actualQuantity);
            retBaseQuantity = baseQuantity;
            decimal factor = baseQuantity > 0 ? actualQuantity / baseQuantity : 0;
            if (baseQuantity > 0)
            {
                // adjust the quantities for each batch until there's no more to adjust
                //
                foreach (OStoreBinItem storeBinItem in storeBinItems)
                {
                    decimal quantityAdjusted =
                        storeBinItem.PeekAdjustQuantity(-baseQuantity);

                    StoreCheckOutItemDetail detail = new StoreCheckOutItemDetail();
                    detail.UnitOfMeasureID = actualUnitOfMeasureId;
                    detail.StoreBinItemID = (Guid)storeBinItem.ObjectID;
                    detail.UnitPrice = (decimal)storeBinItem.UnitPrice;
                    detail.BaseQuantity = -quantityAdjusted;
                    detail.ActualQuantity = -quantityAdjusted * factor;
                    detail.LotNumber = storeBinItem.LotNumber;
                    detail.BatchDate = storeBinItem.BatchDate;
                    detail.ExpiryDate = storeBinItem.ExpiryDate;
                    details.Add(detail);

                    baseQuantity += quantityAdjusted;
                    if (baseQuantity <= 0)
                        break;
                }
            }
            return details;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Takes a peek at what the possible unit (based on the base unit)
        /// cost of items would be.
        /// </summary>
        /// <param name="binId"></param>
        /// <param name="catalogueId"></param>
        /// <param name="actualQuantity"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public void PeekItemsUnitCost(Guid binId, Guid catalogueId, decimal actualQuantity, Guid actualUnitOfMeasureId, out decimal peekUnitCost, out decimal peekTotalCost)
        {
            decimal totalCount = 0, totalCost = 0, baseQuantity = 0;
            List<StoreCheckOutItemDetail> details = PeekItems(binId, catalogueId, actualQuantity, actualUnitOfMeasureId, out baseQuantity);

            foreach (StoreCheckOutItemDetail detail in details)
            {
                totalCount += (decimal)detail.BaseQuantity;
                totalCost += (decimal)detail.BaseQuantity * (decimal)detail.UnitPrice;
            }
            peekUnitCost = 0;
            if (totalCount != 0)
                peekUnitCost = totalCost / totalCount;
            if (baseQuantity != totalCount)
                peekTotalCost = peekUnitCost * baseQuantity;
            else
                peekTotalCost = totalCost;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Checks out unreserved items from the store.
        /// </summary>
        /// <param name="binId"></param>
        /// <param name="catalogueId"></param>
        /// <param name="actualQuantity"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <param name="destinationType"></param>
        /// <param name="workId"></param>
        /// <param name="userId"></param>
        /// <param name="locationId"></param>
        /// <param name="equipmentId"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public List<StoreCheckOutItemDetail> CheckOutItems(
            Guid binId, Guid catalogueId, decimal actualQuantity, Guid actualUnitOfMeasureId,
            int destinationType, Guid? workId, Guid? userId, Guid? locationId, Guid? equipmentId, Guid? sourceObjectId)
        {
            return AdjustItemsDownwards(StoreItemTransactionType.CheckOut,
                binId, catalogueId, actualQuantity, actualUnitOfMeasureId, destinationType, workId, userId, locationId, equipmentId, null, null, sourceObjectId);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Transfers items out of the store.
        /// </summary>
        /// <param name="binId"></param>
        /// <param name="catalogueId"></param>
        /// <param name="actualQuantity"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <param name="fromStoreId"></param>
        /// <param name="toStoreId"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public List<StoreCheckOutItemDetail> TransferOutItems(
            Guid binId, Guid catalogueId, decimal actualQuantity, Guid actualUnitOfMeasureId,
            Guid? fromStoreId, Guid? toStoreId, Guid? sourceObjectId)
        {
            return AdjustItemsDownwards(StoreItemTransactionType.StoreTransfer,
                binId, catalogueId, actualQuantity, actualUnitOfMeasureId, 0, null, null, null, null, fromStoreId, toStoreId, sourceObjectId);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Adjust items' quantity upwards. This method is used if
        /// and only if the application is adjusting the quantity of a
        /// known batch upwards.
        ///
        /// Application should avoid calling this method directly.
        /// </summary>
        /// <param name="binId">Bin from which to reserve items. Leave null if the reservation is across the entire store.</param>
        /// <param name="quantity">Quantity to reserve</param>
        /// <param name="unitOfMeasureId">Unit of Measure to reserve in.</param>
        //----------------------------------------------------------------
        protected void AdjustItemsUpwards(Guid storeBinItemId, decimal quantity,
            int itemTransactionType,
            int destinationType, Guid? workId, Guid? userId, Guid? locationId, Guid? equipmentId,
            Guid? fromStoreId, Guid? toStoreId, Guid? sourceObjectId)
        {
            if (quantity > 0)
            {
                OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem[storeBinItemId];
                storeBinItem.AdjustQuantity(quantity, null, itemTransactionType, destinationType,
                    workId, userId, locationId, equipmentId, fromStoreId, toStoreId, sourceObjectId);
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Adjust items' quantity upwards. This method is used if
        /// and only if the application is checking in a new batch of
        /// items into the store.
        ///
        /// Application should avoid calling this method directly.
        /// </summary>
        /// <param name="adjustment"></param>
        /// <param name="binId"></param>
        /// <param name="catalogueId"></param>
        /// <param name="quantity"></param>
        /// <param name="itemTransactionType"></param>
        /// <param name="destinationType"></param>
        /// <param name="workId"></param>
        /// <param name="userId"></param>
        /// <param name="locationId"></param>
        /// <param name="equipmentId"></param>
        /// <param name="fromStoreId"></param>
        /// <param name="toStoreId"></param>
        //----------------------------------------------------------------
        protected void AdjustItemsUpwards(Guid binId, Guid catalogueId,
            StoreCheckInItemDetail detail, int itemTransactionType, Guid? equipmentId, Guid? fromStoreId, Guid? toStoreId, Guid? sourceObjectId)
        {
            if (detail.BaseQuantity > 0)
            {
                OCatalogue catalogue = TablesLogic.tCatalogue[catalogueId];
                OStoreBin storeBin = TablesLogic.tStoreBin[binId];
                OStoreItem storeItem = this.FindStoreItem(catalogue);

                if (storeItem == null)
                {
                    storeItem = this.CreateStoreItem(catalogue);
                    if (storeItem.CostingType == StoreItemCostingType.StandardCosting)
                        storeItem.StandardCostingUnitPrice = detail.UnitPrice;
                    StoreItems.Add(storeItem);
                    storeItem.Save();
                }

                if (storeBin != null)
                {
                    if (storeItem.Catalogue.EquipmentTypeID == null)
                    {
                        // Consumables/non-consumables.
                        //
                        storeBin.AddBinItem(storeItem, catalogueId, equipmentId, detail.BaseQuantity, detail.ExpiryDate, detail.LotNumber, detail.UnitPrice, fromStoreId, toStoreId, sourceObjectId);
                    }
                    else
                    {
                        OEquipment rootEquipment = TablesLogic.tEquipment.Load(TablesLogic.tEquipment.ParentID == null);

                        // Count the total number of equipment based on the
                        // equipment type, and use that number to
                        // name the equipment.
                        //
                        int equipmentCount = TablesLogic.tEquipment.Select(
                            TablesLogic.tEquipment.ObjectID.Count())
                            .Where(
                            TablesLogic.tEquipment.EquipmentTypeID == catalogue.EquipmentTypeID);
                        equipmentCount++;

                        // Equipment
                        //
                        if (itemTransactionType == StoreItemTransactionType.CheckIn)
                        {
                            for (int i = 0; i < detail.BaseQuantity; i++)
                            {
                                OStoreBinItem storeBinItem = storeBin.AddBinItem(storeItem, catalogueId, equipmentId, 1, detail.ExpiryDate, detail.LotNumber, detail.UnitPrice, fromStoreId, toStoreId, sourceObjectId);

                                // When we do a check-in, always create a new equipment.
                                //
                                OEquipment equipment = TablesLogic.tEquipment.Create();

                                equipment.IsPhysicalEquipment = 1;
                                equipment.IsInStore = 1;
                                equipment.StoreID = storeBin.StoreID;
                                equipment.DateOfOwnership = DateTime.Today;
                                equipment.ObjectName = catalogue.ObjectName + " #" + (equipmentCount++).ToString();
                                equipment.ParentID = rootEquipment.ObjectID;

                                if (detail.PurchaseOrder != null)
                                {
                                    equipment.PurchaseOrderNumber = detail.PurchaseOrder.ObjectNumber;
                                    equipment.Vendor = detail.PurchaseOrder.Vendor.ObjectName;
                                    equipment.CurrencyID = detail.PurchaseOrder.CurrencyID;
                                    equipment.PriceAtCurrency = detail.UnitPriceInSelectedCurrency;
                                    equipment.WarrantyPeriod = detail.PurchaseOrder.WarrantyPeriod;
                                    equipment.WarrantyUnit = detail.PurchaseOrder.WarrantyUnit.ToString();
                                    equipment.Warranty = detail.PurchaseOrder.Warranty;
                                    equipment.PurchaseOrderID = detail.PurchaseOrder.ObjectID;
                                }

                                // Sets all string fields to empty string.
                                // If there are new string fields, remember
                                // to set them to empty, otherwise,
                                // reports may not show properly.
                                //
                                equipment.SerialNumber = "";
                                equipment.ModelNumber = "";
                                equipment.Barcode = "";
                                equipment.ObjectNumber = "";
                                equipment.RunningNumberCode = "";

                                equipment.StoreBinItemID = storeBinItem.ObjectID;
                                equipment.EquipmentTypeID = catalogue.EquipmentTypeID;
                                equipment.PriceAtOwnership = detail.UnitPrice;
                                equipment.Save();

                                storeBinItem.EquipmentID = equipment.ObjectID;
                                storeBinItem.Save();
                            }
                        }
                    }
                }

                storeBin.Save();
            }
        }

        /// <summary>
        /// Transfers StoreBinItems tied to an equipment from one store to this store.
        /// </summary>
        /// <param name="storeBinItemId"></param>
        /// <param name="toStoreBinId"></param>
        public void TransferEquipmentStoreBinItem(Guid storeBinItemId,
            Guid toStoreBinId,
            Guid? sourceObjectId)
        {
            OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(storeBinItemId);

            if (storeBinItem.EquipmentID != null &&
                storeBinItem.Equipment != null)
            {
                Guid? fromStoreId = storeBinItem.StoreBin.StoreID;
                Guid? fromStoreItemId = storeBinItem.StoreBin.Store.FindStoreItem(storeBinItem.Catalogue).ObjectID;

                OStoreItem storeItem = this.FindStoreItem(storeBinItem.Catalogue);
                if (storeItem == null)
                {
                    storeItem = this.CreateStoreItem(storeBinItem.Catalogue);
                    StoreItems.Add(storeItem);
                    storeItem.Save();
                }

                // Transfers the entire store bin over to the
                // target store location. the target store location
                // can be a physical store or an issue location.
                //
                storeBinItem.StoreBinID = toStoreBinId;

                OStoreBin storeBin = TablesLogic.tStoreBin.Load(toStoreBinId);

                if (storeBin.Store.StoreType == LogicLayer.StoreType.IssueLocation)
                    storeBinItem.Equipment.LocationID = storeBin.Store.LocationID;
                else
                    storeBinItem.Equipment.LocationID = null;
                storeBinItem.Save();

                Guid? toStoreId = storeBin.StoreID;

                // Create the transactional logs to log the transfer
                // from one store to another.
                //
                OStoreItemTransaction t1 = TablesLogic.tStoreItemTransaction.Create();
                t1.SourceObjectID = sourceObjectId;
                t1.StoreBinItemID = storeBinItem.ObjectID;
                t1.StoreItemID = fromStoreItemId;
                t1.UnitPrice = storeBinItem.UnitPrice;
                t1.Quantity = -storeBinItem.PhysicalQuantity;
                t1.DateOfTransaction = DateTime.Now;
                t1.TransactionType = StoreItemTransactionType.StoreTransfer;
                t1.FromStoreID = fromStoreId;
                t1.ToStoreID = toStoreId;
                t1.Save();

                OStoreItemTransaction t2 = TablesLogic.tStoreItemTransaction.Create();
                t2.SourceObjectID = sourceObjectId;
                t2.StoreBinItemID = storeBinItem.ObjectID;
                t2.StoreItemID = storeItem.ObjectID;
                t2.UnitPrice = storeBinItem.UnitPrice;
                t2.Quantity = storeBinItem.PhysicalQuantity;
                t2.DateOfTransaction = DateTime.Now;
                t2.TransactionType = StoreItemTransactionType.StoreTransfer;
                t2.FromStoreID = fromStoreId;
                t2.ToStoreID = toStoreId;
                t2.Save();
            }
        }

        /// <summary>
        /// Transfers StoreBinItems tied to an equipment from one store to this store.
        /// <para></para>
        /// This method is called by the Equipment.Saving method to update
        /// properties of the store batch
        /// </summary>
        /// <param name="storeBinItemId"></param>
        /// <param name="toStoreBinId"></param>
        public void TransferEquipmentStoreBinItem(Guid storeBinItemId,
            Guid toStoreBinId,
            decimal newEquipmentUnitPrice,
            OCatalogue newCatalog,
            Guid? sourceObjectId)
        {
            OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(storeBinItemId);

            if (storeBinItem.EquipmentID != null &&
                storeBinItem.Equipment != null)
            {
                decimal oldEquipmentUnitPrice = storeBinItem.UnitPrice.Value;

                Guid? fromStoreId = storeBinItem.StoreBin.StoreID;
                Guid? fromStoreItemId = storeBinItem.StoreBin.Store.FindStoreItem(storeBinItem.Catalogue).ObjectID;

                OStoreItem storeItem = this.FindStoreItem(newCatalog);
                if (storeItem == null)
                {
                    storeItem = this.CreateStoreItem(newCatalog);
                    StoreItems.Add(storeItem);
                    storeItem.Save();
                }

                // Transfers the entire store bin over to the
                // target store location. the target store location
                // can be a physical store or an issue location.
                //
                storeBinItem.StoreBinID = toStoreBinId;

                OStoreBin storeBin = TablesLogic.tStoreBin.Load(toStoreBinId);
                storeBinItem.UnitPrice = newEquipmentUnitPrice;
                storeBinItem.CatalogueID = newCatalog.ObjectID;
                storeBinItem.Save();

                Guid? toStoreId = storeBin.StoreID;

                // Create the transactional logs to log the transfer
                // from one store to another.
                //
                OStoreItemTransaction t1 = TablesLogic.tStoreItemTransaction.Create();
                t1.SourceObjectID = sourceObjectId;
                t1.StoreBinItemID = storeBinItem.ObjectID;
                t1.StoreItemID = fromStoreItemId;
                t1.UnitPrice = oldEquipmentUnitPrice;
                t1.Quantity = -storeBinItem.PhysicalQuantity;
                t1.DateOfTransaction = DateTime.Now;

                // We use a store transfer transaction type
                // for all equipment updates from the equipment
                // edit page.
                //
                t1.TransactionType = StoreItemTransactionType.StoreTransfer;
                t1.FromStoreID = fromStoreId;
                t1.ToStoreID = toStoreId;
                t1.Save();

                OStoreItemTransaction t2 = TablesLogic.tStoreItemTransaction.Create();
                t2.SourceObjectID = sourceObjectId;
                t2.StoreBinItemID = storeBinItem.ObjectID;
                t2.StoreItemID = storeItem.ObjectID;
                t2.UnitPrice = newEquipmentUnitPrice;
                t2.Quantity = storeBinItem.PhysicalQuantity;
                t2.DateOfTransaction = DateTime.Now;

                // We use a store transfer transaction type
                // for all equipment updates from the equipment
                // edit page.
                //
                t2.TransactionType = StoreItemTransactionType.StoreTransfer;
                t2.FromStoreID = fromStoreId;
                t2.ToStoreID = toStoreId;
                t2.Save();
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Transfer items from another store into the specified bin.
        /// </summary>
        /// <param name="binId"></param>
        /// <param name="catalogueId"></param>
        /// <param name="detail"></param>
        /// <param name="fromStoreId"></param>
        /// <param name="toStoreId"></param>
        //----------------------------------------------------------------
        public void TransferInItems(Guid binId, Guid catalogueId, StoreCheckInItemDetail detail, Guid? fromStoreId, Guid? toStoreId, Guid? sourceObjectId)
        {
            AdjustItemsUpwards(binId, catalogueId, detail, StoreItemTransactionType.StoreTransfer, null, fromStoreId, toStoreId, sourceObjectId);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Check in new items to the store.
        /// </summary>
        /// <param name="binId"></param>
        /// <param name="catalogueId"></param>
        /// <param name="detail"></param>
        //----------------------------------------------------------------
        public void CheckInNewItems(Guid binId, Guid catalogueId, StoreCheckInItemDetail detail, Guid? sourceObjectId)
        {
            AdjustItemsUpwards(binId, catalogueId, detail, StoreItemTransactionType.CheckIn, null, null, null, sourceObjectId);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Check in work order items. If a reservation has been
        /// previously made for the item, specify the reservation ID
        /// in the storeBinReservationId parameter.
        /// </summary>
        /// <param name="reservation"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public void CheckInWorkOrderItems(Guid workId, Guid? storeBinReservationId, List<StoreCheckInWorkOrderItemDetail> details, Guid? sourceObjectId)
        {
            decimal totalCheckedIn = 0;
            foreach (StoreCheckInWorkOrderItemDetail detail in details)
            {
                List<OStoreBinItem> storeBinItems = TablesLogic.tStoreBinItem[TablesLogic.tStoreBinItem.ObjectID == detail.StoreBinItemID, true];
                if (storeBinItems.Count == 0)
                    continue;

                OStoreBinItem storeBinItem = storeBinItems[0];
                storeBinItem.Activate();
                storeBinItem.AdjustQuantity(detail.BaseQuantity, null, StoreItemTransactionType.CheckIn,
                    StoreDestinationType.Work, workId, null, null, null, null, null, sourceObjectId);

                totalCheckedIn += detail.BaseQuantity;
            }

            if (storeBinReservationId != null)
            {
                OStoreBinReservation r = TablesLogic.tStoreBinReservation[storeBinReservationId];
                r.AdjustReservation(totalCheckedIn);
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Check in store request items. If a reservation has been
        /// previously made for the item, specify the reservation ID
        /// in the storeBinReservationId parameter.
        /// </summary>
        /// <param name="reservation"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public void CheckInStoreRequestItems(int Destination, Guid? userId, Guid? storeBinReservationId, List<StoreCheckInWorkOrderItemDetail> details, Guid? sourceObjectId)
        {
            decimal totalCheckedIn = 0;
            foreach (StoreCheckInWorkOrderItemDetail detail in details)
            {
                List<OStoreBinItem> storeBinItems = TablesLogic.tStoreBinItem[TablesLogic.tStoreBinItem.ObjectID == detail.StoreBinItemID, true];
                if (storeBinItems.Count == 0)
                    continue;

                OStoreBinItem storeBinItem = storeBinItems[0];
                storeBinItem.Activate();
                storeBinItem.AdjustQuantity(detail.BaseQuantity, null, StoreItemTransactionType.CheckIn,
                    Destination, null, userId, null, null, null, null, sourceObjectId);

                totalCheckedIn += detail.BaseQuantity;
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Check out work order items without reservation.
        /// </summary>
        /// <param name="reservation"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public List<StoreCheckOutItemDetail> CheckOutWorkOrderItems(Guid binId, Guid catalogueId, decimal actualQuantity,
            Guid actualUnitOfMeasureId, Guid workId, Guid? sourceObjectId)
        {
            return CheckOutItems(binId, catalogueId, actualQuantity, actualUnitOfMeasureId,
                StoreDestinationType.Work, workId, null, null, null, sourceObjectId);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Check out store request items without reservation.
        /// </summary>
        /// <param name="reservation"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public List<StoreCheckOutItemDetail> CheckOutStoreRequestItems(Guid binId, Guid catalogueId, decimal actualQuantity,
            Guid actualUnitOfMeasureId, int DestinationType, Guid? userId, Guid? sourceObjectId)
        {
            return CheckOutItems(binId, catalogueId, actualQuantity, actualUnitOfMeasureId,
               DestinationType, null, userId, null, null, sourceObjectId);
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Get the averaged unit cost of stock for the specified
        /// catalogue for ALL existing item batches in ALL stores.
        ///
        /// This is used by the scheduled work to determine the
        /// estimated cost per unit of material.
        /// </summary>
        /// <param name="catalogueId"></param>
        //---------------------------------------------------------------
        public static decimal ComputeAverageUnitCost(Guid catalogueId, Guid? storeId, Guid? storeBinId, Guid toUnitOfMeasureId)
        {
            Guid fromUnitOfMeasureId = (Guid)TablesLogic.tCatalogue[(Guid)catalogueId].UnitOfMeasureID;

            decimal result = (decimal)
                Query.Select(
                (TablesLogic.tStoreBinItem.PhysicalQuantity *
                TablesLogic.tStoreBinItem.UnitPrice).Sum() /
                TablesLogic.tStoreBinItem.UnitPrice.Sum())
                .Where(
                TablesLogic.tStoreBinItem.IsDeleted == 0 &
                TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                (storeId == null ? Query.True : TablesLogic.tStoreBinItem.StoreBin.StoreID == storeId) &
                (storeBinId == null ? Query.True : TablesLogic.tStoreBinItem.StoreBinID == storeBinId) &
                TablesLogic.tStoreBinItem.PhysicalQuantity > 0);

            return OUnitConversion.ComputeBaseToActualCost(fromUnitOfMeasureId, toUnitOfMeasureId, result);
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Check if there are any low inventory items in the store that can be
        /// reordered.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public bool CheckLowInventoryItems()
        {
            foreach (OStoreItem storeItem in this.StoreItems)
                if (storeItem.ReorderThreshold != null &&
                    storeItem.ReorderDefault != null &&
                    storeItem.TotalAvailableQuantity < storeItem.ReorderThreshold &&
                    storeItem.ItemType == StoreItemType.Stocked)
                    return true;
            return false;
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Generate purchase request for items that have fallen
        /// below the inventory threshold.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public OPurchaseRequest GeneratePurchaseRequestForLowInventoryItems(Guid requestorId)
        {
            using (Connection c = new Connection())
            {
                OPurchaseRequest pr = TablesLogic.tPurchaseRequest.Create();

                pr.StoreID = this.ObjectID;
                pr.PurchaseRequestorID = requestorId;

                int count = 1;
                foreach (OStoreItem storeItem in this.StoreItems)
                {
                    if (storeItem.ReorderThreshold != null &&
                        storeItem.ReorderDefault != null &&
                        storeItem.TotalAvailableQuantity <= storeItem.ReorderThreshold &&
                        storeItem.ItemType == StoreItemType.Stocked)
                    {
                        OPurchaseRequestItem pri = TablesLogic.tPurchaseRequestItem.Create();

                        pri.CatalogueID = storeItem.CatalogueID;
                        pri.ItemDescription = storeItem.Catalogue.ObjectName;
                        pri.ItemNumber = count++;
                        pri.ItemType = PurchaseItemType.Material;
                        pri.QuantityRequired = storeItem.ReorderDefault;
                        pri.UnitOfMeasureID = storeItem.Catalogue.UnitOfMeasureID;

                        pr.PurchaseRequestItems.Add(pri);
                    }
                }
                pr.TriggerWorkflowEvent("SaveAsDraft");
                pr.Save();
                c.Commit();

                return pr;
            }
        }

        /// <summary>
        /// Gets the issue location.
        /// </summary>
        /// <param name="locationId"></param>
        /// <returns></returns>
        public static OStore GetIssueLocation(Guid locationId)
        {
            return TablesLogic.tStore.Load(
                TablesLogic.tStore.StoreType == LogicLayer.StoreType.IssueLocation &
                TablesLogic.tStore.LocationID == locationId);
        }

        /// <summary>
        /// Gets the issue location as a list of OStore objects.
        /// </summary>
        /// <param name="locationId"></param>
        /// <returns></returns>
        public static List<OStore> GetIssueLocationAsList(Guid? locationId, Guid? includingStoreId)
        {
            return TablesLogic.tStore.LoadList(
                (TablesLogic.tStore.StoreType == LogicLayer.StoreType.IssueLocation &
                TablesLogic.tStore.LocationID == locationId &
                TablesLogic.tStore.IsDeleted == 0) |
                TablesLogic.tStore.ObjectID == includingStoreId, true);
        }

        /// <summary>
        /// Validates and checks to ensure that none of the
        /// store bins are locked.
        /// <para></para>
        /// Returns a list of store bins that are currently
        /// locked.
        /// </summary>
        /// <returns></returns>
        public static string ValidateStoreBinsNotLocked(List<Guid> storeBinIds)
        {
            List<OStoreBin> lockedStoreBins = TablesLogic.tStoreBin.LoadList(
                TablesLogic.tStoreBin.ObjectID.In(storeBinIds) &
                TablesLogic.tStoreBin.IsLocked == 1);

            string lockedBins = "";
            foreach (OStoreBin lockedStoreBin in lockedStoreBins)
                lockedBins += (lockedBins == "" ? "" : ", ") + lockedStoreBin.ObjectName;

            return lockedBins;
        }

        /// <summary>
        /// Determines which of the store items in this store are
        /// currently below their threshold.
        /// <para></para>
        /// This method sets the LowInventory flag to true for
        /// OStoreItem that have fallen below reorder threshold,
        /// and false otherwise.
        /// </summary>
        /// <returns></returns>
        public bool DetermineLowInventoryItems()
        {
            bool hasAtLeastOneLowInventoryItem = false;
            TStoreItem si = TablesLogic.tStoreItem;
            TStoreBinItem sbi = TablesLogic.tStoreBinItem;
            TStoreBinReservation sbr = TablesLogic.tStoreBinReservation;

            DataTable dt = si.Select(
                si.ObjectID,

                si.ReorderThreshold,

                sbi.Select(sbi.PhysicalQuantity.Sum())
                    .Where(sbi.IsDeleted == 0 &
                        sbi.StoreBin.StoreID == this.ObjectID &
                        sbi.CatalogueID == si.CatalogueID &
                        sbi.PhysicalQuantity > 0).As("PhysicalQuantity"),

                sbr.Select(sbr.BaseQuantityReserved.Sum())
                    .Where(sbr.IsDeleted == 0 &
                        sbr.StoreBin.StoreID == this.ObjectID &
                        sbr.CatalogueID == si.CatalogueID &
                        sbr.BaseQuantityReserved > 0).As("ReservedQuantity")
                )
                .Where(si.StoreID == this.ObjectID);

            foreach (DataRow dr in dt.Rows)
            {
                OStoreItem storeItem = this.StoreItems.Find((Guid)dr["ObjectID"]);

                decimal reorderThreshold = dr["ReorderThreshold"] == DBNull.Value ? 0M : Convert.ToDecimal(dr["ReorderThreshold"]);
                decimal physicalQuantity = dr["PhysicalQuantity"] == DBNull.Value ? 0M : Convert.ToDecimal(dr["PhysicalQuantity"]);
                decimal reservedQuantity = dr["ReservedQuantity"] == DBNull.Value ? 0M : Convert.ToDecimal(dr["ReservedQuantity"]);

                if (physicalQuantity - reservedQuantity < reorderThreshold)
                {
                    storeItem.IsLowInventory = true;
                    hasAtLeastOneLowInventoryItem = true;
                }
                else
                    storeItem.IsLowInventory = false;
            }
            return hasAtLeastOneLowInventoryItem;
        }
    }

    public class StoreCheckOutItemDetail
    {
        public Guid? StoreBinItemID;
        public Guid? UnitOfMeasureID;
        public decimal UnitPrice;
        public decimal BaseQuantity;
        public decimal ActualQuantity;
        public string LotNumber;
        public DateTime? BatchDate;
        public DateTime? ExpiryDate;
    }

    public class StoreCheckInItemDetail
    {
        public decimal UnitPrice;
        public decimal BaseQuantity;
        public string LotNumber;
        public DateTime? ExpiryDate;
        public OPurchaseOrder PurchaseOrder;
        public decimal? UnitPriceInSelectedCurrency;
    }

    public class StoreCheckInWorkOrderItemDetail
    {
        public Guid StoreBinItemID;
        public decimal BaseQuantity;
    }

    public class StoreType
    {
        public const int Storeroom = 0;
        public const int IssueLocation = 1;
    }
}