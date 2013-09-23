<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
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
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        List<ColumnOrder> columnOrders = new List<ColumnOrder>();
        columnOrders.Add(TablesLogic.tSessionAudit.LogonDateTime.Desc);
        e.CustomSortOrder = columnOrders;
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
        <web:search runat="server" ID="panel" Caption="Login/Logout History" GridViewID="gridResults"
            SearchType="ObjectQuery" BaseTable="tSessionAudit" OnSearch="panel_Search" EditButtonVisible="false"
            SearchTextBoxHint="E.g.: User Name, Login Name, Network Address, etc..."
            AutoSearchOnLoad="true" MaximumNumberOfResults="100" 
            SearchTextBoxPropertyNames="UserName,NetworkID" AdvancedSearchPanelID="panelAdvanced"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1" >
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <%--<ui:UIFieldTextBox runat="server" ID="UserName" Caption="User Name" PropertyName="UserName"
                    InternalControlWidth="95%" meta:resourcekey="UserNameResource2">
                </ui:UIFieldTextBox>
                <ui:UIFieldTextBox runat="server" ID="NetworkID" PropertyName="NetworkID" Caption="Network Address"
                    InternalControlWidth="95%" meta:resourcekey="NetworkIDResource2">
                </ui:UIFieldTextBox>--%>
                <ui:UIFieldDateTime runat="server" ID="LogonDateTime" Caption="Log on Date/Time"
                    PropertyName="LogonDateTime" SearchType="Range" meta:resourcekey="LogonDateTimeResource2"
                    ShowDateControls="True">
                </ui:UIFieldDateTime>
                <ui:UIFieldRadioList runat="server" ID="rdlLoginSuccessded" Caption="Log in succeeded"
                    PropertyName="Succeeded" meta:resourcekey="rdlLoginSuccessdedResource2" TextAlign="Right">
                    <Items>
                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource3">Yes</asp:ListItem>
                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource4">No</asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
                <ui:UIFieldDateTime runat="server" ID="Logoffdatetime" Caption="Log off Date/Time"
                    PropertyName="LogoffDateTime" SearchType="Range" meta:resourcekey="LogoffdatetimeResource2"
                    ShowDateControls="True">
                </ui:UIFieldDateTime>
            </ui:UIPanel>
            <%--</ui:UITabView>
            <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                SortExpression="LogonDateTime DESC" meta:resourcekey="gridResultsResource1" Width="100%"
                OnRowDataBound="gridResults_RowDataBound" DataKeyNames="ObjectID" GridLines="Both"
                RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Columns>
                    <cc1:UIGridViewBoundColumn DataField="UserName" HeaderText="User Name" meta:resourcekey="UIGridViewBoundColumnResource6"
                        PropertyName="UserName" ResourceAssemblyName="" SortExpression="UserName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="NetworkID" HeaderText="Network Address" meta:resourcekey="UIGridViewBoundColumnResource7"
                        PropertyName="NetworkID" ResourceAssemblyName="" SortExpression="NetworkID">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="LogonDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                        HeaderText="Log on Date/Time" meta:resourcekey="UIGridViewBoundColumnResource8"
                        PropertyName="LogonDateTime" ResourceAssemblyName="" SortExpression="LogonDateTime">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="SucceededText" HeaderText="Succeeded?" meta:resourcekey="UIGridViewBoundColumnResource9"
                        PropertyName="SucceededText" ResourceAssemblyName="" SortExpression="SucceededText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="LogoffDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                        HeaderText="Log off Date/Time" meta:resourcekey="UIGridViewBoundColumnResource10"
                        PropertyName="LogoffDateTime" ResourceAssemblyName="" SortExpression="LogoffDateTime">
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
