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
    [Database("#database"), Map("ChecklistResponse")]
    [Serializable] public partial class TChecklistResponse : LogicLayerSchema<OChecklistResponse>
    {
        public SchemaGuid ChecklistResponseSetID;
        public SchemaDecimal ScoreNumerator;
        public SchemaInt DisplayOrder;

        public TChecklistResponseSet ChecklistResponseSet { get { return OneToOne<TChecklistResponseSet>("ChecklistResponseSetID"); } }
    }


    /// <summary>
    /// Represents a collection of responses available to the user 
    /// for selection in a checklist item. An example of set of
    /// responses is as follows: Yes/No/Unknown. There are 3 responses,
    /// and the 3 together form a logical response set.
    /// </summary>
    [Serializable]
    public abstract partial class OChecklistResponse : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// ChecklistResponseSet table.
        /// </summary>
        public abstract Guid? ChecklistResponseSetID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the actual score accumulated by the
        /// checklist if the user selects this response for the checklist
        /// item.
        /// </summary>
        public abstract decimal? ScoreNumerator { get; set; }
        /// <summary>
        /// [Column] Gets or sets the order of display of this response
        /// in relation to the rest of the responses in the response set.
        /// </summary>
        public abstract int? DisplayOrder { get; set; }

        /// <summary>
        /// Gets or sets the OChecklistResponseSet object that contains
        /// this response as one of its many responses.
        /// </summary>
        public abstract OChecklistResponseSet ChecklistResponseSet { get; }

        public bool IsDuplicateName(OChecklistResponseSet set)
        {
            foreach (OChecklistResponse resp in set.ChecklistResponses)
                if (resp != this && resp.ObjectName == this.ObjectName && resp.ObjectID != this.ObjectID)
                    return true;
            return false;
        }


    }
}
