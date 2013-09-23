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
    
    public partial class TSurveyGroup : LogicLayerSchema<OSurveyGroup>
    {
        

        public SchemaInt SurveyTargetType;

    }

    /// <summary>
    /// Represents a survey group.
    /// </summary>
    public abstract partial class OSurveyGroup: LogicLayerPersistentObject
    {

        /// <summary>
        /// 
        /// </summary>
        public abstract int? SurveyTargetType { get; set; }

        public static List<OSurveyGroup> GetSurveyGroup()
        {
            return TablesLogic.tSurveyGroup.LoadList(Query.True);
        }

        public static List<OSurveyGroup> GetSurveyGroupBySurveyTargetType(int? targetType)
        {
            return TablesLogic.tSurveyGroup.LoadList
                (TablesLogic.tSurveyGroup.SurveyTargetType == targetType);
        }
    }
}
