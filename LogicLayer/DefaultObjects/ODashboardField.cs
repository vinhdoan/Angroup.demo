//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using Anacle.DataFramework;


namespace LogicLayer
{
    [Serializable]
    public partial class TDashboardField : LogicLayerSchema<ODashboardField>
    {
        public SchemaGuid DashboardID;
        public SchemaInt DisplayOrder;
        public SchemaString ControlIdentifier;
        [Size(255)]
        public SchemaString ControlCaption;
        public SchemaInt ControlType;
        public SchemaInt DataType;

        [Default(1)]
        public SchemaInt IsInsertBlank;
        public SchemaInt IsPopulatedByQuery;
        public SchemaText TextList;
        public SchemaText ValueList;
        public SchemaText ListQuery;
        public SchemaString DataTextField;
        public SchemaString DataValueField;
        public SchemaString CSharpMethodName;

        public TDashboard Dashboard { get { return OneToOne<TDashboard>("DashboardID"); } }
        public TDashboardField CascadeControl { get { return ManyToMany<TDashboardField>("DashboardFieldsCascadeFields", "DashboardFieldID", "CascadeControlID"); } }

    }


    [Serializable]
    public abstract partial class ODashboardField : LogicLayerPersistentObject
    {
        public abstract Guid? DashboardID { get; set; }
        public abstract int? DisplayOrder { get; set; }
        public abstract String ControlIdentifier { get; set; }
        public abstract String ControlCaption { get; set; }
        public abstract int? ControlType { get; set; }
        public abstract int? DataType { get; set; }

        public abstract int? IsInsertBlank { get; set; }
        public abstract int? IsPopulatedByQuery { get; set; }
        public abstract String TextList { get; set; }
        public abstract String ValueList { get; set; }
        public abstract string ListQuery { get; set; }
        public abstract String DataTextField { get; set; }
        public abstract String DataValueField { get; set; }
        public abstract String CSharpMethodName { get; set; }

        public abstract DataList<ODashboard> Dashboard { get; set; }
        public abstract DataList<ODashboardField> CascadeControl { get; set; }

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

        public string ControlTypeText
        {
            get
            {
                if (ControlType == 0) return Resources.Strings.ReportFieldControlType_TextBox;
                else if (ControlType == 1) return Resources.Strings.ReportFieldControlType_DateTime;
                else if (ControlType == 2) return Resources.Strings.ReportFieldControlType_DropdownList;
                else if (ControlType == 3) return Resources.Strings.ReportFieldControlType_RadioButtonList;
                else if (ControlType == 4) return Resources.Strings.ReportFieldControlType_Date;
                else if (ControlType == 5) return Resources.Strings.ReportFieldControlType_MultiSelectList;
                else if (ControlType == 6) return Resources.Strings.ReportFieldControlType_ContextTree;
                return "";
            }
        }

    }
}

