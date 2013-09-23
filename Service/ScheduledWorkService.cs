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
using System.Collections;

using LogicLayer;

namespace Service
{
    /// <summary>
    /// Represents a service that generates Works from a
    /// saved Scheduled Work.
    /// </summary>
    public class ScheduledWorkService : AnacleServiceBase
    {
        /// <summary>
        /// Occurs when the timer service is up.
        /// </summary>
        public override void OnExecute()
        {
            // Pick just one scheduled work (the one with the earliest  
            // scheduled start date/time) to generate works for.
            //
            TScheduledWork sw = TablesLogic.tScheduledWork;
            OScheduledWork scheduledWork = sw.Load(
                (sw.IsAllFixedWorksCreatedAtOnce == 1 |
                sw.SchedulerStartDateTime.AddDays(0 - sw.NumberOfDaysInAdvanceToCreateFixedWorks) < DateTime.Now) &
                sw.SchedulerInProgress == 1,
                sw.SchedulerStartDateTime.Asc);

            if (scheduledWork == null)
                return;
            
            scheduledWork.CreateWorksForNextCycle("SubmitForAssignment");

        }
    }
}
