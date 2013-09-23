<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    /// <summary>
    /// Populates the search form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        
        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", null));

        listStatus.Bind(OActivity.GetStatuses("OPurchaseOrder"), "ObjectName", "ObjectName");
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
        ExpressionCondition cond = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                cond = cond & TablesLogic.tPurchaseOrder.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                cond = cond & TablesLogic.tPurchaseOrder.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            cond = Query.False;
            foreach (OPosition position in AppSession.User.Positions)
                foreach (OLocation location in position.LocationAccess)
                    cond = cond | TablesLogic.tPurchaseOrder.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }

        
        
        TPurchaseOrder po = TablesLogic.tPurchaseOrder;
        TPurchaseOrderItem poi = TablesLogic.tPurchaseOrderItem;
        TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;
        TPurchaseOrderReceipt receipt = TablesLogic.tPurchaseOrderReceipt;
        ExpressionCondition havingCondition = Query.True;

        if (rdlInvoice.SelectedIndex == 2)//show POs that are not invoiced completely
        {
            DataTable poWithFullInvoice = po.Select(
              po.ObjectID
              )
              .Where(
              cond &
              panel.GetCondition())
               .GroupBy(po.ObjectID)
              .Having(poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == po.ObjectID)
                                          == inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == po.ObjectID & inv.IsDeleted == 0 & inv.CurrentActivity.ObjectName == "Approved"));
            ArrayList poIDs = new ArrayList();
            foreach (DataRow row in poWithFullInvoice.Rows)
            {
                poIDs.Add(row["ObjectID"]);
            }
            cond = cond & !po.ObjectID.In(poIDs);
        }
        else if (rdlInvoice.SelectedIndex == 1)//show POs that are 100% Invoiced
        {
            havingCondition = havingCondition & poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == po.ObjectID)
            == inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == po.ObjectID & inv.IsDeleted == 0 & inv.CurrentActivity.ObjectName == "Approved");
        }
        if (rdlReceipt.SelectedIndex == 2)
        {
            DataTable poWithFullReceipt = po.Select(
              po.ObjectID
              )
              .Where(
              cond &
              panel.GetCondition())
               .GroupBy(po.ObjectID)
              .Having(poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == po.ObjectID)
                                          == receipt.Select((receipt.PurchaseOrderReceiptItems.UnitPrice * receipt.PurchaseOrderReceiptItems.QuantityDelivered).Sum()).Where(receipt.PurchaseOrderID == po.ObjectID));
            ArrayList poIDs = new ArrayList();
            foreach (DataRow row in poWithFullReceipt.Rows)
            {
                poIDs.Add(row["ObjectID"]);
            }
            cond = cond & !po.ObjectID.In(poIDs);
        }
        else if (rdlReceipt.SelectedIndex == 1)
        {
            havingCondition = havingCondition & poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == po.ObjectID)
            == receipt.Select((receipt.PurchaseOrderReceiptItems.UnitPrice * receipt.PurchaseOrderReceiptItems.QuantityDelivered).Sum()).Where(receipt.PurchaseOrderID == po.ObjectID);
        } 
        
        DataTable dt = new DataTable();
            dt = po.Select(
            po.ObjectID,
            po.ObjectNumber,
            po.Case.ObjectNumber.As("Case.ObjectNumber"),
            po.PurchaseType.ObjectName.As("PurchaseType.ObjectName"),
            po.Vendor.ObjectName.As("Vendor.ObjectName"),
            po.Description,
            po.DateRequired,
            po.DateEnd,
            po.DateAccounted,
            po.DateVarianceAccounted,
            po.CurrentActivity.ObjectName.As("CurrentActivity.ObjectName"),
            poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == po.ObjectID).As("TotalPOAmount"),
            inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == po.ObjectID & inv.IsDeleted == 0 & inv.CurrentActivity.ObjectName == "Approved" & inv.InvoiceType == 0).As("TotalInvoiced"),
            inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == po.ObjectID & inv.IsDeleted == 0 & inv.CurrentActivity.ObjectName == "Approved" & inv.InvoiceType != 0).As("TotalCreditDebit")
            )
            .Where(
            cond &
            panel.GetCondition())
            .GroupBy(po.ObjectID,
            po.ObjectNumber,
            po.Case.ObjectNumber,
            po.PurchaseType.ObjectName,
            po.Vendor.ObjectName,
            po.Description,
            po.DateRequired,
            po.DateEnd,
            po.DateAccounted,
            po.DateVarianceAccounted,
            po.CurrentActivity.ObjectName)
            .Having(            
            havingCondition 
            );
       
        e.CustomResultTable = dt;
    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, true, Security.Decrypt(Request["TYPE"]),false,false);
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
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAccountPO_Click(object sender, EventArgs e)
    {
        List<object> ids = gridResults.GetSelectedKeys();

        DateTime date = new DateTime(Convert.ToInt32(dropYear1.SelectedValue), Convert.ToInt32(dropMonth1.SelectedValue), 1);
        OPurchaseOrder.AccountPurchaseOrder(ids, date);

        panel.PerformSearch();
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAccountPOVariance_Click(object sender, EventArgs e)
    {
        List<object> ids = gridResults.GetSelectedKeys();

        DateTime date = new DateTime(Convert.ToInt32(dropYear2.SelectedValue), Convert.ToInt32(dropMonth2.SelectedValue), 1);
        OPurchaseOrder.AccountPurchaseOrderVariance(ids, date);

        panel.PerformSearch();
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
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:search runat="server" ID="panel" Caption="PO Matching" GridViewID="gridResults" BaseTable="tPurchaseOrder" OnSearch="panel_Search" SearchType="SelectQuery" AssignedCheckboxVisible="true" OnPopulateForm="panel_PopulateForm"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectNumber" Caption="PO Number" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" />
                    <ui:UIFieldTextBox runat='server' ID='textCaseNumber' PropertyName="Case.ObjectNumber" Caption="Case Number" Span="Half" />
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" PropertyName="EquipmentID" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType" Caption="Type" PropertyName="PurchaseTypeID">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" PropertyName="Description" MaxLength="255" meta:resourcekey="DescriptionResource1" />
                    <ui:UIFieldDateTime runat='server' ID="DateRequired" SearchType="Range" Caption="Date Required" ShowTimeControls="False" PropertyName="DateRequired" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" />
                    <ui:UIFieldTextBox ID="VendorName" runat="server" Caption="Vendor Name" PropertyName="Vendor.ObjectName" meta:resourcekey="VendorNameResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldRadioList runat="server" ID="rdlInvoice" Caption="Invoiced">
                        <Items>
                            <asp:ListItem Value="0">All</asp:ListItem>
                            <asp:ListItem Value="1">Only show POs that are 100% invoiced</asp:ListItem>
                            <asp:ListItem Value="2">Only show POs that are not invoiced completely</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldRadioList runat="server" ID="rdlReceipt" Caption="Goods Receipts">
                        <Items>
                            <asp:ListItem Value="0">All</asp:ListItem>
                            <asp:ListItem Value="1">Only show POs where items are 100% received</asp:ListItem>
                            <asp:ListItem Value="2">Only show POs where items have not been completely received</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <br />
                    <br />
                    <br />
                    <table style="width: 100%" cellpadding='0' cellspacing='0' border='0'>
                        <tr>
                            <td style="width: 49.5%">
                                <ui:UIPanel ID="Panel1" runat="server" meta:resourcekey="Panel1Resource1">
                                    <asp:Label ID="Label1" runat="server" Font-Bold="True" Text="Ship To:" meta:resourcekey="Label1Resource1"></asp:Label><br />
                                    <ui:UIFieldTextBox ID="ShipToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine" PropertyName="ShipToAddress" meta:resourcekey="ShipToAddressResource1" />
                                    <ui:UIFieldTextBox ID="ShipToAttention" runat="server" Caption="Attention" PropertyName="ShipToAttention" meta:resourcekey="ShipToAttentionResource1" />
                                </ui:UIPanel>
                            </td>
                            <td style="width: 49.5%">
                                <ui:UIPanel ID="Panel2" runat="server" meta:resourcekey="Panel2Resource1">
                                    <asp:Label ID="Label2" runat="server" Font-Bold="True" Text="Bill To:" meta:resourcekey="Label2Resource1"></asp:Label><br />
                                    <ui:UIFieldTextBox ID="BillToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine" PropertyName="BillToAddress" meta:resourcekey="BillToAddressResource1" />
                                    <ui:UIFieldTextBox ID="BillToAttention" runat="server" Caption="Attention" PropertyName="BillToAttention" meta:resourcekey="BillToAttentionResource1" />
                                </ui:UIPanel>
                            </td>
                        </tr>
                    </table>
                    <ui:UIFieldTextBox runat="server" ID="FreightTerms" PropertyName="FreightTerms" Caption="Freight Terms" TextMode="MultiLine" Rows="3" meta:resourcekey="FreightTermsResource1" />
                    <ui:UIFieldTextBox runat="server" ID="PaymentTerms" PropertyName="PaymentTerms" Caption="Payment Terms" TextMode="MultiLine" Rows="3" meta:resourcekey="PaymentTermsResource1" />
                    <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" Caption="Status">
                    </ui:UIFieldListBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1">
                    <asp:panel runat='server' id="panelAccounting" visible="false">
                        <table>
                            <tr>
                                <td>
                                    <asp:label runat="server" id="labelPO">Set all selected to month accounted:</asp:label>
                                </td>
                                <td>
                                    <asp:dropdownlist runat="server" id="dropMonth1">
                                        <asp:ListItem Value="1">Jan</asp:ListItem>
                                        <asp:ListItem Value="2">Feb</asp:ListItem>
                                        <asp:ListItem Value="3">Mar</asp:ListItem>
                                        <asp:ListItem Value="4">Apr</asp:ListItem>
                                        <asp:ListItem Value="5">May</asp:ListItem>
                                        <asp:ListItem Value="6">Jun</asp:ListItem>
                                        <asp:ListItem Value="7">Jul</asp:ListItem>
                                        <asp:ListItem Value="8">Aug</asp:ListItem>
                                        <asp:ListItem Value="9">Sep</asp:ListItem>
                                        <asp:ListItem Value="10">Oct</asp:ListItem>
                                        <asp:ListItem Value="11" Selected="true">Nov</asp:ListItem>
                                        <asp:ListItem Value="12">Dec</asp:ListItem>
                                    </asp:dropdownlist>
                                    <asp:dropdownlist runat="server" id="dropYear1">
                                        <asp:ListItem Value="2009">2009</asp:ListItem>
                                        <asp:ListItem Value="2010">2010</asp:ListItem>
                                        <asp:ListItem Value="2011">2011</asp:ListItem>
                                    </asp:dropdownlist>
                                    <ui:uibutton runat="server" Text="Set" id="buttonAccountPO" ImageUrl="~/images/tick.gif" OnClick="buttonAccountPO_Click" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:label runat="server" id="labelPO2">Set all selected variance accounted date to:</asp:label>
                                </td>
                                <td>
                                    <asp:dropdownlist runat="server" id="dropMonth2">
                                        <asp:ListItem Value="1">Jan</asp:ListItem>
                                        <asp:ListItem Value="2">Feb</asp:ListItem>
                                        <asp:ListItem Value="3">Mar</asp:ListItem>
                                        <asp:ListItem Value="4">Apr</asp:ListItem>
                                        <asp:ListItem Value="5">May</asp:ListItem>
                                        <asp:ListItem Value="6">Jun</asp:ListItem>
                                        <asp:ListItem Value="7">Jul</asp:ListItem>
                                        <asp:ListItem Value="8">Aug</asp:ListItem>
                                        <asp:ListItem Value="9">Sep</asp:ListItem>
                                        <asp:ListItem Value="10">Oct</asp:ListItem>
                                        <asp:ListItem Value="11" Selected="true">Nov</asp:ListItem>
                                        <asp:ListItem Value="12">Dec</asp:ListItem>
                                    </asp:dropdownlist>
                                    <asp:dropdownlist runat="server" id="dropYear2">
                                        <asp:ListItem Value="2009">2009</asp:ListItem>
                                        <asp:ListItem Value="2010">2010</asp:ListItem>
                                        <asp:ListItem Value="2011">2011</asp:ListItem>
                                    </asp:dropdownlist>
                                    <ui:uibutton runat="server" Text="Set" id="buttonAccountPOVariance" ImageUrl="~/images/tick.gif" OnClick="buttonAccountPOVariance_Click" />
                                </td>
                            </tr>
                        </table>
                    </asp:panel>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="ObjectNumber DESC" meta:resourcekey="gridResultsResource1" AllowPaging="True" AllowSorting="True" PagingEnabled="True">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewColumnResource3">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="PO Number" meta:resourcekey="UIGridViewColumnResource4">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Case.ObjectNumber" HeaderText="Case Number">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="PurchaseType.ObjectName" HeaderText="Type">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Vendor.ObjectName" HeaderText="Vendor">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description" meta:resourcekey="UIGridViewColumnResource5">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="DateRequired" HeaderText="Date Required" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewColumnResource6">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="DateEnd" HeaderText="Date Required" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewColumnResource6">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="DateAccounted" HeaderText="Month Accounted" DataFormatString="{0:MMM-yyyy}"  Visible="false">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalPOAmount" HeaderText="Total PO Amount" DataFormatString="{0:n}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalInvoiced" HeaderText="Total Invoiced" DataFormatString="{0:n}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalCreditDebit" HeaderText="Total Credit/Debit Memos" DataFormatString="{0:n}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="DateVarianceAccounted" HeaderText="Month Variance Accounted" DataFormatString="{0:MMM-yyyy}" Visible="false">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status" ResourceName="Resources.WorkflowStates" meta:resourcekey="UIGridViewColumnResource7" >
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                        <Commands>
                            <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1"></ui:UIGridViewCommand>
                        </Commands>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
