//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OBudget
    /// </summary>

    public partial class TBudget : LogicLayerSchema<OBudget>
    {
        public SchemaInt BudgetSpendingPolicy;
        public SchemaInt BudgetDeductionPolicy;

        public TBudgetGroup BudgetGroups { get { return ManyToMany<TBudgetGroup>("BudgetBudgetGroup", "BudgetID", "BudgetGroupID"); } }
    }


    public abstract partial class OBudget : LogicLayerPersistentObject
    {

        public abstract DataList<OBudgetGroup> BudgetGroups { get; set; }

        /// <summary>
        /// [Column] Gets or sets the future budget spending policy.
        /// <list>
        ///     <item>0 - Disallow spending from budget periods that have not been created. </item>
        ///     <item>1 - Allow spending from budget periods that have not been created. </item>
        /// </list>
        /// </summary>
        public abstract int? BudgetSpendingPolicy { get; set; }


        /// <summary>
        /// [Column] Gets or sets at which point in time the budget is deducted.
        /// <list>
        ///     <item>0 - Deducted at the point of submission of any purchase object. </item>
        ///     <item>1 - Deducted at the point of approval of any purchase object. </item>
        /// </list>
        /// </summary>
        public abstract int? BudgetDeductionPolicy { get; set; }

        /// <summary>
        /// Gets a list of budgets at or under the specified
        /// list of locations.
        /// </summary>
        /// <param name="locations"></param>
        /// <returns></returns>
        public static List<OBudget> GetBudgetsByListOfLocations(List<OLocation> locations)
        {

            ExpressionCondition cond = Query.False;
            TBudget b = TablesLogic.tBudget;
            TBudget b1 = new TBudget();

            foreach (OLocation location in locations)
                cond = cond | b1.ApplicableLocations.HierarchyPath.Like(location.HierarchyPath + "%");

            return b.LoadList(
                b1.Select(b1.ApplicableLocations.ObjectID.Count()).Where(b1.ObjectID == b.ObjectID) ==
                b1.Select(b1.ApplicableLocations.ObjectID.Count()).Where(b1.ObjectID == b.ObjectID & cond),
                b.ObjectName.Asc
                );
        }

        /// <summary>
        /// Gets a list of budget objects that cover the selected location.
        /// </summary>
        /// <param name="location"></param>
        /// <returns></returns>
        public static List<OBudget> GetCoveringBudgets(OLocation location, Guid? includingBudgetId, Guid? budgetGroupId)
        {
            return TablesLogic.tBudget.LoadList(
                (TablesLogic.tBudget.IsDeleted == 0 &
                TablesLogic.tBudget.BudgetGroups.ObjectID == budgetGroupId &
                TablesLogic.tBudget.ObjectID.In(GetCoveringBudgetIDs(location)))
                |
                TablesLogic.tBudget.ObjectID == includingBudgetId,
                true
                );
        }

        public static List<OBudget> GetCoveringBudgets(List<OLocation> location, Guid? includingBudgetId, Guid? budgetGroupId)
        {
            return TablesLogic.tBudget.LoadList(
                (TablesLogic.tBudget.IsDeleted == 0 &
                TablesLogic.tBudget.BudgetGroups.ObjectID == budgetGroupId &
                TablesLogic.tBudget.ObjectID.In(GetCoveringBudgetIDs(location)))
                |
                TablesLogic.tBudget.ObjectID == includingBudgetId,
                true
                );
        }

        public static List<OBudget> GetCoveringBudgets(OLocation location, List<Guid> includingBudgetId, Guid? budgetGroupId)
        {
            return TablesLogic.tBudget.LoadList(
                (TablesLogic.tBudget.IsDeleted == 0 &
                TablesLogic.tBudget.BudgetGroups.ObjectID == budgetGroupId &
                TablesLogic.tBudget.ObjectID.In(GetCoveringBudgetIDs(location)))
                |
                (includingBudgetId == null || includingBudgetId.Count == 0? 
                Query.False : TablesLogic.tBudget.ObjectID.In(includingBudgetId)),
                true
                );
        }


        public static List<OBudget> GetCoveringBudgets(List<OLocation> location, List<Guid> includingBudgetId, Guid? budgetGroupId)
        {
            return TablesLogic.tBudget.LoadList(
                (TablesLogic.tBudget.IsDeleted == 0 &
                TablesLogic.tBudget.BudgetGroups.ObjectID == budgetGroupId &
                TablesLogic.tBudget.ObjectID.In(GetCoveringBudgetIDs(location)))
                |
                (includingBudgetId == null || includingBudgetId.Count == 0 ?
                Query.False : TablesLogic.tBudget.ObjectID.In(includingBudgetId)),
                true
                );
        }

    }


    /// <summary>
    /// Enumerates the various deduction policies 
    /// that the user can implement for the budget.
    /// </summary>
    public class BudgetDeductionPolicy
    {
        /// <summary>
        /// Indicates the budget available balance
        /// is deducted at the point when the procurement
        /// object is submitted for approval.
        /// </summary>
        public static int DeductAtSubmission = 0;

        /// <summary>
        /// Indicates the budget available balance
        /// is deducted at the point when the procurement
        /// object is approved.
        /// </summary>
        public static int DeductAtApproval = 1;

    }
}
