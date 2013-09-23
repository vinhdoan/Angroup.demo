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
    /// Summary description for OSurveyPlannerExtension
    /// </summary>
    [Database("#database"), Map("SurveyPlannerUpdate")]
    public partial class TSurveyPlannerUpdate : LogicLayerSchema<OSurveyPlannerUpdate>
    {
        public SchemaGuid SurveyPlannerID;
        public SchemaDateTime PreviousValidityEnd;
        public SchemaDateTime NewValidityEnd;
        public SchemaDecimal PreviousSurveyThreshold;
        public SchemaDecimal NewSurveyThreshold;

        [Size(255)]
        public SchemaString Remarks;

        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }
    }


    public abstract partial class OSurveyPlannerUpdate : LogicLayerPersistentObject
    {
        public abstract Guid? SurveyPlannerID { get; set; }
        public abstract DateTime? PreviousValidityEnd { get; set; }
        public abstract DateTime? NewValidityEnd { get; set; }
        public abstract Decimal? PreviousSurveyThreshold { get; set; }
        public abstract Decimal? NewSurveyThreshold { get; set; }

        public abstract string Remarks { get; set; }

        public abstract OSurveyPlanner SurveyPlanner { get; set; }


    }

    public static class SurveyPlannerUpdateType
    {
        public const int ChangeOfSurveyThreshold = 0;
        public const int ExtensionOfSurveyValidityEnd = 1;
    }
}

