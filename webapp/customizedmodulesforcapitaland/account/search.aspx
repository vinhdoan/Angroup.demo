<%@ Page Language="C#" Theme="Classy" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource1" %>

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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" OnPopulateForm="panel_PopulateForm" Caption="Account"
                GridViewID="gridResults" BaseTable="tAccount" OnSearch="panel_Search" SearchType="ObjectQuery"
                EditButtonVisible="true" AssignedCheckboxVisible="false" SearchAssignedOnly="true" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <!--Tab Search-->
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTreeList runat="server" ID="treeAccount" Caption="Account"
                            OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" 
                            meta:resourcekey="treeAccountResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox ID="textAccountName" runat="server" Caption="Account Name"
                            PropertyName="ObjectName" InternalControlWidth="95%" 
                            meta:resourcekey="textAccountNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList ID="radioAccountType" runat="server" 
                            Caption="Account Type" RepeatDirection="Vertical"
                            PropertyName="Type" meta:resourcekey="radioAccountTypeResource1" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Selected="True" meta:resourcekey="ListItemResource1" Text="Any"></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2" Text="Category"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3" Text="Line Item"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                    </ui:UITabView>
                    <!--Tab Result-->
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIFieldTreeList runat="server" ID="treeMoveToAccount" OnAcquireTreePopulater="treeMoveToAccount_AcquireTreePopulater"
                            Caption="Move To" meta:resourcekey="treeMoveToAccountResource1" 
                            ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIButton runat='server' ID='buttonMove' Text="Move selected account items/categories"
                            ImageUrl="~/images/tick.gif" OnClick="buttonMove_Click" 
                            meta:resourcekey="buttonMoveResource1"></ui:UIButton>
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridResults" Caption="Account Category/Item" OnRowDataBound="gridResults_RowDataBound"
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
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Type" HeaderText="Type" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Type" 
                                    ResourceAssemblyName="" SortExpression="Type">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Account Path" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Path" 
                                    ResourceAssemblyName="" SortExpression="Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AccountCode" HeaderText="Account Code" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="AccountCode" 
                                    ResourceAssemblyName="" SortExpression="AccountCode">
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
