<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
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
        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null));

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }

    
    /// <summary>
    /// Searches the form.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OStoreAdjust"))
        {
            foreach (OLocation location in position.LocationAccess)
            {
                if (e.CustomCondition == null)
                    e.CustomCondition = TablesLogic.tStoreAdjust.Store.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                else
                    e.CustomCondition = e.CustomCondition | TablesLogic.tStoreAdjust.Store.Location.HierarchyPath.Like(location.HierarchyPath + "%");
            }
        }
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Adjustment" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tStoreAdjust" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery"
                meta:resourcekey="panelResource1" OnSearch="panel_Search"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTextBox runat='server' ID="ObjectNumber" PropertyName="ObjectNumber" Caption="Adjustment Number"
                            Span="Half" meta:resourcekey="ObjectNumberResource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldDropDownList runat='server' ID='StoreID' PropertyName="StoreID" Caption="Store Name"
                            ToolTip="The store name as displayed on the screen." meta:resourcekey="StoreIDResource1" />
                        <ui:UIFieldTextBox runat='server' ID="Description" PropertyName="Description" Caption="Remarks"
                            meta:resourcekey="DescriptionResource1" InternalControlWidth="95%" />
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" SortExpression="ObjectNumber"
                            KeyName="ObjectID" meta:resourcekey="gridResultsResource1" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
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
                                    CommandText="Edit" ImageUrl="~/images/edit.gif" 
                                    meta:resourceKey="UIGridViewColumnResource1">
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" 
                                    HeaderText="Adjustment Number" meta:resourceKey="UIGridViewColumnResource4" 
                                    PropertyName="ObjectNumber" ResourceAssemblyName="" 
                                    SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Store.ObjectName" HeaderText="Store Name" 
                                    meta:resourceKey="UIGridViewColumnResource5" PropertyName="Store.ObjectName" 
                                    ResourceAssemblyName="" SortExpression="Store.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Remarks" 
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="Description" 
                                    ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" 
                                    HeaderText="Created Date/Time" 
                                    PropertyName="CreatedDateTime" ResourceAssemblyName="" 
                                    DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                                    SortExpression="CreatedDateTime">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                    HeaderText="Status" meta:resourceKey="UIGridViewColumnResource7" 
                                    PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                    ResourceName="Resources.WorkflowStates" 
                                    SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" 
                                    HeaderText="Assigned User(s)" 
                                    PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    HeaderText="Assigned Position(s)" 
                                    
                                    PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2">
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
