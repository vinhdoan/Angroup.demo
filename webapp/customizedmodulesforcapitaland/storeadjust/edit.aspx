<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OStoreAdjust adjust = panel.SessionObject as OStoreAdjust;
        if (Request["StoreID"] != null)
            adjust.StoreID = new Guid(Security.Decrypt(Request["StoreID"].ToString()));

        StoreID.Bind(
            OStore.FindAccessibleStores(AppSession.User,
            Security.Decrypt(Request["TYPE"]),
            adjust.StoreID));

        objectBase.ObjectNumberVisible = !adjust.IsNew;

        if (adjust.StoreStockTakeID != null)
        {
            buttonViewStockTake.Visible = AppSession.User.AllowViewAll("OStoreStockTake");
            buttonEditStockTake.Visible = AppSession.User.AllowEditAll("OStoreStockTake") || OActivity.CheckAssignment(AppSession.User, adjust.StoreStockTakeID);
        }

        // Show currency symbols on specific controls.
        //
        if (!IsPostBack)
        {
            //CostOfStockAdjusted.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            CostOfStockAdjustedDownwards.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            CostOfStockAdjustedUpwards.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";

            ((UIGridViewBoundColumn)gridAdjustItem.Columns[5]).DataFormatString = OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
            ((UIGridViewBoundColumn)gridAdjustItem.Columns[12]).DataFormatString = OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
        }

        panel.ObjectPanel.BindObjectToControls(adjust);
    }


    /// <summary>
    /// Validates and saves the Store Adjustment object
    /// into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OStoreAdjust storeAdjust = panel.SessionObject as OStoreAdjust;

            // Validate
            //
            if (objectBase.SelectedAction == "SubmitForApproval" ||
                objectBase.SelectedAction == "Approve" ||
                objectBase.SelectedAction == "Commit")
            {
                if (!storeAdjust.ValidateSufficientItemsForAdjustment())
                {
                    string list = "";
                    foreach (OStoreAdjustItem item in storeAdjust.StoreAdjustItems)
                        list += (list == "" ? "" : Resources.Messages.General_CommaSeparator) +
                            item.Catalogue.ObjectName + " (" + item.StoreBin.ObjectName + ")";

                    ((UIGridView)Page.FindControl("gridAdjustItem")).ErrorMessage = String.Format(Resources.Errors.Adjust_InsufficientItems, list);
                }
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            storeAdjust.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Initializes the controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void AdjustItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OStoreAdjust adjust = panel.SessionObject as OStoreAdjust;
        panel.ObjectPanel.BindControlsToObject(adjust);

        OStoreAdjustItem storeAdjustItem = AdjustItem_SubPanel.SessionObject as OStoreAdjustItem;

        Adjust_CatalogueID.PopulateTree();

        Adjust_StoreBinID.Items.Clear();
        if (adjust.Store != null)
            Adjust_StoreBinID.Bind(adjust.Store.StoreBins);

        Adjust_StoreBinItemID.Items.Clear();
        if (storeAdjustItem.StoreBin != null)
            Adjust_StoreBinItemID.Bind(
                storeAdjustItem.StoreBin.GetStoreBinItemsList(storeAdjustItem.CatalogueID), "BatchDetail", "ObjectID", true);

        AdjustItem_SubPanel.ObjectPanel.BindObjectToControls(storeAdjustItem);
    }


    /// <summary>
    /// Validates and adds the store adjust item.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void AdjustItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OStoreAdjust adjust = (OStoreAdjust)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(adjust);

        OStoreAdjustItem item = (OStoreAdjustItem)AdjustItem_SubPanel.SessionObject;
        AdjustItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        // Validate
        //
        if (adjust.HasDuplicateAdjustItems(item))
            this.Adjust_StoreBinItemID.ErrorMessage = Resources.Errors.Adjust_DuplicateItem;
        
        // Validates quantity if its a Whole Number according to Catalog Type
        if (Adjust_CatalogueID.SelectedValue != "")
        {
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(Adjust_CatalogueID.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(Adjust_Quantity.Text) != 0)
            {
                Adjust_Quantity.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }
        }
        if (!AdjustItem_SubPanel.ObjectPanel.IsValid)
            return;

        // Additional processing
        //
        Adjust_CatalogueID.SelectedValue = "";
        this.Adjust_StoreBinID.SelectedIndex = 0;
        this.Adjust_Quantity.Text = "";

        // Add
        //
        adjust.StoreAdjustItems.Add(item);
        panel.ObjectPanel.BindObjectToControls(adjust);
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Adjust_CatalogueID_AcquireTreePopulater(object sender)
    {
        OStoreAdjustItem storeAdjustItem = this.AdjustItem_SubPanel.SessionObject as OStoreAdjustItem;
        List<OStore> s = new List<OStore>();
        s.Add(TablesLogic.tStore.Load(new Guid(StoreID.SelectedValue)));
        return new CatalogueTreePopulater(Adjust_CatalogueID.SelectedValue, true, true, true, true, s);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OStoreAdjust adjust = (OStoreAdjust)panel.SessionObject;

        buttonAddItems.Visible = StoreID.SelectedValue != "";
        gridAdjustItem.Visible = StoreID.SelectedValue != "";
        StoreID.Enabled = gridAdjustItem.Rows.Count == 0 && !AdjustItem_Panel.Visible;

        panelDetails.Enabled =
            objectBase.CurrentObjectState != "Committed" &&
            objectBase.CurrentObjectState != "PendingApproval";
        tabDetails.Enabled = objectBase.CurrentObjectState != "Cancelled";

        labelStoreStockTake.Visible = adjust.StoreStockTakeID != null;
        panelAdjustmentDetails.Enabled = adjust.StoreStockTakeID == null;
    }


    /// <summary>
    /// Occurs when the user selects a different destination type.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DestinationType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects a different store in the store
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreAdjust adjust = (OStoreAdjust)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(adjust);

        Adjust_StoreBinID.Items.Clear();
        if (adjust.Store != null)
            Adjust_StoreBinID.Bind(adjust.Store.StoreBins);
    }


    /// <summary>
    /// Occurs when the user selects a different store bin from
    /// the store bin dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Adjust_StoreBinID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreAdjustItem item = (OStoreAdjustItem)this.AdjustItem_SubPanel.SessionObject;
        AdjustItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        Adjust_StoreBinItemID.Items.Clear();
        if (item.StoreBin != null && item.CatalogueID != null)
            Adjust_StoreBinItemID.Bind(item.StoreBin.GetStoreBinItemsList((Guid)item.CatalogueID), "BatchDetail", "ObjectID", true);
    }


    /// <summary>
    /// Occurs when the user selects a different store bin item.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Adjust_StoreBinItemID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreAdjustItem item = (OStoreAdjustItem)this.AdjustItem_SubPanel.SessionObject;
        AdjustItem_SubPanel.ObjectPanel.BindControlsToObject(item);
        AdjustItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Occurs when the user selects a node in the catalog treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Adjust_CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OStoreAdjust adjust = (OStoreAdjust)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(adjust);

        OStoreAdjustItem item = (OStoreAdjustItem)this.AdjustItem_SubPanel.SessionObject;
        AdjustItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        // update the bins and the unit of measure conversion
        //
        Adjust_StoreBinItemID.Items.Clear();
        if (item.StoreBin != null && item.CatalogueID != null)
            Adjust_StoreBinItemID.Bind(item.StoreBin.GetStoreBinItemsList((Guid)item.CatalogueID), "BatchDetail", "ObjectID", true);

        AdjustItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Occurs when the user clicks on the "Add Consumables/Non-Consumables" button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddItems_Click(object sender, EventArgs e)
    {
        OStoreAdjust storeAdjust = (OStoreAdjust)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(storeAdjust);
        panel.FocusWindow = false;
        Window.Open("additems.aspx", "AnacleEAM_Popup");
    }


    /// <summary>
    /// Occurs when the user confirms and closes the pop-up window.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OStoreAdjust storeAdjust = panel.SessionObject as OStoreAdjust;
        panel.ObjectPanel.BindControlsToObject(storeAdjust);
        panel.ObjectPanel.BindObjectToControls(storeAdjust);
    }


    /// <summary>
    /// Occurs when the user clicks on the edit stock take button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditStockTake_Click(object sender, EventArgs e)
    {
        OStoreAdjust adjust = panel.SessionObject as OStoreAdjust;

        if (AppSession.User.AllowEditAll("OStoreStockTake") || OActivity.CheckAssignment(AppSession.User, adjust.StoreStockTakeID))
            Window.OpenEditObjectPage(Page, "OStoreStockTake", adjust.StoreStockTakeID.ToString(), "");
        else
            panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
    }

    /// <summary>
    /// Occurs when the user clicks on the view stock take button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewStockTake_Click(object sender, EventArgs e)
    {
        OStoreAdjust storeAdjust = panel.SessionObject as OStoreAdjust;
        Window.OpenViewObjectPage(Page, "OStoreStockTake", storeAdjust.StoreStockTakeID.ToString(), "");
    }

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void gridAdjustItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[12].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
                e.Row.Cells[11].Text = Convert.ToDecimal(e.Row.Cells[11].Text).ToString("#,##0");
        }
    }

    /// <summary>
    /// Used to check for whole number in Check in quantity
    /// </summary>
    private int NumberDecimalPlaces(string dec)
    {
        string numberStr = dec.Trim();
        string decSeparator = ".";
        // or "NumberFormatInfo.CurrentInfo.CurrencyDecimalSepar ator"

        int index = numberStr.IndexOf(decSeparator);
        int decPlaces;
        if (index == -1)
            decPlaces = 0;
        else
            decPlaces = numberStr.Length - (index + decSeparator.Length);
        return decPlaces;
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
    <ui:UIObjectPanel runat="server" id="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Adjustment" BaseTable="tStoreAdjust"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Adjustment" 
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameVisible="false"
                        ObjectNumberCaption="Adjustment Number" ObjectNumberEnabled="false" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIPanel runat="server" ID="panelDetails" BorderStyle="NotSet" 
                        meta:resourcekey="panelDetailsResource1">
                        <ui:UIFieldLabel runat="server" ID="labelStoreStockTake" PropertyName="StoreStockTake.ObjectNumber"
                            Caption="Stock Take" ContextMenuAlwaysEnabled="True" DataFormatString="" 
                            meta:resourcekey="labelStoreStockTakeResource1">
                            <ContextMenuButtons>
                                <ui:UIButton runat="server" ID="buttonViewStockTake" Text="View Stock Take" ImageUrl="~/images/view.gif"
                                    OnClick="buttonViewStockTake_Click" AlwaysEnabled="True" 
                                    meta:resourcekey="buttonViewStockTakeResource1" />
                                <ui:UIButton runat="server" ID="buttonEditStockTake" Text="Edit Stock Take" ImageUrl="~/images/edit.gif"
                                    OnClick="buttonEditStockTake_Click" AlwaysEnabled="True" 
                                    meta:resourcekey="buttonEditStockTakeResource1" />
                            </ContextMenuButtons>
                        </ui:UIFieldLabel>
                        <ui:UIPanel runat="server" ID="panelAdjustmentDetails" BorderStyle="NotSet" 
                            meta:resourcekey="panelAdjustmentDetailsResource1">
                            <ui:UIFieldDropDownList runat="server" ID="StoreID" PropertyName="StoreID" Caption="Store"
                                OnSelectedIndexChanged="StoreID_SelectedIndexChanged" meta:resourcekey="StoreIDResource1"
                                ValidateRequiredField="True" />
                            <ui:UIFieldTextBox runat="server" ID="Description" PropertyName="Description" Caption="Remarks"
                                ToolTip="Remarks for the check in." TextMode="MultiLine" 
                                meta:resourcekey="DescriptionResource1" InternalControlWidth="95%">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldLabel ID="CostOfStockAdjustedUpwards" Caption="Adjustment Up" PropertyName="CostOfStockAdjustedUpwards"
                                runat="server" Span="Half" DataFormatString="{0:#,##0.00##}" meta:resourcekey="CostOfStockAdjustedUpwardsResource1" />
                            <ui:UIFieldLabel ID="CostOfStockAdjustedDownwards" Caption="Adjustment Down" PropertyName="CostOfStockAdjustedDownwards"
                                runat="server" Span="Half" DataFormatString="{0:#,##0.00##}" meta:resourcekey="CostOfStockAdjustedDownwardsResource1" />
                            <br />
                            <br />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIButton runat="server" ID="buttonAddItems" Text="Add Multiple Items"
                                ImageUrl="~/images/add.gif" CausesValidation="False" 
                                OnClick="buttonAddItems_Click"  />
                            <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False" 
                                OnClick="buttonItemsAdded_Click" meta:resourcekey="buttonItemsAddedResource1" />
                            <br />
                            <br />
                            <ui:UIGridView runat="server" ID="gridAdjustItem" PropertyName="StoreAdjustItems"
                                Caption="Adjustment Items" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="gridAdjustItemResource1"
                                Width="100%" ValidateRequiredField="True" ShowFooter='True' 
                                PageSize="1000" DataKeyNames="ObjectID" GridLines="Both" 
                                RowErrorColor="" style="clear:both;" 
                                OnRowDataBound="gridAdjustItem_RowDataBound">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Commands>
                                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                        CommandName="DeleteObject" CommandText="Delete" 
                                        ConfirmText="Are you sure you wish to delete the selected items?" 
                                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                        CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                        meta:resourceKey="UIGridViewCommandResource2" />
                                </Commands>
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
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.ObjectName" 
                                        HeaderText="Catalog" meta:resourceKey="UIGridViewColumnResource3" 
                                        PropertyName="Catalogue.ObjectName" ResourceAssemblyName="" 
                                        SortExpression="Catalogue.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.StockCode" 
                                        HeaderText="Stock Code" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                        PropertyName="Catalogue.StockCode" ResourceAssemblyName="" 
                                        SortExpression="Catalogue.StockCode">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="StoreBin.ObjectName" HeaderText="Bin" 
                                        meta:resourceKey="UIGridViewColumnResource4" PropertyName="StoreBin.ObjectName" 
                                        ResourceAssemblyName="" SortExpression="StoreBin.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="StoreBinItem.UnitPrice" 
                                        DataFormatString="{0:n}" HeaderText="Unit Price" 
                                        meta:resourceKey="UIGridViewColumnResource5" 
                                        PropertyName="StoreBinItem.UnitPrice" ResourceAssemblyName="" 
                                        SortExpression="StoreBinItem.UnitPrice">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="StoreBinItem.LotNumber" 
                                        HeaderText="Lot Number" meta:resourceKey="UIGridViewColumnResource6" 
                                        PropertyName="StoreBinItem.LotNumber" ResourceAssemblyName="" 
                                        SortExpression="StoreBinItem.LotNumber">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="StoreBinItem.BatchDate" 
                                        DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Batch Date" 
                                        meta:resourceKey="UIGridViewColumnResource7" 
                                        PropertyName="StoreBinItem.BatchDate" ResourceAssemblyName="" 
                                        SortExpression="StoreBinItem.BatchDate">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="StoreBinItem.ExpiryDate" 
                                        DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Expiry Date" 
                                        meta:resourceKey="UIGridViewColumnResource8" 
                                        PropertyName="StoreBinItem.ExpiryDate" ResourceAssemblyName="" 
                                        SortExpression="StoreBinItem.ExpiryDate">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="AdjustText" HeaderText="Direction" 
                                        meta:resourceKey="UIGridViewColumnResource9" PropertyName="AdjustText" 
                                        ResourceAssemblyName="" SortExpression="AdjustText">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Quantity" 
                                        HeaderText="Adjustment Quantity" meta:resourceKey="UIGridViewColumnResource10" 
                                        PropertyName="Quantity" ResourceAssemblyName="" SortExpression="Quantity">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" 
                                        HeaderText="UOM" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                        PropertyName="Catalogue.UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                        SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="SubTotal" DataFormatString="{0:n}" 
                                        FooterAggregate="Sum" HeaderText="SubTotal" 
                                        meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="SubTotal" 
                                        ResourceAssemblyName="" SortExpression="SubTotal">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="AdjustItem_Panel" 
                                meta:resourcekey="AdjustItem_PanelResource1" BorderStyle="NotSet">
                                <web:subpanel runat="server" ID="AdjustItem_SubPanel" GridViewID="gridAdjustItem"
                                    OnPopulateForm="AdjustItem_SubPanel_PopulateForm" OnValidateAndUpdate="AdjustItem_SubPanel_ValidateAndUpdate" />
                                <ui:UIFieldTreeList runat="server" ID="Adjust_CatalogueID" PropertyName="CatalogueID"
                                    OnSelectedNodeChanged="Adjust_CatalogueID_SelectedNodeChanged" Caption="Catalog Item"
                                    ValidateRequiredField="True" OnAcquireTreePopulater="Adjust_CatalogueID_AcquireTreePopulater"
                                    ToolTip="Catalog item to adjust" 
                                    meta:resourcekey="Adjust_CatalogueIDResource1" ShowCheckBoxes="None" 
                                    TreeValueMode="SelectedNode" />
                                <ui:UIFieldDropDownList runat="server" ID="Adjust_StoreBinID" PropertyName="StoreBinID"
                                    ValidateRequiredField="True" Caption="Bin" Span="Half" ToolTip="The bin where the item to adjust can be found."
                                    OnSelectedIndexChanged="Adjust_StoreBinID_SelectedIndexChanged" meta:resourcekey="Adjust_StoreBinIDResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="Adjust_StoreBinItemID" PropertyName="StoreBinItemID"
                                    ValidateRequiredField="True" Caption="Item Batch" OnSelectedIndexChanged="Adjust_StoreBinItemID_SelectedIndexChanged"
                                    meta:resourcekey="Adjust_StoreBinItemIDResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldLabel ID="Adjust_PhysicalQUantity" Caption="Physical Quantity" PropertyName="StoreBinItem.PhysicalQuantity"
                                    runat="server" Span="Half" 
                                    meta:resourcekey="Adjust_PhysicalQUantityResource1" DataFormatString="" />
                                <ui:UIFieldLabel ID="Adjust_UnitOfMeasure" Caption="Unit of Measure" PropertyName="StoreBinItem.Catalogue.UnitOfMeasure.ObjectName"
                                    runat="server" Span="Half" 
                                    meta:resourcekey="Adjust_UnitOfMeasureResource1" DataFormatString="" />
                                <ui:UIFieldLabel ID="Adjust_StoreBinItem_BatchDate" Caption="Batch Date" PropertyName="StoreBinItem.BatchDate"
                                    runat="server" DataFormatString="{0:dd-MMM-yyyy}" Span="Half" meta:resourcekey="Adjust_StoreBinItem_BatchDateResource1" />
                                <ui:UIFieldLabel ID="Adjust_StoreBinItem_LotNumber" Caption="Lot Number" PropertyName="StoreBinItem.LotNumber"
                                    runat="server" Span="Half" 
                                    meta:resourcekey="Adjust_StoreBinItem_LotNumberResource1" DataFormatString="" />
                                <ui:UIFieldLabel ID="Adjust_StoreBinItem_ExpiryDate" Caption="Expiry Date" PropertyName="StoreBinItem.ExpiryDate"
                                    runat="server" DataFormatString="{0:dd-MMM-yyyy}" Span="Half" meta:resourcekey="Adjust_StoreBinItem_ExpiryDateResource1" />
                                <ui:UIFieldLabel ID="Adjust_StoreBinItem_UnitPrice" Caption="Unit Price ($)" PropertyName="StoreBinItem.UnitPrice"
                                    runat="server" DataFormatString="{0:#,##0.00##}" Span="Half" meta:resourcekey="Adjust_StoreBinItem_UnitPriceResource1" />
                                <br />
                                <ui:UIFieldRadioList runat="server" ID="Adjust_AdjustUp" PropertyName="AdjustUp"
                                    ValidateRequiredField="True" Caption="Adjustment Direction" 
                                    RepeatColumns="0" meta:resourcekey="Adjust_AdjustUpResource1" TextAlign="Right">
                                    <Items>
                                        <asp:ListItem value="1" meta:resourcekey="ListItemResource1" Text="Up"></asp:ListItem>
                                        <asp:ListItem value="0" meta:resourcekey="ListItemResource2" Text="Down"></asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldTextBox runat="server" ID="Adjust_Quantity" Caption="Quantity to Adjust"
                                    PropertyName="Quantity" ValidateRequiredField="True" ValidateRangeField="True"
                                    ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Currency"
                                    Span="Half" meta:resourcekey="Adjust_QuantityResource1" 
                                    InternalControlWidth="95%" />
                                <ui:uifieldlabel runat="server" id="labelUnitOfMeasure" CAption="Unit of Measure"
                                    PropertyName="Catalogue.UnitOfMeasure.ObjectName" DataFormatString="" 
                                    meta:resourcekey="labelUnitOfMeasureResource1">
                                </ui:uifieldlabel>
                            </ui:UIObjectPanel>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Status History" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview1Resource2">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
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
