
<%@ Page Language="C#" %>

<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        if (this.labelMessage.Text != "")
        {
            this.labelMessage.Visible = true;
            this.reportViewer.Visible = false;
        }
        else
        {
            this.labelMessage.Visible = false;
            this.reportViewer.Visible = true;
        }
    }

    protected string TranslateReportItem(string text)
    {
        string translatedText = Resources.Reports.ResourceManager.GetString(text);
        if (translatedText == null || translatedText == "")
            return text;
        return translatedText;
    }
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {

            if (Session["ReportID"] != null && Session["ReportParameter"] != null)
            {
                try
                {
                    Guid rId = new Guid(Session["ReportID"].ToString());
                    OReport report = TablesLogic.tReport.LoadObject(rId) as OReport;
                    OReportTemplate template = null;

                    // Set the processing mode for the ReportViewer to Local
                    reportViewer.LocalReport.DisplayName = TranslateReportItem(report.ReportName);

                    reportViewer.ProcessingMode = ProcessingMode.Local;
                    LocalReport localReport = reportViewer.LocalReport;

                    System.IO.MemoryStream stream = new System.IO.MemoryStream();
                    if (Session["ReportTemplateID"] != null)
                    {
                        template = TablesLogic.tReportTemplate.Load(new Guid(Session["ReportTemplateID"].ToString()));
                        stream = new System.IO.MemoryStream(template.RdlBytes);
                    }
                    else
                        stream = new System.IO.MemoryStream(report.ReportFileBytes);
                    localReport.LoadReportDefinition(stream);

                    //set report parameter value
                    ReportParameterInfoCollection reportParamInfo = localReport.GetParameters();
                    ReportParameter[] reportParam = new ReportParameter[reportParamInfo.Count];
                    global::Parameter[] reportFields = (global::Parameter[])Session["ReportParameter"];
                    int i = 0;
                    bool hasError = false;
                    string errorMsg = "Following errors encounter when trying to process the report: \n";
                    foreach (ReportParameterInfo paramInfo in reportParamInfo)
                    {
                        //if it is REPORT_CAPTION param, we pass in the display report name
                        if (paramInfo.Name == "REPORT_CAPTION" && Session["ReportCaption"] != null)
                        {
                            reportParam[i] = new ReportParameter(paramInfo.Name, Session["ReportCaption"].ToString(), false);
                        }
                        else if (paramInfo.Name == "GENERATED_BY")
                        {
                            reportParam[i] = new ReportParameter(paramInfo.Name, AppSession.User.ObjectName, false);
                        }
                        //for other filter display
                        else if (paramInfo.Name == "REPORT_FILTER_DISPLAY" && Session["ReportParametersDisplay"] != null)
                        {
                            ArrayList paramValueList = Session["ReportParametersDisplay"] as ArrayList;
                            StringBuilder b = new StringBuilder();
                            //to force it to show line by line, we separate them by <br>
                            foreach (object v in paramValueList)
                            {
                                b.AppendLine(v.ToString());
                            }
                            reportParam[i] = new ReportParameter(paramInfo.Name, b.ToString(), false);
                        }
                        else
                        {
                            //Pass all other filter value through the one parameter
                            StringBuilder filterValue = new StringBuilder();
                            foreach (global::Parameter field in reportFields)
                            {
                                if (field.ParameterName == paramInfo.Name)
                                {
                                    //if paramInfo allow null value, do not check
                                    if (!paramInfo.Nullable)
                                    {

                                        //if value is null and the report parameter does not allow null, throw exception        
                                        if (field.Value == DBNull.Value || field.Value == null)
                                        {
                                            hasError = true;
                                            errorMsg += "Value for field " + paramInfo.Name + " cannot be null. \n";
                                        }
                                        //if the value is null, do not pass in value, 
                                        else if (field.Value.ToString() == "" && !paramInfo.AllowBlank)
                                        {
                                            hasError = true;
                                            errorMsg += "Value for field " + paramInfo.Name + " cannot be blank. \n";
                                        }
                                    }
                                    if (field.IsSingleValue)
                                    {
                                        if (field.Value != DBNull.Value && field.Value != null)
                                            reportParam[i] = new ReportParameter(paramInfo.Name, field.Value.ToString(), false);
                                        else
                                        {
                                            reportParam[i] = new ReportParameter(paramInfo.Name);
                                        }
                                    }
                                    else
                                    {
                                        if (field.List != null)
                                        {
                                            string[] fieldValues = new string[field.List.Count];
                                            for (int n = 0; n < field.List.Count; n++)
                                                fieldValues[n] = field.List[n].ToString();
                                            reportParam[i] = new ReportParameter(paramInfo.Name, fieldValues, false);
                                        }
                                    }

                                    break;
                                }
                            }
                        }
                        i++;
                    }
                    if (hasError)
                        throw new Exception(errorMsg);

                    localReport.SetParameters(reportParam);
                    //set query value
                    string paramPrefix = "";
                    bool positional = false;
                    string connectionString = "";
                    DbProviderFactory df = Anacle.DataFramework.Connection.GetDBProviderSetting(out paramPrefix, out positional, out connectionString);

                    // KF BEGIN
                    // updated to allow the result of a C# method to be bound to the RDL report
                    //
                    if (report.ReportType == 1 && report.UseCSharpQuery == 1)
                    {
                        object dataSource = Analysis.InvokeMethod(report.CSharpMethodName, reportFields);
                        if (dataSource is DataSet && template.ReportDataSet != null && template.ReportDataSet.Count > 1)
                        {
                            int NumberOfReportDataSet = template.ReportDataSet.Count;
                            int NumberOfDataSourceTable = ((DataSet)dataSource).Tables.Count;
                            int NumberOfResultAdded = 0;

                            foreach (DataTable dt in ((DataSet)dataSource).Tables)
                            {
                                foreach (OReportDataSet RDS in template.ReportDataSet)
                                {
                                    if (RDS.DataSetName == dt.TableName)
                                    {
                                        ReportDataSource reportDataSource = new ReportDataSource(dt.TableName, dt);
                                        localReport.DataSources.Add(reportDataSource);
                                        NumberOfResultAdded++;
                                    }
                                }
                            }
                            if (NumberOfResultAdded != NumberOfReportDataSet)
                                throw new Exception("Number of datatable passed in does not tally with number of datasource defined in the report.");
                        }
                        //for report accept 1 table
                        else if (template.ReportDataSet != null && template.ReportDataSet.Count == 1)
                        {
                            ReportDataSource reportDataSource = new ReportDataSource(template.ReportDataSet[0].DataSetName, dataSource);
                            localReport.DataSources.Add(reportDataSource);
                        }
                    }
                    else
                    {
                        if (template != null)
                        {
                            DataTable dt = Analysis.DoQuery(report.ReportQuery, reportFields);
                            ReportDataSource reportDataSource = new ReportDataSource(template.ReportDataSet[0].DataSetName, dt);
                            localReport.DataSources.Add(reportDataSource);
                        }
                        else
                        {
                            localReport.SetParameters(reportParam);
                            foreach (OReportDataSet rDS in report.ReportDataSet)
                            {
                                DataTable dt = GetReportDataSet(df, rDS, reportParamInfo, connectionString, positional, paramPrefix).Tables[0];
                                ReportDataSource reportDataSource = new ReportDataSource(rDS.DataSetName, dt);
                                localReport.DataSources.Add(reportDataSource);
                            }
                        }
                    }

                }
                catch (Exception ex)
                {
                    ShowException(ex);
                }
            }
            //Rachel. For those adhoc form. only meant for rdl report with one single dataset. and pass in the dataset name through query string ReportDataSetName 
            else
            {
                if (DiskCache.ContainsKey("ReportTable") && (Request["ReportDataSetName"] != null || Request["IsDataSet"] == "1") && Request["ReportVirtualPath"] != null)
                {
                    // reportViewer.LocalReport.DisplayName = report.ObjectName;
                    reportViewer.Width = Window.popupWidth - 40;
                    reportViewer.Height = Window.popupHeight - 40;
                    
                    // 2011.09.29, no longer needed.
                    //for downloading purpose
                    reportViewer.LocalReport.DisplayName = "Form.rdl";
                    reportViewer.ProcessingMode = ProcessingMode.Local;
                    LocalReport localReport = reportViewer.LocalReport;
                    //using text reader instead of file stream to read the file to avoid access right issue
                    System.IO.TextReader reader = null;
                    if (Request["IsReportVirtualPath"] == "0")
                        reader = new System.IO.StreamReader(Security.Decrypt(Request["ReportVirtualPath"].ToString()));
                    else
                        reader = new System.IO.StreamReader(Page.MapPath(Security.Decrypt(Request["ReportVirtualPath"].ToString())));
                    localReport.LoadReportDefinition(reader);

                    if (Request["IsDataSet"] == "1")
                    {
                        DataSet ds = DiskCache.GetDataSet("ReportTable");
                        if (ds != null && ds.Tables.Count > 0)
                        {
                            foreach (DataTable dt in ds.Tables)
                            {
                                ReportDataSource reportDataSource = new ReportDataSource(dt.TableName, dt);
                                localReport.DataSources.Add(reportDataSource);
                            }
                        }
                    }
                    else
                    {
                        ReportDataSource reportDataSource = new ReportDataSource(Security.Decrypt(Request["ReportDataSetName"].ToString()), DiskCache.GetDataTable("ReportTable"));
                        localReport.DataSources.Add(reportDataSource);
                    }


                    // KF modified this to output straight to PDF
                    //
                    if (Request["PDF"] == "1")
                    {
                        ExportToPDF();
                    }
                    // KF END;
                    // modified this to output straight to Excel
                    //
                    if (Request["XLS"] == "1")
                    {
                        ExportToExcel();
                    }
                    // 2011 05 01
                    // Kien Trung
                    // modified this to out put straight to image.
                    if (Request["JPG"] == "1")
                    {
                        ExportToImage();
                    }

                    // remove reporttable after used.
                    DiskCache.Remove("ReportTable");

                    // Kien Trung END
                }
            }
        }
    }


    protected void ExportToExcel()
    {
        LocalReport localReport = reportViewer.LocalReport;
        Random r = new Random();
        Warning[] warnings = null;
        string mimeType = null, encoding = null, fileNameExtension = null;
        string deviceInfo = "";
        string[] streams = null;
        byte[] byteImage = localReport.Render("Excel", deviceInfo, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);

        Response.ClearHeaders();
        Response.ClearContent();
        Response.Cache.SetCacheability(HttpCacheability.Public);
        Response.ContentType = "application/vnd.ms-excel";
        
        //Rachel. Allow to set the name of the file through request string
        string name = "report.xls";
        if (localReport.DisplayName != "" && localReport.DisplayName != null)
            name = localReport.DisplayName + ".xls";
        if (Request["N"] != null)
            name = Request["N"].ToString() + ".xls";
        Response.AddHeader("content-disposition", "attachment; filename=" + name);
        Response.BinaryWrite(byteImage);
        //Response.Write(sr.ReadToEnd());
        Response.End();
        

    }

    protected void ExportToImage()
    {
        LocalReport localReport = reportViewer.LocalReport;
        Random r = new Random();
        Warning[] warnings = null;
        string mimeType = null, encoding = null, fileNameExtension = null;
        string deviceInfo = "";
        string[] streams = null;
        byte[] byteImage = localReport.Render("Image", deviceInfo, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);
        
        Response.ClearHeaders();
        Response.ClearContent();
        Response.Cache.SetCacheability(HttpCacheability.Public);
        Response.ContentType = "image/jpeg";
        string name = "report.jpeg";
        if (localReport.DisplayName != "" && localReport.DisplayName != null)
            name = localReport.DisplayName + ".jpeg";
        if (Request["N"] != null)
            name = Request["N"].ToString() + ".jpeg";
        Response.AddHeader("content-disposition", "attachment; filename=" + name);
        Response.BinaryWrite(byteImage);
        
        Response.End();
        
    }

    protected void ExportToPDF()
    {
        LocalReport localReport = reportViewer.LocalReport;
        Random r = new Random();
        Warning[] warnings = null;
        string mimeType = null, encoding = null, fileNameExtension = null;
        string deviceInfo = "";
        string[] streams = null;
        byte[] byteImage = localReport.Render("PDF", deviceInfo, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);
        
        
        Response.ClearHeaders();
        Response.ClearContent();
        Response.Cache.SetCacheability(HttpCacheability.Public);
        Response.ContentType = "application/pdf";
        string name = "report.pdf";
        if (localReport.DisplayName != "" && localReport.DisplayName != null)
            name = localReport.DisplayName + ".pdf";
        if (Request["N"] != null)
            name = Request["N"].ToString() + ".pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + name);
        Response.BinaryWrite(byteImage);
        
        
        Response.End();
        
    }
    
    /// <summary>
    /// Shows an exception in the message label.
    /// </summary>
    /// <param name="ex"></param>
    protected void ShowException(Exception ex)
    {
        StringBuilder sb = new StringBuilder();
        Exception currentException = ex;
        while (currentException != null)
        {
            sb.Append(currentException.Message + "\n" + currentException.StackTrace + "\n\n");
            currentException = currentException.InnerException;
        }
        this.labelMessage.Text = 
            HttpUtility.HtmlEncode(sb.ToString()).Replace("\n", "<br>");
    }

    
    /// <summary>
    /// A single db parameter is built based on the name of a report filter field.
    /// dbparam carried the value of report field entered by user.
    /// Db param data type is matched with the field datatype
    /// dbparam name is the name of the field's identifer name with the parameter prefix
    /// </summary>
    /// <param name="reportFields"></param>
    /// <param name="reportParam"></param>
    /// <param name="paramPrefix"></param>
    /// <returns></returns>
    private DbParameter GetSingleDbParameter(global::Parameter field, string paramPrefix, DbParameter dbParam)
    {
        dbParam.ParameterName = paramPrefix + field.ParameterName;
        dbParam.Size = field.Size;
        //convert the value to null if no value or wrong value to avoid unexpected error entered
        try
        {
            if (field.DataType == DbType.Int32)//tessa
            {
                dbParam.DbType = DbType.Int32;
                dbParam.Value = Convert.ToInt32(field.Value);
            }
            else if (field.DataType == DbType.Decimal)//tessa
            {
                dbParam.DbType = DbType.Decimal;
                dbParam.Value = Convert.ToDecimal(field.Value);

            }
            else if (field.DataType == DbType.Double)//tessa
            {
                dbParam.DbType = DbType.Double;
                dbParam.Value = Convert.ToDouble(field.Value);
            }
            else if (field.DataType == DbType.DateTime)//tessa
            {
                dbParam.DbType = DbType.DateTime;
                dbParam.Value = Convert.ToDateTime(field.Value);
            }
            else if (field.DataType == DbType.Guid)//tessa
            {
                dbParam.DbType = DbType.Guid;
                dbParam.Value = new Guid(field.Value.ToString());
            }
            else
            {
                dbParam.DbType = DbType.String;
                dbParam.Value = field.Value;
            }
        }

        catch (Exception ex)
        {
            dbParam.Value = DBNull.Value;
        }
        return dbParam;
    }
    /// <summary>
    /// fill the report dataset with database independent code
    /// </summary>
    /// <param name="rDS"></param>
    /// <returns></returns>
    private DataSet GetReportDataSet(DbProviderFactory df, OReportDataSet rDS, ReportParameterInfoCollection reportParamsInfo, string connectionString, bool positional, string paramPrefix)
    {
        DbConnection cn = df.CreateConnection();
        cn.ConnectionString = connectionString;
        cn.Open();

        DbCommand command = cn.CreateCommand();
        command.CommandType = CommandType.Text;

        DbParameter[] queryParams = this.GetQueryParameters(command, rDS, positional, paramPrefix);
        command.CommandText = rDS.Query;
        if (queryParams != null)
            command.Parameters.AddRange(queryParams);
        DbDataAdapter adapter = df.CreateDataAdapter();
        adapter.SelectCommand = command;
        DataSet ds = new DataSet();
        adapter.Fill(ds);
        cn.Close();
        return ds;
    }
    /// <summary>
    /// build command parameter. if it's odbc parameter then use the specified order else match the name
    /// </summary>
    /// <param name="reportParamsInfo"></param>
    /// <returns></returns>
    private DbParameter[] GetQueryParameters(DbCommand command, OReportDataSet rDS, bool positional, string paramPrefix)
    {
        global::Parameter[] reportFields = (global::Parameter[])Session["ReportParameter"];
        if (reportFields == null || reportFields.Length == 0)
            return null;

        DbParameter[] dbParams;

        if (!positional)
        {
            int count = 0;
            dbParams = new DbParameter[reportFields.Length];
            for (int i = 0; i < reportFields.Length; i++)
            {
                DbParameter dbParam = command.CreateParameter();
                dbParams[count] = GetSingleDbParameter(reportFields[i], paramPrefix, dbParam);
                count++;
            }
        }
        else
        {
            int count = 0;
            //positional parameter, param name is passed by order as specified in Query parameter order
            //parameter order is the list of report field, separated by comma
            if (rDS.ParameterOrder != null && rDS.ParameterOrder.Trim() != "")
            {
                string[] fieldOrder = rDS.ParameterOrder.Split(',');
                dbParams = new DbParameter[fieldOrder.Length];
                for (int i = 0; i < fieldOrder.Length; i++)
                {
                    //match the field order with the actual report field through the name
                    for (int n = 0; n < reportFields.Length; n++)
                    {
                        if (fieldOrder[i].Trim() == reportFields[n].ParameterName)
                        {
                            DbParameter dbParam = command.CreateParameter();
                            dbParams[count] = GetSingleDbParameter(reportFields[n], paramPrefix, dbParam);
                            count++;
                            break;
                        }
                    }

                }
            }
            else
                return null;

        }
        return dbParams;

    }

    /// <summary>
    /// Return a set of query parameter in ODbc style. and convert the query of the report data set to ODBC syntax
    /// Assumption that the query is written in ODBC and general SQL syntax, no SQL server specify syntax
    /// </summary>
    /// <param name="command"></param>
    /// <param name="rDS"></param>
    /// <param name="paramPrefix"></param>
    /// <returns></returns>
    public SqlQueryString GenerateSqlQuery(global::Parameter[] reportFields, OReportDataSet rDS, string paramPrefix)
    {

        List<DbParameter> dbParams = new List<DbParameter>();
        string queryString = rDS.Query + " ";
        bool isLiteral = false;
        string paramName = "";
        //string builder to store the last query
        StringBuilder sb = new StringBuilder();
        //read through character by character and search for parameter and create a parameter for the found parameter , and replace the query parameter with a question mark         
        //double quotation is part of literal value        
        for (int i = 0; i < queryString.Length - 1; i++)
        {
            //if currently it is not within a literal, then when encounter param Prefix, it's a parameter
            if (!isLiteral && queryString[i] == paramPrefix[0])
            {
                paramName = "";
                //looking for the last character of the parameter, i.e. empty space or +
                for (int y = i + 1; y < queryString.Length; y++)
                {
                    //reach to the end of the param name. i.e. characters that are not alllowed to be part of the parameter name
                    //using regular expression to find the right match
                    if (!System.Text.RegularExpressions.Regex.IsMatch(queryString[y].ToString(), @"[a-z0-9A-Z]") && queryString[y] != '_' && queryString[y] != '@' && queryString[y] != '$' && queryString[y] != '#')
                    {
                        bool found = false;
                        //search for the field with the same name to param name
                        foreach (global::Parameter field in reportFields)
                        {
                            if (field.ParameterName == paramName)
                            {
                                found = true;
                                DbParameter dbParam = Connection.GetProviderFactory().CreateParameter();
                                dbParam.ParameterName = field.ParameterName;
                                dbParam.DbType = field.DataType;
                                dbParam.Size = field.Size;
                                dbParam.Value = field.Value;
                                dbParams.Add(dbParam);
                                break;
                            }
                        }
                        if (!found)
                        {
                            throw new Exception("Unable to find report field that match with query parameter " + paramName);
                        }
                        //fast forward to the end of the parameter name
                        i = y - 1;
                        sb.Append('?');
                        break;
                    }
                    //concatenate the param name
                    else
                    {
                        paramName += queryString[y];
                    }
                }
            }
            else
            {
                sb.Append(queryString[i]);
                if (!isLiteral && queryString[i] == '\'')
                {
                    isLiteral = true;
                }
                else if (isLiteral)
                {
                    //ensure it's a close quotation, not double quote
                    if (queryString[i] == '\'')
                    {
                        if (queryString[i + 1] != '\'')
                        {
                            isLiteral = false;
                        }
                        //if it is a double quote, jump to the next
                        else
                        {
                            i = i + 1;
                            sb.Append(queryString[i]);
                        }
                    }
                }
            }

        }
        SqlQueryString sqlQuery = new SqlQueryString();
        sqlQuery.QueryString = sb.ToString();
        sqlQuery.Parameters = new DbParameter[dbParams.Count];
        for (int i = 0; i < dbParams.Count; i++)
            sqlQuery.Parameters[i] = dbParams[i];
        return sqlQuery;
    }

    protected void linkBtnExport_Click(object sender, EventArgs e)
    {
        if (dropFormat.SelectedIndex == 1)
            ExportToExcel();
        if (dropFormat.SelectedIndex == 2)
            ExportToPDF();
        if (dropFormat.SelectedIndex == 3)
            ExportToImage();

    }
    
  
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Anacle.EAM ReportViewer</title>
</head>
<body style="margin: 0px">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <div align="right" style="background-color:#D9D9D9">
    <asp:DropDownList runat="server" ID='dropFormat' Font-Names="Tahoma" Font-Size="8pt">
        <Items>
            <asp:ListItem Text="Select a format" Selected="True"></asp:ListItem>
            <asp:ListItem Text="Microsoft Office Excel"></asp:ListItem>
            <asp:ListItem Text="Acrobat (PDF) file"></asp:ListItem>
            <asp:ListItem Text="Image file"></asp:ListItem>
        </Items>
    </asp:DropDownList>
    <asp:Button runat="server" ID='linkBtnExport' Font-Names="Tahoma" Font-Bold="true" Font-Size="8pt" Text="Export" OnClick="linkBtnExport_Click"></asp:Button>
    </div>
    <asp:Label runat="server" ID="labelMessage" Font-Bold="false" ForeColor="red" EnableViewState="false"
        Visible="false"></asp:Label>
    <div class="div-main">
        <rsweb:ReportViewer ID="reportViewer" runat="server" ForeColor="Black" ProcessingMode="Local" Width="100%"
            Font-Names="Tahoma" Font-Size="8pt" Height="750px" ShowPrintButton="false" 
            ShowCredentialPrompts="false" EnableTheming="false" ZoomMode="Percent" ZoomPercent="100"
            ShowExportControls="false" ExportContentDisposition="AlwaysAttachment">
        </rsweb:ReportViewer>
    </div>
    </form>
</body>
</html>
