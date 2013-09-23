<%@ Page Language="C#" Inherits="PageBase" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>

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
        OPurchaseRequest pr = Session["::SessionObject::"] as OPurchaseRequest;
        int itemNumber = 0;
        foreach (OPurchaseRequestItem pri in pr.PurchaseRequestItems)
            if (pri.ItemNumber > itemNumber && pri.ItemNumber != null)
                itemNumber = pri.ItemNumber.Value;
        itemNumber++;

        List<OPurchaseRequestItem> items = new List<OPurchaseRequestItem>();
        foreach (GridViewRow row in gridResults.GetSelectedRows())
        {
            // Create an add object
            //
            OFixedRate fixedRate = TablesLogic.tFixedRate.Load((Guid)gridResults.DataKeys[row.RowIndex][0]);
            OPurchaseRequestItem pri = TablesLogic.tPurchaseRequestItem.Create();
            pri.ItemNumber = itemNumber++;
            pri.ItemType = PurchaseItemType.Service;
            pri.FixedRateID = fixedRate.ObjectID;
            pri.ItemDescription = fixedRate.ObjectName;
            pri.UnitOfMeasureID = fixedRate.UnitOfMeasureID;
            pri.EstimatedUnitPrice = pri.EstimatedUnitPrice;
            gridResults.BindRowToObject(pri, row);
            items.Add(pri);
        }
        if (!panelAddItems.IsValid)
            return;

        pr.PurchaseRequestItems.AddRange(items);

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
            UIFieldTextBox textUnitPrice = c.FindControl("textUnitPrice") as UIFieldTextBox;

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
        <web:search runat="server" ID="panel" Caption="Add Service Items" meta:resourcekey="panelResource1" 
            GridViewID="gridResults" AddSelectedButtonVisible="true"
            AddButtonVisible="false" EditButtonVisible="false" BaseTable="tFixedRate"
            OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"
            SearchType="ObjectQuery" SearchAssignedOnly="false" OnValidateAndAddSelected="panel_ValidateAndAddSelected">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1"
                BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Search"
                    meta:resourcekey="uitabview1Resource1">
                    <web:searchfixedrate runat="server" ID="searchFixedRate"></web:searchfixedrate>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Results"
                    meta:resourcekey="uitabview2Resource1">
                    <ui:UIObjectPanel runat="server" ID="panelAddItems" meta:resourcekey="panelAddItemsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            BindObjectsToRows="true" meta:resourcekey="gridResultsResource1"
                            Width="100%" SortExpression="ObjectName" RowErrorColor=""
                            SetValidationGroupForSelectedRowsOnly="true">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="Path" HeaderText="Catalog Name" meta:resourcekey="UIGridViewBoundColumnResource1" />
                                <ui:UIGridViewBoundColumn PropertyName="ItemCode" HeaderText="Item Code" meta:resourcekey="UIGridViewBoundColumnResource2" />
                                <ui:UIGridViewBoundColumn PropertyName="UnitOfMeasure.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource3"
                                    HeaderText="Unit of measure" />
                                <ui:UIGridViewBoundColumn PropertyName="UnitPrice" Visible="false" meta:resourcekey="UIGridViewBoundColumnResource4"/>
                                <ui:UIGridViewTemplateColumn HeaderText="Receipt Mode" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <ui:UIFieldRadioList runat="server" ID="radioReceiptMode" PropertyName="ReceiptMode"
                                            Caption="Receipt Mode" ShowCaption="false" FieldLayout="Flow"
                                            OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged"
                                            RepeatDirection="Horizontal" RepeatColumns="0" meta:resourcekey="radioReceiptModeResource1">
                                            <Items>
                                                <asp:ListItem Value="0" Selected='True' meta:resourcekey="ListItemResource1">Quantity</asp:ListItem>
                                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Dollar Amount</asp:ListItem>
                                            </Items>
                                        </ui:UIFieldRadioList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Quantity" meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textQuantity" Caption="Quantity" meta:resourcekey="textQuantityResource1"
                                            PropertyName="QuantityRequired" ShowCaption="false" FieldLayout="Flow"
                                            ValidateRequiredField="true" ValidateDataTypeCheck="true"
                                            ValidationDataType="Currency" ValidateRangeField='true' ValidationRangeMin="0"
                                            ValidationRangeMinInclusive="false" ValidationRangeType="Currency">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Estimated Unit Price">
                                    <ItemTemplate>
                                    <ui:UIFieldTextBox ID="EstimatedUnitPrice" runat="server" Caption="Estimated Unit Price" ShowCaption="false"
                                    PropertyName="EstimatedUnitPrice" ValidateDataTypeCheck="True" ValidateRangeField="True" FieldLayout="Flow"
                                    ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                    ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="EstimatedUnitPriceResource1" />
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
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
