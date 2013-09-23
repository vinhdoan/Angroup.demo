<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
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
        return new LocationTreePopulaterForCapitaland(null, true, true, "OBudget",false,false);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" 
                OnPopulateForm="panel_PopulateForm" Caption="Budget" 
                GridViewID="gridResults" BaseTable="tBudget" SearchType="ObjectQuery"
                OnSearch="panel_Search" EditButtonVisible="true" 
                AutoSearchOnLoad="true" SearchTextBoxHint="Budget Name" 
                MaximumNumberOfResults="30" SearchTextBoxPropertyNames="ObjectName"
                AdvancedSearchPanelID="panelAdvanced"
                AssignedCheckboxVisible="false"
                SearchAssignedOnly="true" meta:resourcekey="panelResource1"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <!--Tab Search-->
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" 
                            Caption="Location" 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                            meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <%--<ui:UIFieldTextBox ID="textBudgetName" runat="server" PropertyName="ObjectName"
                            Caption="Budget Name" InternalControlWidth="95%" 
                            meta:resourcekey="textBudgetNameResource1"></ui:UIFieldTextBox>--%>
                        <ui:UIFieldTextBox runat="server" 
                            ID="textDefaultNumberOfMonthsPerBudgetPeriod" 
                            PropertyName="DefaultNumberOfMonthsPerBudgetPeriod" 
                            Caption="Number of Months per Budget Period" 
                            CaptionWidth="200px" 
                            SearchType="Range" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textDefaultNumberOfMonthsPerBudgetPeriodResource1"></ui:UIFieldTextBox><br />
                        <ui:UIFieldTextBox runat="server" 
                            ID="textDefaultNumberOfMonthsPerInterval" 
                            PropertyName="DefaultNumberOfMonthsPerInterval" 
                            Caption="Number of Months per Interval" 
                            CaptionWidth="200px" 
                            SearchType="Range" 
                            Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textDefaultNumberOfMonthsPerIntervalResource1"></ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <!--Tab Result-->
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >--%>
                        <ui:UIGridView runat="server" ID="gridResults" Caption="Budget" 
                            KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                            style="clear:both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Budget Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DefaultNumberOfMonthsPerBudgetPeriod" 
                                    HeaderText="Default Number of Months per Budget Period" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="DefaultNumberOfMonthsPerBudgetPeriod" ResourceAssemblyName="" 
                                    SortExpression="DefaultNumberOfMonthsPerBudgetPeriod">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DefaultNumberOfMonthsPerInterval" 
                                    HeaderText="Default Number of Months per Interval" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="DefaultNumberOfMonthsPerInterval" ResourceAssemblyName="" 
                                    SortExpression="DefaultNumberOfMonthsPerInterval">
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
