//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

using Anacle.DataFramework;

namespace LogicLayer
{
    public class TApplicationSettingService : LogicLayerSchema<OApplicationSettingService>
    {
        public SchemaGuid ApplicationSettingID;
        [Size(100)]
        public SchemaString ServiceName;
        public SchemaInt IsEnabled;
        [Size(100)]
        public SchemaString TimerInterval;
    }

    /// <summary>
    /// Represents a settings for the running of a service.
    /// </summary>
    public abstract class OApplicationSettingService : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key
        /// to the application setting table that
        /// represents the application setting
        /// object that contains this settings
        /// for a service.
        /// </summary>
        public abstract Guid? ApplicationSettingID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the service name.
        /// </summary>
        public abstract String ServiceName { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating
        /// whether the service is enabled.
        /// </summary>
        public abstract int? IsEnabled { get; set; }

        /// <summary>
        /// [Column] Gets or sets the timer interval.
        /// </summary>
        public abstract String TimerInterval { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public OBackgroundServiceRun BackgroundServiceRun
        {
            get
            {
                return TablesLogic.tBackgroundServiceRun.Load(TablesLogic.tBackgroundServiceRun.IsDeleted == 0 &
                                                              TablesLogic.tBackgroundServiceRun.ServiceName == this.ServiceName);
            }

        }

        /// <summary>
        /// 
        /// </summary>
        public bool HasErrorMessage
        {
            get
            {
                if (this.BackgroundServiceRun != null &&
                    this.BackgroundServiceRun.LastRunErrorMessage != null &&
                    this.BackgroundServiceRun.LastRunErrorMessage.Trim() != "")
                    return true;
                return false;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public override void Saving()
        {
            base.Saving();
            
            if (this.IsNew)
            {
                using (Connection c = new Connection())
                {
                    OBackgroundServiceRun bsr = TablesLogic.tBackgroundServiceRun.Create();
                    bsr.ServiceName = this.ServiceName;
                    bsr.NextRunDateTime = GetNextDateTime();
                    bsr.Save();
                    c.Commit();
                }
            }
        }

        /// <summary>
        /// Gets the minimum date AFTEr the current time.
        /// </summary>
        /// <param name="possibleDateTimes"></param>
        /// <returns></returns>
        private DateTime GetMinimumDate(DateTime currentTime, List<DateTime> possibleDateTimes)
        {
            DateTime min = DateTime.MaxValue;
            foreach (DateTime possibleDateTime in possibleDateTimes)
                if (possibleDateTime > currentTime && possibleDateTime < min)
                    min = possibleDateTime;
            return min;
        }

        /// <summary>
        /// Gets the hours and minutes.
        /// </summary>
        /// <returns></returns>
        private DateTime GetHoursAndMinutes(string hoursAndMinutes)
        {
            string[] hoursAndMinutesSplit = hoursAndMinutes.Split(':');
            int hours = 0;
            int minutes = 0;
            if (hoursAndMinutesSplit.Length > 0)
                Int32.TryParse(hoursAndMinutesSplit[0], out hours);
            if (hoursAndMinutesSplit.Length > 1)
                Int32.TryParse(hoursAndMinutesSplit[1], out minutes);
            return new DateTime(1900, 1, 1, hours, minutes, 0);
        }

        /// <summary>
        /// Gets the day of the week.
        /// </summary>
        /// <param name="dayOfWeek"></param>
        /// <returns></returns>
        private DayOfWeek GetDayOfWeek(string dayOfWeek)
        {
            dayOfWeek = dayOfWeek.ToLower();
            if (dayOfWeek.StartsWith("sun"))
                return DayOfWeek.Sunday;
            else if (dayOfWeek.StartsWith("mon"))
                return DayOfWeek.Monday;
            else if (dayOfWeek.StartsWith("tue"))
                return DayOfWeek.Tuesday;
            else if (dayOfWeek.StartsWith("wed"))
                return DayOfWeek.Wednesday;
            else if (dayOfWeek.StartsWith("thu"))
                return DayOfWeek.Thursday;
            else if (dayOfWeek.StartsWith("fri"))
                return DayOfWeek.Friday;
            else if (dayOfWeek.StartsWith("sat"))
                return DayOfWeek.Saturday;
            return DayOfWeek.Sunday;
        }

        /// <summary>
        /// Gets the date of the start of the week 
        /// (assuming the start of the week is on sunday)
        /// </summary>
        /// <param name="dateTime"></param>
        /// <returns></returns>
        private DateTime GetStartOfWeek(DateTime dateTime)
        {
            while (dateTime.DayOfWeek != DayOfWeek.Sunday)
                dateTime = dateTime.AddDays(-1);
            return new DateTime(dateTime.Year, dateTime.Month, dateTime.Day, 0, 0, 0);
        }


        /// <summary>
        /// Gets the date of the month, given the date of the first
        /// day of the month, the day number.
        /// </summary>
        /// <param name="firstDayOfMonth"></param>
        /// <param name="dayOfMonth"></param>
        /// <returns></returns>
        private DateTime GetDayOfMonth(DateTime firstDayOfMonth, int dayOfMonth)
        {
            DateTime lastDayOfMonth = firstDayOfMonth.AddMonths(1).AddDays(-1);
            if (dayOfMonth > lastDayOfMonth.Day)
                dayOfMonth = lastDayOfMonth.Day;
            return new DateTime(firstDayOfMonth.Year, firstDayOfMonth.Month, dayOfMonth);
        }


        /// <summary>
        /// Gets the next time to run this service.
        /// </summary>
        public DateTime GetNextDateTime()
        {
            string[] timerParams = this.TimerInterval.ToString().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

            List<DateTime> nextPossibleDateTimes = new List<DateTime>();

            string timeUnit = timerParams[1].ToLower();
            int timeValue = 1;
            Int32.TryParse(timerParams[0], out timeValue);

            if (timeUnit.StartsWith("sec"))
            {
                //--------------------------------------------------
                // SECONDS
                // Format: x sec(onds)
                //--------------------------------------------------
                return DateTime.Now.AddSeconds(timeValue);
            }
            else if (timeUnit.StartsWith("min"))
            {
                //--------------------------------------------------
                // MINUTES
                // Format: x min(utes)
                //--------------------------------------------------
                return DateTime.Now.AddMinutes(timeValue);
            }
            else if (timeUnit.StartsWith("day"))
            {
                //--------------------------------------------------
                // DAYS
                // Format: x day(s) HH:mm HH:mm HH:mm...
                //--------------------------------------------------
                DateTime now = DateTime.Now;
                DateTime nextday = now.AddDays(timeValue);
                for (int i = 2; i < timerParams.Length; i++)
                {
                    DateTime hhmm = GetHoursAndMinutes(timerParams[i]);
                    nextPossibleDateTimes.Add(
                        new DateTime(now.Year, now.Month, now.Day, hhmm.Hour, hhmm.Minute, 0));
                    nextPossibleDateTimes.Add(
                        new DateTime(nextday.Year, nextday.Month, nextday.Day, hhmm.Hour, hhmm.Minute, 0));
                }
                if (nextPossibleDateTimes.Count == 0)
                    return now.AddDays(timeValue);
                else
                    return GetMinimumDate(now, nextPossibleDateTimes);
            }
            else if (timeUnit.StartsWith("week"))
            {
                //---------------------------------------------------------------
                // WEEKS
                // Format: x week(s) HH:mm HH:mm HH:mm... Sunday Monday Tuesday...
                //                   ----- time -----     ---- day of week -----
                //---------------------------------------------------------------
                DateTime now = DateTime.Now;
                DateTime thisWeek = GetStartOfWeek(now);
                DateTime nextWeek = thisWeek.AddDays(timeValue * 7);
                List<DateTime> hhmms = new List<DateTime>();
                List<int> daysOfWeek = new List<int>();
                for (int i = 2; i < timerParams.Length; i++)
                {
                    if (timerParams[i].Contains(":"))
                        hhmms.Add(GetHoursAndMinutes(timerParams[i]));
                    else
                        daysOfWeek.Add((int)GetDayOfWeek(timerParams[i]));
                }
                for (int i = 0; i < hhmms.Count; i++)
                    for (int j = 0; j < daysOfWeek.Count; j++)
                    {
                        DateTime thisweekday = thisWeek.AddDays(daysOfWeek[j]);
                        DateTime nextweekday = nextWeek.AddDays(daysOfWeek[j]);
                        nextPossibleDateTimes.Add(new DateTime(
                            thisweekday.Year, thisweekday.Month, thisweekday.Day, hhmms[i].Hour, hhmms[i].Minute, 0));
                        nextPossibleDateTimes.Add(new DateTime(
                            nextweekday.Year, nextweekday.Month, nextweekday.Day, hhmms[i].Hour, hhmms[i].Minute, 0));
                    }

                if (nextPossibleDateTimes.Count == 0)
                    return now.AddDays(timeValue * 7);
                else
                    return GetMinimumDate(now, nextPossibleDateTimes);
            }
            else if (timeUnit.StartsWith("month"))
            {
                //---------------------------------------------------------------
                // MONTHS
                // Format: x month(s) HH:mm HH:mm HH:mm... 1 2 3 4...
                //                    ----- time ------    --- day of month ---
                //---------------------------------------------------------------
                DateTime now = DateTime.Now;
                DateTime thisMonth = new DateTime(now.Year, now.Month, 1);
                DateTime nextMonth = thisMonth.AddMonths(timeValue);
                List<DateTime> hhmms = new List<DateTime>();
                List<int> daysOfMonth = new List<int>();
                for (int i = 2; i < timerParams.Length; i++)
                {
                    if (timerParams[i].Contains(":"))
                        hhmms.Add(GetHoursAndMinutes(timerParams[i]));
                    else
                    {
                        int dayOfMonth = 1;
                        Int32.TryParse(timerParams[i], out dayOfMonth);
                        daysOfMonth.Add(dayOfMonth);
                    }
                }
                for (int i = 0; i < hhmms.Count; i++)
                    for (int j = 0; j < daysOfMonth.Count; j++)
                    {
                        DateTime thisMonthDay = GetDayOfMonth(thisMonth, daysOfMonth[j]);
                        DateTime nextMonthDay = GetDayOfMonth(nextMonth, daysOfMonth[j]);

                        nextPossibleDateTimes.Add(new DateTime(
                            thisMonthDay.Year, thisMonthDay.Month, thisMonthDay.Day, hhmms[i].Hour, hhmms[i].Minute, 0));
                        nextPossibleDateTimes.Add(new DateTime(
                            nextMonthDay.Year, nextMonthDay.Month, nextMonthDay.Day, hhmms[i].Hour, hhmms[i].Minute, 0));
                    }

                if (nextPossibleDateTimes.Count == 0)
                    return now.AddMonths(timeValue);
                else
                    return GetMinimumDate(now, nextPossibleDateTimes);
            }

            return DateTime.Now.AddMinutes(5);
        }
    }
}
