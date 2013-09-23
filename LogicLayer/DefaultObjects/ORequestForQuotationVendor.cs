//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Serializable] 
    public partial class TRequestForQuotationVendor : LogicLayerSchema<ORequestForQuotationVendor>
    {
        public SchemaGuid RequestForQuotationID;
        public SchemaGuid VendorID;
        [Default(0)]
        public SchemaInt IsSubmitted;
        public SchemaDateTime DateOfQuotation;
        public SchemaText FreightTerms;
        public SchemaText PaymentTerms;
        public SchemaString ContactAddressCountry;
        public SchemaString ContactAddressState;
        public SchemaString ContactAddressCity;
        [Size(255)]
        public SchemaString ContactAddress;
        public SchemaString ContactCellPhone;
        public SchemaString ContactEmail;
        public SchemaString ContactFax;
        public SchemaString ContactPhone;
        public SchemaString ContactPerson;

        [Default(0)]
        public SchemaDecimal TaxPercentage;
        public SchemaGuid CurrencyID;
        [Default(0)]
        public SchemaInt IsExchangeRateDefined;
        public SchemaDecimal ForeignToBaseExchangeRate;

        public TVendor Vendor { get { return OneToOne<TVendor>("VendorID"); } }
        public TRequestForQuotation RequestForQuotation { get { return OneToOne<TRequestForQuotation>("RequestForQuotationID"); } }
        public TRequestForQuotationVendorItem RequestForQuotationVendorItems { get { return OneToMany<TRequestForQuotationVendorItem>("RequestForQuotationVendorID"); } }
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
    }


    /// <summary>
    /// Represents a physical quotation from vendor indicating
    /// terms of the quotation and a collection of the quote
    /// of each line item in the original request for quotation.
    /// </summary>
    [Serializable]
    public abstract partial class ORequestForQuotationVendor : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the RequestForQuotation table 
        /// that indicates the request for quotation that this quotation
        /// has been generated for.
        /// </summary>
        public abstract Guid? RequestForQuotationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Vendor table 
        /// that indicates the vendor who provided this quotation.
        /// </summary>
        public abstract Guid? VendorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this quotation has been submitted by the vendor.
        /// A submitted quotation must have the date of the 
        /// quotation, the alternative currency, adn all of
        /// the quotation item's unit prices and quantity
        /// provided filled up.
        /// </summary>
        public abstract int? IsSubmitted { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date of the quotation.
        /// This date is used in conjunction with the quotation 
        /// currency to determine the currency exchange rate.
        /// </summary>
        public abstract DateTime? DateOfQuotation { get; set; }

        /// <summary>
        /// [Column] Gets or sets the freight terms associated with
        /// this quotation. This will be copied to the purchase
        /// order should this quotation be awarded, and this
        /// item is copied to the new purchase order.
        /// </summary>
        public abstract String FreightTerms { get; set; }

        /// <summary>
        /// [Column] Gets or sets the payment terms associated with
        /// this quotation. This will be copied to the purchase
        /// order should this quotation be awarded, and this
        /// item is copied to the new purchase order.
        /// </summary>
        public abstract String PaymentTerms { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddressCountry { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddressState { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddressCity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactCellPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract String ContactPerson { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact details.
        /// </summary>
        public abstract Decimal? TaxPercentage { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Currency table that represents the foreign 
        /// currency of the line items in this vendor's 
        /// quotation.
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// the exchange rate for the selected currency
        /// was defined when the currency was selected.
        /// <para></para>
        /// If the selected currency is the system's base 
        /// currency, then this flag will be 1.
        /// </summary>
        public abstract int? IsExchangeRateDefined { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Currency table that represents the foreign 
        /// currency exchange rate.
        /// <para></para>
        /// The date of the quotation and the selected
        /// currency is used to determine the exchange rate.
        /// <para></para>
        /// If a default exchange rate cannot be found in the
        /// exchange rate table, then the user may enter
        /// the exchange rate manually.
        /// </summary>
        public abstract decimal? ForeignToBaseExchangeRate { get; set; }

        /// <summary>
        /// Gets or sets the OVendor object that represents
        /// the vendor who provided this quotation.
        /// </summary>
        public abstract OVendor Vendor { get; set; }

        /// <summary>
        /// Gets or sets the reference to an OCurrency object
        /// that represents the foreign currency that will
        /// be set to a quotation line item when a new
        /// one is created.
        /// </summary>
        public abstract OCurrency Currency { get; set; }

        /// <summary>
        /// Gets or sets the ORequestForQuotation object that represents
        /// the request for quotation that this quotation
        /// has been generated for.
        /// </summary>
        public abstract ORequestForQuotation RequestForQuotation { get; set; }

        /// <summary>
        /// Gets a one-to-many list of ORequestForQuotationVendorItem objects 
        /// that represents the quotation for each individual line item
        /// in the request for quotation.
        /// </summary>
        public abstract DataList<ORequestForQuotationVendorItem> RequestForQuotationVendorItems { get; }

        /// <summary>
        /// Gets the total amount quoted in this quotation in
        /// the selected currency.
        /// </summary>
        public decimal? TotalQuotationInSelectedCurrency
        {
            get
            {
                if (this.IsSubmitted == 1)
                {
                    decimal? total = 0;
                    foreach (ORequestForQuotationVendorItem rfqVendorItem in RequestForQuotationVendorItems)
                        total += Round(rfqVendorItem.UnitPriceInSelectedCurrency * rfqVendorItem.QuantityProvided);
                    return total == null ? 0M : (decimal)total;
                }
                else
                    return null;
            }
        }


        /// <summary>
        /// Gets the total amount quoted in this quotation.
        /// </summary>
        public decimal? TotalQuotation
        {
            get
            {
                if (this.IsSubmitted == 1)
                {
                    decimal? total = 0;
                    foreach (ORequestForQuotationVendorItem rfqVendorItem in RequestForQuotationVendorItems)
                        total += Round(rfqVendorItem.UnitPrice * rfqVendorItem.QuantityProvided);
                    return total == null ? 0M : (decimal)total;
                }
                else
                    return null;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public string IsSubmittedText
        {
            get
            {
                if (this.IsSubmitted == 0)
                    return Resources.Strings.General_No;
                else if (this.IsSubmitted == 1)
                    return Resources.Strings.General_Yes;
                return "";

            }
        }

        /// <summary>
        /// Updates the exchange rate from the one defined
        /// in the database.
        /// </summary>
        public void UpdateExchangeRate()
        {
            this.IsExchangeRateDefined = 0;
            this.ForeignToBaseExchangeRate = null;

            decimal? rate = null;
            if (this.DateOfQuotation != null && this.CurrencyID != null)
                rate = OCurrency.GetExchangeRate(this.DateOfQuotation.Value, this.CurrencyID.Value);

            if (rate != null)
            {
                this.IsExchangeRateDefined = 1;
                this.ForeignToBaseExchangeRate = rate;
                return;
            }
        }


        /// <summary>
        /// Updates the unit price of all vendor quoted items.
        /// </summary>
        public void UpdateItemsUnitPrice()
        {
            OCurrency baseCurrency = OApplicationSetting.Current.BaseCurrency;

            foreach (ORequestForQuotationVendorItem rfqVendorItem in this.RequestForQuotationVendorItems)
            {
                if (rfqVendorItem.CurrencyID == baseCurrency.ObjectID)
                    rfqVendorItem.UnitPrice = rfqVendorItem.UnitPriceInSelectedCurrency;
                else
                    // FIX: 2011.05.23, Kim Foong, Round the UnitPrice * Exchange Rate to 2-decimal places.
                    //rfqVendorItem.UnitPrice = rfqVendorItem.UnitPriceInSelectedCurrency * this.ForeignToBaseExchangeRate;
                    rfqVendorItem.UnitPrice = Round(rfqVendorItem.UnitPriceInSelectedCurrency * this.ForeignToBaseExchangeRate);
            }
        }


        /// <summary>
        /// Validates that the quotation from the vendor has been provided
        /// by ensuring that the quantities, unit prices
        /// </summary>
        /// <returns></returns>
        public bool ValidateQuotationProvided()
        {
            if (this.DateOfQuotation == null ||
                this.CurrencyID == null ||
                this.ForeignToBaseExchangeRate == null)
                return false;

            foreach (ORequestForQuotationVendorItem rfqVendorItem in this.RequestForQuotationVendorItems)
            {
                if (rfqVendorItem.UnitPrice == null || rfqVendorItem.QuantityProvided == null)
                    return false;
            }
            return true;
        }

        /// <summary>
        /// Updates the currencyID of each ORequestForQuotationVendorItem
        /// objects.
        /// </summary>
        public void UpdateItemCurrencies()
        {
            foreach (ORequestForQuotationVendorItem rfqVendorItem in this.RequestForQuotationVendorItems)
                rfqVendorItem.CurrencyID = this.CurrencyID;
        }


    }
}
