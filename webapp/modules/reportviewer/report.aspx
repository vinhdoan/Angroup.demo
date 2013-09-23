<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" MaintainScrollPositionOnPostback="true" culture="auto" meta:resourcekey="PageResource2" uiculture="auto" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Resources" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    Hashtable reportColumnMappings = new Hashtable();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            OReport report = TablesLogic.tReport.Load((Guid)Session["ReportID"]);
            foreach (OReportColumnMapping reportColumnMapping in report.ReportColumnMappings)
                reportColumnMappings[reportColumnMapping.ColumnName] = reportColumnMapping;
            
            // Removes the drag drop report chart from the disk everytime
            // a new report is generated.
            //
            DiskCache.Remove("DragDropReportChart");
            
            //Rachel. Set visible column at start based on the report setting
            if (Request["VisibleColumnAtStart"] != null)
                ReportObject.VisibleColumnsAtStart = Convert.ToInt32(Security.Decrypt(Request["VisibleColumnAtStart"]).ToString());

            //must set the report datasource first before deserializing the report setting. 
            if (DiskCache.GetValue("ReportDataSourceType") == "DataTable")
            {
                if (DiskCache.ContainsKey("ReportDataSource"))
                {
                    DataTable dt = DiskCache.GetDataTable("ReportDataSource");
                    int totalColumns = dt.Columns.Count;
                    for (int i = 0; i < totalColumns; i++)
                    {
                        string clName = dt.Columns[i].ColumnName;
                        OReportColumnMapping column = reportColumnMappings[clName] as OReportColumnMapping;

                        if (column != null && dt.Columns[i].DataType == typeof(String)
                            && column.ResourceName != null && column.ResourceName.Trim() != "")
                        {
                            foreach (DataRow dr in dt.Rows)
                            {
                                string resourceAssemblyName = column.ResourceAssemblyName;
                                Assembly asm;
                                if (resourceAssemblyName.Trim() == "")
                                    asm = Assembly.Load("App_GlobalResources");
                                else
                                    asm = Assembly.Load(resourceAssemblyName);

                                if (asm != null)
                                {
                                    ResourceManager rm = new ResourceManager(column.ResourceName, asm);
                                    if (rm != null && dr[clName] != null && dr[clName].ToString() != "")
                                    {
                                        string a = dr[clName].ToString();
                                        string translatedText = rm.GetString(a, System.Threading.Thread.CurrentThread.CurrentUICulture);
                                        if (translatedText != null && translatedText != "")
                                            dr[clName] = translatedText;
                                    }
                                }
                            }
                        }
                    }

                    ReportObject.BindData(dt);
                }
            }

            if (Session["ReportCaption"] != null)
                ReportObject.ReportCaption = (string)Session["ReportCaption"];
           
            if (Session["ReportParametersDisplay"] != null)
                ReportObject.ReportParameters = (ArrayList)Session["ReportParametersDisplay"];

            ReportObject.ReportGeneratedBy = Audit.UserName;
            ReportObject.ReportGeneratedDate = DateTime.Now.ToString("dd-MMM-yyyy HH:mm");
            this.buttonCancel.Attributes.Add("onclick", "javascript:SetTemplatePanelVisibility(0); return false;");
            this.buttOnValidateAndSaveTemplate.Attributes.Add("onclick", "javascript:SetTemplatePanelVisibility(1); return false;");
            SetTemplatePanelDisplay();
        }

    }
    
    /// <summary>
    /// 
    /// </summary>
    protected void SetTemplatePanelDisplay()
    {
        //check whether the Template is editable by the current user
        if (Session["ReportTemplateID"] != null)
        {
            Guid templateID = new Guid(Session["ReportTemplateID"].ToString());
            if (OReportTemplate.IsEditableTemplate(templateID, (Guid)AppSession.User.ObjectID))
                this.buttOnValidateAndSave.Visible = true;
            else
                this.buttOnValidateAndSave.Visible = false;

            //populate the report column setting based on the report                
            OReportTemplate.DisplayReportTemplate(ReportObject, templateID);
            //populate template content
            OReportTemplate template = TablesLogic.tReportTemplate[templateID];
            this.TemplateName.Text = template.ObjectName;
            this.AccessControl.SelectedValue = template.AccessControl == null ? "" : template.AccessControl.ToString();
            this.TemplateDescription.Text = template.Description;

        }
        //new template
        else
            this.buttOnValidateAndSave.Visible = false;

        
        // Sets the header text of the individual columns if they have
        // a corresponding ReportColumnMapping object set up in 
        // the report page. This basically translates the column name
        // into the display text based on the user's current language
        // settings.
        //
        // If there is no mapping for that column, then we just use
        // the column name as the header text.
        // 
        OReport report = TablesLogic.tReport.Load((Guid)Session["ReportID"]);
        string id = Session["ReportID"].ToString();
        foreach (DragDropGridColumn col in ReportObject.Columns)
        {
            col.HeaderText = col.ColumnName;
            OReportColumnMapping mapping = reportColumnMappings[col.ColumnName] as OReportColumnMapping;
            if (mapping != null)
            {
                col.HeaderText = mapping.HeaderText;
                if (mapping.DataFormatString != null)
                    col.DataFormatString = mapping.DataFormatString;
            }
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        tableMessage.Visible = labelMessage.Text.Trim() != "";
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void SaveReportTemplate(object sender, EventArgs e)
    {
        try
        {
            //edit
            OReportTemplate template = TablesLogic.tReportTemplate[new Guid(Session["ReportTemplateID"].ToString())];
            BindToReportTemplateObject(template);
            template.ObjectName = this.TemplateName.Text;
            template.AccessControl = Convert.ToInt32(this.AccessControl.SelectedValue);
            template.Description = this.TemplateDescription.Text;
            template.ReportID = (Guid)Session["ReportID"];
            int validate = OReportTemplate.SaveTemplateObject(template, ReportObject);
            if (validate == 1)
                this.labelMessage.Text = Resources.Errors.General_NameDuplicate;
            else
                this.labelMessage.Text = Resources.Messages.General_ItemSaved;
            //refresh report object.
            SetTemplatePanelDisplay();
        }
        catch (Exception ex)
        {
            //throw ex;
        }
        panelSaveTemplate.Update();
    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="template"></param>
    protected void BindToReportTemplateObject(OReportTemplate template)
    {
        template.ObjectName = this.TemplateName.Text;
        template.AccessControl = Convert.ToInt32(this.AccessControl.SelectedValue);
        template.Description = this.TemplateDescription.Text;
        template.ReportID = (Guid)Session["ReportID"];
        if (template.IsNew)
            template.CreatorID = AppSession.User.ObjectID;
    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void SaveNewReportTemplate(object sender, EventArgs e)
    {
        try
        {
            OReportTemplate template = TablesLogic.tReportTemplate.Create();
            BindToReportTemplateObject(template);
            int validate = OReportTemplate.SaveTemplateObject(template, ReportObject);
            if (validate == 1)
                this.labelMessage.Text = Resources.Errors.General_NameDuplicate;
            else
            {
                //set the template sessionID to the new template ID
                Session["ReportTemplateID"] = template.ObjectID;
                //refresh report object
                SetTemplatePanelDisplay();
                this.labelMessage.Text = Resources.Messages.General_ItemSaved;
            }

            // 2010.11.24
            // Li Shan
            // Always show the template panel when the template is saved.
            //
            this.SavePanel.Style["display"] = "none";
            this.TemplatePanel.Style["display"] = "";
        }
        catch (Exception ex)
        {
            //throw ex;
        }
        panelSaveTemplate.Update();
    }


    protected void buttonCloseWindow_Click(object sender, EventArgs e)
    {
        Window.Close();
    }
</script>

<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body style="margin: 10px 10px 10px 10px">

    <script type='text/javascript'>
	    window.focus();
    </script>

    <form id="form2" runat="server">

        <script type='text/javascript'>
	        function SetTemplatePanelVisibility(vis)
	        {
	            document.getElementById('TemplatePanel').style.display = (vis ? '' : 'none');
	            document.getElementById('SavePanel').style.display = (vis ? 'none' : '');
	        }
        </script>

        <ui:UIPanel runat="server" ID="panel" BorderStyle="NotSet" 
            meta:resourcekey="panelResource1">
            <div id="SavePanel" runat="server">
                <asp:LinkButton ID="buttOnValidateAndSaveTemplate" runat="server" 
                    CausesValidation="False" 
                    meta:resourcekey="buttOnValidateAndSaveTemplateResource2">Click here to save this layout</asp:LinkButton>
                &nbsp;
                &nbsp;
                &nbsp;
                <ui:UIButton runat="server" ID="buttonCloseWindow" ImageUrl="~/images/window-delete-big.gif"
                    AlwaysEnabled="True" Text="Close Window" OnClick="buttonCloseWindow_Click" 
                    meta:resourcekey="buttonCloseWindowResource1">
                </ui:UIButton>
                <hr />
            </div>
            <div id="TemplatePanel" style="display: none" runat="server">
                <ui:UIPanel runat="server" ID="panelSaveTemplate" BorderStyle="NotSet" 
                    meta:resourcekey="panelSaveTemplateResource1">
                    <table width="100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td>
                                <ui:UIButton ID="buttOnValidateAndSave" runat="server" 
                                    OnClick="SaveReportTemplate" ConfirmText="Save changes?"
                                    Text="Save changes" ImageUrl="~/images/disk-big.gif" Visible="False" 
                                    meta:resourcekey="buttOnValidateAndSaveResource2" />
                                <ui:UIButton ID="buttOnValidateAndSaveNew" runat="server" 
                                    OnClick="SaveNewReportTemplate" Text="Save as new layout"
                                    ImageUrl="~/images/disksave-big.gif" 
                                    meta:resourcekey="buttOnValidateAndSaveNewResource2" />
                                <asp:LinkButton ID="buttonCancel" runat="server" CausesValidation="False" 
                                    meta:resourcekey="buttonCancelResource2"><img align="absmiddle" src="../../images/Window-Delete-big.gif" alt="Close" style="border:none; " />Close Layout Panel</asp:LinkButton>
                            </td>
                        </tr>
                        <tr height="10px">
                            <td>
                                <hr />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table border="0" cellpadding="0" cellspacing="0" width="100%" runat="server" id="tableMessage">
                                    <tr runat="server">
                                        <td runat="server">
                                            <div class='object-message' style="width: 100%">
                                                <asp:Label runat='server' ID='labelMessage' ForeColor="Red" Font-Bold="True" meta:resourcekey="labelMessageResource1"></asp:Label>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr height="10px" runat="server">
                                        <td runat="server">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div class="div-form-short">
                                    <ui:UIFieldTextBox runat="server" ID="TemplateName" ValidateRequiredField="True"
                                        Caption="Layout Name" ToolTip="Name of the report layout" 
                                        InternalControlWidth="95%" meta:resourcekey="TemplateNameResource2">
                                    </ui:UIFieldTextBox>
                                    <ui:UIFieldTextBox runat="server" ID="TemplateDescription" Caption="Description"
                                        Rows="2" TextMode="MultiLine" ToolTip="Description of the report layout" 
                                        InternalControlWidth="95%" meta:resourcekey="TemplateDescriptionResource2">
                                    </ui:UIFieldTextBox>
                                    <ui:UIFieldRadioList runat="server" ID="AccessControl" Caption="Access Control"
                                        RepeatDirection="Vertical" 
                                        ToolTip="Set whether the layout could be edited by other users or just by the layout creator" 
                                        meta:resourcekey="AccessControlResource2" TextAlign="Right">
                                        <Items>
                                            <asp:ListItem value="1" Selected="True" meta:resourcekey="ListItemResource4">Editable by all users</asp:ListItem>
                                            <asp:ListItem value="2" meta:resourcekey="ListItemResource5">Editable by me and viewable by all users</asp:ListItem>
                                            <asp:ListItem value="3" meta:resourcekey="ListItemResource6">Editable and viewable by me only</asp:ListItem>
                                        </Items>
                                    </ui:UIFieldRadioList>
                                </div>
                            </td>
                        </tr>
                    </table>
                </ui:UIPanel>
            </div>
            <br />
            <ui:UIDragDropGrid ID="ReportObject" runat="server" ImagePath="../../images/" 
                ChartVirtualPath="~/components/chartdisplay.aspx" 
                ChartTypeNames="Pie (Multiple);Pie (Nest);Donuts;Gauge;Bar (Vertical);Bar (Vertical Stacked); Bar (Vertical Fully Stacked);Bar (Horizontal); Bar (Horizontal Stacked);Bar (Horizontal Fully Stacked);Radar (Spider);Radar (Spider Stacked);Radar (Spider Fully Stacked);Radar (Polar);Radar (Polar Stacked);Radar (Polar Fully Stacked)" 
                ChartTypeValues="Pie:Pies;Pie:PiesNested;Pie:Donuts;Gauge;Basic:Vertical;Basic:Vertical:Stacked;Basic:Vertical:FullStacked;Basic:Horizontal;Basic:Horizontal:Stacked;Basic:Horizontal:FullStacked;Radar:Spider;Radar:Spider:Stacked;Radar:Spider:FullStacked;Radar:Polar;Radar:Polar:Stacked;Radar:Polar:FullStacked" 
                ChartView="False" 
                DisplayChartType="" GridChartView="False" 
                meta:resourcekey="ReportObjectResource2" ></ui:UIDragDropGrid>
        </ui:UIPanel>
        <script src='scripts/boxover.js' type='text/javascript'></script>
    </form>
</body>
</html>
