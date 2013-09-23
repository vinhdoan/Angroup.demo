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
    public partial class TNotificationHierarchy : LogicLayerSchema<ONotificationHierarchy>
    {
        public TNotificationHierarchyLevel NotificationHierarchyLevels { get { return OneToMany<TNotificationHierarchyLevel>("NotificationHierarchyID"); } }
    }

    /// <summary>
    /// Represents a hierarchy of users or roles to
    /// which notifications will be sent when 
    /// action on workflow objects are not performed in time.
    /// </summary>
    public abstract partial class ONotificationHierarchy : LogicLayerPersistentObject
    {
        /// <summary>
        /// Gets a list of ONotificationHierarchyLevel objects
        /// that contains the list of users or roles
        /// to which notifications will be sent.
        /// </summary>
        public abstract DataList<ONotificationHierarchyLevel> NotificationHierarchyLevels { get; }


        /// <summary>
        /// Disallow delete if:
        /// <para></para>
        /// 1. Any of the notification processes uses this notification
        /// hierarchy.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            int count = TablesLogic.tNotificationProcess.Select(
                TablesLogic.tNotificationProcess.ObjectID.Count())
                .Where(
                TablesLogic.tNotificationProcess.NotificationHierarchyID == this.ObjectID &
                TablesLogic.tNotificationProcess.IsDeleted == 0);

            if (count > 0)
                return false;

            return true;
        }


        /// <summary>
        /// Overrides the saving method to:
        /// <para></para>
        /// 1. Update the Notification level numbers of each of the Notification hierarchy level
        ///    objects.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            UpdateNotificationLevels();
        }


        /// <summary>
        /// Gets all Notification hierarchies.
        /// </summary>
        public static List<ONotificationHierarchy> GetAllNotificationHierarchies()
        {
            return TablesLogic.tNotificationHierarchy.LoadAll();
        }


        /// <summary>
        /// Sort the Notification hierarchy level objects and assign
        /// a sequential running number start from 1.
        /// </summary>
        public void UpdateNotificationLevels()
        {
            if (this.NotificationHierarchyLevels.Count > 0)
            {
                List<ONotificationHierarchyLevel> levels = new List<ONotificationHierarchyLevel>();
                foreach (ONotificationHierarchyLevel level in this.NotificationHierarchyLevels)
                    levels.Add(level);

                levels.Sort("NotificationTimeInMinutes1 ASC");
                int i = 1;
                foreach (ONotificationHierarchyLevel level in levels)
                    level.NotificationLevel = i++;
            }
        }


        /// <summary>
        /// Finds the ONotificationHierarchyLevel in this object so that its NotificationLevel = level
        /// <para></para>
        /// This method is used in the hierarchical-forwarding scenario.
        /// </summary>
        /// <param name="level">The Notification hierarchy level, in the order
        /// of the Notification limit. The first Notification hierarchy level is
        /// 1, the second is 2, and so on.</param>
        /// <returns>Returns the ONotificationHierarchyLevel object.</returns>
        public ONotificationHierarchyLevel FindNotificationHierarchyLevelByLevel(int level)
        {
            foreach (ONotificationHierarchyLevel NotificationHierarchyLevel in this.NotificationHierarchyLevels)
                if (NotificationHierarchyLevel.NotificationLevel == level)
                    return NotificationHierarchyLevel;
            return null;
        }


    }


}