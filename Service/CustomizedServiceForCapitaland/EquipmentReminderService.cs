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
using System.Data.Sql;
using System.Data.SqlClient;
using System.Text.RegularExpressions;

namespace Service
{
    public partial class EquipmentReminderService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            List<OEquipmentReminder> reminders = TablesLogic.tEquipmentReminder.LoadList(
                                                 TablesLogic.tEquipmentReminder.IsReminderSent != 1 &
                                                 TablesLogic.tEquipmentReminder.ReminderDate <= DateTime.Today.Date);
            List<Guid> userIdList = new List<Guid>();
            foreach (OEquipmentReminder re in reminders)
            {
                if (re.Equipment.ReminderUser1 != null)
                {
                    if (!userIdList.Contains((Guid)re.Equipment.ReminderUser1ID))
                    {
                        userIdList.Add((Guid)re.Equipment.ReminderUser1ID);
                        SendEmail(re, re.Equipment.ReminderUser1);
                    }
                }
                if (re.Equipment.ReminderUser2 != null)
                {
                    if (!userIdList.Contains((Guid)re.Equipment.ReminderUser2ID))
                    {
                        userIdList.Add((Guid)re.Equipment.ReminderUser2ID);
                        SendEmail(re, re.Equipment.ReminderUser2);
                    }
                }
                if (re.Equipment.ReminderUser3 != null)
                {
                    if (!userIdList.Contains((Guid)re.Equipment.ReminderUser3ID))
                    {
                        userIdList.Add((Guid)re.Equipment.ReminderUser3ID);
                        SendEmail(re, re.Equipment.ReminderUser3);
                    }
                }
                if (re.Equipment.ReminderUser4 != null)
                {
                    if (!userIdList.Contains((Guid)re.Equipment.ReminderUser4ID))
                    {
                        userIdList.Add((Guid)re.Equipment.ReminderUser4ID);
                        SendEmail(re, re.Equipment.ReminderUser4);
                    }
                }
                using (Connection c = new Connection())
                {
                    re.IsReminderSent = 1;
                    re.Save();
                    c.Commit();
                }
            }

        }
        public void SendEmail(OEquipmentReminder re, OUser user)
        {
            re.SendMessage("Equipment_Reminder",
                user.UserBase.Email, user.UserBase.Cellphone);

        }
    }

}
