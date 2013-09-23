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
    [Serializable]
    public partial class TRequestForQuotation : LogicLayerSchema<ORequestForQuotation>
    {
        public SchemaGuid CaseID;
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        public SchemaInt IsTermContract;
        [Size(255)]
        public SchemaString Description;
        public SchemaDateTime DateRequired;
        public SchemaDateTime DateEnd;

        public SchemaGuid PurchaseTypeID;
        public SchemaGuid PurchaseAdministratorID;
        public SchemaGuid StoreID;

        [Size(255)]
        public SchemaString ShipToAddress;
        [Size(255)]
        public SchemaString ShipToAttention;
        [Size(255)]
        public SchemaString BillToAddress;
        [Size(255)]
        public SchemaString BillToAttention;

        public SchemaText AwardedJustification;
        [Default(0)]
        public SchemaInt BudgetDistributionMode;
        public SchemaInt IsSubmittedForApproval;
        public SchemaInt IsApproved;
        public SchemaString ApprovalRemarks;

        [Default(0)]
        public SchemaInt MinimumNumberOfQuotationsPolicy;
        [Default(0)]
        public SchemaInt MinimumNumberOfQuotations;
        [Default(0)]
        public SchemaDecimal MinimumApplicableRFQAmount;
        [Default(0)]
        public SchemaInt BudgetValidationPolicy;

        public TCase Case { get { return OneToOne<TCase>("CaseID"); } }

        public TCode PurchaseType { get { return OneToOne<TCode>("PurchaseTypeID"); } }

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }

        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }

        public TRequestForQuotationItem RequestForQuotationItems { get { return OneToMany<TRequestForQuotationItem>("RequestForQuotationID"); } }

        public TRequestForQuotationVendor RequestForQuotationVendors { get { return OneToMany<TRequestForQuotationVendor>("RequestForQuotationID"); } }

        public TPurchaseBudget PurchaseBudgets { get { return OneToMany<TPurchaseBudget>("RequestForQuotationID"); } }

        public TPurchaseBudgetSummary PurchaseBudgetSummaries { get { return OneToMany<TPurchaseBudgetSummary>("RequestForQuotationID"); } }

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }

        public TUser PurchaseAdministrator { get { return OneToOne<TUser>("PurchaseAdministratorID"); } }
    }

    /// <summary>
    /// Represents a request for quotation that can be used to gather
    /// quotations from vendors.
    /// </summary>
    [Serializable]
    public abstract partial class ORequestForQuotation : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract Guid? CaseID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table
        /// that indicates the location this request for quotation is
        /// intended for.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Equipment table
        /// that indicates the location this request for quotation is
        /// intended for.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag to indicate that this Request
        /// for Quotation is for a term contract.
        /// </summary>
        public abstract int? IsTermContract { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description for this request
        /// for quotation object.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the materials or
        /// services are required.
        /// </summary>
        public abstract DateTime? DateRequired { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the
        /// required services should end.
        /// <para></para>
        /// This is applicable only if this Request for Quotation
        /// is for a term contract.
        /// </summary>
        public abstract DateTime? DateEnd { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates the purchase type.
        /// </summary>
        public abstract Guid? PurchaseTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table
        /// that indicates the purchase administrator to follow
        /// up with this request for quotation.
        /// </summary>
        public abstract Guid? PurchaseAdministratorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table
        /// that indicates the store the materials purchase are intended
        /// for.
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
        /// [Column] Gets or sets a description for the justifcation
        /// of the award of the purchase to a selected vendor.
        /// This is provided by the purchase administrator
        /// of this request for quotation.
        /// </summary>
        public abstract string AwardedJustification { get; set; }

        /// <summary>
        /// [Column] Gets or sets the budget distribution mode.
        /// <para></para>
        /// <list>
        ///     <item>0 - Budget Distribution by Entire RFQ. </item>
        ///     <item>1 - Budget Distribution by RFQ line items. </item>
        /// </list>
        /// <para></para>
        /// Note that when the budget distribution is by an entire
        /// RFQ, then the user will be allowed to copy only the entire
        /// RFQ to a new PO, but will not be allowed to copy
        /// individual line items to a new PO.
        /// </summary>
        public abstract int? BudgetDistributionMode { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating that the
        /// request for quotation has been submitted for approval.
        /// </summary>
        public abstract int? IsSubmittedForApproval { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating that the
        /// request for quotation has been approved.
        /// </summary>
        public abstract int? IsApproved { get; set; }

        /// <summary>
        /// [Column] Gets or sets a description for the
        /// approval of the award to a selected vendor.
        /// This is provided by the approver of this
        /// request for quotation.
        /// </summary>
        public abstract string ApprovalRemarks { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value indicating the policy
        /// of the system with respect to creating purchase orders
        /// from quotations.
        /// <para></para>
        /// <list>
        ///     <item>0 - A minimum number of quotations is not required.</item>
        ///     <item>1 - A minimum number of quotations is preferred. A warning is displayed if the minimum quotations is not satisfied.</item>
        ///     <item>2 - A minimum number of quotations is required. </item>
        /// </list>
        /// <para></para>
        /// </summary>
        public abstract int? MinimumNumberOfQuotationsPolicy { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum number of quotations
        /// required before a Purchase Order can be created from a
        /// Request for Quotation. This value must be more than
        /// or equals to 1. At the very least, there must be at
        /// least 1 quotation in a Request for Quotation before
        /// any Purchase Order can be created anyway.
        /// </summary>
        public abstract int? MinimumNumberOfQuotations { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum amount (inclusive)
        /// that will result in the minimum quotation policy taking effect.
        /// </summary>
        public abstract decimal? MinimumApplicableRFQAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value indicating
        /// the budget validation policy.
        /// <list>
        ///     <item>0 - Budget consumption must be equal to line items. (default) </item>
        ///     <item>1 - Budget consumption must be less than or equal to line items. </item>
        ///     <item>2 - No validation. </item>
        /// </list>
        /// </summary>
        public abstract int? BudgetValidationPolicy { get; set; }

        /// <summary>
        /// Gets or sets the reference to the OCase object
        /// that represents the case this request for quotation
        /// is associated with.
        /// </summary>
        public abstract OCase Case { get; set; }

        /// <summary>
        /// Gets or sets the Purchase Type object the represents
        /// the purchase type of this request for quotation.
        /// </summary>
        public abstract OCode PurchaseType { get; set; }

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
        /// Gets a one-to-many list of ORequestForQuotationItem objects that represents
        /// the list of request for quotation items that this request for quotation contains.
        /// </summary>
        public abstract DataList<ORequestForQuotationItem> RequestForQuotationItems { get; }

        /// <summary>
        /// Gets a one-to-many list of ORequestForQuotationVendor objects that represents
        /// the list of quotes provided by vendors.
        /// </summary>
        public abstract DataList<ORequestForQuotationVendor> RequestForQuotationVendors { get; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudget objects that represents
        /// the budget distribution for this request for quotation.
        /// </summary>
        public abstract DataList<OPurchaseBudget> PurchaseBudgets { get; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudgetSummary objects that represents
        /// information about this Purchase Request's commitment to the budgets.
        /// </summary>
        public abstract DataList<OPurchaseBudgetSummary> PurchaseBudgetSummaries { get; }

        /// <summary>
        /// Gets or sets the ORequestForQuotationVendor object that represents
        /// the awarded quotation.
        /// </summary>
        public abstract ORequestForQuotationVendor AwardedQuotation { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents
        /// the store the materials purchase are intended
        /// for.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents
        /// the purchase administrator to follow
        /// up with this request for quotation.
        /// </summary>
        public abstract OUser PurchaseAdministrator { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents
        /// the approver who will approve the quotation
        /// given by the selected vendor.
        /// </summary>
        public abstract OUser PurchaseApprover { get; set; }

        /// <summary>
        /// Determines if the number of vendors awarded to
        /// this quotation by counting the total number
        /// of distinct vendors for each item.
        /// </summary>
        /// <returns></returns>
        public int NumberOfAwardedVendors
        {
            get
            {
                Hashtable vendors = new Hashtable();
                foreach (ORequestForQuotationItem requestForQuotationItem in this.RequestForQuotationItems)
                    if (requestForQuotationItem.AwardedVendorID != null)
                        vendors[requestForQuotationItem.AwardedVendorID.Value] = 1;

                return vendors.Keys.Count;
            }
        }

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

        /*
        /// <summary>
        /// Gets the total awarded amount of this request for quotation.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                decimal? taskAmount = 0;

                foreach (ORequestForQuotationItem rfqItem in this.RequestForQuotationItems)
                    taskAmount += rfqItem.UnitPrice * rfqItem.QuantityProvided;

                if (taskAmount != null)
                    return taskAmount.Value;
                return 0;
            }
        }
        */

        /// <summary>
        /// Gets the total number of quotations returned by the vendors
        /// invited to quote for the job.
        /// </summary>
        public int NumberOfQuotations
        {
            get
            {
                int count = 0;
                foreach (ORequestForQuotationVendor rfqVendor in this.RequestForQuotationVendors)
                    if (rfqVendor.IsSubmitted == 1)
                        count++;
                return count;
            }
        }

        /// <summary>
        /// Gets the total number of vendors invited to quote for the job.
        /// </summary>
        public string NumberOfQuotationsVendors
        {
            get
            {
                int count1 = 0;
                int count2 = 0;
                foreach (ORequestForQuotationVendor rfqVendor in this.RequestForQuotationVendors)
                {
                    if (rfqVendor.IsSubmitted == 1)
                        count1++;
                    count2++;
                }
                return count1 + " / " + count2;
            }
        }

        /// <summary>
        /// Returns the text representing the
        /// budget distribution mode.
        /// </summary>
        public string BudgetDistributionModeText
        {
            get
            {
                if (this.BudgetDistributionMode == BudgetDistribution.EntireAmount)
                    return Resources.Strings.BudgetDistributionMode_Entire;
                else if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
                    return Resources.Strings.BudgetDistributionMode_LineItems;
                return "";
            }
        }

        /// <summary>
        /// A cached copy of the budget summary table that
        /// can be queried from the database
        /// </summary>
        private List<OPurchaseBudgetSummary> tempPurchaseBudgetSummaries;

        /// <summary>
        /// A cached copy of the budget summary table. This
        /// is a temporary list of the budget summaries that
        /// provides a snapshot of the budget accounts when
        /// the RFQ object is before the pending approval state.
        /// </summary>
        public List<OPurchaseBudgetSummary> TempPurchaseBudgetSummaries
        {
            get
            {
                return tempPurchaseBudgetSummaries;
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

            if (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            {
                //this.ObjectName = this.Campaign + "/" + this.Description;
                string itemDescription = "";
                if (this.RequestForQuotationItems.Count > 0)
                {
                    ORequestForQuotationItem item = this.RequestForQuotationItems.Find((r) => r.ItemNumber == 1);
                    if (item != null)
                        itemDescription = item.ItemDescription;
                }
                if (Description.Length + itemDescription.Length + 1 > 255)
                    itemDescription = itemDescription.Substring(0, 255 - Description.Length - 3 - 1) + "...";//1 for '/', 3 for '...'

                this.ObjectName = this.Description + (itemDescription != "" ? "/" + itemDescription : "");
            }
            else
            {
                this.ObjectName = this.Description;
                if (this.AwardedVendors != "")
                    this.ObjectName = String.Format("{0} ({1})", this.Description, this.AwardedVendors);
            }

            // 2011.07.08, Kien Trung
            // copy workID from rfq over to items
            // if this rfq generated from work.
            //
            if (this.Work != null)
            {
                foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
                {
                    item.WorkID = this.WorkID;
                }
            }
        }

        /// <summary>
        /// Computes the temporary list of budget
        /// summaries.
        /// </summary>
        public void ComputeTempBudgetSummaries()
        {
            List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
            OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null);
            tempPurchaseBudgetSummaries = OPurchaseBudgetSummary.CreateBudgetSummariesForSubmission(transactions);
        }

        /// <summary>
        /// Submits for Request for Quotation for approval by doing: <br/>
        /// 1. Creates the budget transaction logs. <br/>
        /// 2. Creates the budget summaries and stamp them with the current
        /// budget available balance. <br/>
        /// <para></para>
        /// This method is called from the RFQ workflow after. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void SubmitForApproval()
        {
            using (Connection c = new Connection())
            {
                if (this.IsSubmittedForApproval != 1)
                {
                    if (this.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired &&
                        this.BudgetDistributionMode != null)
                    {
                        OPurchaseBudget.CreateBudgetTransactionLogsAndSummaries(this.PurchaseBudgets, this.PurchaseBudgetSummaries, BudgetTransactionType.PurchasePendingApproval);
                    }
                    this.IsSubmittedForApproval = 1;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Approves the Request for Quotation by doing the following:<br/>
        /// 1. Update all budget transactions to indicated Approved.<br/>
        /// 2. Create budget summaries if not already created.<br/>
        /// 3. Stamp budget summaries with current budget balance at approval.<br/>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Approve()
        {
            using (Connection c = new Connection())
            {
                if (this.IsApproved != 1)
                {
                    if (this.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired &&
                        this.BudgetDistributionMode != null)
                    {
                        /*
                        // Create budget summaries if not already created.
                        //
                        if (this.PurchaseBudgetSummaries.Count == 0)
                        {
                            OPurchaseBudget.CreateBudgetTransactionLogsAndSummaries(
                                this.PurchaseBudgets, this.PurchaseBudgetSummaries, BudgetTransactionType.PurchasePendingApproval);
                        }
                         * */

                        // Update all budget transactions to indicated Approved.
                        //
                        List<OBudgetTransactionLog> transactions = OPurchaseBudget.SetBudgetTransactionLogsTransactionType(
                            this.PurchaseBudgets, BudgetTransactionType.PurchaseApproved);

                        // Stamp budget summaries with current budget balance at approval.
                        //
                        OPurchaseBudgetSummary.UpdateBudgetSummariesAfterApproval(transactions, this.PurchaseBudgetSummaries);
                    }
                    this.IsApproved = 1;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Rejects the Request for Quotation by doing the following:
        /// 1. Cancels all budget transactions.
        /// 2. Clears all budget summaries.
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Reject()
        {
            using (Connection c = new Connection())
            {
                if (this.IsSubmittedForApproval != 0)
                {
                    OPurchaseBudget.ClearBudgetTransactionLogs(this.PurchaseBudgets);
                    this.PurchaseBudgetSummaries.Clear();

                    this.IsSubmittedForApproval = 0;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Cancels the Request for Quotation by doing the following:
        /// 1. Unlink all RFQ line items from the WJ line items.
        /// 2. Cancel all budget transactions.
        /// <para></para>
        /// This method is called from the RFQ workflow after. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                // Unlink all RFQ line items from the WJ line items.
                //
                foreach (ORequestForQuotationItem rfqItem in this.RequestForQuotationItems)
                    rfqItem.PurchaseRequestItemID = null;

                // Cancel all budget transactions.
                //
                OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
                this.PurchaseBudgetSummaries.Clear();
                //this.CRVTenderCancelRFQSync();//Nguyen Quoc Phuong 29-Nov-2012

                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Closes the Request for Quotation by doing the following: <br/>
        /// 1. Cancels all budget transactions. <br/>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        public void Close()
        {
            using (Connection c = new Connection())
            {
                // Cancel all budget transactions.
                //
                OPurchaseBudget.ClearBudgetTransactionLogs(this.PurchaseBudgets);
                this.Save();

                // Close related case.
                //
                OCase.CloseCaseWhenAllDocumentsClosedOrCancelled(this.CaseID);

                c.Commit();
            }
            if(this.IsGroupWJ != 1 && !String.IsNullOrEmpty(this.CRVSerialNumber)) this.CRVTenderCloseRFQSync();//Nguyen Quoc Phuong 10-Dec-2012
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Deactivate all purchase request line items, when this
        /// purchase request is deactivated.
        /// <para></para>
        /// Then, releases all budgets.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Deactivating()
        {
            base.Deactivating();

            foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
                item.Deactivate();

            // Cancel all budget transactions.
            //
            OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
            this.PurchaseBudgetSummaries.Clear();
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Re-order the list of items in the checklist response set.
        /// </summary>
        /// <param name="i"></param>
        /// --------------------------------------------------------------
        public void ReorderItems(ORequestForQuotationItem p)
        {
            Global.ReorderItems(RequestForQuotationItems, p, "ItemNumber");
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Check if the vendor ID is duplicate in the list of
        /// RequestForQuotationVendors
        /// </summary>
        /// <param name="vendorId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool IsDuplicateVendorID(Guid vendorId)
        {
            foreach (ORequestForQuotationVendor rfqVendor in RequestForQuotationVendors)
            {
                if (rfqVendor.VendorID == vendorId)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Check if the vendor is duplicate in the list of
        /// RequestForQuotationVendors
        /// </summary>
        /// <param name="rfqVendor"></param>
        /// <returns></returns>
        public bool IsDuplicateVendor(ORequestForQuotationVendor rfqVendor)
        {
            foreach (ORequestForQuotationVendor rfqv in RequestForQuotationVendors)
            {
                if (rfqVendor.VendorID == rfqv.VendorID &&
                    rfqVendor.ObjectID != rfqv.ObjectID)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Gets a list of vendors who have submitted quotations.
        /// </summary>
        /// <returns></returns>
        public List<OVendor> GetVendorsWithSubmittedQuotations()
        {
            List<OVendor> vendors = new List<OVendor>();
            foreach (ORequestForQuotationVendor rfqVendor in this.RequestForQuotationVendors)
                if (rfqVendor.IsSubmitted == 1)
                    vendors.Add(rfqVendor.Vendor);

            vendors.Sort("ObjectName", true);
            return vendors;
        }

        public void AwardLineItemsToVendor(Guid vendorId, List<Guid> rfqItemIds)
        {
            AwardLineItemsToVendor(vendorId, rfqItemIds, null);
        }

        /// <summary>
        /// Awards the specified line items to the vendor.
        /// </summary>
        /// <param name="vendorId"></param>
        /// <param name="rfqItemIds"></param>
        public void AwardLineItemsToVendor(Guid vendorId, List<Guid> rfqItemIds, DateTime? AwardedDate)
        {
            ORequestForQuotationVendor rfqVendor =
                this.RequestForQuotationVendors.Find(v => v.VendorID == vendorId);

            if (rfqVendor != null)
            {
                foreach (Guid rfqItemId in rfqItemIds)
                {
                    ORequestForQuotationItem rfqItem = this.RequestForQuotationItems.Find(rfqItemId);

                    ORequestForQuotationVendorItem rfqVendorItem =
                        rfqVendor.RequestForQuotationVendorItems.Find((i) => i.RequestForQuotationItemID == rfqItemId);

                    if (rfqItem != null && rfqVendorItem != null)
                    {
                        rfqItem.CurrencyID = rfqVendorItem.CurrencyID;
                        rfqItem.AwardedRequestForQuotationVendorItemID = rfqVendorItem.ObjectID;
                        rfqItem.AwardedVendorID = vendorId;
                        rfqItem.UnitPrice = rfqVendorItem.UnitPrice;
                        rfqItem.UnitPriceInSelectedCurrency = rfqVendorItem.UnitPriceInSelectedCurrency;
                        rfqItem.QuantityProvided = rfqVendorItem.QuantityProvided;

                        // 2011.07.11, Kien Trung
                        // Updated: Addtional Fields for CCL
                        // ChargeAmount and RecoverableAmount
                        //
                        rfqItem.ChargeAmount = rfqVendorItem.ChargeAmount;
                        rfqItem.RecoverableAmount = rfqVendorItem.RecoverableAmount;
                        rfqItem.RecoverableAmountInSelectedCurrency = rfqVendorItem.RecoverableAmountInSelectedCurrency;

                        ////Nguyen Quoc Phuong 28-Nov-2012
                        ////Record Awarded Date to update CRV when submit for approveal
                        //rfqVendor.CRVAwardedDate = System.DateTime.Now;
                        ////End Nguyen Quoc Phuong 28-Nov-2012
                        //rfqItem.AwardedDate = AwardedDate;//Nguyen Quoc Phuong 29-Nov-2012
                        
                    }
                }

                if (this.NumberOfAwardedVendors > 1)
                    this.BudgetDistributionMode = BudgetDistribution.LineItem;
                this.UpdateApplicablePurchaseSettings();
            }
        }

        /// <summary>
        /// Clears the line items award.
        /// </summary>
        /// <param name="rfqItemIds"></param>
        public void ClearAwardLineItems(List<Guid> rfqItemIds)
        {
            foreach (Guid rfqItemId in rfqItemIds)
            {
                ORequestForQuotationItem rfqItem = this.RequestForQuotationItems.Find(rfqItemId);

                if (rfqItem != null)
                {
                    rfqItem.CurrencyID = null;
                    rfqItem.AwardedVendorID = null;
                    rfqItem.UnitPrice = null;
                    rfqItem.UnitPriceInSelectedCurrency = null;
                    rfqItem.QuantityProvided = null;

                    // 2011.07.11, Kien Trung
                    // updated additional fields for CCL
                    //
                    rfqItem.RecoverableAmount = null;
                    rfqItem.ChargeAmount = null;
                    //rfqItem.AwardedDate = null;//Nguyen Quoc Phuong 29-Nov-2012
                }
            }
        }

        /// <summary>
        /// Gets a flag indicating if any of the items in the
        /// in the quotation has been awarded.
        /// </summary>
        /// <returns></returns>
        public bool HasBeenAwarded()
        {
            foreach (ORequestForQuotationItem rfqItem in this.RequestForQuotationItems)
                if (rfqItem.AwardedVendorID != null)
                    return true;
            return false;
        }

        /// <summary>
        /// Adds items into the vendor quotation based on
        /// items defined in the request for quotation.
        /// </summary>
        /// <param name="rfqVendor"></param>
        /// <returns></returns>
        public void CreateRequestForQuotationVendorItems(ORequestForQuotationVendor rfqVendor)
        {
            foreach (ORequestForQuotationItem item in RequestForQuotationItems)
            {
                ORequestForQuotationVendorItem rfqVendorItem = TablesLogic.tRequestForQuotationVendorItem.Create();

                rfqVendorItem.ItemNumber = item.ItemNumber;
                rfqVendorItem.ItemType = item.ItemType;
                rfqVendorItem.ItemDescription = item.ItemDescription;
                rfqVendorItem.CatalogueID = item.CatalogueID;
                rfqVendorItem.FixedRateID = item.FixedRateID;
                rfqVendorItem.UnitOfMeasureID = item.UnitOfMeasureID;
                rfqVendorItem.CatalogueID = item.CatalogueID;
                rfqVendorItem.UnitPrice = 0.0M;
                rfqVendorItem.QuantityProvided = item.QuantityRequired;
                rfqVendorItem.ItemDiscount = 0.0M;
                rfqVendorItem.RequestForQuotationItemID = item.ObjectID;

                // 2011 05 03
                // Kien Trung bug fix
                // Set AwardedRequestForQuotationVendorItemID to
                // newly created vendor item objectid
                // if awardvendorid = rfqVendorid.
                //
                if (rfqVendor.VendorID == item.AwardedVendorID)
                    item.AwardedRequestForQuotationVendorItemID = rfqVendorItem.ObjectID;

                rfqVendor.RequestForQuotationVendorItems.Add(rfqVendorItem);
            }
        }

        /// <summary>
        /// Create a new request for quotation object, and copy all
        /// RFQ line items to the RequestForQuotationVendorItems
        /// </summary>
        public ORequestForQuotationVendor CreateRequestForQuotationVendor(Guid? vendorId)
        {
            ORequestForQuotationVendor rfqVendor = TablesLogic.tRequestForQuotationVendor.Create();

            OVendor vendor = TablesLogic.tVendor[vendorId];
            if (vendor != null)
            {
                rfqVendor.VendorID = vendorId;
                rfqVendor.ContactAddress = vendor.OperatingAddress;
                rfqVendor.ContactAddressCity = vendor.OperatingAddressCity;
                rfqVendor.ContactAddressCountry = vendor.OperatingAddressCountry;
                rfqVendor.ContactAddressState = vendor.OperatingAddressState;
                rfqVendor.ContactCellPhone = vendor.OperatingCellPhone;
                rfqVendor.ContactEmail = vendor.OperatingEmail;
                rfqVendor.ContactFax = vendor.OperatingFax;
                rfqVendor.ContactPhone = vendor.OperatingPhone;
                rfqVendor.ContactPerson = vendor.OperatingContactPerson;
                if (vendor.CurrencyID != null)
                    rfqVendor.CurrencyID = vendor.CurrencyID;
                else
                {
                    rfqVendor.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;
                    rfqVendor.ForeignToBaseExchangeRate = 1.0M;
                    rfqVendor.IsExchangeRateDefined = 1;
                }
            }

            CreateRequestForQuotationVendorItems(rfqVendor);
            return rfqVendor;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Create a single RFQ from a set of PRs
        /// </summary>
        /// <param name="prIds"></param>
        /// --------------------------------------------------------------
        public static ORequestForQuotation CreateRFQFromPRs(List<Guid> prIds)
        {
            return CreateRFQFromPRLineItems(TablesLogic.tPurchaseRequestItem[
                TablesLogic.tPurchaseRequestItem.PurchaseRequest.CurrentActivity.ObjectName == "Approved" &
                TablesLogic.tPurchaseRequestItem.PurchaseRequestID.In(prIds.ToArray()), null]);
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Create a single RFQ from a set of WJ line items and saves the
        /// RFQ into the database.
        /// </summary>
        /// <param name="prLineItems"></param>
        /// --------------------------------------------------------------
        public static ORequestForQuotation CreateRFQFromPRLineItems(List<OPurchaseRequestItem> items)
        {
            using (Connection c = new Connection())
            {
                if (items.Count == 0)
                    return null;

                OPurchaseRequest r = items[0].PurchaseRequest;
                ORequestForQuotation o = TablesLogic.tRequestForQuotation.Create();

                o.LocationID = r.LocationID;
                o.Description = r.Description;
                o.DateRequired = r.DateRequired;
                o.DateEnd = r.DateRequired;
                o.BillToAddress = r.BillToAddress;
                o.BillToAttention = r.BillToAttention;
                o.ShipToAddress = r.ShipToAddress;
                o.ShipToAttention = r.ShipToAttention;
                o.PurchaseAdministratorID = r.PurchaseAdministratorID;
                //tessa begin 2009.11.02 for capitaland
                o.Background = r.Background;
                o.Scope = r.Scope;
                //tessa end
                AddRFQLineItemsFromPRLineItems(o, items);

                // KF BEGIN 2007.05.21
                int count = o.RequestForQuotationItems.Count;
                // KF END

                o.TriggerWorkflowEvent("SaveAsDraft");
                o.Save();
                c.Commit();

                // KF BEGIN 2007.05.21
                //
                if (count == 0)
                    return null;
                else
                    return o;
                // KF END
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Add a set of WJ items into an RFQ.
        /// </summary>
        /// <param name="items"></param>
        /// --------------------------------------------------------------
        public static void AddRFQLineItemsFromPRLineItems(ORequestForQuotation rfq, List<OPurchaseRequestItem> items)
        {
            using (Connection c = new Connection())
            {
                int i = TablesLogic.tRequestForQuotationItem[
                    TablesLogic.tRequestForQuotationItem.RequestForQuotationID == rfq.ObjectID].Count + 1;

                // KF BEGIN 2007.05.09
                List<Guid> purchaseRequestIds = new List<Guid>();
                // KF END

                foreach (OPurchaseRequestItem item in items)
                {
                    if (item.RequestForQuotationItem == null && item.PurchaseOrderItem == null)
                    {
                        ORequestForQuotationItem n = TablesLogic.tRequestForQuotationItem.Create();

                        n.ItemNumber = i++;
                        n.ItemType = item.ItemType;
                        n.CatalogueID = item.CatalogueID;
                        n.FixedRateID = item.FixedRateID;
                        n.ItemDescription = item.ItemDescription;
                        n.UnitOfMeasureID = item.UnitOfMeasureID;
                        n.QuantityRequired = item.QuantityRequired;
                        n.PurchaseRequestItemID = item.ObjectID;
                        n.ReceiptMode = item.ReceiptMode;

                        rfq.RequestForQuotationItems.Add(n);

                        // KF BEGIN 2007.05.09
                        if (!purchaseRequestIds.Contains(item.PurchaseRequestID.Value))
                            purchaseRequestIds.Add(item.PurchaseRequestID.Value);
                        // KF END
                    }
                }
                rfq.Save();

                // KF BEGIN 2007.05.09
                // here we check and make sure that the purchase request is set to "CLOSED"
                // when all items have been copied to a purchase request/purchase order.
                //
                foreach (Guid purchaseRequestId in purchaseRequestIds)
                {
                    OPurchaseRequest purchaseRequest = TablesLogic.tPurchaseRequest[purchaseRequestId];
                    if (purchaseRequest != null)
                    {
                        bool isClosed = true;
                        foreach (OPurchaseRequestItem prItem in purchaseRequest.PurchaseRequestItems)
                            if (prItem.RequestForQuotationItem == null && prItem.PurchaseOrderItem == null)
                            {
                                isClosed = false;
                                break;
                            }
                        if (isClosed && purchaseRequest.CurrentActivity.ObjectName != "Close")
                        {
                            purchaseRequest.TriggerWorkflowEvent("Close");
                            purchaseRequest.Save();
                        }
                    }
                }
                // KF END

                c.Commit();
            }
        }

        /// <summary>
        /// Checks if there is at least one material item in the purchase.
        /// </summary>
        /// <returns></returns>
        public bool HasMaterialItems()
        {
            foreach (ORequestForQuotationItem i in this.RequestForQuotationItems)
                if (i.ItemType == PurchaseItemType.Material)
                    return true;
            return false;
        }

        /// <summary>
        /// Validates that there is sufficient amount in the budgets
        /// for the deduction.
        /// </summary>
        /// <returns>Returns a string of a list of budget periods and accounts
        /// that are insufficient. Returns an empty string otherwise.
        /// </returns>
        public string ValidateSufficientBudget()
        {
            List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
            return OBudgetPeriod.CheckSufficientBalance(
                OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null));
        }

        /// <summary>
        /// Gets the most applicable purchase settings and store it
        /// in a temporary variable.
        /// </summary>
        public void UpdateApplicablePurchaseSettings()
        {
            OPurchaseSettings purchaseSettings =
                OPurchaseSettings.GetPurchaseSettings(this.Location, this.PurchaseType, this.BudgetGroupID);

            if (purchaseSettings != null)
            {
                this.MinimumNumberOfQuotationsPolicy = purchaseSettings.MinimumNumberOfQuotationsPolicy;
                this.MinimumApplicableRFQAmount = purchaseSettings.MinimumApplicableRFQAmount;
                this.MinimumNumberOfQuotations = purchaseSettings.MinimumNumberOfQuotations;
                this.BudgetValidationPolicy = purchaseSettings.BudgetValidationPolicy;
            }
            else
            {
                this.MinimumNumberOfQuotationsPolicy = PurchasePolicy.NotRequired;
                this.MinimumApplicableRFQAmount = 0;
                this.MinimumNumberOfQuotations = 0;
                this.BudgetValidationPolicy = PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems;
            }
        }

        /// <summary>
        /// Validates that there are sufficient number of quotations
        /// for this request for qoutation.
        /// <para></para>
        /// This method returns
        /// <list>
        ///     <item>0 - if there is insufficient quotations.</item>
        ///     <item>1 - if there is sufficient quotations.</item>
        ///     <item>-1 - if there is insufficient quotations, and a warning will be shown.</item>
        /// </list>
        /// </summary>
        /// <returns></returns>
        public int ValidateSufficientNumberOfQuotations()
        {
            if (this.MinimumNumberOfQuotationsPolicy ==
                PurchasePolicy.NotRequired)
            {
                return 1;
            }
            else if (this.MinimumNumberOfQuotationsPolicy ==
                PurchasePolicy.Preferred)
            {
                if (this.TaskAmount < this.MinimumApplicableRFQAmount)
                    return 1;

                if (this.NumberOfQuotations >= this.MinimumNumberOfQuotations)
                    return 1;
                else
                    return -1;
            }
            else if (this.MinimumNumberOfQuotationsPolicy ==
                PurchasePolicy.Required)
            {
                if (this.TaskAmount < this.MinimumApplicableRFQAmount)
                    return 1;

                if (this.NumberOfQuotations >= this.MinimumNumberOfQuotations)
                    return 1;
                else
                    return 0;
            }
            return 1;
        }

        /// <summary>
        /// Updates the awarded items' unit price of all
        /// the RFQ items in this RFQ. This method should
        /// be called after the user updates the quotation
        /// of any of the vendors.
        /// </summary>
        public void UpdateVendorAwardedItemsUnitPrice()
        {
            Hashtable rfqItems = new Hashtable();
            foreach (ORequestForQuotationItem rfqItem in this.RequestForQuotationItems)
                rfqItems[rfqItem.ObjectID.Value] = rfqItem;

            foreach (ORequestForQuotationVendor rfqVendor in this.RequestForQuotationVendors)
            {
                foreach (ORequestForQuotationVendorItem rfqVendorItem in rfqVendor.RequestForQuotationVendorItems)
                {
                    ORequestForQuotationItem rfqItem = rfqItems[rfqVendorItem.RequestForQuotationItemID.Value] as ORequestForQuotationItem;
                    if (rfqItem != null && rfqItem.AwardedVendorID == rfqVendor.VendorID)
                    {
                        rfqItem.UnitPrice = rfqVendorItem.UnitPrice;
                        rfqItem.UnitPriceInSelectedCurrency = rfqVendorItem.UnitPriceInSelectedCurrency;
                        rfqItem.QuantityProvided = rfqVendorItem.QuantityProvided;

                        // 2011.07.10, Kien Trung
                        // update new fields: ChargeAmount, RecoverableAmount
                        // customized for CCL.
                        rfqItem.ChargeAmount = rfqVendorItem.ChargeAmount;
                        rfqItem.RecoverableAmount = rfqVendorItem.RecoverableAmount;
                        rfqItem.RecoverableAmountInSelectedCurrency = rfqVendorItem.RecoverableAmountInSelectedCurrency;

                        rfqItems.Remove(rfqVendorItem.RequestForQuotationItemID.Value);
                    }
                }
            }

            // Whatever RFQ items that is remaining in the list will be unawarded.
            //
            foreach (ORequestForQuotationItem rfqItem in rfqItems.Values)
            {
                rfqItem.CurrencyID = null;
                rfqItem.AwardedVendorID = null;
                rfqItem.UnitPrice = null;
                rfqItem.UnitPriceInSelectedCurrency = null;
                rfqItem.QuantityProvided = null;

                // 2011.07.10, Kien Trung
                // update new fields: ChargeAmount, RecoverableAmount
                // customized for CCL.
                rfqItem.ChargeAmount = null;
                rfqItem.RecoverableAmount = null;
                rfqItem.RecoverableAmountInSelectedCurrency = null;
            }
        }

        /// <summary>
        /// Validates that the budget amount is equals to the line
        /// item amount.
        /// <para></para>
        /// This function is generic and can be applied to any of
        /// the WJ/RFQ/PO objects provided the line items implement
        /// the ItemNumber and the Amount properties.
        /// </summary>
        /// <returns>Returns -1 if the validation succeeds. Returns 0 if
        /// the total WJ amount does not equal the budget amount .
        /// Returns any other number if that line number does
        /// not equal the budget amount</returns>
        //public int ValidateBudgetAmountEqualsLineItemAmount()
        //{
        //    // If the budget validation is not required, return -1
        //    // immediately to indicate the validation succeeded.
        //    //
        //    if (this.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired)
        //        return -1;

        //    if (this.BudgetDistributionMode != null)
        //    {
        //        // Find out the total amount by line items
        //        // or the entire WJ.
        //        //
        //        int maxItemNumber = 0;
        //        Hashtable totalLineItemAmounts = new Hashtable();
        //        foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
        //        {
        //            int itemNumber = 0;
        //            if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
        //                itemNumber = item.ItemNumber.Value;

        //            if (itemNumber > maxItemNumber)
        //                maxItemNumber = itemNumber;
        //            if (totalLineItemAmounts[itemNumber] == null)
        //                totalLineItemAmounts[itemNumber] = 0M;

        //            if (item.Subtotal != null)
        //                totalLineItemAmounts[itemNumber] =
        //                    (decimal)totalLineItemAmounts[itemNumber] + item.Subtotal.Value;
        //        }

        //        // Find out the total budgeted amount by line items
        //        // or the entire WJ.
        //        //
        //        Hashtable totalBudgetAmounts = new Hashtable();
        //        foreach (OPurchaseBudget prBudget in this.PurchaseBudgets)
        //        {
        //            int itemNumber = 0;
        //            if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
        //                itemNumber = prBudget.ItemNumber.Value;
        //            if (itemNumber > maxItemNumber)
        //                maxItemNumber = itemNumber;
        //            if (totalBudgetAmounts[itemNumber] == null)
        //                totalBudgetAmounts[itemNumber] = 0M;
        //            totalBudgetAmounts[itemNumber] =
        //                (decimal)totalBudgetAmounts[itemNumber] + prBudget.Amount.Value;
        //        }

        //        // Compare the line items and the budget totals
        //        // to ensure that they match.
        //        //
        //        for (int i = 0; i <= maxItemNumber; i++)
        //        {
        //            decimal totalLineItemAmount = totalLineItemAmounts[i] == null ? 0 : (decimal)totalLineItemAmounts[i];
        //            decimal totalBudgetAmount = totalBudgetAmounts[i] == null ? 0 : (decimal)totalBudgetAmounts[i];

        //            // Test based on the budget validation settings.
        //            //
        //            if (this.BudgetValidationPolicy == 0 && totalLineItemAmount != totalBudgetAmount)
        //                return i;
        //            if (this.BudgetValidationPolicy == 1 && totalLineItemAmount < totalBudgetAmount)
        //                return i;
        //        }
        //        return -1;
        //    }
        //    else
        //        return -1;
        //}

        /// <summary>
        /// Gets a datatable of the quotation items, grouped
        /// either by vendor, or by individual line items.
        /// </summary>
        /// <param name="groupByVendor"></param>
        /// <returns></returns>
        public DataTable GetVendorItems()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ObjectID", typeof(string));
            dt.Columns.Add("Vendor", typeof(string));
            dt.Columns.Add("Currency", typeof(string));
            dt.Columns.Add("ItemType", typeof(string));
            dt.Columns.Add("ItemNumber", typeof(string));
            dt.Columns.Add("ItemDescription", typeof(string));
            dt.Columns.Add("QuantityRequired", typeof(decimal));
            dt.Columns.Add("QuantityProvided", typeof(decimal));
            dt.Columns.Add("UnitPriceInSelectedCurrency", typeof(decimal));
            dt.Columns.Add("UnitPrice", typeof(decimal));
            dt.Columns.Add("IsAwarded", typeof(int));

            Hashtable ht = new Hashtable(100);
            foreach (ORequestForQuotationItem rfqItem in this.RequestForQuotationItems)
                ht[rfqItem.ObjectID.Value] = rfqItem;

            foreach (ORequestForQuotationVendor rfqVendor in this.RequestForQuotationVendors)
            {
                if (rfqVendor.IsSubmitted == 1)
                {
                    foreach (ORequestForQuotationVendorItem rfqVendorItem in rfqVendor.RequestForQuotationVendorItems)
                    {
                        ORequestForQuotationItem rfqItem = ht[rfqVendorItem.RequestForQuotationItemID.Value] as ORequestForQuotationItem;
                        dt.Rows.Add(
                            rfqVendorItem.ObjectID,
                            rfqVendor.Vendor.ObjectName,
                            rfqVendorItem.Currency.ObjectName,
                            rfqItem.ItemTypeText,
                            rfqItem.ItemNumber,
                            rfqItem.ItemDescription,
                            rfqItem.QuantityRequired,
                            rfqVendorItem.QuantityProvided,
                            rfqVendorItem.UnitPriceInSelectedCurrency,
                            rfqVendorItem.UnitPrice
                            );
                    }
                }
            }
            return dt;
        }

        /// <summary>
        /// Validates that the list of RFQ line item numbers and descriptions
        /// that have not been generated into POs.
        /// </summary>
        /// <param name="purchaseRequestItemIds"></param>
        /// <returns></returns>
        public static string ValidateRFQLineItemsNotGeneratedToPO(List<Guid> requestForQuotationItemIds)
        {
            StringBuilder sb = new StringBuilder();

            // Gets a list of all RFQ item numbers that have been generated
            // into POs.
            //
            TPurchaseOrderItem poItem = TablesLogic.tPurchaseOrderItem;
            DataTable dt = poItem.Select(
                poItem.RequestForQuotationItem.ItemNumber,
                poItem.RequestForQuotationItem.ItemDescription)
                .Where(
                poItem.PurchaseOrder.CurrentActivity.ObjectName != "Cancelled" &
                poItem.RequestForQuotationItemID.In(requestForQuotationItemIds) &
                poItem.IsDeleted == 0);
            foreach (DataRow dr in dt.Rows)
                sb.Append(dr["ItemNumber"].ToString() + ". " + dr["ItemDescription"].ToString() + "<br/>");

            return sb.ToString();
        }

        /// <summary>
        /// Validates that RFQs line items are awarded to exactly 1 vendor.
        /// </summary>
        /// <param name="rfqIds"></param>
        /// <returns></returns>
        public static bool ValidateRFQLineItemsAwardedToSingleVendor(List<Guid> requestForQuotationItemIds)
        {
            TRequestForQuotationItem rfqItem = TablesLogic.tRequestForQuotationItem;

            DataTable dt = rfqItem.SelectDistinct(rfqItem.AwardedVendorID)
                .Where(
                rfqItem.IsDeleted == 0 &

                // 2010.09.08
                // Kim Foong
                // Ignore those that are not awarded to a vendor.
                rfqItem.AwardedVendorID != null &

                rfqItem.ObjectID.In(requestForQuotationItemIds));

            if (dt.Rows.Count != 1)
                return false;
            else
                return true;
        }

        /// <summary>
        /// Validates that RFQs indicated by the list of RFQ IDs
        /// have the same case associated with them.
        /// <para></para>
        /// Returns a flag to indicate
        /// </summary>
        /// <param name="rfqIds"></param>
        public static bool ValidateRFQsHaveSameProperties(List<Guid> rfqIds)
        {
            TRequestForQuotation rfq = TablesLogic.tRequestForQuotation;

            DataTable dt = rfq.Select(
                rfq.CaseID,
                rfq.LocationID,
                rfq.EquipmentID,
                rfq.BudgetDistributionMode,
                rfq.IsTermContract,
                rfq.PurchaseTypeID,
                rfq.DateRequired,
                rfq.DateEnd)
                .Where(rfq.IsDeleted == 0 & rfq.ObjectID.In(rfqIds));

            Hashtable cases = new Hashtable();
            for (int i = 0; i < dt.Rows.Count - 1; i++)
            {
                DataRow dr = dt.Rows[i];
                DataRow dr2 = dt.Rows[i + 1];
                if (!dr["CaseID"].Equals(dr2["CaseID"]) ||
                    !dr["LocationID"].Equals(dr2["LocationID"]) ||
                    !dr["EquipmentID"].Equals(dr2["EquipmentID"]) ||
                    !dr["BudgetDistributionMode"].Equals(dr2["BudgetDistributionMode"]) ||
                    !dr["IsTermContract"].Equals(dr2["IsTermContract"]) ||
                    !dr["PurchaseTypeID"].Equals(dr2["PurchaseTypeID"]) ||
                    !dr["DateRequired"].Equals(dr2["DateRequired"]) ||
                    !dr["DateEnd"].Equals(dr2["DateEnd"])
                    )
                    return false;
            }

            return true;
        }

        /// <summary>
        /// Validates that RFQs indicated by the list of RFQ IDs
        /// that have been awarded.
        /// <para></para>
        /// Returns a list of RFQ numbers that have not been
        /// awarded.
        /// </summary>
        /// <param name="rfqIds"></param>
        /// <returns></returns>
        public static string ValidateRFQsAwarded(List<Guid> rfqIds)
        {
            TRequestForQuotation rfq = TablesLogic.tRequestForQuotation;

            DataTable dt = rfq.Select(rfq.ObjectNumber)
                .Where(rfq.IsDeleted == 0 & rfq.ObjectID.In(rfqIds) & rfq.CurrentActivity.ObjectName != "Awarded");

            StringBuilder sb = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
                sb.Append((sb.Length == 0 ? "" : ", ") + dr[0].ToString());

            return sb.ToString();
        }

        /// <summary>
        /// Validates that RFQs indicated by the list of RFQ IDs
        /// that have been awarded to a single vendor.
        /// <para></para>
        /// Returns a list of RFQ numbers that have not been
        /// awarded to a single vendor.
        /// </summary>
        /// <param name="rfqIds"></param>
        /// <returns></returns>
        public static string ValidateRFQsAwardedToSingleVendor(List<Guid> rfqIds)
        {
            TRequestForQuotation rfq = TablesLogic.tRequestForQuotation;

            DataTable dt = rfq.Select(rfq.ObjectNumber)
                .Where(rfq.IsDeleted == 0 & rfq.ObjectID.In(rfqIds) & rfq.CurrentActivity.ObjectName != "Awarded")
                .GroupBy(rfq.ObjectNumber)
                .Having(rfq.RequestForQuotationItems.AwardedVendorID.Count() > 1);

            StringBuilder sb = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
                sb.Append((sb.Length == 0 ? "" : ", ") + dr[0].ToString());

            return sb.ToString();
        }

        /// <summary>
        /// Validates to ensure that at least one item awarded to
        /// a vendor.
        /// </summary>
        /// <returns></returns>
        public bool ValidateAtLeastOneItemAwarded()
        {
            foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
            {
                if (item.AwardedVendorID != null)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// validates that if there are more than 1 RFQs, then
        /// the budget distribution mode must be by individual
        /// line items.
        /// </summary>
        /// <param name="rfqIds"></param>
        /// <returns></returns>
        public static string ValidateRFQsDistributionMode(List<Guid> rfqIds)
        {
            if (rfqIds.Count > 1)
            {
                TRequestForQuotation rfq = TablesLogic.tRequestForQuotation;

                DataTable dt =
                    rfq.Select(rfq.ObjectNumber)
                    .Where(rfq.IsDeleted == 0 & rfq.ObjectID.In(rfqIds) &
                    rfq.BudgetDistributionMode == BudgetDistribution.EntireAmount);

                StringBuilder sb = new StringBuilder();
                foreach (DataRow dr in dt.Rows)
                    sb.Append((sb.Length == 0 ? "" : ", ") + dr[0].ToString());

                return sb.ToString();
            }
            return "";
        }

        /// <summary>
        /// Computes the remaining budget amount that has not
        /// been created in the purchase budgets for the
        /// specified line item number.
        /// </summary>
        public decimal ComputeRemainingBudgetAmount(int? itemNumber)
        {
            decimal remaining = 0;

            decimal totalItems = 0;
            foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
                if (item.Subtotal != null)
                {
                    if (itemNumber == null ||
                        this.BudgetDistributionMode == BudgetDistribution.EntireAmount ||
                        item.ItemNumber == itemNumber)
                        totalItems += item.Subtotal.Value;
                }

            decimal totalBudgets = 0;
            foreach (OPurchaseBudget purchaseBudget in this.PurchaseBudgets)
            {
                if (purchaseBudget.Amount != null)
                {
                    if (itemNumber == null ||
                        this.BudgetDistributionMode == BudgetDistribution.EntireAmount ||
                        purchaseBudget.ItemNumber == itemNumber)
                        totalBudgets += purchaseBudget.Amount.Value;
                }
            }

            remaining = totalItems - totalBudgets;
            if (remaining < 0)
                remaining = 0;
            return remaining;
        }
    }
}