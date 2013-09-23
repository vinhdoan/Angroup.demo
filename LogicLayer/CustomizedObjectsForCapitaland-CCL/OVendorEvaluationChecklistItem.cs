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

    public partial class TVendorEvaluationChecklistItem : LogicLayerSchema<OVendorEvaluationChecklistItem>
    {
        public SchemaGuid VendorEvaluationID;
        public SchemaInt StepNumber;
        public SchemaInt ChecklistType;
        public SchemaDecimal ScoreDenominator;
        public SchemaGuid ChecklistItemID;
        public SchemaGuid SelectedResponseID;
        public SchemaGuid ChecklistResponseSetID;

        public SchemaInt IsOverall;

        [Size(255)]
        public SchemaString Description;

        public TVendorEvaluation VendorEvaluation { get { return OneToOne<TVendorEvaluation>("VendorEvaluationID"); } }
        public TChecklistItem ChecklistItem { get { return OneToOne<TChecklistItem>("ChecklistItemID"); } }
        public TChecklistResponseSet ChecklistResponseSet { get { return OneToOne<TChecklistResponseSet>("ChecklistResponseSetID"); } }
        public TChecklistResponse SelectedResponse { get { return OneToOne<TChecklistResponse>("SelectedResponseID"); } }
    }


    public abstract partial class OVendorEvaluationChecklistItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Work table 
        /// that indicates the work that contains this checklist item.
        /// </summary>
        public abstract Guid? VendorEvaluationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the step number of this checklist item.
        /// </summary>
        public abstract int? StepNumber { get; set; }

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
        public abstract int? ChecklistType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the score denominator of this
        /// checklist item. 
        /// </summary>
        public abstract decimal? ScoreDenominator { get; set; }

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
        public abstract OVendorEvaluation VendorEvaluation { get; set; }
        public abstract int? IsOverall { get; set; }
        public abstract Guid? ChecklistItemID { get; set; }
        public abstract OChecklistItem ChecklistItem { get; set; }
        public abstract OChecklistResponseSet ChecklistResponseSet { get; set; }
        public abstract OChecklistResponse SelectedResponse { get; set; }
        public abstract Guid? ChecklistResponseSetID { get; set; }
    }

}
