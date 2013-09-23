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
using System.Data.Odbc;
using System.Data.Common;
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
    /// Summary description for OSurveyPlanner
    /// </summary>
    public partial class TSurveyPlannerAccess : LogicLayerSchema<OSurveyPlannerAccess>
    {
        public SchemaGuid UserID;
        public SchemaGuid SurveyPlannerID;

        public TUser User { get { return OneToOne<TUser>("UserID"); } }
        public TSurveyPlanner SurveyPlanner { get { return OneToOne<TSurveyPlanner>("SurveyPlannerID"); } }
           
    }


    public abstract partial class OSurveyPlannerAccess : LogicLayerPersistentObject
    {
        public abstract Guid? UserID { get; set; }
        public abstract Guid? SurveyPlannerID { get; set; }

        public abstract OUser User { get; set; }
        public abstract OSurveyPlanner SurveyPlanner { get; set; }
    }
}


