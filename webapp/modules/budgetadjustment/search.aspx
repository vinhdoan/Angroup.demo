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
        dropBudget.Bind(OBudget.GetAccessibleBugets(AppSession.User, null, "OBudgetAdjustment"));
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
                e.CustomCondition = TablesLogic.tBudgetAdjustment.Budget.ObjectID.In(OBudget.GetAccessibleBudgetIDs(location));
            else
                e.CustomCondition = Query.False;
        }
        else
        {
            // If no locations are selected
            // 
            e.CustomCondition =
                TablesLogic.tBudgetAdjustment.Budget.ObjectID.In(OBudget.GetAccessibleBudgetIDs(AppSession.User, "OBudgetAdjustment"));
        }


    }


    /// <summary>
    /// Occurs when user mades selection on the budget drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        Guid? budgetId = null;
        if(dropBudget.SelectedValue!="")
            budgetId= new Guid(dropBudget.SelectedValue);

        dropBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetId, null));
    }

    
    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }
    

    /// <summary>
    /// Occurs when the user selects a different node in the location tree.
    /// When that happens, update the budget list for the selected location.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        Guid? locationID = null;
        if (treeLocation.SelectedValue != "")
            locationID = new Guid(treeLocation.SelectedValue);

        dropBudget.Bind(OBudget.GetBudgetsByLocationID(locationID, null));
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
            <web:search runat="server" ID="panel" SearchType="ObjectQuery" Caption="Budget Adjustment" EditButtonVisible="false"
                GridViewID="gridResults" OnPopulateForm="panel_PopulateForm" BaseTable="tBudgetAdjustment" SearchAssignedOnly='false'
                OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabviewSearch" Caption="Search" meta:resourcekey="uitabviewSearchResource1">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeLocation_SelectedNodeChanged" meta:resourcekey="treeLocationResource1" >
                        </ui:UIFieldTreeList>
                        <ui:UIFieldDropDownList ID="dropBudget" runat="server" Caption="Budget" PropertyName="BudgetID"
                            OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" meta:resourcekey="dropBudgetResource1" 
                            Span="Half" />
                        <ui:UIFieldDropDownList runat="server" ID="dropBudgetPeriod" Caption="Budget Period" PropertyName="BudgetPeriodID" meta:resourcekey="dropBudgetPeriodResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="textAdjustmentDescription" runat="server" Caption="Description"
                            PropertyName="Description" ToolTip="Description of the readjustment"  meta:resourcekey="textAdjustmentDescriptionResource1"/>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" 
                            Caption="Status" meta:resourcekey="StatusIDResource1">
                        </ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabviewResults" Caption="Results"  meta:resourcekey="uitabviewResultsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" meta:resourcekey="gridResultsResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" meta:resourcekey="UIGridViewButtonColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" meta:resourcekey="UIGridViewButtonColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Adjustment Number" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" HeaderText="Budget Name" meta:resourcekey="UIGridViewBoundColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BudgetPeriod.ObjectName" HeaderText="Budget Period Name" meta:resourcekey="UIGridViewBoundColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" ResourceName="Resources.WorkflowStates"
                                    HeaderText="Current Status" meta:resourcekey="UIGridViewBoundColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Created Date/Time" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" meta:resourcekey="UIGridViewBoundColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CreatedUser" HeaderText="Created By" meta:resourcekey="UIGridViewBoundColumnResource6">
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
