<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase"
    Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    /// <summary>
    /// Populates the search controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeCatalogue.PopulateTree();
        dropUnitOfMeasure.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
    }


    /// <summary>
    /// Constructs custom condition for the search.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition =
            TablesLogic.tCatalogue.IsCatalogueItem == 1 &
            (TablesLogic.tCatalogue.InventoryCatalogType == InventoryCatalogType.Consumable |
            TablesLogic.tCatalogue.InventoryCatalogType == InventoryCatalogType.NonConsumable) &
            TablesLogic.tCatalogue.EquipmentTypeID == null;

        // Creates a condition that searches the catalog items
        // by a comma separated list of stock codes.
        //
        if (textStockCode.Text.Trim() != "")
        {
            string[] stockCodes = textStockCode.Text.Split(',');
            ExpressionCondition stockCodeCondition = Query.False;
            foreach (string stockCode in stockCodes)
                if (stockCode.Trim() != "")
                    stockCodeCondition |= TablesLogic.tCatalogue.StockCode.Like("%" + stockCode.Trim() + "%");
            e.CustomCondition &= stockCodeCondition;
        }

        if (treeCatalogue.SelectedValue != "")
            e.CustomCondition = e.CustomCondition &
                TablesLogic.tCatalogue.HierarchyPath.Like(
                TablesLogic.tCatalogue.Load(new Guid(treeCatalogue.SelectedValue)).HierarchyPath + "%");
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        return new CatalogueTreePopulater(null, true);
    }


    /// <summary>
    /// Occurs when the costing type changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropCostingType_SelectedIndexChanged(object sender, EventArgs e)
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
            UIFieldRadioList dropCostingType = c.FindControl("dropCostingType") as UIFieldRadioList;
            UIFieldTextBox textStandardCostingUnitPrice = c.FindControl("textStandardCostingUnitPrice") as UIFieldTextBox;
            Label labelUnitPriceNotApplicable = c.FindControl("labelUnitPriceNotApplicable") as Label;

            if (dropCostingType.SelectedValue == StoreItemCostingType.StandardCosting.ToString())
            {
                textStandardCostingUnitPrice.Visible = true;
                labelUnitPriceNotApplicable.Visible = false;
            }
            else
            {
                textStandardCostingUnitPrice.Visible = false;
                labelUnitPriceNotApplicable.Visible = true;
            }
        }
    }



    /// <summary>
    /// Occurs when the user clicks on Add Selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OStore store = Session["::SessionObject::"] as OStore;
        List<OStoreItem> items = new List<OStoreItem>();

        // Creates and binds the StoreCheckIn item objects.
        //
        foreach (GridViewRow row in gridResults.GetSelectedRows())
        {
            // Creates, binds and adds the StoreCheckInItem to the
            // StoreCheckIn object.
            //
            OStoreItem item = TablesLogic.tStoreItem.Create();
            Guid catalogId = (Guid)gridResults.DataKeys[row.RowIndex][0];
            item.CatalogueID = catalogId;

            gridResults.BindRowToObject(item, row);
            if (item.CostingType.Value != StoreItemCostingType.StandardCosting)
                item.StandardCostingUnitPrice = null;
            items.Add(item);
        }
        if (!panelAddItems.IsValid)
            return;

        store.StoreItems.AddRange(items);
        Window.Opener.ClickUIButton("buttonItemsAdded");
        Window.Close();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Add Inventory Catalogs" meta:resourcekey="panelResource1"
            GridViewID="gridResults" BaseTable="tCatalogue" CloseWindowButtonVisible="true"
            OnPopulateForm="panel_PopulateForm" AddButtonVisible="false"
            EditButtonVisible="false" AddSelectedButtonVisible="true"
            OnSearch="panel_Search" OnValidateAndAddSelected="panel_ValidateAndAddSelected">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabstrip" BorderStyle="NotSet" 
                meta:resourcekey="tabstripResource1">
                <ui:UITabView runat="server" ID="tabSearch" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                    <ui:UIFieldTreeList runat='server' ID="treeCatalogue" OnAcquireTreePopulater="treeCatalogue_AcquireTreePopulater"
                        Caption="Catalog" meta:resourcekey="treeCatalogueResource1" 
                        ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldDropDownList runat='server' ID="dropUnitOfMeasure"
                        PropertyName="UnitOfMeasureID" Caption="Unit of Measure" 
                        meta:resourcekey="dropUnitOfMeasureResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="textCatalogName" PropertyName="ObjectName"
                        Caption="Catalog Name" Span="Half" 
                        ToolTip="Part of the name of catalog items to search for" 
                        InternalControlWidth="95%" meta:resourcekey="textCatalogNameResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textManufacturer" PropertyName="Manufacturer"
                        Span="Half" Caption="Manufacturer" 
                        ToolTip="Manufacturer of the Catalog item." InternalControlWidth="95%" 
                        meta:resourcekey="textManufacturerResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textModel" PropertyName="Model"
                        Span="Half" Caption="Model" ToolTip="Model of the Catalog item." 
                        InternalControlWidth="95%" meta:resourcekey="textModelResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textStockCode" Span="Half"
                        Caption="Stock Code" InternalControlWidth="95%" 
                        meta:resourcekey="textStockCodeResource1" />
                    <asp:TextBox runat="server" ID="textStoreID" Visible="False" 
                        meta:resourcekey="textStoreIDResource1"></asp:TextBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="tabResultsResource1">
                    <ui:UIObjectPanel runat="server" ID="panelAddItems" BorderStyle="NotSet" 
                        meta:resourcekey="panelAddItemsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            SortExpression="ObjectNumber" SetValidationGroupForSelectedRowsOnly="True"
                            KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID" GridLines="Both" 
                            ImageRowErrorUrl="" meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Catalog Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StockCode" HeaderText="Stock Code" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="StockCode" 
                                    ResourceAssemblyName="" SortExpression="StockCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of Measure" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Costing Type" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldRadioList ID="dropCostingType" runat="server" Caption="CostingType" 
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="dropCostingTypeResource1" 
                                            OnSelectedIndexChanged="dropCostingType_SelectedIndexChanged" 
                                            PropertyName="CostingType" RepeatDirection="Vertical" ShowCaption="False" 
                                            TextAlign="Right" ValidateRequiredField="True">
                                            <Items>
                                                <asp:ListItem meta:resourcekey="ListItemResource1" Selected="True" Text="FIFO" 
                                                    Value="0"></asp:ListItem>
                                                <asp:ListItem meta:resourcekey="ListItemResource2" Text="LIFO" Value="1"></asp:ListItem>
                                                <asp:ListItem meta:resourcekey="ListItemResource3" Text="Standard" Value="3"></asp:ListItem>
                                                <asp:ListItem meta:resourcekey="ListItemResource4" Text="Average" Value="4"></asp:ListItem>
                                            </Items>
                                        </cc1:UIFieldRadioList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Item Type" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldRadioList ID="Catalogue_ItemType" runat="server" 
                                            Caption="Item Type" FieldLayout="Flow" InternalControlWidth="80px" 
                                            meta:resourcekey="Catalogue_ItemTypeResource1" PropertyName="ItemType" 
                                            RepeatColumns="0" RepeatDirection="Vertical" ShowCaption="False" 
                                            TextAlign="Right" ValidateRequiredField="True">
                                            <Items>
                                                <asp:ListItem meta:resourcekey="ListItemResource5" Selected="True" 
                                                    Text="Stocked" Value="0"></asp:ListItem>
                                                <asp:ListItem meta:resourcekey="ListItemResource6" Text="Non Stocked " 
                                                    Value="1"></asp:ListItem>
                                            </Items>
                                        </cc1:UIFieldRadioList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" Width="100px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Unit Price" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource3">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textStandardCostingUnitPrice" runat="server" 
                                            Caption="Unit Price" FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textStandardCostingUnitPriceResource1" 
                                            PropertyName="StandardCostingUnitPrice" ShowCaption="False" 
                                            ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                            ValidationRangeMin="0" ValidationRangeType="Currency" Visible="False">
                                        </cc1:UIFieldTextBox>
                                        <asp:Label ID="labelUnitPriceNotApplicable" runat="server" 
                                            meta:resourcekey="labelUnitPriceNotApplicableResource1" Text="Not Applicable"></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Reorder Quantity" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource4">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="txtReorderDefault" runat="server" 
                                            Caption="Reorder Quantity" FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="txtReorderDefaultResource1" PropertyName="ReorderDefault" 
                                            ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                            ValidationRangeMin="0" ValidationRangeMinInclusive="False" 
                                            ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" Width="100px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Reorder Threshold" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource5">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="txtReorderThreshold" runat="server" 
                                            Caption="Reorder Threshold" FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="txtReorderThresholdResource1" PropertyName="ReorderThreshold" 
                                            ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                            ValidationDataType="Currency" ValidationRangeMin="0" 
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
