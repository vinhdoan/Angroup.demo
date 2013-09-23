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
    public partial class TRequestForQuotationVendor : LogicLayerSchema<ORequestForQuotationVendor>
    {
        public SchemaGuid VendorContactID;
    }


    /// <summary>
    /// Represents a physical quotation from vendor indicating
    /// terms of the quotation and a collection of the quote
    /// of each line item in the original request for quotation.
    /// </summary>
    public abstract partial class ORequestForQuotationVendor : LogicLayerPersistentObject
    {
        private decimal minimumQuote;
        public abstract Guid? VendorContactID { get; set; }

        /// <summary>
        /// Returns the minimum quote (in base currency) in this Request for Quotation. This
        /// value is updated only after the ORequestForQuotation.ComputeLowestQuotation() 
        /// method has been called.
        /// </summary>
        public decimal MinimumQuote
        {
            get
            {
                return minimumQuote;
            }
            set
            {
                minimumQuote = value;
            }
        }


        /// <summary>
        /// Returns the percentage above the minimum quote for this Request for Quotation. This
        /// value is updated only after the ORequestForQuotation.ComputeLowestQuotation() 
        /// method has been called.
        /// </summary>
        public decimal PercentageAboveMinimumQuote
        {
            get
            {
                decimal? thisQuote = this.TotalQuotation;

                if (this.minimumQuote > 0 && minimumQuote != decimal.MaxValue && thisQuote.HasValue)
                    return thisQuote.Value / this.minimumQuote * 100 - 100;
                else
                    return -1;
            }
        }

        /// <summary>
        /// Returns the percentage above the minimum quote for this Request for Quotation. This
        /// value is updated only after the ORequestForQuotation.ComputeLowestQuotation() 
        /// method has been called.
        /// </summary>
        public string PercentageAboveMinimumQuoteText
        {
            get
            {
                decimal p = PercentageAboveMinimumQuote;
                if (p == 0)
                    return Resources.Strings.RequestForQuotation_Lowest;
                else if (p > 0)
                    return p.ToString("0.0") + "%";
                else
                    return "";
            }
        }
    }
}
