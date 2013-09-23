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
    [Database("#database"), Map("PurchaseOrder")]
    public partial class TPurchaseOrder : LogicLayerSchema<OPurchaseOrder>
    {
        public SchemaGuid CaseID;
        [Size(255)]
        public SchemaString Description;
        public SchemaInt IsTermContract;
        public SchemaGuid GeneratedTermContractID;
        public SchemaDateTime DateOfOrder;
        public SchemaDateTime DateRequired;
        public SchemaDateTime DateEnd;
        public SchemaGuid PurchaseTypeID;

        public SchemaGuid PurchaseAdministratorID;

        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        public SchemaGuid ContractID;

        public SchemaGuid StoreID;
        public SchemaGuid VendorID;
        public SchemaText FreightTerms;
        public SchemaText PaymentTerms;
        public SchemaString ContactAddressCountry;
        public SchemaString ContactAddressState;
        public SchemaString ContactAddressCity;
        [Size(255)]
        public SchemaString ContactAddress;
        public SchemaString ContactCellPhone;
        public SchemaString ContactEmail;
        public SchemaString ContactFax;
        public SchemaString ContactPhone;
        public SchemaString ContactPerson;
        [Size(255)]
        public SchemaString ShipToAddress;
        [Size(255)]
        public SchemaString ShipToAttention;
        [Size(255)]
        public SchemaString BillToAddress;
        [Size(255)]
        public SchemaString BillToAttention;

        public SchemaGuid CurrencyID;
        [Default(0)]
        public SchemaInt IsExchangeRateDefined;
        public SchemaDecimal ForeignToBaseExchangeRate;

        [Default(0)]
        public SchemaInt BudgetDistributionMode;
        public SchemaInt IsSubmittedForApproval;
        public SchemaInt IsApproved;

        [Default(0)]
        public SchemaInt RFQToPOPolicy;
        [Default(0)]
        public SchemaDecimal MinimumApplicablePOAmount;
        [Default(0)]
        public SchemaInt BudgetValidationPolicy;
        [Default(1)]
        public SchemaInt POMatchingType;
        [Default(0)]
        public SchemaInt IsPOAllowedClosure;

        public TContract GeneratedTermContract { get { return OneToOne<TContract>("GeneratedTermContractID"); } }

        public TCase Case { get { return OneToOne<TCase>("CaseID"); } }

        public TCode PurchaseType { get { return OneToOne<TCode>("PurchaseTypeID"); } }

        public TVendor Vendor { get { return OneToOne<TVendor>("VendorID"); } }

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }

        public TUser PurchaseAdministrator { get { return OneToOne<TUser>("PurchaseAdministratorID"); } }

        public TPurchaseOrderItem PurchaseOrderItems { get { return OneToMany<TPurchaseOrderItem>("PurchaseOrderID"); } }

        public TPurchaseOrderReceipt PurchaseOrderReceipts { get { return OneToMany<TPurchaseOrderReceipt>("PurchaseOrderID"); } }

        public TPurchaseBudget PurchaseBudgets { get { return OneToMany<TPurchaseBudget>("PurchaseOrderID"); } }

        public TPurchaseBudgetSummary PurchaseBudgetSummaries { get { return OneToMany<TPurchaseBudgetSummary>("PurchaseOrderID"); } }

        public TPurchaseInvoice PurchaseInvoices { get { return OneToMany<TPurchaseInvoice>("PurchaseOrderID"); } }

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }

        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }

        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }

        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
    }

    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseOrder : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Case table that represents the Case this
        /// Purchase Order is associated with.
        /// </summary>
        public abstract Guid? CaseID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description for this purchase
        /// order object.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating if this purchase
        /// order is for a term contract.
        /// </summary>
        public abstract int? IsTermContract { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Contract
        /// table that indicates the term contract generated
        /// by this Purchase Order upon approval.
        /// </summary>
        public abstract Guid? GeneratedTermContractID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date this purchase order was
        /// made.
        /// </summary>
        public abstract DateTime? DateOfOrder { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the materials or
        /// services are required.
        /// </summary>
        public abstract DateTime? DateRequired { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the
        /// required services should end.
        /// <para></para>
        /// This is applicable only if this Purchase Order
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
        /// up with this purchase order.
        /// </summary>
        public abstract Guid? PurchaseAdministratorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table
        /// that indicates the location where any service is to be
        /// carried out in.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Equipment table
        /// that indicates the equipment where any service is to be
        /// carried out on.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Contract table
        /// that indicates the purchase agreement contract that will be
        /// used to define the prices of materials and services in
        /// this purchase order.
        /// </summary>
        public abstract Guid? ContractID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table
        /// that indicates the store the materials purchase are intended
        /// for.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Vendor table
        /// that indicates the vendor who will be providing the
        /// materials or services.
        /// </summary>
        public abstract Guid? VendorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Currency table that represents the foreign
        /// currency of the line items in this vendor's
        /// quotation.
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// the exchange rate for the selected currency
        /// was defined when the currency was selected.
        /// <para></para>
        /// If the selected currency is the system's base
        /// currency, then this flag will be 1.
        /// </summary>
        public abstract int? IsExchangeRateDefined { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Currency table that represents the foreign
        /// currency exchange rate.
        /// <para></para>
        /// The date of the quotation and the selected
        /// currency is used to determine the exchange rate.
        /// <para></para>
        /// If a default exchange rate cannot be found in the
        /// exchange rate table, then the user may enter
        /// the exchange rate manually.
        /// </summary>
        public abstract decimal? ForeignToBaseExchangeRate { get; set; }

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
        /// [Column] Gets or sets the freight terms associated with
        /// this purchase order.
        /// </summary>
        public abstract String FreightTerms { get; set; }

        /// <summary>
        /// [Column] Gets or sets the payment terms associated with
        /// this purchase order.
        /// </summary>
        public abstract String PaymentTerms { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddressCountry { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddressState { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddressCity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactCellPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactPerson { get; set; }

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
        /// [Column] Gets or sets a value indicating if a purchase order
        /// must be created from a request for quotation.
        /// <para></para>
        /// <list>
        ///     <item>0 - Not required.</item>
        ///     <item>1 - Preferred. A warning is displayed if the minimum quotations is not satisfied.</item>
        ///     <item>2 - Required. </item>
        /// </list>
        /// <para></para>
        /// </summary>
        public abstract int? RFQToPOPolicy { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum amount (inclusive)
        /// that will result in the PO policy taking effect.
        /// </summary>
        public abstract decimal? MinimumApplicablePOAmount { get; set; }

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
        /// [Column] Gets or sets a value indicating
        /// the how this PO should be matched.
        /// <list>
        ///     <item>0 - 3-Way matching to Goods Receipt (Quantity Billed &lt;= Quantity Delivered). </item>
        ///     <item>1 - 2-Way matching to Purchase Order (Quantity Billed &lt;= Quantity Ordered). </item>
        /// </list>
        /// </summary>
        public abstract int? POMatchingType { get; set; }

        /// <summary>
        /// [Column] Gets or sets whether the PO is allowed to close if PO amount <> IR amount
        /// this field is updated from PurchaseSetting
        /// </summary>
        public abstract int? IsPOAllowedClosure { get; set; }

        /// <summary>
        /// Gets or sets a reference to the OContract object
        /// generated by this Term Contract Purchase Order when
        /// it is approved.
        /// </summary>
        public abstract OContract GeneratedTermContract { get; set; }

        /// <summary>
        /// Gets or sets the reference to the OCase object
        /// that represents the case this purchase order
        /// is associated with.
        /// </summary>
        public abstract OCase Case { get; set; }

        /// <summary>
        /// Gets or sets the Purchase Type object the represents
        /// the purchase type of this request for quotation.
        /// </summary>
        public abstract OCode PurchaseType { get; set; }

        /// <summary>
        /// Gets or sets the OVendor object that represents
        /// the vendor who will be providing the
        /// materials or services.
        /// </summary>
        public abstract OVendor Vendor { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents
        /// the store the materials purchase are intended
        /// for.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents
        /// the purchase administrator to follow
        /// up with this purchase order.
        /// </summary>
        public abstract OUser PurchaseAdministrator { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseOrderItem objects that represents
        /// the list of purchase order items that this purchase order contains.
        /// </summary>
        public abstract DataList<OPurchaseOrderItem> PurchaseOrderItems { get; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseOrderReceipt objects that represents
        /// the quantity of the materials and services that have been received
        /// against this purchase order.
        /// </summary>
        public abstract DataList<OPurchaseOrderReceipt> PurchaseOrderReceipts { get; }

        /// <summary>
        /// Gets or sets the OLocation object that represents
        /// the location where any service is to be
        /// carried out in.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets or sets the OEquipment object that represents
        /// the equipment where any service is to be
        /// carried out on.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }

        /// <summary>
        /// Gets or sets the OContract object that represents
        /// the purchase agreement contract that will be
        /// used to define the prices of materials and services in
        /// this purchase order.
        /// </summary>
        public abstract OContract Contract { get; set; }

        /// <summary>
        /// Gets or sets the OCurrency object that represents
        /// the default currency that will be set on a purchase order
        /// line item when a new item is created.
        /// </summary>
        public abstract OCurrency Currency { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudget objects that represents
        /// the budget distribution for this purchase order.
        /// </summary>
        public abstract DataList<OPurchaseBudget> PurchaseBudgets { get; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudgetSummary objects that represents
        /// information about this purchase order's commitment to the budgets.
        /// </summary>
        public abstract DataList<OPurchaseBudgetSummary> PurchaseBudgetSummaries { get; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseInvoice objects that represents
        /// the list of invoices created and matched against this
        /// purchase order.
        /// </summary>
        public abstract DataList<OPurchaseInvoice> PurchaseInvoices { get; }

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
        /// Gets the total awarded amount of this request for quotation.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                decimal? taskAmount = 0;

                foreach (OPurchaseOrderItem poItem in this.PurchaseOrderItems)
                    taskAmount += Round(poItem.UnitPrice * poItem.QuantityOrdered);

                if (taskAmount != null)
                    return taskAmount.Value;

                return 0;
            }
        }

        /// <summary>
        /// Gets the exchange rate in text representation. The
        /// output looks like:
        /// <para></para>
        /// &nbsp; &nbsp; 1 AUD is 1.62 SGD.
        /// <para></para>
        /// where AUD is the foreign currency and SGD is the system's
        /// base currency.
        /// </summary>
        public string ExchangeRate
        {
            get
            {
                if (this.Currency != null)
                    return String.Format(Resources.Strings.PurchaseOrder_ExchangeRate,
                        this.Currency.ObjectName, this.ForeignToBaseExchangeRate, OApplicationSetting.Current.BaseCurrency.ObjectName);
                return "";
            }
        }

        /// <summary>
        /// Gets the budget distribution mode in text.
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
                string itemDescription = "";
                if (this.PurchaseOrderItems.Count > 0)
                {
                    OPurchaseOrderItem item = this.PurchaseOrderItems.Find((r) => r.ItemNumber == 1);
                    if (item != null)
                        itemDescription = item.ItemDescription;
                }
                if (Description.Length + itemDescription.Length + 1 > 255)
                    itemDescription = itemDescription.Substring(0, 255 - Description.Length - 3 - 1) + "...";//1 for '/', 3 for '...'

                this.ObjectName = this.Description + (itemDescription != "" ? "/" + itemDescription : "");
            }
            else
                this.ObjectName = this.Description;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Deactivate all purchase order line items, when this
        /// purchase order is deactivated.
        /// <para></para>
        /// Then, releases all budgets.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Deactivating()
        {
            base.Deactivating();

            foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                item.Deactivate();

            // Cancel all budget transactions.
            //
            OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
            this.PurchaseBudgetSummaries.Clear();
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
        /// Submits for Purchase Order for approval by doing: <br/>
        /// 1. Creates the budget transaction logs. <br/>
        /// 2. Creates the budget summaries and stamp them with the current
        /// budget available balance. <br/>
        /// <para></para>
        /// This method is called from the workflow. It should
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
                        OPurchaseBudget.CreateBudgetTransactionLogsAndSummaries(
                            this.PurchaseBudgets, this.PurchaseBudgetSummaries, BudgetTransactionType.PurchasePendingApproval);
                    }
                    this.IsSubmittedForApproval = 1;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Rejects the Purchase Order by doing the following:
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
                    // Cancels all budget transactions.
                    //
                    OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
                    this.PurchaseBudgetSummaries.Clear();

                    this.IsSubmittedForApproval = 0;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Cancels the Purchase Order by doing the following: <br/>
        /// 1. Unlink all PO line items from RFQ / WJ line items. <br/>
        /// 2. Cancel all PO budget transactions. <br/>
        /// 3. Undo the transfer of the previous RFQ budget transactions. <br/>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                //if (this.PurchaseOrderItems.Count > 0 &&
                //    this.PurchaseOrderItems[0].RequestForQuotationItem != null &&
                //    this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation != null)
                //{
                //    ORequestForQuotation o = this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation;
                //    if (o.CurrentActivity.ObjectName == "Close")
                //        o.TriggerWorkflowEvent("Cancel");
                //}

                // Unlink all PO line items from RFQ / WJ line items.
                // Copy RfqItemID to OriginalRfqItemID for reference.
                //
                foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                {
                    item.OriginalRequestForQuotationItemID = item.RequestForQuotationItemID;
                    //item.PurchaseRequestItemID = null;
                    //item.RequestForQuotationItemID = null;
                }

                // Cancel all PO budget transactions.
                //
                if (this.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired &&
                    this.BudgetDistributionMode != null)
                {
                    OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
                    this.PurchaseBudgetSummaries.Clear();
                }

                //Nguyen Quoc Phuong 5-Dec-2012
                if (this.IsSyncCRV)
                {
                    int? status = this.UpdateCRVGProcurementContract();
                    if (status != (int)EnumCRVUpdateGroupProcurementContractStatus.SUCCESSFUL)
                    {
                        this.CRVSyncError = (int)EnumCRVTenderPOSyncError.UPDATE;
                        this.CRVSyncErrorNoOfTries = 0;
                    }
                }
                //End Nguyen Quoc Phuong 5-Dec-2012

                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Closes the Purchase Order by doing the following: <br/>
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
                if (this.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired &&
                    this.BudgetDistributionMode != null)
                    OPurchaseBudget.ClearBudgetTransactionLogs(this.PurchaseBudgets);

                this.Save();

                // Close related case.
                //
                OCase.CloseCaseWhenAllDocumentsClosedOrCancelled(this.CaseID);

                //Nguyen Quoc Phuong 5-Dec-2012
                if (this.IsSyncCRV)
                {
                    int? status = this.UpdateCRVGProcurementContract();
                    if (status != (int)EnumCRVUpdateGroupProcurementContractStatus.SUCCESSFUL)
                    {
                        this.CRVSyncError = (int)EnumCRVTenderPOSyncError.UPDATE;
                        this.CRVSyncErrorNoOfTries = 0;
                    }
                }
                //End Nguyen Quoc Phuong 5-Dec-2012

                c.Commit();
            }
        }

        /// <summary>
        /// Updates the exchange rate from the one defined
        /// in the database.
        /// </summary>
        public void UpdateExchangeRate()
        {
            this.IsExchangeRateDefined = 0;
            this.ForeignToBaseExchangeRate = null;

            decimal? rate = null;
            if (this.DateOfOrder != null && this.CurrencyID != null)
                rate = OCurrency.GetExchangeRate(this.DateOfOrder.Value, this.CurrencyID.Value);

            if (rate != null)
            {
                this.IsExchangeRateDefined = 1;
                this.ForeignToBaseExchangeRate = rate;
                return;
            }
        }

        /// <summary>
        /// Updates the unit price of all vendor quoted items.
        /// </summary>
        public void UpdateSingleItemUnitPrice(OPurchaseOrderItem purchaseOrderItem)
        {
            purchaseOrderItem.UnitPrice = Round(purchaseOrderItem.UnitPriceInSelectedCurrency * this.ForeignToBaseExchangeRate);
        }

        /// <summary>
        /// Updates the dropdown lists of all rows in the RequestForQuotationVendorItems
        /// grid view. Also updates the currencyID of each ORequestForQuotationVendorItem
        /// objects.
        /// </summary>
        public void UpdateItemCurrencies()
        {
            foreach (OPurchaseOrderItem poItem in this.PurchaseOrderItems)
            {
                poItem.CurrencyID = this.CurrencyID;
                UpdateSingleItemUnitPrice(poItem);
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Re-order the list of items in the checklist response set.
        /// </summary>
        /// <param name="i"></param>
        /// --------------------------------------------------------------
        public void ReorderItems(OPurchaseOrderItem p)
        {
            Global.ReorderItems(PurchaseOrderItems, p, "ItemNumber");
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Returns true if all unit prices in the list of purchase
        /// order items have been entered.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ValidateAllUnitPricesEntered()
        {
            foreach (OPurchaseOrderItem item in PurchaseOrderItems)
                if (item.UnitPrice == null)
                    return false;

            return true;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Create a new receipt for goods and services. This method
        /// will compute the balance of all goods and services
        /// received and update the balance into the receipt line items.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public OPurchaseOrderReceipt CreateReceipt()
        {
            OPurchaseOrderReceipt r = TablesLogic.tPurchaseOrderReceipt.Create();

            r.DateOfReceipt = DateTime.Today;
            r.StoreID = this.StoreID;

            foreach (OPurchaseOrderItem item in PurchaseOrderItems)
            {
                OPurchaseOrderReceiptItem ri = TablesLogic.tPurchaseOrderReceiptItem.Create();

                ri.PurchaseOrderItem = item;
                if (item.ReceiptMode == ReceiptModeType.Quantity)
                {
                    ri.QuantityDelivered = item.QuantityOrdered - item.QuantityDelivered;
                    ri.UnitPrice = item.UnitPrice;

                    if (ri.QuantityDelivered < 0)
                        ri.QuantityDelivered = 0;
                }
                else if (item.ReceiptMode == ReceiptModeType.Dollar)
                {
                    ri.QuantityDelivered = 1;
                    ri.UnitPrice = item.UnitPrice - item.DollarAmountDelivered;

                    if (ri.UnitPrice < 0)
                        ri.UnitPrice = 0;
                }

                r.PurchaseOrderReceiptItems.Add(ri);
            }

            return r;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Determines if there are any unsaved receipts in the purchase
        /// order. Returns true if so, false otherwise.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ContainsUnsavedReceipts()
        {
            foreach (OPurchaseOrderReceipt receipt in this.PurchaseOrderReceipts)
                if (receipt.IsNew)
                    return true;
            return false;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Determines if all items in the list of purchase order items
        /// are service items. Returns true if so, false otherwise.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ContainsOnlyServiceItems()
        {
            foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                if (item.ItemType == PurchaseItemType.Material)
                    return false;
            return true;
        }

        /// <summary>
        /// Checks the user is receiving any material items.
        /// </summary>
        /// <returns></returns>
        public bool IsReceivingMaterialItems(OPurchaseOrderReceipt receipt)
        {
            foreach (OPurchaseOrderReceiptItem item in receipt.PurchaseOrderReceiptItems)
            {
                OPurchaseOrderItem poItem = this.PurchaseOrderItems.Find(item.PurchaseOrderItemID.Value);
                if (item.QuantityDelivered > 0 &&
                    poItem.ItemType == PurchaseItemType.Material)
                    return true;
            }

            return false;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Create a single PO from a set of RFQs
        /// </summary>
        /// <param name="prIds"></param>
        /// --------------------------------------------------------------
        public static OPurchaseOrder CreatePOFromRFQs(List<Guid> rfqIds, int purchaseOrderType)
        {
            return CreatePOFromRFQLineItems(
                TablesLogic.tRequestForQuotationItem.LoadList(
                TablesLogic.tRequestForQuotationItem.AwardedVendorID != null &
                TablesLogic.tRequestForQuotationItem.RequestForQuotation.CurrentActivity.ObjectName == "Awarded" &
                TablesLogic.tRequestForQuotationItem.RequestForQuotation.ObjectID.In(rfqIds)), purchaseOrderType);
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Create a single RFQ from a set of PRs
        /// </summary>
        /// <param name="prIds"></param>
        /// --------------------------------------------------------------
        public static OPurchaseOrder CreatePOFromPRs(List<Guid> prIds)
        {
            return CreatePOFromPRLineItems(TablesLogic.tPurchaseRequestItem[
                TablesLogic.tPurchaseRequestItem.PurchaseRequest.CurrentActivity.ObjectName == "Approved" &
                TablesLogic.tPurchaseRequestItem.PurchaseRequestID.In(prIds.ToArray()), null]);
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Create a single RFQ from a set of WJ line items and saves the
        /// RFQ into the database.
        ///
        /// The line items must come from RFQs that have been awarded
        /// already.
        /// </summary>
        /// <param name="prLineItems"></param>
        /// --------------------------------------------------------------
        public static OPurchaseOrder CreatePOFromPRLineItems(List<OPurchaseRequestItem> items)
        {
            using (Connection c = new Connection())
            {
                if (items.Count == 0)
                    return null;

                OPurchaseRequest r = items[0].PurchaseRequest;
                OPurchaseOrder o = TablesLogic.tPurchaseOrder.Create();

                o.Description = r.Description;
                o.DateRequired = r.DateRequired;
                o.DateEnd = r.DateRequired;
                o.BillToAddress = r.BillToAddress;
                o.BillToAttention = r.BillToAttention;
                o.ShipToAddress = r.ShipToAddress;
                o.ShipToAttention = r.ShipToAttention;
                o.DateOfOrder = DateTime.Today;
                o.PurchaseAdministratorID = r.PurchaseAdministratorID;
                o.LocationID = r.LocationID;
                o.EquipmentID = r.EquipmentID;

                AddPOLineItemsFromPRLineItems(o, items);

                // KF BEGIN 2007.05.21
                int count = o.PurchaseOrderItems.Count;
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
        /// Add WJ Lines into a PO.
        /// </summary>
        /// <param name="o"></param>
        /// <param name="items"></param>
        /// --------------------------------------------------------------
        public static void AddPOLineItemsFromPRLineItems(OPurchaseOrder o, List<OPurchaseRequestItem> items)
        {
            using (Connection c = new Connection())
            {
                int i = TablesLogic.tPurchaseOrderItem[
                    TablesLogic.tPurchaseOrderItem.PurchaseOrderID == o.ObjectID].Count + 1;

                List<Guid> purchaseRequestIds = new List<Guid>();

                foreach (OPurchaseRequestItem item in items)
                {
                    if (item.RequestForQuotationItem == null && item.PurchaseOrderItem == null)
                    {
                        OPurchaseOrderItem n = TablesLogic.tPurchaseOrderItem.Create();

                        n.ItemNumber = i++;
                        n.ItemType = item.ItemType;
                        n.CatalogueID = item.CatalogueID;
                        n.FixedRateID = item.FixedRateID;
                        n.ItemDescription = item.ItemDescription;
                        n.UnitOfMeasureID = item.UnitOfMeasureID;
                        n.QuantityOrdered = item.QuantityRequired;
                        n.PurchaseRequestItemID = item.ObjectID;
                        n.ReceiptMode = item.ReceiptMode;

                        o.PurchaseOrderItems.Add(n);

                        if (!purchaseRequestIds.Contains(item.PurchaseRequestID.Value))
                            purchaseRequestIds.Add(item.PurchaseRequestID.Value);
                    }
                }
                o.Save();

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
                c.Commit();
            }
        }

        /// <summary>
        /// Checks if there is at least one material item in the purchase.
        /// </summary>
        /// <returns></returns>
        public bool HasMaterialItems()
        {
            foreach (OPurchaseOrderItem i in this.PurchaseOrderItems)
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
        public int ValidateBudgetAmountEqualsLineItemAmount()
        {
            // If the budget validation is not required, return -1
            // immediately to indicate the validation succeeded.
            //
            if (this.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired)
                return -1;

            if (this.BudgetDistributionMode != null)
            {
                // Find out the total amount by line items
                // or the entire WJ.
                //
                int maxItemNumber = 0;
                Hashtable totalLineItemAmounts = new Hashtable();
                foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                {
                    int itemNumber = 0;
                    decimal? recoverables = (item.RecoverableAmount == null ? 0 : item.RecoverableAmount.Value);

                    if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
                        itemNumber = item.ItemNumber.Value;

                    if (itemNumber > maxItemNumber)
                        maxItemNumber = itemNumber;
                    if (totalLineItemAmounts[itemNumber] == null)
                        totalLineItemAmounts[itemNumber] = 0M;

                    totalLineItemAmounts[itemNumber] =
                        (decimal)totalLineItemAmounts[itemNumber] + item.Subtotal.Value - recoverables.Value;
                }

                // Find out the total budgeted amount by line items
                // or the entire WJ.
                //
                Hashtable totalBudgetAmounts = new Hashtable();
                foreach (OPurchaseBudget prBudget in this.PurchaseBudgets)
                {
                    int itemNumber = 0;
                    if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
                        itemNumber = prBudget.ItemNumber.Value;
                    if (itemNumber > maxItemNumber)
                        maxItemNumber = itemNumber;
                    if (totalBudgetAmounts[itemNumber] == null)
                        totalBudgetAmounts[itemNumber] = 0M;
                    totalBudgetAmounts[itemNumber] =
                        (decimal)totalBudgetAmounts[itemNumber] + prBudget.Amount.Value;
                }

                // Compare the line items and the budget totals
                // to ensure that they match.
                //
                for (int i = 0; i <= maxItemNumber; i++)
                {
                    decimal totalLineItemAmount = totalLineItemAmounts[i] == null ? 0 : (decimal)totalLineItemAmounts[i];
                    decimal totalBudgetAmount = totalBudgetAmounts[i] == null ? 0 : (decimal)totalBudgetAmounts[i];

                    // Test based on the budget validation settings.
                    //
                    if (this.BudgetValidationPolicy == 0 && totalLineItemAmount != totalBudgetAmount)
                        return i;
                    if (this.BudgetValidationPolicy == 1 && totalLineItemAmount < totalBudgetAmount)
                        return i;
                }
                return -1;
            }
            else
                return -1;
        }

        /// <summary>
        /// Gets a flag indicating whether the PO needs to be generated
        /// from an RFQ.
        /// <para></para>
        /// This method returns
        /// <list>
        ///     <item>0 - The PO does not satisfy the RFQ to PO policy.</item>
        ///     <item>1 - The PO satisfies the RFQ to PO policy.</item>
        ///     <item>-1 - The PO does not satisfy the RFQ to PO policy, and a warning will be shown.</item>
        /// </list>
        /// </summary>
        /// </summary>
        /// <returns></returns>
        public int ValidateRFQToPOPolicy()
        {
            decimal taskAmount = this.TaskAmount;
            if (this.RFQToPOPolicy == PurchasePolicy.NotRequired)
                return 1;
            else if (this.RFQToPOPolicy == PurchasePolicy.Preferred)
            {
                if (this.TaskAmount < this.MinimumApplicablePOAmount)
                    return 1;
                else
                    return -1;
            }
            else if (this.RFQToPOPolicy == PurchasePolicy.Required)
            {
                if (this.TaskAmount < this.MinimumApplicablePOAmount)
                    return 1;
                else
                    return 0;
            }
            return 1;
        }

        /// <summary>
        /// Gets the most applicable purchase settings and store it
        /// in a temporary variable.
        /// </summary>
        public void UpdateApplicablePurchaseSettings()
        {
            OPurchaseSettings purchaseSettings =
                OPurchaseSettings.GetPurchaseSettings(this.Location, this.PurchaseType);

            if (purchaseSettings != null)
            {
                this.RFQToPOPolicy = purchaseSettings.RFQToPOPolicy;
                this.MinimumApplicablePOAmount = purchaseSettings.MinimumApplicablePOAmount;
                this.BudgetValidationPolicy = purchaseSettings.BudgetValidationPolicy;
                this.IsPOAllowedClosure = purchaseSettings.IsPOAllowedClosure;
            }
            else
            {
                this.RFQToPOPolicy = 0;
                this.MinimumApplicablePOAmount = 0;
                this.BudgetValidationPolicy = PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems;
                this.IsPOAllowedClosure = 0;
            }
        }

        /// <summary>
        /// Determines and returns a flag indicating whether all
        /// items are copied from an RFQ.
        /// </summary>
        /// <returns></returns>
        public bool IsAllItemsCopiedFromRFQ()
        {
            foreach (OPurchaseOrderItem purchaseOrderItem in this.PurchaseOrderItems)
            {
                if (purchaseOrderItem.RequestForQuotationItemID == null)
                    return false;
            }
            return true;
        }

        /// <summary>
        /// Validates that there are sufficient number of quotations
        /// for this request for qoutation.
        /// <para></para>
        /// This method returns
        /// <list>
        ///     <item>0 - if there is insufficient quotations.</item>
        ///     <item>1 - if there is sufficient quotations.</item>
        ///     <item>-1 - if there is insufficient quotations, but a justification is required.</item>
        /// </list>
        /// </summary>
        /// <returns></returns>
        public int ValidateSufficientNumberOfQuotations()
        {
            if (this.RFQToPOPolicy == PurchasePolicy.NotRequired)
            {
                return 1;
            }
            else if (this.RFQToPOPolicy == PurchasePolicy.Preferred)
            {
                if (this.TaskAmount < this.MinimumApplicablePOAmount)
                    return 1;

                if (this.IsAllItemsCopiedFromRFQ())
                    return 1;
                else
                    return -1;
            }
            else if (this.RFQToPOPolicy == PurchasePolicy.Required)
            {
                if (this.TaskAmount < this.MinimumApplicablePOAmount)
                    return 1;

                if (this.IsAllItemsCopiedFromRFQ())
                    return 1;
                else
                    return 0;
            }
            return 1;
        }

        /// <summary>
        /// Get all accessible purchase orders that have been approved
        /// (or currently in the Pending Receipt state).
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static DataTable GetAccessibleApprovedPurchaseOrders(OUser user, string objectType, Guid? includingPurchaseOrderId)
        {
            // Gets the list of all accessible locations / equipment.
            //
            ArrayList locationIds = new ArrayList();
            ArrayList equipmentIds = new ArrayList();
            foreach (OPosition position in user.GetPositionsByObjectType(objectType))
            {
                foreach (OLocation location in position.LocationAccess)
                    locationIds.Add(location.ObjectID.Value);
                foreach (OEquipment equipment in position.EquipmentAccess)
                    equipmentIds.Add(equipment.ObjectID.Value);
            }

            // Get all the hierarchy paths of all
            // accessible locations.
            //
            TLocation loc = TablesLogic.tLocation;
            TEquipment eqpt = TablesLogic.tEquipment;
            DataTable locHierarchyPaths = loc.Select(loc.HierarchyPath).Where(loc.IsDeleted == 0 & loc.ObjectID.In(locationIds));
            DataTable eqptHierarchyPaths = eqpt.Select(eqpt.HierarchyPath).Where(eqpt.IsDeleted == 0 & eqpt.ObjectID.In(equipmentIds));

            // Construct the condition to include only
            // locations accessible by the specified
            // user.
            //
            TPurchaseOrder c = TablesLogic.tPurchaseOrder;
            ExpressionCondition locCond = Query.False;
            ExpressionCondition eqptCond = Query.False;
            foreach (DataRow dr in locHierarchyPaths.Rows)
                locCond = locCond | c.Location.HierarchyPath.Like((string)dr[0] + "%");
            foreach (DataRow dr in eqptHierarchyPaths.Rows)
                eqptCond = eqptCond | c.Equipment.HierarchyPath.Like((string)dr[0] + "%");

            // Query the DB and return the result.
            //
            return c.Select(
                c.ObjectID,
                (c.ObjectNumber + ": " + c.Description).As("PurchaseOrder"))
                .Where(
                (locCond &
                (c.EquipmentID == null | eqptCond) &
                c.IsDeleted == 0 &
                c.CurrentActivity.ObjectName == "PendingReceipt") |
                c.ObjectID == includingPurchaseOrderId)
                .OrderBy(
                c.ObjectNumber.Asc);
        }

        /// <summary>
        /// Validates that no good receipts and purchase invoices have been created against
        /// this purchase order.
        /// </summary>
        /// <param name="purchaseOrderId"></param>
        /// <returns></returns>
        public static bool ValidateNoGoodsReceiptAndInvoices(Guid? purchaseOrderId)
        {
            StringBuilder sb = new StringBuilder();

            // Gets a list of all RFQ item numbers that have been generated
            // into POs.
            //
            TPurchaseOrderReceipt por = TablesLogic.tPurchaseOrderReceipt;
            DataTable dt = por.Select(por.ObjectID)
                .Where(
                por.PurchaseOrderID == purchaseOrderId &
                por.IsDeleted == 0);

            // Gets a list of all invoices generated against this PO.
            // into POs.
            //
            TPurchaseInvoice pi = TablesLogic.tPurchaseInvoice;
            DataTable dt2 = pi.Select(pi.ObjectID)
                .Where(
                pi.PurchaseOrderID == purchaseOrderId &
                pi.CurrentActivity.ObjectName != "Cancelled" &
                pi.IsDeleted == 0);

            return dt.Rows.Count == 0 && dt2.Rows.Count == 0;
        }

        /// <summary>
        /// Validates that selected the store bins of this purchase
        /// order is not locked (provided there are inventory items
        /// checked in during this receipt).
        /// <para></para>
        /// Returns
        /// </summary>
        /// <returns></returns>
        public string ValidateStoreBinNotLocked()
        {
            foreach (OPurchaseOrderReceipt por in this.PurchaseOrderReceipts)
            {
                if (por.IsNew)
                {
                    List<Guid> storeBinIds = new List<Guid>();

                    bool containsMaterialItems = false;
                    foreach (OPurchaseOrderReceiptItem poReceiptItem in por.PurchaseOrderReceiptItems)
                    {
                        if (poReceiptItem.PurchaseOrderItem.ItemType == PurchaseItemType.Material &&
                            poReceiptItem.QuantityDelivered > 0)
                            containsMaterialItems = true;
                    }

                    if (containsMaterialItems)
                    {
                        DataTable dt = TablesLogic.tStoreBin.Select(
                            TablesLogic.tStoreBin.Store.ObjectName.As("StoreName"),
                            TablesLogic.tStoreBin.ObjectName.As("StoreBinName"))
                            .Where(
                            TablesLogic.tStoreBin.IsLocked == 1 &
                            TablesLogic.tStoreBin.ObjectID == por.StoreBinID);

                        if (dt.Rows.Count > 0)
                            return dt.Rows[0]["StoreBinName"].ToString() + " (" + dt.Rows[0]["StoreName"].ToString() + ")";
                        else
                            return "";
                    }
                    else
                        return "";
                }
            }
            return "";
        }

        /// <summary>
        /// Validates to ensure that all invoices are closed and cancelled
        /// before the Purchase Order is closed.
        /// </summary>
        /// <returns></returns>
        public bool ValidateInvoicesClosedOrCancelled()
        {
            if (TablesLogic.tPurchaseInvoice.Select(
                TablesLogic.tPurchaseInvoice.ObjectID.Count())
                .Where(
                TablesLogic.tPurchaseInvoice.IsDeleted == 0 &
                TablesLogic.tPurchaseInvoice.PurchaseOrderID == this.ObjectID &
                TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName != "Close" &
                TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName != "Cancelled") > 0)
                return false;

            return true;
        }
    }

    /// <summary>
    /// Enumerates the different types of matching.
    /// </summary>
    public class PurchaseOrderMatchingType
    {
        /// <summary>
        /// 2-way matching with Purchase Order. (Quantity Billed &lt;= Quantity Ordered)
        /// </summary>
        public const int TwoWayMatching = 0;

        /// <summary>
        /// 3-way matching with goods receipt. (Quantity Billed &lt;= Quantity Delivered)
        /// </summary>
        public const int ThreeWayMatching = 1;
    }
}