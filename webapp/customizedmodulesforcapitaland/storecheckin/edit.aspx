<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OStoreCheckIn checkin = panel.SessionObject as OStoreCheckIn;
        objectBase.ObjectNumber.Visible = !checkin.IsNew;

        if (Request["StoreID"] != null)
            checkin.StoreID = new Guid(Security.Decrypt(Request["StoreID"].ToString()));

        if (!IsPostBack)
        {
            ((UIGridViewBoundColumn)gridCheckInItem.Columns[6]).DataFormatString = OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
            ((UIGridViewBoundColumn)gridCheckInItem.Columns[9]).DataFormatString = OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
            CheckIn_UnitPrice.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
        
        /// For populating fields to create new catalog
        //ParentID.PopulateTree();
        //UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        //radioInventoryCatalogType.Items.Clear();
        //radioInventoryCatalogType.Items.Add(new ListItem(Resources.Strings.InventoryCatalogType_Consumables, "0"));
        //radioInventoryCatalogType.Items.Add(new ListItem(Resources.Strings.InventoryCatalogType_NonConsumables, "1"));
        
        List<OStore> list = OStore.FindAccessibleStoresActiveForCheckIn(AppSession.User, Security.Decrypt(Request["TYPE"]), checkin.StoreID, true, false);
        StoreID.Bind(list);
        if (checkin.StoreID != null)
            StoreCheckOutID.Bind(OStoreCheckIn.GetStoreCheckOut(checkin.StoreID.Value), "ObjectNumberAndDescription", "ObjectID");
        panel.ObjectPanel.BindObjectToControls(checkin);
    }

    /// <summary>
    /// Validates and saves the object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OStoreCheckIn storeCheckIn = panel.SessionObject as OStoreCheckIn;
            panel.ObjectPanel.BindControlsToObject(storeCheckIn);
            
            // Validates to ensure that the none of the store bins
            // are locked before we try to check in.
            //
            if (objectBase.SelectedAction == "Commit" ||
                objectBase.SelectedAction == "SubmitForApproval" ||
                objectBase.SelectedAction == "Approve")
            {
                string lockedBins = storeCheckIn.ValidateBinsNotLocked();
                if (lockedBins != "")
                    gridCheckInItem.ErrorMessage = String.Format(Resources.Errors.StoreCheckIn_StoreBinsLocked, lockedBins);
            }
            
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            storeCheckIn.Save();
            c.Commit();
        }
    }



    /// <summary>
    /// Hides/shows and enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OStoreCheckIn checkin = (OStoreCheckIn)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(checkin);

        buttonAddItems.Visible = checkin.StoreID != null;
        buttonAddEquipment.Visible = checkin.StoreID != null;
        gridCheckInItem.Visible = checkin.StoreID != null;
        StoreID.Enabled = (checkin.CheckInItems.Count == 0 && !CheckInItem_Panel.Visible);

        panelDetails.Enabled =
            objectBase.CurrentObjectState != "Committed" &&
            objectBase.CurrentObjectState != "PendingApproval";
        tabDetails.Enabled = objectBase.CurrentObjectState != "Cancelled";

        /*
        OStoreCheckInItem storeCheckInItem = CheckInItem_SubPanel.SessionObject as OStoreCheckInItem;
        CheckInItem_SubPanel.ObjectPanel.BindControlsToObject(storeCheckInItem);
        //panelInventory.Visible = false;
        */
        buttonViewStoreCheckout.Enabled = true;

        //if (radioInventoryCatalogType.SelectedIndex == 0)
        //    IsRemovedAfterExpended.Visible = true;
        //else
        //    IsRemovedAfterExpended.Visible = false;

        //if (CreateNewCatalog.Checked)
        //{
        //    CheckIn_CatalogueID.Visible = false;
        //    Panel_NewCatalog.Visible = true;
        //}
        //else
        //{
        //    CheckIn_CatalogueID.Visible = true;
        //    Panel_NewCatalog.Visible = false;
        //}
    }

    
    /// <summary>
    /// Populates the check-in item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckInItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OStoreCheckIn checkin = panel.SessionObject as OStoreCheckIn;
        panel.ObjectPanel.BindControlsToObject(checkin);

        OStoreCheckInItem storeCheckInItem = CheckInItem_SubPanel.SessionObject as OStoreCheckInItem;
        CheckIn_CatalogueID.PopulateTree();
        if (checkin.Store != null)
            CheckIn_StoreBinID.Bind(checkin.Store.StoreBins);

        //if (storeCheckInItem.CatalogueID != null)
        //    resetInventoryCatalogFields();

        //OCatalogueTemp ct = TablesLogic.tCatalogueTemp.Load(
        //    TablesLogic.tCatalogueTemp.AttachedObjectID == storeCheckInItem.ObjectID);
        //if(ct != null)
        //{
        //    CatalogName.Text = ct.ObjectName;
        //    ParentID.SelectedValue = ct.ParentID.ToString();
        //    IsSharedAcrossAllStores.Checked = ct.IsSharedAcrossAllStores == 1 ? true : false;
        //    IsRemovedAfterExpended.Checked = ct.IsRemovedAfterExpended == 1 ? true : false;
        //    UnitOfMeasureID.SelectedValue = ct.UnitOfMeasureID.ToString();
        //    radioInventoryCatalogType.SelectedIndex = ct.InventoryCatalogType.Value;
        //}
        
        
        CheckInItem_SubPanel.ObjectPanel.BindObjectToControls(storeCheckInItem);
    }
    
    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CheckIn_CatalogueID_AcquireTreePopulater(object sender)
    {
        OStoreCheckInItem storeCheckInItem = CheckInItem_SubPanel.SessionObject as OStoreCheckInItem;
        List<OStore> s = new List<OStore>();
        s.Add(TablesLogic.tStore.Load(new Guid(StoreID.SelectedValue)));
        return new CatalogueTreePopulater(storeCheckInItem.CatalogueID, true, true, true, true,s);
    }
    
    /// <summary>
    /// Occurs when the user selects an item in the store dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {
        if(StoreID.SelectedValue != null && StoreID.SelectedValue != string.Empty)
            StoreCheckOutID.Bind(OStoreCheckIn.GetStoreCheckOut((new Guid(this.StoreID.SelectedValue))), "ObjectNumberAndDescription", "ObjectID");
    }

    /// <summary>
    /// Reset the fields after creating inventory catalog
    /// </summary>
    //private void resetInventoryCatalogFields()
    //{
    //    CreateNewCatalog.Checked = false;
    //    CatalogName.Text = "";
    //    ParentID.SelectedValue = "";
    //    UnitOfMeasureID.SelectedValue = "";
    //    radioInventoryCatalogType.SelectedIndex = -1;
    //    IsSharedAcrossAllStores.Checked = false;
    //    IsRemovedAfterExpended.Checked = false;
    //}
    
    /// <summary>
    /// Validates and adds the check-in item into the store check-in
    /// object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckInItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        
        // Bind controls to objects
        //
        OStoreCheckIn storeCheckIn = panel.SessionObject as OStoreCheckIn;
        panel.ObjectPanel.BindControlsToObject(storeCheckIn);

        OStoreCheckInItem storeCheckInItem = CheckInItem_SubPanel.SessionObject as OStoreCheckInItem;
        CheckInItem_SubPanel.ObjectPanel.BindControlsToObject(storeCheckInItem);

        //// Creates a new Inventory Catalog Item Object and bind to the StoreCheckIn Object
        //if (CreateNewCatalog.Checked)
        //{
        //    OCatalogueTemp cat = TablesLogic.tCatalogueTemp.Create();
        //    cat.ObjectName = CatalogName.Text;
        //    cat.ParentID = new Guid(ParentID.SelectedValue);
        //    cat.UnitOfMeasureID = new Guid(UnitOfMeasureID.SelectedValue);
        //    cat.InventoryCatalogType = radioInventoryCatalogType.SelectedIndex;
        //    cat.IsSharedAcrossAllStores = IsSharedAcrossAllStores.Checked ? 1 : 0;
        //    cat.IsRemovedAfterExpended = IsRemovedAfterExpended.Checked ? 1 : 0;
        //    cat.AttachedObjectID = storeCheckInItem.ObjectID;
        //    storeCheckInItem.CatalogueTempID = cat.ObjectID;
        //    using (Connection c = new Connection())
        //    {
        //        cat.Save();
        //        c.Commit();
        //    }
            
        //    //resetInventoryCatalogFields();
        //}
        
        // Validates quantity if its a Whole Number according to Catalog Type
        if (CheckIn_CatalogueID.SelectedValue != "")
        {
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(CheckIn_CatalogueID.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(CheckIn_Quantity.Text) != 0)
            {
                CheckIn_Quantity.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }
        }
        
        // Add
        //
        storeCheckIn.CheckInItems.Add(storeCheckInItem);
        panel.ObjectPanel.BindObjectToControls(storeCheckIn);

        // Additional processing.
        //
        CheckIn_CatalogueID.SelectedValue = "";
        this.CheckIn_StoreBinID.SelectedIndex = 0;
        this.CheckIn_UnitPrice.Text = "";
        this.CheckIn_Quantity.Text = "";
    }

    
    /// <summary>
    /// Occurs when the user clicks on the Add Consumables/Non-Consumables button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddItems_Click(object sender, EventArgs e)
    {
        OStoreCheckIn storeCheckIn = panel.SessionObject as OStoreCheckIn;
        panel.ObjectPanel.BindControlsToObject(storeCheckIn);
        panel.FocusWindow = false;
        Window.Open("additems.aspx", "AnacleEAM_Popup");
    }


    /// <summary>
    /// Occurs when the user clicks on the Add Equipment button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddEquipment_Click(object sender, EventArgs e)
    {
        OStoreCheckIn storeCheckIn = panel.SessionObject as OStoreCheckIn;
        panel.ObjectPanel.BindControlsToObject(storeCheckIn);
        panel.FocusWindow = false;
        Window.Open("addeqpt.aspx", "AnacleEAM_Popup");
    }


    /// <summary>
    /// Occurs when the user confirms the adding of items in
    /// the pop-up window.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void  buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OStoreCheckIn storeCheckIn = panel.SessionObject as OStoreCheckIn;
        panel.ObjectPanel.BindControlsToObject(storeCheckIn);
        panel.ObjectPanel.BindObjectToControls(storeCheckIn);
    }
    
    /// <summary>
    /// Occurs when user clicks view Store Checkout
    /// </summary>
    protected void buttonViewStoreCheckout_Click(object sender, EventArgs e)
    {

        if (StoreCheckOutID.SelectedValue != "")
            Window.OpenEditObjectPage(this, "OStoreCheckOut", StoreCheckOutID.SelectedValue, "");
    }

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void gridCheckInItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[9].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
                e.Row.Cells[8].Text = Convert.ToDecimal(e.Row.Cells[8].Text).ToString("#,##0");
            if (e.Row.Cells[2].Text == "")
            {
                //UIGridViewBoundColumn a = e.Row.FindControl("ObjectName");
            }
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

    /// <summary>
    /// Occurs when the user selects an item in the Belongs Under tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        OCatalogue catalog = panel.SessionObject as OCatalogue;
        List<OStore> s = OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null);

        return new CatalogueTreePopulater(panel.SessionObject.ParentID, false, false, true, false, s);
    }

    protected void radioInventoryCatalogType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void CreateNewCatalog_CheckedChanged(object sender, EventArgs e)
    {

    }

    protected void IsSharedAcrossAllStores_CheckedChanged(object sender, EventArgs e)
    {
    
    }

    protected void buttonAddCatalog_Click(object sender, EventArgs e)
    {
        OFunction function = OFunction.GetFunctionByObjectType("OCatalogue");
        Window.Open(
            Page.ResolveUrl(function.EditUrl) + "?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("NEW:")) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt("OCatalogue")) +
            "&CheckIn=1" +
            "&" + "ButtonID=" + this.repopulateCatalogueButton.ClientID + "&N=1", "AnacleEAM_Window_AddCatalog");   
    }

    protected void repopulateCatalogue_Click(object sender, EventArgs e)
    {
        OStoreCheckInItem checkInItem = this.CheckInItem_SubPanel.SessionObject as OStoreCheckInItem;
        checkInItem.CatalogueID = (Guid)Session["NewCatalogID"];
        CheckIn_CatalogueID.PopulateTree();
        CheckIn_CatalogueID.SelectedValue = Session["NewCatalogID"].ToString();
        Session["NewCatalogID"] = null;
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
    
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Check In" BaseTable="tStoreCheckIn"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <span style="display:none"><ui:UIButton runat="server" ID="repopulateCatalogueButton" OnClick="repopulateCatalogue_Click"
            CausesValidation="false"/></span>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Check In" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameVisible="false" ObjectNumberEnabled="false"
                            ObjectNumberCaption="Check-In Number" meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIPanel runat="server" ID="panelDetails" BorderStyle="NotSet" 
                            meta:resourcekey="panelDetailsResource1">
                            <ui:UIFieldDropDownList runat="server" ID="StoreID" PropertyName="StoreID" Caption="Store"
                                OnSelectedIndexChanged="StoreID_SelectedIndexChanged" meta:resourcekey="StoreIDResource1"
                                ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldSearchableDropDownList runat="server" ID="StoreCheckOutID" PropertyName="StoreCheckOutID"
                            Caption="Store Check Out" meta:resourcekey="StoreCheckOutIDResource1" 
                                SearchInterval="300">
                            <contextmenubuttons>
                                <ui:uibutton id="buttonViewStoreCheckout" runat="server" alwaysenabled="True" causesvalidation="False" confirmtext="Please remember to save this Store Check In\n\nAre you sure you want to continue?" imageurl="~/images/view.gif" meta:resourcekey="uttonViewStoreCheckoutResource1" onclick="buttonViewStoreCheckout_Click" text="View Store Checkout" />
                            </contextmenubuttons>
                            </ui:UIFieldSearchableDropDownList>
                            <ui:UIFieldTextBox TextMode="MultiLine" runat="server" ID="Description" PropertyName="Description" Caption="Remarks"
                                meta:resourcekey="DescriptionResource1" InternalControlWidth="95%"></ui:UIFieldTextBox>
                            <br />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIButton runat="server" ID="buttonAddItems" OnClick="buttonAddItems_Click" 
                                Text="Add Multiple Items" ImageUrl="~/images/add.gif" 
                                CausesValidation="False" />
                            <ui:UIButton runat="server" ID="buttonAddEquipment" 
                                OnClick="buttonAddEquipment_Click" Text="Add Equipment" 
                                ImageUrl="~/images/add.gif" CausesValidation="False" 
                                meta:resourcekey="buttonAddEquipmentResource1" />
                            <ui:UIButton runat="server" ID="buttonItemsAdded" 
                                OnClick="buttonItemsAdded_Click"  CausesValidation="False" 
                                meta:resourcekey="buttonItemsAddedResource1" />
                            <br />
                            <br />
                            <ui:UIGridView runat="server" ID="gridCheckInItem" PropertyName="CheckInItems" Caption="Check In Items"
                                KeyName="ObjectID" meta:resourcekey="gridCheckInItemResource1" 
                                Width="100%" ValidateRequiredField="True" PageSize="1000" ShowFooter='True' 
                                DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                                style="clear:both;" OnRowDataBound="gridCheckInItem_RowDataBound">
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
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.InventoryCatalogTypeText" 
                                        HeaderText="Type" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                        PropertyName="Catalogue.InventoryCatalogTypeText" ResourceAssemblyName="" 
                                        SortExpression="Catalogue.InventoryCatalogTypeText">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.ObjectName" 
                                        HeaderText="Check in item" meta:resourceKey="UIGridViewColumnResource3" 
                                        PropertyName="Catalogue.ObjectName" ResourceAssemblyName="" 
                                        SortExpression="Catalogue.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.StockCode" 
                                        HeaderText="Stock Code" meta:resourcekey="UIGridViewBoundColumnResource2" 
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
                                    <cc1:UIGridViewBoundColumn DataField="UnitPrice" 
                                        DataFormatString="{0:#,##0.00}" HeaderText="Unit Price" 
                                        meta:resourceKey="UIGridViewColumnResource5" PropertyName="UnitPrice" 
                                        ResourceAssemblyName="" SortExpression="UnitPrice">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Quantity" HeaderText="Quantity" 
                                        meta:resourceKey="UIGridViewColumnResource6" PropertyName="Quantity" 
                                        ResourceAssemblyName="" SortExpression="Quantity">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" 
                                        HeaderText="Unit of Measure" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                        PropertyName="Catalogue.UnitOfMeasure.ObjectName" ResourceAssemblyName=""  
                                        SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="SubTotal" DataFormatString="{0:#,##0.00}" 
                                        FooterAggregate="Sum" HeaderText="SubTotal" 
                                        meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="SubTotal" 
                                        ResourceAssemblyName="" SortExpression="SubTotal">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="CheckInItem_Panel" 
                                meta:resourcekey="CheckInItem_PanelResource1" BorderStyle="NotSet">
                                <web:subpanel runat="server" ID="CheckInItem_SubPanel" GridViewID="gridCheckInItem"
                                    OnPopulateForm="CheckInItem_SubPanel_PopulateForm"
                                    MultiSelectGridID="CheckIn_MultiCatalogueID" MultiSelectColumnNames="CatalogueID,StoreBinID,UnitPrice,Quantity,ExpiryDate,LotNumber"
                                    OnValidateAndUpdate="CheckInItem_SubPanel_ValidateAndUpdate" />
                                <ui:UIPanel runat="server" ID="panelCatalogDetail" BorderStyle="NotSet" 
                                    meta:resourcekey="panelCatalogDetailResource1">
                            <ui:uibutton id="buttonAddCatalog" runat="server" alwaysenabled="True" causesvalidation="False"
                            imageurl="~/images/add.gif" meta:resourcekey="buttonAddCatalogResource1" 
                            onclick="buttonAddCatalog_Click" Text="Add New Catalog"/>
                                    <ui:UIFieldTreeList runat="server" ID="CheckIn_CatalogueID" PropertyName="CatalogueID"
                                        Caption="Catalog Item" ValidateRequiredField="True" OnAcquireTreePopulater="CheckIn_CatalogueID_AcquireTreePopulater"
                                        ToolTip="Catalog item to check in" 
                                        meta:resourcekey="CheckIn_CatalogueIDResource1" ShowCheckBoxes="None" 
                                        TreeValueMode="SelectedNode" />
                                        <ui:UIFieldDropDownList runat="server" ID="CheckIn_StoreBinID" PropertyName="StoreBinID"
                                        ValidateRequiredField="True" Caption="Bin" Span="Half" ToolTip="The bin where this item is checked in to."
                                        meta:resourcekey="CheckIn_StoreBinIDResource1">
                                    </ui:UIFieldDropDownList>
                                    <ui:UIFieldTextBox runat="server" ID="CheckIn_UnitPrice" PropertyName="UnitPrice"
                                        Span="Half" ValidateRequiredField="True" ValidationDataType="Currency" Caption="Unit Price"
                                        ValidateRangeField="True" ValidationRangeMin="0" 
                                        ValidationRangeType="Currency" 
                                        meta:resourcekey="CheckIn_UnitPriceResource1" InternalControlWidth="95%" />
                                    <ui:UIFieldTextBox runat="server" ID="CheckIn_Quantity" PropertyName="Quantity" Span="Half"
                                        ValidateRangeField="True" ValidationRangeType='Currency' 
                                        ValidationRangeMin="0" ValidationRangeMinInclusive="False"
                                        ValidateRequiredField="True" ValidationDataType="Currency" Caption="Quantity"
                                        ToolTip="Quantity to check-in." 
                                        meta:resourcekey="CheckIn_QuantityResource1" InternalControlWidth="95%" />
                                    <ui:uifieldlabel runat="server" id="labelUnitOfMeasure" 
                                        PropertyName="Catalogue.UnitOfMeasure.ObjectName" Caption="Unit of Measure" 
                                        DataFormatString="" meta:resourcekey="labelUnitOfMeasureResource1"></ui:uifieldlabel>
                                    <ui:UIPanel runat="server" ID="panelInventory" BorderStyle="NotSet" 
                                        meta:resourcekey="panelInventoryResource1">
                                        <ui:UIFieldDateTime runat="server" ID="CheckIn_ExpiryDate" PropertyName="ExpiryDate"
                                            Caption="Expiry Date" Span="Half" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                                            meta:resourcekey="CheckIn_ExpiryDateResource1" ShowDateControls="True" />
                                        <ui:UIFieldTextBox runat="server" ID="CheckIn_LotNumber" PropertyName="LotNumber"
                                            Caption="Lot Number" Span="Half" ToolTip="Lot number of this batch as specified by the manufacturer"
                                            meta:resourcekey="CheckIn_LotNumberResource1" InternalControlWidth="95%" />
                                    </ui:UIPanel>
                                </ui:UIPanel>
                            </ui:UIObjectPanel>
                            <div style="height:400px"></div>
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
