//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// Copyright 2013 (c) DGroup Pte. Ltd.
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
using System.Threading;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;
using System.Collections;
using System.Transactions;

namespace Service
{
    public class AnacleServiceBase
    {
        /// <summary>
        /// The service name of this service. This is used to
        /// identify the source that outputs events to the background
        /// service log.
        /// </summary>
        protected string ServiceName = "";

        [ThreadStatic]
        protected static OApplicationSetting applicationSetting = null;

        /// <summary>
        /// The application setting service object of this service. 
        /// </summary>
        protected OApplicationSettingService applicationSettingService = null;

        /// <summary>
        /// Returns a cached copy of the application settings 
        /// applicable to the current executing thread and
        /// the current loop that the service is executing in.
        /// </summary>
        public static OApplicationSetting ApplicationSetting
        {
            get
            {
                return applicationSetting;
            }
        }


        /// <summary>
        /// Used by the service to implement a lock.
        /// </summary>
        private ArrayList SyncRoot = new ArrayList();


        /// <summary>
        /// Constructor.
        /// </summary>
        public AnacleServiceBase()
        {
            ServiceName = this.GetType().Name;
            RefreshApplicationServiceSettings();
        }

        /// <summary>
        /// Starts the service.
        /// </summary>
        public void Start()
        {
            LogEvent("Service starting...");
            try
            {
                RefreshApplicationServiceSettings();
                OnStart();

                //set current status to stopped if it is running.
                if (applicationSettingService != null)
                {
                    OBackgroundServiceRun bsr = applicationSettingService.BackgroundServiceRun;
                    if (bsr != null)
                    {
                        if (bsr.CurrentStatus == (int)BackgroundServiceCurrentStatus.Running)
                        {
                            UpdateBackgroundServiceRun(null, (int)BackgroundServiceCurrentStatus.Stopped, null);
                            UpdateBackgroundServiceRunNextRun();
                        }
                    }
                }

            }
            catch (Exception ex)
            {
                LogException("Unable to start service: ", ex);
            }
            LogEvent("Service started.");
        }

        /// <summary>
        /// Executes the service.
        /// </summary>
        public void Execute()
        {
            // Tries to grab a lock. If it fails, simply just quit and 
            // wait from the next run.
            //
            // This helps to prevent re-entry of the patrolling service
            // should the server suddenly runs into a serious CPU load.
            // 
            if (Monitor.TryEnter(SyncRoot))
            {
                try
                {
                    DateTime dtnow = DateTime.Now;
                    RefreshApplicationServiceSettings();

                    OBackgroundServiceRun servicerun = applicationSettingService.BackgroundServiceRun;

                    if (servicerun == null)
                    {
                        using (Connection c = new Connection())
                        {
                            servicerun = TablesLogic.tBackgroundServiceRun.Create();
                            servicerun.ServiceName = applicationSettingService.ServiceName;
                            servicerun.NextRunDateTime = dtnow;
                            servicerun.Save();
                            c.Commit();
                        }
                    }

                    if (servicerun.CurrentStatus == (int)BackgroundServiceCurrentStatus.Running || (servicerun.CurrentStatus == (int)BackgroundServiceCurrentStatus.Stopped && servicerun.NextRunDateTime <= dtnow))
                    {
                        using (Connection c = new Connection())
                        {
                            servicerun.LastRunStartDateTime = DateTime.Now;
                            servicerun.LastRunCompleteDateTime = null;
                            servicerun.CurrentStatus = (int)BackgroundServiceCurrentStatus.Running;
                            servicerun.LastRunErrorMessage = "";
                            servicerun.NextRunDateTime = null;
                            servicerun.Save();
                            c.Commit();
                        }

                        LogEvent("Service executing...");
                        OnExecute();

                        //log and update successful
                        LogEvent("Service successfully Executed");
                        RefreshApplicationServiceSettings();
                        UpdateBackgroundServiceRun((int)BackgroundServiceLastRunStatus.Succeeded, (int)BackgroundServiceCurrentStatus.Stopped, "");

                        //update next run time
                        UpdateBackgroundServiceRunNextRun();
                    }
                }
                catch (Exception ex)
                {
                    //log and update fail
                    LogException("Unable to execute service: ", ex);
                    RefreshApplicationServiceSettings();
                    UpdateBackgroundServiceRun((int)BackgroundServiceLastRunStatus.Failed, (int)BackgroundServiceCurrentStatus.Stopped, ex.ToString());
                    //update next run time
                    UpdateBackgroundServiceRunNextRun();
                }
                finally
                {
                    Monitor.Exit(SyncRoot);
                }
            }
        }

