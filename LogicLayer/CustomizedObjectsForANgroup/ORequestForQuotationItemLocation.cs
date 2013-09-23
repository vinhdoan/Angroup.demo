//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TRequestForQuotationItemLocation : LogicLayerSchema<ORequestForQuotationItemLocation>
    {
        public SchemaGuid RequestForQuotationItemID;
        public SchemaGuid LocationID;
        public SchemaInt QuantityRequired;
        public SchemaDecimal AmountRatio;
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
    }


    /// <summary>
    /// Represents 
    /// </summary>
    public abstract partial class ORequestForQuotationItemLocation : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the EstimatedUnitPrice
        /// that indicates the purchase request that contains this item.
        /// </summary>
        public abstract Guid? RequestForQuotationItemID { get; set; }
        public abstract Guid? LocationID { get; set; }
        public abstract int? QuantityRequired { get; set; }
        public abstract decimal? AmountRatio { get; set; }
        public abstract OLocation Location { get; set; }
        /// <summary>
        /// Gets the sub total awarded for this
        /// line item. The sub-total is the unit price (in base currency) 
        /// multiplied by the quantity provided.
        /// </summary>

    }
}
