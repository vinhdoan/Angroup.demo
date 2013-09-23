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
    /// Summary description for OVendor
    /// </summary>
    [Database("#database"), Map("ScheduledWorkChecklist")]
    [Serializable] public partial class TScheduledWorkChecklist : LogicLayerSchema<OScheduledWorkChecklist>
    {
        public SchemaGuid ScheduledWorkID;
        public SchemaGuid ChecklistID;
        public SchemaInt CycleNumber;

        public TScheduledWork ScheduledWork { get { return OneToOne<TScheduledWork>("ScheduledWorkID"); } }
        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }
    }


    /// <summary>
    /// Represents a sequence of checklists that will be assigned to the cycles 
    /// of Work objects created by the ScheduledWork object.
    /// </summary>
    [Serializable] public abstract partial class OScheduledWorkChecklist : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the ScheduledWork table 
        /// that indicates the scheduled work object that contains this 
        /// record.
        /// </summary>
        public abstract Guid? ScheduledWorkID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Checklist table 
        /// that indicates the checklist that will be created for works
        /// in this cycle.
        /// </summary>
        public abstract Guid? ChecklistID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the cycle number. From the user
        /// interface, this will be automatically numbered from 1
        /// to the total number of OScheduledWorkChecklist objects.
        /// </summary>
        public abstract int? CycleNumber { get; set; }

        /// <summary>
        /// Gets or sets the OScheduled object that represents
        /// the scheduled work object that contains this 
        /// record.
        /// </summary>
        public abstract OScheduledWork ScheduledWork { get; set; }

        /// <summary>
        /// Gets or sets the OChecklist object that represents 
        /// the checklist that will be created for works
        /// in this cycle.
        /// </summary>
        public abstract OChecklist Checklist { get; set; }
    }

}