<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
    }


    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition =
                    TablesLogic.tBudget.ObjectID.In(OBudget.GetAccessibleBudgetIDs(location));
            else
                e.CustomCondition = Query.False;
        }
        else
        {
            // If no locations are selected
            // 
            TUser user = TablesLogic.tUser;
            e.CustomCondition =
                TablesLogic.tBudget.ObjectID.In(OBudget.GetAccessibleBudgetIDs(AppSession.User, "OBudget"));
        }
        
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, "OBudget");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" meta:resourcekey="panelResource1"
                OnPopulateForm="panel_PopulateForm" 
                Caption="Budget"
                GridViewID="gridResults" BaseTable="tBudget" 
                SearchType="ObjectQuery"
                OnSearch="panel_Search" EditButtonVisible="true"
                 AssignedCheckboxVisible="false"
                SearchAssignedOnly="true"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <!--Tab Search-->
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" 
                            Caption="Location" meta:resourcekey="treeLocationResource1"
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox ID="textBudgetName" runat="server" 
                            Span="Full" PropertyName="ObjectName"
                            Caption="Budget Name" meta:resourcekey="textBudgetNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" meta:resourcekey="textDefaultNumberOfMonthsPerBudgetPeriodResource1"
                            ID="textDefaultNumberOfMonthsPerBudgetPeriod" 
                            PropertyName="DefaultNumberOfMonthsPerBudgetPeriod" 
                            Caption="Number of Months per Budget Period" 
                            CaptionWidth="200px" 
                            SearchType="Range" Span="Half"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" meta:resourcekey="textDefaultNumberOfMonthsPerIntervalResource1"
                            ID="textDefaultNumberOfMonthsPerInterval" 
                            PropertyName="DefaultNumberOfMonthsPerInterval" 
                            Caption="Number of Months per Interval" 
                            CaptionWidth="200px" 
                            SearchType="Range" 
                            Span="Half"></ui:UIFieldTextBox>
                    </ui:UITabView>
                    <!--Tab Result-->
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" Caption="Budget" 
                            KeyName="ObjectID" Width="100%" meta:resourcekey="gridResultsResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" 
                                    ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn 
                                    HeaderText="Budget Name" 
                                    PropertyName="ObjectName" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn 
                                    HeaderText="Default Number of Months per Budget Period" 
                                    PropertyName="DefaultNumberOfMonthsPerBudgetPeriod" meta:resourcekey="UIGridViewBoundColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn 
                                    HeaderText="Default Number of Months per Interval" 
                                    PropertyName="DefaultNumberOfMonthsPerInterval" meta:resourcekey="UIGridViewBoundColumnResource3">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
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
