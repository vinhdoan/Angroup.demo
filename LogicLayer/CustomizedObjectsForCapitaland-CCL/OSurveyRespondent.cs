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
    /// Summary description for OSurveyRespondent
    /// </summary>
    public partial class TSurveyRespondent : LogicLayerSchema<OSurveyRespondent>
    {
        public SchemaInt SurveyTargetType;

        public SchemaInt RespondentType;

        public SchemaString EmailAddress;

        public SchemaDateTime ExpiryDate;

        public TLocation Locations { get { return ManyToMany<TLocation>("SurveyRespondentLocation", "SurveyRespondentID", "LocationID"); } }

        public SchemaGuid TenantID;

        public SchemaGuid UserID;

        public TUser Tenant { get { return OneToOne<TUser>("TenantID"); } }

        public TUser User { get { return OneToOne<TUser>("UserID"); } }
        
        public SchemaGuid SurveyRespondentPortfolioID;

        public TSurveyRespondentPortfolio SurveyRespondentPortfolio { get { return OneToOne<TSurveyRespondentPortfolio>("SurveyRespondentPortfolioID"); } }

        public SchemaGuid TenantContactID;

        public TTenantContact TenantContact { get { return OneToOne<TTenantContact>("TenantContactID"); } }
    }


    public abstract partial class OSurveyRespondent : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the values indicates the type of survey.
        /// <para></para>
        /// 0 - Surveys for Services provided by Contracted Vendors.
        /// 1 - Surveys for Services provided by Contracted Vendors evaluated by Managing Agents.
        /// 2 - Surveys for Other Reasons.
        /// </summary>
        public abstract int? SurveyTargetType { get; set; }

        public abstract int? RespondentType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the value of email address of this portfolio.
        /// </summary>
        public abstract string EmailAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the latest date for responding to survey.
        /// </summary>
        public abstract DateTime? ExpiryDate { get; set; }

        public abstract DataList<OLocation> Locations { get; set; }

        public abstract Guid? TenantID { get; set; }

        public abstract Guid? UserID { get; set; }

        public abstract OUser Tenant { get; set; }

        public abstract OUser User { get; set; }
        
        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? SurveyRespondentPortfolioID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract OSurveyRespondentPortfolio SurveyRespondentPortfolio { get; set; }

        public abstract Guid? TenantContactID { get; set; }

        public abstract OTenantContact TenantContact { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string LocationsAccess
        {
            get
            {
                string strLocation = "";
                foreach (OLocation location in this.Locations)
                    strLocation = strLocation == "" ? strLocation + location.ObjectName : strLocation + ", " + location.ObjectName;
                return strLocation;
            }
        }

    }

    public enum EnumRespondentType
    {
        Tenant = 0,
        User = 1,
        Others = 2
    }

}

