//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
#define OVERRIDE_RFQ_TASKLOCATIONS

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TRequestForQuotation : LogicLayerSchema<ORequestForQuotation>
    {
        public SchemaText Background;

        public SchemaText Scope;

        public SchemaText Evaluation;

        [Size(255)]
        public SchemaString Warranty;

        public SchemaString Campaign;

        public SchemaInt hasWarranty;

        [Default(0)]
        public SchemaInt IsGroupWJ;

        public SchemaInt WarrantyPeriod;

        public SchemaInt WarrantyPeriodInterval;

        public SchemaGuid CancelledPurchaseOrderID;

        public SchemaGuid BudgetGroupID;

        public SchemaGuid RequestorID;

        public SchemaGuid TransactionTypeGroupID;

        public SchemaGuid BackgroundTypeID;

        public SchemaGuid EmployerCompanyID;

        public SchemaGuid GroupRequestForQuotationID;

        public TRequestForQuotation GroupRequestForQuotation { get { return OneToOne<TRequestForQuotation>("GroupRequestForQuotationID"); } }

        public TRequestForQuotation ChildRequestForQuotation { get { return OneToMany<TRequestForQuotation>("GroupRequestForQuotationID"); } }

        public TPurchaseOrder CancelledPurchaseOrder { get { return OneToOne<TPurchaseOrder>("CancelledPurchaseOrderID"); } }

        [Size(255)]
        public SchemaString RFQTitle;
        public SchemaInt AutoCalculateReallocationTo;
        [Size(50)]
        public SchemaString RequestorName;
        public SchemaGuid CampaignID;

        [Default(0)]
        public SchemaInt IsPaymentPaidByPercentage;

        [Default(0)]
        public SchemaInt IsGroupApproval;
        public SchemaInt IsDelegatedToHOD;

        public TLocation GroupWJLocations { get { return ManyToMany<TLocation>("RequestForQuotationLocation", "RequestForQuotationID", "LocationID"); } }

        public TBudgetGroup BudgetGroup { get { return OneToOne<TBudgetGroup>("BudgetGroupID"); } }

        public TUser Requestor { get { return OneToOne<TUser>("RequestorID"); } }

        public TCode TransactionTypeGroup { get { return OneToOne<TCode>("TransactionTypeGroupID"); } }

        public TCode BackgroundType { get { return OneToOne<TCode>("BackgroundTypeID"); } }

        public TRFQBudgetReallocationToPeriod RFQBudgetReallocationToPeriods { get { return OneToMany<TRFQBudgetReallocationToPeriod>("RequestForQuotationID"); } }

        public TRFQBudgetReallocationFromPeriod RFQBudgetReallocationFromPeriods { get { return OneToMany<TRFQBudgetReallocationFromPeriod>("RequestForQuotationID"); } }

        public TCapitalandCompany EmployerCompany { get { return OneToOne<TCapitalandCompany>("EmployerCompanyID"); } }

        public TRequestForQuotationPaymentSchedule RequestForQuotationPaymentSchedules { get { return OneToMany<TRequestForQuotationPaymentSchedule>("RequestForQuotationID"); } }
    }

    /// <summary>
    /// Represents a request for quotation that can be used to gather
    /// quotations from vendors.
    /// </summary>

    public abstract partial class ORequestForQuotation : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled, ICloneable
    {
        /// <summary>
        /// [Column] Gets or Sets the Background
        /// </summary>
        public abstract String Background { get; set; }

        /// <summary>
        /// [Column] Gets or Sets the Scope
        /// </summary>
        public abstract String Scope { get; set; }

        /// <summary>
        /// [Column] Gets or Sets the Evaluation
        /// </summary>
        public abstract String Evaluation { get; set; }

        /// <summary>
        /// [Column] Gets or Sets the Warranty
        /// </summary>
        public abstract String Warranty { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract String Campaign { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? hasWarranty { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? IsGroupWJ { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? WarrantyPeriod { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? WarrantyPeriodInterval { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? CancelledPurchaseOrderID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? BudgetGroupID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? RequestorID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? TransactionTypeGroupID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? BackgroundTypeID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? GroupRequestForQuotationID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? CampaignID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract ORequestForQuotation GroupRequestForQuotation { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<ORequestForQuotation> ChildRequestForQuotation { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<OLocation> GroupWJLocations { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract OBudgetGroup BudgetGroup { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OUser Requestor { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCode TransactionTypeGroup { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCode BackgroundType { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? AutoCalculateReallocationTo { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract String RequestorName { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? IsPaymentPaidByPercentage { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? IsGroupApproval { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? IsDelegatedToHOD { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<ORFQBudgetReallocationToPeriod> RFQBudgetReallocationToPeriods { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<ORFQBudgetReallocationFromPeriod> RFQBudgetReallocationFromPeriods { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? EmployerCompanyID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract String RFQTitle { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OCapitalandCompany EmployerCompany { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract OPurchaseOrder CancelledPurchaseOrder { get; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<ORequestForQuotationPaymentSchedule> RequestForQuotationPaymentSchedules { get; set; }

        /// <summary>
        /// This is to get List<OAttachment> for email message attachments
        /// Gets all the attachments from Vendor that has been awarded to send email to approvers.
        /// </summary>
        public override List<OAttachment> EmailMessageAttachments
        {
            get
            {
                // this is for attachment sending email.
                // currently sending attachment for awarded vendor only.
                // to avoid attachment of emails too big.
                //
                List<OAttachment> attachments = new List<OAttachment>();
                List<ORequestForQuotationVendor> awardedVendors =
                        this.RequestForQuotationVendors.FindAll((v) => v.IsSubmitted == (int)EnumApplicationGeneral.Yes);
                //this.RequestForQuotationItems.Find((i) => i.AwardedVendorID == v.VendorID) != null);
                if (awardedVendors != null)
                {
                    for (int i = 0; i < awardedVendors.Count; i++)
                        if (awardedVendors[i].Attachments != null)
                            attachments.AddRange(awardedVendors[i].Attachments.FindAll((a) => a.ObjectID != null));
                }

                return attachments;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static DataTable WJDetails(ORequestForQuotation o)
        {
            DataTable dt = new DataTable();
            dt.TableName = "WJDetails";

            dt = TablesLogic.tRequestForQuotation.Select
                (TablesLogic.tRequestForQuotation.Location.BuildingOwner.LogoFile.As("BuildingLogo"),
                TablesLogic.tRequestForQuotation.Location.BuildingOwner.ObjectName.As("BuildingOwner"),
                TablesLogic.tRequestForQuotation.Location.BuildingManagement.ObjectName.As("BuildingManagement"),
                TablesLogic.tRequestForQuotation.Location.BuildingOwner.Address.As("BuildingAddress"),
                TablesLogic.tRequestForQuotation.Location.BuildingOwner.Country.As("BuildingCountry"),
                TablesLogic.tRequestForQuotation.Location.BuildingOwner.PostalCode.As("BuildingPostalCode"),
                TablesLogic.tRequestForQuotation.Location.BuildingOwner.PhoneNo.As("BuildingPhone"),
                TablesLogic.tRequestForQuotation.Location.BuildingOwner.FaxNo.As("BuildingFax"),
                TablesLogic.tRequestForQuotation.Location.ObjectName.As("BuildingName"),
                TablesLogic.tRequestForQuotation.ObjectNumber.As("WJNumber"),
                TablesLogic.tRequestForQuotation.Description.As("WJDescription"),
                TablesLogic.tRequestForQuotation.Background,
                TablesLogic.tRequestForQuotation.Scope,
                TablesLogic.tRequestForQuotation.Evaluation,
                TablesLogic.tRequestForQuotation.Warranty,
                TablesLogic.tRequestForQuotation.WarrantyPeriod,
                TablesLogic.tRequestForQuotation.WarrantyPeriodInterval,
                TablesLogic.tRequestForQuotation.AwardedJustification,
                TablesLogic.tRequestForQuotation.CreatedUser)
                .Where
                (TablesLogic.tRequestForQuotation.ObjectID == o.ObjectID &
                TablesLogic.tRequestForQuotation.IsDeleted == 0);

            dt.Columns.Add("SubmitForApprovalDate", typeof(DateTime));
            dt.Rows[0]["SubmitForApprovalDate"] = o.SubmitForApprovalDate;

            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static DataTable WJApprovers(ORequestForQuotation o)
        {
            DataTable dt = new DataTable();
            dt.TableName = "WJApprovers";

            dt.Columns.Add("Level", typeof(int));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("ApprovedDate", typeof(DateTime));
            dt.Columns.Add("Action", typeof(string));

            foreach (Approvers a in o.ApproverList)
                dt.Rows.Add(a.ApprovalLevel, a.ApproverName, a.ApprovalDateTime, a.ApprovalStatus);

            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static DataTable WJQuotations(ORequestForQuotation o)
        {
            DataTable dt = new DataTable();
            dt.TableName = "WJQuotations";

            dt.Columns.Add("Number", typeof(int));
            dt.Columns.Add("Contractor", typeof(string));
            dt.Columns.Add("IPTVendor", typeof(string));
            dt.Columns.Add("ReferenceNumber", typeof(string));
            dt.Columns.Add("QuotationAmount", typeof(decimal));
            dt.Columns.Add("AboveMinimum", typeof(string));

            foreach (QuotationReceived q in o.QuotationReceivedList)
                dt.Rows.Add(q.Number, q.Contractor, q.IPTVendor, q.QuotationReference, q.QuotationAmount, q.PercentageAboveMinimumQuoteText);

            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static DataTable WJLineItems(ORequestForQuotation o)
        {
            DataTable dt = new DataTable();
            dt.TableName = "WJLineItems";

            dt = TablesLogic.tRequestForQuotationItem.Select
                (TablesLogic.tRequestForQuotationItem.ItemNumber,
                (Anacle.DataFramework.Case.When
                (TablesLogic.tRequestForQuotationItem.ItemType == PurchaseItemType.Material, Resources.Strings.PurchaseItemType_Material)
                .When
                (TablesLogic.tRequestForQuotationItem.ItemType == PurchaseItemType.Service, Resources.Strings.PurchaseItemType_Service)
                .When
                (TablesLogic.tRequestForQuotationItem.ItemType == PurchaseItemType.Others, Resources.Strings.PurchaseItemType_Others)
                .End).As("ItemType"),
                TablesLogic.tRequestForQuotationItem.ItemDescription,
                TablesLogic.tRequestForQuotationItem.AwardedVendor.ObjectName.As("AwardedVendor"),
                TablesLogic.tRequestForQuotationItem.Currency.ObjectName.As("Currency"),
                TablesLogic.tRequestForQuotationItem.QuantityProvided,
                (TablesLogic.tRequestForQuotationItem.UnitPrice * TablesLogic.tRequestForQuotationItem.QuantityProvided).As("SubTotal"))
                .Where
                (TablesLogic.tRequestForQuotationItem.RequestForQuotationID == o.ObjectID &
                TablesLogic.tRequestForQuotationItem.IsDeleted == 0)
                .OrderBy
                (TablesLogic.tRequestForQuotationItem.ItemNumber.Asc);
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static DataTable WJBudgetSummaries(ORequestForQuotation o)
        {
            DataTable dt = new DataTable();
            dt.TableName = "WJBudgets";

            dt.Columns.Add("BudgetPeriod", typeof(string));
            dt.Columns.Add("AccountName", typeof(string));
            dt.Columns.Add("AccountCode", typeof(string));
            dt.Columns.Add("TotalAvailableAdjusted", typeof(decimal));
            dt.Columns.Add("TotalAvailableBeforeSubmission", typeof(decimal));
            dt.Columns.Add("TotalAvaiableAtSubmission", typeof(decimal));
            dt.Columns.Add("TotalAvailableAfterApproval", typeof(decimal));

            foreach (BudgetSummary b in o.BudgetSummaries)
                dt.Rows.Add(b.BudgetPeriod, b.AccountName,
                    b.AccountCode, b.TotalAvailableAdjusted,
                    b.TotalAvailableBeforeSubmission, b.TotalAvailableAtSubmission,
                    b.TotalAvailableAfterApproval);

            return dt;
        }

        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                DataSet ds = new DataSet();
                DataSet dsTemp = new DataSet();
                DataTable dtWJDetails = WJDetails(this);
                DataTable dtWJItems = WJLineItems(this);
                DataTable dtWJQuotations = WJQuotations(this);
                DataTable dtWJBudgets = WJBudgetSummaries(this);
                DataTable dtWJApprovers = WJApprovers(this);

                dsTemp = dtWJDetails.DataSet;
                dsTemp.Tables.Remove(dtWJDetails);
                dsTemp = dtWJItems.DataSet;
                dsTemp.Tables.Remove(dtWJItems);

                dtWJDetails.TableName = "WJDetails";
                dtWJItems.TableName = "WJLineItems";
                dtWJApprovers.TableName = "WJApprovers";
                dtWJBudgets.TableName = "WJBudgets";
                dtWJQuotations.TableName = "WJQuotations";

                ds.Tables.Add(dtWJDetails);
                ds.Tables.Add(dtWJItems);
                ds.Tables.Add(dtWJApprovers);
                ds.Tables.Add(dtWJQuotations);
                ds.Tables.Add(dtWJBudgets);

                return ds;
            }
        }

        /// <summary>
        /// Gets List of vendor submitted quotation
        /// seperated by comma ','
        /// </summary>
        public string AwardedVendors
        {
            get
            {
                string str = "";
                if (RequestForQuotationVendors != null && RequestForQuotationItems != null)
                {
                    List<ORequestForQuotationVendor> awardedVendors =
                        this.RequestForQuotationVendors.FindAll((v) =>
                            this.RequestForQuotationItems.Find((i) => i.AwardedVendorID == v.VendorID) != null);
                    if (awardedVendors != null)
                        for (int i = 0; i < awardedVendors.Count; i++)
                            str += awardedVendors[i].Vendor.ObjectName + (i != (awardedVendors.Count - 1) ? ", " : "");
                }
                return str;
            }
        }

        /// <summary>
        /// Gets IsGroupWJ text (Yes or No)
        /// </summary>
        public string IsGroupWJText
        {
            get
            {
                if (IsGroupWJ == (int)EnumApplicationGeneral.Yes)
                    return Resources.Strings.General_Yes;
                else
                    return Resources.Strings.General_No;
            }
        }

        /// <summary>
        /// Method to update budget amount
        /// </summary>
        public void UpdateBudgetAmount()
        {
            if (this.PurchaseBudgets.Count == 1)
            {
                decimal? amount = 0;
                foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
                {
                    if (item.Subtotal != null)
                    {
                        amount += item.Subtotal -
                            (this.IsRecoverable == (int)EnumRecoverable.Recoverable ? item.RecoverableAmount : 0);
                    }
                }

                this.PurchaseBudgets[0].Amount = amount;
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
                decimal? taskAmount2 = 0;
                foreach (ORequestForQuotationItem rfqItem in this.RequestForQuotationItems)
                    taskAmount += Round(rfqItem.UnitPrice * rfqItem.QuantityProvided);

                foreach (OPurchaseBudget pb in this.PurchaseBudgets)
                    taskAmount2 += pb.Amount;

                if (taskAmount == null && taskAmount2 != null)
                    return taskAmount2.Value;
                if (taskAmount != null && taskAmount2 == null)
                    return taskAmount.Value;
                if (taskAmount != null && taskAmount2 != null)
                {
                    if (taskAmount > taskAmount2)
                        return taskAmount.Value;
                    else
                        return taskAmount2.Value;
                }
                return 0;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public decimal TotalPurchaseBudgateAmount
        {
            get
            {
                decimal totalBudgetAmount = 0;

                foreach (OPurchaseBudget budget in this.PurchaseBudgets)
                {
                    totalBudgetAmount += budget.Amount.Value;
                }

                return totalBudgetAmount;
            }
        }

        /// Gets the total amount to be reallocated from the source budget.
        /// </summary>
        public decimal TotalFromBudgetAmount
        {
            get
            {
                decimal total = 0;
                foreach (ORFQBudgetReallocationFromPeriod period in this.RFQBudgetReallocationFromPeriods)
                    foreach (ORFQBudgetReallocationFrom from in period.RFQBudgetReallocationFroms)
                        if (from.TotalAmount != null)
                            total += from.TotalAmount.Value;
                return total;
            }
        }

        /// <summary>
        /// Gets the total amount to be reallocated to the destination
        /// budget.
        /// </summary>
        public decimal TotalToBudgetAmount
        {
            get
            {
                decimal total = 0;
                foreach (ORFQBudgetReallocationToPeriod period in this.RFQBudgetReallocationToPeriods)
                    foreach (ORFQBudgetReallocationTo to in period.RFQBudgetReallocationTos)
                        if (to.TotalAmount != null)
                            total += to.TotalAmount.Value;
                return total;
            }
        }

        /// <summary>
        /// Computes the lowest quotation and updates the value to all
        /// the quotations, so that we can compute the percentage difference.
        /// </summary>
        public void ComputeLowestQuotation()
        {
            decimal minimumQuote = decimal.MaxValue;
            foreach (ORequestForQuotationVendor v in this.RequestForQuotationVendors)
            {
                if (v.IsSubmitted == (int)EnumApplicationGeneral.Yes)
                {
                    decimal quote = v.TotalQuotation.HasValue ? v.TotalQuotation.Value : 0M;
                    if (quote < minimumQuote)
                        minimumQuote = quote;
                }
            }

            foreach (ORequestForQuotationVendor v in this.RequestForQuotationVendors)
                v.MinimumQuote = minimumQuote;
        }

        /// <summary>
        /// Check the sub-total of each From Budget Period is equal to the sub-total Of the corresponding to Budget period
        /// and vice versa
        /// </summary>
        /// <returns></returns>
        public bool IsEqualReallocateAmount(out string periodList)
        {
            Hashtable toPeriodTotal = new Hashtable();
            Hashtable fromPeriodTotal = new Hashtable();
            List<string> keys = new List<string>();
            periodList = string.Empty;

            foreach (ORFQBudgetReallocationToPeriod p in RFQBudgetReallocationToPeriods)
            {
                string key = p.ToBudget.ObjectName + "->" + p.ToBudgetPeriod.ObjectName;

                if (toPeriodTotal[key] == null)
                    toPeriodTotal[key] = p.TotalAmount.Value;
                else
                    toPeriodTotal[key] = (decimal)toPeriodTotal[key] + p.TotalAmount.Value;

                if (!keys.Contains(key))
                    keys.Add(key);
            }

            foreach (ORFQBudgetReallocationFromPeriod p in RFQBudgetReallocationFromPeriods)
            {
                string key = p.FromBudget.ObjectName + "->" + p.FromBudgetPeriod.ObjectName;

                if (fromPeriodTotal[key] == null)
                    fromPeriodTotal[key] = p.TotalAmount.Value;
                else
                    fromPeriodTotal[key] = (decimal)fromPeriodTotal[key] + p.TotalAmount.Value;
            }

            foreach (string key in keys)
            {
                decimal fpTotal = (decimal)toPeriodTotal[key];
                decimal tpTotal = (decimal)fromPeriodTotal[key];

                if (fpTotal != tpTotal)
                    periodList = periodList.Trim().Length == 0 ? key : periodList + ", " + key;
            }

            if (periodList.Trim().Length > 0)
                return false;
            else
                return true;
        }

        /// <summary>
        /// Check the Total Of From Budget Items is equal to Total Of To Budget Items
        /// </summary>
        /// <returns></returns>
        public bool IsReallocateAcrossBudgetPeriod(out string acrossPeriod)
        {
            List<string> toPeriodList = new List<string>();
            List<string> fromPeriodList = new List<string>();
            acrossPeriod = string.Empty;

            if ((RFQBudgetReallocationToPeriods == null || RFQBudgetReallocationToPeriods.Count == 0)
                && (RFQBudgetReallocationFromPeriods == null || RFQBudgetReallocationFromPeriods.Count == 0))
                return false;

            foreach (ORFQBudgetReallocationToPeriod p in RFQBudgetReallocationToPeriods)
            {
                string key = p.ToBudget.ObjectName + "->" + p.ToBudgetPeriod.ObjectName;
                if (!toPeriodList.Contains(key))
                    toPeriodList.Add(key);
            }

            foreach (ORFQBudgetReallocationFromPeriod p in RFQBudgetReallocationFromPeriods)
            {
                string key = p.FromBudget.ObjectName + "->" + p.FromBudgetPeriod.ObjectName;
                if (!fromPeriodList.Contains(key))
                    fromPeriodList.Add(key);
            }

            List<string> onlyInToPeriod = toPeriodList.Except(fromPeriodList).ToList();
            List<string> onlyInFromPeriod = fromPeriodList.Except(toPeriodList).ToList();

            if (onlyInFromPeriod != null && onlyInFromPeriod.Count > 0)
                foreach (string s in onlyInFromPeriod)
                    acrossPeriod = acrossPeriod.Trim().Length == 0 ?
                        s : (acrossPeriod + ", " + s);

            if (onlyInToPeriod != null && onlyInToPeriod.Count > 0)
                foreach (string s in onlyInToPeriod)
                    acrossPeriod = acrossPeriod.Trim().Length == 0 ?
                        s : (acrossPeriod + ", " + s);

            if (onlyInFromPeriod.Count == 0 && onlyInToPeriod.Count == 0)
                return false;
            else
                return true;
        }

        /// <summary>
        /// Get ApprovalHierarchy for document template (WJPrintOut)
        /// </summary>
        ///
        public List<Approvers> ApproverList
        {
            get
            {
                return this.ApproverLists;
            }
        }

        /// <summary>
        /// Get QuotationReceived for document template (WJPrintOut)
        /// </summary>
        public List<QuotationReceived> QuotationReceivedList
        {
            get
            {
                this.ComputeLowestQuotation();
                List<QuotationReceived> qr = new List<QuotationReceived>();
                int no = 0;
                foreach (ORequestForQuotationVendor quotationvendor in this.RequestForQuotationVendors)
                {
                    QuotationReceived quotation = new QuotationReceived();
                    no++;
                    quotation.Number = no;
                    quotation.Contractor = quotationvendor.Vendor.ObjectName;
                    quotation.IPTVendor = quotationvendor.Vendor.IsInterestedPartyText;
                    quotation.QuotationReference = quotationvendor.ObjectNumber;
                    quotation.QuotationAmount = quotationvendor.TotalQuotation;
                    quotation.PercentageAboveMinimumQuoteText = quotationvendor.PercentageAboveMinimumQuoteText;
                    qr.Add(quotation);
                }
                return qr;
            }
        }

        /// <summary>
        /// get BuildingName for WJPrintOut
        /// </summary>
        public String BuildingName
        {
            get
            {
                // 2010.08.24
                // Kim Foong
                // Updated this to show locations in a Group WJ.
                //
                if (this.IsGroupWJ == 1)
                {
                    string s = "";
                    foreach (OLocation location in this.GroupWJLocations)
                        s += (s == "" ? "" : ", ") + location.ObjectName;
                    return s;
                }
                else
                {
                    return this.Location.ObjectName;
                }
            }
        }

        /// <summary>
        /// Text to display to indicate that message sent to approver includes an ipt vendor in the awarded items
        /// </summary>
        public string AwardedIPTVendorMessageTitleIndication
        {
            get
            {
                foreach (ORequestForQuotationItem i in this.RequestForQuotationItems)
                {
                    if (i.AwardedVendor.IsInterestedParty == 1)
                        return LogicLayer.Resources.Strings.RequestForQuotation_AwardedIPTVendorMessageTitleIndication;
                }
                return "";
            }
        }

        /// <summary>
        /// Get submit for approval datetime fro WJPrintOut
        /// </summary>
        public DateTime? SubmitForApprovalDate
        {
            get
            {
                string currentStatus = this.CurrentActivity.CurrentStateName;
                if (currentStatus == "Awarded" || currentStatus == "Close" || currentStatus == "PendingApproval")
                {
                    return
                        TablesLogic.tActivityHistory.Select(TablesLogic.tActivityHistory.ModifiedDateTime.Max())
                        .Where(TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                        TablesLogic.tActivityHistory.TriggeringEventName == "SubmitForApproval");
                }
                else
                    return DateTime.Now;
            }
        }

        /// <summary>
        /// Gets Last approval date (WJ Printout)
        /// Copy to PO date as well.
        /// </summary>
        public DateTime? LastApprovalDate
        {
            get
            {
                string currentStatus = this.CurrentActivity.CurrentStateName;
                if (currentStatus == "Awarded" || currentStatus == "Close")
                {
                    return
                        TablesLogic.tActivityHistory.Select(TablesLogic.tActivityHistory.ModifiedDateTime.Max())
                        .Where(TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                        TablesLogic.tActivityHistory.CurrentStateName == "Awarded");
                }
                return null;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Create a single RFQ from a set of WJ line items and saves the
        /// RFQ into the database.
        /// </summary>
        /// <param name="prLineItems"></param>
        /// --------------------------------------------------------------
        public static ORequestForQuotation CreateRFQFromPRLineItemsWithBudget(List<OPurchaseRequestItem> items)
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
                //o.RequestorID = r.PurchaseRequestorID;
                o.TransactionTypeGroupID = r.TransactionTypeGroupID;
                o.BudgetGroupID = r.BudgetGroupID;
                o.PurchaseTypeID = r.PurchaseTypeID;
                //tessa begin 2009.11.02 for capitaland
                o.Background = r.Background;
                o.Scope = r.Scope;
                //tessa end
                AddRFQLineItemsFromPRLineItemsWithBudget(o, items);

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
        public static void AddRFQLineItemsFromPRLineItemsWithBudget(ORequestForQuotation rfq, List<OPurchaseRequestItem> items)
        {
            using (Connection c = new Connection())
            {
                int i = TablesLogic.tRequestForQuotationItem[
                    TablesLogic.tRequestForQuotationItem.RequestForQuotationID == rfq.ObjectID].Count + 1;

                Hashtable purchaseRequests = new Hashtable();
                // KF BEGIN 2007.05.09
                List<Guid> purchaseRequestIds = new List<Guid>();
                // KF END

                foreach (OPurchaseRequestItem item in items)
                {
                    if (item.RequestForQuotationItem == null && item.PurchaseOrderItem == null)
                    {
                        ORequestForQuotationItem n = TablesLogic.tRequestForQuotationItem.Create();
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
                        rfq.PurchaseBudgets.AddRange(newPurchaseBudgets);

                        n.ItemNumber = i++;
                        n.ItemType = item.ItemType;
                        n.CatalogueID = item.CatalogueID;
                        n.FixedRateID = item.FixedRateID;
                        n.ItemDescription = item.ItemDescription;
                        n.UnitOfMeasureID = item.UnitOfMeasureID;
                        n.QuantityRequired = item.QuantityRequired;
                        n.PurchaseRequestItemID = item.ObjectID;
                        n.ReceiptMode = item.ReceiptMode;
                        n.EstimatedUnitPrice = item.EstimatedUnitPrice;

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

                // Transfer all the budgets over to the PO.
                //
                List<OBudgetTransactionLog> newTransactions = new List<OBudgetTransactionLog>();
                List<OBudgetTransactionLog> modifiedTransactions = new List<OBudgetTransactionLog>();
                OPurchaseBudget.CreateBudgetTransactionLogs(rfq.PurchaseBudgets, BudgetTransactionType.PurchaseApproved, newTransactions, modifiedTransactions);
                foreach (OBudgetTransactionLog transaction in newTransactions)
                    transaction.Save();
                foreach (OBudgetTransactionLog transaction in modifiedTransactions)
                    transaction.Save();

                // KF END

                c.Commit();
            }
        }

        /// <summary>
        /// Find that the specified account ID
        /// in the list of amounts in this temp rfq budget reallocation to.
        /// </summary>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public ORFQBudgetReallocationTo FindRFQBudgetReallocationToByAccountId(
            ORFQBudgetReallocationToPeriod period, Guid accountId)
        {
            if (period == null || period.RFQBudgetReallocationTos == null)
                return null;

            foreach (ORFQBudgetReallocationTo to in period.RFQBudgetReallocationTos)
                if (to.AccountID == accountId)
                    return to;
            return null;
        }

        public ORFQBudgetReallocationToPeriod FindRFQBudgetReallocationToPeriod(Guid budgetId, Guid budgetPeriodId)
        {
            if (this.RFQBudgetReallocationToPeriods == null)
                return null;

            foreach (ORFQBudgetReallocationToPeriod period in this.RFQBudgetReallocationToPeriods)
                if (period.ToBudgetID == budgetId && period.ToBudgetPeriodID == budgetPeriodId)
                    return period;
            return null;
        }

        public ORFQBudgetReallocationToPeriod FindRFQBudgetReallocationToPeriod(Guid budgetId, Guid budgetPeriodId, Guid accountId)
        {
            if (this.RFQBudgetReallocationToPeriods == null)
                return null;

            foreach (ORFQBudgetReallocationToPeriod period in this.RFQBudgetReallocationToPeriods)
            {
                if (period.ToBudgetID == budgetId && period.ToBudgetPeriodID == budgetPeriodId
                    && period.RFQBudgetReallocationTos != null && period.RFQBudgetReallocationTos.Count > 0 &&
                    period.RFQBudgetReallocationTos[0].AccountID == accountId)
                    return period;
            }
            return null;
        }

        /// <summary>
        /// Computes the temporary list of BudgetReallocationTos
        /// summaries.
        /// </summary>
        public void ComputeBudgetReallocationToPeriods()
        {
            if (this.TempPurchaseBudgetSummaries == null || this.TempPurchaseBudgetSummaries.Count == 0)
            {
                if (this.RFQBudgetReallocationToPeriods != null)
                {
                    this.RFQBudgetReallocationToPeriods.Clear();

                    if (this.RFQBudgetReallocationFromPeriods != null)
                        this.RFQBudgetReallocationFromPeriods.Clear();
                }
                return;
            }

            //remove RFQBudgetReallactionTo either not in budget summary
            //or the corresponding budget summary is >= 0
            if (this.RFQBudgetReallocationToPeriods != null && this.RFQBudgetReallocationToPeriods.Count > 0)
            {
                int periodCount = this.RFQBudgetReallocationToPeriods.Count;
                for (int i = 0; i < periodCount; i++)
                {
                    ORFQBudgetReallocationToPeriod period = this.RFQBudgetReallocationToPeriods[i];

                    if (period.RFQBudgetReallocationTos != null)
                    {
                        int reallocationToCount = period.RFQBudgetReallocationTos.Count;

                        for (int j = 0; j < reallocationToCount; j++)
                        {
                            ORFQBudgetReallocationTo to = period.RFQBudgetReallocationTos[j];
                            bool matchAccountID = false;
                            foreach (OPurchaseBudgetSummary summary in this.TempPurchaseBudgetSummaries)
                            {
                                //remove RFQBudgetReallactionTo whose budget summary >= 0
                                if (to.AccountID == summary.AccountID
                                    && period.ToBudgetID == summary.BudgetID
                                    && period.ToBudgetPeriodID == summary.BudgetPeriodID)
                                {
                                    matchAccountID = true;

                                    if (summary.TotalAvailableAtSubmission >= 0)
                                    {
                                        period.RFQBudgetReallocationTos.Remove(to);
                                        reallocationToCount--;
                                        j--;
                                    }

                                    break;
                                }
                            }

                            //remove RFQBudgetReallactionTo not in budget summary
                            if (!matchAccountID)
                            {
                                period.RFQBudgetReallocationTos.Remove(to);
                                reallocationToCount--;
                                j--;
                            }
                        }
                    }

                    if (period.RFQBudgetReallocationTos == null || period.RFQBudgetReallocationTos.Count == 0)
                    {
                        this.RFQBudgetReallocationToPeriods.Remove(period);
                        periodCount--;
                        i--;
                        continue;
                    }
                }
            }

            foreach (OPurchaseBudgetSummary summary in this.TempPurchaseBudgetSummaries)
            {
                if (summary.TotalAvailableAfterDeduction < 0)
                {
                    ORFQBudgetReallocationToPeriod period = this.FindRFQBudgetReallocationToPeriod(
                        summary.BudgetID.Value, summary.BudgetPeriodID.Value, summary.AccountID.Value);

                    if (period == null)
                    {
                        period = TablesLogic.tRFQBudgetReallocationToPeriod.Create();
                        period.RequestForQuotationID = this.ObjectID;
                        period.ToBudgetID = summary.BudgetID;
                        period.ToBudgetPeriodID = summary.BudgetPeriodID;

                        ORFQBudgetReallocationTo to = TablesLogic.tRFQBudgetReallocationTo.Create();
                        to.AccountID = summary.AccountID;
                        to.RFQBudgetReallocationToPeriodID = period.ObjectID;

                        if (AutoCalculateReallocationTo == 1)
                            period.TotalAmount = -summary.TotalAvailableAfterDeduction;

                        to.TotalAmount = period.TotalAmount;
                        to.Interval01Amount = to.TotalAmount;

                        //switch (period.ToBudgetPeriod.TotalNumberOfIntervals)
                        //{
                        //    case 1: to.Interval01Amount = to.TotalAmount; break;
                        //    case 2: to.Interval02Amount = to.TotalAmount; break;
                        //    case 3: to.Interval03Amount = to.TotalAmount; break;
                        //    case 4: to.Interval04Amount = to.TotalAmount; break;
                        //    case 5: to.Interval05Amount = to.TotalAmount; break;
                        //    case 6: to.Interval06Amount = to.TotalAmount; break;
                        //    case 7: to.Interval07Amount = to.TotalAmount; break;
                        //    case 8: to.Interval08Amount = to.TotalAmount; break;
                        //    case 9: to.Interval09Amount = to.TotalAmount; break;
                        //    case 10: to.Interval10Amount = to.TotalAmount; break;
                        //    case 11: to.Interval11Amount = to.TotalAmount; break;
                        //    case 12: to.Interval12Amount = to.TotalAmount; break;
                        //    case 13: to.Interval13Amount = to.TotalAmount; break;
                        //    case 14: to.Interval14Amount = to.TotalAmount; break;
                        //    case 15: to.Interval15Amount = to.TotalAmount; break;
                        //    case 16: to.Interval16Amount = to.TotalAmount; break;
                        //    case 17: to.Interval17Amount = to.TotalAmount; break;
                        //    case 18: to.Interval18Amount = to.TotalAmount; break;
                        //    case 19: to.Interval19Amount = to.TotalAmount; break;
                        //    case 20: to.Interval20Amount = to.TotalAmount; break;
                        //    case 21: to.Interval21Amount = to.TotalAmount; break;
                        //    case 22: to.Interval22Amount = to.TotalAmount; break;
                        //    case 23: to.Interval23Amount = to.TotalAmount; break;
                        //    case 24: to.Interval24Amount = to.TotalAmount; break;
                        //    case 25: to.Interval25Amount = to.TotalAmount; break;
                        //    case 26: to.Interval26Amount = to.TotalAmount; break;
                        //    case 27: to.Interval27Amount = to.TotalAmount; break;
                        //    case 28: to.Interval28Amount = to.TotalAmount; break;
                        //    case 29: to.Interval29Amount = to.TotalAmount; break;
                        //    case 30: to.Interval30Amount = to.TotalAmount; break;
                        //    case 31: to.Interval31Amount = to.TotalAmount; break;
                        //    case 32: to.Interval32Amount = to.TotalAmount; break;
                        //    case 33: to.Interval33Amount = to.TotalAmount; break;
                        //    case 34: to.Interval34Amount = to.TotalAmount; break;
                        //    case 35: to.Interval35Amount = to.TotalAmount; break;
                        //    case 36: to.Interval36Amount = to.TotalAmount; break;
                        //}

                        period.RFQBudgetReallocationTos.Add(to);
                        this.RFQBudgetReallocationToPeriods.Add(period);
                    }
                    else
                    {
                        //ORFQBudgetReallocationTo to = this.FindRFQBudgetReallocationToByAccountId(period, summary.AccountID.Value);
                        ORFQBudgetReallocationTo to = period.RFQBudgetReallocationTos[0];

                        if (AutoCalculateReallocationTo == 1)
                            period.TotalAmount = -summary.TotalAvailableAfterDeduction;

                        to.TotalAmount = period.TotalAmount;
                        to.Interval01Amount = to.TotalAmount;

                        //switch (period.ToBudgetPeriod.TotalNumberOfIntervals)
                        //{
                        //    case 1: to.Interval01Amount = to.TotalAmount; break;
                        //    case 2: to.Interval02Amount = to.TotalAmount; break;
                        //    case 3: to.Interval03Amount = to.TotalAmount; break;
                        //    case 4: to.Interval04Amount = to.TotalAmount; break;
                        //    case 5: to.Interval05Amount = to.TotalAmount; break;
                        //    case 6: to.Interval06Amount = to.TotalAmount; break;
                        //    case 7: to.Interval07Amount = to.TotalAmount; break;
                        //    case 8: to.Interval08Amount = to.TotalAmount; break;
                        //    case 9: to.Interval09Amount = to.TotalAmount; break;
                        //    case 10: to.Interval10Amount = to.TotalAmount; break;
                        //    case 11: to.Interval11Amount = to.TotalAmount; break;
                        //    case 12: to.Interval12Amount = to.TotalAmount; break;
                        //    case 13: to.Interval13Amount = to.TotalAmount; break;
                        //    case 14: to.Interval14Amount = to.TotalAmount; break;
                        //    case 15: to.Interval15Amount = to.TotalAmount; break;
                        //    case 16: to.Interval16Amount = to.TotalAmount; break;
                        //    case 17: to.Interval17Amount = to.TotalAmount; break;
                        //    case 18: to.Interval18Amount = to.TotalAmount; break;
                        //    case 19: to.Interval19Amount = to.TotalAmount; break;
                        //    case 20: to.Interval20Amount = to.TotalAmount; break;
                        //    case 21: to.Interval21Amount = to.TotalAmount; break;
                        //    case 22: to.Interval22Amount = to.TotalAmount; break;
                        //    case 23: to.Interval23Amount = to.TotalAmount; break;
                        //    case 24: to.Interval24Amount = to.TotalAmount; break;
                        //    case 25: to.Interval25Amount = to.TotalAmount; break;
                        //    case 26: to.Interval26Amount = to.TotalAmount; break;
                        //    case 27: to.Interval27Amount = to.TotalAmount; break;
                        //    case 28: to.Interval28Amount = to.TotalAmount; break;
                        //    case 29: to.Interval29Amount = to.TotalAmount; break;
                        //    case 30: to.Interval30Amount = to.TotalAmount; break;
                        //    case 31: to.Interval31Amount = to.TotalAmount; break;
                        //    case 32: to.Interval32Amount = to.TotalAmount; break;
                        //    case 33: to.Interval33Amount = to.TotalAmount; break;
                        //    case 34: to.Interval34Amount = to.TotalAmount; break;
                        //    case 35: to.Interval35Amount = to.TotalAmount; break;
                        //    case 36: to.Interval36Amount = to.TotalAmount; break;
                        //}
                    }
                }
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
                foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
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
                }
            }
            return skipApproval;
        }

        public bool ValidateFromAccountIdDoesNotExist(Guid budgetId, Guid budgetPeriodId, Guid accountId)
        {
            if (this.RFQBudgetReallocationFromPeriods == null)
                return true;

            foreach (ORFQBudgetReallocationFromPeriod period in this.RFQBudgetReallocationFromPeriods)
            {
                if (period.RFQBudgetReallocationFroms == null)
                    continue;
                else if (period.FromBudgetID == budgetId && period.FromBudgetPeriodID == budgetPeriodId)
                {
                    foreach (ORFQBudgetReallocationFrom from in period.RFQBudgetReallocationFroms)
                        if (from.AccountID == accountId)
                            return false;
                }
            }

            return true;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="budgetId"></param>
        /// <param name="budgetPeriodId"></param>
        /// <returns></returns>
        public ORFQBudgetReallocationFromPeriod FindRFQBudgetReallocationFromPeriod(Guid budgetId, Guid budgetPeriodId)
        {
            if (this.RFQBudgetReallocationFromPeriods == null)
                return null;

            foreach (ORFQBudgetReallocationFromPeriod period in this.RFQBudgetReallocationFromPeriods)
                if (period.FromBudgetID == budgetId && period.FromBudgetPeriodID == budgetPeriodId)
                    return period;
            return null;
        }

        /// <summary>
        /// Validates that there is sufficient amount in the budgets
        /// for the deduction.
        /// </summary>
        /// <returns>Returns a string of a list of budget periods and accounts
        /// that are insufficient. Returns an empty string otherwise.
        /// </returns>
        public string ValidateSufficientBudgetWithBudgetReallocation()
        {
            List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
            return OBudgetPeriod.CheckSufficientBalance(
                OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null), this);
        }

        /// <summary>
        /// Checks for all available budgeted amount for the budget item should
        /// not be less than 0 after the reallocation (of both from)
        /// And make sure the item has not been inactivated
        /// </summary>
        /// <returns></returns>
        public string CheckSufficientAvailableAmountForReallocation()
        {
            string listOfAccounts = "";

            if (this.RFQBudgetReallocationFromPeriods != null)
            {
                foreach (ORFQBudgetReallocationFromPeriod period in this.RFQBudgetReallocationFromPeriods)
                    foreach (ORFQBudgetReallocationFrom from in period.RFQBudgetReallocationFroms)
                    {
                        //if (from.CurrentAvailable.Value - from.TotalAmount.Value < 0)
                        if (from.TotalAvailableBalance.Value - from.TotalAmount.Value < 0)
                            listOfAccounts += (listOfAccounts == "" ? "" : ", ") + from.Account.Path;
                    }
            }

            return listOfAccounts;
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
        public void SubmitForApprovalForCapitaland()
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

                    CreateBudgetVariationLogs();
                    UpdateBudgetSummaryWithReallocation();
                    this.IsSubmittedForApproval = 1;
                }
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        ///
        /// </summary>
        public void CreateBudgetVariationLogs()
        {
            ComputeFromBudgetSummary();

            if (this.RFQBudgetReallocationToPeriods != null && this.RFQBudgetReallocationFromPeriods != null)
            {
                foreach (ORFQBudgetReallocationFromPeriod fromPeriod in this.RFQBudgetReallocationFromPeriods)
                    foreach (ORFQBudgetReallocationFrom from in fromPeriod.RFQBudgetReallocationFroms)
                    {
                        // Create a variation log record for each of the
                        // intervals whose value is greater than zero.
                        //
                        //from.AvailableAtSubmission = from.CurrentAvailable - from.TotalAmount;

                        from.TotalOpeningBalanceAtSubmission = from.TotalOpeningBalance;
                        from.TotalAdjustedAmountAtSubmission = from.TotalAdjustedAmount;
                        from.TotalReallocatedAmountAtSubmission = from.TotalReallocatedAmount;
                        from.TotalBalanceAfterVariationAtSubmission = from.TotalBalanceAfterVariation;
                        from.TotalPendingApprovalAtSubmission = from.TotalPendingApproval;
                        from.TotalApprovedAtSubmission = from.TotalApproved;
                        from.TotalDirectInvoicePendingApprovalAtSubmission = from.TotalDirectInvoicePendingApproval;
                        from.TotalDirectInvoiceApprovedAtSubmission = from.TotalDirectInvoiceApproved;
                        from.TotalAvailableBalanceAtSubmission = from.TotalAvailableBalance;

                        from.Save();

                        for (int i = 1; i <= 1; i++)
                        {
                            decimal changeValue = (decimal)from.TotalAmount;

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Reallocation;
                            log.BudgetID = fromPeriod.FromBudgetID;
                            log.BudgetPeriodID = fromPeriod.FromBudgetPeriodID;
                            log.AccountID = from.AccountID;
                            log.IntervalNumber = fromPeriod.FromBudgetPeriod.GetIntervalNumber(DateTime.Today);
                            log.VariationAmount = -changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.RequestForQuotationID = this.ObjectID;
                            log.VariationStatus = BudgetVariationStatus.PendingApproval;
                            log.Save();
                        }
                    }

                foreach (ORFQBudgetReallocationToPeriod toPeriod in this.RFQBudgetReallocationToPeriods)
                    foreach (ORFQBudgetReallocationTo to in toPeriod.RFQBudgetReallocationTos)
                    {
                        // The ValidateAccountIdDoesNotExist can be used to test
                        // if the account exists in the budget period. If it does
                        // NOT exist, then an opening balance of ZERO must be
                        // created for that account.
                        //
                        bool hasValue = false;
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)to.DataRow["Interval" + (i.ToString("00")) + "Amount"];
                            if (changeValue != 0)
                                hasValue = true;
                        }
                        if (hasValue && toPeriod.ToBudgetPeriod.ValidateAccountIdDoesNotExist(to.AccountID.Value))
                        {
                            OBudgetPeriodOpeningBalance openingBalance = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                            openingBalance.BudgetPeriodID = toPeriod.ToBudgetPeriodID;
                            openingBalance.AccountID = to.AccountID;
                            openingBalance.Save();
                        }

                        // Create a variation log record for each of the
                        // intervals whose value is greater than zero.
                        //
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)to.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Reallocation;
                            log.BudgetID = toPeriod.ToBudgetID;
                            log.BudgetPeriodID = toPeriod.ToBudgetPeriodID;
                            log.AccountID = to.AccountID;
                            log.IntervalNumber = i;
                            log.VariationAmount = changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.RequestForQuotationID = this.ObjectID;
                            log.VariationStatus = BudgetVariationStatus.PendingApproval;
                            log.Save();
                        }
                    }
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
        public void ApproveForCapitaland()
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

                    OBudgetVariationLog.SetBudgetVariationLogsStatusByRequestForQuotationID(this.ObjectID.Value, BudgetVariationStatus.Approved);
                    this.IsApproved = 1;
                }
                this.Save();
                if (this.isSyncCRV && !String.IsNullOrEmpty(this.CRVSerialNumber))
                    this.CRVTenderAwardedRFQSync();//Nguyen Quoc Phuong 10-Dec-2012                
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
        public void RejectForCapitaland()
        {
            using (Connection c = new Connection())
            {
                if (this.IsSubmittedForApproval != 0)
                {
                    OPurchaseBudget.ClearBudgetTransactionLogs(this.PurchaseBudgets);
                    this.PurchaseBudgetSummaries.Clear();
                    OBudgetVariationLog.ClearBudgetVariationLogsByRequestForQuotationID(this.ObjectID.Value);

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
        public void CancelForCapitaland()
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
                OBudgetVariationLog.ClearBudgetVariationLogsByRequestForQuotationID(this.ObjectID.Value);

                this.Save();
                c.Commit();
            }
            if(this.IsGroupWJ != 1 && !String.IsNullOrEmpty(this.CRVSerialNumber)) this.CRVTenderCancelRFQSync();//Nguyen Quoc Phuong 10-Dec-2012
        }

        /// <summary>
        ///
        /// </summary>
        public void UpdateBudgetSummaryWithReallocation()
        {
            if (PurchaseBudgetSummaries != null && RFQBudgetReallocationToPeriods != null)
            {
                Hashtable summary = new Hashtable();
                foreach (OPurchaseBudgetSummary s in PurchaseBudgetSummaries)
                    summary[s.BudgetID.Value.ToString() + "," + s.BudgetPeriodID.Value.ToString() + "," + s.AccountID.Value.ToString()] = s;

                foreach (ORFQBudgetReallocationToPeriod p in RFQBudgetReallocationToPeriods)
                    foreach (ORFQBudgetReallocationTo to in p.RFQBudgetReallocationTos)
                    {
                        string key =
                        p.ToBudgetID.Value.ToString() + "," +
                        (p.ToBudgetPeriodID == null ? "" : p.ToBudgetPeriodID.Value.ToString()) + "," +
                        to.AccountID.Value.ToString();

                        ((OPurchaseBudgetSummary)summary[key]).TotalReallocation = to.TotalAmount;
                    }
            }
        }

        public void UpdateTempBudgetSummaryWithReallocation()
        {
            if (TempPurchaseBudgetSummaries != null && RFQBudgetReallocationToPeriods != null)
            {
                Hashtable summary = new Hashtable();
                foreach (OPurchaseBudgetSummary s in TempPurchaseBudgetSummaries)
                    summary[s.BudgetID.Value.ToString() + "," + s.BudgetPeriodID.Value.ToString() + "," + s.AccountID.Value.ToString()] = s;

                foreach (ORFQBudgetReallocationToPeriod p in RFQBudgetReallocationToPeriods)
                    foreach (ORFQBudgetReallocationTo to in p.RFQBudgetReallocationTos)
                    {
                        string key =
                        p.ToBudgetID.Value.ToString() + "," +
                        (p.ToBudgetPeriodID == null ? "" : p.ToBudgetPeriodID.Value.ToString()) + "," +
                        to.AccountID.Value.ToString();

                        ((OPurchaseBudgetSummary)summary[key]).TotalReallocation = to.TotalAmount;
                    }
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
        public void UpdateBudgetReallocation()
        {
            if (this.RFQBudgetReallocationFromPeriods != null)
            {
                foreach (ORFQBudgetReallocationFromPeriod period in this.RFQBudgetReallocationFromPeriods)
                {
                    period.RFQBudgetReallocationFroms[0].TotalAmount = period.TotalAmount;

                    //update each interval amount
                }
            }

            if (this.RFQBudgetReallocationToPeriods != null)
            {
                foreach (ORFQBudgetReallocationToPeriod period in this.RFQBudgetReallocationToPeriods)
                {
                    period.RFQBudgetReallocationTos[0].TotalAmount = period.TotalAmount;

                    //update each interval amount
                }
            }
        }

        /// <summary>
        /// BudgetSummaries for WJPrintOut distinct Account
        /// </summary>
        public List<BudgetSummary> BudgetSummaries
        {
            get
            {
                List<BudgetSummary> budgetSummaries = new List<BudgetSummary>();
                List<OPurchaseBudgetSummary> listPurchaseBudgetSummaries = new List<OPurchaseBudgetSummary>();

                if (!this.CurrentActivity.ObjectName.Is("PendingApproval", "Awarded", "Close", "Cancelled"))
                {
                    this.ComputeTempBudgetSummaries();
                    listPurchaseBudgetSummaries = this.TempPurchaseBudgetSummaries;
                }
                else
                {
                    listPurchaseBudgetSummaries = this.PurchaseBudgetSummaries.FindAll((o) => o.ObjectID != null);
                }

                foreach (OPurchaseBudgetSummary s in listPurchaseBudgetSummaries)
                {
                    BudgetSummary bs = new BudgetSummary();
                    bs.Budget = s.Budget.ObjectName;
                    bs.BudgetPeriod = s.BudgetPeriod.ObjectName;
                    bs.AccountName = s.Account.Path;
                    bs.AccountCode = s.Account.AccountCode;
                    bs.TotalAvailableAdjusted = Round(s.TotalAvailableAdjusted).Value.ToString();
                    bs.TotalAvailableBeforeSubmission = Round(s.TotalAvailableBeforeSubmission).Value.ToString();
                    bs.TotalAvailableAtSubmission = Round(s.TotalAvailableAtSubmission).Value.ToString();
                    bs.TotalAvailableAfterApproval = Round(s.TotalAvailableAfterApproval).Value.ToString();
                    budgetSummaries.Add(bs);
                }

                return budgetSummaries;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public void ComputeFromBudgetSummary()
        {
            if (this.RFQBudgetReallocationFromPeriods.Count > 0)
            {
                foreach (ORFQBudgetReallocationFromPeriod fromPeriod in this.RFQBudgetReallocationFromPeriods)
                {
                    if (fromPeriod.FromBudgetPeriod != null && fromPeriod.RFQBudgetReallocationFroms.Count > 0)
                    {
                        DataTable dt = fromPeriod.FromBudgetPeriod.GenerateSummaryBudgetViewWithoutTree(null);

                        foreach (ORFQBudgetReallocationFrom from in fromPeriod.RFQBudgetReallocationFroms)
                        {
                            DataRow[] drs = dt.Select("AccountID = '" + from.AccountID.Value.ToString
                                () + "'");
                            if (drs != null && drs.Length > 0)
                            {
                                from.TotalOpeningBalance = Convert.ToDecimal(drs[0]["TotalOpeningBalance"].ToString());
                                from.TotalAdjustedAmount = Convert.ToDecimal(drs[0]["TotalAdjustedAmount"].ToString());
                                from.TotalReallocatedAmount = Convert.ToDecimal(drs[0]["TotalReallocatedAmount"].ToString());
                                from.TotalBalanceAfterVariation = Convert.ToDecimal(drs[0]["TotalBalanceAfterVariation"].ToString());
                                from.TotalPendingApproval = Convert.ToDecimal(drs[0]["TotalPendingApproval"].ToString());
                                from.TotalApproved = Convert.ToDecimal(drs[0]["TotalApproved"].ToString());
                                from.TotalAvailableBalance = Convert.ToDecimal(drs[0]["TotalAvailableBalance"].ToString());
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Clones a RFQ object. The budget distribution, however, is not cloned.
        /// </summary>
        /// <returns></returns>
        public object Clone()
        {
            ORequestForQuotation newObject = TablesLogic.tRequestForQuotation.Create();
            newObject.ShallowCopy(this);
            newObject.DateRequired = null;
            newObject.DateEnd = null;
            newObject.IsSubmittedForApproval = null;
            newObject.IsApproved = null;
            newObject.CreatedUserID = Workflow.CurrentUser != null ? Workflow.CurrentUser.ObjectID : null;

            // 2011.12.01
            // Thai Binh
            // Copy over GroupWJLocations
            foreach (OLocation location in this.GroupWJLocations)
            {
                newObject.GroupWJLocations.Add(location);
            }

            // 2010.11.16
            // Kim Foong
            // Bug fix to clear the ObjectNumber
            //
            newObject.ObjectNumber = null;

            Hashtable rfqItemNewObjectID = new Hashtable();

            foreach (ORequestForQuotationItem thisItem in this.RequestForQuotationItems)
            {
                ORequestForQuotationItem newItem = TablesLogic.tRequestForQuotationItem.Create();
                newItem.ShallowCopy(thisItem);

                // 2011 05 04
                // Kien Trung
                // Bug fix to clear awardRfqVendorItemID.
                //
                thisItem.AwardedRequestForQuotationVendorItemID = null;
                rfqItemNewObjectID[thisItem.ObjectID.Value] = newItem.ObjectID;

                // 2011.12.01
                // Thai Binh
                // Bug fix to add RequestForQuotationItemLocation
                //
                foreach (ORequestForQuotationItemLocation rfqLoc in thisItem.RequestForQuotationItemLocation)
                {
                    ORequestForQuotationItemLocation newRfqLoc = TablesLogic.tRequestForQuotationItemLocation.Create();
                    newRfqLoc.ShallowCopy(rfqLoc);
                    newItem.RequestForQuotationItemLocation.Add(newRfqLoc);
                }

                newObject.RequestForQuotationItems.Add(newItem);
            }

            foreach (ORequestForQuotationVendor thisItem in this.RequestForQuotationVendors)
            {
                ORequestForQuotationVendor newItem = TablesLogic.tRequestForQuotationVendor.Create();
                newItem.VendorID = thisItem.VendorID;
                newItem.IsSubmitted = 0;

                OVendor vendor = TablesLogic.tVendor[newItem.VendorID];

                if (vendor != null)
                {
                    newItem.ContactAddress = vendor.OperatingAddress;
                    newItem.ContactAddressCity = vendor.OperatingAddressCity;
                    newItem.ContactAddressCountry = vendor.OperatingAddressCountry;
                    newItem.ContactAddressState = vendor.OperatingAddressState;
                    newItem.ContactCellPhone = vendor.OperatingCellPhone;
                    newItem.ContactEmail = vendor.OperatingEmail;
                    newItem.ContactFax = vendor.OperatingFax;
                    newItem.ContactPhone = vendor.OperatingPhone;
                    newItem.ContactPerson = vendor.OperatingContactPerson;
                    if (vendor.CurrencyID != null)
                    {
                        if (newItem.CurrencyID != vendor.CurrencyID)
                        {
                            newItem.CurrencyID = vendor.CurrencyID;
                            newItem.UpdateExchangeRate();
                        }
                    }
                    else
                    {
                        newItem.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;
                        newItem.ForeignToBaseExchangeRate = 1.0M;
                        newItem.IsExchangeRateDefined = 1;
                    }
                }
                newObject.CreateRequestForQuotationVendorItems(newItem);
                newItem.UpdateItemCurrencies();

                newObject.RequestForQuotationVendors.Add(newItem);
            }

            return newObject;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="item"></param>
        public void UpdateLineItemsToRFQVendors(ORequestForQuotationItem item)
        {
            foreach (ORequestForQuotationVendor rfqVendor in this.RequestForQuotationVendors)
            {
                ORequestForQuotationVendorItem rfqVendorItem = rfqVendor.RequestForQuotationVendorItems.Find((r) => r.RequestForQuotationItemID == item.ObjectID);
                if (rfqVendorItem == null)
                    rfqVendorItem = TablesLogic.tRequestForQuotationVendorItem.Create();

                rfqVendorItem.ItemNumber = item.ItemNumber;
                rfqVendorItem.ItemType = item.ItemType;
                rfqVendorItem.ItemDescription = item.ItemDescription;
                rfqVendorItem.CatalogueID = item.CatalogueID;
                rfqVendorItem.FixedRateID = item.FixedRateID;
                rfqVendorItem.UnitOfMeasureID = item.UnitOfMeasureID;
                rfqVendorItem.CatalogueID = item.CatalogueID;
                rfqVendorItem.UnitPrice = rfqVendorItem.UnitPrice != null ? rfqVendorItem.UnitPrice : 0.0M;
                rfqVendorItem.QuantityProvided = item.QuantityRequired;
                rfqVendorItem.ItemDiscount = rfqVendorItem.ItemDiscount != null ? rfqVendorItem.ItemDiscount : 0.0M;
                rfqVendorItem.RequestForQuotationItemID = item.ObjectID;
                rfqVendorItem.UnitPriceInSelectedCurrency = (rfqVendorItem.UnitPriceInSelectedCurrency != null ? rfqVendorItem.UnitPriceInSelectedCurrency : 0.0M);

                rfqVendor.RequestForQuotationVendorItems.Add(rfqVendorItem);
                rfqVendor.UpdateItemCurrencies();
                rfqVendor.UpdateItemsUnitPrice();
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="item"></param>
        public void RemoveLineItemsFromRFQVendors(ORequestForQuotationItem item)
        {
            foreach (ORequestForQuotationVendor rfqVendor in this.RequestForQuotationVendors)
            {
                ORequestForQuotationVendorItem rfqVendorItem = rfqVendor.RequestForQuotationVendorItems.Find((r) => r.RequestForQuotationItemID == item.ObjectID);
                if (rfqVendorItem != null)
                {
                    List<ORequestForQuotationVendorItem> rfqVendorItems = rfqVendor.RequestForQuotationVendorItems.FindAll((r) => r.ItemNumber > rfqVendorItem.ItemNumber);
                    foreach (ORequestForQuotationVendorItem vendorItem in rfqVendorItems)
                        vendorItem.ItemNumber = vendorItem.ItemNumber - 1;
                    rfqVendor.RequestForQuotationVendorItems.RemoveObject(rfqVendorItem);
                }
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public string ValidateBudgetAmountEqualsLineItemAmount()
        {
            // If the budget validation is not required, return -1
            // immediately to indicate the validation succeeded.
            //
            if (this.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired)
                return null;

            if (this.IsGroupWJ == 1 && BudgetDistributionMode == BudgetDistribution.EntireAmount)
            {
                Hashtable totalLineItemAmounts = new Hashtable();
                foreach (OLocation ol in this.GroupWJLocations)
                {
                    totalLineItemAmounts[ol.ObjectID] = 0M;
                }
                Hashtable totalBudgetAmounts = new Hashtable();

                foreach (OLocation olo in this.GroupWJLocations)
                {
                    totalBudgetAmounts[olo.ObjectID] = 0M;
                }
                foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
                {
                    if (rfqitem.ReceiptMode.Value == 1)
                    {
                        decimal? total = 0M;
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            total += rfqil.AmountRatio;
                        }
                        if (total.Value == 0)
                            total = 1;
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqil.LocationID] = Math.Round((((decimal)totalLineItemAmounts[rfqil.LocationID]) + IsNull(rfqitem.UnitPrice, 0) * rfqil.AmountRatio.Value / total.Value), 2, MidpointRounding.AwayFromZero);
                        }
                    }
                    else if (rfqitem.ReceiptMode.Value == 0)
                    {
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            // 2011.03.07
                            // Kim Foong
                            // Fixed so that null values are treated as 0.
                            //totalLineItemAmounts[rfqil.LocationID] = (decimal)totalLineItemAmounts[rfqil.LocationID] + rfqitem.UnitPrice.Value * rfqil.QuantityRequired.Value;
                            totalLineItemAmounts[rfqil.LocationID] = (decimal)totalLineItemAmounts[rfqil.LocationID] + IsNull(rfqitem.UnitPrice, 0) * IsNull(rfqil.QuantityRequired, 0);
                        }
                    }
                }
                foreach (OPurchaseBudget pb in this.PurchaseBudgets)
                {
                    totalBudgetAmounts[pb.LocationID] = (decimal)totalBudgetAmounts[pb.LocationID] + pb.Amount.Value;
                }
                string same = null;
                int PbCount = 0;
                foreach (OPurchaseBudget pbt in this.PurchaseBudgets)
                {
                    //        OPurchaseSettings purchaseSettings =
                    //OPurchaseSettings.GetPurchaseSettings(Location, PurchaseType, BudgetGroupID);
                    if ((decimal)totalLineItemAmounts[pbt.LocationID] != (decimal)totalBudgetAmounts[pbt.LocationID] && BudgetValidationPolicy == 0 ||
                        (decimal)totalLineItemAmounts[pbt.LocationID] < (decimal)totalBudgetAmounts[pbt.LocationID] && BudgetValidationPolicy < 2
                        )
                    {
                        same = string.Format(LogicLayer.Resources.Strings.RequestForQuotation_EntireNotMatch, pbt.Budget.ObjectName);
                        return same;
                    }
                    PbCount++;
                }
                //if (PbCount != totalLineItemAmounts.Count)
                //    same = "account";
                return same;
            }
            else if (IsGroupWJ == 1 && BudgetDistributionMode == BudgetDistribution.LineItem)
            {
                Hashtable totalLineItemAmounts = new Hashtable();
                foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
                {
                    foreach (OLocation ol in GroupWJLocations)
                    {
                        totalLineItemAmounts[ol.ObjectID + ":" + rfqitem.ItemNumber] = 0M;
                    }
                }
                Hashtable totalBudgetAmounts = new Hashtable();
                foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
                {
                    foreach (OLocation ol in GroupWJLocations)
                    {
                        totalBudgetAmounts[ol.ObjectID + ":" + rfqitem.ItemNumber] = 0M;
                    }
                }
                foreach (ORequestForQuotationItem rfqitm in this.RequestForQuotationItems)
                {
                    if (rfqitm.ReceiptMode.Value == 1)
                    {
                        decimal? total = 0M;
                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqitm.RequestForQuotationItemLocation)
                        {
                            total += rfqiLocation.AmountRatio.Value;
                        }
                        if (total == 0)
                            total = 1;
                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqitm.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitm.ItemNumber] = Math.Round(((decimal)totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitm.ItemNumber] + IsNull(rfqitm.UnitPrice, 0) * rfqiLocation.AmountRatio.Value / total.Value), 2, MidpointRounding.AwayFromZero);
                        }
                    }
                    else if (rfqitm.ReceiptMode.Value == 0)
                    {
                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqitm.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitm.ItemNumber] = (decimal)totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitm.ItemNumber] + rfqitm.UnitPrice.Value * rfqiLocation.QuantityRequired.Value;
                        }
                    }
                }

                foreach (OPurchaseBudget pb in PurchaseBudgets)
                {
                    totalBudgetAmounts[pb.LocationID + ":" + pb.ItemNumber] = (decimal)totalBudgetAmounts[pb.LocationID + ":" + pb.ItemNumber] + pb.Amount.Value;
                }
                string same = null;
                int Pbaccount = 0;
                foreach (OPurchaseBudget pbt in this.PurchaseBudgets)
                {
                    //        OPurchaseSettings purchaseSettings =
                    //OPurchaseSettings.GetPurchaseSettings(TablesLogic.tLocation.Load(pbt.LocationID), pbt.PurchaseRequest.PurchaseType);

                    if ((decimal)totalLineItemAmounts[pbt.LocationID + ":" + pbt.ItemNumber] != (decimal)totalBudgetAmounts[pbt.LocationID + ":" + pbt.ItemNumber] && BudgetValidationPolicy == 0 ||
                        (decimal)totalLineItemAmounts[pbt.LocationID + ":" + pbt.ItemNumber] < (decimal)totalBudgetAmounts[pbt.LocationID + ":" + pbt.ItemNumber] && BudgetValidationPolicy < 2
                        )
                    {
                        same = string.Format(LogicLayer.Resources.Strings.RequestForQuotation_LineNotMatch, pbt.ItemNumber + "(" + pbt.Budget.ObjectName + ")");
                        return same;
                    }
                    Pbaccount++;
                }
                if (Pbaccount != totalLineItemAmounts.Count)
                    same = "account";
                return same;
            }

            if (this.BudgetDistributionMode != null)
            {
                // Find out the total amount by line items
                // or the entire WJ.
                //
                int maxItemNumber = 0;
                Hashtable totalLineItemAmounts = new Hashtable();
                foreach (ORequestForQuotationItem item in this.RequestForQuotationItems)
                {
                    int itemNumber = 0;
                    if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
                        itemNumber = item.ItemNumber.Value;

                    if (itemNumber > maxItemNumber)
                        maxItemNumber = itemNumber;
                    if (totalLineItemAmounts[itemNumber] == null)
                        totalLineItemAmounts[itemNumber] = 0M;

                    if (item.Subtotal != null)
                    {
                        // 2011.07.10, Kien Trung
                        // Modified to take in Recoverable amount
                        //
                        if (this.IsRecoverable == (int)EnumRecoverable.Recoverable)
                        {
                            totalLineItemAmounts[itemNumber] =
                                (decimal)totalLineItemAmounts[itemNumber] + item.Subtotal.Value - item.RecoverableAmount;
                        }
                        else
                        {
                            totalLineItemAmounts[itemNumber] =
                                (decimal)totalLineItemAmounts[itemNumber] + item.Subtotal.Value;
                        }
                    }
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
                    if (this.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems &&
                        totalLineItemAmount != totalBudgetAmount)
                    {
                        // 2011.03.07
                        // Kim Foong
                        // Added a new string to return a text representin
                        // the whole RFQ instead of the item number
                        //
                        if (i == 0)
                            return LogicLayer.Resources.Strings.RequestForQuotation_RFQ;
                        return string.Format(LogicLayer.Resources.Strings.RequestForQuotation_LineNotMatch, i.ToString());
                    }

                    if (this.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems &&
                        totalLineItemAmount < totalBudgetAmount)
                    {
                        // 2011.03.07
                        // Kim Foong
                        // Added a new string to return a text representin
                        // the whole RFQ instead of the item number
                        //
                        if (i == 0)
                            return LogicLayer.Resources.Strings.RequestForQuotation_RFQ;
                        return string.Format(LogicLayer.Resources.Strings.RequestForQuotation_LineNotMatch, i.ToString());
                    }
                }
                return null;
            }
            return null;
        }

        /// <summary>
        ///
        /// </summary>
        public void CreateChildRFQs()
        {
            if (this.IsGroupWJ == 1 && this.IsSubmittedForApproval != 1)
                ORequestForQuotation.CreateRFQFromGroupRFQ(this);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="rfq"></param>
        /// <returns></returns>
        public static List<ORequestForQuotation> CreateRFQFromGroupRFQ(ORequestForQuotation rfq)
        {
            List<ORequestForQuotation> newRfqList = new List<ORequestForQuotation>();
            foreach (OLocation loc in rfq.GroupWJLocations)
            {
                ORequestForQuotation newRfq = TablesLogic.tRequestForQuotation.Create();
                newRfq.ShallowCopy(rfq);
                newRfq.IsGroupWJ = 0;
                newRfq.IsGroupApproval = 0;
                newRfq.IsSubmittedForApproval = 0;
                newRfq.ObjectNumber = null;
                newRfq.LocationID = loc.ObjectID;
                newRfq.CampaignID = rfq.CampaignID;
                newRfq.GroupRequestForQuotationID = rfq.ObjectID;
                //Nguyen Quoc Phuong 17-Dec-2012
                newRfq.CRVSerialNumber = rfq.CRVSerialNumber;
                newRfq.CRVProjectTitle = rfq.CRVProjectTitle;
                newRfq.CRVProjectReferenceNo = rfq.CRVProjectReferenceNo;
                newRfq.CRVProjectDescription = rfq.CRVProjectDescription;
                //End Nguyen Quoc Phuong 17-Dec-2012

                foreach (ORequestForQuotationItem rfqItem in rfq.RequestForQuotationItems)
                {
                    ORequestForQuotationItem newRfqItem = TablesLogic.tRequestForQuotationItem.Create();
                    newRfqItem.ShallowCopy(rfqItem);

                    if (rfqItem.ReceiptMode == ReceiptModeType.Quantity)
                    {
                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqItem.RequestForQuotationItemLocation)
                        {
                            if (rfqiLocation.LocationID == loc.ObjectID)
                            {
                                newRfqItem.QuantityRequired = rfqiLocation.QuantityRequired;
                                newRfqItem.QuantityProvided = rfqiLocation.QuantityRequired;
                            }
                        }
                    }
                    else
                    {
                        // FIX: 2011.06.03, Kim Foong, Fixed computation of amount if receipt mode = Dollar
                        decimal totalRatio = 0;
                        rfqItem.RequestForQuotationItemLocation.Sort("LocationID", true);
                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqItem.RequestForQuotationItemLocation)
                            if (rfqiLocation.AmountRatio != null)
                                totalRatio += rfqiLocation.AmountRatio.Value;

                        decimal totalUnitPrice = 0;
                        decimal totalUnitPriceInSelectedCurrency = 0;
                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqItem.RequestForQuotationItemLocation)
                        {
                            if (rfqiLocation.LocationID == loc.ObjectID)
                            {
                                if (rfqiLocation != rfqItem.RequestForQuotationItemLocation[rfqItem.RequestForQuotationItemLocation.Count - 1])
                                {
                                    newRfqItem.UnitPriceInSelectedCurrency = Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqItem.UnitPriceInSelectedCurrency);
                                    newRfqItem.UnitPrice = Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqItem.UnitPrice);
                                }
                                else
                                {
                                    newRfqItem.UnitPriceInSelectedCurrency = newRfqItem.UnitPriceInSelectedCurrency - totalUnitPriceInSelectedCurrency;
                                    newRfqItem.UnitPrice = newRfqItem.UnitPrice - totalUnitPrice;
                                }
                            }
                            totalUnitPriceInSelectedCurrency += Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqItem.UnitPriceInSelectedCurrency.Value);
                            totalUnitPrice += Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqItem.UnitPrice.Value);
                        }
                    }
                    newRfq.RequestForQuotationItems.Add(newRfqItem);
                }

                foreach (ORequestForQuotationVendor rfqVendor in rfq.RequestForQuotationVendors)
                {
                    ORequestForQuotationVendor newRfqVendor = TablesLogic.tRequestForQuotationVendor.Create();
                    newRfqVendor.ShallowCopy(rfqVendor);
                    foreach (ORequestForQuotationVendorItem rfqvItem in rfqVendor.RequestForQuotationVendorItems)
                    {
                        ORequestForQuotationVendorItem newRfqVItem = TablesLogic.tRequestForQuotationVendorItem.Create();
                        newRfqVItem.ShallowCopy(rfqvItem);

                        // 2011.08.09, Kien Trung
                        // FIX: to remove link to parent rfq items.
                        // and re-link rfq item ID to child WJ Items
                        //
                        newRfqVItem.RequestForQuotationItemID =
                            newRfq.RequestForQuotationItems.Find((i) => i.ItemNumber == newRfqVItem.ItemNumber && i.ItemDescription == newRfqVItem.ItemDescription).ObjectID;

                        if (rfqvItem.RequestForQuotationItem.ReceiptMode == ReceiptModeType.Quantity)
                        {
                            foreach (ORequestForQuotationItemLocation rfqiLocation in rfqvItem.RequestForQuotationItem.RequestForQuotationItemLocation)
                            {
                                if (rfqiLocation.LocationID == loc.ObjectID)
                                    newRfqVItem.QuantityProvided = rfqiLocation.QuantityRequired;
                            }
                        }
                        else if (rfqvItem.RequestForQuotationItem.ReceiptMode == ReceiptModeType.Dollar)
                        {
                            // FIX: 2011.06.03, Kim Foong, Fixed computation of amount if receipt mode = Dollar
                            decimal totalRatio = 0;
                            rfqvItem.RequestForQuotationItem.RequestForQuotationItemLocation.Sort("LocationID", true);
                            foreach (ORequestForQuotationItemLocation rfqiLocation in rfqvItem.RequestForQuotationItem.RequestForQuotationItemLocation)
                                if (rfqiLocation.AmountRatio != null)
                                    totalRatio += rfqiLocation.AmountRatio.Value;

                            decimal totalUnitPrice = 0;
                            decimal totalUnitPriceInSelectedCurrency = 0;
                            foreach (ORequestForQuotationItemLocation rfqiLocation in rfqvItem.RequestForQuotationItem.RequestForQuotationItemLocation)
                            {
                                if (rfqiLocation.LocationID == loc.ObjectID)
                                {
                                    if (rfqiLocation != rfqvItem.RequestForQuotationItem.RequestForQuotationItemLocation[rfqvItem.RequestForQuotationItem.RequestForQuotationItemLocation.Count - 1])
                                    {
                                        newRfqVItem.UnitPriceInSelectedCurrency = Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqVItem.UnitPriceInSelectedCurrency);
                                        newRfqVItem.UnitPrice = Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqVItem.UnitPrice);
                                    }
                                    else
                                    {
                                        newRfqVItem.UnitPriceInSelectedCurrency = newRfqVItem.UnitPriceInSelectedCurrency - totalUnitPriceInSelectedCurrency;
                                        newRfqVItem.UnitPrice = newRfqVItem.UnitPrice - totalUnitPrice;
                                    }
                                }
                                totalUnitPriceInSelectedCurrency += Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqVItem.UnitPriceInSelectedCurrency.Value);
                                totalUnitPrice += Round(rfqiLocation.AmountRatio.Value / totalRatio * newRfqVItem.UnitPrice.Value);
                            }
                        }
                        newRfqVendor.RequestForQuotationVendorItems.Add(newRfqVItem);
                    }

                    // copy attachment
                    //
                    newRfqVendor.Attachments.Clear();
                    foreach (OAttachment oa in rfqVendor.Attachments)
                    {
                        OAttachment newAttachment = TablesLogic.tAttachment.Create();
                        newAttachment.ShallowCopy(oa);
                        newRfqVendor.Attachments.Add(newAttachment);
                    }
                    newRfq.RequestForQuotationVendors.Add(newRfqVendor);
                }
                foreach (OPurchaseBudget pb in rfq.PurchaseBudgets)
                {
                    if (pb.LocationID == loc.ObjectID)
                    {
                        OPurchaseBudget newPb = TablesLogic.tPurchaseBudget.Create();
                        newPb.ShallowCopy(pb);

                        if (rfq.IsApproved == 1)
                            newPb.TransferFromPurchaseBudgetID = pb.ObjectID;
                        newRfq.PurchaseBudgets.Add(newPb);
                    }
                }
                if (newRfq != null)
                {
                    using (Connection c = new Connection())
                    {
                        newRfq.Save();
                        c.Commit();
                    }
                }
                newRfqList.Add(newRfq);
            }

            if (rfq.IsApproved == 1)
            {
                foreach (ORequestForQuotation nRfq in newRfqList)
                {
                    nRfq.SubmitForApprovalForCapitaland();
                    nRfq.TriggerWorkflowEvent("Award");
                }
            }
            else
            {
                foreach (ORequestForQuotation nRfq in newRfqList)
                    nRfq.TriggerWorkflowEvent("SaveAsDraft");
            }
            return newRfqList;
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public string ValidateReallocationAcrossGroups()
        {
            Hashtable reallocationFromAmount = new Hashtable();
            Hashtable reallocationToAmount = new Hashtable();

            List<Guid?> IDs = new List<Guid?>();
            for (int i = 0; i < this.RFQBudgetReallocationFromPeriods.Count; i++)
                for (int j = 0; j < RFQBudgetReallocationFromPeriods[i].RFQBudgetReallocationFroms.Count; j++)
                    IDs.Add(this.RFQBudgetReallocationFromPeriods[i].RFQBudgetReallocationFroms[j].AccountID);

            for (int i = 0; i < this.RFQBudgetReallocationToPeriods.Count; i++)
                for (int j = 0; j < RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos.Count; j++)
                    IDs.Add(this.RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos[j].AccountID);

            Hashtable groupNames = LogicLayer.OAccount.GetInheritedGroupNames(IDs);
            for (int i = 0; i < this.RFQBudgetReallocationFromPeriods.Count; i++)
            {
                for (int j = 0; j < RFQBudgetReallocationFromPeriods[i].RFQBudgetReallocationFroms.Count; j++)
                {
                    string groupName = groupNames[RFQBudgetReallocationFromPeriods[i].RFQBudgetReallocationFroms[j].AccountID].ToString();
                    reallocationFromAmount[RFQBudgetReallocationFromPeriods[i].FromBudgetPeriodID + ":" + groupName] = 0m;
                }
            }

            for (int i = 0; i < this.RFQBudgetReallocationToPeriods.Count; i++)
            {
                for (int j = 0; j < RFQBudgetReallocationFromPeriods[i].RFQBudgetReallocationFroms.Count; j++)
                {
                    string groupName = groupNames[RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos[j].AccountID].ToString();
                    reallocationFromAmount[RFQBudgetReallocationFromPeriods[i].FromBudgetPeriodID + ":" + groupName] =
                        (decimal?)reallocationFromAmount[RFQBudgetReallocationFromPeriods[i].FromBudgetPeriodID + ":" + groupName] +
                            RFQBudgetReallocationFromPeriods[i].RFQBudgetReallocationFroms[j].TotalAmount;
                }
            }
            for (int i = 0; i < this.RFQBudgetReallocationToPeriods.Count; i++)
            {
                for (int j = 0; j < RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos.Count; j++)
                {
                    string groupName = groupNames[RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos[j].AccountID].ToString();
                    reallocationToAmount[RFQBudgetReallocationToPeriods[i].ToBudgetPeriodID + ":" + groupName] = 0m;
                }
            }
            for (int i = 0; i < this.RFQBudgetReallocationToPeriods.Count; i++)
            {
                for (int j = 0; j < RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos.Count; j++)
                {
                    string groupName = groupNames[RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos[j].AccountID].ToString();
                    reallocationToAmount[RFQBudgetReallocationToPeriods[i].ToBudgetPeriodID + ":" + groupName] =
                        (decimal?)reallocationToAmount[RFQBudgetReallocationToPeriods[i].ToBudgetPeriodID + ":" + groupName] +
                        RFQBudgetReallocationToPeriods[i].RFQBudgetReallocationTos[j].TotalAmount;
                }
            }
            List<Guid?> periodIDs = new List<Guid?>();
            for (int i = 0; i < this.RFQBudgetReallocationFromPeriods.Count; i++)
                periodIDs.Add(RFQBudgetReallocationFromPeriods[i].FromBudgetPeriodID);
            for (int i = 0; i < this.RFQBudgetReallocationToPeriods.Count; i++)
                periodIDs.Add(RFQBudgetReallocationToPeriods[i].ToBudgetPeriodID);
            foreach (Guid? id in IDs)
            {
                foreach (Guid? periodID in periodIDs)
                {
                    if (groupNames[id] != null)
                    {
                        if (reallocationFromAmount[periodID + ":" + groupNames[id]] != null)
                        {
                            if (reallocationToAmount[periodID + ":" + groupNames[id]] == null)
                                return string.Format(Resources.Errors.BudgetReallocation_budgetToLess, groupNames[id]);
                            else
                                if ((decimal?)reallocationFromAmount[periodID + ":" + groupNames[id]] != (decimal?)reallocationToAmount[periodID + ":" + groupNames[id]])
                                    return string.Format(Resources.Errors.BudgetReallocation_budgetFromNotMatchTo, groupNames[id]);
                        }
                        else
                        {
                            if (reallocationToAmount[periodID + ":" + groupNames[id]] != null)
                                return string.Format(Resources.Errors.BudgetReallocation_budgetFromLess, groupNames[id]);
                        }
                    }
                }
            }
            return "";
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="val"></param>
        /// <param name="defaultValue"></param>
        /// <returns></returns>
        public decimal IsNull(decimal? val, decimal defaultValue)
        {
            if (val == null)
                return defaultValue;
            else
                return val.Value;

            // What is this for?
            //
            //this.RequestForQuotationItems.Find(p => p.ItemNumber == 1);
        }
    }

    /// <summary>
    ///
    /// </summary>
    public class QuotationReceived
    {
        public int Number;
        public string Contractor;
        public string IPTVendor;
        public string QuotationReference;
        public string PercentageAboveMinimumQuoteText;
        public decimal? QuotationAmount;
    }

    /// <summary>
    ///
    /// </summary>
    public class BudgetSummary
    {
        public string Budget;
        public string BudgetPeriod;
        public string AccountName;
        public string AccountCode;
        public string TotalAvailableAdjusted;
        public string TotalAvailableBeforeSubmission;
        public string TotalAvailableAtSubmission;
        public string TotalAvailableAfterApproval;
    }
}