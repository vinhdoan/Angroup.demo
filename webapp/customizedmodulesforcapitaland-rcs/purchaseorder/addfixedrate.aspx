<%@ Page Language="C#" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Initializes the controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = searchFixedRate.GetCustomCondition();
    }

    /// <summary>
    /// Adds the WJ item object into the session object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OPurchaseOrder po = Session["::SessionObject::"] as OPurchaseOrder;
        int itemNumber = 0;
        foreach (OPurchaseOrderItem poi in po.PurchaseOrderItems)
            if (poi.ItemNumber > itemNumber && poi.ItemNumber != null)
                itemNumber = poi.ItemNumber.Value;
        itemNumber++;

        List<OPurchaseOrderItem> items = new List<OPurchaseOrderItem>();
        foreach (GridViewRow row in gridResults.GetSelectedRows())
        {
            // Create an add object
            //
            OFixedRate fixedRate = TablesLogic.tFixedRate.Load((Guid)gridResults.DataKeys[row.RowIndex][0]);
            OPurchaseOrderItem poi = TablesLogic.tPurchaseOrderItem.Create();
            poi.ItemNumber = itemNumber++;
            poi.ItemType = PurchaseItemType.Service;
            poi.FixedRateID = fixedRate.ObjectID;
            poi.ItemDescription = fixedRate.ObjectName;
            poi.UnitOfMeasureID = fixedRate.UnitOfMeasureID;
            gridResults.BindRowToObject(poi, row);
            items.Add(poi);
        }
        if (!panelAddItems.IsValid)
            return;
        po.PurchaseOrderItems.AddRange(items);

        Window.Opener.ClickUIButton("buttonItemsAdded");
        Window.Close();
    }


    /// <summary>
    /// Occurs if the user selects a receipt mode.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioReceiptMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        Control c = sender as Control;
        while (true)
        {
            c = c.Parent;
            if (c == null || c is GridViewRow)
                break;
        }
        if (c is GridViewRow)
        {
            UIFieldTextBox textQuantity = c.FindControl("textQuantity") as UIFieldTextBox;

            if (((UIFieldRadioList)sender).SelectedValue == ReceiptModeType.Quantity.ToString())
            {
                textQuantity.Enabled = true;
            }
            else
            {
                textQuantity.Enabled = false;
                textQuantity.Text = "1.00";
            }
        }
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OPurchaseOrder po = Session["::SessionObject::"] as OPurchaseOrder;
            if (po.ContractID != null)
            {
                OFixedRate fixedRate = TablesLogic.tFixedRate.Load((Guid)gridResults.DataKeys[e.Row.RowIndex][0]);
                UIFieldTextBox textUnitPrice = e.Row.FindControl("textUnitPrice") as UIFieldTextBox;
                textUnitPrice.Text = po.Contract.GetServiceUnitPrice(fixedRate.ObjectID.Value).ToString("#,##0.00");
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet"
        type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Add Service Items"
            GridViewID="gridResults" AddSelectedButtonVisible="true" meta:resourcekey="panelResource1"
            AddButtonVisible="false" EditButtonVisible="false" BaseTable="tFixedRate"
            OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"
            SearchType="ObjectQuery" SearchAssignedOnly="false" OnValidateAndAddSelected="panel_ValidateAndAddSelected">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1"
                BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Search"
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:searchfixedrate runat="server" ID="searchFixedRate"></web:searchfixedrate>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Results"
                    meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                    <ui:UIObjectPanel runat="server" ID="panelAddItems" 
                        meta:resourcekey="panelAddItemsResource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            BindObjectsToRows="True" meta:resourcekey="gridResultsResource1"
                            Width="100%" SortExpression="ObjectName" RowErrorColor=""
                            SetValidationGroupForSelectedRowsOnly="True" 
                            OnRowDataBound="gridResults_RowDataBound" DataKeyNames="ObjectID" 
                            GridLines="Both" ImageRowErrorUrl="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Catalog Name" 
                                    meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Path" 
                                    ResourceAssemblyName="" SortExpression="Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemCode" HeaderText="Item Code" 
                                    meta:resourceKey="UIGridViewBoundColumnResource2" PropertyName="ItemCode" 
                                    ResourceAssemblyName="" SortExpression="ItemCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of measure" meta:resourceKey="UIGridViewBoundColumnResource3" 
                                    PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" 
                                    meta:resourceKey="UIGridViewBoundColumnResource4" PropertyName="UnitPrice" 
                                    ResourceAssemblyName="" SortExpression="UnitPrice" Visible="False">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Receipt Mode" 
                                    meta:resourceKey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldRadioList ID="radioReceiptMode" runat="server" 
                                            Caption="Receipt Mode" FieldLayout="Flow" 
                                            meta:resourceKey="radioReceiptModeResource1" 
                                            OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged" 
                                            PropertyName="ReceiptMode" RepeatColumns="0" ShowCaption="False" 
                                            TextAlign="Right">
                                            <Items>
                                                <asp:ListItem meta:resourceKey="ListItemResource1" Selected="True" 
                                                    Text="Quantity" Value="0"></asp:ListItem>
                                                <asp:ListItem meta:resourceKey="ListItemResource2" Text="Dollar Amount" 
                                                    Value="1"></asp:ListItem>
                                            </Items>
                                        </cc1:UIFieldRadioList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Unit Price" 
                                    meta:resourceKey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textUnitPrice" runat="server" Caption="Unit Price" 
                                            FieldLayout="Flow" InternalControlWidth="95%" 
                                            meta:resourceKey="textUnitPriceResource1" 
                                            PropertyName="UnitPriceInSelectedCurrency" ShowCaption="False" 
                                            ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                            ValidationRangeMin="0" ValidationRangeMinInclusive="False" 
                                            ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Quantity" 
                                    meta:resourceKey="UIGridViewTemplateColumnResource3">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textQuantity" runat="server" Caption="Quantity" 
                                            FieldLayout="Flow" InternalControlWidth="95%" 
                                            meta:resourceKey="textQuantityResource1" PropertyName="QuantityOrdered" 
                                            ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                            ValidationRangeMin="0" ValidationRangeMinInclusive="False" 
                                            ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIObjectPanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
