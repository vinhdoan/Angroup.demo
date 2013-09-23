//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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
    /// Represents the schema for the Activity table.
    /// </summary>
    public partial class  TActivity : LogicLayerSchema<OActivity>
    {
        [Size(255)]
        public SchemaString ApprovedOnBehalfOfUser;

        public TUser CarbonCopyUsers { get { return ManyToMany<TUser>("ActivityCarbonCopyUser", "ActivityID", "UserID"); } }
        public TPosition SecretaryPositions { get { return ManyToMany<TPosition>("ActivitySecretaryPosition", "ActivityID", "PositionID"); } }
        public SchemaGuid ApprovedByUserID;
        public SchemaDecimal PreviousTaskAmount;
        

    }


    /// <summary>
    /// Represents the current activity or a task of an object.
    /// </summary>
    public abstract partial class OActivity : PersistentObject
    {
        /// <summary>
        /// Gets or sets the name of the user this task was
        /// approved on behalf of.
        /// </summary>
        public abstract string ApprovedOnBehalfOfUser { get; set; }
        public abstract Decimal? PreviousTaskAmount { get; set; }
        bool isForApprove = false;
        /// <summary>
        /// Gets a list of users who have copied this task.
        /// </summary>
        public abstract DataList<OUser> CarbonCopyUsers { get; }


        /// <summary>
        /// Gets a list of users who are assigned to this task.
        /// </summary>
        public abstract DataList<OPosition> SecretaryPositions { get; }
        public abstract Guid? ApprovedByUserID { get; set; }
        public string AssignedUserText
        {
            get
            {
                string userString = string.Empty;

                foreach (OUser u in Users)
                {
                    if (userString.Trim().Length == 0)
                        userString = u.ObjectName;
                    else
                        userString += ", " + u.ObjectName;
                }

                return userString;

            }
        }

        public string AssignedPositionText
        {
            get
            {
                string positionString = string.Empty;

                foreach (OPosition p in Positions)
                {
                    if (positionString.Trim().Length == 0)
                        positionString = p.ObjectName;
                    else
                        positionString += ", " + p.ObjectName;
                }

                return positionString;;

            }
        }
        public string AssignedUserPositionsWithUserNamesText
        {
            get
            {
                string positionUserName = "";
                foreach (OPosition p in Positions)
                {
                    if (positionUserName.Trim().Length == 0)
                        positionUserName = p.PositionNameWithUserNames;
                    else
                        positionUserName += ", " + p.PositionNameWithUserNames;
                }

                return positionUserName;
            }
        }

        public bool IsForApprove
        {
            get { return isForApprove; }
            set { isForApprove = value; }
        }

        /// <summary>
        /// Gets the total number of of outstanding tasks grouped by
        /// object type and the status.
        /// </summary>
        /// <returns></returns>
        public static DataTable GetOutstandingTasksGroupedByObjectTypeAndStatus(OUser user, DateTime dateTime, params string[] itemsStatus)
        {
            TActivity b = SchemaFactory.Get<TActivity>();

            return TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.ObjectName,
                TablesLogic.tActivity.TaskNumber,
                TablesLogic.tActivity.TaskName,
                TablesLogic.tActivity.ObjectID.CountDistinct().As("Count"))
                .Where(
                TablesLogic.tActivity.ObjectName != null &
                TablesLogic.tActivity.ObjectTypeName != null &
                TablesLogic.tActivity.IsDeleted == 0 &
                TablesLogic.tActivity.ScheduledStartDateTime <= dateTime &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)) &
                TablesLogic.tActivity.CurrentStateName.In(itemsStatus))
                .GroupBy(
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.ObjectName,
                TablesLogic.tActivity.TaskNumber,
                TablesLogic.tActivity.TaskName)
                .OrderBy(
                TablesLogic.tActivity.ObjectTypeName.Asc,
                TablesLogic.tActivity.ObjectName.Asc,
                TablesLogic.tActivity.TaskNumber.Asc,
                TablesLogic.tActivity.TaskName.Asc);
        }

        /// <summary>
        /// caleb. Get Distinct Users for activities
        /// Have to return userList for framework method signature
        /// </summary>
        /// <returns></returns>
        public static List<OUser> GetDistinctUserForActivities()
        {

            return TablesLogic.tUser.LoadList((TablesLogic.tUser.ObjectID.In(TablesLogic.tActivity.Select(
                TablesLogic.tActivity.Users.ObjectID)) |
                    TablesLogic.tUser.Positions.ObjectID.In(TablesLogic.tActivity.Select(TablesLogic.tActivity.Positions.ObjectID))));

        }

    }
}
