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
    public class OPCDAService : AnacleServiceBase
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="itemName"></param>
        /// <returns></returns>
        private ReadRequestItem NewReadRequestItem(string itemName)
        {
            ReadRequestItem rri = new ReadRequestItem();
            rri.ItemName = itemName;
            return rri;
        }

        /// <summary>
        /// Reading all readings from an OPC server.
        /// </summary>
        private void ProcessOPCServer(OOPCDAServer opcDaServer)
        {
            if (opcDaServer.AutomaticPollingEnabled == 0)
                return;

            XmlServer srv = null;
            try
            {
                srv = new XmlServer(opcDaServer.ObjectName);

                List<OPoint> points = TablesLogic.tPoint.LoadList(
                    TablesLogic.tPoint.OPCDAServerID == opcDaServer.ObjectID);
                if (points.Count == 0)
                    return;

                List<ReadRequestItem> readRequestItems = new List<ReadRequestItem>();
                Hashtable hash = new Hashtable();
                foreach (OPoint point in points)
                {
                    readRequestItems.Add(NewReadRequestItem(point.OPCItemName));
                    hash[point.OPCItemName] = point;
                }
                ReadRequestItemList readItemList = new ReadRequestItemList();
                readItemList.Items = readRequestItems.ToArray();

                ReplyBase reply;
                RequestOptions options = new RequestOptions();
                options.ReturnErrorText = true;
                options.ReturnItemName = true;
                ReplyItemList rslt;
                OPCError[] err;
                reply = srv.Read(options, readItemList, out rslt, out err);
                if (rslt == null)
                    throw new Exception(err[0].Text);
                else
                {
                    int count = 0;
                    foreach (ItemValue iv in rslt.Items)
                    {
                        if (iv.ResultID == null)
                        {
                            try
                            {
                                using (Connection c = new Connection())
                                {
                                    // Create the readings. 
                                    //
                                    OReading reading = TablesLogic.tReading.Create();
                                    OPoint point = hash[iv.ItemName] as OPoint;

                                    if (point != null)
                                    {
                                        reading.PointID = point.ObjectID;
                                        reading.LocationID = point.LocationID;
                                        //reading.LocationTypeParameterID = point.LocationTypeParameterID;
                                        reading.EquipmentID = point.EquipmentID;
                                        //reading.EquipmentTypeParameterID = point.EquipmentTypeParameterID;
                                        reading.DateOfReading = DateTime.Now;

                                        if (iv.Value is bool)
                                            reading.Reading = ((bool)iv.Value) ? 1 : 0;
                                        else
                                            reading.Reading = Convert.ToDecimal(iv.Value.ToString());
                                        reading.Source = ReadingSource.OPCServer;
                                        reading.CheckForBreachOfReading(point);
                                        reading.Save();
                                        count++;
                                    }
                                    c.Commit();
                                }
                            }
                            catch (Exception ex)
                            {
                                LogEvent(ex.Message + "\n\n" + ex.StackTrace, BackgroundLogMessageType.Error);
                            }
                        }
                        else
                            LogEvent("Error reading '" + iv.ItemName + "': " + iv.ResultID.Name, BackgroundLogMessageType.Error);
                    }
                    LogEvent(count + " points out of " + readItemList.Items.Length + " successfully read from server '" + opcDaServer.ObjectName + "'.");
                }
            }
            catch (Exception ex)
            {
                LogEvent(ex.Message + "\n\n" + ex.StackTrace, BackgroundLogMessageType.Error);
            }
            finally
            {
                if (srv != null)
                    srv.Dispose();
            }
            
        }

        /// <summary>
        /// Process all OPC servers.
        /// </summary>
        private void ProcessAll()
        {
            List<OOPCDAServer> opcDaServers = TablesLogic.tOPCDAServer.LoadList(
                TablesLogic.tOPCDAServer.AutomaticPollingEnabled == 1);

            foreach (OOPCDAServer opcDaServer in opcDaServers)
                ProcessOPCServer(opcDaServer);
        }

        /// <summary>
        /// Occurs when the time is up for the service to run.
        /// </summary>
        public override void OnExecute()
        {
            ProcessAll();
        }
    }
}

