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
using System.Data;
using System.Configuration;
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
    /// Summary description for OChecklist
    /// </summary>
    public partial class TTaxCode : LogicLayerSchema<OTaxCode>
    {
        [Size(255)]
        public SchemaString SAPTaxCode;
    }


    /// <summary>
    /// Represents a tax code that stores information about the tax
    /// percentage that can be applied in an invoice by a vendor.
    /// </summary>
    public abstract partial class OTaxCode : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract string SAPTaxCode { get; set; }

    }

}
