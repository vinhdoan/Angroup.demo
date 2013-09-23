<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Budget Reallocation" SearchType="ObjectQuery"
                GridViewID="gridResults" OnPopulateForm="panel_PopulateForm" EditButtonVisible="false"
                BaseTable="tBudgetReallocation" OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabviewSearch" Caption="Search" meta:resourcekey="uitabviewSearchResource1">
                        <ui:UIFieldTreeList Caption="Location" runat="server" ID="treeLocation" meta:resourcekey="treeLocationResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldDropDownList ID="dropFromBudget" runat="server" Caption="From Budget" PropertyName="FromBudgetID"
                            Span="Half" OnSelectedIndexChanged="dropFromBudget_SelectedIndexChanged" meta:resourcekey="dropFromBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropFromBudgetPeriod" Caption="From Budget Period" PropertyName="FromBudgetPeriodID" Span="Half" meta:resourcekey="dropFromBudgetPeriodResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList ID="dropToBudget" runat="server" Caption="To Budget" PropertyName="ToBudgetID"
                            Span="Half" OnSelectedIndexChanged="dropToBudget_SelectedIndexChanged" meta:resourcekey="dropToBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropToBudgetPeriod" Caption="To Budget Period" PropertyName="ToBudgetPeriodID" Span="Half" meta:resourcekey="dropToBudgetPeriodResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="textAdjustmentDescription" runat="server" Caption="Description"
                            PropertyName="Description" ToolTip="Description of the reallocation" meta:resourcekey="textAdjustmentDescriptionResource1" />
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="StatusIDResource1">
                        </ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabviewResults" Caption="Results" meta:resourcekey="uitabviewResultsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" meta:resourcekey="gridResultsResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Budget Reallocation Number" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FromBudget.ObjectName" HeaderText="From Budget" meta:resourcekey="UIGridViewBoundColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FromBudgetPeriod.ObjectName" HeaderText="From Bugdet Period" meta:resourcekey="UIGridViewBoundColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ToBudget.ObjectName" HeaderText="To Budget" meta:resourcekey="UIGridViewBoundColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ToBudgetPeriod.ObjectName" HeaderText="To Bugdet Period" meta:resourcekey="UIGridViewBoundColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" ResourceName="Resources.WorkflowStates"
                                    HeaderText="Current Status" meta:resourcekey="UIGridViewBoundColumnResource7">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
