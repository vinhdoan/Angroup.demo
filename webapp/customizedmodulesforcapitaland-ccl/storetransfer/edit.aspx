<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;

        objectBase.ObjectNumberVisible = !storeTransfer.IsNew;

        treeFromLocation.PopulateTree();
        treeToLocation.PopulateTree();

        if (storeTransfer.FromStoreType == StoreType.Storeroom)
        {
            //List<OStore> list = OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), storeTransfer.FromStoreID, true, false);
            List<OStore> list = new List<OStore>();
            list.Add(OApplicationSetting.Current.FromStore);
            FromStoreID.Bind(list, "ObjectName", "ObjectID", false);
        }
        else
        {
            //FromStoreID.Bind(OStore.GetIssueLocationAsList(storeTransfer.FromLocationID, storeTransfer.FromStoreID), false);
            List<OStore> list = new List<OStore>();
            list.Add(OApplicationSetting.Current.FromStore);
            FromStoreID.Bind(list, "ObjectName", "ObjectID", false);
        }

        if (storeTransfer.ToStoreType == StoreType.Storeroom)
            ToStoreID.Bind(OStore.GetAllPhysicalStoreroomsActiveForCheckIns(storeTransfer.ToStoreID));
        else
            ToStoreID.Bind(OStore.GetIssueLocationAsList(storeTransfer.ToLocationID, storeTransfer.ToStoreID), false);

        if (!IsPostBack)
        {
            ((UIGridViewBoundColumn)gridTransferItem.Columns[9]).DataFormatString = OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
            ((UIGridViewBoundColumn)gridTransferItem.Columns[10]).DataFormatString = OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
        }

        panel.ObjectPanel.BindObjectToControls(storeTransfer);
    }

    /// <summary>
    /// Binds the from/to store dropdown lists.
    /// </summary>
    /// <param name="storeTransfer"></param>
    protected void BindFromStoreDropDownLists(OStoreTransfer storeTransfer)
    {
        if (storeTransfer.FromStoreType == StoreType.Storeroom)
        {
            //FromStoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null, true, false));
            List<OStore> list = new List<OStore>();
            list.Add(OApplicationSetting.Current.FromStore);
            FromStoreID.Bind(list, "ObjectName", "ObjectID", false);
        }
        else
        {
            //FromStoreID.Bind(OStore.GetIssueLocationAsList(storeTransfer.FromLocationID, null), false);
            List<OStore> list = new List<OStore>();
            list.Add(OApplicationSetting.Current.FromStore);
            FromStoreID.Bind(list, "ObjectName", "ObjectID", false);
        }
    }

    /// <summary>
    /// Binds the from/to store dropdown lists.
    /// </summary>
    /// <param name="storeTransfer"></param>
    protected void BindToStoreDropDownLists(OStoreTransfer storeTransfer)
    {
        if (storeTransfer.ToStoreType == StoreType.Storeroom)
            //ToStoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null, true, false));
            // 2011.02.16
            // Kim Foong
            // Should populate active stores only.
            //ToStoreID.Bind(OStore.GetAllPhysicalStorerooms());
            ToStoreID.Bind(OStore.GetAllPhysicalStoreroomsActiveForCheckIns());
        else
            ToStoreID.Bind(OStore.GetIssueLocationAsList(storeTransfer.ToLocationID, null), false);
    }

    /// <summary>
    /// Populates the store transfer item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TransferItem_SubPanel_Populate(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;

        OStoreTransferItem storeTransferItem = TransferItem_SubPanel.SessionObject as OStoreTransferItem;
        TransferItem_CatalogueID.PopulateTree();

        if (storeTransferItem.CatalogueID != null)
        {
            TransferItem_FromStoreBinID.Bind(
                OStore.FindBinsByCatalogue((Guid)storeTransfer.FromStoreID,
                storeTransferItem.CatalogueID, false,
                storeTransferItem.FromStoreBinID), "ObjectName", "ObjectID", true);
            TransferItem_ToStoreBinID.Bind(
                OStore.FindBinsByCatalogue((Guid)storeTransfer.ToStoreID,
                storeTransferItem.CatalogueID, true,
                storeTransferItem.ToStoreBinID), "ObjectName", "ObjectID", true);

            // Ensure that the equipment dropdown list is compulsory if the
            // user selected a equipment catalog type.
            //
            if (storeTransferItem.Catalogue != null)
            {
                if (storeTransferItem.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment)
                {
                    dropStoreBinItem.Visible = true;
                    dropStoreBinItem.ValidateRequiredField = true;
                }
                else
                {
                    dropStoreBinItem.Visible = false;
                    dropStoreBinItem.ValidateRequiredField = false;
                }
            }
        }
        else
        {
            TransferItem_FromStoreBinID.Items.Clear();
            TransferItem_ToStoreBinID.Items.Clear();
        }
        BindStoreBinItemDropDownList();

        TransferItem_SubPanel.ObjectPanel.BindObjectToControls(storeTransferItem);
    }

    /// <summary>
    /// Validates and inserts the store transfer item object
    /// into the store transfer object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TransferItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OStoreTransfer transfer = (OStoreTransfer)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(transfer);

        OStoreTransferItem item = (OStoreTransferItem)TransferItem_SubPanel.SessionObject;
        TransferItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        // Validate
        //
        if (item.FromStoreBinID == item.ToStoreBinID)
        {
            TransferItem_FromStoreBinID.ErrorMessage = Resources.Errors.Transfer_FromBinSameAsToBin;
            TransferItem_ToStoreBinID.ErrorMessage = Resources.Errors.Transfer_FromBinSameAsToBin;
        }
        if (transfer.HasDuplicateTransferItem(item))
        {
            TransferItem_CatalogueID.ErrorMessage = Resources.Errors.Transfer_DuplicateItem;
            TransferItem_FromStoreBinID.ErrorMessage = Resources.Errors.Transfer_DuplicateItem;
            if (item.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment)
                dropStoreBinItem.ErrorMessage = Resources.Errors.Transfer_DuplicateItem;
        }

        // Validates quantity if its a Whole Number according to Catalog Type
        if (TransferItem_CatalogueID.SelectedValue != "")
        {
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(TransferItem_CatalogueID.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(TransferItem_QuantityToTransfer.Text) != 0)
            {
                TransferItem_QuantityToTransfer.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }
        }

        if (!TransferItem_SubPanel.ObjectPanel.IsValid)
            return;

        // 2010.06.03
        // Kim Foong
        // If the user clicks the Update button to select between different
        // store transfer items, when the store transfer is in an approved
        // state, it will crash. This fixes that.
        //
        if (objectBase.CurrentObjectState.Is("Start", "Draft", "PendingApproval"))
        {
            if (item.Catalogue.IsGeneratedFromEquipmentType == 0)
            {
                item.Quantity = item.QuantityToTransfer;
            }
            else if (item.Catalogue.IsGeneratedFromEquipmentType == 1)
            {
                item.Quantity = 1;
                item.QuantityToTransfer = 1;
            }

            // Compute the estimated unit cost of items
            // to be transferred.
            //
            item.ComputeEstimatedUnitCost();
        }

        // Insert
        //
        transfer.StoreTransferItems.Add(item);
        panel.ObjectPanel.BindObjectToControls(transfer);
    }

    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater TransferItemID_AcquireTreePopulater(object sender)
    {
        OStoreTransferItem storeTransferItem = TransferItem_SubPanel.SessionObject as OStoreTransferItem;
        List<OStore> s = new List<OStore>();
        s.Add(TablesLogic.tStore.Load(new Guid(FromStoreID.SelectedValue)));
        return new CatalogueTreePopulater(storeTransferItem.CatalogueID, true, true, true, true, s);
    }

    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        this.buttonAddItems.Visible = this.FromStoreID.SelectedValue != "" && this.ToStoreID.SelectedValue != "";
        this.buttonAddEquipment.Visible = this.FromStoreID.SelectedValue != "" && this.ToStoreID.SelectedValue != "";
        this.gridTransferItem.Visible = this.FromStoreID.SelectedValue != "" && this.ToStoreID.SelectedValue != "";

        panelStore.Enabled = (this.gridTransferItem.Rows.Count == 0 && !this.TransferItem_Panel.Visible);
        FromStoreID.Visible = radioFromStoreType.SelectedValue == StoreType.Storeroom.ToString();
        ToStoreID.Visible = radioToStoreType.SelectedValue == StoreType.Storeroom.ToString();
        treeFromLocation.Visible = radioFromStoreType.SelectedValue == StoreType.IssueLocation.ToString();
        treeToLocation.Visible = radioToStoreType.SelectedValue == StoreType.IssueLocation.ToString();

        panelDetails.Enabled =
            objectBase.CurrentObjectState != "Committed" &&
            objectBase.CurrentObjectState != "PendingApproval" &&
            objectBase.CurrentObjectState != "PendingStoreApproval";
        tabDetails.Enabled = objectBase.CurrentObjectState != "Cancelled";

        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        OStoreTransferItem storeTransferItem = TransferItem_SubPanel.SessionObject as OStoreTransferItem;
        TransferItem_SubPanel.ObjectPanel.BindControlsToObject(storeTransferItem);

        if (storeTransfer != null &&
            storeTransferItem != null &&
            storeTransferItem.Catalogue != null)
        {

            if (storeTransferItem.Catalogue.IsGeneratedFromEquipmentType == 0)
            {
                // This is an inventory check-in, so show the
                // lot number and expiry date fields.
                //
                //TransferItem_Quantity.Enabled = true;
            }
            else if (storeTransferItem.Catalogue.IsGeneratedFromEquipmentType == 1)
            {
                // This is an equipment check-in, so show
                // serial number, model number and equipment
                // related fields.
                //
                //TransferItem_Quantity.Enabled = false;
                //TransferItem_Quantity.Text = "1";
                storeTransferItem.Quantity = 1;

                if (objectBase.CurrentObjectState == "ApprovedForTransfer")
                {
                    TransferItem_QuantityToTransfer.Text = "1";
                    storeTransferItem.QuantityToTransfer = 1;
                }
            }

        }

        if (
            objectBase.CurrentObjectState == "Committed" ||
            objectBase.CurrentObjectState == "ApprovedForTransfer" ||
            objectBase.CurrentObjectState == "Cancel")
        {
            gridTransferItem.Columns[6].Visible = true;
            gridTransferItem.Columns[1].Visible = TransferItem_Panel.Enabled =
            buttonAddEquipment.Enabled = buttonAddItems.Enabled =
            gridTransferItem.Commands[0].Visible = gridTransferItem.Commands[1].Visible = false;
        }
        else
            gridTransferItem.Columns[6].Visible = false;

        // Fix from store, setup from Application Setting
        FromStoreID.Enabled = false;
    }

    /// <summary>
    /// Occurs when the user selects an item in the From Store
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void FromStoreID_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Occurs when the user selects an item in the To Store
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ToStoreID_SelectedIndexChanged(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// Occurs when the user clicks on an item on the catalog treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TransferItem_CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OStoreTransfer transfer = (OStoreTransfer)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(transfer);

        OStoreTransferItem item = (OStoreTransferItem)this.TransferItem_SubPanel.SessionObject;
        TransferItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        TransferItem_FromStoreBinID.Bind(
            OStore.FindBinsByCatalogue((Guid)transfer.FromStoreID, item.CatalogueID, false), "ObjectName", "ObjectID", true);
        TransferItem_ToStoreBinID.Bind(
            OStore.FindBinsByCatalogue((Guid)transfer.ToStoreID, item.CatalogueID, true), "ObjectName", "ObjectID", true);

        // Ensure that the equipment dropdown list is compulsory if the
        // user selected a equipment catalog type.
        //
        if (item.Catalogue != null)
        {
            if (item.Catalogue.InventoryCatalogType == InventoryCatalogType.Equipment)
            {
                dropStoreBinItem.Visible = true;
                dropStoreBinItem.ValidateRequiredField = true;
            }
            else
            {
                dropStoreBinItem.Visible = false;
                dropStoreBinItem.ValidateRequiredField = false;
            }
        }

        dropStoreBinItem.Items.Clear();
    }

    /// <summary>
    /// Validates and saves the store transfer object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;

            // 2011.02.21
            // Kim Foong.
            // The BindControlsToObject should be called instead.
            //
            //panel.ObjectPanel.BindObjectToControls(storeTransfer);
            panel.ObjectPanel.BindControlsToObject(storeTransfer);

            // Validate
            //
            if (objectBase.SelectedAction == "SubmitForApproval" ||
                objectBase.SelectedAction == "Approve" ||
                objectBase.SelectedAction == "Commit")
            {
                if (!storeTransfer.ValidateItemsFromAndToStore())
                {
                    gridTransferItem.ErrorMessage = Resources.Errors.Transfer_FromStoreBinToStoreBinDoNotMatchTransfer;
                }
                else
                {
                    //if (!storeTransfer.ValidateSufficientItemsForTransfer())
                    //{
                    //    string list = "";
                    //    foreach (OStoreTransferItem item in storeTransfer.StoreTransferItems)
                    //        if (item.Valid)
                    //            list += (list == "" ? "" : Resources.Messages.General_CommaSeparator) + item.Catalogue.ObjectName + " (" + item.FromStoreBin.ObjectName + ")";

                    //    ((UIGridView)Page.FindControl("gridTransferItem")).ErrorMessage = String.Format(Resources.Errors.Transfer_InsufficientItems, list);
                    //}

                    // Validates to ensure that the none of the store bins
                    // are locked before we try to check in.
                    //
                    string lockedBins = storeTransfer.ValidateBinsNotLocked();
                    if (lockedBins != "")
                        gridTransferItem.ErrorMessage = String.Format(Resources.Errors.StoreTransfer_StoreBinsLocked, lockedBins);

                    foreach (OStoreTransferItem transferItem in storeTransfer.StoreTransferItems)
                    {
                        if (transferItem.Quantity > transferItem.QuantityToTransfer)
                            gridTransferItem.ErrorMessage = Resources.Errors.StoreTransfer_InvalidAmount;
                    }
                }
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            storeTransfer.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Occurs when the user clicks on the
    /// "Add Consumables/Non-Consumables" button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddItems_Click(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        panel.FocusWindow = false;
        Window.Open("additems.aspx", "AnacleEAM_Popup");
    }

    /// <summary>
    /// Occurs when the user clicks on the "Add Equipment" button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddEquipment_Click(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        panel.FocusWindow = false;
        Window.Open("addeqpt.aspx", "AnacleEAM_Popup");
    }

    /// <summary>
    /// Occurs when the user confirms and closes
    /// the pop up window.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        panel.ObjectPanel.BindObjectToControls(storeTransfer);
    }

    /// <summary>
    /// Binds the store bin item dropdown list to show
    /// the list of equipment available for selection
    /// in the bin.
    /// </summary>
    protected void BindStoreBinItemDropDownList()
    {
        OStoreTransferItem storeTransferItem = this.TransferItem_SubPanel.SessionObject as OStoreTransferItem;

        dropStoreBinItem.Items.Clear();
        if (storeTransferItem.FromStoreBin != null)
            dropStoreBinItem.Bind(storeTransferItem.FromStoreBin.
                GetEquipmentStoreBinItem(storeTransferItem.CatalogueID, storeTransferItem.StoreBinItemID),
                "Equipment.ObjectName", "ObjectID", true);

    }

    /// <summary>
    /// Occurs when the user selects a different "From" store bin.
    /// Updates the list of equipment according to the selected bin.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TransferItem_FromStoreBinID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreTransferItem storeTransferItem = this.TransferItem_SubPanel.SessionObject as OStoreTransferItem;
        TransferItem_SubPanel.ObjectPanel.BindControlsToObject(storeTransferItem);

        BindStoreBinItemDropDownList();
    }

    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeFromLocation_AcquireTreePopulater(object sender)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;

        return new LocationTreePopulaterForCapitaland(storeTransfer.FromLocationID, false, true, "OStoreTransfer", false, false);
    }

    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeToLocation_AcquireTreePopulater(object sender)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;

        return new LocationTreePopulaterForCapitaland(storeTransfer.ToLocationID, false, true, "OStoreTransfer", false, false);
    }

    /// <summary>
    /// Occurs when the user selects node on the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeFromLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        BindFromStoreDropDownLists(storeTransfer);
    }

    /// <summary>
    /// Occurs when the user selects node on the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeToLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        BindToStoreDropDownLists(storeTransfer);
    }

    /// <summary>
    /// Occurs when the user selects an item in the radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioFromStoreType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        storeTransfer.FromStoreID = null;
        storeTransfer.FromLocationID = null;
        BindFromStoreDropDownLists(storeTransfer);
    }

    /// <summary>
    /// Occurs when the user selects an item in the radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioToStoreType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = panel.SessionObject as OStoreTransfer;
        panel.ObjectPanel.BindControlsToObject(storeTransfer);
        storeTransfer.ToStoreID = null;
        storeTransfer.ToLocationID = null;
        BindToStoreDropDownLists(storeTransfer);
    }

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void gridTransferItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[9].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
            {
                try
                {
                    e.Row.Cells[8].Text = Convert.ToDecimal(e.Row.Cells[8].Text).ToString("#,##0");
                }
                catch
                {
                }
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="serveR" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Transfer" BaseTable="tStoreTransfer"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"
            ShowWorkflowActionAsButtons="True"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Transfer" meta:resourcekey="uitabview1Resource1"
                    BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameVisible="false"
                        ObjectNumberEnabled="false" ObjectNumberCaption="Transfer Number" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIPanel runat='server' ID="panelDetails" BorderStyle="NotSet" meta:resourcekey="panelDetailsResource1">
                        <ui:UIPanel runat="server" ID="panelStore" BorderStyle="NotSet" meta:resourcekey="panelStoreResource1">
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr valign="top">
                                    <td>
                                        <ui:UISeparator runat="server" ID="UISeparator1" Caption="From Store" meta:resourcekey="UISeparator1Resource1" />
                                        <ui:UIFieldRadioList runat="server" ID="radioFromStoreType" Caption="Store Type"
                                            PropertyName="FromStoreType" OnSelectedIndexChanged="radioFromStoreType_SelectedIndexChanged"
                                            ValidateRequiredField="True" meta:resourcekey="radioFromStoreTypeResource1" TextAlign="Right">
                                            <Items>
                                                <asp:ListItem Text="Storeroom" Value="0" meta:resourcekey="ListItemResource1"></asp:ListItem>
                                                <asp:ListItem Text="Location" Value="1" meta:resourcekey="ListItemResource2"></asp:ListItem>
                                            </Items>
                                        </ui:UIFieldRadioList>
                                        <ui:UIFieldTreeList runat="server" ID="treeFromLocation" PropertyName="FromLocationID"
                                            Caption="Location" OnAcquireTreePopulater="treeFromLocation_AcquireTreePopulater"
                                            OnSelectedNodeChanged="treeFromLocation_SelectedNodeChanged" ValidateRequiredField="True"
                                            meta:resourcekey="treeFromLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                                        </ui:UIFieldTreeList>
                                        <ui:UIFieldDropDownList runat="server" ID="FromStoreID" ValidateRequiredField="True"
                                            PropertyName="FromStoreID" Caption="Store Name" ToolTip="Store from which the items will be transfered."
                                            OnSelectedIndexChanged="FromStoreID_SelectedIndexChanged" meta:resourcekey="FromStoreIDResource1" />
                                    </td>
                                    <td style="width: 5%">
                                    </td>
                                    <td>
                                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="To Store" meta:resourcekey="UISeparator2Resource1" />
                                        <ui:UIFieldRadioList runat="server" ID="radioToStoreType" Caption="Store Type" PropertyName="ToStoreType"
                                            OnSelectedIndexChanged="radioToStoreType_SelectedIndexChanged" ValidateRequiredField="True"
                                            meta:resourcekey="radioToStoreTypeResource1" TextAlign="Right">
                                            <Items>
                                                <asp:ListItem Text="Storeroom" Value="0" meta:resourcekey="ListItemResource3"></asp:ListItem>
                                                <asp:ListItem Text="Location" Value="1" meta:resourcekey="ListItemResource4"></asp:ListItem>
                                            </Items>
                                        </ui:UIFieldRadioList>
                                        <ui:UIFieldTreeList runat="server" ID="treeToLocation" PropertyName="ToLocationID"
                                            Caption="Location" OnAcquireTreePopulater="treeToLocation_AcquireTreePopulater"
                                            OnSelectedNodeChanged="treeToLocation_SelectedNodeChanged" ValidateRequiredField="True"
                                            meta:resourcekey="treeToLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                                        </ui:UIFieldTreeList>
                                        <ui:UIFieldDropDownList runat="server" ID="ToStoreID" ValidateRequiredField="True"
                                            PropertyName="ToStoreID" Caption="Store Name" ToolTip="Store to which the items will be transferred."
                                            OnSelectedIndexChanged="ToStoreID_SelectedIndexChanged" meta:resourcekey="ToStoreIDResource1">
                                        </ui:UIFieldDropDownList>
                                    </td>
                                </tr>
                            </table>
                        </ui:UIPanel>
                        <br />
                        <br />
                        <ui:UIFieldTextBox runat="server" ID="Description" PropertyName="Description" Caption="Remarks"
                            ToolTip="Remarks for the transfer." TextMode="MultiLine" meta:resourcekey="DescriptionResource1"
                            InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
                        <ui:UIButton runat="server" ID="buttonAddItems" Text="Add Multiple Items" ImageUrl="~/images/add.gif"
                            CausesValidation="False" OnClick="buttonAddItems_Click" />
                        <ui:UIButton runat="server" ID="buttonAddEquipment" Text="Add Equipment" ImageUrl="~/images/add.gif"
                            CausesValidation="False" OnClick="buttonAddEquipment_Click" meta:resourcekey="buttonAddEquipmentResource1" />
                        <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False" OnClick="buttonItemsAdded_Click"
                            meta:resourcekey="buttonItemsAddedResource1" />
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridTransferItem" PropertyName="StoreTransferItems"
                            Caption="Transfer Items" KeyName="ObjectID" meta:resourcekey="gridTransferItemResource1"
                            Width="100%" BindObjectsToRows="True" PagingEnabled="True" RowErrorColor="" ValidateRequiredField="True"
                            ShowFooter="True" PageSize="1000" DataKeyNames="ObjectID" GridLines="Both" Style="clear: both;"
                            OnRowDataBound="gridTransferItem_RowDataBound" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject"
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.ObjectName" HeaderText="Item" meta:resourceKey="UIGridViewColumnResource7"
                                    PropertyName="Catalogue.ObjectName" ResourceAssemblyName="" SortExpression="Catalogue.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StoreBinItem.Equipment.ObjectName" HeaderText="Equipment Name"
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="StoreBinItem.Equipment.ObjectName"
                                    ResourceAssemblyName="" SortExpression="StoreBinItem.Equipment.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="FromStoreBin.ObjectName" HeaderText="From Bin"
                                    meta:resourceKey="UIGridViewColumnResource8" PropertyName="FromStoreBin.ObjectName"
                                    ResourceAssemblyName="" SortExpression="FromStoreBin.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ToStoreBin.ObjectName" HeaderText="To Bin"
                                    meta:resourceKey="UIGridViewColumnResource9" PropertyName="ToStoreBin.ObjectName"
                                    ResourceAssemblyName="" SortExpression="ToStoreBin.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Quantity Received" meta:resourcekey="GridViewQuantityResource2">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox ID="Quantity" runat="server" Caption="Quantity" FieldLayout="Flow"
                                            InternalControlWidth="95%" MaxLength="255" meta:resourcekey="QuantityResource2"
                                            PropertyName="Quantity" ShowCaption="False" ValidateRequiredField="True">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewBoundColumn HeaderText="Quantity to Transfer" PropertyName="QuantityToTransfer"
                                    meta:resourcekey="QuantitytoTransferResource2" DataField="QuantityToTransfer"
                                    ResourceAssemblyName="" SortExpression="QuantityToTransfer">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" HeaderText="Unit of Measure"
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                    ResourceAssemblyName="" SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EstimatedUnitCost" HeaderText="Estimated Unit Cost"
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="EstimatedUnitCost"
                                    ResourceAssemblyName="" SortExpression="EstimatedUnitCost">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="SubTotal" DataFormatString="{0:n}" FooterAggregate="Sum"
                                    HeaderText="Sub Total" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="SubTotal"
                                    ResourceAssemblyName="" SortExpression="SubTotal">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="TransferItem_Panel" meta:resourcekey="TransferItem_PanelResource1"
                            BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="TransferItem_SubPanel" OnPopulateForm="TransferItem_SubPanel_Populate"
                                GridViewID="gridTransferItem" MultiSelectColumnNames="CatalogueID,FromStoreBinID,ToStoreBinID,Quantity"
                                OnValidateAndUpdate="TransferItem_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTreeList runat="server" ID="TransferItem_CatalogueID" PropertyName="CatalogueID"
                                Caption="Catalogue" ValidateRequiredField="True" OnAcquireTreePopulater="TransferItemID_AcquireTreePopulater"
                                ToolTip="Item being transferred." OnSelectedNodeChanged="TransferItem_CatalogueID_SelectedNodeChanged"
                                meta:resourcekey="TransferItem_CatalogueIDResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldLabel runat="server" ID="TransferItem_UnitOfMeasure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                Caption="Unit of Measure" meta:resourcekey="TransferItem_UnitOfMeasureResource1"
                                DataFormatString="" />
                            <ui:UIFieldDropDownList runat="server" ID="TransferItem_FromStoreBinID" ValidateRequiredField="True"
                                PropertyName="FromStoreBinID" Caption="From Bin" Span="Half" ToolTip="Bin of the store where the item is transferred from."
                                meta:resourcekey="TransferItem_FromStoreBinIDResource1" OnSelectedIndexChanged="TransferItem_FromStoreBinID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropStoreBinItem" PropertyName="StoreBinItemID"
                                Caption="Equipment" ToolTip="The equipment to be transferred." meta:resourcekey="dropStoreBinItemResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="TransferItem_ToStoreBinID" ValidateRequiredField="True"
                                PropertyName="ToStoreBinID" Caption="To Bin" Span="Half" ToolTip="Bin of the store where the item is transferred to."
                                meta:resourcekey="TransferItem_ToStoreBinIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox runat="server" ID="TransferItem_QuantityToTransfer" PropertyName="QuantityToTransfer"
                                Span="Half" ValidateRequiredField="True" ValidationDataType="Double" Caption="Quantity To Transfer"
                                meta:resourcekey="TransferItem_QuantityResource3" InternalControlWidth="95%" />
                            <%--<ui:UIFieldLabel runat="server" ID="labelUnitOfMeasure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                Caption="Unit of Measure" DataFormatString="" meta:resourcekey="labelUnitOfMeasureResource1">
                            </ui:UIFieldLabel>--%>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
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
                    <br />
                    <br />
                    <br />
                    <br />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Status History" BorderStyle="NotSet"
                    meta:resourcekey="uitabview1Resource2">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Memo" meta:resourcekey="uitabview2Resource1"
                    BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Attachments" meta:resourcekey="uitabview3Resource1"
                    BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>