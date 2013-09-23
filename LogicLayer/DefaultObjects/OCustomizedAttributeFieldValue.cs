//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;

using System.Collections;
using Anacle.DataFramework;

namespace LogicLayer
{
    //rachel 16 Mar 2007    
    [Serializable] public abstract partial class OCustomizedAttributeFieldValue : OCustomizedFieldValue
    {
        //set the attched type id, such as the location type id of the location object to make sure when the location's location type id changed, this will not be binded to that location anymore. 
        public abstract Guid? AttachedPropertyID { get;set;}
    }

    [Map("CustomizedAttributeFieldValue"), Database("#database")]
    [Serializable] public partial class TCustomizedAttributeFieldValue : LogicLayerSchema<OCustomizedAttributeFieldValue>
    {
        public SchemaGuid AttachedObjectID;
        public SchemaGuid AttachedPropertyID;
        public SchemaText FieldValue;
        [Size(100)]
        public SchemaString ColumnName;
    }
}
