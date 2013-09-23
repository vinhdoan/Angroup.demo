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
        OStoreTransfer storeTransfer = Session["::SessionObject::"] as OStoreTransfer;
        TStoreBinItem sbi = TablesLogic.tStoreBinItem;
        TCatalogue c = TablesLogic.tCatalogue;

        textFromStoreID.Text = storeTransfer.FromStoreID.ToString() + "," + storeTransfer.FromStoreType.ToString();
        textToStoreID.Text = storeTransfer.ToStoreID.ToString() + "," + storeTransfer.ToStoreType.ToString();

        ExpressionCondition catalogTypeCondition =
            c.InventoryCatalogType == InventoryCatalogType.Consumable |
            c.InventoryCatalogType == InventoryCatalogType.NonConsumable;

        // Checks that if any of the store location is an issue location
        // then we exclude consumables from the search.
        //
        if (storeTransfer.FromStoreType == StoreType.IssueLocation ||
            storeTransfer.ToStoreType == StoreType.IssueLocation)
        {
            catalogTypeCondition = c.InventoryCatalogType == InventoryCatalogType.NonConsumable;
            hintNonConsumablesOnly.Visible = true;
        }
        else
            hintNonConsumablesOnly.Visible = false;

        // Construct the search condition.
        //
        e.CustomCondition =
            sbi.Select(sbi.ObjectID)
                .Where(sbi.StoreBin.StoreID == storeTransfer.FromStoreID &
                sbi.CatalogueID == c.ObjectID).Exists() &
            c.IsCatalogueItem == 1 &
            catalogTypeCondition &
            c.EquipmentTypeID == null;

        // Creates a condition that searches the catalog items
        // by a comma separated list of stock codes.
        //
        if (textStockCode.Text.Trim() != "")
        {
            string[] stockCodes = textStockCode.Text.Split(',');
            ExpressionCondition stockCodeCondition = Query.False;
            foreach (string stockCode in stockCodes)
                if (stockCode.Trim() != "")
                    stockCodeCondition |= c.StockCode.Like("%" + stockCode.Trim() + "%");
            e.CustomCondition &= stockCodeCondition;
        }

        if (treeCatalogue.SelectedValue != "")
            e.CustomCondition = e.CustomCondition &
                c.HierarchyPath.Like(
                c.Load(new Guid(treeCatalogue.SelectedValue)).HierarchyPath + "%");
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        OStoreTransfer storeTransfer = Session["::SessionObject::"] as OStoreTransfer;
        List<OStore> s = new List<OStore>();
        s.Add(TablesLogic.tStore.Load(storeTransfer.FromStoreID));
        return new CatalogueTreePopulater(treeCatalogue.SelectedValue, true, false, true, false, s);
    }



    /// <summary>
    /// Binds the store bins to the dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OStoreTransfer storeTransfer = Session["::SessionObject::"] as OStoreTransfer;
            if (storeTransfer != null)
            {
                Guid catalogId = (Guid)((DataRowView)e.Row.DataItem)["ObjectID"];
                OCatalogue catalog = TablesLogic.tCatalogue.Load(catalogId);

                DataTable fromStoreBins = OStore.FindBinsByCatalogue(storeTransfer.FromStoreID, catalogId, false);
                UIFieldDropDownList dropFromStoreBin = ((UIFieldDropDownList)e.Row.FindControl("dropFromStoreBin"));
                dropFromStoreBin.Bind(fromStoreBins, "ObjectName", "ObjectID", true);
                if (dropFromStoreBin.Items.Count == 2)
                {
                    dropFromStoreBin.SelectedIndex = 1;
                    dropFromStoreBin.Enabled = false;
                }

                DataTable toStoreBins = OStore.FindBinsByCatalogue(storeTransfer.ToStoreID, catalogId, true);
                UIFieldDropDownList dropToStoreBin = ((UIFieldDropDownList)e.Row.FindControl("dropToStoreBin"));
                dropToStoreBin.Bind(toStoreBins, "ObjectName", "ObjectID", true);
                if (dropToStoreBin.Items.Count == 2)
                {
                    dropToStoreBin.SelectedIndex = 1;
                    dropToStoreBin.Enabled = false;
                }

            }
        }
    }


    /// <summary>
    /// Add selected items into the StoreTransfer.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = Session["::SessionObject::"] as OStoreTransfer;
        List<OStoreTransferItem> items = new List<OStoreTransferItem>();

        if (storeTransfer.CurrentActivity.ObjectName == "Start" ||
            storeTransfer.CurrentActivity.ObjectName == "Draft")
        {
            // Creates and binds the StoreCheckIn item objects.
            //
            foreach (GridViewRow row in gridResults.GetSelectedRows())
            {
                // Creates, binds and adds the StoreCheckInItem to the
                // StoreCheckIn object.
                //
                OStoreTransferItem item = TablesLogic.tStoreTransferItem.Create();
                Guid catalogId = (Guid)gridResults.DataKeys[row.RowIndex][0];
                item.CatalogueID = catalogId;
                gridResults.BindRowToObject(item, row);
                items.Add(item);

                if (textFromStoreID.Text != storeTransfer.FromStoreID.ToString() + "," + storeTransfer.FromStoreType.ToString() ||
                    textToStoreID.Text != storeTransfer.ToStoreID.ToString() + "," + storeTransfer.ToStoreType.ToString())
                {
                    UIFieldDropDownList dropFromStoreBin = ((UIFieldDropDownList)row.FindControl("dropFromStoreBin"));
                    UIFieldDropDownList dropToStoreBin = ((UIFieldDropDownList)row.FindControl("dropToStoreBin"));

                    dropFromStoreBin.ErrorMessage = Resources.Errors.Transfer_FromStoreToStoreChanged;
                    dropToStoreBin.ErrorMessage = Resources.Errors.Transfer_FromStoreToStoreChanged;

                }
            }
            if (!panelAddItems.IsValid)
                return;

            // Adds the items into the StoreCheckIn object
            //
            foreach (OStoreTransferItem item in items)
            {
                item.ComputeEstimatedUnitCost();
                storeTransfer.StoreTransferItems.Add(item);
            }
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
        <web:search runat="server" ID="panel" Caption="Add Multiple Items"
            GridViewID="gridResults" BaseTable="tCatalogue" CloseWindowButtonVisible="true"
            OnPopulateForm="panel_PopulateForm" AddButtonVisible="false"
            AddSelectedButtonVisible="true" EditButtonVisible="false"
            OnSearch="panel_Search" OnValidateAndAddSelected="panel_ValidateAndAddSelected">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabstrip" BorderStyle="NotSet" 
                meta:resourcekey="tabstripResource1">
                <ui:UITabView runat="server" ID="tabSearch" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                    <asp:TextBox runat="server" ID="textFromStoreID" Visible="False" 
                        meta:resourcekey="textFromStoreIDResource1"></asp:TextBox>
                    <asp:TextBox runat="server" ID="textToStoreID" Visible="False" 
                        meta:resourcekey="textToStoreIDResource1"></asp:TextBox>
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
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="tabResultsResource1">
                    <ui:UIObjectPanel runat="server" ID="panelAddItems" BorderStyle="NotSet" 
                        meta:resourcekey="panelAddItemsResource1">
                        <ui:UIHint runat="server" ID="hintNonConsumablesOnly" 
                            meta:resourcekey="hintNonConsumablesOnlyResource1" Text=""><asp:Table 
                            runat="server" CellPadding="4" CellSpacing="0" Width="100%" 
                                meta:resourcekey="TableResource1">
                                <asp:TableRow 
                                runat="server" meta:resourcekey="TableRowResource1"><asp:TableCell runat="server" 
                                        VerticalAlign="Top" Width="16px" meta:resourcekey="TableCellResource1"><asp:Image 
                                    runat="server" ImageUrl="~/images/information.gif" 
                                        meta:resourcekey="ImageResource1" /></asp:TableCell>
                                    <asp:TableCell 
                                    runat="server" VerticalAlign="Top" meta:resourcekey="TableCellResource2"><asp:Label 
                                        runat="server" meta:resourcekey="LabelResource1"> You can only add non-consumables for this transfer because you have selected an issue location to transfer items from OR an issue location to transfer items to. </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            SortExpression="ObjectNumber" SetValidationGroupForSelectedRowsOnly="True"
                            KeyName="ObjectID" Width="100%" OnRowDataBound="gridResults_RowDataBound" 
                            DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" 
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
                                <cc1:UIGridViewTemplateColumn HeaderText="From Bin" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldDropDownList ID="dropFromStoreBin" runat="server" 
                                            Caption="Store Bin" FieldLayout="Flow" InternalControlWidth="200px" 
                                            meta:resourcekey="dropFromStoreBinResource1" PropertyName="FromStoreBinID" 
                                            ShowCaption="False" ValidateRequiredField="True">
                                        </cc1:UIFieldDropDownList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="To Bin" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldDropDownList ID="dropToStoreBin" runat="server" Caption="Store Bin" 
                                            FieldLayout="Flow" InternalControlWidth="200px" 
                                            meta:resourcekey="dropToStoreBinResource1" PropertyName="ToStoreBinID" 
                                            ShowCaption="False" ValidateRequiredField="True">
                                        </cc1:UIFieldDropDownList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Quantity to Transfer" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource3">
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
