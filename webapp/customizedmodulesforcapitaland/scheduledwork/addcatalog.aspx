<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase"
    Culture="auto" UICulture="auto" meta:resourcekey="PageResource2" %>

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
        OWork work = Session["::SessionObject::"] as OWork;

        dropStore.Bind(OStore.FindAccessibleStores(AppSession.User, "OWork", null));
        treeCatalogue.PopulateTree();
        dropUnitOfMeasure.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
    }


    /// <summary>
    /// Constructs custom condition for the search.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        OWork work = Session["::SessionObject::"] as OWork;

        // Search for only consumables to add to a work
        //
        e.CustomCondition =
            TablesLogic.tCatalogue.IsCatalogueItem == 1 &
            (TablesLogic.tCatalogue.InventoryCatalogType == InventoryCatalogType.Consumable) &
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
    /// Binds the store bins to the dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid catalogId = (Guid)((DataRowView)e.Row.DataItem)["ObjectID"];
            OCatalogue catalog = TablesLogic.tCatalogue.Load(catalogId);

            if (dropStore.SelectedValue == "")
                return;
            Guid storeId = new Guid(dropStore.SelectedValue);

            DataTable storeBins = OStore.FindBinsByCatalogue(storeId, catalogId, false);
            UIFieldDropDownList dropStoreBin = ((UIFieldDropDownList)e.Row.FindControl("dropStoreBin"));
            dropStoreBin.Bind(storeBins, "ObjectName", "ObjectID", true);
            if (dropStoreBin.Items.Count == 2)
            {
                dropStoreBin.SelectedIndex = 1;
                dropStoreBin.Enabled = false;
            }

            DataTable conversions = OUnitConversion.GetConversions(catalog.UnitOfMeasureID.Value, null);
            UIFieldDropDownList dropCheckOutUnit = ((UIFieldDropDownList)e.Row.FindControl("dropCheckOutUnit"));
            dropCheckOutUnit.Bind(conversions, "ObjectName", "ToUnitOfMeasureID", true);
            if (dropCheckOutUnit.Items.Count == 2)
            {
                dropCheckOutUnit.SelectedIndex = 1;
                dropCheckOutUnit.Enabled = false;
            }
            else
            {
                // auto-select the base unit
                //
                foreach (ListItem item in dropCheckOutUnit.Items)
                    if (item.Value == catalog.UnitOfMeasureID.ToString())
                    {
                        item.Selected = true;
                        break;
                    }
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
        OScheduledWork work = Session["::SessionObject::"] as OScheduledWork;
        List<OScheduledWorkCost> items = new List<OScheduledWorkCost>();

        if (work.CurrentActivity.ObjectName == "Start" ||
            work.CurrentActivity.ObjectName == "Draft" ||
            work.CurrentActivity.ObjectName == "PendingExecution" ||
            work.CurrentActivity.ObjectName == "PendingMaterial" ||
            work.CurrentActivity.ObjectName == "PendingContractor")
        {
            // Creates and binds the StoreCheckIn item objects.
            //
            foreach (GridViewRow row in gridResults.GetSelectedRows())
            {
                // Creates, binds and adds the StoreCheckInItem to the
                // StoreCheckIn object.
                //
                OScheduledWorkCost item = TablesLogic.tScheduledWorkCost.Create();
                Guid catalogId = (Guid)gridResults.DataKeys[row.RowIndex][0];
                item.CostType = WorkCostType.Material;
                item.CatalogueID = catalogId;

                item.ObjectName = item.Catalogue != null ? item.Catalogue.ObjectName : "";
                item.CostDescription = item.Catalogue != null ? item.Catalogue.ObjectName : "";
                item.EstimatedCostFactor = 1.0M;

                gridResults.BindRowToObject(item, row);
                if (item.StoreBin != null)
                    item.StoreID = item.StoreBin.StoreID;

                item.EstimatedUnitCost = OStore.ComputeAverageUnitCost(
                    (Guid)item.CatalogueID,
                    item.StoreID,
                    item.StoreBinID,
                    (Guid)item.UnitOfMeasureID);
                
                items.Add(item);
            }
            if (!panelAddItems.IsValid)
                return;

            work.ScheduledWorkCost.AddRange(items);
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
    <div>
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Add Inventory Items"
                GridViewID="gridResults" BaseTable="tCatalogue" CloseWindowButtonVisible="true"
                OnPopulateForm="panel_PopulateForm" AddButtonVisible="false"
                EditButtonVisible="false" AddSelectedButtonVisible="true"
                OnSearch="panel_Search" OnValidateAndAddSelected="panel_ValidateAndAddSelected">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabstrip" BorderStyle="NotSet" meta:resourcekey="tabstripResource1">
                    <ui:UITabView runat="server" ID="tabSearch" Caption="Search" BorderStyle="NotSet" meta:resourcekey="tabSearchResource2">
                        <ui:UIFieldDropDownList runat="server" ID="dropStore" ValidateRequiredField='True'
                            Caption="Store" meta:resourcekey="dropStoreResource2">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTreeList runat='server' ID="treeCatalogue" OnAcquireTreePopulater="treeCatalogue_AcquireTreePopulater"
                            Caption="Catalog" meta:resourcekey="treeCatalogueResource2" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldDropDownList runat='server' ID="dropUnitOfMeasure"
                            PropertyName="UnitOfMeasureID" Caption="Unit of Measure" meta:resourcekey="dropUnitOfMeasureResource2">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="textCatalogName" PropertyName="ObjectName"
                            Caption="Catalog Name" Span="Half" ToolTip="Part of the name of catalog items to search for" InternalControlWidth="95%" meta:resourcekey="textCatalogNameResource2" />
                        <ui:UIFieldTextBox runat="server" ID="textManufacturer" PropertyName="Manufacturer"
                            Span="Half" Caption="Manufacturer" ToolTip="Manufacturer of the Catalog item." InternalControlWidth="95%" meta:resourcekey="textManufacturerResource2" />
                        <ui:UIFieldTextBox runat="server" ID="textModel" PropertyName="Model"
                            Span="Half" Caption="Model" ToolTip="Model of the Catalog item." InternalControlWidth="95%" meta:resourcekey="textModelResource2" />
                        <ui:UIFieldTextBox runat="server" ID="textStockCode" Span="Half"
                            Caption="Stock Code" InternalControlWidth="95%" meta:resourcekey="textStockCodeResource2" />
                        <asp:TextBox runat="server" ID="textStoreID" Visible="False" meta:resourcekey="textStoreIDResource1"></asp:TextBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabResults" Caption="Results" BorderStyle="NotSet" meta:resourcekey="tabResultsResource2">
                        <ui:UIObjectPanel runat="server" ID="panelAddItems" BorderStyle="NotSet" meta:resourcekey="panelAddItemsResource1">
                            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                                SortExpression="ObjectNumber" SetValidationGroupForSelectedRowsOnly="True"
                                KeyName="ObjectID" Width="100%" OnRowDataBound="gridResults_RowDataBound" 
                                DataKeyNames="ObjectID" GridLines="Both" 
                                meta:resourcekey="gridResultsResource1" RowErrorColor="" style="clear:both;">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Columns>
                                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Catalog Name" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="StockCode" HeaderText="Stock Code" meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="StockCode" ResourceAssemblyName="" SortExpression="StockCode">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Unit of Measure" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Store Bin" meta:resourcekey="UIGridViewTemplateColumnResource4">
                                        <ItemTemplate>
                                            <cc1:UIFieldDropDownList ID="dropStoreBin" runat="server" Caption="Store Bin" FieldLayout="Flow" InternalControlWidth="200px" meta:resourcekey="dropStoreBinResource2" PropertyName="StoreBinID" ShowCaption="False" ValidateRequiredField="True">
                                            </cc1:UIFieldDropDownList>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Check-Out Quantity" meta:resourcekey="UIGridViewTemplateColumnResource5">
                                        <ItemTemplate>
                                            <cc1:UIFieldTextBox ID="textQuantity" runat="server" Caption="Quantity" FieldLayout="Flow" InternalControlWidth="50px" meta:resourcekey="textQuantityResource2" PropertyName="EstimatedQuantity" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeMinInclusive="False" ValidationRangeType="Currency">
                                            </cc1:UIFieldTextBox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Check-Out Unit" meta:resourcekey="UIGridViewTemplateColumnResource6">
                                        <ItemTemplate>
                                            <cc1:UIFieldDropDownList ID="dropCheckOutUnit" runat="server" Caption="Check-Out Unit" FieldLayout="Flow" InternalControlWidth="100px" meta:resourcekey="dropCheckOutUnitResource2" PropertyName="UnitOfMeasureID" ShowCaption="False" ValidateRequiredField="True">
                                            </cc1:UIFieldDropDownList>
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
    </div>
    </form>
</body>
</html>
