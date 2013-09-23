//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using System.Collections;

namespace LogicLayer
{
    //rachel 16 Mar 2007    
    [Serializable] public abstract partial class OCustomizedRecordFieldValue : OCustomizedFieldValue
    {

    }

    [Map("CustomizedRecordFieldValue"), Database("#database")]
    [Serializable] public partial class TCustomizedRecordFieldValue : LogicLayerSchema<OCustomizedRecordFieldValue>
    {
        public SchemaGuid AttachedObjectID;
        public SchemaGuid AttachedPropertyID;
        public SchemaText FieldValue;
        [Size(100)]
        public SchemaString ColumnName;

    }


}
