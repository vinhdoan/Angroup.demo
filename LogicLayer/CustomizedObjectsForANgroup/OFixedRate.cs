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
    public partial class TFixedRate : LogicLayerSchema<OFixedRate>
    {
        public SchemaDecimal DefaultChargeOut;
    }


    /// <summary>
    /// Represents a fixed rate item or a fixed rate group. A
    /// fixed rate item is a record describing services that 
    /// can be provided by an external vendor to the user's
    /// company. When used in a purchase agreement, it
    /// indicates the services and the unit price that the
    /// vendor provides to the company when a purchase order
    /// is raised for those services to the vendor.
    /// </summary>
    public abstract partial class OFixedRate : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets the DefaultChargeOut.
        /// </summary>
        public abstract decimal? DefaultChargeOut { get; set; }
    }
    
}

