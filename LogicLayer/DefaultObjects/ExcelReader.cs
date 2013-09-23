using System;
using System.Data;
using System.IO;
using System.Data.OleDb;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Security;
using System.Net;
using System.Security.Cryptography.X509Certificates;



namespace LogicLayer
{
    /// <summary>
    /// This class contains methods to load an Excel file from the disk.
    /// </summary>
    public class ExcelReader
    {
        /// Method to trust all certificates
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="certificate"></param>
        /// <param name="chain"></param>
        /// <param name="errors"></param>
        /// <returns></returns>
        private static bool TrustAllCertificates(Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
        {
            // trust any certificate
            return true;
        }

        /// <summary>
        /// Loads an Excel file from disk and returns the first sheet as a DataTable.
        /// </summary>
        /// <param name="excelFileName"></param>
        /// <returns></returns>
        public DataTable LoadExcelFile(string excelFileName)
        {
            DataTable dtExceldata = new DataTable();

            System.Configuration.AppSettingsReader app = new System.Configuration.AppSettingsReader();
            String provider = (String)app.GetValue("Provider",typeof(String));
            String extProperties = (String)app.GetValue("Extended Properties", typeof(String));

            int enable32ws = (int)OApplicationSetting.Current.ExcelReaderUseWebService;

            string connString = "Provider=" + provider + ";Data Source=" + excelFileName + ";Extended Properties='" + extProperties + "'";
            
            //Check if the server is in 64 bit mode and the app requires 32-bit web service
                if ((enable32ws==1) && (getBitEnv()==64))
                {
                    try
                    {
                        OApplicationSetting appSetting = OApplicationSetting.Current;

                        ServicePointManager.CertificatePolicy = new TrustAllCertificatePolicy();

                        LogicLayer.ExcelWebServices.ExcelReaderWebService websrv = new LogicLayer.ExcelWebServices.ExcelReaderWebService();

                        websrv.Credentials = CredentialCache.DefaultCredentials;
                        websrv.Url = OApplicationSetting.Current.ExcelReaderWebServiceURL;

                        dtExceldata = websrv.ExcelToDataTable(excelFileName);
                    }
                    catch
                    {
                        dtExceldata=null;
                    }
                }
                else
                {
                    OleDbCommand excelCommand = new OleDbCommand();
                    OleDbDataAdapter excelDataAdapter = new OleDbDataAdapter();

                    try
                    {
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
                    }
                    catch
                    {
                        dtExceldata = null;
                    }
                }
                
            return dtExceldata;
        }

        private int getBitEnv()
        {
            //get the server environmet (32/64) by checking the integer size
            return IntPtr.Size * 8;
        }
    }

    public class TrustAllCertificatePolicy : System.Net.ICertificatePolicy
    {
        public TrustAllCertificatePolicy() { }
        public bool CheckValidationResult(ServicePoint sp,
            X509Certificate cert,
            WebRequest req,
            int problem)
        {
            return true;
        }
    }

}
