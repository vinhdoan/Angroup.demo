//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
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
    public partial class WorkNotification : AnacleServiceBase
    {

        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            List<OWork> ListOfWork = TablesLogic.tWork.LoadList(
                TablesLogic.tWork.IsDeleted == 0 &
                TablesLogic.tWork.CurrentActivity.IsDeleted == 0 &
                TablesLogic.tWork.CurrentActivity.ObjectName == "PendingExecution" &
                TablesLogic.tWork.NotifyWorkTechnician == 1 &
                TablesLogic.tWork.IsPendingExecutionNotified != 1 &
                TablesLogic.tWork.ScheduledStartDateTime < DateTime.Now
                );

            foreach (OWork W in ListOfWork)
            {
                using (Connection c = new Connection())
                {
                    W.NotifyTechnicianPendingExecution();
                    W.Save();
                    c.Commit();
                }
            }
        }

    }
}
