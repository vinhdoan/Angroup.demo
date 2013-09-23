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
    /// <summary>
    /// Summary description for OLocationType
    /// </summary>
    [Database("#database"), Map("LocationTypeParameter")]
    [Serializable] public partial class TLocationTypeParameter : LogicLayerSchema<OLocationTypeParameter>
    {
        public SchemaGuid LocationTypeID;
        public SchemaGuid UnitOfMeasureID;

        public TLocationType LocationType { get { return OneToOne<TLocationType>("LocationTypeID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
    }


    [Serializable] public abstract partial class OLocationTypeParameter : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// LocationType table.
        /// </summary>
        public abstract Guid? LocationTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets to the foreign key to the
        /// Code table to represent the unit of measure this
        /// reading is taken in.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// Gets or sets the OLocationType object that contains
        /// this location type parameter.
        /// </summary>
        public abstract OLocationType LocationType { get; set; }

        /// <summary>
        /// Gets the OCode object representing the unit of
        /// measure that this parameter is taken in.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set; }


        /// <summary>
        /// Gets a list of location type parameters based on
        /// location type ID.
        /// </summary>
        /// <param name="locationTypeId"></param>
        /// <returns></returns>
        public static List<OLocationTypeParameter> GetLocationTypeParameters(Guid locationTypeId)
        {
            return TablesLogic.tLocationTypeParameter.LoadList(
                TablesLogic.tLocationTypeParameter.LocationTypeID == locationTypeId);
        }
    }
}