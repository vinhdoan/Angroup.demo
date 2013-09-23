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
    public partial class ContractReminderService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            List<OContractReminder> reminders = TablesLogic.tContractReminder.LoadList(
                                                 TablesLogic.tContractReminder.IsReminderSent != 1 &
                                                 TablesLogic.tContractReminder.ReminderDate <= DateTime.Today.Date);
            List<Guid> userIdList = new List<Guid>();
            foreach (OContractReminder re in reminders)
            {
                if (re.Contract.Reminder1User != null)
                {
                    if (!userIdList.Contains((Guid)re.Contract.Reminder1UserID))
                    {
                        userIdList.Add((Guid)re.Contract.Reminder1UserID);
                        SendEmail(re, re.Contract.Reminder1User);
                    }
                }
                if (re.Contract.Reminder2User != null)
                {
                    if (!userIdList.Contains((Guid)re.Contract.Reminder2UserID))
                    {
                        userIdList.Add((Guid)re.Contract.Reminder2UserID);
                        SendEmail(re, re.Contract.Reminder2User);
                    }
                }
                if (re.Contract.Reminder3User != null)
                {
                    if (!userIdList.Contains((Guid)re.Contract.Reminder3UserID))
                    {
                        userIdList.Add((Guid)re.Contract.Reminder3UserID);
                        SendEmail(re, re.Contract.Reminder3User);
                    }
                }
                if (re.Contract.Reminder4User != null)
                {
                    if (!userIdList.Contains((Guid)re.Contract.Reminder4UserID))
                    {
                        userIdList.Add((Guid)re.Contract.Reminder4UserID);
                        SendEmail(re, re.Contract.Reminder4User);
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
        public void SendEmail(OContractReminder re, OUser user)
        {
            re.SendMessage("Contract_Reminder",
                user.UserBase.Email, user.UserBase.Cellphone);

        }
    }

}
