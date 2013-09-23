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
    /// Summary description for OSurveyTrade
    /// </summary>
    public partial class TSurveyPlannerServiceLevel : LogicLayerSchema<OSurveyPlannerServiceLevel>
    {
        public SchemaInt ItemNumber;
        
        public SchemaGuid SurveyPlannerID;
        
        public SchemaGuid SurveyServiceLevelID;
        
        public SchemaGuid ChecklistID;

        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }

        public TSurveyServiceLevel SurveyServiceLevel { get { return OneToOne<TSurveyServiceLevel>("SurveyServiceLevelID"); } }

        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }
    }


    public abstract partial class OSurveyPlannerServiceLevel : LogicLayerPersistentObject
    {
        public abstract int? ItemNumber { get; set; }
        
        public abstract Guid? SurveyPlannerID { get; set; }
        
        public abstract Guid? SurveyServiceLevelID { get; set; }
        
        public abstract Guid? ChecklistID { get; set; }

        public abstract OSurveyPlanner SurveyPlanner { get; set; }

        public abstract OSurveyServiceLevel SurveyServiceLevel { get; set; }

        public abstract OChecklist Checklist { get; set; }

    }

}

