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
    public partial class TBillItem : LogicLayerSchema<OBillItem>
    {
        public SchemaGuid WorkCostID;

        public SchemaGuid RequestForQuotationItemID;

    }


    /// <summary>
    /// Represents the Bill for an OPC point obtained
    /// from the server, entered by a user through the work
    /// module, or entered by the user through the Point module.
    /// </summary>
    public abstract partial class OBillItem : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {

        public abstract Guid? WorkCostID { get; set; }

        public abstract Guid? RequestForQuotationItemID { get; set; }

        public static OBillItem CreateBillItem(OBill bill, OWorkCost WorkCost)
        {
            OBillItem item = TablesLogic.tBillItem.Create();
            item.BatchID = bill.BatchID;
            item.AssetID = bill.AssetID;
            item.BillObjectNumber = bill.ObjectNumber;
            item.ChargeID = WorkCost.Work.ChargeType.AmosChargeID;
            item.Description = "";
            item.ReadingDescription = "";
            item.WorkCostID = WorkCost.ObjectID;
            item.ItemNo = bill.BillItem.Count + 1;
            item.BillID = bill.ObjectID;
            item.updatedOn = DateTime.Today;
            item.ChargeAmount = WorkCost.ChargeOut;

            return item;
        }
    }
}

