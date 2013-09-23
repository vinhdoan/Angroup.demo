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
using OPC;
using OPCAE;
using OPCAE.NET;

namespace Service
{
    public class OPCAEService : AnacleServiceBase
    {
        List<OPCAEServerSubscription> serverSubscriptions = new List<OPCAEServerSubscription>();

        /// <summary>
        /// Occurs when the service is instructed to start.
        /// <para></para>
        /// Initializes and creates all OPC AE subscriptions.
        /// </summary>
        public override void OnStart()
        {
            lock (serverSubscriptions)
            {
                List<OOPCAEServer> opcAeServers = TablesLogic.tOPCAEServer.LoadList(
                    TablesLogic.tOPCAEServer.ReceivingEventsEnabled == 1);

                foreach (OOPCAEServer opcAeServer in opcAeServers)
                {
                    Guid opcAeServiceId = opcAeServer.ObjectID.Value;

                    // So create the server susbcription and insert it 
                    // into the list.
                    //
                    OpcEventServer opcEventServer = new OpcEventServer();
                    int rtc = opcEventServer.Connect(opcAeServer.ObjectName);

                    if (HRESULTS.Failed(rtc))
                        LogEvent("Cannot connect to server, error 0x" + rtc.ToString("X"), BackgroundLogMessageType.Error);
                    else
                    {
                        int bufferTime, maxSize;
                        EventSubscriptionMgt eventSubscription = new EventSubscriptionMgt(new OnAEeventHandler(myEventHandler));
                        rtc = eventSubscription.Create(opcEventServer, true, 1000, 100, serverSubscriptions.Count, out bufferTime, out maxSize);
                        if (HRESULTS.Failed(rtc))
                            LogEvent(opcEventServer.GetErrorString(rtc), BackgroundLogMessageType.Error);
                        else
                        {
                            LogEvent("New subscription to AE server '" + opcAeServer.ObjectName + "' created");
                            OPCAEServerSubscription serverSubscription = new OPCAEServerSubscription();
                            serverSubscription.OpcAeServerName = opcAeServer.ObjectName;
                            serverSubscription.OpcEventServer = opcEventServer;
                            serverSubscription.EventSubscription = eventSubscription;
                            serverSubscriptions.Add(serverSubscription);
                        }
                    }
                }
            }
        }


        /// <summary>
        /// Occurs whenever an event is sent to us.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void myEventHandler(object sender, userEventArgs e)
        {
            lock (serverSubscriptions)
            {
                try
                {
                    int numberOfEvents = e.Events.Length;

                    for (int i = 0; i < numberOfEvents; ++i)        // display new events
                    {
                        using (Connection c = new Connection())
                        {
                            // Load the associated event trigger.
                            //
                            OOPCAEEvent aeEvent = TablesLogic.tOPCAEEvent.Load(
                                TablesLogic.tOPCAEEvent.OPCEventSource == e.Events[i].Source &
                                TablesLogic.tOPCAEEvent.OPCAEServer.ObjectName == serverSubscriptions[e.ClientSubscription].OpcAeServerName);

                            if (aeEvent != null)
                            {
                                // Save the event in the history table.
                                //
                                OOPCAEEventHistory eventHistory = TablesLogic.tOPCAEEventHistory.Create();

                                eventHistory.OPCAEEventID = aeEvent.ObjectID;
                                eventHistory.DateOfEvent = DateTime.FromFileTime(e.Events[i].Time);
                                eventHistory.Source = e.Events[i].Source;
                                eventHistory.ConditionName = e.Events[i].ConditionName;
                                eventHistory.SubConditionName = e.Events[i].SubconditionName;
                                eventHistory.Severity = e.Events[i].Severity;
                                eventHistory.Message = e.Events[i].Message;
                                eventHistory.EventCategory = e.Events[i].EventCategory;

                                int ntyp = e.Events[i].EventType;
                                if (ntyp == (uint)OPCAEEventType.OPC_SIMPLE_EVENT)
                                    eventHistory.EventType = AEEventType.Simple;
                                else if (ntyp == (uint)OPCAEEventType.OPC_CONDITION_EVENT)
                                    eventHistory.EventType = AEEventType.Condition;
                                else if (ntyp == (uint)OPCAEEventType.OPC_TRACKING_EVENT)
                                    eventHistory.EventType = AEEventType.Tracking;

                                eventHistory.CheckForEvent(aeEvent);

                                if (aeEvent.SaveHistoricalEvents == 1)
                                    eventHistory.Save();
                            }
                            c.Commit();
                        }
                    }
                }
                catch
                {
                }
            }
        }


        /// <summary>
        /// Occurs when the service is instructed to stop.
        /// <para></para>
        /// Closes all subscriptions and disconnects from
        /// the AE servers.
        /// </summary>
        public override void OnStop()
        {
            base.OnStop();

            lock (serverSubscriptions)
            {
                // Dispose and disconnect.
                //
                foreach (OPCAEServerSubscription serverSubscription in serverSubscriptions)
                {
                    serverSubscription.EventSubscription.Dispose();
                    serverSubscription.OpcEventServer.Disconnect();
                }
            }
        }


        public class OPCAEServerSubscription
        {
            public string OpcAeServerName;
            public OpcEventServer OpcEventServer;
            public EventSubscriptionMgt EventSubscription;
        }
    }
}

