//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

namespace Anacle.DataFramework
{
    [Map("Loglog"), Database("#databaseVisualGSM")]
    public class TLoglog : Schema<OLoglog>
    {
        public SchemaInt SeqNo;
        public SchemaInt Tried;
        [Size(255)]
        public SchemaString Destination;
        [Size(255)]
        public SchemaString Content;
        [Size(255)]
        public SchemaString OutContent;
        public SchemaDateTime RecTime;
        public SchemaDateTime SentTime;
        public SchemaDateTime WhenToSent;
        public SchemaInt Succeed;
        public SchemaInt PortNo;
    }


    public abstract class OLoglog : PersistentObject
    {
        public abstract int? SeqNo { get; set; }
        public abstract int? Tried { get; set; }
        public abstract String Destination { get; set; }
        public abstract String Content { get; set; }
        public abstract String OutContent { get; set; }
        public abstract DateTime? RecTime { get; set; }
        public abstract DateTime? SentTime { get; set; }
        public abstract DateTime? WhenToSent { get; set; }
        public abstract int? Succeed { get; set; }
        public abstract int? PortNo { get; set; }
    }

}
