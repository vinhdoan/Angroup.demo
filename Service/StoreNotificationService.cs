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
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;

namespace Service
{
    partial class StoreNotificationService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            List<OStore> stores = TablesLogic.tStore.LoadList(TablesLogic.tStore.StoreType == StoreType.Storeroom);

            foreach (OStore store in stores)
            {
                if (store.DetermineLowInventoryItems())
                {
                    store.SendMessage("Store_LowInventory",
                        store.NotifyUser1, store.NotifyUser2, store.NotifyUser3, store.NotifyUser4);
                }
            }
        }  
    }
}
