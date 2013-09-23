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
    /// </summary>
    [Database("#database"), Map("StoreAdjust")]
    [Serializable] public partial class TStoreAdjust : LogicLayerSchema<OStoreAdjust>
    {
        public SchemaGuid StoreID;
        public SchemaGuid StoreStockTakeID;
        public SchemaText Description;
        [Default(0)]
        public SchemaInt IsCommitted;

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TStoreAdjustItem StoreAdjustItems { get { return OneToMany<TStoreAdjustItem>("StoreAdjustID"); } }
        public TStoreStockTake StoreStockTake { get { return OneToOne<TStoreStockTake>("StoreStockTakeID"); } }
    }


    /// <summary>
    /// Represents a store item adjustment form that contains a list of items that
    /// are to be adjusted to a single store. This can be used by the store
    /// manager to adjust his stock after a stock take finds additional or missing 
    /// stock.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreAdjust : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table
        /// that indicates the store where items will be adjusted.
        /// </summary>
        public abstract Guid? StoreID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreStockTake table
        /// that indicates which stock take generated this adjustment.
        /// </summary>
        public abstract Guid? StoreStockTakeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a description of the adjustment.
        /// </summary>
        public abstract string Description { get; set;}

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this adjustment has been committed.
        /// </summary>
        public abstract int? IsCommitted { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents
        /// the store where items will be adjusted.
        /// </summary>
        public abstract OStore Store { get; set; }


        /// <summary>
        /// Gets a one-to-many list of OStoreAdjustItem objects that 
        /// represents the list of items and their quantities to 
        /// be adjusted.
        /// </summary>
        public abstract DataList<OStoreAdjustItem> StoreAdjustItems { get; }

        /// <summary>
        /// Gets a reference to the OStoreStockTake table that represents
        /// the represents the stock take that generated this adjustment.
        /// </summary>
        public abstract OStoreStockTake StoreStockTake { get; }


        /// <summary>
        /// Gets the list of locations associated with this task.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();

                if (this.Store != null && this.Store.Location != null)
                    locations.Add(this.Store.Location);
                return locations;
            }
        }


        /// <summary>
        /// Gets the total amount of items that are to be checked in.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                decimal total = 0;
                foreach (OStoreAdjustItem item in this.StoreAdjustItems)
                    total += item.Quantity.Value * item.StoreBinItem.UnitPrice.Value;
                return total;
            }
        }

        /// <summary>
        /// Computes and returns the total cost of stock
        /// adjusted downwards.
        /// </summary>
        public decimal CostOfStockAdjustedUpwards
        {
            get
            {
                decimal total = 0;
                foreach (OStoreAdjustItem item in StoreAdjustItems)
                {
                    if (item.AdjustUp == 1 && item.Quantity != null)
                        total += (decimal)item.Quantity * (decimal)item.StoreBinItem.UnitPrice;
                }
                return total;
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Computes and returns the total cost of stock
        /// adjusted downwards.
        /// </summary>
        //----------------------------------------------------------------
        public decimal CostOfStockAdjustedDownwards
        {
            get
            {
                decimal total = 0;
                foreach (OStoreAdjustItem item in StoreAdjustItems)
                {
                    if (item.AdjustUp == 0 && item.Quantity != null)
                        total += (decimal)item.Quantity * (decimal)item.StoreBinItem.UnitPrice;
                }
                return total;
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Computes and returns the total cost of stock
        /// adjusted and any direction.
        /// </summary>
        //----------------------------------------------------------------
        public decimal CostOfStockAdjusted
        {
            get
            {
                decimal total = 0;
                foreach (OStoreAdjustItem item in StoreAdjustItems)
                {
                    if (item.Quantity != null)
                    {
                        if( item.AdjustUp==1 )
                            total += (decimal)item.Quantity * (decimal)item.StoreBinItem.UnitPrice;
                        else
                            total -= (decimal)item.Quantity * (decimal)item.StoreBinItem.UnitPrice;
                    }
                }
                return total;
            }
        }


        /// <summary>
        /// Disallow delete if:
        /// <para></para>
        /// 1. The Adjustment has been committed into the database.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (this.IsCommitted == 1)
                return false;
            return true;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Validates if there are sufficient items in the store for check-out before
        /// committing the checkout. Returns true if there are sufficient items in the
        /// store, false, if at least one item is insufficient.
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------
        public bool ValidateSufficientItemsForAdjustment()
        {
            bool valid = true;

            foreach (OStoreAdjustItem item in StoreAdjustItems)
            {
                item.Valid = true;

                if (item.StoreBinItemID != null)
                {
                    OStoreBinItem binItem = TablesLogic.tStoreBinItem[item.StoreBinItemID];

                    if (binItem == null || (binItem.PhysicalQuantity < item.Quantity && item.AdjustUp == 0))
                    {
                        item.Valid = false;
                        valid = false;
                    }
                }
            }
            return valid;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Check if a duplicate adjustment already exists. Returns
        /// true if so, false otherwise.
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public bool HasDuplicateAdjustItems(OStoreAdjustItem item)
        {
            foreach (OStoreAdjustItem adjustItem in StoreAdjustItems)
            {
                if (adjustItem.StoreBinItemID == item.StoreBinItemID &&
                    adjustItem.ObjectID != item.ObjectID)
                    return true;
            }
            return false;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Commits the transfer. Once this method is called, no items in the StoreTransferItems list
        /// should be modified.
        /// </summary>
        //----------------------------------------------------------------
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (IsCommitted == 0)
                {
                    foreach (OStoreAdjustItem item in StoreAdjustItems)
                    {
                        decimal adjustQty = 0;
                        if (item.AdjustUp == 1)
                            adjustQty = (decimal)item.Quantity;
                        else
                            adjustQty = -(decimal)item.Quantity;

                        OStoreBinItem binItem = TablesLogic.tStoreBinItem[item.StoreBinItemID];
                        binItem.AdjustQuantity(
                            adjustQty, null, StoreItemTransactionType.Adjust, StoreDestinationType.None,
                            null, null, null, null, null, null, item.ObjectID);
                    }
                    IsCommitted = 1;
                    this.Save();
                }
            }

            this.Save();
        }


        /// <summary>
        /// Cancel the check-in and saves to the database.
        /// The cancellation can take place only if there are
        /// no other transactions on the store bin items other
        /// than the one that was created by the check in.
        /// </summary>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                if (IsCommitted == 1)
                {
                    foreach (OStoreAdjustItem item in StoreAdjustItems)
                    {
                        foreach (OStoreItemTransaction storeItemTransaction in
                            OStoreItemTransaction.GetTransactionsAssociatedWithSourceObject(item))
                            storeItemTransaction.ReverseTransaction();
                    }
                    IsCommitted = 0;
                    this.Save();
                }

                c.Commit();
            }
        }


        /// <summary>
        /// Validates and checks that this check in can be cancelled,
        /// that is, there must be no other transactions other than
        /// the one created by the check in.
        /// </summary>
        public bool ValidateCancellable()
        {
            foreach (OStoreAdjustItem item in StoreAdjustItems)
            {
                // Load a list of transactions, each representing
                // one transaction on a OStoreBinItem. This is because
                // a check-out can affect more than one OStoreBinItem.
                // 
                List<OStoreItemTransaction> storeItemTransactions =
                     OStoreItemTransaction.GetTransactionsAssociatedWithSourceObject(item);

                if (storeItemTransactions.Count == 0)
                    return false;

                foreach (OStoreItemTransaction storeItemTransaction in storeItemTransactions)
                    if (storeItemTransaction.HasTransactionsThatOccuredAfterThis())
                        return false;
            }
            return true;
        }
    }
}
