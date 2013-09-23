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
    /// Summary description for OEquipmentType
    /// </summary>
    [Database("#database"), Map("EquipmentTypeParameter")]
    [Serializable] public partial class TEquipmentTypeParameter : LogicLayerSchema<OEquipmentTypeParameter>
    {
        public SchemaGuid EquipmentTypeID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaInt IsIncreasingMeter;
        public SchemaDecimal ReadingMaximum;
        public SchemaDecimal ReadingMultiplicationFactor;

        public TEquipmentType EquipmentType { get { return OneToOne<TEquipmentType>("EquipmentTypeID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
    }


    /// <summary>
    /// Represents a parameter in a collection of parameters under
    /// an equipment type.
    /// </summary>
    [Serializable]
    public abstract partial class OEquipmentTypeParameter : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to 
        /// the EquipmentType table.
        /// </summary>
        public abstract Guid? EquipmentTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the OCode table.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// Gets or sets the OEquipmentType object 
        /// that represents the equipment type that 
        /// this parameter belongs to.
        /// </summary>
        public abstract OEquipmentType EquipmentType { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that 
        /// represents the unit of measure the 
        /// reading of this parameter is taken in.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that 
        /// indicates whether this parameter is an 
        /// increasing meter value, or an absolute 
        /// meter value.
        /// <para></para>
        /// An increasing meter value refers to 
        /// meters like water consumption meters, 
        /// power usage meters, where the reading 
        /// continues to increase over time until it 
        /// reaches the maximum and restarts over.
        /// <para></para>
        /// A non-increasing meter refers to 
        /// absolute meters like thermometers.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 - This is a non-increasing 
        /// meter, like a thermometer.</item>
        /// 		<item>1 - This is an increasing meter, 
        /// like a water/power usage meter.</item>
        /// 	</list>
        /// </summary>
        public abstract Int32? IsIncreasingMeter { get; set; }

        /// <summary>
        /// [Column] Gets or sets the maximum 
        /// value that the reading can reach, 
        /// before rewinding back to zero. This is 
        /// only applicable if IsIncreasingMeter is 1.
        /// </summary>
        public abstract Decimal? ReadingMaximum { get; set; }

        /// <summary>
        /// [Column] Gets or sets the factor to be 
        /// multiplied to the reading to get the true 
        /// value of the reading.
        /// </summary>
        public abstract Decimal? ReadingMultiplicationFactor { get; set; }

        /// <summary>
        /// Gets the localized text that indicates 
        /// whether this parameter is an increasing 
        /// meter or not.
        /// </summary>
        public string IsIncreasingMeterText
        {
            get
            {
                if (IsIncreasingMeter == 1)
                    return "Yes";
                else
                    return "No";
            }
        }


        /// <summary>
        /// Gets a list of location type parameters based on
        /// equipment type ID.
        /// </summary>
        /// <param name="equipmentTypeId"></param>
        /// <returns></returns>
        public static List<OEquipmentTypeParameter> GetEquipmentTypeParameters(Guid equipmentTypeId)
        {
            return TablesLogic.tEquipmentTypeParameter.LoadList(
                TablesLogic.tEquipmentTypeParameter.EquipmentTypeID == equipmentTypeId);
        }
    }
}