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
    /// Summary description for TACGDataCarPark
    /// </summary>
    public partial class TACGDataCarPark : LogicLayerSchema<OACGDataCarPark>
    {
        public SchemaGuid ACGDataID;
        public SchemaInt Month;
        public SchemaInt TotalNumberOfLots;
        public SchemaInt SeasonLotSold;
        public SchemaDecimal TenantRateInclGST;
        public SchemaDecimal NonTenantRateInclGST;
        public SchemaDecimal PerEntryCost;
        public TACGData ACGData { get { return OneToOne<TACGData>("ACGDataID"); } }
    }


    /// <summary>
    /// Summary description for OACGDataCarPark
    /// </summary>
    public abstract partial class OACGDataCarPark : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the ACGDataID.
        /// </summary>
        public abstract Guid? ACGDataID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month.
        /// </summary>
        public abstract int? Month { get; set; }
        /// <summary>
        /// [Column] Gets or sets the TotalNumberOfLots.
        /// </summary>
        public abstract int? TotalNumberOfLots { get; set; }
        /// <summary>
        /// [Column] Gets or sets the SeasonLotSold.
        /// </summary>
        public abstract int? SeasonLotSold { get; set; }
        /// <summary>
        /// [Column] Gets or sets the TenantRateInclGST.
        /// </summary>
        public abstract Decimal? TenantRateInclGST { get; set; }
        /// <summary>
        /// [Column] Gets or sets the NonTenantRateInclGST.
        /// </summary>
        public abstract Decimal? NonTenantRateInclGST { get; set; }
        /// <summary>
        /// [Column] Gets or sets the PerEntryCost.
        /// </summary>
        public abstract Decimal? PerEntryCost { get; set; }

        /// <summary>
        /// [Column] Gets or sets the ACGData
        /// </summary>
        public abstract OACGData ACGData { get; set; }

        public String MonthText
        {
            get
            {
                if (this.Month == 1)
                    return "Jan";
                else if (this.Month == 2)
                    return "Feb";
                else if (this.Month == 3)
                    return "Mar";
                else if (this.Month == 4)
                    return "Apr";
                else if (this.Month == 5)
                    return "May";
                else if (this.Month == 6)
                    return "Jun";
                else if (this.Month == 7)
                    return "Jul";
                else if (this.Month == 8)
                    return "Aug";
                else if (this.Month == 9)
                    return "Sep";
                else if (this.Month == 10)
                    return "Oct";
                else if (this.Month == 11)
                    return "Nov";
                else if (this.Month == 12)
                    return "Dec";
                else return "";
            }
        }
    }

}
