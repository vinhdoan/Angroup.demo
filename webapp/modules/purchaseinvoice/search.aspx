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

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }


    /// <summary>
    /// Implements custom conditions.
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
    }
    
    
    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, false, true, Security.Decrypt(Request["TYPE"]));
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
            e.Row.Cells[12].Text = e.Row.Cells[11].Text + e.Row.Cells[12].Text;
            e.Row.Cells[13].Text = e.Row.Cells[11].Text + e.Row.Cells[13].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[11].Visible = false;
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
            <web:search runat="server" ID="panel" Caption="Purchase Invoice" GridViewID="gridResults" EditButtonVisible="false" AssignedCheckboxVisible="true"
                BaseTable="tPurchaseInvoice" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" OnSearch="panel_Search" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1" >
                        <ui:uifieldtextbox runat="serveR" id="textObjectNumber" meta:resourcekey="textObjectNumberResource1" Caption="Invoice Number" PropertyName="ObjectNumber"></ui:uifieldtextbox>
                        <ui:UIFieldCheckBoxList runat="server" ID="checklistMatchType" meta:resourcekey="checklistMatchTypeResource1" PropertyName="MatchType"
                            Caption="Match Type">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Direct invoice (not matched to any purchase document)."></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Matched to Purchase Order."></asp:ListItem>
                            </Items>
                        </ui:UIFieldCheckBoxList>
                        <ui:UIFieldCheckBoxList runat="server" ID="checklistInvoiceType" meta:resourcekey="checklistInvoiceTypeResource1" PropertyName="InvoiceType"
                            Caption="Invoice Type">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource3" Text="Standard Invoice"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource4" Text="Credit Memo"></asp:ListItem>
                                <asp:ListItem Value="2" Text="Debit Memo" meta:resourcekey="ListItemResource5"></asp:ListItem>
                            </Items>
                        </ui:UIFieldCheckBoxList>
                        <ui:UIPanel runat="server" ID="panelLocationEquipment" meta:resourcekey="panelLocationEquipmentResource1">
                            <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                                OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1"  >
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" PropertyName="EquipmentID"
                                OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" meta:resourcekey="treeEquipmentResource1">
                            </ui:UIFieldTreeList>
                        </ui:UIPanel>
                        <ui:UIFieldDateTime runat='server' ID="dateDateOfInvoice" meta:resourcekey="dateDateOfInvoiceResource1" Caption="Date of Invoice"
                            ShowTimeControls="False" PropertyName="DateOfInvoice" SearchType="Range"
                            Span="Half" />
                        <div style="clear: both">
                        </div>
                        <ui:UIFieldTextBox runat="server" ID="textReferenceNumber" meta:resourcekey="textReferenceNumberResource1" Caption="Reference Number"
                            PropertyName="ReferenceNumber" Span="Half" >
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textDescription" meta:resourcekey="textDescriptionResource1" Caption="Description" PropertyName="Description" MaxLength="255">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textVendorName" Caption="Vendor Name" meta:resourcekey="textVendorNameResource1" PropertyName="Vendor.ObjectName" MaxLength="255">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" meta:resourcekey="listStatusResource1"
                            Caption="Status">
                        </ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" meta:resourcekey="gridResultsResource1" KeyName="ObjectID" Width="100%" SortExpression="ObjectNumber DESC" OnRowDataBound="gridResults_RowDataBound">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1"
                                    CommandName="EditObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2"
                                    CommandName="ViewObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3"
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" meta:resourcekey="UIGridViewBoundColumnResource1" HeaderText="Invoice Number">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="MatchTypeText" meta:resourcekey="UIGridViewBoundColumnResource2" HeaderText="Match Type">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="InvoiceTypeText" meta:resourcekey="UIGridViewBoundColumnResource3" HeaderText="Invoice Type">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="PurchaseType.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource4" HeaderText="Purchase Type">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Description" meta:resourcekey="UIGridViewBoundColumnResource5" HeaderText="Description">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Vendor.ObjectName" HeaderText="Vendor Name" meta:resourcekey="UIGridViewBoundColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Currency.ObjectName" HeaderText="Currency" meta:resourcekey="UIGridViewBoundColumnResource7" ItemStyle-ForeColor="#777777">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Currency.CurrencySymbol" HeaderText="" meta:resourcekey="UIGridViewBoundColumnResource8" ItemStyle-ForeColor="#777777">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TotalAmountInSelectedCurrency" HeaderText="Total Amount" meta:resourcekey="UIGridViewBoundColumnResource9" DataFormatString="{0:n}" ItemStyle-ForeColor="#777777">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TotalTaxInSelectedCurrency" HeaderText="Total Tax" DataFormatString="{0:n}" meta:resourcekey="UIGridViewBoundColumnResourcee10" ItemStyle-ForeColor="#777777">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TotalAmount" HeaderText="Total Amount<br/>(Base Currency)" DataFormatString="{0:c}" meta:resourcekey="UIGridViewBoundColumnResource11" HtmlEncode="false">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TotalTax" HeaderText="Total Tax<br/>(Base Currency)" DataFormatString="{0:c}" meta:resourcekey="UIGridViewBoundColumnResource12" HtmlEncode="false">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource13"
                                    ResourceName="Resources.WorkflowStates">
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
