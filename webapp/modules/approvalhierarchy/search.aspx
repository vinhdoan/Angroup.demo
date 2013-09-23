<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web"
    TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="LogicLayer" %>

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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Approval Hierarchy"
            GridViewID="gridResults" BaseTable="tApprovalHierarchy" EditButtonVisible="false"
            OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName"
                        Caption="Hierarchy Name" 
                        ToolTip="The approval hierarchy name as displayed on screen." meta:resourcekey="NameResource1"/>
                    <ui:UIFieldTextBox runat="server" ID="textUser" 
                        PropertyName="ApprovalHierarchyLevels.Users.ObjectName"
                        Caption="User Name" ToolTip="The name of the user." meta:resourcekey="textUserResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldListBox runat="serveR" ID="listRoles" 
                        PropertyName="ApprovalHierarchyLevels.Roles.ObjectID"
                        Caption="Roles" meta:resourcekey="listRolesResource1"></ui:UIFieldListBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" meta:resourcekey="gridResultsResource1">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" 
                                CommandName="EditObject" />
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                CommandName="ViewObject" />
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource3"/>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectName" 
                                HeaderText="Approval Hierarchy Name" meta:resourcekey="UIGridViewBoundColumnResource1"/>
                        </Columns>
                        <Commands>
                            <ui:UIGridViewCommand CommandText="Deleted Selected" ImageUrl="~/images/delete.gif"
                                CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete the selected items?" meta:resourcekey="UIGridViewCommandResource1"/>
                        </Commands>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
