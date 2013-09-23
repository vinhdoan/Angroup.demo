using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Represents one level in the Notification hierarchy.
    /// </summary>
    public class TNotificationHierarchyLevel : LogicLayerSchema<ONotificationHierarchyLevel>
    {
        public SchemaGuid NotificationHierarchyID;
        public SchemaInt NotificationLevel;
        public SchemaInt NotificationTimeInMinutes1;
        public SchemaInt NotificationTimeInMinutes2;
        public SchemaInt NotificationTimeInMinutes3;
        public SchemaInt NotificationTimeInMinutes4;
        public TUser Users { get { return ManyToMany<TUser>("NotificationHierarchyLevelUser", "NotificationHierarchyLevelID", "UserID"); } }
        public TPosition Positions { get { return ManyToMany<TPosition>("NotificationHierarchyLevelPosition", "NotificationHierarchyLevelID", "PositionID"); } }
        public TRole Roles { get { return ManyToMany<TRole>("NotificationHierarchyLevelRole", "NotificationHierarchyLevelID", "RoleID"); } }
    }


    /// <summary>
    /// Represents one level in the Notification hierarchy.
    /// </summary>
    public abstract class ONotificationHierarchyLevel : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// NotificationHierarchy table that represents that
        /// Notification hierarchy under which this Notification
        /// hierarchy level belongs to.
        /// </summary>
        public abstract Guid? NotificationHierarchyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the numeric Notification
        /// level of this Notification hierarchy level. 
        /// </summary>
        public abstract int? NotificationLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default Notification time in minutes
        /// for the first milestone.
        /// <para></para>
        /// This time will be overriden by the notification process' time
        /// if the user indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes1 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default Notification time in minutes
        /// for the second milestone.
        /// <para></para>
        /// This time will be overriden by the notification process' time
        /// if the user indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes2 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default Notification time in minutes
        /// for the third milestone.
        /// <para></para>
        /// This time will be overriden by the notification process' time
        /// if the user indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes3 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default Notification time in minutes
        /// for the fourth milestone.
        /// <para></para>
        /// This time will be overriden by the notification process' time
        /// if the user indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes4 { get; set; }

        /// <summary>
        /// Gets the list of users who will be notified
        /// at this level.
        /// </summary>
        public abstract DataList<OUser> Users { get; set; }

        /// <summary>
        /// Gets the list of positions who will be notified
        /// at this level.
        /// </summary>
        public abstract DataList<OPosition> Positions { get; set; }

        /// <summary>
        /// Gets the list of roles that will be notified
        /// at this level.
        /// </summary>
        public abstract DataList<ORole> Roles { get; set; }

        /// <summary>
        /// This is a temporary link to the ONotificationProcessTiming
        /// object associated with this notification hierarchy level.
        /// This link is not saved into the database, but allows the user to 
        /// update the non-default timing in the user interface.
        /// </summary>
        public ONotificationProcessTiming TempNotificationProcessingTiming;

        /// <summary>
        /// Gets a comma-separated list of user names.
        /// </summary>
        public string UserNames
        {
            get
            {
                string userNames = "";
                foreach (OUser user in this.Users)
                    userNames += (userNames == "" ? "" : ", ") + user.ObjectName;
                return userNames;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of job names.
        /// </summary>
        public string PositionNames
        {
            get
            {
                string positionNames = "";
                foreach (OPosition position in this.Positions)
                    positionNames += (positionNames == "" ? "" : ", ") + position.ObjectName;
                return positionNames;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of job names.
        /// </summary>
        public string RoleNames
        {
            get
            {
                string roleNames = "";
                foreach (ORole role in this.Roles)
                    roleNames += (roleNames == "" ? "" : ", ") + role.RoleName;
                return roleNames;
            }
        }


        /// <summary>
        /// Validates that at least one user or one job has been specified.
        /// </summary>
        /// <returns></returns>
        public bool ValidateUserOrRoleOrPositionSpecified()
        {
            return (this.Roles.Count > 0 ||
                this.Positions.Count > 0 ||
                this.Users.Count > 0);
        }
    }
}
