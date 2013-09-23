<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {


    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
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
        <web:search runat="server" ID="panel" Caption="Report" GridViewID="gridResults" EditButtonVisible="false"
            BaseTable="tReport" OnSearch="panel_Search" SearchType="ObjectQuery" SearchTextBoxHint="E.g.: Report Name, Category Name"
            AutoSearchOnLoad="true" MaximumNumberOfResults="100" SearchTextBoxPropertyNames="ReportName,CategoryName"
            AdvancedSearchPanelID="" meta:resourcekey="panelResource1"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTextBox runat='server' ID='txt_ReportName' Caption="Report Name" ToolTip="The report name as displayed on the menu." PropertyName="ReportName"
                            meta:resourcekey="ObjectNameResource1" />
                        <ui:UIFieldTextBox runat='server' ID='txt_CategoryName' Caption="Category Name" ToolTip="The category name as displayed on the menu." PropertyName="CategoryName"
                            meta:resourcekey="CategoryNameResource1" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">--%>
            <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                Width="100%" SortExpression="CategoryName" AllowPaging="True" AllowSorting="True"
                PagingEnabled="True">
                <Columns>
                    <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                        HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                    </ui:UIGridViewButtonColumn>
                    <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewObject"
                        HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                    </ui:UIGridViewButtonColumn>
                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                        HeaderText="" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewColumnResource3">
                    </ui:UIGridViewButtonColumn>
                    <ui:UIGridViewBoundColumn PropertyName="CategoryName" HeaderText="Category Name"
                        meta:resourcekey="UIGridViewColumnResource5">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ReportName" HeaderText="Report Name" meta:resourcekey="UIGridViewColumnResource4">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ModifiedDateTime" HeaderText="Last Modified"
                        DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}">
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
