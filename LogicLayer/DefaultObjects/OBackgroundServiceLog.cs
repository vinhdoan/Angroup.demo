//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TBackgroundServiceLog : LogicLayerSchema<OBackgroundServiceLog>
    {
        [Size(255)]
        public SchemaString ServiceName;
        public SchemaInt MessageType;
        [Size(4000)]
        public SchemaString Message;
        

    }

    public abstract partial class OBackgroundServiceLog : LogicLayerPersistentObject
    {
        public abstract string ServiceName { get; set; }

        public abstract int? MessageType { get; set; }

        public abstract string Message { get; set; }
        
        /// <summary>
        /// Deletes messages from the background service log table older than 
        /// n number of days, where n is a value set up in the Application Settings.
        /// </summary>
        public static void ClearLogHistory(DateTime lastDate)
        {
            using (Connection c = new Connection())
            {
                TablesLogic.tBackgroundServiceLog.DeleteList(
                    TablesLogic.tBackgroundServiceLog.CreatedDateTime < lastDate);
                c.Commit();
            }
        }
    }

    // from EventLogEntryType
    public enum BackgroundLogMessageType
    {
        // Summary:
        //     An error event. This indicates a significant problem the user should know
        //     about; usually a loss of functionality or data.
        Error = 1,
        //
        // Summary:
        //     A warning event. This indicates a problem that is not immediately significant,
        //     but that may signify conditions that could cause future problems.
        Warning = 2,
        //
        // Summary:
        //     An information event. This indicates a significant, successful operation.
        Information = 4,
        //
        // Summary:
        //     A success audit event. This indicates a security event that occurs when an
        //     audited access attempt is successful; for example, logging on successfully.
        SuccessAudit = 8,
        //
        // Summary:
        //     A failure audit event. This indicates a security event that occurs when an
        //     audited access attempt fails; for example, a failed attempt to open a file.
        FailureAudit = 16,
    }
}
