//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    [Database("#database"), Map("SurveyReminder")]
    public partial class TSurveyReminder : LogicLayerSchema<OSurveyReminder>
    {
        public SchemaGuid SurveyPlannerID; 
        public SchemaDateTime ReminderDate;
        [Size(255)]
        public SchemaString EmailList;
        public SchemaDateTime EmailSentOn;

        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }
    }


    public abstract partial class OSurveyReminder : LogicLayerPersistentObject
    {
        public abstract Guid? SurveyPlannerID { get; set; }
        public abstract DateTime? ReminderDate { get; set; }
        public abstract string EmailList { get; set; }
        public abstract DateTime? EmailSentOn { get; set; }

        public abstract OSurveyPlanner SurveyPlanner { get; set; }


        /// --------------------------------------------------------------
        /// <summary>
        /// Set the survey number format
        /// </summary>
        /// --------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            //if (this.IsNew)
            //{
            //    // format of the contract number can be changed per customization
            //    //
            //    this.ObjectNumber = ORunningNumber.GenerateNextNumber("SurveyReminder", "SR/{2:00}{1:00}/{0:0000}", true);
            //}
        }

        public override bool IsDeactivable()
        {
            if (this.EmailSentDateTime != null)
                return false;
            else
                return true;
        }
    }

}

