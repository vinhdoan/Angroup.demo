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
    /// Summary description for OStoreItem
    /// </summary>
    [Database("#database"), Map("StoreCheckOut")]
    [Serializable]
    public partial class TStoreCheckOut : LogicLayerSchema<OStoreCheckOut>
    {
        public SchemaGuid StoreID;

        public SchemaText Description;

        [Default(0)]
        public SchemaInt DestinationType;
        public SchemaGuid UserID;
        public SchemaGuid WorkID;
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        [Default(0)]
        public SchemaInt IsCommitted;

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }

        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }

        public TUser User { get { return OneToOne<TUser>("UserID"); } }

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }

        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }

        public TStoreCheckOutItem StoreCheckOutItems { get { return OneToMany<TStoreCheckOutItem>("StoreCheckOutID"); } }
    }

    /// <summary>
    /// Represents a check-out form that contains a list of items that
    /// are to be checked out from a single store.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreCheckOut : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of the check-out.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the destination type.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 - StoreDestinationType.None: No destination</item>
        /// 		<item>1 - StoreDestinationType.User: Items are consumed by a user.</item>
        /// 		<item>2 - StoreDestinationType.Work: Items are consumed by a work.</item>
        /// 		<item>3 - StoreDestinationType.Location: Items are consumed by a location.</item>
        /// 		<item>4 - StoreDestinationType.Equipment: Items are consumed by a equipment.</item>
        /// 	</list>
        /// </summary>
        public abstract int? DestinationType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Work table that
        /// indicates the Work this check out is meant for.
        /// </summary>
        public abstract Guid? WorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table that
        /// indicates the User this check out is meant for.
        /// </summary>
        public abstract Guid? UserID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table.
        /// This is currently not used.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table.
        /// This is currently not used.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this check out has been committed.
        /// </summary>
        public abstract int? IsCommitted { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents the store
        /// items will be checked out from.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets or sets the OWork object that represents the work
        /// that this check out will be meant for. Note that using this
        /// module to check-out items will not automatically add a
        /// work cost into the work.
        /// </summary>
        public abstract OWork Work { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the user
        /// the items will be checked out to.
        /// </summary>
        public abstract OUser User { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents the
        /// location the items will be checked out to. This is
        /// currently not in use.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets or sets the OEquipment object that represents the
        /// location the items will be checked out to. This is
        /// currently not in use.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OStoreCheckOutItem objects that
        /// represents a list of items that will be checked out from
        /// the store once this object is committed.
        /// </summary>
        public abstract DataList<OStoreCheckOutItem> StoreCheckOutItems { get; }

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
                foreach (OStoreCheckOutItem item in this.StoreCheckOutItems)
                {
                    total += item.BaseQuantity.Value * item.EstimatedUnitCost.Value;
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
        /// Validates if there are sufficient items in the store for check-out before
        /// committing the checkout. Returns true if there are sufficient items in the
        /// store, false, if at least one item is insufficient.
        /// </summary>
        /// <returns></returns>
        public bool ValidateSufficientItemsForCheckout()
        {
            bool valid = true;

            // Build a hash table to contain the available quantiy of items
            // by store bin and catalogue.
            //
            Hashtable availableQuantity = new Hashtable();
            foreach (OStoreCheckOutItem item in StoreCheckOutItems)
            {
                if (item.StoreBinID != null && item.CatalogueID != null)
                {
                    string key = item.StoreBinID.ToString() + "," + item.CatalogueID.ToString();
                    if (availableQuantity[key] == null)
                    {
                        availableQuantity[key] =
                            Store.FindBin((Guid)item.StoreBinID).
                            GetTotalAvailableQuantity((Guid)item.CatalogueID); ;
                    }
                }
            }

            // Then we check the quantity to be checked out against
            // the available quantity in the hash table.
            //
            foreach (OStoreCheckOutItem item in StoreCheckOutItems)
            {
                item.Valid = true;

                if (item.StoreBinID != null && item.CatalogueID != null)
                {
                    // 2011 12 22 ptb
                    // Validate the quantity against the quantity reserved in WO
                    if (item.FromWorkCostID != null)
                    {
                        OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Load(
                           TablesLogic.tStoreBinReservation.WorkCostID == item.FromWorkCostID);

                        if (sbr == null || item.BaseQuantity.Value > sbr.BaseQuantityRequired)
                        {
                            item.Valid = false;
                            valid = false;
                        }
                    }
                    else
                    {
                        string key = item.StoreBinID.ToString() + "," + item.CatalogueID.ToString();
                        decimal newAvailableQuantity = (decimal)availableQuantity[key] - item.BaseQuantity.Value;
                        availableQuantity[key] = newAvailableQuantity;
                        if (newAvailableQuantity < 0)
                        {
                            item.Valid = false;
                            valid = false;
                        }
                    }
                }
            }
            return valid;
        }

        /// <summary>
        /// Check if there is a duplicate item in the list check-out items. An
        /// item is duplicate if another item with the same selected Catalogue and Bin
        /// is in the list.
        ///
        /// Returns false if no duplicates are found.
        /// </summary>
        /// <returns></returns>
        public bool HasDuplicateCheckOutItem(OStoreCheckOutItem itemToTest)
        {
            foreach (OStoreCheckOutItem item in StoreCheckOutItems)
            {
                // KF BEGIN 2007.04.27
                if (item.ObjectID != itemToTest.ObjectID &&
                    item.StoreBinID == itemToTest.StoreBinID &&
                    item.CatalogueID == itemToTest.CatalogueID)
                    return true;
                // KF END
            }
            return false;
        }

        /// <summary>
        /// Commit the checkout and saves it to the database.
        /// </summary>
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (IsCommitted == 0)
                {
                    if (ValidateSufficientItemsForCheckout())
                    {
                        foreach (OStoreCheckOutItem item in StoreCheckOutItems)
                        {
                            Store.CheckOutItems((Guid)item.StoreBinID, (Guid)item.CatalogueID, (decimal)item.ActualQuantity,
                                (Guid)item.ActualUnitOfMeasureID, (int)this.DestinationType,
                                this.WorkID, this.UserID, this.LocationID, this.EquipmentID, item.ObjectID);
                        }
                    }
                    IsCommitted = 1;
                    this.Save();

                    //2011-12-09 ptb
                    //Clear the reserved items
                    foreach (OStoreCheckOutItem sti in this.StoreCheckOutItems)
                    {
                        OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Load(
                            TablesLogic.tStoreBinReservation.WorkCostID == sti.FromWorkCostID);
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

        ///// <summary>
        ///// Cancel the check-out and saves to the database.
        ///// </summary>
        //public void Cancel()
        //{
        //    using (Connection c = new Connection())
        //    {
        //        if (IsCommitted == 1)
        //        {
        //            foreach (OStoreCheckOutItem item in StoreCheckOutItems)
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
        /// Validates and checks that this check out can be cancelled,
        /// that is, there must be no other transactions other than
        /// the one created by the check out.
        /// </summary>
        public bool ValidateCancellable()
        {
            foreach (OStoreCheckOutItem item in StoreCheckOutItems)
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
            foreach (OStoreCheckOutItem checkOutItem in this.StoreCheckOutItems)
                storeBinIds.Add(checkOutItem.StoreBinID.Value);

            List<OStoreBin> lockedStoreBins = TablesLogic.tStoreBin.LoadList(
                TablesLogic.tStoreBin.ObjectID.In(storeBinIds) &
                TablesLogic.tStoreBin.IsLocked == 1);

            StringBuilder sb = new StringBuilder();
            foreach (OStoreBin lockedStoreBin in lockedStoreBins)
                sb.Append((sb.Length == 0 ? "" : ", ") + lockedStoreBin.ObjectName);
            return sb.ToString();
        }

        public string DestinationTypeText
        {
            get
            {
                switch (this.DestinationType)
                {
                    case StoreDestinationType.User:
                        return "User";
                    case StoreDestinationType.Work:
                        return "Work";
                    case StoreDestinationType.Location:
                        return "Location";
                    case StoreDestinationType.Equipment:
                        return "Equipment";
                    default:
                        return "None";
                }
            }
        }

        public string CheckOutToUser
        {
            get
            {
                if (DestinationType == StoreDestinationType.User && this.User != null)
                    return User.ObjectName;
                return "";
            }
        }
    }

    public class StoreDestinationType
    {
        public const int None = 0;
        public const int User = 1;
        public const int Work = 2;
        public const int Location = 3;
        public const int Equipment = 4;
    }
}