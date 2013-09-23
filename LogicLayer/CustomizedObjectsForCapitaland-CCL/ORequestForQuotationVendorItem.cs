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
    
    public partial class TRequestForQuotationVendorItem : LogicLayerSchema<ORequestForQuotationVendorItem>
    {
        public SchemaDecimal ChargeAmount;

        public SchemaDecimal RecoverableAmount;

        public SchemaDecimal RecoverableAmountInSelectedCurrency;
    }


    /// <summary>
    /// Represents an object that contains the quoted price of a line
    /// item from a request for quotation item object.
    /// </summary>
    public abstract partial class ORequestForQuotationVendorItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// 
        /// </summary>
        public abstract decimal? ChargeAmount { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract decimal? RecoverableAmount { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract decimal? RecoverableAmountInSelectedCurrency { get; set; }

        /// <summary>
        /// Gets the sub total awarded for this
        /// line item. The sub-total is the unit price (in base currency) 
        /// multiplied by the quantity provided.
        /// </summary>
        public decimal? Subtotal
        {
            get
            {
                return Round(this.QuantityProvided * this.UnitPrice);
            }
        }

        /// <summary>
        /// Gets the sub total awarded for this
        /// line item. The sub-total is the unit price (in selected currency) 
        /// multiplied by the quantity provided.
        /// </summary>
        public decimal? SubtotalInSelectedCurrency
        {
            get
            {
                return Round(this.QuantityProvided * this.UnitPriceInSelectedCurrency);
            }
        }
    }
}
