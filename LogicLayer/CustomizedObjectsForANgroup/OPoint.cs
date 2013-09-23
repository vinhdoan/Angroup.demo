//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPoint : LogicLayerSchema<OPoint>
    {
        public SchemaInt BillingType;
        public SchemaGuid ChargeTypeID;
        public SchemaGuid TenantLeaseID;
        public SchemaGuid TenantID;
        public SchemaInt ReadingDay;
        public SchemaGuid ReminderUser1ID;
        public SchemaGuid ReminderUser2ID;
        public SchemaGuid ReminderUser3ID;
        public SchemaGuid ReminderUser4ID;
        public SchemaDecimal LastReading;
        public SchemaDecimal Tariff;
        public SchemaDecimal Discount;
        [Default(0)]
        public SchemaInt IsActive;
        public SchemaGuid TenantContactID;
        public SchemaGuid TypeOfMeterID;
        public SchemaDateTime LastReminderDate;
        public SchemaInt IsLock;
        public SchemaString BMSCode;
        public SchemaGuid meterID;


        public TChargeType ChargeType { get { return OneToOne<TChargeType>("ChargeTypeID"); } }
        public TCode TypeOfMeter { get { return OneToOne<TCode>("TypeOfMeterID"); } }
        public TTenantLease TenantLease { get { return OneToOne<TTenantLease>("TenantLeaseID"); } }
        public TTenantContact TenantContact { get { return OneToOne<TTenantContact>("TenantContactID"); } }
        public TUser Tenant { get { return OneToOne<TUser>("TenantID"); } }
        public TUser ReminderUser1 { get { return OneToOne<TUser>("ReminderUser1ID"); } }
        public TUser ReminderUser2 { get { return OneToOne<TUser>("ReminderUser2ID"); } }
        public TUser ReminderUser3 { get { return OneToOne<TUser>("ReminderUser3ID"); } }
        public TUser ReminderUser4 { get { return OneToOne<TUser>("ReminderUser4ID"); } }
    
    }


    /// <summary>
    /// Represents a condition-monitored point in which the 
    /// readings from any source can be tested against acceptable
    /// limits set up against this point. When the reading exceeds
    /// the acceptable limits, this can be set up to generate
    /// a Work object.
    /// <para></para>
    /// This point can also be associated with an OPC DA server,
    /// so that the OPC service can retrieve readings automatically
    /// from the OPC server.
    /// </summary>
    public abstract partial class OPoint : LogicLayerPersistentObject
    {
        public abstract int? BillingType { get; set; }
        public abstract Guid? ChargeTypeID { get; set; }
        public abstract Guid? TenantLeaseID { get; set; }
        public abstract Guid? TenantID { get; set; }
        public abstract int? ReadingDay { get; set; }
        public abstract Guid? ReminderUser1ID { get; set; }
        public abstract Guid? ReminderUser2ID { get; set; }
        public abstract Guid? ReminderUser3ID { get; set; }
        public abstract Guid? ReminderUser4ID { get; set; }
        public abstract Decimal? LastReading { get; set; }
        public abstract Decimal? Tariff { get; set; }
        public abstract Decimal? Discount { get; set; }
        public abstract int? IsActive { get; set; }
        public abstract Guid? TenantContactID { get; set; }
        public abstract Guid? TypeOfMeterID { get; set; }
        public abstract DateTime? LastReminderDate { get; set; }
        public abstract int? IsLock { get; set; }
        public abstract String BMSCode { get; set; }
        public abstract Guid? meterID { get; set; }

        public abstract OChargeType ChargeType { get; set; }
        public abstract OCode TypeOfMeter { get; set; }
        public abstract OTenantLease TenantLease { get; set; }
        public abstract OTenantContact TenantContact { get; set; }
        public abstract OUser Tenant { get; set; }
        public abstract OUser ReminderUser1 { get; set; }
        public abstract OUser ReminderUser2 { get; set; }
        public abstract OUser ReminderUser3 { get; set; }
        public abstract OUser ReminderUser4 { get; set; }

        public String TenantName
        {
            get
            {
                String tenantName = "";
                if (this.Tenant != null)
                    tenantName = this.Tenant.ObjectName;
                else if (this.TenantLease != null)
                {
                    if (this.TenantLease.Tenant != null)
                        tenantName = this.TenantLease.Tenant.ObjectName;
                }
                return tenantName;
            }
        }

        public String IsActiveText
        {
            get
            {
                if (this.IsActive == 1)
                    return Resources.Strings.General_Yes;
                else if (this.IsActive == 0)
                    return Resources.Strings.General_No;
                return "";
            }
        }

        public String IsLockText
        {
            get
            {
                if (this.IsLock == 1)
                    return Resources.Strings.General_Yes;
                else if (this.IsLock == 0)
                    return Resources.Strings.General_No;
                return "";
            }
        }

        public bool IsReadingWithTenantExist(Guid? readingId, DateTime? DateOfReading)
        {
            if (DateOfReading!=null && (this.Tenant != null || this.TenantLease != null))
            {
                OReading reading = TablesLogic.tReading.Load(
                    TablesLogic.tReading.ObjectID != readingId &
                    TablesLogic.tReading.PointID == this.ObjectID &
                    TablesLogic.tReading.DateOfReading.Month() == DateOfReading.Value.Month &
                    TablesLogic.tReading.DateOfReading.Year() == DateOfReading.Value.Year);
                if (reading != null)
                    return true;
            }
            return false;
        }
        public bool IsReadingWithTenantExist(DateTime? DateOfReading, Guid? workID)
        {
            if (DateOfReading != null && (this.Tenant != null || this.TenantLease != null))
            {
                OReading reading = TablesLogic.tReading.Load(TablesLogic.tReading.PointID == this.ObjectID &
                    TablesLogic.tReading.WorkID != workID &
                    TablesLogic.tReading.DateOfReading.Month() == DateOfReading.Value.Month &
                    TablesLogic.tReading.DateOfReading.Year() == DateOfReading.Value.Year);
                if (reading != null)
                    return true;
            }
            return false;
        }
        public bool IsReadingBackDate(Guid? readingId, DateTime? DateOfReading)
        {
            List<OReading> readingList = TablesLogic.tReading.LoadList(
                TablesLogic.tReading.ObjectID != readingId &
                TablesLogic.tReading.PointID == this.ObjectID,
                TablesLogic.tReading.DateOfReading.Desc);
            if (readingList.Count > 0)
            {
                OReading lastReading = readingList[0];
                if (lastReading.DateOfReading != null)
                {
                    if (lastReading.DateOfReading > DateOfReading)
                        return true;
                }
            }
            return false;
        }


        public decimal? ComputeRate()
        {
            if(this.Factor!=null && this.Discount!=null)
            {
                if (this.Discount > 0)
                    return Math.Round((this.Tariff.Value * (100 - this.Discount.Value) / 100), 4, MidpointRounding.AwayFromZero);
            }
            return 0;
        }


        /// <summary>
        /// Gets the maximum value to deduct
        /// from the previous reading when there's
        /// a roll-over.
        /// </summary>
        /// <returns></returns>
        public decimal GetMaximumValueToDeduct(decimal lastReading)
        {
            // Gets the string representation
            // of the maximum number, excluding
            // the decimal places. (Assuming that
            // the maximum reading only has '9'
            // as all its digits.
            //
            string s = "";
            if (this.MaximumReading != null)
                s = this.MaximumReading.Value.ToString("0");
            else
                s = lastReading.ToString("0");

            // Convert this a value "1xxxxx" where
            // xxxxx is a string of zeros, the length
            // being the number of non-decimal digits of
            // the maximum reading.
            //
            string v = "1";
            for (int i = 0; i < s.Length; i++)
                v = v + "0";
            return Convert.ToDecimal(v);
        }


        /// <summary>
        /// Update the default tariff and discount from the Point Tariff
        /// table.
        /// </summary>
        public void UpdateDefaultTariffAndDiscount()
        {
            if (this.Location == null || this.IsLock == 1)
                return;

            OPointTariff pointTariff = TablesLogic.tPointTariff.Load(
                this.Location.HierarchyPath.Like("%" + TablesLogic.tPointTariff.Location.HierarchyPath + "%"));

            if (pointTariff != null)
            {
                this.Tariff = pointTariff.DefaultTariff;
                this.Discount = pointTariff.DefaultDiscount;
            }
            else
            {
                this.Tariff = null;
                this.Discount = null;
            }
        }


        /// <summary>
        /// Returns a flag to indicate if readings have been taken for this point.
        /// </summary>
        /// <returns></returns>
        public bool HasReadings()
        {
            TReading r = TablesLogic.tReading;
            if((int)r.Select(r.ObjectID.Count()).Where(
                r.PointID == this.ObjectID &
                r.IsDeleted == 0) > 0)
                return true;
            return false;
        }
        //public List<string> GetMetersAndBarcodes(Guid? pLocationID)
        //{
        //    List<string> metersAndBarcodes = new List<string>();
        //    DataTable dt = TablesLogic.tMeter.Select(
        //        TablesLogic.tMeter.ObjectName, TablesLogic.tMeter.Barcode).Where(
        //        TablesLogic.tMeter.LocationID == pLocationID &
        //        TablesLogic.tMeter.IsDeleted == 0);
        //    for (int i=0;i<dt.Rows.Count;i++)
        //    {
        //        metersAndBarcodes.Add(dt.Rows[i][0].ToString() + "(" + dt.Rows[i][1].ToString() + ")");
        //    }
        //    return metersAndBarcodes;
        //}
        public List<OMeter> GetMeters(Guid? pLocationID)
        {
            List<OMeter> meters = new List<OMeter>();
            OLocation lo = TablesLogic.tLocation.Load(pLocationID);
            List<Guid?> locationIDs = new List<Guid?>();
            if (lo != null)
            {
                // 1
                 meters = TablesLogic.tMeter.LoadList(
                      lo.HierarchyPath.Like(TablesLogic.tMeter.Location.HierarchyPath + "%"));

                // 2
                //DataTable dt = TablesLogic.tLocation.Select(
                //    TablesLogic.tLocation.ObjectID,
                //    TablesLogic.tLocation.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.Parent.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID,
                //    TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectID)
                // .Where(
                //     TablesLogic.tLocation.ObjectID = pLocationID);

                //foreach (DataRow dr in dt.Rows)
                //{
                //    foreach (object id in dr.ItemArray)
                //        if (id != DBNull.Value)
                //            locationIDs.Add(id);
                //}

                //List<OMeter> meters = TablesLogic.tMeter.Location.LoadList(
                //      TablesLogic.tMeter.LocationID.In(locationIDs));
            }
            return meters;
        }
        public OMeter GetMeter(Guid? meterID)
        {
            OMeter meter = TablesLogic.tMeter.Load(
                TablesLogic.tMeter.ObjectID == meterID&
                 TablesLogic.tMeter.IsDeleted == 0);
            return meter;
        }

    }
}


