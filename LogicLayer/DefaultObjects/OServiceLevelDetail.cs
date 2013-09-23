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
    [Database("#database"), Map("ServiceLevelDetail")]
    [Serializable] public partial class TServiceLevelDetail : LogicLayerSchema<OServiceLevelDetail>
    {
        public SchemaGuid ServiceLevelID;
        public SchemaInt StepNumber;
        public SchemaGuid TypeOfServiceID;
        public SchemaInt Priority;
        public SchemaInt AcknowledgementLimitInMinutes;
        public SchemaInt ArrivalLimitInMinutes;
        public SchemaInt CompletionLimitInMinutes;

        public TServiceLevel ServiceLevel { get { return OneToOne<TServiceLevel>("ServiceLevelID"); } }
        public TCode TypeOfService { get { return OneToOne<TCode>("TypeOfServiceID"); } }
    }


    /// <summary>
    /// Represents a set up of acknowledgement, arrival and completion
    /// time limits by the type of service and priority. 
    /// </summary>
    [Serializable]
    public abstract partial class OServiceLevelDetail : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the ServiceLevel table 
        /// that indicates 
        /// </summary>
        public abstract Guid? ServiceLevelID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the step number of this service level.
        /// </summary>
        public abstract int? StepNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the priority of the work this set of
        /// limits will apply to.
        /// </summary>
        public abstract int? Priority { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the type of service of the work this
        /// set of limits will apply to.
        /// </summary>
        public abstract Guid? TypeOfServiceID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the acknowledgement time in minutes.
        /// </summary>
        public abstract int? AcknowledgementLimitInMinutes { get; set; }

        /// <summary>
        /// [Column] Gets or sets the arrival time in minutes.
        /// </summary>
        public abstract int? ArrivalLimitInMinutes { get; set; }

        /// <summary>
        /// [Column] Gets or sets the completion time in minutes.
        /// </summary>
        public abstract int? CompletionLimitInMinutes { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents
        /// the type of service of the work this
        /// set of limits will apply to.
        /// </summary>
        public abstract OCode TypeOfService { get; set; }

        public OServiceLevelDetail()
        {
        }
    }
}


