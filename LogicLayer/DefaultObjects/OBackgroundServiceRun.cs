//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TBackgroundServiceRun : LogicLayerSchema<OBackgroundServiceRun>
    {
        [Size(255)]
        public SchemaString ServiceName;

        public SchemaDateTime LastRunStartDateTime;
        public SchemaDateTime LastRunCompleteDateTime;

        public SchemaInt LastRunStatus;
        [Default(0)]
        public SchemaInt CurrentStatus;
        
        [Size(1000)]
        public SchemaString LastRunErrorMessage;
        public SchemaDateTime NextRunDateTime;
    }

    public abstract partial class OBackgroundServiceRun : LogicLayerPersistentObject
    {
        public abstract string ServiceName { get; set; }

        public abstract DateTime? LastRunStartDateTime { get; set; }

        public abstract DateTime? LastRunCompleteDateTime { get; set; }

        public abstract int? LastRunStatus { get; set; }

        public abstract int? CurrentStatus { get; set; }

        public abstract string LastRunErrorMessage { get; set; }

        public abstract DateTime? NextRunDateTime { get; set; }


        /// <summary>
        /// 
        /// </summary>
        public String LastRunStatusText
        {
            get
            {
                if (this.LastRunStatus == (int)BackgroundServiceLastRunStatus.Succeeded)
                    return "SUCCEEDED";
                else if (this.LastRunStatus == (int)BackgroundServiceLastRunStatus.Failed)
                    return "FAILED";
                return "";
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public String CurrentStatusText
        {
            get
            {
                if (this.CurrentStatus == (int)BackgroundServiceCurrentStatus.Running)
                    return "RUNNING";
                else if (this.CurrentStatus == (int)BackgroundServiceCurrentStatus.Stopped)
                    return "WAITING";
                return "";
            }
        }

    }

    public enum BackgroundServiceLastRunStatus
    {   
        Failed = 0,
        Succeeded = 1,
    }

    public enum BackgroundServiceCurrentStatus
    {
        Stopped = 0,
        Running = 1,
    }
}
