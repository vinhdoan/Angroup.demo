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
    public partial class TPurchaseRequestItem : LogicLayerSchema<OPurchaseRequestItem>
    {
        public SchemaDecimal EstimatedUnitPrice;
    }


    /// <summary>
    /// Represents the item requested in a purchase request object.
    /// </summary>
    public abstract partial class OPurchaseRequestItem : LogicLayerPersistentObject
    {

        /// <summary>
        /// [Column] Gets or sets the EstimatedUnitPrice
        /// that indicates the purchase request that contains this item.
        /// </summary>
        public abstract Decimal? EstimatedUnitPrice { get; set; }
        /// <summary>
        /// Gets the sub total awarded for this
        /// line item. The sub-total is the unit price (in base currency) 
        /// multiplied by the quantity provided.
        /// </summary>
        public decimal? Subtotal
        {
            get
            {
                return this.QuantityRequired * this.EstimatedUnitPrice;
            }
        }
    }
}
