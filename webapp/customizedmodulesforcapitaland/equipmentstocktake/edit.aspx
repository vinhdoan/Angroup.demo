<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;

        treeLocation.PopulateTree();
        treeCatalogue.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(StockTake);

    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        bool IsDraftState = objectBase.CurrentObjectState.Is("Start", "Draft");
        this.panelHeader.Enabled = IsDraftState;
        this.LocationStockTakeItems.Visible = !IsDraftState;
        this.LocationStockTakeItems.Enabled = objectBase.CurrentObjectState.Is("InProgress");
        this.LocationStockTakeItems_ObjectPanel.Enabled = objectBase.CurrentObjectState.Is("InProgress");
        this.tabViewAdjustmentItems.Visible = !objectBase.CurrentObjectState.Is("Start", "Draft", "InProgress");
        this.ReconciliationItems_ObjectPanel.Enabled = objectBase.CurrentObjectState.Is("PendingReconciliation");
        this.LocationStockTakeReconciliationItems.Enabled = objectBase.CurrentObjectState.Is("PendingReconciliation") && !this.ReconciliationItems_SubPanel.Visible;

        panelCatalogue.Visible = !IsIncludingToAllCatalogueTypes.Checked;

        Reconciliation_EquipmentID.Visible = false;
        sddl_ReconciliatedEquipmentID.Visible = Action.SelectedValue == "3";
        panelNewEquipment.Visible = Action.SelectedValue == "2";

        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        if (objectBase.CurrentObjectState.Is("PendingReconciliation"))
        {
            ListItem item = objectBase.GetWorkflowRadioListItem("Close");
            item.Enabled = (StockTake.HasItemsPendingReconciliation > 0) ? false : true;

            ListItem item2 = objectBase.GetWorkflowRadioListItem("SubmitForApproval");
            item2.Enabled = (StockTake.HasItemsPendingReconciliation == 0) ? false : true;
        }

    }


    protected void LocationStockTakeItems_RowDataBound(Object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataKey key = LocationStockTakeItems.DataKeys[e.Row.RowIndex];


            if (key["IsManuallyAdded"].ToString() != "1")
            {
                e.Row.Cells[1].Controls[0].Visible = false;
                e.Row.Cells[2].Controls[0].Visible = false;
            }

            if (objectBase.CurrentObjectState != "InProgress")
            {
                UIFieldTextBox text = (UIFieldTextBox)e.Row.FindControl("ObservedQuantity");

                if (text != null)
                    text.Enabled = false;
            }
        }
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
            OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(StockTake);


            // Validate
            //
            if (objectBase.SelectedAction == "Start")
            {
                string lockedStoreBins = StockTake.ValidateStoreBinsNotLocked();
                if (lockedStoreBins != "")
                    gridLocations.ErrorMessage = String.Format(Resources.Errors.LocationStockTake_StoreBinsLocked, lockedStoreBins);
            }
            else if (objectBase.SelectedAction == "SubmitForReconciliation")
            {
                Hashtable hashCount = new Hashtable();
                foreach (OLocationStockTakeItem item in StockTake.LocationStockTakeItems)
                {
                    if (hashCount[item.ObjectID] == null)
                        hashCount[item.ObjectID] = item.ObservedQuantity.Value;
                    else
                        hashCount[item.ObjectID] = item.ObservedQuantity.Value + Convert.ToDecimal(hashCount[item.ObjectID]);
                }

                StringBuilder sb = new StringBuilder();
                foreach (DictionaryEntry de in hashCount)
                {
                    decimal count = Convert.ToDecimal(de.Value);
                    if (count > 1)
                    {
                        if (sb.Length == 0)
                            sb.Append(de.Key + ":" + count.ToString("#,##0"));
                        else
                            sb.Append(", " + de.Key + ":" + count.ToString("#,##0"));
                    }
                }

                if (sb.Length > 0)
                    LocationStockTakeItems.ErrorMessage = String.Format(Resources.Errors.LocationStockTake_EquipmentQtyGreaterThanOne, sb.ToString());

                sb = new StringBuilder();
                foreach (OLocationStockTakeItem item in StockTake.LocationStockTakeItems)
                {
                    if (item.IsManuallyAdded == 1 && item.ObservedQuantity == 0)
                    {
                        sb.Append((sb.Length == 0 ? "" : ", ") + item.ItemName + " (" + item.Barcode + ")");
                    }
                }
                if (sb.Length > 0)
                    LocationStockTakeItems.ErrorMessage = String.Format(Resources.Errors.LocationStockTake_InvalidObservedQuantities, sb.ToString());
            }
            else if (objectBase.SelectedAction == "SubmitForApproval")
            {
                StringBuilder sb = new StringBuilder();
                foreach (OLocationStockTakeReconciliationItem item in StockTake.LocationStockTakeReconciliationItems)
                {
                    if (item.Action == LocationStockTakeReconciliationAction.TransferToAnotherLocation
                        && item.Equipment == null)
                        sb.Append((sb.Length == 0 ? "" : ", ") + item.ItemName + " (" + item.ScannedCode + ")");
                }

                if (sb.Length > 0)
                    LocationStockTakeReconciliationItems.ErrorMessage = String.Format(Resources.Errors.LocationStockTake_InvalidTransferEquipment, sb.ToString());

                sb = new StringBuilder();
                foreach (OLocationStockTakeReconciliationItem item in StockTake.LocationStockTakeReconciliationItems)
                {
                    if (item.Action == LocationStockTakeReconciliationAction.CreateNewEquipment
                        && item.EquipmentName == null)
                        sb.Append((sb.Length == 0 ? "" : ", ") + item.ItemName + " (" + item.ScannedCode + ")");
                }

                if (sb.Length > 0)
                    LocationStockTakeReconciliationItems.ErrorMessage = String.Format(Resources.Errors.LocationStockTake_InvalidNewEquipment, sb.ToString());



                Hashtable hashCount = new Hashtable();
                foreach (OLocationStockTakeReconciliationItem rItem in StockTake.LocationStockTakeReconciliationItems)
                {
                    if (hashCount[rItem.ObjectID] == null)
                        hashCount[rItem.ObjectID] = rItem.ObservedQuantity.Value;
                    else
                        hashCount[rItem.ObjectID] = rItem.ObservedQuantity.Value + Convert.ToDecimal(hashCount[rItem.ObjectID]);
                }

                sb = new StringBuilder();
                foreach (DictionaryEntry de in hashCount)
                {
                    decimal count = Convert.ToDecimal(de.Value);
                    if (count > 1)
                    {
                        if (sb.Length == 0)
                            sb.Append(de.Key + ":" + count.ToString("#,##0"));
                        else
                            sb.Append(", " + de.Key + ":" + count.ToString("#,##0"));
                    }
                }

                if (sb.Length > 0)
                    LocationStockTakeReconciliationItems.ErrorMessage = String.Format(Resources.Errors.LocationStockTake_EquipmentQtyGreaterThanOne, sb.ToString());

            }

            if (!panel.ObjectPanel.IsValid)
                return;

            StockTake.Save();
            c.Commit();
        }
    }

    protected TreePopulater treeLocation_TreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }

    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);
        if (treeLocation.SelectedValue != "")
            StockTake.Locations.AddGuid(new Guid(treeLocation.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(StockTake);
    }

    protected void gridLocations_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(StockTake);

            foreach (Guid id in dataKeys)
                StockTake.Locations.RemoveGuid(id);

            panel.ObjectPanel.BindObjectToControls(StockTake);
        }
    }

    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        return new CatalogueTreePopulater(null, true, false, false, true);
    }

    protected void treeCatalogue_SelectedNodeChanged(object sender, EventArgs e)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);
        if (treeCatalogue.SelectedValue != "")
            StockTake.Catalogues.AddGuid(new Guid(treeCatalogue.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(StockTake);
    }

    protected void gridCatalogues_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(StockTake);

            foreach (Guid id in dataKeys)
                StockTake.Catalogues.RemoveGuid(id);

            panel.ObjectPanel.BindObjectToControls(StockTake);
        }
    }

    protected void IsIncludingToAllCatalogueTypes_CheckedChanged(object sender, EventArgs e)
    {

    }

    protected TreePopulater LocationID_AcquireTreePopulater(object sender)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);

        OLocationStockTakeItem item = (OLocationStockTakeItem)LocationStockTakeItems_SubPanel.SessionObject;

        if (StockTake.Locations != null && StockTake.Locations.Count > 0)
            return new LocationTreePopulater(item.LocationID, false, true, Security.Decrypt(Request["TYPE"]), StockTake.Locations.ToGuidList());
        else
            return new LocationTreePopulater(item.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    protected void LocationStockTakeItems_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);

        OLocationStockTakeItem item = (OLocationStockTakeItem)LocationStockTakeItems_SubPanel.SessionObject;

        if (item.IsNew && item.StockTakeItemType == null)
            item.StockTakeItemType = LocationStockTakeItemType.Equipment;
        if (item.IsNew && item.PhysicalQuantity == null)
            item.PhysicalQuantity = 0;
        if (item.IsNew && item.ObservedQuantity == null)
            item.ObservedQuantity = 0;

        LocationID.PopulateTree();
        LocationStockTakeItems_SubPanel.ObjectPanel.BindObjectToControls(item);

    }

    protected void LocationStockTakeItems_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);
        OLocationStockTakeItem item = (OLocationStockTakeItem)LocationStockTakeItems_SubPanel.SessionObject;
        LocationStockTakeItems_SubPanel.ObjectPanel.BindControlsToObject(item);

        item.IsManuallyAdded = 1;

        if (item.ObservedQuantity == 0)
            ObservedQuantity.ErrorMessage = Resources.Errors.LocationStockTake_InvalidObservedQuantity;

        if (!LocationStockTakeItems_SubPanel.ObjectPanel.IsValid)
            return;

        StockTake.LocationStockTakeItems.Add(item);
        panel.ObjectPanel.BindObjectToControls(StockTake);
    }


    protected TreePopulater Reconciliation_EquipmentID_AcquireTreePopulater(object sender)
    {
        OLocationStockTakeReconciliationItem item = (OLocationStockTakeReconciliationItem)ReconciliationItems_SubPanel.SessionObject;
        return new EquipmentTreePopulater(item.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    protected TreePopulater Reconciliation_LocationID_AcquireTreePopulater(object sender)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);

        OLocationStockTakeReconciliationItem item = (OLocationStockTakeReconciliationItem)ReconciliationItems_SubPanel.SessionObject;

        if (StockTake.Locations != null && StockTake.Locations.Count > 0)
            return new LocationTreePopulater(item.LocationID, false, true, Security.Decrypt(Request["TYPE"]), StockTake.Locations.ToGuidList());
        else
            return new LocationTreePopulater(item.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    protected void ReconciliationItems_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);

        OLocationStockTakeReconciliationItem item = (OLocationStockTakeReconciliationItem)ReconciliationItems_SubPanel.SessionObject;
        Reconciliation_EquipmentID.PopulateTree();
        sddl_ReconciliatedEquipmentID.Bind(TablesLogic.tEquipment.LoadList(TablesLogic.tEquipment.Barcode == item.ScannedCode | TablesLogic.tEquipment.SerialNumber == item.ScannedCode));
        Reconciliation_LocationID.PopulateTree();
        EquipmentTypeID.PopulateTree();
        EquipmentParentID.PopulateTree();

        Action.Items.Clear();
        if (item.ReconciliationType == ReconciliationType.ExistingButNotFound)
        {
            Action.Items.Add(new ListItem("KIV", "0"));
            Action.Items.Add(new ListItem("Mark As Missing", "1"));
        }
        else if (item.ReconciliationType == ReconciliationType.ScannedCodeNotMatched)
        {
            Action.Items.Add(new ListItem("KIV", "0"));
            Action.Items.Add(new ListItem("Create New Equipment", "2"));
        }
        else if (item.ReconciliationType == ReconciliationType.ScannedCodeMatched)
        {
            Action.Items.Add(new ListItem("KIV", "0"));
            Action.Items.Add(new ListItem("Create New Equipment", "2"));
            Action.Items.Add(new ListItem("Transfer To The Selected Location", "3"));
        }

        if (item.Action == LocationStockTakeReconciliationAction.CreateNewEquipment
            && item.SerialNumber == null && item.ScannedCode != null)
            item.SerialNumber = item.ScannedCode;

        ReconciliationItems_SubPanel.ObjectPanel.BindObjectToControls(item);

    }


    protected void ReconciliationItems_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OLocationStockTake StockTake = (OLocationStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StockTake);
        OLocationStockTakeReconciliationItem item = (OLocationStockTakeReconciliationItem)ReconciliationItems_SubPanel.SessionObject;
        ReconciliationItems_SubPanel.ObjectPanel.BindControlsToObject(item);

        if (item.StockTakeItemType == LocationStockTakeItemType.Equipment)
        {
            if (item.Action == LocationStockTakeReconciliationAction.TransferToAnotherLocation)
            {
                if (item.Equipment != null)
                {
                    if (item.Equipment.StoreBinItemID != null)
                    {
                        OStoreBinItem sb = TablesLogic.tStoreBinItem.Load(item.Equipment.StoreBinItemID);
                        if (sb != null && sb.Catalogue != null)
                            item.CatalogueID = sb.Catalogue.ObjectID;
                    }

                    if (item.Equipment.LocationID == item.LocationID)
                        Reconciliation_EquipmentID.ErrorMessage = Resources.Errors.LocationStockTake_InvalidTransferLocation;

                }
                else
                    Reconciliation_EquipmentID.ErrorMessage = Resources.Errors.LocationStockTake_EquipmentHasInvalidCatalogueID;
            }
            else if (item.Action == LocationStockTakeReconciliationAction.CreateNewEquipment)
            {
                OEquipment eqpt = TablesLogic.tEquipment.Create();
                eqpt.IsPhysicalEquipment = 1;
                eqpt.ObjectName = item.EquipmentName;
                eqpt.ParentID = item.EquipmentParentID;
                eqpt.EquipmentTypeID = item.EquipmentTypeID;
                eqpt.LocationID = item.LocationID;
                eqpt.SerialNumber = item.SerialNumber;
                eqpt.DateOfOwnership = item.DateOfOwnership;
                eqpt.PriceAtOwnership = item.PriceAtOwnership;

                foreach (OLocationStockTakeReconciliationItem rItem in StockTake.LocationStockTakeReconciliationItems)
                {
                    if (rItem.ObjectID != item.ObjectID
                        && rItem.EquipmentName != null && rItem.EquipmentName.Trim().ToUpper() == item.EquipmentName.Trim().ToUpper()
                        && rItem.EquipmentParentID == item.EquipmentParentID)
                    {
                        EquipmentName.ErrorMessage = Resources.Errors.LocationStockTake_DuplicatedEquipmentInReconciliationItems;
                        break;
                    }
                }

                if (eqpt.IsDuplicateName())
                    EquipmentName.ErrorMessage = Resources.Errors.LocationStockTake_DuplicatedEquipmentInSystem;

                if (eqpt.IsCyclicalReference())
                    EquipmentParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;
            }

        }


        if (!ReconciliationItems_SubPanel.ObjectPanel.IsValid)
            return;

        if (item.StockTakeItemType == LocationStockTakeItemType.Equipment)
        {
            if (item.Action == LocationStockTakeReconciliationAction.TransferToAnotherLocation ||
                item.Action == LocationStockTakeReconciliationAction.NoAction)
            {
                item.EquipmentName = null;
                item.EquipmentParentID = null;
                item.EquipmentTypeID = null;
                item.SerialNumber = null;
                item.DateOfOwnership = null;
                item.PriceAtOwnership = null;
            }

            if (item.Action == LocationStockTakeReconciliationAction.CreateNewEquipment ||
                item.Action == LocationStockTakeReconciliationAction.NoAction)
            {
                item.EquipmentID = null;
                item.CatalogueID = null;
            }
        }


        StockTake.LocationStockTakeReconciliationItems.Add(item);
        panel.ObjectPanel.BindObjectToControls(StockTake);
    }

    protected void LocationStockTakeReconciliationItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataKey key = LocationStockTakeReconciliationItems.DataKeys[e.Row.RowIndex];
            UIFieldRadioList actionForExisting = (UIFieldRadioList)e.Row.FindControl("ActionForExisting");
            UIFieldRadioList actionForScannedCodeNotMatched = (UIFieldRadioList)e.Row.FindControl("ActionForScannedCodeNotMatched");
            UIFieldRadioList actionForScannedCodeMatched = (UIFieldRadioList)e.Row.FindControl("ActionForScannedCodeMatched");
            OLocationStockTakeReconciliationItem LSTRI = ((OLocationStockTake)panel.SessionObject).LocationStockTakeReconciliationItems.Find(new Guid(key.Value.ToString()));

            if (LSTRI.ReconciliationType == ReconciliationType.ScannedCodeNotMatched)
            {
                e.Row.Cells[1].Controls[0].Visible = true;
                actionForExisting.Visible = false;
                actionForExisting.PropertyName = string.Empty;
                actionForScannedCodeMatched.Visible = false;
                actionForScannedCodeMatched.PropertyName = string.Empty;
                actionForScannedCodeNotMatched.Visible = true;
                actionForScannedCodeNotMatched.PropertyName = "Action";
            }
            else if (LSTRI.ReconciliationType == ReconciliationType.ScannedCodeMatched)
            {
                e.Row.Cells[1].Controls[0].Visible = true;
                actionForExisting.Visible = false;
                actionForExisting.PropertyName = string.Empty;
                actionForScannedCodeMatched.Visible = true;
                actionForScannedCodeMatched.PropertyName = "Action";
                actionForScannedCodeNotMatched.Visible = false;
                actionForScannedCodeNotMatched.PropertyName = string.Empty;
            }
            else if (LSTRI.ReconciliationType == ReconciliationType.ExistingButNotFound)
            {
                e.Row.Cells[1].Controls[0].Visible = false;
                actionForExisting.Visible = true;
                actionForExisting.PropertyName = "Action";
                actionForScannedCodeNotMatched.Visible = false;
                actionForScannedCodeNotMatched.PropertyName = string.Empty;
                actionForScannedCodeMatched.Visible = false;
                actionForScannedCodeMatched.PropertyName = string.Empty;
            }
        }
    }

    protected void Action_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (Action.SelectedValue == LocationStockTakeReconciliationAction.CreateNewEquipment.ToString()
            && SerialNumber.Text == "" && Reconciliation_ScannedCode.Text.Trim().Length > 0)
            SerialNumber.Text = Reconciliation_ScannedCode.Text;
    }

    protected TreePopulater EquipmentTypeID_AcquireTreePopulater(object sender)
    {
        OLocationStockTakeReconciliationItem item = (OLocationStockTakeReconciliationItem)ReconciliationItems_SubPanel.SessionObject;
        return new EquipmentTypeTreePopulater(item.EquipmentTypeID, true, true);
    }

    protected TreePopulater EquipmentParentID_AcquireTreePopulater(object sender)
    {
        OLocationStockTakeReconciliationItem item = (OLocationStockTakeReconciliationItem)ReconciliationItems_SubPanel.SessionObject;
        return new EquipmentTreePopulater(item.EquipmentParentID, true, true, Security.Decrypt(Request["TYPE"]));
    }

    protected void ActionForExisting_SelectedIndexChanged(object sender, EventArgs e)
    {
        UIFieldRadioList ActionForExisting = (UIFieldRadioList)sender;
        if (ActionForExisting.SelectedValue != "0")
        {
            GridViewRow GVR = (GridViewRow)ActionForExisting.Parent.Parent;
            ReconciliationItems_SubPanel.EditObject(new Guid(LocationStockTakeReconciliationItems.DataKeys[GVR.RowIndex].Value.ToString()));
        }
    }

    protected void ActionForScannedCodeNotMatched_SelectedIndexChanged(object sender, EventArgs e)
    {
        UIFieldRadioList ActionForScannedCodeNotMatched = (UIFieldRadioList)sender;
        if (ActionForScannedCodeNotMatched.SelectedValue != "0")
        {
            GridViewRow GVR = (GridViewRow)ActionForScannedCodeNotMatched.Parent.Parent;
            ReconciliationItems_SubPanel.EditObject(new Guid(LocationStockTakeReconciliationItems.DataKeys[GVR.RowIndex].Value.ToString()));
        }
    }

    protected void ActionForScannedCodeMatched_SelectedIndexChanged(object sender, EventArgs e)
    {
        UIFieldRadioList ActionForScannedCodeMatched = (UIFieldRadioList)sender;
        if (ActionForScannedCodeMatched.SelectedValue != "0")
        {
            GridViewRow GVR = (GridViewRow)ActionForScannedCodeMatched.Parent.Parent;
            ReconciliationItems_SubPanel.EditObject(new Guid(LocationStockTakeReconciliationItems.DataKeys[GVR.RowIndex].Value.ToString()));
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Equipment Stock Take" BaseTable="tLocationStockTake"
            ObjectPanelID="tabObject" OnPopulateForm="panel_PopulateForm" AutomaticBindingAndSaving="true"
            OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip ID="tabObject" runat="server" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="uitabview1" runat="server" BorderStyle="NotSet" Caption="Details"
                    ismodifiedbyajax="False" meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" ObjectNameVisible="false"
                        ObjectNumberCaption="Stock Take Number" ObjectNumberEnabled="false" ObjectNumberVisible="true" />
                    <ui:UIPanel ID="panelHeader" runat="server" BorderStyle="NotSet" meta:resourcekey="panelHeaderResource1">
                        <ui:UIFieldTextBox ID="Reason" runat="server" Caption="Reason" PropertyName="Reason"
                            ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="ReasonResource1" />
                        <ui:UIFieldTreeList ID="treeLocation" runat="server" Caption="Location" OnAcquireTreePopulater="treeLocation_TreePopulater"
                            ToolTip="The location that this stock take applies to" ShowCheckBoxes="None"
                            TreeValueMode="SelectedNode" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                            meta:resourcekey="treeLocationResource1">
                        </ui:UIFieldTreeList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gridLocations" PropertyName="Locations" Caption="List of Location"
                                        ValidateRequiredField="True" ToolTip="The locations this stock take applies to."
                                        KeyName="ObjectID" BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both"
                                        RowErrorColor="" Style="clear: both;" OnAction="gridLocations_Action" ImageRowErrorUrl="" meta:resourcekey="gridLocationsResource1">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Commands>
                                            <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?"
                                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                        </Commands>
                                        <Columns>
                                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?"
                                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </ui:UIGridViewButtonColumn>
                                            <ui:UIGridViewBoundColumn DataField="Path" HeaderText="Location Path" PropertyName="Path"
                                                ResourceAssemblyName="" SortExpression="Path" meta:resourcekey="UIGridViewBoundColumnResource1">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </ui:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <ui:UIFieldCheckBox runat="server" ID="IsIncludingToAllCatalogueTypes" PropertyName="IsIncludingToAllCatalogueTypes"
                            Caption="All Equipment Types?" Text="Yes, the stock take includes all equipment types under the selected location(s)"
                            TextAlign="Right" OnCheckedChanged="IsIncludingToAllCatalogueTypes_CheckedChanged" meta:resourcekey="IsIncludingToAllCatalogueTypesResource1">
                        </ui:UIFieldCheckBox>
                        <ui:UIPanel ID="panelCatalogue" runat="server" BorderStyle="NotSet" meta:resourcekey="panelCatalogueResource1">
                            <ui:UIFieldTreeList runat="server" ID="treeCatalogue" Caption="Equipment Type" ToolTip="Equipment type that this stock take applies to"
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" OnAcquireTreePopulater="treeCatalogue_AcquireTreePopulater"
                                OnSelectedNodeChanged="treeCatalogue_SelectedNodeChanged" meta:resourcekey="treeCatalogueResource1" />
                            <ui:UIGridView runat="server" ID="gridCatalogues" PropertyName="Catalogues" Caption="List of Equipment Type"
                                ValidateRequiredField="True" ToolTip="The equipments this stock take applies to. "
                                KeyName="ObjectID" BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both"
                                RowErrorColor="" Style="clear: both;" OnAction="gridCatalogues_Action" ImageRowErrorUrl="" meta:resourcekey="gridCataloguesResource1">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Commands>
                                    <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                        CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?"
                                        ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                                </Commands>
                                <Columns>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?"
                                        ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn DataField="Path" HeaderText="Equipment Type" PropertyName="Path"
                                        ResourceAssemblyName="" SortExpression="Path" meta:resourcekey="UIGridViewBoundColumnResource2">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <br />
                    <ui:UIHint ID="hintLockBins" runat="server" meta:resourcekey="hintLockBinsResource1"></ui:UIHint>
                    <br />
                    <ui:UIFieldLabel ID="lblLocationTakeStartDate" runat="server" ajaxpostback="False"
                        border="0" Caption="Stock Take Start Date" cellpadding="2" cellspacing="0" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                        Height="20px" ismodifiedbyajax="False" meta:resourcekey="lblStoreTakeStartDateResource1"
                        PropertyName="LocationStockTakeStartDateTime" Span="Half" stringvalue="" Style="float: left;
                        table-layout: fixed;" Width="99%">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="lblLocationTakeEndDate" runat="server" ajaxpostback="False"
                        border="0" Caption="Stock Take End Date" cellpadding="2" cellspacing="0" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                        Height="20px" ismodifiedbyajax="False" meta:resourcekey="lblStoreTakeEndDateResource1"
                        PropertyName="LocationStockTakeEndDateTime" Span="Half" stringvalue="" Style="float: left;
                        table-layout: fixed;" Width="99%">
                    </ui:UIFieldLabel>
                    <br />
                    <br />
                    <ui:UISeparator ID="UISeparator1" runat="server" meta:resourcekey="UISeparatorResource1" />
                    <ui:UIGridView ID="LocationStockTakeItems" runat="server" BindObjectsToRows="True" Width="100%"
                        Caption="Equipment" CheckBoxColumnVisible="False" DataKeyNames="ObjectID,IsManuallyAdded"
                        OnRowDataBound="LocationStockTakeItems_RowDataBound" PropertyName="LocationStockTakeItems"
                        SortExpression="Location.Path, ItemName" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="LocationStockTakeItemsResource1" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource3" />
                        </Commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject"
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location Path" PropertyName="Location.Path"
                                ResourceAssemblyName="" SortExpression="Location.Path" meta:resourcekey="UIGridViewBoundColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment Path"
                                PropertyName="Equipment.Path" ResourceAssemblyName="" SortExpression="Equipment.Path" meta:resourcekey="UIGridViewBoundColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ItemName" HeaderText="Item Name" PropertyName="ItemName"
                                ResourceAssemblyName="" SortExpression="ItemName" meta:resourcekey="UIGridViewBoundColumnResource5">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ItemType" HeaderText="Item Type" PropertyName="ItemType"
                                ResourceAssemblyName="" SortExpression="ItemType" meta:resourcekey="UIGridViewBoundColumnResource6">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Barcode" HeaderText="Tag Number" PropertyName="Barcode"
                                ResourceAssemblyName="" SortExpression="Barcode" meta:resourcekey="UIGridViewBoundColumnResource7">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="SerialNumber" HeaderText="Serial Number" PropertyName="SerialNumber"
                                ResourceAssemblyName="" SortExpression="SerialNumber" meta:resourcekey="UIGridViewBoundColumnResource8">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ScannedCode" HeaderText="Scanned Code" PropertyName="ScannedCode"
                                ResourceAssemblyName="" SortExpression="ScannedCode" meta:resourcekey="UIGridViewBoundColumnResource9">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="PhysicalQuantity" DataFormatString="{0:#,##0}"
                                HeaderText="Physical Qty" PropertyName="PhysicalQuantity" ResourceAssemblyName=""
                                SortExpression="PhysicalQuantity" meta:resourcekey="UIGridViewBoundColumnResource10">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Observed Qty" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <ui:UIFieldTextBox ID="ObservedQuantity" runat="server" Caption="Actual Qty" InternalControlWidth="80px"
                                        PropertyName="ObservedQuantity" DataFormatString="{0:#,##0}" ShowCaption="False" FieldLayout="Flow"
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" ValidateRequiredField="True"
                                        ValidationDataType="Integer" ValidationRangeMin="0" ValidationRangeMax="1" ValidationRangeType="Integer" meta:resourcekey="ObservedQuantityResource1">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="LocationStockTakeItems_ObjectPanel" BorderStyle="NotSet" meta:resourcekey="LocationStockTakeItems_ObjectPanelResource1">
                        <web:subpanel runat="server" ID="LocationStockTakeItems_SubPanel" GridViewID="LocationStockTakeItems"
                            OnPopulateForm="LocationStockTakeItems_SubPanel_PopulateForm" OnValidateAndUpdate="LocationStockTakeItems_SubPanel_ValidateAndUpdate">
                        </web:subpanel>
                        <ui:UIFieldTreeList runat="server" ID="LocationID" Caption="Found At Location" PropertyName="LocationID"
                            ValidateRequiredField="True" ShowCheckBoxes="None" TreeValueMode="SelectedNode"
                            OnAcquireTreePopulater="LocationID_AcquireTreePopulater" meta:resourcekey="LocationIDResource1" />
                        <ui:UIFieldTextBox runat="server" ID="tb_ScannedCode" PropertyName="ScannedCode"
                            Span="Half" Caption="Scanned Code" ToolTip="The scanned code that represents this equipment." InternalControlWidth="95%" meta:resourcekey="tb_ScannedCodeResource1" />
                        <ui:UIFieldTextBox ID="Remarks" runat="server" Caption="Remarks" PropertyName="Remarks"
                            ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="RemarksResource1" />
                        <ui:UIFieldLabel ID="PhysicalQuantity" runat="server" PropertyName="PhysicalQuantity"
                            DataFormatString="{0:#,##0}" Caption="Physical Qty" meta:resourcekey="PhysicalQuantityResource1" />
                        <ui:UIFieldTextBox ID="ObservedQuantity" runat="server" Caption="Actual Qty" InternalControlWidth="80px"
                            PropertyName="ObservedQuantity" DataFormatString="{0:#,##0}" ValidateDataTypeCheck="True"
                            ValidateRangeField="True" ValidateRequiredField="True" ValidationDataType="Integer"
                            ValidationRangeMin="0" ValidationRangeMax="1" ValidationRangeType="Integer" meta:resourcekey="ObservedQuantityResource2">
                        </ui:UIFieldTextBox>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabViewAdjustmentItems" runat="server" BorderStyle="NotSet" Caption="Reconciliation" meta:resourcekey="tabViewAdjustmentItemsResource1">
                    <ui:UIGridView ID="LocationStockTakeReconciliationItems" runat="server" ajaxpostback="False"
                        BindObjectsToRows="True" Caption="Reconciliation Items" PropertyName="LocationStockTakeReconciliationItems"
                        CheckBoxColumnVisible="False" DataKeyNames="ObjectID,IsManuallyAdded" GridLines="Both" ismodifiedbyajax="False" pagingenabled="True" RowErrorColor=""
                        SortExpression="Location.Path, ItemName" Style="clear: both;" Width="100%" OnRowDataBound="LocationStockTakeReconciliationItems_RowDataBound" meta:resourcekey="LocationStockTakeReconciliationItemsResource1">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject"
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource5">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location Path" PropertyName="Location.Path"
                                ResourceAssemblyName="" SortExpression="Location.Path" meta:resourcekey="UIGridViewBoundColumnResource11">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment Path"
                                PropertyName="Equipment.Path" ResourceAssemblyName="" SortExpression="Equipment.Path" meta:resourcekey="UIGridViewBoundColumnResource12">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ItemName" HeaderText="Item Name" PropertyName="ItemName"
                                ResourceAssemblyName="" SortExpression="ItemName" meta:resourcekey="UIGridViewBoundColumnResource13">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ItemType" HeaderText="Item Type" PropertyName="ItemType"
                                ResourceAssemblyName="" SortExpression="ItemType" meta:resourcekey="UIGridViewBoundColumnResource14">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Barcode" HeaderText="Tag Number" PropertyName="Barcode"
                                ResourceAssemblyName="" SortExpression="Barcode" meta:resourcekey="UIGridViewBoundColumnResource15">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="SerialNumber" HeaderText="Serial Number" PropertyName="SerialNumber"
                                ResourceAssemblyName="" SortExpression="SerialNumber" meta:resourcekey="UIGridViewBoundColumnResource16">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ScannedCode" HeaderText="Scanned Code" PropertyName="ScannedCode"
                                ResourceAssemblyName="" SortExpression="ScannedCode" meta:resourcekey="UIGridViewBoundColumnResource17">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="PhysicalQuantity" DataFormatString="{0:#,##0}"
                                HeaderText="Physical Qty" meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="PhysicalQuantity"
                                ResourceAssemblyName="" SortExpression="PhysicalQuantity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ObservedQuantity" DataFormatString="{0:#,##0}"
                                HeaderText="Observed Qty" meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="ObservedQuantity"
                                ResourceAssemblyName="" SortExpression="ObservedQuantity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Action" meta:resourcekey="UIGridViewTemplateColumnResource2">
                                <ItemTemplate>
                                    <cc1:UIFieldRadioList ID="ActionForExisting" runat="server" Caption="Action" meta:resourcekey="ActionForExistingResource1" OnSelectedIndexChanged="ActionForExisting_SelectedIndexChanged" RepeatColumns="0" RepeatDirection="Vertical" ShowCaption="False" TextAlign="Right" ValidateRequiredField="True">
                                        <Items>
                                            <asp:ListItem meta:resourcekey="ListItemResource1" Selected="True" Text="KIV" Value="0"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource2" Text="Mark as Missing" Value="1"></asp:ListItem>
                                        </Items>
                                    </cc1:UIFieldRadioList>
                                    <cc1:UIFieldRadioList ID="ActionForScannedCodeNotMatched" runat="server" Caption="Action" meta:resourcekey="ActionForScannedCodeNotMatchedResource1" OnSelectedIndexChanged="ActionForScannedCodeNotMatched_SelectedIndexChanged" RepeatColumns="0" RepeatDirection="Vertical" ShowCaption="False" TextAlign="Right" ValidateRequiredField="True">
                                        <Items>
                                            <asp:ListItem meta:resourcekey="ListItemResource3" Selected="True" Text="KIV" Value="0"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource4" Text="Create Eqpt" Value="2"></asp:ListItem>
                                        </Items>
                                    </cc1:UIFieldRadioList>
                                    <cc1:UIFieldRadioList ID="ActionForScannedCodeMatched" runat="server" Caption="Action" meta:resourcekey="ActionForScannedCodeMatchedResource1" OnSelectedIndexChanged="ActionForScannedCodeMatched_SelectedIndexChanged" RepeatColumns="0" RepeatDirection="Vertical" ShowCaption="False" TextAlign="Right" ValidateRequiredField="True">
                                        <Items>
                                            <asp:ListItem meta:resourcekey="ListItemResource5" Selected="True" Text="KIV" Value="0"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource6" Text="Create Eqpt" Value="2"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource7" Text="Move to New Loc" Value="3"></asp:ListItem>
                                        </Items>
                                    </cc1:UIFieldRadioList>
                                </ItemTemplate>
                                <ControlStyle Width="115px" />
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="ReconciliationItems_ObjectPanel" BorderStyle="NotSet" meta:resourcekey="ReconciliationItems_ObjectPanelResource1">
                        <web:subpanel runat="server" ID="ReconciliationItems_SubPanel" GridViewID="LocationStockTakeReconciliationItems"
                            UpdateAndNewButtonVisible="false" OnPopulateForm="ReconciliationItems_SubPanel_PopulateForm"
                            OnValidateAndUpdate="ReconciliationItems_SubPanel_ValidateAndUpdate"></web:subpanel>
                        <ui:UIFieldTreeList runat="server" ID="Reconciliation_LocationID" Caption="Found At Location"
                            PropertyName="LocationID" ValidateRequiredField="True" ShowCheckBoxes="None"
                            TreeValueMode="SelectedNode" OnAcquireTreePopulater="Reconciliation_LocationID_AcquireTreePopulater" meta:resourcekey="Reconciliation_LocationIDResource1" />
                        <ui:UIFieldTextBox runat="server" ID="Reconciliation_ScannedCode" PropertyName="ScannedCode"
                            Span="Half" Caption="Scanned Code" Enabled="False" InternalControlWidth="95%" meta:resourcekey="Reconciliation_ScannedCodeResource1" />
                        <ui:UIFieldTextBox ID="Reconciliation_Remarks" runat="server" Caption="Remarks" PropertyName="Remarks"
                            ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="Reconciliation_RemarksResource1" />
                        <ui:UIFieldLabel ID="Reconciliation_PhysicalQuantity" runat="server" PropertyName="PhysicalQuantity"
                            DataFormatString="{0:#,##0}" Caption="Physical Qty" meta:resourcekey="Reconciliation_PhysicalQuantityResource1" />
                        <ui:UIFieldLabel ID="Reconciliation_ObservedQuantity" runat="server" PropertyName="ObservedQuantity"
                            DataFormatString="{0:#,##0}" Caption="Observed Qty" meta:resourcekey="Reconciliation_ObservedQuantityResource1" />
                        <ui:UIFieldRadioList runat="server" ID="Action" PropertyName="Action" Caption="Action"
                            RepeatColumns="0" TextAlign="Right" ValidateRequiredField="True" OnSelectedIndexChanged="Action_SelectedIndexChanged" meta:resourcekey="ActionResource1">
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTreeList runat="server" ID="Reconciliation_EquipmentID" Caption="Equipment"
                            PropertyName="EquipmentID" ValidateRequiredField="True" ShowCheckBoxes="None"
                            TreeValueMode="SelectedNode" OnAcquireTreePopulater="Reconciliation_EquipmentID_AcquireTreePopulater" meta:resourcekey="Reconciliation_EquipmentIDResource1" />
                        <ui:UIFieldSearchableDropDownList runat="server" ID="sddl_ReconciliatedEquipmentID"
                            Caption="Equipment" PropertyName="EquipmentID" ValidateRequiredField="True" meta:resourcekey="sddl_ReconciliatedEquipmentIDResource1" SearchInterval="300">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIPanel ID="panelNewEquipment" runat="server" BorderStyle="NotSet" meta:resourcekey="panelNewEquipmentResource1">
                            <ui:UIFieldTextBox runat="server" ID="EquipmentName" PropertyName="EquipmentName"
                                Span="Half" Caption="Equipment Name" ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="EquipmentNameResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTreeList runat="server" ID="EquipmentParentID" PropertyName="EquipmentParentID"
                                Caption="Belongs Under" ValidateRequiredField="True" ToolTip="The equipment or the folder under which this equipment belongs."
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" OnAcquireTreePopulater="EquipmentParentID_AcquireTreePopulater" meta:resourcekey="EquipmentParentIDResource1" />
                            <ui:UIFieldTreeList runat="server" ID="EquipmentTypeID" PropertyName="EquipmentTypeID"
                                Caption="Equipment Type" ValidateRequiredField="True" ToolTip="The type of this equipment."
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" OnAcquireTreePopulater="EquipmentTypeID_AcquireTreePopulater" meta:resourcekey="EquipmentTypeIDResource1">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox runat="server" ID="SerialNumber" PropertyName="SerialNumber" Span="Half"
                                Caption="Serial Number" ToolTip="The serial number of this equipment." InternalControlWidth="95%" meta:resourcekey="SerialNumberResource1" />
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Status History" meta:resourcekey="StatusHistoryResource1"
                    BorderStyle="NotSet">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView ID="tabMemo" runat="server" BorderStyle="NotSet" Caption="Memo"
                    meta:resourcekey="tabMemoResource1">
                    <web:memo ID="Memo1" runat="server" />
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" BorderStyle="NotSet" Caption="Attachments"
                    CssClass="div-form" meta:resourcekey="uitabview2Resource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
