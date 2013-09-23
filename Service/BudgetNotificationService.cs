//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO.Ports;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;
using System.Collections;

namespace Service
{
    public partial class BudgetNotificationService: AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            DateTime today = DateTime.Today;
            OApplicationSetting appSetting = OApplicationSetting.Current;
            // Gets all budget periods that are 
            // 1. Active
            // 2. Start Date >= now
            // 3. (End Date or Closing Date, whichever is greater) <= now 
            //
            List<OBudgetPeriod> budgetPeriods = TablesLogic.tBudgetPeriod.LoadList(
                TablesLogic.tBudgetPeriod.IsActive == 1 &
                TablesLogic.tBudgetPeriod.StartDate <= today &
                ((TablesLogic.tBudgetPeriod.ClosingDate == null &
                TablesLogic.tBudgetPeriod.EndDate >= today) |
                (TablesLogic.tBudgetPeriod.ClosingDate != null &
                TablesLogic.tBudgetPeriod.ClosingDate >= today)));

            foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
            {
                if (applicationSetting.BudgetNotificationPolicy == BudgetNotificationMode.Both)
                {
                    NotifyBudgetPeriodBelowThresholdOpeningBalances(budgetPeriods);
                    NotifyBudgetPeriodBelowThresholdIntervalOpeningBalances(budgetPeriods);
                }
                else
                {
                    if (applicationSetting.BudgetNotificationPolicy == BudgetNotificationMode.Interval)
                        NotifyBudgetPeriodBelowThresholdIntervalOpeningBalances(budgetPeriods);
                    if (applicationSetting.BudgetNotificationPolicy == BudgetNotificationMode.Total)
                        NotifyBudgetPeriodBelowThresholdOpeningBalances(budgetPeriods);
                }
            }
        }

        protected void NotifyBudgetPeriodBelowThresholdOpeningBalances(List<OBudgetPeriod> budgetPeriods)
        {
            DateTime today = DateTime.Today;
            foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
            {
                bool atLeastOneAccountBelowThreshold = budgetPeriod.DetermineLowThresholdOpeningBalances(null);

                if (atLeastOneAccountBelowThreshold)
                {
                    OBudget budget = budgetPeriod.Budget;
                    budgetPeriod.SendMessage("Budget_AvailableBelowThreshold",
                        budget.NotifyUser1, budget.NotifyUser2, budget.NotifyUser3, budget.NotifyUser4);
                }
            }

        }

        protected void NotifyBudgetPeriodBelowThresholdIntervalOpeningBalances(List<OBudgetPeriod> budgetPeriods)
        {
            DateTime today = DateTime.Today;
            // 2011 05 04
            // Customized for malaysia, notify budget admin, users
            // if the available interval opening balance below threhold.
            // message temaplate needed to specify in message template module.
            //
            foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
            {
                bool atLeastOneAccountBelowThreshold = budgetPeriod.DetermineLowThresholdIntervalOpeningBalances(today, null);
                if (atLeastOneAccountBelowThreshold)
                {
                    OBudget budget = budgetPeriod.Budget;
                    budgetPeriod.SendMessage("Budget_IntervalAvailableBelowThreshold",
                        budget.NotifyUser1, budget.NotifyUser2, budget.NotifyUser3, budget.NotifyUser4);
                }
            }
        }

    }
}
