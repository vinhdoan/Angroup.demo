<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (e.CustomCondition == null)
            e.CustomCondition = TablesLogic.tStoreStockTake.StoreID.In(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null))
                | (TablesLogic.tStoreStockTake.StoreID == null & TablesLogic.tStoreStockTake.CurrentActivity.Users.ObjectID == AppSession.User.UserBaseID);
    }

    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null), true);
    }
    
    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (StoreID.Control.SelectedValue != "")
            StoreBinList.Bind(TablesLogic.tStoreBin[TablesLogic.tStoreBin.StoreID == new Guid(StoreID.Control.SelectedValue)]);
        else StoreBinList.Items.Clear();
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
        <web:search runat="server" ID="panel" Caption="Stock Take" GridViewID="gridResults" EditButtonVisible="false" meta:resourcekey="panelResource1" AssignedCheckboxVisible="true"
            ObjectPanelID="tabSearch" BaseTable="tStoreStockTake" OnSearch="panel_Search" SearchType="ObjectQuery" OnPopulateForm="panel_PopulateForm"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" 
                meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    CssClass="div-form" meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                    <ui:UIFieldDropdownlist runat="server" ID="StoreID" PropertyName="StoreID" Caption="Store"
                        OnSelectedIndexChanged="StoreID_SelectedIndexChanged" 
                        meta:resourcekey="StoreIDResource1" />
                    <ui:UIFieldDropDownList runat="server" ID="StoreBinList" PropertyName="StoreBins.ObjectID"
                        Rows="8" meta:resourcekey="StoreBinListResource1" Caption="Bin" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    CssClass="div-form" meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                    <ui:UIGridView runat="server" ID="gridResults" BindObjectsToRows="True" KeyName="ObjectID"
                        Width="100%" AjaxPostBack="False" IsModifiedByAjax="False" 
                        SortExpression="ObjectNumber desc" meta:resourcekey="gridResultsResource1" 
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
                        style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="DeleteObject" CommandText="Delete Selected" 
                                ConfirmText="Are you sure you wish to delete the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewBoundColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewBoundColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                ConfirmText="Are you sure you wish to delete this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourceKey="UIGridViewBoundColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" 
                                HeaderText="Stockt Take Number" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="ObjectNumber" 
                                ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Store.ObjectName" HeaderText="Store" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" 
                                PropertyName="Store.ObjectName" ResourceAssemblyName="" 
                                SortExpression="Store.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="StoreStockTakeStartDateTime" 
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Start Date" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" 
                                PropertyName="StoreStockTakeStartDateTime" ResourceAssemblyName="" 
                                SortExpression="StoreStockTakeStartDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="StoreStockTakeEndDateTime" 
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="End Date" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" 
                                PropertyName="StoreStockTakeEndDateTime" ResourceAssemblyName="" 
                                SortExpression="StoreStockTakeEndDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource8" 
                                PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                ResourceName="Resources.WorkflowStates" 
                                SortExpression="CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" 
                                    HeaderText="Assigned User(s)" 
                                    PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    HeaderText="Assigned Position(s)" 
                                    
                                    PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
