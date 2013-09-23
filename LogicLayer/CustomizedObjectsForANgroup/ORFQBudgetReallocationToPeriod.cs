//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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
    /// Created by TVO
    /// </summary>
    [Serializable]
    public partial class TRFQBudgetReallocationToPeriod : LogicLayerSchema<ORFQBudgetReallocationToPeriod>
    {
        public SchemaGuid RequestForQuotationID;
        public SchemaGuid ToBudgetID;
        public SchemaGuid ToBudgetPeriodID;
        public SchemaDecimal TotalAmount;

        public TRequestForQuotation RequestForQuotation { get { return OneToOne<TRequestForQuotation>("RequestForQuotationID"); } }
        public TBudget ToBudget { get { return OneToOne<TBudget>("ToBudgetID"); } }
        public TBudgetPeriod ToBudgetPeriod { get { return OneToOne<TBudgetPeriod>("ToBudgetPeriodID"); } }

        public TRFQBudgetReallocationTo RFQBudgetReallocationTos { get { return OneToMany<TRFQBudgetReallocationTo>("RFQBudgetReallocationToPeriodID"); } }
    }


    /// <summary>
    /// Represents a budget reallocation record that 
    /// </summary>
    [Serializable]
    public abstract partial class ORFQBudgetReallocationToPeriod : LogicLayerPersistentObject
    {
        public abstract Guid? RequestForQuotationID { get; set; }
        public abstract Guid? ToBudgetID { get; set; }
        public abstract Guid? ToBudgetPeriodID { get; set; }
        public abstract decimal? TotalAmount { get; set; }

        public abstract ORequestForQuotation RequestForQuotation { get; set; }
        public abstract OBudget ToBudget { get; set; }
        public abstract OBudgetPeriod ToBudgetPeriod { get; set; }

        public abstract DataList<ORFQBudgetReallocationTo> RFQBudgetReallocationTos { get; }

        public string ToBudgetAccount
        {
            get
            {
                if (RFQBudgetReallocationTos == null || RFQBudgetReallocationTos.Count == 0
                    || RFQBudgetReallocationTos[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationTos[0].Account.ObjectName;
            }
        }


        
    }
}