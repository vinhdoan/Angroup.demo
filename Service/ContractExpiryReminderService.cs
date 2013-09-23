//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Anacle.DataFramework;
using LogicLayer;

namespace Service
{
    /// <summary>
    /// Checks all contracts and sends out notifications as the
    /// contract's end date approaches.
    /// </summary>
    public class ContractExpiryReminderService : AnacleServiceBase
    {
        public override void OnExecute()
        {
            // Gets a list of all expiring contracts due
            // for reminder.
            //
            TContract c = TablesLogic.tContract;
            List<OContract> expiringContracts =
                c.LoadList(
                (c.EndReminderDays1 != null & (c.ContractEndDate.AddDays(0 - c.EndReminderDays1) >= c.LastReminderDate | c.LastReminderDate == null) & c.ContractEndDate.AddDays(0 - c.EndReminderDays1) <= DateTime.Now) |
                (c.EndReminderDays2 != null & (c.ContractEndDate.AddDays(0 - c.EndReminderDays2) >= c.LastReminderDate | c.LastReminderDate == null) & c.ContractEndDate.AddDays(0 - c.EndReminderDays2) <= DateTime.Now) |
                (c.EndReminderDays3 != null & (c.ContractEndDate.AddDays(0 - c.EndReminderDays3) >= c.LastReminderDate | c.LastReminderDate == null) & c.ContractEndDate.AddDays(0 - c.EndReminderDays3) <= DateTime.Now) |
                (c.EndReminderDays4 != null & (c.ContractEndDate.AddDays(0 - c.EndReminderDays4) >= c.LastReminderDate | c.LastReminderDate == null) & c.ContractEndDate.AddDays(0 - c.EndReminderDays4) <= DateTime.Now)
                );

            // For each expiring contract, send a reminder
            // based on a template set up in the user interface.
            //
            foreach (OContract contract in expiringContracts)
            {
                using (Connection conn = new Connection())
                {
                    string cellphone = "";
                    string email = "";

                    if (contract.Reminder1User != null)
                    {
                        cellphone += contract.Reminder1User.UserBase.Cellphone + ";";
                        email += contract.Reminder1User.UserBase.Email + ";";
                    }
                    if (contract.Reminder2User != null)
                    {
                        cellphone += contract.Reminder2User.UserBase.Cellphone + ";";
                        email += contract.Reminder2User.UserBase.Email + ";";
                    }
                    if (contract.Reminder3User != null)
                    {
                        cellphone += contract.Reminder3User.UserBase.Cellphone + ";";
                        email += contract.Reminder3User.UserBase.Email + ";";
                    }
                    if (contract.Reminder4User != null)
                    {
                        cellphone += contract.Reminder4User.UserBase.Cellphone + ";";
                        email += contract.Reminder4User.UserBase.Email + ";";
                    }

                    contract.SendMessage("Contract_Expiry", email, cellphone);
                    contract.LastReminderDate = DateTime.Now;

                    contract.Save();
                    conn.Commit();
                }
            }

        }
    }
}
