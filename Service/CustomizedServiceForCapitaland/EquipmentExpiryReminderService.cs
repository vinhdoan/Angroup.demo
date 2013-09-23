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
    public class EquipmentExpiryReminderService : AnacleServiceBase
    {
        public override void OnExecute()
        {
            // Gets a list of all expiring contracts due
            // for reminder.
            //
            TEquipment e = TablesLogic.tEquipment;
            List<OEquipment> expiringEquipments =
                e.LoadList(
                (e.EndReminderDays1 != null & (e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays1) >= e.LastReminderDate | e.LastReminderDate == null) & e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays1) <= DateTime.Now) |
                (e.EndReminderDays2 != null & (e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays2) >= e.LastReminderDate | e.LastReminderDate == null) & e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays2) <= DateTime.Now) |
                (e.EndReminderDays3 != null & (e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays3) >= e.LastReminderDate | e.LastReminderDate == null) & e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays3) <= DateTime.Now) |
                (e.EndReminderDays4 != null & (e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays4) >= e.LastReminderDate | e.LastReminderDate == null) & e.WarrantyExpiryDate.AddDays(0 - e.EndReminderDays4) <= DateTime.Now)
                );

            // For each expiring contract, send a reminder
            // based on a template set up in the user interface.
            //
            foreach (OEquipment eqpt in expiringEquipments)
            {
                using (Connection conn = new Connection())
                {
                    string cellphone = "";
                    string email = "";

                    if (eqpt.ReminderUser1 != null)
                    {
                        cellphone += eqpt.ReminderUser1.UserBase.Cellphone + ";";
                        email += eqpt.ReminderUser1.UserBase.Email + ";";
                    }
                    if (eqpt.ReminderUser2 != null)
                    {
                        cellphone += eqpt.ReminderUser2.UserBase.Cellphone + ";";
                        email += eqpt.ReminderUser2.UserBase.Email + ";";
                    }
                    if (eqpt.ReminderUser3 != null)
                    {
                        cellphone += eqpt.ReminderUser3.UserBase.Cellphone + ";";
                        email += eqpt.ReminderUser3.UserBase.Email + ";";
                    }
                    if (eqpt.ReminderUser4 != null)
                    {
                        cellphone += eqpt.ReminderUser4.UserBase.Cellphone + ";";
                        email += eqpt.ReminderUser4.UserBase.Email + ";";
                    }

                    eqpt.SendMessage("Equipment_WarrantyExpiry", email, cellphone);
                    eqpt.LastReminderDate = DateTime.Now;

                    eqpt.Save();
                    conn.Commit();
                }
            }

        }
    }
}
