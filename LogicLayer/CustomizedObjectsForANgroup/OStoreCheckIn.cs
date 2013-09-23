//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TStoreCheckIn : LogicLayerSchema<OStoreCheckIn>
    {
        public SchemaGuid StoreCheckOutID;

        public SchemaGuid WorkID;

        public TStoreCheckOut StoreCheckOut { get { return OneToOne<TStoreCheckOut>("StoreCheckOutID"); } }

        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }
    }

    public abstract partial class OStoreCheckIn : LogicLayerPersistentObject
    {
        public abstract Guid? StoreCheckOutID { get; set; }

        public abstract Guid? WorkID { get; set; }

        public abstract OStoreCheckOut StoreCheckOut { get; set; }

        public abstract OWork Work { get; set; }

        // Returns a List of StoreCheckOut
        // Where IsMovedToAnotherStore == 1
        // MoveToStoreID = this.StoreID
        // Checkouts linked to checkin that is deleted == 0
        // Workflow Status <> Cancelled
        public static List<OStoreCheckOut> GetStoreCheckOut(Guid StoreID)
        {
            List<OStoreCheckOut> list = TablesLogic.tStoreCheckOut[
                TablesLogic.tStoreCheckOut.IsMovedToAnotherStore == 1 &
                TablesLogic.tStoreCheckOut.MoveToStoreID == StoreID &
                TablesLogic.tStoreCheckOut.CurrentActivity.ObjectName != "Draft" &
                TablesLogic.tStoreCheckOut.CurrentActivity.ObjectName != "PendingApproval"
                //&
                //TablesLogic.tStoreCheckOut.MoveToStore.CurrentActivity.ObjectName != "Cancelled"
                ];
            for (int i = 0; i < list.Count; i++)
            {
                OStoreCheckIn s = TablesLogic.tStoreCheckIn.Load(
                            TablesLogic.tStoreCheckIn.StoreCheckOutID == list[i].ObjectID);
                if (s != null)
                    list.RemoveAt(i);
            }
            return list;
        }

        /// <summary>
        /// Updates the work cost.
        /// </summary>
        public void UpdateWorkCost()
        {
            using (Connection c = new Connection())
            {
                foreach (OStoreCheckInItem item in this.CheckInItems)
                {
                    if (item.FromWorkCostID != null)
                    {
                        OWorkCost wc = item.FromWorkCost;
                        wc.ActualQuantityPrevious = wc.ActualQuantity;
                        wc.ActualQuantity = wc.ActualQuantity - item.Quantity;
                        //wc.ActualUnitCost = item.EstimatedUnitCost;
                        wc.Save();
                    }
                }
                c.Commit();
            }
        }

        /// <summary>
        /// Cancel the check-in and saves to the database.
        /// The cancellation can take place only if there are
        /// no other transactions on the store bin items other
        /// than the one that was created by the check in.
        /// </summary>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                if (IsCommitted == 1)
                {
                    foreach (OStoreCheckInItem item in CheckInItems)
                    {
                        foreach (OStoreItemTransaction storeItemTransaction in
                            OStoreItemTransaction.GetTransactionsAssociatedWithSourceObject(item))
                            storeItemTransaction.ReverseTransaction();

                        //Increase the amount back in WO also
                        OWorkCost wc = item.FromWorkCost;
                        if (wc != null)
                        {
                            wc.ActualQuantity = wc.ActualQuantity + item.Quantity;
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

        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                DataSet dsTemp = null;
                DataSet ds = new DataSet();
                ds.DataSetName = "StoreCheckIn";

                DataTable dtStoreCheckIn = TablesLogic.tStoreCheckIn.Select(
                    TablesLogic.tStoreCheckIn.ObjectNumber.As("StoreCheckInNumber"),
                    TablesLogic.tStoreCheckIn.CreatedUser,
                    TablesLogic.tStoreCheckIn.CreatedDateTime,
                    TablesLogic.tStoreCheckIn.ModifiedUser,
                    TablesLogic.tStoreCheckIn.Store.ObjectName.As("Store"),
                    TablesLogic.tStoreCheckIn.Work.ObjectNumber.As("WONumber")
                    ).Where(
                    TablesLogic.tStoreCheckIn.ObjectID == this.ObjectID
                    & TablesLogic.tStoreCheckIn.IsDeleted == 0
                    );

                dtStoreCheckIn.TableName = "StoreCheckIn";
                dsTemp = dtStoreCheckIn.DataSet;
                dsTemp.Tables.Remove(dtStoreCheckIn);
                ds.Tables.Add(dtStoreCheckIn);

                DataTable dtItems = TablesLogic.tStoreCheckIn.Select(
                    TablesLogic.tStoreCheckIn.CheckInItems.Catalogue.ObjectName.As("Description"),
                    TablesLogic.tStoreCheckIn.CheckInItems.StoreBin.ObjectName.As("StoreBin"),
                    TablesLogic.tStoreCheckIn.CheckInItems.Catalogue.UnitOfMeasure.ObjectName.As("UOM"),
                    TablesLogic.tStoreCheckIn.CheckInItems.Quantity
                    ).Where(
                    TablesLogic.tStoreCheckIn.ObjectID == this.ObjectID
                    & TablesLogic.tStoreCheckIn.CheckInItems.IsDeleted == 0
                    )
                    .OrderBy(
                    TablesLogic.tStoreCheckIn.CheckInItems.Catalogue.ObjectName.Asc,
                    TablesLogic.tStoreCheckIn.CheckInItems.Quantity.Asc
                   );

                dtItems.TableName = "StoreCheckInItems";
                dsTemp = dtItems.DataSet;
                dsTemp.Tables.Remove(dtItems);
                ds.Tables.Add(dtItems);

                return ds;
            }
        }
    }
}