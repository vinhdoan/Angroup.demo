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
        public string accountCondition(OAccount account)
        {
            if (account != null)
                return @"ac.HierarchyPath Like '" + account.HierarchyPath + @"' + '%' and ";
            else
                return null;
        }
        public DataTable GenerateBudgetAdjustmentDetail(Guid? accountID)
        {
            OAccount account = TablesLogic.tAccount.Load(accountID);         
            string sql = @"select vlog.AccountID,ad.ObjectNumber as 'AdjustNumber',
(isnull(a9.ObjectName + ' > ', '') + isnull(a8.ObjectName + ' > ', '') + isnull(a7.ObjectName + ' > ', '') + isnull(a6.ObjectName + ' > ', '') + isnull(a5.ObjectName + ' > ', '') +
isnull(a4.ObjectName + ' > ', '') + isnull(a3.ObjectName + ' > ', '') + isnull(a2.ObjectName + ' > ', '') + isnull(a1.ObjectName + ' > ', '') + ac.ObjectName ) as 'AccountName'
,ac.AccountCode,
CONVERT(Varchar(11),DATEADD(dd,-(DAY(bp.StartDate)-1),DateAdd(mm,((vlog.IntervalNumber-1)*bp.NumberOfMonthsPerInterval),bp.StartDate)),106) as 'Month',vlog.VariationAmount as Amount 
from BudgetVariationLog vlog
left join BudgetAdjustment ad on ad.ObjectID = vlog.BudgetAdjustmentID
left join BudgetPeriod bp on ad.BudgetPeriodID = bp.ObjectID
left join Account ac on ac.ObjectID = vlog.AccountID
left join Account a1 on ac.ParentID = a1.ObjectID
left join Account a2 on a1.ParentID = a2.ObjectID
left join Account a3 on a2.ParentID = a3.ObjectID
left join Account a4 on a3.ParentID = a4.ObjectID
left join Account a5 on a4.ParentID = a5.ObjectID
left join Account a6 on a5.ParentID = a6.ObjectID
left join Account a7 on a6.ParentID = a7.ObjectID
left join Account a8 on a7.ParentID = a8.ObjectID
left join Account a9 on a8.ParentID = a9.ObjectID
where ad.BudgetPeriodID = '" + this.ObjectID.ToString()+@"' and " + accountCondition(account)+
@"vlog.BudgetAdjustmentID is not null
and vlog.IsDeleted=0
order by ad.ObjectNumber,(isnull(a9.ObjectName + ' > ', '') + isnull(a8.ObjectName + ' > ', '') + isnull(a7.ObjectName + ' > ', '') + isnull(a6.ObjectName + ' > ', '') + isnull(a5.ObjectName + ' > ', '') +
isnull(a4.ObjectName + ' > ', '') + isnull(a3.ObjectName + ' > ', '') + isnull(a2.ObjectName + ' > ', '') + isnull(a1.ObjectName + ' > ', '') + ac.ObjectName )
,vlog.IntervalNumber";

            DataTable adjust = Connection.ExecuteQuery("#database", sql).Tables[0];
            return adjust;
        }
        public DataTable GenerateBudgetReallocationDetail(Guid? accountID)
        {
            OAccount account = TablesLogic.tAccount.Load(accountID); 
            string sql = @"select vlog.AccountID,br.ObjectNumber as 'ReallocateNumber',
(isnull(a9.ObjectName + ' > ', '') + isnull(a8.ObjectName + ' > ', '') + isnull(a7.ObjectName + ' > ', '') + isnull(a6.ObjectName + ' > ', '') + isnull(a5.ObjectName + ' > ', '') +
isnull(a4.ObjectName + ' > ', '') + isnull(a3.ObjectName + ' > ', '') + isnull(a2.ObjectName + ' > ', '') + isnull(a1.ObjectName + ' > ', '') + ac.ObjectName ) as 'AccountName'
,ac.AccountCode,
CONVERT(Varchar(11),DATEADD(dd,-(DAY(bp.StartDate)-1),DateAdd(mm,((vlog.IntervalNumber-1)*bp.NumberOfMonthsPerInterval),bp.StartDate)),106) as 'Month',vlog.VariationAmount as Amount 
from BudgetVariationLog vlog
left join BudgetReallocation br on br.ObjectID = vlog.BudgetReallocationID
left join BudgetPeriod bp on vlog.BudgetPeriodID = bp.ObjectID
left join Account ac on ac.ObjectID = vlog.AccountID
left join Account a1 on ac.ParentID = a1.ObjectID
left join Account a2 on a1.ParentID = a2.ObjectID
left join Account a3 on a2.ParentID = a3.ObjectID
left join Account a4 on a3.ParentID = a4.ObjectID
left join Account a5 on a4.ParentID = a5.ObjectID
left join Account a6 on a5.ParentID = a6.ObjectID
left join Account a7 on a6.ParentID = a7.ObjectID
left join Account a8 on a7.ParentID = a8.ObjectID
left join Account a9 on a8.ParentID = a9.ObjectID
where vlog.BudgetPeriodID = '"+ this.ObjectID.ToString() +@"' and " + accountCondition(account)+ @" vlog.BudgetReallocationID is not null
and vlog.IsDeleted=0
order by br.ObjectNumber,(isnull(a9.ObjectName + ' > ', '') + isnull(a8.ObjectName + ' > ', '') + isnull(a7.ObjectName + ' > ', '') + isnull(a6.ObjectName + ' > ', '') + isnull(a5.ObjectName + ' > ', '') +
isnull(a4.ObjectName + ' > ', '') + isnull(a3.ObjectName + ' > ', '') + isnull(a2.ObjectName + ' > ', '') + isnull(a1.ObjectName + ' > ', '') + ac.ObjectName )
,vlog.IntervalNumber";

            DataTable reallocation = Connection.ExecuteQuery("#database", sql).Tables[0];
            return reallocation;
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
        public static decimal? GetAvailableBalances(Guid budgetId, Guid budgetPeriodId, Guid accountId)
        {
            decimal? balance = null;

            TBudgetPeriod bp = TablesLogic.tBudgetPeriod;
            TBudgetPeriodOpeningBalance bal = TablesLogic.tBudgetPeriodOpeningBalance;
            TBudgetVariationLog var = TablesLogic.tBudgetVariationLog;
            TBudgetTransactionLog trans = TablesLogic.tBudgetTransactionLog;

            DataTable dt = (DataTable)bal.Select(
                (bal.TotalOpeningBalance +
                    Case.IsNull(
                        var.Select(var.VariationAmount.Sum())
                        .Where(
                        var.IsDeleted == 0 &
                        (bal.BudgetPeriod.Budget.BudgetDeductionPolicy == null |
                        bal.BudgetPeriod.Budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission |
                        var.VariationStatus != BudgetVariationStatus.PendingApproval) &
                        var.AccountID == bal.AccountID &
                        var.BudgetPeriodID == budgetPeriodId), 0)).As("Adjusted"),

                (bal.TotalOpeningBalance +
                    Case.IsNull(
                        var.Select(var.VariationAmount.Sum())
                        .Where(
                        var.IsDeleted == 0 &
                        (bal.BudgetPeriod.Budget.BudgetDeductionPolicy == 0 |
                        var.VariationStatus != BudgetVariationStatus.PendingApproval) &
                        var.AccountID == bal.AccountID &
                        var.BudgetPeriodID == budgetPeriodId), 0) -

                    Case.IsNull(
                    trans.Select(trans.TransactionAmount.Sum())
                        .Where(
                        trans.IsDeleted == 0 &
                        trans.AccountID == bal.AccountID &
                        trans.BudgetID == budgetId &

                        // Include or exclude pending approval transactions
                        // depending on the budget's deduction policy.
                        //
                        (bal.BudgetPeriod.Budget.BudgetDeductionPolicy==0 |
                        trans.TransactionType.In(
                        BudgetTransactionType.DirectCreditDebitMemoApproved, 
                        BudgetTransactionType.DirectInvoiceApproved, 
                        BudgetTransactionType.PurchaseApproved, 
                        BudgetTransactionType.PurchaseCreditDebitMemoApproved, 
                        BudgetTransactionType.PurchaseInvoiceApproved)) &

                        trans.DateOfExpenditure >= bp.Select(bp.StartDate).Where(bp.ObjectID == budgetPeriodId) &
                        trans.DateOfExpenditure <= bp.Select(bp.EndDate).Where(bp.ObjectID == budgetPeriodId)), 0)).As("Balance"))

                .Where(
                bal.BudgetPeriodID == budgetPeriodId &
                bal.AccountID == accountId
                );

            if (dt == null || dt.Rows.Count == 0)
                return null;

            try
            {
                balance = decimal.Parse(dt.Rows[0]["Balance"].ToString());
            }
            catch
            {

            }

            return balance;
            
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
        public static DataTable GetAvailableBalances(Guid budgetId, Guid budgetPeriodId, List<Guid> accountIds)
        {
            TBudgetPeriod bp = TablesLogic.tBudgetPeriod;
            TBudgetPeriodOpeningBalance bal = TablesLogic.tBudgetPeriodOpeningBalance;
            TBudgetVariationLog var = TablesLogic.tBudgetVariationLog;
            TBudgetTransactionLog trans = TablesLogic.tBudgetTransactionLog;

            return (DataTable)bal.Select(
                bal.AccountID,
                bal.BudgetPeriod.BudgetID.As("BudgetID"),
                bal.BudgetPeriodID.As("BudgetPeriodID"),

                bal.Account.ObjectName.As("AccountName"),
                bal.BudgetPeriod.Budget.ObjectName.As("BudgetName"),
                bal.BudgetPeriod.ObjectName.As("BudgetPeriodName"),

                (bal.TotalOpeningBalance +
                    Case.IsNull(
                        var.Select(var.VariationAmount.Sum())
                        .Where(
                        var.IsDeleted == 0 &
                        (bal.BudgetPeriod.Budget.BudgetDeductionPolicy == null |
                        bal.BudgetPeriod.Budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission |
                        var.VariationStatus != BudgetVariationStatus.PendingApproval) &
                        var.AccountID == bal.AccountID &
                        var.BudgetPeriodID == budgetPeriodId), 0)).As("Adjusted"),

                (bal.TotalOpeningBalance +
                    Case.IsNull(
                        var.Select(var.VariationAmount.Sum())
                        .Where(
                        var.IsDeleted == 0 &
                        (bal.BudgetPeriod.Budget.BudgetDeductionPolicy == 0 |
                        var.VariationStatus != BudgetVariationStatus.PendingApproval) &
                        var.AccountID == bal.AccountID &
                        var.BudgetPeriodID == budgetPeriodId), 0) -

                    Case.IsNull(
                    trans.Select(trans.TransactionAmount.Sum())
                        .Where(
                        trans.IsDeleted == 0 &
                        trans.AccountID == bal.AccountID &
                        trans.BudgetID == budgetId &

                        // Include or exclude pending approval transactions
                        // depending on the budget's deduction policy.
                        //
                        (bal.BudgetPeriod.Budget.BudgetDeductionPolicy==0 |
                        trans.TransactionType.In(
                        BudgetTransactionType.DirectCreditDebitMemoApproved, 
                        BudgetTransactionType.DirectInvoiceApproved, 
                        BudgetTransactionType.PurchaseApproved, 
                        BudgetTransactionType.PurchaseCreditDebitMemoApproved, 
                        BudgetTransactionType.PurchaseInvoiceApproved)) &

                        trans.DateOfExpenditure >= bp.Select(bp.StartDate).Where(bp.ObjectID == budgetPeriodId) &
                        trans.DateOfExpenditure <= bp.Select(bp.EndDate).Where(bp.ObjectID == budgetPeriodId)), 0)).As("Balance"))

                .Where(
                bal.BudgetPeriodID == budgetPeriodId &
                (accountIds == null ? Query.True : bal.AccountID.In(accountIds))
                );
        }


        /// <summary>
        /// Gets the total budget consumption not that does not fall
        /// within any budget periods.
        /// <para></para>
        /// This method uses a single SQL select with sub-queries
        /// to obtain the result.
        /// <para></para>
        /// The DataTable contains the following columns: AccountID, Balance.
        /// </summary>
        /// <returns></returns>
        public static DataTable GetNegativeBalancesOfUncommittedConsumptions(Guid budgetId, List<Guid> accountIds)
        {
            TAccount ac = TablesLogic.tAccount;
            TBudget b = TablesLogic.tBudget;
            TBudgetPeriod bp = TablesLogic.tBudgetPeriod;
            TBudgetPeriodOpeningBalance bal = TablesLogic.tBudgetPeriodOpeningBalance;
            TBudgetVariationLog var = TablesLogic.tBudgetVariationLog;
            TBudgetTransactionLog trans = TablesLogic.tBudgetTransactionLog;

            DataTable dt = (DataTable)ac.Select(
                ac.ObjectID.As("AccountID"),
                ((ExpressionData)budgetId).As("BudgetID"),

                ac.ObjectName.As("AccountName"),
                b.Select(b.ObjectName).Where(b.ObjectID == budgetId).As("BudgetName"),
                "".As("BudgetPeriodName"),

                0.As("Adjusted"),
                Case.IsNull(
                    trans.Select(0 - trans.TransactionAmount.Sum())
                    .Where(
                    trans.IsDeleted == 0 &
                    trans.AccountID == ac.ObjectID &
                    trans.BudgetID == budgetId &

                    // Include or exclude pending approval transactions
                    // depending on the budget's deduction policy.
                    //
                    (bp.Select(bp.Budget.BudgetDeductionPolicy).Where(bp.BudgetID == budgetId) == 0 |
                    trans.TransactionType.In(
                    BudgetTransactionType.DirectCreditDebitMemoApproved,
                    BudgetTransactionType.DirectInvoiceApproved,
                    BudgetTransactionType.PurchaseApproved,
                    BudgetTransactionType.PurchaseCreditDebitMemoApproved,
                    BudgetTransactionType.PurchaseInvoiceApproved)) &

                    (trans.DateOfExpenditure < bp.Select(bp.StartDate.Min()).Where(bp.BudgetID == budgetId) |
                    trans.DateOfExpenditure > bp.Select(bp.EndDate.Max()).Where(bp.BudgetID == budgetId))), 0).As("Balance"))

                .Where(
                (accountIds == null ? Query.True : ac.ObjectID.In(accountIds))
                );

            dt.Columns.Add("BudgetPeriodID", typeof(Guid));
            return dt;
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
        public static string CheckSufficientBalance(List<OBudgetTransactionLog> transactions, ORequestForQuotation rfq)
        {
            DataTable dt = GetAvailableBalanceByTransactions(transactions);

            Hashtable availableBalance = new Hashtable();
            foreach (DataRow dr in dt.Rows)
                availableBalance[dr["BudgetID"] + "," + dr["BudgetPeriodID"] + "," + dr["AccountID"]] = dr;

            Hashtable reallocatedTo = new Hashtable();
            if (rfq != null && rfq.RFQBudgetReallocationToPeriods != null)
            {
                foreach (ORFQBudgetReallocationToPeriod p in rfq.RFQBudgetReallocationToPeriods)
                    foreach (ORFQBudgetReallocationTo to in p.RFQBudgetReallocationTos)
                    {
                        reallocatedTo[p.ToBudgetID.Value.ToString() + "," 
                            + p.ToBudgetPeriodID.Value.ToString() + "," 
                            + to.AccountID.Value.ToString()] = to.TotalAmount.Value;
                    }
            }

            // Go through all transactions and deduct the money from the 
            // availableBalance hash table.
            //
            foreach (OBudgetTransactionLog transaction in transactions)
            {
                // If the BudgetPeriodID is null, it is for a budget period that 
                // has not been created yet, so we do not check for sufficient balances.
                //
                // Also, if we are going to do a transfer from the budget
                // transaction from another budget transaction log record (this occurs
                // when we create RFQ from PO or create invoice from PO),
                // we should not be checking for budget balance, since the
                // amount transferred should always be less than or equal
                // to the original amount we transfer from.
                //
                if (transaction.BudgetPeriodID != null && transaction.TransferFromBudgetTransactionLogID == null)
                {
                    string key =
                        transaction.BudgetID.Value.ToString() + "," +
                        (transaction.BudgetPeriodID == null ? "" : transaction.BudgetPeriodID.Value.ToString()) + "," +
                        transaction.AccountID.Value.ToString();

                    ((DataRow)availableBalance[key])["Balance"] =
                        (decimal)((DataRow)availableBalance[key])["Balance"] -
                        transaction.TransactionAmount.Value;

                    if (reallocatedTo.ContainsKey(key))
                    {
                        ((DataRow)availableBalance[key])["Balance"] = 
                            (decimal)((DataRow)availableBalance[key])["Balance"] + 
                            ((decimal)reallocatedTo[key]);
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
        /// Checks and ensures that the spending policies are met.
        /// </summary>
        /// <param name="transactions"></param>
        /// <param name="rfq"></param>
        /// <returns></returns>
        public static string CheckSpendingPolicy(List<OBudgetTransactionLog> transactions)
        {
            string budgetNames = "";

            // Loads all the budgets related to the transactions up.
            //
            Hashtable budgetHash = new Hashtable();
            List<Guid> budgetIds = new List<Guid>();
            foreach (OBudgetTransactionLog transaction in transactions)
            {
                if (budgetHash[transaction.BudgetID.Value] == null)
                {
                    budgetHash[transaction.BudgetID.Value] = 1;
                    budgetIds.Add(transaction.BudgetID.Value);
                }
            }
            budgetHash = new Hashtable();
            List<OBudget> budgets = TablesLogic.tBudget.LoadList(
                TablesLogic.tBudget.ObjectID.In(budgetIds));
            foreach (OBudget budget in budgets)
                budgetHash[budget.ObjectID.Value] = budget;

            // Find the budget periods applicable to all transactions.
            //
            DetermineBudgetPeriods(transactions);

            // Go through all transactions and ensure that the budget periods
            // for the dates are available.
            //
            foreach (OBudgetTransactionLog transaction in transactions)
            {
                // If the BudgetPeriodID is null, it is for a budget period that 
                // has not been created yet, so we just have to check to ensure
                // that the budget has been created.
                //
                if (transaction.BudgetPeriodID == null)
                {
                    OBudget budget = budgetHash[transaction.BudgetID.Value] as OBudget;

                    if (budget.BudgetSpendingPolicy == 0)
                        budgetNames += budget.ObjectName + " (" + transaction.DateOfExpenditure.Value.ToString("dd-MMM-yyyy") + "); ";
                }
            }

            return budgetNames;
        }


        /// <summary>
        /// Generates the summarized budget view.
        /// </summary>
        /// <returns></returns>
        public DataTable GenerateSummaryBudgetViewWithoutTree(Guid? accountID)
        {
            
            TBudgetPeriodOpeningBalance ob = TablesLogic.tBudgetPeriodOpeningBalance;
            TBudgetVariationLog budgetVariationLog = TablesLogic.tBudgetVariationLog;
            TBudgetTransactionLog budgetTransactionLog = TablesLogic.tBudgetTransactionLog;
            DataTable dt1 = new DataTable();
            DataTable dt2 = new DataTable();
            

            OAccount account = TablesLogic.tAccount.Load(accountID);

     
               dt1 = ob.Select(
               ob.ObjectID,
               ob.AccountID,
               ob.Account.Type,
               ob.Account.ParentID,
               ob.TotalOpeningBalance,
               ob.BudgetPeriod.Budget.BudgetDeductionPolicy,
               budgetVariationLog.Select(Case.IsNull(budgetVariationLog.VariationAmount, 0).Sum())
                   .Where(
                   budgetVariationLog.IsDeleted == 0 &
                   budgetVariationLog.AccountID == ob.AccountID &
                   budgetVariationLog.BudgetPeriodID == this.ObjectID &
                   budgetVariationLog.VariationType == BudgetVariationType.Adjustment)
                   .As("TotalAdjustedAmount"),
               budgetVariationLog.Select(Case.IsNull(budgetVariationLog.VariationAmount, 0).Sum())
                   .Where(
                   budgetVariationLog.IsDeleted == 0 &
                   budgetVariationLog.AccountID == ob.AccountID &
                   budgetVariationLog.BudgetPeriodID == this.ObjectID &
                   budgetVariationLog.VariationType == BudgetVariationType.Reallocation &
                   (ob.BudgetPeriod.Budget.BudgetDeductionPolicy == null |
                       ob.BudgetPeriod.Budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission |
                       budgetVariationLog.VariationStatus != BudgetVariationStatus.PendingApproval))
                   .As("TotalReallocatedAmount"),

               budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                   .Where(
                   budgetTransactionLog.IsDeleted == 0 &
                   budgetTransactionLog.AccountID == ob.AccountID &
                   budgetTransactionLog.BudgetID == this.BudgetID &
                   this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                   budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                   budgetTransactionLog.TransactionType == BudgetTransactionType.PurchasePendingApproval)
                   .As("TotalPendingApproval"),
               budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                   .Where(
                   budgetTransactionLog.IsDeleted == 0 &
                   budgetTransactionLog.AccountID == ob.AccountID &
                   budgetTransactionLog.BudgetID == this.BudgetID &
                   this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                   budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                   (budgetTransactionLog.TransactionType == BudgetTransactionType.PurchaseApproved |
                   budgetTransactionLog.TransactionType == BudgetTransactionType.PurchaseInvoiceApproved))
                   .As("TotalApproved"),
               budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                   .Where(
                   budgetTransactionLog.IsDeleted == 0 &
                   budgetTransactionLog.AccountID == ob.AccountID &
                   budgetTransactionLog.BudgetID == this.BudgetID &
                   this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                   budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                   budgetTransactionLog.TransactionType == BudgetTransactionType.PurchaseInvoiceApproved)
                   .As("TotalInvoiceApproved"),
               budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                   .Where(
                   budgetTransactionLog.IsDeleted == 0 &
                   budgetTransactionLog.AccountID == ob.AccountID &
                   budgetTransactionLog.BudgetID == this.BudgetID &
                   this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                   budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                   budgetTransactionLog.TransactionType == BudgetTransactionType.DirectInvoicePendingApproval)
                   .As("TotalDirectInvoicePendingApproval"),
               budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                   .Where(
                   budgetTransactionLog.IsDeleted == 0 &
                   budgetTransactionLog.AccountID == ob.AccountID &
                   budgetTransactionLog.BudgetID == this.BudgetID &
                   this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                   budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                   budgetTransactionLog.TransactionType == BudgetTransactionType.DirectInvoiceApproved)
                   .As("TotalDirectInvoiceApproved"),
               budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.NonCommittedAmount, 0).Sum())
                   .Where(
                   budgetTransactionLog.IsDeleted == 0 &
                   budgetTransactionLog.AccountID == ob.AccountID &
                   budgetTransactionLog.BudgetID == this.BudgetID &
                   this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                   budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                   budgetTransactionLog.TransactionType == BudgetTransactionType.PurchaseCreditDebitMemoApproved)
                   .As("TotalPurchaseCreditDebitMemoApproved"),
               budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.NonCommittedAmount, 0).Sum())
                   .Where(
                   budgetTransactionLog.IsDeleted == 0 &
                   budgetTransactionLog.AccountID == ob.AccountID &
                   budgetTransactionLog.BudgetID == this.BudgetID &
                   this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                   budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                   budgetTransactionLog.TransactionType == BudgetTransactionType.DirectCreditDebitMemoApproved)
                   .As("TotalDirectCreditDebitMemoApproved")
                   )
               .Where(
                   ob.BudgetPeriodID == this.ObjectID &
                   (account == null ? Query.True : ob.Account.HierarchyPath.Like(account.HierarchyPath + "%")));
            //}
            dt1.Columns.Add("TotalBalanceAfterVariation", typeof(decimal));
            dt1.Columns.Add("TotalAvailableBalance", typeof(decimal));
            dt1.Columns.Add("TotalCreditDebitMemoApproved", typeof(decimal));
            foreach (DataRow dr in dt1.Rows)
            {
                foreach (DataColumn dc in dt1.Columns)
                    if (dc.DataType == typeof(decimal) && dr[dc.ColumnName] == DBNull.Value)
                        dr[dc.ColumnName] = 0;

                dr["TotalBalanceAfterVariation"] =
                    (decimal)dr["TotalOpeningBalance"] +
                    (decimal)dr["TotalAdjustedAmount"] +
                    (decimal)dr["TotalReallocatedAmount"];

                if (dr["BudgetDeductionPolicy"] == DBNull.Value ||
                    (int)dr["BudgetDeductionPolicy"] == BudgetDeductionPolicy.DeductAtSubmission)
                {
                    dr["TotalAvailableBalance"] =
                        (decimal)dr["TotalBalanceAfterVariation"] -
                        (decimal)dr["TotalPendingApproval"] -
                        (decimal)dr["TotalApproved"] -
                        (decimal)dr["TotalDirectInvoicePendingApproval"] -
                        (decimal)dr["TotalDirectInvoiceApproved"];
                }
                else
                {
                    dr["TotalAvailableBalance"] =
                        (decimal)dr["TotalBalanceAfterVariation"] -
                        (decimal)dr["TotalApproved"] -
                        (decimal)dr["TotalDirectInvoiceApproved"];
                }

                dr["TotalCreditDebitMemoApproved"] =
                    (decimal)dr["TotalPurchaseCreditDebitMemoApproved"] +
                    (decimal)dr["TotalDirectCreditDebitMemoApproved"];
            }

            // 2011 06 02, Kien Trung, CUSTOMIZED for CCL
            // Add in subtotal at category level of budget accounts
            //
            dt2 = ob.SelectDistinct
                (ob.Account.ParentID.As("AccountID"))
                .Where
                (ob.BudgetPeriodID == this.ObjectID &
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
                    if (dc.ColumnName.StartsWith("Total"))
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
            // 2011 06 02, Kien Trung, CUSTOMIZED END.

            dt1.Merge(dt2);
                
            
            return dt1;
        }




        /// <summary>
        /// Generates the yearly budget view.
        /// </summary>
        /// <returns></returns>
        public DataTable GenerateYearlyBudgetView(Guid? accountID)
        {
            TBudgetPeriodOpeningBalance ob = TablesLogic.tBudgetPeriodOpeningBalance;
            TBudgetVariationLog budgetVariationLog = TablesLogic.tBudgetVariationLog;
            TBudgetTransactionLog budgetTransactionLog = TablesLogic.tBudgetTransactionLog;
            OAccount account=TablesLogic.tAccount.Load(accountID);
            DateTime today = DateTime.Today;

            ExpressionDataNumeric ytdOpeningBalance = (ExpressionDataNumeric)0;
            DateTime currentDate = this.StartDate.Value;
            int c = 1;
            for (; currentDate <= this.EndDate.Value && currentDate <= today; currentDate = currentDate.AddMonths(this.NumberOfMonthsPerInterval.Value))
            {
                ytdOpeningBalance += ob.GetColumn("OpeningBalance" + String.Format("{0:00}", c)) as ExpressionDataNumeric;
                c++;
            }
            
            DataTable dt2 = new DataTable();
            DataTable dt1 = ob.Select(
                ob.ObjectID,
                ob.AccountID,
                ob.Account.ParentID,
                ob.Account.Type,
                ob.TotalOpeningBalance,
                ob.BudgetPeriod.Budget.BudgetDeductionPolicy,
                budgetVariationLog.Select(Case.IsNull(budgetVariationLog.VariationAmount, 0).Sum())
                    .Where(
                    budgetVariationLog.IsDeleted == 0 &
                    budgetVariationLog.AccountID == ob.AccountID &
                    budgetVariationLog.BudgetPeriodID == this.ObjectID &
                    budgetVariationLog.VariationType == BudgetVariationType.Adjustment)
                    .As("TotalAdjustedAmount"),
                budgetVariationLog.Select(Case.IsNull(budgetVariationLog.VariationAmount, 0).Sum())
                    .Where(
                    budgetVariationLog.IsDeleted == 0 &
                    budgetVariationLog.AccountID == ob.AccountID &
                    budgetVariationLog.BudgetPeriodID == this.ObjectID &
                    budgetVariationLog.VariationType == BudgetVariationType.Reallocation &
                    (ob.BudgetPeriod.Budget.BudgetDeductionPolicy == null |
                        ob.BudgetPeriod.Budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission |
                        budgetVariationLog.VariationStatus != BudgetVariationStatus.PendingApproval))
                    .As("TotalReallocatedAmount"),
                budgetVariationLog.Select(Case.IsNull(budgetVariationLog.VariationAmount, 0).Sum())
                    .Where(
                    budgetVariationLog.IsDeleted == 0 &
                    budgetVariationLog.AccountID == ob.AccountID &
                    budgetVariationLog.BudgetPeriodID == this.ObjectID &
                    budgetVariationLog.VariationType == BudgetVariationType.Reallocation &
                    budgetVariationLog.VariationStatus == BudgetVariationStatus.PendingApproval)
                    .As("TotalPendingApprovalReallocatedAmount"),

                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    budgetTransactionLog.TransactionType == BudgetTransactionType.PurchasePendingApproval)
                    .As("TotalPendingApproval"),
                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    budgetTransactionLog.DateOfExpenditure <= today &
                    budgetTransactionLog.TransactionType == BudgetTransactionType.PurchasePendingApproval)
                    .As("TotalPendingApprovalYTD"),

                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    (budgetTransactionLog.TransactionType == BudgetTransactionType.PurchaseApproved |
                    budgetTransactionLog.TransactionType == BudgetTransactionType.PurchaseInvoiceApproved))
                    .As("TotalApproved"),
                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    budgetTransactionLog.TransactionType == BudgetTransactionType.PurchaseInvoiceApproved)
                    .As("TotalInvoiceApproved"),
                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    budgetTransactionLog.TransactionType == BudgetTransactionType.DirectInvoicePendingApproval)
                    .As("TotalDirectInvoicePendingApproval"),
                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    budgetTransactionLog.TransactionType == BudgetTransactionType.DirectInvoiceApproved)
                    .As("TotalDirectInvoiceApproved"),

                (ytdOpeningBalance +
                Case.IsNull(budgetVariationLog.Select(Case.IsNull(budgetVariationLog.VariationAmount, 0).Sum())
                    .Where(
                    budgetVariationLog.DateOfVariation <= today &
                    budgetVariationLog.IsDeleted == 0 &
                    budgetVariationLog.AccountID == ob.AccountID &
                    budgetVariationLog.BudgetPeriodID == this.ObjectID), 0)).As("TotalBalanceAfterVariationYTD"),

                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    budgetTransactionLog.DateOfExpenditure <= today &
                    budgetTransactionLog.TransactionType != BudgetTransactionType.PurchasePendingApproval)
                    .As("TotalCommittedYTD"),
                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.StartDate <= budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.DateOfExpenditure <= this.EndDate &
                    today < budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.TransactionType != BudgetTransactionType.PurchasePendingApproval)
                    .As("TotalCommittedRestOfBudgetPeriod"),
                budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                    .Where(
                    budgetTransactionLog.IsDeleted == 0 &
                    budgetTransactionLog.AccountID == ob.AccountID &
                    budgetTransactionLog.BudgetID == this.BudgetID &
                    this.EndDate < budgetTransactionLog.DateOfExpenditure &
                    budgetTransactionLog.TransactionType != BudgetTransactionType.PurchasePendingApproval)
                    .As("TotalCommittedAfterCurrentBudgetPeriod")

                    )
                .Where(
                    ob.BudgetPeriodID == this.ObjectID&(
                    account == null ? Query.True : ob.Account.HierarchyPath.Like(account.HierarchyPath + "%")));

            dt1.Columns.Add("PercentageVarianceYTD", typeof(decimal));
            dt1.Columns.Add("TotalBalanceAfterVariation", typeof(decimal));
            dt1.Columns.Add("TotalAvailableBalance", typeof(decimal));
            dt1.Columns.Add("TotalAvailableBalanceExcludingPendingApprovals", typeof(decimal));
            foreach (DataRow dr in dt1.Rows)
            {
                foreach (DataColumn dc in dt1.Columns)
                    if (dc.DataType == typeof(decimal) && dr[dc.ColumnName] == DBNull.Value)
                        dr[dc.ColumnName] = 0;

                if ((decimal)dr["TotalBalanceAfterVariationYTD"] != 0)
                {
                    dr["PercentageVarianceYTD"] =
                        ((decimal)dr["TotalBalanceAfterVariationYTD"] -
                        (decimal)dr["TotalCommittedYTD"]) * 100M / (decimal)dr["TotalBalanceAfterVariationYTD"];
                }

                dr["TotalBalanceAfterVariation"] =
                    (decimal)dr["TotalOpeningBalance"] +
                    (decimal)dr["TotalAdjustedAmount"] +
                    (decimal)dr["TotalReallocatedAmount"];

                dr["TotalAvailableBalance"] =
                    (decimal)dr["TotalBalanceAfterVariation"] -
                    (decimal)dr["TotalPendingApproval"] -
                    (decimal)dr["TotalApproved"] -
                    (decimal)dr["TotalDirectInvoicePendingApproval"] -
                    (decimal)dr["TotalDirectInvoiceApproved"];

                dr["TotalAvailableBalanceExcludingPendingApprovals"] =
                    (decimal)dr["TotalBalanceAfterVariation"] -
                    (decimal)dr["TotalApproved"] -
                    (decimal)dr["TotalDirectInvoiceApproved"];
            }

            dt2 = ob.SelectDistinct
                (ob.Account.ParentID.As("AccountID"))
                .Where
                (ob.BudgetPeriodID == this.ObjectID & (
                account == null ? Query.True : ob.Account.HierarchyPath.Like(account.HierarchyPath + "%")));
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
                    if (dc.ColumnName.StartsWith("Total"))
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

        public DataTable GenerateIntervalViewForCapitaland(
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
        /// Gets the interval number given a date.
        /// </summary>
        /// <param name="date"></param>
        /// <returns></returns>
        public int GetIntervalNumber(DateTime date)
        {
            if (date < this.StartDate)
                return 1;
            if (date >= this.EndDate.Value.AddDays(1))
                return this.TotalNumberOfIntervals;

            // Add a column for each of the intervals to compute
            // the total available amount for that interval.
            //
            int currentInterval = 1;
            int totalIntervals = this.TotalNumberOfIntervals;
            for (currentInterval = 1; currentInterval <= totalIntervals; currentInterval++)
            {
                DateTime intervalStartDate = this.StartDate.Value.AddMonths(
                    (currentInterval - 1) * this.NumberOfMonthsPerInterval.Value);
                DateTime intervalEndDate = this.StartDate.Value.AddMonths(
                    (currentInterval) * this.NumberOfMonthsPerInterval.Value);
                if (intervalEndDate > this.EndDate.Value)
                    intervalEndDate = this.EndDate.Value.AddDays(1);

                if (intervalStartDate <= date && date < intervalEndDate)
                    return currentInterval;
            }

            // Returns the last interval
            //
            return this.TotalNumberOfIntervals;
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
        public static string CheckSufficientBalanceAfterUpdatingUnitpriceAndQuantity(DataList<OPurchaseBudget> purchaseBudgets)
        {

            StringBuilder sb = new StringBuilder();

            // Go through all transactions and deduct the money from the 
            // availableBalance hash table.
            //
            foreach (OPurchaseBudget pb in purchaseBudgets)
            {
                List<OBudgetTransactionLog> transactions = TablesLogic.tBudgetTransactionLog.LoadList(
                                                            TablesLogic.tBudgetTransactionLog.PurchaseBudgetID == pb.ObjectID);
                if (transactions.Count > 0)
                {
                    DataTable dt = GetAvailableBalanceByTransactions(transactions);
                    Hashtable availableBalance = new Hashtable();
                    foreach (DataRow dr in dt.Rows)
                        availableBalance[dr["BudgetID"] + "," + dr["BudgetPeriodID"] + "," + dr["AccountID"]] = dr;


                    // This is because the transaction amount in the new budget transaction log may be greater
                    // than the amount after updating unit price and quantity in pending receipt status.
                    /*
               
                     */
                    OBudgetTransactionLog transaction = transactions[0];//this is because in capitaland 1 purchase budget only has 1 transaction log
                    if (transaction.BudgetPeriodID != null)
                    {
                        // Here, we only compute the available balance
                        decimal previousTransactionLogAmount = 0;
                        if (transaction.TransactionAmount != null)
                            previousTransactionLogAmount = transaction.TransactionAmount.Value;
                        if (previousTransactionLogAmount < pb.Amount)
                        {
                            string key =
                                transaction.BudgetID.Value.ToString() + "," +
                                (transaction.BudgetPeriodID == null ? "" : transaction.BudgetPeriodID.Value.ToString()) + "," +
                                transaction.AccountID.Value.ToString();

                            ((DataRow)availableBalance[key])["Balance"] =
                                (decimal)((DataRow)availableBalance[key])["Balance"] +
                                previousTransactionLogAmount -
                                pb.Amount;
                        }
                    }
                    // Go through all available balances and see 
                    // which one budget period / account is insufficient.
                    //

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
                }
            }

            
            return sb.ToString();
        }

    }
    
}
