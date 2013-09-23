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
        OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
        objectBase.ObjectNumberVisible = !storeCheckOut.IsNew;

        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), storeCheckOut.StoreID));
        UserID.Bind(OUser.GetAllUsers());

        if (!IsPostBack)
        {
            ((UIGridViewBoundColumn)gridCheckOutItem.Columns[10]).DataFormatString =
                OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
            
            ((UIGridViewBoundColumn)gridCheckOutItem.Columns[11]).DataFormatString =
                OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
        }

        panel.ObjectPanel.BindObjectToControls(storeCheckOut);
    }


    /// <summary>
    /// Validates and saves the Store Check-out object 
    /// into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
            panel.ObjectPanel.BindControlsToObject(storeCheckOut);

            // Validate
            //
            if (objectBase.SelectedAction == "SubmitForApproval" ||
                objectBase.SelectedAction == "Approve" ||
                objectBase.SelectedAction == "Commit")
            {
                if (!storeCheckOut.ValidateSufficientItemsForCheckout())
                {
                    string list = "";
                    foreach (OStoreCheckOutItem item in storeCheckOut.StoreCheckOutItems)
                        if (!item.Valid)
                            list += (list == "" ? "" : Resources.Messages.General_CommaSeparator) + item.Catalogue.ObjectName + " (" + item.StoreBin.ObjectName + ")";

                    gridCheckOutItem.ErrorMessage = String.Format(Resources.Errors.CheckOut_InsufficientItems, list);
                }

                // Validates to ensure that the none of the store bins
                // are locked before we try to check in.
                //
                string lockedBins = storeCheckOut.ValidateBinsNotLocked();
                if (lockedBins != "")
                    gridCheckOutItem.ErrorMessage = String.Format(Resources.Errors.StoreCheckOut_StoreBinsLocked, lockedBins);
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            storeCheckOut.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Initializes the controls in the check-out item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void CheckOutItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
        OStoreCheckOutItem item = CheckOutItem_SubPanel.SessionObject as OStoreCheckOutItem;

        CheckOut_CatalogueID.PopulateTree();

        CheckOut_StoreBinID.Items.Clear();
        CheckOut_ActualUnitOfMeasureID.Items.Clear();

        if (storeCheckOut.StoreID != null && item.CatalogueID != null)
        {
            CheckOut_StoreBinID.Bind(
                OStore.FindBinsByCatalogue(storeCheckOut.StoreID, item.CatalogueID, true, item.StoreBinID),
                "ObjectName", "ObjectID", true);
            CheckOut_ActualUnitOfMeasureID.Bind(
                OUnitConversion.GetConversions(item.Catalogue.UnitOfMeasureID, item.ActualUnitOfMeasureID), "ObjectName", "ToUnitOfMeasureID", false);
        }
        
        CheckOutItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Validates and inserts the store check-out item
    /// into the store check-out object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckOutItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OStoreCheckOut storeCheckOut = (OStoreCheckOut)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(storeCheckOut);

        OStoreCheckOutItem item = (OStoreCheckOutItem)CheckOutItem_SubPanel.SessionObject;
        CheckOutItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        // Compute the estimated unit cost for the items.
        //
        item.ComputeBaseQuantity();
        item.ComputeEstimatedUnitCost();

        // Insert
        //
        storeCheckOut.StoreCheckOutItems.Add(item);
        panel.ObjectPanel.BindObjectToControls(storeCheckOut);
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CatalogueID_AcquireTreePopulater(object sender)
    {
        OStoreCheckOutItem storeCheckOutItem = this.CheckOutItem_SubPanel.SessionObject as OStoreCheckOutItem;
        return new CatalogueTreePopulater(storeCheckOutItem.CatalogueID, true, true);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OStoreCheckOut checkout = (OStoreCheckOut)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(checkout);

        buttonAddItems.Visible = checkout.StoreID != null;
        gridCheckOutItem.Visible = checkout.StoreID != null;
        StoreID.Enabled = (checkout.StoreCheckOutItems.Count == 0 && !CheckOutItem_Panel.Visible);
        panelDestinationUser.Visible = DestinationType.SelectedIndex == 1;
        panelDestinationWork.Visible = DestinationType.SelectedIndex == 2;
        CheckOut_ConversionText.Visible = (CheckOut_ConversionText.Text != "");

        foreach (GridViewRow row in gridCheckOutItem.Grid.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                UIFieldLabel labelValid = (UIFieldLabel)row.FindControl("labelValid");
                Image imageError = (Image)row.FindControl("imageError");

                if (labelValid != null && imageError != null)
                    imageError.Visible = labelValid.Text.ToString() == "false";
            }
        }

        panelDetails.Enabled = 
            objectBase.CurrentObjectState != "Committed" &&
            objectBase.CurrentObjectState != "PendingApproval";
        tabDetails.Enabled = objectBase.CurrentObjectState != "Cancelled";
    }


    /// <summary>
    /// Occurs when the user selects a different value from
    /// the destination type dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DestinationType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects a different store from 
    /// the dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects a different node in the
    /// catalog treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckOut_CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        // Bind to object.
        //
        OStoreCheckOut checkout = (OStoreCheckOut)this.panel.SessionObject;

        OStoreCheckOutItem item = (OStoreCheckOutItem)this.CheckOutItem_SubPanel.SessionObject;
        CheckOutItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        // Update dropdown lists.
        //
        CheckOut_StoreBinID.Items.Clear();
        CheckOut_ActualUnitOfMeasureID.Items.Clear();

        if (checkout.StoreID != null && item.CatalogueID != null)
        {
            CheckOut_StoreBinID.Bind(
                OStore.FindBinsByCatalogue(checkout.StoreID, item.CatalogueID, true, null),
                "ObjectName", "ObjectID", true);
            CheckOut_ActualUnitOfMeasureID.Bind(
                OUnitConversion.GetConversions(item.Catalogue.UnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }
        
        
        CheckOutItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Occurs when the user selects a different 
    /// check-out unit of measure.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckOut_ActualUnitOfMeasureID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreCheckOutItem item = (OStoreCheckOutItem)this.CheckOutItem_SubPanel.SessionObject;
        CheckOutItem_SubPanel.ObjectPanel.BindControlsToObject(item);
        CheckOutItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Occurs when the user clicks on the "Add Consumables/Non-Consumables" button.
    /// Pops up the additems.aspx page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddItems_Click(object sender, EventArgs e)
    {
        OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
        panel.ObjectPanel.BindControlsToObject(storeCheckOut);
        panel.FocusWindow = false;
        Window.Open("additems.aspx", "AnacleEAM_Popup");
    }


    /// <summary>
    /// Occurs when the user confirms the items to add in the pop-up page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
        panel.ObjectPanel.BindControlsToObject(storeCheckOut);
        panel.ObjectPanel.BindObjectToControls(storeCheckOut);
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
        <ui:UIObjectPanel runat="serveR" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Check Out" BaseTable="tStoreCheckOut"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Check Out" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameVisible="false" ObjectNumberEnabled="false"
                            ObjectNumberCaption="Check-Out Number" meta:resourcekey="objectBase1"></web:base>
                        <ui:UIPanel runat="server" ID="panelDetails" BorderStyle="NotSet" 
                            meta:resourcekey="panelDetailsResource1">
                            <ui:UIFieldDropDownList runat="server" ID="StoreID" PropertyName="StoreID" Caption="Store"
                                OnSelectedIndexChanged="StoreID_SelectedIndexChanged" meta:resourcekey="StoreIDResource1"
                                ValidateRequiredField="True" />
                            <ui:UIFieldTextBox runat="server" ID="Description" PropertyName="Description" Caption="Remarks"
                                ToolTip="Remarks for the check in." TextMode="MultiLine" 
                                meta:resourcekey="DescriptionResource1" InternalControlWidth="95%"></ui:UIFieldTextBox>
                            <ui:UIFieldRadioList runat="server" ID="DestinationType" ValidateRequiredField="True"
                                RepeatColumns="0" PropertyName="DestinationType" Caption="Check-Out To" OnSelectedIndexChanged="DestinationType_SelectedIndexChanged"
                                meta:resourcekey="DestinationTypeResource1" TextAlign="Right">
                                <Items>
                                    <asp:listitem value="0" selected="True" meta:resourcekey="ListItemResource1">None</asp:listitem>
                                    <asp:listitem value="1" meta:resourcekey="ListItemResource2">User</asp:listitem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="panelDestinationUser" 
                                meta:resourcekey="panelDestinationUserResource1" BorderStyle="NotSet">
                                <ui:UIFieldDropDownList runat="server" ID="UserID" PropertyName="UserID" Caption="User"
                                    ValidateRequiredField="True" meta:resourcekey="UserIDResource1">
                                </ui:UIFieldDropDownList>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panelDestinationWork" 
                                meta:resourcekey="panelDestinationWorkResource1" BorderStyle="NotSet">
                                <ui:UIFieldDropDownList runat="server" ID="WorkID" PropertyName="WorkID" Caption="Work"
                                    ValidateRequiredField="True" ToolTip="Work order number that this check out is for."
                                    meta:resourcekey="WorkIDResource1">
                                </ui:UIFieldDropDownList>
                            </ui:UIPanel>
                            <br />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIButton runat="server" ID="buttonAddItems" 
                                Text="Add Consumables/Non-Consumables" ImageUrl="~/images/add.gif" 
                                CausesValidation="False" OnClick="buttonAddItems_Click" 
                                meta:resourcekey="buttonAddItemsResource1" />
                            <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False" 
                                OnClick="buttonItemsAdded_Click" meta:resourcekey="buttonItemsAddedResource1" />
                            <br />
                            <br />
                            <ui:UIGridView runat="server" ID="gridCheckOutItem" PropertyName="StoreCheckOutItems"
                                Caption="Check Out Items" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="gridCheckOutItemResource1"
                                Width="100%" ValidateRequiredField="True" ShowFooter="True" 
                                PageSize="1000" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                                RowErrorColor="" style="clear:both;">
                                <PagerSettings Mode="NumericFirstLast" />
                                <commands>
                                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                        CommandName="DeleteObject" CommandText="Delete" 
                                        ConfirmText="Are you sure you wish to delete the selected items?" 
                                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                        CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                        meta:resourceKey="UIGridViewCommandResource2" />
                                </commands>
                                <Columns>
                                    <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" 
                                        CommandName="EditObject" ImageUrl="~/images/edit.gif" 
                                        meta:resourceKey="UIGridViewColumnResource1">
                                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewButtonColumn>
                                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
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
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" 
                                        HeaderText="Base Unit" meta:resourceKey="UIGridViewColumnResource5" 
                                        PropertyName="Catalogue.UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                        SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ActualQuantity" 
                                        HeaderText="Check-Out Quantity" meta:resourceKey="UIGridViewColumnResource6" 
                                        PropertyName="ActualQuantity" ResourceAssemblyName="" 
                                        SortExpression="ActualQuantity">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ActualUnitOfMeasure.ObjectName" 
                                        HeaderText="Check-Out Unit" meta:resourceKey="UIGridViewColumnResource7" 
                                        PropertyName="ActualUnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                        SortExpression="ActualUnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="BaseQuantity" HeaderText="Base Quantity" 
                                        meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="BaseQuantity" 
                                        ResourceAssemblyName="" SortExpression="BaseQuantity">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" 
                                        HeaderText="Base Unit" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                        PropertyName="Catalogue.UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                        SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="EstimatedUnitCost" 
                                        HeaderText="Unit Cost (Estimated)" 
                                        meta:resourcekey="UIGridViewBoundColumnResource4" 
                                        PropertyName="EstimatedUnitCost" ResourceAssemblyName="" 
                                        SortExpression="EstimatedUnitCost">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="SubTotal" FooterAggregate="Sum" 
                                        HeaderText="Sub Total" meta:resourcekey="UIGridViewBoundColumnResource5" 
                                        PropertyName="SubTotal" ResourceAssemblyName="" SortExpression="SubTotal">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="CheckOutItem_Panel" 
                                meta:resourcekey="CheckOutItem_PanelResource1" BorderStyle="NotSet">
                                <web:subpanel runat="server" ID="CheckOutItem_SubPanel" GridViewID="gridCheckOutItem"
                                    MultiSelectColumnNames="CatalogueID,StoreBinID,ActualQuantity,ActualUnitOfMeasureID"
                                    OnPopulateForm="CheckOutItem_SubPanel_PopulateForm" OnValidateAndUpdate="CheckOutItem_SubPanel_ValidateAndUpdate" />
                                <ui:UIFieldTreeList runat="server" ID="CheckOut_CatalogueID" PropertyName="CatalogueID"
                                    Caption="Catalog Item" ValidateRequiredField="True" OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater"
                                    ToolTip="Catalog item to check-out" OnSelectedNodeChanged="CheckOut_CatalogueID_SelectedNodeChanged"
                                    meta:resourcekey="CheckOut_CatalogueIDResource1" ShowCheckBoxes="None" 
                                    TreeValueMode="SelectedNode" />
                                <ui:UIFieldDropDownList runat="server" ID="CheckOut_StoreBinID" PropertyName="StoreBinID"
                                    ValidateRequiredField="True" Caption="Bin (Avail Qty)" Span="Half" ToolTip="The bin where this item is checked out from."
                                    meta:resourcekey="CheckOut_StoreBinIDResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldLabel runat="server" ID="CheckOut_BaseUnitOfMeasure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                    Caption="Base Unit" meta:resourcekey="CheckOut_BaseUnitOfMeasureResource1" 
                                    DataFormatString="" />
                                <ui:UIFieldTextBox runat="server" ID="CheckOut_ActualQuantity" PropertyName="ActualQuantity"
                                    ValidateRangeField="True" ValidationRangeType='Currency' 
                                    ValidationRangeMin="0"  ValidationRangeMinInclusive="False" 
                                    Span="Half" ValidateRequiredField="True" ValidationDataType="Double" Caption="Check-Out Quantity"
                                    ToolTip="Check-out quantity." 
                                    meta:resourcekey="CheckOut_ActualQuantityResource1" 
                                    InternalControlWidth="95%" />
                                <ui:UIFieldDropDownList runat="server" ID="CheckOut_ActualUnitOfMeasureID" PropertyName="ActualUnitOfMeasureID"
                                    ValidateRequiredField="True" Caption="Check-Out Unit" Span="Half" OnSelectedIndexChanged="CheckOut_ActualUnitOfMeasureID_SelectedIndexChanged"
                                    meta:resourcekey="CheckOut_ActualUnitOfMeasureIDResource1">
                                </ui:UIFieldDropDownList>
                                <br />
                                <ui:UIFieldLabel runat="server" ID="CheckOut_ConversionText" PropertyName="ConversionText"
                                    Caption="Conversion Example" 
                                    meta:resourcekey="CheckOut_ConversionTextResource1" DataFormatString="" />
                            </ui:UIObjectPanel>
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />
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
