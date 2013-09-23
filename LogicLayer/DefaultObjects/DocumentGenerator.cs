using System;
using System.Diagnostics;
using System.Configuration;
using System.IO;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

using System.Net;
using System.Web.Services;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;

using CrystalDecisions;
using CrystalDecisions.Shared;
using CrystalDecisions.CrystalReports;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.CrystalReports.Engine.Migration;
using Microsoft.Reporting;
using Microsoft.Reporting.WebForms;
using Anacle.DataFramework;



namespace LogicLayer
{
    public class DocumentGenerator
    {
        /// <summary>
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
        /// Generate a PDF from a HTML file.
        /// </summary>
        /// <param name="Url"></param>
        /// <returns></returns>
        public static string WKHtmlToPdf(string Url)
        {
            var p = new Process();

            // WKHTML2PDF is a .exe file, and there is no other way
            // to access it's API other than by running the .exe as a separate
            // process.
            //
            string switches = "";
            switches += "--print-media-type ";
            switches += "--margin-top 10mm --margin-bottom 10mm --margin-right 10mm --margin-left 10mm ";
            switches += "--page-size Letter ";
            switches += "--redirect-delay 100";

            string fileName = ConfigurationManager.AppSettings["ReportTempFolder"] + Guid.NewGuid().ToString() + ".pdf";

            var startInfo = new ProcessStartInfo
            {
                Arguments = switches + " " + Path.GetFileName(Url) + " \"" + fileName + "\"",
                UseShellExecute = false, // needs to be false in order to redirect output
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                RedirectStandardInput = true, // redirect all 3, as it should be all 3 or none
                WorkingDirectory = Path.GetDirectoryName(Url)
            };

            ServicePointManager.ServerCertificateValidationCallback = TrustAllCertificates;
            HttpContext c = HttpContext.Current;
            
            if (c != null)
                startInfo.FileName = 
                    c.Request.PhysicalApplicationPath + "wkhtmltopdf\\wkhtmltopdf.exe";
                    //c.Server.MapPath("~/wkhtmltopdf/wkhtmltopdf.exe");
            else
                startInfo.FileName = "wkhtmltopdf.exe";
            p.StartInfo = startInfo;
            p.Start();

            //  wait n milliseconds for exit (as after exit, it can't read the output)
            p.WaitForExit(60000);

            // read the exit code, close process
            int returnCode = p.ExitCode;
            p.Close();
            return fileName;
        }



        /// <summary>
        /// Generate a Word, Excel or PDF report from a Crystal Reports template.
        /// </summary>
        /// <param name="templateFileBytes"></param>
        /// <param name="ds"></param>
        /// <param name="outputFormat"></param>
        /// <returns></returns>
        public static byte[] GenerateFromCrystalReportTemplate(byte[] templateFileBytes, DataSet ds, int? outputFormat)
        {
            // Crystal Reports behave in a strange way. It can only load
            // the template from disk and output the final report to disk 
            // (but not to/from memory stream). So we need to set up
            // temporary file paths in the ReportTempFolder.
            // 
            string reportTempFolder = ConfigurationManager.AppSettings["ReportTempFolder"];
            string templatePath = reportTempFolder + Guid.NewGuid().ToString();
            string outputPath = reportTempFolder + Guid.NewGuid().ToString();

            // Write the crystal report template file out to disk.
            //
            FileStream fs = new FileStream(templatePath, FileMode.Create);
            try { fs.Write(templateFileBytes, 0, templateFileBytes.Length); }
            finally { fs.Close(); }

            // Create the new Crystal Report objects, load the template 
            // and set the data source.
            //
            ReportDocument doc = new ReportDocument();
            doc.Load(templatePath);
            doc.SetDataSource(ds);

            // 2011 04 29
            // Kien Trung
            // Open all the sub reports and set data source to them.
            foreach (ReportDocument sub in doc.Subreports)
                sub.SetDataSource(ds);

            // Then we export the output to a file.
            //
            ExportOptions exportOpts = doc.ExportOptions;
            if (outputFormat == DocumentOutputFormat.AcrobatPDF)
                exportOpts.ExportFormatType = ExportFormatType.PortableDocFormat;
            else if (outputFormat == DocumentOutputFormat.MicrosoftExcel)
                exportOpts.ExportFormatType = ExportFormatType.Excel;
            else if (outputFormat == DocumentOutputFormat.MicrosoftWord)
                exportOpts.ExportFormatType = ExportFormatType.WordForWindows;
            exportOpts.ExportDestinationType = ExportDestinationType.DiskFile;
            exportOpts.DestinationOptions = new DiskFileDestinationOptions();
            ((DiskFileDestinationOptions)doc.ExportOptions.DestinationOptions).DiskFileName = outputPath;
            doc.Export();

            // And we then read the file and return it to the caller.
            //
            FileStream fs2 = new FileStream(outputPath, FileMode.Open);
            byte[] output = new byte[fs2.Length];
            try { fs2.Read(output, 0, (int)fs2.Length); }
            finally { fs2.Close(); }
            return output;
        }


