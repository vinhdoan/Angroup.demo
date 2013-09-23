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
    public partial class TNotificationMilestones : LogicLayerSchema<ONotificationMilestones>
    {
        public SchemaString ObjectTypeName;
        [Size(255), Default("*")]
        public SchemaString States;

        public SchemaString ExpectedField1;
        public SchemaString DateTimeLimitField1;
        public SchemaString ReferenceField1;
        public SchemaString MilestoneName1;

        public SchemaString ExpectedField2;
        public SchemaString DateTimeLimitField2;
        public SchemaString ReferenceField2;
        public SchemaString MilestoneName2;

        public SchemaString ExpectedField3;
        public SchemaString DateTimeLimitField3;
        public SchemaString ReferenceField3;
        public SchemaString MilestoneName3;

        public SchemaString ExpectedField4;
        public SchemaString DateTimeLimitField4;
        public SchemaString ReferenceField4;
        public SchemaString MilestoneName4;



    }

    /// <summary>
    /// Represents a hierarchy of users or roles to
    /// which notifications will be sent when 
    /// action on workflow objects are not performed in time.
    /// </summary>
    public abstract partial class ONotificationMilestones : LogicLayerPersistentObject
    {
        public abstract String ObjectTypeName { get; set; }
        public abstract String States { get; set; }

        public abstract String ExpectedField1 { get; set; }
        public abstract String DateTimeLimitField1 { get; set; }
        public abstract String ReferenceField1 { get; set; }
        public abstract String MilestoneName1 { get; set; }

        public abstract String ExpectedField2 { get; set; }
        public abstract String DateTimeLimitField2 { get; set; }
        public abstract String ReferenceField2 { get; set; }
        public abstract String MilestoneName2 { get; set; }

        public abstract String ExpectedField3 { get; set; }
        public abstract String DateTimeLimitField3 { get; set; }
        public abstract String ReferenceField3 { get; set; }
        public abstract String MilestoneName3 { get; set; }

        public abstract String ExpectedField4 { get; set; }
        public abstract String DateTimeLimitField4 { get; set; }
        public abstract String ReferenceField4 { get; set; }
        public abstract String MilestoneName4 { get; set; }


        /// <summary>
        /// Allows the object to be deactivated if there
        /// are notification processes associated with this
        /// set of milestones.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if ((int)TablesLogic.tNotificationProcess.Select(
                TablesLogic.tNotificationProcess.ObjectID.Count())
                .Where(
                TablesLogic.tNotificationProcess.NotificationMilestonesID == this.ObjectID &
                TablesLogic.tNotificationProcess.IsDeleted == 0) > 0)
                return false;
            return true;
        }


        /// <summary>
        /// Gets all notification milestones.
        /// </summary>
        /// <param name="includingNotificationMilestonesId"></param>
        /// <returns></returns>
        public static List<ONotificationMilestones> GetAllMilestones(Guid? includingNotificationMilestonesId)
        {
            return TablesLogic.tNotificationMilestones.LoadList(
                TablesLogic.tNotificationMilestones.IsDeleted == 0 |
                TablesLogic.tNotificationMilestones.ObjectID == includingNotificationMilestonesId,
                true);
        }
    }


}