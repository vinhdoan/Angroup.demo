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
    /// Summary description for OSurveyResponseFrom
    /// </summary>
    [Database("#database"), Map("SurveyResponseFrom")]
    public partial class TSurveyResponseFrom : LogicLayerSchema<OSurveyResponseFrom>
    {
        public SchemaGuid SurveyPlannerID;
        public SchemaGuid SurveyID;
        public SchemaGuid SurveyRespondentPortfolioID;
        public SchemaString EmailAddress;

        public TSurveyRespondentPortfolio SurveyRespondentPortfolio { get { return OneToOne<TSurveyRespondentPortfolio>("SurveyRespondentPortfolioID"); } }
        public TLocation Locations { get { return ManyToMany<TLocation>("SurveyRespondentLocation", "SurveyRespondentPortfolioID", "LocationID"); } }//201109
        public TSurveyChecklistItem SurveyCheckListItems { get { return OneToMany<TSurveyChecklistItem>("SurveyResponseFromID"); } }
    }


    public abstract partial class OSurveyResponseFrom : LogicLayerPersistentObject
    {
        public abstract Guid? SurveyPlannerID { get; set; }
        public abstract Guid? SurveyID { get; set; }
        public abstract Guid? SurveyRespondentPortfolioID { get; set; }
        public abstract string EmailAddress { get; set; }

        public abstract OSurveyRespondentPortfolio SurveyRespondentPortfolio { get; set; }
        public abstract DataList<OLocation> Locations { get; set; }
        public abstract DataList<OSurveyChecklistItem> SurveyCheckListItems { get; set; }

    }
}

