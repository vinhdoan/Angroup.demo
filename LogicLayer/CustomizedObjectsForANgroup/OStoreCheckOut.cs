//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TStoreCheckOut : LogicLayerSchema<OStoreCheckOut>
    {
        [Default(0)]
        public SchemaInt IsMovedToAnotherStore;
        public SchemaGuid MoveToStoreID;
        [Default(0)]
        public SchemaInt IsNotified;

        public TStore MoveToStore { get { return OneToOne<TStore>("MoveToStoreID"); } }
    }

    public abstract partial class OStoreCheckOut : LogicLayerPersistentObject
    {
        public abstract int? IsMovedToAnotherStore { get; set; }

        public abstract Guid? MoveToStoreID { get; set; }

        public abstract int? IsNotified { get; set; }

        public abstract OStore MoveToStore { get; set; }

        public string ObjectNumberAndDescription
        {
            get
            {
                return ObjectNumber + ", " + Description;
            }
        }

        public void NotifyCheckIn()
        {
            if (IsNotified == 0)
            {
                if (this.IsMovedToAnotherStore.Value == 1 && this.MoveToStore != null)
                {
                    //creat new check in work
                    using (Connection c = new Connection())
                    {
                        OStoreCheckIn checkIn = TablesLogic.tStoreCheckIn.Create();
                        checkIn.StoreID = this.MoveToStoreID;
                        checkIn.Description = this.Description;
                        checkIn.StoreCheckOutID = this.ObjectID;
                        checkIn.Save();

                        checkIn.TriggerWorkflowEvent("SaveAsDraft");
                        //checkIn.StoreCheckOutID = this.ObjectID;
                        //checkIn.StoreCheckOut.Store = this.Store;
                        checkIn.Save();
                        c.Commit();
                    }
                    //email the check in side user
                    string email = "";
                    /*
                    if (store.NotifyUser1 != null)
                    {
                        email += store.NotifyUser1.UserBase.Email + ";";
                    }
                    if (store.NotifyUser2 != null)
                    {
                        email += store.NotifyUser2.UserBase.Email + ";";
                    } if (store.NotifyUser3 != null)
                    {
                        email += store.NotifyUser3.UserBase.Email + ";";
                    } if (store.NotifyUser4 != null)
                    {
                        email += store.NotifyUser4.UserBase.Email + ";";
                    }
                     * */
                    List<OUser> users = OUser.GetUsersByRoleAndAboveLocation(this.MoveToStore.Location, "INVENTORYADMIN");
                    foreach (OUser user in users)
                        if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "")
                            email += user.UserBase.Email + ";";

                    this.SendMessage("StoreCheckOut_NotifyCheckIn", email, "");
                }

                IsNotified = 1;
            }
        }

        //public List<OUser> GetCreator()
        //{
        //    List<OUser> lst = new List<OUser>();
        //    lst.Add(this.User);
        //    return lst;
        //}

        public List<OUser> GetCreator()
        {
            return TablesLogic.tUser.LoadList(TablesLogic.tUser.ObjectID == this.CreatedUserID);
        }

        public void UpdateWorkCost()
        {
            if (this.DestinationType == 2)
            {
                using (Connection c = new Connection())
                {
                    foreach (OStoreCheckOutItem item in this.StoreCheckOutItems)
                    {
                        OWorkCost wc = item.FromWorkCost;
                        wc.ActualQuantity = wc.ActualQuantity == null ?
                            item.ActualQuantity : wc.ActualQuantity + item.ActualQuantity;
                        wc.ActualUnitCost = item.EstimatedUnitCost;
                        wc.ActualCostTotal = wc.ActualQuantity * wc.ActualUnitCost;
                        wc.Save();
                    }
                    c.Commit();
                }
            }
        }

        /// <summary>
        /// Cancel the check-out and saves to the database.
        /// </summary>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                if (IsCommitted == 1)
                {
                    foreach (OStoreCheckOutItem item in StoreCheckOutItems)
                    {
                        foreach (OStoreItemTransaction storeItemTransaction in
                            OStoreItemTransaction.GetTransactionsAssociatedWithSourceObject(item))
                            storeItemTransaction.ReverseTransaction();

                        //Return the amount back in WO also
                        OWorkCost wc = item.FromWorkCost;
                        if (wc != null)
                        {
                            wc.ActualQuantity = wc.ActualQuantity - item.ActualQuantity;
                            wc.ActualCostTotal = wc.ActualQuantity * wc.ActualUnitCost;
                            wc.Save();
                        }
                    }
                    IsCommitted = 0;
                    this.Save();
                }
                c.Commit();
            }
        }
    }
}