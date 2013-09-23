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
    public partial class UpdateContractStatus : AnacleServiceBase
    {

        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            List<OContract> listContract = TablesLogic.tContract.LoadList(
                TablesLogic.tContract.ContractEndDate < DateTime.Now &
                TablesLogic.tContract.CurrentActivity.ObjectName == "InProgress");
            using (Connection c = new Connection())
            {
                foreach (OContract contract in listContract)
                {
                    try
                    {
                        contract.SaveAndTransit("Expire");
                    }
                    catch (Exception ex)
                    { }
                }
                c.Commit();
            }
        }

    }
}
