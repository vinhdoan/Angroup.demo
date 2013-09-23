//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;
using System.Xml;

namespace LogicLayer
{
    [Database("#database"), Map("Report")]
    [Serializable] public partial class TReport : LogicLayerSchema<OReport>
    {
        public SchemaInt ContextTree;
        public SchemaInt ReportType;
        public SchemaImage ReportFileBytes;
        [Size(100)]
        public SchemaString ReportFileName;
        public SchemaText ReportQuery;
        [Size(255)]
        public SchemaString DataSourceName;
        public SchemaInt OdbcSyntax;
        public SchemaString ParamPrefix;
        [Default(0)]
        public SchemaInt UseCSharpQuery;
        [Size(255)]      
        public SchemaString CSharpMethodName;
        //Rachel. Visible column at start
        public SchemaInt VisibleColumnAtStart;
        [Size(255)]
        public SchemaString CategoryName;
        [Size(255)]
        public SchemaString ReportName;

        public TReportField CascadeControl { get { return ManyToMany<TReportField>("ReportCascadeFields", "ReportID", "CascadeControlID"); } }

        public TReportDataSet ReportDataSet { get { return OneToMany<TReportDataSet>("ReportID"); } }
        public TReportField ReportFields { get { return OneToMany<TReportField>("ReportID"); } }
        public TRole Roles { get { return ManyToMany<TRole>("ReportRole", "ReportID", "RoleID"); } }

        public TReportColumnMapping ReportColumnMappings { get { return OneToMany<TReportColumnMapping>("ReportID"); } }
        public TReportTemplate ReportTemplate { get { return OneToMany<TReportTemplate>("ReportID"); } }
    }


