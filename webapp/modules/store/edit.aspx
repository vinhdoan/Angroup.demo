<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase"
    Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OStore store = panel.SessionObject as OStore;

        NotifyUser1.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYADMIN", store.Location)));
        NotifyUser2.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYADMIN", store.Location)));
        NotifyUser3.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYADMIN", store.Location)));
        NotifyUser4.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYADMIN", store.Location)));
        LocationID.PopulateTree();

        // Disable the screen entirely if the store is an
        // issue location.
        //
        if (store.StoreType == StoreType.IssueLocation)
        {
            tabObject.Enabled = false;
        }

        panel.ObjectPanel.BindObjectToControls(store);
    }


    /// <summary>
    /// Validates and saves the store object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OStore store = panel.SessionObject as OStore;
            panel.ObjectPanel.BindControlsToObject(store);

            // Validate
            //
            if (store.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            store.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Location_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(((OStore)panel.SessionObject).LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CatalogueItemID_AcquireTreePopulater(object sender)
    {
        OStoreItem storeItem = Catalogue_SubPanel.SessionObject as OStoreItem;
        return new CatalogueTreePopulater(storeItem.CatalogueID, true, true, true, true);
    }


    /// <summary>
    /// Populates the Store Item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Catalogue_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OStoreItem storeItem = Catalogue_SubPanel.SessionObject as OStoreItem;

        // Sets the costing type of the store item to 
        // what has been set in the store.
        //
        if (storeItem.CostingType == null)
            storeItem.CostingType = OApplicationSetting.Current.InventoryDefaultCostingType;

        Catalogue_CatalogueItemID.PopulateTree();
        Catalogue_CatalogueItemID.Enabled = storeItem.IsNew;
        panelInventoryDetail.Visible = storeItem.Catalogue != null &&
            storeItem.Catalogue.InventoryCatalogType != InventoryCatalogType.Equipment;

        Catalogue_SubPanel.ObjectPanel.BindObjectToControls(storeItem);

        Catalogue_CostingType.Enabled = gridStoreItemBatches.Rows.Count == 0;


    }


    /// <summary>
    /// Validates and adds the Store Item object into the Store.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Catalogue_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OStore store = (OStore)panel.SessionObject;

        OStoreItem storeItem = (OStoreItem)Catalogue_SubPanel.SessionObject;
        Catalogue_SubPanel.ObjectPanel.BindControlsToObject(storeItem);

        // Validate
        //
        if (store.HasDuplicateStoreItem(storeItem))
            Catalogue_CatalogueItemID.ErrorMessage = Resources.Errors.Store_DuplicateItem;
        if (!Catalogue_SubPanel.ObjectPanel.IsValid)
            return;

        // Update
        //
        if (storeItem.ItemType.Value == StoreItemType.NonStocked ||
            storeItem.ItemType.Value == StoreItemType.SpecialOrder)
        {
            storeItem.ReorderDefault = null;
            storeItem.ReorderThreshold = null;
        }

        // Add
        //
        store.StoreItems.Add(storeItem);
        panelCatalogue.BindObjectToControls(store);
    }


    /// <summary>
    /// Occurs when the user selects an item from the item type radio
    /// button list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Catalogue_ItemType_SelectedIndexChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Occurs when the user clicks on the buttons in the
    /// Store Item gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gridCatalogue_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "ViewTransactions")
        {
            foreach (object o in objectIds)
            {
                panel.FocusWindow = false;
                Window.Open("transaction.aspx?ID=" + HttpUtility.UrlEncode(Security.EncryptGuid((Guid)o)), "AnacleEAM_Transaction");
                break;
            }
        }
    }


    /// <summary>
    /// Occurs when the user clicks on the Generate Purchase Request for
    /// Low Inventory Items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePR_Click(object sender, EventArgs e)
    {
        OStore store = panel.SessionObject as OStore;
        panel.ObjectPanel.BindControlsToObject(store);

        panel.Message = "";
        gridCatalogue.ErrorMessage = "";
        if (store.CheckLowInventoryItems())
        {
            OPurchaseRequest pr = store.GeneratePurchaseRequestForLowInventoryItems((Guid)AppSession.User.ObjectID);
            Window.OpenEditObjectPage(this, "OPurchaseRequest", pr.ObjectID.ToString(), "");
        }
        else
        {
            panel.Message = Resources.Errors.Store_NoLowInventoryItems;
            gridCatalogue.ErrorMessage = Resources.Errors.Store_NoLowInventoryItems;
        }
    }


    /// <summary>
    /// Occurs when the user clicks on the Add Multiple Items button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddCatalogs_Click(object sender, EventArgs e)
    {
        OStore store = panel.SessionObject as OStore;
        panel.ObjectPanel.BindControlsToObject(store);

        Window.Open("addcatalog.aspx");
        panel.FocusWindow = false;
    }


    /// <summary>
    /// Occurs when the user adds selected items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OStore store = (OStore)panel.SessionObject;

        panelCatalogue.BindObjectToControls(store);
    }


    /// <summary>
    /// Occurs when the user selects a node in the location treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        OStore store = (OStore)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(store);

        NotifyUser1.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYMANAGER", store.Location)));
        NotifyUser2.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYMANAGER", store.Location)));
        NotifyUser3.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYMANAGER", store.Location)));
        NotifyUser4.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleAndLocation("INVENTORYMANAGER", store.Location)));

        panel.ObjectPanel.BindControlsToObject(store);
    }


    /// <summary>
    /// Highlights low inventory items in red.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridCatalogue_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (Convert.ToBoolean(((DataRowView)e.Row.DataItem)["HasLowInventory"]) == true)
            {
                e.Row.BackColor = Color.FromArgb(0xff7777);
            }
        }
    }


    /// <summary>
    /// Populates the store bin subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreBin_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OStoreBin storeBin = StoreBin_SubPanel.SessionObject as OStoreBin;
        StoreBin_SubPanel.ObjectPanel.BindObjectToControls(storeBin);
    }


    /// <summary>
    /// Validates and adds the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreBin_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OStore store = (OStore)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(store);

        OStoreBin storeBin = (OStoreBin)StoreBin_SubPanel.SessionObject;
        StoreBin_SubPanel.ObjectPanel.BindControlsToObject(storeBin);

        // Validate
        //
        if (store.HasDuplicateStoreBin(storeBin))
            StoreBin_Name.ErrorMessage = Resources.Errors.Store_DuplicateBin;

        // Add
        //
        store.StoreBins.Add(storeBin);
        panel.ObjectPanel.BindObjectToControls(store);
    }


    /// <summary>
    /// Hides/shows and enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelReorder.Visible = Catalogue_ItemType.SelectedIndex == 0;
        panelStandardCosting.Visible = Catalogue_CostingType.SelectedValue == "3";
    }


    /// <summary>
    /// Occurs when the user selects a different costing type.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Catalogue_CostingType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects a node in the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Catalogue_CatalogueItemID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OStoreItem storeItem = Catalogue_SubPanel.SessionObject as OStoreItem;

        Catalogue_SubPanel.ObjectPanel.BindControlsToObject(storeItem);
        panelInventoryDetail.Visible = storeItem.Catalogue != null && storeItem.Catalogue.InventoryCatalogType != InventoryCatalogType.Equipment;
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
        <web:object runat="server" ID="panel" Caption="Store" BaseTable="tStore"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"
            OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" 
                meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Details"
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false">
                    </web:base>
                    <ui:UIFieldTreeList runat="server" ID="LocationID" PropertyName="LocationID"
                        OnSelectedNodeChanged="Location_SelectedNodeChanged" Caption="Location"
                        ValidateRequiredField="True" OnAcquireTreePopulater="Location_AcquireTreePopulater"
                        ToolTip="Location of the store." meta:resourcekey="LocationIDResource1" 
                        ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                    <ui:UIFieldDropDownList runat="server" ID="NotifyUser1" PropertyName="NotifyUser1ID"
                        Span="Half" Caption="Notify User1" meta:resourcekey="NotifyUser1Resource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="NotifyUser2" PropertyName="NotifyUser2ID"
                        Span="Half" Caption="Notify User2" meta:resourcekey="NotifyUser2Resource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="NotifyUser3" PropertyName="NotifyUser3ID"
                        Span="Half" Caption="Notify User3" meta:resourcekey="NotifyUser3Resource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="NotifyUser4" PropertyName="NotifyUser4ID"
                        Span="Half" Caption="Notify User4" meta:resourcekey="NotifyUser4Resource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldLabel runat="server" ID="TotalCostOfStock" PropertyName="TotalCostOfStock"
                        Caption="Total Cost of Stock ($)" DataFormatString="{0:#,##0.00}"
                        meta:resourcekey="TotalCostOfStockResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Bin" 
                    meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                    <!--Store Bin view-->
                    <ui:UIGridView runat="server" ID="gridBin" PropertyName="StoreBins"
                        Caption="Store Bins" CheckBoxColumnVisible="False" KeyName="ObjectID"
                        meta:resourcekey="gridBinResource1" Width="100%" PagingEnabled="True" 
                        RowErrorColor="" DataKeyNames="ObjectID" GridLines="Both" 
                        style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                meta:resourceKey="UIGridViewCommandResource1" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" 
                                CommandName="EditObject" ImageUrl="~/images/edit.gif" 
                                meta:resourceKey="UIGridViewColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                ConfirmText="Are you sure you wish to delete this item?" 
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Bin Name" 
                                meta:resourceKey="UIGridViewColumnResource3" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                meta:resourceKey="UIGridViewColumnResource4" PropertyName="Description" 
                                ResourceAssemblyName="" SortExpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TotalPhysicalCost" 
                                DataFormatString="{0:#,##0.00}" HeaderText="Physical Cost of Stock ($)" 
                                meta:resourceKey="UIGridViewColumnResource5" PropertyName="TotalPhysicalCost" 
                                ResourceAssemblyName="" SortExpression="TotalPhysicalCost">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn 
                                HeaderText="Locked for Stock Taking" 
                                PropertyName="IsLockedText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="StoreBin_Panel" 
                        meta:resourcekey="StoreBin_PanelResource1" BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="StoreBin_SubPanel" GridViewID="gridBin"
                            OnValidateAndUpdate="StoreBin_SubPanel_ValidateAndUpdate"
                            OnPopulateForm="StoreBin_SubPanel_PopulateForm" />
                        <ui:UIFieldTextBox runat="server" ID="StoreBin_Name" PropertyName="ObjectName"
                            ValidateRequiredField="True" Caption="Bin Name" Span="Half"
                            ToolTip="Name of the bin in this store." 
                            meta:resourcekey="StoreBin_NameResource1" InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="StoreBin_LocationDescription"
                            PropertyName="Description" Caption="Description" ToolTip="Description on the bin location."
                            meta:resourcekey="StoreBin_LocationDescriptionResource1" 
                            InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
                        <ui:UIGridView runat="server" ID="StoreBin_GridView" PropertyName="StoreBinItemsConsolidated"
                            Caption="Items in this Bin" CheckBoxColumnVisible="False"
                            KeyName="ObjectID" meta:resourcekey="StoreBin_GridViewResource1"
                            Width="100%" PagingEnabled="True"
                            RowErrorColor="" DataKeyNames="ObjectID" GridLines="Both" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue" HeaderText="Catalog" 
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="Catalogue" 
                                    ResourceAssemblyName="" SortExpression="Catalogue">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure" 
                                    HeaderText="Unit of Measure" meta:resourceKey="UIGridViewColumnResource7" 
                                    PropertyName="UnitOfMeasure" ResourceAssemblyName="" 
                                    SortExpression="UnitOfMeasure">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AvailableQuantity" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Available Bal" 
                                    meta:resourceKey="UIGridViewColumnResource8" PropertyName="AvailableQuantity" 
                                    ResourceAssemblyName="" SortExpression="AvailableQuantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PhysicalQuantity" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Physical Bal" 
                                    meta:resourceKey="UIGridViewColumnResource9" PropertyName="PhysicalQuantity" 
                                    ResourceAssemblyName="" SortExpression="PhysicalQuantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PhysicalCost" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Total Physical Cost ($)" 
                                    meta:resourceKey="UIGridViewColumnResource10" PropertyName="PhysicalCost" 
                                    ResourceAssemblyName="" SortExpression="PhysicalCost">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabCatalog" Caption="Catalog"
                    meta:resourcekey="uitabview5Resource1" BorderStyle="NotSet">
                    <!--Inventory Catalog-->
                    <ui:UIButton runat="server" ID="buttonGeneratePR" ImageUrl="~/images/add.gif"
                        Text="Generate Purchase Request for Low Inventory Items"
                        ConfirmText="Are you sure you wish to generate a purchase request from low inventory store items?"
                        OnClick="buttonGeneratePR_Click" meta:resourcekey="buttonGeneratePRResource1" />
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelAddCatalogButtons" BorderStyle="NotSet" 
                        meta:resourcekey="panelAddCatalogButtonsResource1">
                        <ui:UIButton runat="server" ID="buttonAddCatalogs" Text="Add Inventory Catalogs"
                            ImageUrl="~/images/add.gif" OnClick="buttonAddCatalogs_Click"
                            CausesValidation="False" meta:resourcekey="buttonAddCatalogsResource1" />
                        <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False"
                            OnClick="buttonItemsAdded_Click" 
                            meta:resourcekey="buttonItemsAddedResource1"></ui:UIButton>
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelCatalogue" BorderStyle="NotSet" 
                        meta:resourcekey="panelCatalogueResource1">
                        <ui:UIGridView runat="server" ID="gridCatalogue" PropertyName="StoreItems"
                            OnRowDataBound="gridCatalogue_RowDataBound" Caption="Store Catalog"
                            CheckBoxColumnVisible="False" OnAction="gridCatalogue_Action"
                            KeyName="ObjectID" meta:resourcekey="gridCatalogueResource1"
                            Width="100%" PagingEnabled="True"
                            RowErrorColor="" DataKeyNames="ObjectID" GridLines="Both" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                    meta:resourceKey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" 
                                    CommandName="EditObject" ImageUrl="~/images/edit.gif" 
                                    meta:resourceKey="UIGridViewColumnResource11">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                    ConfirmText="Are you sure you wish to remove this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource12">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" 
                                    CommandName="ViewTransactions" CommandText="View Transactions" 
                                    ImageUrl="~/images/table.gif" meta:resourceKey="UIGridViewColumnResource13">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.ObjectName" 
                                    HeaderText="Catalog" meta:resourceKey="UIGridViewColumnResource14" 
                                    PropertyName="Catalogue.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Catalogue.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemTypeText" HeaderText="Item Type" 
                                    meta:resourceKey="UIGridViewColumnResource15" PropertyName="ItemTypeText" 
                                    ResourceAssemblyName="" SortExpression="ItemTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CostingTypeText" 
                                    HeaderText="Costing Type" meta:resourceKey="UIGridViewColumnResource16" 
                                    PropertyName="CostingTypeText" ResourceAssemblyName="" 
                                    SortExpression="CostingTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of Measure" meta:resourceKey="UIGridViewColumnResource17" 
                                    PropertyName="Catalogue.UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ReorderDefault" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Reorder Qty" 
                                    meta:resourceKey="UIGridViewColumnResource18" PropertyName="ReorderDefault" 
                                    ResourceAssemblyName="" SortExpression="ReorderDefault">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ReorderThreshold" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Reorder Threshold" 
                                    meta:resourceKey="UIGridViewColumnResource19" PropertyName="ReorderThreshold" 
                                    ResourceAssemblyName="" SortExpression="ReorderThreshold">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableQuantity" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Available Bal" 
                                    meta:resourceKey="UIGridViewColumnResource20" 
                                    PropertyName="TotalAvailableQuantity" ResourceAssemblyName="" 
                                    SortExpression="TotalAvailableQuantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="HasLowInventory" 
                                    DataFormatString="&lt;img src='../../images/warn-{0}.gif'/&gt;" 
                                    HeaderText="Low?" HtmlEncode="False" 
                                    meta:resourceKey="UIGridViewColumnResource21" PropertyName="HasLowInventory" 
                                    ResourceAssemblyName="" SortExpression="HasLowInventory">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalPhysicalQuantity" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Physical Bal" 
                                    meta:resourceKey="UIGridViewColumnResource22" 
                                    PropertyName="TotalPhysicalQuantity" ResourceAssemblyName="" 
                                    SortExpression="TotalPhysicalQuantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalPhysicalCost" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Physical Cost ($)" 
                                    meta:resourceKey="UIGridViewColumnResource23" PropertyName="TotalPhysicalCost" 
                                    ResourceAssemblyName="" SortExpression="TotalPhysicalCost">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="Catalogue_Panel" 
                            meta:resourcekey="Catalogue_PanelResource1" BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="Catalogue_SubPanel" OnPopulateForm="Catalogue_SubPanel_PopulateForm"
                                GridViewID="gridCatalogue" MultiSelectColumnNames="CatalogueID,CostingType,ItemType,ReorderDefault,ReorderThreshold"
                                OnValidateAndUpdate="Catalogue_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTreeList runat="server" ID="Catalogue_CatalogueItemID"
                                PropertyName="CatalogueID" Caption="Catalog Item" ValidateRequiredField="True"
                                OnAcquireTreePopulater="CatalogueItemID_AcquireTreePopulater"
                                ToolTip="Catalog item that this store item refers to" meta:resourcekey="Catalogue_CatalogueItemIDResource1"
                                OnSelectedNodeChanged="Catalogue_CatalogueItemID_SelectedNodeChanged" 
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIPanel runat="server" ID="panelInventoryDetail" BorderStyle="NotSet" 
                                meta:resourcekey="panelInventoryDetailResource1">
                                <ui:UIFieldRadioList runat="server" ID="Catalogue_CostingType"
                                    PropertyName="CostingType" ValidateRequiredField="True" Caption="Costing Type"
                                    ToolTip="Costing type that this store item will be tied to."
                                    RepeatColumns="0" meta:resourcekey="Catalogue_CostingTypeResource1"
                                    OnSelectedIndexChanged="Catalogue_CostingType_SelectedIndexChanged" 
                                    TextAlign="Right">
                                    <Items>
                                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource1"
                                            Text="FIFO"></asp:ListItem>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource2"
                                            Text="LIFO"></asp:ListItem>
                                        <asp:ListItem Value="3" Text="Standard Costing" meta:resourcekey="ListItemResource5" 
                                            ></asp:ListItem>
                                        <asp:ListItem Value="4" Text="Average Costing" meta:resourcekey="ListItemResource6" 
                                            ></asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIPanel runat="server" ID="panelStandardCosting" BorderStyle="NotSet" 
                                    meta:resourcekey="panelStandardCostingResource1">
                                    <ui:UIFieldTextBox runat="server" ID="textStandardCostingUnitPrice"
                                        ValidationDataType="Currency" ValidateRequiredField="True"
                                        ValidationNumberOfDecimalPlaces="2" ValidateRangeField='True'
                                        ValidationRangeType="Currency" ValidationRangeMin="0" PropertyName="StandardCostingUnitPrice"
                                        Caption="Standard Costing Unit Price ($)" CaptionWidth="180px"
                                        Span="Half" 
                                        ToolTip="Unit price of all items of this catalog in the store when the standard costing type is used." 
                                        InternalControlWidth="95%" 
                                        meta:resourcekey="textStandardCostingUnitPriceResource1">
                                    </ui:UIFieldTextBox>
                                </ui:UIPanel>
                                <ui:UISeparator runat="server" ID="separatorReorder" 
                                    meta:resourcekey="separatorReorderResource1" />
                                <ui:UIFieldRadioList runat='server' ID="Catalogue_ItemType" PropertyName="ItemType"
                                    ValidateRequiredField='True' RepeatColumns="0" Caption="Item Type"
                                    OnSelectedIndexChanged="Catalogue_ItemType_SelectedIndexChanged"
                                    meta:resourcekey="Catalogue_ItemTypeResource1" TextAlign="Right">
                                    <Items>
                                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource3"
                                            Text="Stocked"></asp:ListItem>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource4"
                                            Text="Non-Stocked"></asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIPanel runat="server" ID="panelReorder" 
                                    meta:resourcekey="panelReorderResource1" BorderStyle="NotSet">
                                    <ui:UIFieldTextBox runat="server" ID="Catalogue_ReorderDefault"
                                        ValidationDataType="Double" ValidationRangeMin="0" PropertyName="ReorderDefault"
                                        Caption="Reorder Quantity" Span="Half" ToolTip="Default reorder quantity of the store item."
                                        meta:resourcekey="Catalogue_ReorderDefaultResource1" 
                                        ValidateRangeField="True" ValidationRangeMinInclusive="False" 
                                        ValidationRangeType="Double" InternalControlWidth="95%">
                                    </ui:UIFieldTextBox>
                                    <ui:UIFieldTextBox runat="server" ID="Catalogue_ReorderThreshold"
                                        ValidationDataType="Double" ValidationRangeMin="0" PropertyName="ReorderThreshold"
                                        Caption="Reorder Threshold " Span="Half" ToolTip="Reorder threshold quantity of the store item."
                                        meta:resourcekey="Catalogue_ReorderThresholdResource1" 
                                        ValidateRangeField="True" ValidationRangeMinInclusive="False" 
                                        ValidationRangeType="Double" InternalControlWidth="95%">
                                    </ui:UIFieldTextBox>
                                </ui:UIPanel>
                            </ui:UIPanel>
                            <ui:UISeparator runat="server" ID="UISeparator1" meta:resourcekey="UISeparator1Resource1" />
                            <ui:UIGridView runat="server" ID="gridStoreItemBatches" PropertyName="StoreItemBatch"
                                Caption="Item Batches" CheckBoxColumnVisible="False" SortExpression="BatchDate"
                                KeyName="ObjectID" meta:resourcekey="UIGridView1Resource1"
                                Width="100%" PagingEnabled="True"
                                RowErrorColor="" DataKeyNames="ObjectID" GridLines="Both" 
                                style="clear:both;">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Columns>
                                    <cc1:UIGridViewBoundColumn DataField="BatchDate" 
                                        DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Batch Date" 
                                        meta:resourceKey="UIGridViewColumnResource24" PropertyName="BatchDate" 
                                        ResourceAssemblyName="" SortExpression="BatchDate">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Equipment" HeaderText="Equipment" 
                                        meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Equipment" 
                                        ResourceAssemblyName="" SortExpression="Equipment">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="LotNumber" HeaderText="Lot Number" 
                                        meta:resourceKey="UIGridViewColumnResource25" PropertyName="LotNumber" 
                                        ResourceAssemblyName="" SortExpression="LotNumber">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ExpiryDate" 
                                        DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Expiry Date" 
                                        meta:resourceKey="UIGridViewColumnResource26" PropertyName="ExpiryDate" 
                                        ResourceAssemblyName="" SortExpression="ExpiryDate">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="UnitPrice" 
                                        DataFormatString="{0:#,##0.00##}" HeaderText="Unit Price ($)" 
                                        meta:resourceKey="UIGridViewColumnResource27" PropertyName="UnitPrice" 
                                        ResourceAssemblyName="" SortExpression="UnitPrice">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="PhysicalQuantity" 
                                        DataFormatString="{0:#,##0.00##}" HeaderText="Physical Bal" 
                                        meta:resourceKey="UIGridViewColumnResource28" PropertyName="PhysicalQuantity" 
                                        ResourceAssemblyName="" SortExpression="PhysicalQuantity">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="PhysicalCost" 
                                        DataFormatString="{0:#,##0.00##}" HeaderText="Physical Cost ($)" 
                                        meta:resourceKey="UIGridViewColumnResource29" PropertyName="PhysicalCost" 
                                        ResourceAssemblyName="" SortExpression="PhysicalCost">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Memo" 
                    meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Attachments"
                    meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
