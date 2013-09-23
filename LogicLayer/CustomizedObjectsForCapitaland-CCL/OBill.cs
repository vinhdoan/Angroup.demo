//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TBill : LogicLayerSchema<OBill>
    {
        public SchemaString InstanceID;

    }


    /// <summary>
    /// Represents the Bill for an OPC point obtained
    /// from the server, entered by a user through the work
    /// module, or entered by the user through the Point module.
    /// </summary>
    public abstract partial class OBill : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {
        public abstract String InstanceID { get; set; }

        public static void CreateBill(OWork work, int? batchID, int? batchNo)
        {
            using (Connection c = new Connection())
            {
                OBill bill = TablesLogic.tBill.Create();
                bill.BatchID = batchID;
                bill.BatchNo = batchNo;

                OLocation currentLocation = work.Location;
                while (currentLocation != null)
                {
                    if (currentLocation.AmosAssetID != null)
                        break;
                    currentLocation = currentLocation.Parent;
                }
                if (currentLocation != null)
                    bill.AssetID = currentLocation.AmosAssetID;
                bill.LeaseID = 0;
                
               
                if (work.TenantLeaseID != null)
                {
                    bill.DebtorID = work.TenantLease.Tenant.AmosOrgID;
                    bill.LeaseID = (work.TenantLease.AmosLeaseID == null ? 0 : work.TenantLease.AmosLeaseID);
                }
                 if (work.TenantContact != null)
                {
                    bill.ContactID = work.TenantContact.AmosContactID;
                    bill.AddressID = work.TenantContact.AmosBillAddressID;
                }
                bill.SuiteID = (work.Location.AmosSuiteID == null ? 0 : work.Location.AmosSuiteID); 
               
                bill.LocationID = work.LocationID;
                bill.ChargeFrom = work.ScheduledStartDateTime.Value;
                bill.ChargeTo = work.ScheduledEndDateTime.Value;

                bill.updatedOn = DateTime.Today;
                bill.Save();
                foreach(OWorkCost workcost in work.WorkCost)
                {
                    OBillItem item = OBillItem.CreateBillItem(bill, workcost);
                    bill.BillItem.Add(item);
                }
                bill.Save();
                work.BillToAMOSStatus = 1;
                work.LastestBillID = bill.ObjectID;
                work.Save();
                c.Commit();
            }     
        }

        public static void AddBillItem(Guid? BillID,OWork work)
        {
            using (Connection c = new Connection())
            {
                OBill bill = TablesLogic.tBill.Load(BillID);
                 foreach(OWorkCost workcost in work.WorkCost)
                {
                    OBillItem item = OBillItem.CreateBillItem(bill, workcost);
                    bill.BillItem.Add(item);
                }
                bill.Save();
                work.BillToAMOSStatus = 1;
                work.LastestBillID = bill.ObjectID;
                work.Save();
                c.Commit();
            }
        }

       
        
    }
}

