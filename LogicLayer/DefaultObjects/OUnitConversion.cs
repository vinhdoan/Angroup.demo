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
    [Database("#database"), Map("UnitConversion")]
    [Serializable] public partial class TUnitConversion : LogicLayerSchema<OUnitConversion>
    {
        public SchemaGuid FromUnitOfMeasureID;

        public TCode FromUnitOfMeasure { get { return OneToOne<TCode>("FromUnitOfMeasureID"); } }
        public TUnitConversionTo UnitConversionsTo { get { return OneToMany<TUnitConversionTo>("UnitConversionID"); } }
    }


    /// <summary>
    /// Represents a record of a base unit from which conversions to 
    /// target unit can be set up.
    /// </summary>
    [Serializable] public abstract partial class OUnitConversion : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table that indicates
        /// the base unit of measure to convert from.
        /// </summary>
        public abstract Guid? FromUnitOfMeasureID { get;set;}

        /// <summary>
        /// Gets or sets the OCode object that represents the base unit measure to 
        /// convert from.
        /// </summary>
        public abstract OCode FromUnitOfMeasure { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OUnitConversionTo objects that represents all 
        /// the possible unit of measures to convert to.
        /// </summary>
        public abstract DataList<OUnitConversionTo> UnitConversionsTo { get; }

        public OUnitConversion()
        {
        }


        /// <summary>
        /// Checks if there's duplicate conversion with the same 'From' unit of measure.
        /// </summary>
        /// <returns></returns>
        public bool HasDuplicateUnitOfMeasure()
        {
            return TablesLogic.tUnitConversion[
                TablesLogic.tUnitConversion.FromUnitOfMeasureID == this.FromUnitOfMeasureID &
                TablesLogic.tUnitConversion.ObjectID != this.ObjectID].Count > 0;
        }


        /// <summary>
        /// Find the unit conversion based on the target UnitOfMeasureID.
        /// </summary>
        /// <param name="TargetUnitOfMeasureID"></param>
        /// <returns></returns>
        public OUnitConversionTo FindConversion(Guid TargetUnitOfMeasureID)
        {
            foreach (OUnitConversionTo unit in UnitConversionsTo)
                if (unit.ToUnitOfMeasureID == TargetUnitOfMeasureID)
                    return unit;
            return null;
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Find the unit conversion based on base UnitOfMeasureID and the target UnitOfMeasureID.
        /// </summary>
        /// <param name="BaseUnitOfMeasureID"></param>
        /// <param name="TargetUnitOfMeasureID"></param>
        /// <param name="reverse"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        protected static OUnitConversionTo FindConversion(Guid FromUnitOfMeasureID, Guid ToUnitOfMeasureID)
        {
            List<OUnitConversionTo> to = TablesLogic.tUnitConversionTo[
                TablesLogic.tUnitConversionTo.ToUnitOfMeasureID==ToUnitOfMeasureID &
                TablesLogic.tUnitConversionTo.UnitConversion.FromUnitOfMeasureID==FromUnitOfMeasureID];

            if (to.Count > 0)
                return to[0];
            return null;
        }



        //---------------------------------------------------------------
        /// <summary>
        /// Find the conversion factor from the fromUnitOfMeasureID,
        /// to the toUnitOfMeasureID.
        /// </summary>
        /// <param name="fromUnitOfMeasureID"></param>
        /// <param name="toUnitOfMeasureID"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static decimal FindConversionFactor(Guid fromUnitOfMeasureID, Guid toUnitOfMeasureID)
        {
            OUnitConversionTo to = FindConversion(fromUnitOfMeasureID, toUnitOfMeasureID);

            if (to == null)
                return 1.0M;
            else
                return (decimal)to.ConversionFactor;
        }


        /// <summary>
        /// Gets a list of all possible target conversions given the base UnitOfMeasureID, and
        /// returns it in a DataTable. This datatable will also include the base UnitOfMeasureID,
        /// and the conversion factor for this will be 1.0.
        /// </summary>
        /// <param name="FromUnitOfMeasureID"></param>
        /// <returns></returns>
        public static DataTable GetConversions(Guid? fromUnitOfMeasureID, Guid? includingUnitOfMeasureID)
        {
            DataTable dt = Query.Select(
                TablesLogic.tUnitConversionTo.ToUnitOfMeasureID,
                TablesLogic.tUnitConversionTo.ToUnitOfMeasure.ObjectName)
                .Where(
                TablesLogic.tUnitConversionTo.UnitConversion.FromUnitOfMeasureID == fromUnitOfMeasureID);

            if (includingUnitOfMeasureID != null)
            {
                bool found = false;
                foreach (DataRow dr in dt.Rows)
                    if ((Guid)dr["ToUnitOfMeasureID"] == includingUnitOfMeasureID.Value)
                    {
                        found = true;
                        break;
                    }
                if (!found)
                {
                    DataRow dr2 = dt.NewRow();
                    dr2["ToUnitOfMeasureID"] = includingUnitOfMeasureID.Value;
                    dr2["ObjectName"] = TablesLogic.tCode.Load(includingUnitOfMeasureID).ObjectName;
                    dt.Rows.Add(dr2);
                }
            }

            DataRow dr3 = dt.NewRow();
            dr3["ToUnitOfMeasureID"] = fromUnitOfMeasureID;
            dr3["ObjectName"] = TablesLogic.tCode[fromUnitOfMeasureID].ObjectName;
            dt.Rows.InsertAt(dr3, 0);
            return dt;
        }



        //---------------------------------------------------------------
        /// <summary>
        /// Compute the conversion such that 
        /// the result = baseQuantity * conversionFactor.
        /// </summary>
        /// <param name="reverse"></param>
        /// <param name="baseUnitOfMeasureId"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <param name="v"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static decimal ConvertBaseToActualQuantity(Guid baseUnitOfMeasureId, Guid actualUnitOfMeasureId, decimal baseQuantity)
        {
            if (baseUnitOfMeasureId == actualUnitOfMeasureId)
            {
                return baseQuantity; // no conversion
            }
            else
            {
                OUnitConversionTo to = FindConversion(baseUnitOfMeasureId, actualUnitOfMeasureId);
                if (to != null)
                    return (decimal)to.ConversionFactor * baseQuantity;
                else
                    return 0;
            }
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Compute the conversion such that 
        /// the result = baseCost / conversionFactor.
        /// </summary>
        /// <param name="reverse"></param>
        /// <param name="baseUnitOfMeasureId"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <param name="v"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static decimal ComputeBaseToActualCost(Guid baseUnitOfMeasureId, Guid actualUnitOfMeasureId, decimal baseCost)
        {
            if (baseUnitOfMeasureId == actualUnitOfMeasureId)
            {
                return baseCost; // no conversion
            }
            else
            {
                OUnitConversionTo to = FindConversion(baseUnitOfMeasureId, actualUnitOfMeasureId);
                if (to != null)
                    return baseCost / (decimal)to.ConversionFactor;
                else
                    return baseCost;
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Convert actual quantity to base quantity.
        /// </summary>
        /// <param name="baseUnitOfMeasureId"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <param name="actualQuantity"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static decimal ConvertActualToBaseQuantity(Guid baseUnitOfMeasureId, Guid actualUnitOfMeasureId, decimal actualQuantity)
        {
            return ComputeBaseToActualCost(baseUnitOfMeasureId, actualUnitOfMeasureId, actualQuantity);
        }

        //----------------------------------------------------------------
        /// <summary>
        /// Convert actual quantity to base quantity.
        /// </summary>
        /// <param name="baseUnitOfMeasureId"></param>
        /// <param name="actualUnitOfMeasureId"></param>
        /// <param name="actualQuantity"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public static decimal ConvertActualToBaseCost(Guid baseUnitOfMeasureId, Guid actualUnitOfMeasureId, decimal actualQuantity)
        {
            return ConvertBaseToActualQuantity(baseUnitOfMeasureId, actualUnitOfMeasureId, actualQuantity);
        }



    }
}

