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
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// </summary>
    public partial class TBudgetReallocation : LogicLayerSchema<OBudgetReallocation>
    {
        public SchemaText Description;
        public SchemaInt BudgetReallocationType;

    }


    public partial class OBudgetReallocation : LogicLayerPersistentObject
    {
        public abstract int? BudgetReallocationType { get; set; }
        public override void Saving()
        {
            base.Saving();
            ComputeTotal();
        }
        public string ValidateReallocationAcrossGroups()
        {

            Hashtable reallocationFromAmount = new Hashtable();
            Hashtable reallocationToAmount = new Hashtable();


            List<Guid?> IDs = new List<Guid?>();
            for (int i = 0; i < this.BudgetReallocationFroms.Count; i++)
                IDs.Add(this.BudgetReallocationFroms[i].AccountID);
            for (int i = 0; i < this.BudgetReallocationTos.Count; i++)
                IDs.Add(this.BudgetReallocationTos[i].AccountID);
            Hashtable groupNames = LogicLayer.OAccount.GetInheritedGroupNames(IDs);
            for (int i = 0; i < this.BudgetReallocationFroms.Count; i++)
            {
                string groupName = groupNames[BudgetReallocationFroms[i].AccountID].ToString();
                reallocationFromAmount[groupName] = 0m;
            }

            for (int i = 0; i < this.BudgetReallocationFroms.Count; i++)
            {
                string groupName = groupNames[BudgetReallocationFroms[i].AccountID].ToString();
                reallocationFromAmount[groupName] =(decimal?)reallocationFromAmount[groupName]+ BudgetReallocationFroms[i].TotalAmount;
            }

            for (int i = 0; i < this.BudgetReallocationTos.Count; i++)
            {
                string groupName = groupNames[BudgetReallocationTos[i].AccountID].ToString();
                reallocationToAmount[groupName] = 0m;
            }
            for (int i = 0; i < this.BudgetReallocationTos.Count; i++)
            {
                string groupName = groupNames[BudgetReallocationTos[i].AccountID].ToString();
                reallocationToAmount[groupName] = (decimal?)reallocationToAmount[groupName] + BudgetReallocationTos[i].TotalAmount;
            }
            
            foreach (Guid? id in IDs)
            {
                if (groupNames[id] != null)
                {
                    if (reallocationFromAmount[groupNames[id]] != null)
                    {
                        if (reallocationToAmount[groupNames[id]] == null)
                            return string.Format(Resources.Errors.BudgetReallocation_budgetToLess, groupNames[id]);
                        else
                            if ((decimal?)reallocationFromAmount[groupNames[id]] != (decimal?)reallocationToAmount[groupNames[id]])
                                return string.Format(Resources.Errors.BudgetReallocation_budgetFromNotMatchTo, groupNames[id]);
                    }
                    else
                    {
                        if (reallocationToAmount[groupNames[id]] != null)
                            return string.Format(Resources.Errors.BudgetReallocation_budgetFromLess, groupNames[id]);

                    }
                }
            }
            return "";
            
        }


        // 2010.12.28
        // Kim Foong
        /// <summary>
        /// Called by the workflow.
        /// </summary>
        public void PendingApproval()
        {
            // Validate to ensure that this budget reallocation is not committed
            // if there's insufficient amount.
            // 
            // This is required for cases when the Budget Reallocation is approved
            // from the Home page, or approved via e-mail approval.
            //
            string accounts = this.CheckSufficientAvailableAmount();
            if (accounts != "")
            {
                string errorMessage = String.Format(
                    Resources.Errors.BudgetReallocation_InsufficientAmount, accounts);
                throw new Exception(errorMessage);
            }

        }


        /// <summary>
        /// Copy BudgetReallocation to BudgetVariationLog
        /// </summary>
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (this.IsCommitted != 1)
                {
                    // 2010.12.28
                    // Kim Foong
                    // Validate to ensure that this budget reallocation is not committed
                    // if there's insufficient amount.
                    // 
                    // This is required for cases when the Budget Reallocation is approved
                    // from the Home page, or approved via e-mail approval.
                    //
                    string accounts = this.CheckSufficientAvailableAmount();
                    if (accounts != "")
                    {
                        string errorMessage = String.Format(
                            Resources.Errors.BudgetReallocation_InsufficientAmount, accounts);
                        throw new Exception(errorMessage);
                    }


                    foreach (OBudgetReallocationFrom from in this.BudgetReallocationFroms)
                    {
                        // Create a variation log record for each of the 
                        // intervals whose value is greater than zero.
                        //

                        // Kim Foong:
                        // For CapitaLand, they won't be allocating month-on-month
                        // basis. So the actual value will be stored in the 1st interval.
                        //
                        //for (int i = 1; i <= 36; i++)
                        for (int i = 1; i <= 1; i++)
                        {
                            decimal changeValue = (decimal)from.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Reallocation;
                            log.BudgetID = this.FromBudgetID;
                            log.BudgetPeriodID = this.FromBudgetPeriodID;
                            log.AccountID = from.AccountID;

                            // Kim Foong
                            // Now we just base on the date of approval to determin
                            // the interval number, since capitaland users 
                            // do not want to reallocate individual months.
                            //log.IntervalNumber = i;
                            log.IntervalNumber = this.FromBudgetPeriod.GetIntervalNumber(DateTime.Today);

                            log.VariationAmount = -changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.BudgetReallocationID = this.ObjectID;
                            log.VariationStatus = BudgetVariationStatus.Approved;
                            log.Save();
                        }
                    }

                    foreach (OBudgetReallocationTo to in this.BudgetReallocationTos)
                    {
                        // The ValidateAccountIdDoesNotExist can be used to test
                        // if the account exists in the budget period. If it does
                        // NOT exist, then an opening balance of ZERO must be
                        // created for that account.
                        //
                        bool hasValue = false;
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)to.DataRow["Interval" + (i.ToString("00")) + "Amount"];
                            if (changeValue != 0)
                                hasValue = true;
                        }
                        if (hasValue && this.ToBudgetPeriod.ValidateAccountIdDoesNotExist(to.AccountID.Value))
                        {
                            OBudgetPeriodOpeningBalance openingBalance = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                            openingBalance.BudgetPeriodID = this.ToBudgetPeriodID;
                            openingBalance.AccountID = to.AccountID;
                            openingBalance.Save();
                        }


                        // Create a variation log record for each of the 
                        // intervals whose value is greater than zero.
                        //
                        // Kim Foong:
                        // For CapitaLand, they won't be allocating month-on-month
                        // basis. So the actual value will be stored in the 1st interval.
                        //
                        //for (int i = 1; i <= 36; i++)
                        for (int i = 1; i <= 1; i++)
                        {
                            decimal changeValue = (decimal)to.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Reallocation;
                            log.BudgetID = this.ToBudgetID;
                            log.BudgetPeriodID = this.ToBudgetPeriodID;
                            log.AccountID = to.AccountID;

                            // Kim Foong
                            // Now we just base on the date of approval to determin
                            // the interval number, since capitaland users 
                            // do not want to reallocate individual months.
                            //log.IntervalNumber = i;
                            log.IntervalNumber = this.ToBudgetPeriod.GetIntervalNumber(DateTime.Today);

                            log.VariationAmount = changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.BudgetReallocationID = this.ObjectID;
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


        /// <summary>
        /// Computes the total for each reallocation from/to items.
        /// </summary>
        public void ComputeTotal()
        {
            foreach (OBudgetReallocationFrom r in this.BudgetReallocationFroms)
                r.Interval01Amount = r.TotalAmount;

            foreach (OBudgetReallocationTo r in this.BudgetReallocationTos)
                r.Interval01Amount = r.TotalAmount;
        }

        public void ComputeFromBudgetSummary()
        {
            if (FromBudgetPeriod != null && BudgetReallocationFroms.Count > 0)
            {
                DataTable dt = FromBudgetPeriod.GenerateSummaryBudgetViewWithoutTree(null);

                foreach (OBudgetReallocationFrom from in BudgetReallocationFroms)
                {
                    DataRow[] drs = dt.Select("AccountID = '" + from.AccountID.Value.ToString() + "'");
                    if (drs != null && drs.Length > 0)
                    {
                        from.TotalOpeningBalance = Convert.ToDecimal(drs[0]["TotalOpeningBalance"].ToString());
                        from.TotalAdjustedAmount = Convert.ToDecimal(drs[0]["TotalAdjustedAmount"].ToString());
                        from.TotalReallocatedAmount = Convert.ToDecimal(drs[0]["TotalReallocatedAmount"].ToString());
                        from.TotalBalanceAfterVariation = Convert.ToDecimal(drs[0]["TotalBalanceAfterVariation"].ToString());
                        from.TotalPendingApproval = Convert.ToDecimal(drs[0]["TotalPendingApproval"].ToString());
                        from.TotalApproved = Convert.ToDecimal(drs[0]["TotalApproved"].ToString());
                        from.TotalDirectInvoicePendingApproval = Convert.ToDecimal(drs[0]["TotalDirectInvoicePendingApproval"].ToString());
                        from.TotalDirectInvoiceApproved = Convert.ToDecimal(drs[0]["TotalDirectInvoiceApproved"].ToString());
                        from.totalAvailableBalance = Convert.ToDecimal(drs[0]["TotalAvailableBalance"].ToString());
                    }
                }

            }
        }

        public void ComputeToBudgetSummary()
        {
            if (ToBudgetPeriod != null && BudgetReallocationTos.Count > 0)
            {
                DataTable dt = ToBudgetPeriod.GenerateSummaryBudgetViewWithoutTree(null);

                foreach (OBudgetReallocationTo to in BudgetReallocationTos)
                {
                    DataRow[] drs = dt.Select("AccountID = '" + to.AccountID.Value.ToString() + "'");
                    if (drs != null && drs.Length > 0)
                    {
                        to.TotalOpeningBalance = Convert.ToDecimal(drs[0]["TotalOpeningBalance"].ToString());
                        to.TotalAdjustedAmount = Convert.ToDecimal(drs[0]["TotalAdjustedAmount"].ToString());
                        to.TotalReallocatedAmount = Convert.ToDecimal(drs[0]["TotalReallocatedAmount"].ToString());
                        to.TotalBalanceAfterVariation = Convert.ToDecimal(drs[0]["TotalBalanceAfterVariation"].ToString());
                        to.TotalPendingApproval = Convert.ToDecimal(drs[0]["TotalPendingApproval"].ToString());
                        to.TotalApproved = Convert.ToDecimal(drs[0]["TotalApproved"].ToString());
                        to.TotalDirectInvoicePendingApproval = Convert.ToDecimal(drs[0]["TotalDirectInvoicePendingApproval"].ToString());
                        to.TotalDirectInvoiceApproved = Convert.ToDecimal(drs[0]["TotalDirectInvoiceApproved"].ToString());
                        to.totalAvailableBalance = Convert.ToDecimal(drs[0]["TotalAvailableBalance"].ToString());
                    }
                }

            }
        }

        public enum EnumBudgetReallocationType
        {
            BetweenSubCategory=0,
            WithinSubCategory=1
        }

        public enum EnumBudgetReallocationMainCategory
        {
            Capex = 0,
            NonCapex = 1
        }
    }



}