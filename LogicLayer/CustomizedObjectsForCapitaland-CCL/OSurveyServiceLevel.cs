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
    /// Summary discription for OSurveyGroup.
    /// </summary>
    
    public partial class TSurveyServiceLevel : LogicLayerSchema<OSurveyServiceLevel>
    {
        public SchemaGuid SurveyChecklistID;

        public TChecklist SurveyChecklist { get { return OneToOne<TChecklist>("SurveyChecklistID"); } }

        public SchemaInt SurveyTargetType;

    }

    /// <summary>
    /// Represents a survey group.
    /// </summary>
    public abstract partial class OSurveyServiceLevel: LogicLayerPersistentObject
    {
        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? SurveyChecklistID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract OChecklist SurveyChecklist { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract int? SurveyTargetType { get; set; }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public static List<OSurveyServiceLevel> GetSurveyServiceLevels()
        {
            return TablesLogic.tSurveyServiceLevel.LoadList(Query.True);
        }

    }
}
