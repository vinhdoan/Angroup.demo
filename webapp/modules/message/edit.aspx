﻿<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.IO" %>
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
        OMessage message = panel.SessionObject as OMessage;
        panel.ObjectPanel.BindObjectToControls(message);
        if (message.IsSuccessful == 1)
            lblSuccessful.Text = "Yes";
        else
            lblSuccessful.Text = "No";

        labelMessageText.Text = message.Message;
    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);


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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Message History" BaseTable="tMessage"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                        BorderStyle="NotSet" meta:resourcekey="tabDetailsResource2">
                    <ui:UIFieldLabel ID="UIFieldLabel1" runat="server" Caption="Message Type" PropertyName="MessageType" 
                            DataFormatString="" meta:resourcekey="UIFieldLabelResource2"></ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="labelSender" runat="server" Caption="Sender" PropertyName="Sender" 
                            DataFormatString=""></ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="labelRecipient" runat="server" Caption="Recipient(s)" 
                            PropertyName="Recipient" DataFormatString="" 
                            meta:resourcekey="labelRecipientResource2"></ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="UIFieldLabel2" runat="server" Caption="Sent date/time" 
                            PropertyName="SentDateTime" DataFormatString="{0:dd-MMM-yyyy}" 
                            meta:resourcekey="UIFieldLabel1Resource2"></ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="lblSuccessful" runat="server" Caption="Successful" 
                            DataFormatString="" meta:resourcekey="lblSuccessfulResource2"></ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="UIFieldLabel3" runat="server" Caption="Number of tries" 
                            PropertyName="NumberOfTries" DataFormatString="" 
                            meta:resourcekey="UIFieldLabel3Resource2"></ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="UIFieldLabel4" runat="server" Caption="Status Message" 
                            PropertyName="ErrorMessage" DataFormatString="" 
                            meta:resourcekey="UIFieldLabel2Resource2"></ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="UIFieldLabel5" runat="server" Caption="Email Header" 
                            PropertyName="Header" DataFormatString="" 
                            meta:resourcekey="UIFieldLabel5Resource2"></ui:UIFieldLabel>
                    <ui:UISeparator runat="server" ID="sep1" Caption="Message" 
                            meta:resourcekey="sep1Resource2" />
                    <table cellpadding='0' cellspacing='6' border='0' style="width: 100%">
                        <tr>
                            <td style="width: 150px"><asp:Label runat="server" ID="labelMessage" 
                                    Text="Message Text:" meta:resourcekey="labelMessageResource2"></asp:Label></td>
                            <td><asp:Label runat="server" ID="labelMessageText" 
                                    meta:resourcekey="labelMessageTextResource1"></asp:Label></td>
                        </tr>
                    </table>
                    </ui:UITabView>
                    
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>

