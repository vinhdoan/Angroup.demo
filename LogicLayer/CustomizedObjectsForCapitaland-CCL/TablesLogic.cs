//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Reflection;
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
    /// Contains all the declarations to instantiate the Schema classes.
    /// </summary>
    public partial class TablesLogic : TablesData
    {
        public static TVendorEvaluation tVendorEvaluation = SchemaFactory.Get<TVendorEvaluation>();
        public static TVendorEvaluationChecklistItem tVendorEvaluationChecklistItem = SchemaFactory.Get<TVendorEvaluationChecklistItem>();

        public static TSurveyPlannerServiceLevel tSurveyPlannerServiceLevel = SchemaFactory.Get<TSurveyPlannerServiceLevel>();
        public static TSurveyServiceLevel tSurveyServiceLevel = SchemaFactory.Get<TSurveyServiceLevel>();

        public static TSurveyPlannerNotification tSurveyPlannerNotification = SchemaFactory.Get<TSurveyPlannerNotification>();
        public static TSurveyPlannerAccess tSurveyPlannerAccess = SchemaFactory.Get<TSurveyPlannerAccess>();
        public static TSurveyPlannerRespondent tSurveyPlannerRespondent = SchemaFactory.Get<TSurveyPlannerRespondent>();

        public static TSupporter tSupporter = SchemaFactory.Get<TSupporter>();
   }
}

