//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStoreCheckIn
    /// Represent one check in batch of items into the store
    /// </summary>
    [Database("#database"), Map("StoreCheckIn")]
    [Serializable]
    public partial class TStoreCheckIn : LogicLayerSchema<OStoreCheckIn>
    {
        public SchemaGuid StoreID;
        public SchemaText Description;
        [Default(0)]
        public SchemaInt IsCommitted;

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }

        public TStoreCheckInItem CheckInItems { get { return OneToMany<TStoreCheckInItem>("StoreCheckInID"); } }
    }

    /// <summary>
    /// Represents a check-in form that contains a list of items that
    /// are to be checked in to a single store.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreCheckIn : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table
        /// that indicates the store to check items in to.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of this check in.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this check in has been committed.
        /// </summary>
        public abstract int? IsCommitted { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents the
        /// store items will be checked in to.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets a one-to-many list of O objects that represents
        /// a list of items that will be checked in.
        /// </summary>
        public abstract DataList<OStoreCheckInItem> CheckInItems { get; }

        /// <summary>
        /// Gets the list of locations associated with this task.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();

                if (this.Store != null)
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
                foreach (OStoreCheckInItem item in this.CheckInItems)
                {
                    total += item.Quantity.Value * item.UnitPrice.Value;
                }
                return total;
            }
        }

        /// <summary>
        /// Disallow delete if:
        /// <para></para>
        /// 1. The Check-In has been committed into the database.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (this.IsCommitted == 1)
                return false;
            return true;
        }

        /// <summary>
        /// Commit the check-in and saves to the database.
        /// Once this method is called, the CheckInItems list
        /// must not be modified.
        /// </summary>
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (IsCommitted == 0)
                {
                    foreach (OStoreCheckInItem item in CheckInItems)
                    {
                        StoreCheckInItemDetail detail = new StoreCheckInItemDetail();
                        detail.ExpiryDate = item.ExpiryDate;
                        detail.LotNumber = item.LotNumber;
                        detail.UnitPrice = (decimal)item.UnitPrice;
                        detail.BaseQuantity = (decimal)item.Quantity;

                        Store.CheckInNewItems((Guid)item.StoreBinID, (Guid)item.CatalogueID, detail, item.ObjectID);
                    }
                    IsCommitted = 1;
                    this.Save();
                }
                c.Commit();
            }
        }

        ///// <summary>
        ///// Cancel the check-in and saves to the database.
        ///// The cancellation can take place only if there are
        ///// no other transactions on the store bin items other
        ///// than the one that was created by the check in.
        ///// </summary>
        //public void Cancel()
        //{
        //    using (Connection c = new Connection())
        //    {
        //        if (IsCommitted == 1)
        //        {
        //            foreach (OStoreCheckInItem item in CheckInItems)
        //            {
        //                foreach (OStoreItemTransaction storeItemTransaction in
        //                    OStoreItemTransaction.GetTransactionsAssociatedWithSourceObject(item))
        //                    storeItemTransaction.ReverseTransaction();
        //            }
        //            IsCommitted = 0;
        //            this.Save();
        //        }
        //        c.Commit();
        //    }
        //}

        /// <summary>
        /// Validates and checks that this check in can be cancelled,
        /// that is, there must be no other transactions other than
        /// the one created by the check in.
        /// </summary>
        public bool ValidateCancellable()
        {
            foreach (OStoreCheckInItem item in CheckInItems)
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

        /// <summary>
        /// Validates that none of the bins are locked.
        /// <para></para>
        /// Returns a list of store bins that are locked.
        /// </summary>
        /// <returns></returns>
        public string ValidateBinsNotLocked()
        {
            List<Guid> storeBinIds = new List<Guid>();
            foreach (OStoreCheckInItem checkInItem in this.CheckInItems)
                storeBinIds.Add(checkInItem.StoreBinID.Value);

            List<OStoreBin> lockedStoreBins = TablesLogic.tStoreBin.LoadList(
                TablesLogic.tStoreBin.ObjectID.In(storeBinIds) &
                TablesLogic.tStoreBin.IsLocked == 1);

            StringBuilder sb = new StringBuilder();
            foreach (OStoreBin lockedStoreBin in lockedStoreBins)
                sb.Append((sb.Length == 0 ? "" : ", ") + lockedStoreBin.ObjectName);
            return sb.ToString();
        }
    }
}