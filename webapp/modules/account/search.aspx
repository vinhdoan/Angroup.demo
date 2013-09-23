<%@ Page Language="C#" Theme="Classy" Inherits="PageBase" Culture="auto" 
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
        treeAccount.PopulateTree();
        treeMoveToAccount.PopulateTree();
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeAccount.SelectedValue != "")
        {
            OAccount account = TablesLogic.tAccount[new Guid(treeAccount.SelectedValue)];
            if (account != null)
                e.CustomCondition = TablesLogic.tAccount.HierarchyPath.Like(account.HierarchyPath + "%");
        }
    }

    /// <summary>
    /// Occurs when a data row of grid view is bound to data.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[3].Text == "1") //line item
                e.Row.Cells[3].Text = Resources.Strings.BudgetCategory_TypeLineItem;
            else
                e.Row.Cells[3].Text = Resources.Strings.BudgetCategory_TypeCategory;
        }
    }

    /// <summary>
    /// Constructs the financial accounts tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeAccount_AcquireTreePopulater(object sender)
    {
        return new AccountTreePopulater(null, true, true);
    }

    /// <summary>
    /// Moves the selected items and categories into the folder selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonMove_Click(object sender, EventArgs e)
    {
        
        int cyclicalCount = 0;
        int count = 0;

        if (treeMoveToAccount.SelectedValue != null && treeMoveToAccount.SelectedValue != "")
        {
            OAccount.MoveAccounts(
                gridResults.GetSelectedKeys(),
                new Guid(treeMoveToAccount.SelectedValue.ToString()), ref cyclicalCount, ref count);

            panel.PerformSearch();
            if (count > 0)
                panel.Message = count + " items moved successfully. ";
            if (cyclicalCount > 0)
                panel.Message = panel.Message +
                    cyclicalCount + " categories or line items cannot be moved because they result in a cyclical loop. Please select another category to move these items to.";

            treeAccount.PopulateTree();
        }
        else
        {
            panel.Message = "Please select a category to move the selected items.";
        }
    }

    /// <summary>
    /// Constructs a budget category tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeMoveToAccount_AcquireTreePopulater(object sender)
    {
        return new AccountTreePopulater(null, true, false);
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
            <web:search runat="server" ID="panel" OnPopulateForm="panel_PopulateForm" Caption="Account"
                GridViewID="gridResults" BaseTable="tAccount" OnSearch="panel_Search" SearchType="ObjectQuery"
                EditButtonVisible="true" AssignedCheckboxVisible="false" SearchAssignedOnly="true" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch">
                    <!--Tab Search-->
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTreeList runat="server" ID="treeAccount" Caption="Account"
                            OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" meta:resourcekey="treeAccountResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox ID="textAccountName" runat="server" Span="Full" Caption="Account Name"
                            PropertyName="ObjectName" meta:resourcekey="textAccountNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList ID="radioAccountType" runat="server" Caption="Account Type" RepeatDirection="Vertical"
                            PropertyName="Type" meta:resourcekey="radioAccountTypeResource1">
                            <Items>
                                <asp:ListItem Value="" Selected="True" meta:resourcekey="ListItemResource1">Any</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">Category</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3">Line Item</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                    </ui:UITabView>
                    <!--Tab Result-->
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1">
                        <ui:UIFieldTreeList runat="server" ID="treeMoveToAccount" OnAcquireTreePopulater="treeMoveToAccount_AcquireTreePopulater"
                            Caption="Move To" meta:resourcekey="treeMoveToAccountResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIButton runat='server' ID='buttonMove' Text="Move selected account items/categories" meta:resourcekey="buttonMoveResource1"
                            ImageUrl="~/images/tick.gif" OnClick="buttonMove_Click"></ui:UIButton>
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridResults" Caption="Account Category/Item" OnRowDataBound="gridResults_RowDataBound"
                            KeyName="ObjectID" Width="100%" meta:resourcekey="gridResultsResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewButtonColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Type" HeaderText="Type" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Path" HeaderText="Account Path" meta:resourcekey="UIGridViewBoundColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AccountCode" HeaderText="Account Code" meta:resourcekey="UIGridViewBoundColumnResource3">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1" >
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
