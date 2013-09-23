<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Performs the search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {

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
        <ui:UIObjectPanel runat='server' ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Function" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tFunction" OnSearch="panel_Search" meta:resourcekey="panelResource1"
                SearchTextBoxHint="Function Name, Category Name, Sub Category Name" AutoSearchOnLoad="false" MaximumNumberOfResults="30" 
                SearchTextBoxPropertyNames="ObjectTypeName,FunctionName,CategoryName,SubCategoryName" AdvancedSearchPanelID="panelAdvanced"
                SearchType="ObjectQuery"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldTextBox runat='server' ID='textCategoryName' Caption="Category Name" 
                            Span="Half" propertyname="CategoryName" InternalControlWidth="95%" 
                            meta:resourcekey="textCategoryNameResource1" />
                        <ui:UIFieldTextBox runat='server' ID='textSubCategoryName' 
                            Caption="Sub-Category Name" Span="Half" propertyname="SubCategoryName" 
                            InternalControlWidth="95%" meta:resourcekey="textSubCategoryNameResource1" />
                        <ui:UIFieldTextBox runat='server' ID='textFunctionName' 
                            Caption="Function Name"  propertyname="FunctionName"
                            MaxLength="255" InternalControlWidth="95%" 
                            meta:resourcekey="textFunctionNameResource1" />
                        <ui:UIFieldTextBox runat='server' ID='textObjectType' PropertyName="ObjectTypeName"
                            Caption="Object Type" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textObjectTypeResource1" />
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            Width="100%" SortExpression="CategoryName, DisplayOrder, FunctionName" 
                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
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
                                <cc1:UIGridViewBoundColumn DataField="CategoryName" HeaderText="Category Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="CategoryName" 
                                    ResourceAssemblyName="" SortExpression="CategoryName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="SubCategoryName" 
                                    HeaderText="Sub-Category Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="SubCategoryName" ResourceAssemblyName="" 
                                    SortExpression="SubCategoryName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="FunctionName" HeaderText="Function Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="FunctionName" 
                                    ResourceAssemblyName="" SortExpression="FunctionName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectTypeName" HeaderText="Object Type" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="ObjectTypeName" 
                                    ResourceAssemblyName="" SortExpression="ObjectTypeName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MainUrl" HeaderText="Main Url" 
                                    PropertyName="MainUrl" 
                                    ResourceAssemblyName="" SortExpression="MainUrl">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EditUrl" HeaderText="Edit Url" 
                                    PropertyName="EditUrl" 
                                    ResourceAssemblyName="" SortExpression="EditUrl">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn HeaderText="Display Order" PropertyName="DisplayOrder" 
                                    ResourceAssemblyName="" SortExpression="DisplayOrder">
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
