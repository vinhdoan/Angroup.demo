//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Represents one level in the Notification hierarchy.
    /// </summary>
    public class TNotificationProcessTiming : LogicLayerSchema<ONotificationProcessTiming>
    {
        public SchemaGuid NotificationProcessID;
        public SchemaInt NotificationLevel;
        public SchemaInt NotificationTimeInMinutes1;
        public SchemaInt NotificationTimeInMinutes2;
        public SchemaInt NotificationTimeInMinutes3;
        public SchemaInt NotificationTimeInMinutes4;
    }


    /// <summary>
    /// Represents one level in the Notification hierarchy.
    /// </summary>
    public abstract class ONotificationProcessTiming : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// NotificationHierarchy table that represents that
        /// Notification hierarchy under which this Notification
        /// hierarchy level belongs to.
        /// </summary>
        public abstract Guid? NotificationProcessID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the numeric Notification
        /// level of this Notification hierarchy level. 
        /// </summary>
        public abstract int? NotificationLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Notification time in minutes
        /// for the first milestone.
        /// <para></para>
        /// This time overrides the default notification time
        /// in the notification hierarchy level, if the user
        /// indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes1 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Notification time in minutes
        /// for the second milestone.
        /// <para></para>
        /// This time overrides the default notification time
        /// in the notification hierarchy level, if the user
        /// indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes2 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Notification time in minutes
        /// for the third milestone.
        /// <para></para>
        /// This time overrides the default notification time
        /// in the notification hierarchy level, if the user
        /// indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes3 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Notification time in minutes
        /// for the fourth milestone.
        /// <para></para>
        /// This time overrides the default notification time
        /// in the notification hierarchy level, if the user
        /// indicated not to use the default notification time.
        /// </summary>
        public abstract int? NotificationTimeInMinutes4 { get; set; }

    }

}
