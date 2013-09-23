using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.OleDb;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using System.Text;

namespace ExcelReaderWebService
{
    /// <summary>
    /// This class contains web service to load excel reader from the disk
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class ExcelReaderWebService : System.Web.Services.WebService
    {
        /// <summary>
        /// Loads an Excel file from disk and returns the first sheet as a DataTable.
        /// </summary>
        /// <param name="excelFileName"></param>
        /// <returns></returns>
        [WebMethod]
        public DataTable ExcelToDataTable(string excelFileName)
        {
            System.Configuration.AppSettingsReader app = new System.Configuration.AppSettingsReader();
            String provider = (String)app.GetValue("Provider", typeof(String));
            String extProperties = (String)app.GetValue("Extended Properties", typeof(String));
            
            string connString = "Provider=" + provider + ";Data Source=" + excelFileName + ";Extended Properties='" + extProperties + "'";

            DataTable dtExceldata = new DataTable();

            try
            {
                OleDbCommand excelCommand = new OleDbCommand();
                OleDbDataAdapter excelDataAdapter = new OleDbDataAdapter();

                using (OleDbConnection excelConn = new OleDbConnection(connString))
                {
                    excelConn.Open();

                    String sheetName = "";

                    DataTable dtExcelSheets = new DataTable();
                    dtExcelSheets = excelConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                    if (dtExcelSheets.Rows.Count > 0)
                    {
                        sheetName = dtExcelSheets.Rows[0]["TABLE_NAME"].ToString();
                    }
                    OleDbCommand OleCmdSelect = new OleDbCommand("SELECT * FROM [" + sheetName + "]", excelConn);
                    OleDbDataAdapter OleAdapter = new OleDbDataAdapter(OleCmdSelect);

                    OleAdapter.FillSchema(dtExceldata, System.Data.SchemaType.Source);
                    OleAdapter.Fill(dtExceldata);
                    excelConn.Close();
                }

                return dtExceldata;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
    }
}
