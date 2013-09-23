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
    /// Summary description for OSurveyResponseTo
    /// </summary>
    [Database("#database"), Map("SurveyResponseTo")]
    public partial class TSurveyResponseTo : LogicLayerSchema<OSurveyResponseTo>
    {
        public SchemaGuid SurveyTradeID;
        public SchemaGuid SurveyPlannerID;

        public SchemaInt DisplayOrder;
        public SchemaGuid SurveyID;
        public SchemaGuid ChecklistID;
        public SchemaInt ContractMandatory;

        public SchemaGuid ContractID;

        // Additional fields to keep tract information when it is not contract mandatory
        //
        [Size(255)]
        public SchemaString EvaluatedPartyName;

        public TSurvey Survey { get { return OneToOne<TSurvey>("SurveyID"); } }
        public TSurveyTrade SurveyTrade { get { return OneToOne<TSurveyTrade>("SurveyTradeID"); } }
        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }
        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }
    }


    public abstract partial class OSurveyResponseTo : LogicLayerPersistentObject
    {
        public abstract Guid? SurveyTradeID { get; set; }
        public abstract Guid? SurveyPlannerID { get; set; }

        public abstract int? DisplayOrder { get; set; }
        public abstract Guid? SurveyID { get; set; }
        public abstract Guid? ChecklistID { get; set; }
        public abstract int? ContractMandatory { get; set; }

        public abstract Guid? ContractID { get; set; }

        public abstract String EvaluatedPartyName { get; set; }

        public abstract OSurvey Survey { get; set; }
        public abstract OSurveyTrade SurveyTrade { get; set; }
        public abstract OChecklist Checklist { get; set; }
        public abstract OContract Contract { get; set; }


        public string EvaluatedParty
        {
            get
            {
                if (this.ContractMandatory == 1 && this.Contract != null && this.Contract.Vendor != null)
                {
                    return this.Contract.Vendor.ObjectName;
                }
                else
                {
                    return this.EvaluatedPartyName;
                }
            }
        }

    }
}

