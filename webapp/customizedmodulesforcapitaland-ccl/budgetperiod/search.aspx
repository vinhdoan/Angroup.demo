<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

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
        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }

    }


    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        ExpressionCondition condition = Query.True;
            //UIBinder.BuildCondition(TablesLogic.tBudgetPeriod, panelMain);
        ExpressionCondition havingCondition = null;
        
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
            {
                TBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod;
                TBudgetPeriod budgetPeriod2 = new TBudgetPeriod();

                condition = condition &
                    budgetPeriod.Budget.ApplicableLocations.HierarchyPath.Like(location.HierarchyPath + "%");
                havingCondition = 
                    budgetPeriod.Budget.ApplicableLocations.ObjectID.Count() <=
                    budgetPeriod2.Select(budgetPeriod2.Budget.ApplicableLocations.ObjectID.Count()).Where(budgetPeriod2.ObjectID == budgetPeriod.ObjectID);
            }
        }
        else
        {
            // If no locations are selected
            // 
            TBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod;
            TBudgetPeriod budgetPeriod2 = new TBudgetPeriod();

            TUser user = TablesLogic.tUser;
            condition = condition &
                user.Select(user.ObjectID)
                .Where(
                    budgetPeriod.Budget.ApplicableLocations.HierarchyPath.Like(user.Positions.LocationAccess.HierarchyPath + "%") &
                    user.Positions.Role.RoleFunctions.Function.ObjectTypeName == Security.Decrypt(Request["TYPE"]) &
                    user.ObjectID == AppSession.User.ObjectID).Exists();
            
            havingCondition =
                budgetPeriod.Budget.ApplicableLocations.ObjectID.Count() <=
                budgetPeriod2.Select(budgetPeriod2.Budget.ApplicableLocations.ObjectID.Count()).Where(budgetPeriod2.ObjectID == budgetPeriod.ObjectID);
        }

        ExpressionData[] listGroupColumns = new ExpressionData[] 
            {   TablesLogic.tBudgetPeriod.ObjectID,
                TablesLogic.tBudgetPeriod.IsActive,
                TablesLogic.tBudgetPeriod.ObjectName,
                TablesLogic.tBudgetPeriod.Budget.ObjectID,
                TablesLogic.tBudgetPeriod.Budget.ObjectName,
                TablesLogic.tBudgetPeriod.StartDate,
                TablesLogic.tBudgetPeriod.EndDate,
                TablesLogic.tBudgetPeriod.ClosingDate,
                TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName
            };
        List<ColumnOrder> orderColumns = new List<ColumnOrder>();
        orderColumns.Add(TablesLogic.tBudgetPeriod.EndDate.Desc);
        
        e.CustomCondition = condition;
        e.CustomHavingCondition = havingCondition;
        e.CustomGroupBy = listGroupColumns;
        e.CustomSortOrder = orderColumns;
        
        //e.CustomResultTable = 
        //    TablesLogic.tBudgetPeriod.Select(
        //        TablesLogic.tBudgetPeriod.ObjectID,
        //        TablesLogic.tBudgetPeriod.IsActive,
        //        TablesLogic.tBudgetPeriod.ObjectName,
        //        TablesLogic.tBudgetPeriod.Budget.ObjectName.As("Budget.ObjectName"),
        //        TablesLogic.tBudgetPeriod.StartDate,
        //        TablesLogic.tBudgetPeriod.EndDate,
        //        TablesLogic.tBudgetPeriod.ClosingDate,
        //        TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName.As("CurrentActivity.ObjectName"))
        //        .Where(
        //        condition & 
        //        TablesLogic.tBudgetPeriod.IsDeleted == 0)
        //        .GroupBy(
        //        TablesLogic.tBudgetPeriod.ObjectID,
        //        TablesLogic.tBudgetPeriod.IsActive,
        //        TablesLogic.tBudgetPeriod.ObjectName,
        //        TablesLogic.tBudgetPeriod.Budget.ObjectID,
        //        TablesLogic.tBudgetPeriod.Budget.ObjectName,
        //        TablesLogic.tBudgetPeriod.StartDate,
        //        TablesLogic.tBudgetPeriod.EndDate,
        //        TablesLogic.tBudgetPeriod.ClosingDate,
        //        TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName)
        //        .Having(
        //        havingCondition);
        
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "OBudgetPeriod",false,false);
    }

    
    /// <summary>
    /// Occurs when the user clicks on a button in the gridResults grid view.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ShowBudgetView")
        {
            Window.Open("budgetview.aspx?ID=" + HttpUtility.UrlEncode(Security.Encrypt(dataKeys[0].ToString())), "AnacleEAM_Popup");
        }
    }

    
    /// <summary>
    /// Occurs when the gridview is data bound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[5].Text == "0")
                e.Row.Cells[4].Controls[0].Visible = false;
            //Guid objectId = (Guid)gridResults.DataKeys[e.Row.RowIndex][0];
            //OBudgetPeriod bp = TablesLogic.tBudgetPeriod.Load(objectId);
            //if (bp.CurrentActivity != null)
            //{
            //    //e.Row.Cells[12].Text = bp.CurrentActivity.AssignedUserText;
            //    //e.Row.Cells[13].Text = bp.CurrentActivity.AssignedUserPositionsWithUserNamesText;
            //}
            
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[5].Visible = false;
        }
        
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
            <web:search runat="server" ID="panel" Caption="Budget Period" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tBudgetPeriod" AutoSearchOnLoad="true" MaximumNumberOfResults="30" 
                SearchTextBoxPropertyNames="ObjectName" AdvancedSearchPanelID="panelAdvanced"
                SearchTextBoxHint="Budget Period Name" SearchType="ObjectQuery"
                OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                            meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <%--<ui:UIFieldTextBox ID="textBudgetPeriodName" runat="server" PropertyName="ObjectName"
                            Caption="Budget Period Name" InternalControlWidth="95%" 
                            meta:resourcekey="textBudgetPeriodNameResource1"></ui:UIFieldTextBox>--%>
                        <%--<ui:UIFieldTextBox ID="textBudgetName" runat="server" PropertyName="Budget.ObjectName"
                            Caption="Budget Name" InternalControlWidth="95%" 
                            meta:resourcekey="textBudgetNameResource1"></ui:UIFieldTextBox>--%>
                        <ui:UIFielddatetime ID="textStartDate" runat="server" Span="Half" 
                            PropertyName="StartDate" Caption="Start Date" SearchType="Range" 
                            meta:resourcekey="textStartDateResource1" ShowDateControls="True"></ui:UIFielddatetime>
                        <ui:UIFielddatetime ID="textEndDate" runat="server" Span="Half" 
                            PropertyName="EndDate" Caption="End Date" SearchType="Range" 
                            meta:resourcekey="textEndDateResource1" ShowDateControls="True"></ui:UIFielddatetime>
                        <ui:UIFielddatetime ID="textClosingDate" runat="server" Span="Half" 
                            PropertyName="ClosingDate" Caption="Closing Date" SearchType="Range" 
                            meta:resourcekey="textClosingDateResource1" ShowDateControls="True"></ui:UIFielddatetime>
                        <ui:UIFieldListBox runat="server" ID="listStatus" Rows="4"
                            PropertyName="CurrentActivity.ObjectName" Caption="Status" 
                            meta:resourcekey="listStatusResource1" ></ui:UIFieldListBox>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >--%>
                    </ui:UIPanel>    
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" 
                            OnAction="gridResults_Action" OnRowDataBound="gridResults_RowDataBound" 
                            DataKeyNames="ObjectID" GridLines="Both" SortExpression="EndDate DESC"
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
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ShowBudgetView" 
                                    ImageUrl="~/images/printer.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource4">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsActive" HeaderText="Is Active" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="IsActive" 
                                    ResourceAssemblyName="" SortExpression="IsActive">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Budget.ObjectName" 
                                    HeaderText="Budget Name" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="Budget.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Budget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" 
                                    HeaderText="Budget Period Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StartDate" 
                                    DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Start Date" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="StartDate" 
                                    ResourceAssemblyName="" SortExpression="StartDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EndDate" 
                                    DataFormatString="{0:dd-MMM-yyyy}" HeaderText="End Date" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="EndDate" 
                                    ResourceAssemblyName="" SortExpression="EndDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ClosingDate" 
                                    DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Closing Date" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="ClosingDate" 
                                    ResourceAssemblyName="" SortExpression="ClosingDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                    HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource7" 
                                    PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                    ResourceName="Resources.WorkflowStates" 
                                    SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%-- <cc1:UIGridViewBoundColumn HeaderText="Assigned User(s)" 
                                    meta:resourcekey="UIGridViewBoundColumnResource8" ResourceAssemblyName="">
                                     <HeaderStyle HorizontalAlign="Left" />
                                     <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>--%>
                                <cc1:UIGridViewBoundColumn HeaderText="Assigned Position(s)" PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText"
                                    meta:resourcekey="UIGridViewBoundColumnResource9" ResourceAssemblyName="">
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
