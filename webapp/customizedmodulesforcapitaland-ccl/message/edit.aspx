<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OMessage message = panel.SessionObject as OMessage;
        panel.ObjectPanel.BindObjectToControls(message);
        if (message.IsSuccessful == 1)
            lblSuccessful.Text = "Yes";
        else
            lblSuccessful.Text = "No";

        //labelMessageText.Text = message.Message;
    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OMessage message = panel.SessionObject as OMessage;

        textMessage.Visible = message.MessageType.Is("SMS", "SMSIN");
        labelMessage.Visible = gridDocument.Visible = message.MessageType.Is("EMAIL");

    }

    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OMessage message = panel.SessionObject as OMessage;
            panel.ObjectPanel.BindControlsToObject(message);

            message.Save();
        }
    }

    /// <summary>
    /// Occurs when the user clicks on a button in the UIGridView.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gridDocument_Action(object sender, string commandName, System.Collections.Generic.List<object> objectIds)
    {
        if (commandName == "ViewDocument")
        {
            // View the document, so load it from
            // database and let user download it.
            //
            using (Connection c = new Connection())
            {
                foreach (Guid objectId in objectIds)
                {
                    string contentType = "";
                    string fileName = "";
                    OMessageAttachment b = TablesLogic.tMessageAttachment[objectId];
                    Window.Download(b.FileBytes, b.Filename, "application/octet-stream");
                }
            }
        }
        if (commandName == "DeleteDocument")
        {
            // remove the document from the database.
            //
            OMessage o = panel.SessionObject as OMessage;
            panel.ObjectPanel.BindControlsToObject(o);

            if (o != null)
            {
                foreach (Guid objectId in objectIds)
                    o.Attachments.RemoveGuid(objectId);
            }

            panel.ObjectPanel.BindObjectToControls(o);
        }
    }

    protected void gridDocument_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string Attachment = "";

            Attachment = String.Format(Resources.Strings.GeneralDisplayTitleFontColor, e.Row.Cells[5].Text);

            if (e.Row.Cells[4].Text != "&nbsp;" && e.Row.Cells[3].Text != "&nbsp;")
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, Convert.ToDateTime(e.Row.Cells[4].Text).ToFriendlyString(), e.Row.Cells[3].Text);
            else
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, DateTime.Now.AddSeconds(-1).ToFriendlyString(), AppSession.User.ObjectName);

            e.Row.Cells[5].Text = Attachment;
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[4].Visible = false;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Message History" BaseTable="tMessage"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" BorderStyle="NotSet"
                    meta:resourcekey="tabDetailsResource2">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" ObjectNameVisible="false"
                        ObjectNumberVisible="false" />
                    <ui:UIFieldLabel ID="UIFieldLabel1" runat="server" Caption="Message Type" PropertyName="MessageType"
                        DataFormatString="" meta:resourcekey="UIFieldLabelResource2">
                    </ui:UIFieldLabel>
                    <ui:UIFieldTextBox ID="labelSender" runat="server" Caption="Sender" PropertyName="Sender"
                        DataFormatString="">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox ID="labelRecipient" runat="server" Caption="Recipient(s)" PropertyName="Recipient"
                        DataFormatString="" meta:resourcekey="labelRecipientResource2">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox ID="labelCCRecipient" runat="server" Caption="CC Recipient(s)" PropertyName="CarbonCopyRecipient"
                        DataFormatString="" >
                    </ui:UIFieldTextBox>
                    <ui:UIFieldLabel ID="UIFieldLabel2" runat="server" Caption="Sent date/time" PropertyName="SentDateTime"
                        DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIFieldLabel1Resource2">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="lblSuccessful" runat="server" Caption="Successful" DataFormatString=""
                        meta:resourcekey="lblSuccessfulResource2">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="UIFieldLabel3" runat="server" Caption="Number of tries" PropertyName="NumberOfTries"
                        DataFormatString="" meta:resourcekey="UIFieldLabel3Resource2">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="UIFieldLabel4" runat="server" Caption="Status Message" PropertyName="ErrorMessage"
                        DataFormatString="" meta:resourcekey="UIFieldLabel2Resource2">
                    </ui:UIFieldLabel>
                    <ui:UIFieldTextBox ID="UIFieldLabel5" runat="server" Caption="Email Header" PropertyName="Header"
                        DataFormatString="" meta:resourcekey="UIFieldLabel5Resource2">
                    </ui:UIFieldTextBox>
                    <ui:UIGridView runat='server' ID="gridDocument" OnAction="gridDocument_Action" Caption="Attachments"
                        PropertyName="MessageAttachments" KeyName="ObjectID" ShowCaption="false" meta:resourcekey="gridDocumentResource1"
                        OnRowDataBound="gridDocument_RowDataBound">
                        <Commands>
                            <ui:UIGridViewCommand CommandName="DeleteDocument" CommandText="Delete" ImageUrl="~/images/delete.gif"
                                ConfirmText="Are you sure you wish to delete the selected documents?" meta:resourcekey="UIGridViewCommandResource1" />
                        </Commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewDocument"
                                HeaderText="" meta:resourcekey="UIGridViewColumnResource1" AlwaysEnabled="true">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteDocument"
                                HeaderText="" ConfirmText="Are you sure you wish to delete this document?" meta:resourcekey="UIGridViewColumnResource2">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CreatedUser" HeaderText="Created User">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Created Date Time">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Filename" HeaderText="File Name" meta:resourcekey="UIGridViewColumnResource3">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="FileSize" HeaderText="File Size (bytes)"
                                DataFormatString="{0:#,##0}" meta:resourcekey="UIGridViewColumnResource4">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIFieldTextBox runat="server" ID="textMessage" PropertyName="Message" ShowCaption="false"
                        Caption="Message" TextMode="MultiLine" Rows="3">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldRichTextBox runat="server" ID="labelMessage" Caption="Message" ShowCaption="false"
                        PropertyName="Message">
                    </ui:UIFieldRichTextBox>
                </ui:UITabView>
                <ui:UITabView ID="tabMemo" runat="server" BorderStyle="NotSet" Caption="Memo" meta:resourcekey="tabMemoResource1">
                    <web:memo ID="memo1" runat="server" />
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
