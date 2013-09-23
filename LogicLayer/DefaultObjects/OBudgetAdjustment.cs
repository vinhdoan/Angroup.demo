//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    [Serializable] 
    public partial class TBudgetAdjustment : LogicLayerSchema<OBudgetAdjustment>
    {
        
        
        public SchemaGuid BudgetID;
        public SchemaGuid BudgetPeriodID;
        [Default(0)]
        public SchemaInt IsCommitted;
        public SchemaInt IsNewVersion;

        public TBudgetAdjustmentDetail BudgetAdjustmentDetails { get { return OneToMany<TBudgetAdjustmentDetail>("BudgetAdjustmentID"); } }
        public TBudget Budget { get { return OneToOne<TBudget>("BudgetID"); } }
        public TBudgetPeriod BudgetPeriod { get { return OneToOne<TBudgetPeriod>("BudgetPeriodID"); } }
    }


    [Serializable]
    public abstract partial class OBudgetAdjustment : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Budget table that represents the budget this
        /// adjustment will be committed against.
        /// </summary>
        public abstract Guid? BudgetID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// BudgetPeriod table that represents the budget period this
        /// adjustment will be committed against.
        /// </summary>
        public abstract Guid? BudgetPeriodID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating if
        /// this budget adjustment has been committed to the
        /// budget.
        /// </summary>
        public abstract int? IsCommitted { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating if
        /// this budget adjustment is new version
        /// </summary>
        public abstract int? IsNewVersion { get; set; }

        /// <summary>
        /// Gets a reference to a list of OBudgetAdjustmentDetail objects
        /// that contain information about the accounts, and the amount
        /// to adjust.
        /// </summary>
        public abstract DataList<OBudgetAdjustmentDetail> BudgetAdjustmentDetails { get; }

        /// <summary>
        /// Gets a reference to an OBudget object representing
        /// the budget that this adjustment will be committed against.
        /// </summary>
        public abstract OBudget Budget { get; set; }

        /// <summary>
        /// Gets a reference to an OBudgetPeriod object representing
        /// the budget period that this adjustment will be committed against.
        /// </summary>
        public abstract OBudgetPeriod BudgetPeriod { get; set; }


        /// <summary>
        /// Gets the total amount to be adjusted across all budget accounts
        /// in this adjustment record.
        /// <para></para>
        /// This property is meant to be displayed in the budget adjustment
        /// edit page. Developers should avoid using this property to 
        /// generate reports.
        /// </summary>
        public decimal TotalAdjustmentAmount
        {
            get
            { 
                decimal total =0;
                foreach (OBudgetAdjustmentDetail detail in this.BudgetAdjustmentDetails)
                    total += detail.TotalAmount.Value;
                return total;
            }
        }


        /// <summary>
        /// Gets the total task amount.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                return TotalAdjustmentAmount;
            }
        }


        /// <summary>
        /// Gets a list of locations applicable to
        /// the budget that this adjustment will commit
        /// against.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in this.Budget.ApplicableLocations)
                    locations.Add(location);
                return locations;
            }
        }

        /// <summary>
        /// Validates that the specified account ID does not exist
        /// in the list of amounts in this budget.
        /// </summary>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public bool ValidateAccountIdDoesNotExist(Guid accountId)
        {
            foreach (OBudgetAdjustmentDetail detail in this.BudgetAdjustmentDetails)
            {
                if (detail.AccountID == accountId)
                    return false;
            }
            return true;
        }


        /// <summary>
        /// Check sufficient available amount
        /// and check if the item has been inactivated
        /// </summary>
        /// <returns></returns>
        public string CheckSufficientAvailableAmount()
        {
            string listOfAccounts = "";
            DataTable dt = this.BudgetPeriod.GetAvailableBalanceOfAllAccounts();
            Hashtable balanceHash = new Hashtable();
            foreach (DataRow dr in dt.Rows)
                balanceHash[dr["AccountID"]] = dr["Balance"];

            foreach (OBudgetAdjustmentDetail budgetAdjustmentDetail in this.BudgetAdjustmentDetails)
            {
                decimal balance = 0;
                if (balanceHash[budgetAdjustmentDetail.AccountID.Value] != null)
                    balance = (decimal)balanceHash[budgetAdjustmentDetail.AccountID.Value];

                if (balance + budgetAdjustmentDetail.TotalAmount.Value < 0)
                    listOfAccounts += (listOfAccounts == "" ? "" : ", ") + budgetAdjustmentDetail.Account.Path;
            }

            return listOfAccounts;
        }


        /*
        /// <summary>
        /// Copy this budget adjusment detail to the budget variationlog
        /// </summary>
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (this.IsCommitted != 1)
                {
                    foreach (OBudgetAdjustmentDetail budgetAdjustmentDetail in this.BudgetAdjustmentDetails)
                    {
                        // The ValidateAccountIdDoesNotExist can be used to test
                        // if the account exists in the budget period. If it does
                        // NOT exist, then an opening balance of ZERO must be
                        // created for that account.
                        //
                        bool hasValue = false;
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)budgetAdjustmentDetail.DataRow["Interval" + (i.ToString("00")) + "Amount"];
                            if (changeValue != 0)
                                hasValue = true;
                        }
                        if (hasValue && this.BudgetPeriod.ValidateAccountIdDoesNotExist(budgetAdjustmentDetail.AccountID.Value))
                        {
                            OBudgetPeriodOpeningBalance openingBalance = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                            openingBalance.BudgetPeriodID = this.BudgetPeriodID;
                            openingBalance.AccountID = budgetAdjustmentDetail.AccountID;
                            openingBalance.Save();
                        }

                        // Create a variation log record for each of the 
                        // intervals whose value is greater than zero.
                        //
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)budgetAdjustmentDetail.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Adjustment;
                            log.BudgetID = this.BudgetID;
                            log.BudgetPeriodID = this.BudgetPeriodID;
                            log.AccountID = budgetAdjustmentDetail.AccountID;
                            log.IntervalNumber = i;
                            log.VariationAmount = changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.BudgetAdjustmentID = this.ObjectID;
                            log.VariationStatus = BudgetVariationStatus.Approved;
                            log.Save();
                        }
                    }
                    this.IsCommitted = 1;
                    this.Save();
                }
                c.Commit();
            }
        }
        */



        /// <summary>
        /// Readjustment object cannot be deleted if object is at Budget_Readjustment_COmmitted state
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (this.IsCommitted == 1)
                return false;
            return true;
        }


        /// <summary>
        /// HeaderText of Interval01Amount for Template
        /// </summary>
        public string Header01
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate;
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval02Amount for Template
        /// </summary>
        public string Header02
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(1);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval03Amount for Template
        /// </summary>
        public string Header03
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(2);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval04Amount for Template
        /// </summary>
        public string Header04
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(3);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval05Amount for Template
        /// </summary>
        public string Header05
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(4);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval06Amount for Template
        /// </summary>
        public string Header06
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(5);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval07Amount for Template
        /// </summary>
        public string Header07
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(6);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval08Amount for Template
        /// </summary>
        public string Header08
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(7);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval09Amount for Template
        /// </summary>
        public string Header09
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(8);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval10Amount for Template
        /// </summary>
        public string Header10
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(9);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval11Amount for Template
        /// </summary>
        public string Header11
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(10);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval12Amount for Template
        /// </summary>
        public string Header12
        {
            get
            {
                DateTime startDate = this.BudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(11);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        public List<OActivityHistory> StatusHistory
        {
            get
            {
                List<OActivityHistory> statusHistory = TablesLogic.tActivityHistory.LoadList(
                                                       TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID);
                return statusHistory;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Called just before the object is saved.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            // this can be customized further to remove BudgetAdjustmentDetails if there is no change at all
            
            // get previous work reading from database
            List<OBudgetAdjustmentDetail> oldList = TablesLogic.tBudgetAdjustmentDetail.LoadList(TablesLogic.tBudgetAdjustmentDetail.BudgetAdjustmentID == this.ObjectID);
            DataList<OBudgetAdjustmentDetail> newList = this.BudgetAdjustmentDetails;
            List<Guid> deleteList = new List<Guid>();
            foreach (OBudgetAdjustmentDetail o in oldList)
            {
                if (newList.FindObject((Guid)o.ObjectID) == null)
                    deleteList.Add((Guid)o.ObjectID);
            }
            foreach (Guid i in deleteList)
                TablesLogic.tBudgetAdjustmentDetail.Delete(i);
        }
    }
}
