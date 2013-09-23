using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;
namespace LogicLayer
{
    /// <summary>
    /// Created by TVO
    /// </summary>
    [Serializable] 
    public partial class TBudgetAdjustmentDetail : LogicLayerSchema<OBudgetAdjustmentDetail>
    {
        public SchemaGuid BudgetAdjustmentID;
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

        public TBudgetAdjustment BudgetAdjustment { get { return OneToOne<TBudgetAdjustment>("BudgetAdjustmentID"); } }
        public TAccount Account { get { return OneToOne<TAccount>("AccountID"); } }
    }

    [Serializable] 
    public abstract partial class OBudgetAdjustmentDetail : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// budget adjustment record that this detail belongs under.
        /// </summary>
        public abstract Guid? BudgetAdjustmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the budget account that this
        /// adjustment is made to.
        /// </summary>
        public abstract Guid? AccountID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the amount to adjust in one of
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
        /// [Column] Gets or sets the total amount adjusted.
        /// </summary>
        public abstract decimal? TotalAmount { get; set; }


        /// <summary>
        /// Gets the reference to an OBudgetAdjustment object that
        /// represents the budget adjustment record that this 
        /// detail belongs under.
        /// </summary>
        public abstract OBudgetAdjustment BudgetAdjustment { get; set; }

        /// <summary>
        /// Gets the reference to an OAccount object that 
        /// represents the budget account code that this
        /// adjustment is made to.
        /// </summary>
        public abstract OAccount Account { get; set; }

        /// <summary>
        /// Validates that the total of opening balances
        /// for all intervals equals the opening balance
        /// total.
        /// </summary>
        /// <returns></returns>
        public bool ValidateTotal()
        {
            decimal? total =
                Interval01Amount + Interval02Amount + Interval03Amount + Interval04Amount + Interval05Amount +
                Interval06Amount + Interval07Amount + Interval08Amount + Interval09Amount + Interval10Amount +
                Interval11Amount + Interval12Amount + Interval13Amount + Interval14Amount + Interval15Amount +
                Interval16Amount + Interval17Amount + Interval18Amount + Interval19Amount + Interval20Amount +
                Interval21Amount + Interval22Amount + Interval23Amount + Interval24Amount + Interval25Amount +
                Interval26Amount + Interval27Amount + Interval28Amount + Interval29Amount + Interval30Amount +
                Interval31Amount + Interval32Amount + Interval33Amount + Interval34Amount + Interval35Amount +
                Interval36Amount;

            if (total == TotalAmount)
                return true;
            else
                return false;

        }

        public Decimal? IntervalAmountGet(int index)
        {
            switch (index)
            {
                case 1: return Interval01Amount;
                case 2: return Interval02Amount;
                case 3: return Interval03Amount;
                case 4: return Interval04Amount;
                case 5: return Interval05Amount;
                case 6: return Interval06Amount;
                case 7: return Interval07Amount;
                case 8: return Interval08Amount;
                case 9: return Interval09Amount;
                case 10: return Interval10Amount;
                case 11: return Interval11Amount;
                case 12: return Interval12Amount;
                case 13: return Interval13Amount;
                case 14: return Interval14Amount;
                case 15: return Interval15Amount;
                case 16: return Interval16Amount;
                case 17: return Interval17Amount;
                case 18: return Interval18Amount;
                case 19: return Interval19Amount;
                case 20: return Interval20Amount;
                case 21: return Interval21Amount;
                case 22: return Interval22Amount;
                case 23: return Interval23Amount;
                case 24: return Interval24Amount;
                case 25: return Interval25Amount;
                case 26: return Interval26Amount;
                case 27: return Interval27Amount;
                case 28: return Interval28Amount;
                case 29: return Interval29Amount;
                case 30: return Interval30Amount;
                case 31: return Interval31Amount;
                case 32: return Interval32Amount;
                case 33: return Interval33Amount;
                case 34: return Interval34Amount;
                case 35: return Interval35Amount;
                case 36: return Interval36Amount;
                default: return null;
            }
        }

