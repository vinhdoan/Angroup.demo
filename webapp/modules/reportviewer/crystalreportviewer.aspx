<%@ Page Language="C#" %>

<%@ Register Assembly="CrystalDecisions.Web, Version=10.5.3700.0, Culture=neutral, PublicKeyToken=692fbea5521e1304"
    Namespace="CrystalDecisions.Web" TagPrefix="CR" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Collections.Generic"%>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="CrystalDecisions.CrystalReports.Engine" %>
<%@ Import Namespace="CrystalDecisions.Shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        if (this.labelMessage.Text != "")
        {
            this.labelMessage.Visible = true;
            this.crystalReportViewer.Visible = false;
        }
        else
        {
            this.labelMessage.Visible = false;
            this.crystalReportViewer.Visible = true;
        }
    }
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        ReportDocument doc = null;
        // for showing crystal report in Report builder
        if (Session["ReportID"] != null && Session["ReportParameter"] != null)
        {
            try
            {               
                Guid rId = new Guid(Session["ReportID"].ToString());
                OReport report = TablesLogic.tReport.LoadObject(rId) as OReport;
                OReportTemplate template = null;
                doc = new ReportDocument();
                global::Parameter[] reportFields = (global::Parameter[])Session["ReportParameter"];

                String fileName = "";
                
                String CrystalReportPath = System.Configuration.ConfigurationManager.AppSettings["ReportTempFolder"];
                DataTable dt = null;
                
                //load report using reporttemplate
                if (Session["ReportTemplateID"] != null)
                {
                    Guid templateID = new Guid(Session["ReportTemplateID"].ToString());
                    template = TablesLogic.tReportTemplate.LoadObject(templateID) as OReportTemplate;

                    fileName = template.ObjectNumber;
                }
                else //load report
                {
                    fileName = report.ReportFileName;
                }
                byte[] fileBytes = template == null ? report.ReportFileBytes : template.RdlBytes;
                if (File.Exists(CrystalReportPath + fileName))
                    File.Delete(CrystalReportPath + fileName);

                File.WriteAllBytes(CrystalReportPath + fileName, fileBytes);
                if (report.UseCSharpQuery == 1)
                {
                    object dataSource = Analysis.InvokeMethod(report.CSharpMethodName, reportFields);
                    dt = (DataTable)dataSource;
                }
                else 
                {
                    dt = Analysis.DoQuery(report.ReportQuery, reportFields);                    
                }
                doc.Load(CrystalReportPath + fileName);
                doc.SetDataSource(dt);

                this.crystalReportViewer.ReportSource = doc;
                Session["ReportID"] = null;
                Session["ReportParameter"] = null;
            }
            catch (Exception ex)
            {
                //throw ex;        
                if (ex.InnerException != null)
                    this.labelMessage.Text = ex.InnerException.Message;
                else
                    this.labelMessage.Text = ex.Message;
            }
        }
        else
        {
            if (DiskCache.ContainsKey("CrystalReportTable") && Request["CrystalReportPath"] != null)
                //Session["CrystalReportPath"] != null && Session["CrystalReportPath"].ToString()!="")
            {
                // 2011 04 29
                // Kien Trung
                // Modified to take in Data Set instead of data table.
                //
                DataSet dt = DiskCache.GetDataSet("CrystalReportTable");

                // 2011 04 29
                // Kien Trung
                // Modified to take in Request instead of session.
                //string CrystalReportPath = Session["CrystalReportPath"].ToString();
                string CrystalReportPath = Security.Decrypt(Request["CrystalReportPath"].ToString());
                doc = new ReportDocument();
                
                // 2011 04 29
                // Kien Trung
                // Check if the report path is virtual path or physical path
                if (Request["IsReportVirtualPath"] == "0")
                    doc.Load(CrystalReportPath);
                else
                    doc.Load(Server.MapPath(CrystalReportPath));
                doc.SetDataSource(dt);
                
                // 2011 04 29
                // Kien Trung
                // Open all the sub reports and set data source to them.
                foreach (ReportDocument sub in doc.Subreports)
                    sub.SetDataSource(dt);
                
                this.crystalReportViewer.ReportSource = doc;

                
                if (Request["PDF"] == "1")
                {
                    ExportToPDF(doc);
                }
                if (Request["DOC"] == "1")
                {
                    ExportToWord(doc);
                }
                if (Request["XLS"] == "1")
                {
                    ExportToExcel(doc);
                }
                DiskCache.Remove("CrystalReportTable");
                //Session["CrystalReportPath"] = null;
            }
        }
    }

    protected void ExportToExcel(ReportDocument doc)
    {
        string tempFileName = System.IO.Path.GetTempFileName();
        string fileName = "report.xls";
        if (Request["N"] != null)
            fileName = Request["N"].ToString() + ".xls";

        ExportOptions exportOpts = doc.ExportOptions;
        exportOpts.ExportFormatType = ExportFormatType.Excel;
        exportOpts.ExportDestinationType = ExportDestinationType.DiskFile;
        exportOpts.DestinationOptions = new DiskFileDestinationOptions();
        DiskFileDestinationOptions diskOpts = new DiskFileDestinationOptions();
        ((DiskFileDestinationOptions)doc.ExportOptions.DestinationOptions).DiskFileName = tempFileName;
        doc.Export();

        Response.ClearHeaders();
        Response.ClearContent();
        Response.Cache.SetCacheability(HttpCacheability.Public);
        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader("content-disposition", "attachment; filename=" + fileName);
        Response.AddHeader("pragma", "public");
        Response.WriteFile(tempFileName);
        Response.End();
    }

    protected void ExportToWord(ReportDocument doc)
    {
        string tempFileName = System.IO.Path.GetTempFileName();
        string fileName = "report.doc";
        if (Request["N"] != null)
            fileName = Request["N"].ToString() + ".doc";

        ExportOptions exportOpts = doc.ExportOptions;
        exportOpts.ExportFormatType = ExportFormatType.WordForWindows;
        exportOpts.ExportDestinationType = ExportDestinationType.DiskFile;
        exportOpts.DestinationOptions = new DiskFileDestinationOptions();
        DiskFileDestinationOptions diskOpts = new DiskFileDestinationOptions();
        ((DiskFileDestinationOptions)doc.ExportOptions.DestinationOptions).DiskFileName = tempFileName;
        doc.Export();

        Response.ClearHeaders();
        Response.ClearContent();
        Response.Cache.SetCacheability(HttpCacheability.Public);
        Response.ContentType = "application/vnd.ms-word";
        Response.AddHeader("content-disposition", "attachment; filename=" + fileName);
        Response.AddHeader("pragma", "public");
        Response.WriteFile(tempFileName);
        Response.End();
    }

    protected void ExportToPDF(ReportDocument doc)
    {
        string tempFileName = System.IO.Path.GetTempFileName();
        string fileName = "report.pdf";
        if (Request["N"] != null)
            fileName = Request["N"].ToString() + ".pdf";

        ExportOptions exportOpts = doc.ExportOptions;
        exportOpts.ExportFormatType = ExportFormatType.PortableDocFormat;
        exportOpts.ExportDestinationType = ExportDestinationType.DiskFile;
        exportOpts.DestinationOptions = new DiskFileDestinationOptions();
        DiskFileDestinationOptions diskOpts = new DiskFileDestinationOptions();
        ((DiskFileDestinationOptions)doc.ExportOptions.DestinationOptions).DiskFileName = tempFileName;
        doc.Export();

        Response.ClearHeaders();
        Response.ClearContent();
        Response.Cache.SetCacheability(HttpCacheability.Public);
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + fileName);
        Response.AddHeader("pragma", "public");
        Response.WriteFile(tempFileName);
        Response.End();
    }

    
  
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Untitled Page</title>
</head>
<body style="margin:0px">
    <form id="form1" runat="server">   
    
    <asp:Label runat="server" ID="labelMessage" Font-Bold="true" ForeColor="red" EnableViewState="false" Visible="false"></asp:Label>
    <div>
        <CR:CrystalReportViewer ID="crystalReportViewer" runat="server" AutoDataBind="true" />
    </div>
    <div>
        
    </div>
    </form>
</body>
</html>

