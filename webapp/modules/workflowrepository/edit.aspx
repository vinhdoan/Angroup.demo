<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="Anacle.WorkflowFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        panel.RegisterPostBackControlForSaveButtons();
    }
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OWorkflowRepository workflowRepository = (OWorkflowRepository)panel.SessionObject;

        dropObjectTypeName.Bind(
            OFunction.GetObjectTypeNamesByImplementation(workflowRepository.ObjectTypeName, typeof(IWorkflowEnabled)), "ObjectTypeName", "ObjectTypeName");
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
        
        panel.ObjectPanel.BindObjectToControls(workflowRepository);
    }


    /// <summary>
    /// Gets the file bytes from the PostedFile property
    /// of the HttpInputFile control and converts it into
    /// a string of Unicode text.
    /// </summary>
    /// <param name="postedFile"></param>
    /// <returns></returns>
    protected string GetFileText(HttpPostedFile postedFile)
    {
        if (postedFile == null || postedFile.ContentLength == 0)
            return null;

        byte[] buffer = new byte[postedFile.ContentLength];

        postedFile.InputStream.Position = 0;
        postedFile.InputStream.Read(buffer, 0, postedFile.ContentLength);

        string s = Encoding.UTF8.GetString(buffer);
        return s;
    }


    /// <summary>
    /// Gets the file bytes from the PostedFile property
    /// of the HttpInputFile control and converts it into
    /// a string of Unicode text. Additionally, this also
    /// converts the 
    /// </summary>
    /// <param name="postedFile"></param>
    /// <returns></returns>
    protected string GetWorkflowFileText(HttpPostedFile postedFile)
    {
        string workflowTextFile = GetFileText(postedFile);

        return Regex.Replace(workflowTextFile, @"x:Class=""[a-zA-Z\._]*""", "");
    }
    
    
    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OWorkflowRepository workflowRepository = (OWorkflowRepository)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(workflowRepository);

            // Validate
            //
            if (!workflowRepository.ValidateNoDuplicateObjectType())
                dropObjectTypeName.ErrorMessage = Resources.Errors.WorkflowRepository_DuplicateObjectType;
            if (fileWorkflow.PostedFile.FileName != "" && !fileWorkflow.PostedFile.FileName.EndsWith(".xoml"))
                fileWorkflow.ErrorMessage = String.Format(Resources.Errors.WorkflowRepository_ExtensionInvalid, ".xoml");
            if (fileRules.PostedFile.FileName != "" && !fileRules.PostedFile.FileName.EndsWith(".rules"))
                fileRules.ErrorMessage = String.Format(Resources.Errors.WorkflowRepository_ExtensionInvalid, ".rules");
            if (fileLayout.PostedFile.FileName != "" && !fileLayout.PostedFile.FileName.EndsWith(".layout"))
                fileLayout.ErrorMessage = String.Format(Resources.Errors.WorkflowRepository_ExtensionInvalid, ".layout");

            // Validate the workflow
            //
            if (WorkflowEngine.Engine is WindowsWorkflowEngine)
            {
                string workflowFileText = GetWorkflowFileText(fileWorkflow.PostedFile);
                string rulesFileText = GetFileText(fileRules.PostedFile);

                try
                {
                    ((WindowsWorkflowEngine)WorkflowEngine.Engine).ValidateWorkflow(
                        workflowFileText, rulesFileText);
                }
                catch (System.Workflow.ComponentModel.Compiler.WorkflowValidationFailedException ex)
                {
                    if (ex is System.Workflow.ComponentModel.Compiler.WorkflowValidationFailedException)
                    {
                        string error = "";
                        error = ex.Message + "<br/>";
                        if (((System.Workflow.ComponentModel.Compiler.WorkflowValidationFailedException)ex).Errors != null)
                            foreach (System.Workflow.ComponentModel.Compiler.ValidationError validationError in
                                ((System.Workflow.ComponentModel.Compiler.WorkflowValidationFailedException)ex).Errors)
                                error += "<br/>" + validationError.ErrorText;

                        fileWorkflow.ErrorMessage = String.Format(Resources.Errors.WorkflowRepositry_WorkflowValidationError, error);
                        fileRules.ErrorMessage = String.Format(Resources.Errors.WorkflowRepositry_WorkflowValidationError, error);
                    }
                }
                catch (Exception ex)
                {
                    fileWorkflow.ErrorMessage = ex.Message;
                    fileRules.ErrorMessage = ex.Message;
                }
            }
            else
            {
                fileWorkflow.ErrorMessage = String.Format(Resources.Errors.WorkflowRepository_UnableToValidateWorkflow);
                fileRules.ErrorMessage = String.Format(Resources.Errors.WorkflowRepository_UnableToValidateWorkflow);
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            OWorkflowRepositoryVersion version = TablesWorkflow.tWorkflowRepositoryVersion.Create();
            version.WorkflowFile = GetWorkflowFileText(fileWorkflow.PostedFile);
            version.RulesFile = GetFileText(fileRules.PostedFile);
            version.LayoutFile = GetFileText(fileLayout.PostedFile);
            workflowRepository.WorkflowRepositoryVersions.Add(version);
            

            // Save
            //
            WindowsWorkflowEngine.InvalidWorkflowDefinitionCache();
            workflowRepository.Save();
            c.Commit();
        }
    }


    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        
        OWorkflowRepository workflowRepository = panel.SessionObject as OWorkflowRepository;
        dropObjectTypeName.Enabled = workflowRepository.IsNew;
    }


    /// <summary>
    /// Downloads the selected file to the user.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridVersions_Action(object sender, string commandName, List<object> dataKeys)
    {
        Guid versionId = (Guid)dataKeys[0];

        OWorkflowRepository workflowRepository = panel.SessionObject as OWorkflowRepository;
        OWorkflowRepositoryVersion workflowRepositoryVersion =
            workflowRepository.WorkflowRepositoryVersions.FindObject(versionId) as OWorkflowRepositoryVersion;

        if (workflowRepositoryVersion != null)
        {
            string fileName =
                workflowRepository.ObjectTypeName + "." +
                commandName.Replace("Download", "").ToLower();

            if (commandName == "DownloadXoml")
                Window.Download(workflowRepositoryVersion.WorkflowFile, fileName, "application/xml");
            else if (commandName == "DownloadRules")
                Window.Download(workflowRepositoryVersion.RulesFile, fileName, "application/xml");
            else if (commandName == "DownloadLayout")
                Window.Download(workflowRepositoryVersion.LayoutFile, fileName, "application/xml");
            panel.FocusWindow = false;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Workflow Repository" BaseTable="TablesWorkflow.tWorkflowRepository" SavingConfirmationText="Saving will publish the specified workflow files as the latest version, and all subsequent objects created will run using this new workflow. This change is not reversible.\n\nAre you sure you want to proceed?"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
            
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                    meta:resourcekey="tabObjectResource1" >
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNameVisible ="false" ObjectNumberVisible ="false">
                        </web:base>
                        <ui:UIFieldDropDownlist runat="server" ID="dropObjectTypeName" 
                            Caption="Object Type Name" PropertyName="ObjectTypeName" 
                            ValidateRequiredField="True" meta:resourcekey="dropObjectTypeNameResource1"></ui:UIFieldDropDownlist>
                        <br />
                        <br />
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" Caption="Workflow Files" 
                            meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldInputFile runat="server" ID="fileWorkflow" Caption=".xoml" 
                            ValidateRequiredField="True" meta:resourcekey="fileWorkflowResource1"></ui:UIFieldInputFile>
                        <ui:UIFieldInputFile runat="server" ID="fileRules" Caption=".rules" 
                            meta:resourcekey="fileRulesResource1" ></ui:UIFieldInputFile>
                             <ui:UIFieldInputFile runat="server" ID="fileLayout" Caption=".layout" ValidateRequiredField="true" 
                             ></ui:UIFieldInputFile>
                        <br />
                        <br />
                        <asp:Image runat='server' ID="imageInfo" ImageUrl="~/images/information.png" 
                            meta:resourcekey="imageInfoResource1" /> 
                        <asp:Label runat="server" ID="labelInfo" 
                            Text="Select the workflow files and click the Save above to upload and publish them as the latest version." 
                            meta:resourcekey="labelInfoResource1"></asp:Label>
                        <br />
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridVersions" 
                            PropertyName="WorkflowRepositoryVersions" CheckBoxColumnVisible="False" 
                            Caption="Workflow Versions" OnAction="gridVersions_Action" 
                            SortExpression="WorkflowVersionNumber" DataKeyNames="ObjectID" GridLines="Both" 
                            ImageRowErrorUrl="" meta:resourcekey="gridVersionsResource1" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="WorkflowVersionNumber" 
                                    HeaderText="Version" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="WorkflowVersionNumber" ResourceAssemblyName="" 
                                    SortExpression="WorkflowVersionNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedUser" HeaderText="Uploaded By" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="CreatedUser" 
                                    ResourceAssemblyName="" SortExpression="CreatedUser">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" 
                                    DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Uploaded Date/Time" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="CreatedDateTime" ResourceAssemblyName="" 
                                    SortExpression="CreatedDateTime">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Download Files" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIButton ID="buttonDownloadXoml" runat="server" CausesValidation="False" 
                                            CommandArgument="<%# ((GridViewRow)Container).RowIndex %>" 
                                            CommandName="DownloadXoml" meta:resourcekey="buttonDownloadXomlResource1" 
                                            Text=".xoml" />
                                        <cc1:UIButton ID="buttonDownloadRules" runat="server" CausesValidation="False" 
                                            CommandArgument="<%# ((GridViewRow)Container).RowIndex %>" 
                                            CommandName="DownloadRules" meta:resourcekey="buttonDownloadRulesResource1" 
                                            Text=".rules" />
                                            <cc1:UIButton ID="buttonDownloadLayout" runat="server" CausesValidation="False" 
                                            CommandArgument="<%# ((GridViewRow)Container).RowIndex %>" 
                                            CommandName="DownloadLayout" meta:resourcekey="buttonDownloadLayoutResource1" 
                                            Text=".layout" />
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" 
                        meta:resourcekey="tabMemoResource1" BorderStyle="NotSet">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
