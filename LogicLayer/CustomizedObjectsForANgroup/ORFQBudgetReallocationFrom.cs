using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Serializable] 
    public partial class TRFQBudgetReallocationFrom : LogicLayerSchema<ORFQBudgetReallocationFrom>
    {
        public SchemaGuid RFQBudgetReallocationFromPeriodID;
        public SchemaGuid AccountID;

        [Default(0)] public SchemaDecimal Interval01Amount;
        [Default(0)] public SchemaDecimal Interval02Amount;
        [Default(0)] public SchemaDecimal Interval03Amount;
        [Default(0)] public SchemaDecimal Interval04Amount;
        [Default(0)] public SchemaDecimal Interval05Amount;
        [Default(0)] public SchemaDecimal Interval06Amount;
        [Default(0)] public SchemaDecimal Interval07Amount;
        [Default(0)] public SchemaDecimal Interval08Amount;
        [Default(0)] public SchemaDecimal Interval09Amount;
        [Default(0)] public SchemaDecimal Interval10Amount;
        [Default(0)] public SchemaDecimal Interval11Amount;
        [Default(0)] public SchemaDecimal Interval12Amount;
        [Default(0)] public SchemaDecimal Interval13Amount;
        [Default(0)] public SchemaDecimal Interval14Amount;
        [Default(0)] public SchemaDecimal Interval15Amount;
        [Default(0)] public SchemaDecimal Interval16Amount;
        [Default(0)] public SchemaDecimal Interval17Amount;
        [Default(0)] public SchemaDecimal Interval18Amount;
        [Default(0)] public SchemaDecimal Interval19Amount;
        [Default(0)] public SchemaDecimal Interval20Amount;
        [Default(0)] public SchemaDecimal Interval21Amount;
        [Default(0)] public SchemaDecimal Interval22Amount;
        [Default(0)] public SchemaDecimal Interval23Amount;
        [Default(0)] public SchemaDecimal Interval24Amount;
        [Default(0)] public SchemaDecimal Interval25Amount;
        [Default(0)] public SchemaDecimal Interval26Amount;
        [Default(0)] public SchemaDecimal Interval27Amount;
        [Default(0)] public SchemaDecimal Interval28Amount;
        [Default(0)] public SchemaDecimal Interval29Amount;
        [Default(0)] public SchemaDecimal Interval30Amount;
        [Default(0)] public SchemaDecimal Interval31Amount;
        [Default(0)] public SchemaDecimal Interval32Amount;
        [Default(0)] public SchemaDecimal Interval33Amount;
        [Default(0)] public SchemaDecimal Interval34Amount;
        [Default(0)] public SchemaDecimal Interval35Amount;
        [Default(0)] public SchemaDecimal Interval36Amount;
        [Default(0)] public SchemaDecimal TotalAmount;
        //public SchemaDecimal AvailableAtSubmission;
        public SchemaDecimal TotalOpeningBalanceAtSubmission;
        public SchemaDecimal TotalAdjustedAmountAtSubmission;
        public SchemaDecimal TotalReallocatedAmountAtSubmission;
        public SchemaDecimal TotalBalanceAfterVariationAtSubmission;
        public SchemaDecimal TotalPendingApprovalAtSubmission;
        public SchemaDecimal TotalApprovedAtSubmission;
        public SchemaDecimal TotalDirectInvoicePendingApprovalAtSubmission;
        public SchemaDecimal TotalDirectInvoiceApprovedAtSubmission;
        public SchemaDecimal TotalAvailableBalanceAtSubmission;


        public TRFQBudgetReallocationFromPeriod RFQBudgetReallocationFromPeriod { get { return OneToOne<TRFQBudgetReallocationFromPeriod>("RFQBudgetReallocationFromPeriodID"); } }
        public TAccount Account { get { return OneToOne<TAccount>("AccountID"); } }

    }

    /// <summary>
    /// Represents the money that will be reallocated from the specified
    /// budget account.
    /// </summary>
    [Serializable]
    public abstract partial class ORFQBudgetReallocationFrom : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// budget reallocation record that this detail belongs under.
        /// </summary>
        public abstract Guid? RFQBudgetReallocationFromPeriodID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the budget account that this
        /// money is reallocated from.
        /// </summary>
        public abstract Guid? AccountID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the amount to reallocate in one of
        /// the 36 intervals in the budget period.
        /// </summary>
        public abstract decimal? Interval01Amount { get; set; }
        public abstract decimal? Interval02Amount { get; set; }
        public abstract decimal? Interval03Amount { get; set; }
        public abstract decimal? Interval04Amount { get; set; }
        public abstract decimal? Interval05Amount { get; set; }
        public abstract decimal? Interval06Amount { get; set; }
        public abstract decimal? Interval07Amount { get; set; }
        public abstract decimal? Interval08Amount { get; set; }
        public abstract decimal? Interval09Amount { get; set; }
        public abstract decimal? Interval10Amount { get; set; }
        public abstract decimal? Interval11Amount { get; set; }
        public abstract decimal? Interval12Amount { get; set; }
        public abstract decimal? Interval13Amount { get; set; }
        public abstract decimal? Interval14Amount { get; set; }
        public abstract decimal? Interval15Amount { get; set; }
        public abstract decimal? Interval16Amount { get; set; }
        public abstract decimal? Interval17Amount { get; set; }
        public abstract decimal? Interval18Amount { get; set; }
        public abstract decimal? Interval19Amount { get; set; }
        public abstract decimal? Interval20Amount { get; set; }
        public abstract decimal? Interval21Amount { get; set; }
        public abstract decimal? Interval22Amount { get; set; }
        public abstract decimal? Interval23Amount { get; set; }
        public abstract decimal? Interval24Amount { get; set; }
        public abstract decimal? Interval25Amount { get; set; }
        public abstract decimal? Interval26Amount { get; set; }
        public abstract decimal? Interval27Amount { get; set; }
        public abstract decimal? Interval28Amount { get; set; }
        public abstract decimal? Interval29Amount { get; set; }
        public abstract decimal? Interval30Amount { get; set; }
        public abstract decimal? Interval31Amount { get; set; }
        public abstract decimal? Interval32Amount { get; set; }
        public abstract decimal? Interval33Amount { get; set; }
        public abstract decimal? Interval34Amount { get; set; }
        public abstract decimal? Interval35Amount { get; set; }
        public abstract decimal? Interval36Amount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total amount reallocationed.
        /// </summary>
        public abstract decimal? TotalAmount { get; set; }
        //public abstract decimal? AvailableAtSubmission { get; set; }
        public abstract decimal? TotalOpeningBalanceAtSubmission { get; set; }
        public abstract decimal? TotalAdjustedAmountAtSubmission { get; set; }
        public abstract decimal? TotalReallocatedAmountAtSubmission { get; set; }
        public abstract decimal? TotalBalanceAfterVariationAtSubmission { get; set; }
        public abstract decimal? TotalPendingApprovalAtSubmission { get; set; }
        public abstract decimal? TotalApprovedAtSubmission { get; set; }
        public abstract decimal? TotalDirectInvoicePendingApprovalAtSubmission { get; set; }
        public abstract decimal? TotalDirectInvoiceApprovedAtSubmission { get; set; }
        public abstract decimal? TotalAvailableBalanceAtSubmission { get; set; }

        public abstract ORFQBudgetReallocationFromPeriod RFQBudgetReallocationFromPeriod { get; set; }
        public abstract OAccount Account { get; set; }

        //public decimal? CurrentAvailable
        //{
        //    get
        //    {
        //        if(RFQBudgetReallocationFromPeriod == null)
        //            return null;

        //        return OBudgetPeriod.GetAvailableBalances(
        //            this.RFQBudgetReallocationFromPeriod.FromBudgetID.Value, 
        //            this.RFQBudgetReallocationFromPeriod.FromBudgetPeriodID.Value, 
        //            AccountID.Value);
        //    }
        //}

        private decimal? totalOpeningBalance;
        private decimal? totalAdjustedAmount;
        private decimal? totalReallocatedAmount;
        private decimal? totalBalanceAfterVariation;
        private decimal? totalPendingApproval;
        private decimal? totalApproved;
        private decimal? totalDirectInvoicePendingApproval;
        private decimal? totalDirectInvoiceApproved;
        private decimal? totalAvailableBalance;

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
            get { return totalAvailableBalance; }
            set { totalAvailableBalance = value; }
        }       
       
    }
}
