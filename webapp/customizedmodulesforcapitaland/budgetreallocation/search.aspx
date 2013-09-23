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
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(Object sender, EventArgs e)
    {
        dropFromBudget.Bind(OBudget.GetAccessibleBugets(AppSession.User, null, "OBudgetReallocation"));
        dropToBudget.Bind(OBudget.GetAccessibleBugets(AppSession.User, null, "OBudgetReallocation"));
        treeLocation.PopulateTree();

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
            {
                List<Guid> budgetIds = OBudget.GetAccessibleBudgetIDs(location);
                e.CustomCondition =
                    (TablesLogic.tBudgetReallocation.FromBudgetID.In(budgetIds) &
                    TablesLogic.tBudgetReallocation.ToBudgetID.In(budgetIds));
            }
            else
                e.CustomCondition = Query.False;
        }
        else
        {
            List<Guid> budgetIds = OBudget.GetAccessibleBudgetIDs(AppSession.User, "OBudgetReallocation");
            e.CustomCondition =
                (TablesLogic.tBudgetReallocation.FromBudgetID.In(budgetIds) &
                TablesLogic.tBudgetReallocation.ToBudgetID.In(budgetIds));
        }
    }


    /// <summary>
    /// Occurs when the user selects an item in the From Budget
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropFromBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        Guid? budgetId = null;
        if (dropFromBudget.SelectedValue != "")
            budgetId = new Guid(dropFromBudget.SelectedValue);

        dropFromBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetId, null));
    }

    /// <summary>
    /// Occurs when the user selects an item in the To Budget
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropToBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        Guid? budgetId = null;
        if (dropToBudget.SelectedValue != "")
            budgetId = new Guid(dropToBudget.SelectedValue);

        dropToBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetId, null));
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
            <web:search runat="server" ID="panel" Caption="Budget Reallocation" SearchType="ObjectQuery"
                GridViewID="gridResults" OnPopulateForm="panel_PopulateForm" EditButtonVisible="false" AssignedCheckboxVisible="true"
                BaseTable="tBudgetReallocation" OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabviewSearch" Caption="Search" meta:resourcekey="uitabviewSearchResource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList Caption="Location" runat="server" ID="treeLocation" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldDropDownList ID="dropFromBudget" runat="server" Caption="From Budget" PropertyName="FromBudgetID"
                            Span="Half" OnSelectedIndexChanged="dropFromBudget_SelectedIndexChanged" meta:resourcekey="dropFromBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropFromBudgetPeriod" Caption="From Budget Period" PropertyName="FromBudgetPeriodID" Span="Half" meta:resourcekey="dropFromBudgetPeriodResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList ID="dropToBudget" runat="server" Caption="To Budget" PropertyName="ToBudgetID"
                            Span="Half" OnSelectedIndexChanged="dropToBudget_SelectedIndexChanged" meta:resourcekey="dropToBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropToBudgetPeriod" Caption="To Budget Period" PropertyName="ToBudgetPeriodID" Span="Half" meta:resourcekey="dropToBudgetPeriodResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="textAdjustmentDescription" runat="server" Caption="Description"
                            PropertyName="Description" ToolTip="Description of the reallocation" meta:resourcekey="textAdjustmentDescriptionResource1" InternalControlWidth="95%" />
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="StatusIDResource1"></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabviewResults" Caption="Results" meta:resourcekey="uitabviewResultsResource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" 
                            meta:resourcekey="gridResultsResource1" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
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
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource6">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Budget Reallocation Number" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="FromBudget.ObjectName" HeaderText="From Budget" meta:resourceKey="UIGridViewBoundColumnResource2" PropertyName="FromBudget.ObjectName" ResourceAssemblyName="" SortExpression="FromBudget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="FromBudgetPeriod.ObjectName" HeaderText="From Bugdet Period" meta:resourceKey="UIGridViewBoundColumnResource3" PropertyName="FromBudgetPeriod.ObjectName" ResourceAssemblyName="" SortExpression="FromBudgetPeriod.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ToBudget.ObjectName" HeaderText="To Budget" meta:resourceKey="UIGridViewBoundColumnResource4" PropertyName="ToBudget.ObjectName" ResourceAssemblyName="" SortExpression="ToBudget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ToBudgetPeriod.ObjectName" HeaderText="To Bugdet Period" meta:resourceKey="UIGridViewBoundColumnResource5" PropertyName="ToBudgetPeriod.ObjectName" ResourceAssemblyName="" SortExpression="ToBudgetPeriod.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourceKey="UIGridViewBoundColumnResource6" PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Current Status" meta:resourceKey="UIGridViewBoundColumnResource7" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" 
                                    HeaderText="Assigned User(s)" 
                                    PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource8">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    HeaderText="Assigned Position(s)" 
                                    
                                    PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource9">
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
