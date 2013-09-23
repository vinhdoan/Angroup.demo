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
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Reflection;
using System.Web;
using System.Web.Services;
using System.Transactions;
using System.Threading;

using Anacle.DataFramework;
using LogicLayer;
using Anacle.WorkflowFramework;

namespace Service
{
    public partial class ServiceMain : ServiceBase
    {
        private System.Timers.Timer timer1 = new System.Timers.Timer();

        //service patrol interval in SECONDS
        private object ServiceTimerInterval = System.Configuration.ConfigurationManager.AppSettings["ServicePatrolInterval"];

        public Hashtable subServicesHashTable = new Hashtable();

        public List<AnacleServiceBase> subservices = new List<AnacleServiceBase>();

        public static ServiceMain MainService = new ServiceMain();

        /// <summary>
        /// Used by the service to implement a lock.
        /// </summary>
        private ArrayList SyncRoot = new ArrayList();

        public ServiceMain()
        {
            //System.Threading.Thread.Sleep(10000);

            InitializeComponent();
            timer1.Elapsed += new System.Timers.ElapsedEventHandler(timer1_Elapsed);
            timer1.Interval = this.GetTimerIntervalInMilliseconds();
        }

        public ServiceMain(IContainer container)
        {
            container.Add(this);
            InitializeComponent();
        }

        void timer1_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
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
                    if (timer1.Enabled)
                        timer1.Enabled = false;

                    Patrol();
                }
                catch (Exception ex)
                {
                    Common.LogException("Exception in Patrol Service: ", ex, "Main Service");
                }
                finally
                {
                    if (!timer1.Enabled)
                        timer1.Enabled = true;

                    Monitor.Exit(SyncRoot);
                }
            }
        }

        private double GetTimerIntervalInMilliseconds()
        {
            try
            {
                int repeatInterval = Convert.ToInt32(ServiceTimerInterval);
                TimeSpan ts = new TimeSpan();
                ts = new TimeSpan(0, 0, 0, repeatInterval, 0);
                return ts.TotalMilliseconds;
            }
            catch
            {
                //default 5seconds
                return 5000;
            }
        }

        //private bool CheckDependencies(string serviceName)
        //{
        //    bool check = true;
        //    OApplicationSettingService o = TablesLogic.tApplicationSettingService.Load(TablesLogic.tApplicationSettingService.ServiceName == serviceName &
        //                                                                               TablesLogic.tApplicationSettingService.ApplicationSettingID == OApplicationSetting.Current.ObjectID);

        //    if (o != null)
        //    {
        //        if (o.DependentServiceName != null && o.DependentServiceName.Trim() != "")
        //        {
        //            string[] ds = o.DependentServiceName.Split(',');
        //            ExpressionCondition e = null;

        //            for (int i = 0; i < ds.Length; i++)
        //            {
        //                if (e == null)
        //                    e = TablesLogic.tBackgroundServiceRun.ServiceName == ds[i];
        //                else
        //                    e |= TablesLogic.tBackgroundServiceRun.ServiceName == ds[i];
        //            }

        //            List<OBackgroundServiceRun> dependentservices = TablesLogic.tBackgroundServiceRun.LoadList(e);

        //            string emailMessage = Resources.Notifications.ServiceDependency_HeaderMessage;

        //            foreach (OBackgroundServiceRun bsr in dependentservices)
        //            {
        //                if (bsr.LastRunStatus == (int)BackgroundServiceLastRunStatus.Failed)
        //                {
        //                    emailMessage += String.Format(Resources.Notifications.ServiceDependency_FailedServices, bsr.ServiceName, bsr.LastRunStartDateTime, bsr.LastRunErrorMessage, bsr.NextRunDateTime);
        //                    check = false;
        //                }
        //            }

        //            if (!check)
        //            {
        //                Common.SendEmailOnError(emailMessage, serviceName);
        //            }
        //        }
        //    }

        //    return check;
        //}

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        public static void Main()
        {
            Type[] types = Assembly.GetExecutingAssembly().GetTypes();

            // Initialize the DataFramework
            //
            Anacle.DataFramework.Global.Initialize();

            // Initializes the workflow engine.
            //
            WorkflowEngine.Initialize();
            WorkflowEngine.Engine.StartWorkflowEngine();

            // Create the sub-services
            //
            //applicationSetting = OApplicationSetting.Current;
            foreach (Type type in types)
            {
                if (type.IsSubclassOf(typeof(AnacleServiceBase)))
                {
                    AnacleServiceBase serviceBase = Activator.CreateInstance(type) as AnacleServiceBase;

                    if (serviceBase != null)
                    {
                        //if (applicationSetting.IsServiceEnabled(type.Name))
                        MainService.subservices.Add(serviceBase);
                        MainService.subServicesHashTable.Add(serviceBase.GetType().Name, serviceBase);
                    }
                }
            }
            ServiceBase.Run(MainService);
        }

        private void Patrol()
        {
            Common.LogEvent("Patrol Executing...", "Main Service");

            List<OApplicationSettingService> services = TablesLogic.tApplicationSettingService.LoadList(
                                                        TablesLogic.tApplicationSettingService.ApplicationSettingID == OApplicationSetting.Current.ObjectID &
                                                        TablesLogic.tApplicationSettingService.IsDeleted == 0 &
                                                        TablesLogic.tApplicationSettingService.IsEnabled == 1);

            foreach (OApplicationSettingService ass in services)
            {
                //if (CheckDependencies(ass.ServiceName))
                //{
                AnacleServiceBase asb = (AnacleServiceBase)subServicesHashTable[ass.ServiceName];
                if (asb == null)
                    throw new Exception("Unable to find service '" + ass.ServiceName + "'. Are you sure you configured the service name correctly?");

                //run the OnExecute method on a new thread
                Common.LogEvent("Creating thread for " + ass.ServiceName, "Main Service");
                Thread thread = new Thread(new ThreadStart(asb.Execute));
                thread.Start();
                Common.LogEvent("Thread sucessfully created for " + ass.ServiceName, "Main Service");
                //}
            }

            Common.LogEvent("Patrol successfully Executed", "Main Service");
        }

        /// <summary>
        /// Starts all sub-services.
        /// </summary>
        /// <param name="args"></param>
        protected override void OnStart(string[] args)
        {
            try
            {
                base.OnStart(args);

                foreach (AnacleServiceBase subservice in subservices)
                {
                    subservice.Start();
                }

                //start the timer for patrol
                timer1.Enabled = true;
            }
            catch (Exception ex)
            {
                Common.LogException("Exception in ServiceMain: ", ex, "Main Service");
            }
        }

        /// <summary>
        /// Stops all sub-services.
        /// </summary>
        protected override void OnStop()
        {
            try
            {
                base.OnStop();

                foreach (AnacleServiceBase subservice in subservices)
                {
                    subservice.Stop();
                }
            }
            catch (Exception ex)
            {
                Common.LogException("Exception in ServiceMain: ", ex, "Main Service");
            }
        }

    }
}
