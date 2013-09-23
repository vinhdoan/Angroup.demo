//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO.Ports;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;
using System.Collections;
using System.Data.Sql;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;


namespace Service
{

    public partial class CRVReSyncService : AnacleServiceBase
    {
        const int MAX_TRY_NO = 3;
        const int MAX_TRY_NO_PO = MAX_TRY_NO;
        const int MAX_TRY_NO_RFQ = MAX_TRY_NO;
        const string CreateCRVGProcurementContractErrorTemplate = "CreateCRVGProcurementContractErrorTemplate";
        const string UpdateCRVGProcurementContractErrorTemplate = "UpdateCRVGProcurementContractErrorTemplate";
        const string UpdateCRVGroupProcurementInfoErrorTemplate = "UpdateCRVGroupProcurementInfoErrorTemplate";
        const string RFQCancelRealeaseCRVSerialNumberErrorTemplate = "RFQCancelRealeaseCRVSerialNumberErrorTemplate";
        const string CloseCRVTenderErrorTemplate = "CloseCRVTenderErrorTemplate";
        const string ReleaseCRVTenderErrorTemplate = "ReleaseCRVTenderErrorTemplate";
        const string CRVTenderRFQSubmitForApprovalFromRejectErrorTemplate = "CRVTenderRFQSubmitForApprovalFromRejectErrorTemplate";

        // Nguyen Quoc Phuong 5-Dec-2012
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            ReSyncPO();
            ReSyncRFQ();
        }
        // Nguyen Quoc Phuong 5-Dec-2012

        //Nguyen Quoc Phuong 13-Dec-2012
        private void ReSyncPO()
        {
            List<OPurchaseOrder> POs = TablesLogic.tPurchaseOrder.LoadList(TablesLogic.tPurchaseOrder.CRVSyncError != (int)EnumCRVTenderPOSyncError.SUCCEED &
                                                                           TablesLogic.tPurchaseOrder.CRVSyncErrorNoOfTries < MAX_TRY_NO_PO);
            foreach (OPurchaseOrder po in POs)
            {
                if (po.CRVSyncError == null)
                {
                    po.CRVSyncError = (int)EnumCRVTenderPOSyncError.SUCCEED;
                    po.CRVSyncErrorNoOfTries = 0;
                    using (Connection c = new Connection())
                    {
                        po.Save();
                        c.Commit();
                    }
                    continue;
                }
                if (po.CRVSyncError == (int)EnumCRVTenderPOSyncError.CREATE)
                {
                    int? status = po.CreateCRVGProcurementContract();
                    if (status != (int)EnumCRVCreateGroupProcurementContractStatus.SUCCESSFUL)
                    {
                        po.CRVSyncErrorNoOfTries = po.CRVSyncErrorNoOfTries + 1;
                        if (po.CRVSyncErrorNoOfTries == MAX_TRY_NO_PO)
                            po.SendMessage(CreateCRVGProcurementContractErrorTemplate, TablesLogic.tUser.Load(po.CreatedUserID));
                    }
                    else
                    {
                        po.CRVSyncError = (int)EnumCRVTenderPOSyncError.SUCCEED;
                        po.CRVSyncErrorNoOfTries = 0;
                    }
                    using (Connection c = new Connection())
                    {
                        po.Save();
                        c.Commit();
                    }
                    continue;
                }
                if (po.CRVSyncError == (int)EnumCRVTenderPOSyncError.UPDATE)
                {
                    int? status = po.UpdateCRVGProcurementContract();
                    if (status != (int)EnumCRVUpdateGroupProcurementContractStatus.SUCCESSFUL)
                    {
                        po.CRVSyncErrorNoOfTries = po.CRVSyncErrorNoOfTries + 1;
                        if (po.CRVSyncErrorNoOfTries == MAX_TRY_NO_PO)
                            po.SendMessage(UpdateCRVGProcurementContractErrorTemplate, TablesLogic.tUser.Load(po.CreatedUserID));
                    }
                    else
                    {
                        po.CRVSyncError = (int)EnumCRVTenderPOSyncError.SUCCEED;
                        po.CRVSyncErrorNoOfTries = 0;
                    }
                    using (Connection c = new Connection())
                    {
                        po.Save();
                        c.Commit();
                    }
                    continue;

                }
            }
        }
        //End Nguyen Quoc Phuong 13-Dec-2012

