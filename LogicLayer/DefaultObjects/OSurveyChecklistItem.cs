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
    /// Summary description for OSurveyChecklistItem
    /// </summary>
    [Database("#database"), Map("SurveyChecklistItem")]
    public partial class TSurveyChecklistItem : LogicLayerSchema<OSurveyChecklistItem>
    {
        public SchemaGuid SurveyPlannerID;
        public SchemaGuid SurveyID;
        public SchemaGuid EvaluatedPartyID;
        [Size(255)]
        public SchemaString EvaluatedPartyName;
        public SchemaGuid SurveyResponseToID;
        public SchemaGuid SurveyResponseFromID;
        public SchemaGuid SurveyRespondentID;
        public SchemaInt Status;

        [Size(255)]
        public SchemaString FilledInRespondentName;
        public SchemaString FilledInRespondentContactNumber;
        public SchemaString FilledInRespondentEmailAddress;

        public SchemaInt StepNumber;
        public SchemaInt IsMandatoryField;
        public SchemaInt ChecklistItemType;
        public SchemaGuid ChecklistID;
        public SchemaGuid ChecklistResponseSetID;
        public SchemaInt IsOverall;

        [Size(500)]
        public SchemaString Description;

        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }
        public TSurvey Survey { get { return OneToOne<TSurvey>("SurveyID"); } }
        public TSurveyResponseTo SurveyResponseTo { get { return OneToOne<TSurveyResponseTo>("SurveyResponseToID"); } }
        public TSurveyResponseFrom SurveyResponseFrom { get { return OneToOne<TSurveyResponseFrom>("SurveyResponseFromID"); } }
        public TSurveyRespondent SurveyRespondent { get { return OneToOne<TSurveyRespondent>("SurveyRespondentID"); } }
        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }
        public TChecklistResponseSet ChecklistResponseSet { get { return OneToOne<TChecklistResponseSet>("ChecklistResponseSetID"); } }
        public TChecklistResponse SelectedResponses { get { return ManyToMany<TChecklistResponse>("SurveyChecklistItemChecklistResponse", "SurveyChecklistItemID", "ChecklistResponseID"); } }        
    }


    /// <summary>
    /// Represents a step in a series of steps in a checklist, which can
    /// be attached to a work so that the assigned in-house technician
    /// or term contractor can perform inspections or actions indicated
    /// in the checklist.
    /// </summary>
    public abstract partial class OSurveyChecklistItem : LogicLayerPersistentObject
    {
        public abstract Guid? SurveyPlannerID { get;set;}
        public abstract Guid? SurveyID { get;set;}
        public abstract Guid? EvaluatedPartyID { get;set;}
        public abstract string EvaluatedPartyName { get; set; }

        public abstract Guid? SurveyResponseToID { get;set;}
        public abstract Guid? SurveyResponseFromID { get;set;}
        public abstract Guid? SurveyRespondentID { get;set;}
        public abstract int? Status { get;set;}

        public abstract string FilledInRespondentName { get;set;}
        public abstract string FilledInRespondentContactNumber { get;set;}
        public abstract string FilledInRespondentEmailAddress { get;set;}

        public abstract int? StepNumber { get;set;}
        public abstract int? IsMandatoryField { get;set;}
        public abstract int? ChecklistItemType { get;set;}
        public abstract Guid? ChecklistID { get;set;}
        public abstract Guid? ChecklistResponseSetID { get; set; }
        public abstract int? IsOverall { get; set; }
        
        public abstract string Description { get; set; }

        public abstract OSurveyPlanner SurveyPlanner { get; set; }
        public abstract OSurvey Survey { get; set; }
        public abstract OSurveyResponseTo SurveyResponseTo { get; set; }
        public abstract OSurveyResponseFrom SurveyResponseFrom { get; set; }
        public abstract OSurveyRespondent SurveyRespondent { get; set; }
        public abstract OChecklist Checklist { get; set; }
        public abstract OChecklistResponseSet ChecklistResponseSet { get; set; }
        public abstract DataList<OChecklistResponse> SelectedResponses { get; }

        /// --------------------------------------------------------------
        /// <summary>
        /// Set the survey number format
        /// </summary>
        /// --------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            if (this.IsNew)
            {
                // format of the contract number can be changed per customization
                //
                this.ObjectNumber = ORunningNumber.GenerateNextNumber("SurveyChecklistItem", "SCLI/{2:00}{1:00}/{0:0000}", true);
            }
        }
    }

    public static class SurveyStatusType
    {
        public const int OpenForReply = 0;
        public const int ValidWithReply = 1;
        public const int CloseWithoutReply = 2;
    }
}