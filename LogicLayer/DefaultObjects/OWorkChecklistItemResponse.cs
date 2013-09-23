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
    /// Summary description for OChecklistResponseSet
    /// </summary>

    [Database("#database"), Map("WorkChecklistItemResponse")]
    public partial class TWorkChecklistItemResponse : LogicLayerSchema<OWorkChecklistItemResponse>
    {
        public SchemaInt DisplayOrder;
        public SchemaGuid WorkChecklistItemID;
        public SchemaDecimal ScoreNumerator;

        public TWorkChecklistItem WorkChecklistItem { get { return OneToOne<TWorkChecklistItem>("WorkChecklistItemID"); } }
    }


    /// <summary>
    /// Represents a possible response for a checklist item that 
    /// is attached to the work. Responses are answers to a question
    /// in the checklist, and examples are: 'Yes', 'No', 'Ok', 'Not Ok',
    /// etc.
    /// </summary>
    public abstract partial class OWorkChecklistItemResponse : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the order of display of 
        /// this response.
        /// </summary>
        public abstract int? DisplayOrder { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the ? table 
        /// that indicates
        /// </summary>
        public abstract Guid? WorkChecklistItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the numerator of the score,
        /// the score that will be added to the total if
        /// the user selects this response.
        /// </summary>
        public abstract decimal? ScoreNumerator { get; set; }

        /// <summary>
        /// Gets or sets the OWorkChecklistItem object that represents
        /// the checklist item that this record is a response to.
        /// </summary>
        public abstract OWorkChecklistItem WorkChecklistItem { get; }
    }

}