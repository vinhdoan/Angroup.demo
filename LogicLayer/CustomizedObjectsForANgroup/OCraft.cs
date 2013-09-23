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
    public partial class TCraft : LogicLayerSchema<OCraft>
    {
        public SchemaDecimal DefaultChargeOut;
        public SchemaDecimal DefaultOTChargeOut;
    }


    /// <summary>
    /// Represents a craft record containing information
    /// about the normal and overtime hourly rates of a technician.
    /// Basically, craft is a record indicating the superiority
    /// of the in-house technician in a company, and his pay scale.
    /// </summary>
    public abstract partial class OCraft : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the DefaultChargeOut.
        /// </summary>
        public abstract decimal? DefaultChargeOut { get; set; }
        /// <summary>
        /// [Column] Gets or sets the DefaultOTChargeOut.
        /// </summary>
        public abstract decimal? DefaultOTChargeOut { get; set; }
    }

}
