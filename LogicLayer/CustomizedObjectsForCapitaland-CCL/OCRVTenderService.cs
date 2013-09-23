//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Reflection;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;
using System.Collections.Generic;

namespace LogicLayer
{
    /// <summary>
    /// Contains all the declarations to instantiate the Schema classes.
    /// </summary>
    public class OCRVTenderService
    {
        private CRVTenderService.TenderService TenderService = new LogicLayer.CRVTenderService.TenderService();
        public CRVTenderService.CRVTender CRVTender;
        public CRVTenderService.CRVTenderVendor CRVTenderVendor;
        public CRVTenderService.GroupProcurementInformation GroupProcurementInformation;
        public CRVTenderService.GProcurementContract GProcurementContract;

        public CRVTenderService.CRVTender CRVTender_Create()
        {
            return new CRVTenderService.CRVTender();
        }

        public CRVTenderService.CRVTenderVendor CRVTenderVendor_Create()
        {
            return new CRVTenderService.CRVTenderVendor();
        }

        public CRVTenderService.GroupProcurementInformation GroupProcurementInformation_Create()
        {
            return new CRVTenderService.GroupProcurementInformation();
        }

        public CRVTenderService.GProcurementContract GProcurementContract_Create()
        {
            return new CRVTenderService.GProcurementContract();
        }

        public OCRVTenderService()
        {
        }

        public OCRVTenderService(string URL)
        {
            TenderService.Url = URL;
        }

        public string URL
        {
            get
            {
                return TenderService.Url;
            }
            set
            {
                TenderService.Url = value;
            }
        }

        public string[] GetActiveCRVSerialNumbers (string systemcode)
        {
            try
            {
                return TenderService.GetActiveCRVSerialNumbers(systemcode);
            }
            catch
            {
            }
            return null;
        }

        public CRVTenderService.CRVTender GetFullTenderInfo (string systemcode, string CRVSerialNo)
        {
            try
            {
                return TenderService.GetFullTenderInfo(systemcode,CRVSerialNo);
            }
            catch
            {
            }
            return null; 
        }

        public int? ConfirmCRVSerialUsage(string systemcode, string CRVSerialNo, bool IsInUse)
        {
            try
            {
                return TenderService.ConfirmCRVSerialUsage(systemcode, CRVSerialNo, IsInUse);
            }
            catch
            {
            }
            return null;
        }

        public CRVTenderService.GroupProcurementInformation GetGroupProcurementInfo(string systemcode, string CRVSerialNo)
        {
            try
            {
                return TenderService.GetGroupProcurementInformation(systemcode, CRVSerialNo);
            }
            catch
            {
            }
            return null;
        }

        public int? UpdateGroupProcurementInfo(string systemcode, string CRVSerialNo, CRVTenderService.GroupProcurementInformation GPI)
        {
            try
            {
                return TenderService.UpdateGroupProcurementInformation(systemcode, CRVSerialNo, GPI);
            }
            catch
            {
            }
            return null;
        }

        public int? CreateGroupProcurementContract(string systemcode, string CRVSerialNo, CRVTenderService.GProcurementContract GPC)
        {
            try
            {
                return TenderService.CreateGroupProcurementContract(systemcode, CRVSerialNo, GPC);
            }
            catch
            {
            }
            return null;
        }

        public int? UpdateGroupProcurementContract(string systemcode, string CRVSerialNo, CRVTenderService.GProcurementContract GPC)
        {
            try
            {
                return TenderService.UpdateGroupProcurementContract(systemcode, CRVSerialNo, GPC);
            }
            catch
            {
            }
            return null;
        }
        public int? UpdateTenderVendorAwardStatus(string systemcode, string CRVSerialNo, CRVTenderService.CRVTenderVendor TenderVendor)
        {
            try
            {
                return TenderService.UpdateTenderVendorAwardStatus(systemcode, CRVSerialNo, TenderVendor);
            }
            catch
            {
            }
            return null;
        }

