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
        treeEquipment.PopulateTree();
    }

    /// <summary>
    /// Adds custom conditions to search the invoices.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseInvoice.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseInvoice.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            e.CustomCondition = Query.False;
            foreach (OPosition position in AppSession.User.Positions)
                foreach (OLocation location in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tPurchaseInvoice.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }

        e.CustomCondition = e.CustomCondition &
            TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName.In("Approved", "Close") &
            TablesLogic.tPurchaseInvoice.InvoiceType == PurchaseInvoiceType.StandardInvoice;
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, true, "OPurchaseInvoice",
            false, false);
    }

    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, false, true, "OPurchaseInvoice");
    }

    /// <summary>
    /// Occurs when the results are bound to the result gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[8].Text = e.Row.Cells[7].Text + e.Row.Cells[8].Text;
            e.Row.Cells[9].Text = e.Row.Cells[7].Text + e.Row.Cells[9].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[7].Visible = false;
    }

    /// <summary>
    /// Occurs when the user selects a button in the grid view.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "SelectObject")
        {
            foreach (Guid id in dataKeys)
            {
                Window.Opener.Populate(id.ToString());
                Window.Close();
                break;
            }
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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Purchase Invoice" GridViewID="gridResults"
            EditButtonVisible="false" AddButtonVisible="false" BaseTable="tPurchaseInvoice"
            OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" OnSearch="panel_Search">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldTextBox runat="serveR" ID="textObjectNumber" meta:resourcekey="textObjectNumberResource1"
                        Caption="Invoice Number" PropertyName="ObjectNumber">
                    </ui:UIFieldTextBox>
                    <ui:UIPanel runat="server" ID="panelLocationEquipment" meta:resourcekey="panelLocationEquipmentResource1">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" meta:resourcekey="treeEquipmentResource1"
                            Caption="Equipment" PropertyName="EquipmentID" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater">
                        </ui:UIFieldTreeList>
                    </ui:UIPanel>
                    <ui:UIFieldDateTime runat='server' ID="dateDateOfInvoice" Caption="Date of Invoice"
                        meta:resourcekey="dateDateOfInvoiceResource1" ShowTimeControls="False" PropertyName="DateOfInvoice"
                        SearchType="Range" Span="Half" />
                    <div style="clear: both">
                    </div>
                    <ui:UIFieldTextBox runat="server" ID="textReferenceNumber" Caption="Reference Number"
                        meta:resourcekey="textReferenceNumberResource1" PropertyName="ReferenceNumber"
                        Span="Half">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="textDescription" meta:resourcekey="textDescriptionResource1"
                        Caption="Description" PropertyName="Description" MaxLength="255">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="textVendorName" meta:resourcekey="textVendorNameResource1"
                        Caption="Vendor Name" PropertyName="Vendor.ObjectName" MaxLength="255">
                    </ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" meta:resourcekey="gridResultsResource1"
                        SortExpression="ObjectNumber DESC" OnRowDataBound="gridResults_RowDataBound"
                        OnAction="gridResults_Action" CheckBoxColumnVisible="false" PageSize="10">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/tick.gif" meta:resourcekey="UIGridViewButtonColumnResource1"
                                CommandName="SelectObject" HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Invoice Number"
                                meta:resourcekey="UIGridViewBoundColumnResource1">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="PurchaseType.ObjectName" HeaderText="Purchase Type"
                                meta:resourcekey="UIGridViewBoundColumnResource2">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource3">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Vendor.ObjectName" HeaderText="Vendor Name"
                                meta:resourcekey="UIGridViewBoundColumnResource4">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Currency.ObjectName" HeaderText="Currency"
                                ItemStyle-ForeColor="#777777" meta:resourcekey="UIGridViewBoundColumnResource5">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Currency.CurrencySymbol" HeaderText="" ItemStyle-ForeColor="#777777"
                                meta:resourcekey="UIGridViewBoundColumnResource6">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAmountInSelectedCurrency" HeaderText="Total Amount"
                                DataFormatString="{0:n}" ItemStyle-ForeColor="#777777" meta:resourcekey="UIGridViewBoundColumnResource7">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalTaxInSelectedCurrency" HeaderText="Total Tax"
                                DataFormatString="{0:n}" ItemStyle-ForeColor="#777777" meta:resourcekey="UIGridViewBoundColumnResource8">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAmount" HeaderText="Total Amount<br/>(Base Currency)"
                                DataFormatString="{0:c}" HtmlEncode="false" meta:resourcekey="UIGridViewBoundColumnResource9">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalTax" HeaderText="Total Tax<br/>(Base Currency)"
                                DataFormatString="{0:c}" HtmlEncode="false" meta:resourcekey="UIGridViewBoundColumnResource10">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status"
                                meta:resourcekey="UIGridViewBoundColumnResource11" ResourceName="Resources.WorkflowStates">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>