        public void IntervalAmountSet(int index, Decimal value)
        {
            switch (index)
            {
                case 1: Interval01Amount = value; return;
                case 2: Interval02Amount = value; return;
                case 3: Interval03Amount = value; return;
                case 4: Interval04Amount = value; return;
                case 5: Interval05Amount = value; return;
                case 6: Interval06Amount = value; return;
                case 7: Interval07Amount = value; return;
                case 8: Interval08Amount = value; return;
                case 9: Interval09Amount = value; return;
                case 10: Interval10Amount = value; return;
                case 11: Interval11Amount = value; return;
                case 12: Interval12Amount = value; return;
                case 13: Interval13Amount = value; return;
                case 14: Interval14Amount = value; return;
                case 15: Interval15Amount = value; return;
                case 16: Interval16Amount = value; return;
                case 17: Interval17Amount = value; return;
                case 18: Interval18Amount = value; return;
                case 19: Interval19Amount = value; return;
                case 20: Interval20Amount = value; return;
                case 21: Interval21Amount = value; return;
                case 22: Interval22Amount = value; return;
                case 23: Interval23Amount = value; return;
                case 24: Interval24Amount = value; return;
                case 25: Interval25Amount = value; return;
                case 26: Interval26Amount = value; return;
                case 27: Interval27Amount = value; return;
                case 28: Interval28Amount = value; return;
                case 29: Interval29Amount = value; return;
                case 30: Interval30Amount = value; return;
                case 31: Interval31Amount = value; return;
                case 32: Interval32Amount = value; return;
                case 33: Interval33Amount = value; return;
                case 34: Interval34Amount = value; return;
                case 35: Interval35Amount = value; return;
                case 36: Interval36Amount = value; return;
            }
        }

        public void CalculateTotal()
        {
            TotalAmount =
                Interval01Amount + Interval02Amount + Interval03Amount + Interval04Amount + Interval05Amount +
                Interval06Amount + Interval07Amount + Interval08Amount + Interval09Amount + Interval10Amount +
                Interval11Amount + Interval12Amount + Interval13Amount + Interval14Amount + Interval15Amount +
                Interval16Amount + Interval17Amount + Interval18Amount + Interval19Amount + Interval20Amount +
                Interval21Amount + Interval22Amount + Interval23Amount + Interval24Amount + Interval25Amount +
                Interval26Amount + Interval27Amount + Interval28Amount + Interval29Amount + Interval30Amount +
                Interval31Amount + Interval32Amount + Interval33Amount + Interval34Amount + Interval35Amount +
                Interval36Amount;

        }


        /// <summary>
        /// Tests to check if the adjustment is a zero adjustment.
        /// Returns true if so, false otherwise.
        /// <para></para>
        /// The adjustment detail is considered a zero adjustment if
        /// all the IntervalNAmount fields are all zero.
        /// </summary>
        /// <returns></returns>
        public bool IsZeroAdjustment()
        {
            if (Interval01Amount == 0 &&
                Interval02Amount == 0 &&
                Interval03Amount == 0 &&
                Interval04Amount == 0 &&
                Interval05Amount == 0 &&
                Interval06Amount == 0 &&
                Interval07Amount == 0 &&
                Interval08Amount == 0 &&
                Interval09Amount == 0 &&
                Interval10Amount == 0 &&
                Interval11Amount == 0 &&
                Interval12Amount == 0 &&
                Interval13Amount == 0 &&
                Interval14Amount == 0 &&
                Interval15Amount == 0 &&
                Interval16Amount == 0 &&
                Interval17Amount == 0 &&
                Interval18Amount == 0 &&
                Interval19Amount == 0 &&
                Interval20Amount == 0 &&
                Interval21Amount == 0 &&
                Interval22Amount == 0 &&
                Interval23Amount == 0 &&
                Interval24Amount == 0 &&
                Interval25Amount == 0 &&
                Interval26Amount == 0 &&
                Interval27Amount == 0 &&
                Interval28Amount == 0 &&
                Interval29Amount == 0 &&
                Interval30Amount == 0 &&
                Interval31Amount == 0 &&
                Interval32Amount == 0 &&
                Interval33Amount == 0 &&
                Interval34Amount == 0 &&
                Interval35Amount == 0 &&
                Interval36Amount == 0)
                return true;
            else
                return false;
        }
    }
}
