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
        public TPosition LastApprovedPositions { get { return ManyToMany<TPosition>("ActivityLastApprovedPosition", "ActivityID", "PositionID"); } }
        public TUser LastApprovedUsers { get { return ManyToMany<TUser>("ActivityLastApprovedUser", "ActivityID", "UserID"); } }
    }


    /// <summary>
    /// Represents the current activity or a task of an object.
    /// </summary>
    public abstract partial class OActivity : PersistentObject
    {
        public abstract DataList<OPosition> LastApprovedPositions { get; }
        public abstract DataList<OUser> LastApprovedUsers { get; set; }

        /// <summary>
        /// Gets all outstanding tasks assigned to the user and applicable
        /// to 
        /// </summary>
        /// <returns></returns>
        public static DataTable GetOutstandingTasksAtDate(OUser user, DateTime dateTime, string search)
        {
            TActivity b = SchemaFactory.Get<TActivity>();

            return
                TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.ObjectID,
                TablesLogic.tActivity.AttachedObjectID,
                TablesLogic.tActivity.ObjectName.As("Status"),
                TablesLogic.tActivity.ScheduledStartDateTime,
                TablesLogic.tActivity.ScheduledEndDateTime,
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.TaskAmount,
                TablesLogic.tActivity.TaskName,
                TablesLogic.tActivity.TaskNumber,
                TablesLogic.tActivity.Description,
                TablesLogic.tActivity.CreatedUser,
                TablesLogic.tActivity.CreatedDateTime,
                TablesLogic.tActivity.Priority)
                .Where(
                TablesLogic.tActivity.IsDeleted == 0 &
                (TablesLogic.tActivity.TaskName.Like(search) |
                TablesLogic.tActivity.TaskNumber.Like(search)) &
                TablesLogic.tActivity.ScheduledStartDateTime.Date() <= dateTime &
                TablesLogic.tActivity.ScheduledEndDateTime.Date() >= dateTime &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)) &
                (TablesLogic.tActivity.ApprovedUsers.ObjectID == null | TablesLogic.tActivity.ApprovedUsers.ObjectID != user.ObjectID))
                .OrderBy(
                TablesLogic.tActivity.ScheduledEndDateTime.Asc);
        }

        /// <summary>
        /// Queries the database and returns a table of activities assigned to the
        /// currently logged on user. This table is to be used
        /// and bound to the inbox gridTasks grid view.
        /// </summary>
        /// <param name="userBase">The OUserBase object of the currently logged on user.</param>
        /// <param name="dateTime">The date/time at which point to query the table.</param>
        /// <returns>A DataTable of tasks.</returns>
        public static DataTable GetOutstandingActivitiesForInbox(OUser user, DateTime dateTime,
            string objectTypeName, string status, string search)
        {
            return
                TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.ObjectID,
                TablesLogic.tActivity.AttachedObjectID,
                TablesLogic.tActivity.ObjectName.As("Status"),
                TablesLogic.tActivity.ScheduledStartDateTime,
                TablesLogic.tActivity.ScheduledEndDateTime,
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.TaskAmount,
                TablesLogic.tActivity.TaskName,
                TablesLogic.tActivity.TaskNumber,
                TablesLogic.tActivity.CreatedUser,
                TablesLogic.tActivity.CreatedDateTime,
                TablesLogic.tActivity.Description,
                TablesLogic.tActivity.Priority)
                .Where(
                TablesLogic.tActivity.ObjectTypeName != null &
                TablesLogic.tActivity.ObjectTypeName.Like(objectTypeName) &
                TablesLogic.tActivity.ObjectName != null &
                TablesLogic.tActivity.ObjectName.Like(status) &
                (TablesLogic.tActivity.TaskName.Like(search) |
                TablesLogic.tActivity.TaskNumber.Like(search) |
                TablesLogic.tActivity.CreatedUser.Like(search)) &
                TablesLogic.tActivity.IsDeleted == 0 &
                TablesLogic.tActivity.ScheduledStartDateTime <= dateTime &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)) &
                (TablesLogic.tActivity.ApprovedUsers.ObjectID == null | TablesLogic.tActivity.ApprovedUsers.ObjectID != user.ObjectID))
                .OrderBy(
                TablesLogic.tActivity.ScheduledEndDateTime.Asc);

        }
        /// <summary>
        /// Gets the total number of of outstanding tasks grouped by
        /// object type and the status.
        /// </summary>
        /// <returns></returns>
        public static DataTable GetOutstandingTasksGroupedByObjectTypeAndStatus(OUser user, DateTime dateTime)
        {
            TActivity b = SchemaFactory.Get<TActivity>();

            return TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.ObjectName,
                TablesLogic.tActivity.ObjectID.CountDistinct().As("Count"))
                .Where(
                TablesLogic.tActivity.ObjectName != null &
                TablesLogic.tActivity.ObjectTypeName != null &
                TablesLogic.tActivity.IsDeleted == 0 &
                TablesLogic.tActivity.ScheduledStartDateTime <= dateTime &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)) &
                (TablesLogic.tActivity.ApprovedUsers.ObjectID == null | TablesLogic.tActivity.ApprovedUsers.ObjectID != user.ObjectID))
                .GroupBy(
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.ObjectName)
                .OrderBy(
                TablesLogic.tActivity.ObjectTypeName.Asc,
                TablesLogic.tActivity.ObjectName.Asc);
        }
    }
}
