//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
        public SchemaGuid PurchaseRequestID;
        public SchemaGuid RequestForQuotationID;
        public SchemaGuid PurchaseOrderID;
        public SchemaGuid BudgetID;
        public SchemaGuid BudgetPeriodID;
        public SchemaGuid AccountID;
        public SchemaDecimal TotalAvailableAdjusted;
        public SchemaDecimal TotalAvailableBeforeSubmission;
        public SchemaDecimal TotalAvailableAtSubmission;
        public SchemaDecimal TotalAvailableAfterApproval;

        public TPurchaseOrder PurchaseRequest { get { return OneToOne<TPurchaseOrder>("PurchaseRequestID"); } }
        public TRequestForQuotation RequestForQuotation { get { return OneToOne<TRequestForQuotation>("RequestForQuotationID"); } }
        public TPurchaseOrder PurchaseOrder { get { return OneToOne<TPurchaseOrder>("PurchaseOrderID"); } }

        public TBudget Budget { get { return OneToOne<TBudget>("BudgetID"); } }
        public TBudgetPeriod BudgetPeriod { get { return OneToOne<TBudgetPeriod>("BudgetPeriodID"); } }
        public TAccount Account { get { return OneToOne<TAccount>("AccountID"); } }
    }


    /// <summary>
    /// Represents the budget distributions in a purchase request, request for quotation
    /// or a purchase order object.
    /// </summary>
    public abstract partial class OPurchaseBudgetSummary : LogicLayerPersistentObject
    {
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
        /// [Column] Gets or sets the foreign key to the Budget table 
        /// that indicates the budget that the amount will be committed
        /// against.
        /// </summary>
        public abstract Guid? BudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the BudgetPeriod table 
        /// that indicates the budget period that the amount will be committed
        /// against. When the BudgetPeriodID is null, it means that the
        /// amount is being committed against a budget period that has not
        /// been opened yet.
        /// </summary>
        public abstract Guid? BudgetPeriodID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Budget table 
        /// that indicates the account of the budget that the amount 
        /// will be committed against.
        /// </summary>
        public abstract Guid? AccountID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total budget available by taking
        /// sum of the opening balance and the reallocations and 
        /// adjustments, before any consumption.
        /// </summary>
        public abstract decimal? TotalAvailableAdjusted { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total budget available before
        /// the WJ/RFQ/PO has been raised.
        /// </summary>
        public abstract decimal? TotalAvailableBeforeSubmission { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total budget available at 
        /// the point when the WJ/RFQ/PO was submitted to for approval.
        /// This value includes the consumption from this WJ/RFQ/PO.
        /// </summary>
        public abstract decimal? TotalAvailableAtSubmission { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total budget available at 
        /// the point when the WJ/RFQ/PO was approved.
        /// This value includes the consumption from this WJ/RFQ/PO.
        /// </summary>
        public abstract decimal? TotalAvailableAfterApproval { get; set; }

        /// <summary>
        /// [Column] Gets or sets the OBudget object that
        /// represents the budget in this summary.
        /// </summary>
        public abstract OBudget Budget { get; set; }

        /// <summary>
        /// [Column] Gets or sets the OBudgetPeriod object that
        /// represents the budget period in this summary.
        /// </summary>
        public abstract OBudgetPeriod BudgetPeriod { get; set; }

        /// <summary>
        /// [Column] Gets or sets the OAccount object that
        /// represents the account in this summary.
        /// </summary>
        public abstract OAccount Account { get; set; }

        /*
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
                budgetSummary.TotalAvailableAtSubmission = budgetSummary.TotalAvailableBeforeSubmission - totalAmountToCommit;
                budgetSummaries.Add(budgetSummary);
            }

            return budgetSummaries;
        }
        */

        /// <summary>
        /// [Column] Updates the set of budget summaries with the latest 
        /// available figures.
        /// </summary>
        /// <returns></returns>
        public static void UpdateBudgetSummariesAfterApproval(
            List<OBudgetTransactionLog> transactions, 
            DataList<OPurchaseBudgetSummary> purchaseBudgetSummaries)
        {
            // Gets a data table of all available balances,
            // based the budget and budget period in the list 
            // of transactions.
            //
            DataTable dt = OBudgetPeriod.GetAvailableBalanceByTransactions(transactions);

            // Create a budget summary for each row returned
            // by the GetAvailableBalanceByTransactions above.
            //
            foreach (DataRow dr in dt.Rows)
            {
                foreach (OPurchaseBudgetSummary purchaseBudgetSummary in purchaseBudgetSummaries)
                {
                    if (purchaseBudgetSummary.BudgetID == (Guid)dr["BudgetID"] &&
                        purchaseBudgetSummary.BudgetPeriodID == null &&
                        dr["BudgetPeriodID"] == DBNull.Value &&
                        purchaseBudgetSummary.AccountID == (Guid)dr["AccountID"])
                    {
                        purchaseBudgetSummary.TotalAvailableAfterApproval = (decimal)dr["Balance"];
                    }
                    else if (purchaseBudgetSummary.BudgetID == (Guid)dr["BudgetID"] &&
                        purchaseBudgetSummary.BudgetPeriodID == (Guid)dr["BudgetPeriodID"] &&
                        purchaseBudgetSummary.AccountID == (Guid)dr["AccountID"])
                    {
                        purchaseBudgetSummary.TotalAvailableAfterApproval = (decimal)dr["Balance"];
                    }
                }
            }
        }


    }

}