        /// <summary>
        /// Generates an Excel or PDF output given a RDL template and a DataSet.
        /// </summary>
        /// <param name="templateFileBytes"></param>
        /// <param name="ds"></param>
        /// <param name="outputFormat"></param>
        /// <returns></returns>
        public static byte[] GenerateFromRDLTemplate(byte[] templateFileBytes, DataSet ds, int? outputFormat)
        {
            // Load the report from the document template.
            //
            LocalReport localReport = new LocalReport();
            MemoryStream mem = new MemoryStream(templateFileBytes);
            StreamReader sr = new StreamReader(mem);
            localReport.LoadReportDefinition(sr);
            sr.Close();
            mem.Close();

            // Add the data tables to the report.
            //
            if (ds != null)
                foreach (DataTable dt in ds.Tables)
                {
                    ReportDataSource reportDataSource = new ReportDataSource(dt.TableName, dt);
                    localReport.DataSources.Add(reportDataSource);
                }

            // Generate the output.
            // 
            Warning[] warnings = null;
            string mimeType = null, encoding = null, fileNameExtension = null;
            string[] streams = null;
            string format = "";
            if (outputFormat == DocumentOutputFormat.AcrobatPDF)
                format = "PDF";
            if (outputFormat == DocumentOutputFormat.MicrosoftExcel)
                format = "Excel";
            if (outputFormat == DocumentOutputFormat.Image)
                format = "Image";

            return localReport.Render(format, "", out mimeType, out encoding, out fileNameExtension, out streams, out warnings);
        }



