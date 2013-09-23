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
    public partial class ReminderForMeterReadingService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            List<OPoint> pointList = TablesLogic.tPoint.LoadList(
                TablesLogic.tPoint.ReadingDay == DateTime.Today.Day &
                TablesLogic.tPoint.IsActive == 1 &
                (TablesLogic.tPoint.LastReminderDate ==null |
                TablesLogic.tPoint.LastReminderDate.Date() < DateTime.Today.Date));

            List<Guid> userIdList = new List<Guid>();
            
            foreach (OPoint point in pointList)
            {
                if (point.ReminderUser1 != null)
                {
                    if (!userIdList.Contains((Guid)point.ReminderUser1.ObjectID))
                    {
                        userIdList.Add((Guid)point.ReminderUser1.ObjectID);
                        SendEmail(point.ReminderUser1);
                    }
                }
                if (point.ReminderUser2 != null)
                {
                    if (!userIdList.Contains((Guid)point.ReminderUser2.ObjectID))
                    {
                        userIdList.Add((Guid)point.ReminderUser2.ObjectID);
                        SendEmail(point.ReminderUser2);
                    }
                }
                if (point.ReminderUser3 != null)
                {
                    if (!userIdList.Contains((Guid)point.ReminderUser3.ObjectID))
                    {
                        userIdList.Add((Guid)point.ReminderUser3.ObjectID);
                        SendEmail(point.ReminderUser3);
                    }
                }
                if (point.ReminderUser4 != null)
                {
                    if (!userIdList.Contains((Guid)point.ReminderUser4.ObjectID))
                    {
                        userIdList.Add((Guid)point.ReminderUser4.ObjectID);
                        SendEmail(point.ReminderUser4);
                    }
                }
                using (Connection c = new Connection())
                {
                    point.LastReminderDate = DateTime.Today;
                    point.Save();
                    c.Commit();
                }
            }
        }
        public void SendEmail(OUser user)
        {
            user.SendMessage("Reading_Reminder",
                user.UserBase.Email, user.UserBase.Cellphone);
            
        }
    }
}
