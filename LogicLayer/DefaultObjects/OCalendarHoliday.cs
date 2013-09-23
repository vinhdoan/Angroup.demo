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
    [Database("#database"), Map("CalendarHoliday")]
    [Serializable] public partial class TCalendarHoliday : LogicLayerSchema<OCalendarHoliday>
    {
        public SchemaGuid CalendarID;
        public SchemaDateTime HolidayDate;

        public TCalendar Calendar { get { return OneToOne<TCalendar>("CalendarID"); } }
    }


    /// <summary>
    /// Represents a record containing information about a holiday
    /// in a calendar.
    /// </summary>
    [Serializable]
    public abstract partial class OCalendarHoliday : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Foreign database key to the OCalendar object.
        /// </summary>
        public abstract Guid? CalendarID { get; set; }
        /// <summary>
        /// [Column] Date of the holiday.
        /// </summary>
        public abstract DateTime? HolidayDate { get; set; }

        /// <summary>
        /// Gets or sets the OCalendar object that contains this holiday.
        /// </summary>
        public abstract OCalendar Calendar { get; }

        public static bool IsHoliday(DateTime dt)
        {
            OCalendarHoliday ch = TablesLogic.tCalendarHoliday.Load(TablesLogic.tCalendarHoliday.HolidayDate == dt &
                                              TablesLogic.tCalendarHoliday.CalendarID != null &
                                              TablesLogic.tCalendarHoliday.IsDeleted == 0);

            if (ch != null)
                return true;

            return false;
        }

        public OCalendarHoliday()
        {
        }

        public bool IsDuplicateName(OCalendar parentCalendar)
        {
            return TablesLogic.tCalendarHoliday[
                TablesLogic.tCalendarHoliday.ObjectName == this.ObjectName &
                TablesLogic.tCalendarHoliday.CalendarID == parentCalendar.ObjectID &
                TablesLogic.tCalendarHoliday.ObjectID != this.ObjectID].Count > 0;
        }

    }


}