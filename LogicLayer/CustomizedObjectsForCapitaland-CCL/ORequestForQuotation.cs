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
using System.Text;
using System.Linq;

using Anacle.DataFramework;

namespace LogicLayer
{

    public partial class TRequestForQuotation : LogicLayerSchema<ORequestForQuotation>
    {
        [Default(0)]
        public SchemaInt IsCharged;

        [Default(0)]
        public SchemaInt IsRecoverable;

        public SchemaString RequestorCellPhone;
        public SchemaString RequestorFax;
        public SchemaString RequestorEmail;
        public SchemaString RequestorPhone;

        public SchemaGuid TenantID;

        public SchemaGuid TenantLeaseID;

        public TTenantLease TenantLease { get { return OneToOne<TTenantLease>("TenantLeaseID"); } }

        public SchemaGuid TenantContactID;

        public SchemaGuid WorkID;

        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }

        //20120209 ptb
        public SchemaGuid BillToID;
        public SchemaGuid BillToContactPersonID;
        public SchemaGuid DeliveryToID;
        public SchemaGuid DeliverToContactPersonID;

        public TCapitalandCompany BillTo { get { return OneToOne<TCapitalandCompany>("BillToID"); } }
        public TUser BillToContactPerson { get { return OneToOne<TUser>("BillToContactPersonID"); } }
        public TCapitalandCompany DeliveryTo { get { return OneToOne<TCapitalandCompany>("DeliveryToToID"); } }
        public TUser DeliverToContactPerson { get { return OneToOne<TUser>("DeliverToContactPersonID"); } }

        public SchemaString DeliverToAddress;
        public SchemaString DeliverToPerson;
        [Default(0)]
        public SchemaInt IsDeliverToOther;

        public SchemaGuid SubmitterID;
        public TUser Submitter { get { return OneToOne<TUser>("SubmitterID"); } }

        //20120221 ptb
        //supporters
        public TSupporter Supporters { get { return OneToMany<TSupporter>("RFQID"); } }

