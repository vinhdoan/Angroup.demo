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
    /// <summary>
    /// Summary description for TCase
    /// </summary>
    public partial class TCase : LogicLayerSchema<OCase>
    {
        // Caller information
        public SchemaString Caller;
        [Size(255)]
        public SchemaString CallerContact;
        // Time Stats
        public SchemaDateTime IncidentStartTime;
        public SchemaDateTime IncidentRespondTime;
        public SchemaDateTime IncidentEscalationTime;
        public SchemaDateTime IncidentResolutionTime;
        public SchemaDateTime IncidentClosedTime;
        public SchemaInt ToInformSupervisor;       
    }

    /// <summary>
    /// Summary description for OCase
    /// </summary>
    public abstract partial class OCase : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract String Caller { get; set; }
        public abstract String CallerContact { get; set; }

        public abstract DateTime? IncidentDateTime { get; set; }
        public abstract DateTime? IncidentRespondTime { get; set; }
        public abstract DateTime? IncidentEscalationTime { get; set; }
        public abstract DateTime? IncidentResolutionTime { get; set; }
        public abstract DateTime? IncidentClosedTime { get; set; }
        public abstract int? ToInformSupervisor { get; set; }
    }
}

