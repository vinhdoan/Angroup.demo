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
    [Serializable]
    public abstract class OCustomizedFieldValue : LogicLayerPersistentObject
    {
        public abstract Guid? AttachedObjectID { get;set;}
        //column that can be bind to individual field
        public abstract String ColumnName { get;set;}
        //actual value
        public abstract String FieldValue { get;set;}

    }
    [Serializable]
    public abstract class OCustomizedObject : LogicLayerPersistentObject
    {
        public abstract string AttachedObjectName { get; set; }
        public abstract string AttachedPropertyName { get;set;}
        public abstract int? TabViewPosition { get;set;}
    }
    [Serializable]
    public abstract class OCustomizedField : LogicLayerPersistentObject
    {
        public abstract string ColumnName { get; set; }
        public abstract string ControlCaption { get; set; }
        public abstract string ControlSpan { get; set; }
        public abstract string ControlType { get; set; }
        public abstract string DataType { get; set; }
        public abstract int? MaxLength { get; set; }
        public abstract int? MultiLineTextBox { get; set; }
        public abstract int? IsPopulatedByCode { get; set; }
        public abstract Guid? CodeTypeID { get; set; }
        public abstract string TextList { get; set; }
        public abstract string ValueList { get; set; }
        public abstract int? ValidateRequiredField { get; set; }
        public abstract int? ValidateRangeField { get; set; }
        public abstract string ValidateRangeMin { get; set; }
        public abstract string ValidateRangeMax { get; set; }
        public abstract int? IsActive { get; set; }
        public abstract int? DisplayOrder { get;set;}
        public abstract string CheckboxCaption { get;set;}
        public abstract string ToolTip { get;set;}

        /// <summary>
        /// generate unique field ID 
        /// </summary>
        /// <param name="fieldIndex"></param>
        /// <returns></returns>
        public string GetUniqueFieldsID(string SessionID)
        {
            return SessionID + "_" + DateTime.Now.ToString("ddMMyyyyHHmmssfffffff");
        }

        public DataTable ConstructTextValueTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Text", typeof(string));
            dt.Columns.Add("Value", typeof(string));

            if (TextList == null || ValueList == null)
                return dt;

            string[] texts = TextList.Split(',');
            string[] values = ValueList.Split(',');

            for (int i = 0; i < texts.Length && i < values.Length; i++)
                dt.Rows.Add(texts[i], values[i]);
            return dt;
        }

    }

}
