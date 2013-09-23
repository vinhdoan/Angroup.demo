//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("PurchaseRequest")]
    [Serializable] public partial class TPurchaseRequest : LogicLayerSchema<OPurchaseRequest>
    {
        [Size(255)]
        public SchemaString Description;
        public SchemaDateTime DateRequired;

        public SchemaGuid PurchaseAdministratorID;
        public SchemaGuid PurchaseRequestorID;
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        public SchemaGuid StoreID;

        [Size(255)]
        public SchemaString ShipToAddress;
        [Size(255)]
        public SchemaString ShipToAttention;
        [Size(255)]
        public SchemaString BillToAddress;
        [Size(255)]
        public SchemaString BillToAttention;

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TPurchaseRequestItem PurchaseRequestItems { get { return OneToMany<TPurchaseRequestItem>("PurchaseRequestID"); } }

        public TUser PurchaseAdministrator { get { return OneToOne<TUser>("PurchaseAdministratorID"); } }
        public TUser PurchaseRequestor { get { return OneToOne<TUser>("PurchaseRequestorID"); } }
    }


    /// <summary>
    /// Represents a purchase request object raised for procuring 
    /// materials or services.
    /// </summary>
    [Serializable]
    public abstract partial class OPurchaseRequest : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the description for this purchase
        /// request object.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the materials or 
        /// services are required.
        /// </summary>
        public abstract DateTime? DateRequired { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table 
        /// that indicates the purchase administrator to follow
        /// up with this request.
        /// </summary>
        public abstract Guid? PurchaseAdministratorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table 
        /// that indicates the requestor who raised this purchase
        /// request.
        /// </summary>
        public abstract Guid? PurchaseRequestorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table
        /// that indicates the location this purchase request is 
        /// intended for.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Equipment table
        /// that indicates the location this purchase request is 
        /// intended for.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table 
        /// that indicates the store this purchase request (for 
        /// materials) is intended for. 
        /// <para></para>
        /// If this WJ is generated from using the "Generate Low Inventory
        /// Purchase Request" from the Store module, this field will
        /// have a value.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the address to ship the materials
        /// or perform the services at.
        /// </summary>
        public abstract String ShipToAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the person in-charge who will
        /// attend to the receipt of the materials or services.
        /// </summary>
        public abstract String ShipToAttention { get; set; }

        /// <summary>
        /// [Column] Gets or sets the address to bill to.
        /// </summary>
        public abstract String BillToAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the person in-charge who will
        /// attend to the billing.
        /// </summary>
        public abstract String BillToAttention { get; set; }

        /// <summary>
        /// [Column] Gets or sets the budget distribution mode.
        /// <para></para>
        /// <list>
        ///     <item>0 - Budget Distribution by Entire WJ. </item>
        ///     <item>1 - Budget Distribution by WJ line items. </item>
        /// </list>
        /// <para></para>
        /// Note that when the budget distribution is by an entire
        /// WJ, then the user will be allowed to copy only the entire
        /// WJ to a new RFQ/PO, but will not be allowed to copy 
        /// individual line items to a RFQ/PO.
        /// </summary>
        public abstract int? BudgetDistributionMode { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating that the
        /// purchase request has been committed.
        /// </summary>
        public abstract int? IsCommitted { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents
        /// the location this purchase request is intended for.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets or sets the OEquipment object that represents
        /// the equipment this purchase request is intended for.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents
        /// the store this purchase request (for materials) 
        /// is intended for.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseRequestItem objects that represents
        /// a list of materials or services requested.
        /// </summary>
        public abstract DataList<OPurchaseRequestItem> PurchaseRequestItems { get; }

        /// <summary>
        /// Gets or sets the OUser object that represents
        /// the purchase administrator to follow
        /// up with this request.
        /// </summary>
        public abstract OUser PurchaseAdministrator { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents
        /// the requestor who raised this purchase request.
        /// </summary>
        public abstract OUser PurchaseRequestor { get; set; }


        /// <summary>
        /// Gets the location indicated by this purchase request.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> taskLocations = new List<OLocation>();
                if (this.LocationID != null)
                    taskLocations.Add(this.Location);
                return taskLocations;
            }
        }

        /// <summary>
        /// Gets the equipment indicated by this purchase request.
        /// </summary>
        public override List<OEquipment> TaskEquipments
        {
            get
            {
                List<OEquipment> taskEquipments = new List<OEquipment>();
                if (this.EquipmentID != null)
                    taskEquipments.Add(this.Equipment);
                return taskEquipments;
            }
        }


        /// <summary>
        /// Gets the task amount of this purchase request.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                decimal? taskAmount = 0;
                foreach (OPurchaseRequestItem prItem in this.PurchaseRequestItems)
                    taskAmount += prItem.UnitPrice * prItem.QuantityRequired;

                if (taskAmount != null)
                    return taskAmount.Value;
                return 0;
            }
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Called just before the object is saved.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            this.ObjectName = this.Description;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Deactivate all purchase request line items, when this 
        /// purchase request is deactivated.
        /// </summary>
        /// --------------------------------------------------------------
        //public override void Deactivating()
        //{
        //    base.Deactivating();

        //    foreach (OPurchaseRequestItem item in this.PurchaseRequestItems)
        //        item.Deactivate();
        //}

        /// --------------------------------------------------------------
        /// <summary>
        /// Re-order the list of items in the checklist response set.
        /// </summary>
        /// <param name="i"></param>
        /// --------------------------------------------------------------
        public void ReorderItems(OPurchaseRequestItem p)
        {
            Global.ReorderItems(PurchaseRequestItems, p, "ItemNumber");
        }


        /// <summary>
        /// Validates that the list of purchase request line item numbers
        /// and descriptions that have not been generated into RFQs or POs.
        /// </summary>
        /// <param name="purchaseRequestItemIds"></param>
        /// <returns></returns>
        public static string ValidatePRLineItemsNotGeneratedToRFQOrPO(List<Guid> purchaseRequestItemIds)
        {
            StringBuilder sb = new StringBuilder();

            // Gets a list of all WJ item numbers that have been generated
            // into RFQs.
            //
            TRequestForQuotationItem rfqItem = TablesLogic.tRequestForQuotationItem;
            DataTable dt = rfqItem.Select(
                rfqItem.PurchaseRequestItem.ItemNumber,
                rfqItem.PurchaseRequestItem.ItemDescription)
                .Where(
                rfqItem.RequestForQuotation.CurrentActivity.ObjectName != "Cancelled" &
                rfqItem.PurchaseRequestItemID.In(purchaseRequestItemIds) &
                rfqItem.IsDeleted == 0);
            foreach (DataRow dr in dt.Rows)
                sb.Append(dr["ItemNumber"].ToString() + ". " + dr["ItemDescription"].ToString() + "<br/>");

            // Gets a list of all WJ item numbers that have been generated
            // into POs.
            //
            TPurchaseOrderItem poItem = TablesLogic.tPurchaseOrderItem;
            dt = poItem.Select(
                poItem.PurchaseRequestItem.ItemNumber,
                poItem.PurchaseRequestItem.ItemDescription)
                .Where(
                poItem.PurchaseOrder.CurrentActivity.ObjectName != "Cancelled" &
                poItem.PurchaseRequestItemID.In(purchaseRequestItemIds) &
                poItem.IsDeleted == 0);
            foreach (DataRow dr in dt.Rows)
                sb.Append(dr["ItemNumber"].ToString() + ". " + dr["ItemDescription"].ToString() + "<br/>");

            return sb.ToString();
        }
        public List<OActivityHistory> PRStatusHistory
        {
            get
            {
                List<OActivityHistory> statusHistory = TablesLogic.tActivityHistory.LoadList(
                                                       TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID);
                return statusHistory;
            }
        }
    }




    /// <summary>
    /// Represents the different types of budget distribution
    /// available for all 
    /// </summary>
    public class BudgetDistribution
    {
        /// <summary>
        /// Distribute the budget by the entire amount.
        /// </summary>
        public const int EntireAmount = 0;

        /// <summary>
        /// Distribute the budget by line items.
        /// </summary>
        public const int LineItem = 1;
    }
}
