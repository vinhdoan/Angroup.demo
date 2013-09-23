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
    public partial class TBudgetAdjustment : LogicLayerSchema<OBudgetAdjustment>
    {
        public SchemaString VersionName;
        public SchemaText Description;
    }


    public abstract partial class OBudgetAdjustment : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract String VersionName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of this
        /// adjustment.
        /// </summary>
        public abstract String Description { get; set; }


        // 2010.12.28
        // Kim Foong
        /// <summary>
        /// Called by the workflow.
        /// </summary>
        public void PendingApproval()
        {
            // Validate to ensure that this budget adjustment is not committed
            // if there's insufficient amount.
            // 
            // This is required for cases when the Budget Adjustment is approved
            // from the Home page, or approved via e-mail approval.
            //
            string listOfAccounts = this.CheckSufficientAvailableAmount();
            if (listOfAccounts != "")
                throw new Exception(String.Format(Resources.Errors.BudgetAdjustment_InsufficientAmount, listOfAccounts));

        }


        /// <summary>
        /// Copy this budget adjusment detail to the budget variationlog
        /// </summary>
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (this.IsCommitted != 1)
                {
                    // 2010.12.28
                    // Kim Foong
                    // Validate to ensure that this budget adjustment is not committed
                    // if there's insufficient amount.
                    // 
                    // This is required for cases when the Budget Adjustment is approved
                    // from the Home page, or approved via e-mail approval.
                    //
                    string listOfAccounts = this.CheckSufficientAvailableAmount();
                    if (listOfAccounts != "")
                        throw new Exception(String.Format(Resources.Errors.BudgetAdjustment_InsufficientAmount, listOfAccounts));

                    foreach (OBudgetAdjustmentDetail budgetAdjustmentDetail in this.BudgetAdjustmentDetails)
                    {
                        // The ValidateAccountIdDoesNotExist can be used to test
                        // if the account exists in the budget period. If it does
                        // NOT exist, then an opening balance of ZERO must be
                        // created for that account.
                        //
                        bool hasValue = false;
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)budgetAdjustmentDetail.DataRow["Interval" + (i.ToString("00")) + "Amount"];
                            if (changeValue != 0)
                                hasValue = true;
                        }
                        if (hasValue && this.BudgetPeriod.ValidateAccountIdDoesNotExist(budgetAdjustmentDetail.AccountID.Value))
                        {
                            OBudgetPeriodOpeningBalance openingBalance = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                            openingBalance.BudgetPeriodID = this.BudgetPeriodID;
                            openingBalance.AccountID = budgetAdjustmentDetail.AccountID;
                            openingBalance.Save();
                        }

                        // Create a variation log record for each of the 
                        // intervals whose value is greater than zero.
                        //
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)budgetAdjustmentDetail.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Adjustment;
                            log.BudgetID = this.BudgetID;
                            log.BudgetPeriodID = this.BudgetPeriodID;
                            log.AccountID = budgetAdjustmentDetail.AccountID;
                            log.IntervalNumber = i;
                            log.VariationAmount = changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.BudgetAdjustmentID = this.ObjectID;
                            log.VariationStatus = BudgetVariationStatus.Approved;
                            log.Save();
                        }
                    }
                    this.IsCommitted = 1;
                    this.Save();
                }
                c.Commit();
            }
        }

        public void ComputeBudgetSummary()
        {
            if (BudgetPeriod != null && BudgetAdjustmentDetails.Count > 0)
            {
                DataTable dt = BudgetPeriod.GenerateSummaryBudgetViewWithoutTree(null);

                foreach (OBudgetAdjustmentDetail detail in BudgetAdjustmentDetails)
                {
                    DataRow[] drs = dt.Select("AccountID = '" + detail.AccountID.Value.ToString() + "'");
                    if (drs != null && drs.Length > 0)
                    {
                        detail.TotalOpeningBalance = Convert.ToDecimal(drs[0]["TotalOpeningBalance"].ToString());
                        detail.TotalAdjustedAmount = Convert.ToDecimal(drs[0]["TotalAdjustedAmount"].ToString());
                        detail.TotalReallocatedAmount = Convert.ToDecimal(drs[0]["TotalReallocatedAmount"].ToString());
                        detail.TotalBalanceAfterVariation = Convert.ToDecimal(drs[0]["TotalBalanceAfterVariation"].ToString());
                        detail.TotalPendingApproval = Convert.ToDecimal(drs[0]["TotalPendingApproval"].ToString());
                        detail.TotalApproved = Convert.ToDecimal(drs[0]["TotalApproved"].ToString());
                        detail.TotalDirectInvoicePendingApproval = Convert.ToDecimal(drs[0]["TotalDirectInvoicePendingApproval"].ToString());
                        detail.TotalDirectInvoiceApproved = Convert.ToDecimal(drs[0]["TotalDirectInvoiceApproved"].ToString());
                        detail.totalAvailableBalance = Convert.ToDecimal(drs[0]["TotalAvailableBalance"].ToString());
                    }
                }

            }
        }


        // 2011.03.31
        // Kim Foong
        // Validates to ensure that total = monthly breakdown.
        /// <summary>
        /// Validates to ensure that the total amounts for the individual accounts equal to the
        /// total.
        /// </summary>
        /// <returns></returns>
        public string ValidateIntervalAmountsEqualTotal()
        {
            string accounts="";
            foreach (OBudgetAdjustmentDetail budgetAdjustmentDetail in this.BudgetAdjustmentDetails)
            {
                decimal total = 0;
                for (int i = 1; i <= 36; i++)
                    total += (decimal)budgetAdjustmentDetail.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                if (budgetAdjustmentDetail.TotalAmount != total)
                    accounts += budgetAdjustmentDetail.Account.Path + "; ";
            }

            return accounts;
        }
    }
}
