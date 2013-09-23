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
    /// <summary>
    /// Summary description for OChecklist
    /// </summary>
    [Database("#database"), Map("Calendar")]
    [Serializable] public partial class TCalendar : LogicLayerSchema<OCalendar>
    {
        public SchemaInt IsWorkDay0;
        public SchemaInt IsWorkDay1;
        public SchemaInt IsWorkDay2;
        public SchemaInt IsWorkDay3;
        public SchemaInt IsWorkDay4;
        public SchemaInt IsWorkDay5;
        public SchemaInt IsWorkDay6;

        public TCalendarHoliday HolidayDates { get { return OneToMany<TCalendarHoliday>("CalendarID"); } }

        public void x()
        {
            List<OUser> users = TablesLogic.tUser.LoadAll();
            foreach (OUser user in users)
            {
                OUser superior = user.Superior;
                Console.WriteLine(superior.ObjectName);
            }
        }
    }


    /// <summary>
    /// Represents a calendar, usually for a specific region, country, city.
    /// It indicates which days of the weeks are working days, and all the
    /// holidays associated with this calendar.
    /// </summary>
    [Serializable]
    public abstract partial class OCalendar : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Indicates if Sunday is a work day.
        /// </summary>
        public abstract int? IsWorkDay0 { get;set;}
        /// <summary>
        /// [Column] Indicates if Monday is a work day.
        /// </summary>
        public abstract int? IsWorkDay1 { get;set;}
        /// <summary>
        /// [Column] Indicates if Tuesday is a work day.
        /// </summary>
        public abstract int? IsWorkDay2 { get;set;}
        /// <summary>
        /// [Column] Indicates if Wednesday is a work day.
        /// </summary>
        public abstract int? IsWorkDay3 { get;set;}
        /// <summary>
        /// [Column] Indicates if Thursday is a work day.
        /// </summary>
        public abstract int? IsWorkDay4 { get;set;}
        /// <summary>
        /// [Column] Indicates if Friday is a work day.
        /// </summary>
        public abstract int? IsWorkDay5 { get;set;}
        /// <summary>
        /// [Column] Indicates if Saturday is a work day.
        /// </summary>
        public abstract int? IsWorkDay6 { get;set;}


        /// <summary>
        /// Gets a one-to-many list of OCalendarHoliday representing holidays in a Calendar.
        /// </summary>
        public abstract DataList<OCalendarHoliday> HolidayDates { get; }

        public OCalendar()
        {
        }

        public static List<OCalendar> GetAllCalendars()
        {
            return TablesLogic.tCalendar[Query.True];
        }


        /// <summary>
        /// Disallow deactivating of the calendar if:
        /// 1. It is used in an existing scheduled work that has been created, 
        ///    and not cancelled.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            int count = TablesLogic.tScheduledWork.Select(
                TablesLogic.tScheduledWork.ObjectID.Count())
                .Where(
                TablesLogic.tScheduledWork.CurrentActivity.ObjectName == "Created" &
                TablesLogic.tScheduledWork.CalendarID == this.ObjectID &
                TablesLogic.tScheduledWork.IsDeleted == 0);

            if (count > 0)
                return false;
            else
                return true;
        }


        private Hashtable hashWorkDays = null;
        private Hashtable hashHolidayDates = null;

        /// ----------------------------------------------------------------
        /// <summary>
        /// Initializes some internal hash tables for fast searching
        /// for work days and holidays
        /// </summary>
        /// ----------------------------------------------------------------
        public void InitializeSearchTable()
        {
            // find out all holiday dates and working days.
            //
            hashWorkDays = new Hashtable();
            hashWorkDays[0] = this.IsWorkDay0 == 1 ? 1 : 0;
            hashWorkDays[1] = this.IsWorkDay1 == 1 ? 1 : 0;
            hashWorkDays[2] = this.IsWorkDay2 == 1 ? 1 : 0;
            hashWorkDays[3] = this.IsWorkDay3 == 1 ? 1 : 0;
            hashWorkDays[4] = this.IsWorkDay4 == 1 ? 1 : 0;
            hashWorkDays[5] = this.IsWorkDay5 == 1 ? 1 : 0;
            hashWorkDays[6] = this.IsWorkDay6 == 1 ? 1 : 0;

            hashHolidayDates = new Hashtable();
            foreach (OCalendarHoliday holiday in this.HolidayDates)
                hashHolidayDates[holiday.HolidayDate.Value] = 1;
        }



        /// ----------------------------------------------------------------
        /// <summary>
        /// Find the next working day either by moving forward or 
        /// backwards.
        /// </summary>
        /// <param name="blockType"></param>
        /// ----------------------------------------------------------------
        public bool FindNextWorkingDay(bool cancelIfCollide, bool moveForward, ref DateTime start, ref DateTime end)
        {
            DateTime prev = start;        // get the start date;

            int loopingCount = 365;
            while (loopingCount >= 0)
            {
                loopingCount--;

                if ((int)hashWorkDays[(int)start.DayOfWeek] == 1 &&
                    hashHolidayDates[start] == null)
                {
                    // no change to the dates
                    return true;
                }

                if (cancelIfCollide)
                    return false;
                else if (moveForward)
                {
                    start = start.AddDays(1);
                    end = end.AddDays(1);
                }
                else
                {
                    start = start.AddDays(-1);
                    end = end.AddDays(-1);
                }
            }
            return false;
        }


        /// ----------------------------------------------------------------
        /// <summary>
        /// Determine the next date of work, based on the various scheduledWork
        /// parameters entered by the user.
        /// </summary>
        /// <param name="scheduledWork"></param>
        /// <param name="start"></param>
        /// <param name="end"></param>
        /// <returns></returns>
        /// ----------------------------------------------------------------
        public static bool ScheduleNextDate(OScheduledWork scheduledWork, ref DateTime start, ref DateTime end)
        {
            if (scheduledWork.FrequencyInterval == 0)
            {
                // daily
                start = start.Add(new TimeSpan(scheduledWork.FrequencyCount.Value, 0, 0, 0));
                end = end.Add(new TimeSpan(scheduledWork.FrequencyCount.Value, 0, 0, 0));
                return true;
            }
            else if (scheduledWork.FrequencyInterval == 1)
            {
                // weekly
                if (scheduledWork.WeekType == 0)
                {
                    // simple 
                    start = start.Add(new TimeSpan(scheduledWork.FrequencyCount.Value * 7, 0, 0, 0));
                    end = end.Add(new TimeSpan(scheduledWork.FrequencyCount.Value * 7, 0, 0, 0));
                    return true;
                }
                else
                {
                    // based on specific days of the week
                    //
                    int[] dayOfWeekSelected = new int[] {
                        scheduledWork.WeekTypeDay0.Value, 
                        scheduledWork.WeekTypeDay1.Value, 
                        scheduledWork.WeekTypeDay2.Value, 
                        scheduledWork.WeekTypeDay3.Value,
                        scheduledWork.WeekTypeDay4.Value, 
                        scheduledWork.WeekTypeDay5.Value, 
                        scheduledWork.WeekTypeDay6.Value };

                    DateTime tempStart = start;
                    DateTime tempEnd = end;
                    for (int i = 0; i < 7; i++)
                    {
                        tempStart = tempStart.Add(new TimeSpan(1, 0, 0, 0));
                        tempEnd = tempEnd.Add(new TimeSpan(1, 0, 0, 0));

                        if (dayOfWeekSelected[(int)tempStart.DayOfWeek] == 1)
                        {
                            start = tempStart;
                            end = tempEnd;
                            return true;
                        }
                        if (tempStart.DayOfWeek == DayOfWeek.Saturday)
                        {
                            tempStart = tempStart.Add(new TimeSpan(7 * (scheduledWork.FrequencyCount.Value - 1), 0, 0, 0));
                            tempEnd = tempEnd.Add(new TimeSpan(7 * (scheduledWork.FrequencyCount.Value - 1), 0, 0, 0));
                        }
                    }
                    return false;
                }
            }
            else if (scheduledWork.FrequencyInterval == 2)
            {
                // monthly
                //
                if (scheduledWork.MonthType == 0)
                {
                    // simple, just add month
                    //
                    DateTime tempStart = start.AddMonths(scheduledWork.FrequencyCount.Value);
                    DateTime original = scheduledWork.FirstWorkStartDateTime.Value;

                    // but sometimes the day of the month be pushed backwards, so we try
                    // to keep it to the original day... 
                    //
                    if (tempStart.Day < original.Day)
                    {
                        int lastDayInMonth = DateTime.DaysInMonth(tempStart.Year, tempStart.Month);
                        if (original.Day > lastDayInMonth)
                            tempStart = new DateTime(tempStart.Year, tempStart.Month, lastDayInMonth,
                                tempStart.Hour, tempStart.Minute, tempStart.Second, tempStart.Millisecond);
                        else
                            tempStart = new DateTime(tempStart.Year, tempStart.Month, original.Day,
                                tempStart.Hour, tempStart.Minute, tempStart.Second, tempStart.Millisecond);
                    }

                    end = end.Add(tempStart.Subtract(start));
                    start = tempStart;
                    return true;
                }
                else
                {
                    int dayOfWeek = scheduledWork.MonthTypeDay.Value;
                    int weekNumber = scheduledWork.MonthTypeWeekNumber.Value;

                    DateTime tempStart;
                    DateTime nextMonth = start.AddMonths(scheduledWork.FrequencyCount.Value);
                    nextMonth = new DateTime(nextMonth.Year, nextMonth.Month, 1);

                    // find the date of the month that matches the week number
                    // as well as the day of the week.
                    if (weekNumber < 5)
                    {
                        // first to fourth week of the month
                        tempStart =
                            new DateTime(nextMonth.Year, nextMonth.Month, (weekNumber - 1) * 7 + 1,
                            start.Hour, start.Minute, start.Second, start.Millisecond);
                    }
                    else
                    {
                        // last week of the month
                        DateTime lastWeekOfNextMonth = nextMonth.AddMonths(1).AddDays(-7);
                        tempStart =
                            new DateTime(lastWeekOfNextMonth.Year, lastWeekOfNextMonth.Month, lastWeekOfNextMonth.Day,
                            start.Hour, start.Minute, start.Second, start.Millisecond);
                    }

                    // then, search that week for a day that matches the required day
                    //
                    for (int i = 0; i < 7; i++)
                    {
                        if ((int)tempStart.DayOfWeek == dayOfWeek)
                        {
                            end = end.Add(tempStart.Subtract(start));
                            start = tempStart;
                            return true;
                        }
                        tempStart = tempStart.AddDays(1);
                    }
                    return false;
                }
            }
            else if (scheduledWork.FrequencyInterval == 3)
            {
                // yearly
                //
                DateTime tempStart = start.AddMonths(12 * scheduledWork.FrequencyCount.Value);
                DateTime original = scheduledWork.FirstWorkStartDateTime.Value;

                // like the monthly case, 
                // but sometimes the day of the month be pushed backwards, so we try
                // to keep it to the original day... 
                //
                if (tempStart.Day < original.Day)
                {
                    int lastDayInMonth = DateTime.DaysInMonth(tempStart.Year, tempStart.Month);
                    if (original.Day > lastDayInMonth)
                        tempStart = new DateTime(tempStart.Year, tempStart.Month, lastDayInMonth,
                            tempStart.Hour, tempStart.Minute, tempStart.Second, tempStart.Millisecond);
                    else
                        tempStart = new DateTime(tempStart.Year, tempStart.Month, original.Day,
                            tempStart.Hour, tempStart.Minute, tempStart.Second, tempStart.Millisecond);
                }

                end = end.Add(tempStart.Subtract(start));
                start = tempStart;
                return true;
            }
            return false;
        }

    }
}

