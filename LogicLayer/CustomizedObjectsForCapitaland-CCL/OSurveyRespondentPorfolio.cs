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
    /// Summary description for OSurveyRespondentPortfolio
    /// </summary>
    public partial class TSurveyRespondentPortfolio : LogicLayerSchema<OSurveyRespondentPortfolio>
    {
        public SchemaInt RespondentType;

        [Default(0)]
        public SchemaInt AppliesToAllLocations;
        
    }


    public abstract partial class OSurveyRespondentPortfolio : LogicLayerPersistentObject
    {
        
        public abstract int? AppliesToAllLocations { get; set; }

        public abstract int? RespondentType { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string LocationsAccess
        {
            get
            {
                string strLocation = "";
                if (this.AppliesToAllLocations != 1)
                    foreach (OLocation location in this.Locations)
                        strLocation = strLocation == "" ? strLocation + location.ObjectName : strLocation + ", " + location.ObjectName;
                else
                    strLocation = OLocation.GetRootLocation().ObjectName;
                return strLocation;
            }
        }
    }

}

