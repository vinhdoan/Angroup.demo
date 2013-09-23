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
    public partial class TPurchaseOrderItem : LogicLayerSchema<OPurchaseOrderItem>
    {
        public SchemaDecimal EstimatedUnitPrice;
       
        [Size(1000)]
        public SchemaString AdditionalDescription;

        public SchemaGuid TaxCodeID;
        public SchemaGuid OriginalRequestForQuotationItemID;
        public SchemaDecimal OriginalUnitPrice;
        public SchemaDecimal OriginalUnitPriceInSelectedCurrency;
        public SchemaDecimal OriginalQuantity;
        public SchemaDecimal TaxAmount;
    }


    /// <summary>
    /// Represents 
    /// </summary>
    
    public abstract partial class OPurchaseOrderItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the EstimatedUnitPrice
        /// that indicates the purchase request that contains this item.
        /// </summary>
        public abstract Decimal? EstimatedUnitPrice { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract string AdditionalDescription { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? TaxCodeID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? OriginalRequestForQuotationItemID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Decimal? OriginalUnitPrice { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Decimal? OriginalUnitPriceInSelectedCurrency { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Decimal? OriginalQuantity { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract decimal? TaxAmount { get; set; }
        /// <summary>
        /// Gets the sub total awarded for this
        /// line item. The sub-total is the unit price (in base currency) 
        /// multiplied by the quantity provided.
        /// </summary>
        public decimal? EstimatedSubtotal
        {
            get
            {
                return Round(this.QuantityOrdered * this.EstimatedUnitPrice);
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
                return Round(this.QuantityOrdered * this.UnitPriceInSelectedCurrency);
            }
        }

        public decimal? SubtotalOriginalAmount
        {
            get
            {
                decimal? subtotal = 0;
                if (OriginalQuantity != null && OriginalUnitPriceInSelectedCurrency != null)
                    subtotal = Round(this.OriginalQuantity * this.OriginalUnitPriceInSelectedCurrency);
                return subtotal;
            }
        }

        /// <summary>
        /// Gets the purchase request number or request for quotation number
        /// that this purchase order item was copied from.
        /// </summary>
        public List<ORequestForQuotation> CopiedFromRequestForQuotations
        {
            get
            {
                List<ORequestForQuotation> RFQs = new List<ORequestForQuotation>();
                if (RequestForQuotationItem != null && RequestForQuotationItem.RequestForQuotation != null)
                    RFQs.Add(RequestForQuotationItem.RequestForQuotation);
                return RFQs;
            }
        }
    }
}
