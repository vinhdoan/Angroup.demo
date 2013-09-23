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
using System.Data.SqlClient;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("CustomizedAttributeField")]
    public class TCustomizedAttributeField : LogicLayerSchema<OCustomizedAttributeField>
    {
        //ID of the object this attribute object tied to, it's the GUID of the editing  Location Type. it is 1:m relationship
        public SchemaGuid MainObjectID;
        [Size(255)]
        //refer to the object type name of the object that this customized object is attached to such as LOCATION 
        public SchemaString AttachedObjectName;
        //column name of the attribute in the main object. such as locationTypeID, 
        [Size(100)]
        public SchemaString AttachedPropertyName;
        public SchemaString TabViewID;

        [Size(100)]
        public SchemaString ColumnName;
        public SchemaString ControlCaption;
        public SchemaString ControlSpan;
        public SchemaString ControlType;
        public SchemaString DataType;
        public SchemaInt MaxLength;
        public SchemaInt MultiLineTextBox;
        public SchemaInt IsPopulatedByCode;
        public SchemaGuid CodeTypeID;
        public SchemaText TextList;
        public SchemaText ValueList;
        public SchemaInt ValidateRequiredField;
        public SchemaInt ValidateRangeField;
        public SchemaString ValidateRangeMin;
        public SchemaString ValidateRangeMax;
        public SchemaInt IsActive;
        public SchemaInt DisplayOrder;
        public SchemaString CheckboxCaption;
        [Size(255)]
        public SchemaString ToolTip;
        public SchemaInt IsVisible;
    }


    [Serializable] public abstract class OCustomizedAttributeField : OCustomizedField
    {
        public abstract Guid? MainObjectID { get; set;}
        //refer to the main object
        public abstract string AttachedObjectName { get; set; }
        public abstract string AttachedPropertyName { get;set;}
        public abstract string TabViewID { get;set;}
        public abstract int? IsVisible { get;set;}
    }
}
