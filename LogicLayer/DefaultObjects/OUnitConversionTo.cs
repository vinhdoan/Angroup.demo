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
    [Database("#database"), Map("UnitConversionTo")]
    [Serializable] public partial class TUnitConversionTo : LogicLayerSchema<OUnitConversionTo>
    {
        public SchemaGuid UnitConversionID;
        public SchemaGuid ToUnitOfMeasureID;
        public SchemaDecimal ConversionFactor;

        public TCode ToUnitOfMeasure { get { return OneToOne<TCode>("ToUnitOfMeasureID"); } }
        public TUnitConversion UnitConversion { get { return OneToOne<TUnitConversion>("UnitConversionID"); } }
    }


    /// <summary>
    /// Represents a set of conversions to a target unit, together with
    /// the conversion factor from the base unit.
    /// </summary>
    [Serializable] public abstract partial class OUnitConversionTo : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table that indicates the unit of measure to convert the base unit to.
        /// </summary>
        public abstract Guid? ToUnitOfMeasureID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the conversion factor, the factor to multiply to 
        /// convert a value in the 'from' unit of measure to the 'to' unit of 
        /// measure.
        /// <para></para>
        /// For example, if the base unit is kilogram and the quantity is 1, then 
        /// the conversion factor from 'kg' to 'g' is 1000. Therefore, 1 kg is 
        /// 1000g.
        /// </summary>
        public abstract Decimal? ConversionFactor { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents the unit of measure to convert the base unit to.
        /// </summary>
        public abstract OCode ToUnitOfMeasure { get; }
        public abstract OUnitConversion UnitConversion { get; }


        /// <summary>
        /// Count the number of decimals in the specified value.
        /// </summary>
        /// <param name="x"></param>
        /// <returns></returns>
        private int CountDecimals(decimal x)
        {
            int count = 0;

            while (true)
            {
                x = x * 10;
                decimal y = x;
                if (Decimal.Truncate(y) == y)
                    return count;
                if (count > 10)
                    return count;
                count++;
            }

        }


        /// <summary>
        /// Validates the ensure that the conversion has no 
        /// more than 4 decimal places that may cause computations
        /// to corrupt.
        /// </summary>
        /// <returns></returns>
        public bool ValidateConversionHasLessThanFourDecimalPlaces()
        {
            if(ConversionFactor!=null)
            {
                if(CountDecimals(ConversionFactor.Value) > 4 ||
                    CountDecimals(1/ConversionFactor.Value) > 4)
                    return false;
            }

            return true;
        }

    }
}

