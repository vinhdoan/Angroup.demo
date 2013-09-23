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
    public partial class TContractPriceService : LogicLayerSchema<OContractPriceService>
    {
        public SchemaInt AllowVariation;
        public SchemaDecimal VariationPercentage;
    }


    /// <summary>
    /// Represents part of a purchase agreement that indicates
    /// the fixed rates or set of fixed rates set out in the purchase 
    /// agreement contract along with a price factor applied to 
    /// the standard rates indicated in the fixed rates.
    /// </summary>
    public abstract partial class OContractPriceService : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets a flag indicating if variation
        /// is allowed for the agreed price.
        /// </summary>
        public abstract int? AllowVariation { get; set; }

        /// <summary>
        /// [Column] Gets or sets the percentage variation allowed.
        /// </summary>
        public abstract decimal? VariationPercentage { get; set; }


        /// <summary>
        /// Returns a translated string that indicates whether this item
        /// allows variation.
        /// </summary>
        public string AllowVariationText
        {
            get
            {
                if (AllowVariation == 0)
                    return Resources.Strings.General_No;
                else if (AllowVariation == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }
    }
}
