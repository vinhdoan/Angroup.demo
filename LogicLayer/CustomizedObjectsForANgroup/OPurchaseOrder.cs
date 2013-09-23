//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text.RegularExpressions;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OPurchaseOrder
    /// </summary>
    public partial class TPurchaseOrder : LogicLayerSchema<OPurchaseOrder>
    {
        public SchemaDateTime DateAccounted;

        public SchemaDateTime DateVarianceAccounted;

        public SchemaGuid TransactionTypeGroupID;

        public SchemaInt POType;

        public TCode TransactionTypeGroup { get { return OneToOne<TCode>("TransactionTypeGroupID"); } }

        // These fields are for Letter of Award.
        //
        public SchemaGuid TrustID;
        public SchemaGuid LOAOnBehalfOfID;
        public SchemaGuid SignatoryID;

        // These fields are for Purchase Order.
        //
        public SchemaGuid DeliveryToID;
        public SchemaGuid BillToID;
        public SchemaDateTime DeliveryDate;

        // This field is for both PO and LOA.
        //
        public SchemaGuid ManagementCompanyID;

        // for PaymentSchedule
        //
        [Default(0)]
        public SchemaInt IsPaymentPaidByPercentage;

        public SchemaDateTime WorkCompletionDate;

        public SchemaInt HasWarranty;

        public SchemaInt WarrantyPeriod;

        public SchemaInt WarrantyUnit;

        public SchemaString Warranty;

        public SchemaInt IsGroupPO;

        public SchemaGuid BudgetGroupID;

        public SchemaGuid CampaignID;

        public SchemaGuid RequestForQuotationID;

        [Default(0)]
        public SchemaInt HasTaxCodePerLineItem;

        public SchemaGuid DeliverToContactPersonID;

        public SchemaGuid BillToContactPersonID;

        public ExpressionData TotalPOAmount
        {
            get
            {
                TPurchaseOrderItem poi = TablesLogic.tPurchaseOrderItem;

                return poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == this.ObjectID);
            }
        }

        public ExpressionData TotalInvoiced
        {
            get
            {
                TPurchaseOrder po = TablesLogic.tPurchaseOrder;
                TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;

                // 2011.02.16
                // Kim Foong
                // Included the Close status.
                return inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == this.ObjectID & inv.IsDeleted == 0 & (inv.CurrentActivity.ObjectName == "Approved" | inv.CurrentActivity.ObjectName == "Close") & inv.InvoiceType == 0);
            }
        }

        public ExpressionData TotalCreditDebit
        {
            get
            {
                TPurchaseOrder po = TablesLogic.tPurchaseOrder;
                TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;

                // 2011.02.16
                // Kim Foong
                // Included the Close status.
                return inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == this.ObjectID & inv.IsDeleted == 0 & (inv.CurrentActivity.ObjectName == "Approved" | inv.CurrentActivity.ObjectName == "Close") & inv.InvoiceType != 0);
            }
        }

        public TCapitalandCompany ManagementCompany { get { return OneToOne<TCapitalandCompany>("ManagementCompanyID"); } }

        public TCapitalandCompany DeliveryTo { get { return OneToOne<TCapitalandCompany>("DeliveryToID"); } }

        public TCapitalandCompany BillTo { get { return OneToOne<TCapitalandCompany>("BillToID"); } }

        public TCapitalandCompany Trust { get { return OneToOne<TCapitalandCompany>("TrustID"); } }

        public TCapitalandCompany LOAOnBehalfOf { get { return OneToOne<TCapitalandCompany>("LOAOnBehalfOfID"); } }

        public TUser Signatory { get { return OneToOne<TUser>("SignatoryID"); } }

        public TPurchaseOrderPaymentSchedule PurchaseOrderPaymentSchedules { get { return OneToMany<TPurchaseOrderPaymentSchedule>("PurchaseOrderID"); } }

        public TLocation GroupPOLocations { get { return ManyToMany<TLocation>("PurchaseOrderLocation", "PurchaseOrderID", "LocationID"); } }

        public TRequestForQuotation RequestForQuotation { get { return OneToOne<TRequestForQuotation>("RequestForQuotationID"); } }

        public TUser DeliverToContactPerson { get { return OneToOne<TUser>("DeliverToContactPersonID"); } }

        public TUser BillToContactPerson { get { return OneToOne<TUser>("BillToContactPersonID"); } }
    }

    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseOrder : LogicLayerPersistentObject
    {
        /// <summary>
        ///
        /// </summary>
        public abstract DateTime? DateAccounted { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DateTime? DateVarianceAccounted { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? TransactionTypeGroupID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? POType { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCode TransactionTypeGroup { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? TrustID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? LOAOnBehalfOfID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? SignatoryID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? DeliveryToID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? BillToID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DateTime? DeliveryDate { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? ManagementCompanyID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? CampaignID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? IsPaymentPaidByPercentage { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DateTime? WorkCompletionDate { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? HasWarranty { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? WarrantyPeriod { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? WarrantyUnit { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract string Warranty { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? IsGroupPO { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? BudgetGroupID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? HasTaxCodePerLineItem { get; set; }

        /// <summary>
        /// Gets or set contact person ID for Delivery To
        /// (for Marcom instance only)
        /// </summary>
        public abstract Guid? DeliverToContactPersonID { get; set; }

        /// <summary>
        /// Gets or set contact person ID for Bill To
        /// (for Marcom instance only)
        /// </summary>
        public abstract Guid? BillToContactPersonID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCapitalandCompany ManagementCompany { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCapitalandCompany DeliveryTo { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCapitalandCompany BillTo { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCapitalandCompany Trust { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCapitalandCompany LOAOnBehalfOf { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract OUser Signatory { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<OPurchaseOrderPaymentSchedule> PurchaseOrderPaymentSchedules { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<OLocation> GroupPOLocations { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? RequestForQuotationID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract ORequestForQuotation RequestForQuotation { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OUser DeliverToContactPerson { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OUser BillToContactPerson { get; set; }

        public List<OAttachment> TempEmailMessageAttachments;

        public string TypeText
        {
            get
            {
                if (POType == PurchaseOrderType.PO)
                    return Resources.Strings.PurchaseOrder_PurchaseOrder;
                else if (POType == PurchaseOrderType.LOA)
                    return Resources.Strings.PurchaseOrder_LetterOfAward;

                return Resources.Strings.PurchaseOrder_PurchaseOrder;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="po"></param>
        /// <returns></returns>
        public static OAttachment GeneratePODocument(OPurchaseOrder po)
        {
            List<ODocumentTemplate> listDocTemplates = ODocumentTemplate.GetDocumentTemplates("OPurchaseOrder", po, po.CurrentActivity.ObjectName);
            ODocumentTemplate template = listDocTemplates.Find((d) =>
                d.TemplateType == DocumentTemplate.RDLTemplate |
                d.TemplateType == DocumentTemplate.CrystalTemplate);

            byte[] fileBytes = DocumentGenerator.GenerateDocument(template, po);

            OAttachment attachment = TablesLogic.tAttachment.Create();
            attachment.Filename = po.ObjectNumber.Replace(" ", "_").Replace("/", "_") + ".pdf";
            attachment.FileBytes = fileBytes;

            return attachment;
        }

        /// <summary>
        ///
        /// </summary>
        public override List<OAttachment> EmailMessageAttachments
        {
            get
            {
                // this is for attachment sending email.
                // to avoid attachment of emails too big.
                //
                List<OAttachment> attachments = new List<OAttachment>();

                OAttachment attachment = OPurchaseOrder.GeneratePODocument(this);

                attachments.Add(attachment);

                if (this.TempEmailMessageAttachments != null)
                    attachments.AddRange(this.TempEmailMessageAttachments);

                return attachments;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public List<OPurchaseInvoice> NonCancelledPurchaseInvoices
        {
            get
            {
                List<OPurchaseInvoice> invoices = new List<OPurchaseInvoice>();
                foreach (OPurchaseInvoice invoice in this.PurchaseInvoices)
                    if (!invoice.CurrentActivity.ObjectName.Is("Cancelled"))
                        invoices.Add(invoice);
                return invoices;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public decimal? TotalInvoiced
        {
            get
            {
                decimal? totalInvoiced = 0;
                foreach (OPurchaseInvoice invoice in this.PurchaseInvoices)
                {
                    if ((invoice.CurrentActivity.ObjectName.Is("Approved") ||
                        invoice.CurrentActivity.ObjectName.Is("Close")) &&
                        invoice.InvoiceType == PurchaseInvoiceType.StandardInvoice)
                        totalInvoiced += invoice.TotalAmount;
                }
                return totalInvoiced;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public decimal? TotalCreditDebit
        {
            get
            {
                decimal? totalCreditDebit = 0.0M;
                foreach (OPurchaseInvoice invoice in this.PurchaseInvoices)
                {
                    if ((invoice.CurrentActivity.ObjectName.Is("Approved") ||
                        invoice.CurrentActivity.ObjectName.Is("Close")) &&
                        (invoice.InvoiceType == PurchaseInvoiceType.CreditMemo ||
                        invoice.InvoiceType == PurchaseInvoiceType.DebitMemo))
                        totalCreditDebit += invoice.TotalAmount;
                }
                return totalCreditDebit;
            }
        }

        /// <summary>
        /// Frst Purchase Budget path
        /// for PO document template purpose
        /// </summary>
        public string FirstPurchaseBudgetPath
        {
            get
            {
                string budgetPath = "";
                if (this.PurchaseBudgets.Count > 0)
                {
                    OAccount account = PurchaseBudgets[0].Account;
                    budgetPath = account.Path;
                }
                return budgetPath;
            }
        }

        /// <summary>
        /// for PO Document Template
        /// </summary>
        public Decimal SubTotal
        {
            get
            {
                decimal total = 0;
                foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                {
                    total += item.Subtotal.Value;
                }
                return total;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public decimal? TotalRecoverableAmount
        {
            get
            {
                decimal total = 0;
                if (this.IsRecoverable == (int)EnumRecoverable.Recoverable)
                    foreach (OPurchaseOrderItem i in this.PurchaseOrderItems)
                        total += i.RecoverableAmount.Value;
                return total;
            }
        }

        /// <summary>
        /// for PO Document Template
        /// </summary>
        public Decimal SubTotalInSelectedCurrency
        {
            get
            {
                decimal total = 0;
                foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                {
                    total += item.SubtotalInSelectedCurrency.Value;
                }
                return total;
            }
        }

        public void UpdateSingleItemRecoverable(OPurchaseOrderItem item)
        {
            OCurrency baseCurrency = OApplicationSetting.Current.BaseCurrency;
            item.RecoverableAmountInSelectedCurrency = Round(item.RecoverableAmountInSelectedCurrency);

            if (item.CurrencyID == baseCurrency.ObjectID)
                item.RecoverableAmount = item.RecoverableAmountInSelectedCurrency;
            else
                item.RecoverableAmount = Round(item.RecoverableAmountInSelectedCurrency * this.ForeignToBaseExchangeRate);
        }

        /// <summary>
        ///
        /// </summary>
        public void UpdateItemRecoverables()
        {
            foreach (OPurchaseOrderItem poItem in this.PurchaseOrderItems)
            {
                poItem.CurrencyID = this.CurrencyID;
                UpdateSingleItemRecoverable(poItem);
            }
        }

        /// <summary>
        ///
        /// </summary>
        public decimal? TotalRecoverableAmountInSelectedCurrency
        {
            get
            {
                decimal total = 0;
                if (this.IsRecoverable == (int)EnumRecoverable.Recoverable)
                    foreach (OPurchaseOrderItem i in this.PurchaseOrderItems)
                        total += i.RecoverableAmountInSelectedCurrency.Value;
                return total;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public Decimal SubTotalOriginalAmount
        {
            get
            {
                decimal total = 0;
                foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                {
                    total += item.SubtotalOriginalAmount.Value;
                }
                return total;
            }
        }

        /// <summary>
        /// for PO Document Template
        /// </summary>
        public Decimal totalGST
        {
            get
            {
                decimal gst = 0;
                decimal vendorTaxAmount = 0;
                if (this.Vendor != null && this.Vendor.TaxCode != null)
                    vendorTaxAmount = this.Vendor.TaxCode.TaxPercentage.Value / 100;
                //taxcode per line item
                if (OApplicationSetting.Current.AllowPerLineItemTaxInPO != null && OApplicationSetting.Current.AllowPerLineItemTaxInPO == 1 &&
                    this.HasTaxCodePerLineItem != null && this.HasTaxCodePerLineItem == 1)
                {
                    foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                    {
                        //if(item.TaxCodeID!=null)
                        //{
                        //    OTaxCode taxcode = TablesLogic.tTaxCode.Load(item.TaxCodeID);
                        //    if (taxcode != null)
                        //        gst += item.Subtotal.Value * (taxcode.TaxPercentage.Value / 100);
                        //}
                        //else
                        //    gst += item.Subtotal.Value * vendorTaxAmount;
                        if (item.TaxAmount != null)
                            gst += item.TaxAmount.Value;
                    }
                }
                else//taxcode from vendor
                    gst = this.SubTotal * vendorTaxAmount;
                return gst;
            }
        }

        /// <summary>
        /// for PO Document Template
        /// </summary>
        public Decimal totalGSTInSelectedCurrency
        {
            get
            {
                decimal gst = 0;
                decimal vendorTaxAmount = 0;
                if (this.Vendor != null && this.Vendor.TaxCode != null)
                    vendorTaxAmount = this.Vendor.TaxCode.TaxPercentage.Value / 100;
                //taxcode per line item
                if (OApplicationSetting.Current.AllowPerLineItemTaxInPO != null && OApplicationSetting.Current.AllowPerLineItemTaxInPO == 1 &&
                    this.HasTaxCodePerLineItem != null && this.HasTaxCodePerLineItem == 1)
                {
                    foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                    {
                        // 2011.02.15
                        // Kien Trung
                        // Sum of tax amount for each line item instead of calculate
                        // tax amount by tax code.

                        //if(item.TaxCodeID!=null)
                        //{
                        //    OTaxCode taxcode = TablesLogic.tTaxCode.Load(item.TaxCodeID);
                        //    if (taxcode != null)
                        //        gst += item.SubtotalInSelectedCurrency.Value * (taxcode.TaxPercentage.Value / 100);
                        //}
                        //else
                        //    gst += item.SubtotalInSelectedCurrency.Value * vendorTaxAmount;
                        gst += item.TaxAmount.Value;
                    }
                }
                else//taxcode from vendor
                    gst = this.SubTotalInSelectedCurrency * vendorTaxAmount;
                return gst;
            }
        }

        /// <summary>
        /// for PO Document Template
        /// </summary>
        public Decimal TotalWithGST
        {
            get { return this.SubTotal + this.totalGST; }
        }

        /// <summary>
        /// for PO Document Template
        /// </summary>
        public Decimal TotalWithGSTInSelectedCurrency
        {
            get { return this.SubTotalInSelectedCurrency + this.totalGSTInSelectedCurrency; }
        }

        /// <summary>
        /// Get the RFQNumber if the PO is generated by RFQ
        /// </summary>
        public String RFQNumber
        {
            get
            {
                string number = "";
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    number = PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.ObjectNumber;
                }
                return number;
            }
        }

        /// <summary>
        /// get quotation reference number which is AwardedRequestForQuotationVendor's Number
        /// if the PO is generated by RFQ
        /// </summary>
        public String QuotationNumber
        {
            get
            {
                string number = "";
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null
                    && PurchaseOrderItems[0].RequestForQuotationItem.AwardedRequestForQuotationVendorItem != null)
                {
                    number = PurchaseOrderItems[0].RequestForQuotationItem.AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ObjectNumber;
                }
                return number;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public String CompanyName
        {
            get
            {
                string name = "";
                if (this.ManagementCompany != null)
                {
                    if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM" ||
                         ConfigurationManager.AppSettings["CustomizedInstance"] == "IT" ||
                         ConfigurationManager.AppSettings["CustomizedInstance"] == "OPS")
                    {
                        name = this.ManagementCompany.ObjectName.Replace("#", "<br>");
                    }
                    else
                        name = this.ManagementCompany.ObjectName;
                }
                return name;
            }
        }

        /// <summary>
        /// Get the RFQ Created User if the PO is generated from RFQ
        /// </summary>
        public String RFQCreatedUser
        {
            get
            {
                string createdUser = "";
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    createdUser = PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.RequestorName;
                }
                return createdUser;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public DateTime? RFQCreatedDate
        {
            get
            {
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    return PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.CreatedDateTime;
                }
                return null;
            }
        }

        public String RFQDescription
        {
            get
            {
                string number = "";
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    number = PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.Description;
                }
                return number;
            }
        }

        public String RFQScope
        {
            get
            {
                string number = "";
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    number = PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.Scope;
                }
                return number;
            }
        }

        public String RFQEmployerCompany
        {
            get
            {
                string com = "";
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    com = (PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.EmployerCompany != null ?
                        PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.EmployerCompany.ObjectName :
                        "");
                }
                return com;
            }
        }

        public DateTime? RFQStartDate
        {
            get
            {
                DateTime? RFQStartDate = null;
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    RFQStartDate = PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.DateRequired;
                }
                return RFQStartDate;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public DateTime? RFQEndDate
        {
            get
            {
                DateTime? RFQEndDate = null;
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    RFQEndDate = PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.DateEnd;
                }
                return RFQEndDate;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public String RFQTitle
        {
            get
            {
                String RFQTitle = null;
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    RFQTitle = (PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.RFQTitle != null ?
                        PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.RFQTitle.ToUpper() : "");
                }
                return RFQTitle;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public String RFQBackground
        {
            get
            {
                String RFQBackground = "";
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                {
                    RFQBackground = (PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.Background != null ?
                        PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.Background : "");
                }
                return RFQBackground;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public String DeliveryPhoneNo
        {
            get
            {
                string phone = "";
                if (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                {
                    if (DeliverToContactPerson != null)
                    {
                        phone = DeliverToContactPerson.UserBase.Phone;
                    }
                }
                else
                {
                    if (this.DeliveryTo != null)
                        phone = this.DeliveryTo.PhoneNo;
                }
                return phone;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public String DeliveryFax
        {
            get
            {
                string fax = "";
                if (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                {
                    if (DeliverToContactPerson != null)
                    {
                        fax = DeliverToContactPerson.UserBase.Fax;
                    }
                }
                else
                {
                    if (this.DeliveryTo != null)
                        fax = this.DeliveryTo.FaxNo;
                }
                return fax;
            }
        }

        public int IsTaxAmountShow
        {
            get
            {
                int i = 0;
                if (this.HasTaxCodePerLineItem != null && this.HasTaxCodePerLineItem == 1)
                    i = 1;
                return i;
            }
        }

        public Decimal TotalInvoiceAmount
        {
            get
            {
                decimal total = 0;
                foreach (OPurchaseInvoice invoice in this.PurchaseInvoices)
                {
                    total += (decimal)invoice.TotalAmount;
                }
                return total;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public DateTime? RFQApprovedDate
        {
            get
            {
                if (this.PurchaseOrderItems.Count > 0 && PurchaseOrderItems[0].RequestForQuotationItem != null)
                    return PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.LastApprovalDate;
                return this.DateOfOrder;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public string ManagementCompanyName
        {
            get
            {
                string name = this.ManagementCompany.ObjectName;
                string operate = name.Replace("#", "<br/>");
                return operate;
            }
        }

        /// <summary>
        /// Update the object name to show the WJ number.
        /// </summary>
        public override void Saving2()
        {
            base.Saving2();

            string rfqNumber = this.RFQNumber;
            if (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            {
                if (this.CampaignID != null)
                {
                    string campaign = TablesLogic.tCampaign.Load(this.CampaignID).ObjectName;
                    this.ObjectName = campaign + "/" + this.Description;
                }
            }
            else
            {
                if (rfqNumber != "")
                    this.ObjectName = String.Format("({0}) {1}", rfqNumber, this.Description);
            }
        }

        /// <summary>
        /// Account for POs. (For capitaland DEMO)
        /// </summary>
        /// <param name="poIds"></param>
        public static void AccountPurchaseOrder(List<object> poIds, DateTime date)
        {
            List<OPurchaseOrder> pos = TablesLogic.tPurchaseOrder.LoadList(
                TablesLogic.tPurchaseOrder.ObjectID.In(poIds));

            using (Connection c = new Connection())
            {
                foreach (OPurchaseOrder po in pos)
                {
                    po.DateAccounted = date;
                    po.Save();
                }
                c.Commit();
            }
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
        public static OPurchaseOrder CreatePOFromPRLineItemsWithBudget(List<OPurchaseRequestItem> items)
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
                o.PurchaseTypeID = r.PurchaseTypeID;
                o.TransactionTypeGroupID = r.TransactionTypeGroupID;
                AddPOLineItemsFromPRLineItemsWithBudget(o, items);

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
        public static void AddPOLineItemsFromPRLineItemsWithBudget(OPurchaseOrder o, List<OPurchaseRequestItem> items)
        {
            using (Connection c = new Connection())
            {
                int i = TablesLogic.tPurchaseOrderItem[
                    TablesLogic.tPurchaseOrderItem.PurchaseOrderID == o.ObjectID].Count + 1;

                Hashtable purchaseRequests = new Hashtable();
                List<Guid> purchaseRequestIds = new List<Guid>();

                foreach (OPurchaseRequestItem item in items)
                {
                    if (item.RequestForQuotationItem == null && item.PurchaseOrderItem == null)
                    {
                        OPurchaseOrderItem n = TablesLogic.tPurchaseOrderItem.Create();
                        OPurchaseRequest pr = null;
                        if (purchaseRequests[item.PurchaseRequestID.Value] == null)
                        {
                            pr = TablesLogic.tPurchaseRequest.Load(item.PurchaseRequestID);
                            purchaseRequests[item.PurchaseRequestID.Value] = pr;
                        }
                        else
                            pr = purchaseRequests[item.PurchaseRequestID.Value] as OPurchaseRequest;

                        // Transfer budget transactions over to the PO.
                        //
                        List<OPurchaseBudget> newPurchaseBudgets =
                            OPurchaseBudget.TransferPurchaseBudgets(pr.PurchaseBudgets, item.ItemNumber);

                        foreach (OPurchaseBudget purchaseBudget in newPurchaseBudgets)
                            purchaseBudget.ItemNumber = i;
                        o.PurchaseBudgets.AddRange(newPurchaseBudgets);

                        n.ItemNumber = i++;
                        n.ItemType = item.ItemType;
                        n.CatalogueID = item.CatalogueID;
                        n.FixedRateID = item.FixedRateID;
                        n.ItemDescription = item.ItemDescription;
                        n.UnitOfMeasureID = item.UnitOfMeasureID;
                        n.QuantityOrdered = item.QuantityRequired;
                        n.PurchaseRequestItemID = item.ObjectID;
                        n.ReceiptMode = item.ReceiptMode;
                        n.EstimatedUnitPrice = item.EstimatedUnitPrice;

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

                // Transfer all the budgets over to the PO.
                //
                List<OBudgetTransactionLog> newTransactions = new List<OBudgetTransactionLog>();
                List<OBudgetTransactionLog> modifiedTransactions = new List<OBudgetTransactionLog>();
                OPurchaseBudget.CreateBudgetTransactionLogs(o.PurchaseBudgets, BudgetTransactionType.PurchaseApproved, newTransactions, modifiedTransactions);
                foreach (OBudgetTransactionLog transaction in newTransactions)
                    transaction.Save();
                foreach (OBudgetTransactionLog transaction in modifiedTransactions)
                    transaction.Save();

                // here we check and make sure that the request for quotation is set to "CLOSED"
                // when all items have been copied to a purchase order.
                //
                foreach (OPurchaseRequest obj in purchaseRequests.Values)
                {
                    if (obj != null)
                    {
                        bool isClosed = true;
                        foreach (OPurchaseRequestItem objItem in obj.PurchaseRequestItems)
                            if (objItem.PurchaseOrderItem == null)
                            {
                                isClosed = false;
                                break;
                            }
                        if (isClosed && obj.CurrentActivity.ObjectName != "Close")
                        {
                            obj.TriggerWorkflowEvent("Close");
                            obj.Save();
                        }
                    }
                }
                c.Commit();
            }
        }

        /// <summary>
        /// Account for POs. (For capitaland DEMO)
        /// </summary>
        /// <param name="poIds"></param>
        public static void AccountPurchaseOrderVariance(List<object> poIds, DateTime date)
        {
            List<OPurchaseOrder> pos = TablesLogic.tPurchaseOrder.LoadList(
                TablesLogic.tPurchaseOrder.ObjectID.In(poIds));

            using (Connection c = new Connection())
            {
                foreach (OPurchaseOrder po in pos)
                {
                    po.DateVarianceAccounted = date;
                    po.Save();
                }
                c.Commit();
            }
        }

        public bool IsSkipApprovalAllow()
        {
            bool skipApproval = false;
            decimal? totalBudgetAmount = 0;
            decimal? totalAmount = 0;
            if (this.IsApproved != 1)
            {
                foreach (OPurchaseBudget budget in this.PurchaseBudgets)
                {
                    totalBudgetAmount += budget.Amount;
                }
                foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                {
                    if (item.PurchaseRequestItemID != null)
                    {
                        foreach (OPurchaseBudget budget in item.PurchaseRequestItem.PurchaseRequest.PurchaseBudgets)
                        {
                            totalAmount += budget.Amount;
                        }
                        if (totalAmount >= totalBudgetAmount)
                            skipApproval = true;
                    }
                    if (item.RequestForQuotationItemID != null)
                    {
                        foreach (OPurchaseBudget budget in item.RequestForQuotationItem.RequestForQuotation.PurchaseBudgets)
                        {
                            totalAmount += budget.Amount;
                        }
                        if (totalAmount >= totalBudgetAmount)
                            skipApproval = true;
                    }
                }
            }
            return skipApproval;
        }

        /// <summary>
        /// Approves the Purchase Order by doing the following:<br/>
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
                    // Create a new contract tied to this purchase order.
                    //
                    if (this.IsTermContract == 1 && this.POType == PurchaseOrderType.LOA)
                    {
                        OContract contract = TablesLogic.tContract.Create();
                        contract.ContractStartDate = this.DateRequired;
                        contract.ContractEndDate = this.DateEnd;
                        contract.Description = this.Description;
                        decimal total = 0;
                        foreach (OPurchaseOrderItem poi in this.PurchaseOrderItems)
                            total += Round(poi.UnitPrice.Value * poi.QuantityOrdered.Value);
                        contract.ContractSum = total;
                        contract.VendorID = this.VendorID;
                        contract.Terms = "";
                        contract.Warranty = "";
                        contract.Insurance = "";
                        contract.ContactCellphone = "";
                        contract.ContactEmail = "";
                        contract.ContactFax = "";
                        contract.ContactPerson = "";
                        contract.ContactPhone = "";
                        contract.ObjectName = this.Description;
                        contract.ProvideMaintenance = 0;
                        contract.ProvidePricingAgreement = 0;
                        contract.PurchaseOrderID = this.ObjectID;
                        contract.Save();
                        contract.TriggerWorkflowEvent("Start");
                        contract.Save();

                        this.GeneratedTermContractID = contract.ObjectID;
                    }

                    if (this.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired &&
                        this.BudgetDistributionMode != null)
                    {
                        List<OBudgetTransactionLog> transactions = null;

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
                        transactions = OPurchaseBudget.SetBudgetTransactionLogsTransactionType(
                            this.PurchaseBudgets, BudgetTransactionType.PurchaseApproved);

                        // Stamp budget summaries with current budget balance at approval.
                        //
                        OPurchaseBudgetSummary.UpdateBudgetSummariesAfterApproval(transactions, this.PurchaseBudgetSummaries);
                    }
                    this.IsApproved = 1;
                }

                ////Nguyen Quoc Phuong 5-Dec-2012
                //int? status = this.UpdateCRVGProcurementContract();
                //if (status != (int)EnumCRVUpdateGroupProcurementContractStatus.SUCCESSFUL)
                //{
                //    this.CRVSyncError = (int)EnumCRVTenderPOSyncError.UPDATE;
                //    this.CRVSyncErrorNoOfTries = 0;
                //}
                ////End Nguyen Quoc Phuong 5-Dec-2012

                this.Save();

                c.Commit();
            }
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
        public static OPurchaseOrder CreatePOFromRFQLineItems(List<ORequestForQuotationItem> items, int purchaseOrderType)
        {
            using (Connection c = new Connection())
            {
                if (items.Count == 0)
                    return null;

                items.Sort("RequestForQuotation.CreatedDateTime ASC, ItemNumber ASC");

                ORequestForQuotation r = items[0].RequestForQuotation;
                OPurchaseOrder o = TablesLogic.tPurchaseOrder.Create();

                o.CaseID = r.CaseID;
                o.LocationID = r.LocationID;
                o.EquipmentID = r.EquipmentID;
                o.PurchaseTypeID = r.PurchaseTypeID;

                // 2011.02.02
                // Kim Foong
                // Added the folllowing to copy the validation policy
                // over to the PO.
                o.BudgetValidationPolicy = r.BudgetValidationPolicy;

                o.BudgetDistributionMode = r.BudgetDistributionMode;
                o.Description = r.Description;
                o.DateRequired = r.DateRequired;

                o.DateEnd = r.DateEnd;
                o.IsTermContract = r.IsTermContract;
                o.BillToAddress = r.BillToAddress;
                o.BillToAttention = r.BillToAttention;
                o.ShipToAddress = r.ShipToAddress;
                o.ShipToAttention = r.ShipToAttention;
                o.PurchaseAdministratorID = r.PurchaseAdministratorID;
                o.StoreID = r.StoreID;
                o.BudgetGroupID = r.BudgetGroupID;
                o.TransactionTypeGroupID = r.TransactionTypeGroupID;
                o.POType = purchaseOrderType;
                o.HasWarranty = r.hasWarranty;
                o.WarrantyPeriod = r.WarrantyPeriod;
                o.WarrantyUnit = r.WarrantyPeriodInterval;
                o.Warranty = r.Warranty;
                o.CampaignID = r.CampaignID;

                // 2011.07.10, Kien Trung
                // Copied Recoverable Type from rfq to PO.
                //
                o.IsRecoverable = r.IsRecoverable;                

                if (Workflow.CurrentUser != null)
                {
                    o.DeliverToContactPersonID = Workflow.CurrentUser.ObjectID;
                    o.BillToContactPersonID = Workflow.CurrentUser.ObjectID;
                }
                else
                {
                    o.DeliverToContactPersonID = r.RequestorID;
                    o.BillToContactPersonID = r.RequestorID;
                }

                if (o.Location != null)
                {
                    if (purchaseOrderType == PurchaseOrderType.PO)
                    {
                        o.DeliveryToID = o.Location.BuildingOwnerID;
                        o.BillToID = o.Location.BuildingTrustID;
                        o.ManagementCompanyID = o.Location.BuildingManagementID;
                    }
                    if (purchaseOrderType == PurchaseOrderType.LOA)
                    {
                        o.LOAOnBehalfOfID = o.Location.BuildingOwnerID;
                        o.TrustID = o.Location.BuildingTrustID;
                        o.ManagementCompanyID = o.Location.BuildingManagementID;
                        o.SignatoryID = o.Location.DefaultLOASignatoryID;
                    }
                }

                if (items[0].AwardedVendorID != null)
                {
                    o.VendorID = items[0].AwardedVendorID;
                    o.ContactAddress = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactAddress;
                    o.ContactAddressCity = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactAddressCity;
                    o.ContactAddressCountry = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactAddressCountry;
                    o.ContactAddressState = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactAddressState;
                    o.ContactCellPhone = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactCellPhone;
                    o.ContactEmail = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactEmail;
                    o.ContactFax = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactFax;
                    o.ContactPerson = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactPerson;
                    o.ContactPhone = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ContactPhone;
                    o.FreightTerms = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.FreightTerms;
                    o.PaymentTerms = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.PaymentTerms;
                    // FIX : 2011 05 19, Kien Trung
                    // move saving foreign exchange rate from rfq to po
                    // before add po line item from rfq.
                    o.ForeignToBaseExchangeRate = items[0].AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ForeignToBaseExchangeRate;
                }
                o.IsPaymentPaidByPercentage = r.IsPaymentPaidByPercentage;
                AddPOLineItemsFromRFQLineItems(o, items);
                CreatePaymentSchedule(o, r.RequestForQuotationPaymentSchedules);
                int count = o.PurchaseOrderItems.Count;

                if (count == 0)
                    return null;

                o.DateOfOrder = o.RFQApprovedDate;

                //20120209 ptb
                //copy billtoID and billtoContactPerson
                if (r.BillToID != null)
                    o.BillToID = r.BillToID;
                if (r.BillToContactPersonID != null)
                    o.BillToContactPersonID = r.BillToContactPersonID;
                if (r.DeliveryToID != null)
                    o.DeliveryToID = r.DeliveryToID;
                if (r.DeliverToContactPersonID != null)
                    o.DeliverToContactPersonID = r.DeliverToContactPersonID;
                if (r.IsDeliverToOther == null || r.IsDeliverToOther == 0)
                    o.IsDeliverToOther = 0;
                else
                {
                    o.IsDeliverToOther = 1;
                    o.DeliverToPerson = r.DeliverToPerson;
                    o.DeliverToAddress = r.DeliverToAddress;
                }

                o.Save();
                o.TriggerWorkflowEvent("SubmitForReceipt");

                //close wj if all items of this wj have already been created into POs/LOAs
                // 2011.06.24, Kien Trung
                // MODIFIED: change condition to auto close rfq when PO generated.
                // count distinct number of rfq items that sum of quantityordered = quantityrequired
                //
                TPurchaseOrderItem poItem = TablesLogic.tPurchaseOrderItem;
                TPurchaseOrderItem poItemOrdered = new TPurchaseOrderItem();

                //List<OPurchaseOrderItem> poList = poItem.LoadList
                DataTable dtPOItems = poItem.SelectDistinct
                    (poItem.RequestForQuotationItemID)
                    .Where
                    (poItem.PurchaseOrder.IsDeleted == 0 &
                    poItem.PurchaseOrder.CurrentActivity.ObjectName != "Cancelled" &
                    poItem.RequestForQuotationItem.RequestForQuotationID == r.ObjectID &
                    (poItem.RequestForQuotationItem.QuantityProvided -
                    (poItemOrdered.Select(poItemOrdered.QuantityOrdered.Sum())
                    .Where
                    (poItemOrdered.RequestForQuotationItemID == poItem.RequestForQuotationItemID &
                    poItemOrdered.PurchaseOrder.CurrentActivity.ObjectName != "Cancelled" &
                    poItemOrdered.PurchaseOrder.IsDeleted == 0)) == 0));

                if (dtPOItems.Rows.Count == r.RequestForQuotationItems.Count)
                {
                    r.TriggerWorkflowEvent("Close");
                    r.Save();
                }

                //Nguyen Quoc Phuong 4-Dec-2012
                //o.RequestForQuotation = r;
                if (o.IsSyncCRV)
                {
                    int? status = o.CreateCRVGProcurementContract();
                    if (status != (int)EnumCRVCreateGroupProcurementContractStatus.SUCCESSFUL) return null;
                }
                //End Nguyen Quoc Phuong 4-Dec-2012

                c.Commit();

                return o;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="o"></param>
        /// <param name="items"></param>
        public static void AddPOLineItemsFromRFQLineItems(
            OPurchaseOrder o, List<ORequestForQuotationItem> items)
        {
            using (Connection c = new Connection())
            {
                int i = o.PurchaseOrderItems.Count + 1;

                List<Guid> requestForQuotationIds = new List<Guid>();
                Hashtable requestForQuotations = new Hashtable();
                List<OPurchaseBudget> newPurchaseBudgets = new List<OPurchaseBudget>();

                // Get the quotation (based on the latest date)
                // so that we can copy the exchange rate over to the PO.
                //
                List<Guid> rfqVendorItemIds = new List<Guid>();
                foreach (ORequestForQuotationItem item in items)
                    if (item.AwardedRequestForQuotationVendorItemID != null)
                        rfqVendorItemIds.Add(item.AwardedRequestForQuotationVendorItemID.Value);

                ORequestForQuotationVendor rfqVendor = TablesLogic.tRequestForQuotationVendor.Load(
                    TablesLogic.tRequestForQuotationVendor.RequestForQuotationVendorItems.ObjectID.In(rfqVendorItemIds),
                    TablesLogic.tRequestForQuotationVendor.DateOfQuotation.Desc);

                // 2011.06.25, Kien Trung
                // FIX: Transfer partial transaction amount when
                // budget distribution mode is entire amount of Rfq.
                // move this out side to do transfer only one.
                //
                if (o.BudgetDistributionMode == BudgetDistribution.EntireAmount)
                {
                    ORequestForQuotation r = items[0].RequestForQuotation;
                    decimal? transactionAmount = 0M;
                    decimal? recoverableAmount = 0M;
                    foreach (ORequestForQuotationItem rItem in items)
                    {
                        if (o.IsRecoverable == (int)EnumRecoverable.Recoverable)
                            recoverableAmount += Round(rItem.RecoverableAmount);

                        if (rItem.OrderQuantity != 0)
                            transactionAmount += Round(rItem.OrderQuantity.Value * rItem.UnitPrice.Value);
                    }

                    // subtract recoverable amount if there is.
                    //
                    transactionAmount = Round(transactionAmount - recoverableAmount);
                    newPurchaseBudgets =
                        OPurchaseBudget.TransferPartialPurchaseBudgets(r.PurchaseBudgets, null, transactionAmount);
                }
                foreach (ORequestForQuotationItem item in items)
                {
                    // item.PurchaseOrderItem == null
                    if (item.AwardedVendorID != null && item.OrderQuantity != 0)
                    {
                        OPurchaseOrderItem n = TablesLogic.tPurchaseOrderItem.Create();

                        ORequestForQuotation rfq = null;
                        if (requestForQuotations[item.RequestForQuotationID.Value] == null)
                        {
                            rfq = TablesLogic.tRequestForQuotation.Load(item.RequestForQuotationID);
                            requestForQuotations[item.RequestForQuotationID.Value] = rfq;
                        }
                        else
                            rfq = requestForQuotations[item.RequestForQuotationID.Value] as ORequestForQuotation;

                        // Transfer budget transactions over to the PO.
                        // 2011.06.25, Kien Trung
                        // COMMENTED: transfer partial purchase budget instead.
                        //
                        //List<OPurchaseBudget> newPurchaseBudgets =
                        //    OPurchaseBudget.TransferPurchaseBudgets(rfq.PurchaseBudgets, item.ItemNumber);

                        // 2011.06.25, Kien Trung
                        // Transfer budget transactions over to the PO
                        // NEW: transfer transaction amount partially
                        // Allow PO to be generate from rfq items partially
                        // (multiple PO for each rfq item)
                        // 2011.07.10, Kien Trung
                        // FIX: Check if recoverable then subtract recoverable amount
                        //
                        if (o.BudgetDistributionMode == BudgetDistribution.LineItem)
                        {
                            decimal? transactionAmount = 0M;
                            decimal recoverableAmount = 0M;

                            if (o.IsRecoverable == (int)EnumRecoverable.Recoverable)
                                recoverableAmount = item.RecoverableAmount.Value;

                            transactionAmount = Round(item.OrderQuantity.Value * item.UnitPrice.Value);
                            transactionAmount = Round(transactionAmount - recoverableAmount);

                            newPurchaseBudgets =
                                OPurchaseBudget.TransferPartialPurchaseBudgets(rfq.PurchaseBudgets, item.ItemNumber, transactionAmount);
                        }

                        // 2011.06.25, Kien Trung
                        // FIX: check itemnumber is null
                        foreach (OPurchaseBudget purchaseBudget in newPurchaseBudgets)
                            if (purchaseBudget.ItemNumber == null)
                                purchaseBudget.ItemNumber = i;

                        o.PurchaseBudgets.AddRange(newPurchaseBudgets);

                        // Update the PO line item details.
                        //
                        n.ItemNumber = i++;
                        n.ItemType = item.ItemType;
                        n.ItemDescription = item.ItemDescription;
                        n.AdditionalDescription = item.AdditionalDescription;
                        n.CatalogueID = item.CatalogueID;
                        n.FixedRateID = item.FixedRateID;
                        n.UnitOfMeasureID = item.UnitOfMeasureID;
                        n.CurrencyID = item.CurrencyID;
                        n.UnitPrice = item.UnitPrice;
                        n.UnitPriceInSelectedCurrency = item.UnitPriceInSelectedCurrency;
                        n.ChargeAmount = item.ChargeAmount;
                        n.RecoverableAmountInSelectedCurrency = item.RecoverableAmountInSelectedCurrency;
                        n.RecoverableAmount = item.RecoverableAmount;

                        // 2011.06.25, Kien Trung
                        // NEW: generate PO with quantity ordered
                        // is the quantity user enter,
                        // instead of quantity provided from vendor quotation.
                        //
                        //n.QuantityOrdered = item.QuantityProvided;
                        n.QuantityOrdered = item.OrderQuantity;
                        n.RequestForQuotationItemID = item.ObjectID;
                        n.ReceiptMode = item.ReceiptMode;

                        o.ForeignToBaseExchangeRate = rfqVendor.ForeignToBaseExchangeRate;
                        o.CurrencyID = item.CurrencyID;
                        o.PurchaseOrderItems.Add(n);
                        item.Save();

                        if (!requestForQuotationIds.Contains(item.ObjectID.Value))
                            requestForQuotationIds.Add(item.RequestForQuotationID.Value);
                    }
                }
                o.Save();

                // Transfer all the budgets over to the PO.
                //
                List<OBudgetTransactionLog> newTransactions = new List<OBudgetTransactionLog>();
                List<OBudgetTransactionLog> modifiedTransactions = new List<OBudgetTransactionLog>();
                OPurchaseBudget.CreateBudgetTransactionLogs(o.PurchaseBudgets, BudgetTransactionType.PurchaseApproved, newTransactions, modifiedTransactions);
                foreach (OBudgetTransactionLog transaction in newTransactions)
                    transaction.Save();
                foreach (OBudgetTransactionLog transaction in modifiedTransactions)
                    transaction.Save();

                #region To remove

                //not auto close RFQ when po is created from RFQ
                // here we check and make sure that the request for quotation is set to "CLOSED"
                // when all items have been copied to a purchase order.
                //
                //foreach (ORequestForQuotation requestForQuotation in requestForQuotations.Values)
                //{
                //    if (requestForQuotation != null)
                //    {
                //        bool isClosed = true;
                //        foreach (ORequestForQuotationItem rfqItem in requestForQuotation.RequestForQuotationItems)
                //            if (rfqItem.PurchaseOrderItem == null)
                //            {
                //                isClosed = false;
                //                break;
                //            }
                //        if (isClosed && requestForQuotation.CurrentActivity.ObjectName != "Close")
                //        {
                //            requestForQuotation.TriggerWorkflowEvent("Close");
                //            requestForQuotation.Save();
                //        }
                //    }
                //}

                #endregion To remove
            }
        }

        /// <summary>
        /// Validates that the budget spending policy is adhered to, that is,
        /// budgets can be spent or not if they are not yet created for
        /// a finacial period.
        /// <para></para>
        /// Returns a list of budgets that failed because budget periods
        /// are not available.
        /// </summary>
        public string ValidateBudgetSpendingPolicy()
        {
            List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
            return OBudgetPeriod.CheckSpendingPolicy(
                OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null));
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="po"></param>
        /// <param name="RFQPaymentSchedules"></param>
        public static void CreatePaymentSchedule(OPurchaseOrder o, DataList<ORequestForQuotationPaymentSchedule> RFQPaymentSchedules)
        {
            using (Connection c = new Connection())
            {
                decimal? totalPOAmount = 0;
                foreach (OPurchaseOrderItem item in o.PurchaseOrderItems)
                {
                    totalPOAmount += Round(item.QuantityOrdered * item.UnitPriceInSelectedCurrency);
                }
                decimal? totalPreviousAmount = 0;
                int i = 0;
                int count = RFQPaymentSchedules.Count;
                foreach (ORequestForQuotationPaymentSchedule paymentSchedule in RFQPaymentSchedules)
                {
                    i++;
                    OPurchaseOrderPaymentSchedule ps = TablesLogic.tPurchaseOrderPaymentSchedule.Create();
                    ps.DateOfPayment = paymentSchedule.DateOfPayment;
                    ps.Description = paymentSchedule.Description;

                    if (o.IsPaymentPaidByPercentage == null)
                    {
                        if (i < count)
                            totalPreviousAmount += ps.AmountToPay = Math.Round(Convert.ToDecimal(totalPOAmount / count), 2, MidpointRounding.AwayFromZero);
                        else
                            ps.AmountToPay = totalPOAmount - totalPreviousAmount;
                        o.PurchaseOrderPaymentSchedules.Add(ps);
                    }
                    else if (o.IsPaymentPaidByPercentage == 1 && paymentSchedule.PercentageToPay != null)
                    {
                        ps.PercentageToPay = paymentSchedule.PercentageToPay;
                        if (i < count)
                            totalPreviousAmount += ps.AmountToPay = Math.Round(Convert.ToDecimal(totalPOAmount * paymentSchedule.PercentageToPay / 100), 2, MidpointRounding.AwayFromZero);
                        else
                            totalPreviousAmount += totalPOAmount - totalPreviousAmount;
                        o.PurchaseOrderPaymentSchedules.Add(ps);
                    }
                    else if (o.IsPaymentPaidByPercentage == 0)
                    {
                        if (totalPOAmount >= paymentSchedule.AmountToPay + totalPreviousAmount)
                            totalPreviousAmount += ps.AmountToPay = paymentSchedule.AmountToPay;
                        else
                        {
                            ps.AmountToPay = totalPOAmount - totalPreviousAmount;
                            o.PurchaseOrderPaymentSchedules.Add(ps);
                            break;
                        }
                    }
                }
                o.Save();
            }
        }

        /// <summary>
        ///
        /// </summary>
        public Decimal GetTotalInvoiceAmount
        {
            get
            {
                Decimal amount = (Decimal)TablesLogic.tPurchaseInvoice.Select
                        (TablesLogic.tPurchaseInvoice.TotalAmount.Sum())
                    .Where
                        (TablesLogic.tPurchaseInvoice.PurchaseOrderID == this.ObjectID &
                        TablesLogic.tPurchaseInvoice.InvoiceType == PurchaseInvoiceType.StandardInvoice &
                        TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName == "Close" &
                        TablesLogic.tPurchaseInvoice.IsDeleted == 0);
                return amount;
            }
        }

        /// <summary>
        /// Called when OPurchaseOrder goes into CancelledAndRevised State
        /// </summary>
        public void CreateRequestForQuotationForUnreceivedItems()
        {
            using (Connection c = new Connection())
            {
                // Create a new RequestForQuotation object
                // assign all the values from PurchaseOrder
                ORequestForQuotation rfq = TablesLogic.tRequestForQuotation.Create();
                OPurchaseOrderItem p = TablesLogic.tPurchaseOrderItem.Load(
                                TablesLogic.tPurchaseOrderItem.PurchaseOrderID == this.ObjectID);
                ORequestForQuotationItem rfqi = null;
                if (p != null)
                {
                    rfqi = TablesLogic.tRequestForQuotationItem.Load(
                        TablesLogic.tRequestForQuotationItem.ObjectID == p.RequestForQuotationItemID);
                }

                rfq.LocationID = this.LocationID;
                rfq.Description = this.Description;
                rfq.BudgetGroupID = this.BudgetGroupID;
                rfq.TransactionTypeGroupID = this.TransactionTypeGroupID;
                rfq.IsTermContract = this.IsTermContract;
                rfq.WarrantyPeriod = this.WarrantyPeriod;
                rfq.Warranty = this.Warranty;
                rfq.DateRequired = this.DateRequired;
                rfq.DateEnd = this.DateEnd;
                rfq.PurchaseTypeID = this.PurchaseTypeID;
                rfq.IsGroupWJ = this.IsGroupPO;
                rfq.RequestorName = this.CreatedUser;
                rfq.CancelledPurchaseOrderID = this.ObjectID;

                if (rfqi != null)
                {
                    // Assign Background Type, Transaction Type, Background Scope
                    rfq.Scope = p.RequestForQuotationItem.RequestForQuotation.Scope;
                    rfq.BackgroundTypeID = p.RequestForQuotationItem.RequestForQuotation.BackgroundTypeID;
                    rfq.TransactionTypeGroupID = p.RequestForQuotationItem.RequestForQuotation.TransactionTypeGroupID;
                }
                rfq.Save();

                // Create RequestForQuotationItem for each PurchaseOrderItem in this PO
                foreach (OPurchaseOrderItem poi in this.PurchaseOrderItems)
                {
                    ORequestForQuotationItem rfqItem = TablesLogic.tRequestForQuotationItem.Create();
                    if (poi.QuantityDelivered != poi.QuantityOrdered)
                    {
                        rfqItem.QuantityRequired = (poi.QuantityOrdered - poi.QuantityDelivered);
                        rfqItem.RequestForQuotationID = rfq.ObjectID;
                        rfqItem.CatalogueID = poi.CatalogueID;
                        rfqItem.FixedRateID = poi.FixedRateID;
                        rfqItem.ItemDescription = poi.ItemDescription;
                        rfqItem.UnitOfMeasureID = poi.UnitOfMeasureID;
                        rfqItem.ReceiptMode = poi.ReceiptMode;
                        rfqItem.PurchaseRequestItemID = poi.PurchaseRequestItemID;
                        rfqItem.CurrencyID = poi.CurrencyID;
                        rfqItem.UnitPrice = poi.UnitPrice;
                        rfqItem.UnitPriceInSelectedCurrency = poi.UnitPriceInSelectedCurrency;
                        rfqItem.ItemNumber = poi.ItemNumber;
                        rfqItem.ItemType = poi.ItemType;
                        rfqItem.RequestForQuotationID = rfq.ObjectID;
                        rfqItem.Save();
                        rfq.RequestForQuotationItems.Add(rfqItem);
                    }
                }

                rfq.SaveAndTransit("SaveAsDraft");

                // Create RequestForQuotationVendor object

                ORequestForQuotationVendor rfqVendor = TablesLogic.tRequestForQuotationVendor.Create();
                rfqVendor.RequestForQuotationID = rfq.ObjectID;
                rfqVendor.IsSubmitted = 1;
                rfqVendor.ContactAddress = this.ContactAddress;
                rfqVendor.ContactAddressCity = this.ContactAddressCity;
                rfqVendor.ContactAddressState = this.ContactAddressState;
                rfqVendor.ContactCellPhone = this.ContactCellPhone;
                rfqVendor.ContactEmail = this.ContactEmail;
                rfqVendor.ContactFax = this.ContactFax;
                rfqVendor.ContactPerson = this.ContactPerson;
                rfqVendor.ContactPhone = this.ContactPhone;
                rfqVendor.CurrencyID = this.CurrencyID;
                rfqVendor.ForeignToBaseExchangeRate = this.ForeignToBaseExchangeRate;
                rfqVendor.VendorID = this.VendorID;
                // Create ORequestForQuotationVendorItem for each new RequestforQuotationItem created above
                foreach (ORequestForQuotationItem rfqItem in rfq.RequestForQuotationItems)
                {
                    ORequestForQuotationVendorItem rfqVendorItem = TablesLogic.tRequestForQuotationVendorItem.Create();
                    rfqVendorItem.RequestForQuotationItemID = rfqItem.ObjectID;
                    rfqVendorItem.ItemDescription = rfqItem.ItemDescription;
                    rfqVendorItem.ItemNumber = rfqItem.ItemNumber;
                    rfqVendorItem.ItemType = rfqItem.ItemType;
                    rfqVendorItem.FixedRateID = rfqItem.FixedRateID;
                    rfqVendorItem.CatalogueID = rfqItem.CatalogueID;
                    rfqVendorItem.RequestForQuotationVendorID = rfqVendor.ObjectID;
                    rfqVendorItem.UnitPrice = rfqItem.UnitPrice;
                    rfqVendorItem.UnitOfMeasureID = rfqItem.UnitOfMeasureID;
                    rfqVendorItem.UnitPriceInSelectedCurrency = rfqItem.UnitPriceInSelectedCurrency;
                    rfqVendorItem.Save();
                    rfqVendor.RequestForQuotationVendorItems.Add(rfqVendorItem);
                }
                rfqVendor.Save();
                rfq.RequestForQuotationVendors.Add(rfqVendor);
                rfq.Save();
                this.RequestForQuotationID = rfq.ObjectID;
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Validates if the total contract price within variation.
        /// </summary>
        /// <param name="i"></param>
        /// <returns></returns>
        public bool ValidateContractPriceWithinVariation(OPurchaseOrderItem i)
        {
            if (this.ContractID == null)
                return true;

            if (i.ItemType == PurchaseItemType.Material)
            {
                OContractPriceMaterial p = this.Contract.GetContractPriceMaterial(i.CatalogueID.Value);
                decimal unitPrice = this.Contract.GetMaterialUnitPrice(i.CatalogueID.Value);

                if (p.AllowVariation == null || p.AllowVariation == 0)
                    return i.UnitPrice == unitPrice;
                else
                    return
                        unitPrice * ((100 - p.VariationPercentage) / 100) <= i.UnitPrice &&
                        i.UnitPrice <= unitPrice * ((100 + p.VariationPercentage) / 100);
            }
            else if (i.ItemType == PurchaseItemType.Service)
            {
                OContractPriceService p = this.Contract.GetContractPriceService(i.FixedRateID.Value);
                decimal unitPrice = this.Contract.GetServiceUnitPrice(i.FixedRateID.Value);

                if (p.AllowVariation == null || p.AllowVariation == 0)
                    return i.UnitPrice == unitPrice;
                else
                    return
                        unitPrice * ((100 - p.VariationPercentage) / 100) <= i.UnitPrice &&
                        i.UnitPrice <= unitPrice * ((100 + p.VariationPercentage) / 100);
            }
            return true;
        }

        public static DataSet GetPurchaseOrderDataSetForCrystalReports(OPurchaseOrder po)
        {
            String RFQBackground = Regex.Replace(po.RFQBackground, @"<[^>]*>", String.Empty);

            //OPurchaseOrder po = TablesLogic.tPurchaseOrder.Load(POID);
            //DataTable PODetailsReport = dtPODetails();

            DataSet ds = new DataSet();
            DataSet dsTemp = new DataSet();
            DataTable PODetailsReport = PODetails(po.ObjectID);
            PODetailsReport.Columns.Add("GST", typeof(Decimal));
            PODetailsReport.Rows[0]["GST"] = po.totalGST;
            PODetailsReport.Columns.Add("PoDate", typeof(DateTime));
            PODetailsReport.Rows[0]["PoDate"] = po.RFQApprovedDate;
            PODetailsReport.Columns.Add("RFQBackground", typeof(string));
            PODetailsReport.Rows[0]["RFQBackground"] = RFQBackground;

            DataTable POItemsReport = POItems(po.ObjectID);
            DataTable POMgmtCompany = POMgmtCompanyReport(po.ManagementCompanyID);

            #region obselete code

            //PODetailsReport.ImportRow(PODetails(po.ObjectID).Rows[0]);

            //PODetailsReport.Columns.Add("QuotationNo");
            //PODetailsReport.Rows[0]["QuotationNo"] = po.QuotationNumber;
            //PODetailsReport.Rows[0]["DeliverToContactName"] = po.DeliverToContactPerson != null ? po.DeliverToContactPerson.ObjectName : "";
            //PODetailsReport.Rows[0]["BillToContactName"] = po.BillToContactPerson != null ? po.BillToContactPerson.ObjectName : "";

            //ds.Tables["PODetailsReport"].ImportRow(PODetails(po.ObjectID).Rows[0]);

            //DataTable POItemsReport = new DataTable();

            //POItemsReport.TableName = "POItemsReport";
            //POItemsReport.Columns.Add("ItemDescription");
            //POItemsReport.Columns.Add("ItemQuantity", typeof(Decimal));
            //POItemsReport.Columns.Add("ItemUnitPrice", typeof(Decimal));
            //POItemsReport.Columns.Add("AdditionalDescription", typeof(string));
            //POItemsReport.Columns.Add("POID", typeof(Guid));
            //POItemsReport.Columns.Add("unitprice", typeof(Decimal));
            //POItemsReport.Columns.Add("TaxAmount",typeof(Decimal));

            //foreach (DataRow row in POItems(po.ObjectID).Rows)
            //{
            //    DataRow r = POItemsReport.NewRow();
            //    r["ItemDescription"] = row["ItemDescription"];
            //    r["ItemQuantity"] = row["ItemQuantity"];
            //    r["ItemUnitPrice"] = row["ItemUnitPrice"];
            //    r["AdditionalDescription"] = row["AdditionalDescription"];
            //    r["POID"] = row["POID"];
            //    r["TaxAmount"] = row["TaxAmount"];
            //    r["unitprice"] = Convert.ToDecimal(row["unitprice"]).ToString("#,##0.00##");
            //    //ds.Tables["POItemsReport"].ImportRow(row);
            //    POItemsReport.Rows.Add(r);
            //}
            //ds.Tables.Add(POItemsReport);

            //DataTable POMgmtCompany = new DataTable();

            //POMgmtCompany.TableName = "POMgmtCompany";
            //POMgmtCompany.Columns.Add("CompanyID", typeof(Guid));
            //POMgmtCompany.Columns.Add("Logo", typeof(Byte[]));
            //ds.Tables.Add(POMgmtCompany);
            //ds.Tables["POMgmtCompany"].ImportRow(POMgmtCompanyReport(po.ManagementCompanyID).Rows[0]);

            #endregion obselete code

            ds.Tables.Add(PurchaseBudgetTable(po));

            // Kien Trung
            // remove the dataset from existing datatable
            // to add in to our dataset instead importing row.
            dsTemp = PODetailsReport.DataSet;
            dsTemp.Tables.Remove(PODetailsReport);

            dsTemp = POItemsReport.DataSet;
            dsTemp.Tables.Remove(POItemsReport);

            dsTemp = POMgmtCompany.DataSet;
            dsTemp.Tables.Remove(POMgmtCompany);

            // add datatable to our own dataset for printing purpose.
            PODetailsReport.TableName = "PODetailsReport";
            ds.Tables.Add(PODetailsReport);

            POItemsReport.TableName = "POItemsReport";
            ds.Tables.Add(POItemsReport);

            POMgmtCompany.TableName = "POMgmtCompany";
            ds.Tables.Add(POMgmtCompany);

            ds.AcceptChanges();
            return ds;
        }

        #region obselete

        //protected static DataTable dtPODetails()
        //{
        //    DataTable dt = new DataTable();
        //    dt.Columns.Add("CompanyName");
        //    dt.Columns.Add("CompanyAddress");
        //    dt.Columns.Add("CompanyCountry");
        //    dt.Columns.Add("CompanyPostalCode");
        //    dt.Columns.Add("CompanyTelNo");
        //    dt.Columns.Add("CompanyFaxNo");
        //    dt.Columns.Add("CompanyRegNo");
        //    dt.Columns.Add("CompanyID", typeof(Guid));
        //    dt.Columns.Add("PoDeliverName");
        //    dt.Columns.Add("PoDeliverAddress");
        //    dt.Columns.Add("PoDeliverCountry");
        //    dt.Columns.Add("PoDeliverPostalCode");
        //    dt.Columns.Add("PoDeliverTelNo");
        //    dt.Columns.Add("PoDeliverFaxNo");
        //    dt.Columns.Add("PoDeliverContactName");
        //    dt.Columns.Add("PoVendorName");
        //    dt.Columns.Add("PoVendorAddress");
        //    dt.Columns.Add("PoVendorCountry");
        //    dt.Columns.Add("PoVendorPostalCode");
        //    dt.Columns.Add("PoVendorTelNo");
        //    dt.Columns.Add("PoVendorFaxNo");
        //    dt.Columns.Add("PoVendorContactName");
        //    dt.Columns.Add("PoBillName");
        //    dt.Columns.Add("PoBillAddress");
        //    dt.Columns.Add("PoBillCountry");
        //    dt.Columns.Add("PoBillPostalCode");
        //    dt.Columns.Add("PoNumber");
        //    dt.Columns.Add("PoPaymentTerms");
        //    dt.Columns.Add("PoId", typeof(Guid));
        //    dt.Columns.Add("PoSubject");
        //    dt.Columns.Add("WJNo");
        //    dt.Columns.Add("WJCreatedDateTime", typeof(DateTime));
        //    dt.Columns.Add("DeliverToContactName");
        //    dt.Columns.Add("BillToContactName");

        //    return dt;
        //}

        #endregion obselete

        protected static DataTable PODetails(Guid? POID)
        {
            DataTable dt = new DataTable();

            #region obselete

            //            string sql = "";
            //            if (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            //                sql = @"select maCompany.ObjectName as 'CompanyName',maCompany.Address as 'CompanyAddress',maCompany.Country as 'CompanyCountry',maCompany.PostalCode as 'CompanyPostalCode',maCompany.PhoneNo as 'CompanyTelNo',maCompany.FaxNo as 'CompanyFaxNo',maCompany.RegNo as 'CompanyRegNo',
            //                maCompany.ObjectID as 'CompanyID',
            //                delivery.ObjectName as 'PoDeliverName',delivery.Address as 'PoDeliverAddress',delivery.Country as 'PoDeliverCountry',delivery.PostalCode as 'PoDeliverPostalCode',ub.Phone as 'PoDeliverTelNo',ub.Fax as 'PoDeliverFaxNo',
            //                rfq.CreatedUser as 'PoDeliverContactName', po.ContactAddress as 'PoVendorAddress',po.ContactAddressCountry as 'PoVendorCountry',
            //                Vendor.ObjectName as 'PoVendorName', po.ContactPerson as 'PoVendorContactName', po.ContactPhone as 'PoVendorTelNo', po.ContactFax as 'PoVendorFaxNo',
            //                rfq.ObjectNumber as 'WJNo',billTo.ObjectName as 'PoBillName', billTo.Address as 'PoBillAddress', billTo.Country as 'PoBillCountry', billTo.PostalCode as 'PoBillPostalCode',
            //                po.ObjectNumber as 'PONumber',rfq.CreatedDateTime as 'WJCreatedDateTime', po.PaymentTerms as 'PoPaymentTerms',po.ObjectID as 'POID',po.Description as 'POSubject'
            //                from PurchaseOrder po
            //                left join CapitalandCompany maCompany on maCompany.ObjectID = po.ManagementCompanyID
            //                left join CapitalandCompany delivery on delivery.ObjectID = po.DeliveryToID
            //                left join PurchaseOrderItem poItem on poItem.PurchaseOrderID = po.ObjectID
            //                left join RequestForQuotationItem rfqItem on rfqItem.ObjectID = poItem.RequestForQuotationItemID
            //                left join RequestForQuotation rfq on rfq.ObjectID = rfqItem.RequestForQuotationID
            //                left join Vendor on Vendor.ObjectID = po.VendorID
            //                left join CapitalandCompany billTo on billTo.ObjectID = po.BillToID
            //                left join [User] u on po.DeliverToContactPersonID = u.ObjectID
            //                left join [UserBase] ub on u.UserBaseID = ub.ObjectID
            //                where po.ObjectID ='" + POID.ToString() + "'";
            //            else
            //                 sql = @"select maCompany.ObjectName as 'CompanyName',maCompany.Address as 'CompanyAddress',maCompany.Country as 'CompanyCountry',maCompany.PostalCode as 'CompanyPostalCode',maCompany.PhoneNo as 'CompanyTelNo',maCompany.FaxNo as 'CompanyFaxNo',maCompany.RegNo as 'CompanyRegNo',
            //                maCompany.ObjectID as 'CompanyID',
            //                delivery.ObjectName as 'PoDeliverName',delivery.Address as 'PoDeliverAddress',delivery.Country as 'PoDeliverCountry',delivery.PostalCode as 'PoDeliverPostalCode',delivery.PhoneNo as 'PoDeliverTelNo',delivery.FaxNo as 'PoDeliverFaxNo',
            //                rfq.CreatedUser as 'PoDeliverContactName', po.ContactAddress as 'PoVendorAddress',po.ContactAddressCountry as 'PoVendorCountry',
            //                Vendor.ObjectName as 'PoVendorName', Vendor.OperatingAddressPostalCode as 'PoVendorPostalCode', po.ContactPerson as 'PoVendorContactName', po.ContactPhone as 'PoVendorTelNo', po.ContactFax as 'PoVendorFaxNo',
            //                rfq.ObjectNumber as 'WJNo',billTo.ObjectName as 'PoBillName', billTo.Address as 'PoBillAddress', billTo.Country as 'PoBillCountry', billTo.PostalCode as 'PoBillPostalCode',
            //                po.ObjectNumber as 'PONumber',rfq.CreatedDateTime as 'WJCreatedDateTime', po.PaymentTerms as 'PoPaymentTerms',po.ObjectID as 'POID',po.Description as 'POSubject'
            //                from PurchaseOrder po
            //                left join CapitalandCompany maCompany on maCompany.ObjectID = po.ManagementCompanyID
            //                left join CapitalandCompany delivery on delivery.ObjectID = po.DeliveryToID
            //                left join PurchaseOrderItem poItem on poItem.PurchaseOrderID = po.ObjectID
            //                left join RequestForQuotationItem rfqItem on rfqItem.ObjectID = poItem.RequestForQuotationItemID
            //                left join RequestForQuotation rfq on rfq.ObjectID = rfqItem.RequestForQuotationID
            //                left join Vendor on Vendor.ObjectID = po.VendorID
            //                left join CapitalandCompany billTo on billTo.ObjectID = po.BillToID
            //                where po.ObjectID ='" + POID.ToString() + "'";

            //DataSet ds = Connection.ExecuteQuery("#database", sql);
            //return ds.Tables[0];

            #endregion obselete

            // Kien Trung
            // converted the sql select query to data query
            // Look tidier and easier to manage the query
            //
            dt = TablesLogic.tPurchaseOrder.SelectTop
                (1,
                Workflow.CurrentUser.ObjectName.As("PoPrintedUser"),
                TablesLogic.tPurchaseOrder.ManagementCompany.ObjectName.As("CompanyName"),
                TablesLogic.tPurchaseOrder.ManagementCompany.Description.As("CompanyDescription"),
                TablesLogic.tPurchaseOrder.ManagementCompany.Address.As("CompanyAddress"),
                TablesLogic.tPurchaseOrder.ManagementCompany.Country.As("CompanyCountry"),
                TablesLogic.tPurchaseOrder.ManagementCompany.PostalCode.As("CompanyPostalCode"),
                TablesLogic.tPurchaseOrder.ManagementCompany.PhoneNo.As("CompanyTelNo"),
                TablesLogic.tPurchaseOrder.ManagementCompany.FaxNo.As("CompanyFaxNo"),
                TablesLogic.tPurchaseOrder.ManagementCompany.RegNo.As("CompanyRegNo"),
                TablesLogic.tPurchaseOrder.ManagementCompanyID.As("CompanyID"),
                TablesLogic.tPurchaseOrder.DeliveryTo.ObjectName.As("PoDeliverName"),
                TablesLogic.tPurchaseOrder.DeliveryTo.Description.As("PoDeliverDescription"),
                TablesLogic.tPurchaseOrder.DeliveryTo.Address.As("PoDeliverAddress"),
                TablesLogic.tPurchaseOrder.DeliveryTo.Country.As("PoDeliverCountry"),
                TablesLogic.tPurchaseOrder.DeliveryTo.PostalCode.As("PoDeliverPostalCode"),
                (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM" ?
                TablesLogic.tPurchaseOrder.DeliverToContactPerson.UserBase.Phone : TablesLogic.tPurchaseOrder.DeliveryTo.PhoneNo).As("PoDeliverTelNo"),
                (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM" ?
                TablesLogic.tPurchaseOrder.DeliverToContactPerson.UserBase.Fax : TablesLogic.tPurchaseOrder.DeliveryTo.FaxNo).As("PoDeliverFaxNo"),
                TablesLogic.tPurchaseOrder.DeliveryDate.As("PoDeliverDate"),
                //TablesLogic.tPurchaseOrder.PurchaseOrderItems.RequestForQuotationItem.RequestForQuotation.CreatedUser.As("PoDeliverContactName"),
                TablesLogic.tPurchaseOrder.DeliverToContactPerson.ObjectName.As("PoDeliverContactName"),
                TablesLogic.tPurchaseOrder.ContactAddress.As("PoVendorAddress"),
                TablesLogic.tPurchaseOrder.ContactAddressCountry.As("PoVendorCountry"),
                TablesLogic.tPurchaseOrder.Vendor.ObjectName.As("PoVendorName"),
                TablesLogic.tPurchaseOrder.Vendor.OperatingAddressPostalCode.As("PoVendorPostalCode"),
                TablesLogic.tPurchaseOrder.Vendor.VendorSAPCode.As("PoVendorSAPCode"),
                TablesLogic.tPurchaseOrder.ContactPerson.As("PoVendorContactName"),
                TablesLogic.tPurchaseOrder.ContactPhone.As("PoVendorTelNo"),
                TablesLogic.tPurchaseOrder.ContactFax.As("PoVendorFaxNo"),
                TablesLogic.tPurchaseOrder.PurchaseOrderItems.RequestForQuotationItem.RequestForQuotation.ObjectNumber.As("WJNo"),
                TablesLogic.tPurchaseOrder.BillTo.ObjectName.As("PoBillName"),
                TablesLogic.tPurchaseOrder.BillTo.Description.As("PoBillDescription"),
                TablesLogic.tPurchaseOrder.BillTo.Address.As("PoBillAddress"),
                TablesLogic.tPurchaseOrder.BillTo.Country.As("PoBillCountry"),
                TablesLogic.tPurchaseOrder.BillTo.PostalCode.As("PoBillPostalCode"),
                TablesLogic.tPurchaseOrder.PurchaseOrderItems.RequestForQuotationItem.AwardedRequestForQuotationVendorItem.RequestForQuotationVendor.ObjectNumber.As("QuotationNo"),
                TablesLogic.tPurchaseOrder.ObjectNumber.As("PoNumber"),
                TablesLogic.tPurchaseOrder.Currency.CurrencySymbol.As("PoCurrency"),
                TablesLogic.tPurchaseOrder.PurchaseOrderItems.RequestForQuotationItem.RequestForQuotation.CreatedDateTime.As("WJCreatedDateTime"),
                TablesLogic.tPurchaseOrder.PaymentTerms.As("PoPaymentTerms"),
                TablesLogic.tPurchaseOrder.ObjectID.As("POID"),
                TablesLogic.tPurchaseOrder.Description.As("PoSubject"),
                TablesLogic.tPurchaseOrder.DeliverToContactPerson.ObjectName.As("DeliverToContactName"),
                TablesLogic.tPurchaseOrder.BillToContactPerson.ObjectName.As("BillToContactName"),
                TablesLogic.tPurchaseOrder.DeliverToAddress,
                TablesLogic.tPurchaseOrder.DeliverToPerson,
                TablesLogic.tPurchaseOrder.IsDeliverToOther)
                .Where
                (TablesLogic.tPurchaseOrder.ObjectID == POID.Value);

            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="POID"></param>
        /// <returns></returns>
        protected static DataTable POItems(Guid? POID)
        {
            DataTable dt = TablesLogic.tPurchaseOrderItem.Select
                (TablesLogic.tPurchaseOrderItem.PurchaseOrderID.As("POID"),
                (Anacle.DataFramework.Case
                .When(TablesLogic.tPurchaseOrderItem.ItemType == PurchaseItemType.Others,
                TablesLogic.tPurchaseOrderItem.ItemDescription)
                .Else(TablesLogic.tPurchaseOrderItem.AdditionalDescription).End).As("ItemDescription"),
                TablesLogic.tPurchaseOrderItem.QuantityOrdered.As("ItemQuantity"),
                TablesLogic.tPurchaseOrderItem.UnitPriceInSelectedCurrency.As("ItemUnitPrice"),
                TablesLogic.tPurchaseOrderItem.UnitOfMeasure.ObjectName.As("ItemUnitMeasure"),
                ("").As("AdditionalDescription"),
                TablesLogic.tPurchaseOrderItem.UnitPriceInSelectedCurrency.As("ItemUnitPriceInSelectedCurrency"),
                TablesLogic.tPurchaseOrderItem.TaxAmount)
                .Where
                (TablesLogic.tPurchaseOrderItem.PurchaseOrderID == POID &
                TablesLogic.tPurchaseOrderItem.IsDeleted == 0)
                .OrderBy
                (TablesLogic.tPurchaseOrderItem.ItemNumber.Asc);
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="ManagementCompanyID"></param>
        /// <returns></returns>
        protected static DataTable POMgmtCompanyReport(Guid? ManagementCompanyID)
        {
            DataTable dt = TablesLogic.tCapitalandCompany.Select
                (TablesLogic.tCapitalandCompany.LogoFile.As("Logo"),
                TablesLogic.tCapitalandCompany.ObjectID.As("CompanyID"))
                .Where
                (TablesLogic.tCapitalandCompany.ObjectID == ManagementCompanyID);
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        protected static DataTable PurchaseBudetTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("BudgetCategory");
            dt.Columns.Add("POID");
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="po"></param>
        /// <returns></returns>
        protected static DataTable PurchaseBudgetTable(OPurchaseOrder po)
        {
            DataTable dt = new DataTable();
            dt.TableName = "PurchaseBudget";
            dt.Columns.Add("BudgetCategory");
            dt.Columns.Add("POID");
            ArrayList account = new ArrayList();
            foreach (OPurchaseBudget pb in po.PurchaseBudgets)
            {
                if (!account.Contains(pb.AccountID))
                {
                    account.Add(pb.AccountID);
                    DataRow row = dt.NewRow();
                    row["BudgetCategory"] = pb.Account.Path;
                    row["POID"] = pb.PurchaseOrderID;
                    dt.Rows.Add(row);
                }
            }
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        public List<PurchaseBudgetAccount> PurchaseBudgetAccounts
        {
            get
            {
                List<PurchaseBudgetAccount> accountList = new List<PurchaseBudgetAccount>();
                ArrayList account = new ArrayList();
                foreach (OPurchaseBudget pb in this.PurchaseBudgets)
                {
                    if (!account.Contains(pb.AccountID))
                    {
                        account.Add(pb.AccountID);
                        PurchaseBudgetAccount acc = new PurchaseBudgetAccount();
                        acc.accountPath = pb.Account.Path;
                        accountList.Add(acc);
                    }
                }
                return accountList;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="user"></param>
        /// <param name="objectID"></param>
        /// <param name="Object"></param>
        /// <param name="isEditable"></param>
        /// <returns></returns>
        public static bool IsObjectEditOrView(OUser user, Guid objectID, String Object, bool isEditable)
        {
            bool status = false;
            if (isEditable)
            {
                if (user.AllowEditAll(Object) || OActivity.CheckAssignment(user, objectID))
                    status = true;
            }
            else
            {
                if (user.AllowViewAll(Object) || OActivity.CheckAssignment(user, objectID))
                    status = true;
            }
            return status;
        }

        /// <summary>
        ///
        /// </summary>
        public class PurchaseBudgetAccount
        {
            public string accountPath;
        }

        /// <summary>
        ///
        /// </summary>
        public void UpdateTransactionAmount()
        {
            foreach (OPurchaseBudget pb in this.PurchaseBudgets)
            {
                int numberOfMonths = 0;
                DateTime currentDate = pb.StartDate.Value;
                while (currentDate <= pb.EndDate.Value)
                {
                    numberOfMonths++;
                    currentDate = pb.StartDate.Value.AddMonths(numberOfMonths);
                }
                if (numberOfMonths == 0)
                    numberOfMonths = 1;

                decimal amountPerMonth = Math.Round(pb.Amount.Value / numberOfMonths, 2, MidpointRounding.AwayFromZero);

                List<OBudgetTransactionLog> budgetTransactionLogs =
                    TablesLogic.tBudgetTransactionLog.LoadList
                    (TablesLogic.tBudgetTransactionLog.PurchaseBudgetID == pb.ObjectID);
                int i = 0;

                foreach (OBudgetTransactionLog btl in budgetTransactionLogs)
                {
                    if (i == numberOfMonths - 1)
                        amountPerMonth = pb.Amount.Value - amountPerMonth * (numberOfMonths - 1);
                    if (btl.ReturnAmount == null)
                        btl.ReturnAmount = btl.TransactionAmount;
                    btl.TransactionAmount = amountPerMonth;
                    btl.Save();
                    i++;
                }
            }
        }
    }

    public class PurchaseOrderType
    {
        public const int PO = 1;
        public const int LOA = 0;
    }
}