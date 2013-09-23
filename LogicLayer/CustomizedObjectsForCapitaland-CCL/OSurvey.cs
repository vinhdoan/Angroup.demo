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
    /// Summary description for OSurvey
    /// </summary>
    public partial class TSurvey : LogicLayerSchema<OSurvey>
    {
        public SchemaDateTime SurveyRespondedDateTime;

        public SchemaDateTime SurveyInvitedDateTime;

        public SchemaString NetworkID;

        public SchemaInt SurveyTargetType;

        //public SchemaString EvaluatedParty;

        //public SchemaGuid EvaluatedVendorID;

        //public SchemaGuid EvaluatedContractID;

        public SchemaGuid SurveyPlannerRespondentID;

        public SchemaGuid SurveyRespondentPortfolioID;

        public SchemaString FilledInRespondentBuildingName;

        [Size(255)]
        public SchemaString FilledInRespondentUnitNumber;

        public SchemaString FilledInRespondentDesignation;

        [Size(255)]
        public SchemaString FilledInRespondentName;

        public SchemaString FilledInRespondentContactNumber;

        public SchemaString FilledInRespondentEmailAddress;

        //public SchemaInt IsResponded;

        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }

        public TSurveyPlannerRespondent SurveyPlannerRespondent { get { return OneToOne<TSurveyPlannerRespondent>("SurveyPlannerRespondentID"); } }

        //public TSurveyGroupServiceLevel SurveyGroupServiceLevels { get { return ManyToMany<TSurveyGroupServiceLevel>("SurveySurveyGroupServiceLevel", "SurveyID", "SurveyGroupServiceLevelID"); } }

        //public TVendor EvaluatedVendor { get { return OneToOne<TVendor>("EvaluatedVendorID"); } }

        //public TContract EvaluatedContract { get { return OneToOne<TContract>("EvaluatedContractID"); } }
    }


    public abstract partial class OSurvey : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {
        public abstract DateTime? SurveyRespondedDateTime { get; set; }

        public abstract DateTime? SurveyInvitedDateTime { get; set; }

        public abstract string NetworkID { get; set; }

        public abstract int? SurveyTargetType { get; set; }

        //public abstract DataList<OSurveyGroupServiceLevel> SurveyGroupServiceLevels { get; }

        //public abstract string EvaluatedParty { get; set; }

        //public abstract Guid? EvaluatedVendorID { get; set; }

        //public abstract Guid? EvaluatedContractID { get; set; }

        public abstract string FilledInRespondentName { get; set; }

        public abstract string FilledInRespondentContactNumber { get; set; }

        public abstract string FilledInRespondentEmailAddress { get; set; }

        public abstract string FilledInRespondentBuildingName { get; set; }

        public abstract string FilledInRespondentUnitNumber { get; set; }

        public abstract string FilledInRespondentDesignation { get; set; }

        public abstract OSurveyPlanner SurveyPlanner { get; set; }

        public abstract Guid? SurveyPlannerRespondentID { get; set; }

        public abstract Guid? SurveyRespondentPortfolioID { get; set; }

        public abstract OSurveyPlannerRespondent SurveyPlannerRespondent { get; set; }

        //public abstract OVendor EvaluatedVendor { get; set; }

        //public abstract OContract EvaluatedContract { get; set; }

        public void UpdateSurveyChecklistItem()
        {
            this.SurveyChecklistItems.Clear();
            if (this.SurveyPlanner.SurveyPlannerServiceLevels.Count > 0)
            {
                foreach (OSurveyPlannerServiceLevel level in this.SurveyPlanner.SurveyPlannerServiceLevels)
                {
                    foreach (OChecklistItem item in level.Checklist.ChecklistItems)
                    {
                        OSurveyChecklistItem scItem = TablesLogic.tSurveyChecklistItem.Create();
                        scItem.StepNumber = item.StepNumber;
                        scItem.ObjectName = item.ObjectName;
                        scItem.ChecklistItemType = item.ChecklistType;
                        scItem.ChecklistResponseSetID = item.ChecklistResponseSetID;
                        scItem.IsOverall = item.IsOverall;
                        scItem.IsMandatoryField = item.IsMandatoryField;
                        scItem.ChecklistID = level.ChecklistID;
                        scItem.HasSingleTextboxField = item.HasSingleTextboxField;
                        scItem.ChecklistItemID = item.ObjectID;

                        scItem.SurveyTargetType = this.SurveyTargetType;
                        
                        scItem.SurveyPlannerID = this.SurveyPlannerID;
                        scItem.SurveyRespondentID = this.SurveyPlannerRespondent.SurveyRespondentID;
                        scItem.SurveyRespondentPortfolioID = this.SurveyPlannerRespondent.SurveyRespondentPortfolioID;//201109
                        scItem.SurveyGroupServiceLevelID = level.ObjectID;
                        //scItem.EvaluatedContractID = this.EvaluatedContractID;
                        //scItem.EvaluatedVendorID = this.EvaluatedVendorID;
                        

                        //if (this.SurveyTargetType == (int)EnumSurveyTargetType.Tenant ||
                        //    this.SurveyTargetType == (int)EnumSurveyTargetType.Others)
                        //    scItem.EvaluatedParty = level.SurveyGroup.ObjectName;
                        //else
                        //    scItem.EvaluatedParty = this.EvaluatedParty;

                        this.SurveyChecklistItems.Add(scItem);
                    }
                }
            }
        }

        /// <summary>
        /// Construct public URL for this survey
        /// e.g. https://eam-survey.dc.capitaland.com with
        /// text Click here to take survey
        /// </summary>
        public string EmbeddedEmailURL
        {
            get
            {
                return "<a href=\"" + 
                    OSurveyPlanner.GenerateSurveyFormURL(this.SurveyPlannerID.Value, 
                    this.SurveyPlannerRespondent.SurveyRespondentPortfolioID.Value, this.SurveyPlannerRespondent.SurveyRespondentPortfolio.EmailAddress, false) + //201109
                    "\">" + "Click here to take survey" + "</a>";
            }
        }

        public string SurveyStatusType
        {
            get
            {
                return TranslateSurveyStatusType(this.Status);
            }
        }

        public string TranslateSurveyStatusType(int? status)
        {
            switch (status)
            {
                case (int)EnumSurveyStatusType.Open:
                    return "Open to collect response";
                    break;
                case (int)EnumSurveyStatusType.Responded:
                    return "Response collected";
                    break;
                case (int)EnumSurveyStatusType.ClosedWithResponse:
                    return "Closed with response collected";
                    break;
                case (int)EnumSurveyStatusType.ClosedWithoutResponse:
                    return "Closed with no response";
                    break;
                default:
                    return "Error";
            }
        }

        /// <summary>
        /// Dear User,
        /// Please click on the following URL to complete the online evaluation form.
        /// {0}
        /// Please submit by end of {1}.
        /// Thank you.
        /// This is a computer-generated email, please do not reply to this email address. If you have any enquiries, please email to:
        /// moe_fdd_pdm_surveys@moe.gov.sg
        /// P.S.: Please copy the URL and paste it into your browser address bar if the online evaluation form can not be opened by clicking on the URL.
        /// </summary>
        /// <param name="type"></param>
        public void SendSurveyEmail(OSurveyPlannerNotification notification)
        {
            if (notification.SurveyEmailType == (int)EnumSurveyEmailType.SurveyStarted)
            {
                SendMessage(notification.SubjectMessageTemplate, notification.BodyMessageTemplate, this.SurveyPlannerRespondent.SurveyRespondent.EmailAddress, "");
                //SendMessage("Survey_SurveyStarted", this.SurveyPlannerRespondent.SurveyRespondent.EmailAddress, "");
            }
            if (notification.SurveyEmailType == (int)EnumSurveyEmailType.SurveyNotResponded)
            {
                SendMessage(notification.SubjectMessageTemplate, notification.BodyMessageTemplate, this.SurveyPlannerRespondent.SurveyRespondent.EmailAddress, "");
                //SendMessage("Survey_SurveyReminder", this.SurveyPlannerRespondent.SurveyRespondent.EmailAddress, "");
            }
        }
    }

    public enum EnumSurveyStatusType
    {
        Open = 0,
        Saved = 1,
        Responded = 2,
        ClosedWithResponse = 3,
        ClosedWithoutResponse = 4
    }


    
}

