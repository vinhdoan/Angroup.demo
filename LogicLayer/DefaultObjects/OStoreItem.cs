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
    /// Summary description for OStoreItem
    /// Catalogue item that could be store in the store.
    /// Actual item with its quantity will be reflected in the storebin object
    /// </summary>
    [Database("#database"), Map("StoreItem")]
    [Serializable] public partial class TStoreItem : LogicLayerSchema<OStoreItem>
    {
        public SchemaDateTime LastNotificationDate;
        public SchemaGuid StoreID;
        public SchemaGuid CatalogueID;
        
        [Default(StoreItemCostingType.FIFO)]
        public SchemaInt CostingType;
        
        [Default(StoreItemType.Stocked)]
        public SchemaInt ItemType;

        public SchemaDecimal StandardCostingUnitPrice;
        public SchemaDecimal ReorderDefault;
        public SchemaDecimal ReorderThreshold;        
        
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }  
        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TStoreItemTransaction StoreItemTransactions { get { return OneToMany<TStoreItemTransaction>("StoreItemID"); } }
    }


    /// <summary>
    /// Represents a record containing information about the item 
    /// that its containing store currently keeps. This information
    /// include the cost accounting method (FIFO/LIFO) and whether
    /// or not the item is stocked, or non-stocked.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the last date/time a reminder 
        /// notification was sent when the quantity this item fell below 
        /// threshold.
        /// </summary>
        public abstract DateTime? LastNotificationDate { get;set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store that 
        /// indicates the store that this store item record belongs to.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the CatalogueID
        /// table to indicate the catalogue the item in this record belongs
        /// to.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the costing type, or the accounting method of an item of this catalogue in this store.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 / StoreItemCostingType.FIFO: First-in-first-out </item>
        /// 		<item>1 / StoreItemCostingType.LIFO: Last-in-first-out</item>
        /// 		<item>3 / StoreItemCostingType.StandardCosting: Standard costing</item>
        /// 		<item>4 / StoreItemCostingType.AverageCosting: Average costing</item>
        /// 	</list>
        /// </summary>
        public abstract int? CostingType { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value to indicate whether this item is checked for low-inventory.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 / StoreItemType.Stocked: If the quantity for this item falls below threshold, it can be re-ordered.</item>
        /// 		<item>1 / StoreItemType.NonStocked: This item will never be re-ordered even if it falls to zero.</item>
        /// 	</list>
        /// </summary>
        public abstract int? ItemType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the standard unit price of this 
        /// item applicable if the costing type is Standard Costing.
        /// </summary>
        public abstract decimal? StandardCostingUnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity to re-order if the 
        /// quantity of this item falls below threshold.
        /// </summary>
        /// 
        public abstract decimal? ReorderDefault { get; set; }

        /// <summary>
        /// [Column] Gets or sets the threshold, so that if the 
        /// quantity of this item in the store falls below this threshold, 
        /// it is considered to be low, and a re-order can take place.
        /// </summary>
        public abstract decimal? ReorderThreshold { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that represents the 
        /// catalogue the item in this record belongs to.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents the store
        /// that this store item record belongs to.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets a one-to-many list of O objects that represents a list of 
        /// transactions for the items of this record's catalogue in this store.
        /// </summary>
        public abstract DataList<OStoreItemTransaction> StoreItemTransactions { get; }



        //----------------------------------------------------------------
        /// <summary>
        /// Disallow removing from the store if:
        /// <para></para>
        /// 1. There are transactions against the store item. 
        /// <para></para>
        /// Returns true if deactivable, false otherwise. The 
        /// UIGridview makes use of this field to hide and show the
        /// DeleteObject button accordingly.
        /// </summary>
        /// <returns>
        /// </returns>
        //----------------------------------------------------------------
        public override bool IsRemovable()
        {
            if ((int)TablesLogic.tStoreItemTransaction.Select(
                TablesLogic.tStoreItemTransaction.ObjectID.Count())
                .Where(
                TablesLogic.tStoreItemTransaction.IsDeleted == 0 &
                TablesLogic.tStoreItemTransaction.StoreItemID == this.ObjectID) > 0)
                return false;

            return true;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Checks to see if the store bin with the specified storeBinId
        /// has any items currently held in the bin.
        /// </summary>
        /// <param name="storeBinId"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static bool HasItems(Guid storeItemId)
        {
            OStoreItem item = TablesLogic.tStoreItem[storeItemId];
            if (item == null)
                return false;

            return TablesLogic.tStoreBinItem[
                TablesLogic.tStoreBinItem.StoreBin.StoreID == item.StoreID &
                TablesLogic.tStoreBinItem.CatalogueID == item.CatalogueID &
                TablesLogic.tStoreBinItem.PhysicalQuantity > 0].Count > 0;
        }



        //----------------------------------------------------------------
        /// <summary>
        /// Gets the localized costing type text for display on-screen.
        /// </summary>
        //----------------------------------------------------------------
        public string CostingTypeText
        {
            get
            {
                if (CostingType == StoreItemCostingType.FIFO)
                    return Resources.Strings.CostingType_FIFO;
                else if (CostingType == StoreItemCostingType.LIFO)
                    return Resources.Strings.CostingType_LIFO;
                else if (CostingType == StoreItemCostingType.Expiry)
                    return Resources.Strings.CostingType_Expiry;
                else if (CostingType == StoreItemCostingType.StandardCosting)
                    return Resources.Strings.CostingType_StandardCosting;
                else if (CostingType == StoreItemCostingType.AverageCosting)
                    return Resources.Strings.CostingType_AverageCosting;
                return "";
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Gets the localized item type text for display on-screen.
        /// </summary>
        //----------------------------------------------------------------
        public string ItemTypeText
        {
            get
            {
                if (ItemType == StoreItemType.Stocked)
                    return Resources.Strings.ItemType_Stocked;
                else if (ItemType == StoreItemType.NonStocked)
                    return Resources.Strings.ItemType_NonStocked;
                else if (ItemType == StoreItemType.SpecialOrder)
                    return Resources.Strings.ItemType_SpecialOrder;
                return "";
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Gets the total physical quantity of this item in this store.
        /// </summary>
        //----------------------------------------------------------------
        public decimal TotalPhysicalQuantity
        {
            get
            {
                return (decimal) Query.Select( 
                    TablesLogic.tStoreBinItem.PhysicalQuantity.Sum())
                    .Where(
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.StoreBin.StoreID == this.StoreID &
                    TablesLogic.tStoreBinItem.CatalogueID == this.CatalogueID &
                    TablesLogic.tStoreBinItem.PhysicalQuantity > 0);
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Gets the total physical quantity of this item in this store.
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
                    TablesLogic.tStoreBinItem.StoreBin.StoreID == this.StoreID &
                    TablesLogic.tStoreBinItem.CatalogueID == this.CatalogueID &
                    TablesLogic.tStoreBinItem.PhysicalQuantity > 0);
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Gets the total available quantity of this item in this store.
        /// </summary>
        //----------------------------------------------------------------
        public decimal TotalAvailableQuantity
        {
            get
            {
                decimal a = (decimal)Query.Select(
                    TablesLogic.tStoreBinItem.PhysicalQuantity.Sum())
                    .Where(
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.StoreBin.StoreID == this.StoreID &
                    TablesLogic.tStoreBinItem.CatalogueID == this.CatalogueID &
                    TablesLogic.tStoreBinItem.PhysicalQuantity > 0) 
                    -
                    (decimal)Query.Select(
                    TablesLogic.tStoreBinReservation.BaseQuantityReserved.Sum())
                    .Where(
                    TablesLogic.tStoreBinReservation.IsDeleted == 0 &
                    TablesLogic.tStoreBinReservation.StoreBin.StoreID == this.StoreID &
                    TablesLogic.tStoreBinReservation.CatalogueID == this.CatalogueID &
                    TablesLogic.tStoreBinReservation.BaseQuantityReserved > 0);

                return (a < 0) ? 0 : a;
            }
        }


        public DataTable StoreItemBatch
        {
            get
            {
                return (DataTable)Query.Select(
                    TablesLogic.tStoreBinItem.ObjectID,
                    TablesLogic.tStoreBinItem.ObjectName,
                    TablesLogic.tStoreBinItem.Equipment.ObjectName.As("Equipment"),
                    TablesLogic.tStoreBinItem.Catalogue.ObjectName.As("Catalogue"),
                    TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                    TablesLogic.tStoreBinItem.LotNumber,
                    TablesLogic.tStoreBinItem.BatchDate,
                    TablesLogic.tStoreBinItem.ExpiryDate,
                    TablesLogic.tStoreBinItem.UnitPrice,
                    TablesLogic.tStoreBinItem.PhysicalQuantity,
                    (TablesLogic.tStoreBinItem.PhysicalQuantity * TablesLogic.tStoreBinItem.UnitPrice).As("PhysicalCost"))
                    .Where(
                    TablesLogic.tStoreBinItem.IsDeleted == 0 &
                    TablesLogic.tStoreBinItem.CatalogueID == this.CatalogueID &
                    TablesLogic.tStoreBinItem.StoreBin.StoreID == this.StoreID &
                    TablesLogic.tStoreBinItem.PhysicalQuantity > 0);
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Checks if the inventory level (available quantity)
        /// has fallen below the reorder threshold.
        /// </summary>
        //----------------------------------------------------------------
        public bool HasLowInventory
        {
            get
            {
                if (ReorderThreshold != null && 
                    TotalAvailableQuantity <= ReorderThreshold)
                    return true;
                return false;
            }
        }


        /// <summary>
        /// A flag that indicates if the inventory level
        /// of this item has fallen below the reorder threshold.
        /// <para></para>
        /// NOTE: This flag is updated only by the OStore.DetermineLowInventory()
        /// method.
        /// </summary>
        public bool IsLowInventory;


        /// <summary>
        /// Overrides the saving method to update the StoreBinItems
        /// with the same CatalogueID as this StoreItem to update their
        /// unit prices, if the Costing Type of this StoreItem has 
        /// been set up as Standard Costing.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            if (this.CostingType == StoreItemCostingType.StandardCosting)
            {
                List<OStoreBinItem> storeBinItems = 
                    TablesLogic.tStoreBinItem.LoadList(
                    TablesLogic.tStoreBinItem.CatalogueID == this.CatalogueID &
                    TablesLogic.tStoreBinItem.StoreBin.StoreID == this.StoreID);

                foreach (OStoreBinItem storeBinItem in storeBinItems)
                {
                    storeBinItem.UnitPrice = this.StandardCostingUnitPrice;
                    storeBinItem.Save();
                }
            }
        }
    }


    /// <summary>
    /// Contains a set of values that enumerate the 
    /// various costing types supported by the system.
    /// </summary>
    public class StoreItemCostingType
    {
        /// <summary>
        /// First-in first-out.
        /// </summary>
        public const int FIFO = 0;

        /// <summary>
        /// Last-in first-out.
        /// </summary>
        public const int LIFO = 1;

        /// <summary>
        /// First-expire first-out. 
        /// </summary>
        public const int Expiry = 2;

        /// <summary>
        /// Standard costing.
        /// </summary>
        public const int StandardCosting = 3;

        /// <summary>
        /// Average costing.
        /// </summary>
        public const int AverageCosting = 4;
    }

    public class StoreItemType
    {
        public const int Stocked = 0;
        public const int NonStocked = 1;
        public const int SpecialOrder = 2;
    }
}
