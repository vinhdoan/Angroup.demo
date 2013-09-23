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
    public partial class TReading : LogicLayerSchema<OReading>
    {
        public SchemaDecimal Consumption;
        public SchemaDecimal Factor;
        public SchemaDecimal Tariff;
        public SchemaDecimal Discount;
        [Default(0)]
        public SchemaInt BillToAMOSStatus;
        public SchemaGuid LastestBillID;
        [Size(255)]
        public SchemaString AMOSErrorMessage;
    }


    /// <summary>
    /// Represents the reading for an OPC point obtained
    /// from the server, entered by a user through the work
    /// module, or entered by the user through the Point module.
    /// </summary>
    public abstract partial class OReading : LogicLayerPersistentObject
    {
        public abstract Decimal? Consumption { get; set; }
        public abstract Decimal? Factor { get; set; }
        public abstract Decimal? Tariff { get; set; }
        public abstract Decimal? Discount { get; set; }
        public abstract int? BillToAMOSStatus { get; set; }
        public abstract Guid? LastestBillID { get; set; }
        public abstract string AMOSErrorMessage { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public String BillToAMOSStatusText
        {
            get
            {
                return TranslateBillToAMOSStatus(this.BillToAMOSStatus);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="status"></param>
        /// <returns></returns>
        public static String TranslateBillToAMOSStatus(int? status)
        {
            if (status == (int)EnumBillToAMOSStatus.NotPostedToAMOS)
                return Resources.Strings.BillToAMOSStatusText_NotPostedToAmos;
            else if (status == (int)EnumBillToAMOSStatus.PendingPosting)
                return Resources.Strings.BillToAMOSStatusText_PendingPosting;
            else if (status == (int)EnumBillToAMOSStatus.PostedToAMOS)
                return Resources.Strings.BillToAMOSStatusText_PostedToAmos;
            else if (status == (int)EnumBillToAMOSStatus.PostedToAMOSFailed)
                return Resources.Strings.BillToAMOSStatusText_PostedToAmosFailed;
            else if (status == (int)EnumBillToAMOSStatus.PostedToAMOSSuccessful)
                return Resources.Strings.BillToAMOSStatusText_PostedToAmosSuccessful;
            else if (status == (int)EnumBillToAMOSStatus.UnableToPostDueToError)
                return Resources.Strings.BillToAMOSStatusText_UnableToPostDueToError;
            else if (status == (int)EnumBillToAMOSStatus.NotPostedDueToCancelled)
                return Resources.Strings.BillToAMOSStatusText_NotPostedCancelled;
            else
                return "";
        }

        /// <summary>
        /// 
        /// </summary>
        public Decimal? BillAmount
        {
            get
            {
                return this.Consumption * this.Factor * Math.Round(this.Tariff.Value * (100 - this.Discount.Value) / 100, 4, MidpointRounding.AwayFromZero);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public override void Saving()
        {
            using (Connection c = new Connection())
            {
                OPoint point = TablesLogic.tPoint.Load(this.PointID);
                if (point != null)
                {
                    this.Consumption = this.GetConsumption();
                    if (this.Factor == null)
                        this.Factor = point.Factor;
                    if (this.Tariff == null)
                        this.Tariff = point.Tariff;
                    if (this.Discount == null)
                        this.Discount = point.Discount;

                    if (point.TenantLease != null)
                    {
                        if (point.TenantLease.LeaseStatus == EnumLeaseStatus.New ||
                            (point.TenantLease.LeaseStatus == EnumLeaseStatus.Renewal && point.TenantLease.LeaseEndDate > DateTime.Today))
                        {
                            // do nothing.
                        }
                        else
                        {
                            // otherwise disable the point.
                            //
                            //point.IsActive = 0;
                            //point.Save();

                            //because of amos' logic changed,we move this disable
                            //point part to service mode.
                            //so,here is do nothing either.
                        }
                    }
                }
                this.Save();
                c.Commit();
            }
            base.Saving();
        }


        public decimal? GetConsumption()
        {
            return GetConsumption(this.PointID, this.DateOfReading, this.Reading);
            /*
            decimal? consumption = 0m;

            OPoint point = TablesLogic.tPoint.Load(this.PointID);

            OReading reading = TablesLogic.tReading.Load(TablesLogic.tReading.PointID == this.PointID &
                    TablesLogic.tReading.DateOfReading.Month() == (this.DateOfReading.Value.Month - 1) &
                    TablesLogic.tReading.DateOfReading.Year() == this.DateOfReading.Value.Year);

            if (reading != null && this.Consumption == null)
            {
                if (this.Reading >= reading.Reading)
                    consumption = this.Reading - reading.Reading;
                else
                    consumption = point.MaximumReading - reading.Reading + this.Reading;
            }
            else
            {
                if (this.Reading >= point.LastReading)
                    consumption = this.Reading - point.LastReading;
                else
                    consumption = point.MaximumReading - point.LastReading + this.Reading;
            }
            return consumption;*/
        }


        /// <summary>
        /// Gets the consumption by deducting the latest reading
        /// from the previous reading.
        /// </summary>
        /// <param name="pointId"></param>
        /// <param name="currentReading"></param>
        /// <returns></returns>
        public static decimal? GetConsumption(Guid? pointId, DateTime? currentReadingDate, decimal? currentReading)
        {
            decimal? consumption = 0m;

            OPoint point = TablesLogic.tPoint.Load(pointId);

            OReading reading = TablesLogic.tReading.Load(
                TablesLogic.tReading.PointID == pointId &
                TablesLogic.tReading.DateOfReading < currentReadingDate,
                TablesLogic.tReading.DateOfReading.Desc);

            if (reading != null)
            {
                if (currentReading >= reading.Reading)
                    consumption = currentReading - reading.Reading;
                else
                    consumption = point.GetMaximumValueToDeduct(point.LastReading.Value) + currentReading - reading.Reading;
            }
            else
            {
                if (currentReading >= point.LastReading)
                    consumption = currentReading - point.LastReading;
                else
                    consumption = point.GetMaximumValueToDeduct(point.LastReading.Value) + currentReading - point.LastReading;
            }
            return consumption;
        }


        /// <summary>
        /// Checks if the current reading causes the consumption exceed by 1.5
        /// times the previous consumption.
        /// </summary>
        /// <returns></returns>
        public bool DoesReadingExceedPreviousConsumptionBy1Point5Times()
        {
            return DoesReadingExceedPreviousConsumptionBy1Point5Times(this.Point, this.DateOfReading, this.Reading);
        }


        /// <summary>
        /// Checks if the current reading causes the consumption exceed by 1.5
        /// times the previous consumption.
        /// </summary>
        /// <returns></returns>
        public static bool DoesReadingExceedPreviousConsumptionBy1Point5Times(OPoint point, DateTime? currentReadingDate, decimal? currentReading)
        {
            if (point != null && currentReading != null && currentReadingDate != null)
            {
                OReading reading = TablesLogic.tReading.Load(
                    TablesLogic.tReading.PointID == point.ObjectID &
                    TablesLogic.tReading.DateOfReading < currentReadingDate,
                    TablesLogic.tReading.DateOfReading.Desc);

                decimal? consumption = 0;
                if (reading != null)
                {
                    if (currentReading >= reading.Reading)
                        consumption = currentReading - reading.Reading;
                    else
                        consumption = point.GetMaximumValueToDeduct(point.LastReading.Value) + currentReading - reading.Reading;

                    if (consumption > reading.Consumption * 1.5M)
                        return true;
                    else
                        return false;

                }
                else
                {
                    return false;
                }
            }
            return false;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    public enum EnumBillToAMOSStatus
    {
        NotPostedToAMOS = 0,
        PendingPosting = 1,
        PostedToAMOS = 2,
        PostedToAMOSFailed = 3,
        PostedToAMOSSuccessful = 4,
        UnableToPostDueToError = 5,
        NotPostedDueToCancelled = 6
    }
}

