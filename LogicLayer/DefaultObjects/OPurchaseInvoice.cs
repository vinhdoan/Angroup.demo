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
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("PurchaseInvoice")] 
    public partial class TPurchaseInvoice : LogicLayerSchema<OPurchaseInvoice>
    {
        [Default(0)]
        public SchemaInt MatchType;
        [Default(0)]
        public SchemaInt InvoiceType;
        public SchemaGuid PurchaseTypeID;
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        public SchemaGuid PurchaseOrderID;
        public SchemaDateTime DateOfInvoice;
        public SchemaString ReferenceNumber;
        [Size(255)]
        public SchemaString Description;
        
        public SchemaGuid VendorID;
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
        public SchemaGuid CurrencyID;
        [Default(0)]
        public SchemaInt IsExchangeRateDefined;
        public SchemaDecimal ForeignToBaseExchangeRate;
        public SchemaDecimal TotalAmountInSelectedCurrency;
        public SchemaDecimal TotalTaxInSelectedCurrency;
        public SchemaGuid TaxCodeID;
        public SchemaDecimal TotalAmount;
        public SchemaDecimal TotalTax;

        public SchemaGuid CreditDebitMemoOnInvoiceID;
        public SchemaInt IsSubmittedForApproval;
        public SchemaInt IsApproved;
        [Default(0)]
        public SchemaInt BudgetValidationPolicy;

        public TCode PurchaseType { get { return OneToOne<TCode>("PurchaseTypeID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        public TVendor Vendor { get { return OneToOne<TVendor>("VendorID"); } }
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
        public TTaxCode TaxCode { get { return OneToOne<TTaxCode>("TaxCodeID"); } }
        public TPurchaseOrder PurchaseOrder { get { return OneToOne<TPurchaseOrder>("PurchaseOrderID"); } }
        public TPurchaseBudget PurchaseBudgets { get { return OneToMany<TPurchaseBudget>("PurchaseInvoiceID"); } }
        public TPurchaseBudgetSummary PurchaseBudgetSummaries { get { return OneToMany<TPurchaseBudgetSummary>("PurchaseOrderID"); } }
        public TPurchaseInvoice CreditDebitMemoOnInvoice { get { return OneToOne<TPurchaseInvoice>("CreditDebitMemoOnInvoiceID"); } }

    }


    /// <summary>
    /// Represents a purchase invoice submitted by a vendor
    /// in order get paid for a service rendered, or goods
    /// delivered.
    /// </summary>
    public abstract partial class OPurchaseInvoice : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets a flag indicating the type
        /// of this invoice.
        /// <list>
        ///     <item>0 - Direct Invoice; </item>
        ///     <item>1 - Matched to Purchase Order; </item>
        ///     <item>2 - Matched to Purchase Order Receipt; </item>
        /// </list>
        /// </summary>
        public abstract int? MatchType { get; set; }


        /// <summary>
        /// [Column] Gets or sets a flag indicating if this invoice
        /// is a standard invoice, a credit memo, or a debit memo.
        /// <para></para>
        /// <list>
        ///     <item>0 - Standard invoice; </item>
        ///     <item>1 - Credit memo; </item>
        ///     <item>2 - Debit memo; </item>
        /// </list>
        /// </summary>
        public abstract int? InvoiceType { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code
        /// that indicates the purchase type this invoice was
        /// billed for.
        /// </summary>
        public abstract Guid? PurchaseTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a foreign key to the Location
        /// table that indicates the location (where the services was carried 
        /// out) this invoice is billed to. This is only applicable if the
        /// invoice type is a direct invoice, or an invoice matched to a purchase
        /// order.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a foreign key to the Location
        /// table that indicates the equipment (on which the services was carried 
        /// out) this invoice is billed to. This is only applicable if the
        /// invoice type is a direct invoice, or an invoice matched to a purchase
        /// order.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        public abstract Guid? PurchaseOrderID { get; set; }
        public abstract DateTime? DateOfInvoice { get; set; }
        public abstract string ReferenceNumber { get; set; }
        public abstract string Description { get; set; }

        public abstract Guid? VendorID { get; set; }
        public abstract String ContactAddressCountry { get; set; }
        public abstract String ContactAddressState { get; set; }
        public abstract String ContactAddressCity { get; set; }
        public abstract String ContactAddress { get; set; }
        public abstract String ContactCellPhone { get; set; }
        public abstract String ContactEmail { get; set; }
        public abstract String ContactFax { get; set; }
        public abstract String ContactPhone { get; set; }
        public abstract String ContactPerson { get; set; }

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
        /// [Column] Gets or sets the foreign key to the
        /// Currency table that represents the foreign 
        /// currency of the line items in this invoice
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
        /// The date of the invoice and the selected
        /// currency is used to determine the exchange rate.
        /// <para></para>
        /// If a default exchange rate cannot be found in the
        /// exchange rate table, then the user may enter
        /// the exchange rate manually.
        /// </summary>
        public abstract decimal? ForeignToBaseExchangeRate { get; set; }

        public abstract decimal? TotalAmountInSelectedCurrency { get; set; }
        public abstract decimal? TotalTaxInSelectedCurrency { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Tax
        /// Code table that indicates the tax code that the total net amount
        /// of this invoice is subjected to.
        /// </summary>
        public abstract Guid? TaxCodeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total amount of this invoice
        /// in the base currency.
        /// </summary>
        public abstract decimal? TotalAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total tax of this invoice
        /// in the base currency.
        /// </summary>
        public abstract decimal? TotalTax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the invoice
        /// table that indicates which source invoice this
        /// invoice is matched to.
        /// <para></para>
        /// This field will contain a value only if this invoice
        /// is a credit or debit memo.
        /// </summary>
        public abstract Guid? CreditDebitMemoOnInvoiceID { get; set; }

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
        /// [Column] Gets or sets the OCode object that
        /// represents the purchase type this invoice was
        /// billed for.
        /// </summary>
        public abstract OCode PurchaseType { get; set; }

        public abstract OVendor Vendor { get; set; }

        /// <summary>
        /// Gets or sets a reference to the OCurrency object
        /// that indicates the alternate currency this invoice is billed in.
        /// </summary>
        public abstract OCurrency Currency { get; set; }

        /// <summary>
        /// Gets or sets a reference to the OTaxCode object
        /// that indicates the tax code that the total net amount
        /// of this invoice is subjected to.
        /// </summary>
        public abstract OTaxCode TaxCode { get; set; }

        public abstract OPurchaseOrder PurchaseOrder { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudget objects that represents
        /// the budget distribution for this invoice.
        /// </summary>
        public abstract DataList<OPurchaseBudget> PurchaseBudgets { get; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudgetSummary objects that represents
        /// information about this invoice's commitment to the budgets.
        /// </summary>
        public abstract DataList<OPurchaseBudgetSummary> PurchaseBudgetSummaries { get; }


        /// <summary>
        /// Gets a reference to the PurchaseInvoice object representing
        /// the invoice that this current credit/debit memo is matched
        /// against.
        /// </summary>
        public abstract OPurchaseInvoice CreditDebitMemoOnInvoice { get; set; }


        /// <summary>
        /// Gets a string indicating the type of this invoice.
        /// </summary>
        public string InvoiceTypeText
        {
            get
            {
                if (InvoiceType == PurchaseInvoiceType.StandardInvoice &&
                    MatchType == PurchaseMatchType.InvoiceMatchedToPO)
                    return Resources.Strings.InvoiceType_StandardInvoice;
                else if (InvoiceType == PurchaseInvoiceType.StandardInvoice &&
                    MatchType == PurchaseMatchType.DirectInvoice)
                    return Resources.Strings.InvoiceType_DirectExpense;
                else if (InvoiceType == PurchaseInvoiceType.CreditMemo)
                    return Resources.Strings.InvoiceType_CreditMemo;
                else if (InvoiceType == PurchaseInvoiceType.DebitMemo)
                    return Resources.Strings.InvoiceType_DebitMemo;
                return "";
            }
        }


        /// <summary>
        /// Gets a string indicating the type of this invoice
        /// in the localized text.
        /// </summary>
        public string MatchTypeText
        {
            get
            {
                if (MatchType == PurchaseMatchType.DirectInvoice)
                    return Resources.Strings.MatchType_DirectInvoice;
                else if (MatchType == PurchaseMatchType.InvoiceMatchedToPO)
                    return Resources.Strings.MatchType_InvoiceMatchedToPO;
                else if (MatchType == PurchaseMatchType.InvoiceMatchedToPOReceipt)
                    return Resources.Strings.MatchType_InvoiceMatchedToPOReceipt;
                return "";
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
                decimal? total = this.TotalAmount + this.TotalTax;
                if (total == null)
                    return 0;
                return total.Value;
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


        /// <summary>
        /// Gets the total of this invoice (amount + tax) in
        /// the system's base currency.
        /// </summary>
        public decimal TotalAmountAndTax
        {
            get
            {
                return Convert.ToDecimal(this.TotalAmount + this.TotalTax);
            }
        }


        private decimal totalCreditDebitMemoAmount = -1;


        /// <summary>
        /// Gets the total credit/debit memo amount in the system
        /// against this invoice in the system's base currency.
        /// </summary>
        public decimal TotalCreditDebitMemoAmount
        {
            get
            {
                if (totalCreditDebitMemoAmount == -1)
                {
                    TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;
                    totalCreditDebitMemoAmount =
                        inv.Select(inv.TotalAmount.Sum())
                        .Where(
                        inv.IsDeleted == 0 &
                        inv.CurrentActivity.ObjectName == "Approved" &
                        inv.CreditDebitMemoOnInvoiceID == this.ObjectID &
                        (inv.InvoiceType == PurchaseInvoiceType.CreditMemo |
                        inv.InvoiceType == PurchaseInvoiceType.DebitMemo));
                }
                return totalCreditDebitMemoAmount;
            }
        }


        /// <summary>
        /// Gets the total invoice amount balance after credit/debit
        /// memos.
        /// </summary>
        public decimal TotalAmountAfterCreditDebitMemos
        {
            get
            {
                return Convert.ToDecimal(TotalAmount) - TotalCreditDebitMemoAmount;
            }
        }


        /*
        /// <summary>
        /// Updates the invoice amount and tax in base currency.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            this.ObjectName = this.Description;
            UpdateTotalAmountAndTaxInBaseCurrency();
        }
        */


        /// <summary>
        /// Releases all budgets.
        /// </summary>
        public override void Deactivating()
        {
            base.Deactivating();

            // Cancel all budget transactions.
            //
            OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
            this.PurchaseBudgetSummaries.Clear();

        }


        /// <summary>
        /// Updates the total invoice amount and tax in base currency.
        /// </summary>
        public void UpdateTotalAmountAndTaxInBaseCurrency()
        {
            this.TotalAmount = Round(this.TotalAmountInSelectedCurrency * this.ForeignToBaseExchangeRate);
            this.TotalTax = Round(this.TotalTaxInSelectedCurrency * this.ForeignToBaseExchangeRate);

            // 2011.07.04, Kien Trung
            // Force invoice total amount = purchaseorder.SubTotal
            // if subtotalinselectedcurrency == this invoice amount in selected currency.
            //
            if (this.PurchaseOrder != null)
            {
                // Kien Trung
                // Non-Recoverable case.
                //
                if (this.PurchaseOrder.IsRecoverable == (int)EnumRecoverable.NonRecoverable &&
                    this.TotalAmountInSelectedCurrency == this.PurchaseOrder.SubTotalInSelectedCurrency)
                    this.TotalAmount = this.PurchaseOrder.SubTotal;
                // Kien Trung
                // In case of recoverable,
                //
                else if (this.PurchaseOrder.IsRecoverable == (int)EnumRecoverable.Recoverable &&
                    this.TotalAmountInSelectedCurrency == (this.PurchaseOrder.SubTotalInSelectedCurrency - this.PurchaseOrder.TotalRecoverableAmountInSelectedCurrency.Value))
                    this.TotalAmount = this.PurchaseOrder.SubTotal - this.PurchaseOrder.TotalRecoverableAmount.Value;
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



        //----------------------------------------------------------------
        /// <summary>
        /// Create an Invoice object based on a single Purchase Order's
        /// Receipt items.
        /// </summary>
        /// <param name="items"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static OPurchaseInvoice CreateInvoiceFromPOReceipts(List<OPurchaseOrderReceipt> items)
        {
            using (Connection c = new Connection())
            {
                OPurchaseInvoice invoice = TablesLogic.tPurchaseInvoice.Create();

                OPurchaseOrder po = null;
                foreach (OPurchaseOrderReceipt receipt in items)
                {
                    po = receipt.PurchaseOrder;
                    break;
                }

                if (po != null)
                {
                    invoice.DateOfInvoice = DateTime.Today;
                    invoice.VendorID = po.VendorID;
                    invoice.ContactAddress = po.ContactAddress;
                    invoice.ContactAddressCity = po.ContactAddressCity;
                    invoice.ContactAddressCountry = po.ContactAddressCountry;
                    invoice.ContactAddressState = po.ContactAddressState;
                    invoice.ContactCellPhone = po.ContactCellPhone;
                    invoice.ContactEmail = po.ContactEmail;
                    invoice.ContactFax = po.ContactFax;
                    invoice.ContactPerson = po.ContactPerson;
                    invoice.ContactPhone = po.ContactPhone;
                }

                invoice.Save();
                c.Commit();

                return invoice;
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Generate a single invoice for a set of Purchase Orders
        /// </summary>
        /// <param name="poIds"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static OPurchaseInvoice GenerateInvoiceFromPurchaseOrders(List<Guid> poIds)
        {
            return CreateInvoiceFromPOReceipts(
                TablesLogic.tPurchaseOrderReceipt[
                TablesLogic.tPurchaseOrderReceipt.PurchaseOrderID.In(poIds.ToArray()), null]);
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
            if (this.DateOfInvoice != null && this.CurrencyID != null)
                rate = OCurrency.GetExchangeRate(this.DateOfInvoice.Value, this.CurrencyID.Value);

            if (rate != null)
            {
                this.IsExchangeRateDefined = 1;
                this.ForeignToBaseExchangeRate = rate;
                return;
            }
        }


        /// <summary>
        /// Updates the vendor details.
        /// </summary>
        public void UpdateVendorDetails()
        {
            if (this.VendorID == null)
            {
                this.ContactAddress = "";
                this.ContactAddressCity = "";
                this.ContactAddressCountry = "";
                this.ContactAddressState = "";
                this.ContactCellPhone = "";
                this.ContactEmail = "";
                this.ContactFax = "";
                this.ContactPerson = "";
                this.ContactPhone = "";
                this.CurrencyID = null;
                this.ForeignToBaseExchangeRate = null;
                this.IsExchangeRateDefined = null;
            }
            else
            {
                this.ContactAddress = this.Vendor.OperatingAddress;
                this.ContactAddressCity = this.Vendor.OperatingAddressCity;
                this.ContactAddressCountry = this.Vendor.OperatingAddressCountry;
                this.ContactAddressState = this.Vendor.OperatingAddressState;
                this.ContactCellPhone = this.Vendor.OperatingCellPhone;
                this.ContactEmail = this.Vendor.OperatingEmail;
                this.ContactFax = this.Vendor.OperatingFax;
                this.ContactPerson = this.Vendor.OperatingContactPerson;
                this.ContactPhone = this.Vendor.OperatingPhone;

                if (this.Vendor.CurrencyID != null)
                {
                    if (this.CurrencyID != this.Vendor.CurrencyID)
                    {
                        this.CurrencyID = this.Vendor.CurrencyID;
                        this.UpdateExchangeRate();
                    }
                }
                else
                {
                    this.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;
                    this.ForeignToBaseExchangeRate = 1.0M;
                    this.IsExchangeRateDefined = 1;
                }

            }
        }


        /// <summary>
        /// Updates the vendor details.
        /// </summary>
        public void UpdateVendorDetailsExceptCurrency()
        {
            if (this.VendorID == null)
            {
                this.ContactAddress = "";
                this.ContactAddressCity = "";
                this.ContactAddressCountry = "";
                this.ContactAddressState = "";
                this.ContactCellPhone = "";
                this.ContactEmail = "";
                this.ContactFax = "";
                this.ContactPerson = "";
                this.ContactPhone = "";
                this.CurrencyID = null;
            }
            else
            {
                this.ContactAddress = this.Vendor.OperatingAddress;
                this.ContactAddressCity = this.Vendor.OperatingAddressCity;
                this.ContactAddressCountry = this.Vendor.OperatingAddressCountry;
                this.ContactAddressState = this.Vendor.OperatingAddressState;
                this.ContactCellPhone = this.Vendor.OperatingCellPhone;
                this.ContactEmail = this.Vendor.OperatingEmail;
                this.ContactFax = this.Vendor.OperatingFax;
                this.ContactPerson = this.Vendor.OperatingContactPerson;
                this.ContactPhone = this.Vendor.OperatingPhone;
            }
        }


        /// <summary>
        /// Create the budget transaction logs and summaries.
        /// </summary>
        public List<OBudgetTransactionLog> CreateBudgetTransactionLogsAndSummaries()
        {
            int transactionType = BudgetTransactionType.DirectInvoicePendingApproval;

            if (this.MatchType == PurchaseMatchType.InvoiceMatchedToPO ||
                this.MatchType == PurchaseMatchType.InvoiceMatchedToPOReceipt)
            {
                // PO Matched Invoice.
                // Regardless of whether the invoice is a standard
                // invoice or credit/debit memo, the budget transaction
                // log's type must be set to 'Approved'.
                //
                transactionType = BudgetTransactionType.PurchaseApproved;
            }
            else
            {
                // Direct Invoice
                //
                if (this.InvoiceType == PurchaseInvoiceType.StandardInvoice)
                {
                    // Standard invoice.
                    //
                    transactionType = BudgetTransactionType.DirectInvoicePendingApproval;
                }
                else
                {
                    // Credit memos/debit memos
                    //
                    transactionType = BudgetTransactionType.DirectInvoiceApproved;
                }
            }

            return OPurchaseBudget.CreateBudgetTransactionLogsAndSummaries(
                this.PurchaseBudgets, this.PurchaseBudgetSummaries, transactionType);

        }




        /// <summary>
        /// Approves the Invoice by doing the following:<br/>
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
                    List<OBudgetTransactionLog> transactions = null;

                    /*****************
                    // Create budget summaries if not already created.
                    //
                    if (this.PurchaseBudgetSummaries.Count == 0)
                    {
                        transactions = CreateBudgetTransactionLogsAndSummaries();
                    }
                    *****************/

                    // Update all budget transactions to indicated Direct Invoiced / Approved.
                    //
                    // If we are dealing with credit/debit memos, we must also transfer
                    // the transaction amounts for the transaction logs to another field
                    // to store the non-committed amount.
                    //
                    if (this.MatchType == PurchaseMatchType.InvoiceMatchedToPO ||
                        this.MatchType == PurchaseMatchType.InvoiceMatchedToPOReceipt)
                    {
                        // PO-Matched Invoice
                        //
                        if (this.InvoiceType == PurchaseInvoiceType.StandardInvoice)
                            transactions = OPurchaseBudget.SetBudgetTransactionLogsTransactionType(
                                this.PurchaseBudgets, BudgetTransactionType.PurchaseInvoiceApproved);
                        else
                            transactions = OPurchaseBudget.SetBudgetTransactionLogsTransactionTypeAndTransferToNonCommitted(
                                this.PurchaseBudgets, BudgetTransactionType.PurchaseCreditDebitMemoApproved);
                    }
                    else
                    {
                        // Direct Invoice
                        //
                        if (this.InvoiceType == PurchaseInvoiceType.StandardInvoice)
                            transactions = OPurchaseBudget.SetBudgetTransactionLogsTransactionType(
                                this.PurchaseBudgets, BudgetTransactionType.DirectInvoiceApproved);
                        else
                            transactions = OPurchaseBudget.SetBudgetTransactionLogsTransactionTypeAndTransferToNonCommitted(
                                this.PurchaseBudgets, BudgetTransactionType.DirectCreditDebitMemoApproved);
                    }
                     

                    // Stamp budget summaries with current budget balance at approval.
                    //
                    OPurchaseBudgetSummary.UpdateBudgetSummariesAfterApproval(transactions, this.PurchaseBudgetSummaries);
                    this.IsApproved = 1;

                    if (this.InvoiceType == PurchaseInvoiceType.StandardInvoice)
                    {
                        //transit PO to Close if all approved invoice amount is match PO Amount
                        //
                        decimal? totalInvoice = 0;
                        totalInvoice = (decimal)TablesLogic.tPurchaseInvoice.Select
                            (TablesLogic.tPurchaseInvoice.TotalAmount.Sum())
                            .Where
                            (TablesLogic.tPurchaseInvoice.PurchaseOrderID == this.PurchaseOrderID &
                            TablesLogic.tPurchaseInvoice.InvoiceType == PurchaseInvoiceType.StandardInvoice &
                            TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName.In("Approved", "Close") &
                            TablesLogic.tPurchaseInvoice.IsDeleted == 0);

                        OPurchaseOrder po = this.PurchaseOrder;
                        
                        if (po != null && 
                            totalInvoice == po.SubTotal && 
                            po.CurrentActivity.ObjectName != "Close")
                            po.TriggerWorkflowEvent("Close");
                    }

                    // if there is any credit note submitted together with invoice.
                    // approve the credit note as well.
                    //
                    if (this.AutoGeneratedCreditNoteID != null)
                    {
                        OPurchaseInvoice creditnote = TablesLogic.tPurchaseInvoice[this.AutoGeneratedCreditNoteID.Value];
                        List<OPurchaseBudget> purchaseBudgets =
                           OPurchaseBudget.TransferPartialPurchaseBudgets(
                                this.PurchaseBudgets, null, creditnote.TotalAmount);
                        creditnote.PurchaseBudgets.Clear();
                        creditnote.PurchaseBudgets.AddRange(purchaseBudgets);
                        OPurchaseBudget.CreateBudgetTransactionLogsAndSummaries(
                            creditnote.PurchaseBudgets, creditnote.PurchaseBudgetSummaries, BudgetTransactionType.PurchaseCreditDebitMemoApproved);
                        creditnote.TriggerWorkflowEvent("Approve");
                        creditnote.Save();
                    }
                }
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Rejects the Invoice by doing the following:
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
                    // 2010.05.10 
                    // Add this here instead it should be called before the purchase budgets
                    // are cleared.
                    OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);

                    // For invoices matched to purchase orders, the purchase
                    // budget distributions must be cleared, as an invoice
                    // matched to a PO was never created with any purchase
                    // budget distributions at all.
                    //
                    if (this.MatchType == PurchaseMatchType.InvoiceMatchedToPO ||
                        this.MatchType == PurchaseMatchType.InvoiceMatchedToPOReceipt)
                    {
                        this.PurchaseBudgets.Clear();
                    }

                    // 2010.05.10 
                    // Removed this because it should be called before the purchase budgets
                    // are cleared.
                    // OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);

                    this.PurchaseBudgetSummaries.Clear();

                    this.IsSubmittedForApproval = 0;
                    if (this.AutoGeneratedCreditNoteID != null)
                    {
                        OPurchaseInvoice creditnote = TablesLogic.tPurchaseInvoice[this.AutoGeneratedCreditNoteID.Value];
                        creditnote.TriggerWorkflowEvent("RejectForRedraft");
                    }
                }
                this.Save();
                c.Commit();
            }
        }


       


        /// <summary>
        /// Updates the tax.
        /// </summary>
        public void UpdateTax()
        {
            // 2011.03.16
            // Kim Foong
            // Removed this temporarily, because user's are experiencing
            // invoices with huge tax amounts.
            //
            //if (this.PurchaseOrder != null && this.PurchaseOrder.HasTaxCodePerLineItem != null && this.PurchaseOrder.HasTaxCodePerLineItem == 1)
            //{
            //    decimal taxAmountInSelectedCurrency = (decimal)TablesLogic.tPurchaseInvoice.Select(
            //                                    TablesLogic.tPurchaseInvoice.TotalTaxInSelectedCurrency.Sum())
            //                                    .Where(TablesLogic.tPurchaseInvoice.PurchaseOrderID == this.PurchaseOrderID &
            //                                            TablesLogic.tPurchaseInvoice.CurrentActivity.CurrentStateName != "Cancelled" &
            //                                            TablesLogic.tPurchaseInvoice.IsDeleted == 0 &
            //                                            TablesLogic.tPurchaseInvoice.ObjectID != this.ObjectID);
            //    this.TotalTaxInSelectedCurrency = 
            //        (this.PurchaseOrder.totalGSTInSelectedCurrency - taxAmountInSelectedCurrency > 0 ? 
            //        this.PurchaseOrder.totalGSTInSelectedCurrency - taxAmountInSelectedCurrency : 0);
            //}

            // 2011.03.16
            // Kim Foong, 
            // fixed to check for != null instead
            //if (this.TotalAmountInSelectedCurrency == null && this.TaxCode != null)
            if (this.TotalAmountInSelectedCurrency != null && this.TaxCode != null)
                // FIX: 2011.05.23, Kim Foong, Round the computation of the Invoice tax to 2 decimal places.
                //this.TotalTaxInSelectedCurrency = this.TotalAmountInSelectedCurrency * this.TaxCode.TaxPercentage / 100;
                this.TotalTaxInSelectedCurrency = Round(this.TotalAmountInSelectedCurrency * this.TaxCode.TaxPercentage / 100);
        }

        /*
        /// <summary>
        /// Creates a new invoice object from a purchase order.
        /// </summary>
        /// <param name="po"></param>
        /// <returns></returns>
        public static OPurchaseInvoice CreateInvoiceFromPO(OPurchaseOrder po, int invoiceType)
        {
            using (Connection c = new Connection())
            {
                TPurchaseInvoice i = TablesLogic.tPurchaseInvoice;
                decimal totalInvoiceAmountInSelectedCurrency = 
                    (decimal)i.Select(i.TotalAmountInSelectedCurrency.Sum())
                    .Where(
                        i.IsDeleted == 0 &
                        i.InvoiceType == PurchaseInvoiceType.StandardInvoice &
                        i.CurrentActivity.ObjectName != "Cancelled" &
                        i.PurchaseOrderID == po.ObjectID) -
                    (decimal)i.Select(i.TotalAmountInSelectedCurrency.Sum())
                    .Where(
                        i.IsDeleted == 0 &
                        i.InvoiceType != PurchaseInvoiceType.StandardInvoice &
                        i.CurrentActivity.ObjectName != "Cancelled" &
                        i.PurchaseOrderID == po.ObjectID);


                decimal totalInvoiceAmount =
                    (decimal)i.Select(i.TotalAmount.Sum())
                    .Where(
                        i.IsDeleted == 0 &
                        i.InvoiceType == PurchaseInvoiceType.StandardInvoice &
                        i.CurrentActivity.ObjectName != "Cancelled" &
                        i.PurchaseOrderID == po.ObjectID) -
                    (decimal)i.Select(i.TotalAmount.Sum())
                    .Where(
                        i.IsDeleted == 0 &
                        i.InvoiceType != PurchaseInvoiceType.StandardInvoice &
                        i.CurrentActivity.ObjectName != "Cancelled" &
                        i.PurchaseOrderID == po.ObjectID);

                if (totalInvoiceAmountInSelectedCurrency < 0)
                    totalInvoiceAmountInSelectedCurrency = 0;
                if (totalInvoiceAmount < 0)
                    totalInvoiceAmount = 0;

                decimal totalPOAmountInSelectedCurrency = 0;
                decimal totalPOAmount = 0;
                foreach (OPurchaseOrderItem items in po.PurchaseOrderItems)
                {
                    totalPOAmountInSelectedCurrency += items.UnitPriceInSelectedCurrency.Value * items.QuantityOrdered.Value;
                    totalPOAmount += items.UnitPrice.Value * items.QuantityOrdered.Value;
                }

                OPurchaseInvoice invoice = TablesLogic.tPurchaseInvoice.Create();
                invoice.PurchaseOrderID = po.ObjectID;
                invoice.MatchType = PurchaseMatchType.InvoiceMatchedToPO;
                invoice.InvoiceType = invoiceType;
                invoice.LocationID = po.LocationID;
                invoice.EquipmentID = po.EquipmentID;
                invoice.PurchaseTypeID = po.PurchaseTypeID;
                invoice.Description = po.Description;
                invoice.VendorID = po.VendorID;
                invoice.CurrencyID = po.CurrencyID;
                invoice.DateOfInvoice = DateTime.Today;
                invoice.ForeignToBaseExchangeRate = po.ForeignToBaseExchangeRate;
                invoice.IsExchangeRateDefined = po.IsExchangeRateDefined;
                if (invoiceType == PurchaseInvoiceType.StandardInvoice)
                {
                    // for standard invoices, automatically
                    // compute the remaining uninvoiced amount
                    // on that PO.
                    //
                    invoice.TotalAmount = totalPOAmount - totalInvoiceAmount;
                    invoice.TotalAmountInSelectedCurrency = totalPOAmountInSelectedCurrency - totalInvoiceAmountInSelectedCurrency;
                }
                else
                {
                    invoice.TotalAmount = null;
                    invoice.TotalAmountInSelectedCurrency = null;

                    // for credit/debit memos matched to POs, auto select the
                    // invoice to credit/debit against, if only
                    // one invoice is available.
                    //
                    List<OPurchaseInvoice> invoices = TablesLogic.tPurchaseInvoice.LoadList(
                        TablesLogic.tPurchaseInvoice.InvoiceType == PurchaseInvoiceType.StandardInvoice &
                        TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName == "Approved" &
                        TablesLogic.tPurchaseInvoice.PurchaseOrderID == po.ObjectID);
                    if (invoices.Count == 1)
                        invoice.CreditDebitMemoOnInvoiceID = invoices[0].ObjectID;
                }
                invoice.TotalTax = null;
                invoice.TotalTaxInSelectedCurrency = null;

                invoice.UpdateVendorDetailsExceptCurrency();

                if (invoice.Vendor != null && invoice.Vendor.TaxCode != null &&
                    (invoice.Vendor.TaxCode.StartDate == null || invoice.Vendor.TaxCode.StartDate <= invoice.DateOfInvoice) &&
                    (invoice.Vendor.TaxCode.EndDate == null || invoice.Vendor.TaxCode.EndDate >= invoice.DateOfInvoice))
                {
                    invoice.TaxCodeID = invoice.Vendor.TaxCodeID;
                    invoice.UpdateTax();
                }
                invoice.UpdateTotalAmountAndTaxInBaseCurrency();
                invoice.UpdateApplicablePurchaseSettings();

                invoice.Save();
                invoice.TriggerWorkflowEvent("SaveAsDraft");
                c.Commit();
                return invoice;
            }

        }
        */

        /// <summary>
        /// Gets a list of non-cancelled invoices by purchase order.
        /// </summary>
        /// <param name="po"></param>
        /// <returns></returns>
        public static DataTable GetNonCancelledInvoicesByPurchaseOrder(OPurchaseOrder po)
        {
            TPurchaseInvoice t = TablesLogic.tPurchaseInvoice;

            DataTable dt = 
                t.Select(
                    t.ObjectID,
                    t.DateOfInvoice,
                    t.ObjectNumber,
                    t.Description,
                    t.TotalAmount,
                    t.InvoiceType,
                    t.TotalTax,
                    t.TotalAmountInSelectedCurrency,
                    t.TotalTaxInSelectedCurrency,
                    t.Currency.ObjectName.As("Currency.ObjectName"),
                    t.Currency.CurrencySymbol.As("Currency.CurrencySymbol"),
                    (t.TotalAmount + t.TotalTax).As("TotalAmountAndTax"),
                    t.Currency.ObjectName.As("Currency.ObjectName"),
                    t.CurrentActivity.ObjectName.As("CurrentActivity.ObjectName"))
                    .Where(
                    t.IsDeleted == 0 &
                    t.CurrentActivity.ObjectName != "Cancelled" &
                    t.PurchaseOrderID == po.ObjectID);

            dt.Columns.Add("InvoiceTypeText", typeof(String));
            foreach (DataRow dr in dt.Rows)
            {
                if((int)dr["InvoiceType"] == PurchaseInvoiceType.StandardInvoice)
                    dr["InvoiceTypeText"] = Resources.Strings.InvoiceType_StandardInvoice;
                else if ((int)dr["InvoiceType"] == PurchaseInvoiceType.CreditMemo)
                    dr["InvoiceTypeText"] = Resources.Strings.InvoiceType_CreditMemo;
                else if ((int)dr["InvoiceType"] == PurchaseInvoiceType.DebitMemo)
                    dr["InvoiceTypeText"] = Resources.Strings.InvoiceType_DebitMemo;
            }
            return dt;
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
                this.BudgetValidationPolicy = purchaseSettings.BudgetValidationPolicy;
                this.IsInvoiceGreaterThanPOAllowed = purchaseSettings.InvoiceLargerThanPO;
            }
            else
            {
                this.BudgetValidationPolicy = PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems;
            }
        }


        /// <summary>
        /// Validates that the budget amount is equals to the total
        /// invoice amount.
        /// <para></para>
        /// This function is generic and can be applied to any of
        /// the WJ/RFQ/PO objects provided the line items implement
        /// the ItemNumber and the Amount properties.
        /// </summary>
        /// <returns>Returns true if the validation succeeds. False otherwise.</returns>
        public bool ValidateBudgetAmountEqualsTotalAmount()
        {
            // If the budget validation is not required, return -1
            // immediately to indicate the validation succeeded.
            //
            if (this.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired)
                return true;

            // Find out the total amount by line items
            // or the entire WJ.
            // ADDED: recoverable amount.
            decimal totalAmount = this.TotalAmount.Value;
            decimal recoverableAmount = 0M;

            if (this.PurchaseOrder != null &&
                this.PurchaseOrder.IsRecoverable == (int)EnumRecoverable.Recoverable &&
                this.InvoiceType != PurchaseInvoiceType.CreditMemo &&
                this.InvoiceType != PurchaseInvoiceType.DebitMemo)
                recoverableAmount = Round(totalAmount * this.PurchaseOrder.TotalRecoverableAmount.Value / this.PurchaseOrder.SubTotal);

            totalAmount = totalAmount - recoverableAmount;

            // Find out the total budgeted amount by line items
            // or the entire WJ.
            //
            decimal totalBudgetAmount = 0M;
            foreach (OPurchaseBudget prBudget in this.PurchaseBudgets)
                totalBudgetAmount += prBudget.Amount.Value;

            // Compare the line items and the budget totals
            // to ensure that they match.
            //
            // Test based on the budget validation settings.
            //
            if (this.BudgetValidationPolicy == 
                PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems && 
                totalAmount != totalBudgetAmount)
                return false;
            if (this.BudgetValidationPolicy == 
                PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems && 
                totalAmount < totalBudgetAmount)
                return false;
            return true;
        }


        /// <summary>
        /// Validates that there is sufficient amount in the budgets
        /// for the deduction if this is a standard invoice.
        /// <para></para>
        /// NOTE: For credit/debit memos, we do not need to check
        /// for sufficient budgets, since we are technically adding
        /// money back into the budgets. 
        /// </summary>
        /// <returns>Returns a string of a list of budget periods and accounts
        /// that are insufficient. Returns an empty string otherwise.
        /// </returns>
        public string ValidateSufficientBudget()
        {
            if (this.InvoiceType == PurchaseInvoiceType.StandardInvoice)
            {
                // Standard invoices.
                //
                List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
                return OBudgetPeriod.CheckSufficientBalance(
                    OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null));
            }
            else
            {
                // For credit/debit memos, we do not have to check for sufficient
                // budget balances. 
                //
                return "";
            }
        }


        /// <summary>
        /// Gets a list of standard invoices matched to the specified purchase
        /// order ID.
        /// </summary>
        /// <param name="purchaseOrderId"></param>
        /// <returns></returns>
        public static DataTable GetPOMatchedStandardInvoices(Guid? purchaseOrderId, Guid? includingInvoiceId)
        {
            TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;

            return inv.Select(
                inv.ObjectID,
                (inv.ObjectNumber + ": " + inv.Description).As("ObjectNumberAndDescription"))
                .Where(
                inv.ObjectID == includingInvoiceId |
                (inv.IsDeleted == 0 &
                inv.CurrentActivity.ObjectName == "Approved" &
                inv.PurchaseOrderID == purchaseOrderId &
                inv.InvoiceType == PurchaseInvoiceType.StandardInvoice));
        }


        /// <summary>
        /// Validates that there are no non-cancelled credit
        /// or debit memos matched against this invoice.
        /// <para>
        /// </para>
        /// Returns the list of uncancelled credit/debit memo numbers
        /// matched against this invoice.
        /// </summary>
        /// <returns></returns>
        public String ValidateNoCreditOrDebitMemos()
        {
            if (this.InvoiceType == PurchaseInvoiceType.StandardInvoice)

            {
                TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;
                
                DataTable  dt = inv.Select(inv.ObjectNumber)
                      .Where(
                      inv.IsDeleted == 0 &
                      inv.CurrentActivity.ObjectName != "Cancelled" &
                      inv.CreditDebitMemoOnInvoiceID == this.ObjectID &
                      (inv.InvoiceType == PurchaseInvoiceType.CreditMemo |
                      inv.InvoiceType == PurchaseInvoiceType.DebitMemo) &
                      (inv.IsAutoGeneratedFromInvoice == null | inv.IsAutoGeneratedFromInvoice == 0));
                
                StringBuilder sb = new StringBuilder();
                foreach (DataRow dr in dt.Rows)
                    sb.Append(dr[0].ToString() + "; ");
                return sb.ToString();
               
            }
            return "";
        }


        /// <summary>
        /// Updates the vendor details based on the invoice that
        /// this current credit/debit memo is created against.
        /// </summary>
        public void UpdateDetailsFromStandardInvoice()
        {
            OPurchaseInvoice parentInvoice = this.CreditDebitMemoOnInvoice;
            if (parentInvoice != null)
            {
                this.PurchaseOrderID = parentInvoice.PurchaseOrderID;
                this.MatchType = parentInvoice.MatchType;
                this.LocationID = parentInvoice.LocationID;
                this.EquipmentID = parentInvoice.EquipmentID;

                // 2011.08.01, Kien Trung
                // FIX: copy transactiontypeid, budgetgroupID
                // PurchaseTypeID over to credit memo.
                //
                this.TransactionTypeGroupID = parentInvoice.TransactionTypeGroupID;
                this.PurchaseTypeID = parentInvoice.PurchaseTypeID;
                this.BudgetGroupID = parentInvoice.BudgetGroupID;

                this.VendorID = parentInvoice.VendorID;
                this.ContactAddress = parentInvoice.ContactAddress;
                this.ContactAddressState = parentInvoice.ContactAddressState;
                this.ContactAddressCity = parentInvoice.ContactAddressCity;
                this.ContactAddress = parentInvoice.ContactAddress;
                this.ContactCellPhone = parentInvoice.ContactCellPhone;
                this.ContactEmail = parentInvoice.ContactEmail;
                this.ContactFax = parentInvoice.ContactFax;
                this.ContactPerson = parentInvoice.ContactPerson;
                this.ContactPhone = parentInvoice.ContactPhone;
                this.CurrencyID = parentInvoice.CurrencyID;
                this.ForeignToBaseExchangeRate = parentInvoice.ForeignToBaseExchangeRate;
                this.TaxCodeID = parentInvoice.TaxCodeID;
                this.Description = parentInvoice.Description;
            }
        }


        /// <summary>
        /// Validates that there is sufficient budget for the cancellation
        /// of credit/debit memos.
        /// <para></para>
        /// This is required because the cancellation of a credit/debit memo
        /// will result in deducting from the budgets.
        /// </summary>
        public string ValidateSufficientBudgetForCancellation()
        {
            if (this.InvoiceType == PurchaseInvoiceType.CreditMemo ||
                this.InvoiceType == PurchaseInvoiceType.DebitMemo)
            {
                List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
                return OBudgetPeriod.CheckSufficientBalance(
                    OPurchaseBudget.CreateCreditDebitMemoBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.DirectInvoiceApproved, transactions));
            }
            else
                return "";
        }


        /// <summary>
        /// Creates a credit memo from an existing standard invoice.
        /// </summary>
        /// <param name="standardInvoice"></param>
        /// <returns></returns>
        public static OPurchaseInvoice CreateCreditMemoFromStandardInvoice(
            OPurchaseInvoice standardInvoice)
        {
            OPurchaseInvoice newInvoice = null;
            using (Connection c = new Connection())
            {
                newInvoice = TablesLogic.tPurchaseInvoice.Create();
                newInvoice.DateOfInvoice = DateTime.Today;
                newInvoice.InvoiceType = PurchaseInvoiceType.CreditMemo;
                newInvoice.CreditDebitMemoOnInvoiceID = standardInvoice.ObjectID;
                
                newInvoice.UpdateDetailsFromStandardInvoice();
                newInvoice.Save();
                newInvoice.TriggerWorkflowEvent("SaveAsDraft");
                newInvoice.Save();
                c.Commit();
            }
            return newInvoice;
        }


        /// <summary>
        /// Creates a debit memo from an existing standard invoice.
        /// </summary>
        /// <param name="standardInvoice"></param>
        /// <returns></returns>
        public static OPurchaseInvoice CreateDebitMemoFromStandardInvoice(
            OPurchaseInvoice standardInvoice)
        {
            OPurchaseInvoice newInvoice = null;
            using (Connection c = new Connection())
            {
                newInvoice = TablesLogic.tPurchaseInvoice.Create();
                newInvoice.DateOfInvoice = DateTime.Today;
                newInvoice.InvoiceType = PurchaseInvoiceType.DebitMemo;
                newInvoice.CreditDebitMemoOnInvoiceID = standardInvoice.ObjectID;
                newInvoice.UpdateDetailsFromStandardInvoice();
                newInvoice.Save();
                newInvoice.TriggerWorkflowEvent("SaveAsDraft");
                newInvoice.Save();
                c.Commit();
            }
            return newInvoice;
        }


        /// <summary>
        /// Validates than the sum of the total credit/debit memo amounts
        /// include this credit/debit memo's is less than or equals
        /// to the total original invoice amount.
        /// <para></para>
        /// This method also ensures that the sum of the tax amounts also
        /// meets the requirements.
        /// </summary>
        /// <returns></returns>
        public bool ValidateTotalCreditDebitMemoAmountLessThanOriginalInvoiceAmount()
        {
            if (this.InvoiceType == PurchaseInvoiceType.CreditMemo ||
                this.InvoiceType == PurchaseInvoiceType.DebitMemo)
            {
                TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;

                decimal totalCreditAmount =
                    inv.Select(inv.TotalAmount.Sum())
                    .Where(
                    inv.IsDeleted == 0 &
                    inv.CurrentActivity.ObjectName != "Approved" &
                    // 2011.08.21, Kien Trung
                    // Bug Fixed: add condition != this.ObjectID to exclude
                    // the current credit memo.
                    inv.ObjectID != this.ObjectID &
                    inv.CreditDebitMemoOnInvoiceID == this.CreditDebitMemoOnInvoiceID &
                    (inv.InvoiceType == PurchaseInvoiceType.CreditMemo |
                    inv.InvoiceType == PurchaseInvoiceType.DebitMemo));

                decimal totalCreditTax =
                    inv.Select(inv.TotalTax.Sum())
                    .Where(
                    inv.IsDeleted == 0 &
                    inv.CurrentActivity.ObjectName != "Approved" &
                    // 2011.08.21, Kien Trung
                    // Bug Fixed: add condition != this.ObjectID to exclude
                    // the current credit memo.
                    inv.ObjectID != this.ObjectID &
                    inv.CreditDebitMemoOnInvoiceID == this.CreditDebitMemoOnInvoiceID &
                    (inv.InvoiceType == PurchaseInvoiceType.CreditMemo |
                    inv.InvoiceType == PurchaseInvoiceType.DebitMemo));

                decimal totalInvoiceAmount = 0;
                decimal totalInvoiceTax = 0;
                
                if (this.CreditDebitMemoOnInvoice.TotalAmount != null)
                    totalInvoiceAmount = this.CreditDebitMemoOnInvoice.TotalAmount.Value;
                if (this.CreditDebitMemoOnInvoice.TotalTax != null)
                    totalInvoiceTax = this.CreditDebitMemoOnInvoice.TotalTax.Value;

                if ((totalCreditAmount + this.TotalAmount.Value) > totalInvoiceAmount)
                    return false;

                if ((totalCreditTax + this.TotalTax.Value) > totalInvoiceTax)
                    return false;
            }

            return true;
        }

    }


    /// <summary>
    /// Enumerates the different types of invoices.
    /// </summary>
    public class PurchaseMatchType
    {
        /// <summary>
        /// A direct invoice that does not have PO.
        /// </summary>
        public const int DirectInvoice = 0;

        /// <summary>
        /// An invoice that is matched to a PO.
        /// </summary>
        public const int InvoiceMatchedToPO = 1;

        /// <summary>
        /// An invoice that is matched to a PO receipt.
        /// </summary>
        public const int InvoiceMatchedToPOReceipt = 2;
    }


    /// <summary>
    /// Enumerates the different types of invoices.
    /// </summary>
    public class PurchaseInvoiceType
    {
        /// <summary>
        /// A standard invoice.
        /// </summary>
        public const int StandardInvoice = 0;

        /// <summary>
        /// A credit memo.
        /// </summary>
        public const int CreditMemo = 1;

        /// <summary>
        /// A debit memo.
        /// </summary>
        public const int DebitMemo = 2;
    }
}
