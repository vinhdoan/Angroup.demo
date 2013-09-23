<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
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
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        List<ColumnOrder> orderColumns = new List<ColumnOrder>();
        orderColumns.Add(TablesLogic.tMessage.ScheduledDateTime.Desc);
        e.CustomSortOrder = orderColumns;
    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

    }

    
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string message = (string)((DataRowView)e.Row.DataItem)["Message"];
            if (message != null)
            {
                message = System.Text.RegularExpressions.Regex.Replace(message, @"<(.|\n)*?>", string.Empty);
                message = message.Substring(0, (message.Length > 200 ? 200 : message.Length));
                e.Row.Cells[14].Text = message;

            }

        }
    }
    
    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ResendMessage")
        {
            foreach (Guid oID in dataKeys)
            {
                OMessage message = TablesLogic.tMessage.Load(oID);
                if (message != null)
                {
                    using (Connection c = new Connection())
                    {
                        message.IsSuccessful = 0;
                        message.NumberOfTries = 0;
                        message.ErrorMessage = "";
                        message.SentDateTime = null;
                        message.Save();
                        c.Commit();
                    }

                }

            }
            panel.PerformSearch();
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Message History" GridViewID="gridResults"
                BaseTable="tMessage" OnSearch="panel_Search" EditButtonVisible="false"
                AutoSearchOnLoad="false" MaximumNumberOfResults="30" 
                SearchTextBoxPropertyNames="Header,Message,Recipient,MessageType" AdvancedSearchPanelID="panelAdvanced"
                SearchTextBoxHint="E.g. Header, Recipients, Message, Message Type"
                OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" 
                meta:resourcekey="panelResource1"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1" >
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <%--<ui:UIFieldTextBox runat="server" ID="MessageType" Caption="Message Type" 
                            PropertyName="MessageType" InternalControlWidth="95%" 
                            meta:resourcekey="MessageTypeResource2"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textReceipient" Caption="Receipient(s)" 
                            PropertyName="Recipient" InternalControlWidth="95%" >
                        </ui:UIFieldTextBox>--%>
                        <ui:UIFieldDateTime runat="server" ID="SentDateTime" 
                            PropertyName="SentDateTime" Caption="Sent Date/Time" SearchType="Range" 
                            meta:resourcekey="SentDateTimeResource2" ShowDateControls="True"></ui:UIFieldDateTime>
                        <ui:UIFieldRadioList runat="server" ID="rdlIsSuccessful" Caption="Successful?"  
                            PropertyName="IsSuccessful" meta:resourcekey="rdlIsSuccessfulResource2" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource3">No</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource8">Yes</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldDropDownList ID="UIFieldDropDownList1" runat="server" Caption="Number of Tries" 
                            PropertyName="NumberOfTries" meta:resourcekey="UIFieldDropDownListResource2">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource9"></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource10">0</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource11">1</asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource12">2</asp:ListItem>
                                <asp:ListItem Value="3" meta:resourcekey="ListItemResource13">3</asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <%--<ui:UIFieldTextBox runat="server" ID="txtMessageText" Caption="Message Text" 
                            PropertyName="Message" InternalControlWidth="95%" 
                            meta:resourcekey="txtMessageTextResource2"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="txtEmailHeader" Caption="Message Header" 
                            PropertyName="Header" InternalControlWidth="95%" 
                            meta:resourcekey="txtEmailHeaderResource2"></ui:UIFieldTextBox>--%>
                    </ui:UIPanel>    
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
                        <%--<ui:UIButton runat="server" Text="Resend" ID="btnResend" 
                            OnClick="btnResend_Click" meta:resourcekey="btnResendResource2" />--%>
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" 
                            KeyName="ObjectID" SortExpression="ScheduledDateTime DESC"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            OnRowDataBound="gridResults_RowDataBound" DataKeyNames="ObjectID" 
                            GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" style="clear:both;" OnAction="gridResults_Action">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="True" CausesValidation="False" 
                                    CommandName="ResendMessage" CommandText="Resend Selected" 
                                    ImageUrl="~/images/tick.gif" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ScheduledDateTime" 
                                    DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Scheduled Date/Time" 
                                    meta:resourcekey="UIGridViewBoundColumnResource10" 
                                    PropertyName="ScheduledDateTime" ResourceAssemblyName="" 
                                    SortExpression="ScheduledDateTime">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Sender" HeaderText="Sender" 
                                    PropertyName="Sender" ResourceAssemblyName="" SortExpression="Sender">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Recipient" HeaderText="Recipient(s)" 
                                    meta:resourcekey="UIGridViewBoundColumnResource11" PropertyName="Recipient" 
                                    ResourceAssemblyName="" SortExpression="Recipient">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CarbonCopyRecipient" HeaderText="CC Recipient(s)" 
                                    PropertyName="CarbonCopyRecipient" 
                                    ResourceAssemblyName="" SortExpression="CarbonCopyRecipient">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MessageType" HeaderText="Message Type" 
                                    meta:resourcekey="UIGridViewBoundColumnResource12" PropertyName="MessageType" 
                                    ResourceAssemblyName="" SortExpression="MessageType">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="SentDateTime" 
                                    DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Sent Date/Time" 
                                    meta:resourcekey="UIGridViewBoundColumnResource13" PropertyName="SentDateTime" 
                                    ResourceAssemblyName="" SortExpression="SentDateTime">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsSuccessfulText" HeaderText="Successful" 
                                    meta:resourcekey="UIGridViewBoundColumnResource14" 
                                    PropertyName="IsSuccessfulText" ResourceAssemblyName="" 
                                    SortExpression="IsSuccessfulText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NumberOfTries" 
                                    HeaderText="Number of tries" meta:resourcekey="UIGridViewBoundColumnResource15" 
                                    PropertyName="NumberOfTries" ResourceAssemblyName="" 
                                    SortExpression="NumberOfTries">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NumberOfAttachments" 
                                    HeaderText="Number of attachments"
                                    PropertyName="NumberOfAttachments" ResourceAssemblyName="" 
                                    SortExpression="NumberOfAttachments">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MessagePriority" 
                                    HeaderText="Priority"
                                    PropertyName="MessagePriority" ResourceAssemblyName="" 
                                    SortExpression="MessagePriority">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Message" HeaderText="Message Text" 
                                    meta:resourcekey="UIGridViewBoundColumnResource16" PropertyName="Message" 
                                    ResourceAssemblyName="" SortExpression="Message">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Header" HeaderText="Message Header" 
                                    meta:resourcekey="UIGridViewBoundColumnResource17" PropertyName="Header" 
                                    ResourceAssemblyName="" SortExpression="Header">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ErrorMessage" HeaderText="Status Message" 
                                    meta:resourcekey="UIGridViewBoundColumnResource18" PropertyName="ErrorMessage" 
                                    ResourceAssemblyName="" SortExpression="ErrorMessage">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    <%--</ui:UITabView>
                </ui:UITabStrip>--%>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
