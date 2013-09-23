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
using System.Collections;
namespace LogicLayer
{

    [Database("#database"), Map("CustomizedRecordObject")]
    [Serializable] public partial class TCustomizedRecordObject : LogicLayerSchema<OCustomizedRecordObject>
    {
        [Size(255)]
        //the table schema of the object that this customized object is attached to such as tLocation
        public SchemaString AttachedObjectName;
        public SchemaInt TabViewPosition;
        //the translated object name for object record
        [Size(100)]
        public SchemaString TranslateObjectName;
        //attribute field definition
        public TCustomizedRecordField CustomizedRecordFields { get { return OneToMany<TCustomizedRecordField>("RecordObjectID"); } }
    }


    [Serializable] public abstract partial class OCustomizedRecordObject : LogicLayerPersistentObject
    {
        public abstract string AttachedObjectName { get; set; }
        public abstract string TranslateObjectName { get;set;}
        public abstract int? TabViewPosition { get;set;}
        public abstract DataList<OCustomizedRecordField> CustomizedRecordFields { get; }
        /// --------------------------------------------------------------
        /// <summary>
        /// Get all the object record fields for this object in display order
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public OCustomizedRecordField[] GetCustomizedRecordFields()
        {
            List<OCustomizedRecordField> objectFields = new List<OCustomizedRecordField>();
            Hashtable h = new Hashtable();
            int max = 0;

            foreach (OCustomizedRecordField field in this.CustomizedRecordFields)
            {
                if (field.DisplayOrder.Value > max)
                    max = field.DisplayOrder.Value;
                h[field.DisplayOrder.Value] = field;
            }
            for (int i = 0; i <= max; i++)
                if (h[i] != null)
                    objectFields.Add((OCustomizedRecordField)h[i]);
            return objectFields.ToArray();
        }
        public void ReorderItem(PersistentObject obj)
        {
            Global.ReorderItems(CustomizedRecordFields, obj, "DisplayOrder");
        }


    }
}
