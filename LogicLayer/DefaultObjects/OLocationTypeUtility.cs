//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
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
    [Serializable]
    public partial class TLocationTypeUtility : LogicLayerSchema<OLocationTypeUtility>
    {
        public SchemaGuid LocationTypeID;
        public SchemaGuid UnitOfMeasureID;

        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
    }

    [Serializable]
    public abstract partial class OLocationTypeUtility : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] A foreign key to the LocationType table
        /// that indicates the location type this belongs under.
        /// </summary>
        public abstract Guid? LocationTypeID{ get; set; }

        /// <summary>
        /// [Column] A foreign key to the Code table
        /// that indicates the unit of measure of the values this utility
        /// record accepts.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// Gets a reference to the Code table that indicates the 
        /// unit of measure of the values this utility record accepts.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set; }
    }
}