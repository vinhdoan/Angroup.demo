using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LogicLayer
{
    public static class DateTimeExtensions
    {
        /// <summary>
        /// Returns a user-friendly time based with reference from
        /// the current time.
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static string ToFriendlyString(this DateTime dateTime)
        {
            bool past = false;
            DateTime now = DateTime.Now;
            string timeString = "";
            string additionalTime = "";
            TimeSpan ts;
            if (dateTime > now)
            {
                ts = dateTime.Subtract(now);
                past = false;
            }
            else
            {
                ts = now.Subtract(dateTime);
                past = true;
            }

            timeString = dateTime.ToString("dd-MMM-yyyy") + " at " +  dateTime.ToString("hh:mm:ss tt");

            if (ts.Seconds == 0 && ts.Minutes == 0 && ts.Hours == 0 && ts.Days == 0)
                timeString = Resources.Strings.Time_Now;

            else if (ts.Days == 1)
                additionalTime += String.Format(Resources.Strings.Time_DaysSingular, ts.Days);
            else if (ts.Days > 1 && ts.Days < 100)
                additionalTime += String.Format(Resources.Strings.Time_DaysPlural, ts.Days);

            else if (ts.Days > 100 && ts.Days < 366)
                additionalTime += String.Format(Resources.Strings.Time_MonthPlural, ts.Days / 30);

            else if (ts.Days > 365 && (ts.Days / 365) == 1)
                additionalTime += String.Format(Resources.Strings.Time_YearSingular, ts.Days / 365);
            else if (ts.Days > 365 && (ts.Days / 365) > 1)
                additionalTime += String.Format(Resources.Strings.Time_YearPlural, ts.Days / 365);

            else if (ts.Hours == 1 && ts.Days == 0)
                additionalTime += String.Format(Resources.Strings.Time_HoursSingular, ts.Hours);
            else if (ts.Hours > 1 && ts.Days == 0)
                additionalTime += String.Format(Resources.Strings.Time_HoursPlural, ts.Hours);

            else if (ts.Minutes == 1 && ts.Hours == 0 && ts.Days == 0)
                additionalTime += String.Format(Resources.Strings.Time_MinutesSingular, ts.Minutes);
            else if (ts.Minutes > 1 && ts.Days == 0)
                additionalTime += String.Format(Resources.Strings.Time_MinutesPlural, ts.Minutes);

            else if (ts.Seconds == 1 && ts.Hours == 0)
                additionalTime += Resources.Strings.Time_MomentsAgo;
            else if (ts.Seconds > 1 && ts.Hours == 0)
                additionalTime += Resources.Strings.Time_MomentsAgo;

            if (additionalTime != "")
                return timeString + " (" + FormatReturnString(additionalTime,past) + ")";
            else
                return timeString;
        }

        private static string FormatReturnString(string additionalTime, bool past)
        {
            if (past)
                additionalTime = String.Format(Resources.Strings.Time_Past, additionalTime);
            else
                additionalTime = String.Format(Resources.Strings.Time_Future, additionalTime);
            return additionalTime;
        }
    }
}
