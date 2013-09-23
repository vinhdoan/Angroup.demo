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
        return new LocationTreePopulaterForCapitaland(null, true, true, Security.Decrypt(Request["TYPE"]),false,false);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
            <web:search runat="server" ID="panel" SearchType="ObjectQuery" Caption="Budget Adjustment" EditButtonVisible="false"
                GridViewID="gridResults" OnPopulateForm="panel_PopulateForm" BaseTable="tBudgetAdjustment" AssignedCheckboxVisible="true"
                OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabviewSearch" Caption="Search" meta:resourcekey="uitabviewSearchResource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeLocation_SelectedNodeChanged" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" >
                        </ui:UIFieldTreeList>
                        <ui:UIFieldDropDownList ID="dropBudget" runat="server" Caption="Budget" PropertyName="BudgetID"
                            OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" meta:resourcekey="dropBudgetResource1" 
                            Span="Half" />
                        <ui:UIFieldDropDownList runat="server" ID="dropBudgetPeriod" Caption="Budget Period" PropertyName="BudgetPeriodID" meta:resourcekey="dropBudgetPeriodResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="textAdjustmentDescription" runat="server" Caption="Description"
                            PropertyName="Description" ToolTip="Description of the readjustment"  meta:resourcekey="textAdjustmentDescriptionResource1" InternalControlWidth="95%"/>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" 
                            Caption="Status" meta:resourcekey="StatusIDResource1"></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabviewResults" Caption="Results"  meta:resourcekey="uitabviewResultsResource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" 
                            meta:resourcekey="gridResultsResource1" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Adjustment Number" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Budget.ObjectName" HeaderText="Budget Name" meta:resourceKey="UIGridViewBoundColumnResource2" PropertyName="Budget.ObjectName" ResourceAssemblyName="" SortExpression="Budget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BudgetPeriod.ObjectName" HeaderText="Budget Period Name" meta:resourceKey="UIGridViewBoundColumnResource3" PropertyName="BudgetPeriod.ObjectName" ResourceAssemblyName="" SortExpression="BudgetPeriod.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="VersionName" HeaderText="Version Name" 
                                    PropertyName="VersionName" ResourceAssemblyName="" SortExpression="VersionName" 
                                    meta:resourcekey="UIGridViewBoundColumnResource7">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Current Status" meta:resourceKey="UIGridViewBoundColumnResource4" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
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
                                <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Created Date/Time" meta:resourceKey="UIGridViewBoundColumnResource5" PropertyName="CreatedDateTime" ResourceAssemblyName="" SortExpression="CreatedDateTime">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedUser" HeaderText="Created By" meta:resourceKey="UIGridViewBoundColumnResource6" PropertyName="CreatedUser" ResourceAssemblyName="" SortExpression="CreatedUser">
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
