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
using xmldanet;
using xmldanet.xmlda;

namespace Service
{
    /// <summary>
    /// Clears unwanted data on a regular basis.
    /// </summary>
    public class DataClearingService : AnacleServiceBase
    {
        public override void OnExecute()
        {
            // Clear messages and log-in histories.
            //
            OApplicationSetting applicationSetting = OApplicationSetting.Current;
            OSessionAudit.ClearLoginHistory(DateTime.Now.AddDays(-applicationSetting.NumberOfDaysToKeepLoginHistory.Value));
            OMessage.ClearMessageHistory(DateTime.Now.AddDays(-applicationSetting.NumberOfDaysToKeepMessageHistory.Value));
            OBackgroundServiceLog.ClearLogHistory(DateTime.Now.AddDays(-applicationSetting.NumberOfDaysToKeepBackgroundServiceLog.Value));
        }
    }
}
