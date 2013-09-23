//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for TCustomer
    /// </summary>
    public partial class TTransactionHistory : LogicLayerSchema<OTransactionHistory>
    {
        public SchemaInt ItemNumber;
        public SchemaGuid CustomerAccountID;
        public TCustomerAccount CustomerAccount { get { return OneToOne<TCustomerAccount>("CustomerAccountID"); } }
        public SchemaInt Ticket;
        public SchemaDateTime OpenTime;
        public SchemaInt Type;
        public SchemaDecimal Size;
        // ex XAUUSD
        public SchemaGuid ItemID;
        public TCode Item { get { return OneToOne<TCode>("ItemID"); } }
        public SchemaDecimal OpenPrice;
        // S/L: Stop Loss
        public SchemaDecimal StopLoss;
        public SchemaDecimal TakeProfit; // Take Profit
        public SchemaDateTime CloseTime;
        public SchemaDecimal ClosePrice;
        public SchemaDecimal Commission;
        public SchemaDecimal Tax;
        public SchemaDecimal Swap;
        public SchemaDecimal Profit;
    }

    /// <summary>
    /// Summary description for OCustomer
    /// </summary>
    public abstract partial class OTransactionHistory : LogicLayerPersistentObject
    {
        public abstract int? ItemNumber { get; set; }
        public abstract Guid? CustomerAccountID { get; set; }
        public abstract OCustomerAccount CustomerAccount { get; set; }
        public abstract int? Ticket { get; set; }
        public abstract DateTime? OpenTime { get; set; }
        public abstract int? Type { get; set; }
        public abstract decimal? Size { get; set; }
        // ex XAUUSD
        public abstract Guid? ItemID { get; set; }
        public abstract OCode Item { get; set; }
        public abstract decimal? OpenPrice { get; set; }
        // S/L: Stop Loss
        public abstract decimal? StopLoss { get; set; }
        public abstract decimal? TakeProfit { get; set; }
        public abstract DateTime? CloseTime { get; set; }
        public abstract decimal? ClosePrice { get; set; }
        public abstract decimal? Commission { get; set; }
        public abstract decimal? Tax { get; set; }
        public abstract decimal? Swap { get; set; }
        public abstract decimal? Profit { get; set; }
        public string TypeText
        {
            get
            {
                if (Type == 0) return "sell";
                else return "buy";
            }
        }
        public class TransactionHistoryType
        {
            public const int Buy = 1;
            public const int Sell = 0;
            public const int Deposit = 2;
            public const int Withdraw = 3;
        }
    }
}

