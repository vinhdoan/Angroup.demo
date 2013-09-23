using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Service
{
    /// <summary>
    /// Represents a timer.
    /// </summary>
    public class AnacleTimer : IDisposable
    {
        System.Timers.Timer timer = new System.Timers.Timer();
        private string[] timerParams;
        private object parameter;
        private DateTime nextRunDateTime;

        private long maxInterval = 3600000;  // Total milliseconds for 1 hour.
        private long minInterval = 500;  // Total milliseconds for 0.5 second.

        public delegate void AnacleTimerEventHandler(object sender, AnacleTimerEventArgs eventArgs);
        public event AnacleTimerEventHandler Elapsed;

        /// <summary>
        /// Gets the next run's date time.
        /// </summary>
        public DateTime NextRunDateTime
        {
            get
            {
                return nextRunDateTime;
            }
        }

        /// <summary>
        /// Gets or sets a flag indicating whether the 
        /// timer is enabled.
        /// </summary>
        public bool Enabled
        {
            get
            {
                return timer.Enabled;
            }
            set
            {
                timer.Enabled = value;
            }
        }


        /// <summary>
        /// Constructor.
        /// </summary>
        public AnacleTimer(object parameter)
        {
            timer.Elapsed += new System.Timers.ElapsedEventHandler(timer_Elapsed);
            this.parameter = parameter;
            this.SetTimerFrequency("5 minutes");
        }

        /// <summary>
        /// Gets the minimum date AFTEr the current time.
        /// </summary>
        /// <param name="possibleDateTimes"></param>
        /// <returns></returns>
        DateTime GetMinimumDate(DateTime currentTime, List<DateTime> possibleDateTimes)
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
        DateTime GetHoursAndMinutes(string hoursAndMinutes)
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
        DayOfWeek GetDayOfWeek(string dayOfWeek)
        {
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
        DateTime GetStartOfWeek(DateTime dateTime)
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
        DateTime GetDayOfMonth(DateTime firstDayOfMonth, int dayOfMonth)
        {
            DateTime lastDayOfMonth = firstDayOfMonth.AddMonths(1).AddDays(-1);
            if (dayOfMonth > lastDayOfMonth.Day)
                dayOfMonth = lastDayOfMonth.Day;
            return new DateTime(firstDayOfMonth.Year, firstDayOfMonth.Month, dayOfMonth);
        }


        /// <summary>
        /// Gets the next time to run this service.
        /// </summary>
        DateTime GetNextDateTime()
        {
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

        /// <summary>
        /// Sets the timer frequency represented by a string.
        /// <para></para>
        /// The timer frequency can be specified in one of the 
        /// following formats. 
        /// <para></para>
        /// x sec(onds)
        /// x min(utes)
        /// x day(s) HH:mm HH:mm HH:mm... 
        /// x week(s) HH:mm HH:mm HH:mm... sun(day) mon(day) tue(day)...
        /// x month(s) HH:mm HH:mm HH:mm... 1 2 3 4 5 6 7 8 9 10...
        /// </summary>
        /// <param name="timerFrequency"></param>
        public void SetTimerFrequency(string timerFrequency)
        {
            timerParams = timerFrequency.ToString().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < timerParams.Length; i++)
                timerParams[i] = timerParams[i].ToLower();
        }

        /// <summary>
        /// Starts the timer and waits for the next occurrence
        /// </summary>
        public void Start()
        {
            DateTime now = DateTime.Now;
            nextRunDateTime = GetNextDateTime();

            long currentInterval = Convert.ToInt64(nextRunDateTime.Subtract(now).TotalMilliseconds);
            if (currentInterval > maxInterval)
                currentInterval = maxInterval;
            if (currentInterval < minInterval)
                currentInterval = minInterval;

            timer.Interval = currentInterval;
            timer.Enabled = true;
            timer.Start();
        }


        /// <summary>
        /// Stop the timer.
        /// </summary>
        public void Stop()
        {
            timer.Stop();
            timer.Enabled = false;
        }



        /// <summary>
        /// Occurs when the timer elapsed. When the timer completes,
        /// it is up to the caller to re-start the timer by calling
        /// the Start() method.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            timer.Enabled = false;

            DateTime now = DateTime.Now;
            
            if (now < nextRunDateTime)
            {
                long currentInterval = Convert.ToInt64(nextRunDateTime.Subtract(now).TotalMilliseconds);
                if (currentInterval > maxInterval)
                    currentInterval = maxInterval;
                if (currentInterval < minInterval)
                    currentInterval = minInterval;

                // We still need the timer to continue running until the 
                // we reach time to run.
                //
                // This is to cater for long intervals (for eg., a month)
                // where the interval in milliseconds exceeds the
                // maximum allowable for a 32-bit integer.
                //
                timer.Interval = currentInterval;
                timer.Enabled = true;
            }
            else
            {
                // Once the remaining interval hits 0, 
                // the timer has reached the required interval
                // and will trigger the elapsed function.
                //
                if (this.Elapsed != null)
                    Elapsed(this, new AnacleTimerEventArgs(this.parameter));
            }
        }


        /// <summary>
        /// Dispose the timer.
        /// </summary>
        public void Dispose()
        {
            timer.Dispose();
        }
    }

}
