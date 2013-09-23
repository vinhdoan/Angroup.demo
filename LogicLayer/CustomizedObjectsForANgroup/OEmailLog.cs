//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TEmailLog : LogicLayerSchema<OEmailLog>
    {
        public SchemaDateTime DateTimeReceived;
        [Size(255)]
        public SchemaString FromRecipient;
        [Size(255)]
        public SchemaString Subject;
        public SchemaText EmailBody;
        public SchemaInt IsSuccessful;
        [Size(255)]
        public SchemaString ErrorMessage;
    }

    public abstract partial class OEmailLog : LogicLayerPersistentObject
    {
        public abstract DateTime? DateTimeReceived { get; set; }

        public abstract String FromRecipient { get; set; }

        public abstract String Subject { get; set; }

        public abstract String EmailBody { get; set; }

        public abstract int? IsSuccessful { get; set; }

        public abstract String ErrorMessage { get; set; }

        public static OEmailLog WriteToEmailLog(String FromRecipient, String Subject, String EmailBody)
        {
            Audit.UserName = null;
            Workflow.CurrentUser = null;
            using (Connection c = new Connection())
            {
                OEmailLog log = TablesLogic.tEmailLog.Create();
                log.FromRecipient = FromRecipient;
                log.Subject = Subject;
                log.EmailBody = EmailBody;
                log.DateTimeReceived = DateTime.Now;
                //log.ErrorMessage = ErrorMessage;
                log.Save();
                c.Commit();
                return log;
            }
        }

        public void UpdateEmailLog(bool boolIsSuccessful, String strErrorMessage)
        {
            Audit.UserName = null;
            Workflow.CurrentUser = null;
            using (Connection c = new Connection())
            {
                if (boolIsSuccessful)
                    this.IsSuccessful = 1;
                else
                {
                    this.IsSuccessful = 0;
                    this.ErrorMessage = strErrorMessage;
                }
                this.Save();
                c.Commit();
            }
        }

        public String IsSuccessfulText
        {
            get
            {
                if (this.IsSuccessful == 1)
                    return "Yes";
                else
                    return "No";
            }
        }
    }
}