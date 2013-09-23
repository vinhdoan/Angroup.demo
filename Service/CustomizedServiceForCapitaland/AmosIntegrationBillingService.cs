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
    public partial class AmosIntegrationBillingService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            String connAmos = System.Configuration.ConfigurationManager.AppSettings["AmosStagging"].ToString();
            String connLive = System.Configuration.ConfigurationManager.AppSettings["database"].ToString();

            List<OReading> readingList = TablesLogic.tReading.LoadList(
                TablesLogic.tReading.BillToAMOSStatus==1);

            foreach (OReading reading in readingList)
            {
                //SqlParameter accID = new SqlParameter("@", );
                //Connection.ExecuteNonQuery(connLive, "insert", accID);

                using (Connection c = new Connection())
                {
                    reading.BillToAMOSStatus = 2;
                    reading.Save();
                    c.Commit();
                }
            }
        }
    }
}
