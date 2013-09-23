<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

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
        ExpressionCondition condition = UIBinder.BuildCondition(TablesLogic.tBudgetPeriod, panelMain);
        ExpressionCondition havingCondition = null;
        
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
                    budgetPeriod.Budget.ApplicableLocations.ObjectID.Count() >=
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
                    user.Positions.Role.RoleFunctions.Function.ObjectTypeName == "OBudgetPeriod" &
                    user.ObjectID == AppSession.User.ObjectID).Exists();
            havingCondition = 
                budgetPeriod.Budget.ApplicableLocations.ObjectID.Count() >=
                budgetPeriod2.Select(budgetPeriod2.Budget.ApplicableLocations.ObjectID.Count()).Where(budgetPeriod2.ObjectID == budgetPeriod.ObjectID);
        }


        e.CustomResultTable =
            TablesLogic.tBudgetPeriod.Select(
                TablesLogic.tBudgetPeriod.ObjectID,
                TablesLogic.tBudgetPeriod.IsActive,
                TablesLogic.tBudgetPeriod.ObjectName,
                TablesLogic.tBudgetPeriod.Budget.ObjectName.As("Budget.ObjectName"),
                TablesLogic.tBudgetPeriod.StartDate,
                TablesLogic.tBudgetPeriod.EndDate,
                TablesLogic.tBudgetPeriod.ClosingDate,
                TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName.As("CurrentActivity.ObjectName"))
                .Where(
                condition & 
                TablesLogic.tBudgetPeriod.IsDeleted == 0)
                .GroupBy(
                TablesLogic.tBudgetPeriod.ObjectID,
                TablesLogic.tBudgetPeriod.IsActive,
                TablesLogic.tBudgetPeriod.ObjectName,
                TablesLogic.tBudgetPeriod.Budget.ObjectID,
                TablesLogic.tBudgetPeriod.Budget.ObjectName,
                TablesLogic.tBudgetPeriod.StartDate,
                TablesLogic.tBudgetPeriod.EndDate,
                TablesLogic.tBudgetPeriod.ClosingDate,
                TablesLogic.tBudgetPeriod.CurrentActivity.ObjectName)
                .Having(
                havingCondition);
        
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, "OBudgetPeriod");
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" >
            <web:search runat="server" ID="panel" Caption="Budget Period" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tBudgetPeriod" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search" meta:resourcekey="panelResource1" >
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" >
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search"  meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1" >
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox ID="textBudgetPeriodName" runat="server" Span="Full" PropertyName="ObjectName"
                            Caption="Budget Period Name" meta:resourcekey="textBudgetPeriodNameResource1" ></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="textBudgetName" runat="server" Span="Full" PropertyName="Budget.ObjectName"
                            Caption="Budget Name" meta:resourcekey="textBudgetNameResource1" ></ui:UIFieldTextBox>
                        <ui:UIFielddatetime ID="textStartDate" runat="server" Span="Half" PropertyName="StartDate" Caption="Start Date" SearchType="Range" meta:resourcekey="textStartDateResource1" ></ui:UIFielddatetime>
                        <ui:UIFielddatetime ID="textEndDate" runat="server" Span="Half" PropertyName="EndDate" Caption="End Date" SearchType="Range" meta:resourcekey="textEndDateResource1" ></ui:UIFielddatetime>
                        <ui:UIFielddatetime ID="textClosingDate" runat="server" Span="Half" PropertyName="ClosingDate" Caption="Closing Date" SearchType="Range" meta:resourcekey="textClosingDateResource1" ></ui:UIFielddatetime>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" Caption="Status"  meta:resourcekey="listStatusResource1" >
                        </ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results"  meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" OnAction="gridResults_Action" OnRowDataBound="gridResults_RowDataBound">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1" 
                                    CommandName="EditObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif"  meta:resourcekey="UIGridViewButtonColumnResource2" 
                                    CommandName="ViewObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif"  meta:resourcekey="UIGridViewButtonColumnResource3" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/printer.gif" 
                                    CommandName="ShowBudgetView" HeaderText=""  meta:resourcekey="UIGridViewButtonColumnResource4" >
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="IsActive" HeaderText="Is Active" meta:resourcekey="UIGridViewBoundColumnResource1" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" HeaderText="Budget Name" meta:resourcekey="UIGridViewBoundColumnResource2" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Budget Period Name" meta:resourcekey="UIGridViewBoundColumnResource3" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StartDate" HeaderText="Start Date" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource4" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="EndDate" HeaderText="End Date" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource5" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ClosingDate" HeaderText="Closing Date" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource6" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status" ResourceName="Resources.WorkflowStates" meta:resourcekey="UIGridViewBoundColumnResource7" >
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" meta:resourcekey="UIGridViewCommandResource1"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
