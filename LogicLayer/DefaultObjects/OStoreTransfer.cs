//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStoreTransfer
    /// </summary>
    [Database("#database"), Map("StoreTransfer")]
    [Serializable]
    public partial class TStoreTransfer : LogicLayerSchema<OStoreTransfer>
    {
        [Default(0)]
        public SchemaInt FromStoreType;
        public SchemaGuid FromLocationID;
        public SchemaGuid FromStoreID;
        [Default(0)]
        public SchemaInt ToStoreType;
        public SchemaGuid ToLocationID;
        public SchemaGuid ToStoreID;

        public SchemaText Description;
        [Default(0)]
        public SchemaInt IsCommitted;

        public TStore FromStore { get { return OneToOne<TStore>("FromStoreID"); } }

        public TStore ToStore { get { return OneToOne<TStore>("ToStoreID"); } }

        public TStoreTransferItem StoreTransferItems { get { return OneToMany<TStoreTransferItem>("StoreTransferID"); } }
    }

    /// <summary>
    /// Represents a transfer form that contains a list of items that
    /// are to be transfer from one store to another.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreTransfer : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets a flag indicating the
        /// type of the store items will be transferred from:
        /// <para>
        /// </para>
        /// <list>
        ///     <item>0 - Physical Store; </item>
        ///     <item>1 - Issue Location; </item>
        /// </list>
        /// </summary>
        public abstract int? FromStoreType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table
        /// that indicates the issue location to transfer items from.
        /// </summary>
        public abstract Guid? FromLocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table
        /// that indicates the store to transfer items from.
        /// </summary>
        public abstract Guid? FromStoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating the
        /// type of the store items will be transferred to:
        /// <para>
        /// </para>
        /// <list>
        ///     <item>0 - Physical Store; </item>
        ///     <item>1 - Issue Location; </item>
        /// </list>
        /// </summary>
        public abstract int? ToStoreType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table
        /// that indicates the issue location to transfer items to.
        /// </summary>
        public abstract Guid? ToLocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table
        /// that indicates the store to transfer items to.
        /// </summary>
        public abstract Guid? ToStoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of the transfer.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this transfer has been committed.
        /// </summary>
        public abstract int? IsCommitted { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents
        /// the store to transfer items from.
        /// </summary>
        public abstract OStore FromStore { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents
        /// the store to transfer items to.
        /// </summary>
        public abstract OStore ToStore { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OStoreTransferItem objects
        /// that represents the items to be transfer.
        /// </summary>
        public abstract DataList<OStoreTransferItem> StoreTransferItems { get; }

        /// <summary>
        /// Gets the list of locations associated with this task.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();

                if (this.CurrentActivity.ObjectName == "ApprovedForTransfer")
                {
                    if (this.ToStore != null && this.ToStore.Location != null)
                        locations.Add(this.ToStore.Location);
                }
                else
                {
                    if (this.FromStore != null && this.FromStore.Location != null)
                        locations.Add(this.FromStore.Location);
                    //if (this.ToStore != null && this.ToStore.Location != null)
                    //    locations.Add(this.ToStore.Location);
                }
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
                foreach (OStoreTransferItem item in this.StoreTransferItems)
                {
                    total += item.Quantity.Value * item.EstimatedUnitCost.Value;
                }
                return total;
            }
        }

        /// <summary>
        /// Gets the translated text of the from-store type.
        /// </summary>
        public string FromStoreTypeText
        {
            get
            {
                if (this.FromStoreType == StoreType.Storeroom)
                    return Resources.Strings.StoreType_Storeroom;
                else if (this.FromStoreType == StoreType.IssueLocation)
                    return Resources.Strings.StoreType_IssueLocation;
                return "";
            }
        }

        /// <summary>
        /// Gets the name of the store / location.
        /// </summary>
        public string FromStoreText
        {
            get
            {
                if (this.FromStoreType == StoreType.Storeroom)
                    return this.FromStore.ObjectName;
                else if (this.FromStoreType == StoreType.IssueLocation)
                    return this.FromStore.Location.FastPath;
                return "";
            }
        }

        /// <summary>
        /// Gets the translated text of the to-store type.
        /// </summary>
        public string ToStoreTypeText
        {
            get
            {
                if (this.ToStoreType == StoreType.Storeroom)
                    return Resources.Strings.StoreType_Storeroom;
                else if (this.ToStoreType == StoreType.IssueLocation)
                    return Resources.Strings.StoreType_IssueLocation;
                return "";
            }
        }

        /// <summary>
        /// Gets the name of the store / location.
        /// </summary>
        public string ToStoreText
        {
            get
            {
                if (this.ToStoreType == StoreType.Storeroom)
                    return this.ToStore.ObjectName;
                else if (this.ToStoreType == StoreType.IssueLocation)
                    return this.ToStore.Location.FastPath;
                return "";
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
        /// Check if there is a duplicate item in the list check-out items. An
        /// item is duplicate if another item with the same selected Catalogue and Bin
        /// is in the list.
        ///
        /// Returns false if no duplicates are found.
        /// </summary>
        /// <returns></returns>
        public bool HasDuplicateTransferItem(OStoreTransferItem itemToTest)
        {
            foreach (OStoreTransferItem item in StoreTransferItems)
            {
                if (item.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment)
                {
                    if (item.ObjectID != itemToTest.ObjectID &&
                        item.FromStoreBinID == itemToTest.FromStoreBinID &&
                        item.ToStoreBinID == itemToTest.ToStoreBinID &&
                        item.CatalogueID == itemToTest.CatalogueID &&
                        item.StoreBinItemID == itemToTest.StoreBinItemID)
                        return true;
                }
                else
                {
                    if (item.ObjectID != itemToTest.ObjectID &&
                        item.FromStoreBinID == itemToTest.FromStoreBinID &&
                        item.ToStoreBinID == itemToTest.ToStoreBinID &&
                        item.CatalogueID == itemToTest.CatalogueID)
                        return true;
                }
            }
            return false;
        }

        /// <summary>
        /// Validates that all items originate from the
        /// specified store and are to be transferred to
        /// the specified store.
        /// </summary>
        /// <returns></returns>
        public bool ValidateItemsFromAndToStore()
        {
            foreach (OStoreTransferItem item in StoreTransferItems)
            {
                if (item.FromStoreBin.StoreID != this.FromStoreID)
                    return false;
                if (item.ToStoreBin.StoreID != this.ToStoreID)
                    return false;
            }
            return true;
        }

        /// <summary>
        /// Validates if there are sufficient items in the store for transfer before
        /// committing the transfer. Returns true if there are sufficient items in the
        /// store, false, if at least one item is insufficient.
        /// </summary>
        /// <returns></returns>
        public bool ValidateSufficientItemsForTransfer()
        {
            bool valid = true;

            Hashtable h = new Hashtable();

            foreach (OStoreTransferItem item in StoreTransferItems)
            {
                item.Valid = true;

                if (item.FromStoreBinID != null && item.CatalogueID != null)
                {
                    string key = item.FromStoreBinID.Value.ToString() + "," + item.CatalogueID.Value.ToString();

                    if (h[key] == null)
                        h[key] = FromStore.FindBin((Guid)item.FromStoreBinID).GetTotalAvailableQuantity((Guid)item.CatalogueID);

                    if (item.Quantity > (decimal)h[key])
                    {
                        item.Valid = false;
                        valid = false;
                    }
                    else
                    {
                        h[key] = (decimal)h[key] - item.Quantity.Value;
                    }
                }
            }
            return valid;
        }

        /// <summary>
        /// Commits the transfer. Once this method is called, no items in the StoreTransferItems list
        /// should be modified.
        /// </summary>
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (IsCommitted == 0)
                {
                    foreach (OStoreTransferItem item in StoreTransferItems)
                    {
                        if (item.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment &&
                            item.StoreBinItemID != null)
                        {
                            // Transfer the equipment batch from one store to another.
                            //
                            ToStore.TransferEquipmentStoreBinItem(item.StoreBinItemID.Value, item.ToStoreBinID.Value, item.ObjectID);
                        }
                        else
                        {
                            // Transfer the consumable/non-consumable batch from
                            // one store to another. This is basically a process
                            // of checking out items from a store, and checking
                            // in items to another.
                            //
                            List<StoreCheckOutItemDetail> details = this.FromStore.TransferOutItems((Guid)item.FromStoreBinID, (Guid)item.CatalogueID,
                                (decimal)item.Quantity, (Guid)item.Catalogue.UnitOfMeasureID, this.FromStoreID, this.ToStoreID, item.ObjectID);

                            foreach (StoreCheckOutItemDetail detail in details)
                            {
                                StoreCheckInItemDetail cidetail = new StoreCheckInItemDetail();
                                cidetail.ExpiryDate = detail.ExpiryDate;
                                cidetail.LotNumber = detail.LotNumber;
                                cidetail.UnitPrice = (decimal)detail.UnitPrice;
                                cidetail.BaseQuantity = (decimal)detail.BaseQuantity;

                                this.ToStore.TransferInItems((Guid)item.ToStoreBinID, (Guid)item.CatalogueID, cidetail, this.FromStoreID, this.ToStoreID, item.ObjectID);
                            }
                        }
                    }

                    // Logic to release the store item reservations.
                    foreach (OStoreTransferItem sti in this.StoreTransferItems)
                    {
                        OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Load(
                            TablesLogic.tStoreBinReservation.StoreTransferItemID == this.ObjectID);
                        if (sbr != null)
                        {
                            sbr.BaseQuantityRequired = 0;
                            sbr.Save();
                            sbr.Deactivate();
                        }
                    }

                    IsCommitted = 1;
                    this.Save();
                }
                c.Commit();
            }
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
                    foreach (OStoreTransferItem item in StoreTransferItems)
                    {
                        foreach (OStoreItemTransaction storeItemTransaction in
                            OStoreItemTransaction.GetTransactionsAssociatedWithSourceObject(item))
                            storeItemTransaction.ReverseTransaction();
                    }
                    IsCommitted = 0;
                    this.Save();
                }
                else
                {
                    //2011-12-09 ptb
                    //Clear the reserved items upon Cancel
                    foreach (OStoreTransferItem sti in this.StoreTransferItems)
                    {
                        OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Load(
                            TablesLogic.tStoreBinReservation.StoreTransferItemID == this.ObjectID);
                        if (sbr != null)
                        {
                            sbr.BaseQuantityRequired = 0;
                            sbr.Save();
                            sbr.Deactivate();
                        }
                    }
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
            foreach (OStoreTransferItem item in StoreTransferItems)
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
            foreach (OStoreTransferItem transferItem in this.StoreTransferItems)
            {
                storeBinIds.Add(transferItem.FromStoreBinID.Value);
                storeBinIds.Add(transferItem.ToStoreBinID.Value);
            }

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