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
    /// Summary discription for OSurveyGroup.
    /// </summary>
    [Database("#database"), Map("SurveyGroup")]
    public partial class TSurveyGroup : LogicLayerSchema<OSurveyGroup>
    {
        public SchemaGuid DefaultSurveyChecklistID;
        public SchemaInt SurveyContractedVendor;
        public SchemaInt SurveyContractedVendorEvaluatedByMA;
        public SchemaInt SurveyOthers;
        public SchemaInt ContractMandatory;
        [Size(255)]
        public SchemaString EvaluatedPartyName;

        public TChecklist Checklist { get { return OneToOne<TChecklist>("DefaultSurveyChecklistID"); } }
    }

    /// <summary>
    /// Represents a survey group.
    /// </summary>
    public abstract partial class OSurveyGroup: LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// Checklist object that indicates the default checklist for this survey object.
        /// </summary>
        public abstract Guid? DefaultSurveyChecklistID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the value that indicates that
        /// whether or not this survey is the survey for services 
        /// provided by contracted vendors.
        /// </summary>
        public abstract int? SurveyContractedVendor { get; set; }

        /// <summary>
        /// [Column] Gets or sets the value that indicates that
        /// whether or not this survey is the survey for services 
        /// provided by contracted vendors evaluated by Managing Agents.
        /// </summary>
        public abstract int? SurveyContractedVendorEvaluatedByMA { get; set; }

        /// <summary>
        /// [Column] Gets or sets the value that indicates that
        /// whether or not this survey is the survey for other reasons.
        /// </summary>
        public abstract int? SurveyOthers { get; set; }

        /// <summary>
        /// [Column] Gets or sets the value that indicates that
        /// whether or not this survey is tied up with a specific contract.
        /// </summary>
        public abstract int? ContractMandatory { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name of the 
        /// evaluated party.
        /// </summary>
        public abstract String EvaluatedPartyName { get; set; }

        /// <summary>
        /// Gets the OChecklist object that represents
        /// the checklist for this survey.
        /// </summary>
        public abstract OChecklist Checklist { get; }



        /// <summary>
        /// 
        /// </summary>
        /// <param name="IsContractMandatory"></param>
        /// <returns></returns>
        public static List<OSurveyGroup> GetSurveyGroupByType(int? IsContractMandatory)
        {
            return TablesLogic.tSurveyGroup.LoadList(
                (IsContractMandatory == null ? Query.True : TablesLogic.tSurveyGroup.ContractMandatory == IsContractMandatory));
        }
    }

    public static class SurveyTargetTypeClass
    {
        public const int SurveyContractedVendor = 0;
        public const int SurveyContractedVendorEvaluatedByMA = 1;
        public const int SurveyOthers = 2;
    }
}