        /// <summary>
        /// Generate a document report from an MHT template.
        /// </summary>
        /// <param name="templateFileBytes"></param>
        /// <param name="persistentObject"></param>
        /// <param name="applicationSettingsObject"></param>
        /// <param name="outputFormat"></param>
        /// <returns></returns>
        public static byte[] GenerateFromMHTTemplate(byte[] templateFileBytes, object persistentObject, object applicationSettingsObject, int? outputFormat)
        {
            MemoryStream mem = new MemoryStream(templateFileBytes);
            StringBuilder build = new StringBuilder();

            //using (StreamReader sr = new StreamReader(mem, Encoding.GetEncoding("windows-1252")))
            //Temporary we use the system default encoding, to avoid conversion problem. If any problem with conversion, we need to find a way to find the encoding of the file
            using (StreamReader sr = new StreamReader(mem, Encoding.Default))
            {
                build.Append(sr.ReadToEnd());
                mem.Close();
            }

            string content = build.ToString();

            // In the MHT document, long lines are always broken up
            // by Microsoft Word using the = sign followed by 
            // a carriage return, so we have to unbreak those lines
            // so that tags that are broken up are not merged.
            //
            content = content.Replace("=\r\n", "").Replace("=\n", "").Replace("=\r", "");

            // Most MHT documents do not have the view layout set to
            // Print mode. If that is the case, insert an XML tag
            // to force the document to open in Print view.
            //
            if (!content.Contains("<w:View>Print</w:View>"))
                content = content.Replace("<w:WordDocument>", "<w:WordDocument><w:View>Print</w:View>");

            content = Regex.Replace(content, @"<span[\s\r\n]+class=SpellE>(?<text>[\s\S]*?)</span>", "${text}");

            Template t = new Template(content, true);
            //t.RemoveSpellingErrorTags();
            t.AddVariable("obj", persistentObject);
            t.AddVariable("applicationSettings", applicationSettingsObject);
            content = t.Generate();

            // Because we are outputing an MHT file, we
            // must encode all unicode characters.
            // So this is what we are going to do here:
            //
            StringBuilder sb = new StringBuilder();
            foreach (char c in content)
            {
                if ((int)c > 255)
                    sb.Append("&#" + ((int)c).ToString() + ";");
                else
                    sb.Append(c);
            }

            // Use to output a HTML page to PDF
            //                    
            if (outputFormat == DocumentOutputFormat.AcrobatPDF)
            {
                string guid = Guid.NewGuid().ToString();
                string pdfFilePath = "";

                if (MhtProcessor.IsMhtContent(content))
                {
                    // Hack the content to add a <div> for page break, because the HTML2PDF 
                    // is unable to recognize the CSS page breaks placed within the <br> tags (which is 
                    // what Microsoft Word does in the MHT files). It only recognizes it if it is in as
                    // <div> tag.
                    //
                    content = content.Replace("page-break-before:always'>\r\n</span>", "page-break-before:always'>\r\n</span><div style='page-break-before:always' />");

                    // Split up the MHT files into smaller files and save it into the temp folder.
                    // before passing it through the HTML2PDF program.
                    //
                    string outputPath = ConfigurationManager.AppSettings["ReportTempFolder"] + guid + "\\";
                    Directory.CreateDirectory(outputPath);
                    string filePath = MhtProcessor.SplitMhtContent(content, outputPath);
                    if (filePath != "")
                        pdfFilePath = WKHtmlToPdf(filePath);
                    //Directory.Delete(outputPath, true);
                }
                else
                {
                    // Just write out the HTML file as is, and pass it through the
                    // HTML2PDF program.
                    //
                    string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + guid + ".htm";
                    StreamWriter fileWriter = new StreamWriter(filePath, false, Encoding.UTF8);
                    content = content.Replace("=\r\n", "").Replace("=\n", "").Replace("=\r", "").Replace("=3D", "=");
                    try { fileWriter.Write(content); }
                    finally { fileWriter.Close(); }
                    pdfFilePath = WKHtmlToPdf(filePath);
                    File.Delete(filePath);
                }

                // We then read the file and return it to the caller.
                //
                FileStream fs2 = new FileStream(pdfFilePath, FileMode.Open);
                byte[] output = new byte[fs2.Length];
                try { fs2.Read(output, 0, (int)fs2.Length); }
                finally { fs2.Close(); }
                return output;
            }
            else
            {
                return Encoding.UTF8.GetBytes(sb.ToString());
            }
        }


        /// <summary>
        ///  Generates a document from a given document template object.
        /// </summary>
        /// <param name="documentTemplate"></param>
        /// <param name="persistentObject"></param>
        /// <returns></returns>
        public static byte[] GenerateDocument(ODocumentTemplate documentTemplate, object persistentObject)
        {
            if (documentTemplate == null)
                throw new Exception("Unable to generate letter because the document template passed in is empty.");

            if (documentTemplate.FileBytes == null || documentTemplate.FileBytes.Length == 0)
                throw new Exception("Unable to generate letter because the document template with the code '" + documentTemplate.ObjectTypeName + "' does not have a document template uploaded.");

            return GenerateDocument(documentTemplate.FileBytes, documentTemplate.TemplateType, documentTemplate.OutputFormat, persistentObject);
        }


        /// <summary>
        ///  Generates a document from a given document template ID.
        /// </summary>
        /// <param name="documentTemplateId"></param>
        /// <param name="persistentObject"></param>
        /// <returns></returns>
        public static byte[] GenerateDocument(Guid? documentTemplateId, object persistentObject)
        {
            ODocumentTemplate documentTemplate = TablesLogic.tDocumentTemplate[documentTemplateId];

            if (documentTemplate == null)
                throw new Exception("Unable to generate letter because the document template with the ID '" + documentTemplateId.ToString() + "' cannot be found.");

            if (documentTemplate.FileBytes == null || documentTemplate.FileBytes.Length == 0)
                throw new Exception("Unable to generate letter because the document template with the ID '" + documentTemplateId.ToString() + "' does not have a document template uploaded.");

            return GenerateDocument(documentTemplate.FileBytes, documentTemplate.TemplateType, documentTemplate.OutputFormat, persistentObject);
        }


