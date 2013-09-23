<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OMessageTemplate messageTemplate = (OMessageTemplate)panel.SessionObject;
        dropObjectTypeName.Bind(OWorkflowRepository.GetAllWorkflowRepositories(), "ObjectTypeName", "ObjectTypeName", true);
        dropObjectTypeName2.Bind(OFunction.GetAllFunctionsWithObjectTypes(), "ObjectTypeName", "ObjectTypeName", true);
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
        foreach (ListItem item in dropObjectTypeName2.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
        
        panel.ObjectPanel.BindObjectToControls(messageTemplate);

        // 2010.05.14
        // Kim Foong
        // Select the 2nd dropdown list based on the selected value, not
        // the selected index, because the lists are different.
        //
        dropObjectTypeName2.SelectedValue = dropObjectTypeName.SelectedValue;
        //dropObjectTypeName2.SelectedIndex = dropObjectTypeName.SelectedIndex;
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
            OMessageTemplate messageTemplate = (OMessageTemplate)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(messageTemplate);

            // Save
            //
            messageTemplate.Save();
            c.Commit();
        }
    }



    /// <summary>
    /// Occurs when the user clicks on the Send Email checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkSendEmail_CheckedChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user clicks on the Send SMS checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkSendSms_CheckedChanged(object sender, EventArgs e)
    {

    }


    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OMessageTemplate messageTemplate = panel.SessionObject as OMessageTemplate;

        panelSms.Visible = checkSendSms.Checked;
        panelEmail.Visible = checkSendEmail.Checked;

        panelGeneral.Visible = radioWhereUsed.SelectedValue == MessageTemplateUsage.General.ToString();
        panelNotifyAssignedWorkflowRecipients.Visible = radioWhereUsed.SelectedValue == MessageTemplateUsage.NotifyAssignedWorkflowRecipients.ToString();

        radioWhereUsed.Enabled = messageTemplate.IsNew;
        //panelGeneral.Enabled = messageTemplate.IsNew;
        //panelNotifyAssignedWorkflowRecipients.Enabled = messageTemplate.IsNew;
        hintGeneral.Visible = messageTemplate.IsNew;
        hintNotifyAssignedWorkflowRecipientsHint.Visible = messageTemplate.IsNew;
        ViewDocumentTag.Visible = dropObjectTypeName2.SelectedIndex > 0;
        dropObjectTypeName2.Enabled = radioWhereUsed.SelectedValue == MessageTemplateUsage.General.ToString();
    }
    
    

    /// <summary>
    /// Occurs when the user selects an item on the Where Used radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioWhereUsed_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when user clicks on the View Document Tag button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ViewDocumentTag_Click(object sender, EventArgs e)
    {
        // 2010.05.14
        // Kim Foong
        // Show the document tags based on the second dropdown
        // list. Not the first.
        //
        string type = this.dropObjectTypeName2.SelectedValue;
        
        //string type = this.dropObjectTypeName.SelectedValue;
        Window.Open("../../modules/documenttemplate/viewdocumenttag.aspx?OBJ="
            + HttpUtility.UrlEncode(Security.Encrypt(type)));
        panel.FocusWindow = false;
    }


    /// <summary>
    /// Occurs when the user clicks on the object type.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropObjectTypeName2_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Occurs when the user clicks on the object type.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropObjectTypeName_SelectedIndexChanged(object sender, EventArgs e)
    {
        dropObjectTypeName2.SelectedValue = dropObjectTypeName.SelectedValue;
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
            <web:object runat="server" ID="panel" Caption="Message Template" BaseTable="tMessageTemplate"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                    meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="Template Name" 
                        ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldRadioList runat="server" ID="radioWhereUsed" 
                            PropertyName="WhereUsed" Caption="Where Used" 
                            OnSelectedIndexChanged="radioWhereUsed_SelectedIndexChanged" 
                            ValidateDataTypeCheck="True" ValidateRequiredField="True" 
                            ValidationDataType="Integer" ValidationNumberOfDecimalPlaces="0" 
                            meta:resourcekey="radioWhereUsedResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1">General</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Notify Assigned Workflow Recipients</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelNotifyAssignedWorkflowRecipients" 
                            BorderStyle="NotSet" 
                            meta:resourcekey="panelNotifyAssignedWorkflowRecipientsResource1">
                            <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName" 
                                PropertyName="ObjectTypeName" Caption="Object Type Name" 
                                ValidateRequiredField="True" 
                                OnSelectedIndexChanged="dropObjectTypeName_SelectedIndexChanged" 
                                meta:resourcekey="dropObjectTypeNameResource1"></ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox runat="server" ID="textStateName" PropertyName="StateName" 
                                Caption="State Name" ValidateRequiredField="True" InternalControlWidth="95%" 
                                meta:resourcekey="textStateNameResource1"></ui:UIFieldTextBox>
                            <ui:UIHint runat='server' ID="hintNotifyAssignedWorkflowRecipientsHint" 
                                meta:resourcekey="hintNotifyAssignedWorkflowRecipientsHintResource1"><asp:Table runat="server" CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" ImageUrl="~/images/information.gif"></asp:Image>
</asp:TableCell>
<asp:TableCell runat="server" VerticalAlign="Top"><asp:Label runat="server">
                                Please ensure that you select the correct object type name and state name before saving. These fields cannot be modified once the message template has been saved into the database.
                            </asp:Label>
</asp:TableCell>
</asp:TableRow>
</asp:Table>
</ui:UIHint>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelGeneral" BorderStyle="NotSet" 
                            meta:resourcekey="panelGeneralResource1">
                            <ui:UIFieldTextBox runat="server" ID="textMessageTemplateCode" PropertyName="MessageTemplateCode"
                                Caption="Message Template Code" ValidateRequiredField="True" 
                                captionwidth="150px" InternalControlWidth="95%" 
                                meta:resourcekey="textMessageTemplateCodeResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIHint runat='server' ID="hintGeneral" 
                                meta:resourcekey="hintGeneralResource1">
                                Please ensure that you enter the correct message template code. 
                            </ui:UIHint>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabTemplates" Caption="Templates" 
                        BorderStyle="NotSet" meta:resourcekey="tabTemplatesResource1" >
                        <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName2"
                            Caption="Object Type" Span="Half" 
                            OnSelectedIndexChanged="dropObjectTypeName2_SelectedIndexChanged" 
                            meta:resourcekey="dropObjectTypeName2Resource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIButton runat="server" Text="View Documents Tag" ID="ViewDocumentTag" 
                            OnClick="ViewDocumentTag_Click" ImageUrl="~/images/view.gif" Visible="False" 
                            meta:resourcekey="ViewDocumentTagResource1" />
                        <ui:UISeparator runat="server" ID="sep1" Caption="SMS" 
                            meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldCheckBox runat="server" ID="checkSendSms" PropertyName="SendSms" Caption="Send SMS"
                            Text="Yes, this template includes an SMS to the recipient." 
                            OnCheckedChanged="checkSendSms_CheckedChanged" 
                            meta:resourcekey="checkSendSmsResource1" TextAlign="Right">
                        </ui:UIFieldCheckBox>
                        <ui:UIPanel runat="server" ID="panelSms" BorderStyle="NotSet" 
                            meta:resourcekey="panelSmsResource1">
                            <ui:UIFieldTextBox runat="server" ID="textSmsTemplate" PropertyName="SmsTemplate"
                                Caption="SMS Template" Rows="5" ValidateRequiredField="True" MaxLength="0" 
                                InternalControlWidth="95%" meta:resourcekey="textSmsTemplateResource1">
                            </ui:UIFieldTextBox>
                        </ui:UIPanel>
                        <ui:UISeparator runat="server" ID="UISeparator1" Caption="E-Mail" 
                            meta:resourcekey="UISeparator1Resource1" />
                        <ui:UIFieldCheckBox runat="server" ID="checkSendEmail" PropertyName="SendEmail" Caption="Send Email"
                            Text="Yes, this template includes an e-mail to the recipient." 
                            OnCheckedChanged="checkSendEmail_CheckedChanged" 
                            meta:resourcekey="checkSendEmailResource1" TextAlign="Right">
                        </ui:UIFieldCheckBox>
                        <ui:UIPanel runat="server" ID="panelEmail" BorderStyle="NotSet" 
                            meta:resourcekey="panelEmailResource1">
                            <ui:UIFieldCheckBox runat="server" ID="checkSendEmailWithAttachments" PropertyName="SendEmailWithAttachments" Caption="With Attachments"
                                Text="Yes, this template e-mail send together with attachments." TextAlign="Right">
                            </ui:UIFieldCheckBox>
                            <ui:UIFieldTextBox runat="server" ID="textEmailSubjectTemplate" PropertyName="EmailSubjectTemplate"
                                Caption="Subject Template" ValidateRequiredField="True"  MaxLength="0" 
                                InternalControlWidth="95%" meta:resourcekey="textEmailSubjectTemplateResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldRichTextBox runat="server" ID="textEmailBodyTemplate" 
                                PropertyName="EmailBodyTemplate" EditorHeight="250px"
                                Caption="Body Template" ValidateRequiredField="True" 
                                meta:resourcekey="textEmailBodyTemplateResource1" >
                            </ui:UIFieldRichTextBox>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabHelp" Caption="Help" BorderStyle="NotSet" 
                        meta:resourcekey="tabHelpResource1" >
                        <ui:UIHint runat='server' ID="hintTemplate" 
                            meta:resourcekey="hintTemplateResource1"><asp:Table runat="server" CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" ImageUrl="~/images/information.gif"></asp:Image>
</asp:TableCell>
<asp:TableCell runat="server" VerticalAlign="Top"><asp:Label runat="server">
                        Create your template by inserting placeholders into the message. The following is an example of a template:
                        <br />
                        <br />
                        <table style="width: 100%">
                            <tr>
                                <td style="width: 30px">
                                </td>
                                <td>
                                    
                                        Dear {obj.Supervisor.ObjectName},<br />
                                        <br />
                                        The following work order has been submitted to you for approval.<br />
                                        <br />
                                        WR#: {obj.ObjectNumber}<br />
                                        Description: {obj.WorkDescription}<br />
                                        Type of Work: {obj.TypeOfWork.ObjectName}<br />
                                        Type of Service: {obj.TypeOfService.ObjectName}<br />
                                        <br />
                                        <br />
                                </td>
                            </tr>
                        </table>
                        <br />
                        <br />
                        The following are The following variables are available for tagging:
                        <br />
                        <br />
                        <table style="width: 100%">
                            <tr>
                                <td style="width: 30px">
                                </td>
                                <td>
                                    {obj.????}<br></br>
                                    {applicationSettings.????}<br></br>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <br />
                        <br />
                        </asp:Label>
</asp:TableCell>
</asp:TableRow>
</asp:Table>
</ui:uihint>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                        meta:resourcekey="tabMemoResource1" >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server"  Caption="Attachments" 
                        BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
