<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource2" uiculture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web"
    TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
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
        listRoles.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID");
    }


    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
    }

    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet"
        type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
        <web:search runat="server" ID="panel" Caption="Approval Hierarchy"
            GridViewID="gridResults" BaseTable="tApprovalHierarchy" EditButtonVisible="false"
            OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                    <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName"
                        Caption="Hierarchy Name" 
                        ToolTip="The approval hierarchy name as displayed on screen." meta:resourcekey="NameResource1" InternalControlWidth="95%"/>
                    <ui:UIFieldTextBox runat="server" ID="textUser" 
                        PropertyName="ApprovalHierarchyLevels.Users.ObjectName"
                        Caption="User Name" ToolTip="The name of the user." meta:resourcekey="textUserResource1" InternalControlWidth="95%">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldListBox runat="server" ID="listRoles" 
                        PropertyName="ApprovalHierarchyLevels.Roles.ObjectID"
                        Caption="Roles" meta:resourcekey="listRolesResource1"></ui:UIFieldListBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                    <ui:UIGridView runat="server" ID="gridResults" 
                        meta:resourcekey="gridResultsResource1" DataKeyNames="ObjectID" 
                        GridLines="Both" RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Deleted Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource5">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Approval Hierarchy Name" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