        /// <summary>
        ///  Generates a document from a given document template code.
        /// </summary>
        /// <param name="documentTemplateCode"></param>
        /// <param name="persistentObject"></param>
        /// <returns></returns>
        //public static byte[] GenerateDocument(string documentTemplateCode, object persistentObject)
        //{
        //    ODocumentTemplate documentTemplate = TablesLogic.tDocumentTemplate.Load(
        //        (TablesLogic.tDocumentTemplate.GenerationMode == 0 |
        //        TablesLogic.tDocumentTemplate.GenerationMode == 2) &
        //        TablesLogic.tDocumentTemplate.DocumentTemplateCode == documentTemplateCode);

        //    if (documentTemplate == null)
        //        throw new Exception("Unable to generate letter because the document template with the code '" + documentTemplateCode + "' cannot be found.");

        //    if (documentTemplate.FileBytes == null || documentTemplate.FileBytes.Length == 0)
        //        throw new Exception("Unable to generate letter because the document template with the code '" + documentTemplateCode + "' does not have a document template uploaded.");

        //    return GenerateDocument(documentTemplate.FileBytes, documentTemplate.TemplateType, documentTemplate.OutputFormat, persistentObject);
        //}


        /// <summary>
        ///  Generates a document from a given document template.
        /// </summary>
        /// <param name="templateFileBytes"></param>
        /// <param name="templateType"></param>
        /// <param name="outputFormat"></param>
        /// <param name="persistentObject"></param>
        /// <returns></returns>
        public static byte[] GenerateDocument(byte[] templateFileBytes, int? templateType, int? outputFormat, object persistentObject)
        {
            if (templateType == DocumentTemplate.RDLTemplate)
            {
                DataSet ds = ((LogicLayerPersistentObject)persistentObject).DocumentTemplateDataSet;
                if (ds == null)
                    throw new Exception("The system is unable to generate the printout from the RDL template as the DocumentTemplateDataSet for the object returns null. Your PersistentObject must implement the DocumentTemplateDataSet in order for the printout to work.");
                return GenerateFromRDLTemplate(templateFileBytes, ds, outputFormat);
            }
            else if (templateType == DocumentTemplate.CrystalTemplate)
            {
                DataSet ds = ((LogicLayerPersistentObject)persistentObject).DocumentTemplateDataSet;
                if (ds == null)
                    throw new Exception("The system is unable to generate the printout from the RPT template as the DocumentTemplateDataSet for the object returns null. Your PersistentObject must implement the DocumentTemplateDataSet in order for the printout to work.");

                return GenerateFromCrystalReportTemplate(templateFileBytes, ds, outputFormat);
            }
            else if (templateType == DocumentTemplate.MHTTemplate)
            {
                return GenerateFromMHTTemplate(templateFileBytes, persistentObject, OApplicationSetting.Current, outputFormat);
            }

            return null;
        }


        /// <summary>
        /// Merges multiple PDFs into one single PDF using PDFSharp library.
        /// </summary>
        /// <param name="outputFileName"></param>
        /// <param name="inputFileNames"></param>
        public static void MergePdfDocuments(string outputFileName, params string[] inputFileNames)
        {
            PdfDocument outputDocument = new PdfDocument();
            
            foreach (string file in inputFileNames)
            {
                PdfDocument inputDocument = PdfReader.Open(file, PdfDocumentOpenMode.Import);
                int count = inputDocument.PageCount;
                for (int idx = 0; idx < count; idx++)
                {
                    PdfPage page = inputDocument.Pages[idx];
                    outputDocument.AddPage(page);
                }
            }

            outputDocument.Save(outputFileName);
        }
    }
}
