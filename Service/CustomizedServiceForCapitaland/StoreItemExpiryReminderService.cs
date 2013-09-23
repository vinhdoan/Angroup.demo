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
    public partial class StoreItemExpiryReminderService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// Gets the current quarter
        /// If the equipment Warranty expiry date is before current quarter then send mail informing
        /// store's notify users.
        /// </summary>
        public override void OnExecute()
        {
            //if(DateTime.Now.Month.ToString().Is("1,4,7,10") && DateTime.Now.Day == 1)
            {
                List<OStore> storeListToSendEmail = new List<OStore>();
                List<OStoreBinItem> listStoreBinItem = TablesLogic.tStoreBinItem.LoadList(
                    TablesLogic.tStoreBinItem.Equipment.WarrantyExpiryDate.Date() <= DateTime.Now.AddMonths(6));
                if (listStoreBinItem != null)
                    foreach (OStoreBinItem sbi in listStoreBinItem)
                    {
                        if (sbi.StoreBin.TotalPhysicalQuantity > 0)
                        {
                            OStore s = sbi.StoreBin.Store;
                            /// Add the storebinitem to store.
                            if (s.StoreBinsWithEquipmentExpiring.Find(sbi.ObjectID.Value) == null)
                                s.StoreBinsWithEquipmentExpiring.Add(sbi);
                            using (Connection c = new Connection())
                            {
                                s.Save();
                                c.Commit();
                            }
                            /// Following code to check if there is duplicate store in the store list to send email
                            bool storeExistsInStoreList = true;
                            if (storeListToSendEmail.Count == 0)
                                storeListToSendEmail.Add(s);
                            else
                            {
                                foreach (OStore tempStore in storeListToSendEmail)
                                    if (tempStore.ObjectID != s.ObjectID)
                                    {
                                        storeExistsInStoreList = false;
                                        break;
                                    }
                            }
                            if (storeExistsInStoreList == true)
                                storeListToSendEmail.Add(s);
                        }
                    }
                foreach (OStore s in storeListToSendEmail)
                {
                    /// Check if the notify users exists, else add their email to the list.
                    if (s.StoreType == 0)
                    {
                        string userEmails = "";
                        if (s.NotifyUser1 != null && s.NotifyUser1.UserBase.Email != null)
                            userEmails = (userEmails != "" ? "," : "") + s.NotifyUser1.UserBase.Email;

                        if (s.NotifyUser2 != null && s.NotifyUser2.UserBase.Email != null)
                            userEmails += (userEmails != "" ? "," : "") + s.NotifyUser2.UserBase.Email;

                        if (s.NotifyUser3 != null && s.NotifyUser3.UserBase.Email != null)
                            userEmails += (userEmails != "" ? "," : "") + s.NotifyUser3.UserBase.Email;

                        if (s.NotifyUser4 != null && s.NotifyUser4.UserBase.Email != null)
                            userEmails += (userEmails != "" ? "," : "") + s.NotifyUser4.UserBase.Email;
                        if (userEmails != "")
                        {
                            s.SendMessage("StoreItemExpiryReminder", userEmails, "");
                        }
                    }
                    using (Connection c = new Connection())
                    {
                        /// Clears the equipment expiring list tied to store.
                        s.StoreBinsWithEquipmentExpiring.Clear();
                        s.Save();
                        c.Commit();
                    }
                }
            }
        }
    }

}
