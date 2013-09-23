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
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        listRoleCodes.Bind(ORole.GetAllRoles(), "RoleCode", "ObjectID");
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
    }
    
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        // 2010.05.10
        // Kim Foong
        // Added a condition to filter locations.
        //
        TPosition p = TablesLogic.tPosition;
        TPosition p2 = new TPosition();

        ExpressionCondition locationCondition = Query.False;

        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                locationCondition = locationCondition | p2.LocationAccess.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        else
        {
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OPosition"))
                foreach (OLocation location in position.LocationAccess)
                    locationCondition = locationCondition | p2.LocationAccess.HierarchyPath.Like(location.HierarchyPath + "%");
        }

        e.CustomCondition =
            (p2.Select(p2.LocationAccess.ObjectID.Count()).Where(p2.ObjectID == p.ObjectID & p2.LocationAccess.IsDeleted == 0) ==
            p2.Select(p2.LocationAccess.ObjectID.Count()).Where(p2.ObjectID == p.ObjectID & p2.LocationAccess.IsDeleted == 0 & locationCondition));
    }

    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }

    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, Security.Decrypt(Request["TYPE"]),false,false);
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        string strLocation = "";
        string strEquipment = "";
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //Guid objectId = (Guid)gridResults.DataKeys[e.Row.RowIndex][0];
            //OPosition position = TablesLogic.tPosition.Load(objectId);
            //foreach (OLocation location in position.LocationAccess)
            //    strLocation = strLocation == "" ? strLocation + location.ObjectName : strLocation + ", " + location.ObjectName;
            //foreach (OEquipment equipment in position.EquipmentAccess)
            //    strEquipment = strEquipment == "" ? strEquipment + equipment.ObjectName : strEquipment + ", " + equipment.ObjectName;
            //e.Row.Cells[6].Text = strLocation;
            //e.Row.Cells[7].Text = strEquipment;
        }        
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
            meta:resourcekey="panelMainResource3">
        <web:search runat="server" ID="panel" Caption="Position" GridViewID="gridResults" EditButtonVisible="false"
            BaseTable="tPosition" OnSearch="panel_Search" meta:resourcekey="panelResource1"
            AutoSearchOnLoad="true" SearchTextBoxHint="E.g. Position Name, Role Name" 
            MaximumNumberOfResults="300" SearchTextBoxPropertyNames="ObjectName,Role.RoleName"
            AdvancedSearchPanelID="panelAdvanced"
            OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">--%>
                <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" 
                        Caption="Select Location" ToolTip="Use this to select the location that this work applies to."
                        OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                        meta:resourcekey="treeLocationResource3" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode" />
                    <ui:UIFieldTreeList ID="treeEquipment" runat="server" Caption="Select Equipment"
                        OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                        meta:resourcekey="treeEquipmentResource3" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTextBox runat="server" ID="txtPositionName" PropertyName="ObjectName"
                        Caption="Position Name" InternalControlWidth="95%" 
                        meta:resourcekey="txtPositionNameResource3" />
                    <ui:UIFieldListBox runat="server" ID="listRoleCodes" PropertyName="RoleID" Caption="Role"
                        meta:resourcekey="ddlRoleCodeResource3" />
                    <ui:UIFieldTextBox runat="server" ID="txtUser" PropertyName="PermanentUsers.User.ObjectName" 
                        Caption="User" InternalControlWidth="95%" SearchType="Like" meta:resourcekey="txtUserResource3" />
                </ui:UIPanel>
                <%--</ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">--%>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                        Width="100%" OnRowDataBound="gridResults_RowDataBound" 
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
                        style="clear:both;">
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
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Position" 
                                meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Role.RoleName" HeaderText="Role Name" 
                                meta:resourcekey="UIGridViewBoundColumnResource10" PropertyName="Role.RoleName" 
                                ResourceAssemblyName="" SortExpression="Role.RoleName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="LocationAccess" HeaderText="Location" 
                                meta:resourcekey="UIGridViewBoundColumnResource11" 
                                PropertyName="LocationAccessText" ResourceAssemblyName="" 
                                SortExpression="LocationAccessText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EquipmentAccess" HeaderText="Equipment" 
                                meta:resourcekey="UIGridViewBoundColumnResource12" 
                                PropertyName="EquipmentAccessText" ResourceAssemblyName="" 
                                SortExpression="EquipmentAccessText">
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
