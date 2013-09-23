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
    /// <summary>
    /// Summary description for OStoreBinItem
    /// Item in each bin with its actual quantity
    /// </summary>
    [Database("#database"), Map("StoreBinItem")]
    [Serializable] public partial class TStoreBinItem : LogicLayerSchema<OStoreBinItem>
    {
        public SchemaGuid StoreBinID;
        public SchemaGuid CatalogueID;
        public SchemaGuid EquipmentID;

        public SchemaDecimal UnitPrice;
        public SchemaDecimal PhysicalQuantity;
        public SchemaDateTime BatchDate;
        public SchemaDateTime ExpiryDate;
        public SchemaString LotNumber;
        public SchemaGuid PurchaseOrderID;

        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
    }


    /// <summary>
    /// Represents the individual batches of stock items checked in
    /// into a bin. It stores information about the quantity, the unit 
    /// price, the batch date, the catalogue, etc.
    /// </summary>
    [Serializable] public abstract partial class OStoreBinItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table to 
        /// indicate the store bin that this batch is contained in.
        /// </summary>
        public abstract Guid? StoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the CatalogueID table to indicate the catalogue that the items in this batch belongs to.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Equipment table to indicate the equipment that
        /// this OStoreBinItem object is associated with.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of items in this batch. 
        /// Same items with different unit price will be stored as a 
        /// separate batch.
        /// </summary>
        public abstract Decimal? UnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the physical quantity of items in this 
        /// batch. This is updated during a check-out, a transfer, or an 
        /// adjustment.
        /// </summary>
        public abstract Decimal? PhysicalQuantity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the batch date of this batch, which is the 
        /// system date/time that this batch was checked into the store. The 
        /// Store module uses this date/time to determine the order of 
        /// checking-out in the FIFO/LIFO costing method.
        /// </summary>
        public abstract DateTime? BatchDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the expiry date of this batch of items. 
        /// This is only for information and does not affect the order of 
        /// check-outs.
        /// </summary>
        public abstract DateTime? ExpiryDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the lot or batch number of this batch of 
        /// items.
        /// </summary>
        public abstract string LotNumber { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that represents the 
        /// catalogue to which this batch of item belongs.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents the store 
        /// bin that this batch is contained in.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }


        /// <summary>
        /// Gets or sets the OEquipment object that represents the store 
        /// bin that this batch is contained in.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }
        public abstract Guid? PurchaseOrderID { get; set; }


        public static List<OStoreBinItem> GetStoreBinItemsOrderByCostingType(int costingType, Guid storeBinId, Guid catalogueId)
        {
            if (costingType == StoreItemCostingType.FIFO)
            {
                return TablesLogic.tStoreBinItem[
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.PhysicalQuantity != 0 &
                    TablesLogic.tStoreBinItem.CatalogueID == catalogueId & 
                    TablesLogic.tStoreBinItem.StoreBinID == storeBinId,
                    TablesLogic.tStoreBinItem.BatchDate.Asc];
            }
            else if (costingType == StoreItemCostingType.LIFO)
            {
                return TablesLogic.tStoreBinItem[
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.PhysicalQuantity != 0 &
                    TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                    TablesLogic.tStoreBinItem.StoreBinID == storeBinId,
                    TablesLogic.tStoreBinItem.BatchDate.Desc];
            }
            else if (costingType == StoreItemCostingType.Expiry)
            {
                return TablesLogic.tStoreBinItem[
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.PhysicalQuantity != 0 &
                    TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                    TablesLogic.tStoreBinItem.StoreBinID == storeBinId,
                    TablesLogic.tStoreBinItem.ExpiryDate.Asc];
            }
            else
            {
                // This applies to Standard Costing and Average Costing
                // and the criteria is the same as the criteria
                // for FIFO.
                //
                return TablesLogic.tStoreBinItem[
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.PhysicalQuantity != 0 &
                    TablesLogic.tStoreBinItem.CatalogueID == catalogueId &
                    TablesLogic.tStoreBinItem.StoreBinID == storeBinId,
                    TablesLogic.tStoreBinItem.BatchDate.Asc];
            }
            return null;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Adjust the physical or available quantity upwards or downwards, only if
        /// the results of the adjustment of both fields do not fall below 0. 
        /// This creates a StoreItemTransaction log and saves it.
        /// 
        /// Saves the item immediately when this method completes.
        /// </summary>
        /// <param name="Quantity">Quantity to adjust.</param>
        /// <returns>The quantity adjusted.</returns>
        //----------------------------------------------------------------
        internal decimal AdjustQuantity(
            decimal quantity, decimal? unitPrice, int transactionType, int destinationType,
            Guid? workID, Guid? userID, Guid? locationID, Guid? equipmentID, Guid? fromStoreID, Guid? toStoreID, Guid? sourceObjectId)
        {
            OStoreItem storeItem = this.StoreBin.Store.FindStoreItem(this.Catalogue);
            return AdjustQuantity(storeItem, quantity, unitPrice, transactionType, destinationType,
                workID, userID, locationID, equipmentID, fromStoreID, toStoreID, sourceObjectId);
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Adjust the physical or available quantity upwards or downwards
        /// without creating a new transaction record.
        /// <para></para>
        /// This method should only be used during the cancellation of
        /// a store check-in/check-out/adjustment/transfer.
        /// </summary>
        /// <param name="Quantity">Quantity to adjust.</param>
        /// <returns>The quantity adjusted.</returns>
        //----------------------------------------------------------------
        internal decimal AdjustQuantityForReversal(decimal quantity)
        {
            if (this.PhysicalQuantity + quantity < 0)
                throw new Exception(Resources.Strings.StoreBinItem_UnableToAdjust);
            this.PhysicalQuantity += quantity;

            // save this object
            //
            if (quantity != 0)
            {
                if (this.PhysicalQuantity == 0 && this.IsDeleted == 0)
                    this.Deactivate();
                if (this.PhysicalQuantity > 0 && this.IsDeleted == 1)
                    this.Activate();

                this.Save();
            }

            return quantity;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Adjust the physical or available quantity upwards or downwards, only if
        /// the results of the adjustment of both fields do not fall below 0. 
        /// This creates a StoreItemTransaction log and saves it.
        /// 
        /// Saves the item immediately when this method completes.
        /// </summary>
        /// <param name="quantity">Quantity to adjust.</param>
        /// <param name="unitPrice">The unit price of the batch to check in. Specify a null
        /// value to avoid performing averaging of the unit price.</param>
        /// <returns>The quantity adjusted.</returns>
        //----------------------------------------------------------------
        internal decimal AdjustQuantity(
            OStoreItem storeItem, decimal quantity, decimal? unitPrice, int transactionType, int destinationType,
            Guid? workID, Guid? userID, Guid? locationID, Guid? equipmentID, Guid? fromStoreID, Guid? toStoreID, Guid? sourceObjectId)
        {
            if (this.PhysicalQuantity + quantity < 0)
                quantity = -(decimal)this.PhysicalQuantity;
            
            // If the unit prices are different, and the current costing 
            // type is set as Average Costing, and the quantity is 
            // greater than zero (ie, we are doing a check-in) 
            // perform an average of the unit price at this juncture.
            // 
            // The formula for computing average is:
            //                   ((price1 * qty1) + (price2 * qty2)) 
            //    price-final = -------------------------------------
            //                               (qty1 + qty2)
            //
            if (unitPrice != null &&
                this.UnitPrice != unitPrice &&
                quantity > 0 &&
                storeItem.CostingType == StoreItemCostingType.AverageCosting)
            {
                this.UnitPrice =
                    (this.UnitPrice * this.PhysicalQuantity + unitPrice * quantity) /
                    (this.PhysicalQuantity + quantity);
            }
            this.PhysicalQuantity += quantity;
            this.Save();

            // create a transactional log if there was any adjustment to the
            // physical quantity.
            //
            if (quantity != 0)
            {
                OStoreItemTransaction t = TablesLogic.tStoreItemTransaction.Create();
                t.SourceObjectID = sourceObjectId;
                t.StoreBinItemID = this.ObjectID;
                t.StoreItemID = storeItem.ObjectID;
                t.UnitPrice = unitPrice;
                t.Quantity = quantity;
                t.DateOfTransaction = DateTime.Now;
                t.TransactionType = transactionType;

                // Unit price should not be null if we are doing a 
                // check-in/transfer in of inventory items. 
                // But in other cases (adjustment, checkout, transfer out)
                // the unit price can be null. If so, we just use this
                // batch's unit price.
                //
                if (t.UnitPrice == null)
                    t.UnitPrice = this.UnitPrice;

                if (t.TransactionType == StoreItemTransactionType.StoreTransfer)
                {
                    t.FromStoreID = fromStoreID;
                    t.ToStoreID = toStoreID;
                }

                t.DestinationType = destinationType;
                if (destinationType == StoreDestinationType.Work)
                    t.WorkID = workID;
                if (destinationType == StoreDestinationType.User)
                    t.UserID = userID;
                if (destinationType == StoreDestinationType.Location)
                    t.LocationID = locationID;
                if (destinationType == StoreDestinationType.Equipment)
                    t.EquipmentID = equipmentID;
                t.Save();
            }

            return quantity;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// This method pretends to adjust the quantity of this
        /// item downwards.
        /// 
        /// This is used by the OStore.PeekItem method.
        /// </summary>
        /// <param name="Quantity">Quantity to adjust.</param>
        /// <returns>The quantity adjusted.</returns>
        //----------------------------------------------------------------
        internal decimal PeekAdjustQuantity(decimal quantity)
        {
            if (this.PhysicalQuantity + quantity < 0)
                quantity = -(decimal)this.PhysicalQuantity;
            return quantity;
        }
    }


}


