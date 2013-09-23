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
using System.IO;
using System.Text.RegularExpressions;

namespace Service
{
    public partial class BMSReadingService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            //int DayDiff = 0;
                //System.Configuration.ConfigurationManager.AppSettings["BMSImportDayDifference"];
            DateTime BMSDate = DateTime.Now.Date;
            List<OOPCDAServer> opcList = TablesLogic.tOPCDAServer.LoadList(
                                          TablesLogic.tOPCDAServer.IsReadFromTextFile == 1);
            foreach (OOPCDAServer opc in opcList)
            {
                OBMSTransmissionStatus.GenerateReadingFromOPCDAServer(opc, false);
            }
        }
       
       
    }
   

}
