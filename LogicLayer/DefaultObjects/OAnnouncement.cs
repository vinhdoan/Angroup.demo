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
    /// Represents the schema for the Announcement table.
    /// </summary>
    public partial class TAnnouncement : LogicLayerSchema<OAnnouncement>
    {
        [Size(1000)]
        public SchemaString Announcement;
        public SchemaDateTime StartDate;
        public SchemaDateTime EndDate;
        public SchemaInt IsViewableByAll;

        public TPosition Positions { get { return ManyToMany<TPosition>("AnnouncementPosition", "AnnouncementID", "PositionID"); } }
    }


    /// <summary>
    /// Represents the current activity or a task of an object.
    /// </summary>
    [Serializable]
    public abstract partial class OAnnouncement : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the announcement text that is
        /// to be display to the user.
        /// </summary>
        public abstract string Announcement { get; set; }

        /// <summary>
        /// [Column] Gets or sets the first date that this
        /// announcement should appear to the assigned users.
        /// Set this to null to indicate that there is no
        /// limit.
        /// </summary>
        public abstract DateTime? StartDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the last date that this
        /// announcement should appear to the assigned users.
        /// Set this to null to indicate that there is no
        /// limit.
        /// </summary>
        public abstract DateTime? EndDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this announcement can be viewed by all users,
        /// regardless of their position.
        /// </summary>
        public abstract int? IsViewableByAll { get; set; }

        /// <summary>
        /// Gets a list of positions that are able to see 
        /// this announcement.
        /// </summary>
        public abstract DataList<OPosition> Positions { get; }


        /// <summary>
        /// Gets a list of all announcements applicable to the
        /// current user and at the specified date time.
        /// </summary>
        /// <param name="user"></param>
        /// <param name="dateTime"></param>
        /// <returns></returns>
        public static DataTable GetAnnouncementsTable(OUser user, DateTime dateTime)
        {
            // 2010.11.18
            // Li Shan
            // Fix to use dateTime.Date for the condition.
            //
            return TablesLogic.tAnnouncement.SelectDistinct(
                TablesLogic.tAnnouncement.ObjectID,
                TablesLogic.tAnnouncement.Announcement,
                TablesLogic.tAnnouncement.CreatedUser,
                TablesLogic.tAnnouncement.CreatedDateTime)
                .Where(
                (TablesLogic.tAnnouncement.StartDate == null |
                TablesLogic.tAnnouncement.StartDate <= dateTime.Date) &
                (TablesLogic.tAnnouncement.EndDate == null |
                dateTime.Date <= TablesLogic.tAnnouncement.EndDate) &
                TablesLogic.tAnnouncement.IsDeleted == 0 &
                (TablesLogic.tAnnouncement.IsViewableByAll == 1 |
                TablesLogic.tAnnouncement.Positions.ObjectID.In(user.Positions))
                );

        }
    }
}
