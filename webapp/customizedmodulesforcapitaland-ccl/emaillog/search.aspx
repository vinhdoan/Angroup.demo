<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource2" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {

        List<ColumnOrder> orderColumns = new List<ColumnOrder>();
        orderColumns.Add(TablesLogic.tEmailLog.DateTimeReceived.Desc);
        e.CustomSortOrder = orderColumns;
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
        <web:search runat="server" ID="panel" Caption="Received Email History" GridViewID="gridResults"
            EditButtonVisible="false" AutoSearchOnLoad="false" MaximumNumberOfResults="30"
            SearchTextBoxPropertyNames="ErrorMessage,EmailBody,Subject,FromRecipient" AdvancedSearchPanelID="panelAdvanced"
            SearchTextBoxHint="E.g. E-mail body, Subject, Senders, etc..." BaseTable="tEmailLog"
            SearchType="ObjectQuery" OnSearch="panel_Search"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource2" >--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <ui:UIFieldDateTime runat='server' ID="DateTimeReceived" SearchType="Range" PropertyName="DateTimeReceived"
                    Caption="DateTime Received" meta:resourcekey="DateTimeReceivedResource1" ShowDateControls="True" />
                <ui:UIFieldTextBox ID="FromRecipient" runat="server" PropertyName="FromRecipient"
                    Caption="From Recipient" InternalControlWidth="95%" meta:resourcekey="FromRecipientResource1" />
                <ui:UIFieldTextBox ID="Subject" runat="server" PropertyName="Subject" Caption="Subject"
                    InternalControlWidth="95%" meta:resourcekey="SubjectResource1" />
                <ui:UIFieldTextBox ID="EmailBody" runat="server" PropertyName="EmailBody" Caption="Email Body"
                    InternalControlWidth="95%" meta:resourcekey="EmailBodyResource1" />
                <ui:UIFieldTextBox ID="ErrorMessage" runat="server" PropertyName="ErrorMessage" Caption="Error Message"
                    InternalControlWidth="95%" meta:resourcekey="ErrorMessageResource1" />
                <ui:UIFieldRadioList ID="IsSuccessful" runat="server" PropertyName="IsSuccessful"
                    Caption="Is Successful" meta:resourcekey="IsSuccessfulResource1" TextAlign="Right">
                    <Items>
                        <asp:ListItem Value="0" Text="No" meta:resourcekey="ListItemResource1" />
                        <asp:ListItem Value="1" Text="Yes" meta:resourcekey="ListItemResource2" />
                    </Items>
                </ui:UIFieldRadioList>
            </ui:UIPanel>
            <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource2" >--%>
            <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID"
                GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridResultsResource1"
                RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Commands>
                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                        CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                </Commands>
                <Columns>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                        meta:resourceKey="UIGridViewColumnResource2">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewBoundColumn DataField="DateTimeReceived" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                        HeaderText="DateTime Received" meta:resourcekey="UIGridViewBoundColumnResource2"
                        PropertyName="DateTimeReceived" ResourceAssemblyName="" SortExpression="DateTimeReceived">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="FromRecipient" HeaderText="From Recipient"
                        meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="FromRecipient"
                        ResourceAssemblyName="" SortExpression="FromRecipient">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Subject" HeaderText="Subject" meta:resourcekey="UIGridViewBoundColumnResource4"
                        PropertyName="Subject" ResourceAssemblyName="" SortExpression="Subject">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <%--<cc1:UIGridViewBoundColumn DataField="EmailBody" HeaderText="Email Body"
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="EmailBody" 
                                    ResourceAssemblyName="" SortExpression="EmailBody">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="200px" />
                                </cc1:UIGridViewBoundColumn>--%>
                    <cc1:UIGridViewBoundColumn DataField="IsSuccessfulText" HeaderText="Is Successful"
                        meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="IsSuccessfulText"
                        ResourceAssemblyName="" SortExpression="IsSuccessfulText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="ErrorMessage" HeaderText="Error Message" meta:resourcekey="UIGridViewBoundColumnResource7"
                        PropertyName="ErrorMessage" ResourceAssemblyName="" SortExpression="ErrorMessage">
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
