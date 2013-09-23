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
        OStoreCheckOut storeCheckOut = Session["::SessionObject::"] as OStoreCheckOut;

        // To track the last StoreID in order to prevent user
        // from changing the store mid-way.
        //
        textStoreID.Text = storeCheckOut.StoreID.ToString();

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
        OStoreCheckOut storeCheckOut = Session["::SessionObject::"] as OStoreCheckOut;
        List<OStore> s = new List<OStore>();
        s.Add(TablesLogic.tStore.Load(storeCheckOut.StoreID));
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
            OStoreCheckOut storeCheckOut = Session["::SessionObject::"] as OStoreCheckOut;
            if (storeCheckOut != null)
            {
                Guid catalogId = (Guid)((DataRowView)e.Row.DataItem)["ObjectID"];
                OCatalogue catalog = TablesLogic.tCatalogue.Load(catalogId);

                DataTable storeBins = OStore.FindBinsByCatalogue(storeCheckOut.StoreID.Value, catalogId, false);
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
    }


    /// <summary>
    /// Occurs when the user clicks on Add Selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OStoreCheckOut storeCheckOut = Session["::SessionObject::"] as OStoreCheckOut;
        List<OStoreCheckOutItem> items = new List<OStoreCheckOutItem>();

        if (storeCheckOut.CurrentActivity.ObjectName == "Start" ||
            storeCheckOut.CurrentActivity.ObjectName == "Draft")
        {
            // Creates and binds the StoreCheckIn item objects.
            //
            foreach (GridViewRow row in gridResults.GetSelectedRows())
            {
                // Creates, binds and adds the StoreCheckInItem to the
                // StoreCheckIn object.
                //
                OStoreCheckOutItem item = TablesLogic.tStoreCheckOutItem.Create();
                Guid catalogId = (Guid)gridResults.DataKeys[row.RowIndex][0];
                item.CatalogueID = catalogId;
                gridResults.BindRowToObject(item, row);
                items.Add(item);

                // Validate that the store in the check-out page
                // has not been changed.
                //
                if (textStoreID.Text != storeCheckOut.StoreID.ToString())
                    ((UIFieldDropDownList)row.FindControl("dropStoreBin")).ErrorMessage = Resources.Errors.StoreCheckOut_StoreChanged;

            }
            if (!panelAddItems.IsValid)
            {
                panel.Message = panelAddItems.CheckErrorMessages();
                return;
            }

            // Adds the items into the StoreCheckIn object
            //
            foreach (OStoreCheckOutItem item in items)
            {
                item.ComputeBaseQuantity();
                item.ComputeEstimatedUnitCost();
                storeCheckOut.StoreCheckOutItems.Add(item);
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
        <web:search runat="server" ID="panel" Caption="Add Multiple Items" GridViewID="gridResults"
            BaseTable="tCatalogue" CloseWindowButtonVisible="true" OnPopulateForm="panel_PopulateForm"
            AddButtonVisible="false" EditButtonVisible="false" AddSelectedButtonVisible="true"
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
                    <ui:UIFieldDropDownList runat='server' ID="dropUnitOfMeasure" PropertyName="UnitOfMeasureID"
                        Caption="Unit of Measure" meta:resourcekey="dropUnitOfMeasureResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="textCatalogName" PropertyName="ObjectName"
                        Caption="Catalog Name" Span="Half" 
                        ToolTip="Part of the name of catalog items to search for" 
                        InternalControlWidth="95%" meta:resourcekey="textCatalogNameResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textManufacturer" PropertyName="Manufacturer"
                        Span="Half" Caption="Manufacturer" 
                        ToolTip="Manufacturer of the Catalog item." InternalControlWidth="95%" 
                        meta:resourcekey="textManufacturerResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textModel" PropertyName="Model" Span="Half"
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
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" SortExpression="ObjectNumber"
                            SetValidationGroupForSelectedRowsOnly="True" KeyName="ObjectID" Width="100%"
                            OnRowDataBound="gridResults_RowDataBound" DataKeyNames="ObjectID" 
                            GridLines="Both" meta:resourcekey="gridResultsResource1" 
                            RowErrorColor="" style="clear:both;">
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
                                <cc1:UIGridViewTemplateColumn HeaderText="Store Bin" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldDropDownList ID="dropStoreBin" runat="server" Caption="Store Bin" 
                                            FieldLayout="Flow" InternalControlWidth="200px" 
                                            meta:resourcekey="dropStoreBinResource1" PropertyName="StoreBinID" 
                                            ShowCaption="False" ValidateRequiredField="True">
                                        </cc1:UIFieldDropDownList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Check-Out Quantity" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textQuantity" runat="server" Caption="Quantity" 
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textQuantityResource1" PropertyName="ActualQuantity" 
                                            ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                            ValidationRangeMin="0" ValidationRangeMinInclusive="False" 
                                            ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Check-Out Unit" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource3">
                                    <ItemTemplate>
                                        <cc1:UIFieldDropDownList ID="dropCheckOutUnit" runat="server" 
                                            Caption="Check-Out Unit" FieldLayout="Flow" InternalControlWidth="100px" 
                                            meta:resourcekey="dropCheckOutUnitResource1" 
                                            PropertyName="ActualUnitOfMeasureID" ShowCaption="False" 
                                            ValidateRequiredField="True">
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
    </form>
</body>
</html>
