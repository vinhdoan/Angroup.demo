<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource2" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        dropObjectTypeName.Bind(OWorkflowRepository.GetAllWorkflowRepositories(), "ObjectTypeName", "ObjectTypeName", true);
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }

        panelAutoUpload.Visible = Page.Request.Url.AbsoluteUri.StartsWith("http://localhost");
        textLocalFolder.Text = Page.Request.PhysicalApplicationPath;
    }


    /// <summary>
    /// Gets the file bytes from the PostedFile property
    /// of the HttpInputFile control and converts it into
    /// a string of Unicode text.
    /// </summary>
    /// <param name="postedFile"></param>
    /// <returns></returns>
    protected string GetFileText(Stream stream)
    {
        if (stream == null || stream.Length == 0)
            return null;

        byte[] buffer = new byte[stream.Length];

        stream.Position = 0;
        stream.Read(buffer, 0, (int)stream.Length);

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
    protected string GetWorkflowFileText(Stream stream)
    {
        string workflowTextFile = GetFileText(stream);

        return Regex.Replace(workflowTextFile, @"x:Class=""[a-zA-Z\._]*""", "");
    }


    /// <summary>
    /// Automatically upload all workflow files from the given folder.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAutoUpload_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        StringBuilder sb = new StringBuilder();
        string[] filenames = System.IO.Directory.GetFiles(textLocalFolder.Text, "*.xoml");

        foreach (string filename in filenames)
        {
            using (Connection c = new Connection())
            {
                string workflowName = Path.GetFileNameWithoutExtension(filename);
                string typeName = workflowName.Replace("Workflow", "");
                if (!workflowName.StartsWith("O"))
                    continue;

                OWorkflowRepository workflowRepository = TablesWorkflow.tWorkflowRepository.Load(
                    TablesWorkflow.tWorkflowRepository.ObjectTypeName == typeName);
                if (workflowRepository == null)
                {
                    workflowRepository = TablesWorkflow.tWorkflowRepository.Create();
                    workflowRepository.ObjectTypeName = typeName;
                    workflowRepository.Save();
                }


                try
                {
                    string ruleFilename = filename.Replace(".xoml", ".rules");

                    FileStream fs1 = new FileStream(filename, FileMode.Open, FileAccess.Read);
                    FileStream fs2 = null;
                    if (File.Exists(ruleFilename))
                        fs2 = new FileStream(ruleFilename, FileMode.Open, FileAccess.Read);

                    try
                    {
                        // Validate the workflow
                        //
                        if (WorkflowEngine.Engine is WindowsWorkflowEngine)
                        {
                            string workflowFileText = GetWorkflowFileText(fs1);
                            string rulesFileText = GetFileText(fs2);

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

                                    sb.Append(typeName + ": " + String.Format(Resources.Errors.WorkflowRepositry_WorkflowValidationError, error) + "<br/>");
                                    continue;
                                }
                            }
                            catch (Exception ex)
                            {
                                sb.Append(typeName + ": " + ex.Message + "<br/>");
                                continue;
                            }
                        }
                        else
                        {
                            sb.Append(typeName + ": " + Resources.Errors.WorkflowRepository_UnableToValidateWorkflow + "<br/>");
                            continue;
                        }

                        OWorkflowRepositoryVersion version = TablesWorkflow.tWorkflowRepositoryVersion.Create();
                        version.WorkflowFile = GetWorkflowFileText(fs1);
                        version.RulesFile = GetFileText(fs2);
                        workflowRepository.WorkflowRepositoryVersions.Add(version);
                        workflowRepository.Save();
                        sb.Append(typeName + ": " + Resources.Messages.WorkflowRepository_UploadedSuccessfully + "<br/>");

                    }
                    catch (Exception ex)
                    {
                        sb.Append(typeName + ": " + ex.Message + "<br/>");
                        continue;
                    }
                    finally
                    {
                        if (fs1 != null)
                            fs1.Close();
                        if (fs2 != null)
                            fs2.Close();
                    }
                }
                catch (Exception ex)
                {
                    sb.Append(typeName + ": " + ex.Message + "<br/>");
                    continue;
                }

                c.Commit();
            }
        }

        panel.Message = sb.ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Workflow Repository" GridViewID="gridResults"
            BaseTable="TablesWorkflow.tWorkflowRepository" meta:resourcekey="panelResource1"
            
            OnPopulateForm="panel_PopulateForm" EditButtonVisible="false"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" BorderStyle="NotSet"
                    meta:resourcekey="uitabview3Resource2">
                    <ui:UIFieldDropDownList runat='server' ID="dropObjectTypeName" PropertyName="ObjectTypeName"
                        Caption="Object Type Name" meta:resourcekey="dropObjectTypeNameResource2">
                    </ui:UIFieldDropDownList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" BorderStyle="NotSet"
                    meta:resourcekey="uitabview4Resource2">
                    <ui:UIPanel runat="server" ID="panelAutoUpload" BorderStyle="NotSet" meta:resourcekey="panelAutoUploadResource1">
                        <ui:UIFieldTextBox runat="server" ID="textLocalFolder" Caption="Server Folder" MaxLength="255"
                            InternalControlWidth="95%" meta:resourcekey="textLocalFolderResource2">
                        </ui:UIFieldTextBox>
                        <table cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style='width: 120px'>
                                </td>
                                <td>
                                    <ui:UIButton runat="server" ID="buttonAutoUpload" Text="Automatically upload all workflow files"
                                        OnClick="buttonAutoUpload_Click" ImageUrl="~/images/upload.png" meta:resourcekey="buttonAutoUploadResource2" />
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="ObjectTypeName"
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridResultsResource1"
                        RowErrorColor="" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectTypeName" HeaderText="Object Type Name"
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="ObjectTypeName"
                                ResourceAssemblyName="" ResourceName="Resources.Objects" SortExpression="ObjectTypeName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ModifiedDateTime" HeaderText="Last uploaded Date Time"
                                DataFormatString="{0:dd-MMM-yyyy}" PropertyName="ModifiedDateTime" ResourceAssemblyName=""
                                ResourceName="" SortExpression="ModifiedDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
