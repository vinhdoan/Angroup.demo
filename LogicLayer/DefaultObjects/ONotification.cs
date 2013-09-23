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
    public partial class TNotification : LogicLayerSchema<ONotification>
    {
        public SchemaGuid ActivityID;

        public SchemaGuid NotificationProcessID;

        public SchemaDateTime NextNotificationDateTime;
        public SchemaInt NextNotificationLevel;
        public SchemaInt NextNotificationMilestone;
    }


    /// <summary>
    /// </summary>
    public abstract partial class ONotification : LogicLayerPersistentObject
    {
        public abstract Guid? ActivityID { get; set; }

        public abstract Guid? NotificationProcessID { get; set; }

        public abstract DateTime? NextNotificationDateTime { get; set; }
        public abstract int? NextNotificationLevel { get; set; }
        public abstract int? NextNotificationMilestone { get; set; }

    }


}