        //Nguyen Quoc Phuong 20-Nov-2012
        public SchemaString CRVSerialNumber;
        public SchemaString CRVProjectReferenceNo;
        public SchemaString CRVProjectTitle;
        public SchemaString CRVProjectDescription;
        [Default((int)EnumCRVTenderRFQSyncError.SUCCEED)]
        public SchemaInt CRVSyncError;
        [Default(0)]
        public SchemaInt CRVSyncErrorNoOfTries;
        //End Nguyen Quoc Phuong 20-Nov-2012


    }


    /// <summary>
    /// Represents a request for quotation that can be used to gather
    /// quotations from vendors.
    /// </summary>

    public abstract partial class ORequestForQuotation : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled, ICloneable
    {
        /// <summary>
        /// 
        /// </summary>
        public abstract int? IsCharged { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? WorkID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract int? IsRecoverable { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract string RequestorCellPhone { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract string RequestorFax { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract string RequestorEmail { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract string RequestorPhone { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? TenantID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? TenantLeaseID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract OTenantLease TenantLease { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? TenantContactID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract OWork Work { get; set; }

        //20120209 ptb
        public abstract Guid? BillToID { get; set; }
        public abstract Guid? BillToContactPersonID { get; set; }
        public abstract OCapitalandCompany BillTo { get; }
        public abstract OUser BillToContactPerson { get; set; }

        public abstract Guid? DeliveryToID { get; set; }
        public abstract Guid? DeliverToContactPersonID { get; set; }
        public abstract OCapitalandCompany DeliveryTo { get; }
        public abstract OUser DeliverToContactPerson { get; set; }

        public abstract string DeliverToAddress { get; set; }
        public abstract string DeliverToPerson { get; set; }
        public abstract int? IsDeliverToOther { get; set; }

        public abstract Guid? SubmitterID { get; set; }
        public abstract OUser Submitter { get; set; }

        //20120221 ptb
        //supporters
        public abstract DataList<OSupporter> Supporters { get; set; }

        //Nguyen Quoc Phuong 20-Nov-2012
        public abstract string CRVSerialNumber { get; set; }
        public abstract string CRVProjectReferenceNo { get; set; }
        public abstract string CRVProjectTitle { get; set; }
        public abstract string CRVProjectDescription { get; set; }
        public abstract int? CRVSyncError { get; set; }
        public abstract int? CRVSyncErrorNoOfTries { get; set; }
        //End Nguyen Quoc Phuong 20-Nov-2012



        public List<ORole> GetRolesToAssign()
        {
            return ORole.GetRolesByRoleCode("PURCHASEADMIN");
        }

        public bool ValidateRFQVendorAttachmentsUploaded()
        {
            if (this.RequestForQuotationVendors.Find((v) => v.IsSubmitted == 1 && v.Attachments.Count == 0) != null)
                return false;
            return true;
        }

        /// <summary>
        /// 
        /// </summary>
        public decimal? TotalChargeAmount
        {
            get
            {
                decimal? chargeAmount = 0M;
                foreach (ORequestForQuotationItem i in this.RequestForQuotationItems)
                    chargeAmount += i.ChargeAmount;
                return chargeAmount;
            }
        }

        /// <summary>
        /// Validates that the list of RFQ line item numbers and descriptions 
        /// that have not been generated into POs.
        /// </summary>
        /// <param name="purchaseRequestItemIds"></param>
        /// <returns></returns>
        public static DataTable ValidateRFQLineItemsNotGeneratedToPOforCCL(List<Guid> requestForQuotationItemIds)
        {
            StringBuilder sb = new StringBuilder();

            // Gets a list of all RFQ item numbers that have been generated
            // into POs.
            //
            // 2011.06.23
            // David
            // generate several po from one rfq item. 
            // 
            TPurchaseOrderItem poItem = TablesLogic.tPurchaseOrderItem;
            TPurchaseOrderItem poItemOrdered = new TPurchaseOrderItem();

            DataTable dt = poItem.SelectDistinct(
                poItem.RequestForQuotationItemID,
                poItem.RequestForQuotationItem.ItemNumber,
                poItem.RequestForQuotationItem.ItemDescription)
                .Where(
                poItem.PurchaseOrder.CurrentActivity.ObjectName != "Cancelled" &
                poItem.RequestForQuotationItemID.In(requestForQuotationItemIds) &
                (poItem.RequestForQuotationItem.QuantityProvided -
                (poItemOrdered.Select(poItemOrdered.QuantityOrdered.Sum())
                .Where
                (poItemOrdered.RequestForQuotationItemID == poItem.RequestForQuotationItemID &
                poItemOrdered.PurchaseOrder.CurrentActivity.ObjectName != "Cancelled" &
                poItemOrdered.PurchaseOrder.IsDeleted == 0)) == 0) &
                poItem.IsDeleted == 0);

            return dt;
        }

        // 2011.08.07
        // Should not be necessary anymore.
        //
        public static DataTable ListRecoverableType(bool IsGenerateFromWorkOrRFQ)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Text");
            dt.Columns.Add("Value", typeof(int));
            dt.Rows.Add(new object[] { "Non recoverable", 0 });
            if (IsGenerateFromWorkOrRFQ)
                dt.Rows.Add(new object[] { "Recoverable from Tenant", 1 });
            dt.Rows.Add(new object[] { "Recoverable from Third Party", 2 });
            return dt;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="w"></param>
        /// <param name="rfqType"></param>
        /// <returns></returns>
        public static ORequestForQuotation CreateRFQFromWork(OWork w, int rfqType)
        {
            using (Connection c = new Connection())
            {
                ORequestForQuotation rfq = TablesLogic.tRequestForQuotation.Create();

                rfq.LocationID = OLocation.GetLocationByTypeAndBelowOrAboveLocation(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, w.Location, null)[0].ObjectID;
                rfq.EquipmentID = w.EquipmentID;
                rfq.Description = w.WorkDescription;
                rfq.IsGroupWJ = 0;
                // By Default, Set this WJ generated from Work Order is recoverable.
                //
                rfq.IsRecoverable = (int)EnumRecoverable.Recoverable;

                // NOTED: RequestorID & RequestorName in ORequestForQuotaiton are different from OWork.
                // to copy RequestorID from OWork use TenantID instead.
                //
                if (Workflow.CurrentUser != null)
                {
                    rfq.RequestorName = Workflow.CurrentUser.ObjectName;
                    rfq.RequestorID = Workflow.CurrentUser.ObjectID;
                }
                // Budget Group
                //
                List<OBudgetGroup> groups = Workflow.CurrentUser.GetAllAccessibleBudgetGroup("ORequestForQuotation", rfq.BudgetGroupID);
                if (groups != null && groups.Count == 1)
                    rfq.BudgetGroupID = groups[0].ObjectID;

                OApplicationSetting applicationSetting = OApplicationSetting.Current;
                DateTime today = DateTime.Today;
                switch (applicationSetting.DefaultRequiredUnit)
                {
                    case (int)EnumRequestForQuotationDefaultDateUnit.Day:
                        rfq.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value);
                        break;
                    case (int)EnumRequestForQuotationDefaultDateUnit.Week:
                        rfq.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value * 7);
                        break;
                    case (int)EnumRequestForQuotationDefaultDateUnit.Month:
                        rfq.DateRequired = today.AddMonths(applicationSetting.DefaultRequiredCount.Value);
                        break;
                    case (int)EnumRequestForQuotationDefaultDateUnit.Year:
                        rfq.DateRequired = today.AddYears(applicationSetting.DefaultRequiredCount.Value);
                        break;
                }
                switch (applicationSetting.DefaultEndUnit)
                {
                    case (int)EnumRequestForQuotationDefaultDateUnit.Day:
                        rfq.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value);
                        break;
                    case (int)EnumRequestForQuotationDefaultDateUnit.Week:
                        rfq.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value * 7);
                        break;
                    case (int)EnumRequestForQuotationDefaultDateUnit.Month:
                        rfq.DateEnd = today.AddMonths(applicationSetting.DefaultEndCount.Value);
                        break;
                    case (int)EnumRequestForQuotationDefaultDateUnit.Year:
                        rfq.DateEnd = today.AddYears(applicationSetting.DefaultEndCount.Value);
                        break;
                }

                // Work Information
                //
                rfq.WorkID = w.ObjectID;
                rfq.TenantID = w.RequestorID;
                rfq.TenantLeaseID = w.TenantLeaseID;
                rfq.IsCharged = w.IsChargedToCaller;
                rfq.TenantContactID = w.TenantContactID;
                rfq.RequestorEmail = w.RequestorEmail;
                rfq.RequestorCellPhone = w.RequestorCellPhone;

                // Save and trigger the wj as draft.
                //
                rfq.Save();
                rfq.TriggerWorkflowEvent("SaveAsDraft");
                c.Commit();

                return rfq;
            }
        }

        public string ValidateSufficientNumberOfQuotationsRequired()
        {
            if (this.ValidateSufficientNumberOfQuotations() == -1)
                return String.Format(Resources.Strings.RequestForQuotation_MinimumQuotationsPreferred, this.MinimumNumberOfQuotations);
            else if (this.ValidateSufficientNumberOfQuotations() == 0)
                return String.Format(Resources.Strings.RequestForQuotation_MinimumQuotationsRequired, this.MinimumNumberOfQuotations);
            else
                return "";
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="workCosts"></param>
        /// <returns></returns>
        public static ORequestForQuotation CreateRFQFromWorkCosts(List<OWorkCost> workCosts)
        {
            using (Connection c = new Connection())
            {
                if (workCosts.Count == 0)
                    return null;

                workCosts.Sort("CreatedDateTime ASC");

                OWork w = workCosts[0].Work;
                ORequestForQuotation rfq = TablesLogic.tRequestForQuotation.Create();
                rfq.CaseID = w.CaseID;
                rfq.LocationID = w.LocationID;
                rfq.EquipmentID = w.EquipmentID;
                rfq.Description = w.WorkDescription;
                rfq.DateRequired = w.ScheduledStartDateTime;
                rfq.DateEnd = w.ScheduledEndDateTime;
                rfq.IsRecoverable = 1;//recoverable from tenant
                int itemnumber = 0;
                foreach (OWorkCost workcost in workCosts)
                {
                    ORequestForQuotationItem item = TablesLogic.tRequestForQuotationItem.Create();
                    item.ItemNumber = itemnumber++;
                    if (workcost.CostType == 0 || workcost.CostType == 2)//technician/craft or other
                        item.ItemType = 2;
                    else if (workcost.CostType == 3)//inventory
                        item.ItemType = 0;
                    else if (workcost.CostType == 1)//fixed rate
                        item.ItemType = 1;
                    item.QuantityRequired = workcost.EstimatedQuantity;
                    item.ItemDescription = workcost.ObjectName;
                    item.CatalogueID = workcost.CatalogueID;
                    item.FixedRateID = workcost.FixedRateID;
                    item.UnitOfMeasureID = workcost.UnitOfMeasureID;
                    item.ChargeAmount = workcost.ChargeOut;
                    item.WorkCostID = workcost.ObjectID;
                    rfq.RequestForQuotationItems.Add(item);
                    item.Save();
                }
                rfq.Save();
                rfq.TriggerWorkflowEvent("SaveAsDraft");

                c.Commit();

                return rfq;
            }
        }

        /// <summary>
        /// Lists the of supporters.
        /// </summary>
        /// <returns></returns>
        public List<OUser> ListOfSupporters()
        {
            List<OUser> lst = new List<OUser>();
            if (Supporters.Count > 0)
            {
                foreach (OSupporter item in this.Supporters)
                    if (item.IsApproved == 0)
                        lst.Add(item.Supporter);
            }

            return lst;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="messageTemplateCode"></param>
        /// <param name="triggeringEventName"></param>
        public void SendEmailToSupporters(string messageTemplateCode, EnumSupportStatus supportStatus)
        {
            if (this.CurrentActivity != null)
            {
                OMessageTemplate messageTemplate = TablesLogic.tMessageTemplate.Load(
                                                  TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

                if (messageTemplate != null)
                {
                    ORequestForQuotation rfq = this;

                    string emailRecipients = "";
                    string emailCCRecipients = "";

                    if (supportStatus == EnumSupportStatus.Pending)
                    {
                        if (rfq.ListOfSupporters().Count == 0)
                            return;
                        else
                        {
                            // Email all supporters that they have a pending task to support
                            foreach (OUser supporter in rfq.ListOfSupporters())
                            {
                                emailRecipients += supporter.UserBase.Email + ";";
                            }
                        }
                    }
                    else
                    {
                        OSupporter supporter = rfq.Supporters.Find(lf => lf.IsApproved == (int)EnumSupportStatus.Rejected);
                        if (supporter == null)
                            return;
                        emailRecipients = rfq.Requestor.UserBase.Email;
                    }

                    // Generate and the send message to the users.
                    messageTemplate.GenerateAndSendMessage(this, emailRecipients, emailCCRecipients, "");
                }
            }
        }


        /// <summary>
        /// Determines whether this WJ is supported.
        /// </summary>
        /// <returns>
        ///   <c>true</c> if this WJ is supported; otherwise, <c>false</c>.
        /// </returns>
        public bool IsSupported()
        {
            if (Supporters.Count > 0)
            {
                foreach (OSupporter item in Supporters)
                    if (item.IsApproved == 0)
                        return false;
            }
            return true;
        }

        /// <summary>
        /// Workflow Policy: reset supporters status.
        /// </summary>
        public void ResetSupporters()
        {
            if (Supporters.Count > 0)
            {
                foreach (OSupporter item in Supporters)
                {
                    using (Connection c = new Connection())
                    {
                        item.IsApproved = 0;
                        item.Save();
                        c.Commit();
                    }
                }
            }
        }

        public void Reject_Supporter()
        {
            OSupporter suppoter = this.Supporters.Find(lf => lf.SupporterID == Workflow.CurrentUser.ObjectID);

            if (suppoter != null)
            {
                using (Connection c = new Connection())
                {
                    suppoter.IsApproved = 2;
                    suppoter.Save();
                    c.Commit();
                }
            }
        }

        /// <summary>
        /// Workflow Policy: Set isApproved to 1
        /// </summary>
        public void Approve_Supporter()
        {
            OSupporter suppoter = this.Supporters.Find(lf => lf.SupporterID == Workflow.CurrentUser.ObjectID);

            if (suppoter != null)
            {
                using (Connection c = new Connection())
                {
                    suppoter.IsApproved = 1;
                    suppoter.Save();
                    c.Commit();
                }
            }
        }

        public List<OUser> GetCreator()
        {
            return TablesLogic.tUser.LoadList(TablesLogic.tUser.ObjectID == this.CreatedUserID);
        }

        #region CRV interface methods
        //Nguyen Quoc Phuong 29-Nov-2012
        public string CRVTenderApproveRFQSync()
        {
            OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            string SystemCode = this.SystemCode;
            if (string.IsNullOrEmpty(SystemCode))
                return Resources.Errors.CRVTenderService_SystemCodeNotFound;
            int? ConfirmStatus = CRVTenderService.ConfirmCRVSerialUsage(
                SystemCode,
                this.CRVSerialNumber,
                true);
            if (ConfirmStatus == null) return Resources.Errors.CRVTenderService_ConnectionFail;
            if (ConfirmStatus != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
                return Resources.Errors.RequestForQuotation_UpdateCRVTenderVendorAwardStatusFail;
            //PTB: No need to update CRV, information will be updated when RFQ is approved
            //try
            //{
            //    CRVTenderService.CRVTender = CRVTenderService.GetFullTenderInfo(
            //                                    SystemCode,
            //                                    this.CRVSerialNumber);
            //    if (CRVTenderService.CRVTender == null) throw new Exception();

            //    List<string> AwardedCRVVendorIDs = new List<string>();
            //    foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
            //        if (rfqitem.AwardedVendor != null &&
            //            !string.IsNullOrEmpty(rfqitem.AwardedVendor.CRVVendorID) &&
            //            !rfqitem.AwardedVendor.CRVVendorID.Is(AwardedCRVVendorIDs.ToArray()))
            //            AwardedCRVVendorIDs.Add(rfqitem.AwardedVendor.CRVVendorID);

            //    for (int i = 0; i < CRVTenderService.CRVTender.CRVTenderVendors.Length; i++)
            //    {
            //        ORequestForQuotationVendor rfqvendor = this.RequestForQuotationVendors.Find(a => a.Vendor.CRVVendorID == CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID);
            //        if (CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID.Is(AwardedCRVVendorIDs.ToArray()))
            //        {
            //            //CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = string.Format("{0:dd/MM/yyyy}", rfqvendor.CRVAwardedDate(this).Value);
            //            CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.AWARDED;
            //        }
            //        else
            //        {
            //            CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = null;
            //            CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.NOT_AWARDED;
            //        }
            //        int? status = CRVTenderService.UpdateTenderVendorAwardStatus(
            //            SystemCode,
            //            this.CRVSerialNumber,
            //            CRVTenderService.CRVTender.CRVTenderVendors[i]);
            //        if (status != (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL) throw new Exception();
            //    }
            //}
            //catch
            //{
            //    int? ReleaseStatus = CRVTenderService.ConfirmCRVSerialUsage(
            //                            SystemCode,
            //                            this.CRVSerialNumber,
            //                            false);
            //    if (ReleaseStatus == null)
            //    {
            //        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUBMIT_FOR_APPROVE;
            //        this.CRVSyncErrorNoOfTries = 0;
            //        return Resources.Errors.CRVTenderService_ConnectionFail;
            //    }
            //    if (ReleaseStatus != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
            //    {
            //        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUBMIT_FOR_APPROVE;
            //        this.CRVSyncErrorNoOfTries = 0;
            //        return Resources.Errors.RequestForQuotation_UpdateCRVTenderVendorAwardStatusFail;
            //    }
            //    return Resources.Errors.RequestForQuotation_UpdateCRVTenderVendorAwardStatusFail;
            //}
            return string.Empty;
        }
        //End Nguyen Quoc Phuong 29-Nov-2012

        //Nguyen Quoc Phuong 11-Dec-2012
        public string CRVTenderApproveRFQFromRejectSync()
        {
            try
            {
                if(this.GroupRequestForQuotation == null) CRVTenderApproveRFQFromReject();
            }
            catch
            {
                this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUBMIT_FOR_APPROVE_REJECT;
                this.CRVSyncErrorNoOfTries = 0;
                return Resources.Errors.CRVTenderService_ConnectionFail;
            }
            return string.Empty;
        }
        //End Nguyen Quoc Phuong 11-Dec-2012

        //Nguyen Quoc Phuong 11-Dec-2012
        public void CRVTenderApproveRFQFromReject()
        {
            //PTB: No need to update CRV, information will be updated when RFQ is approved
            //OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            //string SystemCode = this.SystemCode;
            //if (string.IsNullOrEmpty(SystemCode))
            //    throw new Exception(Resources.Errors.CRVTenderService_SystemCodeNotFound);
            //CRVTenderService.CRVTender = CRVTenderService.GetFullTenderInfo(
            //                                SystemCode,
            //                                this.CRVSerialNumber);
            //if (CRVTenderService.CRVTender == null) throw new Exception();

            //List<string> AwardedCRVVendorIDs = new List<string>();
            //foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
            //    if (rfqitem.AwardedVendor != null &&
            //        !string.IsNullOrEmpty(rfqitem.AwardedVendor.CRVVendorID) &&
            //        !rfqitem.AwardedVendor.CRVVendorID.Is(AwardedCRVVendorIDs.ToArray()))
            //        AwardedCRVVendorIDs.Add(rfqitem.AwardedVendor.CRVVendorID);

            //for (int i = 0; i < CRVTenderService.CRVTender.CRVTenderVendors.Length; i++)
            //{
            //    ORequestForQuotationVendor rfqvendor = this.RequestForQuotationVendors.Find(a => a.Vendor.CRVVendorID == CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID);
            //    if (CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID.Is(AwardedCRVVendorIDs.ToArray()))
            //    {
            //        //CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = string.Format("{0:dd/MM/yyyy}", rfqvendor.CRVAwardedDate(this).Value);
            //        CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.AWARDED;
            //    }
            //    else
            //    {
            //        CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = null;
            //        CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.NOT_AWARDED;
            //    }
            //    int? status = CRVTenderService.UpdateTenderVendorAwardStatus(
            //        SystemCode,
            //        this.CRVSerialNumber,
            //        CRVTenderService.CRVTender.CRVTenderVendors[i]);
            //    if (status != (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL) throw new Exception();
            //}
        }
        //End Nguyen Quoc Phuong 11-Dec-2012

        //Nguyen Quoc Phuong 29-Nov-2012
        public string CRVTenderRejectRFQSync()
        {
            OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);

            string SystemCode = this.SystemCode;
            if (string.IsNullOrEmpty(SystemCode))
                return Resources.Errors.CRVTenderService_SystemCodeNotFound;
            

            //Commented out by: Nguyen Quoc Phuong 11-Dec-2012
            //Reason: When reject does not release CRV serial number
            //int? ReleaseStatus = CRVTenderService.ConfirmCRVSerialUsage(
            //    SystemCode,
            //    this.CRVSerialNumber,
            //    false);
            //if (ReleaseStatus == null)
            //{
            //    using (Connection c = new Connection())
            //    {
            //        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.REJECT_FOR_REWORK;
            //        this.CRVSyncErrorNoOfTries = 0;
            //        this.Save();
            //        c.Commit();
            //    }
            //    return Resources.Errors.CRVTenderService_ConnectionFail;
            //}
            //if (ReleaseStatus != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
            //{
            //    using (Connection c = new Connection())
            //    {
            //        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.REJECT_FOR_REWORK;
            //        this.CRVSyncErrorNoOfTries = 0;
            //        this.Save();
            //        c.Commit();
            //    }
            //    return Resources.Errors.RequestForQuotation_UpdateCRVTenderVendorAwardStatusFail;
            //}
            try
            {
                if (this.GroupRequestForQuotation == null)
                {
                    CRVTenderService.CRVTender = CRVTenderService.GetFullTenderInfo(
                                                    SystemCode,
                                                    this.CRVSerialNumber);
                    if (CRVTenderService.CRVTender == null) throw new Exception();

                    List<string> AwardedCRVVendorIDs = new List<string>();
                    List<Guid> rfqitemIds = new List<Guid>();
                    foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
                        rfqitemIds.Add(rfqitem.ObjectID.Value);
                    this.ClearAwardLineItems(rfqitemIds);

                    for (int i = 0; i < CRVTenderService.CRVTender.CRVTenderVendors.Length; i++)
                    {
                        CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = null;
                        CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.TENDERING;
                        //int? status = 
                        CRVTenderService.UpdateTenderVendorAwardStatus(
                        SystemCode,
                        this.CRVSerialNumber,
                        CRVTenderService.CRVTender.CRVTenderVendors[i]);
                        //if (status != (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL) throw new Exception();
                    }
                }
            }
            catch
            {
            }
            return string.Empty;
        }
        //End Nguyen Quoc Phuong 29-Nov-2012

        //Nguyen Quoc Phuong 30-Nov-2012
        public string CRVTenderAwardedRFQSync()
        {
            try
            {
                if (this.GroupRequestForQuotation == null)
                {
                    int? status = CRVTenderAwardedRFQ();
                    if (status != (int)EnumCRVUpdateGroupProcurementInfoStatus.SUCCESSFUL) throw new Exception();

                    int? updateCRVVendorStatus = this.CRVTenderAwardedRFQUpdateCRVVendor();
                    if (updateCRVVendorStatus != (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL) throw new Exception();
                }
            }
            catch (Exception ex)
            {
                this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.AWARD;
                this.CRVSyncErrorNoOfTries = 0;                    
                
                using (Connection c = new Connection())
                {
                    this.Save();
                    c.Commit();
                }
            }
            return string.Empty;
        }
        //End Nguyen Quoc Phuong 30-Nov-2012

        //Nguyen Quoc Phuong 30-Nov-2012
        public int? CRVTenderAwardedRFQ()
        {
            OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            string SystemCode = this.SystemCode;
            if (string.IsNullOrEmpty(SystemCode))
                return null;
            CRVTenderService.GroupProcurementInformation = CRVTenderService.GetGroupProcurementInfo(
                                                            SystemCode,
                                                            this.CRVSerialNumber);
            if (CRVTenderService.GroupProcurementInformation == null) return null;

            CRVTenderService.GroupProcurementInformation.ProjectRefNo = this.ObjectNumber;
            CRVTenderService.GroupProcurementInformation.ProjectDescription = this.Description;
            CRVTenderService.GroupProcurementInformation.ContractSum = this.TaskAmount;
            CRVTenderService.GroupProcurementInformation.Currency = OApplicationSetting.Current.BaseCurrency.ObjectName;
            return CRVTenderService.UpdateGroupProcurementInfo(
                                SystemCode,
                                this.CRVSerialNumber,
                                CRVTenderService.GroupProcurementInformation);
        }
        //End Nguyen Quoc Phuong 30-Nov-2012

        /// <summary>
        /// Update the CRV Vendor Awarded Date
        /// </summary>
        /// <returns></returns>
        public int? CRVTenderAwardedRFQUpdateCRVVendor()
        {
            OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            string SystemCode = this.SystemCode;
            if (string.IsNullOrEmpty(SystemCode))
                throw new Exception(Resources.Errors.CRVTenderService_SystemCodeNotFound);
            CRVTenderService.CRVTender = CRVTenderService.GetFullTenderInfo(
                                            SystemCode,
                                            this.CRVSerialNumber);
            if (CRVTenderService.CRVTender == null) throw new Exception();

            List<string> AwardedCRVVendorIDs = new List<string>();
            foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
                if (rfqitem.AwardedVendor != null &&
                    !string.IsNullOrEmpty(rfqitem.AwardedVendor.CRVVendorID) &&
                    !rfqitem.AwardedVendor.CRVVendorID.Is(AwardedCRVVendorIDs.ToArray()))
                    AwardedCRVVendorIDs.Add(rfqitem.AwardedVendor.CRVVendorID);
            
            for (int i = 0; i < CRVTenderService.CRVTender.CRVTenderVendors.Length; i++)
            {
                ORequestForQuotationVendor rfqvendor = this.RequestForQuotationVendors.Find(a => a.Vendor.CRVVendorID == CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID);
                if (CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID.Is(AwardedCRVVendorIDs.ToArray()))
                {
                    CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = string.Format("{0:dd/MM/yyyy}", this.LastApprovalDate);
                    CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.AWARDED;
                }
                else if (CRVTenderService.CRVTender.CRVTenderVendors[i].Status != (int)EnumCRVTenderAwardVendorStatus.WITHDRAWN)
                {
                    CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = null;
                    CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.NOT_AWARDED;
                }
                int? status = CRVTenderService.UpdateTenderVendorAwardStatus(
                    SystemCode,
                    this.CRVSerialNumber,
                    CRVTenderService.CRVTender.CRVTenderVendors[i]);

                if (status != (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL)
                    return status;
            }

            return (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL;
        }

        //Nguyen Quoc Phuong 29-Nov-2012
        public string CRVTenderCancelRFQSync()
        {
            //Commented out by: Nguyen Quoc Phuong 11-Dec-2012
            //Reason: When cancel, release CRV serial number
            //OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            //if (this.NumberOfPOGenerated == 0)
            //{
            //    try
            //    {
            //        List<OActivityHistory> ActivityHistories = this.ActivityHistories.FindAll(a => a.WorkflowInstanceID == this.CurrentActivity.WorkflowInstanceID);
            //        ActivityHistories.Sort("ModifiedDateTime DESC");
            //        int? status = CRVTenderService.CancelTender(SystemCode,
            //                                                    this.CRVSerialNumber,
            //                                                    ActivityHistories[0].TaskName);
            //        if (status != (int)EnumCRVCancelTender.SUCCESSFUL) throw new Exception();
            //    }
            //    catch (Exception ex)
            //    {
            //        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CANCEL;
            //        this.CRVSyncErrorNoOfTries = 0;
            //        using (Connection c = new Connection())
            //        {
            //            this.Save();
            //            c.Commit();
            //        }
            //    }
            //}
            //else
            //{
            //    try
            //    {
            //        int? status = CRVTenderService.CloseTender(SystemCode,
            //                                                    this.CRVSerialNumber);
            //        if (status != (int)EnumCRVCloseTender.SUCCESSFUL) throw new Exception();
            //    }
            //    catch (Exception ex)
            //    {
            //        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CLOSE;
            //        this.CRVSyncErrorNoOfTries = 0;
            //        using (Connection c = new Connection())
            //        {
            //            this.Save();
            //            c.Commit();
            //        }
            //    }
            //}
            if (this.GroupRequestForQuotation == null)
            {
                int? status = CRVTenderCancelRFQ();
                if (status != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
                {
                    using (Connection c = new Connection())
                    {
                        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CANCEL;
                        this.CRVSyncErrorNoOfTries = 0;
                        this.Save();
                        c.Commit();
                    }
                    return Resources.Errors.CRVTenderService_ConnectionFail;
                }
            }
            else
            {
                List<ORequestForQuotation> ChildsRFQ = TablesLogic.tRequestForQuotation.LoadList(TablesLogic.tRequestForQuotation.GroupRequestForQuotationID == this.GroupRequestForQuotationID);
                bool isAllCancelled = true;
                foreach (ORequestForQuotation ChildRFQ in ChildsRFQ)
                    if (!ChildRFQ.CurrentActivity.ObjectName.Is("Cancelled")) isAllCancelled = false;
                bool isAllCloseOrCancelled = true;
                foreach (ORequestForQuotation ChildRFQ in ChildsRFQ)
                    if (!ChildRFQ.CurrentActivity.ObjectName.Is("Cancelled", "Close")) isAllCloseOrCancelled = false;
                if (isAllCancelled)
                {
                    int? status = CRVTenderCancelRFQ();
                    if (status != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
                    {
                        using (Connection c = new Connection())
                        {
                            this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CANCEL;
                            this.CRVSyncErrorNoOfTries = 0;
                            this.Save();
                            c.Commit();
                        }
                        return Resources.Errors.CRVTenderService_ConnectionFail;
                    }
                }
                else if (isAllCloseOrCancelled)
                {
                    int? status = CRVTenderCloseRFQ();
                    if (status != (int)EnumCRVCloseTender.SUCCESSFUL)
                    {
                        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CLOSE;
                        this.CRVSyncErrorNoOfTries = 0;
                        using (Connection c = new Connection())
                        {
                            this.Save();
                            c.Commit();
                        }
                    }
                }
            }
            return string.Empty;
        }
        //End Nguyen Quoc Phuong 29-Nov-2012

        //Nguyen Quoc Phuong 29-Nov-2012
        public int? CRVTenderCancelRFQ()
        {
            OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            string SystemCode = this.SystemCode;
            if (string.IsNullOrEmpty(SystemCode))
                return null;
            CRVTenderService.CRVTender = CRVTenderService.GetFullTenderInfo(
                                                SystemCode,
                                                this.CRVSerialNumber);
            if (CRVTenderService.CRVTender == null) return null;

            List<string> AwardedCRVVendorIDs = new List<string>();
            List<Guid> rfqitemIds = new List<Guid>();
            foreach (ORequestForQuotationItem rfqitem in this.RequestForQuotationItems)
                rfqitemIds.Add(rfqitem.ObjectID.Value);
            this.ClearAwardLineItems(rfqitemIds);

            for (int i = 0; i < CRVTenderService.CRVTender.CRVTenderVendors.Length; i++)
            {
                CRVTenderService.CRVTender.CRVTenderVendors[i].AwardDate = null;
                CRVTenderService.CRVTender.CRVTenderVendors[i].Status = (int)EnumCRVTenderAwardVendorStatus.TENDERING;
                int? status = CRVTenderService.UpdateTenderVendorAwardStatus(
                                SystemCode,
                                this.CRVSerialNumber,
                                CRVTenderService.CRVTender.CRVTenderVendors[i]);
                if (status != (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL) return null;
            }
            return CRVTenderService.ConfirmCRVSerialUsage(
                    SystemCode,
                    this.CRVSerialNumber,
                    false);
        }
        //End Nguyen Quoc Phuong 29-Nov-2012

        //Nguyen Quoc Phuong 29-Nov-2012
        public string CRVTenderCloseRFQSync()
        {
            try
            {
                if (this.GroupRequestForQuotation == null)
                {
                    int? status = CRVTenderCloseRFQ();
                    if (status != (int)EnumCRVCloseTender.SUCCESSFUL)
                    {
                        this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CLOSE;
                        this.CRVSyncErrorNoOfTries = 0;
                        using (Connection c = new Connection())
                        {
                            this.Save();
                            c.Commit();
                        }
                    }
                }
                else
                {
                    List<ORequestForQuotation> ChildsRFQ = TablesLogic.tRequestForQuotation.LoadList(TablesLogic.tRequestForQuotation.GroupRequestForQuotationID == this.GroupRequestForQuotationID);
                    bool isAllCancelled = true;
                    foreach (ORequestForQuotation ChildRFQ in ChildsRFQ)
                        if (!ChildRFQ.CurrentActivity.ObjectName.Is("Cancelled")) isAllCancelled = false;
                    bool isAllCloseOrCancelled = true;
                    foreach (ORequestForQuotation ChildRFQ in ChildsRFQ)
                        if (!ChildRFQ.CurrentActivity.ObjectName.Is("Cancelled", "Close")) isAllCloseOrCancelled = false;
                    if (isAllCancelled)
                    {
                        int? status = CRVTenderCancelRFQ();
                        if (status != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
                        {
                            using (Connection c = new Connection())
                            {
                                this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CANCEL;
                                this.CRVSyncErrorNoOfTries = 0;
                                this.Save();
                                c.Commit();
                            }
                            return Resources.Errors.CRVTenderService_ConnectionFail;
                        }
                    }
                    else if (isAllCloseOrCancelled)
                    {
                        int? status = CRVTenderCloseRFQ();
                        if (status != (int)EnumCRVCloseTender.SUCCESSFUL)
                        {
                            this.CRVSyncError = (int)EnumCRVTenderRFQSyncError.CLOSE;
                            this.CRVSyncErrorNoOfTries = 0;
                            using (Connection c = new Connection())
                            {
                                this.Save();
                                c.Commit();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
            }
            return string.Empty;
        }
        //End Nguyen Quoc Phuong 29-Nov-2012

        //Nguyen Quoc Phuong 29-Nov-2012
        public int? CRVTenderCloseRFQ()
        {
            OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            string SystemCode = this.SystemCode;
            if (string.IsNullOrEmpty(SystemCode))
                return null;
            return CRVTenderService.CloseTender(
                    SystemCode,
                    this.CRVSerialNumber);
        }
        //End Nguyen Quoc Phuong 29-Nov-2012

        //Nguyen Quoc Phuong 29-Nov-2012
        public bool isSyncCRV
        {
            get
            {
                if(this.GroupRequestForQuotation == null)
                    return (this.PurchaseType != null ? this.PurchaseType.RequiredCRVSerialNumber == 1 : false)
                            && (this.PurchaseType.OnlyApplicableForTermContract == 1 ? this.IsTermContract == 1 : true)
                            //&& (this.Location != null ? this.Location.Parent.SyncCRV == 1 : false)
                            && (this.Location != null ? this.Location.SyncCRV == 1 : false)
                            && (this.CurrentActivity.ObjectName.Is("Draft","Start") || 
                            (!(String.IsNullOrEmpty(this.CRVSerialNumber) && !this.CurrentActivity.ObjectName.Is("Draft","Start"))));
                            //&& (this.IsGroupWJ == 1 ? false : true);
                else
                    return (this.GroupRequestForQuotation.PurchaseType != null ? this.GroupRequestForQuotation.PurchaseType.RequiredCRVSerialNumber == 1 : false)
                            && (this.GroupRequestForQuotation.PurchaseType.OnlyApplicableForTermContract == 1 ? this.GroupRequestForQuotation.IsTermContract == 1 : true)
                            && (this.GroupRequestForQuotation.Location != null ? this.GroupRequestForQuotation.Location.SyncCRV == 1 : false)
                            && (this.CurrentActivity.ObjectName.Is("Draft","Start") || 
                            (!(String.IsNullOrEmpty(this.CRVSerialNumber) && !this.CurrentActivity.ObjectName.Is("Draft"))));
            }
        }
        //End Nguyen Quoc Phuong 29-Nov-2012
        #endregion

        public int NumberOfPOGenerated
        {
            get
            {
                List<OPurchaseOrder> POs = new List<OPurchaseOrder>();
                if (this.GroupRequestForQuotation == null)
                    POs = TablesLogic.tPurchaseOrder.LoadList(TablesLogic.tPurchaseOrder.PurchaseOrderItems.RequestForQuotationItem.RequestForQuotationID == this.ObjectID
                                                               & TablesLogic.tPurchaseOrder.CurrentActivity.ObjectName != "Cancelled"
                                                               & TablesLogic.tPurchaseOrder.CurrentActivity.ObjectName != "CancelledAndRevised");
                else
                    POs = TablesLogic.tPurchaseOrder.LoadList(TablesLogic.tPurchaseOrder.PurchaseOrderItems.RequestForQuotationItem.RequestForQuotation.GroupRequestForQuotationID == this.GroupRequestForQuotationID
                                                                & TablesLogic.tPurchaseOrder.CurrentActivity.ObjectName != "Cancelled"
                                                                & TablesLogic.tPurchaseOrder.CurrentActivity.ObjectName != "CancelledAndRevised");
                return POs.Count;
            }
        }

        //ptb 10-Dec-2012
        public string WarrantyPeriodIntervalText
        {
            get
            {
                switch (WarrantyPeriodInterval)
                {
                    case 0: return "days(s)";
                    case 1: return "week(s)";
                    case 2: return "month(s)";
                    case 3: return "year(s)";
                    default: return "";
                }
            }
        }

        //ptb 10-Dec-2012
        public string WarrantyText
        {
            get
            {
                return String.Format("{0} {1} {2}", WarrantyPeriod.Value, WarrantyPeriodIntervalText, Warranty);
            }
        }

        public string SystemCode
        {
            get
            {
                if (this.GroupRequestForQuotation == null && this.Location != null)
                    return this.Location.GetSystemCode();
                else if (this.GroupRequestForQuotation != null && this.GroupRequestForQuotation.Location != null)
                    return this.GroupRequestForQuotation.Location.GetSystemCode();
                return string.Empty;
            }
        }
    }

    /// <summary>
    /// Enum for type of WJ indicate 
    /// the WJ is recoverable or non-recoverable.
    /// </summary>
    public enum EnumRecoverable
    {
        NonRecoverable = 0,
        Recoverable = 1
    }

    /// <summary>
    /// Enum for budget destribution term
    /// </summary>
    public enum EnumBudgetDistributionTerm
    {
        Monthly = 0,
        Quaterly = 1,
        HalfYearly = 2,
        Yearly = 3
    }

    public enum EnumCRVTenderRFQSyncError
    {
        SUCCEED = 0,

        /// <summary>
        /// Confirm CRV serial number in used succeed but facing error when update Tender.
        /// Can not release the CRV serial number.
        /// Need to run service to release the CRV serial number (set CRV serial number not in use) later.
        /// </summary>
        SUBMIT_FOR_APPROVE = 1,

        /// <summary>
        ///
        /// </summary>
        REJECT_FOR_REWORK = 2,

        /// <summary>
        /// CRV Tender unsucceed to update when awarded. Need to run service to update CRV tender later.
        /// </summary>
        AWARD = 3,

        /// <summary>
        /// CRV Tender unsucceed to cancel. Need to run service to cancel CRV tender later.
        /// </summary>
        CANCEL = 4,

        /// <summary>
        /// CRV Tender unsucceed to close. Need to run service to close later.
        /// </summary>
        CLOSE = 5,

        SUBMIT_FOR_APPROVE_REJECT = 6
    }

}

