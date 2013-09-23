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
    /// Summary description for OSurveyRespondent
    /// </summary>
    public partial class TSurveyPlannerRespondent : LogicLayerSchema<OSurveyPlannerRespondent>
    {

        public SchemaGuid SurveyPlannerID;

        public SchemaGuid SurveyRespondentID;

        public SchemaGuid SurveyID;

        //public SchemaDateTime RespondedDateTime;

        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }

        public TSurveyRespondent SurveyRespondent { get { return OneToOne<TSurveyRespondent>("SurveyRespondentID"); } }
        

        public SchemaGuid SurveyRespondentPortfolioID;

        public TSurveyRespondentPortfolio SurveyRespondentPortfolio { get { return OneToOne<TSurveyRespondentPortfolio>("SurveyRespondentPortfolioID"); } }
    }


    public abstract partial class OSurveyPlannerRespondent : LogicLayerPersistentObject
    {

        public abstract Guid? SurveyPlannerID { get; set; }

        public abstract Guid? SurveyRespondentID { get; set; }

        public abstract Guid? SurveyID { get; set; }

        //public abstract DateTime? RespondedDateTime { get; set; }

        public abstract OSurveyPlanner SurveyPlanner { get; set; }

        public abstract OSurveyRespondent SurveyRespondent { get; set; }
        //201109
        public abstract Guid? SurveyRespondentPortfolioID { get; set; }

        public abstract OSurveyRespondentPortfolio SurveyRespondentPortfolio { get; set; }

    }

}

