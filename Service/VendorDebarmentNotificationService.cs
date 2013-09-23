//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Anacle.DataFramework;
using LogicLayer;

namespace Service
{
    /// <summary>
    /// Checks all contracts and sends out notifications as the
    /// contract's end date approaches.
    /// </summary>
    public class VendorDebarmentNotificationService : AnacleServiceBase
    {
        public override void OnExecute()
        {
            // Gets a list of all expiring contracts due
            // for reminder.
            //
            TVendor v = TablesLogic.tVendor;
            List<OVendor> vendors =
                v.LoadList(
                (v.DebarmentNotification1Days != null & (v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification1Days) >= v.LastNotificationDate | v.LastNotificationDate == null) & v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification1Days) <= DateTime.Now) |
                (v.DebarmentNotification2Days != null & (v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification2Days) >= v.LastNotificationDate | v.LastNotificationDate == null) & v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification2Days) <= DateTime.Now) |
                (v.DebarmentNotification3Days != null & (v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification3Days) >= v.LastNotificationDate | v.LastNotificationDate == null) & v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification3Days) <= DateTime.Now) |
                (v.DebarmentNotification4Days != null & (v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification4Days) >= v.LastNotificationDate | v.LastNotificationDate == null) & v.DebarmentEndDate.AddDays(0 - v.DebarmentNotification4Days) <= DateTime.Now)
                );

            // For each expiring contract, send a reminder
            // based on a template set up in the user interface.
            //
            foreach (OVendor vendor in vendors)
            {
                using (Connection c = new Connection())
                {
                    string cellphone = "";
                    string email = "";

                    if (vendor.NotifyUser1 != null)
                    {
                        cellphone += vendor.NotifyUser1.UserBase.Cellphone + ";";
                        email += vendor.NotifyUser1.UserBase.Email + ";";
                    }
                    if (vendor.NotifyUser2 != null)
                    {
                        cellphone += vendor.NotifyUser2.UserBase.Cellphone + ";";
                        email += vendor.NotifyUser2.UserBase.Email + ";";
                    }
                    if (vendor.NotifyUser3 != null)
                    {
                        cellphone += vendor.NotifyUser3.UserBase.Cellphone + ";";
                        email += vendor.NotifyUser3.UserBase.Email + ";";
                    }
                    if (vendor.NotifyUser4 != null)
                    {
                        cellphone += vendor.NotifyUser4.UserBase.Cellphone + ";";
                        email += vendor.NotifyUser4.UserBase.Email + ";";
                    }

                    vendor.SendMessage("Vendor_Debarment", email, cellphone);
                    vendor.LastNotificationDate = DateTime.Now;

                    vendor.Save();
                    c.Commit();
                }
            }

        }
    }
}
