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


using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("CustomizedRecordField")]
    [Serializable] public partial class TCustomizedRecordField : LogicLayerSchema<OCustomizedRecordField>
    {
        public SchemaGuid RecordObjectID;
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
        public TCustomizedRecordObject CustomizedRecordObject { get { return OneToOne<TCustomizedRecordObject>("RecordObjectID"); } }
    }


    [Serializable] public abstract partial class OCustomizedRecordField : OCustomizedField
    {
        public abstract Guid? RecordObjectID { get; set;}
        public abstract OCustomizedRecordObject CustomizedRecordObject { get;}
    }
}
