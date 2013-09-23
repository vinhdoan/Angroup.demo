//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Globalization;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    //-----------------------------------------------------
    // TO be removed.
    //-----------------------------------------------------
    public partial class TCurrency : LogicLayerSchema<OCurrency>
    {
        [Size(255)]
        public SchemaString Description;
        
        [Size(5)]
        public SchemaString CurrencySymbol;

        public TCurrencyExchangeRate CurrencyExchangeRates { get { return OneToMany<TCurrencyExchangeRate>("CurrencyID"); } }
    }


    /// <summary>
    /// 
    /// </summary>
    public abstract partial class OCurrency : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets a human-readable description associated with this
        /// currency. An example of such description would be, 'American Dollar', 
        /// 'Sterling Pound'
        /// </summary>
        public abstract String Description { get; set; }


        /// <summary>
        /// [Column] Gets or sets a maximum five-character symbol to represent
        /// the currency. Examples of currency symbols are '$', '£', '€'.
        /// </summary>
        public abstract String CurrencySymbol { get; set; }


        /// <summary>
        /// Gets a string representation of the
        /// currency name and the description.
        /// </summary>
        public string CurrencyNameAndDescription
        {
            get
            {
                return ObjectName + ", " + Description;
            }
        }


        /// <summary>
        /// Gets a list represent the exchange rates applicable for the
        /// conversion from the base currency to this currency for specific
        /// periods.
        /// </summary>
        public abstract DataList<OCurrencyExchangeRate> CurrencyExchangeRates { get; }


        /// <summary>
        /// Gets the data format string corresponding to this
        /// currency.
        /// <para></para>
        /// This is often called in pages (Invoice, POs) where a secondary 
        /// currency will appear in addition to the base currency, so that
        /// the data format string can be set on gridview columns that
        /// display the secondary currencies.
        /// </summary>
        /// <param name="currencyName"></param>
        /// <returns></returns>
        public string DataFormatString
        {
            get
            {
                return this.CurrencySymbol + "{0:n}";
            }
        }


        /// <summary>
        /// Disallow delete:
        /// 1. If the currency is the system's base currency.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (this.ObjectID == OApplicationSetting.Current.BaseCurrencyID)
                return false;


            return true;
        }


        /// <summary>
        /// Get all currencies.
        /// </summary>
        /// <returns></returns>
        public static List<OCurrency> GetAllCurrencies()
        {
            return TablesLogic.tCurrency[Query.True];
        }


        /// <summary>
        /// Get all currencies.
        /// </summary>
        /// <returns></returns>
        public static List<OCurrency> GetAllCurrencies(Guid? includingCurrencyId)
        {
            return TablesLogic.tCurrency.LoadList(
                TablesLogic.tCurrency.IsDeleted==0 |
                TablesLogic.tCurrency.ObjectID==includingCurrencyId, true);
        }


        /// <summary>
        /// Validates that the currency exchange rate does not
        /// overlap with another existing rate in this currency.
        /// </summary>
        /// <param name="currencyExchangeRate"></param>
        /// <returns></returns>
        public bool ValidateExchangeRateHasNoOverlaps(OCurrencyExchangeRate currencyExchangeRate)
        {
            foreach (OCurrencyExchangeRate existingExchangeRate in this.CurrencyExchangeRates)
            {
                if (currencyExchangeRate.ObjectID == existingExchangeRate.ObjectID)
                    continue;

                // 
                // 
                DateTime? existingRateStartDate = existingExchangeRate.EffectiveStartDate;
                if (existingRateStartDate == null)
                    existingRateStartDate = DateTime.MinValue;

                DateTime? existingRateEndDate = existingExchangeRate.EffectiveEndDate;
                if (existingRateEndDate == null)
                    existingRateEndDate = DateTime.MaxValue;

                DateTime? currentRateStartDate = currencyExchangeRate.EffectiveStartDate;
                if (currentRateStartDate == null)
                    currentRateStartDate = DateTime.MinValue;

                DateTime? currentRateEndDate = currencyExchangeRate.EffectiveEndDate;
                if (currentRateEndDate == null)
                    currentRateEndDate = DateTime.MaxValue;


                if ((existingRateStartDate <= currentRateStartDate &&
                    currentRateStartDate <= existingRateEndDate) ||
                    (existingRateStartDate <= currentRateEndDate &&
                    currentRateEndDate <= existingRateEndDate) ||
                    (currentRateStartDate <= existingRateStartDate &&
                    existingRateEndDate <= currentRateEndDate))
                    return false;
            }
            return true;
        }


        /// <summary>
        /// Gets the foreign-to-base exchange rate of the specified
        /// currency ID given the date to query.
        /// </summary>
        /// <param name="date"></param>
        /// <param name="currencyId"></param>
        /// <returns></returns>
        public static decimal? GetExchangeRate(DateTime date, Guid currencyId)
        {
            if (currencyId == OApplicationSetting.Current.BaseCurrencyID)
                return 1.0M;

            TCurrencyExchangeRate er = TablesLogic.tCurrencyExchangeRate;

            return (decimal?)er.Select(er.ForeignToBaseExchangeRate)
                .Where(er.Currency.ObjectID == currencyId & er.EffectiveStartDate <= date & date <= er.EffectiveEndDate);
        }

    }
}
