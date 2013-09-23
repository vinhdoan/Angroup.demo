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
    /// Represents the schema for the Activity table.
    /// </summary>
    public partial class TActivity : LogicLayerSchema<OActivity>
    {
        [Size(255)]
        public SchemaString CurrentStateName;
        [Size(255)]
        public SchemaString TriggeringEventName;
        [Size(255)]
        public SchemaString TaskName;
        [Size(255)]
        public SchemaString TaskNumber;
        [Size(255)]
        public SchemaString Description;
        [Size(1000)]
        public SchemaString TaskPreviousComments;
        [Size(1000)]
        public SchemaString TaskCurrentComments;
        public SchemaDecimal TaskAmount;
        public SchemaString ObjectTypeName;
        public SchemaGuid AttachedObjectID;
        public SchemaInt Priority;
        public SchemaDateTime ScheduledStartDateTime;
        public SchemaDateTime ScheduledEndDateTime;
        public SchemaString WorkflowInstanceID;
        public SchemaGuid ApprovalProcessID;
        //public SchemaGuid ApprovalHierarchyID;
        public SchemaInt PreviousApprovalLevel;
        public SchemaInt CurrentApprovalLevel;
        public SchemaInt LastApprovalLevel;
        public SchemaInt NextApprovalLevel;

        public SchemaGuid NotificationID;
        [Default(0)]
        public SchemaInt NumberOfApprovalsAtCurrentLevel;
        [Default(0)]
        public SchemaInt NumberOfApprovalsRequiredAtCurrentLevel;
		public SchemaInt WorkflowVersionNumber;

        // 2010.05.16
        // Kim Foong
        // Allow user the choose between skipping previous
        // approvers, or starting the approval from the first level.
        public SchemaInt SkipToLastRejectedLevel;

        // 2011.10.14, Kien Trung
        // Kien Trung
        // Allow user to choose between skipping levels of him/herself
        // as approvers, or starting the approval from the next level.
        public SchemaInt SkipToNextRequiredApprovalLevel;

        

        public TUser Users { get { return ManyToMany<TUser>("ActivityUser", "ActivityID", "UserID"); } }
        public TPosition Positions { get { return ManyToMany<TPosition>("ActivityPosition", "ActivityID", "PositionID"); } }

        public TUser ApprovedUsers { get { return ManyToMany<TUser>("ActivityApprovedUser", "ActivityID", "UserID"); } }
        public TPosition ApprovedPositions { get { return ManyToMany<TPosition>("ActivityApprovedPosition", "ActivityID", "PositionID"); } }

        
        public TApprovalProcess ApprovalProcess { get { return OneToOne<TApprovalProcess>("ApprovalProcessID"); } }
        public TApprovalHierarchy ApprovalHierarchy { get { return OneToOne<TApprovalHierarchy>("ApprovalHierarchyID"); } }
        public TNotification Notification { get { return OneToOne<TNotification>("NotificationID"); } }
    }


    /// <summary>
    /// Represents the current activity or a task of an object.
    /// </summary>
    [Serializable]
    public abstract partial class OActivity : PersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the current status name of the task.
        /// Developers are encouraged to use CurrentStateName to obtain
        /// the status name of the task instead of ObjectName,
        /// which was the Anacle.EAM v5.2 behavior.
        /// </summary>
        public abstract string CurrentStateName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name of the task.
        /// </summary>
        public abstract string TriggeringEventName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name of the task.
        /// </summary>
        public abstract string TaskName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the task number of the task. This can be used to indicate the
        /// Purchase Order number for a Purchase Order object, the Work
        /// number for a Work object.
        /// </summary> 
        public abstract string TaskNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of the task.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the comments given by the previously
        /// assigned user of the task.
        /// </summary>
        public abstract string TaskPreviousComments { get; set; }

        /// <summary>
        /// [Column] Gets or sets the comments given by the currently
        /// assigned user of the task.
        /// </summary>
        public abstract string TaskCurrentComments { get; set; }

        /// <summary>
        /// [Column] Gets or sets the amount in the base currency
        /// associated with this task. This value will only
        /// be updated during the SetStateAndAssign or 
        /// SetStateAndAssignApprovers activity.
        /// </summary>
        public abstract decimal? TaskAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets the .NET type name of the object.
        /// </summary>
        public abstract string ObjectTypeName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the ObjectID of the PersistentObject that this activity
        /// is related to.
        /// </summary>
        public abstract Guid? AttachedObjectID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the priority of the task. This will appear in the
        /// user's inbox of tasks as the priority.
        /// </summary>
        public abstract int? Priority { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date and time this task is scheduled to start.
        /// This affects when the task will appear in the user's inbox. If
        /// this date and time is set to the future, then the task will only
        /// appear after that point in time.
        /// </summary>
        public abstract DateTime? ScheduledStartDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date and time this task is scheduled to end.
        /// This affects how the task appears in the user's inbox. If this
        /// date and time is in the past, then the task will be highlight
        /// in the user's inbox as outstanding.
        /// </summary>
        public abstract DateTime? ScheduledEndDateTime { get; set; }


        /// <summary>
        /// [Column] Gets or sets the WorkflowInstanceID as generated from the
        /// Workflow Engine.
        /// </summary>
        public abstract string WorkflowInstanceID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the WorkflowVersionNumber as used by the
        /// Workflow Engine.
        /// </summary>
        public abstract int? WorkflowVersionNumber { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the ApprovalProcessDetail table. 
        /// When performing a workflow transition in the user interface,
        /// the objectPanel will pop-up a workflow dialog for the user
        /// to select the appropriate approval process detail. The selection
        /// will populate this property.
        /// <para></para>
        /// Otherwise, this property must be set before calling Transit into 
        /// an event that leads to an approval state.
        /// <para></para>
        /// </summary>
        public abstract Guid? ApprovalProcessID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the ApprovalHierarchy
        /// that represents the hierarchy of users/roles configured
        /// to approve this object.
        /// </summary>
        //public abstract Guid? ApprovalHierarchyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the previous approval level in the
        /// approval hierarchy. 
        /// </summary>
        public abstract int? PreviousApprovalLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the current approval level in the
        /// approval hierarchy. 
        /// </summary>
        public abstract int? CurrentApprovalLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the last level this task was approved.
        /// This value is always updated when after an approval, and is
        /// never reset to 1 when the task is rejected.
        /// <para></para>
        /// This is used for the if the Mode of Forwarding is 
        /// Hierarchical with Skipping, so that a rejected task re-submitted
        /// for approval continues on at the previously approved level.
        /// </summary>
        public abstract int? LastApprovalLevel { get; set; }


        public abstract int? NextApprovalLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Notification
        /// table that indicates the notification process tied
        /// to this object.
        /// </summary>
        public abstract Guid? NotificationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of approvals
        /// already given at the current level.
        /// </summary>
        public abstract int? NumberOfApprovalsAtCurrentLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of approvals
        /// required at the current level.
        /// </summary>
        public abstract int? NumberOfApprovalsRequiredAtCurrentLevel { get; set; }

        // 2010.05.16
        // Kim Foong
        // Allow user the choose between skipping previous
        // approvers, or starting the approval from the first level.
        /// <summary>
        /// [Column] Gets or sets a flag to indicate that the
        /// approval should skip to the last level that rejected
        /// this task.
        /// </summary>
        public abstract int? SkipToLastRejectedLevel { get; set; }

        public abstract int? SkipToNextRequiredApprovalLevel { get; set; }

        /// <summary>
        /// Gets a list of users who are assigned to this task.
        /// </summary>
        public abstract DataList<OUser> Users { get; }

        /// <summary>
        /// Gets a list of users who have approved this task.
        /// </summary>
        public abstract DataList<OUser> ApprovedUsers { get; }

        /// <summary>
        /// Gets a list of position who have approved this task.
        /// </summary>
        public abstract DataList<OPosition> ApprovedPositions { get; }



        /// <summary>
        /// Gets a list positions that are assigned to this task.
        /// </summary>
        public abstract DataList<OPosition> Positions { get; }

        /// <summary>
        /// Gets or sets the OApprovalProcess object that
        /// represents the approval process selected by
        /// the user on the user interface to indicate the
        /// approval hierarchy to be used for the approval of
        /// this object.
        /// </summary>
        public abstract OApprovalProcess ApprovalProcess { get; set; }


        /// <summary>
        /// Gets or sets the OApprovalHierarchy object 
        /// that represents the hierarchy of users/roles configured
        /// to approve this object.
        /// </summary>
        public abstract OApprovalHierarchy ApprovalHierarchy { get; set; }

        /// <summary>
        /// Gets or sets the ONotification object that
        /// represents the notification details.
        /// </summary>
        public abstract ONotification Notification { get; set; }


        /// <summary>
        /// Determines if this activity is assigned to the 
        /// specified user, or to one of the positions 
        /// held by the specified user.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public bool IsAssignedToUser(OUser user)
        {
            if (Users.FindObject(user.ObjectID.Value) != null)
                return true;

            foreach (OPosition position in user.Positions)
                if (this.Positions.FindObject(position.ObjectID.Value) != null)
                    return true;

            return false;
        }


        /// <summary>
        /// Gets a distinct list of statuses applicable to the
        /// specified object type.
        /// </summary>
        /// <returns></returns>
        public static DataTable GetStatuses(string objectTypeName)
        {
            return TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.ObjectName)
                .Where(
                (objectTypeName == null || objectTypeName == "") ?
                Query.True :
                TablesLogic.tActivity.ObjectTypeName == objectTypeName);
        }


        /// <summary>
        /// Gets a list of activities that should appear in month view
        /// calendar for the specified month in a DataTable form.
        /// </summary>
        /// <param name="userBase">The UserBase object of the user
        /// who is currently logged on.</param>
        /// <param name="year">The year that the calendar will display.</param>
        /// <param name="month">The month that the calendar will display</param>
        /// <returns>A DataTable of activities.</returns>
        public static DataTable GetMonthActivities(OUser user, int year, int month)
        {
            DateTime monthStart = new DateTime(year, month, 1);
            DateTime monthEnd = new DateTime(year, month, 1).AddMonths(1);

            return Query.SelectDistinct(
                TablesLogic.tActivity.ObjectID,
                TablesLogic.tActivity.AttachedObjectID,
                TablesLogic.tActivity.ObjectName.As("Status"),
                TablesLogic.tActivity.ScheduledStartDateTime,
                TablesLogic.tActivity.ScheduledEndDateTime,
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.TaskName,
                TablesLogic.tActivity.TaskNumber,
                TablesLogic.tActivity.Description,
                TablesLogic.tActivity.Priority)
                .Where(
                TablesLogic.tActivity.IsDeleted == 0 &
                TablesLogic.tActivity.ScheduledStartDateTime < monthEnd &
                TablesLogic.tActivity.ScheduledEndDateTime >= monthStart &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)))
                .OrderBy(
                TablesLogic.tActivity.TaskNumber.Asc);
        }


        /// <summary>
        /// Queries the database and returns a table of activities assigned to the
        /// currently logged on user. This table is to be used
        /// and bound to the inbox gridTasks grid view.
        /// </summary>
        /// <param name="userBase">The OUserBase object of the currently logged on user.</param>
        /// <param name="dateTime">The date/time at which point to query the table.</param>
        /// <returns>A DataTable of tasks.</returns>
        public static DataTable GetOutstandingActivitiesForInbox_Orignal(OUser user, DateTime dateTime,
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
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)))
                .OrderBy(
                TablesLogic.tActivity.ScheduledEndDateTime.Asc);

        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="startDate"></param>
        /// <returns></returns>
        public static DataTable GetCalendarTaskCount(OUser user, DateTime calendarStartDate)
        {
            DateTime calendarEndDate = calendarStartDate.AddDays(41);
            DateTime monthStart = new DateTime(calendarStartDate.AddMonths(1).Year, calendarStartDate.AddMonths(1).Month, 1);
            DateTime monthEnd = monthStart.AddMonths(1);

            DataTable dt = TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.ObjectID,
                TablesLogic.tActivity.ScheduledStartDateTime.Date().As("StartDate"),
                TablesLogic.tActivity.ScheduledEndDateTime.Date().As("EndDate")
                )
                .Where(
                TablesLogic.tActivity.IsDeleted == 0 &
                ((TablesLogic.tActivity.ScheduledStartDateTime.Date() >= monthStart &
                TablesLogic.tActivity.ScheduledStartDateTime.Date() < monthEnd) |
                (TablesLogic.tActivity.ScheduledEndDateTime.Date() >= monthStart &
                TablesLogic.tActivity.ScheduledEndDateTime.Date() < monthEnd) |
                (TablesLogic.tActivity.ScheduledStartDateTime.Date() < monthStart &
                TablesLogic.tActivity.ScheduledStartDateTime.Date() >= monthEnd)) &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)));

            // Construct a table of 42 number of counts.
            //
            DataTable dt2 = new DataTable();
            dt2.Columns.Add("count", typeof(int));
            for (int i = 0; i < 42; i++)
                dt2.Rows.Add(0);

            foreach (DataRow dr in dt.Rows)
            {
                DateTime taskStart = dr["StartDate"] == DBNull.Value ? DateTime.MinValue : (DateTime)dr["StartDate"];
                DateTime taskEnd = dr["EndDate"] == DBNull.Value ? DateTime.MaxValue : (DateTime)dr["EndDate"];
                if (taskStart < calendarStartDate)
                    taskStart = calendarStartDate;
                for (DateTime taskDate = taskStart;
                    taskDate <= taskEnd && taskDate <= calendarEndDate;
                    taskDate = taskDate.AddDays(1))
                {
                    int c = taskDate.Subtract(calendarStartDate).Days;
                    dt2.Rows[c][0] = 1;
                }
            }

            return dt2;
        }


        /// <summary>
        /// Queries the database and returns a table of task type 
        /// </summary>
        /// <returns></returns>
        public static DataTable GetTaskTypeTable()
        {
            DataTable dt =
                TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.ObjectTypeName.As("TaskType"))
                .Where(
                TablesLogic.tActivity.IsDeleted == 0);

            List<OFunction> functions = OFunction.GetAllFunctions();
            Hashtable functionHash = new Hashtable();
            foreach (OFunction function in functions)
                functionHash[function.ObjectTypeName] = function;

            foreach (DataRow dr in dt.Rows)
            {
                OFunction function = functionHash[dr["TaskType"]] as OFunction;
                if (function != null)
                    dr["TaskType"] = function.FunctionName;
            }
            return dt;
        }

        public static DataTable GetPriority()
        {
            DataTable dt =
                TablesLogic.tActivity.SelectDistinct(
                TablesLogic.tActivity.Priority)
                .Where(
                TablesLogic.tActivity.IsDeleted == 0);
            return dt;
        }

        /// <summary>
        /// Gets the total number of of outstanding tasks grouped by
        /// object type and the status.
        /// </summary>
        /// <returns></returns>
        public static DataTable GetOutstandingTasksGroupedByObjectTypeAndStatus_Original(OUser user, DateTime dateTime)
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
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)))
                .GroupBy(
                TablesLogic.tActivity.ObjectTypeName,
                TablesLogic.tActivity.ObjectName)
                .OrderBy(
                TablesLogic.tActivity.ObjectTypeName.Asc,
                TablesLogic.tActivity.ObjectName.Asc);
        }


        /// <summary>
        /// Gets all outstanding tasks assigned to the user and applicable
        /// to 
        /// </summary>
        /// <returns></returns>
        public static DataTable GetOutstandingTasksAtDate_Orginal(OUser user, DateTime dateTime, string search)
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
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)))
                .OrderBy(
                TablesLogic.tActivity.ScheduledEndDateTime.Asc);
        }





        /// <summary>
        /// Returns an integer to indicate whether this activity is late.
        /// </summary>
        /// <returns>Returns 1 if late, 0 otherwise.</returns>
        public int IsLate()
        {
            return ScheduledEndDateTime <= DateTime.Now ? 1 : 0;
        }


        /// <summary>
        /// Returns a flag indicating if an object
        /// is or is not assigned to the current user.
        /// </summary>
        /// <returns></returns>
        public static bool CheckAssignment(OUser user, Guid? objectId)
        {
            int count = TablesLogic.tActivity.Select(
                TablesLogic.tActivity.ObjectID.Count())
                .Where(
                TablesLogic.tActivity.AttachedObjectID == objectId &
                TablesLogic.tActivity.IsDeleted == 0 &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)));

            return count > 0;
        }


        /// <summary>
        /// Returns a hashtable of boolean flags indicating if an object
        /// is or is not assigned to the current user. This is used by
        /// the search panel to find out the list of tasks assigned to 
        /// the current user, by using a single query.
        /// </summary>
        /// <returns></returns>
        public static Hashtable GetAssignmentHash(OUser user, List<Guid> objectIds)
        {
            DataTable dt = TablesLogic.tActivity.Select(
                TablesLogic.tActivity.AttachedObjectID)
                .Where(
                TablesLogic.tActivity.AttachedObjectID.In(objectIds) &
                TablesLogic.tActivity.IsDeleted == 0 &
                (TablesLogic.tActivity.Users.ObjectID == user.ObjectID |
                TablesLogic.tActivity.Positions.ObjectID.In(user.Positions)));

            Hashtable ht = new Hashtable();
            foreach (DataRow dr in dt.Rows)
                ht[dr["AttachedObjectID"]] = 1;

            return ht;
        }

        public string GetUserListByActivity(OActivity act)
        {
            string userList = "";
            if (act != null)
                foreach (OUser user in act.Users)
                    userList = userList == "" ? userList + user.ObjectName : userList + ", " + user.ObjectName;
            return userList;
        }

        public static List<OActivity> GetTasks(List<object> objectIds)
        {
            if (objectIds != null)
            {
                List<Guid> listOfIds = new List<Guid>();

                foreach (Guid id in objectIds)
                    listOfIds.Add(id);

                List<OActivity> activitylist = TablesLogic.tActivity.LoadList(
                    TablesLogic.tActivity.ObjectID.In(listOfIds));
                return activitylist;
            }
            else
                return null;
        }

        /// <summary>
        /// Removes the current assigned users and/or positions
        /// Assigns the specified users and/or positions 
        /// </summary>
        /// <param name="act"></param>
        /// <param name="users"></param>
        /// <param name="positions"></param>
        /// <returns></returns>
        public static bool SaveTaskReassignment(OActivity act, List<OUser> users, List<OPosition> positions, List<OPosition> secretaries)
        {
            using (Connection c = new Connection())
            {
                if (users != null)
                {
                    act.Users.Clear();

                    foreach (OUser user in users)
                        act.Users.Add(user);
                }

                if (positions != null)
                {
                    act.Positions.Clear();

                    foreach (OPosition position in positions)
                        act.Positions.Add(position);
                }

                if (secretaries != null)
                {
                    act.SecretaryPositions.Clear();
                    foreach (OPosition position in secretaries)
                    {
                        act.Positions.Add(position);
                        act.SecretaryPositions.Add(position);
                    }
                }

                act.Save();
                c.Commit();
                return true;
            }
        }


    }
}