        private void UpdateBackgroundServiceRun(int? lastRunStatus, int currentStatus, String lastRunErrorMsg)
        {
            int retries = 100;

            do
            {
                try
                {
                    using (Connection c = new Connection())
                    {
                        OBackgroundServiceRun bsr = applicationSettingService.BackgroundServiceRun;

                        if (lastRunStatus != null)
                        {
                            bsr.LastRunStatus = lastRunStatus;
                            bsr.LastRunErrorMessage = lastRunErrorMsg;
                        }

                        bsr.LastRunCompleteDateTime = DateTime.Now;
                        bsr.CurrentStatus = currentStatus;
                        bsr.Save();
                        c.Commit();
                        return;
                    }
                }
                catch (Exception e)
                {
                    if (retries <= 0) throw e;
                    else Thread.Sleep(1000); //wait for 1 second before retrying
                }
            } while (retries-- > 0);
        }

        private void UpdateBackgroundServiceRunNextRun()
        {
            int retries = 100;

            do
            {
                try
                {
                    using (Connection c = new Connection())
                    {
                        OBackgroundServiceRun bsr = applicationSettingService.BackgroundServiceRun;
                        bsr.NextRunDateTime = applicationSettingService.GetNextDateTime();
                        bsr.Save();
                        c.Commit();
                        return;
                    }
                }
                catch (Exception e)
                {
                    if (retries <= 0) throw e;
                    else Thread.Sleep(1000); //wait for 1 second before retrying
                }
            } while (retries-- > 0);

        }

        //Used to reload the application setting service object
        private void RefreshApplicationServiceSettings()
        {
            applicationSetting = OApplicationSetting.Current;
            applicationSettingService = TablesLogic.tApplicationSettingService.Load(TablesLogic.tApplicationSettingService.ApplicationSettingID == applicationSetting.ObjectID &
                                                                                        TablesLogic.tApplicationSettingService.IsDeleted == 0 &
                                                                                        TablesLogic.tApplicationSettingService.ServiceName == this.ServiceName);
        }

        /// <summary>
        /// Stops the service.
        /// </summary>
        public void Stop()
        {
            LogEvent("Service stopping...");
            try
            {
                RefreshApplicationServiceSettings();
                OnStop();
                //set current status to stopped if it is running.
                if (applicationSettingService != null)
                {
                    OBackgroundServiceRun bsr = applicationSettingService.BackgroundServiceRun;
                    if (bsr != null)
                    {
                        if (bsr.CurrentStatus == (int)BackgroundServiceCurrentStatus.Running)
                        {
                            UpdateBackgroundServiceRun(null, (int)BackgroundServiceCurrentStatus.Stopped, null);
                            UpdateBackgroundServiceRunNextRun();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogException("Unable to stop service: ", ex);
            }
            LogEvent("Service stopped.");
        }


        /// <summary>
        /// Occurs when the service first starts, before
        /// the timer is activated.
        /// </summary>
        public virtual void OnStart()
        {
        }


        /// <summary>
        /// Occurs when the service is due to run. The deriving
        /// service class must implement this event.
        /// </summary>
        public virtual void OnExecute()
        {
        }


        /// <summary>
        /// Occurs when the service stops. 
        /// </summary>
        public virtual void OnStop()
        {
        }


        /// <summary>
        /// Logs a message into the background service log
        /// </summary>
        /// <param name="logMessage"></param>
        public void LogEvent(string logMessage)
        {
            Common.LogEvent(logMessage, BackgroundLogMessageType.Information, this.ServiceName);
        }

        /// <summary>
        /// Logs a message into the background service log
        /// </summary>
        /// <param name="logMessage"></param>
        public void LogEvent(string logMessage, BackgroundLogMessageType messageType)
        {
            Common.LogEvent(logMessage, messageType, this.ServiceName);
        }

        /// <summary>
        /// Logs an exception into the background service log.
        /// </summary>
        /// <param name="exception"></param>
        public void LogException(string logMessage, Exception exception)
        {
            Common.LogException(logMessage, exception, this.ServiceName);
        }
    }
}
