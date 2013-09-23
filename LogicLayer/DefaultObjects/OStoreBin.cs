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
    /// Summary description for OStoreItem
    /// </summary>
    [Database("#database"), Map("StoreBin")]
    [Serializable]
    public partial class TStoreBin : LogicLayerSchema<OStoreBin>
    {
        [Default(0)]
        public SchemaInt IsDefaultBin;
        [Default(0)]
        public SchemaInt IsLocked;
        public SchemaGuid StoreID;
        [Size(255)]
        public SchemaString Description;

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }

        public TStoreBinItem StoreBinItems { get { return OneToMany<TStoreBinItem>("StoreBinID"); } }

        public TStoreBinReservation StoreBinReservations { get { return OneToMany<TStoreBinReservation>("StoreBinID"); } }
    }

    /// <summary>
    /// Represents a compartmentalization of the store into what
    /// is known as "bins" in Anacle.EAM. Each store must have
    /// a bin before checking in items. When a user creates a
    /// new store, a default bin is always created.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreBin : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets a flag that indicates
        /// whether this bin is a default bin created by the
        /// OStore object. Default bins play a special role
        /// in the Asset Center. When OEquipment objects are
        /// created, they are automatically "checked-in" into
        /// the store and into the default store bin. And
        /// this flag is used to identify that.
        /// </summary>
        public abstract int? IsDefaultBin { get; set; }

        /// <summary>
        /// [Column] Gets or sets the IsLocked for this bin.
        /// </summary>
        public abstract int? IsLocked { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description for this bin.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents the store that
        /// has set up this bin.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OStoreBinItem objects that represents
        /// the various batches of stock items checked in to the store under
        /// this bin.
        /// </summary>
        public abstract DataList<OStoreBinItem> StoreBinItems { get; }

        /// <summary>
        /// Gets a one-to-many list of OStoreBinReservation objects that
        /// represents the list of reservation of stock items in this bin.
        /// </summary>
        public abstract DataList<OStoreBinReservation> StoreBinReservations { get; }

        /// <summary>
        /// Gets a translated text indicating whether the store bin
        /// is locked for stock taking.
        /// </summary>
        public string IsLockedText
        {
            get
            {
                if (this.IsLocked == 0)
                    return Resources.Strings.General_No;
                else if (this.IsLocked == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// This object is only deactivable if it has not been saved.
        ///
        /// Returns true if deactivable, false otherwise. The
        /// UIGridview makes use of this field to hide and show the
        /// DeleteObject button accordingly.
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------
        public override bool IsDeactivatable()
        {
            return IsNew;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Checks to see if the store bin with the specified storeBinId
        /// has any items currently held in the bin.
        /// </summary>
        /// <param name="storeBinId"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static bool HasItems(Guid storeBinId)
        {
            return TablesLogic.tStoreBinItem[
                TablesLogic.tStoreBinItem.StoreBinID == storeBinId &
                TablesLogic.tStoreBinItem.PhysicalQuantity > 0].Count > 0;
        }

        /// <summary>
        /// Gets a list of store bins by the store ID.
        /// </summary>
        /// <param name="storeId"></param>
        /// <param name="includingStoreBinId"></param>
        /// <returns></returns>
        public static List<OStoreBin> GetStoreBinsByStoreID(Guid storeId, Guid? includingStoreBinId)
        {
            return TablesLogic.tStoreBin.LoadList(
                (TablesLogic.tStoreBin.IsDeleted == 0 &
                TablesLogic.tStoreBin.StoreID == storeId) |
                TablesLogic.tStoreBin.ObjectID == includingStoreBinId, true);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Find the batch whose type corresponds to the store item.
        /// </summary>
        /// <param name="storeItem"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public List<OStoreBinItem> FindBinItem(Guid storeItemID)
        {
            OStoreItem storeItem = TablesLogic.tStoreItem[storeItemID];
            if (storeItem == null)
                return null;

            List<OStoreBinItem> storeBinItems = new List<OStoreBinItem>();

            foreach (OStoreBinItem storeBinItem in StoreBinItems)
            {
                if (storeBinItem.CatalogueID == storeItem.CatalogueID &&
                    storeBinItem.PhysicalQuantity > 0)
                    storeBinItems.Add(storeBinItem);
            }

            if (storeItem.CostingType == StoreItemCostingType.FIFO)
                storeBinItems.Sort(new StoreBinItemFIFOComparison());
            else if (storeItem.CostingType == StoreItemCostingType.LIFO)
                storeBinItems.Sort(new StoreBinItemLIFOComparison());
            else if (storeItem.CostingType == StoreItemCostingType.Expiry)
                storeBinItems.Sort(new StoreBinItemExpiryComparison());

            return storeBinItems;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Find the batch whose type corresponds to the store item.
        /// </summary>
        /// <param name="storeItem"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public List<OStoreBinItem> FindBinItemByCatalogueID(Guid catalogueID)
        {
            List<OStoreItem> storeItems = TablesLogic.tStoreItem[
                TablesLogic.tStoreItem.StoreID == this.StoreID &
                TablesLogic.tStoreItem.CatalogueID == catalogueID];
            if (storeItems.Count == 0)
                return null;

            OStoreItem storeItem = storeItems[0];
            List<OStoreBinItem> storeBinItems = new List<OStoreBinItem>();

            foreach (OStoreBinItem storeBinItem in StoreBinItems)
            {
                if (storeBinItem.CatalogueID == catalogueID &&
                    storeBinItem.PhysicalQuantity > 0)
                    storeBinItems.Add(storeBinItem);
            }

            if (storeItem.CostingType == StoreItemCostingType.FIFO)
                storeBinItems.Sort(new StoreBinItemFIFOComparison());
            else if (storeItem.CostingType == StoreItemCostingType.LIFO)
                storeBinItems.Sort(new StoreBinItemLIFOComparison());
            else if (storeItem.CostingType == StoreItemCostingType.Expiry)
                storeBinItems.Sort(new StoreBinItemExpiryComparison());

            return storeBinItems;
        }

        /// <summary>
        /// Add a new item batch into this bin.
        /// </summary>
        /// <param name="storeItem">The store catalog that this item belongs to.</param>
        /// <param name="catalogueId">The catalogue that this item should belong to.</param>
        /// <param name="quantity">The quantity in the base unit of measure to add.</param>
        /// <param name="expiryDate">The expiry date (if any) for this batch.</param>
        /// <param name="lotNumber">The batch number as specified by the manufacturer.</param>
        /// <param name="unitPrice">The unit price.</param>
        /// <param name="fromStoreId">The ID of the store to transfer the item from.
        /// Leave this empty perform a check-in instead of a transfer.</param>
        /// <param name="toStoreId">The ID of the store to transfer the item to,
        /// or check-in the item to.</param>
        /// <param name="sourceObjectId">The source object that caused a check-in or
        /// transfer.</param>
        /// <returns>An OStoreBinItem object representing the batch that was
        /// created.</returns>
        public OStoreBinItem AddBinItem(OStoreItem storeItem, Guid catalogueId, Guid? equipmentId,
            decimal quantity, DateTime? expiryDate, string lotNumber, decimal unitPrice,
            Guid? fromStoreId, Guid? toStoreId, Guid? sourceObjectId)
        {
            OStoreBinItem storeBinItem = null;

            bool trackLotNumberAndExpiry = true;

            if (storeItem.Catalogue.InventoryCatalogType == InventoryCatalogType.Consumable ||
                storeItem.Catalogue.InventoryCatalogType == InventoryCatalogType.NonConsumable)
            {
                if (storeItem.CostingType == StoreItemCostingType.AverageCosting ||
                    storeItem.CostingType == StoreItemCostingType.StandardCosting)
                {
                    // Check to see if there is an existing batch with exactly the same
                    // catalog ID. If so, load that up and use it.
                    //
                    // Note that if there are multiple batches of the same item
                    // in this store bin (that should not happen), then only
                    // the first batch loaded by the DataFramework will be used.
                    //
                    storeBinItem = TablesLogic.tStoreBinItem.Load(
                        TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID &
                        TablesLogic.tStoreBinItem.CatalogueID == catalogueId, true);

                    // For standard and average costing, do not track
                    // the lot numbers and expiry dates.
                    //
                    trackLotNumberAndExpiry = false;
                }
            }
            else if (storeItem.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment)
            {
            }

            // If no similar batch can be found, or we aren't doing
            // merging of batches, then we simply create a new batch.
            //
            if (storeBinItem == null)
            {
                storeBinItem = TablesLogic.tStoreBinItem.Create();
                storeBinItem.CatalogueID = catalogueId;
                storeBinItem.BatchDate = DateTime.Now;
                storeBinItem.PhysicalQuantity = 0;
                if (trackLotNumberAndExpiry)
                {
                    storeBinItem.ExpiryDate = expiryDate;
                    storeBinItem.LotNumber = lotNumber;
                }
                else
                {
                    storeBinItem.ExpiryDate = null;
                    storeBinItem.LotNumber = "";
                }
                if (storeItem.CostingType == StoreItemCostingType.StandardCosting)
                    storeBinItem.UnitPrice = storeItem.StandardCostingUnitPrice;
                else
                    storeBinItem.UnitPrice = unitPrice;

                this.StoreBinItems.Add(storeBinItem);
            }

            // Finally, we adjust the StoreBinItem quantity
            //
            int transactionType = StoreItemTransactionType.CheckIn;
            Guid? workID = null;
            if (fromStoreId != null && toStoreId != null)
                transactionType = StoreItemTransactionType.StoreTransfer;

            // 20120222 ptb
            // Set the workID if source is a CheckIn
            OStoreCheckInItem scii = TablesLogic.tStoreCheckInItem[sourceObjectId];
            workID = (scii != null && scii.FromWorkCostID != null) ? scii.FromWorkCost.WorkID : null;

            if (workID == null)
                storeBinItem.AdjustQuantity(
                    storeItem, quantity, unitPrice, transactionType,
                    StoreDestinationType.None, workID, null, null, null, fromStoreId, toStoreId, sourceObjectId);
            else
                storeBinItem.AdjustQuantity(
                    storeItem, quantity, unitPrice, transactionType,
                    StoreDestinationType.Work, workID, null, null, null, fromStoreId, toStoreId, sourceObjectId);

            return storeBinItem;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Sums the available quantity for all batches of item of the specified catalogueId
        /// that are stored in this Bin.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public decimal GetTotalAvailableQuantity(Guid catalogueId)
        {
            decimal a = (decimal)Query.Select(
                TablesLogic.tStoreBinItem.PhysicalQuantity.Sum())
                .Where(
                TablesLogic.tStoreBinItem.IsDeleted == 0 &
                TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID) -

                (decimal)Query.Select(
                TablesLogic.tStoreBinReservation.BaseQuantityReserved.Sum())
                .Where(
                TablesLogic.tStoreBinReservation.IsDeleted == 0 &
                TablesLogic.tStoreBinReservation.CatalogueID == catalogueId &
                TablesLogic.tStoreBinReservation.StoreBinID == this.ObjectID)
                ;

            return (a < 0) ? 0 : a;
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Sums the physical quantity for all batches of item of the specified catalogueId
        /// that are stored in this Bin.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public decimal GetTotalPhysicalQuantity(Guid catalogueId)
        {
            return (decimal)Query.Select(
                TablesLogic.tStoreBinItem.PhysicalQuantity.Sum())
                .Where(
                TablesLogic.tStoreBinItem.IsDeleted == 0 &
                TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Gets the total physical items in this bin, regardless of
        /// their catalogue type. This method is used to determine
        /// if this bin can be deactivated from the user interface.
        /// </summary>
        //----------------------------------------------------------------
        public decimal TotalPhysicalQuantity
        {
            get
            {
                return (decimal)Query.Select(
                    TablesLogic.tStoreBinItem.PhysicalQuantity.Sum())
                    .Where(
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID &
                    TablesLogic.tStoreBinItem.PhysicalQuantity > 0);
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Gets the total physical cost of stock for this bin.
        /// </summary>
        //----------------------------------------------------------------
        public decimal TotalPhysicalCost
        {
            get
            {
                return (decimal)Query.Select(
                    (TablesLogic.tStoreBinItem.UnitPrice *
                    TablesLogic.tStoreBinItem.PhysicalQuantity).Sum())
                    .Where(
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID &
                    TablesLogic.tStoreBinItem.PhysicalQuantity > 0);
            }
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Get a DataTable of the store bin items.
        /// </summary>
        //----------------------------------------------------------------
        public DataTable StoreBinItemsConsolidated
        {
            get
            {
                try
                {
                    DataTable dt = Data.LeftJoin(
                        "ObjectID",

                        // query 1
                        (DataTable)Query.Select(
                        //TablesLogic.tStoreBinItem.ObjectID.As("StoreBinItemID"),
                        TablesLogic.tStoreBinItem.CatalogueID.As("ObjectID"),
                        //TablesLogic.tStoreBinItem.ObjectID.As("StoreBinItemID"),
                        TablesLogic.tStoreBinItem.Catalogue.ObjectName.As("Catalogue"),
                        TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                        TablesLogic.tStoreBinItem.PhysicalQuantity.Sum().As("PhysicalQuantity"),
                        TablesLogic.tStoreBinItem.PhysicalQuantity.Sum().As("AvailableQuantity"),
                        (TablesLogic.tStoreBinItem.UnitPrice * TablesLogic.tStoreBinItem.PhysicalQuantity).Sum().As("PhysicalCost"))
                        .Where(
                        TablesLogic.tStoreBinItem.Catalogue.IsDeleted == 0 &
                        TablesLogic.tStoreBinItem.IsDeleted == 0 &
                        TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID
                        //& TablesLogic.tStoreBinItem.PhysicalQuantity > 0
                        )
                        .GroupBy(
                        TablesLogic.tStoreBinItem.CatalogueID,
                        TablesLogic.tStoreBinItem.Catalogue.ObjectName,
                        TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName),

                        // query 2
                        (DataTable)Query.Select(
                        TablesLogic.tStoreBinReservation.CatalogueID.As("ObjectID"),
                        TablesLogic.tStoreBinReservation.BaseQuantityReserved.Sum().As("QuantityReserved"))
                        .Where(
                        TablesLogic.tStoreBinReservation.Catalogue.IsDeleted == 0 &
                        TablesLogic.tStoreBinReservation.IsDeleted == 0 &
                        TablesLogic.tStoreBinReservation.StoreBinID == this.ObjectID &
                        TablesLogic.tStoreBinReservation.BaseQuantityReserved > 0)
                        .GroupBy(
                        TablesLogic.tStoreBinReservation.CatalogueID));

                    dt.Columns.Add("StoreBinItemID", typeof(Guid));

                    foreach (DataRow dr in dt.Rows)
                    {
                        List<OStoreBinItem> StoreBinItems = TablesLogic.tStoreBinItem[
                            TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID &
                            TablesLogic.tStoreBinItem.CatalogueID == new Guid(dr["ObjectID"].ToString()) &
                            TablesLogic.tStoreBinItem.IsDeleted == 0];
                        if (StoreBinItems.Count > 0)
                            dr["StoreBinItemID"] = StoreBinItems[0].ObjectID;
                        dr["AvailableQuantity"] =
                            Data.SafeConvert<decimal>(dr["PhysicalQuantity"]) -
                            Data.SafeConvert<decimal>(dr["QuantityReserved"]);

                        if ((decimal)dr["AvailableQuantity"] < 0)
                            dr["AvailableQuantity"] = 0;
                    }

                    return dt;
                }
                catch (Exception ex)
                {
                    return new DataTable();
                }
            }
        }

        public DataTable GetStoreBinItemsList(Guid? catalogueId)
        {
            DataTable dt = Query.Select(
                TablesLogic.tStoreBinItem.ObjectID,
                TablesLogic.tStoreBinItem.ObjectName,
                TablesLogic.tStoreBinItem.ObjectName.As("BatchDetail"),
                TablesLogic.tStoreBinItem.Catalogue.ObjectName.As("Catalogue"),
                TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                TablesLogic.tStoreBinItem.BatchDate,
                TablesLogic.tStoreBinItem.ExpiryDate,
                TablesLogic.tStoreBinItem.UnitPrice,
                TablesLogic.tStoreBinItem.LotNumber,
                TablesLogic.tStoreBinItem.PhysicalQuantity)
                .Where(
                TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID)
                .OrderBy
                (TablesLogic.tStoreBinItem.BatchDate.Desc);

            foreach (DataRow dr in dt.Rows)
            {
                dr["BatchDetail"] = dr["Catalogue"].ToString() + " (" +
                    ((decimal)dr["PhysicalQuantity"]).ToString("#,##0.00##") + " " +
                    dr["UnitOfMeasure"].ToString() + " x " +
                    ((decimal)dr["UnitPrice"]).ToString("#,##0.00##") + ") " + "(" + ((DateTime)dr["BatchDate"]).ToString("dd-MMM-yyyy") + ")";
            }
            return dt;
        }

        /// <summary>
        /// Gets a list of equipment
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        public DataTable GetEquipmentStoreBinItem(Guid? catalogId, Guid? includingStoreBinItemId)
        {
            DataTable dt = TablesLogic.tStoreBinItem.Select(
                TablesLogic.tStoreBinItem.ObjectID,
                TablesLogic.tStoreBinItem.ObjectName,
                TablesLogic.tStoreBinItem.Equipment.ObjectName.As("Equipment.ObjectName"),
                TablesLogic.tStoreBinItem.Equipment.ModelNumber.As("Equipment.ModelNumber"),
                TablesLogic.tStoreBinItem.Equipment.SerialNumber.As("Equipment.SerialNumber"))
                .Where(
                (
                TablesLogic.tStoreBinItem.CatalogueID == catalogId &
                TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment &
                TablesLogic.tStoreBinItem.Catalogue.IsGeneratedFromEquipmentType == 1 &
                TablesLogic.tStoreBinItem.StoreBinID == this.ObjectID) |
                TablesLogic.tStoreBinItem.ObjectID == includingStoreBinItemId);

            return dt;
        }
    }

    //----------------------------------------------------------------
    /// <summary>
    /// Comparer for FIFO.
    /// </summary>
    //----------------------------------------------------------------
    public class StoreBinItemFIFOComparison : Comparer<OStoreBinItem>
    {
        public override int Compare(OStoreBinItem x, OStoreBinItem y)
        {
            if (x.BatchDate == null || y.BatchDate == null)
                return 0;
            else if (x.BatchDate > y.BatchDate)
                return 1;
            else if (x.BatchDate < y.BatchDate)
                return -1;
            else
                return 0;
        }
    }

    //----------------------------------------------------------------
    /// <summary>
    /// Comparer for LIFO.
    /// </summary>
    //----------------------------------------------------------------
    public class StoreBinItemLIFOComparison : Comparer<OStoreBinItem>
    {
        public override int Compare(OStoreBinItem x, OStoreBinItem y)
        {
            if (x.BatchDate == null || y.BatchDate == null)
                return 0;
            else if (x.BatchDate < y.BatchDate)
                return 1;
            else if (x.BatchDate > y.BatchDate)
                return -1;
            else
                return 0;
        }
    }

    //----------------------------------------------------------------
    /// <summary>
    /// Comparer for Expiry date.
    /// </summary>
    //----------------------------------------------------------------
    public class StoreBinItemExpiryComparison : Comparer<OStoreBinItem>
    {
        public override int Compare(OStoreBinItem x, OStoreBinItem y)
        {
            if (x.ExpiryDate == null)
                return 1;
            else if (y.ExpiryDate == null)
                return -1;
            else if (x.ExpiryDate < y.ExpiryDate)
                return 1;
            else if (x.ExpiryDate > y.ExpiryDate)
                return -1;
            else
                return 0;
        }
    }
}