<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

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
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Notification Hierarchy" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tNotificationHierarchy" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName" Caption="Hierarchy Name"
                            ToolTip="The approval hierarchy name as displayed on screen." 
                            InternalControlWidth="95%" meta:resourcekey="NameResource1" />
                        <ui:UIFieldTextBox runat="server" ID="textUser" 
                            PropertyName="NotificationHierarchyLevels.Users.ObjectName" Caption="User Name" 
                            ToolTip="The name of the user." InternalControlWidth="95%" 
                            meta:resourcekey="textUserResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldListBox runat="server" ID="listRoles" 
                            PropertyName="NotificationHierarchyLevels.Roles.ObjectID" Caption="Roles" 
                            meta:resourcekey="listRolesResource1"></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" DataKeyNames="ObjectID" 
                            GridLines="Both" meta:resourcekey="gridResultsResource1" 
                            RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" 
                                    HeaderText="Approval Hierarchy Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
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
