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
using System.Text;
using System.Data;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TRequestForQuotationItem : LogicLayerSchema<ORequestForQuotationItem>
    {
        public SchemaDecimal EstimatedUnitPrice;
        
        [Size(1000)]
        public SchemaString AdditionalDescription;

        public TRequestForQuotationItemLocation RequestForQuotationItemLocation { get { return OneToMany<TRequestForQuotationItemLocation>("RequestForQuotationItemID"); } }
    }


    /// <summary>
    /// Represents 
    /// </summary>
    public abstract partial class ORequestForQuotationItem : LogicLayerPersistentObject
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
        public abstract DataList<ORequestForQuotationItemLocation> RequestForQuotationItemLocation { get; }
        
        
        /// <summary>
        /// Gets the sub total awarded for this
        /// line item. The sub-total is the unit price (in base currency) 
        /// multiplied by the quantity provided.
        /// </summary>
        public decimal? EstimatedSubtotal
        {
            get
            {
                return this.QuantityRequired * this.EstimatedUnitPrice;
            }
        }

        // NEW: 2011.03.11, Joey
        // Receives a list of rfq ids and returns a datatable of rfqs awarded to ipt vendors
        public static ArrayList GetRFQAwardedToInterestedPartyVendor(List<string> rfqId)
        {
            return (ArrayList)TablesLogic.tRequestForQuotationItem.SelectDistinct
                    (TablesLogic.tRequestForQuotationItem.RequestForQuotationID)
                    .Where
                    (TablesLogic.tRequestForQuotationItem.RequestForQuotationID.In(rfqId) &
                    TablesLogic.tRequestForQuotationItem.AwardedVendor.IsInterestedParty == 1);
        }
    }
}