    [Serializable] public abstract partial class OReport : LogicLayerPersistentObject, ICloneable, IAuditTrailEnabled
    {
        public abstract int? VisibleColumnAtStart { get;set;}
        public abstract string DataSourceName { get; set; }
        /// <summary>
        /// [Column] Gets or sets whether the Report's using ODBC Connection
        /// </summary>
        public abstract int? OdbcSyntax { get; set; }

        public abstract string ParamPrefix { get; set; }

        public abstract int? ContextTree { get; set; }

        /// <summary>
        /// [Column] Gets or sets type of the report
        /// </summary>
        public abstract int? ReportType { get; set; }

        /// <summary>
        /// [Column] Gets or sets Bytes of the rdl or crystal report
        /// </summary>
        public abstract byte[] ReportFileBytes { get;set;}

        /// <summary>
        /// [Column] Gets or sets file name of the rdl or crystal report
        /// </summary>
        public abstract string ReportFileName { get; set; }

        /// <summary>
        /// [Column] Gets or sets query string if the Spreadsheet report's not using CSharp
        /// </summary>
        public abstract string ReportQuery { get; set; }

        /// <summary>
        /// [Column] Gets or sets whether the report uses CSharp
        /// </summary>
        public abstract int? UseCSharpQuery { get; set; }

        /// <summary>
        /// [Column] Gets or sets the CSharp method name if the report's using CSharp
        /// </summary>
        public abstract string CSharpMethodName { get; set; }

        /// <summary>
        /// [Column] Gets or set the foreign key to the LocalizableCaption table to
        /// indicates Category Name
        /// </summary>
        public abstract string CategoryName { get; set; }

        /// <summary>
        /// [Column] Gets or set the foreign key to the LocalizableCaption table to
        /// indicates Report Name
        /// </summary>
        public abstract string ReportName { get; set; }

        public abstract DataList<OReportField> CascadeControl { get; set; }

        public abstract DataList<OReportDataSet> ReportDataSet { get;}

        public abstract DataList<OReportField> ReportFields { get; }

        public abstract DataList<ORole> Roles { get; }

        public abstract DataList<OReportColumnMapping> ReportColumnMappings { get; }

        public abstract DataList<OReportTemplate> ReportTemplate { get; set; }

        /// <summary>
        /// Gets a string that concatenates the category
        /// and the report name of this report.
        /// </summary>
        public string CategoryAndReportName
        {
            get
            {
                return CategoryName + " > " + ReportName;
            }
        }

        /// <summary>
        /// Returns the category and report name for audit trailing.
        /// </summary>
        public override string AuditObjectDescription
        {
            get
            {
                return CategoryAndReportName;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Re-order the display order of the individual fields in this 
        /// report.
        /// </summary>
        /// <param name="reportField"></param>
        /// --------------------------------------------------------------
        public void ReorderItems(OReportField reportField)
        {
            Hashtable h = new Hashtable();

            int max = 0;
            foreach (OReportField field in ReportFields)
            {
                if (reportField != null && field.ObjectID == reportField.ObjectID)
                    field.DisplayOrder = field.DisplayOrder * 2 - 1;
                else
                    field.DisplayOrder = field.DisplayOrder * 2;

                h[field.DisplayOrder.Value] = field;
                if (field.DisplayOrder.Value > max)
                    max = field.DisplayOrder.Value;
            }

            int c = 1;
            for (int i = 0; i <= max; i++)
            {
                if (h[i] != null)
                    ((OReportField)h[i]).DisplayOrder = c++;
            }
        }



        /// --------------------------------------------------------------
        /// <summary>
        /// Get all reports that the specified user has access to 
        /// and returns them as a DataTable.
        /// </summary>
        /// <param name="user"></param>
        /// <param name="categoryName"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static DataTable GetAllReportsByUserAndCategoryName(OUser user)
        {
            return TablesLogic.tReport.SelectDistinct(
                TablesLogic.tReport.ObjectID,
                TablesLogic.tReport.CategoryName,
                TablesLogic.tReport.ReportName)
                .Where(
                TablesLogic.tReport.IsDeleted == 0 &
                TablesLogic.tReport.Roles.RoleCode.In(user.GetRoleCodes()))
                .OrderBy(
                TablesLogic.tReport.CategoryName.Asc,
                TablesLogic.tReport.ReportName.Asc);
        }


        /// <summary>
        /// Get all the report fields for this report in display order
        /// </summary>
        /// <returns></returns>
        public List<OReportField> GetReportFieldsInOrder()
        {
            List<OReportField> reportFields = new List<OReportField>();
            foreach (OReportField field in this.ReportFields)
                reportFields.Add(field);
            reportFields.Sort("DisplayOrder", true);
            return reportFields;
        }


        /// <summary>
        /// Get all fields that are dropdowns only
        /// </summary>
        /// <returns></returns>
        public List<OReportField> GetDropDownReportFields()
        {
            List<OReportField> reportFields = new List<OReportField>();
            if (this.ReportFields.Count > 0)
            {
                foreach (OReportField field in this.ReportFields)
                {
                    if (field.ControlType == 2 || field.ControlType == 3 || field.ControlType == 5)
                        reportFields.Add(field);
                }
            }
            return reportFields;
        }


        public List<OReportField> GetDropDownReportFields(string excludeFieldName)
        {
            List<OReportField> reportFields = new List<OReportField>();
            if (this.ReportFields.Count > 0)
            {
                foreach (OReportField field in this.ReportFields)
                {
                    if ((field.ControlType == 2 || field.ControlType == 3 || field.ControlType == 5) &&
                        field.ControlIdentifier != excludeFieldName)
                        reportFields.Add(field);
                }
            }
            return reportFields;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Traverse into the cascading fields to search for loops.
        /// </summary>
        /// <param name="field"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------      
        protected bool TraverseCascade(Hashtable h, OReportField field, DataTable cascadeTable)
        {
            Hashtable used = new Hashtable();
            OReportField currentField = field;

            while (currentField != null)
            {
                if (used[currentField.ObjectID.Value] != null)
                    return true;  // a loop is found

                used[currentField.ObjectID.Value] = true;
                int count = 0;
                if (currentField.CascadeControl.Count > 0)
                {
                    foreach (OReportField f in currentField.CascadeControl)
                    {
                        if (used[f.ObjectID.Value] != null ||
                             IsLoopCascade(cascadeTable,field,f))
                            return true;  // a loop is found
                        count++;
                        used[f.ObjectID.Value] = true;
                        cascadeTable.Rows.Add(new object[] { field.ObjectID.Value.ToString(), f.ObjectID.Value.ToString() });
                        if (count == currentField.CascadeControl.Count)
                            currentField = null;
                    }
                }
                else
                    break;
           }
            return false;
        }

        /// <summary>
        /// Checks to see if any of the fields has cascade loops.
        /// </summary>
        /// <param name="field"></param>
        /// <returns></returns>
        public bool CascadeHasLoops()
        {
            Hashtable h = new Hashtable();
            DataTable cascadeTable = new DataTable();
            cascadeTable.Columns.Add("Field");
            cascadeTable.Columns.Add("CascadeTo");
            foreach (OReportField field in this.ReportFields)
                h[field.ObjectID.Value] = field;

            foreach (OReportField field in this.ReportFields)
                if (TraverseCascade(h, field,cascadeTable))
                    return true;
            return false;
        }

        /// <summary>
        /// Checks if there is a loop cascade between a pair of report fields.
        /// </summary>
        /// <param name="cascadeTable"></param>
        /// <param name="field"></param>
        /// <param name="cascadeTo"></param>
        /// <returns></returns>
        public bool IsLoopCascade(DataTable cascadeTable, OReportField field, OReportField cascadeTo)
        {
            foreach (DataRow row in cascadeTable.Rows)
            {
                if (row["Field"].ToString() == cascadeTo.ObjectID.Value.ToString()
                    && row["CascadeTo"].ToString() == field.ObjectID.Value.ToString())
                    return true;
            }
            return false;
        }


        /// <summary>
        /// retrieve the static report setting such as Report dataset, query and parameter order if necessary 
        /// </summary>
        /// <param name="report"></param>
        /// <param name="b"></param>
        /// <param name="contents"></param>
        /// <param name="fileName"></param>
        public static void GetStaticReportSettings(OReport report, byte[] b, string contents, string fileName)
        {
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(contents);
            report.ReportFileBytes = b;
            report.ReportFileName = fileName;
            //retrieve dataset name.
            XmlNodeList datasetlist = xmlDoc.GetElementsByTagName("DataSet");
            if (datasetlist == null || datasetlist.Count == 0)
                throw new Exception("Cannot find data set from file. Please check your report document.");
            else
            {
                //clear existing report dataset
                report.ReportDataSet.Clear();
                for (int i = 0; i < datasetlist.Count; i++)
                {
                    OReportDataSet rDS = TablesLogic.tReportDataSet.Create();
                    rDS.ReportID = report.ObjectID;
                    rDS.DataSetName = datasetlist[i].Attributes["Name"].Value;
                    //retrieve the query of the dataset
                    XmlNodeList queryNode = datasetlist[i].ChildNodes;
                    for (int n = 0; n < queryNode.Count; n++)
                    {
                        if (queryNode[n].Name == "Query")
                        {
                            XmlNodeList queryChild = queryNode[n].ChildNodes;
                            for (int y = 0; y < queryChild.Count; y++)
                            {
                                if (queryChild[y].Name == "CommandText")
                                {
                                    rDS.Query = queryChild[y].InnerText;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    report.ReportDataSet.Add(rDS);
                }
            }

        }

        //used for static report
        public static bool DisplayOdbcConvert()
        {
            string convert = System.Configuration.ConfigurationManager.AppSettings["OdbcConvert"];
            if (convert != null && convert.ToUpper() == "YES")
                return true;
            return false;
        }


        /// <summary>
        /// Loads all reports from the database.
        /// </summary>
        /// <returns></returns>
        public static List<OReport> GetAllReports()
        {
            return TablesLogic.tReport.LoadAll(
                TablesLogic.tReport.CategoryName.Asc,
                TablesLogic.tReport.ReportName.Asc);
        }

        /// <summary>
        /// retrieve the static report setting such as Report dataset, query and parameter order if necessary
        /// </summary>
        /// <param name="reportTemplate"></param>
        /// <param name="b"></param>
        /// <param name="contents"></param>
        /// <param name="fileName"></param>
        /// <param name="templateName"></param>
        public static void GetStaticReportSettings(OReportTemplate reportTemplate, byte[] b, string contents, string fileName, string templateName)
        {
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(contents);
            
            reportTemplate.RdlBytes = b;
            reportTemplate.ObjectNumber = fileName;
            reportTemplate.ObjectName = templateName;
            reportTemplate.TemplateType = (int)TemplateTypeName.rdlreport;
            //retrieve dataset name.
            XmlNodeList datasetlist = xmlDoc.GetElementsByTagName("DataSet");
            if (datasetlist == null || datasetlist.Count == 0)
                throw new Exception("Cannot find data set from file. Please check your report document.");
            else
            {
                //clear existing report dataset
                reportTemplate.ReportDataSet.Clear();
                for (int i = 0; i < datasetlist.Count; i++)
                {
                    OReportDataSet rDS = TablesLogic.tReportDataSet.Create();
                    rDS.ReportID = reportTemplate.ObjectID;
                    rDS.DataSetName = datasetlist[i].Attributes["Name"].Value;
                    //retrieve the query of the dataset
                    XmlNodeList queryNode = datasetlist[i].ChildNodes;
                    for (int n = 0; n < queryNode.Count; n++)
                    {
                        if (queryNode[n].Name == "Query")
                        {
                            XmlNodeList queryChild = queryNode[n].ChildNodes;
                            for (int y = 0; y < queryChild.Count; y++)
                            {
                                if (queryChild[y].Name == "CommandText")
                                {
                                    rDS.Query = queryChild[y].InnerText;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    reportTemplate.ReportDataSet.Add(rDS);
                }
            }
        }

        /// <summary>
        /// update the data table name with the column's display name for drag and drop report
        /// </summary>
        /// <param name="dt"></param>
        public static void UpdateTableColumnName(DataSet ds)
        {
            //rachel. allow to specify the column name through extended properties, else using its column name
            foreach (DataTable dt in ds.Tables)
            {
                UpdateTableColumnName(dt);
            }
        }

        /// <summary>
        /// update the data table name with the column's display name for drag and drop report
        /// </summary>
        /// <param name="dt"></param>
        public static void UpdateTableColumnName(DataTable dt)
        {
            //rachel. allow to specify the column name through extended properties, else using its column name
            foreach (DataColumn col in dt.Columns)
            {
                try
                {
                    col.ColumnName = col.ExtendedProperties["DisplayColumnName"].ToString();
                }
                catch
                {
                }
            }
        }

        /// <summary>
        /// remove invisible column so that system will not show it in dynamic report
        /// </summary>
        /// <param name="dt"></param>
        public static void RemoveDataTableColumn(DataSet ds)
        {
            //rachel. allow to specify the column name through extended properties, else using its column name
            foreach (DataTable dt in ds.Tables)
            {
                RemoveDataTableColumn(dt);
            }
        }

        /// <summary>
        /// remove invisible column so that system will not show it in dynamic report
        /// 
        /// </summary>
        /// <param name="dt"></param>
        public static void RemoveDataTableColumn(DataTable dt)
        {
            //rachel. allow to specify the column name through extended properties, else using its column name
            for (int i = dt.Columns.Count - 1; i >= 0; i--)
            {
                DataColumn c = dt.Columns[i];
                try
                {
                    if (c.ExtendedProperties["Visibility"] != null && !Convert.ToBoolean(c.ExtendedProperties["Visibility"]))
                        dt.Columns.Remove(c);
                }
                catch
                {
                }
            }
        }


        /// <summary>
        /// Validates to ensure that no two fields have the same identifiers.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNoDuplicateIdentifiers(OReportField field)
        {
            foreach (OReportField reportField in this.ReportFields)
            {
                if (reportField.ObjectID != field.ObjectID &&
                    reportField.ControlIdentifier.ToLower() == field.ControlIdentifier.ToLower())
                {
                    return false;
                }
            }
            return true;
        }


        /// <summary>
        /// Returns a clone copy of this object.
        /// </summary>
        /// <returns></returns>
        public object Clone()
        {
            OReport report = TablesLogic.tReport.Create();

            report.ShallowCopy(this);

            foreach (OReportField o in this.ReportFields)
            {
                OReportField n = TablesLogic.tReportField.Create();
                n.ShallowCopy(o);
                report.ReportFields.Add(n);
            }

            foreach (OReportDataSet o in this.ReportDataSet)
            {
                OReportDataSet n = TablesLogic.tReportDataSet.Create();
                n.ShallowCopy(o);
                report.ReportDataSet.Add(n);
            }

            foreach (OReportTemplate o in this.ReportTemplate)
            {
                OReportTemplate n = TablesLogic.tReportTemplate.Create();
                n.ShallowCopy(o);
                report.ReportTemplate.Add(n);
            }

            foreach (OReportColumnMapping o in this.ReportColumnMappings)
            {
                OReportColumnMapping n = TablesLogic.tReportColumnMapping.Create();
                n.ShallowCopy(o);
                report.ReportColumnMappings.Add(n);
            }

            foreach (ORole o in this.Roles)
                report.Roles.Add(o);

            // Set up the cascaded controls
            //
            foreach (OReportField o in this.CascadeControl)
            {
                OReportField n = this.ReportFields.Find(p => p.DisplayOrder == o.DisplayOrder);
                if (n != null)
                    report.CascadeControl.Add(n);
            }
            for (int i = 0; i < this.ReportFields.Count; i++)
            {
                foreach (OReportField o in this.ReportFields[i].CascadeControl)
                {
                    OReportField n = this.ReportFields.Find(p => p.DisplayOrder == o.DisplayOrder);
                    if (n != null)
                        report.ReportFields[i].CascadeControl.Add(n);
                }
            }

            return report;
        }
    }

}
