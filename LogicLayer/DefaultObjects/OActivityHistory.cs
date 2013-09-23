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
    /// Represents the schema for the ActivityHistory table.
    /// </summary>
    public partial class TActivityHistory : LogicLayerSchema<OActivityHistory>
    {
        /// <summary>
        /// Represents the column for the current status name of the task.
        /// </summary>
        [Size(255)]
        public SchemaString CurrentStateName;

        /// <summary>
        /// Represents the column for the event name that triggered
        /// this action.
        /// </summary>
        [Size(255)]
        public SchemaString TriggeringEventName;

        /// <summary>
        /// Represents the column for the name of the task.
        /// </summary>
        [Size(255)]
        public SchemaString TaskName;

        /// <summary>
        /// Represents the column for the task number of the task. 
        /// </summary>
        [Size(255)]
        public SchemaString TaskNumber;

        /// <summary>
        /// Represents the column for the description of the task.
        /// </summary>
        [Size(255)]
        public SchemaString Description;

        /// <summary>
        /// Represents the column for the comments given by the previously
        /// assigned user of the task.
        /// </summary>
        [Size(1000)]
        public SchemaString TaskPreviousComments;

        /// <summary>
        /// Represents the column for the .NET type name of the object.
        /// </summary>
        public SchemaString ObjectTypeName;

        /// <summary>
        /// Represents the column for the ObjectID of the PersistentObject 
        /// that this activity is related to.
        /// </summary>
        public SchemaGuid AttachedObjectID;
        
        /// <summary>
        /// Represents the column for the priority of the task. This 
        /// will appear in the user's inbox of tasks as the priority.
        /// </summary>
        public SchemaInt Priority;

        public SchemaInt PreviousApprovalLevel;
        public SchemaInt CurrentApprovalLevel;

        /// <summary>
        /// Represents the column for the date and time this task is
        /// scheduled to start.
        /// </summary>
        public SchemaDateTime ScheduledStartDateTime;

        /// <summary>
        /// Represents the column for the date and time this task is 
        /// scheduled to end.
        /// </summary>
        public SchemaDateTime ScheduledEndDateTime;

        /// <summary>
        /// Represents the column for the WorkflowInstanceID as generated from the
        /// Workflow Engine.
        /// </summary>
        public SchemaString WorkflowInstanceID;

        /// <summary>
        /// Represents the type represented by this activity history.
        /// <list>
        ///     <item>0 - State Transition</item>
        ///     <item>1 - User Reassignment</item>
        /// </list>
        /// </summary>
        public SchemaInt HistoryType;

        /// <summary>
        /// Represents a many-to-many join to the User table.
        /// </summary>
        public TUser Users { get { return ManyToMany<TUser>("ActivityHistoryUser", "ActivityHistoryID", "UserID"); } }

        /// <summary>
        /// Represents a many-to-many join to the Role table.
        /// </summary>
        public TPosition Positions { get { return ManyToMany<TPosition>("ActivityHistoryPosition", "ActivityHistoryID", "PositionID"); } }

    }


    /// <summary>
    /// Represents one or more activities or tasks of a persistent object
    /// stored as a history in this ActivityHistory table.
    /// </summary>
    [Serializable]
    public abstract partial class OActivityHistory : PersistentObject
    {
        /// <summary>
        /// Gets or sets the current status name of the task.
        /// Developers are encouraged to use CurrentStateName to obtain
        /// the status name of the task instead of ObjectName,
        /// which was the Anacle.EAM v5.2 behavior.
        /// </summary>
        public abstract string CurrentStateName { get; set; }

        /// <summary>
        /// Gets or sets the event name triggered by the user or
        /// the system that resulted in the workflow entering
        /// the current state.
        /// </summary>
        public abstract string TriggeringEventName { get; set; }

        /// <summary>
        /// Gets or sets the name of the task.
        /// </summary>
        public abstract string TaskName { get; set; }

        /// <summary>
        /// Gets or sets the task number of the task. This can be used to indicate the
        /// Purchase Order number for a Purchase Order object, the Work
        /// number for a Work object.
        /// </summary>
        public abstract string TaskNumber { get; set; }

        /// <summary>
        /// Gets or sets the description of the task.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// Gets or sets the comments given by the previously
        /// assigned user of the task.
        /// </summary>
        public abstract string TaskPreviousComments { get; set; }

        /// <summary>
        /// Gets or sets the .NET type name of the object.
        /// </summary>
        public abstract string ObjectTypeName { get; set; }

        /// <summary>
        /// Gets or sets the ObjectID of the PersistentObject that this activity
        /// is related to.
        /// </summary>
        public abstract Guid? AttachedObjectID { get; set; }

        /// <summary>
        /// Gets or sets the priority of the task. This will appear in the
        /// user's inbox of tasks as the priority.
        /// </summary>
        public abstract int? Priority { get; set; }

        /// <summary>
        /// [Column] Gets or sets the approval level of the approver
        /// that approved the object. 
        /// <para></para>
        /// If this is not an approval in 
        /// the approval process, this value will be null.
        /// </summary>
        public abstract int? PreviousApprovalLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the approval level of the approver
        /// that will be approving the object. 
        /// <para></para>
        /// If this is not an approval in 
        /// the approval process, this value will be null.
        /// </summary>
        public abstract int? CurrentApprovalLevel { get; set; }

        /// <summary>
        /// Gets or sets the date and time this task is scheduled to start.
        /// This affects when the task will appear in the user's inbox. If
        /// this date and time is set to the future, then the task will only
        /// appear after that point in time.
        /// </summary>
        public abstract DateTime? ScheduledStartDateTime { get; set; }

        /// <summary>
        /// Gets or sets the date and time this task is scheduled to end.
        /// This affects how the task appears in the user's inbox. If this
        /// date and time is in the past, then the task will be highlight
        /// in the user's inbox as outstanding.
        /// </summary>
        public abstract DateTime? ScheduledEndDateTime { get; set; }


        /// <summary>
        /// Gets or sets the WorkflowInstanceID as generated from the
        /// Workflow Engine.
        /// </summary>
        public abstract string WorkflowInstanceID { get; set; }

        /// <summary>
        /// Gets or sets the type represented by this activity history.
        /// <list>
        ///     <item>0 - State Transition</item>
        ///     <item>1 - User Reassignment</item>
        /// </list>
        /// </summary>
        public abstract int? HistoryType { get; set; }

        /// <summary>
        /// Gets a list of users that are assigned to this task.
        /// </summary>
        public abstract DataList<OUser> Users { get; }

        /// <summary>
        /// Gets a list roles that are assigned to this task.
        /// </summary>
        public abstract DataList<OPosition> Positions { get; }

        /// <summary>
        /// Gets a comma-separated list of users who are assigned to this object.
        /// 
        /// If this object does not have a workflow or state, this property returns
        /// a null string.
        /// </summary>
        public string AssignedUserNames
        {
            get
            {
                if (this.Users.Count>0)
                {
                    string users = "";
                    foreach (OUser user in this.Users)
                        if (user != null)
                            users += (users == "" ? "" : ", ") + user.ObjectName;
                    return users;
                }
                else
                    return "";
            }
        }
        /// <summary>
        /// Gets a comma-separated list of positions who are assigned to this object.
        /// 
        /// If this object does not have a workflow or state, this property returns
        /// a null string.
        /// </summary>
        public string AssignedUserPositions
        {
            get
            {
                if (this.Positions.Count > 0)
                {
                    string positions = "";
                    foreach (OPosition position in this.Positions)
                        positions += (positions == "" ? "" : ", ") + position.ObjectName;
                    return positions;
                }
                else
                    return "";
            }
        }



    }
}
