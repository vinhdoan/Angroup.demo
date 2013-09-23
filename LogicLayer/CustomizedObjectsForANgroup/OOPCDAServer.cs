//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TOPCDAServer : LogicLayerSchema<OOPCDAServer>
    {
        public SchemaInt IsReadFromTextFile;
        [Size(255)]
        public SchemaString TextFilePathFormat;
        public SchemaInt BMSReadingDayDifference;
    }


   
    public abstract partial class OOPCDAServer : LogicLayerPersistentObject
    {
        public abstract int? IsReadFromTextFile { get; set; }
        public abstract String TextFilePathFormat { get; set; }
        public abstract int? BMSReadingDayDifference { get; set; }
    }
}

