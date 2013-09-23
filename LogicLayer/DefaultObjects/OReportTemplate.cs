//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

using Anacle.UIFramework;
using System.IO;
using System.Xml;
using System.Web.UI.WebControls;
using System.Web;


namespace LogicLayer
{
    [Database("#database"), Map("ReportTemplate")]
    [Serializable] public partial class TReportTemplate : LogicLayerSchema<OReportTemplate>
    {
        //reference to the report that this template is made for
        public SchemaGuid ReportID;
        //indicate the access control setting for the template: 1 is editable by public, 2 is editable by creator and viewable by all users, 3: editable and viewable by creator only
        public SchemaInt AccessControl;
        //store the columns setting of the report in XML format
        public SchemaText ReportXML;
        public SchemaString Description;
        public SchemaGuid CreatorID;
        //template is rdl report
        public SchemaImage RdlBytes;
        public SchemaInt TemplateType;

        public TReportDataSet ReportDataSet { get { return OneToMany<TReportDataSet>("ReportID"); } }
        public TReport Report { get { return OneToOne<TReport>("ReportID"); } }
        public TUser CreatorUser { get { return OneToOne<TUser>("CreatorID"); } }        
    }


    [Serializable] public abstract partial class OReportTemplate : LogicLayerPersistentObject
    {
        public abstract Guid? ReportID { get; set; }
        public abstract int? AccessControl { get; set; }
        public abstract string ReportXML { get; set; }
        public abstract string Description { get; set; }
        public abstract Guid? CreatorID { get; set; }
        public abstract byte[] RdlBytes { get; set; }

        /// <summary>
        /// [Columns] Gets or sets the format of report template. 
        /// 0: rdl; 1: crystal
        /// </summary>
        public abstract int? TemplateType { get; set; }

        public abstract DataList<OReportDataSet> ReportDataSet { get; }
        public abstract OUser CreatorUser { get; }
        public abstract OReport Report { get; }

        #region ReportTemplate

        /// <summary>
        /// Delete the report template. It first check if the user has the right to delete the report template, if have it will delete the template
        /// return true if successfully deleted, otherwise false
        /// </summary>
        /// <param name="templateID"></param>
        /// <param name="userID"></param>
        /// <returns></returns>
        public static bool DeleteTemplate(Guid templateID, Guid userID)
        {
            if (IsEditableTemplate(templateID, userID))
            {
                using (Connection c = new Connection())
                {
                    TablesLogic.tReportTemplate.Delete(templateID);
                    c.Commit();
                }
                return true;
            }
            else
            {
                return false;
            }
        }
        /// <summary>
        /// Check if the template is editable by the current user
        /// </summary>
        /// <param name="templateID"></param>
        /// <param name="userID"></param>
        /// <returns></returns>
        public static bool IsEditableTemplate(Guid templateID, Guid userID)
        {
            OReportTemplate template = TablesLogic.tReportTemplate[templateID];
            //do not allow edit if the report is private and the creator is not the user
            if ((template.AccessControl == (int)EnumReportTemplateAccessControl.AllowCreatorEditView || 
                template.AccessControl == (int)EnumReportTemplateAccessControl.AllowOthersViewOnly) && template.CreatorID != userID)
                return false;
            else
                return true;
        }

        /// <summary>
        /// return all the templates created for this report(only templates that are viewable by the current user
        /// </summary>
        /// <param name="ReportID"></param>
        /// <returns></returns>
        public static List<OReportTemplate> GetViewableReportTemplates(Guid ReportID, Guid userID)
        {
            return TablesLogic.tReportTemplate[
                TablesLogic.tReportTemplate.ReportID == ReportID & 
                TablesLogic.tReportTemplate.IsDeleted == 0 & 
                (
                (
                TablesLogic.tReportTemplate.AccessControl == (int)EnumReportTemplateAccessControl.AllowOthersEditView | 
                TablesLogic.tReportTemplate.AccessControl == (int)EnumReportTemplateAccessControl.AllowOthersViewOnly | 
                (TablesLogic.tReportTemplate.AccessControl == (int)EnumReportTemplateAccessControl.AllowCreatorEditView & 
                TablesLogic.tReportTemplate.CreatorID == userID)
                ) |
                //or if it is RDL template/crystal report template
                TablesLogic.tReportTemplate.RdlBytes != null
                )];
        }


        /// <summary>
        /// saving a template object
        /// </summary>
        /// <param name="template"></param>
        /// <param name="ReportObject"></param>
        /// <param name="ReportID"></param>
        /// <param name="TemplateName"></param>
        /// <param name="IsPublic"></param>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public static int SaveTemplateObject(OReportTemplate template, UIDragDropGrid ReportObject)
        {
            template.ReportXML = SerializeReportObject(ReportObject);
            int validate = ValidateReportTemplate(template);
            if (validate != 0)
                return validate;
            else
            {
                using (Connection c = new Connection())
                {
                    template.Save();
                    c.Commit();
                }
                return validate;
            }
        }
        /// <summary>
        /// template Name cannot be empty and cannot be the same to existing template name of the same report
        /// return 1 if the name is duplicated (return as integer instead of boolean is to cater for future enhancement where additional field could be added in and need validation
        /// return 0 if the template is valid
        /// </summary>
        /// <param name="TemplateName"></param>
        private static int ValidateReportTemplate(OReportTemplate template)
        {
            ArrayList list = Query.Select(TablesLogic.tReportTemplate.ObjectID).Where(TablesLogic.tReportTemplate.ObjectName == template.ObjectName & TablesLogic.tReportTemplate.ReportID == template.ReportID & TablesLogic.tReportTemplate.ObjectID != template.ObjectID);

            if (list != null && list.Count > 0)
                return 1;
            return 0;
        }

        /// <summary>
        /// Validate template name. Report template name can not be same to existing template name of the same report.
        /// </summary>
        /// <param name="report"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static bool IsTemplateNameDuplicate(OReport report, string name)
        {
            ArrayList list = TablesLogic.tReportTemplate.Select(TablesLogic.tReportTemplate.ObjectID).Where(TablesLogic.tReportTemplate.ObjectName == name & TablesLogic.tReportTemplate.Report.ObjectID == report.ObjectID);
            if (list != null && list.Count > 0)
                return true;
            return false;                
        }


        public static OReportTemplate DisplayReportTemplate(UIDragDropGrid ReportObject, Guid templateID)
        {
            OReportTemplate template = TablesLogic.tReportTemplate[templateID];
            DeserializeReportObject(ReportObject, template.ReportXML);
            return template;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ReportObject"></param>
        /// <param name="ReportXML"></param>
        private static void DeserializeReportObject(UIDragDropGrid ReportObject, string ReportXML)
        {
            DragDropGridColumnCollection Columns = new DragDropGridColumnCollection();
            DragDropGridColumnCollection ChartColumns = new DragDropGridColumnCollection();

            TextReader xml = new StringReader(ReportXML);
            //XmlTextReader reader = new XmlTextReader("E:\\Hein Program\\source-abell\\Test.xml");
            XmlTextReader reader = new XmlTextReader(xml);
            //Move the reader directly to the content of the file (it will point to the Root element)
            reader.MoveToContent();
            while (reader.Read())
            {
                //Surf through element node by node for different each node, handle it differently
                if (reader.NodeType == XmlNodeType.Element)
                {
                    switch (reader.Name)
                    {
                        case "ChartEventArg":
                            ReportObject.ChartEventArg = HttpUtility.HtmlDecode(reader.ReadString());
                            break;
                        case "GridChartView":
                            ReportObject.GridChartView = Convert.ToBoolean(reader.ReadString());
                            break;
                        case "ChartView":
                            ReportObject.ChartView = Convert.ToBoolean(reader.ReadString());
                            break;
                        case "DisplayChartType":
                            ReportObject.DisplayChartType = reader.ReadString();
                            break;
                        case "ChartXAxisColumn":
                            ReportObject.ChartXAxisColumn = Convert.ToInt32(reader.ReadString());
                            break;
                        //build the chartYAxisColumn arraylist
                        case "ChartYAxisColumn":
                            //read all the child of Y axis column element (including the YaxisColumn element itself)
                            XmlReader yCols = reader.ReadSubtree();
                            ArrayList yList = new ArrayList();
                            while (yCols.Read())
                            {
                                if (yCols.NodeType == XmlNodeType.Element && yCols.Name == "YColumnIndex")
                                    yList.Add(Convert.ToString(yCols.GetAttribute("Index")));
                            }
                            ReportObject.ChartYAxisColumn = yList;
                            break;
                        case "ChartZAxisColumn":
                            ReportObject.ChartZAxisColumn = Convert.ToInt32(reader.ReadString());
                            break;
                        case "ChartColumnCollection":
                            ChartColumns = DeserializeColumnCollection(reader.ReadSubtree());
                            foreach (DragDropGridColumn column in ReportObject.Columns)
                            {
                                DragDropGridColumn col = ChartColumns.Find((c) => c.ColumnName == column.ColumnName);
                                if (col == null)
                                {
                                    column.ColumnId = "col" + (ChartColumns.Count + 1).ToString();
                                    column.Visible = false;
                                    ChartColumns.Add(column);
                                }
                            }
                            ReportObject.ChartColumns = ChartColumns;
                            break;
                        case "CollapsedData":
                            ReportObject.CollapsedData = Convert.ToBoolean(reader.ReadString());
                            break;
                        case "CollapsedSummaryRows":
                            ReportObject.CollapsedSummaryRows = Convert.ToBoolean(reader.ReadString());
                            break;
                        case "GridColumnCollection":
                            Columns = DeserializeColumnCollection(reader.ReadSubtree());
                            foreach (DragDropGridColumn column in ReportObject.Columns)
                            {
                                DragDropGridColumn col = Columns.Find((c) => c.ColumnName == column.ColumnName);
                                if (col == null)
                                {
                                    column.ColumnId = "col" + (Columns.Count + 1).ToString();
                                    column.Visible = false;
                                    Columns.Add(column);
                                }
                            }
                            ReportObject.Columns = Columns;
                            break;
                    }
                }
            }
            reader.Close();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="cols"></param>
        /// <returns></returns>
        private static DragDropGridColumnCollection DeserializeColumnCollection(XmlReader cols)
        {
            DragDropGridColumnCollection columnCols = new DragDropGridColumnCollection();
            while (cols.Read())
            {
                if (cols.NodeType == XmlNodeType.Element && cols.Name == "ColSetting")
                {
                    DragDropGridColumn col = new DragDropGridColumn();
                    col.ColumnId = cols.GetAttribute("ColumnId");
                    col.ColumnAgg = (ColumnAgg)Enum.Parse(typeof(ColumnAgg), cols.GetAttribute("ColumnAgg"));
                    col.ColumnName = HttpUtility.HtmlDecode(cols.GetAttribute("ColumnName"));
                    col.ColumnGroup = (ColumnGroup)Enum.Parse(typeof(ColumnGroup), cols.GetAttribute("ColumnGroup"));
                    col.ColumnSort = (ColumnSort)Enum.Parse(typeof(ColumnSort), cols.GetAttribute("ColumnSort"));
                    col.DataType =
                        cols.GetAttribute("DataType") == "Int32" ? typeof(int) :
                        cols.GetAttribute("DataType") == "Double" ? typeof(double) :
                        cols.GetAttribute("DataType") == "Decimal" ? typeof(decimal) :
                        cols.GetAttribute("DataType") == "Guid" ? typeof(Guid) :
                        cols.GetAttribute("DataType") == "DateTime" ? typeof(DateTime) : typeof(string);
                    col.Visible = Convert.ToBoolean(cols.GetAttribute("Visible"));
                    col.DataFormatString = HttpUtility.HtmlDecode(cols.GetAttribute("DataFormatString"));
                    col.HeaderText = HttpUtility.HtmlDecode(cols.GetAttribute("HeaderText"));
                    col.SortPriority = HttpUtility.HtmlDecode(cols.GetAttribute("SortPriority"));
                    columnCols.Add(col);
                }
            }
            return columnCols;
        }
        
        /// <summary>
        /// convert the report properties into xml format to be kept in database. Return a string in xml format contain the setting of the report
        /// </summary>
        private static string SerializeReportObject(UIDragDropGrid ReportObject)
        {
            TextWriter xml = new StringWriter();
            try
            {
                XmlTextWriter writer = new XmlTextWriter(xml);
                //  XmlTextWriter writer = new XmlTextWriter("E:\\Hein Program\\source-abell\\Test.xml", null);

                //write the start document element (xml versioning)
                writer.WriteStartDocument();
                //root element
                writer.WriteStartElement("ReportTemplate");
                //Report chart setting
                //do not serialize the chart setting if there is no charteventarg

                // removed by KF temporarily
                //if (ReportObject.ChartEventArg != "")
                {
                    writer.WriteStartElement("ChartEventArg");
                    writer.WriteString(HttpUtility.HtmlEncode(ReportObject.ChartEventArg.ToString()));
                    writer.WriteEndElement();

                    writer.WriteStartElement("GridChartView");
                    writer.WriteString(ReportObject.GridChartView.ToString());
                    writer.WriteEndElement();

                    writer.WriteStartElement("ChartView");
                    writer.WriteString(ReportObject.ChartView.ToString());
                    writer.WriteEndElement();

                    writer.WriteStartElement("DisplayChartType");
                    writer.WriteString(ReportObject.DisplayChartType.ToString());
                    writer.WriteEndElement();

                    writer.WriteStartElement("ChartXAxisColumn");
                    writer.WriteString(ReportObject.ChartXAxisColumn.ToString());
                    writer.WriteEndElement();

                    //Chart Y axis: ArrayList value store the index of the columns(as element attribute) that represent in the Y axis
                    writer.WriteStartElement("ChartYAxisColumn");
                    if (ReportObject.ChartYAxisColumn != null)
                    {
                        for (int i = 0; i < ReportObject.ChartYAxisColumn.Count; i++)
                        {
                            writer.WriteStartElement("YColumnIndex");
                            writer.WriteAttributeString("Index", ReportObject.ChartYAxisColumn[i].ToString());
                            writer.WriteEndElement();
                        }
                    }
                    writer.WriteEndElement();

                    writer.WriteStartElement("ChartZAxisColumn");
                    writer.WriteString(ReportObject.ChartZAxisColumn.ToString());
                    writer.WriteEndElement();

                    //Chart column collection. Setting for each chart column is manifested through an attribute within the element (column)
                    if (ReportObject.ChartColumns != null)
                    {
                        writer.WriteStartElement("ChartColumnCollection");
                        //Each column is a child element of chartcolumns element                    
                        foreach (DragDropGridColumn col in ReportObject.ChartColumns)
                        {
                            SerializeReportColumn(writer, col);
                        }
                        writer.WriteEndElement();
                    }
                }
                //Grid View Setting
                writer.WriteStartElement("CollapsedData");
                writer.WriteString(ReportObject.CollapsedData.ToString());
                writer.WriteEndElement();

                //Grid View Setting
                writer.WriteStartElement("CollapsedSummaryRows");
                writer.WriteString(ReportObject.CollapsedSummaryRows.ToString());
                writer.WriteEndElement();

                //Grid column collection. Each column is the child element of gridcolumncollection. And each advanced column property will be presented as an attribute within the column element             
                if (ReportObject.Columns != null)
                {
                    writer.WriteStartElement("GridColumnCollection");
                    foreach (DragDropGridColumn col in ReportObject.Columns)
                    {
                        SerializeReportColumn(writer, col);
                    }
                    writer.WriteEndElement();
                }
                writer.WriteEndElement();
                writer.Flush();
                writer.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return xml.ToString();
        }
        /// <summary>
        /// Each column will be represented by one element. and the properties of the column are represented as attribues of the element
        /// </summary>
        private static void SerializeReportColumn(XmlTextWriter writer, DragDropGridColumn col)
        {
            writer.WriteStartElement("ColSetting");
            writer.WriteAttributeString("ColumnId", col.ColumnId.ToString());
            writer.WriteAttributeString("ColumnAgg", col.ColumnAgg.ToString());
            writer.WriteAttributeString("ColumnName", HttpUtility.HtmlEncode(col.ColumnName.ToString()));
            writer.WriteAttributeString("ColumnGroup", col.ColumnGroup.ToString());
            writer.WriteAttributeString("ColumnSort", col.ColumnSort.ToString());
            writer.WriteAttributeString("Visible", col.Visible.ToString());
            writer.WriteAttributeString("DataType", col.DataType.Name);
            writer.WriteAttributeString("DataFormatString", HttpUtility.HtmlEncode(col.DataFormatString));
            writer.WriteAttributeString("HeaderText", HttpUtility.HtmlEncode(col.HeaderText));
            writer.WriteAttributeString("SortPriority", HttpUtility.HtmlEncode(col.SortPriority));
            writer.WriteEndElement();
        }


        public string GetTemplateTypeName()
        {
            if (this.TemplateType != null)
            {
                if (Convert.ToInt32(this.TemplateType) == (int)TemplateTypeName.rdlreport)
                    return Resources.Strings.TemplateType_Rdl;
                if (Convert.ToInt32(this.TemplateType) == (int)TemplateTypeName.crystalreport)
                    return Resources.Strings.TemplateType_Rpt;
            }
            return "";
        }

        /// <summary>
        /// Validate input name against template name of the passed in report object.
        /// </summary>
        /// <param name="report"></param>
        /// <param name="name"></param>
        /// <param name="excludeTemplate"></param>
        /// <returns></returns>
        public static bool IsTemplateNameDuplicated(OReport report, string name, OReportTemplate excludeTemplate)
        {
            List<OReportTemplate> templates = TablesLogic.tReportTemplate.LoadList(
                TablesLogic.tReportTemplate.Report.ObjectID == report.ObjectID &
                (excludeTemplate == null? Query.True : TablesLogic.tReportTemplate.ObjectID != excludeTemplate.ObjectID));
            if(templates != null)
                foreach (OReportTemplate t in templates)
                {
                    if (t.ObjectName == name)
                        return true;
                }
            return false;
        }

        #endregion

        
    }

    public enum EnumReportTemplateAccessControl
    {
        AllowOthersEditView = 1,
        AllowOthersViewOnly = 2,
        AllowCreatorEditView = 3
    }

    public enum TemplateTypeName
    {
        rdlreport = 0,
        crystalreport = 1
    }

}
