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
    /// Summary description for OSurveyRespondent
    /// </summary>
    [Database("#database"), Map("SurveyRespondent")]
    public partial class TSurveyRespondent : LogicLayerSchema<OSurveyRespondent>
    {
        //20110908
        //public TSurveyRespondentPortfolio SurveyRespondentPortfolios { get { return OneToMany<TSurveyRespondentPortfolio>("SurveyRespondentID"); } }
    }


    public abstract partial class OSurveyRespondent : LogicLayerPersistentObject
    {
        // tessa comment out 20110908
        //1 survey respondent portfolio has many survey respondent
        //public abstract DataList<OSurveyRespondentPortfolio> SurveyRespondentPortfolios { get; set; }


    }

}

