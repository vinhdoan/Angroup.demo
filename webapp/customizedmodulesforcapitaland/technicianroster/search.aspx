<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
     protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
        ddlYear.Bind(OTechnicianRoster.BindYear(), "Year", "Year");
        ddlMonth.Bind(OTechnicianRoster.BindMonth(), "MonthName", "Month");
        ddlYear.SelectedValue = Convert.ToString(DateTime.Today.Year);
        ddlMonth.SelectedValue = Convert.ToString(DateTime.Today.Month);
    }
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, true, Security.Decrypt(Request["TYPE"]), false, false);
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tTechnicianRoster.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "")
        {
            e.CustomCondition = Query.False;
            foreach (OPosition position in AppSession.User.Positions)
                foreach (OLocation location in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tTechnicianRoster.Location.HierarchyPath.Like(location.HierarchyPath + "%");
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Technician Roster" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tTechnicianRoster" OnPopulateForm="panel_PopulateForm"
                SearchType="ObjectQuery" OnSearch="panel_Search"
                meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                       <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                                ShowCheckBoxes="None"
                                TreeValueMode="SelectedNode" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1">
                         </ui:UIFieldTreeList>
                         <ui:UIFieldDropDownList runat="server" PropertyName="Year" ID="ddlYear" Caption="Year" Span="Half" meta:resourcekey="ddlYearResource1"></ui:UIFieldDropDownList>
                         <ui:UIFieldDropDownList runat="server" PropertyName="Month" ID ="ddlMonth" Caption="Month" Span="Half" meta:resourcekey="ddlMonthResource1"></ui:UIFieldDropDownList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" meta:resourcekey="gridResultsResource1" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Year" HeaderText="Year" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Year" ResourceAssemblyName="" SortExpression="Year">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Month" HeaderText="Month" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Month" ResourceAssemblyName="" SortExpression="Month">
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
