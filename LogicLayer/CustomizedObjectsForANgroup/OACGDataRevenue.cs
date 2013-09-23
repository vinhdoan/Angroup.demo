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
    public partial class TACGDataRevenue : LogicLayerSchema<OACGDataRevenue>
    {
        public SchemaGuid RevenueTypeID;
        public SchemaGuid ACGDataID;

        public TACGData ACGData { get { return OneToOne<TACGData>("ACGDataID"); } }
        public TACGDataRevenueItem ACGDataRevenueItem { get { return OneToMany<TACGDataRevenueItem>("ACGDataRevenueID"); } }
        public TCode RevenueType { get { return OneToOne<TCode>("RevenueTypeID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract partial class OACGDataRevenue : LogicLayerPersistentObject
    {

        /// <summary>
        /// [Column] Gets or sets the RevenueTypeID.
        /// </summary>
        public abstract Guid? RevenueTypeID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the ACGDataID.
        /// </summary>
        public abstract Guid? ACGDataID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the ACGData
        /// </summary>
        public abstract OACGData ACGData { get; set; }
        /// <summary>
        /// [Column] Gets or sets the RevenueType
        /// </summary>
        public abstract OCode RevenueType { get; set; }
        /// <summary>
        /// [Column] Gets or sets the ACGDataRevenueItem.
        /// </summary>
        public abstract DataList<OACGDataRevenueItem> ACGDataRevenueItem { get; set; }
        /// <summary>
        /// [Column] Create ACGDataRevenue with ACGDataRevenueItem
        /// </summary>
        public static OACGDataRevenue CreateRevenue(OCode code)
        {

            OACGDataRevenue obj = TablesLogic.tACGDataRevenue.Create();
            obj.RevenueTypeID = code.ObjectID;
            
            OACGDataRevenueItem revenue = TablesLogic.tACGDataRevenueItem.Create();
            revenue.ACGDataRevenueID = obj.ObjectID;
            revenue.ACGDataRevenue = obj;
            revenue.EntryType = 0;
            revenue.Month01Amount = 0;
            revenue.Month02Amount = 0;
            revenue.Month03Amount = 0;
            revenue.Month04Amount = 0;
            revenue.Month05Amount = 0;
            revenue.Month06Amount = 0;
            revenue.Month07Amount = 0;
            revenue.Month08Amount = 0;
            revenue.Month09Amount = 0;
            revenue.Month10Amount = 0;
            revenue.Month11Amount = 0;
            revenue.Month12Amount = 0;
            obj.ACGDataRevenueItem.Add(revenue);

            OACGDataRevenueItem revenue1 = TablesLogic.tACGDataRevenueItem.Create();
            revenue1.ACGDataRevenueID = obj.ObjectID;
            revenue1.ACGDataRevenue = obj;
            revenue1.EntryType = 1;
            revenue1.Month01Amount = 0;
            revenue1.Month02Amount = 0;
            revenue1.Month03Amount = 0;
            revenue1.Month04Amount = 0;
            revenue1.Month05Amount = 0;
            revenue1.Month06Amount = 0;
            revenue1.Month07Amount = 0;
            revenue1.Month08Amount = 0;
            revenue1.Month09Amount = 0;
            revenue1.Month10Amount = 0;
            revenue1.Month11Amount = 0;
            revenue1.Month12Amount = 0;
            obj.ACGDataRevenueItem.Add(revenue1);

            return obj;
        }

    }

}
