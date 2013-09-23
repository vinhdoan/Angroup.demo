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
using System.Text;
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
    [Database("#database"), Map("StoreRequest")]
    [Serializable]
    public partial class TStoreRequest : LogicLayerSchema<OStoreRequest>
    {
        public SchemaGuid StoreID;
        public SchemaGuid UserID;

        [Size(255)]
        public SchemaString Remarks;

        [Default(0)]
        public SchemaInt DestinationType;

        [Default(0)]
        public SchemaInt IsReserved;

        [Default(0)]
        public SchemaInt IsCheckedOuted;

        [Default(0)]
        public SchemaInt IsReturned;
        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TStoreRequestItem StoreRequestItems { get { return OneToMany<TStoreRequestItem>("StoreRequestID"); } }        
    }


    /// <summary>
    /// </summary>
    [Serializable]
    public abstract class OStoreRequest : LogicLayerPersistentObject , IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract Guid? StoreID { get; set; }
        public abstract Guid? UserID { get; set; }
        public abstract string Remarks { get; set; }
        public abstract int? DestinationType { get; set; }
        public abstract int? IsReserved { get; set; }
        public abstract int? IsCheckedOuted { get; set; }
        public abstract int? IsReturned { get; set; }
        public abstract OStore Store { get; set; }
        public abstract DataList<OStoreRequestItem> StoreRequestItems { get; set; }
                
        public override void Deactivating()
        {
            base.Deactivating();
            ClearReservations();
        }

        public override void Saving()
        {
            base.Saving();           
        }
        
        // disable delete once reservation has been made
        public override bool IsDeactivatable()
        {
            return IsReserved == 0;
        }

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
                foreach (OStoreRequestItem item in this.StoreRequestItems)
                {
                    total += item.BaseQuantityReserved.Value * item.EstimatedUnitCost.Value;
                }
                return total;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Lock and unreserve all store items currently set up in the 
        /// store request
        /// 
        /// Once this method is called, the application should not 
        /// update the store request anymore.
        /// </summary>
        /// --------------------------------------------------------------
        public void ClearReservations()
        {
            this.IsReserved = 0;
            foreach (OStoreRequestItem StoreRequestItem in this.StoreRequestItems)
            {
                if (StoreRequestItem.StoreBinID != null && StoreRequestItem.CatalogueID != null)
                {
                    if (StoreRequestItem.StoreBinReservation != null)
                    {
                        StoreRequestItem.StoreBinReservation.BaseQuantityRequired = 0;
                        StoreRequestItem.StoreBinReservation.Deactivate();
                    }
                }
            }
        }

        /// <summary>
        /// Validates if there are sufficient items in the store for check-out before
        /// committing the checkout. Returns true if there are sufficient items in the
        /// store, false, if at least one item is insufficient.
        /// </summary>
        /// <returns></returns>
        public bool ValidateSufficientItemsForRequest()
        {
            bool valid = true;

            // Build a hash table to contain the available quantiy of items
            // by store bin and catalogue.
            //
            Hashtable availableQuantity = new Hashtable();
            foreach (OStoreRequestItem item in StoreRequestItems)
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
            foreach (OStoreRequestItem item in StoreRequestItems)
            {
                item.Valid = true;

                if (item.StoreBinID != null && item.CatalogueID != null)
                {
                    string key = item.StoreBinID.ToString() + "," + item.CatalogueID.ToString();
                    decimal newAvailableQuantity = (decimal)availableQuantity[key] - item.BaseQuantityReserved.Value;
                    availableQuantity[key] = newAvailableQuantity;
                    if (newAvailableQuantity < 0)
                    {
                        item.Valid = false;
                        valid = false;
                    }
                }
            }
            return valid;
        }

        /// <summary>
        /// Validates if this item has sufficient amount for reserve/checkout.
        /// Returns true if there are sufficient items in the
        /// store, false, if it is insufficient.
        /// </summary>
        /// <returns></returns>
        public bool ValidateSufficientItemForRequest(OStoreRequestItem item)
        {
            bool valid = true;
            item.ComputeBaseQuantityReserved();
            decimal availableQuantity = Store.FindBin((Guid)item.StoreBinID).GetTotalAvailableQuantity((Guid)item.CatalogueID);
            decimal newAvailableQuantity = availableQuantity - item.BaseQuantityReserved.Value;
            if (newAvailableQuantity < 0)
            {
                item.Valid = false;
                valid = false;
            }
            return valid;            
        }

        /// <summary>
        /// Validates if the return amount exceed requested amount
        /// false, if at least one item is not valid.
        /// </summary>
        /// <returns></returns>
        public bool ValidateReturnAmount()
        {
            bool valid = true;
                        
            foreach (OStoreRequestItem item in StoreRequestItems)
            {
                item.ComputeBaseQuantityReturned();
                if (item.BaseQuantityReturned != null)
                {
                    item.Valid = (item.BaseQuantityReserved >= item.BaseQuantityReturned);
                    if (!item.Valid)
                        valid = false;
                }
            }           
            return valid;
        }

        /// <summary>
        /// Validates if the return amount exceed requested amount
        /// false, if at least one item is not valid.
        /// </summary>
        /// <returns></returns>
        public bool ValidateReturnAmount(OStoreRequestItem item)
        {
            bool valid = true;

            
            item.ComputeBaseQuantityReturned();
            if (item.BaseQuantityReturned != null)
            {
                item.Valid = (item.BaseQuantityReserved >= item.BaseQuantityReturned);
                if (!item.Valid)
                    valid = false;
            }
            
            return valid;
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
            foreach (OStoreRequestItem RequestItem in this.StoreRequestItems)
                storeBinIds.Add(RequestItem.StoreBinID.Value);

            List<OStoreBin> lockedStoreBins = TablesLogic.tStoreBin.LoadList(
                TablesLogic.tStoreBin.ObjectID.In(storeBinIds) &
                TablesLogic.tStoreBin.IsLocked == 1);

            StringBuilder sb = new StringBuilder();
            foreach (OStoreBin lockedStoreBin in lockedStoreBins)
                sb.Append((sb.Length == 0 ? "" : ", ") + lockedStoreBin.ObjectName);
            return sb.ToString();
        }

        /// <summary>
        /// Check if there is a duplicate item in the list check-out items. An
        /// item is duplicate if another item with the same selected Catalogue and Bin
        /// is in the list.
        /// 
        /// Returns false if no duplicates are found.
        /// </summary>
        /// <returns></returns>
        public bool HasDuplicateRequestItem(OStoreRequestItem itemToTest)
        {
            foreach (OStoreRequestItem item in StoreRequestItems)
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
        /// Reserve all items in this request.
        /// </summary>
        public void ReserveItems()
        {
            if (this.IsReserved == 0)
            {
                using (Connection c = new Connection())
                {
                    this.IsReserved = 1;
                    foreach (OStoreRequestItem i in this.StoreRequestItems)
                        i.HandleReservation();
                    this.Save();
                    c.Commit();
                }
            }
        }


        /// <summary>
        /// Check out all items in this request.
        /// </summary>
        public void CheckOutItems()
        {
            if (this.IsCheckedOuted == 0)
            {
                using (Connection c = new Connection())
                {
                    this.IsCheckedOuted = 1;
                    foreach (OStoreRequestItem i in this.StoreRequestItems)
                        i.HandleCheckOut();
                    this.Save();
                    c.Commit();
                }
            }
        }


        /// <summary>
        /// Returns items into the store.
        /// </summary>
        public void ReturnItems()
        {
            if (this.IsReturned == 0)
            {
                using (Connection c = new Connection())
                {
                    this.IsReturned = 1;
                    foreach (OStoreRequestItem i in this.StoreRequestItems)
                        i.HandleReturn();
                    this.Save();
                    c.Commit();
                }
            }
        }
    }

    
}
