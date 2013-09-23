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
    public partial class AmosIntegrationReadBillingServiceOffice : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            String errorMsg = "";
            String instancename = "Amos_SG_RCS_Office";//tessa update 08 Oct 2012
            try
            {
                String connAmos = System.Configuration.ConfigurationManager.AppSettings[instancename].ToString();//tessa update 08 Oct 2012
                String billHeaderTable = System.Configuration.ConfigurationManager.AppSettings["AmosBillHeaderTableStatus"].ToString();

                if (connAmos == "" || connAmos == null)
                    errorMsg = appendErrorMsg(errorMsg, "Amos connection string not available");

                if (billHeaderTable == "" || billHeaderTable == null)
                    errorMsg = appendErrorMsg(errorMsg, "Billing Header Table not available");

                List<OBill> billList = TablesLogic.tBill.LoadList(
                    TablesLogic.tBill.Status == (int)EnumBillStatus.PostedToAMOS &
                    TablesLogic.tBill.InstanceID == instancename);// tessa update 08 Oct 2012

                foreach (OBill bill in billList)
                {
                    DataTable dt = new DataTable();
                    DataSet ds = new DataSet();
                    try
                    {
                        ds = Connection.ExecuteQuery(connAmos,
                        "SELECT  * from " + billHeaderTable +
                        "WHERE batch_id = " + bill.BatchID +
                        "and asset_id = " + bill.AssetID +
                        "and wowj_no = '" + bill.ObjectNumber + "'", null);
                    }
                    catch (Exception e)
                    {
                        errorMsg = appendErrorMsg(errorMsg, e.Message);

                        String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                        OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Billing Service Error", "Read Bill from " + instancename + ": " + errorMsg);//tessa update 08 Oct 2012
                    }
                    if (ds.Tables.Count > 0)
                        dt = ds.Tables[0];

                    foreach (DataRow dr in dt.Rows)
                    {
                        if (dr["amos_interface_status"].ToString() == "SUCCESS")
                        {
                            using (Connection c = new Connection())
                            {
                                foreach (OBillItem item in bill.BillItem)
                                {
                                    item.Reading.BillToAMOSStatus = (int)EnumBillToAMOSStatus.PostedToAMOSSuccessful;
                                    item.Reading.Save();
                                }
                                bill.Status = (int)EnumBillStatus.PostedToAMOSWithStatus;
                                bill.Save();
                                c.Commit();
                            }
                        }
                        else if (dr["amos_interface_status"].ToString() == "FAILED")
                        {
                            using (Connection c = new Connection())
                            {
                                foreach (OBillItem item in bill.BillItem)
                                {
                                    item.Reading.BillToAMOSStatus = (int)EnumBillToAMOSStatus.PostedToAMOSFailed;
                                    if (dr["amos_wowj_errorremarks"] != DBNull.Value)
                                        item.Reading.AMOSErrorMessage = dr["amos_wowj_errorremarks"].ToString();
                                    item.Reading.Save();
                                }
                                bill.Status = (int)EnumBillStatus.PostedToAMOSWithStatus;
                                bill.Save();
                                c.Commit();
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                errorMsg = appendErrorMsg(errorMsg, e.Message);

                String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Billing Service Error", errorMsg);//tessa update 08 Oct 2012
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="errorMsg"></param>
        /// <param name="newError"></param>
        /// <returns></returns>
        public String appendErrorMsg(String errorMsg, String newError)
        {
            if (errorMsg == "")
                errorMsg = newError + "<br />";
            else
                errorMsg = errorMsg + newError + "<br />";

            return errorMsg;
        }
    }
}
