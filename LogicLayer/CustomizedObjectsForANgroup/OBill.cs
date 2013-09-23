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
    [Database("#database"), Map("Bill")]
    public partial class TBill : LogicLayerSchema<OBill>
    {
        public SchemaInt BatchID;
        public SchemaInt BatchNo;
        public SchemaInt AssetID;
        public SchemaInt DebtorID;
        public SchemaInt LeaseID;
        public SchemaInt SuiteID;
        public SchemaInt ContactID;
        public SchemaInt AddressID;
        public SchemaGuid LocationID;
        public SchemaDateTime ChargeFrom;
        public SchemaDateTime ChargeTo;
        public SchemaDateTime updatedOn;
        [Default(0)]
        public SchemaInt Status;

        public TBillItem BillItem { get { return OneToMany<TBillItem>("BillID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }

    }


    /// <summary>
    /// Represents the Bill for an OPC point obtained
    /// from the server, entered by a user through the work
    /// module, or entered by the user through the Point module.
    /// </summary>
    public abstract partial class OBill : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {
        public abstract int? BatchID { get; set; }
        public abstract int? BatchNo { get; set; }
        public abstract int? AssetID { get; set; }
        public abstract int? DebtorID { get; set; }
        public abstract int? LeaseID { get; set; }
        public abstract int? SuiteID { get; set; }
        public abstract int? ContactID { get; set; }
        public abstract int? AddressID { get; set; }
        public abstract Guid? LocationID { get; set; }
        public abstract DateTime? ChargeFrom { get; set; }
        public abstract DateTime? ChargeTo { get; set; }
        public abstract DateTime? updatedOn { get; set; }
        public abstract int? Status { get; set; }

        public abstract DataList<OBillItem> BillItem { get; set; }
        public abstract OLocation Location { get; set; }

        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> taskLocations = new List<OLocation>();
                if (this.Location != null)
                    taskLocations.Add(this.Location);
                return taskLocations;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public String BillStatus
        {
            get
            {
                String status = this.Status == (int)EnumApplicationGeneral.Yes ? Resources.Strings.General_Yes : Resources.Strings.General_No;
                return status;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public static int? GenerateNextBatchID()
        {
            String batchNum = GenerateNextBatchNumber().ToString();

            String strMonth = DateTime.Today.Month.ToString();
            if (strMonth.Length == 1)
                strMonth = "0" + strMonth;
            if (batchNum.Length == 1)
                batchNum = "0" + batchNum;

            String BatchID = DateTime.Today.Day.ToString() + strMonth + DateTime.Today.Year.ToString().Substring(2, 2);

            BatchID = BatchID + batchNum;
            return Convert.ToInt32(BatchID);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public static int? GenerateNextBatchNumber()
        {
            int? batchNum = TablesLogic.tBill.SelectDistinct(TablesLogic.tBill.BatchNo.Max()).Where(
                TablesLogic.tBill.updatedOn.Date() == DateTime.Today.Date);

            if (batchNum == null)
                batchNum = 50;             // Start from this high number so that it does not clash with the IREES system.

            return batchNum + 1;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="reading"></param>
        /// <param name="batchID"></param>
        /// <param name="batchNo"></param>
        public static void CreateBill(OReading reading, int? batchID, int? batchNo)
        {
            using (Connection c = new Connection())
            {
                OBill bill = TablesLogic.tBill.Create();
                bill.BatchID = batchID;
                bill.BatchNo = batchNo;

                OLocation currentLocation = reading.Point.Location;
                while (currentLocation != null)
                {
                    if (currentLocation.AmosAssetID != null)
                        break;
                    currentLocation = currentLocation.Parent;
                }
                if (currentLocation != null)
                {
                    bill.AssetID = currentLocation.AmosAssetID;
                    bill.InstanceID = currentLocation.AMOSInstanceID;
                }
                bill.LeaseID = 0;

                if (reading.Point.TenantID != null)
                    bill.DebtorID = reading.Point.Tenant.AmosOrgID;
                else if (reading.Point.TenantLeaseID != null)
                {
                    bill.DebtorID = reading.Point.TenantLease.Tenant.AmosOrgID;
                    bill.LeaseID = (reading.Point.TenantLease.AmosLeaseID == null ? 0 : reading.Point.TenantLease.AmosLeaseID);
                }
                bill.SuiteID = (reading.Point.Location.AmosSuiteID == null ? 0 : reading.Point.Location.AmosSuiteID);
                if (reading.Point.TenantContact != null)
                {
                    bill.ContactID = reading.Point.TenantContact.AmosContactID;
                    bill.AddressID = reading.Point.TenantContact.AmosBillAddressID;
                }
                bill.LocationID = reading.Point.LocationID;
                bill.ChargeFrom = new DateTime(reading.DateOfReading.Value.Year, reading.DateOfReading.Value.Month, 1);
                bill.ChargeTo = new DateTime(reading.DateOfReading.Value.Year, reading.DateOfReading.Value.Month, 1).AddMonths(1).AddDays(-1);
                bill.updatedOn = DateTime.Today;
                bill.Save();
                OBillItem item = OBillItem.CreateBillItem(bill, reading);
                bill.BillItem.Add(item);
                bill.Save();
                reading.BillToAMOSStatus = (int)EnumBillToAMOSStatus.PendingPosting;
                reading.LastestBillID = bill.ObjectID;
                reading.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="BillID"></param>
        /// <param name="reading"></param>
        public static void AddBillItem(Guid? BillID, OReading reading)
        {
            using (Connection c = new Connection())
            {
                OBill bill = TablesLogic.tBill.Load(BillID);
                OBillItem item = OBillItem.CreateBillItem(bill, reading);

                bill.BillItem.Add(item);
                bill.Save();
                reading.BillToAMOSStatus = (int)EnumBillToAMOSStatus.PendingPosting;
                reading.LastestBillID = bill.ObjectID;
                reading.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public decimal? TotalBillCharge()
        {
            decimal? total = 0m;
            foreach (OBillItem item in this.BillItem)
            {
                total += item.ChargeAmount;
            }
            return total;
        }

    }

    /// <summary>
    /// 
    /// </summary>
    public enum EnumBillStatus
    {
        NotPosted = 0,
        PostedToAMOS = 1,
        PostedToAMOSWithStatus = 2
    }
}

