<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Initializes the controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Constructs and returns a code tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCode_AcquireTreePopulater(object sender)
    {
        return new CodeTreePopulater(null);
    }



    /// <summary>
    /// Constructs additional conditions for the search.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        //if (treeCode.SelectedValue != "")
        //{
        //    List<OCode> o =
        //        TablesLogic.tCode[TablesLogic.tCode.ObjectID == new Guid(treeCode.SelectedValue), true];
        //    if (o.Count == 0)
        //        return;

        //    e.CustomCondition = TablesLogic.tCode.HierarchyPath.Like(o[0].HierarchyPath + "%");
        //}
    }


</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Account" GridViewID="gridResults"
            BaseTable="tCustomerAccount" OnSearch="panel_Search" SearchType="ObjectQuery" EditButtonVisible="false"
            AutoSearchOnLoad="true" MaximumNumberOfResults="30" AdvancedSearchPanelID="panelAdvanced"
            SearchTextBoxHint="CMND, Tên KH, Tên IB, Số TK" AdvancedSearchOnLoad="false"
            SearchTextBoxPropertyNames="Customer.CMND, Customer.CustomerName, IB.ObjectName, AccountNumber"
            OnPopulateForm="panel_PopulateForm"></web:search>
        <div class="div-form">
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <ui:UIFieldSearchableDropDownList runat="server" ID="ddlCustomer" PropertyName="CustomerID"
                    Caption="Customer">
                </ui:UIFieldSearchableDropDownList>
                <ui:UIFieldTextBox runat="server" ID="tbAccountNumber" PropertyName="AccountNumber"
                    Caption="Account">
                </ui:UIFieldTextBox>
            </ui:UIPanel>
            <ui:UISeparator runat="server" Caption="Results" />
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                Width="100%" DataKeyNames="ObjectID"
                GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Commands>
                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                        CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                </Commands>
                <Columns>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                        meta:resourceKey="UIGridViewColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                        meta:resourceKey="UIGridViewColumnResource2">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewBoundColumn DataField="AccountNumber" HeaderText="Account" PropertyName="AccountNumber"
                        ResourceAssemblyName="" SortExpression="AccountNumber">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Customer.CustomerName" HeaderText="Cust. Name" PropertyName="Customer.CustomerName"
                        ResourceAssemblyName="" SortExpression="Customer.CustomerName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IB.ObjectName" HeaderText="IB" PropertyName="IB.ObjectName"
                        ResourceAssemblyName="" SortExpression="IB.ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Deposit" HeaderText="Deposit" PropertyName="Deposit" DataFormatString="{0:#,##0.00}"
                        ResourceAssemblyName="" SortExpression="Deposit">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Equity" HeaderText="Equity" DataFormatString="{0:#,##0.00}"
                        PropertyName="Equity" ResourceAssemblyName="" SortExpression="Equity">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
