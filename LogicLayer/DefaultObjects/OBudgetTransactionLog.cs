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
    /// Summary description for OBudgetConsumption
    /// </summary>
    [Serializable] 
    public partial class TBudgetTransactionLog : LogicLayerSchema<OBudgetTransactionLog>
    {
        public SchemaInt TransactionType;
        public SchemaGuid BudgetID;
        public SchemaGuid AccountID;
        public SchemaGuid PurchaseBudgetID;
        public SchemaGuid InvoiceID;
        public SchemaDateTime DateOfExpenditure;
        public SchemaDecimal TransactionAmount;
        public SchemaDecimal NonCommittedAmount;
        public SchemaDecimal ReturnAmount;
        public SchemaGuid BudgetPeriodID;
        public SchemaGuid TransferFromBudgetTransactionLogID;

        public TBudget Budget { get { return OneToOne<TBudget>("BudgetID"); } }
        public TAccount Account { get { return OneToOne<TAccount>("AccountID"); } }
        public TPurchaseBudget PurchaseBudget { get { return OneToOne<TPurchaseBudget>("PurchaseBudgetID"); } }
        public TPurchaseOrder PurchaseOrder { get { return OneToOne<TPurchaseOrder>("PurchaseOrderID"); } }
    }


    [Serializable]
    public abstract partial class OBudgetTransactionLog : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the budget transaction type.
        /// </summary>
        public abstract int? TransactionType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the budget 
        /// table this consumption applies to.
        /// </summary>
        public abstract Guid? BudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the account 
        /// table that this consumption applies to.
        /// </summary>
        public abstract Guid? AccountID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseRequest
        /// budget table that indicates the purchase request that
        /// consumed against the budget.
        /// </summary>
        public abstract Guid? PurchaseBudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Invoice
        /// table that indicates the purchase order that
        /// consumed against the budget.
        /// </summary>
        public abstract Guid? InvoiceID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date of consumption
        /// that the expense or purchase order object deducts
        /// from the budget. This date is usually the start
        /// date of the purchase order or expense.
        /// </summary>
        public abstract DateTime? DateOfExpenditure { get; set; }

        /// <summary>
        /// [Column] Gets or sets the amount consumed from
        /// the budget specified in the date of consumption.
        /// </summary>
        public abstract Decimal? TransactionAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the non-committed amount.
        /// This non-committed amount is used to store the
        /// credit/debit memo amount.
        /// </summary>
        public abstract Decimal? NonCommittedAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the amount to be returned 
        /// to the previous transaction log, should the 
        /// purchase document be cancelled.
        /// </summary>
        public abstract Decimal? ReturnAmount { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the foreign key to the budget
        /// period table that indicates the budget period
        /// that this transaction applies to.
        /// <para></para>
        /// This field is filled up only at the time the
        /// transaction log is created and will never be 
        /// updated again. Therefore, if this field is null, 
        /// it means that the budget was committed
        /// before the period was opened.
        /// </summary>
        public abstract Guid? BudgetPeriodID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to
        /// the BudgetTransactionLog table that indicates
        /// the log entry that the amount wil be deducted from.
        /// </summary>
        public abstract Guid? TransferFromBudgetTransactionLogID { get; set; }

        /// <summary>
        /// Gets a reference to the OBudget object that represents
        /// the budget the transaction was committed against.
        /// </summary>
        public abstract OBudget Budget { get; set; }

        /// <summary>
        /// Gets a reference to the OAccount object that represents
        /// the account in the budget that the transaction was committed
        /// against.
        /// </summary>
        public abstract OAccount Account { get; set; }

        /// <summary>
        /// Gets a reference to the OPurchaseBudget object that
        /// generated this budget transaction log.
        /// </summary>
        public abstract OPurchaseBudget PurchaseBudget { get; set; }

        public abstract OPurchaseOrder PurchaseOrder { get; set; }


        /// <summary>
        /// Moves the transaction amount to the non-committed amount;
        /// </summary>
        public void TransferTransactionAmountToNonCommittedAmount()
        {
            decimal transactionAmount = 0;
            if (this.TransactionAmount != null)
                transactionAmount = this.TransactionAmount.Value;

            decimal nonCommittedAmount = 0;
            if (this.NonCommittedAmount != null)
                nonCommittedAmount = this.NonCommittedAmount.Value;

            this.TransactionAmount = 0;
            this.NonCommittedAmount = transactionAmount + nonCommittedAmount;
        }
    }


    /// <summary>
    /// Represents the different types of transactions.
    /// </summary>
    public class BudgetTransactionType
    {
        /// <summary>
        /// RFQ/PO pending approval.
        /// </summary>
        public const int PurchasePendingApproval = 1;

        /// <summary>
        /// RFQ/PO approved.
        /// </summary>
        public const int PurchaseApproved = 2;

        /// <summary>
        /// PO-matched invoice approved.
        /// </summary>
        public const int PurchaseInvoiceApproved = 12;

        /// <summary>
        /// PO-matched credit/debit memo approved.
        /// </summary>
        public const int PurchaseCreditDebitMemoApproved = 15;

        /// <summary>
        /// Direct invoice pending approval.
        /// </summary>
        public const int DirectInvoicePendingApproval = 13;

        /// <summary>
        /// Direct invoice approved.
        /// </summary>
        public const int DirectInvoiceApproved = 14;

        /// <summary>
        /// Direct credit/debit memo approved.
        /// </summary>
        public const int DirectCreditDebitMemoApproved = 16;
    }


    /// <summary>
    /// Represents a temporary class used to store information
    /// about what will be committed against budgets.
    /// </summary>
    public class BudgetTransaction
    {
        public Guid BudgetID;
        public DateTime DateOfExpenditure;
        public Guid AccountID;
        public decimal TransactionAmount;

        /// <summary>
        /// 
        /// </summary>
        public Guid BudgetPeriodID;
    }
}
