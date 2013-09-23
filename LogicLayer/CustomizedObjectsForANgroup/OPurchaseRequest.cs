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
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPurchaseRequest : LogicLayerSchema<OPurchaseRequest>
    {
        [Size(500)]
        public SchemaString Background;
        [Size(500)]
        public SchemaString Scope;
        public SchemaGuid TransactionTypeGroupID;
        public SchemaGuid PurchaseTypeID;
        public SchemaGuid BudgetGroupID;
        public SchemaInt IsApproved;
        [Default(0)]
        public SchemaInt MinimumNumberOfQuotationsPolicy;
        [Default(0)]
        public SchemaInt MinimumNumberOfQuotations;
        [Default(0)]
        public SchemaDecimal MinimumApplicableRFQAmount;
        [Default(0)]
        public SchemaInt BudgetDistributionMode;
        [Default(0)]
        public SchemaInt BudgetValidationPolicy;
        public SchemaInt IsSubmittedForApproval;
        public TCode TransactionTypeGroup { get { return OneToOne<TCode>("TransactionTypeGroup"); } }
        public TCode PurchaseType { get { return OneToOne<TCode>("PurchaseTypeID"); } }
        public TBudgetGroup BudgetGroup { get { return OneToOne<TBudgetGroup>("BudgetGroupID"); } }
        public TPurchaseBudget PurchaseBudgets { get { return OneToMany<TPurchaseBudget>("PurchaseRequestID"); } }
        public TPurchaseBudgetSummary PurchaseBudgetSummaries { get { return OneToMany<TPurchaseBudgetSummary>("RequestForQuotationID"); } }
    }


    /// <summary>
    /// Represents a purchase request object raised for procuring 
    /// materials or services.
    /// </summary>
    public abstract partial class OPurchaseRequest : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or Sets the Background
        /// </summary>
        public abstract String Background { get; set; }
        /// <summary>
        /// [Column] Gets or sets a flag indicating that the
        /// request for quotation has been submitted for approval.
        /// </summary>
        public abstract int? IsSubmittedForApproval { get; set; }
        /// <summary>
        /// [Column] Gets or sets a flag indicating that the
        /// request for quotation has been approved.
        /// </summary>
        public abstract int? IsApproved { get; set; }
        
        /// <summary>
        /// [Column] Gets or Sets the Scope
        /// </summary>
        public abstract String Scope { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the purchase type.
        /// </summary>
        public abstract Guid? PurchaseTypeID { get; set; }
        public abstract Guid? BudgetGroupID { get; set; }
        public abstract Guid? TransactionTypeGroupID { get; set; }
        public abstract OCode TransactionTypeGroup { get; set; }
        public abstract OBudgetGroup BudgetGroup { get; set; }
        /// <summary>
        /// [Column] Gets or sets a value indicating the policy
        /// of the system with respect to creating purchase orders
        /// from quotations.
        /// <para></para>
        /// <list>
        ///     <item>0 - A minimum number of quotations is not required.</item>
        ///     <item>1 - A minimum number of quotations is preferred. A warning is displayed if the minimum quotations is not satisfied.</item>
        ///     <item>2 - A minimum number of quotations is required. </item>
        /// </list>
        /// <para></para>
        /// </summary>
        public abstract int? MinimumNumberOfQuotationsPolicy { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum number of quotations
        /// required before a Purchase Order can be created from a
        /// Request for Quotation. This value must be more than
        /// or equals to 1. At the very least, there must be at
        /// least 1 quotation in a Request for Quotation before
        /// any Purchase Order can be created anyway.
        /// </summary>
        public abstract int? MinimumNumberOfQuotations { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum amount (inclusive)
        /// that will result in the minimum quotation policy taking effect.
        /// </summary>
        public abstract decimal? MinimumApplicableRFQAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value indicating
        /// the budget validation policy.
        /// <list>
        ///     <item>0 - Budget consumption must be equal to line items. (default) </item>
        ///     <item>1 - Budget consumption must be less than or equal to line items. </item>
        ///     <item>2 - No validation. </item>
        /// </list>
        /// </summary>
        public abstract int? BudgetValidationPolicy { get; set; }
        /// <summary>
        /// Gets or sets the Purchase Type object the represents
        /// the purchase type of this request for quotation.
        /// </summary>
        public abstract OCode PurchaseType { get; set; }
        /// <summary>
        /// A cached copy of the budget summary table that
        /// can be queried from the database
        /// </summary>
        private List<OPurchaseBudgetSummary> tempPurchaseBudgetSummaries;
        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudget objects that represents
        /// the budget distribution for this request for quotation.
        /// </summary>
        public abstract DataList<OPurchaseBudget> PurchaseBudgets { get; }
        /// <summary>
        /// Gets a one-to-many list of OPurchaseBudgetSummary objects that represents
        /// information about this Purchase Request's commitment to the budgets.
        /// </summary>
        public abstract DataList<OPurchaseBudgetSummary> PurchaseBudgetSummaries { get; }
        /// <summary>
        /// Computes the temporary list of budget
        /// summaries.
        /// </summary>
        public void ComputeTempBudgetSummaries()
        {
            List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
            OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null);
            tempPurchaseBudgetSummaries = OPurchaseBudgetSummary.CreateBudgetSummariesForSubmission(transactions);
        }
        /// <summary>
        /// Gets the most applicable purchase settings and store it
        /// in a temporary variable.
        /// </summary>
        public void UpdateApplicablePurchaseSettings()
        {
            OPurchaseSettings purchaseSettings =
                OPurchaseSettings.GetPurchaseSettings(this.Location, this.PurchaseType, this.BudgetGroupID);

            if (purchaseSettings != null)
            {
                this.MinimumNumberOfQuotationsPolicy = purchaseSettings.MinimumNumberOfQuotationsPolicy;
                this.MinimumApplicableRFQAmount = purchaseSettings.MinimumApplicableRFQAmount;
                this.MinimumNumberOfQuotations = purchaseSettings.MinimumNumberOfQuotations;
                this.BudgetValidationPolicy = purchaseSettings.BudgetValidationPolicy;
            }
            else
            {
                this.MinimumNumberOfQuotationsPolicy = PurchasePolicy.NotRequired;
                this.MinimumApplicableRFQAmount = 0;
                this.MinimumNumberOfQuotations = 0;
                this.BudgetValidationPolicy = PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems;
            }
        }

        /// <summary>
        /// Validates that the budget amount is equals to the line
        /// item amount.
        /// <para></para>
        /// This function is generic and can be applied to any of
        /// the WJ/RFQ/PO objects provided the line items implement
        /// the ItemNumber and the Amount properties.
        /// </summary>
        /// <returns>Returns -1 if the validation succeeds. Returns 0 if 
        /// the total WJ amount does not equal the budget amount .
        /// Returns any other number if that line number does
        /// not equal the budget amount</returns>
        public int ValidateBudgetAmountEqualsLineItemAmount()
        {
            // If the budget validation is not required, return -1
            // immediately to indicate the validation succeeded.
            //
            if (this.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired)
                return -1;

            if (this.BudgetDistributionMode != null)
            {
                // Find out the total amount by line items
                // or the entire WJ.
                //
                int maxItemNumber = 0;
                Hashtable totalLineItemAmounts = new Hashtable();
                foreach (OPurchaseRequestItem item in this.PurchaseRequestItems)
                {
                    int itemNumber = 0;
                    if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
                        itemNumber = item.ItemNumber.Value;

                    if (itemNumber > maxItemNumber)
                        maxItemNumber = itemNumber;
                    if (totalLineItemAmounts[itemNumber] == null)
                        totalLineItemAmounts[itemNumber] = 0M;

                    if (item.Subtotal != null)
                        totalLineItemAmounts[itemNumber] =
                            (decimal)totalLineItemAmounts[itemNumber] + item.Subtotal.Value;
                }

                // Find out the total budgeted amount by line items
                // or the entire WJ.
                //
                Hashtable totalBudgetAmounts = new Hashtable();
                foreach (OPurchaseBudget prBudget in this.PurchaseBudgets)
                {
                    int itemNumber = 0;
                    if (this.BudgetDistributionMode == BudgetDistribution.LineItem)
                        itemNumber = prBudget.ItemNumber.Value;
                    if (itemNumber > maxItemNumber)
                        maxItemNumber = itemNumber;
                    if (totalBudgetAmounts[itemNumber] == null)
                        totalBudgetAmounts[itemNumber] = 0M;
                    totalBudgetAmounts[itemNumber] =
                        (decimal)totalBudgetAmounts[itemNumber] + prBudget.Amount.Value;
                }

                // Compare the line items and the budget totals
                // to ensure that they match.
                //
                for (int i = 0; i <= maxItemNumber; i++)
                {
                    decimal totalLineItemAmount = totalLineItemAmounts[i] == null ? 0 : (decimal)totalLineItemAmounts[i];
                    decimal totalBudgetAmount = totalBudgetAmounts[i] == null ? 0 : (decimal)totalBudgetAmounts[i];

                    // Test based on the budget validation settings.
                    //
                    if (this.BudgetValidationPolicy == 0 && totalLineItemAmount != totalBudgetAmount)
                        return i;
                    if (this.BudgetValidationPolicy == 1 && totalLineItemAmount < totalBudgetAmount)
                        return i;
                }
                return -1;
            }
            else
                return -1;
        }
        /// <summary>
        /// Validates that there is sufficient amount in the budgets
        /// for the deduction.
        /// </summary>
        /// <returns>Returns a string of a list of budget periods and accounts
        /// that are insufficient. Returns an empty string otherwise.
        /// </returns>
        public string ValidateSufficientBudget()
        {
            List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
            return OBudgetPeriod.CheckSufficientBalance(
                OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null));
        }
        /// <summary>
        /// Submits for Request for Quotation for approval by doing: <br/>
        /// 1. Creates the budget transaction logs. <br/>
        /// 2. Creates the budget summaries and stamp them with the current
        /// budget available balance. <br/>
        /// <para></para>
        /// This method is called from the RFQ workflow after. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void SubmitForApproval()
        {
            using (Connection c = new Connection())
            {
                if (this.IsSubmittedForApproval != 1)
                {
                    if (this.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired &&
                        this.BudgetDistributionMode != null)
                    {
                        OPurchaseBudget.CreateBudgetTransactionLogsAndSummaries(this.PurchaseBudgets, this.PurchaseBudgetSummaries, BudgetTransactionType.PurchasePendingApproval);
                    }
                    this.IsSubmittedForApproval = 1;
                }
                this.Save();
                c.Commit();
            }
        }

        /// A cached copy of the budget summary table. This
        /// is a temporary list of the budget summaries that 
        /// provides a snapshot of the budget accounts when
        /// the RFQ object is before the pending approval state.
        /// </summary>
        public List<OPurchaseBudgetSummary> TempPurchaseBudgetSummaries
        {
            get
            {
                return tempPurchaseBudgetSummaries;
            }
        }
        /// <summary>
        /// Approves the Request for Quotation by doing the following:<br/>
        /// 1. Update all budget transactions to indicated Approved.<br/>
        /// 2. Create budget summaries if not already created.<br/>
        /// 3. Stamp budget summaries with current budget balance at approval.<br/>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Approve()
        {
            using (Connection c = new Connection())
            {
                if (this.IsApproved != 1)
                {
                    if (this.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired &&
                        this.BudgetDistributionMode != null)
                    {
                        /*
                        // Create budget summaries if not already created.
                        //
                        if (this.PurchaseBudgetSummaries.Count == 0)
                        {
                            OPurchaseBudget.CreateBudgetTransactionLogsAndSummaries(
                                this.PurchaseBudgets, this.PurchaseBudgetSummaries, BudgetTransactionType.PurchasePendingApproval);
                        }
                         * */

                        // Update all budget transactions to indicated Approved.
                        //
                        List<OBudgetTransactionLog> transactions = OPurchaseBudget.SetBudgetTransactionLogsTransactionType(
                            this.PurchaseBudgets, BudgetTransactionType.PurchaseApproved);

                        // Stamp budget summaries with current budget balance at approval.
                        //
                        OPurchaseBudgetSummary.UpdateBudgetSummariesAfterApproval(transactions, this.PurchaseBudgetSummaries);
                    }
                    this.IsApproved = 1;
                }
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Rejects the Request for Quotation by doing the following:
        /// 1. Cancels all budget transactions. 
        /// 2. Clears all budget summaries.
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Reject()
        {
            using (Connection c = new Connection())
            {
                if (this.IsSubmittedForApproval != 0)
                {
                    OPurchaseBudget.ClearBudgetTransactionLogs(this.PurchaseBudgets);
                    this.PurchaseBudgetSummaries.Clear();

                    this.IsSubmittedForApproval = 0;
                }
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Cancels the Request for Quotation by doing the following:
        /// 1. Unlink all RFQ line items from the WJ line items. 
        /// 2. Cancel all budget transactions.
        /// <para></para>
        /// This method is called from the RFQ workflow after. It should
        /// not be called by the developer directly.
        /// </summary>
        /// <returns></returns>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                // Unlink all RFQ line items from the WJ line items.
                //
                foreach (OPurchaseRequestItem prItem in this.PurchaseRequestItems)
                    prItem.PurchaseRequestID = null;

                // Cancel all budget transactions.
                //
                OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
                this.PurchaseBudgetSummaries.Clear();

                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Closes the Request for Quotation by doing the following: <br/>
        /// 1. Cancels all budget transactions. <br/>
        /// <para></para>
        /// This method is called from the workflow. It should
        /// not be called by the developer directly.
        /// </summary>
        public void Close()
        {
            using (Connection c = new Connection())
            {
                // Cancel all budget transactions.
                //
                OPurchaseBudget.ClearBudgetTransactionLogs(this.PurchaseBudgets);
                this.Save();

                // Close related case.
                //
                //OCase.CloseCaseWhenAllDocumentsClosedOrCancelled(this.CaseID);

                c.Commit();
            }

        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Deactivate all purchase request line items, when this 
        /// purchase request is deactivated.
        /// <para></para>
        /// Then, releases all budgets.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Deactivating()
        {
            base.Deactivating();

            foreach (OPurchaseRequest item in this.PurchaseRequestItems)
                item.Deactivate();

            // Cancel all budget transactions.
            //
            OPurchaseBudget.UndoTransferBudgetTransactionLogs(this.PurchaseBudgets);
            this.PurchaseBudgetSummaries.Clear();

        }


        /// <summary>
        /// Validates that the budget spending policy is adhered to, that is,
        /// budgets can be spent or not if they are not yet created for
        /// a finacial period.
        /// <para></para>
        /// Returns a list of budgets that failed because budget periods
        /// are not available.
        /// </summary>
        public string ValidateBudgetSpendingPolicy()
        {
            List<OBudgetTransactionLog> transactions = new List<OBudgetTransactionLog>();
            return OBudgetPeriod.CheckSpendingPolicy(
                OPurchaseBudget.CreateBudgetTransactionLogs(this.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, transactions, null));
        }
    }

}
