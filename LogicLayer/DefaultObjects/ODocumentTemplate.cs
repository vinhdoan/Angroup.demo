//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Xml;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("DocumentTemplate")]
    [Serializable]
    public partial class TDocumentTemplate : LogicLayerSchema<ODocumentTemplate>
    {
        [Size(255)]
        public SchemaString ObjectTypeName;
        [Size(255)]
        public SchemaString FileName;
        [Size(255)]
        public SchemaString FileDescription;
        [Size(50)]
        public SchemaString ContentType;
        public SchemaImage FileBytes;
        public SchemaInt FileSize;
        [Size(500)]
        public SchemaString ApplicableStates;
        public SchemaInt OutputFormat;
        [Size(500)]
        public SchemaString FLEECondition;

        public SchemaInt TemplateType;
        public SchemaString DocumentTemplateCode;
    }

    /// <summary>
    /// Represents a document template.
    /// </summary>
    [Serializable]
    public abstract partial class ODocumentTemplate : LogicLayerPersistentObject
    {
        public abstract int? TemplateType { get; set; }

        /// <summary>
        /// [Columm] Gets or sets the object type name.
        /// </summary>
        public abstract string ObjectTypeName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the file name.
        /// </summary>
        public abstract String FileName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the file description.
        /// </summary>
        public abstract String FileDescription { get; set; }

        /// <summary>
        /// [Column] Gets or sets the content type of the file.
        /// </summary>
        public abstract String ContentType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the file bytes.
        /// </summary>
        public abstract Byte[] FileBytes { get; set; }

        /// <summary>
        /// [Column] Gets or sets the size of the file.
        /// </summary>
        public abstract int? FileSize { get; set; }

        /// <summary>
        /// [Column] Gets or sets a comma-separated list of state names
        /// of the object (as defined in the object's workflow file)
        /// that are applicable to this document. '*' indicates
        /// that this document applies to every state of the object,
        /// or if the object is not involved in any workflow.
        /// </summary>
        public abstract string ApplicableStates { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Fast Lightweight Expression Evaluator
        /// condition that returns a flag indicating whether this document
        /// template is applicable to the object.
        /// </summary>
        public abstract string FLEECondition { get; set; }

        /// <summary>
        /// [Columm] Gets or sets a flag indicating whether the
        /// generated document is editable or not.
        /// </summary>
        public abstract int? OutputFormat { get; set; }

        public abstract string DocumentTemplateCode { get; set; }

        public string TemplateTypeText
        {
            get
            {
                if (this.TemplateType == DocumentTemplate.RDLTemplate)
                    return "RDL Template";
                else if (this.TemplateType == DocumentTemplate.CrystalTemplate)
                    return "RPT Template";
                else
                    return "MHT Template";
            }
        }

        /// <summary>
        /// Gets the output format in a translated text.
        /// </summary>
        public string OutputFormatText
        {
            get
            {
                if (this.OutputFormat == DocumentOutputFormat.MicrosoftWord)
                    return Resources.Strings.Document_Word;
                else if (this.OutputFormat == DocumentOutputFormat.MicrosoftExcel)
                    return Resources.Strings.Document_Excel;
                else if (this.OutputFormat == DocumentOutputFormat.Static)
                    return Resources.Strings.Document_Static;
                else if (this.OutputFormat == DocumentOutputFormat.AcrobatPDF)
                    return Resources.Strings.Document_Acrobat;
                else if (this.OutputFormat == DocumentOutputFormat.Image)
                    return Resources.Strings.Document_Image;
                return "";
            }
        }

        /// <summary>
        /// Gets the output content MIME type.
        /// </summary>
        public string OutputFileExtension
        {
            get
            {
                if (this.OutputFormat == DocumentOutputFormat.MicrosoftWord)
                    return "doc";
                else if (this.OutputFormat == DocumentOutputFormat.MicrosoftExcel)
                    return "xls";
                else if (this.OutputFormat == DocumentOutputFormat.Static)
                    return "mht";
                else if (this.OutputFormat == DocumentOutputFormat.AcrobatPDF)
                    return "pdf";
                else if (this.OutputFormat == DocumentOutputFormat.Image)
                    return "jpg";
                return "";
            }
        }

        /// <summary>
        /// Gets the output content MIME type.
        /// </summary>
        public string OutputContentMIMEType
        {
            get
            {
                if (this.OutputFormat == DocumentOutputFormat.MicrosoftWord)
                    return "application/vnd.ms-word";
                else if (this.OutputFormat == DocumentOutputFormat.MicrosoftExcel)
                    return "application/vnd.ms-excel";
                else if (this.OutputFormat == DocumentOutputFormat.Static)
                    return "message/rfc822";
                else if (this.OutputFormat == DocumentOutputFormat.AcrobatPDF)
                    return "application/pdf";
                else if (this.OutputFormat == DocumentOutputFormat.Image)
                    return "image/jpg";
                return "";
            }
        }

        public static DataTable GetOutputFormatTable()
        {
            DataTable result = new DataTable();
            result.Columns.Add("Value", typeof(int));
            result.Columns.Add("Text", typeof(string));

            result.Rows.Add(DocumentOutputFormat.MicrosoftWord, Resources.Strings.Document_Word);
            result.Rows.Add(DocumentOutputFormat.MicrosoftExcel, Resources.Strings.Document_Excel);
            result.Rows.Add(DocumentOutputFormat.Static, Resources.Strings.Document_Static);
            result.Rows.Add(DocumentOutputFormat.AcrobatPDF, Resources.Strings.Document_Acrobat);
            result.Rows.Add(DocumentOutputFormat.Image, Resources.Strings.Document_Image);

            return result;
        }

        /// <summary>
        /// Get All Document Template
        /// </summary>
        /// <returns></returns>
        public static List<ODocumentTemplate> GetAllDocumentTemplate()
        {
            return TablesLogic.tDocumentTemplate[Query.True];
        }

        /// <summary>
        /// Gets a list of document templates for the specified object type.
        /// </summary>
        /// <param name="objectTypeName"></param>
        /// <param name="persistentObject"></param>
        /// <param name="currentObjectState"></param>
        /// <returns></returns>
        public static List<ODocumentTemplate> GetDocumentTemplates(string objectTypeName, PersistentObject persistentObject, string currentObjectState)
        {
            // The developer can customize this to filter based on
            // fields in the persistent object.
            //
            List<ODocumentTemplate> documentTemplates = TablesLogic.tDocumentTemplate.LoadList(
                TablesLogic.tDocumentTemplate.ObjectTypeName == objectTypeName,
                TablesLogic.tDocumentTemplate.FileDescription.Asc);

            // 2010.04.27
            // Add the expression evaluator.
            //
            ExpressionEvaluator e = new ExpressionEvaluator();
            e["obj"] = persistentObject;

            // Remove those document templates that do not
            // apply to the current object state.
            //
            for (int i = documentTemplates.Count - 1; i >= 0; i--)
            {
                string[] applicableStates = documentTemplates[i].ApplicableStates.Split(',');
                string fleeCondition = documentTemplates[i].FLEECondition;

                bool isApplicable = false;

                // 2010.04.27
                // Evaluates
                //
                if (fleeCondition == null ||
                    fleeCondition.Trim() == "" ||
                    e.CompileAndEvaluate<bool>(fleeCondition) == true)
                    isApplicable = true;

                bool stateMatch = false;
                foreach (string applicableState in applicableStates)
                    if (applicableState == "*" || applicableState.Trim() == currentObjectState)
                    {
                        stateMatch = true;
                        break;
                    }
                if (!isApplicable || !stateMatch)
                    documentTemplates.RemoveAt(i);
            }

            return documentTemplates;
        }

        /// <summary>
        /// Retrieves property's name, description and type.
        /// </summary>
        /// <param name="node"></param>
        /// <param name="objectType"></param>
        /// <param name="parentObjectType"></param>
        /// <param name="parentPropertyName"></param>
        /// <param name="table1"></param>
        /// <param name="table2"></param>
        public static void GetPropertyByObjectType(XmlNode node, string objectType, string parentObjectType, string parentPropertyName, DataTable table1, DataTable table2)
        {
            // variables explanation
            // For example: objectType = "OPurchaseOrderReceipt"
            // propertyFullName = "LogicLayer.OPurchaseOrderReceipt.PurchaseOrderID"
            // propertyName = "PurchaseOrderID"
            // objTypeFullName = "LogicLayer.OPurchaseOrderReceipt"
            // objType = "OPurchaseOrderReceipt"
            // joinObjectName = "purchaseorderreceipt"
            // propertyJoinName = "{purchaserderreceipt.PurchaseOrderID}"
            //
            string parentName = "";
            string temp = parentPropertyName;
            if (parentPropertyName != null && parentPropertyName.Contains("|"))
            {
                parentName = parentPropertyName.Split('|')[0];
                parentPropertyName = parentPropertyName.Split('|')[1];
            }
            string[] str1 = node.OuterXml.Split(':');
            string propertyFullName = str1[1].Split('"')[0];
            string[] str2 = str1[1].Split('.');
            string propertyName = ((str2.Length - 1) > 2 ? str2[2] : str2[1]).Split('"')[0];
            string objType = propertyFullName.Split('.')[1];
            string objTypeFullName = propertyFullName.Split('.')[0] + "." + propertyFullName.Split('.')[1];
            string joinObjectName = (parentPropertyName != null && (parentPropertyName.Contains("Children") || parentPropertyName.Contains("Parent"))) ?
                parentPropertyName.Replace("obj.", "").ToLower() :
                objType.Replace("O", "").ToLower();

            if (propertyFullName.Contains(objTypeFullName) && objType == objectType)
            {
                string propertyType = GetPropertyType(objTypeFullName + ",LogicLayer", propertyName);
                if (objectType == parentObjectType && parentPropertyName == null)
                    propertyFullName = propertyFullName.Replace(objTypeFullName, "obj");
                else
                    propertyFullName = propertyFullName.Replace(objTypeFullName, "obj." + objectType.Replace("O", ""));

                if (parentName != "")
                    propertyFullName = parentName.Replace("{", "").Replace("}", "") + "." + propertyName;

                string propertyJoinName =
                    "{" +
                    ((parentPropertyName == null || parentName != "") ? propertyFullName :
                    (parentPropertyName.Contains("|") ? parentName + "." : joinObjectName + "." + propertyName))
                    + "}";

                string[] str3 = node.InnerText.Split('\n');
                string str = "";
                for (int i = 0; i < str3.Length; i++)
                    str += str3[i].Trim('\r').Trim() + " ";

                //generate tag list for single-valued properties
                if (!propertyType.StartsWith("IEnumerable:"))
                {
                    DataRow dr = table1.NewRow();
                    dr["TagName"] = propertyJoinName;
                    dr["Description"] = str.Trim();
                    dr["Type"] = propertyType.Contains("LogicLayer") ? propertyType.Split('.')[propertyType.Split('.').Length - 1] : propertyType;
                    table1.Rows.Add(dr);
                }
                else
                {
                    DataRow dr = table2.NewRow();
                    dr["TagName"] = propertyJoinName;
                    dr["Description"] = str.Trim();
                    dr["Type"] = propertyType;
                    table2.Rows.Add(dr);
                }
            }
        }

        /// <summary>
        /// Loads common properties of DataFramework and LogicLayer persistent objects.
        /// </summary>
        /// <param name="node"></param>
        /// <param name="objectType"></param>
        /// <param name="table"></param>
        /// <param name="isLogicLayerObject"></param>
        public static void LoadCommonProperty(XmlNode node, string objectType, DataTable table, bool isLogicLayerObject)
        {
            string[] str1 = node.OuterXml.Split(':');
            string propertyFullName = str1[1].Split('"')[0];
            string[] str2 = propertyFullName.Split('.');
            string propertyName = str2[str2.Length - 1];

            string objType = "";
            string objTypeFullName = "";
            if (isLogicLayerObject)
            {
                objType = str2[1];
                objTypeFullName = str2[0] + "." + str2[1];
            }
            else
            {
                objType = str2[2];
                objTypeFullName = str2[0] + "." + str2[1] + "." + str2[2];
            }

            string propertyType = "";
            if (propertyFullName.Contains(objTypeFullName) && objType == objectType)
            {
                if (isLogicLayerObject)
                    propertyType = ODocumentTemplate.GetPropertyType(objTypeFullName + ",LogicLayer", propertyName);
                else
                    propertyType = ODocumentTemplate.GetPropertyType(objTypeFullName + ",Anacle.DataFramework", propertyName);
                propertyFullName = propertyFullName.Replace(objTypeFullName, "obj");
                propertyName = "{" + propertyFullName + "}";
                string[] str3 = node.InnerText.Split('\n');
                string str = "";
                for (int i = 0; i < str3.Length; i++)
                    str += str3[i].Trim('\r').Trim() + " ";

                DataRow dr = table.NewRow();
                dr["TagName"] = propertyName;
                dr["Description"] = str.Trim();
                dr["Type"] = (propertyType.Contains("LogicLayer") || propertyType.Contains("DataFramework")) ? propertyType.Split('.')[propertyType.Split('.').Length - 1] : propertyType;
                table.Rows.Add(dr);
            }
        }

        /// <summary>
        /// Gets data type for specified property.
        /// </summary>
        /// <param name="typeName"></param>
        /// <param name="propertyName"></param>
        /// <returns></returns>
        public static string GetPropertyType(string typeName, string propertyName)
        {
            string propertyType = "";
            Type objectType = Type.GetType(typeName);

            System.Reflection.PropertyInfo propertyInfo =
                objectType.GetProperty(propertyName,
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Static |
                System.Reflection.BindingFlags.Instance);

            if (propertyInfo != null)
            {
                if (propertyInfo.PropertyType != typeof(string) &&
                    propertyInfo.PropertyType.GetInterface("IEnumerable") != null)
                {
                    // Yes, the property implements IEnumerable.
                    //
                    Type[] genericTypes = propertyInfo.PropertyType.GetGenericArguments();

                    if (genericTypes.Length == 1)
                        propertyType = "IEnumerable:" + genericTypes[0];
                    else
                        //propertyType = "String";
                        propertyType = "IEnumerable";
                }
                else
                {
                    // No, the property does NOT implement IEnumerable.
                    //
                    if (propertyInfo.PropertyType == typeof(Guid?))
                        propertyType = "Guid?";
                    else if (propertyInfo.PropertyType == typeof(decimal?))
                        propertyType = "decimal?";
                    else if (propertyInfo.PropertyType == typeof(Decimal))
                        propertyType = "Decimal";
                    else if (propertyInfo.PropertyType == typeof(double?))
                        propertyType = "double?";
                    else if (propertyInfo.PropertyType == typeof(int?))
                        propertyType = "int?";
                    else if (propertyInfo.PropertyType == typeof(DateTime?))
                        propertyType = "DateTime?";
                    else if (propertyInfo.PropertyType == typeof(byte[]))
                        propertyType = "byte[]";
                    else if (propertyInfo.PropertyType == typeof(string))
                        propertyType = "string";
                    else if (propertyInfo.PropertyType == typeof(Boolean))
                        propertyType = "Boolean";
                    else
                        propertyType = propertyInfo.PropertyType.FullName;
                }
            }
            else
            {
                //throw new Exception();
            }
            return propertyType;
        }

        public static List<ODocumentTemplate> GetDocumentTemplatesByCode(string code)
        {
            return TablesLogic.tDocumentTemplate.LoadList(TablesLogic.tDocumentTemplate.DocumentTemplateCode == code);
        }
    }

    /// <summary>
    /// Enumerates the various output formats supported by the document
    /// template.
    /// </summary>
    public class DocumentOutputFormat
    {
        public const int MicrosoftWord = 0;
        public const int MicrosoftExcel = 1;
        public const int Static = 2;
        public const int AcrobatPDF = 3;
        public const int Image = 4;
    }

    public class DocumentTemplate
    {
        public const int MHTTemplate = 0;
        public const int RDLTemplate = 1;
        public const int CrystalTemplate = 2;
    }
}