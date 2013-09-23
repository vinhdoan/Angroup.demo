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
    /// </summary>
    public partial class TACGDataRevenueItem : LogicLayerSchema<OACGDataRevenueItem>
    {
        public SchemaGuid ACGDataRevenueID;

        public SchemaInt EntryType;
        public SchemaDecimal Month01Amount;
        public SchemaDecimal Month02Amount;
        public SchemaDecimal Month03Amount;
        public SchemaDecimal Month04Amount;
        public SchemaDecimal Month05Amount;
        public SchemaDecimal Month06Amount;
        public SchemaDecimal Month07Amount;
        public SchemaDecimal Month08Amount;
        public SchemaDecimal Month09Amount;
        public SchemaDecimal Month10Amount;
        public SchemaDecimal Month11Amount;
        public SchemaDecimal Month12Amount;

        public TACGDataRevenue ACGDataRevenue { get { return OneToOne<TACGDataRevenue>("ACGDataRevenueID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract partial class OACGDataRevenueItem : LogicLayerPersistentObject
    {

        /// <summary>
        /// [Column] Gets or sets the ACGDataRevenueID.
        /// </summary>
        public abstract Guid? ACGDataRevenueID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the EntryType.
        /// </summary>
        public abstract int? EntryType { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month01Amount.
        /// </summary>
        public abstract Decimal? Month01Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month02Amount
        /// </summary>
        public abstract Decimal? Month02Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month03Amount.
        /// </summary>
        public abstract Decimal? Month03Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month04Amount.
        /// </summary>
        public abstract Decimal? Month04Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month05Amount.
        /// </summary>
        public abstract Decimal? Month05Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month06Amount.
        /// </summary>
        public abstract Decimal? Month06Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month07Amount.
        /// </summary>
        public abstract Decimal? Month07Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month08Amount.
        /// </summary>
        public abstract Decimal? Month08Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month09Amount.
        /// </summary>
        public abstract Decimal? Month09Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month10Amount.
        /// </summary>
        public abstract Decimal? Month10Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month11Amount.
        /// </summary>
        public abstract Decimal? Month11Amount { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Month12Amount.
        /// </summary>
        public abstract Decimal? Month12Amount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the ACGDataRevenue
        /// </summary>
        public abstract OACGDataRevenue ACGDataRevenue { get; set; }
        /// <summary>
        /// [Column] Gets or sets the RevenueType
        /// </summary>
        public abstract OCode RevenueType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the EntryTypeText
        /// </summary>
        public String EntryTypeText
        {
            get
            {
                if (this.EntryType == 0)
                    return "Committed";
                else if (this.EntryType == 1)
                    return "Budgeted";
                else
                    return "";
            }
        }
    }

}
