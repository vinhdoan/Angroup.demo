//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    [Database("#database"), Map("SurveyRespondentPortfolio")]
    public partial class TSurveyRespondentPortfolio : LogicLayerSchema<OSurveyRespondentPortfolio>
    {
        public SchemaInt SurveyType;
        //public SchemaGuid SurveyRespondentID;
        public SchemaString EmailAddress;
        public SchemaDateTime ExpiryDate;

        public TSurveyRespondent SurveyRespondents { get { return OneToMany<TSurveyRespondent>("SurveyRespondentPortfolioID"); } }
        public TLocation Locations { get { return ManyToMany<TLocation>("SurveyRespondentPortfolioLocation", "SurveyRespondentPortfolioID", "LocationID"); } }
        public TContract Contracts { get { return ManyToMany<TContract>("SurveyRespondentPortfolioContract", "SurveyRespondentPortfolioID", "ContractID"); } }
    }


    public abstract partial class OSurveyRespondentPortfolio : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the values indicates the type of survey.
        /// <para></para>
        /// 0 - Surveys for Services provided by Contracted Vendors.
        /// 1 - Surveys for Services provided by Contracted Vendors evaluated by Managing Agents.
        /// 2 - Surveys for Other Reasons.
        /// </summary>
        public abstract int? SurveyType { get; set; }

        

        /// <summary>
        /// [Column] Gets or sets the value of email address of this portfolio.
        /// </summary>
        public abstract string EmailAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the latest date for responding to survey.
        /// </summary>
        public abstract DateTime? ExpiryDate { get; set; }

        /// <summary>
        /// Gets or sets an OSurveyRespondent object that this portfolio is associated with.
        /// </summary>
        public abstract DataList<OSurveyRespondent> SurveyRespondents { get; set; }

        /// <summary>
        /// Gets or sets a many-to-many list of locations that represent the locations
        /// that this portfolio is associated with.
        /// </summary>
        public abstract DataList<OLocation> Locations { get; set; }

        /// <summary>
        /// Gets or sets a many-to-many list of contracts that this portfolio 
        /// is associated with.
        /// </summary>
        public abstract DataList<OContract> Contracts { get; set; }


        /// <summary>
        /// Translate survey type to string.
        /// </summary>
        public string SurveyTypeText
        {
            get
            {
                string SurveyTypeText = Resources.Strings.SurveyPortfolio_Error;
                if (SurveyType == 0)
                    SurveyTypeText = Resources.Strings.SurveyPortfolio_ContractedVendor;
                if (SurveyType == 1)
                    SurveyTypeText = Resources.Strings.SurveyPortfolio_ContractedVendorByMA;
                if (SurveyType == 2)
                    SurveyTypeText = Resources.Strings.SurveyPortfolio_OtherReasons;

                return SurveyTypeText;
            }
        }

        //201109
        //public static List<OSurveyRespondentPortfolio> GetListOfSurveyRespondentPortfolio(int? SurveyTargetType,
        //    ArrayList ListOfSurveyRespondentPortfolioType, DateTime? ExpiryDateAfterInclusive, DateTime? ExpiryDateBeforeExclusive)
        //{
        //    List<OSurveyRespondentPortfolio> list = new List<OSurveyRespondentPortfolio>();

        //    list = TablesLogic.tSurveyRespondentPortfolio.LoadList(
        //        (ExpiryDateAfterInclusive == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.ExpiryDate == null | TablesLogic.tSurveyRespondentPortfolio.ExpiryDate >= ExpiryDateAfterInclusive) &
        //        (ExpiryDateBeforeExclusive == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.ExpiryDate == null | TablesLogic.tSurveyRespondentPortfolio.ExpiryDate < ExpiryDateBeforeExclusive) &
        //        (SurveyTargetType == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.SurveyType == SurveyTargetType) &
        //        (ListOfSurveyRespondentPortfolioType == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.SurveyType.In(ListOfSurveyRespondentPortfolioType))
        //        , TablesLogic.tSurveyRespondentPortfolio.SurveyType.Asc, TablesLogic.tSurveyRespondentPortfolio.ObjectName.Asc);

        //    return list;
        //}

    }

}

