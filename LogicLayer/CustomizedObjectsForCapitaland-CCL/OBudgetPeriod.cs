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
    /// Summary description for OBudget
    /// </summary>
    public partial class TBudgetPeriod : LogicLayerSchema<OBudgetPeriod>
    {
      
    }


    
    public abstract partial class OBudgetPeriod : LogicLayerPersistentObject, IWorkflowEnabled, IAutoGenerateRunningNumber
    {
        /// <summary>
        /// This list of budget period interval opening balance
        /// below this threshold and print out to notify users.
        /// can be further implemented to validate monthly allocated
        /// insufficient opening balance.
        /// 
        /// </summary>
        public List<LowBudgetPeriodIntervalOpeningBalance> LowBudgetPeriodIntervalOpeningBalances;

        /// <summary>
        /// Generate DataTable for determine opening balance below threshold
        /// in interval view.
        /// </summary>
        /// <param name="interval"></param>
        /// <param name="startDate"></param>
        /// <param name="budgetViewOptions"></param>
        /// <param name="variationTypes"></param>
        /// <param name="transactionTypes"></param>
        /// <param name="accountID"></param>
        /// <returns></returns>
        public DataTable GenerateIntervalViewForDetermineLowThreshold(
            int interval,
            BudgetViewOptions budgetViewOptions,
            int[] variationTypes,
            int[] transactionTypes,Guid? accountID)
        {
            List<ColumnAs> columns = new List<ColumnAs>();

            TBudgetPeriodOpeningBalance ob = TablesLogic.tBudgetPeriodOpeningBalance;
            TBudgetVariationLog var = TablesLogic.tBudgetVariationLog;
            TBudgetTransactionLog trans = TablesLogic.tBudgetTransactionLog;
            OAccount account = TablesLogic.tAccount.Load(accountID);

            columns.Add(ob.AccountID);
            columns.Add(ob.ObjectID);
            // Add a column for each of the intervals to compute
            // the total available amount for that interval.
            //
            int currentInterval = interval;
            int totalIntervals = this.TotalNumberOfIntervals;
            for (currentInterval = interval; currentInterval <= totalIntervals; currentInterval++)
            {
                columns.Add((SchemaDecimal)ob.GetColumn("OpeningBalance" + String.Format("{0:00}", currentInterval)));

                DateTime intervalStartDate = this.StartDate.Value.AddMonths(
                    (currentInterval - 1) * this.NumberOfMonthsPerInterval.Value);
                DateTime intervalEndDate = this.StartDate.Value.AddMonths(
                    (currentInterval) * this.NumberOfMonthsPerInterval.Value);
                if (intervalEndDate > this.EndDate.Value)
                    intervalEndDate = this.EndDate.Value.AddDays(1);
                columns.Add(intervalStartDate.As("IntervalDate"));

                ExpressionDataNumeric exp = 0;
                if ((budgetViewOptions & BudgetViewOptions.AddOpeningBalance) > 0)
                    exp = exp + (SchemaDecimal)ob.GetColumn("OpeningBalance" + String.Format("{0:00}", currentInterval));
                if ((budgetViewOptions & BudgetViewOptions.AddVariations) > 0)
                    exp = exp +
                        Case.IsNull(var.Select(Case.IsNull(var.VariationAmount, 0).Sum())
                        .Where(
                        (variationTypes == null ? Query.True : var.VariationType.In(variationTypes)) &
                        var.IntervalNumber == currentInterval &
                        var.IsDeleted == 0 &
                        var.AccountID == ob.AccountID &
                        var.BudgetPeriodID == this.ObjectID &
                        (var.VariationType != BudgetVariationType.Reallocation |
                         var.BudgetPeriod.Budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission |
                         var.VariationStatus != BudgetVariationStatus.PendingApproval)
                        ), 0);
                if ((budgetViewOptions & BudgetViewOptions.AddTransactions) > 0)
                    exp = exp +
                        Case.IsNull(trans.Select(Case.IsNull(trans.TransactionAmount, 0).Sum())
                        .Where(
                        (transactionTypes == null ? Query.True : trans.TransactionType.In(transactionTypes)) &
                        trans.IsDeleted == 0 &
                        trans.AccountID == ob.AccountID &
                        trans.BudgetID == this.BudgetID &
                        intervalStartDate <= trans.DateOfExpenditure &
                        trans.DateOfExpenditure < intervalEndDate), 0);
                if ((budgetViewOptions & BudgetViewOptions.SubtractTransactions) > 0)
                    exp = exp -
                        Case.IsNull(trans.Select(Case.IsNull(trans.TransactionAmount, 0).Sum())
                        .Where(
                        (transactionTypes == null ? Query.True : trans.TransactionType.In(transactionTypes)) &
                        trans.IsDeleted == 0 &
                        trans.AccountID == ob.AccountID &
                        trans.BudgetID == this.BudgetID &
                        intervalStartDate <= trans.DateOfExpenditure &
                        trans.DateOfExpenditure < intervalEndDate), 0);
                columns.Add(exp.As("Interval" + String.Format("{0:00}", currentInterval) + "Amount"));
               
            }

            // Add a column to compute the total available
            // amount for the entire period.
            //
            ExpressionDataNumeric exp2 = 0;

            if ((budgetViewOptions & BudgetViewOptions.AddOpeningBalance) > 0)
                exp2 = exp2 + ob.TotalOpeningBalance;
            if ((budgetViewOptions & BudgetViewOptions.AddVariations) > 0)
                exp2 = exp2 +
                    Case.IsNull(var.Select(Case.IsNull(var.VariationAmount, 0).Sum())
                    .Where(
                    (variationTypes == null ? Query.True : var.VariationType.In(variationTypes)) &
                    var.IsDeleted == 0 &
                    var.AccountID == ob.AccountID &
                    var.BudgetPeriodID == this.ObjectID &
                    (var.VariationType != BudgetVariationType.Reallocation |
                     var.BudgetPeriod.Budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission |
                     var.VariationStatus != BudgetVariationStatus.PendingApproval)
                    ), 0);
            if ((budgetViewOptions & BudgetViewOptions.AddTransactions) > 0)
                exp2 = exp2 +
                    Case.IsNull(trans.Select(Case.IsNull(trans.TransactionAmount, 0).Sum())
                    .Where(
                    (transactionTypes == null ? Query.True : trans.TransactionType.In(transactionTypes)) &
                    trans.IsDeleted == 0 &
                    trans.AccountID == ob.AccountID &
                    trans.BudgetID == this.BudgetID &
                    this.StartDate <= trans.DateOfExpenditure &
                    trans.DateOfExpenditure <= this.EndDate), 0);
            if ((budgetViewOptions & BudgetViewOptions.SubtractTransactions) > 0)
                exp2 = exp2 -
                    Case.IsNull(trans.Select(Case.IsNull(trans.TransactionAmount, 0).Sum())
                    .Where(
                    (transactionTypes == null ? Query.True : trans.TransactionType.In(transactionTypes)) &
                    trans.IsDeleted == 0 &
                    trans.AccountID == ob.AccountID &
                    trans.BudgetID == this.BudgetID &
                    this.StartDate <= trans.DateOfExpenditure &
                    trans.DateOfExpenditure <= this.EndDate), 0);
            columns.Add(exp2.As("TotalAmount"));

            DataTable dt =
                ob.Select(columns.ToArray()).Where(ob.BudgetPeriodID == this.ObjectID &
                    (account == null ? Query.True : ob.Account.HierarchyPath.Like(account.HierarchyPath + "%")));

            return dt;
        }

        /// <summary>
        /// Determines which are the interval opening balances in this threshold
        /// that are currently lower than the threshold. This method
        /// returns true if there are at least one account that has
        /// fallen below threshold.
        /// </summary>
        public bool DetermineLowThresholdIntervalOpeningBalances(DateTime? startDate, Guid? accountID)
        {
            int currentInterval = this.GetIntervalNumber(startDate.Value);
            int totalIntervals = this.TotalNumberOfIntervals;
            DataTable dt = GenerateIntervalViewForDetermineLowThreshold(currentInterval,
                BudgetViewOptions.AddOpeningBalance | BudgetViewOptions.AddVariations | BudgetViewOptions.SubtractTransactions,
                null, null, accountID);
            this.LowBudgetPeriodIntervalOpeningBalances = new List<LowBudgetPeriodIntervalOpeningBalance>();
            bool atLeastOneAccountBelowThreshold = false;
            foreach (DataRow dr in dt.Rows)
            {
                OBudgetPeriodOpeningBalance openingBalance = this.BudgetPeriodOpeningBalances.Find((Guid)dr["ObjectID"]);
                for (currentInterval = this.GetIntervalNumber(startDate.Value); currentInterval <= totalIntervals; currentInterval++)
                {
                    decimal totalIntervalOpeningBalance = (decimal)dr["OpeningBalance" + String.Format("{0:00}", currentInterval)];
                    decimal totalIntervalAvailableBalance = (decimal)dr["Interval" + String.Format("{0:00}", currentInterval) + "Amount"];
                    decimal totalAvailableBalance = (decimal)dr["TotalAmount"];
                    DateTime intervalDate = (DateTime)dr["IntervalDate"];
                    if (openingBalance.LowBudgetThreshold != null && openingBalance.LowBudgetThreshold >= 0 && openingBalance.LowBudgetThreshold <= 100)
                    {
                        if (totalIntervalAvailableBalance < totalIntervalOpeningBalance * openingBalance.LowBudgetThreshold.Value / 100)
                        {
                            
                            LowBudgetPeriodIntervalOpeningBalance lowIntervalBalance = new LowBudgetPeriodIntervalOpeningBalance();
                            lowIntervalBalance.AccountPath = openingBalance.Account.Path;
                            lowIntervalBalance.IntervalAvailableBalance = totalIntervalAvailableBalance;
                            lowIntervalBalance.IntervalOpeningBalance = totalIntervalOpeningBalance;
                            lowIntervalBalance.IntervalDate = intervalDate;
                            lowIntervalBalance.TotalAvailableBalance = totalAvailableBalance;
                            this.LowBudgetPeriodIntervalOpeningBalances.Add(lowIntervalBalance);

                            atLeastOneAccountBelowThreshold = true;
                        }
                        else
                            openingBalance.IsLow = false;
                    }
                }
            }

            return atLeastOneAccountBelowThreshold;
        }

    }

    // this is for email to list down
    // all the account with the interval opening balance &
    // interval available.
    public class LowBudgetPeriodIntervalOpeningBalance
    {
        public string AccountPath;
        public decimal IntervalOpeningBalance;
        public decimal IntervalAvailableBalance;
        public decimal TotalAvailableBalance;
        public DateTime? IntervalDate;
    }
    
}
