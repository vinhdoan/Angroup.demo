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
        ORequestForQuotation rfq = Session["::SessionObject::"] as ORequestForQuotation;
        int itemNumber = 0;
        foreach (ORequestForQuotationItem rfqi in rfq.RequestForQuotationItems)
            if (rfqi.ItemNumber > itemNumber && rfqi.ItemNumber != null)
                itemNumber = rfqi.ItemNumber.Value;
        itemNumber++;

        List<ORequestForQuotationItem> items = new List<ORequestForQuotationItem>();
        foreach (GridViewRow row in gridResults.Rows)
        {
            if (row.Cells[0].Controls[0] is CheckBox &&
                ((CheckBox)row.Cells[0].Controls[0]).Checked)
            {
                // Create an add object
                //
                OFixedRate fixedRate = TablesLogic.tFixedRate.Load((Guid)gridResults.DataKeys[row.RowIndex][0]);
                ORequestForQuotationItem rfqi = TablesLogic.tRequestForQuotationItem.Create();
                rfqi.ItemNumber = itemNumber++;
                rfqi.ItemType = PurchaseItemType.Service;
                rfqi.FixedRateID = fixedRate.ObjectID;
                rfqi.ItemDescription = fixedRate.ObjectName;
                rfqi.UnitOfMeasureID = fixedRate.UnitOfMeasureID;
                gridResults.BindRowToObject(rfqi, row);
                items.Add(rfqi);
            }
        }
        if (!panelAddItems.IsValid)
            return;

        rfq.RequestForQuotationItems.AddRange(items);
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
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
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:searchfixedrate runat="server" ID="searchFixedRate"></web:searchfixedrate>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Results"
                    meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                    <ui:UIObjectPanel runat="server" ID="panelAddItems" BorderStyle="NotSet" 
                        meta:resourcekey="panelAddItemsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            BindObjectsToRows="True" meta:resourcekey="gridResultsResource1"
                            Width="100%" SortExpression="ObjectName" RowErrorColor=""
                            SetValidationGroupForSelectedRowsOnly="True" DataKeyNames="ObjectID" 
                            GridLines="Both" ImageRowErrorUrl="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Catalog Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Path" 
                                    ResourceAssemblyName="" SortExpression="Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemCode" HeaderText="Item Code" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="ItemCode" 
                                    ResourceAssemblyName="" SortExpression="ItemCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of measure" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="UnitPrice" 
                                    ResourceAssemblyName="" SortExpression="UnitPrice" Visible="False">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Receipt Mode" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldRadioList ID="radioReceiptMode" runat="server" 
                                            Caption="Receipt Mode" FieldLayout="Flow" 
                                            meta:resourcekey="radioReceiptModeResource1" 
                                            OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged" 
                                            PropertyName="ReceiptMode" RepeatColumns="0" ShowCaption="False" 
                                            TextAlign="Right">
                                            <Items>
                                                <asp:ListItem meta:resourcekey="ListItemResource1" Selected="True" Value="0">Quantity</asp:ListItem>
                                                <asp:ListItem meta:resourcekey="ListItemResource2" Value="1">Dollar Amount</asp:ListItem>
                                            </Items>
                                        </cc1:UIFieldRadioList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Quantity" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textQuantity" runat="server" Caption="Quantity" 
                                            FieldLayout="Flow" InternalControlWidth="95%" 
                                            meta:resourcekey="textQuantityResource1" PropertyName="QuantityRequired" 
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
