using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;
namespace LogicLayer
{
    public partial class TBudgetAdjustmentDetail : LogicLayerSchema<OBudgetAdjustmentDetail>
    {
        public SchemaDecimal totalAvailableBalance;
    }
    public abstract partial class OBudgetAdjustmentDetail : LogicLayerPersistentObject
    {
        private decimal? totalOpeningBalance;
        private decimal? totalAdjustedAmount;
        private decimal? totalReallocatedAmount;
        private decimal? totalBalanceAfterVariation;
        private decimal? totalPendingApproval;
        private decimal? totalApproved;
        private decimal? totalDirectInvoicePendingApproval;
        private decimal? totalDirectInvoiceApproved;
        public abstract decimal? totalAvailableBalance{get;set;}

        public decimal? TotalOpeningBalance
        {
            get { return totalOpeningBalance; }
            set { totalOpeningBalance = value; }
        }

        public decimal? TotalAdjustedAmount
        {
            get { return totalAdjustedAmount; }
            set { totalAdjustedAmount = value; }
        }

        public decimal? TotalReallocatedAmount
        {
            get { return totalReallocatedAmount; }
            set { totalReallocatedAmount = value; }
        }

        public decimal? TotalBalanceAfterVariation
        {
            get { return totalBalanceAfterVariation; }
            set { totalBalanceAfterVariation = value; }
        }

        public decimal? TotalPendingApproval
        {
            get { return totalPendingApproval; }
            set { totalPendingApproval = value; }
        }

        public decimal? TotalApproved
        {
            get { return totalApproved; }
            set { totalApproved = value; }
        }

        public decimal? TotalDirectInvoicePendingApproval
        {
            get { return totalDirectInvoicePendingApproval; }
            set { totalDirectInvoicePendingApproval = value; }
        }

        public decimal? TotalDirectInvoiceApproved
        {
            get { return totalDirectInvoiceApproved; }
            set { totalDirectInvoiceApproved = value; }
        }

        public decimal? TotalAvailableBalance
        {
            get {
                if (totalAvailableBalance == null)
                    totalAvailableBalance = 0m;
                return totalAvailableBalance;
            }
        }
        public decimal? AfterAprovedAvailableBalance
        {
            get {
                
                return TotalAvailableBalance + TotalAmount; 
                
            }
        }
    }
}
