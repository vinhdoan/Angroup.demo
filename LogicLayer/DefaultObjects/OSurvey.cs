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
    /// Summary description for OSurvey
    /// </summary>
    [Database("#database"), Map("Survey")]
    public partial class TSurvey : LogicLayerSchema<OSurvey>
    {
        public SchemaInt Type;
        public SchemaInt SurveyType;
        public SchemaGuid SurveyPlannerID;
        public SchemaInt Status;

        public SchemaGuid LocationID;
        public SchemaGuid ContractID;
        public SchemaGuid SurveyGroupID;

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }
        public TSurveyGroup SurveyGroup { get { return OneToOne<TSurveyGroup>("SurveyGroupID"); } }
        public TSurveyResponseFrom SurveyResponseFroms { get { return OneToMany<TSurveyResponseFrom>("SurveyID"); } }
        public TSurveyResponseTo SurveyResponseTos { get { return OneToMany<TSurveyResponseTo>("SurveyID"); } }
        public TSurveyChecklistItem SurveyChecklistItems { get { return OneToMany<TSurveyChecklistItem>("SurveyID"); } }

    }


    public abstract partial class OSurvey : LogicLayerPersistentObject
    {
        public abstract int? Type { get; set; }
        public abstract int? SurveyType { get; set; }
        public abstract Guid? SurveyPlannerID { get; set; }
        public abstract int? Status { get; set; }

        public abstract Guid? LocationID { get; set; }
        public abstract Guid? ContractID { get; set; }
        public abstract Guid? SurveyGroupID { get; set; }

        public abstract OLocation Location { get; set; }
        public abstract OContract Contract { get; set; }
        public abstract OSurveyGroup SurveyGroup { get; set; }
        public abstract DataList<OSurveyResponseFrom> SurveyResponseFroms { get; set; }
        public abstract DataList<OSurveyResponseTo> SurveyResponseTos { get; set; }
        public abstract DataList<OSurveyChecklistItem> SurveyChecklistItems { get; set; }


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
            //    this.ObjectNumber = ORunningNumber.GenerateNextNumber("Survey", "SN/{2:00}{1:00}/{0:0000}", true);
            //}
        }

    }

    public static class SurveyEmailType
    {
        public const int SurveyStarted = 0;
        public const int SurveyExtended = 1;
        public const int SurveyClosed = 2;
        public const int RemindRespondent = 3;
    }
}

