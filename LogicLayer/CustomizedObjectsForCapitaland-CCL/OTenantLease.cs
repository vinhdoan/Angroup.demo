//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;


/// <summary>
/// Summary description for CapitalandCompany
/// </summary>

namespace LogicLayer
{
    public partial class TTenantLease : LogicLayerSchema<OTenantLease>
    {
        public SchemaString AMOSInstanceID;
    }


    /// <summary>
    /// </summary>
    public abstract partial class OTenantLease : LogicLayerPersistentObject
    {
        public abstract String AMOSInstanceID { get; set; }

    }
}

