//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPurchaseBudget : LogicLayerSchema<OPurchaseBudget>
    {

        public SchemaGuid PurchaseBudgetID;
        public SchemaGuid PurchaseInvoiceID;
        public SchemaGuid PurchaseRequestID;
        public SchemaGuid RequestForQuotationID;
        public SchemaGuid PurchaseOrderID;
        public SchemaInt ItemNumber;
        public SchemaGuid BudgetID;
        public SchemaGuid AccountID;
        public SchemaDateTime StartDate;
        public SchemaDateTime EndDate;
        [Default(1)]
        public SchemaInt AccrualFrequencyInMonths;
        public SchemaDecimal Amount;
        public SchemaGuid TransferFromBudgetTransactionLogID;
        public SchemaGuid TransferFromPurchaseBudgetID;

        public TPurchaseRequest PurchaseRequest { get { return OneToOne<TPurchaseRequest>("PurchaseRequestID"); } }
        public TBudget Budget { get { return OneToOne<TBudget>("BudgetID"); } }
        public TAccount Account { get { return OneToOne<TAccount>("AccountID"); } }
    }


    /// <summary>
    /// Represents the budget distributions in a purchase request, request for quotation
    /// or a purchase order object.
    /// </summary>
    public abstract partial class OPurchaseBudget : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseBudget table 
        /// that indicates the source purchase budget that generated
        /// this purchase budget.
        /// </summary>
        public abstract Guid? PurchaseBudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseInvoice table 
        /// that indicates the purchase invoice that contains this item.
        /// </summary>
        public abstract Guid? PurchaseInvoiceID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseRequest table 
        /// that indicates the purchase request that contains this item.
        /// </summary>
        public abstract Guid? PurchaseRequestID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the RequestForQuotation table 
        /// that indicates the request for quotation that contains this item.
        /// </summary>
        public abstract Guid? RequestForQuotationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseOrder table 
        /// that indicates the request for quotation that contains this item.
        /// </summary>
        public abstract Guid? PurchaseOrderID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the item number of the purchase request item,
        /// request for quotation item, or the purchase order item that
        /// this budget applies to. If the budget is applied to the entire
        /// WJ/RFQ/PO, then this will be left as null.
        /// </summary>
        public abstract Int32? ItemNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Budget table 
        /// that indicates the budget that the amount will be committed
        /// against.
        /// </summary>
        public abstract Guid? BudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Budget table 
        /// that indicates the account of the budget that the amount 
        /// will be committed against.
        /// </summary>
        public abstract Guid? AccountID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the start date that the amount
        /// will be committed to the budget.
        /// </summary>
        public abstract DateTime? StartDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the end date that the amount
        /// will be committed to the budget.
        /// </summary>
        public abstract DateTime? EndDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the frequency in 
        /// the number months that the amount accrued between
        /// the start and end date.
        /// </summary>
        public abstract Int32? AccrualFrequencyInMonths { get; set; }

        /// <summary>
        /// [Column] Gets or sets the amount that the budget
        /// will be committed to the budget.
        /// </summary>
        public abstract Decimal? Amount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to
        /// the BudgetTransactionLog table that indicates
        /// the log entry that the amount wil be deducted from.
        /// </summary>
        public abstract Guid? TransferFromBudgetTransactionLogID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to
        /// the PurchaseBudget table that indicates
        /// the purchase budget of the original purchase document
        /// that all transactions for the current purchase document 
        /// will be created from.
        /// </summary>
        public abstract Guid? TransferFromPurchaseBudgetID { get; set; }

        /// <summary>
        /// Gets or sets the OPurchaseRequest object that represents
        /// the purchase request that contains this item.
        /// </summary>
        public abstract OPurchaseRequest PurchaseRequest { get; set; }

        /// <summary>
        /// Gets or sets the OBudget object the represents that
        /// budget that the amount will be committed
        /// against.
        /// </summary>
        public abstract OBudget Budget { get; set; }

        /// <summary>
        /// Gets or sets the OAccount object that represents the
        /// account of the budget that the amount 
        /// will be committed against.
        /// </summary>
        public abstract OAccount Account { get; set; }


        /// <summary>
        /// Creates a list of budget transaction logs from the 
        /// specified list of purchase budget distributions and returns
        /// the list through the newTransactionLogs parameter. If
        /// there are any existing transaction logs that are modified,
        /// they will be returned through the modifiedTransactionLogs
        /// parameter.
        /// <para></para>
        /// This method does not save any of the created or modified
        /// transaction logs into the database.
        /// </summary>
        /// <returns></returns>
        public static List<OBudgetTransactionLog> CreateBudgetTransactionLogs(
            DataList<OPurchaseBudget> purchaseBudgets, int transactionType,
            List<OBudgetTransactionLog> newTransactionLogs,
            List<OBudgetTransactionLog> modifiedTransactionLogs)
        {
            foreach (OPurchaseBudget budget in purchaseBudgets)
            {
                if (budget.TransferFromBudgetTransactionLogID != null)
                {
                    // If the purchase budget record indicates that there
                    // is a partial transfer from an existing budget
                    // transaction record, then reduce that budget transaction
                    // record by that amount and transfer it to a
                    // new transaction.
                    //
                    // (This will be executed when creating an Invoice 
                    // from a PO).
                    //
                    OBudgetTransactionLog transferFromLog =
                        TablesLogic.tBudgetTransactionLog.Load(budget.TransferFromBudgetTransactionLogID);
                    if (transferFromLog != null && transferFromLog.TransactionAmount >= budget.Amount)
                    {
                        OBudgetTransactionLog newLog = TablesLogic.tBudgetTransactionLog.Create();
                        newLog.TransactionType = transactionType;
                        newLog.BudgetID = transferFromLog.BudgetID;
                        newLog.AccountID = transferFromLog.AccountID;
                        newLog.PurchaseBudgetID = budget.ObjectID;
                        newLog.DateOfExpenditure = transferFromLog.DateOfExpenditure;
                        newLog.TransactionAmount = budget.Amount;
                        newLog.TransferFromBudgetTransactionLogID = transferFromLog.ObjectID;
                        if (newTransactionLogs != null)
                            newTransactionLogs.Add(newLog);

                        // 2010.07.16
                        // Kim Foong
                        // Modified this to allow the partial transfer 
                        // of invoice amount to be greater than the PO amount.
                        // And if so, put that amount in another field called
                        // the ReturnAmount, so that when an invoice greater
                        // than the PO is cancelled, we transfer the the ReturnAmount
                        // back to the PO.
                        // 
                        if (transferFromLog.TransactionAmount < budget.Amount)
                        {
                            newLog.ReturnAmount = transferFromLog.TransactionAmount;
                            transferFromLog.TransactionAmount = 0;
                        }
                        else
                        {
                            newLog.ReturnAmount = null;
                            transferFromLog.TransactionAmount -= budget.Amount;
                        }
                        if (modifiedTransactionLogs != null)
                            modifiedTransactionLogs.Add(transferFromLog);
                    }
                    else
                    {
                        /* 2010.09.26
                         * Kim Foong
                         * Added this back in to prevent mis-entry of invoice purchase budget amounts.
                         * */
                        throw new Exception(
                            String.Format(Resources.Errors.PurchaseBudget_UnableToTransferAmountFromTransactionLog, budget.Amount.Value));
                    }
                }
                else if (budget.TransferFromPurchaseBudgetID != null)
                {
                    // If the purchase budget record indicates that
                    // there is a transfer from another purchase budget
                    // record, then transfer all transaction logs
                    // from the previous document to the new document.
                    //
                    // (This occurs when an RFQ is converted to a PO).
                    //
                    List<OBudgetTransactionLog> transferFromLogs = TablesLogic.tBudgetTransactionLog.LoadList(
                        TablesLogic.tBudgetTransactionLog.PurchaseBudgetID == budget.TransferFromPurchaseBudgetID);

                    foreach (OBudgetTransactionLog transferFromLog in transferFromLogs)
                    {
                        OBudgetTransactionLog newLog = TablesLogic.tBudgetTransactionLog.Create();
                        newLog.TransactionType = transactionType;
                        newLog.BudgetID = transferFromLog.BudgetID;
                        newLog.AccountID = transferFromLog.AccountID;
                        newLog.PurchaseBudgetID = budget.ObjectID;
                        newLog.DateOfExpenditure = transferFromLog.DateOfExpenditure;
                        newLog.TransactionAmount = transferFromLog.TransactionAmount;
                        newLog.TransferFromBudgetTransactionLogID = transferFromLog.ObjectID;
                        if (newTransactionLogs != null)
                            newTransactionLogs.Add(newLog);

                        transferFromLog.TransactionAmount = 0;
                        if (modifiedTransactionLogs != null)
                            modifiedTransactionLogs.Add(transferFromLog);
                    }
                }
                else
                {
                    // If the two conditions above is not satisfied,
                    // this means that the current purchase document 
                    // is a new document and was not transferred from
                    // a previous purchase document.
                    //
                    // (This means that this occurs only when an RFQ,
                    // or PO, or Direct Invoice is newly created.)
                    //

                    // Determine the total number of months to divide
                    // the total commit amount.
                    //
                    int numberOfMonths = 0;
                    DateTime currentDate = budget.StartDate.Value;
                    while (currentDate <= budget.EndDate.Value)
                    {
                        numberOfMonths++;
                        currentDate = budget.StartDate.Value.AddMonths(numberOfMonths);
                    }
                    if (numberOfMonths == 0)
                        numberOfMonths = 1;

                    decimal amountPerMonth = Math.Round(budget.Amount.Value / numberOfMonths, 2, MidpointRounding.AwayFromZero);

                    // Then create the budget transaction log entries.
                    //
                    for (int i = 0; i < numberOfMonths; i++)
                    {
                        if (i == numberOfMonths - 1)
                            amountPerMonth = budget.Amount.Value - amountPerMonth * (numberOfMonths - 1);

                        OBudgetTransactionLog newLog = TablesLogic.tBudgetTransactionLog.Create();
                        newLog.TransactionType = transactionType;
                        newLog.BudgetID = budget.BudgetID;
                        newLog.AccountID = budget.AccountID;
                        newLog.PurchaseBudgetID = budget.ObjectID;
                        newLog.DateOfExpenditure = budget.StartDate.Value.AddMonths(i);
                        newLog.TransactionAmount = amountPerMonth;
                        newLog.TransferFromBudgetTransactionLogID = null;
                        if (newTransactionLogs != null)
                            newTransactionLogs.Add(newLog);
                    }
                }
            }
            return newTransactionLogs;
        }


        /// <summary>
        /// Creates a list of budget transaction logs from the 
        /// specified list of purchase budget distribution. Unlike
        /// the CreateBudgetTransactionLogs
        /// </summary>
        /// <returns></returns>
        public static List<OBudgetTransactionLog> CreateCreditDebitMemoBudgetTransactionLogs(
            DataList<OPurchaseBudget> purchaseBudgets,
            int transactionType,
            List<OBudgetTransactionLog> newTransactionLogs)
        {
            foreach (OPurchaseBudget budget in purchaseBudgets)
            {
                // Determine the total number of months to divide
                // the total commit amount.
                //
                int numberOfMonths = 0;
                DateTime currentDate = budget.StartDate.Value;
                while (currentDate <= budget.EndDate.Value)
                {
                    numberOfMonths++;
                    currentDate = budget.StartDate.Value.AddMonths(numberOfMonths);
                }
                if (numberOfMonths == 0)
                    numberOfMonths = 1;

                decimal amountPerMonth = Math.Round(budget.Amount.Value / numberOfMonths, 2, MidpointRounding.AwayFromZero);

                // Then create the budget transaction log entries.
                //
                for (int i = 0; i < numberOfMonths; i++)
                {
                    if (i == numberOfMonths - 1)
                        amountPerMonth = budget.Amount.Value - amountPerMonth * (numberOfMonths - 1);

                    OBudgetTransactionLog newLog = TablesLogic.tBudgetTransactionLog.Create();
                    newLog.TransactionType = transactionType;
                    newLog.BudgetID = budget.BudgetID;
                    newLog.AccountID = budget.AccountID;
                    newLog.PurchaseBudgetID = budget.ObjectID;
                    newLog.DateOfExpenditure = budget.StartDate.Value.AddMonths(i);
                    newLog.TransactionAmount = amountPerMonth;
                    newLog.TransferFromBudgetTransactionLogID = null;
                    if (newTransactionLogs != null)
                        newTransactionLogs.Add(newLog);
                }
            }
            return newTransactionLogs;
        }


        /// <summary>
        /// Gets all budget transaction logs.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <returns></returns>
        public static List<OBudgetTransactionLog> GetBudgetTransactionLogs(
            DataList<OPurchaseBudget> purchaseBudgets)
        {
            List<Guid> purchaseBudgetIds = new List<Guid>();
            foreach (OPurchaseBudget purchaseBudget in purchaseBudgets)
                purchaseBudgetIds.Add(purchaseBudget.ObjectID.Value);

            return TablesLogic.tBudgetTransactionLog.LoadList(
                TablesLogic.tBudgetTransactionLog.PurchaseBudgetID.In(purchaseBudgetIds));
        }


        /// <summary>
        /// Sets the purchase budget transaction log's transaction types.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <returns></returns>
        public static List<OBudgetTransactionLog> SetBudgetTransactionLogsTransactionType(
            DataList<OPurchaseBudget> purchaseBudgets,
            int transactionType)
        {
            using (Connection c = new Connection())
            {
                List<OBudgetTransactionLog> logs = GetBudgetTransactionLogs(purchaseBudgets);

                foreach (OBudgetTransactionLog log in logs)
                {
                    log.TransactionType = transactionType;
                    log.Save();
                }
                c.Commit();

                return logs;
            }
        }


        /// <summary>
        /// Sets the purchase budget transaction log's transaction types.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <returns></returns>
        public static List<OBudgetTransactionLog> SetBudgetTransactionLogsTransactionTypeAndTransferToNonCommitted(
            DataList<OPurchaseBudget> purchaseBudgets,
            int transactionType)
        {
            using (Connection c = new Connection())
            {
                List<OBudgetTransactionLog> logs = GetBudgetTransactionLogs(purchaseBudgets);

                foreach (OBudgetTransactionLog log in logs)
                {
                    log.TransactionType = transactionType;
                    log.TransferTransactionAmountToNonCommittedAmount();
                    log.Save();
                }
                c.Commit();

                return logs;
            }
        }


        /// <summary>
        /// Transfer all budget transactions that belongs
        /// to the specified itemNumber to another document.
        /// <para></para>
        /// This mehtod is called when an RFQ is copied to a PO.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <param name="itemNumber"></param>
        public static List<OPurchaseBudget> TransferPurchaseBudgets(
            DataList<OPurchaseBudget> purchaseBudgets,
            int? itemNumber)
        {
            using (Connection c = new Connection())
            {
                List<OPurchaseBudget> newPurchaseBudgets = new List<OPurchaseBudget>();
                Hashtable hashedNewPurchaseBudgets = new Hashtable();
                List<Guid> purchaseBudgetIds = new List<Guid>();

                foreach (OPurchaseBudget budget in purchaseBudgets)
                    if (itemNumber == null || budget.ItemNumber == null ||
                        itemNumber == budget.ItemNumber.Value)
                    {
                        purchaseBudgetIds.Add(budget.ObjectID.Value);
                        OPurchaseBudget newPurchaseBudget = TablesLogic.tPurchaseBudget.Create();
                        OBudgetTransactionLog oldBudgetTransactionLog = TablesLogic.tBudgetTransactionLog.Load(TablesLogic.tBudgetTransactionLog.PurchaseBudgetID == budget.ObjectID);
                        // The caller must fill up the RFQID, PurchaseOrderID
                        // and item numbers.
                        //
                        newPurchaseBudget.ShallowCopy(budget);
                        newPurchaseBudget.PurchaseBudgetID = budget.ObjectID;
                        newPurchaseBudget.Save();
                        newPurchaseBudget.PurchaseOrderID = null;
                        newPurchaseBudget.PurchaseRequestID = null;
                        newPurchaseBudget.RequestForQuotationID = null;
                        newPurchaseBudget.TransferFromPurchaseBudgetID = budget.ObjectID;

                        // 2011.06.25, Kien Trung
                        // FIX: Capture TransferfrombudgettransactionlogID for report purpose
                        //
                        if (oldBudgetTransactionLog != null)
                            newPurchaseBudget.TransferFromBudgetTransactionLogID = oldBudgetTransactionLog.ObjectID;

                        newPurchaseBudgets.Add(newPurchaseBudget);

                        hashedNewPurchaseBudgets[budget.ObjectID.Value] = newPurchaseBudget;
                    }

                c.Commit();

                return newPurchaseBudgets;
            }
        }


        /// <summary>
        /// Validates to ensure that all the purchase budgets in a list 
        /// will commit against budget periods that do not yet exist,
        /// or budget periods that are not closed.
        /// <para></para>
        /// This method will return the list of budget periods that
        /// fail this validation.
        /// </summary>
        /// <returns>
        /// Returns the list of budget periods that
        /// fail this validation
        /// </returns>
        public static string ValidateBudgetPeriodsActiveAndOpened(DataList<OPurchaseBudget> purchaseBudgets)
        {
            StringBuilder sb = new StringBuilder();

            // Here, we construct a condition that allows us to load
            // all budgets that the list of purchase budgets will commit
            // against.
            //
            TBudgetPeriod bp = TablesLogic.tBudgetPeriod;
            ExpressionCondition cond = Query.False;
            foreach (OPurchaseBudget purchaseBudget in purchaseBudgets)
            {
                ExpressionCondition subcond = Query.False;
                for (DateTime d = purchaseBudget.StartDate.Value; d <= purchaseBudget.EndDate.Value; d = d.AddMonths(purchaseBudget.AccrualFrequencyInMonths.Value))
                    subcond = subcond | (bp.StartDate <= d & bp.EndDate >= d);
                cond = cond | (bp.BudgetID == purchaseBudget.BudgetID & subcond);
            }

            // Then we load all the budget periods matching our condition.
            //
            List<OBudgetPeriod> budgetPeriods = bp.LoadList(cond & bp.CurrentActivity.ObjectName != "Cancelled");
            foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
            {
                if (budgetPeriod.IsActive != 1 ||
                    (budgetPeriod.ClosingDate != null &&
                    budgetPeriod.ClosingDate <= DateTime.Today))
                    sb.Append(budgetPeriod.ObjectName + " (" + budgetPeriod.Budget.ObjectName + ")");
            }

            return sb.ToString();
        }


        // 2010.01.07
        // Kim Foong
        /// <summary>
        /// Get the accrual date that commits to a budget that is not created,
        /// or not closed.
        /// </summary>
        /// <param name="budgetPeriods"></param>
        /// <param name="currentAccrualDate"></param>
        /// <returns></returns>
        public static DateTime GetAccrualDateToCommitToNonClosedBudget(
            ArrayList budgetPeriods, 
            DateTime currentAccrualDate)
        {
            if (budgetPeriods == null)
                return currentAccrualDate;

            // Chronologically loop through each budget
            // period (the budgetPeriods must be sorted earliest first)
            //
            foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
            {
                if (budgetPeriod.StartDate <= currentAccrualDate &&
                    currentAccrualDate <= budgetPeriod.EndDate &&
                    budgetPeriod.ClosingDate <= DateTime.Today)
                {
                    currentAccrualDate = budgetPeriod.EndDate.Value.AddDays(1);
                }
            }
            return currentAccrualDate;
        }


        /// <summary>
        /// Transfers partial budget transaction log amounts to another 
        /// document. This method is used to transfer PO budget commitments
        /// to an invoice (which can be a partial amount of the PO). 
        /// <para></para>
        /// Once the partial amounts have been deducted from the previous
        /// document's transaction logs, new PurchaseBudget objects with
        /// the transaction logs will be created for this document.
        /// <para></para>
        /// This mehtod is called when a PO is matched to an Invoice.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <param name="itemNumber"></param>
        public static List<OPurchaseBudget> TransferPartialPurchaseBudgets(
            DataList<OPurchaseBudget> purchaseBudgets,
            int? itemNumber,
            decimal? transactionAmount)
        {
            // Get the list of all purchase budget IDs
            // based on the line item number.
            //
            List<Guid> purchaseBudgetIds = new List<Guid>();
            foreach (OPurchaseBudget budget in purchaseBudgets)
                if (budget.ItemNumber == itemNumber || itemNumber == null)
                    purchaseBudgetIds.Add(budget.ObjectID.Value);

            // Gets the latest date for the transaction logs. Always 
            // retrieving the last batch of transaction logs allows
            // the invoice amount to be greater than the PO under
            // any circumstance.
            //
            DateTime maxDate = TablesLogic.tBudgetTransactionLog.Select(
                TablesLogic.tBudgetTransactionLog.DateOfExpenditure.Max())
                .Where(
                TablesLogic.tBudgetTransactionLog.IsDeleted == 0 &
                TablesLogic.tBudgetTransactionLog.PurchaseBudgetID.In(purchaseBudgetIds));

            if (maxDate.Year < 1900)
                maxDate = new DateTime(1900, 1, 1);

            // Then load the list of all logs that belong
            // to the respective purchase budgets.
            //
            List<OBudgetTransactionLog> logs =
                TablesLogic.tBudgetTransactionLog.LoadList(
                (TablesLogic.tBudgetTransactionLog.DateOfExpenditure == maxDate |
                TablesLogic.tBudgetTransactionLog.TransactionAmount > 0) &
                TablesLogic.tBudgetTransactionLog.PurchaseBudgetID.In(purchaseBudgetIds));

            List<DateTime> dateOfTransactions = new List<DateTime>();
            Hashtable transactionsByDate = new Hashtable();

            // Construct a hashtable of all transactions.
            //
            foreach (OBudgetTransactionLog log in logs)
            {
                DateTime date = log.DateOfExpenditure.Value;

                if (transactionsByDate[date] == null)
                {
                    transactionsByDate[date] = new List<OBudgetTransactionLog>();
                    dateOfTransactions.Add(date);
                }
                List<OBudgetTransactionLog> logList = transactionsByDate[date] as List<OBudgetTransactionLog>;
                logList.Add(log);
            }
            dateOfTransactions.Sort();

            // 2011.01.07
            // Kim Foong
            // Loads up all the budgets and budget periods related to the transaction logs.
            // 
            Hashtable relatedBudgetPeriods = new Hashtable();

            // Then transfer the amounts over.
            //
            List<OPurchaseBudget> newPurchaseBudgets = new List<OPurchaseBudget>();
            foreach (DateTime dateOfTransaction in dateOfTransactions)
            {
                List<OBudgetTransactionLog> logList = transactionsByDate[dateOfTransaction] as List<OBudgetTransactionLog>;

                // First compute the total amount remaining in the transaction
                // logs. 
                // 
                decimal totalRemainingAmount = 0;
                foreach (OBudgetTransactionLog log in logList)
                    totalRemainingAmount += log.TransactionAmount.Value;
                decimal totalRemainingAmountLeft = totalRemainingAmount;

                if (transactionAmount >= totalRemainingAmount)
                {
                    // If the transaction amount is equal to or more
                    // than the total remaining amount, then we can
                    // distribute it to all the transaction logs.
                    //
                    foreach (OBudgetTransactionLog log in logList)
                    {
                        OPurchaseBudget purchaseBudget = TablesLogic.tPurchaseBudget.Create();
                        // 2011.08.01, Kien Trung
                        // ADDED: Carry Item Number for transfer log.
                        //
                        purchaseBudget.ItemNumber = log.PurchaseBudget.ItemNumber;
                        purchaseBudget.BudgetID = log.BudgetID;
                        purchaseBudget.AccountID = log.AccountID;
                        purchaseBudget.Amount = log.TransactionAmount;
                        purchaseBudget.StartDate = log.DateOfExpenditure;
                        purchaseBudget.EndDate = log.DateOfExpenditure;

                        // 2011.01.07
                        // Kim Foong
                        // Force the purchase budget to use the following year's budget by setting the
                        // following year's accrual if the budget period for the original year is closed.
                        //
                        if (OApplicationSetting.Current.AllowInvoiceToUseCurrentYearBudgetIfPreviousIsClosed == 1)
                        {
                            if (relatedBudgetPeriods[purchaseBudget.BudgetID.Value] == null)
                            {
                                relatedBudgetPeriods[purchaseBudget.BudgetID.Value] = new ArrayList();
                                ArrayList periods = (ArrayList)relatedBudgetPeriods[purchaseBudget.BudgetID.Value];

                                // We only load budgets that are closed. Those are not yet closed,
                                // or have not been created yet, we'll ignore.
                                // 
                                List<OBudgetPeriod> budgetPeriods = TablesLogic.tBudgetPeriod.LoadList(
                                    TablesLogic.tBudgetPeriod.BudgetID == purchaseBudget.BudgetID,
                                    TablesLogic.tBudgetPeriod.StartDate.Asc);
                                foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
                                    periods.Add(budgetPeriod);
                            }

                            // 2011.01.07
                            // Kim Foong
                            // Force the purchase budget to use the following year's budget by setting the
                            // following year's accrual if the budget period for the original year is closed.
                            //
                            DateTime originalDate = purchaseBudget.StartDate.Value;

                            purchaseBudget.StartDate = OPurchaseBudget.GetAccrualDateToCommitToNonClosedBudget(
                                (ArrayList)relatedBudgetPeriods[purchaseBudget.BudgetID.Value], purchaseBudget.StartDate.Value);
                            purchaseBudget.EndDate = purchaseBudget.StartDate;
                            if (purchaseBudget.StartDate.Value != originalDate)
                                purchaseBudget.AccrualDateModifiedDueToBudgetClosed = 1;
                        }

                        purchaseBudget.AccrualFrequencyInMonths = 1;
                        purchaseBudget.TransferFromBudgetTransactionLogID = log.ObjectID;

                        // 2011.06.25, Kien Trung
                        // FIX: Capture TransferFromPurchaseBudgetID for partial PO.
                        purchaseBudget.TransferFromPurchaseBudgetID = log.PurchaseBudgetID;

                        newPurchaseBudgets.Add(purchaseBudget);

                        // 2010.07.16
                        // Kim Foong
                        // Fix to reduce the transaction amount.
                        //
                        transactionAmount -= purchaseBudget.Amount.Value;
                    }
                }
                else
                {
                    // Otherwise, we have to aportion the transaction
                    // amount (based on the pro-rate of the remaining
                    // amounts left in each individual transaction) 
                    // to the various budgets and accounts.
                    //
                    for (int i = 0; i < logList.Count; i++)
                    {
                        OBudgetTransactionLog log = logList[i];
                        OPurchaseBudget purchaseBudget = TablesLogic.tPurchaseBudget.Create();
                        // 2011.08.01, Kien Trung
                        // ADDED: Carry Item Number for transfer log.
                        //
                        purchaseBudget.ItemNumber = log.PurchaseBudget.ItemNumber;
                        purchaseBudget.BudgetID = log.BudgetID;
                        purchaseBudget.AccountID = log.AccountID;
                        // 2010.07.20
                        // Chin Weng
                        // Bug fix to test "!=" instead of "=="
                        //if (i == logList.Count - 1)
                        if (i != logList.Count - 1)
                            purchaseBudget.Amount =
                                Math.Round(
                                log.TransactionAmount.Value * transactionAmount.Value / totalRemainingAmount,
                                2, MidpointRounding.AwayFromZero);
                        else
                            // 2010.07.30
                            // Kim Foong
                            // Should use the transaction amount instead of the total remaining amount.
                            //
                            purchaseBudget.Amount = transactionAmount;
                        totalRemainingAmountLeft -= purchaseBudget.Amount.Value;
                        purchaseBudget.StartDate = log.DateOfExpenditure;
                        purchaseBudget.EndDate = log.DateOfExpenditure;
                        purchaseBudget.AccrualFrequencyInMonths = 1;
                        purchaseBudget.TransferFromBudgetTransactionLogID = log.ObjectID;

                        // 2011.06.25, Kien Trung
                        // FIX: Capture TransferFromPurchaseBudgetID for PO.
                        purchaseBudget.TransferFromPurchaseBudgetID = log.PurchaseBudgetID;

                        newPurchaseBudgets.Add(purchaseBudget);

                        // 2010.07.16
                        // Kim Foong
                        // Fix to reduce the transaction amount.
                        //
                        transactionAmount -= purchaseBudget.Amount.Value;
                    }
                }
            }

            // 2010.07.16
            // Kim Foong
            // Put the balance transaction amount back into the last budget,
            // and let the user decide what to do with it.
            //
            if (transactionAmount > 0 && newPurchaseBudgets.Count > 0)
                newPurchaseBudgets[newPurchaseBudgets.Count - 1].Amount += transactionAmount;

            return newPurchaseBudgets;
        }



        /// <summary>
        /// Deactivates all budget transactions that belongs
        /// to the specified itemNumber, but it does not
        /// transfer the amount back to the originating
        /// purchase document.
        /// <para></para>
        /// This method is called when (a) an RFQ is rejected
        /// or closed, (b) a PO is rejected or closed, (c)
        /// an Invoice is rejected.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <param name="itemNumber"></param>
        public static void ClearBudgetTransactionLogs(DataList<OPurchaseBudget> purchaseBudgets)
        {
            List<OBudgetTransactionLog> logs = GetBudgetTransactionLogs(purchaseBudgets);

            using (Connection c = new Connection())
            {
                // Then deactivate all the logs so that they
                // are no longer committed to the budget.
                //
                foreach (OBudgetTransactionLog log in logs)
                {
                    log.TransactionAmount = 0;
                    log.Save();
                    log.Deactivate();
                }
                c.Commit();
            }
        }


        /// <summary>
        /// Deactivates all budget transactions that belongs
        /// to the specified itemNumber, and
        /// transfer the amount back to the originating
        /// purchase document.
        /// <para></para>
        /// This method is called when (a) an RFQ is cancelled, 
        /// (b) a PO is cancelled, (c) an Invoice is cancelled.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        public static void UndoTransferBudgetTransactionLogs(DataList<OPurchaseBudget> purchaseBudgets)
        {
            List<OBudgetTransactionLog> logs = GetBudgetTransactionLogs(purchaseBudgets);

            using (Connection c = new Connection())
            {
                foreach (OBudgetTransactionLog log in logs)
                {
                    // If the transaction log originates from
                    // another transaction log, then transfer
                    // the amount back to the original transaction
                    // log.
                    //
                    // However, if the originating transaction log
                    // is already cancelled (because the originating
                    // document has been cancelled), then the budget
                    // amount is released completely.
                    //
                    if (log.TransferFromBudgetTransactionLogID != null)
                    {
                        OBudgetTransactionLog originalLog =
                            TablesLogic.tBudgetTransactionLog.Load(log.TransferFromBudgetTransactionLogID);
                        if (originalLog != null)
                        {
                            // Choose either the return amount or transaction amount
                            // to add back to the original transaction log.
                            //
                            if (log.ReturnAmount != null)
                                originalLog.TransactionAmount += log.ReturnAmount;
                            else if (log.TransactionAmount != null)
                                originalLog.TransactionAmount += log.TransactionAmount;

                            if (log.NonCommittedAmount != null)
                                originalLog.TransactionAmount += log.NonCommittedAmount;
                            originalLog.Save();
                        }
                    }

                    // Then deactivate all the logs so that they
                    // are no longer committed to the budget.
                    //
                    log.TransactionAmount = 0;
                    log.Save();
                    log.Deactivate();
                }
                c.Commit();
            }
        }


        /// <summary>
        /// Validates the ensure that the selected budget accounts
        /// are valid before submitting the RFQ for approval and returns
        /// a list of inactive budget periods and accounts, if any.
        /// </summary>
        /// <returns></returns>
        public static string ValidateBudgetAccountsAreActive(DataList<OPurchaseBudget> purchaseBudgets)
        {
            List<Guid> budgetIds = new List<Guid>();
            List<Guid> accountIds = new List<Guid>();
            List<DateTime> dates = new List<DateTime>();

            foreach (OPurchaseBudget pBudget in purchaseBudgets)
            {
                budgetIds.Add(pBudget.BudgetID.Value);
                accountIds.Add(pBudget.AccountID.Value);
                dates.Add(pBudget.StartDate.Value);
            }

            List<OBudgetPeriodOpeningBalance> balances =
                OBudgetPeriodOpeningBalance.GetBudgetPeriodOpeningBalanceByBudgetIDAndDate(
                budgetIds.ToArray(), accountIds.ToArray(), dates.ToArray());

            string inactiveBudgetAccounts = "";
            foreach (OBudgetPeriodOpeningBalance balance in balances)
            {
                if (balance.IsActive == 0)
                {
                    inactiveBudgetAccounts +=
                        balance.BudgetPeriod.ObjectName + ", " + balance.Account.Path + "\n";
                }
            }
            return inactiveBudgetAccounts;
        }



        /// <summary>
        /// Creates the budget transaction logs and budget summaries.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <param name="transactionType"></param>
        /// <returns></returns>
        public static List<OBudgetTransactionLog> CreateBudgetTransactionLogsAndSummaries(
            DataList<OPurchaseBudget> purchaseBudgets, 
            DataList<OPurchaseBudgetSummary> purchaseBudgetSummaries,
            int transactionType)
        {
            // Creates the budget transaction logs.
            //
            List<OBudgetTransactionLog> newTransactions = new List<OBudgetTransactionLog>();
            List<OBudgetTransactionLog> modifiedTransactions = new List<OBudgetTransactionLog>();
            OPurchaseBudget.CreateBudgetTransactionLogs(purchaseBudgets, transactionType, newTransactions, modifiedTransactions);

            // Creates the budget summaries and stamp them with the current
            // budget available balance. 
            //
            List<OPurchaseBudgetSummary> budgetSummaries =
                OPurchaseBudgetSummary.CreateBudgetSummariesForSubmission(newTransactions);
            purchaseBudgetSummaries.AddRange(budgetSummaries);

            foreach (OBudgetTransactionLog transaction in newTransactions)
                transaction.Save();
            foreach (OBudgetTransactionLog transaction in modifiedTransactions)
                transaction.Save();

            return newTransactions;
        }

    }
}
