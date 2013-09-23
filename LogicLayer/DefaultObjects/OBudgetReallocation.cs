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
    /// Created by TVO
    /// </summary>
    [Serializable] 
    public partial class TBudgetReallocation : LogicLayerSchema<OBudgetReallocation>
    {
        //[Size(255)]
        //public SchemaString Description;
        public SchemaGuid FromBudgetID;
        public SchemaGuid FromBudgetPeriodID;
        public SchemaGuid ToBudgetID;
        public SchemaGuid ToBudgetPeriodID;
        [Default(0)]
        public SchemaInt IsCommitted;

        public TBudget FromBudget { get { return OneToOne<TBudget>("FromBudgetID"); } }
        public TBudgetPeriod FromBudgetPeriod { get { return OneToOne<TBudgetPeriod>("FromBudgetPeriodID"); } }
        public TBudget ToBudget { get { return OneToOne<TBudget>("ToBudgetID"); } }
        public TBudgetPeriod ToBudgetPeriod { get { return OneToOne<TBudgetPeriod>("ToBudgetPeriodID"); } }
        public TBudgetReallocationFrom BudgetReallocationFroms { get { return OneToMany<TBudgetReallocationFrom>("BudgetReallocationID"); } }
        public TBudgetReallocationTo BudgetReallocationTos { get { return OneToMany<TBudgetReallocationTo>("BudgetReallocationID"); } }
    }


    /// <summary>
    /// Represents a budget reallocation record that 
    /// </summary>
    [Serializable]
    public abstract partial class OBudgetReallocation : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract string Description { get; set; }
        public abstract Guid? FromBudgetID { get; set; }
        public abstract Guid? FromBudgetPeriodID { get; set; }
        public abstract Guid? ToBudgetID { get; set; }
        public abstract Guid? ToBudgetPeriodID { get; set; }
        public abstract int? IsCommitted { get; set; }

        public abstract OBudget FromBudget { get; set; }
        public abstract OBudgetPeriod FromBudgetPeriod { get; set; }
        public abstract OBudget ToBudget { get; set; }
        public abstract OBudgetPeriod ToBudgetPeriod { get; set; }

        public abstract DataList<OBudgetReallocationFrom> BudgetReallocationFroms { get; }
        public abstract DataList<OBudgetReallocationTo> BudgetReallocationTos { get; }


        /// <summary>
        /// Gets the total amount to be reallocated from the source budget.
        /// </summary>
        public decimal TotalFromBudgetAmount
        {
            get
            {
                decimal total = 0;
                foreach (OBudgetReallocationFrom realloc in this.BudgetReallocationFroms)
                    if (realloc.TotalAmount != null)
                        total += realloc.TotalAmount.Value;
                return total;
            }
        }

        /// <summary>
        /// Gets the total amount to be reallocated to the destination 
        /// budget.
        /// </summary>
        public decimal TotalToBudgetAmount
        {
            get
            {
                decimal total = 0;
                foreach (OBudgetReallocationTo realloc in this.BudgetReallocationTos)
                    if (realloc.TotalAmount != null)
                        total += realloc.TotalAmount.Value;
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
                return TotalFromBudgetAmount;
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
                foreach (OLocation location in this.FromBudget.ApplicableLocations)
                    locations.Add(location);
                foreach (OLocation location in this.ToBudget.ApplicableLocations)
                {
                    bool found = false;
                    foreach (OLocation l2 in locations)
                        if (l2.ObjectID == location.ObjectID)
                        {
                            found = true;
                            break;
                        }
                    if (!found)
                        locations.Add(location);
                }
                return locations;
            }
        }

        /// <summary>
        /// Validates that the specified account ID does not exist
        /// in the list of amounts in this budget.
        /// </summary>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public bool ValidateFromAccountIdDoesNotExist(Guid accountId)
        {
            foreach (OBudgetReallocationFrom from in this.BudgetReallocationFroms)
                if (from.AccountID == accountId)
                    return false;
            return true;
        }


        /// <summary>
        /// Validates that the specified account ID does not exist
        /// in the list of amounts in this budget.
        /// </summary>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public bool ValidateToAccountIdDoesNotExist(Guid accountId)
        {
            foreach (OBudgetReallocationTo to in this.BudgetReallocationTos)
                if (to.AccountID == accountId)
                    return false;
            return true;
        }


        /// <summary>
        /// Checks for all available budgeted amount for the budget item should 
        /// not be less than 0 after the reallocation (of both from)
        /// And make sure the item has not been inactivated
        /// </summary>
        /// <returns></returns>
        public string CheckSufficientAvailableAmount()
        {
            string listOfAccounts = "";
            DataTable dt = this.FromBudgetPeriod.GetAvailableBalanceOfAllAccounts();
            Hashtable balanceHash = new Hashtable();
            foreach (DataRow dr in dt.Rows)
                balanceHash[dr["AccountID"]] = dr["Balance"];

            foreach (OBudgetReallocationFrom from in this.BudgetReallocationFroms)
            {
                decimal balance = 0;
                if (balanceHash[from.AccountID.Value] != null)
                    balance = (decimal)balanceHash[from.AccountID.Value];

                if (balance - from.TotalAmount.Value < 0)
                    listOfAccounts += (listOfAccounts == "" ? "" : ", ") + from.Account.Path;
            }

            return listOfAccounts;
        }


        /// <summary>
        /// Check the Total Of From Budget Items is equal to Total Of To Budget Items
        /// </summary>
        /// <returns></returns>
        public bool IsEqualReallocateAmount()
        {
            return TotalFromBudgetAmount == TotalToBudgetAmount;
        }


        /*
        /// <summary>
        /// Copy BudgetReallocation to BudgetVariationLog
        /// </summary>
        public void Commit()
        {
            using (Connection c = new Connection())
            {
                if (this.IsCommitted != 1)
                {
                    foreach (OBudgetReallocationFrom from in this.BudgetReallocationFroms)
                    {
                        // Create a variation log record for each of the 
                        // intervals whose value is greater than zero.
                        //
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)from.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Reallocation;
                            log.BudgetID = this.FromBudgetID;
                            log.BudgetPeriodID = this.FromBudgetPeriodID;
                            log.AccountID = from.AccountID;
                            log.IntervalNumber = i;
                            log.VariationAmount = -changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.BudgetReallocationID = this.ObjectID;
                            log.VariationStatus = BudgetVariationStatus.Approved;
                            log.Save();
                        }
                    }

                    foreach (OBudgetReallocationTo to in this.BudgetReallocationTos)
                    {
                        // The ValidateAccountIdDoesNotExist can be used to test
                        // if the account exists in the budget period. If it does
                        // NOT exist, then an opening balance of ZERO must be
                        // created for that account.
                        //
                        bool hasValue = false;
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)to.DataRow["Interval" + (i.ToString("00")) + "Amount"];
                            if (changeValue != 0)
                                hasValue = true;
                        }
                        if (hasValue && this.ToBudgetPeriod.ValidateAccountIdDoesNotExist(to.AccountID.Value))
                        {
                            OBudgetPeriodOpeningBalance openingBalance = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                            openingBalance.BudgetPeriodID = this.ToBudgetPeriodID;
                            openingBalance.AccountID = to.AccountID;
                            openingBalance.Save();
                        }


                        // Create a variation log record for each of the 
                        // intervals whose value is greater than zero.
                        //
                        for (int i = 1; i <= 36; i++)
                        {
                            decimal changeValue = (decimal)to.DataRow["Interval" + (i.ToString("00")) + "Amount"];

                            if (changeValue == 0)
                                continue;

                            OBudgetVariationLog log = TablesLogic.tBudgetVariationLog.Create();
                            log.VariationType = BudgetVariationType.Reallocation;
                            log.BudgetID = this.ToBudgetID;
                            log.BudgetPeriodID = this.ToBudgetPeriodID;
                            log.AccountID = to.AccountID;
                            log.IntervalNumber = i;
                            log.VariationAmount = changeValue;
                            log.DateOfVariation = DateTime.Today;
                            log.BudgetReallocationID = this.ObjectID;
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
        /// Returns true if the IsCommitted flag is set to 1.
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
        public string Header01From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header02From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header03From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header04From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header05From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header06From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header07From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header08From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header09From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header10From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
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
        public string Header11From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(10);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval12Amount for Template for Reallocation From
        /// </summary>
        public string Header12From
        {
            get
            {
                DateTime startDate = this.FromBudgetPeriod.StartDate.Value;
                DateTime intervalStartDate = startDate.AddMonths(11);
                if (intervalStartDate.Day == 1)
                    return intervalStartDate.ToString("MMM-yyyy");
                else
                    return intervalStartDate.ToString("dd-MMM-yyyy");
            }
        }
        /// <summary>
        /// HeaderText of Interval01Amount for Template for Reallocation To
        /// </summary>
        public string Header01To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header02To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header03To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header04To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header05To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header06To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header07To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header08To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header09To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header10To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header11To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
        public string Header12To
        {
            get
            {
                DateTime startDate = this.ToBudgetPeriod.StartDate.Value;
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
    }
}