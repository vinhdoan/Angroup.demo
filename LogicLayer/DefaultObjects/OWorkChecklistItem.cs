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
    /// Summary description for OChecklist
    /// </summary>
    [Database("#database"), Map("WorkChecklistItem")]
    public partial class TWorkChecklistItem : LogicLayerSchema<OWorkChecklistItem>
    {
        public SchemaGuid WorkID;
        public SchemaInt StepNumber;
        public SchemaInt ChecklistType;
        public SchemaDecimal ScoreDenominator;
        public SchemaGuid SelectedResponseID;
        public SchemaGuid ChecklistResponseSetID;

        [Size(255)]
        public SchemaString Description;

        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }
        public TChecklistResponseSet ChecklistResponseSet { get { return OneToOne<TChecklistResponseSet>("ChecklistResponseSetID"); } }
        public TChecklistResponse SelectedResponses { get { return OneToOne<TChecklistResponse>("SelectedResponseID"); } }
    }


    /// <summary>
    /// Represents a step in a series of steps in a checklist, which can
    /// be attached to a work so that the assigned in-house technician
    /// or term contractor can perform inspections or actions indicated
    /// in the checklist.
    /// </summary>
    public abstract partial class OWorkChecklistItem : LogicLayerPersistentObject
    {

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Work table 
        /// that indicates the work that contains this checklist item.
        /// </summary>
        public abstract Guid? WorkID { get;set;}

        /// <summary>
        /// [Column] Gets or sets the step number of this checklist item.
        /// </summary>
        public abstract int? StepNumber { get;set;}

        /// <summary>
        /// [Column] Gets or sets a value that indicates the item type
        /// of this checklist.
        /// <para></para>
        /// <list>
        /// <item>0 - Choice: the user can select the response from a list of choices</item>
        /// <item>1 - Remarks: the user can input remarks</item>
        /// <item>2 - None: the user need not input any remarks or select any response.</item>
        /// </list>
        /// </summary>
        public abstract int? ChecklistType { get;set;}

        /// <summary>
        /// [Column] Gets or sets the score denominator of this
        /// checklist item. 
        /// </summary>
        public abstract decimal? ScoreDenominator { get;set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the WorkChecklistItemResponse table 
        /// that indicates the response selected by the assigned technician
        /// or contractor.
        /// </summary>
        public abstract Guid? SelectedResponseID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of action or inspection
        /// that the assigned users must perform as part of the checklist.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// Gets or sets the OWork object that represents the work
        /// object that this checklist item is attached to.
        /// </summary>
        public abstract OWork Work { get; set; }
        public abstract OChecklistResponseSet ChecklistResponseSet { get; set; }
        public abstract Guid? ChecklistResponseSetID { get; set; }


    }

}