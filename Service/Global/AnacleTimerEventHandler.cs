using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Service
{
    public class AnacleTimerEventArgs : EventArgs 
    {
        private object parameter;

        /// <summary>
        /// Gets the parameter passed into the AnacleTimer
        /// when it was created.
        /// </summary>
        public object Parameter
        {
            get { return parameter; }
        }

        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="parameter"></param>
        public AnacleTimerEventArgs(object parameter)
        {
            this.parameter = parameter;
        }
    }
}
