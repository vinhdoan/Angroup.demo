<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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
        OStoreAdjust storeAdjust = Session["::SessionObject::"] as OStoreAdjust;

        // To track the last StoreID in order to prevent user
        // from changing the store mid-way.
        //
        textStoreID.Text = storeAdjust.StoreID.ToString();

        e.CustomCondition =
            TablesLogic.tStoreBinItem.StoreBin.StoreID == storeAdjust.StoreID &
            (TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType == InventoryCatalogType.Consumable |
            TablesLogic.tStoreBinItem.Catalogue.InventoryCatalogType == InventoryCatalogType.NonConsumable) &
            TablesLogic.tStoreBinItem.Catalogue.EquipmentTypeID == null;

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
                TablesLogic.tStoreBinItem.Catalogue.HierarchyPath.Like(
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
    /// Binds the store bins to the dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
    }



    /// <summary>
    /// Occurs when the user clicks the Add Selected button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OStoreAdjust storeAdjust = Session["::SessionObject::"] as OStoreAdjust;
        List<OStoreAdjustItem> items = new List<OStoreAdjustItem>();

        if (storeAdjust.CurrentActivity.ObjectName == "Start" ||
            storeAdjust.CurrentActivity.ObjectName == "Draft")
        {
            // Creates and binds the StoreCheckIn item objects.
            //
            foreach (GridViewRow row in gridResults.GetSelectedRows())
            {
                // Creates, binds and adds the StoreCheckInItem to the
                // StoreCheckIn object.
                //
                OStoreAdjustItem item = TablesLogic.tStoreAdjustItem.Create();

                Guid storeBinItemId = (Guid)gridResults.DataKeys[row.RowIndex][0];
                OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(storeBinItemId);
                item.CatalogueID = storeBinItem.CatalogueID;
                item.StoreBinID = storeBinItem.StoreBinID;
                item.StoreBinItemID = storeBinItem.ObjectID;
                gridResults.BindRowToObject(item, row);

                // Validate that the store in the transfer page
                // has not been changed.
                //
                if (textStoreID.Text != storeAdjust.StoreID.ToString())
                    ((UIFieldTextBox)row.FindControl("textQuantity")).ErrorMessage = Resources.Errors.StoreTransfer_StoreChanged;

                items.Add(item);
            }
            if (!panelAddItems.IsValid)
            {
                panel.Message = panelAddItems.CheckErrorMessages();
                return;
            }

            // Adds the items into the StoreCheckIn object
            //
            foreach (OStoreAdjustItem item in items)
                storeAdjust.StoreAdjustItems.Add(item);

            Window.Opener.ClickUIButton("buttonItemsAdded");
            Window.Close();
        }
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
        <web:search runat="server" ID="panel" Caption="Add Consumables/Non-Consumables" GridViewID="gridResults"
            BaseTable="tStoreBinItem" CloseWindowButtonVisible="true" OnPopulateForm="panel_PopulateForm"
            AddButtonVisible="false" EditButtonVisible="false" AddSelectedButtonVisible="true"
            OnSearch="panel_Search" OnValidateAndAddSelected="panel_ValidateAndAddSelected" meta:resourcekey="panelResource1">
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
                    <ui:UIFieldDropDownList runat='server' ID="dropUnitOfMeasure" PropertyName="Catalogue.UnitOfMeasureID"
                        Caption="Unit of Measure" meta:resourcekey="dropUnitOfMeasureResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="textCatalogName" PropertyName="Catalogue.ObjectName"
                        Caption="Catalog Name" Span="Half" 
                        ToolTip="Part of the name of catalog items to search for" 
                        InternalControlWidth="95%" meta:resourcekey="textCatalogNameResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textManufacturer" PropertyName="Catalogue.Manufacturer"
                        Span="Half" Caption="Manufacturer" 
                        ToolTip="Manufacturer of the Catalog item." InternalControlWidth="95%" 
                        meta:resourcekey="textManufacturerResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textModel" PropertyName="Catalogue.Model" Span="Half"
                        Caption="Model" ToolTip="Model of the Catalog item." 
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
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" SetValidationGroupForSelectedRowsOnly="True"
                            SortExpression="StoreBin.ObjectName ASC, Catalogue.ObjectName ASC" KeyName="ObjectID"
                            Width="100%" OnRowDataBound="gridResults_RowDataBound" 
                            DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="StoreBin.ObjectName" 
                                    HeaderText="Store Bin" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="StoreBin.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="StoreBin.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.ObjectName" 
                                    HeaderText="Catalog Name" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="Catalogue.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Catalogue.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.StockCode" 
                                    HeaderText="Stock Code" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="Catalogue.StockCode" ResourceAssemblyName="" 
                                    SortExpression="Catalogue.StockCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of Measure" meta:resourcekey="UIGridViewBoundColumnResource4" 
                                    PropertyName="Catalogue.UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" HeaderText="Unit Price ($)" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="UnitPrice" 
                                    ResourceAssemblyName="" SortExpression="UnitPrice">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PhysicalQuantity" HeaderText="Quantity" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" 
                                    PropertyName="PhysicalQuantity" ResourceAssemblyName="" 
                                    SortExpression="PhysicalQuantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Direction" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldRadioList ID="radioAdjustmentDirection" runat="server" 
                                            Caption="Direction" FieldLayout="Flow" 
                                            meta:resourcekey="radioAdjustmentDirectionResource1" PropertyName="AdjustUp" 
                                            RepeatColumns="0" ShowCaption="False" TextAlign="Right" 
                                            ValidateRequiredField="True">
                                            <Items>
                                                <asp:ListItem meta:resourcekey="ListItemResource1" Value="1" Text="Up"></asp:ListItem>
                                                <asp:ListItem meta:resourcekey="ListItemResource2" Value="0" Text="Down"></asp:ListItem>
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
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textQuantityResource1" PropertyName="Quantity" 
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
