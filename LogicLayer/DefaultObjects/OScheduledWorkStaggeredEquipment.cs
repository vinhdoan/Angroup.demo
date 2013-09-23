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
    [Database("#database"), Map("ScheduledWorkStaggeredEquipment")]
    [Serializable] public partial class TScheduledWorkStaggeredEquipment : LogicLayerSchema<OScheduledWorkStaggeredEquipment>
    {
        public SchemaGuid ScheduledWorkID;
        public SchemaGuid EquipmentID;
        public SchemaInt UnitsToStagger;

        public TScheduledWork ScheduledWork { get { return OneToOne<TScheduledWork>("ScheduledWorkID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
    }


    /// <summary>
    /// Represents information the equipment that will be associated with
    /// the works scheduled, and the number of days or weeks or months or
    /// years to stagger that work.
    /// </summary>
    [Serializable] public abstract partial class OScheduledWorkStaggeredEquipment : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the ScheduledWork table 
        /// that indicates the scheduled work object that contains
        /// this record.
        /// </summary>
        public abstract Guid? ScheduledWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Equipment table 
        /// that indicates the equipment that the work generated will be
        /// associated with.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days/weeks/months/years
        /// to stagger the work. This means that the work generated
        /// for this equipment will be moved forward by the specified
        /// number of days/weeks/months/years from the date all works
        /// for that cycle are originally scheduled to start.
        /// <para></para>
        /// The scheduled work's StaggerBy will
        /// indicate the unit (day/week/month/year) to stagger. 
        /// </summary>
        public abstract int? UnitsToStagger { get; set; }

        /// <summary>
        /// Gets or sets the OScheduledWork object that represents
        /// the scheduled work that contains this record.
        /// </summary>
        public abstract OScheduledWork ScheduledWork { get; set; }

        /// <summary>
        /// Gets or sets the OEquipment object that represents
        /// the equipment that the work generated will be
        /// associated with.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }
    }

}