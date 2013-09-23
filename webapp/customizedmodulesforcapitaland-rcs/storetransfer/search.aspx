<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        FromStoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null));
        ToStoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null));

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }

    /// <summary>
    /// Adds custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        ExpressionCondition cond1 = Query.False;
        ExpressionCondition cond2 = Query.False;

        foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OStoreTransfer"))
        {
            foreach (OLocation location in position.LocationAccess)
            {
                cond1 = cond1 | TablesLogic.tStoreTransfer.FromStore.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                //cond2 = cond2 | TablesLogic.tStoreTransfer.ToStore.Location.HierarchyPath.Like(location.HierarchyPath + "%");
            }
        }
        e.CustomCondition = cond1 /*& cond2*/;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Transfer" GridViewID="gridResults"
            BaseTable="tStoreTransfer" EditButtonVisible="false" SearchType="ObjectQuery"
            AutoSearchOnLoad="true" MaximumNumberOfResults="30" AdvancedSearchPanelID="panelAdvanced"
            SearchTextBoxHint="Store Transfer Number, Description, Status" AdvancedSearchOnLoad="false"
            SearchTextBoxPropertyNames="ObjectNumber,Description,CurrentActivity.ObjectName"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnSearch="panel_Search">
        </web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch"
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search"
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <ui:UIFieldTextBox runat='server' ID="ObjectNumber" PropertyName="ObjectNumber" Caption="Transfer Number"
                    Span="Half" meta:resourcekey="ObjectNumberResource1" InternalControlWidth="95%" />
                <ui:UIFieldDropDownList runat='server' ID='FromStoreID' PropertyName="FromStoreID"
                    Caption="From Store" ToolTip="The store from which items are transferred." meta:resourcekey="FromStoreIDResource1" />
                <ui:UIFieldDropDownList runat='server' ID='ToStoreID' PropertyName="ToStoreID" Caption="To Store"
                    ToolTip="The store to which items are transferred." meta:resourcekey="ToStoreIDResource1" />
                <ui:UIFieldTextBox runat='server' ID="Description" PropertyName="Description" Caption="Remarks"
                    meta:resourcekey="DescriptionResource1" InternalControlWidth="95%" />
                <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                    Caption="Status" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
            </ui:UIPanel>
            <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results"
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" SortExpression="ObjectNumber"
                KeyName="ObjectID" meta:resourcekey="gridResultsResource1" Width="100%" DataKeyNames="ObjectID"
                GridLines="Both" RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Commands>
                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                        CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                </Commands>
                <Columns>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" CommandText="Edit"
                        ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
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
                    <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Transfer Number"
                        meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" ResourceAssemblyName=""
                        SortExpression="ObjectNumber">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="FromStoreTypeText" HeaderText="From Type" meta:resourcekey="UIGridViewBoundColumnResource1"
                        PropertyName="FromStoreTypeText" ResourceAssemblyName="" SortExpression="FromStoreTypeText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="FromStoreText" HeaderText="From" meta:resourceKey="UIGridViewColumnResource5"
                        PropertyName="FromStoreText" ResourceAssemblyName="" SortExpression="FromStoreText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="ToStoreTypeText" HeaderText="From Type" meta:resourcekey="UIGridViewBoundColumnResource2"
                        PropertyName="ToStoreTypeText" ResourceAssemblyName="" SortExpression="ToStoreTypeText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="ToStoreText" HeaderText="To" meta:resourceKey="UIGridViewColumnResource6"
                        PropertyName="ToStoreText" ResourceAssemblyName="" SortExpression="ToStoreText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Remarks" meta:resourceKey="UIGridViewColumnResource7"
                        PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" HeaderText="Created Date/Time"
                        PropertyName="CreatedDateTime" ResourceAssemblyName="" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                        SortExpression="CreatedDateTime">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status"
                        meta:resourceKey="UIGridViewColumnResource8" PropertyName="CurrentActivity.ObjectName"
                        ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" HeaderText="Assigned User(s)"
                        PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" SortExpression="CurrentActivity.AssignedUserText"
                        meta:resourcekey="UIGridViewBoundColumnResource3">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText"
                        HeaderText="Assigned Position(s)" PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText"
                        ResourceAssemblyName="" SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText"
                        meta:resourcekey="UIGridViewBoundColumnResource4">
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