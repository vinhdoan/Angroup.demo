//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OBudgetGroup
    /// </summary>
    [Database("#database"), Map("BudgetGroup")]
    [Serializable]
    public partial class TBudgetGroup : LogicLayerSchema<OBudgetGroup>
    {
        [Size(255)]
        public SchemaString Description;
        public TPosition Positions { get { return ManyToMany<TPosition>("BudgetGroupPosition", "BudgetGroupID", "PositionID"); } }
        public TBudget Budgets { get { return ManyToMany<TBudget>("BudgetBudgetGroup", "BudgetGroupID", "BudgetID"); } }
        public SchemaString IworkflowDepartmentSN;
    }


    [Serializable]
    public abstract partial class OBudgetGroup : LogicLayerPersistentObject
    {
        public abstract string Description { get; set; }
        public abstract string IworkflowDepartmentSN { get; set; }
        public abstract DataList<OPosition> Positions { get; set; }
        public abstract DataList<OBudget> Budgets {get;set;}

        /// <summary>
        /// Disallow delete if:
        /// 1. The budget group is currently attached to a position.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            int count = TablesLogic.tPosition.Select(
                TablesLogic.tPosition.BudgetGroups.ObjectID.Count())
                .Where(
                TablesLogic.tPosition.BudgetGroups.ObjectID== this.ObjectID);

            if (count > 0)
                return false;

            return true;
        }
        public static List<OBudgetGroup> GetListOfBudgetGroupsByListOfPositions(DataList<OPosition> positions)
        {
            ExpressionCondition cond = Query.False;
            //List<OBudgetGroup> budgetgroups = new List<OBudgetGroup>();
            TBudgetGroup bg = TablesLogic.tBudgetGroup;
            //TBudgetGroup bg1 = new TBudgetGroup();
            foreach (OPosition pos in positions)
                foreach (OBudgetGroup bg1 in pos.BudgetGroups)
                    cond = cond | TablesLogic.tBudgetGroup.ObjectID == bg1.ObjectID;

            return bg.LoadList(cond);
        }
    }


    
}
