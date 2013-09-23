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
    /// Summary description for OBudget
    /// </summary>
    [Serializable] 
    public partial class TBudget : LogicLayerSchema<OBudget>
    {
        public SchemaGuid NotifyUser1ID;
        public SchemaGuid NotifyUser2ID;
        public SchemaGuid NotifyUser3ID;
        public SchemaGuid NotifyUser4ID;

        [Default(12)]
        public SchemaInt DefaultNumberOfMonthsPerBudgetPeriod;
        [Default(1)]
        public SchemaInt DefaultNumberOfMonthsPerInterval;

        public TUser NotifyUser1 { get { return OneToOne<TUser>("NotifyUser1ID"); } }
        public TUser NotifyUser2 { get { return OneToOne<TUser>("NotifyUser2ID"); } }
        public TUser NotifyUser3 { get { return OneToOne<TUser>("NotifyUser3ID"); } }
        public TUser NotifyUser4 { get { return OneToOne<TUser>("NotifyUser4ID"); } }

        public TLocation ApplicableLocations { get { return ManyToMany<TLocation>("BudgetLocation", "BudgetID", "LocationID"); } }
        public TBudgetPeriod BudgetPeriods { get { return OneToMany<TBudgetPeriod>("BudgetID"); } }
    }


    [Serializable] 
    public abstract partial class OBudget : LogicLayerPersistentObject
    {
        public abstract Guid? NotifyUser1ID { get; set; }
        public abstract Guid? NotifyUser2ID { get; set; }
        public abstract Guid? NotifyUser3ID { get; set; }
        public abstract Guid? NotifyUser4ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of months a
        /// budget period under this budget is valid for. 
        /// The default is 12.
        /// </summary>
        public abstract int? DefaultNumberOfMonthsPerBudgetPeriod { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of months
        /// an interval in a budget period.
        /// </summary>
        public abstract int? DefaultNumberOfMonthsPerInterval { get; set; }

        public abstract OUser NotifyUser1 { get; set; }
        public abstract OUser NotifyUser2 { get; set; }
        public abstract OUser NotifyUser3 { get; set; }
        public abstract OUser NotifyUser4 { get; set; }

        public abstract DataList<OLocation> ApplicableLocations { get; }
        public abstract DataList<OBudgetPeriod> BudgetPeriods { get; }

        /// <summary>
        /// Disallows deactivation if there is at least one
        /// budget period in this budget.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            // 2010.05.13
            // Kim Foong
            // Allow deletion if there are no active budget periods,
            // (excluding those that are deleted, or cancelled)
            //
            if (TablesLogic.tBudgetPeriod.Select(
                TablesLogic.tBudgetPeriod.ObjectID.Count())
                .Where(
                TablesLogic.tBudgetPeriod.BudgetID == this.ObjectID &
                TablesLogic.tBudgetPeriod.IsDeleted == 0 &
                TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName != "Cancelled") > 0)
                return false;

            return true;
        }


        /// <summary>
        /// Gets a list of all budgets in the system.
        /// </summary>
        /// <returns></returns>
        public static List<OBudget> GetAllBudgets(Guid? includingBudgetId)
        {
            return TablesLogic.tBudget.LoadList(
                TablesLogic.tBudget.IsDeleted == 0 |
                TablesLogic.tBudget.ObjectID == includingBudgetId, true);
        }


        /// <summary>
        /// Gets a list of all accessible budgets.
        /// </summary>
        /// <param name="user"></param>
        /// <param name="includingBudgetId"></param>
        /// <returns></returns>
        public static List<OBudget> GetAccessibleBugets(OUser sessionUser, Guid? includingBudgetId, string objectType)
        {
            List<Guid> accessibleBudgetIds = GetAccessibleBudgetIDs(sessionUser, objectType);

            return TablesLogic.tBudget.LoadList(
                TablesLogic.tBudget.ObjectID.In(accessibleBudgetIds) |
                TablesLogic.tBudget.ObjectID==includingBudgetId, 
                true);
        }


        /// <summary>
        /// Gets a list of budgets at or under the location of the specified
        /// location ID.
        /// </summary>
        /// <param name="locationId"></param>
        /// <param name="includingBudgetId"></param>
        /// <returns></returns>
        public static List<OBudget> GetBudgetsByLocationID(Guid? locationId, Guid? includingBudgetId)
        {
            OLocation location = TablesLogic.tLocation.Load(locationId);

            TBudget budget = TablesLogic.tBudget;
            TBudget budget2 = new TBudget();
            List<OBudget> budgets = budget.LoadList(
                // where condition
                budget.ApplicableLocations.HierarchyPath.Like(location.HierarchyPath+"%"),
                // having condition
                budget.ApplicableLocations.ObjectID.Count() >=
                budget2.Select(budget2.ApplicableLocations.ObjectID.Count()).Where(budget2.ObjectID == budget.ObjectID), 
                false);

            foreach (OBudget b in budgets)
            {
                if (b.ObjectID == includingBudgetId)
                    return budgets;
            }

            OBudget includingBudget = TablesLogic.tBudget.Load(
                TablesLogic.tBudget.ObjectID == includingBudgetId, true);

            if(includingBudget != null)
                budgets.Add(includingBudget);

            return budgets;

        }


        /// <summary>
        /// Gets a list of budget IDs accessible by the specified user.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static List<Guid> GetAccessibleBudgetIDs(OUser sessionUser, string objectType)
        {
            TBudget budget = TablesLogic.tBudget;
            TBudget budget2 = new TBudget();
            TUser user = TablesLogic.tUser;

            DataTable dt = 
                budget.Select(
                    budget.ObjectID)
                .Where(
                    user.Select(user.ObjectID)
                    .Where(
                        budget.ApplicableLocations.HierarchyPath.Like(user.Positions.LocationAccess.HierarchyPath + "%") &
                        user.Positions.Role.RoleFunctions.Function.ObjectTypeName == objectType &
                        user.ObjectID == sessionUser.ObjectID).Exists())
                .Having(
                    budget.ApplicableLocations.ObjectID.Count() >=
                    budget2.Select(budget2.ApplicableLocations.ObjectID.Count()).
                    Where(budget2.ObjectID == budget.ObjectID))
                .GroupBy(
                    budget.ObjectID);

            List<Guid> ids = new List<Guid>();
            foreach (DataRow dr in dt.Rows)
                ids.Add((Guid)dr["ObjectID"]);

            return ids;
        }


        /// <summary>
        /// Gets a list of budget IDs accessible under the specified location.
        /// </summary>
        /// <param name="location"></param>
        /// <returns></returns>
        public static List<Guid> GetAccessibleBudgetIDs(OLocation location)
        {
            TBudget budget = TablesLogic.tBudget;
            TBudget budget2 = new TBudget();

            DataTable dt =
                budget.Select(
                    budget.ObjectID)
                .Where(
                    budget.ApplicableLocations.HierarchyPath.Like(location.HierarchyPath + "%"))
                .Having(
                    budget.ApplicableLocations.ObjectID.Count() >=
                    budget2.Select(budget2.ApplicableLocations.ObjectID.Count()).Where(budget2.ObjectID == budget.ObjectID))
                .GroupBy(
                    budget.ObjectID);

            List<Guid> ids = new List<Guid>();
            foreach (DataRow dr in dt.Rows)
                ids.Add((Guid)dr["ObjectID"]);

            return ids;
        }

        /// <summary>
        /// Gets a list of budget IDs that cover *at least one* of
        /// the specified list of locations.
        /// </summary>
        /// <param name="location"></param>
        /// <returns></returns>
        public static List<Guid> GetCoveringBudgetIDs(List<OLocation> locations)
        {
            TBudget budget = TablesLogic.tBudget;
            TBudget budget2 = new TBudget();

            ExpressionCondition cond = Query.False;

            foreach (OLocation location in locations)
                cond = cond | location.HierarchyPath.Like(budget.ApplicableLocations.HierarchyPath + "%");
            DataTable dt =
                budget.Select(budget.ObjectID).Where(cond);

            List<Guid> ids = new List<Guid>();
            foreach (DataRow dr in dt.Rows)
                ids.Add((Guid)dr["ObjectID"]);

            return ids;
        }


        /// <summary>
        /// Gets a list of budget IDs that cover the specified location.
        /// </summary>
        /// <param name="location"></param>
        /// <returns></returns>
        public static List<Guid> GetCoveringBudgetIDs(OLocation location)
        {
            TBudget budget = TablesLogic.tBudget;
            TBudget budget2 = new TBudget();

            DataTable dt =
                budget.Select(
                    budget.ObjectID)
                .Where(
                    location.HierarchyPath.Like(budget.ApplicableLocations.HierarchyPath + "%"));

            List<Guid> ids = new List<Guid>();
            foreach (DataRow dr in dt.Rows)
                ids.Add((Guid)dr["ObjectID"]);

            return ids;
        }


        /// <summary>
        /// Gets a list of budget objects that cover the selected location.
        /// </summary>
        /// <param name="location"></param>
        /// <returns></returns>
        public static List<OBudget> GetCoveringBudgets(OLocation location, Guid? includingBudgetId)
        {
            return TablesLogic.tBudget.LoadList(
                (TablesLogic.tBudget.IsDeleted == 0 &
                TablesLogic.tBudget.ObjectID.In(GetCoveringBudgetIDs(location)))
                |
                TablesLogic.tBudget.ObjectID == includingBudgetId,
                true
                );
        }

        /// <summary>
        /// Gets a list of budget objects that cover *at least one* of 
        /// the selected list of locations.
        /// </summary>
        /// <param name="location"></param>
        /// <returns></returns>
        public static List<OBudget> GetCoveringBudgets(List<OLocation> location, Guid? includingBudgetId)
        {
            return TablesLogic.tBudget.LoadList(
                (TablesLogic.tBudget.IsDeleted == 0 &
                TablesLogic.tBudget.ObjectID.In(GetCoveringBudgetIDs(location)))
                |
                TablesLogic.tBudget.ObjectID == includingBudgetId,
                true
                );
        }

    }
}
