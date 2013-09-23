<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" ValidateRequest="false"
    Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        if (Page is UIPageBase)
        {
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttonUpload);
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttonUpdateTemplate);
        }
    }

    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OReport report = (OReport)panel.SessionObject;

        ReportRoles.Bind(OUser.GetRoles(), "RoleName", "ObjectID");

        if (report != null && report.ReportFileName != null && report.ReportFileName.Trim() != "")
            this.ReportFileName.Text = report.ReportFileName.ToString();
        List<OReportField> controls = report.GetDropDownReportFields();
        if (controls.Count > 0)
            TreeCascadeControlID.Bind(controls, "ControlCaption", "ObjectID");

        frameBottom.Attributes["src"] = "preview.aspx?ID=" + HttpUtility.UrlEncode(Security.EncryptGuid(report.ObjectID.Value)); ;
        PopulateRdlTemplateGrid();
        panel.ObjectPanel.BindObjectToControls(report);
    }


    /// <summary>
    /// Validates and saves the report object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OReport report = (OReport)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(report);

            // Validate
            //
            if (report.ReportType == 0 && (report.ReportFileBytes == null || report.ReportFileBytes.LongLength <= 0))
                this.RdlInputFile.ErrorMessage = Resources.Errors.Report_ReportFileNotFound;
            if (report.ReportType == 0 && this.panelReportDataSet.Visible && report.ReportDataSet != null && report.ReportDataSet.Count > 0)
            {
                foreach (OReportDataSet rDS in report.ReportDataSet)
                {
                    if (rDS.ParameterOrder != null && rDS.ParameterOrder.Trim() != "")
                    {
                        string[] fieldOrder = rDS.ParameterOrder.Split(',');
                        for (int i = 0; i < fieldOrder.Length; i++)
                        {
                            bool found = false;
                            foreach (OReportField field in report.ReportFields)
                            {
                                if (fieldOrder[i].Trim() == field.ControlIdentifier)
                                {
                                    found = true;
                                    break;
                                }
                            }
                            if (!found)
                                this.ReportParamOrder.ErrorMessage = Resources.Errors.Report_FieldNotFound;
                        }
                    }
                }
            }

            foreach (OReportField reportField in report.ReportFields)
            {
                if (reportField.ControlType == (int)EnumReportControlType.ContextTree)
                    reportField.DataType = (int)EnumReportDataType.UniqueIdentifier;
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            report.Save();
            c.Commit();
        }
    }


    //---------------------------------------------------------------   
    // event
    //---------------------------------------------------------------
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OReport report = (OReport)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(report);

        panelListQuery.Visible = ControlType.SelectedValue == ((int)EnumReportControlType.DropdownList).ToString() || 
            ControlType.SelectedValue == ((int)EnumReportControlType.RadioButtonList).ToString() || 
            ControlType.SelectedValue == ((int)EnumReportControlType.MultiSelectList).ToString();
        panelPopulatedByQuery.Visible = IsPopulatedByQuery.SelectedIndex == 1 || IsPopulatedByQuery.SelectedIndex == 2;
        ListQuery.Visible = IsPopulatedByQuery.SelectedIndex == 1;
        panelNotPopulatedByQuery.Visible = IsPopulatedByQuery.SelectedIndex == 0;
        ReportFieldCMethod.Visible = IsPopulatedByQuery.SelectedIndex == 2;

        TreeCascadeControlID.Visible = ContextTree.SelectedIndex != 0;
        CascadeControlID.Visible = ControlType.SelectedValue == ((int)EnumReportControlType.DropdownList).ToString() ||
            ControlType.SelectedValue == ((int)EnumReportControlType.RadioButtonList).ToString() ||
            ControlType.SelectedValue == ((int)EnumReportControlType.MultiSelectList).ToString() ||
            ControlType.SelectedValue == ((int)EnumReportControlType.ContextTree).ToString();
        ContextFilter.Visible = ControlType.SelectedValue == ((int)EnumReportControlType.ContextTree).ToString();
        DataType.Enabled = ControlType.SelectedValue != ((int)EnumReportControlType.ContextTree).ToString();

        checkIsInsertBlank.Visible = ControlType.SelectedValue == ((int)EnumReportControlType.DropdownList).ToString();
        
        SetReportTypeDisplay();
        if (OReport.DisplayOdbcConvert() && UseCSharpQuery.SelectedValue == "0" && report.ReportType == 0)
            this.panelODbcConvert.Visible = true;
        else
            this.panelODbcConvert.Visible = false;

        ReportQuery.Visible = UseCSharpQuery.SelectedValue == "0";
        CSharpMethodName.Visible = UseCSharpQuery.SelectedValue == "1";
        this.ReportType.Enabled = (panel_RDLTemplate.Visible == true || gridRDLTemplate.Rows.Count > 0) ? false : true;
        frameBottom.Attributes["src"] = "../reportviewer/search.aspx?ID=" + HttpUtility.UrlEncode(Security.EncryptGuid(report.ObjectID.Value));
        tabPreview.Update();
        if (tabObject.SelectedTab == tabQuery && UseCSharpQuery.SelectedIndex == 0)
            Window.WriteJavascript("loadTextInput('" + ReportQuery.Control.ClientID + "');");
    }


    //---------------------------------------------------------------   
    // event
    //---------------------------------------------------------------
    protected void ReloadTreeCascadeControl()
    {
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        List<OReportField> controls = report.GetDropDownReportFields();
        if (controls.Count > 0)
            TreeCascadeControlID.Bind(controls, "ControlCaption", "ObjectID");

        panel.ObjectPanel.BindObjectToControls(report);
    }


    //---------------------------------------------------------------   
    // event
    //---------------------------------------------------------------
    protected void ContextTree_SelectedIndexChanged(object sender, EventArgs e)
    {
        ReloadTreeCascadeControl();
    }


    //---------------------------------------------------------------   
    // event
    //---------------------------------------------------------------
    protected void UseCSharpQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Populates the report field subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ReportField_ObjectPanel_PopulateForm(object sender, EventArgs e)
    {
        OReport report = panel.SessionObject as OReport;
        OReportField reportField = ReportField_SubPanel.SessionObject as OReportField;

        DisplayOrder.Items.Clear();
        for (int i = 0; i < report.ReportFields.Count + 1; i++)
            DisplayOrder.Items.Add(new ListItem((i + 1).ToString(), (i + 1).ToString()));

        CascadeControlID.Bind(report.GetDropDownReportFields(reportField.ControlIdentifier), "ControlCaption", "ObjectID");
        ControlType.Bind(OReportField.GetReportControlTypeTable(), "Name", "Value");
        DataType.Bind(OReportField.GetReportDataTypeTable(), "Name", "Value");
        ContextFilter.Bind(OReportField.GetReportContextTreeTable(), "Name", "Value", false);
        
        if (reportField.DisplayOrder == null)
            reportField.DisplayOrder = DisplayOrder.Items.Count;

        ReportField_SubPanel.ObjectPanel.BindObjectToControls(reportField);
    }


    /// <summary>
    /// Occurs when the user clicks on the remove button to remove
    /// report fields.
    /// </summary>
    /// <param name="sneder"></param>
    /// <param name="e"></param>
    protected void ReportField_SubPanel_Removed(object sneder, EventArgs e)
    {
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        //report.ReorderItems(null);
        LogicLayer.Global.ReorderItems(report.ReportFields, null, "DisplayOrder");
        ReloadTreeCascadeControl();
    }


    /// <summary>
    /// Validates and inserts the report field object into the report object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ReportField_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        OReportField reportField = ReportField_SubPanel.SessionObject as OReportField;
        ReportField_SubPanel.ObjectPanel.BindControlsToObject(reportField);

        // Validate
        //
        if (reportField.ControlIdentifier.Contains(" "))
            ControlIdentifier.ErrorMessage = Resources.Errors.Report_IdentifierHasSpaces;
        if (reportField.ControlIdentifier.Contains(","))
            ControlIdentifier.ErrorMessage = Resources.Errors.Report_IdentifierHasComma;
        if (report.CascadeHasLoops())
        {
            CascadeControlID.ErrorMessage = Resources.Errors.Report_CascadeControlLoop;
            reportField.CascadeControl.Clear();
        }
        if (!report.ValidateNoDuplicateIdentifiers(reportField))
            ControlIdentifier.ErrorMessage = Resources.Errors.Report_DuplicateIdentifier;
        if (!ReportField_SubPanel.ObjectPanel.IsValid)
            return;

        // Insert
        //
        report.ReportFields.Add(reportField);
        panel.ObjectPanel.BindObjectToControls(report);

        // Update
        LogicLayer.Global.ReorderItems(report.ReportFields, reportField, "DisplayOrder");
        ReloadTreeCascadeControl();
    }


    //---------------------------------------------------------------   
    // event
    //---------------------------------------------------------------
    protected void ControlType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ControlType.SelectedValue == ((int)EnumReportControlType.ContextTree).ToString())
            DataType.SelectedValue = ((int)EnumReportDataType.UniqueIdentifier).ToString();
    }


    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected void isPopulatedByQuery_CheckedChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Occurs when the user clicks on the Generate Report Filters
    /// button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGetParam_Click(object sender, EventArgs e)
    {
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        report.ReportFields.Clear();
        ReportViewer reportViewer = new ReportViewer();
        LocalReport localReport = reportViewer.LocalReport;
        System.IO.MemoryStream stream = new System.IO.MemoryStream(report.ReportFileBytes);
        localReport.LoadReportDefinition(stream);
        //Automatically build a list of filters corresponding with the report parameter list
        ReportParameterInfoCollection paramCol = localReport.GetParameters();
        // Session["ReportParameterInfo"] = paramCol;
        int displayOrder = 1;
        if (paramCol != null)
        {
            for (int i = 0; i < paramCol.Count; i++)
            {
                ReportParameterInfo param = paramCol[i];
                //generate for all except default fields such as userID, TreeviewObject, TreeviewID
                if (param.Name.ToUpper() == "USERID")
                    continue;
                if (param.Name.ToUpper() == "TREEVIEWOBJECT")
                    continue;
                if (param.Name.ToUpper() == "TREEVIEWID")
                    continue;
                OReportField field = TablesLogic.tReportField.Create();
                field.ReportID = report.ObjectID;
                field.ControlIdentifier = param.Name;
                //field.ControlCaption = param.Prompt;
                field.DisplayOrder = displayOrder++;
                //half span
                field.ControlSpan = 0;
                //default text box
                field.ControlType = 0;

                //data type
                if (param.DataType == ParameterDataType.String)
                    field.DataType = 0;
                else if (param.DataType == ParameterDataType.Integer)
                    field.DataType = 1;
                else if (param.DataType == ParameterDataType.Float)
                    field.DataType = 3;
                else if (param.DataType == ParameterDataType.DateTime)
                {
                    field.DataType = 4;
                    field.ControlType = 1;
                }
                else if (param.DataType == ParameterDataType.Boolean)
                    field.DataType = 1;
                report.ReportFields.Add(field);
            }
        }
        //refresh field data grid
        this.ReportFields.DataSource = report.ReportFields;
        this.ReportFields.DataBind();
    }


    /// <summary>
    /// Occurs when the user clicks on the Upload File button
    /// to upload an RDL report template.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpload_Click(object sender, EventArgs e)
    {
        try
        {
            OReport report = panel.SessionObject as OReport;
            panel.ObjectPanel.BindControlsToObject(report);
            if (RdlInputFile.PostedFile == null || RdlInputFile.PostedFile.ContentLength <= 0)
            {
                panel.Message = Resources.Errors.Report_InvalidReportFile;
                return;
            }

            else if (report.ReportType == 0)
            {
                if (!RdlInputFile.PostedFile.FileName.EndsWith(".rdl") && !RdlInputFile.PostedFile.FileName.EndsWith(".rdlc"))
                {
                    panel.Message = Resources.Errors.Report_InvalidReportFile;
                    return;
                }
                else
                {
                    byte[] fileBytes = new byte[RdlInputFile.PostedFile.ContentLength];
                    RdlInputFile.PostedFile.InputStream.Position = 0;
                    RdlInputFile.PostedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

                    //Attempt to get datasource and dataset information from rdl file.
                    byte[] b = fileBytes;
                    string contents = ASCIIEncoding.UTF8.GetString(b, 0, b.Length).Trim();
                    OReport.GetStaticReportSettings(report, b, contents, Path.GetFileName(RdlInputFile.PostedFile.FileName));
                    //set the report name
                    this.ReportFileName.Text = report.ReportFileName;
                    //refresh report param order grid
                    this.ReportParamOrder.DataSource = report.ReportDataSet;
                    this.ReportParamOrder.DataBind();

                    panel.Message = Resources.Messages.General_FileUpload;
                }
            }
            //16Jul09: report type named 'crystal report' is removed.
            //else if (report.ReportType == 2)
            //{
            //    if (!RdlInputFile.PostedFile.FileName.EndsWith(".rpt"))
            //    {
            //        panel.Message = Resources.Errors.Report_InvalidReportFile;
            //        return;
            //    }
            //    else
            //    {
            //        byte[] fileBytes = new byte[RdlInputFile.PostedFile.ContentLength];
            //        RdlInputFile.PostedFile.InputStream.Position = 0;
            //        RdlInputFile.PostedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);
            //        report.ReportFileBytes = fileBytes;
            //        report.ReportFileName = Path.GetFileName(RdlInputFile.PostedFile.FileName);
            //        this.ReportFileName.Text = report.ReportFileName;
            //        panel.Message = Resources.Messages.General_FileUpload;
            //    }
            //}
        }
        catch (Exception ex)
        {
            this.RdlInputFile.ErrorMessage = ex.Message;
        }


    }
    protected void DisplayReportParamOrderPanel()
    {
        if (ReportType.SelectedValue == "1")
        {
            this.panelReportDataSet.Visible = false;
            return;
        }

        OReport report = (OReport)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(report);

        if (report != null && report.ReportDataSet != null && report.ReportDataSet.Count > 0)
        {
            string paramName = "";
            bool positional = false;
            string connectionString = "";
            //display parameter order grid if the data base provider use positional parameter instead of named parameter
            Anacle.DataFramework.Connection.GetDBProviderSetting(out paramName, out positional, out connectionString);
            if (positional)
            {
                this.panelReportDataSet.Visible = true;
            }
            else
            {
                this.panelReportDataSet.Visible = false;
            }
        }
        else
            this.panelReportDataSet.Visible = false;
    }

    protected void ReportType_CheckedChanged(object sender, EventArgs e)
    {
        SetReportTypeDisplay();
    }

    /// <summary>
    /// Hides/shows tabviews, panels, controls when report type changes.
    /// ReportType.SelectedValue = "0": rdl
    /// ReportType.SelectedValue = "1": spreadsheet
    /// </summary>
    protected void SetReportTypeDisplay()
    {
        this.buttonGetParam.Visible = ReportType.SelectedValue == "0" ? true : false;
        this.panelDynamic.Visible = ReportType.SelectedValue == "0" ? false : true;
        this.panelStatic.Visible = ReportType.SelectedValue == "0" ? true : false;
        this.gridRDLTemplate.Visible = ReportType.SelectedValue == "0" ? false : true;
        this.VisibleColumnAtStart.Visible = ReportType.SelectedValue == "0" ? false : true;
        this.panel_StaticReportFile.Visible = ReportType.SelectedValue == "0" ? true : false;
        this.tabQuery.Visible = ReportType.SelectedValue == "0" ? false : true;

        if (ReportType.SelectedValue == "0") //rdl
        {
            //show download button if there is any file
            OReport report = (OReport)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(report);

            if (report != null && report.ReportFileBytes != null && report.ReportFileBytes.Length > 0)
                this.buttonDownload.Visible = true;
            else
                this.buttonDownload.Visible = false;
        }
        DisplayReportParamOrderPanel();

        //16Jul09: report type named 'crystal report' is removed.
        //else if (ReportType.SelectedValue == "2")
        //{
        //    this.panelDynamic.Visible = true;
        //    this.panelStatic.Visible = true;
        //    this.panelODbcConvert.Visible = false;
        //    //show download button if there is any file
        //    OReport report = (OReport)panel.SessionObject;
        //    panel.ObjectPanel.BindControlsToObject(report);

        //    if (report != null && report.ReportFileBytes != null && report.ReportFileBytes.Length > 0)
        //        this.buttonDownload.Visible = true;
        //    else
        //        this.buttonDownload.Visible = false;

        //}
    }


    protected void buttonDownload_Click(object sender, EventArgs e)
    {
        OReport report = (OReport)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(report);
        panel.FocusWindow = false;

        // pop-up document in a new window
        Window.Download(report.ReportFileBytes, report.ReportFileName, "text/xml?");
    }


    /// <summary>
    /// Populates the report column mapping form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ReportColumnMappings_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OReportColumnMapping columnMapping = ReportColumnMappings_SubPanel.SessionObject as OReportColumnMapping;

        ReportColumnMappings_SubPanel.ObjectPanel.BindObjectToControls(columnMapping);
    }


    /// <summary>
    /// Validates and inserts the report column mapping into
    /// the report object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ReportColumnMappings_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        OReportColumnMapping mapping = (OReportColumnMapping)ReportColumnMappings_SubPanel.SessionObject;
        ReportColumnMappings_SubPanel.ObjectPanel.BindControlsToObject(mapping);

        // Insert
        //
        report.ReportColumnMappings.Add(mapping);
        panel.ObjectPanel.BindObjectToControls(report);
    }

    protected void ReportType_SelectedIndexChanged(object sender, EventArgs e)
    {
        SetReportTypeDisplay();
    }

    protected void gridRDLTemplate_Action(object sender, string commandName, List<object> objectIds)
    {
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        this.panel_RDLTemplate.ClearErrorMessages();
        panel.Message = "";

        if (commandName == "AddTemplate" || commandName == "EditTemplate")
        {
            this.TemplateFileName.Visible = (commandName == "EditTemplate" && objectIds != null && objectIds.Count > 0);
            this.TemplateUpload.ValidateRequiredField = commandName == "AddTemplate";

            UIGridViewCommand deleteCommand = this.gridRDLTemplate.Commands[0];
            UIGridViewCommand addCommand = this.gridRDLTemplate.Commands[1];
            deleteCommand.Visible = false;
            addCommand.Visible = false;

            if (commandName == "AddTemplate")
            {
                this.TemplateUpdateMode.Text = "";
                this.TemplateName.Text = "";
                this.TemplateType.SelectedIndex = 0;
            }
            this.panel_RDLTemplate.Visible = true;
            //to specify the objectID
            if (commandName == "EditTemplate" && objectIds != null && objectIds.Count > 0)
            {
                this.TemplateUpdateMode.Text = objectIds[0].ToString();
                OReportTemplate template = report.ReportTemplate.FindObject(new Guid(objectIds[0].ToString())) as OReportTemplate;
                this.TemplateName.Text = template.ObjectName;
                this.TemplateFileName.Text = template.ObjectNumber;
                this.TemplateType.SelectedValue = template.TemplateType.ToString();
            }
            else
                this.TemplateUpdateMode.Text = "";

        }
        else if (commandName == "Download")
        //download template
        {
            //OAttachment file = TablesLogic.tAttachment.Create();
            OReportTemplate template = TablesLogic.tReportTemplate.Load(new Guid(objectIds[0].ToString()));
            //file.FileBytes = template.RdlBytes;
            //file.Filename = template.ObjectNumber;
            //file.ContentType = "text/xml";
            //Session["FILE::DOWNLOAD"] = file;
            panel.FocusWindow = false;
            // pop-up document in a new window
            Window.Download(template.RdlBytes, template.ObjectNumber, "text/xml?");
        }
        else if (commandName == "DeleteTemplate")
        {
            foreach (object id in objectIds)
                report.ReportTemplate.RemoveGuid(new Guid(id.ToString()));
            PopulateRdlTemplateGrid();
        }
    }

    protected void PopulateRdlTemplateGrid()
    {
        //update template grid with RDL list
        OReport report = panel.SessionObject as OReport;
        List<OReportTemplate> tempList = new List<OReportTemplate>();
        foreach (OReportTemplate t in report.ReportTemplate)
        {
            if (t.RdlBytes != null)
                tempList.Add(t);
        }
        this.gridRDLTemplate.Bind(tempList);
    }

    /// <summary>
    /// When the Update button in Report Template tabview is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpdateTemplate_Click(object sender, EventArgs e)
    {
        string error = "";
        this.panel_RDLTemplate.ClearErrorMessages();

        this.panel.Message = ValidateTemplateInputFile();
        if (this.panel.Message != "")
            return;

        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        //create new only if the id not exist
        if (TemplateUpdateMode.Text == "")
        {
            OReportTemplate template = TablesLogic.tReportTemplate.Create();
            ReportTemplateUpload(template);
            template.CreatorID = AppSession.User.ObjectID;
        }
        else
        {
            OReportTemplate template = (OReportTemplate)report.ReportTemplate.FindObject(new Guid(TemplateUpdateMode.Text));
            if (template != null && (this.TemplateUpload.Control.PostedFile.FileName != "" && this.TemplateUpload.Control.PostedFile != null
            && this.TemplateUpload.Control.PostedFile.ContentLength != 0))
                ReportTemplateUpload(template);
            template.ObjectName = this.TemplateName.Text;
            if (template.TemplateType != Convert.ToInt32(this.TemplateType.SelectedValue))
                panel.Message = Resources.Messages.Report_TemplateMismatch;

        }
        UIGridViewCommand deleteCommand = this.gridRDLTemplate.Commands[0];
        UIGridViewCommand addCommand = this.gridRDLTemplate.Commands[1];
        deleteCommand.Visible = true;
        addCommand.Visible = true;

        PopulateRdlTemplateGrid();
        this.panel_RDLTemplate.Visible = panel.Message != "";
        panel.ObjectPanel.BindObjectToControls(report);
    }

    protected void ReportTemplateUpload(OReportTemplate template)
    {
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindObjectToControls(report);

        if (this.TemplateType.SelectedValue == ((int)TemplateTypeName.rdlreport).ToString())
        {
            //Attempt to get datasource and dataset information from rdl file.
            byte[] b = (byte[])TemplateUpload.ControlValue;
            string contents = ASCIIEncoding.UTF8.GetString(b, 0, b.Length).Trim();
            OReport.GetStaticReportSettings(template, b, contents, Path.GetFileName(TemplateUpload.Control.PostedFile.FileName), this.TemplateName.Text);
            report.ReportTemplate.Add(template);
        }
        else if (this.TemplateType.SelectedValue == ((int)TemplateTypeName.crystalreport).ToString())
        {
            byte[] b = (byte[])TemplateUpload.ControlValue;
            template.RdlBytes = b;
            template.ObjectNumber = Path.GetFileName(TemplateUpload.Control.PostedFile.FileName);
            template.ObjectName = this.TemplateName.Text;
            template.TemplateType = (int)TemplateTypeName.crystalreport;
            report.ReportTemplate.Add(template);
        }
        panel.ObjectPanel.BindControlsToObject(report);
    }

    protected void buttonCancelTemplate_Click(object sender, EventArgs e)
    {
        this.panel_RDLTemplate.Visible = false;

        UIGridViewCommand deleteCommand = this.gridRDLTemplate.Commands[0];
        UIGridViewCommand addCommand = this.gridRDLTemplate.Commands[1];
        deleteCommand.Visible = true;
        addCommand.Visible = true;
    }

    /// <summary>
    /// Validates input file for report template upload.
    /// </summary>
    /// <returns></returns>
    private string ValidateTemplateInputFile()
    {
        string error = "";
        OReport report = panel.SessionObject as OReport;
        panel.ObjectPanel.BindControlsToObject(report);

        OReportTemplate template = null;
        //in template editing mode, load current report template
        if (this.TemplateUpdateMode.Text != "")
        {
            template = report.ReportTemplate.FindObject(new Guid(this.TemplateUpdateMode.Text)) as OReportTemplate;

            if (template != null)
            {
                //if user upload different template, validate input file format
                if (this.TemplateUpload.Control.PostedFile.FileName != "" && this.TemplateUpload.Control.PostedFile != null
                && this.TemplateUpload.Control.PostedFile.ContentLength != 0)
                    error = ValidateTemplateFileFormat();
            }

        }
        else //in template adding mode
        {
            //no template file selected for uploading
            if (this.TemplateUpload.Control.PostedFile.FileName == "" || this.TemplateUpload.Control.PostedFile == null
            || this.TemplateUpload.Control.PostedFile.ContentLength == 0)
            {
                this.TemplateUpload.ErrorMessage = Resources.Errors.Report_EmptyFile;
                return Resources.Errors.Report_EmptyFile;
            }
            else
            {
                //validate input file format
                error = ValidateTemplateFileFormat();
            }
        }

        //template name cannot be empty
        if (this.TemplateName.Text == "")
        {
            this.TemplateName.ErrorMessage = Resources.Errors.Report_TemplateNameEmpty;
            return this.TemplateName.ErrorMessage;
        }

        //check duplicate template name
        if (OReportTemplate.IsTemplateNameDuplicated(report, this.TemplateName.Text, template))
        {
            this.TemplateName.ErrorMessage = Resources.Errors.Report_TemplateNameDuplicate;
            return Resources.Errors.Report_TemplateNameDuplicate;
        }

        return error;
    }

    /// <summary>
    /// Validate upload file format for template upload.
    /// RDL Template    : File format must be 'rdl', TemplateType=0 
    /// Crystal Template: File format must be 'rpt' for TemplateType=1 
    /// </summary>
    /// <returns></returns>
    protected string ValidateTemplateFileFormat()
    {
        string error = "";
        if (this.TemplateType.SelectedValue == "0" && (!this.TemplateUpload.Control.PostedFile.FileName.ToLower().EndsWith("rdl")
                && !TemplateUpload.Control.PostedFile.FileName.EndsWith(".rdlc")))
        {
            error = Resources.Errors.Report_InvalidRdlTemplateFile;
            this.TemplateUpload.ErrorMessage = error;
        }
        if (this.TemplateType.SelectedValue == "1" &&
            !this.TemplateUpload.Control.PostedFile.FileName.ToLower().EndsWith(".rpt"))
        {
            error = Resources.Errors.Report_InvalidRptTemplateFile;
            this.TemplateUpload.ErrorMessage = error;
        }
        return error;
    }

    /// <summary>
    /// Display template type name for report template.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridRDLTemplate_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[4].Text = e.Row.Cells[4].Text == ((int)TemplateTypeName.rdlreport).ToString() ? Resources.Strings.Report_RDLtemplate : Resources.Strings.Report_RPTtemplate;
        }
    }


    protected void IsPopulatedByQuery_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void tabQuery_Click(object sender, EventArgs e)
    {
        //Window.WriteJavascript("loadTextInput('" + ReportQuery.Control.ClientID + "');");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
    <script language="Javascript" type="text/javascript" src="../../edit_area/edit_area_full.js"></script>
    <script language="Javascript" type="text/javascript" >
        function loadTextInput(var1) {
            editAreaLoader.init({
            id: var1
			, start_highlight: true
			, toolbar: "search, go_to_line, fullscreen, |, undo, redo, |, select_font,|, word_wrap, |, help, save" 
			, browsers: "all"
			, language: "en"
			, syntax: "sql"
			, allow_toggle: true
			, min_width: 600
			, min_height: 200
			, save_callback: "my_save"
			, change_callback: "my_change"
			, word_wrap: "true"
            });
        }

        // callback functions
        function my_save(id, content) {
            var text = document.getElementById(id);
            text.innerHtml = text.innerText = text.value = content;
        }

        // callback functions
        function my_change(id) {
            window.frames['frame_' + id].document.getElementById('a_save').click();
        }
    </script>	
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Report" BaseTable="tReport" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <ui:UITabView ID="uitabview1" runat="server" Caption="Details" meta:resourcekey="uitabview1Resource1"
                    BorderStyle="NotSet">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false"
                        ObjectNameCaption="Report Name" ObjectNumberValidateRequiredField="true" ObjectNameTooltip="The report name as displayed on the menu."
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldTextBox runat="server" ID="textReportName" Caption="Report Name" PropertyName="ReportName"
                        ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="textReportNameResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textCategoryName" Caption="Category Name" PropertyName="CategoryName"
                        ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="textCategoryNameResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="UITabView6" Caption="Filter" BorderStyle="NotSet"
                    meta:resourcekey="UITabView6Resource1">
                    <ui:UIFieldDropDownList ID="ContextTree" runat="server" Caption="Top Context Tree"
                        OnSelectedIndexChanged="ContextTree_SelectedIndexChanged" PropertyName="ContextTree"
                        ValidateRequiredField="True" ToolTip="The context tree that appears on the left frame for the report."
                        meta:resourcekey="ContextTreeResource1">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource1" Text="None"></asp:ListItem>
                            <asp:ListItem Value="10" Text="Account" meta:resourcekey="ListItemResource2"></asp:ListItem>
                            <asp:ListItem Value="11" Text="Inventory Catalog" meta:resourcekey="ListItemResource3"></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Checklist"></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" Text="Code"></asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource4" Text="CodeType"></asp:ListItem>
                            <asp:ListItem Value="4" meta:resourcekey="ListItemResource5" Text="Equipment"></asp:ListItem>
                            <asp:ListItem Value="5" meta:resourcekey="ListItemResource6" Text="EquipmentType"></asp:ListItem>
                            <asp:ListItem Value="6" meta:resourcekey="ListItemResource7" Text="Location"></asp:ListItem>
                            <asp:ListItem Value="7" meta:resourcekey="ListItemResource8" Text="LocationType"></asp:ListItem>
                            <asp:ListItem Value="8" meta:resourcekey="ListItemResource9" Text="Location and Equipment"></asp:ListItem>
                            <asp:ListItem Value="9" meta:resourcekey="ListItemResource10" Text="Service Catalog"></asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldListBox runat="server" ID="TreeCascadeControlID" Caption="Cascade Control"
                        PropertyName="CascadeControl" Span="Half" meta:resourcekey="TreeCascadeControlIDResource1"></ui:UIFieldListBox>
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="Separator2" meta:resourcekey="Separator1Resource1" />
                    <table width="100%">
                        <tr>
                            <td align="right">
                                <ui:UIButton runat="server" ID="buttonGetParam" OnClick="buttonGetParam_Click" ImageUrl="~/images/Symbol-Refresh-big.gif"
                                    Text="Generate report filters" ConfirmText="This action will delete all existing report filters and create a new set of filters based on the report parameters. Are you sure you wish to continue?"
                                    meta:resourcekey="buttonGetParamResource1" />
                            </td>
                        </tr>
                    </table>
                    <ui:UIGridView ID="ReportFields" runat="server" Caption="Filter Fields" PropertyName="ReportFields"
                        SortExpression="DisplayOrder" KeyName="ObjectID" Width="100%" PagingEnabled="True"
                        DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="ReportFieldsResource1"
                        RowErrorColor="" style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                CommandText="Delete" ConfirmText="Are you sure you wish to remove the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourceKey="UIGridViewColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="DisplayOrder" HeaderText="Display Order" meta:resourceKey="UIGridViewColumnResource3"
                                PropertyName="DisplayOrder" ResourceAssemblyName="" SortExpression="DisplayOrder">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ControlCaption" HeaderText="Control Caption"
                                meta:resourceKey="UIGridViewColumnResource4" PropertyName="ControlCaption" ResourceAssemblyName=""
                                SortExpression="ControlCaption">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ControlIdentifier" HeaderText="Control Identifier"
                                meta:resourceKey="UIGridViewColumnResource5" PropertyName="ControlIdentifier"
                                ResourceAssemblyName="" SortExpression="ControlIdentifier">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="ReportField_ObjectPanel" runat="server" meta:resourcekey="ReportField_ObjectPanelResource1"
                        BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="ReportField_SubPanel" GridViewID="ReportFields"
                            OnPopulateForm="ReportField_ObjectPanel_PopulateForm" OnRemoved="ReportField_SubPanel_Removed"
                            OnValidateAndUpdate="ReportField_SubPanel_ValidateAndUpdate"></web:subpanel>
                        <ui:UIFieldDropDownList ID="DisplayOrder" runat="server" Caption="Display Order"
                            PropertyName="DisplayOrder" Span="Half" ValidateRequiredField="True" ToolTip="The order of display of the search field. Lower appears first."
                            meta:resourcekey="DisplayOrderResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="ControlIdentifier" runat="server" Caption="Identifier" PropertyName="ControlIdentifier"
                            ValidateRequiredField="True" ToolTip="The identifier that can be used in the SQL query to perform a filter."
                            meta:resourcekey="ControlIdentifierResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="textControlCaption" Caption="Control Caption"
                            PropertyName="ControlCaption" ValidateRequiredField="True" InternalControlWidth="95%"
                            meta:resourcekey="textControlCaptionResource1" />
                        <ui:UIFieldDropDownList ID="ControlSpan" runat="server" Caption="Span" Span="Half"
                            PropertyName="ControlSpan" ToolTip="Indicates if the search field spans half the width of the form, or the full width."
                            meta:resourcekey="ControlSpanResource1">
                            <Items>
                                <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource11" Text="Half"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource12" Text="Full"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList ID="DataType" runat="server" Caption="Data Type" PropertyName="DataType"
                            Span="Half" ValidateRequiredField="True" ToolTip="The data type of the search field."
                            meta:resourcekey="DataTypeResource1">
                            <%--<Items>
                                <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource17" Text="String"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource18" Text="Integer"></asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource19" Text="Decimal"></asp:ListItem>
                                <asp:ListItem Value="3" meta:resourcekey="ListItemResource20" Text="Double"></asp:ListItem>
                                <asp:ListItem Value="4" meta:resourcekey="ListItemResource21" Text="DateTime"></asp:ListItem>
                                <asp:ListItem Value="5" meta:resourcekey="ListItemResource22" Text="Object Identifier"></asp:ListItem>
                            </Items>--%>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList ID="ControlType" runat="server" Caption="Control Type" PropertyName="ControlType"
                            Span="Half" ValidateRequiredField="True" OnSelectedIndexChanged="ControlType_SelectedIndexChanged"
                            ToolTip="The type of the control that the user inputs." meta:resourcekey="ControlTypeResource1">
                            <%--<Items>
                                <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource13" Text="TextBox"></asp:ListItem>
                                <asp:ListItem Value="4" Text="Date" meta:resourcekey="ListItemResource34"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource14" Text="DateTime"></asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource15" Text="DropDownList"></asp:ListItem>
                                <asp:ListItem Value="3" meta:resourcekey="ListItemResource16" Text="RadioButtonList"></asp:ListItem>
                                <asp:ListItem Value="5" Text="MultiSelectList" ></asp:ListItem>
                                <asp:ListItem Value="6" Text="ContextTree" ></asp:ListItem>
                            </Items>--%>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList ID="ContextFilter" runat="server" Caption="Context Tree"
                            PropertyName="ContextTree" Span="Half" meta:resourcekey="ContextFilterResource1">
                            <%--<Items>
                                <asp:ListItem Value="10" Text="Account" ></asp:ListItem>
                                <asp:ListItem Value="11" Text="Inventory Catalog" ></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Checklist"></asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" Text="Code"></asp:ListItem>
                                <asp:ListItem Value="3" meta:resourcekey="ListItemResource4" Text="CodeType"></asp:ListItem>
                                <asp:ListItem Value="4" meta:resourcekey="ListItemResource5" Text="Equipment"></asp:ListItem>
                                <asp:ListItem Value="5" meta:resourcekey="ListItemResource6" Text="EquipmentType"></asp:ListItem>
                                <asp:ListItem Value="6" meta:resourcekey="ListItemResource7" Text="Location"></asp:ListItem>
                                <asp:ListItem Value="7" meta:resourcekey="ListItemResource8" Text="LocationType"></asp:ListItem>
                                <asp:ListItem Value="8" meta:resourcekey="ListItemResource9" Text="Location and Equipment"></asp:ListItem>
                                <asp:ListItem Value="9" meta:resourcekey="ListItemResource10" Text="Service Catalog"></asp:ListItem>
                            </Items>--%>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldListBox runat="server" ID="CascadeControlID" PropertyName="CascadeControl"
                            Caption="Cascading Control" ToolTip="Indicates the dropdown list control that is updated if this dropdown list changes."
                            meta:resourcekey="CascadeControlIDResource1" AjaxPostBack="False" IsModifiedByAjax="False"></ui:UIFieldListBox>
                        <ui:UIFieldCheckBox runat="server" ID="checkIsRequiredField" PropertyName="IsRequiredField"
                            Caption="Is Required" Text="Yes, the user must enter a value or select an item before performing the search."
                            meta:resourcekey="checkIsRequiredFieldResource1" TextAlign="Right">
                        </ui:UIFieldCheckBox>
                        <ui:UIFieldCheckBox runat="server" ID="checkIsInsertBlank" Caption="Insert Blank?" 
                            Text="Yes, insert blank row to the dropdown list" PropertyName="IsInsertBlank" Span="Full">
                        </ui:UIFieldCheckBox>
                        <ui:UIFieldTextBox runat="server" ID="textHint" PropertyName="ControlHint" Caption="Hint" 
                            ToolTip="The hint to display on this control of the report." Span="Full" MaxLength="1000">
                        </ui:UIFieldTextBox>
                        <br />
                        <ui:UIPanel ID="panelListQuery" runat="server" meta:resourcekey="panelListQueryResource1"
                            BorderStyle="NotSet">
                            <ui:UISeparator runat="server" ID="sep1" Caption="List Query" meta:resourcekey="sep1Resource1" />
                            <ui:UIFieldRadioList ID="IsPopulatedByQuery" runat="server" Caption="Populate with Query?"
                                PropertyName="IsPopulatedByQuery" ToolTip="Indicates if the dropdown list should be populated with a query, or populated with a list of comma-separated values."
                                meta:resourcekey="IsPopulatedByQueryResource1" OnSelectedIndexChanged="IsPopulatedByQuery_SelectedIndexChanged"
                                TextAlign="Right">
                                <Items>
                                    <asp:listItem value="0" meta:resourcekey="ListItemResource27" Text="Populate with a List of Comma-separated values"></asp:listItem>
                                    <asp:listItem value="1" meta:resourcekey="ListItemResource28" Text="Populate with a query"></asp:listItem>
                                    <asp:listItem value="2" meta:resourcekey="ListItemResource29" Text="Populate with a C# Method"></asp:listItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldTextBox runat="server" ID="ReportFieldCMethod" ValidateRequiredField="True"
                                Caption="C# Method" PropertyName="CSharpMethodName" InternalControlWidth="95%"
                                meta:resourcekey="ReportFieldCMethodResource1" />
                            <br />
                            <br />
                            <br />
                            <ui:UIPanel ID="panelNotPopulatedByQuery" runat="server" meta:resourcekey="panelNotPopulatedByQueryResource1"
                                BorderStyle="NotSet">
                                <ui:UIFieldTextBox ID="TextList" runat="server" Caption="Text List" PropertyName="TextList"
                                    ValidateRequiredField="True" ToolTip="A comma separated list of text that will appear to the user for selection"
                                    MaxLength="0" meta:resourcekey="TextListResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox ID="ValueList" PropertyName="ValueList" runat="server" Caption="Value List"
                                    ToolTip="The comma separated list of values that corresponds to the text list."
                                    MaxLength="0" ValidateRequiredField="True" meta:resourcekey="ValueListResource1"
                                    InternalControlWidth="95%" />
                            </ui:UIPanel>
                            <ui:UIPanel ID="panelPopulatedByQuery" runat="server" meta:resourcekey="panelPopulatedByQueryResource1"
                                BorderStyle="NotSet">
                                <ui:UIFieldTextBox ID="ListQuery" runat="server" Caption="List SQL" PropertyName="ListQuery"
                                    Rows="15" TextMode="MultiLine" ValidateRequiredField="True" MaxLength="0" ToolTip="The query in SQL that is used to populate the dropdown list. The default {TreeviewID}, {TreeviewObject}, {UserID} are default fields available for the SQL query."
                                    meta:resourcekey="ListQueryResource2" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox ID="DataValueField" runat="server" Caption="Data Value Field"
                                    PropertyName="DataValueField" ValidateRequiredField="True" Span="Half" ToolTip="The column of the result of the query that will be displayed to the user."
                                    meta:resourcekey="DataValueFieldResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox ID="DataTextField" runat="server" Caption="Data Text Field" PropertyName="DataTextField"
                                    ValidateRequiredField="True" Span="Half" ToolTip="The column of the result of the query that will be used as a value in the dashboard query."
                                    meta:resourcekey="DataTextFieldResource1" InternalControlWidth="95%" />
                            </ui:UIPanel>
                            <ui:UIFieldTextBox ID="UIFieldTextBox4" runat="server" PropertyName="ResourceName"
                                Caption="Resource Name" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox2Resource1" />
                            <ui:UIFieldTextBox ID="UIFieldTextBox5" runat="server" PropertyName="ResourceAssemblyName"
                                Caption="Resource Assembly Name" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox3Resource1" />
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                    <ui:UIPanel runat="server" ID="panelReportDataSet" meta:resourcekey="panelReportDataSetResource1"
                        BorderStyle="NotSet">
                        <br />
                        <ui:UISeparator runat="server" ID="reportDsSep" Width="100%" meta:resourcekey="reportDsSepResource1" />
                        <ui:UIGridView runat="server" ID="ReportParamOrder" Caption="Report Field Order"
                            PropertyName="ReportDataSet" BindObjectsToRows="True" KeyName="ObjectID" Width="100%"
                            meta:resourcekey="ReportParamOrderResource1" PagingEnabled="True" DataKeyNames="ObjectID"
                            GridLines="Both" RowErrorColor="" style="clear: both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="DataSetName" HeaderText="DataSet" meta:resourceKey="UIGridViewColumnResource6"
                                    PropertyName="DataSetName" ResourceAssemblyName="" SortExpression="DataSetName">
                                    <HeaderStyle HorizontalAlign="Left" Width="20%" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Query" HeaderText="Query" meta:resourceKey="UIGridViewColumnResource7"
                                    PropertyName="Query" ResourceAssemblyName="" SortExpression="Query">
                                    <HeaderStyle HorizontalAlign="Left" Width="50%" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Field Order" meta:resourceKey="UIGridViewColumnResource8">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="Reading" runat="server" CaptionWidth="1px" InternalControlWidth="95%"
                                            meta:resourceKey="ReadingResource1" PropertyName="ParameterOrder" TextMode="MultiLine">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" Width="30%" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="ReportParamOrder_ObjectPanel" meta:resourcekey="ReportParamOrder_ObjectPanelResource1"
                            BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="ReportParamOrder_Subpanel1" GridViewID="ReportParamOrder">
                            </web:subpanel>
                        </ui:UIObjectPanel>
                        <!--end of report param order panel-->
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView Caption="Report Type" CssClass="div-form" runat="server" ID="UiTabTemplate"
                    BorderStyle="NotSet" meta:resourcekey="UiTabTemplateResource1">
                    <ui:UIFieldDropDownList ID="ReportType" Span="Half" runat="server" Caption="Report Type"
                        PropertyName="ReportType" ToolTip="Specify type of report, either dynamic (drag and drop report) or static (using report template rdl/rdlc file)"
                        meta:resourcekey="IsDynamicReportResource1" OnSelectedIndexChanged="ReportType_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Selected="True" Value="1" Text="Spreadsheet Report or Static Template Report"
                                meta:resourcekey="ListItemResource23"></asp:ListItem>
                            <asp:ListItem Value="0" Text="Report Definition Language with Embedded Query" meta:resourcekey="ListItemResource24"></asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="VisibleColumnAtStart" PropertyName="VisibleColumnAtStart"
                        Caption="No. of Visible Column" ValidateDataTypeCheck="True" ValidationDataType="Integer"
                        Span="Half" ValidateRangeField="True" ValidationRangeMin="1" ValidationRangeType="Integer"
                        InternalControlWidth="95%" meta:resourcekey="VisibleColumnAtStartResource1" />
                    <br />
                    <br />
                    <ui:UIGridView ID="gridRDLTemplate" runat="server" Caption="Report Template" KeyName="ObjectID"
                        Width="100%" AjaxPostBack="False" IsModifiedByAjax="False" PagingEnabled="True"
                        OnAction="gridRDLTemplate_Action" OnRowDataBound="gridRDLTemplate_RowDataBound"
                        DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridRDLTemplateResource1"
                        RowErrorColor="" style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteTemplate"
                                CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource3" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddTemplate"
                                CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource4" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditTemplate" ImageUrl="~/images/edit.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource1">
                                <controlstyle width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteTemplate" ConfirmText="Are you sure you wish to delete the selected item?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                <controlstyle width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Template Name" meta:resourcekey="UIGridViewBoundColumnResource1"
                                PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TemplateType" HeaderText="Template Type" meta:resourcekey="UIGridViewBoundColumnResource2"
                                PropertyName="TemplateType" ResourceAssemblyName="" SortExpression="TemplateType">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="File Name" meta:resourcekey="UIGridViewBoundColumnResource3"
                                PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" DataFormatString="{0:dd/MMM/yyyy HH:mm:ss}"
                                HeaderText="Created Date" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="CreatedDateTime"
                                ResourceAssemblyName="" SortExpression="CreatedDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewButtonColumn CommandName="Download" meta:resourcekey="UIGridViewButtonColumnResource3"
                                ImageUrl="~/images/download.png"
                                Text="Download Template" ButtonType="Image">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="panel_RDLTemplate" runat="server" Visible="False" BorderStyle="NotSet"
                        meta:resourcekey="panel_RDLTemplateResource1">
                        <web:subpanel runat="server" ID="RDLTemplate_Subpanel" GridViewID="gridRDLTemplate">
                        </web:subpanel>
                        <table border="0" cellpadding="0" cellspacing="0" width="99%">
                            <tr>
                                <td class='subobject-buttons'>
                                    <ui:UIPanel ID="panel_RDLTEmplateSub" runat="server" BorderStyle="NotSet" meta:resourcekey="panel_RDLTEmplateSubResource1">
                                        <ui:UIButton ID="buttonUpdateTemplate" runat="server" ImageUrl="~/images/symbol-check-big.gif"
                                            Text="Update" OnClick="buttonUpdateTemplate_Click" meta:resourcekey="buttonUpdateTemplateResource1" />
                                        <span id="spanCancel" runat="server">
                                            <ui:UIButton ID="buttonCancelTemplate" runat="server" ImageUrl="~/images/Delete-big.png"
                                                Text="Cancel" OnClick="buttonCancelTemplate_Click" meta:resourcekey="buttonCancelTemplateResource1" />
                                        </span>
                                    </ui:UIPanel>
                                </td>
                            </tr>
                        </table>
                        <div class='subobject-panel'>
                            <br />
                            <ui:UIFieldTextBox runat="server" Caption="Template Name" ID="TemplateName" MaxLength="255"
                                ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="TemplateNameResource1" />
                            <ui:UIFieldRadioList runat="server" ID="TemplateType" Caption="Template Type" ValidateRequiredField="True"
                                meta:resourcekey="TemplateTypeResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" Text="Report Definition Language" Selected="True" meta:resourcekey="ListItemResource30"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Crystal Reports" meta:resourcekey="ListItemResource31"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldLabel runat="server" ID="TemplateUpdateMode" Visible="False" DataFormatString=""
                                meta:resourcekey="TemplateUpdateModeResource1" />
                            <ui:UIFieldInputFile runat="server" Caption="Upload Template" ID="TemplateUpload"
                                ValidateRequiredField="True" meta:resourcekey="TemplateUploadResource1" />
                            <ui:UIFieldLabel runat="server" ID="TemplateFileName" Caption="File Name" Visible="False"
                                DataFormatString="" meta:resourcekey="TemplateFileNameResource1">
                            </ui:UIFieldLabel>
                            <br />
                            <br />
                        </div>
                    </ui:UIObjectPanel>
                    <ui:UIPanel runat="server" ID="panel_StaticReportFile" Visible="False" meta:resourcekey="panelStaticResource1"
                        BorderStyle="NotSet">
                        <ui:UIFieldInputFile ID="RdlInputFile" runat="server" Caption="Upload Template" ToolTip="The rdl template to be used for report display"
                            meta:resourcekey="RdlInputFileResource1" />
                        <table cellpadding="0" width="100%">
                            <tr>
                                <td style="width: 124px">
                                </td>
                                <td>
                                    <ui:UIButton runat="server" Text="Upload File" ID="buttonUpload" OnClick="buttonUpload_Click"
                                        ImageUrl="~/images/document-attach.gif" meta:resourcekey="buttonUploadResource1" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <hr />
                                </td>
                            </tr>
                        </table>
                        <br />
                        <table width="100%">
                            <tr height="30px">
                                <td width="120px">
                                    <asp:Label ID="lblRdlFilename" runat="server" meta:resourcekey="lblRdlFilenameResource1"
                                        Text="Report Template File:"></asp:Label>
                                </td>
                                <td width="30%">
                                    <asp:Label ID="ReportFileName" runat="server" meta:resourcekey="RdlFilenameResource2"></asp:Label>
                                </td>
                                <td>
                                    <ui:UIButton runat="server" Visible="False" Text="Download File" ImageUrl="~/images/icon-savesmall.gif"
                                        ID="buttonDownload" OnClick="buttonDownload_Click" meta:resourcekey="buttonDownloadResource1" />
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabQuery" Caption="Query" BorderStyle="NotSet" meta:resourcekey="tabQueryResource1" OnClick="tabQuery_Click">
                    <ui:UIPanel runat="server" ID="panelCSharp" BorderStyle="NotSet" meta:resourcekey="panelCSharpResource1">
                        <ui:UIFieldRadioList runat="server" ID="UseCSharpQuery" PropertyName="UseCSharpQuery"
                            Caption="Use C#" RepeatColumns="0" OnSelectedIndexChanged="UseCSharpQuery_SelectedIndexChanged"
                            meta:resourcekey="UseCSharpQueryResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource32" Text="No"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource33" Text="Yes"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTextBox runat="server" ID="CSharpMethodName" PropertyName="CSharpMethodName"
                            ValidateRequiredField="True" ToolTip="Enter the C# method name in the LogicLayer.Reports class that is to be called to generate the report."
                            Caption="C# Method Name" InternalControlWidth="95%" meta:resourcekey="CSharpMethodNameResource1">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelStatic" Visible="False" meta:resourcekey="panelStaticResource1"
                        BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelODbcConvert" Visible="False" meta:resourcekey="panelODbcConvertResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldCheckBox ID="OdbcSyntax" runat="server" Caption="Using Odbc Syntax" Span="Half"
                                PropertyName="OdbcSyntax" Text="Yes, read queries in Odbc format" ToolTip="If this is checked, all queries of the report will be converted into ODBC syntax format"
                                meta:resourcekey="OdbcSyntaxResource1" TextAlign="Right" />
                            <ui:UIFieldDropDownList ID="paramPrefix" runat="server" Caption="Parameter Prefix"
                                Span="Half" PropertyName="ParamPrefix" ToolTip="Prefix that is used for parameters in the queries of the report"
                                meta:resourcekey="paramPrefixResource1">
                                <Items>
                                    <asp:ListItem Selected="True" Value="@" meta:resourcekey="ListItemResource25" Text="@"></asp:ListItem>
                                    <asp:ListItem Selected="True" Value=":" meta:resourcekey="ListItemResource26" Text=":"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <!--end of static report panel-->
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelDynamic" meta:resourcekey="panelDynamicResource1"
                        BorderStyle="NotSet">
                        <ui:UIFieldTextBox ID="ReportQuery" runat="server" Caption="Report SQL" PropertyName="ReportQuery"
                            Rows="30" TextMode="MultiLine" ValidateRequiredField="True" MaxLength="0" meta:resourcekey="ReportQueryResource1"
                            InternalControlWidth="95%" />
                        <ui:uihint runat="server" id="hintReport" meta:resourcekey="hintReportResource1"
                            Text="">
                            The query in SQL that is used to populate the report. 
                            {UserID}, {ReportID} are default fields available for the SQL query. 
                            <br />
                            <br />
                            {TreeViewID} is also available for the SQL query, if you have selected the 'Top Context Tree'.
                            <br />
                            <br />
                            Note: You can preview your report in the 'Preview' tab.
            
                        </ui:uihint>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" Caption="Results" ID="uitabview7" BorderStyle="NotSet"
                    meta:resourcekey="uitabview7Resource1">
                    <ui:UIGridView ID="gv_ColumnMapping" runat="server" PropertyName="ReportColumnMappings"
                        Caption="Report Column Mappings" SortExpression="DisplayOrder" KeyName="ObjectID"
                        Width="100%" PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gv_ColumnMappingResource1"
                        RowErrorColor="" style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource5" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource6" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourceKey="UIGridViewColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ImageUrl="~/images/delete.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ColumnName" HeaderText="Column Name" meta:resourcekey="UIGridViewBoundColumnResource5"
                                PropertyName="ColumnName" ResourceAssemblyName="" SortExpression="ColumnName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="DataFormatString" HeaderText="Data Format String"
                                meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="DataFormatString"
                                ResourceAssemblyName="" SortExpression="DataFormatString">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="HeaderText" HeaderText="Header Text" meta:resourcekey="UIGridViewBoundColumnResource7"
                                PropertyName="HeaderText" ResourceAssemblyName="" SortExpression="HeaderText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ResourceName" HeaderText="Resource Name" meta:resourcekey="UIGridViewBoundColumnResource8"
                                PropertyName="ResourceName" ResourceAssemblyName="" SortExpression="ResourceName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ResourceAssemblyName" HeaderText="ResourceAssemblyName"
                                meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="ResourceAssemblyName"
                                ResourceAssemblyName="" SortExpression="ResourceAssemblyName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="ReportColumnMappings_ObjectPanel" runat="server" BorderStyle="NotSet"
                        meta:resourcekey="ReportColumnMappings_ObjectPanelResource1">
                        <web:subpanel runat="server" ID="ReportColumnMappings_SubPanel" GridViewID="gv_ColumnMapping"
                            OnPopulateForm="ReportColumnMappings_SubPanel_PopulateForm" OnValidateAndUpdate="ReportColumnMappings_SubPanel_ValidateAndUpdate">
                        </web:subpanel>
                        <ui:UIFieldTextBox ID="ColumnName" PropertyName="ColumnName" runat="server" Caption="Column Name"
                            ValidaterequiredField="True" InternalControlWidth="95%" meta:resourcekey="ColumnNameResource1" />
                        <ui:UIFieldTextBox ID="UIFieldTextBox1" runat="server" PropertyName="DataFormatString"
                            Caption="Data Format String" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="textHeaderText" Caption="Header Text" PropertyName="HeaderText"
                            ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="textHeaderTextResource1" />
                        <ui:UIFieldTextBox ID="UIFieldTextBox2" runat="server" PropertyName="ResourceName"
                            Caption="Resource Name" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox2Resource1" />
                        <ui:UIFieldTextBox ID="UIFieldTextBox3" runat="server" PropertyName="ResourceAssemblyName"
                            Caption="Resource Assembly Name" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox3Resource1" />
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="UITabView5" Caption="Access" meta:resourcekey="UITabView5Resource1"
                    BorderStyle="NotSet">
                    <ui:UIFieldCheckboxList runat="server" ID="ReportRoles" PropertyName="Roles" Caption="Roles"
                        ValidateRequiredField="True" ToolTip="Indicates the roles that have access to view this report."
                        meta:resourcekey="ReportRolesResource1" DataTextField="" DataValueField="" TextAlign="Right">
                    </ui:UIFieldCheckboxList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabPreview" Caption="Preview" meta:resourcekey="tabPreviewResource1"
                    BorderStyle="NotSet">
                    <iframe runat="server" src="about::blank" width="100%" height="500px" id="frameBottom"
                        style="border: solid 1px silver" name="frameBottom"></iframe>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1"
                    BorderStyle="NotSet">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments" meta:resourcekey="uitabview2Resource1"
                    BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
