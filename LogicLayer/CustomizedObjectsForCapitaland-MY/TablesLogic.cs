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

namespace LogicLayer
{
    /// <summary>
    /// Contains all the declarations to instantiate the Schema classes.
    /// </summary>
    public partial class TablesLogic : TablesData
    {
        public static TPurchaseInvoiceVendorItem tPurchaseInvoiceVendorItem = SchemaFactory.Get<TPurchaseInvoiceVendorItem>();
   }
}