        //Nguyen Quoc Phuong 13-Dec-2012
        private void ReSyncRFQ()
        {
            List<ORequestForQuotation> RFQs = TablesLogic.tRequestForQuotation.LoadList(TablesLogic.tRequestForQuotation.CRVSyncError != (int)EnumCRVTenderRFQSyncError.SUCCEED
                                                               & TablesLogic.tRequestForQuotation.CRVSyncErrorNoOfTries < MAX_TRY_NO_RFQ
                                                               & TablesLogic.tRequestForQuotation.GroupRequestForQuotationID == null);
            foreach (ORequestForQuotation rfq in RFQs)
            {
                if (rfq.CRVSyncError == null)
                {
                    rfq.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUCCEED;
                    rfq.CRVSyncErrorNoOfTries = 0;
                    using (Connection c = new Connection())
                    {
                        rfq.Save();
                        c.Commit();
                    }
                    continue;
                }
                if (rfq.CRVSyncError == (int)EnumCRVTenderRFQSyncError.SUBMIT_FOR_APPROVE)
                {
                    if (!string.IsNullOrEmpty(rfq.SystemCode))
                    {
                        string SystemCode = rfq.SystemCode;
                        OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);

                        int? ReleaseStatus = CRVTenderService.ConfirmCRVSerialUsage(
                                                SystemCode,
                                                rfq.CRVSerialNumber,
                                                false);
                        if (ReleaseStatus != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
                        {
                            rfq.CRVSyncErrorNoOfTries = rfq.CRVSyncErrorNoOfTries + 1;
                            if (rfq.CRVSyncErrorNoOfTries == MAX_TRY_NO_RFQ)
                                rfq.SendMessage(ReleaseCRVTenderErrorTemplate, TablesLogic.tUser.Load(rfq.CreatedUserID));
                        }
                        else
                        {
                            rfq.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUCCEED;
                            rfq.CRVSyncErrorNoOfTries = 0;
                        }
                    }
                    else
                    {
                        rfq.CRVSyncErrorNoOfTries = rfq.CRVSyncErrorNoOfTries + 1;
                        if (rfq.CRVSyncErrorNoOfTries == MAX_TRY_NO_RFQ)
                            rfq.SendMessage(ReleaseCRVTenderErrorTemplate, TablesLogic.tUser.Load(rfq.CreatedUserID));
                    }
                    using (Connection c = new Connection())
                    {
                        rfq.Save();
                        c.Commit();
                    }
                    continue;
                }
                if (rfq.CRVSyncError == (int)EnumCRVTenderRFQSyncError.SUBMIT_FOR_APPROVE_REJECT)
                {
                    try
                    {
                        rfq.CRVTenderApproveRFQFromReject();
                        rfq.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUCCEED;
                        rfq.CRVSyncErrorNoOfTries = 0;
                    }
                    catch
                    {
                        rfq.CRVSyncErrorNoOfTries = rfq.CRVSyncErrorNoOfTries + 1;
                        if (rfq.CRVSyncErrorNoOfTries == MAX_TRY_NO_RFQ)
                            rfq.SendMessage(CRVTenderRFQSubmitForApprovalFromRejectErrorTemplate, TablesLogic.tUser.Load(rfq.CreatedUserID));
                    }
                    using (Connection c = new Connection())
                    {
                        rfq.Save();
                        c.Commit();
                    }
                    continue;
                }
                if (rfq.CRVSyncError == (int)EnumCRVTenderRFQSyncError.AWARD)
                {
                    int? status = rfq.CRVTenderAwardedRFQ();
                    int? updateCRVVendorStatus = rfq.CRVTenderAwardedRFQUpdateCRVVendor();
                    if (status != (int)EnumCRVUpdateGroupProcurementInfoStatus.SUCCESSFUL || updateCRVVendorStatus != (int)EnumCRVUpdateTenderVendorAwardStatus.SUCCESSFUL)
                    {
                        rfq.CRVSyncErrorNoOfTries = rfq.CRVSyncErrorNoOfTries + 1;
                        if (rfq.CRVSyncErrorNoOfTries == MAX_TRY_NO_RFQ)
                            rfq.SendMessage(UpdateCRVGroupProcurementInfoErrorTemplate, TablesLogic.tUser.Load(rfq.CreatedUserID));
                    }
                    else
                    {
                        rfq.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUCCEED;
                        rfq.CRVSyncErrorNoOfTries = 0;
                    }
                    using (Connection c = new Connection())
                    {
                        rfq.Save();
                        c.Commit();
                    }
                    continue;
                }
                if (rfq.CRVSyncError == (int)EnumCRVTenderRFQSyncError.CANCEL)
                {
                    int? status = rfq.CRVTenderCancelRFQ();
                    if (status != (int)EnumCRVTenderSerialNumberStatus.SUCCESSFUL)
                    {
                        rfq.CRVSyncErrorNoOfTries = rfq.CRVSyncErrorNoOfTries + 1;
                        if (rfq.CRVSyncErrorNoOfTries == MAX_TRY_NO_RFQ)
                            rfq.SendMessage(RFQCancelRealeaseCRVSerialNumberErrorTemplate, TablesLogic.tUser.Load(rfq.CreatedUserID));
                    }
                    else
                    {
                        rfq.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUCCEED;
                        rfq.CRVSyncErrorNoOfTries = 0;
                    }
                    using (Connection c = new Connection())
                    {
                        rfq.Save();
                        c.Commit();
                    }
                    continue;
                }
                if (rfq.CRVSyncError == (int)EnumCRVTenderRFQSyncError.CLOSE)
                {
                    int? status = rfq.CRVTenderCloseRFQ();
                    if (status != (int)EnumCRVCloseTender.SUCCESSFUL)
                    {
                        rfq.CRVSyncErrorNoOfTries = rfq.CRVSyncErrorNoOfTries + 1;
                        if (rfq.CRVSyncErrorNoOfTries == MAX_TRY_NO_RFQ)
                            rfq.SendMessage(CloseCRVTenderErrorTemplate, TablesLogic.tUser.Load(rfq.CreatedUserID));
                    }
                    else
                    {
                        rfq.CRVSyncError = (int)EnumCRVTenderRFQSyncError.SUCCEED;
                        rfq.CRVSyncErrorNoOfTries = 0;
                    }
                    using (Connection c = new Connection())
                    {
                        rfq.Save();
                        c.Commit();
                    }
                    continue;
                }
            }
        }
        //End Nguyen Quoc Phuong 13-Dec-2012
    }
}
