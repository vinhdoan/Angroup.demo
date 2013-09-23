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
    /// Summary description for OSurveyResponseFrom
    /// </summary>
    public partial class TSurveyResponseFrom : LogicLayerSchema<OSurveyResponseFrom>
    {
       //201109
        public SchemaGuid SurveyRespondentID;

        public TSurveyRespondent SurveyRespondent { get { return OneToOne<TSurveyRespondent>("SurveyRespondentID"); } }
    }


    public abstract partial class OSurveyResponseFrom : LogicLayerPersistentObject
    {
        //201109
        public abstract Guid? SurveyRespondentID { get; set; }

        public abstract OSurveyRespondent SurveyRespondent { get; set; }

    }
}

