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
    public partial class AmosIntegrationPostBillingServiceOffice : AnacleServiceBase
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
                String billHeaderTable = System.Configuration.ConfigurationManager.AppSettings["AmosBillHeaderTable"].ToString();
                String billItemTable = System.Configuration.ConfigurationManager.AppSettings["AmosBillItemTable"].ToString();

                if (connAmos == "" || connAmos == null)
                    errorMsg = appendErrorMsg(errorMsg, "Amos connection string not available");

                if (billHeaderTable == "" || billHeaderTable == null)
                    errorMsg = appendErrorMsg(errorMsg, "Billing Header Table not available");

                if (billItemTable == "" || billItemTable == null)
                    errorMsg = appendErrorMsg(errorMsg, "Billing Item Table not available");

                // Loads up the bills and the bill items so that they
                // will not be loaded up again in the 
                // subsequent connections that we open
                //
                List<OBill> billList = null;
                using (Connection c = new Connection())
                {
                    billList = TablesLogic.tBill.LoadList(
                        TablesLogic.tBill.Status == (int)EnumBillStatus.NotPosted &
                        TablesLogic.tBill.InstanceID == instancename);//tessa update 08 Oct 2012

                    foreach (OBill bill in billList)
                    {
                        int x = bill.BillItem.Count;
                    }
                }

                try
                {
                    // Post all the bills across in one single transaction.
                    //
                    // We have to use the SqlConnection class because
                    // for CapitaLand, the AMOS interface table is running
                    // on SQL 2000. If we used the Anacle.DataFramework's
                    // Connection class, this will cause escalation to a 
                    // Distributed Transaction (and causes the INSERTS
                    // to fail, probably due to the fact that the production servers
                    // are not set up for Distributed Transactions.)
                    //
                    using (SqlConnection c = new SqlConnection(connAmos))
                    {
                        c.Open();
                        using(SqlTransaction t = c.BeginTransaction())
                        {
                            foreach (OBill bill in billList)
                            {
                                errorMsg = "";
                                errorMsg = VerifyObject(bill, errorMsg);
                                if (errorMsg == "")
                                {
                                    int itemCount = bill.BillItem.Count;
                                    decimal? totalBillAmount = bill.TotalBillCharge();

                                    // Doing the IF NOT EXISTS
                                    // ensures that we do not write duplicates
                                    // into the posting table.
                                    //
                                    // This is necessary to ensure that if the service fails,
                                    // we do not write duplicates to the AMOS interface
                                    // tables.
                                    //
                                    ExecuteNonQuery(c, t, 
                                        "IF (NOT EXISTS(SELECT * FROM " + billHeaderTable + " WHERE " +
                                        "batch_id = @batch_id AND " +
                                        "asset_id = @asset_id AND " +
                                        "wowj_no = @wowj_no)) " +
                                        "INSERT INTO " + billHeaderTable +
                                        "([batch_id],[asset_id],[wowj_no],[debtor_id],[lease_id],[suite_id],[contact_id]" +
                                        ",[address_id],[buildfolio_bill_date],[charge_from],[charge_to],[ttl_wo_no_items]" +
                                        ",[charge_amount_bst_lc],[wowj_desc],[updatedon]) " +
                                        " VALUES " +
                                        "(@batch_id,@asset_id,@wowj_no,@debtor_id,@lease_id,@suite_id,@contact_id" +
                                        ",@address_id,@buildfolio_bill_date,@charge_from,@charge_to,@ttl_wo_no_items" +
                                        ",@charge_amount_bst_lc,@wowj_desc,@updatedon) ",
                                        ParameterCreate("@batch_id", bill.BatchID),
                                        ParameterCreate("@asset_id", bill.AssetID),
                                        ParameterCreate("@wowj_no", bill.ObjectNumber),
                                        ParameterCreate("@debtor_id", bill.DebtorID),
                                        ParameterCreate("@lease_id", bill.LeaseID),
                                        ParameterCreate("@suite_id", bill.SuiteID),
                                        ParameterCreate("@contact_id", bill.ContactID),

                                        ParameterCreate("@address_id", bill.AddressID),
                                        ParameterCreate("@buildfolio_bill_date", DateTime.Today),
                                        ParameterCreate("@charge_from", bill.ChargeFrom),
                                        ParameterCreate("@charge_to", bill.ChargeTo),
                                        ParameterCreate("@ttl_wo_no_items", itemCount),

                                        ParameterCreate("@charge_amount_bst_lc", totalBillAmount),
                                        ParameterCreate("@wowj_desc", "Meter Reading"),
                                        ParameterCreate("@updatedon", DateTime.Today));

                                    foreach (OBillItem item in bill.BillItem)
                                    {
                                        // Doing the IF NOT EXISTS
                                        // ensures that we do not write duplicates
                                        // into the posting table.
                                        //
                                        ExecuteNonQuery(c, t, 
                                            "IF (NOT EXISTS(SELECT * FROM " + billItemTable + " WHERE " +
                                            "batch_id=@batch_id AND " +
                                            "asset_id=@asset_id AND " +
                                            "wowj_no=@wowj_no AND " +
                                            "billing_item_sno=@billing_item_sno)) " +

                                            "INSERT INTO " + billItemTable +
                                            "([batch_id],[asset_id],[wowj_no],[billing_item_sno],[charge_id]," +
                                            "[item_desc1],[item_desc2],[charge_amount_lc],[updatedon])" +
                                            " VALUES " +
                                            "(@batch_id,@asset_id,@wowj_no,@billing_item_sno,@charge_id," +
                                            "@item_desc1,@item_desc2,@charge_amount_lc,@updatedon)",

                                            ParameterCreate("@batch_id", item.BatchID),
                                            ParameterCreate("@asset_id", item.AssetID),
                                            ParameterCreate("@wowj_no", item.BillObjectNumber),
                                            ParameterCreate("@billing_item_sno", item.ItemNo),
                                            ParameterCreate("@charge_id", item.ChargeID),

                                            ParameterCreate("@item_desc1", 100, item.Description),
                                            ParameterCreate("@item_desc2", 100, item.ReadingDescription),
                                            ParameterCreate("@charge_amount_lc", item.ChargeAmount),
                                            ParameterCreate("@updatedon", DateTime.Today));
                                    }
                                }
                            }
                            t.Commit();
                        }
                        c.Close();
                    }
                }
                catch (Exception e)
                {
                    errorMsg = appendErrorMsg(errorMsg, e.Message + "\n\n" + e.StackTrace);

                    String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                    OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure,instancename + ": " + "Post Billing Service Error", errorMsg);//tessa update 08 Oct 2012
                }

                // At this juncture, we update our database's status.
                //
                using (Connection c = new Connection())
                {
                    foreach (OBill bill in billList)
                    {
                        foreach (OBillItem item in bill.BillItem)
                        {
                            if (errorMsg == "")
                                item.Reading.BillToAMOSStatus = (int)EnumBillToAMOSStatus.PostedToAMOS;
                            else
                                item.Reading.BillToAMOSStatus = (int)EnumBillToAMOSStatus.UnableToPostDueToError;
                            item.Reading.Save();
                        }
                        bill.Status = (int)EnumBillStatus.PostedToAMOS;
                        bill.Save();
                    }
                    c.Commit();
                }
            }
            catch (Exception e)
            {
                errorMsg = appendErrorMsg(errorMsg, e.Message + "\n\n" + e.StackTrace);

            }

            // Notify  administrator of error
            //
            if (errorMsg != "")
            {
                String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Post Billing Service Error", errorMsg);//tessa update 08 Oct 2012
            }
        }


        public SqlParameter ParameterCreate(string parameterName, object value)
        {
            SqlParameter p = new SqlParameter();
            p.ParameterName = parameterName;
            p.Value = value;
            return p;
        }


        public SqlParameter ParameterCreate(string parameterName, int size, object value)
        {
            SqlParameter p = new SqlParameter();
            p.Size = size;
            p.ParameterName = parameterName;
            p.Value = value;
            return p;
        }


        public void ExecuteNonQuery(SqlConnection c, SqlTransaction t, string commandText, params SqlParameter[] parameters)
        {
            SqlCommand cmd = c.CreateCommand();

            cmd.Transaction = t;
            cmd.CommandText = commandText;
            if (parameters != null)
                cmd.Parameters.AddRange(parameters);
            cmd.ExecuteNonQuery();
        }


        public String appendErrorMsg(String errorMsg, String newError)
        {
            if (errorMsg == "")
                errorMsg = newError + "<br />";
            else
                errorMsg = errorMsg + newError + "<br />";

            return errorMsg;
        }


        public String VerifyObject(OBill bill, String errorMsg)
        {
            if (bill.BatchID == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "BatchID not available");
            if (bill.AssetID == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "AssetID not available");
            if (bill.ObjectNumber == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "ObjectNumber not available");
            if (bill.DebtorID == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "DebtorID not available");
            if (bill.LeaseID == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "LeaseID not available");
            if (bill.SuiteID == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "SuiteID not available");
            if (bill.ContactID == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "ContactID not available");
            if (bill.AddressID == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "AddressID not available");
            if (bill.ChargeFrom == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "ChargeFrom not available");
            if (bill.ChargeTo == null)
                errorMsg = appendErrorMsg(errorMsg, bill.ObjectNumber + ": " + "ChargeTo not available");

            return errorMsg;
        }
    }
}
