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
    public partial class TRFQBudgetReallocationFromPeriod : LogicLayerSchema<ORFQBudgetReallocationFromPeriod>
    {
        public SchemaGuid RequestForQuotationID;
        public SchemaGuid FromBudgetID;
        public SchemaGuid FromBudgetPeriodID;
        public SchemaDecimal TotalAmount;

        public TRequestForQuotation RequestForQuotation { get { return OneToOne<TRequestForQuotation>("RequestForQuotationID"); } }
        public TBudget FromBudget { get { return OneToOne<TBudget>("FromBudgetID"); } }
        public TBudgetPeriod FromBudgetPeriod { get { return OneToOne<TBudgetPeriod>("FromBudgetPeriodID"); } }

        public TRFQBudgetReallocationFrom RFQBudgetReallocationFroms { get { return OneToMany<TRFQBudgetReallocationFrom>("RFQBudgetReallocationFromPeriodID"); } }
    }


    /// <summary>
    /// Represents a budget reallocation record that 
    /// </summary>
    [Serializable]
    public abstract partial class ORFQBudgetReallocationFromPeriod : LogicLayerPersistentObject
    {
        public abstract Guid? RequestForQuotationID { get; set; }
        public abstract Guid? FromBudgetID { get; set; }
        public abstract Guid? FromBudgetPeriodID { get; set; }
        public abstract decimal? TotalAmount { get; set; }

        public abstract ORequestForQuotation RequestForQuotation { get; set; }
        public abstract OBudget FromBudget { get; set; }
        public abstract OBudgetPeriod FromBudgetPeriod { get; set; }

        public abstract DataList<ORFQBudgetReallocationFrom> RFQBudgetReallocationFroms { get; }

        public string FromBudgetAccount
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].Account.ObjectName;
            }
        }

        //public decimal? CurrentAvailable
        //{
        //    get
        //    {
        //        if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
        //            || RFQBudgetReallocationFroms[0].Account == null)
        //            return null;
        //        else
        //            return RFQBudgetReallocationFroms[0].CurrentAvailable;
        //    }
        //}

        //public decimal? AvailableAtSubmission
        //{
        //    get
        //    {
        //        if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
        //            || RFQBudgetReallocationFroms[0].Account == null)
        //            return null;
        //        else
        //            return RFQBudgetReallocationFroms[0].AvailableAtSubmission;
        //    }
        //}

        #region Budget summary before submission

        public decimal? TotalOpeningBalance
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalOpeningBalance;
            }
        }

        public decimal? TotalAdjustedAmount
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalAdjustedAmount;
            }
        }

        public decimal? TotalReallocatedAmount
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalReallocatedAmount;
            }
        }

        public decimal? TotalBalanceAfterVariation
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalBalanceAfterVariation;
            }
        }

        public decimal? TotalPendingApproval
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalPendingApproval;
            }
        }

        public decimal? TotalApproved
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalApproved;
            }
        }

        public decimal? TotalDirectInvoicePendingApproval
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalDirectInvoicePendingApproval;
            }
        }

        public decimal? TotalDirectInvoiceApproved
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalDirectInvoiceApproved;
            }
        }

        public decimal? TotalAvailableBalance
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalAvailableBalance;
            }
        }

        #endregion

        #region Budget summary At submission

        public decimal? TotalOpeningBalanceAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalOpeningBalanceAtSubmission;
            }
        }

        public decimal? TotalAdjustedAmountAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalAdjustedAmountAtSubmission;
            }
        }

        public decimal? TotalReallocatedAmountAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalReallocatedAmountAtSubmission;
            }
        }

        public decimal? TotalBalanceAfterVariationAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalBalanceAfterVariationAtSubmission;
            }
        }

        public decimal? TotalPendingApprovalAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalPendingApprovalAtSubmission;
            }
        }

        public decimal? TotalApprovedAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalApprovedAtSubmission;
            }
        }

        public decimal? TotalDirectInvoicePendingApprovalAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalDirectInvoicePendingApprovalAtSubmission;
            }
        }

        public decimal? TotalDirectInvoiceApprovedAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalDirectInvoiceApprovedAtSubmission;
            }
        }

        public decimal? TotalAvailableBalanceAtSubmission
        {
            get
            {
                if (RFQBudgetReallocationFroms == null || RFQBudgetReallocationFroms.Count == 0
                    || RFQBudgetReallocationFroms[0].Account == null)
                    return null;
                else
                    return RFQBudgetReallocationFroms[0].TotalAvailableBalanceAtSubmission;
            }
        }

        #endregion

    }
}