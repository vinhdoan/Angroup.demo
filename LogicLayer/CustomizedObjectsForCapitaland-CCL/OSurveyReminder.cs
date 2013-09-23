//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
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
    /// Summary description for OSurveyReminder
    /// </summary>
    
    public partial class TSurveyReminder : LogicLayerSchema<OSurveyReminder>
    {
        public SchemaDateTime ScheduledDateTime;

        public SchemaDateTime EmailSentDateTime;

        public SchemaInt SurveyEmailType;

        public SchemaDecimal SurveyThreshold;

        public SchemaInt DaysBeforeValidEnd;

        [Size(1000)]
        public SchemaString NotificationEmail;
    }


    public abstract partial class OSurveyReminder : LogicLayerPersistentObject
    {
        public abstract DateTime? ScheduledDateTime { get; set; }

        public abstract DateTime? EmailSentDateTime { get; set; }

        public abstract decimal? SurveyThreshold { get; set; }

        public abstract int? SurveyEmailType { get; set; }

        public abstract int? DaysBeforeValidEnd { get; set; }

        public abstract string NotificationEmail { get; set; }

        public string SurveyEmailTypeText
        {
            get
            {
                return TranslateSurveyEmailType(this.SurveyEmailType);
            }
        }

        public static string TranslateSurveyEmailType(int? emailType)
        {
            switch (emailType)
            {
                case (int)EnumSurveyEmailType.SurveyStarted:
                    return "New / Unsent (send to everyone who has not received an email message yet)";
                    break;
                case (int)EnumSurveyEmailType.SurveyNotResponded:
                    return "Not Responded (send to everyone who has received an email message, but has not responded)";
                    break;
                case (int)EnumSurveyEmailType.SurveyThresholdReached:
                    return "Threshold Reached (send email when survey responses collected reached threshold)";
                    break;
                case (int)EnumSurveyEmailType.SurveyValidityEnd:
                    return "Closing date reached (send email when survey planner reached closing date)";
                    break;
                default:
                    return "Error";
            }
        }
    }
}

