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
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OBudget
    /// </summary>
    [Serializable]
    public partial class TBudgetPeriod : LogicLayerSchema<OBudgetPeriod>
    {
        [Default(0)]
        public SchemaInt IsActive;
        [Default(1)]
        public SchemaInt NumberOfMonthsPerInterval;
        public SchemaGuid BudgetID;
        public SchemaDateTime StartDate;
        public SchemaDateTime EndDate;
        public SchemaDateTime ClosingDate;

        public TBudget Budget { get { return OneToOne<TBudget>("BudgetID"); } }
        public TBudgetPeriodOpeningBalance BudgetPeriodOpeningBalances { get { return OneToMany<TBudgetPeriodOpeningBalance>("BudgetPeriodID"); } }
    }


    [Serializable]
    public abstract partial class OBudgetPeriod : LogicLayerPersistentObject, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this budget has been approved and is active
        /// for selection.
        /// </summary>
        public abstract int? IsActive { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of months per interval. This value must
        /// be set in such a way that the total number of intervals must
        /// not be greater than 36.
        /// <para></para>
        /// In most budget implementations, a yearly budget
        /// of 12 months is often broken down into monthly intervals,
        /// </summary>
        public abstract int? NumberOfMonthsPerInterval { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Budget
        /// table that indicates which budget this budget period
        /// belongs under.
        /// </summary>
        public abstract Guid? BudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the starting date this
        /// budget is valid from. Only expenditures
        /// created after the start date can commit against
        /// this budget period.
        /// </summary>
        public abstract DateTime? StartDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the ending date this
        /// budget is valid to. Only expenditures
        /// created after the start date can commit against
        /// this budget period.
        /// <para></para>
        /// Having a flexible end date allows for the
        /// creation of project budgets, so that the validity
        /// of the budget is not restricted to an annual or
        /// a monthly boundary.
        /// </summary>
        public abstract DateTime? EndDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the closing date of this
        /// budget period. This indicates the last system date
        /// that expenses or POs can be committed against
        /// this budget period.
        /// </summary>
        public abstract DateTime? ClosingDate { get; set; }


        /// <summary>
        /// Gets or sets a OBudget object that indicates the
        /// budget that this budget period belongs under.
        /// </summary>
        public abstract OBudget Budget { get; set; }

        /// <summary>
        /// Gets a list of OBudgetPeriodOpeningBalance objects that 
        /// represents a set of budget accounts and the
        /// corresponding funds.
        /// </summary>
        public abstract DataList<OBudgetPeriodOpeningBalance> BudgetPeriodOpeningBalances { get; }

        /// <summary>
        /// Gets a list of OBudgetPeriodOpeningBalance objects that
        /// represents the list of budget accounts such that the IsLow flag
        /// is set.
        /// <para></para>
        /// NOTE: The IsLow flag is set by the DetermineLowThresholdOpeningBalances
        /// method after it determines which accounts' available balances
        /// have fallen below the budget threshold.
        /// </summary>
        public List<OBudgetPeriodOpeningBalance> LowBudgetPeriodOpeningBalances 
        {
            get
            {
                List<OBudgetPeriodOpeningBalance> lowBudgetPeriodOpeningBalances = new List<OBudgetPeriodOpeningBalance>();
                foreach (OBudgetPeriodOpeningBalance openingBalance in this.BudgetPeriodOpeningBalances)
                    if (openingBalance.IsLow)
                        lowBudgetPeriodOpeningBalances.Add(openingBalance);
                return lowBudgetPeriodOpeningBalances;
            }
        }


        /// <summary>
        /// Gets the total budget amount for this period.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                return BudgetTotal;
            }
        }


        /// <summary>
        /// Gets the locations of the budget this budget period
        /// is associated with.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in this.Budget.ApplicableLocations)
                    locations.Add(location);
                return locations;
            }
        }


        /// <summary>
        /// Gets the budget total by summing up the
        /// opening balances for all categories in this
        /// budget period.
        /// </summary>
        public decimal BudgetTotal
        {
            get
            {
                decimal total = 0;
                foreach(OBudgetPeriodOpeningBalance op in this.BudgetPeriodOpeningBalances)
                {
                    total += op.TotalOpeningBalance.Value;
                }
                return total;
            }
        }


        /// <summary>
        /// Gets the total number of intervals in this budget period.
        /// </summary>
        public int TotalNumberOfIntervals
        {
            get
            {
                if (this.StartDate == null || 
                    this.EndDate == null || 
                    this.NumberOfMonthsPerInterval == null)
                    return 0;

                DateTime startDate = this.StartDate.Value;
                DateTime endDate = this.EndDate.Value;
                int numberOfMonths = 0;
                while (startDate <= endDate)
                {
                    startDate = startDate.AddMonths(1);
                    numberOfMonths++;
                }
                int numberOfIntervals = numberOfMonths / this.NumberOfMonthsPerInterval.Value;

                if (numberOfIntervals * this.NumberOfMonthsPerInterval.Value != numberOfMonths)
                    numberOfIntervals++;

                return numberOfIntervals;
            }
        }

        /// <summary>
        /// Disallow delete if:
        /// <para></para>
        /// 1. There is at least one budget adjustment against this period, OR 
        /// 2. There is at least one budget reallocation against this period, OR 
        /// 3. There is at least one budget transaction log that falls within this period.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if ((int)TablesLogic.tBudgetAdjustment.Select(
                TablesLogic.tBudgetAdjustment.ObjectID.Count())
                .Where(
                TablesLogic.tBudgetAdjustment.IsDeleted == 0 &
                TablesLogic.tBudgetAdjustment.BudgetPeriodID == this.ObjectID) > 0)
                return false;

            if ((int)TablesLogic.tBudgetReallocation.Select(
                TablesLogic.tBudgetReallocation.ObjectID.Count())
                .Where(
                TablesLogic.tBudgetReallocation.IsDeleted == 0 &
                (TablesLogic.tBudgetReallocation.FromBudgetPeriodID == this.ObjectID |
                TablesLogic.tBudgetReallocation.ToBudgetPeriodID == this.ObjectID)) > 0)
                return false;

            if ((int)TablesLogic.tBudgetTransactionLog.Select(
                TablesLogic.tBudgetTransactionLog.ObjectID.Count())
                .Where(
                TablesLogic.tBudgetTransactionLog.IsDeleted == 0 &
                TablesLogic.tBudgetTransactionLog.BudgetID == this.BudgetID &
                TablesLogic.tBudgetTransactionLog.DateOfExpenditure >= this.StartDate &
                TablesLogic.tBudgetTransactionLog.DateOfExpenditure <= this.EndDate) > 0)
                return false;

            return true;
        }

        /// <summary>
        /// Validates that the specified account ID does not exist
        /// in the list of amounts in this budget.
        /// </summary>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public bool ValidateAccountIdDoesNotExist(Guid accountId)
        {
            foreach (OBudgetPeriodOpeningBalance amount in this.BudgetPeriodOpeningBalances)
            {
                if (amount.AccountID == accountId)
                    return false;
            }
            return true;
        }


        /// <summary>
        /// Opens a new budget period based on a previous budget period.
        /// </summary>
        /// <param name="originalBudgetPeriodId"></param>
        public void CopyBudgetPeriod(Guid originalBudgetPeriodId)
        {
            OBudgetPeriod originalBudgetPeriod = TablesLogic.tBudgetPeriod.Load(originalBudgetPeriodId);
            Guid budgetId = originalBudgetPeriod.BudgetID.Value;
            OBudget budget = TablesLogic.tBudget.Load(budgetId);

            int? defaultNumberOfMonths = budget.DefaultNumberOfMonthsPerBudgetPeriod;
            if (defaultNumberOfMonths == null)
                defaultNumberOfMonths = 12;
            int? defaultNumberOfMonthsPerInterval = budget.DefaultNumberOfMonthsPerInterval;
            if (defaultNumberOfMonthsPerInterval == null)
                defaultNumberOfMonthsPerInterval = 1;

            DateTime? lastEndDate = null;
            OBudgetPeriod lastBudgetPeriod = TablesLogic.tBudgetPeriod.Load(
                (TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName == null |
                TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName != "Cancelled") &
                TablesLogic.tBudgetPeriod.BudgetID == budgetId,
                TablesLogic.tBudgetPeriod.EndDate.Desc);
            if (lastBudgetPeriod != null)
                lastEndDate = lastBudgetPeriod.EndDate;

            this.BudgetID = budgetId;
            if (lastEndDate != null)
            {
                this.StartDate = lastEndDate.Value.AddDays(1);
                if (defaultNumberOfMonths != null)
                    this.EndDate = lastEndDate.Value.AddMonths(defaultNumberOfMonths.Value);
            }
            this.NumberOfMonthsPerInterval = defaultNumberOfMonthsPerInterval;

            foreach (OBudgetPeriodOpeningBalance openingBalance in originalBudgetPeriod.BudgetPeriodOpeningBalances)
            {
                OBudgetPeriodOpeningBalance newOpeningBalance = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                newOpeningBalance.AccountID = openingBalance.AccountID;
                newOpeningBalance.OpeningBalance01 = openingBalance.OpeningBalance01;
                newOpeningBalance.OpeningBalance02 = openingBalance.OpeningBalance02;
                newOpeningBalance.OpeningBalance03 = openingBalance.OpeningBalance03;
                newOpeningBalance.OpeningBalance04 = openingBalance.OpeningBalance04;
                newOpeningBalance.OpeningBalance05 = openingBalance.OpeningBalance05;
                newOpeningBalance.OpeningBalance06 = openingBalance.OpeningBalance06;
                newOpeningBalance.OpeningBalance07 = openingBalance.OpeningBalance07;
                newOpeningBalance.OpeningBalance08 = openingBalance.OpeningBalance08;
                newOpeningBalance.OpeningBalance09 = openingBalance.OpeningBalance09;
                newOpeningBalance.OpeningBalance10 = openingBalance.OpeningBalance10;
                newOpeningBalance.OpeningBalance11 = openingBalance.OpeningBalance11;
                newOpeningBalance.OpeningBalance12 = openingBalance.OpeningBalance12;
                newOpeningBalance.OpeningBalance13 = openingBalance.OpeningBalance13;
                newOpeningBalance.OpeningBalance14 = openingBalance.OpeningBalance14;
                newOpeningBalance.OpeningBalance15 = openingBalance.OpeningBalance15;
                newOpeningBalance.OpeningBalance16 = openingBalance.OpeningBalance16;
                newOpeningBalance.OpeningBalance17 = openingBalance.OpeningBalance17;
                newOpeningBalance.OpeningBalance18 = openingBalance.OpeningBalance18;
                newOpeningBalance.OpeningBalance19 = openingBalance.OpeningBalance19;
                newOpeningBalance.OpeningBalance20 = openingBalance.OpeningBalance20;
                newOpeningBalance.OpeningBalance21 = openingBalance.OpeningBalance21;
                newOpeningBalance.OpeningBalance22 = openingBalance.OpeningBalance22;
                newOpeningBalance.OpeningBalance23 = openingBalance.OpeningBalance23;
                newOpeningBalance.OpeningBalance24 = openingBalance.OpeningBalance24;
                newOpeningBalance.OpeningBalance25 = openingBalance.OpeningBalance25;
                newOpeningBalance.OpeningBalance26 = openingBalance.OpeningBalance26;
                newOpeningBalance.OpeningBalance27 = openingBalance.OpeningBalance27;
                newOpeningBalance.OpeningBalance28 = openingBalance.OpeningBalance28;
                newOpeningBalance.OpeningBalance29 = openingBalance.OpeningBalance29;
                newOpeningBalance.OpeningBalance30 = openingBalance.OpeningBalance30;
                newOpeningBalance.OpeningBalance31 = openingBalance.OpeningBalance31;
                newOpeningBalance.OpeningBalance32 = openingBalance.OpeningBalance32;
                newOpeningBalance.OpeningBalance33 = openingBalance.OpeningBalance33;
                newOpeningBalance.OpeningBalance34 = openingBalance.OpeningBalance34;
                newOpeningBalance.OpeningBalance35 = openingBalance.OpeningBalance35;
                newOpeningBalance.OpeningBalance36 = openingBalance.OpeningBalance36;

                decimal total = 0;
                for (int i = 1; i <= 36; i++)
                    total += Convert.ToDecimal(newOpeningBalance.DataRow["OpeningBalance" + String.Format("{0:00}", i)]);
                newOpeningBalance.TotalOpeningBalance = total;

                this.BudgetPeriodOpeningBalances.Add(newOpeningBalance);
            }
        }


        /// <summary>
        /// Gets a list of budget periods whose budget ID is equal
        /// to the one specified.
        /// </summary>
        /// <param name="budgetId"></param>
        /// <param name="includingBudgetPeriodId"></param>
        /// <returns></returns>
        public static List<OBudgetPeriod> GetBudgetPeriodsByBudgetID(Guid? budgetId, Guid? includingBudgetPeriodId)
        {
            return TablesLogic.tBudgetPeriod.LoadList(
                (TablesLogic.tBudgetPeriod.IsActive == 1 &
                TablesLogic.tBudgetPeriod.BudgetID == budgetId) |
                TablesLogic.tBudgetPeriod.ObjectID == includingBudgetPeriodId,
                true,
                TablesLogic.tBudgetPeriod.StartDate.Asc);

        }


        /// <summary>
        /// Gets a list of open budget periods whose budget ID is equal
        /// to the one specified.
        /// </summary>
        /// <param name="budgetId"></param>
        /// <param name="includingBudgetPeriodId"></param>
        /// <returns></returns>
        public static List<OBudgetPeriod> GetOpenBudgetPeriodsByBudgetID(Guid? budgetId, Guid? includingBudgetPeriodId)
        {
            return TablesLogic.tBudgetPeriod.LoadList(
                (TablesLogic.tBudgetPeriod.IsActive == 1 &
                TablesLogic.tBudgetPeriod.BudgetID == budgetId &
                (TablesLogic.tBudgetPeriod.ClosingDate == null |
                TablesLogic.tBudgetPeriod.ClosingDate > DateTime.Now)) |
                TablesLogic.tBudgetPeriod.ObjectID == includingBudgetPeriodId,
                true,
                TablesLogic.tBudgetPeriod.StartDate.Asc);
        }

        /// <summary>
        /// Gets the budget period that belongs to the specified budget ID,
        /// and whose start/end date covers the specified date.
        /// </summary>
        /// <param name="budgetId"></param>
        /// <param name="date"></param>
        /// <returns></returns>
        public static OBudgetPeriod GetBudgetPeriodByBudgetIDAndDate(Guid budgetId, DateTime date)
        {
            return TablesLogic.tBudgetPeriod.Load(
                TablesLogic.tBudgetPeriod.IsActive == 1 &
                TablesLogic.tBudgetPeriod.BudgetID == budgetId &
                TablesLogic.tBudgetPeriod.StartDate <= date &
                TablesLogic.tBudgetPeriod.EndDate >= date,
                TablesLogic.tBudgetPeriod.StartDate.Asc);
        }


        /// <summary>
        /// Gets the available balance of all budget accounts in a
        /// DataTable. 
        /// <para></para>
        /// This method uses a single SQL select with sub-queries
        /// to obtain the result.
        /// <para></para>
        /// The DataTable contains the following columns: AccountID, Balance.
        /// </summary>
        /// <returns></returns>
        public DataTable GetAvailableBalanceOfAllAccounts()
        {
            return GetAvailableBalanceByAccountIDs(null);
        }

        /// <summary>
        /// Gets the available balance of selected accounts.
        /// <para></para>
        /// This method uses a single SQL select with sub-queries
        /// to obtain the result.
        /// <para></para>
        /// The DataTable contains the following columns: AccountID, Balance.
        /// </summary>
        /// <returns></returns>
        public DataTable GetAvailableBalanceByAccountIDs(List<Guid> accountIds)
        {
            return GetAvailableBalances(
                this.BudgetID.Value, this.ObjectID.Value, accountIds);
        }

        /// <summary>
        /// Constructs the budget account in a tree structure.
        /// </summary>
        /// <param name="dt"></param>
        private DataTable MergeBudgetAccountTree(DataTable inputDt,Guid? accountID)
        {
            DataTable outputDt = new DataTable();

            TBudgetPeriodOpeningBalance ob = TablesLogic.tBudgetPeriodOpeningBalance;
            TAccount ac = TablesLogic.tAccount;
            TAccount ac2 = new TAccount();
            OAccount acc = TablesLogic.tAccount.Load(accountID);

            DataTable dt = ac.Select(
                ac.ObjectID,
                ac.ObjectID.As("AccountID"),
                ac.AccountCode.As("AccountCode"),
                ac.Type,
                ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID.As("a9"),
                ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID.As("a8"),
                ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID.As("a7"),
                ac.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID.As("a6"),
                ac.Parent.Parent.Parent.Parent.Parent.ObjectID.As("a5"),
                ac.Parent.Parent.Parent.Parent.ObjectID.As("a4"),
                ac.Parent.Parent.Parent.ObjectID.As("a3"),
                ac.Parent.Parent.ObjectID.As("a2"),
                ac.Parent.ObjectID.As("a1"),
                ac.ObjectName.As("AccountName"),
                (Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName.As("a9") + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName.As("a8") + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName.As("a7") + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName.As("a6") + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.ObjectName.As("a5") + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.ObjectName.As("a4") + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.ObjectName.As("a3") + " > ", "") +
                Case.IsNull(ac.Parent.Parent.ObjectName.As("a2") + " > ", "") +
                Case.IsNull(ac.Parent.ObjectName.As("a1") + " > ", "") +
                ac.ObjectName).As("Path")
                )
                .Where((
                    ob.Select(ob.ObjectID).Where(
                    ob.BudgetPeriodID == this.ObjectID &
                    ob.Account.HierarchyPath.Like(ac.HierarchyPath + "%")).Exists())&
                    (acc==null?Query.True: 
                    ac.HierarchyPath.Like(acc.HierarchyPath+"%")))
                .OrderBy(
                (
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.Parent.ObjectName + " > ", "") +
                Case.IsNull(ac.Parent.ObjectName + " > ", "") +
                ac.ObjectName).Asc
                );

            DataRow nRow = dt.NewRow();
            nRow["AccountName"] = "Grand Total";
            nRow["AccountID"] = Guid.Empty;

            dt.Rows.Add(nRow);

            // Generate a tree like structure by padding the account name
            // with an appropriate number of spaces.
            //
            dt.Columns.Add("Level", typeof(int));
            foreach (DataRow dr in dt.Rows)
            {
                for (int i = 1; i <= 9; i++)
                {
                    if (dr["a" + i] == DBNull.Value)
                    {
                        dr["Level"] = i - 1;
                        break;
                    }
                }
            }

            // Joins the two tables based on the account ID
            //
            outputDt = Anacle.DataFramework.Data.LeftJoin("AccountID", dt, inputDt);

            return outputDt;
        }


        /// <summary>
        /// Generates the summarized budget view.
        /// </summary>
        /// <returns></returns>
        public DataTable GenerateSummaryBudgetView(Guid? accountID)
        {
            DataTable dt = GenerateSummaryBudgetViewWithoutTree(accountID);
            return MergeBudgetAccountTree(dt,accountID);
        }



        /// <summary>
        /// Generates a view of monthly transactions and variations.
        /// </summary>
        /// <returns></returns>
        public DataTable GenerateIntervalView(
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
            columns.Add(ob.Account.ParentID);
            columns.Add(ob.Account.Type);
            // Add a column for each of the intervals to compute
            // the total available amount for that interval.
            //
            int currentInterval = 1;
            int totalIntervals = this.TotalNumberOfIntervals;
            for (currentInterval = 1; currentInterval <= 36; currentInterval++)
            {
                DateTime intervalStartDate = this.StartDate.Value.AddMonths(
                    (currentInterval - 1) * this.NumberOfMonthsPerInterval.Value);
                DateTime intervalEndDate = this.StartDate.Value.AddMonths(
                    (currentInterval) * this.NumberOfMonthsPerInterval.Value);
                if (intervalEndDate > this.EndDate.Value)
                    intervalEndDate = this.EndDate.Value.AddDays(1);

                if (currentInterval <= totalIntervals)
                {
                    ExpressionDataNumeric exp = 0;
                    if ((budgetViewOptions & BudgetViewOptions.AddOpeningBalance) > 0)
                        exp = exp + (SchemaDecimal)ob.GetColumn("OpeningBalance" + String.Format("{0:00}", currentInterval));
                    if ((budgetViewOptions & BudgetViewOptions.AddVariations) > 0)
                        exp = exp +
                            Case.IsNull(var.Select(Case.IsNull(var.VariationAmount, 0).Sum())
                            .Where(
                            (variationTypes==null ? Query.True : var.VariationType.In(variationTypes)) &
                            var.IntervalNumber == currentInterval &
                            var.IsDeleted == 0 &
                            var.AccountID == ob.AccountID &
                            var.BudgetPeriodID == this.ObjectID), 0);
                    if ((budgetViewOptions & BudgetViewOptions.AddTransactions) > 0)
                        exp = exp +
                            Case.IsNull(trans.Select(Case.IsNull(trans.TransactionAmount, 0).Sum())
                            .Where(
                            (transactionTypes==null ? Query.True : trans.TransactionType.In(transactionTypes)) &
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
                else
                {
                    columns.Add(
                        ((ExpressionDataNumeric)0).As("Interval" + String.Format("{0:00}", currentInterval) + "Amount"));
                }
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
                    var.BudgetPeriodID == this.ObjectID), 0);
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

            DataTable dt1 =
                ob.Select(columns.ToArray())
                .Where(ob.BudgetPeriodID == this.ObjectID & 
                (account == null ? Query.True : ob.Account.HierarchyPath.Like(account.HierarchyPath + "%")));

            DataTable dt2 = ob.SelectDistinct
                (ob.Account.ParentID.As("AccountID"))
                .Where(ob.BudgetPeriodID == this.ObjectID &
                (account == null ? Query.True : ob.Account.HierarchyPath.Like(account.HierarchyPath + "%")));
            dt2.Rows.Add(Guid.Empty);

            foreach (DataColumn dc in dt1.Columns)
                if (!dt2.Columns.Contains(dc.ColumnName))
                    dt2.Columns.Add(dc.ColumnName, dc.DataType);

            foreach (DataRow dr in dt2.Rows)
            {
                DataRow[] drs = dt1.Select("ParentID = '" + dr["AccountID"].ToString() + "'");
                dr["Type"] = 0;
                foreach (DataColumn dc in dt2.Columns)
                {
                    if (dc.ColumnName.StartsWith("Interval") ||
                        dc.ColumnName.StartsWith("Total"))
                    {
                        decimal total = 0M;
                        if (drs.Length > 0)
                        {
                            for (int i = 0; i < drs.Length; i++)
                            {
                                if (drs[i][dc.ColumnName] != DBNull.Value)
                                    total += Convert.ToDecimal(drs[i][dc.ColumnName]);
                            }
                        }
                        else
                        {
                            for (int j = 0; j < dt1.Rows.Count; j++)
                                if (dt1.Rows[j][dc.ColumnName] != DBNull.Value)
                                    total += Convert.ToDecimal(dt1.Rows[j][dc.ColumnName]);
                        }
                        dr[dc.ColumnName] = total;
                    }
                }
            }
            dt1.Merge(dt2);

            return MergeBudgetAccountTree(dt1, accountID);
        }




        /// <summary>
        /// Generates the month-to-date available view.
        /// </summary>
        /// <returns></returns>
        public DataTable GenerateAvailableView(Guid? accountID)
        {
            List<ColumnAs> columns = new List<ColumnAs>();

            TBudgetPeriodOpeningBalance ob = TablesLogic.tBudgetPeriodOpeningBalance;
            TBudgetVariationLog var = TablesLogic.tBudgetVariationLog;
            TBudgetTransactionLog trans = TablesLogic.tBudgetTransactionLog;

            columns.Add(ob.AccountID);

            // Add a column for each of the intervals to compute
            // the total available amount for that interval.
            //
            int currentInterval = 1;
            int totalIntervals = this.TotalNumberOfIntervals;
            for (currentInterval = 1; currentInterval <= 36; currentInterval++)
            {
                DateTime intervalStartDate = this.StartDate.Value.AddMonths(
                    (currentInterval - 1) * this.NumberOfMonthsPerInterval.Value);
                DateTime intervalEndDate = this.StartDate.Value.AddMonths(
                    (currentInterval) * this.NumberOfMonthsPerInterval.Value);
                if (intervalEndDate > this.EndDate.Value)
                    intervalEndDate = this.EndDate.Value.AddDays(1);

                if (currentInterval <= totalIntervals)
                {
                    columns.Add(
                        ((SchemaDecimal)ob.GetColumn("OpeningBalance" + String.Format("{0:00}", currentInterval)) +
                        Case.IsNull(var.Select(Case.IsNull(var.VariationAmount, 0).Sum())
                            .Where(
                            var.IntervalNumber == currentInterval &
                            var.IsDeleted == 0 &
                            var.AccountID == ob.AccountID &
                            var.BudgetPeriodID == this.ObjectID), 0) -
                        Case.IsNull(trans.Select(Case.IsNull(trans.TransactionAmount, 0).Sum())
                            .Where(
                            trans.IsDeleted == 0 &
                            trans.AccountID == ob.AccountID &
                            trans.BudgetID == this.BudgetID &
                            intervalStartDate <= trans.DateOfExpenditure &
                            trans.DateOfExpenditure <= intervalEndDate), 0)).As("Interval" + String.Format("{0:00}", currentInterval) + "Amount"));
                }
                else
                {
                    columns.Add(
                        ((ExpressionDataNumeric)0).As("Interval" + String.Format("{0:00}", currentInterval) + "Amount"));
                }
            }

            // Add a column to compute the total available
            // amount for the entire period.
            //
            columns.Add(
                (ob.TotalOpeningBalance +
                Case.IsNull(var.Select(Case.IsNull(var.VariationAmount, 0).Sum())
                    .Where(
                    var.IsDeleted == 0 &
                    var.AccountID == ob.AccountID &
                    var.BudgetPeriodID == this.ObjectID), 0) -
                Case.IsNull(trans.Select(Case.IsNull(trans.TransactionAmount, 0).Sum())
                    .Where(
                    trans.IsDeleted == 0 &
                    trans.AccountID == ob.AccountID &
                    trans.BudgetID == this.BudgetID &
                    this.StartDate <= trans.DateOfExpenditure &
                    trans.DateOfExpenditure <= this.EndDate), 0)).As("TotalAmount"));


            DataTable dt =
                ob.Select(columns.ToArray()).Where(ob.BudgetPeriodID == this.ObjectID);

            return MergeBudgetAccountTree(dt,accountID);
        }


        /// <summary>
        /// Determine the budget periods applicable to the transactions.
        /// </summary>
        /// <param name="transactions"></param>
        public static List<OBudgetPeriod> DetermineBudgetPeriods(List<OBudgetTransactionLog> transactions)
        {
            List<OBudgetPeriod> budgetPeriods = new List<OBudgetPeriod>();

            foreach (OBudgetTransactionLog transaction in transactions)
            {
                // Check to see if the budget period has already been
                // loaded up in stored in the budgetPeriods list.
                //
                foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
                {
                    if (budgetPeriod.BudgetID == transaction.BudgetID &&
                        budgetPeriod.StartDate <= transaction.DateOfExpenditure &&
                        budgetPeriod.EndDate >= transaction.DateOfExpenditure)
                    {
                        transaction.BudgetPeriodID = budgetPeriod.ObjectID;
                        break;
                    }
                }
                // If not, then we load the budget period from the
                // database and save it into the cache.
                //
                if (transaction.BudgetPeriodID == null)
                {
                    //OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(
                    //    TablesLogic.tBudgetPeriod.BudgetID == transaction.BudgetID &
                    //    TablesLogic.tBudgetPeriod.StartDate <= transaction.DateOfExpenditure &
                    //    TablesLogic.tBudgetPeriod.EndDate >= transaction.DateOfExpenditure);
                    OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(
                        TablesLogic.tBudgetPeriod.IsActive == 1 &
                        TablesLogic.tBudgetPeriod.BudgetID == transaction.BudgetID &
                        TablesLogic.tBudgetPeriod.StartDate <= transaction.DateOfExpenditure &
                        TablesLogic.tBudgetPeriod.EndDate >= transaction.DateOfExpenditure);

                    if (budgetPeriod != null)
                    {
                        transaction.BudgetPeriodID = budgetPeriod.ObjectID;
                        budgetPeriods.Add(budgetPeriod);
                    }
                }
                else
                {
                    OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(transaction.BudgetPeriodID);
                    budgetPeriods.Add(budgetPeriod);
                }
                // If, we can't find any budget period from the database,
                // this means we are committing to a budget period that doesn't exist
                // yet. We'll just pretend nothing's wrong and we won't throw
                // any errors.
            }
            return budgetPeriods;
        }


        /// <summary>
        /// Gets a DataTable of available balances of all relevant budget periods
        /// and their accounts given a list of transactions. 
        /// <para></para>
        /// The resulting DataTable will consist of the following columns:
        /// BudgetPeriodID, AccountID, Balance.
        /// </summary>
        /// <param name="transactions"></param>
        /// <returns></returns>
        public static DataTable GetAvailableBalanceByTransactions(List<OBudgetTransactionLog> transactions)
        {
            List<OBudgetPeriod> budgetPeriods = DetermineBudgetPeriods(transactions);

            // Creates a hashtable of GUID lists, each storing a list of 
            // accounts that appear in the transactions for each budget period.
            //
            Hashtable accountIds = new Hashtable();
            foreach (OBudgetTransactionLog transaction in transactions)
            {
                string key;
                if (transaction.BudgetPeriodID != null)
                    key = transaction.BudgetID.Value.ToString() + ":" + transaction.BudgetPeriodID.Value.ToString();
                else
                    key = transaction.BudgetID.Value.ToString();

                if (accountIds[key] == null)
                    accountIds[key] = new List<Guid>();

                if (transaction.BudgetPeriodID != null)
                {
                    List<Guid> accountIdlist = (List<Guid>)accountIds[key];
                    if (accountIdlist != null)
                        accountIdlist.Add(transaction.AccountID.Value);
                }
            }

            // Get available balances of all relevant budget periods and accounts,
            // and dump them into a hashtable.
            //
            Hashtable availableBalance = new Hashtable();
            DataTable dtResult = new DataTable();
            dtResult.Columns.Add("BudgetID", typeof(Guid));
            dtResult.Columns.Add("BudgetName", typeof(string));
            dtResult.Columns.Add("BudgetPeriodID", typeof(Guid));
            dtResult.Columns.Add("BudgetPeriodName", typeof(string));
            dtResult.Columns.Add("AccountID", typeof(Guid));
            dtResult.Columns.Add("AccountName", typeof(string));
            dtResult.Columns.Add("Adjusted", typeof(decimal));
            dtResult.Columns.Add("Balance", typeof(decimal));
            
            foreach(string key in accountIds.Keys)
            {
                List<Guid> accountIdlist = (List<Guid>)accountIds[key];
                string[] id = key.Split(':');
                Guid budgetId = new Guid(id[0]);
                Guid budgetPeriodId = Guid.Empty;
                if (id.Length > 1)
                    budgetPeriodId = new Guid(id[1]);

                DataTable dt = null;
                if (id.Length > 1)
                    dt = OBudgetPeriod.GetAvailableBalances(budgetId, budgetPeriodId, accountIdlist);
                else
                    dt = OBudgetPeriod.GetNegativeBalancesOfUncommittedConsumptions(budgetId, accountIdlist);
                foreach (DataRow dr in dt.Rows)
                    dtResult.Rows.Add(
                        budgetId,
                        dr["BudgetName"],
                        (id.Length > 1) ? (object)budgetPeriodId : DBNull.Value, 
                        dr["BudgetPeriodName"],
                        dr["AccountID"],
                        dr["AccountName"], 
                        dr["Adjusted"],
                        dr["Balance"]);
            }
            return dtResult;
        }


        /// <summary>
        /// Checks if the transactions are possible based on the
        /// available balances in the budget periods.
        /// </summary>
        /// <param name="transactions"></param>
        /// <returns>Returns a list of budget periods and accounts that
        /// do not have sufficient balance. Returns an empty string
        /// if there is sufficient balance in all budget periods
        /// and accounts.</returns>
        public static string CheckSufficientBalance(List<OBudgetTransactionLog> transactions)
        {
            DataTable dt = GetAvailableBalanceByTransactions(transactions);

            Hashtable availableBalance = new Hashtable();
            foreach (DataRow dr in dt.Rows)
                availableBalance[dr["BudgetID"] + "," + dr["BudgetPeriodID"] + "," + dr["AccountID"]] = dr;

            // 2010.10.21
            // Kim Foong/
            // Load up the list of transactions that are transferred from an existing
            // budget transaction log.
            //
            List<Guid> transferFromBudgetTransactionLogIDs = new List<Guid>();
            Hashtable transferFromBudgetTransactionLogs = new Hashtable();
            foreach (OBudgetTransactionLog transaction in transactions)
                if (transaction.TransferFromBudgetTransactionLogID != null)
                    transferFromBudgetTransactionLogIDs.Add(transaction.TransferFromBudgetTransactionLogID.Value);
            if (transferFromBudgetTransactionLogIDs.Count > 0)
            {
                List<OBudgetTransactionLog> logs = TablesLogic.tBudgetTransactionLog.LoadList(
                    TablesLogic.tBudgetTransactionLog.ObjectID.In(transferFromBudgetTransactionLogIDs), true);
                foreach (OBudgetTransactionLog log in logs)
                    transferFromBudgetTransactionLogs[log.ObjectID.Value] = log;
            }

            // Go through all transactions and deduct the money from the 
            // availableBalance hash table.
            //
            foreach (OBudgetTransactionLog transaction in transactions)
            {
                // If the BudgetPeriodID is null, it is for a future budget period,
                // so we do not check for sufficient balances.
                //
                // Also, if we are going to do a transfer from the budget
                // transaction from another budget transaction log record (this occurs
                // when we create RFQ from PO or create invoice from PO),
                // we should not be checking for budget balance, since the
                // amount transferred should always be less than or equal
                // to the original amount we transfer from.
                //
                
                // 2010.10.21 
                // Kim Foong 
                // Modified to only check for transaction.BudgetPeriodID != null
                // This is because we want to be able to compute the budget availability even
                // when money is being transferred over from another transaction log.
                //
                // This is because the transaction amount in the new budget transaction log may be greater
                // than the amount in the previous transaction log.
                /*
                if (transaction.BudgetPeriodID != null && transaction.TransferFromBudgetTransactionLogID == null)
                {
                    string key =
                        transaction.BudgetID.Value.ToString() + "," +
                        (transaction.BudgetPeriodID == null ? "" : transaction.BudgetPeriodID.Value.ToString()) + "," +
                        transaction.AccountID.Value.ToString();

                    ((DataRow)availableBalance[key])["Balance"] =
                        (decimal)((DataRow)availableBalance[key])["Balance"] - 
                        transaction.TransactionAmount.Value;
                }
                 */
                if (transaction.BudgetPeriodID != null)
                {
                    decimal previousTransactionLogAmount = 0;
                    if (transaction.TransferFromBudgetTransactionLogID != null)
                    {
                        previousTransactionLogAmount =
                            ((OBudgetTransactionLog)transferFromBudgetTransactionLogs[transaction.TransferFromBudgetTransactionLogID.Value])
                            .TransactionAmount.Value;
                    }

                    // Here, we only compute the available balance
                    if (previousTransactionLogAmount < transaction.TransactionAmount.Value)
                    {
                        string key =
                            transaction.BudgetID.Value.ToString() + "," +
                            (transaction.BudgetPeriodID == null ? "" : transaction.BudgetPeriodID.Value.ToString()) + "," +
                            transaction.AccountID.Value.ToString();

                        ((DataRow)availableBalance[key])["Balance"] =
                            (decimal)((DataRow)availableBalance[key])["Balance"] +
                            previousTransactionLogAmount -
                            transaction.TransactionAmount.Value;
                    }
                }
            }

            // Go through all available balances and see 
            // which one budget period / account is insufficient.
            //
            StringBuilder sb = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                if ((decimal)dr["Balance"] < 0)
                {
                    if (sb.Length > 0)
                        sb.Append(", ");
                    sb.Append(dr["BudgetPeriodName"].ToString());
                    sb.Append(" (");
                    OAccount account = TablesLogic.tAccount.Load((Guid)dr["AccountID"]);
                    if (account != null)
                        sb.Append(account.Path);
                    sb.Append(")");
                }
            }
            return sb.ToString();
        }


        /// <summary>
        /// Validates to ensure that this budget period does not
        /// overlap any existing budget periods from the same
        /// budget in the system.
        /// </summary>
        /// <returns></returns>
        public OBudgetPeriod ValidateBudgetPeriodDoesNotOverlapExistingPeriods()
        {
            TBudgetPeriod tb = TablesLogic.tBudgetPeriod;

            OBudgetPeriod budgetPeriod = tb.Load(
                tb.CurrentActivity.ObjectName != "Cancelled" &
                tb.BudgetID == this.BudgetID &
                tb.ObjectID != this.ObjectID &
                ((tb.StartDate <= this.StartDate & this.StartDate <= tb.EndDate) |
                (tb.StartDate <= this.EndDate & this.EndDate <= tb.EndDate) |
                (this.StartDate <= tb.StartDate & tb.EndDate <= this.EndDate)));

            return budgetPeriod;
        }


        /// <summary>
        /// Approves the budget and activates it for selection
        /// by setting the IsActive flag to 1.
        /// <para></para>
        /// This method is called by the workflow and should
        /// never be called by the developer directly.
        /// </summary>
        public void Approve()
        {
            using (Connection c = new Connection())
            {
                this.IsActive = 1;
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Cancels the budget and de-activates it for selection
        /// by setting the IsActive flag to 0.
        /// <para></para>
        /// This method is called by the workflow and should
        /// never be called by the developer directly.
        /// </summary>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                this.IsActive = 0;
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Determines which are the opening balances in this threshold
        /// that are currently lower than the threshold. This method
        /// returns true if there are at least one account that has
        /// fallen below threshold.
        /// </summary>
        public bool DetermineLowThresholdOpeningBalances(Guid? accountID)
        {
            DataTable dt = GenerateSummaryBudgetViewWithoutTree(accountID);

            bool atLeastOneAccountBelowThreshold = false;
            foreach(DataRow dr in dt.Rows)
            {
                OBudgetPeriodOpeningBalance openingBalance = this.BudgetPeriodOpeningBalances.Find((Guid)dr["ObjectID"]);

                decimal totalOpeningBalance = (decimal)dr["TotalOpeningBalance"];
                decimal totalAvailableBalance = (decimal)dr["TotalAvailableBalance"];

                if (openingBalance.LowBudgetThreshold != null && openingBalance.LowBudgetThreshold >= 0 && openingBalance.LowBudgetThreshold <= 100)
                {
                    if (totalAvailableBalance < totalOpeningBalance * openingBalance.LowBudgetThreshold.Value / 100)
                    {
                        openingBalance.IsLow = true;
                        atLeastOneAccountBelowThreshold = true;
                    }
                    else
                        openingBalance.IsLow = false;
                }
            }

            return atLeastOneAccountBelowThreshold;
        }
    }


    /// <summary>
    /// Represents a set of options to indicate the
    /// type of budget view to generate.
    /// </summary>
    public enum BudgetViewOptions
    {
        AddOpeningBalance = 1,
        AddVariations = 2,
        AddTransactions = 4,
        SubtractTransactions = 8,
    }
}
