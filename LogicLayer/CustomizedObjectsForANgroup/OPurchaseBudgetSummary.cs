//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Reflection;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPurchaseBudgetSummary : LogicLayerSchema<OPurchaseBudgetSummary>
    {
        public SchemaDecimal TotalReallocation;
        public SchemaDecimal TotalAvailableAfterDeduction;
    }


    /// <summary>
    /// Represents the budget distributions in a purchase request, request for quotation
    /// or a purchase order object.
    /// </summary>
    public abstract partial class OPurchaseBudgetSummary : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the total reallocation at 
        /// the point when the WJ/RFQ/PO was approved.
        /// This value includes the consumption from this WJ/RFQ/PO.
        /// </summary>
        public abstract decimal? TotalReallocation { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total available at 
        /// the point when the WJ/RFQ/PO was submitted.
        /// This value is the balance after the consumption from this RFQ.
        /// </summary>
        public abstract decimal? TotalAvailableAfterDeduction { get; set; }


        /// <summary>
        /// [Column] Creates a set of budget summaries and stamps
        /// the available balances at this current point in time.
        /// </summary>
        /// <returns></returns>
        public static List<OPurchaseBudgetSummary> CreateBudgetSummariesForSubmission(List<OBudgetTransactionLog> transactions)
        {
            List<OPurchaseBudgetSummary> budgetSummaries = new List<OPurchaseBudgetSummary>();

            // Gets a data table of all available balances,
            // based the budget and budget period in the list 
            // of transactions.
            //
            DataTable dt = OBudgetPeriod.GetAvailableBalanceByTransactions(transactions);

            // Load all budgets.
            //
            List<Guid> budgetIds = new List<Guid>();
            foreach (DataRow dr in dt.Rows)
                budgetIds.Add((Guid)dr["BudgetID"]);
            List<OBudget> budgets = TablesLogic.tBudget.LoadList(TablesLogic.tBudget.ObjectID.In(budgetIds));
            Hashtable hashBudgets = new Hashtable();
            foreach (OBudget budget in budgets)
                hashBudgets[budget.ObjectID.Value] = budget;

            // Create a budget summary for each row returned
            // by the GetAvailableBalanceByTransactions above.
            //
            foreach (DataRow dr in dt.Rows)
            {
                OPurchaseBudgetSummary budgetSummary = TablesLogic.tPurchaseBudgetSummary.Create();
                budgetSummary.BudgetID = (Guid)dr["BudgetID"];
                if (dr["BudgetPeriodID"] != DBNull.Value)
                    budgetSummary.BudgetPeriodID = (Guid)dr["BudgetPeriodID"];
                budgetSummary.AccountID = (Guid)dr["AccountID"];
                budgetSummary.TotalAvailableAdjusted = (decimal)dr["Adjusted"];
                budgetSummary.TotalAvailableBeforeSubmission = (decimal)dr["Balance"];
                
                // Compute the total amount used to be committed.
                //
                decimal totalAmountToCommit = 0;
                foreach (OBudgetTransactionLog transaction in transactions)
                    if (transaction.TransferFromBudgetTransactionLogID == null &
                        transaction.AccountID == budgetSummary.AccountID &&
                        transaction.BudgetID == budgetSummary.BudgetID &&
                        transaction.BudgetPeriodID == budgetSummary.BudgetPeriodID)
                        totalAmountToCommit += transaction.TransactionAmount.Value;

                OBudget budget = hashBudgets[budgetSummary.BudgetID.Value] as OBudget;

                if (budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission)
                    budgetSummary.TotalAvailableAtSubmission = budgetSummary.TotalAvailableBeforeSubmission - totalAmountToCommit;
                else if (budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtApproval)
                    budgetSummary.TotalAvailableAtSubmission = budgetSummary.TotalAvailableBeforeSubmission;

                budgetSummary.TotalAvailableAfterDeduction = budgetSummary.TotalAvailableBeforeSubmission - totalAmountToCommit;

                budgetSummaries.Add(budgetSummary);
            }

            return budgetSummaries;
        }


    }

}

