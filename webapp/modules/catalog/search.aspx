<%@ Page Language="C#" Inherits="PageBase" %>

<script runat="server">
    /// <summary>
    /// Initializes the controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeCatalogue.PopulateTree();
        dropUnitOfMeasure.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
    }


    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeCatalogue.SelectedValue != "")
        {
            OCatalogue Catalogue = TablesLogic.tCatalogue[new Guid(treeCatalogue.SelectedValue)];
            if (Catalogue != null)
                e.CustomCondition = TablesLogic.tCatalogue.HierarchyPath.Like(Catalogue.HierarchyPath + "%");
        }
    }


    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        return new CatalogueTreePopulater(null, true, false, true, true);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Inventory Catalog" GridViewID="gridResults" 
                BaseTable="tCatalogue" OnSearch="panel_Search" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"
                SearchType="ObjectQuery" SearchAssignedOnly="false" ></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1">
                        <ui:UIFieldTreeList runat="server" ID="treeCatalogue" Caption="Inventory Catalog" OnAcquireTreePopulater="treeCatalogue_AcquireTreePopulater" meta:resourcekey="treeCatalogueResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Catalog Name"
                            ToolTip="The Inventory Catalog name as displayed on the screen." Span="Half" meta:resourcekey="UIFieldString1Resource1" />
                        <ui:UIFieldRadioList runat="server" ID="IsCatalogueItem" PropertyName="IsCatalogueItem"
                            Caption="Group/Item" ToolTip="Indicates if the Inventory Catalog to search for is a Inventory Catalog group or item."
                            meta:resourcekey="IsCatalogueItemResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem selected="True" meta:resourcekey="ListItemResource1" Text="Any &#160;" Value=""></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2" Text="Inventory Catalog Group&#160;"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3" Text="Inventory Catalog Item"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelCatalogueItem1" meta:resourcekey="panelCatalogueItem1Resource1" BorderStyle="NotSet">
                            <ui:UIFieldTextBox runat="server" ID="StockCode" PropertyName="StockCode" Caption="Stock Code"
                                ToolTip="Stock code of the Inventory Catalog item." meta:resourcekey="StockCodeResource1" />
                            <ui:UIFieldTextBox runat="server" ID="Manufacturer" PropertyName="Manufacturer" Span="Half"
                                Caption="Manufacturer" ToolTip="Manufacturer of the Inventory Catalog item." meta:resourcekey="ManufacturerResource1" />
                            <ui:UIFieldTextBox runat="server" ID="Model" PropertyName="Model" Span="Half" Caption="Model"
                                ToolTip="Model of the Inventory Catalog item." meta:resourcekey="ModelResource1" />
                            <ui:UIFieldTextBox runat="server" ID="UnitPrice" PropertyName="UnitPrice" Span="Half"
                                Caption="Unit Price ($)" ToolTip="Standard unit price of the item." SearchType="Range"
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="UnitPriceResource1" />
                            <ui:UIFieldDropDownList runat="server" ID="dropUnitOfMeasure" PropertyName="UnitOfMeasureID"
                                Span="Half" Caption="Unit of Measure" ToolTip="Unit of measure for this Inventory Catalog item."
                                meta:resourcekey="UnitOfMeasureIDResource1" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            meta:resourcekey="gridResultsResource1" Width="100%" SortExpression="ObjectName" RowErrorColor="">
                            <Commands>
                                <ui:UIGridViewCommand CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" meta:resourcekey="UIGridViewColumnResource1" />
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" meta:resourcekey="UIGridViewColumnResource2" />
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewColumnResource3" />
                                <ui:UIGridViewBoundColumn PropertyName="Path" HeaderText="Catalog Name" meta:resourcekey="UIGridViewColumnResource4" />
                                <ui:UIGridViewBoundColumn PropertyName="IsCatalogueItemText" HeaderText="Type" meta:resourcekey="UIGridViewColumnResource9" />
                                <ui:UIGridViewBoundColumn PropertyName="InventoryCatalogTypeText"
                                    HeaderText="Type" />
                                <ui:UIGridViewBoundColumn PropertyName="StockCode" HeaderText="Stock Code" meta:resourcekey="UIGridViewColumnResource5" />
                                <ui:UIGridViewBoundColumn PropertyName="Manufacturer" HeaderText="Manufacturer" meta:resourcekey="UIGridViewColumnResource6" />
                                <ui:UIGridViewBoundColumn PropertyName="Model" HeaderText="Model" meta:resourcekey="UIGridViewColumnResource7" />
                                <ui:UIGridViewBoundColumn PropertyName="UnitOfMeasure.ObjectName" HeaderText="Unit of measure"
                                    meta:resourcekey="UIGridViewColumnResource8" />
                                <ui:UIGridViewBoundColumn PropertyName="UnitPrice" HeaderText="Unit Price ($)" DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewColumnResource10" />
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
