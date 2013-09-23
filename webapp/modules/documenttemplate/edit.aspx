<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.IO" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>

<script runat="server">
    /// <summary>
    /// Tells the ASP.NET AJAX engine to perform a full
    /// postback when uploading files.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        // Register the buttonUpload button to force a full
        // postback whenever a file is uploaded.
        //
        if (Page is UIPageBase)
        {
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttonUpload);
        }
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        ODocumentTemplate doctemp = panel.SessionObject as ODocumentTemplate;
        
        dropObjectTypeName.Bind(OFunction.GetAllFunctionsWithObjectTypes(), "ObjectTypeName", "ObjectTypeName", true);
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
        
        panel.ObjectPanel.BindObjectToControls(doctemp);
    }

    
    /// <summary>
    /// Occurs when the user clicks on the upload button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpload_Click(object sender, EventArgs e)
    {
        if (InputFile.PostedFile != null && InputFile.PostedFile.ContentLength > 0)
        {
            if (Path.GetExtension(InputFile.PostedFile.FileName).ToUpper() != ".MHT" &&
                Path.GetExtension(InputFile.PostedFile.FileName).ToUpper() != ".HTM" &&
                Path.GetExtension(InputFile.PostedFile.FileName).ToUpper() != ".HTML")
            {
                panel.Message = "Only word documents saved in .mht/.htm/.html formats are accepted.";
                return;
            }

            ODocumentTemplate doctemplate = (ODocumentTemplate)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(doctemplate);
            
            byte[] fileBytes = new byte[InputFile.PostedFile.ContentLength];
            InputFile.PostedFile.InputStream.Position = 0;
            InputFile.PostedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

            doctemplate.FileBytes = fileBytes;
            doctemplate.FileName = Path.GetFileName(InputFile.PostedFile.FileName);
            doctemplate.FileSize = InputFile.PostedFile.ContentLength;
            doctemplate.ContentType = InputFile.PostedFile.ContentType;
            panel.ObjectPanel.BindObjectToControls(doctemplate);
            
            if (lbFilename.Text != "")
            {
                this.buttonDownload.Visible = true;
            }
            else
            {
                this.buttonDownload.Visible = false;
            }
        }
    }


    /// <summary>
    /// Occurs when the users clicks on the download button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonDownload_Click(object sender, EventArgs e)
    {
        ODocumentTemplate doctemp = (ODocumentTemplate)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(doctemp);
        panel.FocusWindow = false;
        Window.Download(doctemp.FileBytes, doctemp.FileName, doctemp.ContentType);
    }
     

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (lbFilename.Text != "")
        {
            this.buttonDownload.Visible = true;
        }
        else
        {
            this.buttonDownload.Visible = false;
        }
        ViewDocumentTag.Visible = dropObjectTypeName.SelectedIndex > 0;
    }

    
    /// <summary>
    /// Validates and saves the document template object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            ODocumentTemplate docTemp = panel.SessionObject as ODocumentTemplate;
            panel.ObjectPanel.BindControlsToObject(docTemp);

            // Save 
            //
            docTemp.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Occurs when user clicks on the View Document Tag button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ViewDocumentTag_Click(object sender, EventArgs e)
    {
        string type = this.dropObjectTypeName.SelectedValue;
        Window.Open("viewdocumenttag.aspx?OBJ="
            + HttpUtility.UrlEncode(Security.Encrypt(type)));         
        panel.FocusWindow = false;
    }

    protected void dropObjectTypeName_SelectedIndexChanged(object sender, EventArgs e)
    {
        
    }
</script>

<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Document Template" BaseTable="tDocumentTemplate"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                    meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                        BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberVisible="false" />
                        <ui:UIFieldTextBox runat="server" ID="FileDescription" ValidateRequiredField="True"
                            Caption="File Description" PropertyName="FileDescription" 
                            InternalControlWidth="95%" meta:resourcekey="FileDescriptionResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName" ValidateRequiredField="True"
                            Caption="Object Type" PropertyName="ObjectTypeName" Span="Half" 
                            OnSelectedIndexChanged="dropObjectTypeName_SelectedIndexChanged" 
                            meta:resourcekey="dropObjectTypeNameResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIButton runat="server" Text="View Documents Tag" ID="ViewDocumentTag" 
                            OnClick="ViewDocumentTag_Click" ImageUrl="~/images/view.gif" Visible="False" 
                            meta:resourcekey="ViewDocumentTagResource1" />
                        <br />
                        <ui:UIFieldTextBox runat="server" ID="textApplicableStates" PropertyName="ApplicableStates"
                            caption="Applicable States" MaxLength="500" ValidateRequiredField="True" 
                            InternalControlWidth="95%" meta:resourcekey="textApplicableStatesResource1"></ui:UIFieldTextBox>
                        <ui:uifieldtextbox runat='server' id="textFleeCondition" PropertyName="FLEECondition" CAption="Applicable Condition" MaxLength="500" InternalControlWidth="95%" meta:resourcekey="textFleeConditionResource1">
                        </ui:uifieldtextbox>
                        <ui:uifieldradiolist runat="server" id="radioOutputFormat" PropertyName="OutputFormat" Caption="Output Format" meta:resourcekey="radioOutputFormatResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem value="0" Text="Microsoft Word (editable)" meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem value="1" Text="Microsoft Excel (editable)" meta:resourcekey="ListItemResource2"></asp:ListItem>
                                <asp:ListItem value="2" Text="Static (non-editable)" meta:resourcekey="ListItemResource3"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist> 
                        <br />
                        
                        <ui:UIPanel runat="server" ID="panelUploadFile" BorderStyle="NotSet" 
                            meta:resourcekey="panelUploadFileResource1">
                            <ui:UIFieldInputFile ID="InputFile" runat="server" Caption="Upload Template" 
                                meta:resourcekey="InputFileResource1" />
                            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                <tr>
                                    <td style="width: 124px">
                                    </td>
                                    <td>
                                        <ui:UIButton runat="server" Text="Upload File" ID="buttonUpload" OnClick="buttonUpload_Click"
                                            ImageUrl="~/images/upload.png" meta:resourcekey="buttonUploadResource1" />
                                    </td>
                                </tr>
                            </table>
                            <ui:UISeparator runat="server" ID="Separator1" Caption="Uploaded File" 
                                meta:resourcekey="Separator1Resource1" />
                            <ui:UIFieldLabel runat="server" ID="lbFilename" Caption="File Name" PropertyName="FileName"
                                Span="Half" DataFormatString="" meta:resourcekey="lbFilenameResource1"></ui:UIFieldLabel>
                            <ui:UIButton runat="server" Visible="False" Text="Download File" ImageUrl="~/images/icon-savesmall.gif"
                                ID="buttonDownload" OnClick="buttonDownload_Click" 
                                meta:resourcekey="buttonDownloadResource1" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                        meta:resourcekey="tabMemoResource1" >
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" 
                        BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1" >
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
