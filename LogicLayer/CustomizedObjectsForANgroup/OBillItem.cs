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
    [Database("#database"), Map("BillItem")]
    public partial class TBillItem : LogicLayerSchema<OBillItem>
    {
        public SchemaInt BatchID;
        public SchemaInt AssetID;
        public SchemaString BillObjectNumber;
        public SchemaInt ChargeID;
        [Size(255)]
        public SchemaString Description;
        [Size(255)]
        public SchemaString ReadingDescription;
        public SchemaGuid BillID;
        public SchemaGuid ReadingID;
        public SchemaInt ItemNo;
        public SchemaDateTime updatedOn;
        public SchemaDecimal ChargeAmount;

        public TReading Reading { get { return OneToOne<TReading>("ReadingID"); } }
        public TBill Bill { get { return OneToOne<TBill>("BillID"); } }

    }


    /// <summary>
    /// Represents the Bill for an OPC point obtained
    /// from the server, entered by a user through the work
    /// module, or entered by the user through the Point module.
    /// </summary>
    public abstract partial class OBillItem : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {
        public abstract int? BatchID { get; set; }
        public abstract int? AssetID { get; set; }
        public abstract String BillObjectNumber { get; set; }
        public abstract int? ChargeID { get; set; }
        public abstract String Description { get; set; }
        public abstract String ReadingDescription { get; set; }
        public abstract Guid? BillID { get; set; }
        public abstract Guid? ReadingID { get; set; }
        public abstract int? ItemNo { get; set; }

        public abstract OBill Bill { get; set; }
        public abstract OReading Reading { get; set; }
        public abstract DateTime? updatedOn { get; set; }
        public abstract Decimal? ChargeAmount { get; set; }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="bill"></param>
        /// <param name="reading"></param>
        /// <returns></returns>
        public static OBillItem CreateBillItem(OBill bill, OReading reading)
        {
            OBillItem item = TablesLogic.tBillItem.Create();
            item.BatchID = bill.BatchID;
            item.AssetID = bill.AssetID;
            item.BillObjectNumber = bill.ObjectNumber;
            item.ChargeID = reading.Point.ChargeType.AmosChargeID;
            item.Description =
                "[" + reading.Location.ObjectName + "] " + System.Environment.NewLine
                + reading.Point.TypeOfMeter.ObjectName + " Charges: " + "For the month of " + bill.ChargeFrom.Value.ToString("MMMM yyyy") + System.Environment.NewLine
                + "Meter ID: " + reading.Point.Barcode + System.Environment.NewLine;

            /*"[{0}] {1} Charges : {2} {3} Meter ID : {4}" +*/
            /*bill.ChargeFrom.Value.ToString("dd-MMM-yy") + " - " + bill.ChargeTo.Value.ToString("dd-MMM-yy")*/ 

            item.ReadingDescription =
                System.Environment.NewLine
                + "Current Reading: " + reading.Reading.Value.ToString("#,##0.0000") + System.Environment.NewLine
                + "Usage: " + (reading.Consumption.Value * reading.Factor.Value).ToString("#,##0.0000") + "kWh" + System.Environment.NewLine
                + "Rate @ $" + (Math.Round((reading.Tariff.Value * (100 - reading.Discount.Value) / 100), 4, MidpointRounding.AwayFromZero)).ToString("#,##0.0000") + "/kWh" + System.Environment.NewLine
                + "[" + bill.ObjectNumber + "]";

            /*"Current Reading: {0} Usage: {1} Rate @ {2} {3}" + */

            item.ReadingID = reading.ObjectID;
            item.ItemNo = bill.BillItem.Count + 1;
            item.BillID = bill.ObjectID;
            item.updatedOn = DateTime.Today;
            item.ChargeAmount = reading.BillAmount;

            return item;
        }
    }
}

