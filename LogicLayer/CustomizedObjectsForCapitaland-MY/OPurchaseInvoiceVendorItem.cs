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
    /// Summary description for OPurchaseOrder
    /// </summary>
    public partial class TPurchaseInvoiceVendorItem : LogicLayerSchema<OPurchaseInvoiceVendorItem>
    {
        public SchemaGuid PurchaseInvoiceID;
        public SchemaImage FileBytes;
        public SchemaInt FileSize;
        [Size(255)]
        public SchemaString ContentType;
    }


    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseInvoiceVendorItem : LogicLayerPersistentObject
    {
        public abstract Guid? PurchaseInvoiceID { get; set; }
        public abstract byte[] FileBytes { get; set; }
        public abstract int? FileSize { get; set; }
        public abstract string ContentType { get; set; }


    }


}

