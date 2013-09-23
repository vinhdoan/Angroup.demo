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
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        //labelUserLicenseCount.Text = OUserBase.GetUserLicenseText();
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            e.CustomCondition = e.CustomCondition & TablesLogic.tTenantLease.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        
        List<ColumnOrder> orderColumns = new List<ColumnOrder>();
        orderColumns.Add(TablesLogic.tTenantLease.ModifiedDateTime.Desc);
        e.CustomSortOrder = orderColumns;
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
        ddlStatus.Bind(OTenantLease.dtStatusList(), "Status", "Abr");
    }

    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[9].Text = OTenantLease.TranslateStatusName(e.Row.Cells[9].Text);
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="formMain" BorderStyle="NotSet" meta:resourcekey="formMainResource2">
        <web:search runat="server" ID="panel" Caption="Tenant Lease" GridViewID="gridResults"
            BaseTable="tTenantLease" EditButtonVisible="false" SearchType="ObjectQuery" AutoSearchOnLoad="false"
            MaximumNumberOfResults="300" AdvancedSearchPanelID="panelAdvanced" SearchTextBoxHint="Tenant Name, Location (Unit No.)"
            AdvancedSearchOnLoad="false" SearchTextBoxPropertyNames="Tenant.ObjectName,Location.ObjectName,ShopName"
            OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search" meta:resourcekey="panelResource1">
        </web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" 
                        BorderStyle="NotSet">--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <ui:UIFieldTreeList ID="treeLocation" runat="server" Caption="Location" PropertyName=""
                    ShowCheckBoxes="None" TreeValueMode="SelectedNode" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                    meta:resourcekey="treeLocationResource1">
                </ui:UIFieldTreeList>
                <%--<ui:UIFieldTextBox runat="server" ID="txtTenantName" Caption="Tenant Name" PropertyName="Tenant.ObjectName" InternalControlWidth="95%" meta:resourcekey="txtTenantNameResource1"></ui:UIFieldTextBox>--%>
                <ui:UIFieldDateTime runat="server" ID="StartDate" Caption="Start Date" PropertyName="LeaseStartDate"
                    SearchType="Range" meta:resourcekey="StartDateResource1" ShowDateControls="True">
                </ui:UIFieldDateTime>
                <ui:UIFieldDateTime runat="server" ID="EndDate" Caption="End Date" PropertyName="LeaseEndDate"
                    SearchType="Range" meta:resourcekey="EndDateResource1" ShowDateControls="True">
                </ui:UIFieldDateTime>
                <ui:UIFieldDropDownList runat="server" ID="ddlStatus" Caption="Lease Status" PropertyName="LeaseStatus"
                    meta:resourcekey="ddlStatusResource1">
                </ui:UIFieldDropDownList>
                <ui:UIFieldTextBox ID="LeaseAmosOrgID" runat="server" Caption="Amos Org ID" InternalControlWidth="95%"
                    SearchType="Range" PropertyName="AmosOrgID" meta:resourcekey="LeaseAmosOrgIDResource1" />
                <ui:UIFieldTextBox ID="AmosAssetID" runat="server" Caption="Amos Asset ID" InternalControlWidth="95%"
                    PropertyName="AmosAssetID" SearchType="Range" meta:resourcekey="AmosAssetIDResource1" />
                <ui:UIFieldTextBox ID="AmosSuiteID" runat="server" Caption="Amos Suite ID" InternalControlWidth="95%"
                    PropertyName="AmosSuiteID" SearchType="Range" meta:resourcekey="AmosSuiteIDResource1" />
                <ui:UIFieldTextBox ID="AmosLeaseID" runat="server" Caption="Amos Lease ID" InternalControlWidth="95%"
                    PropertyName="AmosLeaseID" SearchType="Range" meta:resourcekey="AmosLeaseIDResource1" />
                <ui:UIFieldRadioList runat="server" Caption="Amos Instance" ID="AmosInstanceID" RepeatColumns="3" PropertyName="AMOSInstanceID"
                    RepeatDirection="Vertical" TextAlign="Right">
                    <Items>
                        <asp:ListItem Value="">All</asp:ListItem>
                        <asp:ListItem Value="Amos_SG_RCS_Retail">Retail</asp:ListItem>
                        <asp:ListItem Value="Amos_SG_RCS_Office">Office</asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>    
            </ui:UIPanel>
            <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" 
                        BorderStyle="NotSet">--%>
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                meta:resourcekey="gridResultsResource1" Width="100%" DataKeyNames="ObjectID"
                GridLines="Both" RowErrorColor="" Style="clear: both;" OnRowDataBound="gridResults_RowDataBound">
                <PagerSettings Mode="NumericFirstLast" />
                <Commands>
                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                        CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                </Commands>
                <Columns>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                        meta:resourceKey="UIGridViewColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
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
                    <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" PropertyName="Location.Path"
                        meta:resourcekey="UIGridViewBoundColumnResource1" ResourceAssemblyName="" SortExpression="Location.Path">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Tenant.ObjectName" HeaderText="Tenant's Name"
                        PropertyName="Tenant.ObjectName" ResourceAssemblyName="" meta:resourcekey="UIGridViewBoundColumnResource2"
                        SortExpression="Tenant.ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="ShopName" HeaderText="Shop Name" PropertyName="ShopName"
                        ResourceAssemblyName="" SortExpression="ShopName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="LeaseStartDate" HeaderText="Start Date" PropertyName="LeaseStartDate"
                        ResourceAssemblyName="" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource3"
                        SortExpression="LeaseStartDate">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="LeaseEndDate" HeaderText="End Date" PropertyName="LeaseEndDate"
                        ResourceAssemblyName="" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource4"
                        SortExpression="LeaseEndDate">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="LeaseStatus" HeaderText="Status" PropertyName="LeaseStatus"
                        ResourceAssemblyName="" meta:resourcekey="UIGridViewBoundColumnResource5" SortExpression="LeaseStatus">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="" HeaderText="Active?" PropertyName="Location.IsActiveText"
                        ResourceAssemblyName="" SortExpression="Location.IsActiveText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="AmosAssetID" HeaderText="Amos Asset ID" PropertyName="AmosAssetID"
                        ResourceAssemblyName="" SortExpression="AmosAssetID" meta:resourcekey="UIGridViewBoundColumnResource6">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="AmosOrgID" HeaderText="Amos Org ID" PropertyName="AmosOrgID"
                        ResourceAssemblyName="" SortExpression="AmosOrgID" meta:resourcekey="UIGridViewBoundColumnResource7">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="AmosSuiteID" HeaderText="Amos Suite ID" PropertyName="AmosSuiteID"
                        ResourceAssemblyName="" SortExpression="AmosSuiteID" meta:resourcekey="UIGridViewBoundColumnResource8">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="AmosLeaseID" HeaderText="Amos Lease ID" PropertyName="AmosLeaseID"
                        ResourceAssemblyName="" SortExpression="AmosLeaseID" meta:resourcekey="UIGridViewBoundColumnResource9">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="AMOSInstanceID" HeaderText="Amos InstanceID"
                        PropertyName="AMOSInstanceID" ResourceAssemblyName="" SortExpression="AMOSInstanceID">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="updatedOn" HeaderText="AMOS Updated On" PropertyName="updatedOn"
                        ResourceAssemblyName="" SortExpression="updatedOn" DataFormatString="{0:dd-MMM-yyyy}"
                        meta:resourcekey="UIGridViewBoundColumnResource10">
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
