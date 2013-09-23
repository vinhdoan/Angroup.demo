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
    public class OCRVVendorService
    {
        private CRVVendorService.VendorService VendorService = new LogicLayer.CRVVendorService.VendorService();
        public CRVVendorService.Code[] Codes;
        public CRVVendorService.Code Code;
        public CRVVendorService.Vendor CRVVendor;

        public CRVVendorService.Code Code_Create()
        {
            return new CRVVendorService.Code();
        }

        public CRVVendorService.Vendor CRVVendor_Create()
        {
            return new CRVVendorService.Vendor();
        }

        public OCRVVendorService()
        {
        }

        public OCRVVendorService(string URL)
        {
            VendorService.Url = URL;
        }

        public string URL
        {
            get
            {
                return VendorService.Url;
            }
            set
            {
                VendorService.Url = value;
            }
        }

        public string[] SearchVendor(string systemcode, string BusinessRegNum, string VendorName)
        {
            try
            {
                return VendorService.SearchVendor(systemcode, BusinessRegNum, VendorName);
            }
            catch
            {
            }
            return null;
        }

        public CRVVendorService.Vendor GetVendor(string systemcode, string CRVVendorID)
        {
            try
            {
                return VendorService.GetVendor(systemcode, CRVVendorID);
            }
            catch
            {
            }
            return null;
        }

        public CRVVendorService.Code[] GetTradeTypeCodesByVendorType(string systemcode, string VendorTypeID)
        {
            try
            {
                return VendorService.GetTradeTypeCodesByVendorType(systemcode, VendorTypeID);
            }
            catch
            {
            }
            return null;
        }

        public CRVVendorService.Code[] GetVendorClassificationCodes(string systemcode)
        {
            try
            {
                return VendorService.GetVendorClassificationCodes(systemcode);
            }
            catch
            {
            }
            return null;
        }

        public CRVVendorService.Code[] GetVendorTypeCodes(string systemcode)
        {
            try
            {
                return VendorService.GetVendorTypeCodes(systemcode);
            }
            catch
            {
            }
            return null;
        }

        public string[] GetOutdatedAndNewVendorList(string systemcode)
        {
            try
            {
                return VendorService.GetOutdatedAndNewVendorList(systemcode);
            }
            catch
            {
            }
            return null;
        }

        public int? SubscribeVendor(string systemcode, string CRVVendorID)
        {
            try
            {
                return VendorService.SubscribeVendor(systemcode, CRVVendorID);
            }
            catch
            {
            }
            return null;
        }

        public bool? IsVendorSubscribed(string systemcode, string CRVVendorID)
        {

            try
            {
                return VendorService.IsVendorSubscribed(systemcode, CRVVendorID);
            }
            catch
            {
            }
            return null;
        }

        public int? UnSubscribeVendor(string systemcode, string CRVVendorID)
        {
            try
            {
                return VendorService.UnSubscribeVendor(systemcode, CRVVendorID);
            }
            catch
            {
            }
            return null;
        }

        public string ConfirmVendorRetrieved(string systemcode, string CRVVendorID)
        {
            try
            {
                return VendorService.ConfirmVendorRetrieved(systemcode, CRVVendorID);
            }
            catch
            {
            }
            return null;
        }

    }

    public enum EnumCRVVendorSubscriptionStatus
    {
        SUCCESSFUL = 0,
        INVALID_SYSTEMCODE = 1,
        INVALID_CRVVENDORID = 2,
        RECORD_NOTEXIST = 3
    }

    public class CRVendorStatus
    {
        public const string ACTIVE = "Active";
        public const string INACTIVE = "Inactive";
        public const string UNLISTED = "Unlisted";
    }
}

