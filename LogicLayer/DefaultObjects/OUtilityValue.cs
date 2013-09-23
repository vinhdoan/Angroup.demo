//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("UtilityValue")]
    [Serializable] public partial class TUtilityValue : LogicLayerSchema<OUtilityValue>
    {       
        public SchemaGuid UtilityID;
        public SchemaGuid LocationTypeUtilityID;
        public SchemaDecimal Value;

        public TUtility Utility { get { return OneToOne<TUtility>("UtilityID"); } }
        public TLocationTypeUtility LocationTypeUtility { get { return OneToOne<TLocationTypeUtility>("LocationTypeUtilityID"); } }

    }


    /// <summary>
    /// Represents a line item entry that contains the
    /// reading of a location type parameter.
    /// </summary>
    [Serializable] public abstract partial class OUtilityValue : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Utility table 
        /// that indicates the utility entry object containing this
        /// record.
        /// </summary>
        public abstract Guid? UtilityID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the LocationTypePoint table 
        /// that indicates the parameter this reading / value is for.
        /// </summary>
        public abstract Guid? LocationTypeUtilityID { get; set; } 

        /// <summary>
        /// [Column] Gets or sets the value of the reading for this
        /// record.
        /// </summary>
        public abstract Decimal? Value { get; set; }

        /// <summary>
        /// Gets or sets the OUtility object that represents
        /// the utility entry object containing this
        /// record.
        /// </summary>        
        public abstract OUtility Utility { get;set; }

        /// <summary>
        /// Gets or sets the OLocationTypeUtility object that represents
        /// the parameter this reading / value is for.
        /// </summary>
        public abstract OLocationTypeUtility LocationTypeUtility { get; set; }
        
    }
}
