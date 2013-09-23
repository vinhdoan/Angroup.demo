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
    /// Summary description for OSurveyTrade
    /// </summary>
    [Database("#database"), Map("SurveyTrade")]
    public partial class TSurveyTrade : LogicLayerSchema<OSurveyTrade>
    {
        public SchemaInt DisplayOrder;
        public SchemaGuid SurveyPlannerID;
        public SchemaGuid SurveyGroupID;
        public SchemaGuid ChecklistID;

        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }
        public TSurveyGroup SurveyGroup { get { return OneToOne<TSurveyGroup>("SurveyGroupID"); } }
        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }
    }


    public abstract partial class OSurveyTrade : LogicLayerPersistentObject
    {
        public abstract int? DisplayOrder { get; set; }
        public abstract Guid? SurveyPlannerID { get; set; }
        public abstract Guid? SurveyGroupID { get; set; }
        public abstract Guid? ChecklistID { get; set; }

        public abstract OSurveyPlanner SurveyPlanner { get; set; }
        public abstract OSurveyGroup SurveyGroup { get; set; }
        public abstract OChecklist Checklist { get; set; }

    }

}