        public int? CancelTender(string systemcode, string CRVSerialNo, string cancelreason)
        {
            try
            {
                return TenderService.CancelTender(systemcode, CRVSerialNo, cancelreason);
            }
            catch
            {
            }
            return null;
        }

        public int? CloseTender(string systemcode, string CRVSerialNo)
        {
            try
            {
                return TenderService.CloseTender(systemcode, CRVSerialNo);
            }
            catch
            {
            }
            return null;
        }

        public int? GetTenderNoOfContracts(string systemcode, string CRVSerialNo)
        {
            try
            {
                int? result = TenderService.GetTenderNoOfContracts(systemcode, CRVSerialNo);
                return result == null ? (int)EnumCRVGetTenderNoOfContracts.TENDERNOTFOUND : result;
            }
            catch
            {
            }
            return null;
        }
    }

    public enum EnumCRVTenderSerialNumberStatus
    {
        SUCCESSFUL = 0,
        INVALID_SERIAL_NO = 1,
        ALR_IN_USE = 2,
        ALR_NOT_IN_USE = 3
    }

    public enum EnumCRVTenderAwardVendorStatus
    {
        NOT_AWARDED = 0,
        AWARDED = 1,
        WITHDRAWN = 2,
        TENDERING = 3
    }

    public enum EnumCRVUpdateTenderVendorAwardStatus
    {
        SUCCESSFUL = 0,
        INVALID_CRVSERIALNO = 1,
        INVALID_VENDOR = 2,
        INVALID_AWARDSTATUS = 3,
        INVALID_DATE = 4
    }

    public enum EnumCRVUpdateGroupProcurementInfoStatus
    {
        SUCCESSFUL = 0,
        INVALID_CRVSERIALNO = 1,
        INVALID_CURRENCY = 3,
        INVALID_PROJECTTITLE = 4,
        INVALID_PROJECTREFNO = 5
    }

    public enum EnumCRVCreateGroupProcurementContractStatus
    {
        SUCCESSFUL = 0,
        INVALID_CRVSERIALNO = 1,
        INVALID_VENDOR = 2,
        INVALID_TRADETYPE = 3,
        INVALID_AWARDAMOUNT = 4,
        INVALID_STARTDATE = 5,
        INVALID_ENDDATE = 6,
        INVALID_CONTRACTSTATUS = 7,
        INVALID_CONTRACTREFNO = 8,
        CONTRACT_EXIST = 9
    }
    public enum EnumCRVUpdateGroupProcurementContractStatus
    {
        SUCCESSFUL = 0,
        INVALID_CRVSERIALNO = 1,
        INVALID_VENDOR = 2,
        INVALID_TRADETYPE = 3,
        INVALID_AWARDAMOUNT = 4,
        INVALID_STARTDATE = 5,
        INVALID_ENDDATE = 6,
        INVALID_CONTRACTSTATUS = 7,
        INVALID_CONTRACTREFNO = 8,
        CONTRACT_NOT_EXIST = 9
    }

    public enum EnumCRVCloseTender
    {
        SUCCESSFUL = 0,
        INVALID_CRVVENDORID = 1,
        TENDER_NOT_IN_TENDERING_STATE = 2,
        TENDER_HAS_NO_AWARDED_VENDOR = 3,
        TENDER_HAS_TENDERING_VENDOR = 4,
        TENDER_IN_CLOSED_STATE = 5,
        TENDER_IN_CANCELLED_STATE = 6,
        FATAL_ERROR = 7
    }

    public enum EnumCRVCancelTender 
    {
        SUCCESSFUL = 0,
        INVALID_CRVVENDORID = 1,
        TENDER_NOT_IN_TENDERING_STATE = 2,
        EMPTY_CANCELREASON = 3,
        TENDER_IN_CLOSED_STATE = 4,
        TENDER_IN_CANCELLED_STATE = 5,
        FATAL_ERROR = 6
    }

    public enum EnumCRVGetTenderNoOfContracts
    {
        TENDERNOTFOUND = -1
    }

    public enum EnumCRVGProcurementContractStatus
    {
        ONGOING = 1,
        COMPLETED = 2,
        CANCELLED = 0
    }
}

