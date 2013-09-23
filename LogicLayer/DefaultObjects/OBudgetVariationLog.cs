//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Created by TVO
    /// </summary>
    [Database("#database"), Map("BudgetVariationLog")]
    [Serializable] public partial class TBudgetVariationLog : LogicLayerSchema<OBudgetVariationLog>
    {
        public SchemaInt VariationType;
        public SchemaGuid BudgetID;
        public SchemaGuid BudgetPeriodID;
        public SchemaGuid AccountID;
        public SchemaInt IntervalNumber;
        public SchemaDecimal VariationAmount;
        public SchemaDateTime DateOfVariation;
        public SchemaGuid BudgetReallocationID;
        public SchemaGuid BudgetAdjustmentID;
    }


    /// <summary>
    /// Represents a variation log on the budget.
    /// </summary>
    [Serializable] 
    public abstract partial class OBudgetVariationLog : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the type of variation.
        /// <list>
        ///     <para>1 - Adjustment </para>
        ///     <para>2 - Reallocation </para>
        /// </list>
        /// </summary>
        public abstract int? VariationType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the budget that this variation
        /// applies to.
        /// </summary>
        public abstract Guid? BudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the budget period that this variation
        /// applies to.
        /// </summary>
        public abstract Guid? BudgetPeriodID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the account that this variation
        /// applies to.
        /// </summary>
        public abstract Guid? AccountID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the interval number of the budget period
        /// that this variation applies.
        /// </summary>
        public abstract int? IntervalNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the value to adjust the budget by.
        /// A positive value indicates an variation upward, a negative
        /// value indicates an variation downward.
        /// </summary>
        public abstract decimal? VariationAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the variation was committed.
        /// </summary>
        public abstract DateTime? DateOfVariation { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// BudgetReallocation table that indicates the budget
        /// reallocation record that committed this variation.
        /// </summary>
        public abstract Guid? BudgetReallocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// BudgetAdjustment table that indicates the budget
        /// adjustment record that committed this variation.
        /// </summary>
        public abstract Guid? BudgetAdjustmentID { get; set; }

    }


    /// <summary>
    /// Represents the different types of transactions.
    /// </summary>
    public class BudgetVariationType
    {
        public const int Adjustment = 0;
        public const int Reallocation = 1;
    }
}
