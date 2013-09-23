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
    [Database("#database"), Map("ReportField")]
    [Serializable]
    public partial class TReportField : LogicLayerSchema<OReportField>
    {
        public SchemaGuid ReportID;
        public SchemaInt DisplayOrder;
        public SchemaString ControlIdentifier;
        [Size(255)]
        public SchemaString ControlCaption;
        public SchemaInt ControlSpan;
        public SchemaInt ControlType;
        public SchemaInt DataType;
        public SchemaInt ContextTree;
        [Size(255)]
        public SchemaString ControlHint;

        [Default(1)]
        public SchemaInt IsInsertBlank;
        public SchemaInt IsRequiredField;
        public SchemaInt IsPopulatedByQuery;
        public SchemaText TextList;
        public SchemaText ValueList;
        public SchemaText ListQuery;
        public SchemaString DataTextField;
        public SchemaString DataValueField;
        public SchemaString CSharpMethodName;
        public SchemaString ResourceAssemblyName;
        public SchemaString ResourceName;

        public TReport Report { get { return OneToOne<TReport>("ReportID"); } }
        public TReportField CascadeControl { get { return ManyToMany<TReportField>("ReportFieldsCascadeFields", "ReportFieldID", "CascadeControlID"); } }

    }


    [Serializable]
    public abstract partial class OReportField : LogicLayerPersistentObject
    {
        public abstract Guid? ReportID { get; set; }
        public abstract int? DisplayOrder { get; set; }
        public abstract String ControlIdentifier { get; set; }
        public abstract String ControlCaption { get; set; }
        public abstract int? ControlSpan { get; set; }
        public abstract int? ControlType { get; set; }
        public abstract int? DataType { get; set; }
        public abstract int? ContextTree { get; set; }
        public abstract String ControlHint { get; set; }

        public abstract int? IsInsertBlank { get; set; }
        public abstract int? IsRequiredField { get; set; }
        public abstract int? IsPopulatedByQuery { get; set; }
        public abstract String TextList { get; set; }
        public abstract String ValueList { get; set; }
        public abstract string ListQuery { get; set; }
        public abstract String DataTextField { get; set; }
        public abstract String DataValueField { get; set; }
        public abstract String CSharpMethodName { get; set; }

        /// <summary>
        /// Gets or sets the resource assembly name used to translate
        /// content in thec column.
        /// </summary>
        public abstract string ResourceAssemblyName { get; set; }

        /// <summary>
        /// Gets or sets the resource name used to translate
        /// content in thec column. For example, Resources.WorkflowStates.
        /// </summary>
        public abstract string ResourceName { get; set; }

        public abstract DataList<OReport> Report { get; set; }
        public abstract DataList<OReportField> CascadeControl { get; set; }

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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="controlType"></param>
        /// <returns></returns>
        public static string TranslateControlType(int? controlType)
        {
            if (controlType == (int)EnumReportControlType.TexBox) return Resources.Strings.ReportFieldControlType_TextBox;
            else if (controlType == (int)EnumReportControlType.DateTime) return Resources.Strings.ReportFieldControlType_DateTime;
            else if (controlType == (int)EnumReportControlType.DropdownList) return Resources.Strings.ReportFieldControlType_DropdownList;
            else if (controlType == (int)EnumReportControlType.RadioButtonList) return Resources.Strings.ReportFieldControlType_RadioButtonList;
            else if (controlType == (int)EnumReportControlType.Date) return Resources.Strings.ReportFieldControlType_Date;
            else if (controlType == (int)EnumReportControlType.MultiSelectList) return Resources.Strings.ReportFieldControlType_MultiSelectList;
            else if (controlType == (int)EnumReportControlType.ContextTree) return Resources.Strings.ReportFieldControlType_ContextTree;
            else if (controlType == (int)EnumReportControlType.MonthYear) return Resources.Strings.ReportFieldControlType_MonthYear;
            else if (controlType == (int)EnumReportControlType.Checkbox) return "Checkbox";
            return "";
        }

        /// <summary>
        /// This is for internal context tree translation. 
        /// No need to put into resource files.
        /// </summary>
        /// <param name="controlType"></param>
        /// <returns></returns>
        public static string TranslateContextTree(int? controlType)
        {
            if (controlType == (int)EnumReportContextTree.Account) return "Account";
            else if (controlType == (int)EnumReportContextTree.Checklist) return "Checklist";
            else if (controlType == (int)EnumReportContextTree.Code) return "Code";
            else if (controlType == (int)EnumReportContextTree.CodeType) return "Code Type";
            else if (controlType == (int)EnumReportContextTree.Equipment) return "Equipment";
            else if (controlType == (int)EnumReportContextTree.EquipmentType) return "Equipment Type";
            else if (controlType == (int)EnumReportContextTree.InventoryCatalog) return "Inventory Catalog";
            else if (controlType == (int)EnumReportContextTree.Location) return "Location";
            else if (controlType == (int)EnumReportContextTree.LocationAndEquipment) return "Location and Equipment";
            else if (controlType == (int)EnumReportContextTree.LocationType) return "Location Type";
            else if (controlType == (int)EnumReportContextTree.ServiceCatalog) return "Service Catalog";
            return "";
        }

        public string ControlTypeText
        {
            get
            {
                return TranslateControlType(this.ControlType);
            }
        }

        public static DataTable GetReportControlTypeTable()
        {
            Type type = typeof(EnumReportControlType);
            //can't use type contraints on value types so have to check 
            if (type.BaseType != typeof(Enum))
                throw new Exception("EnumReportControlType must be of type systen.enum");

            //get value array of entityType values from enum
            Array enumValArray = Enum.GetValues(type);

            DataTable result = new DataTable();
            result.Columns.Add("Value", typeof(int));
            result.Columns.Add("Name", typeof(string));

            //add values and texts of enum to the datatable
            foreach (int val in enumValArray)
            {
                string name = TranslateControlType(val);
                //string name = Enum.GetName(type, val);
                result.Rows.Add(val, name);

            }
            result.DefaultView.Sort = "Name DESC";

            return result;
        }

        public static DataTable GetReportDataTypeTable()
        {
            Type type = typeof(EnumReportDataType);
            //can't use type contraints on value types so have to check 
            if (type.BaseType != typeof(Enum))
                throw new Exception("EnumReportDataType must be of type systen.enum");

            //get value array of entityType values from enum
            Array enumValArray = Enum.GetValues(type);

            DataTable result = new DataTable();
            result.Columns.Add("Value", typeof(int));
            result.Columns.Add("Name", typeof(string));

            //add values and texts of enum to the datatable
            foreach (int val in enumValArray)
            {
                string name = Enum.GetName(type, val);
                result.Rows.Add(val, name);
            }
            result.DefaultView.Sort = "Name DESC";

            return result;
        }

        public static DataTable GetReportContextTreeTable()
        {
            Type type = typeof(EnumReportContextTree);
            //can't use type contraints on value types so have to check 
            if (type.BaseType != typeof(Enum))
                throw new Exception("EnumReportContextTree must be of type systen.enum");

            //get value array of entityType values from enum
            Array enumValArray = Enum.GetValues(type);

            DataTable result = new DataTable();
            result.Columns.Add("Value", typeof(int));
            result.Columns.Add("Name", typeof(string));

            //add values and texts of enum to the datatable
            foreach (int val in enumValArray)
            {
                string name = TranslateContextTree(val);
                result.Rows.Add(val, name);

            }

            return result;
        }

    }

    public enum EnumReportFieldPopulateWith
    {
        ListCommaSeperator = 0,
        Query = 1,
        CSharpMethod = 2
    }


    /// <summary>
    /// 
    /// </summary>
    public enum EnumReportControlType
    {
        TexBox = 0,
        DateTime = 1,
        DropdownList = 2,
        RadioButtonList = 3,
        Date = 4,
        MultiSelectList = 5,
        ContextTree = 6,
        MonthYear = 7,
        Checkbox = 8
    }

    /// <summary>
    /// 
    /// </summary>
    public enum EnumReportDataType
    {
        String = 0,
        Integer = 1,
        Decimal = 2,
        Double = 3,
        DateTime = 4,
        UniqueIdentifier = 5
    }

    /// <summary>
    /// 
    /// </summary>
    public enum EnumReportContextTree
    {
        //<asp:ListItem Value="10" Text="Account" ></asp:ListItem>
        //                        <asp:ListItem Value="11" Text="Inventory Catalog" ></asp:ListItem>
        //                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Checklist"></asp:ListItem>
        //                        <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" Text="Code"></asp:ListItem>
        //                        <asp:ListItem Value="3" meta:resourcekey="ListItemResource4" Text="CodeType"></asp:ListItem>
        //                        <asp:ListItem Value="4" meta:resourcekey="ListItemResource5" Text="Equipment"></asp:ListItem>
        //                        <asp:ListItem Value="5" meta:resourcekey="ListItemResource6" Text="EquipmentType"></asp:ListItem>
        //                        <asp:ListItem Value="6" meta:resourcekey="ListItemResource7" Text="Location"></asp:ListItem>
        //                        <asp:ListItem Value="7" meta:resourcekey="ListItemResource8" Text="LocationType"></asp:ListItem>
        //                        <asp:ListItem Value="8" meta:resourcekey="ListItemResource9" Text="Location and Equipment"></asp:ListItem>
        //                        <asp:ListItem Value="9" meta:resourcekey="ListItemResource10" Text="Service Catalog"></asp:ListItem>
        Checklist = 1,
        Code = 2, 
        CodeType = 3,
        Equipment = 4,
        EquipmentType = 5,
        Location = 6,
        LocationType = 7,
        LocationAndEquipment = 8,
        ServiceCatalog = 9,
        Account = 10,
        InventoryCatalog = 11
    }
}

