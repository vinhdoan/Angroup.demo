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
    public class OCRVWebService
    {
        public CRVWebService.Code[] Codes;
        public CRVWebService.Code Code = new LogicLayer.CRVWebService.Code();
        public CRVWebService.Vendor CRVVendor = new LogicLayer.CRVWebService.Vendor();
        public CRVWebService.VendorService VendorService = new LogicLayer.CRVWebService.VendorService();

        public OCRVWebService()
        {
        }

        public OCRVWebService(string URL)
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
    }
    public enum CRVWebServiceEnum
    {
        SUCCESSFUL = 0,
        INVALID_SYSTEMCODE = 1,
        INVALID_BIZREGNO = 2,
        INVALID_COUNTRY = 3,
        RECORD_NOTEXIST = 4
    }
}

