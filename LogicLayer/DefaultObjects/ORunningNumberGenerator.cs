//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Ciloci.Flee;
using Anacle.DataFramework;

namespace LogicLayer
{
    public class TRunningNumberGenerator : LogicLayerSchema<ORunningNumberGenerator>
    {
        [Size(100)]
        public SchemaString ObjectTypeName;
        [Size(10)]
        public SchemaString ObjectTypeCode;
        public SchemaInt RunningNumberBehavior;
        public SchemaInt IsLocationOrEquipmentCodeAdded;
        [Size(100)]
        public SchemaString FormatString;
        [Size(500)]
        public SchemaString FLEECondition;
        public SchemaInt UsesAdditionalCode;
        [Size(500)]
        public SchemaString FLEEAdditionalCodeExpression;
    }

    /// <summary>
    /// Represents a set of configurable parameters to set up the running
    /// number generation of any object in the system.
    /// </summary>
    public abstract class ORunningNumberGenerator : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the object type name
        /// that the running number generator is configured for.
        /// </summary>
        public abstract String ObjectTypeName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the code used to 
        /// generate all running numbers for this 
        /// </summary>
        public abstract String ObjectTypeCode { get; set; }

        /// <summary>
        /// [Column] Gets or sets how the running numbers
        /// are generated.
        /// <list>
        ///     <para>0 - Consecutive running numbers that increments by 1 each time it is generated, regardless of the date. </para>
        ///     <para>1 - Consecutive running numbers that increments by 1 for the same month and restarts from 1 for a new month.</para>
        ///     <para>2 - Consecutive running numbers that increments by 1 for the same year and restarts from 1 for a new year.</para>
        /// </list>
        /// </summary>
        public abstract Int32? RunningNumberBehavior { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether 
        /// the location's or equipment's code should be added
        /// to the running number. If an object has an equipment
        /// defined, the equipment's code will always override 
        /// the location's code.
        /// </summary>
        public abstract Int32? IsLocationOrEquipmentCodeAdded { get; set; }

        /// <summary>
        /// [Column] Gets or sets the formatting string used to
        /// construct the final running number.
        /// <para></para>
        /// The parameters are used:
        /// <list>
        ///   <item>{0} is the actual running number.</item>
        ///   <item>{1} is the date</item>
        ///   <item>{2} is the object type code.</item>
        ///   <item>{3} is the location/equipment code where applicable.</item>
        ///   <item>{4} is the additional code (based on an expression) where applicable.</item>
        /// </list>
        /// <para></para>
        /// For example, to generate a running number of the following format:
        /// <para></para>
        /// &nbsp; &nbsp; &nbsp; &nbsp; "HC-INV-200901-000001", 
        /// <para></para>
        /// The running number generator should be configured such that the 
        /// ObjectTypeCode is "INV" and the format string is 
        /// "{2}-INV-{1:yyyyMM}-{0:000000}".
        /// <para></para>
        /// </summary>
        public abstract string FormatString { get; set; }


        /// <summary>
        /// [Column] Gets or sets the Fast Lightweight Expression Evaluator
        /// condition that returns a flag indicating whether this document
        /// template is applicable to the object.
        /// </summary>
        public abstract string FLEECondition { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether an additional
        /// code is to be added to the running number based on an expression
        /// specified in the FLEEAdditionalCodeExpression field.
        /// </summary>
        public abstract int? UsesAdditionalCode { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the Fast Lightweight Expression Evaluator 
        /// expression that returns a string for the additional code that
        /// can be added to the running number. When added to the running
        /// number, it can be formatted using the {4} placeholder.
        /// </summary>
        public abstract string FLEEAdditionalCodeExpression { get; set; }

        /// <summary>
        /// Gets a string of text describing the running number behavior.
        /// </summary>
        public string RunningNumberBehaviorText
        {
            get
            {
                if (this.RunningNumberBehavior == RunningNumberIncrementBehavior.IncrementForever)
                    return Resources.Strings.RunningNumberGenerator_IncrementForever;
                else if (this.RunningNumberBehavior == RunningNumberIncrementBehavior.ResetEveryMonth)
                    return Resources.Strings.RunningNumberGenerator_ResetEveryMonth;
                else if (this.RunningNumberBehavior == RunningNumberIncrementBehavior.ResetEveryYear)
                    return Resources.Strings.RunningNumberGenerator_ResetEveryYear;
                else if (this.RunningNumberBehavior == RunningNumberIncrementBehavior.ResetEveryYearInclCurrentYearMonth)
                    return Resources.Strings.RunningNumberGenerator_ResetEveryYearIncCurrentYearMonth;
                return "";
            }
        }


        /// <summary>
        /// Gets a string of text describing whether the
        /// location/equipment code should be added to the
        /// running number.
        /// </summary>
        public string IsLocationOrEquipmentCodeAddedText
        {
            get
            {
                if (IsLocationOrEquipmentCodeAdded == 0)
                    return Resources.Strings.RunningNumberGenerator_LocationEquipment0;
                else if (IsLocationOrEquipmentCodeAdded == 1)
                    return Resources.Strings.RunningNumberGenerator_LocationEquipment1;
                else if (IsLocationOrEquipmentCodeAdded == 2)
                    return Resources.Strings.RunningNumberGenerator_LocationEquipment2;
                return "";
            }
        }


        /// <summary>
        /// Validates that the object type has no duplicate with another
        /// running number generator record in the database.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNoDuplicateObjectTypeName()
        {
            if (TablesLogic.tRunningNumberGenerator.Load(
                TablesLogic.tRunningNumberGenerator.ObjectID != this.ObjectID &

                // 2010.04.27
                // Check for duplicate FLEE condition.
                //
                TablesLogic.tRunningNumberGenerator.FLEECondition == this.FLEECondition &
                TablesLogic.tRunningNumberGenerator.ObjectTypeName == this.ObjectTypeName) != null)
                return false;
            return true;
        }



        public bool checkFormat(ORunningNumberGenerator numberGen)
        {
            int p0 = 1234;
            DateTime p1 = DateTime.Now;
            string p2 = numberGen.ObjectTypeCode;
            string p3 = "";
            string p4 = "";
            string test1 = "";

            if (numberGen.IsLocationOrEquipmentCodeAdded == 1 ||
                numberGen.IsLocationOrEquipmentCodeAdded == 2)
                p3 = "LOC";

            if (numberGen.UsesAdditionalCode == 1)
                p4 = "P4";

            try
            {
                test1 = String.Format(numberGen.FormatString, p0, p1, p2, p3, p4);
                return true;
            }
            catch
            {
                return false;
            }

        }

        /// <summary>
        /// Generates the next running number based on the date, and the specified
        /// persistent object.
        /// </summary>
        /// <param name="date"></param>
        /// <param name="obj"></param>
        public static void GenerateNextRunningNumber(DateTime date, LogicLayerPersistentObjectBase obj)
        {
            // Gets the object type name of the object.
            //
            string objectTypeName = obj.GetType().BaseType.Name;

            // Then load the ORunningNumberGenerator object based on
            // the object type name.
            //
            // 2010.04.27
            // Modified the loader to load a list of generators.
            //
            List<ORunningNumberGenerator> rngs = TablesLogic.tRunningNumberGenerator.LoadList(
                TablesLogic.tRunningNumberGenerator.ObjectTypeName == objectTypeName);
            ORunningNumberGenerator rng = null;
            ExpressionEvaluator e = new ExpressionEvaluator();
            e["obj"] = obj;

            // 2010.04.27
            // Finds the first most applicable running number
            // generator.
            //
            foreach (ORunningNumberGenerator g in rngs)
            {
                if (g.FLEECondition == null ||
                    g.FLEECondition.Trim() == "" ||
                    e.CompileAndEvaluate<bool>(g.FLEECondition) == true)
                {
                    rng = g;
                    break;
                }
            }


            // If no configuration is available, then we simply just create a running
            // number that looks like #00000001 (with 8 digits).
            //
            if (rng == null)
            {
                obj.ObjectNumber = String.Format("#{0:00000000}",
                    ORunningNumber.GenerateNextNumber(new DateTime(1, 1, 1), objectTypeName, "#"));
                return;
            }

            string result = "";
            using (Connection c = new Connection())
            {
                // Determine the date/time to be used to construct the next
                // running number.
                //
                DateTime p1;
                if (rng.RunningNumberBehavior == RunningNumberIncrementBehavior.ResetEveryMonth)
                    p1 = new DateTime(date.Year, date.Month, 1);
                else if (rng.RunningNumberBehavior == RunningNumberIncrementBehavior.ResetEveryYear ||
                         rng.RunningNumberBehavior == RunningNumberIncrementBehavior.ResetEveryYearInclCurrentYearMonth)
                    p1 = new DateTime(date.Year, 1, 1);
                else
                    p1 = new DateTime(1, 1, 1);

                // The object type code.
                //
                string p2 = rng.ObjectTypeCode;

                // Try to determine the location/equipment code
                //
                string p3 = "";
                if (rng.IsLocationOrEquipmentCodeAdded == 1)
                {
                    if (obj.TaskEquipments != null && obj.TaskEquipments.Count > 0)
                    {
                        ExpressionCondition cond = Query.True;
                        foreach (OEquipment equipment in obj.TaskEquipments)
                            cond = cond & equipment.HierarchyPath.Like(TablesLogic.tEquipment.HierarchyPath + "%");
                        OEquipment equipment2 = TablesLogic.tEquipment.Load(
                            TablesLogic.tEquipment.RunningNumberCode != null &
                            TablesLogic.tEquipment.RunningNumberCode != "" &
                            cond,
                            TablesLogic.tEquipment.HierarchyPath.Length().Desc);

                        if (equipment2 != null)
                            p3 = equipment2.RunningNumberCode;
                    }
                    else if (obj.TaskLocations != null && obj.TaskLocations.Count > 0)
                    {
                        ExpressionCondition cond = Query.True;
                        foreach (OLocation location in obj.TaskLocations)
                            cond = cond & location.HierarchyPath.Like(TablesLogic.tLocation.HierarchyPath + "%");
                        OLocation location2 = TablesLogic.tLocation.Load(
                            TablesLogic.tLocation.RunningNumberCode != null &
                            TablesLogic.tLocation.RunningNumberCode != "" &
                            cond,
                            TablesLogic.tLocation.HierarchyPath.Length().Desc);

                        if (location2 != null)
                            p3 = location2.RunningNumberCode;
                    }
                }
                else if (rng.IsLocationOrEquipmentCodeAdded == 2)
                {
                    if (obj.TaskLocations != null && obj.TaskLocations.Count > 0)
                    {
                        ExpressionCondition cond = Query.True;
                        foreach (OLocation location in obj.TaskLocations)
                            cond = cond & location.HierarchyPath.Like(TablesLogic.tLocation.HierarchyPath + "%");
                        OLocation location2 = TablesLogic.tLocation.Load(
                            TablesLogic.tLocation.RunningNumberCode != null &
                            TablesLogic.tLocation.RunningNumberCode != "" &
                            cond,
                            TablesLogic.tLocation.HierarchyPath.Length().Desc);

                        if (location2 != null)
                            p3 = location2.RunningNumberCode;
                    }
                }

                // Adds the additional code.
                string p4 = "";
                if (rng.UsesAdditionalCode == 1)
                {
                    if (rng.FLEEAdditionalCodeExpression != null ||
                        rng.FLEEAdditionalCodeExpression.Trim() != "")
                    {
                        string additionalCode = e.CompileAndEvaluate<string>(rng.FLEEAdditionalCodeExpression);
                        if (additionalCode != null)
                            p4 = additionalCode;
                    }
                }

                // Generates the next number based on all the information
                // that we have.
                //
                int p0 = 0;
                if (p4 == null || p4 == "")
                    p0 = ORunningNumber.GenerateNextNumber(p1, rng.ObjectTypeName, "[" + p2 + "][" + p3 + "]");
                else
                    p0 = ORunningNumber.GenerateNextNumber(p1, rng.ObjectTypeName, "[" + p2 + "][" + p3 + "][" + p4 + "]");
                if (rng.RunningNumberBehavior == RunningNumberIncrementBehavior.ResetEveryYearInclCurrentYearMonth)
                    p1 = new DateTime(date.Year, date.Month, 1);
                result = String.Format(rng.FormatString, p0, p1, p2, p3, p4);
                c.Commit();
            }
            obj.ObjectNumber = result;
        }


    }


    /// <summary>
    /// Represents the different types of running numbers.
    /// </summary>
    public class RunningNumberIncrementBehavior
    {
        /// <summary>
        /// The running number increments forever, regardless of 
        /// the date.
        /// </summary>
        public const int IncrementForever = 0;

        /// <summary>
        /// The running number increments each time it is generated,
        /// but resets itself in a new month.
        /// </summary>
        public const int ResetEveryMonth = 1;

        /// <summary>
        /// The running number increments each time it is generated,
        /// but resets itself in a new year.
        /// </summary>
        public const int ResetEveryYear = 2;
        /// <summary>
        /// The running number increments and resets to zero every year, but include the current year/month in the running number
        /// </summary>
        public const int ResetEveryYearInclCurrentYearMonth = 3;
    }
}
