//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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
    public partial class TSurveyChecklistItem : LogicLayerSchema<OSurveyChecklistItem>
    {
        public SchemaGuid ChecklistItemID;

        public SchemaString NetworkID;

        public SchemaInt SurveyTargetType;

        public SchemaString EvaluatedParty;

        public SchemaGuid EvaluatedVendorID;

        public SchemaGuid EvaluatedContractID;

        public SchemaGuid SurveyGroupServiceLevelID;

        public SchemaString FilledInRespondentBuildingName;

        [Size(255)]
        public SchemaString FilledInRespondentUnitNumber;

        public SchemaString FilledInRespondentDesignation;

        public SchemaInt HasSingleTextboxField;

        public TChecklistItem ChecklistItem { get { return OneToOne<TChecklistItem>("ChecklistItemID"); } }

        //public TSurveyGroupServiceLevel SurveyGroupServiceLevel { get { return OneToOne<TSurveyGroupServiceLevel>("SurveyGroupServiceLevelID"); } }
        //201109
        public SchemaGuid SurveyRespondentPortfolioID;

        public TSurveyRespondentPortfolio SurveyRespondentPortfolio { get { return OneToOne<TSurveyRespondentPortfolio>("SurveyRespondentPortfolioID"); } }
    }


    /// <summary>
    /// Represents a step in a series of steps in a checklist, which can
    /// be attached to a work so that the assigned in-house technician
    /// or term contractor can perform inspections or actions indicated
    /// in the checklist.
    /// </summary>
    public abstract partial class OSurveyChecklistItem : LogicLayerPersistentObject
    {
        public abstract Guid? ChecklistItemID { get; set; }

        public abstract string NetworkID { get; set; }

        public abstract string FilledInRespondentBuildingName { get; set; }

        public abstract string FilledInRespondentUnitNumber { get; set; }

        public abstract string FilledInRespondentDesignation { get; set; }

        public abstract int? SurveyTargetType { get; set; }

        public abstract string EvaluatedParty { get; set; }

        public abstract Guid? EvaluatedVendorID { get; set; }

        public abstract Guid? EvaluatedContractID { get; set; }

        public abstract Guid? SurveyGroupServiceLevelID { get; set; }

        public abstract int? HasSingleTextboxField { get; set; }

        public abstract OChecklistItem ChecklistItem { get; set; }

        //public abstract OSurveyGroupServiceLevel SurveyGroupServiceLevel { get; set; }
        //201109
        public abstract Guid? SurveyRespondentPortfolioID { get; set; }
        public abstract OSurveyRespondentPortfolio SurveyRespondentPortfolio { get; set; }
    }

    
}