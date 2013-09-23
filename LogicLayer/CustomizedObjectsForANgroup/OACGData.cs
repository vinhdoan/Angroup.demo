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
    /// Summary description for TACGData
    /// </summary>
    public partial class TACGData : LogicLayerSchema<OACGData>
    {
        public SchemaInt Year;
        public SchemaGuid LocationID;
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TACGDataCarPark ACGDataCarPark { get { return OneToMany<TACGDataCarPark>("ACGDataID"); } }
        public TACGDataRevenue ACGDataRevenue { get { return OneToMany<TACGDataRevenue>("ACGDataID"); } }
    }


    /// <summary>
    /// Summary description for OACGData
    /// </summary>
    public abstract partial class OACGData : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the Year.
        /// </summary>
        public abstract int? Year { get; set; }
        /// <summary>
        /// [Column] Gets or sets the LocationID.
        /// </summary>
        public abstract Guid? LocationID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the ACGDataID.
        /// </summary>
        public abstract Guid? ACGDataID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Location.
        /// </summary>
        public abstract OLocation Location { get; set; }
        /// <summary>
        /// [Column] Gets or sets the ACGDataCarPark.
        /// </summary>
        public abstract DataList<OACGDataCarPark> ACGDataCarPark { get; set; }
        /// <summary>
        /// [Column] Gets or sets the ACGDataRevenue.
        /// </summary>
        public abstract DataList<OACGDataRevenue> ACGDataRevenue { get; set; }
    }

}
