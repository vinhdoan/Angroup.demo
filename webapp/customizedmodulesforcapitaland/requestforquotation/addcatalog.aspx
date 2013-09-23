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
        e.CustomCondition = searchCatalog.GetCustomCondition();
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
                OCatalogue catalogue = TablesLogic.tCatalogue.Load((Guid)gridResults.DataKeys[row.RowIndex][0]);
                ORequestForQuotationItem rfqi = TablesLogic.tRequestForQuotationItem.Create();
                rfqi.ItemNumber = itemNumber++;
                rfqi.ItemType = PurchaseItemType.Material;
                rfqi.CatalogueID = catalogue.ObjectID;
                rfqi.ItemDescription = catalogue.ObjectName;
                rfqi.UnitOfMeasureID = catalogue.UnitOfMeasureID;
                rfqi.ReceiptMode = ReceiptModeType.Quantity;
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
        <web:search runat="server" ID="panel" Caption="Add Inventory Items" meta:resourcekey="panelResource1"
            GridViewID="gridResults" AddSelectedButtonVisible="true"
            AddButtonVisible="false" EditButtonVisible="false" BaseTable="tCatalogue"
            OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"
            SearchType="ObjectQuery" SearchAssignedOnly="false" OnValidateAndAddSelected="panel_ValidateAndAddSelected">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1"
                BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Search"
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:searchcatalog runat="server" ID="searchCatalog"></web:searchcatalog>
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
                                <cc1:UIGridViewBoundColumn DataField="StockCode" HeaderText="Stock Code" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="StockCode" 
                                    ResourceAssemblyName="" SortExpression="StockCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Manufacturer" HeaderText="Manufacturer" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Manufacturer" 
                                    ResourceAssemblyName="" SortExpression="Manufacturer">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Model" HeaderText="Model" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Model" 
                                    ResourceAssemblyName="" SortExpression="Model">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of measure" meta:resourcekey="UIGridViewBoundColumnResource5" 
                                    PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="UnitPrice" 
                                    ResourceAssemblyName="" SortExpression="UnitPrice" Visible="False">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Quantity" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
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
