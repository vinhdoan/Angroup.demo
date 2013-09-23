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
    public partial class TCurrencyExchangeRate : LogicLayerSchema<OCurrencyExchangeRate>
    {
        public SchemaGuid CurrencyID;
        public SchemaDateTime EffectiveStartDate;
        public SchemaDateTime EffectiveEndDate;
        public SchemaDecimal ForeignToBaseExchangeRate;

        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
    }


    public abstract partial class OCurrencyExchangeRate : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Currency
        /// table that represents the currency that this exchange
        /// rate is associated with.
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the effective start date that this
        /// exchange rate application from.
        /// </summary>
        public abstract DateTime? EffectiveStartDate { get; set; }


        /// <summary>
        /// [Column] Gets or sets the effective end date that this
        /// exchange rate application to.
        /// </summary>
        public abstract DateTime? EffectiveEndDate { get; set; }


        /// <summary>
        /// [Column] Gets or sets the exchange rate, or the factor 
        /// used to multiply an amount in the foreign currency to obtain
        /// the amount in the base currency.
        /// <para></para>
        /// For example, if the system's base currency is SGD, and
        /// we are defining 0.89 as the foreign-to-base exchange rate
        /// for NZD, that means 1 NZD will buy us 0.89 SGD.
        /// </summary>
        public abstract Decimal? ForeignToBaseExchangeRate { get; set; }
        

        //----------------------------------------------------------------
        /// <summary>
        /// Allow deactivation only if the object is new
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------
        public override bool IsRemovable()
        {
            return this.IsNew;
        }
    }
}
