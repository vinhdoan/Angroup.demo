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
    public partial class TCustomerAccount : LogicLayerSchema<OCustomerAccount>
    {
        public SchemaString AccountNumber;
        public SchemaDecimal Deposit;
        //public SchemaDecimal Equity;
        [Default(0)]
        public SchemaInt Status;
        public SchemaGuid CustomerID;
        public SchemaGuid IBID;
        public SchemaGuid LeverageID;
        public SchemaGuid CurrencyID;
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
        public TCode Leverage { get { return OneToOne<TCode>("LeverageID"); } }
        public TCustomer Customer { get { return OneToOne<TCustomer>("CustomerID"); } }
        public TUser IB { get { return OneToOne<TUser>("IBID"); } }
        public TTransactionHistory TransactionHistories { get { return OneToMany<TTransactionHistory>("CustomerAccountID"); } }
        public SchemaDecimal CommissionRate;
        public SchemaDecimal IBCommission;
    }

    /// <summary>
    /// Summary description for OCustomer
    /// </summary>
    public abstract partial class OCustomerAccount : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {
        public abstract string AccountNumber { get; set; }
        public abstract decimal? Deposit { get; set; }
        //public abstract decimal? Equity { get; set; }
        public abstract int? Status { get; set; }
        public abstract Guid? CustomerID { get; set; }
        public abstract Guid? IBID { get; set; }
        public abstract Guid? LeverageID { get; set; }
        public abstract OCode Leverage { get; set; }
        public abstract OCustomer Customer { get; set; }
        public abstract OUser IB { get; set; }
        public abstract Guid? CurrencyID { get; set; }
        public abstract OCurrency Currrency { get; set; }
        public abstract DataList<OTransactionHistory> TransactionHistories { get; set; }
        public abstract decimal? CommissionRate { get; set; }
        public abstract decimal? IBCommission { get; set; }

        public decimal? Equity
        {
            get
            {
                return Deposit - TablesLogic.tTransactionHistory.Select(TablesLogic.tTransactionHistory.Profit.Sum()).Where(TablesLogic.tTransactionHistory.CustomerAccountID == ObjectID);
            }
        }

        public decimal? BrokerCommission
        {
            get
            {
                return CommissionRate * TablesLogic.tTransactionHistory.Select(TablesLogic.tTransactionHistory.Size.Sum()).Where(TablesLogic.tTransactionHistory.CustomerAccountID == ObjectID);
            }
        }

        public string StatusText
        {
            get
            {
                if (Status == 0) return "Active";
                else if (Status == 1) return "Deactive";
                else return "n.a.";
            }
        }

        public class CustomerAccountStatus
        {
            public const int Active = 0;
            public const int Deactive = 1;
        }
    }
}

