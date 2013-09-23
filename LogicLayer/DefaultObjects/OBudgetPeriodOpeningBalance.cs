//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// 
    /// </summary>
    [Serializable]
    public partial class TBudgetPeriodOpeningBalance : LogicLayerSchema<OBudgetPeriodOpeningBalance>
    {
        public SchemaGuid BudgetPeriodID;
        public SchemaGuid AccountID;
        [Default(1)]
        public SchemaInt IsActive;
        [Default(0)]
        public SchemaDecimal TotalOpeningBalance;
        [Default(0)]
        public SchemaDecimal OpeningBalance01;
        [Default(0)]
        public SchemaDecimal OpeningBalance02;
        [Default(0)]
        public SchemaDecimal OpeningBalance03;
        [Default(0)]
        public SchemaDecimal OpeningBalance04;
        [Default(0)]
        public SchemaDecimal OpeningBalance05;
        [Default(0)]
        public SchemaDecimal OpeningBalance06;
        [Default(0)]
        public SchemaDecimal OpeningBalance07;
        [Default(0)]
        public SchemaDecimal OpeningBalance08;
        [Default(0)]
        public SchemaDecimal OpeningBalance09;
        [Default(0)]
        public SchemaDecimal OpeningBalance10;
        [Default(0)]
        public SchemaDecimal OpeningBalance11;
        [Default(0)]
        public SchemaDecimal OpeningBalance12;
        [Default(0)]
        public SchemaDecimal OpeningBalance13;
        [Default(0)]
        public SchemaDecimal OpeningBalance14;
        [Default(0)]
        public SchemaDecimal OpeningBalance15;
        [Default(0)]
        public SchemaDecimal OpeningBalance16;
        [Default(0)]
        public SchemaDecimal OpeningBalance17;
        [Default(0)]
        public SchemaDecimal OpeningBalance18;
        [Default(0)]
        public SchemaDecimal OpeningBalance19;
        [Default(0)]
        public SchemaDecimal OpeningBalance20;
        [Default(0)]
        public SchemaDecimal OpeningBalance21;
        [Default(0)]
        public SchemaDecimal OpeningBalance22;
        [Default(0)]
        public SchemaDecimal OpeningBalance23;
        [Default(0)]
        public SchemaDecimal OpeningBalance24;
        [Default(0)]
        public SchemaDecimal OpeningBalance25;
        [Default(0)]
        public SchemaDecimal OpeningBalance26;
        [Default(0)]
        public SchemaDecimal OpeningBalance27;
        [Default(0)]
        public SchemaDecimal OpeningBalance28;
        [Default(0)]
        public SchemaDecimal OpeningBalance29;
        [Default(0)]
        public SchemaDecimal OpeningBalance30;
        [Default(0)]
        public SchemaDecimal OpeningBalance31;
        [Default(0)]
        public SchemaDecimal OpeningBalance32;
        [Default(0)]
        public SchemaDecimal OpeningBalance33;
        [Default(0)]
        public SchemaDecimal OpeningBalance34;
        [Default(0)]
        public SchemaDecimal OpeningBalance35;
        [Default(0)]
        public SchemaDecimal OpeningBalance36;
        [Default(10)]
        public SchemaDecimal LowBudgetThreshold;

        public TAccount Account { get { return OneToOne<TAccount>("AccountID"); } }
        public TBudgetPeriod BudgetPeriod { get { return OneToOne<TBudgetPeriod>("BudgetPeriodID"); } }
    }


    [Serializable]
    public abstract partial class OBudgetPeriodOpeningBalance : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets a foreign key to the
        /// BudgetPeriod table that indicates the budget
        /// period that this opening balance belongs under.
        /// </summary>
        public abstract Guid? BudgetPeriodID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a foreign key to the 
        /// Account table that indicates the account 
        /// that this opening balance is meant for. It also
        /// indicates the account that is applicable to
        /// the budget period.
        /// </summary>
        public abstract Guid? AccountID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates
        /// whether or not this budget account is active
        /// or not.
        /// </summary>
        public abstract int? IsActive { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total funds
        /// available for expenditure at the opening 
        /// of the budget. 
        /// </summary>
        public abstract Decimal? TotalOpeningBalance { get; set; }


        /// <summary>
        /// [Column] Gets or sets the funds available
        /// for an interval in the budget period. 
        /// </summary>
        public abstract Decimal? OpeningBalance01 { get; set; }
        public abstract Decimal? OpeningBalance02 { get; set; }
        public abstract Decimal? OpeningBalance03 { get; set; }
        public abstract Decimal? OpeningBalance04 { get; set; }
        public abstract Decimal? OpeningBalance05 { get; set; }
        public abstract Decimal? OpeningBalance06 { get; set; }
        public abstract Decimal? OpeningBalance07 { get; set; }
        public abstract Decimal? OpeningBalance08 { get; set; }
        public abstract Decimal? OpeningBalance09 { get; set; }
        public abstract Decimal? OpeningBalance10 { get; set; }
        public abstract Decimal? OpeningBalance11 { get; set; }
        public abstract Decimal? OpeningBalance12 { get; set; }
        public abstract Decimal? OpeningBalance13 { get; set; }
        public abstract Decimal? OpeningBalance14 { get; set; }
        public abstract Decimal? OpeningBalance15 { get; set; }
        public abstract Decimal? OpeningBalance16 { get; set; }
        public abstract Decimal? OpeningBalance17 { get; set; }
        public abstract Decimal? OpeningBalance18 { get; set; }
        public abstract Decimal? OpeningBalance19 { get; set; }
        public abstract Decimal? OpeningBalance20 { get; set; }
        public abstract Decimal? OpeningBalance21 { get; set; }
        public abstract Decimal? OpeningBalance22 { get; set; }
        public abstract Decimal? OpeningBalance23 { get; set; }
        public abstract Decimal? OpeningBalance24 { get; set; }
        public abstract Decimal? OpeningBalance25 { get; set; }
        public abstract Decimal? OpeningBalance26 { get; set; }
        public abstract Decimal? OpeningBalance27 { get; set; }
        public abstract Decimal? OpeningBalance28 { get; set; }
        public abstract Decimal? OpeningBalance29 { get; set; }
        public abstract Decimal? OpeningBalance30 { get; set; }
        public abstract Decimal? OpeningBalance31 { get; set; }
        public abstract Decimal? OpeningBalance32 { get; set; }
        public abstract Decimal? OpeningBalance33 { get; set; }
        public abstract Decimal? OpeningBalance34 { get; set; }
        public abstract Decimal? OpeningBalance35 { get; set; }
        public abstract Decimal? OpeningBalance36 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the threshold in percentage
        /// so that if the available amount (after adjustments and
        /// commitments) falls below the (budget threshold * opening
        /// balance), a notification will be sent to the
        /// reminder recipients of the budget.
        /// </summary>
        public abstract Decimal? LowBudgetThreshold { get; set; }

        /// <summary>
        /// A flag that indicates if the available amount in
        /// this budget account has fallen below threshold. (This flag
        /// is set in the method OBudgetPeriod.DetermineLowThresholdOpeningBalances)
        /// </summary>
        public bool IsLow;

        /// <summary>
        /// Gets or sets an OAccount object that represents
        /// that account this opening balance is meant for.
        /// </summary>
        public abstract OAccount Account { get; set; }

        /// <summary>
        /// Gets or sets an OBudgetPeriod object that represents
        /// that budget period this opening balance is meant for.
        /// </summary>
        public abstract OBudgetPeriod BudgetPeriod { get; set; }


        /// <summary>
        /// Gets the total available balance after all variations
        /// and commitments.
        /// </summary>
        public decimal TotalAvailableBalance
        {
            get
            {
                TBudgetPeriodOpeningBalance ob = TablesLogic.tBudgetPeriodOpeningBalance;
                TBudgetVariationLog budgetVariationLog = TablesLogic.tBudgetVariationLog;
                TBudgetTransactionLog budgetTransactionLog = TablesLogic.tBudgetTransactionLog;

                decimal result =
                ob.Select(
                    ob.TotalOpeningBalance +
                    Case.IsNull(budgetVariationLog.Select(Case.IsNull(budgetVariationLog.VariationAmount, 0).Sum())
                        .Where(
                        budgetVariationLog.IsDeleted == 0 &
                        budgetVariationLog.AccountID == ob.AccountID &
                        budgetVariationLog.BudgetPeriodID == ob.BudgetPeriodID), 0) -
                    Case.IsNull(budgetTransactionLog.Select(Case.IsNull(budgetTransactionLog.TransactionAmount, 0).Sum())
                        .Where(
                        budgetTransactionLog.IsDeleted == 0 &
                        budgetTransactionLog.AccountID == ob.AccountID &
                        budgetTransactionLog.BudgetID == ob.BudgetPeriod.BudgetID &
                        ob.BudgetPeriod.StartDate <= budgetTransactionLog.DateOfExpenditure &
                        budgetTransactionLog.DateOfExpenditure <= ob.BudgetPeriod.EndDate), 0))
                .Where(
                    ob.ObjectID == this.ObjectID);
                return result;
            }
        }


        public string IsActiveText
        {
            get
            {
                if (IsActive == 0)
                    return Resources.Strings.General_No;
                else if (IsActive == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }


        /// <summary>
        /// Validates that the total of opening balances
        /// for all intervals equals the opening balance
        /// total.
        /// </summary>
        /// <returns></returns>
        public bool ValidateTotal()
        {
            decimal? total =
                OpeningBalance01 + OpeningBalance02 + OpeningBalance03 + OpeningBalance04 + OpeningBalance05 +
                OpeningBalance06 + OpeningBalance07 + OpeningBalance08 + OpeningBalance09 + OpeningBalance10 +
                OpeningBalance11 + OpeningBalance12 + OpeningBalance13 + OpeningBalance14 + OpeningBalance15 +
                OpeningBalance16 + OpeningBalance17 + OpeningBalance18 + OpeningBalance19 + OpeningBalance20 +
                OpeningBalance21 + OpeningBalance22 + OpeningBalance23 + OpeningBalance24 + OpeningBalance25 +
                OpeningBalance26 + OpeningBalance27 + OpeningBalance28 + OpeningBalance29 + OpeningBalance30 +
                OpeningBalance31 + OpeningBalance32 + OpeningBalance33 + OpeningBalance34 + OpeningBalance35 +
                OpeningBalance36;

            if (total == TotalOpeningBalance)
                return true;
            else
                return false;

        }


        /// <summary>
        /// Gets a list of opening balances by the budget ID and the
        /// starting date of deduction.
        /// </summary>
        /// <param name="budgetId"></param>
        /// <param name="date"></param>
        /// <returns></returns>
        public static List<OBudgetPeriodOpeningBalance> GetBudgetPeriodOpeningBalanceByBudgetIDAndDate(
            Guid[] budgetIds, Guid[] accountIds, DateTime[] dates)
        {
            TBudgetPeriodOpeningBalance ob = TablesLogic.tBudgetPeriodOpeningBalance;

            ExpressionCondition c = Query.False;

            for (int i = 0; i < budgetIds.Length && i < accountIds.Length && i < dates.Length; i++)
            {
                c = c |
                    (ob.BudgetPeriod.BudgetID == budgetIds[i] &
                    ob.BudgetPeriod.IsActive == 1 &
                    ob.AccountID == accountIds[i] &
                    ob.BudgetPeriod.StartDate <= dates[i] &
                    ob.BudgetPeriod.EndDate >= dates[i]);
            }

            return ob.LoadList(c);
        }

        public Decimal? OpeningBalanceGet(int index)
        {
            switch (index)
            { 
                case 1: return OpeningBalance01;
                case 2: return OpeningBalance02;
                case 3: return OpeningBalance03;
                case 4: return OpeningBalance04;
                case 5: return OpeningBalance05;
                case 6: return OpeningBalance06;
                case 7: return OpeningBalance07;
                case 8: return OpeningBalance08;
                case 9: return OpeningBalance09;
                case 10: return OpeningBalance10;
                case 11: return OpeningBalance11;
                case 12: return OpeningBalance12;
                case 13: return OpeningBalance13;
                case 14: return OpeningBalance14;
                case 15: return OpeningBalance15;
                case 16: return OpeningBalance16;
                case 17: return OpeningBalance17;
                case 18: return OpeningBalance18;
                case 19: return OpeningBalance19;
                case 20: return OpeningBalance20;
                case 21: return OpeningBalance21;
                case 22: return OpeningBalance22;
                case 23: return OpeningBalance23;
                case 24: return OpeningBalance24;
                case 25: return OpeningBalance25;
                case 26: return OpeningBalance26;
                case 27: return OpeningBalance27;
                case 28: return OpeningBalance28;
                case 29: return OpeningBalance29;
                case 30: return OpeningBalance30;
                case 31: return OpeningBalance31;
                case 32: return OpeningBalance32;
                case 33: return OpeningBalance33;
                case 34: return OpeningBalance34;
                case 35: return OpeningBalance35;
                case 36: return OpeningBalance36;
                default: return null;
            }
        }

        public void OpeningBalanceSet(int index,Decimal value)
        {
            switch (index)
            {
                case 1:  OpeningBalance01 = value ; return;
                case 2:  OpeningBalance02 = value ; return;
                case 3:  OpeningBalance03 = value ; return;
                case 4:  OpeningBalance04 = value ; return;
                case 5:  OpeningBalance05 = value ; return;
                case 6:  OpeningBalance06 = value ; return;
                case 7:  OpeningBalance07 = value ; return;
                case 8:  OpeningBalance08 = value ; return;
                case 9:  OpeningBalance09 = value ; return;
                case 10:  OpeningBalance10 = value ; return;
                case 11:  OpeningBalance11 = value ; return;
                case 12:  OpeningBalance12 = value ; return;
                case 13:  OpeningBalance13 = value ; return;
                case 14:  OpeningBalance14 = value ; return;
                case 15:  OpeningBalance15 = value ; return;
                case 16:  OpeningBalance16 = value ; return;
                case 17:  OpeningBalance17 = value ; return;
                case 18:  OpeningBalance18 = value ; return;
                case 19:  OpeningBalance19 = value ; return;
                case 20:  OpeningBalance20 = value ; return;
                case 21:  OpeningBalance21 = value ; return;
                case 22:  OpeningBalance22 = value ; return;
                case 23:  OpeningBalance23 = value ; return;
                case 24:  OpeningBalance24 = value ; return;
                case 25:  OpeningBalance25 = value ; return;
                case 26:  OpeningBalance26 = value ; return;
                case 27:  OpeningBalance27 = value ; return;
                case 28:  OpeningBalance28 = value ; return;
                case 29:  OpeningBalance29 = value ; return;
                case 30:  OpeningBalance30 = value ; return;
                case 31:  OpeningBalance31 = value ; return;
                case 32:  OpeningBalance32 = value ; return;
                case 33:  OpeningBalance33 = value ; return;
                case 34:  OpeningBalance34 = value ; return;
                case 35:  OpeningBalance35 = value ; return;
                case 36:  OpeningBalance36 = value ; return;               
            }
        }

        public void CalculateTotal()
        {
            TotalOpeningBalance  =
                OpeningBalance01 + OpeningBalance02 + OpeningBalance03 + OpeningBalance04 + OpeningBalance05 +
                OpeningBalance06 + OpeningBalance07 + OpeningBalance08 + OpeningBalance09 + OpeningBalance10 +
                OpeningBalance11 + OpeningBalance12 + OpeningBalance13 + OpeningBalance14 + OpeningBalance15 +
                OpeningBalance16 + OpeningBalance17 + OpeningBalance18 + OpeningBalance19 + OpeningBalance20 +
                OpeningBalance21 + OpeningBalance22 + OpeningBalance23 + OpeningBalance24 + OpeningBalance25 +
                OpeningBalance26 + OpeningBalance27 + OpeningBalance28 + OpeningBalance29 + OpeningBalance30 +
                OpeningBalance31 + OpeningBalance32 + OpeningBalance33 + OpeningBalance34 + OpeningBalance35 +
                OpeningBalance36;

        }

    }
}
