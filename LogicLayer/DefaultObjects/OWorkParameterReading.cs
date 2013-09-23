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
    /// Summary description for OVendor
    /// </summary>
    [Database("#database"), Map("WorkParameterReading")]
    public partial class TWorkParameterReading : LogicLayerSchema<OWorkParameterReading>
    {
        public SchemaGuid WorkID; 
        public SchemaGuid EquipmentTypeParameterID;
        public SchemaGuid LocationTypeParameterID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaDecimal Reading;

        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TEquipmentTypeParameter EquipmentTypeParameter { get { return OneToOne<TEquipmentTypeParameter>("EquipmentTypeParameterID"); } }
        public TLocationTypeParameter LocationTypeParameter { get { return OneToOne<TLocationTypeParameter>("LocationTypeParameterID"); } }
    }


    /// <summary>
    /// Represents a parameter reading tied to a work object.
    /// </summary>
    public abstract partial class OWorkParameterReading : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Work table 
        /// that indicates the work that contains this reading record.
        /// </summary>
        public abstract Guid? WorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the EquipmentTypeParameter 
        /// table that indicates the equipment type parameter that this
        /// reading is taken for.
        /// </summary>
        public abstract Guid? EquipmentTypeParameterID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the LocationTypeParameter 
        /// table that indicates the location type parameter that this
        /// reading is taken for.
        /// that indicates
        /// </summary>
        public abstract Guid? LocationTypeParameterID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the unit of measure of the parameter reading.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the reading value of the parameter.
        /// </summary>
        public abstract Decimal? Reading { get; set; }

        /// <summary>
        /// Gets or sets the OWork object that represents the
        /// work object that contains this reading record.
        /// </summary>
        public abstract OWork Work { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents
        /// the unit of measure of the parameter reading.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set; }

        /// <summary>
        /// Gets or sets the OEquipmentTypeParameter object that represents
        /// the equipment type parameter that this
        /// reading is taken for.
        /// </summary>
        public abstract OEquipmentTypeParameter EquipmentTypeParameter { get; set; }

        /// <summary>
        /// Gets or sets the OLocationTypeParameter object that represents
        /// the location type parameter that this
        /// reading is taken for.
        /// </summary>
        public abstract OLocationTypeParameter LocationTypeParameter { get; set; }
    }

}