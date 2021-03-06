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
        ExpressionCondition additionalCondition = Query.True;

        // To track the last StoreID in order to prevent user
        // from changing the store mid-way.
        //
        OStoreCheckIn storeCheckIn = Session["::SessionObject::"] as OStoreCheckIn;
        textStoreID.Text = storeCheckIn.StoreID.ToString();

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
            additionalCondition &= stockCodeCondition;
        }

        if (treeCatalogue.SelectedValue != "")
            additionalCondition = additionalCondition & TablesLogic.tCatalogue.HierarchyPath.Like(
                TablesLogic.tCatalogue.Load(new Guid(treeCatalogue.SelectedValue)).HierarchyPath + "%");

        // Queries the custom result table.
        //        
        DataTable dt =
            TablesLogic.tCatalogue.Select(
            TablesLogic.tCatalogue.ObjectID,
            TablesLogic.tCatalogue.ObjectName,
            TablesLogic.tCatalogue.StockCode,
            TablesLogic.tCatalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure.ObjectName"))
            .Where(
            e.InputCondition &
            additionalCondition &
            TablesLogic.tCatalogue.IsDeleted == 0 &
            TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 1 &
            TablesLogic.tCatalogue.IsCatalogueItem == 1);

        e.CustomResultTable = dt;
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        return new CatalogueTreePopulater(null, true, false, false, true);
    }


    /// <summary>
    /// Binds the store bin dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OStoreCheckIn storeCheckIn = Session["::SessionObject::"] as OStoreCheckIn;
            if (storeCheckIn != null)
            {
                Guid catalogId = (Guid)((DataRowView)e.Row.DataItem)["ObjectID"];

                DataTable storeBins = OStore.FindBinsByCatalogue(storeCheckIn.StoreID.Value, catalogId, true);
                UIFieldDropDownList dropStoreBin = ((UIFieldDropDownList)e.Row.FindControl("dropStoreBin"));
                dropStoreBin.Bind(storeBins, "ObjectName", "ObjectID", true);
                if (dropStoreBin.Items.Count == 2)
                {
                    dropStoreBin.SelectedIndex = 1;
                    dropStoreBin.Enabled = false;
                }
            }
        }
    }



    /// <summary>
    /// Occurs when the user clicks on the add selected button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OStoreCheckIn storeCheckIn = Session["::SessionObject::"] as OStoreCheckIn;
        List<OStoreCheckInItem> items = new List<OStoreCheckInItem>();

        if (storeCheckIn.CurrentActivity.ObjectName == "Start" ||
            storeCheckIn.CurrentActivity.ObjectName == "Draft")
        {
            // Creates and binds the StoreCheckIn item objects.
            //
            foreach (GridViewRow row in gridResults.GetSelectedRows())
            {
                // Creates, binds and adds the StoreCheckInItem to the
                // StoreCheckIn object.
                //
                OStoreCheckInItem item = TablesLogic.tStoreCheckInItem.Create();
                item.CatalogueID = (Guid)gridResults.DataKeys[row.RowIndex][0];
                item.Quantity = 1;
                gridResults.BindRowToObject(item, row);

                // Validate that the store in the check-in page
                // has not been changed.
                //
                if (textStoreID.Text != storeCheckIn.StoreID.ToString())
                    ((UIFieldDropDownList)row.FindControl("dropStoreBin")).ErrorMessage = Resources.Errors.StoreCheckIn_StoreChanged;

                items.Add(item);
            }
            if (!panelAddEquipment.IsValid)
            {
                panel.Message = panelAddEquipment.CheckErrorMessages();
                return;
            }

            // Adds the items into the StoreCheckIn object
            //
            foreach (OStoreCheckInItem item in items)
                storeCheckIn.CheckInItems.Add(item);

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
        <web:search runat="server" ID="panel" Caption="Add Equipment" GridViewID="gridResults"
            AddSelectedButtonVisible="true" BaseTable="tCatalogue" CloseWindowButtonVisible="true"
            OnPopulateForm="panel_PopulateForm" AddButtonVisible="false" EditButtonVisible="false"
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
                    <ui:UIFieldDropDownList runat='server' ID="dropUnitOfMeasure" PropertyName="UnitOfMeasureID"
                        Caption="Unit of Measure" meta:resourcekey="dropUnitOfMeasureResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="textCatalogName" PropertyName="ObjectName"
                        Caption="Catalog Name" Span="Half" 
                        ToolTip="Part of the name of catalog items to search for" 
                        InternalControlWidth="95%" meta:resourcekey="textCatalogNameResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textStockCode" Span="Half" 
                        Caption="Stock Code" InternalControlWidth="95%" 
                        meta:resourcekey="textStockCodeResource1" />
                    <asp:TextBox runat="server" ID="textStoreID" Visible="False" 
                        meta:resourcekey="textStoreIDResource1"></asp:TextBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="tabResultsResource1">
                    <ui:UIObjectPanel runat="server" ID="panelAddEquipment" BorderStyle="NotSet" 
                        meta:resourcekey="panelAddEquipmentResource1">
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
                                            FieldLayout="Flow" InternalControlWidth="100px" 
                                            meta:resourcekey="dropStoreBinResource1" PropertyName="StoreBinID" 
                                            ShowCaption="False" ValidateRequiredField="True">
                                        </cc1:UIFieldDropDownList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Quantity" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textQuantity" runat="server" Caption="Quantity" 
                                            FieldLayout="Flow" InternalControlWidth="30px" 
                                            meta:resourcekey="textQuantityResource1" PropertyName="Quantity" 
                                            ShowCaption="False" ValidateRequiredField="True">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Unit Price ($)" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource3">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textUnitPrice" runat="server" Caption="Unit Price" 
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textUnitPriceResource1" PropertyName="UnitPrice" 
                                            ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                            ValidationNumberOfDecimalPlaces="2" ValidationRangeMin="0" 
                                            ValidationRangeMinInclusive="False" ValidationRangeType="Currency">
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
