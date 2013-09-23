<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="Dashboard" GridViewID="gridResults" SearchType="ObjectQuery"
                BaseTable="tDashboard" OnSearch="panel_Search" EditButtonVisible="false" 
                AutoSearchOnLoad="true" SearchTextBoxHint="Dashboard Name, Dashboard Type" 
                MaximumNumberOfResults="1000" SearchTextBoxPropertyNames="ObjectName"
                AdvancedSearchPanelID="" AdvancedSearchOnLoad="false"
                meta:resourcekey="panelResource1"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTextBox runat='server' ID='ObjectName' PropertyName="ObjectName" Caption="Dashboard Name"
                            ToolTip="The dashboard name." MaxLength="255" meta:resourcekey="ObjectNameResource1" />
                        <ui:UIFieldDropDownList runat='server' ID='DashboardType' PropertyName="DashboardType"
                            Caption="Dashboard Type" ToolTip="The dashboard type." 
                            meta:resourcekey="DashboardTypeResource1">
                            <Items>
                                <asp:ListItem Value=""></asp:ListItem>
                                <asp:ListItem Value="0">Grid</asp:ListItem>
                                <asp:ListItem Value="1">Gauge</asp:ListItem>
                                <asp:ListItem Value="2">Pie</asp:ListItem>
                                <asp:ListItem Value="3">Scatter</asp:ListItem>
                                <asp:ListItem Value="4">Bubble</asp:ListItem>
                                <asp:ListItem Value="5">Basic</asp:ListItem>
                                <asp:ListItem Value="6">Radar</asp:ListItem>
                                <asp:ListItem Value="7">Polar</asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">--%>
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%" SortExpression="ObjectName">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Dashboard Name"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="DashboardTypeText" HeaderText="Dashboard Type" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    <%--</ui:UITabView>
                </ui:UITabStrip>--%>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
