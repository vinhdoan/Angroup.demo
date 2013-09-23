<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.UIFramework" %>
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
        OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
        objectBase.ObjectNumberVisible = !storeCheckOut.IsNew;

        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), storeCheckOut.StoreID));
        MoveToStoreID.Bind(OStore.GetAllPhysicalStoreroomsActiveForCheckIns());
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

                // Validates to ensure that the amount check-out is less than the Estimated Quantity from WO
                if (DestinationType.SelectedValue == "2")
                    foreach (OStoreCheckOutItem scoi in storeCheckOut.StoreCheckOutItems)
                        if ((scoi.FromWorkCost.EstimatedQuantity - scoi.FromWorkCost.ActualQuantity) < scoi.ActualQuantity)
                            gridCheckOutItem.ErrorMessage = Resources.Errors.StoreCheckOut_InsufficientWOItems;

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

        // If work is selected
        if (DestinationType.SelectedValue == "2")
        {
            CheckOut_CatalogueID.Enabled = false;
            CheckOut_StoreBinID.Enabled = false;
            OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Load(
                           TablesLogic.tStoreBinReservation.WorkCostID == item.FromWorkCostID);
            CheckOut_ReservedQuantity.Visible = true;
            if (sbr != null)
                CheckOut_ReservedQuantity.Text = sbr.BaseQuantityRequired.ToString();
            else
                CheckOut_ReservedQuantity.Text = "0";
        }
        else
        {
            CheckOut_CatalogueID.Enabled = true;
            CheckOut_StoreBinID.Enabled = true;
            CheckOut_ReservedQuantity.Visible = false;
        }

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

        // Validates quantity if its a Whole Number according to Catalog Type
        if (CheckOut_CatalogueID.SelectedValue != "")
        {
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(CheckOut_CatalogueID.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(CheckOut_ActualQuantity.Text) != 0)
            {
                CheckOut_ActualQuantity.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }
        }

        // Validates to ensure that the amount check-out is less than the Estimated Quantity from WO
        if (DestinationType.SelectedValue == "2")
            if ((item.FromWorkCost.EstimatedQuantity - item.FromWorkCost.ActualQuantity) < item.ActualQuantity)
            {
                CheckOut_ActualQuantity.ErrorMessage = Resources.Errors.StoreCheckOut_InsufficientWOItems;
                return;
            }

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
        List<OStore> s = new List<OStore>();
        s.Add(TablesLogic.tStore.Load(new Guid(StoreID.SelectedValue)));
        //return new CatalogueTreePopulater(storeCheckOutItem.CatalogueID, true, true);
        return new CatalogueTreePopulater(storeCheckOutItem.CatalogueID, true, true, true, true, s);
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
        panelDestinationWork.Visible = DestinationType.SelectedIndex == 2 && StoreID.SelectedValue != "";
        gridCheckOutItem.Commands[1].Visible = buttonAddItems.Visible = DestinationType.SelectedIndex != 2;
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

        //IsMovedToAnotherStore.Enabled = Description.Enabled = DestinationType.Enabled = buttonAddItems.Enabled =
        //    objectBase.CurrentObjectState != "Committed" &&
        //    objectBase.CurrentObjectState != "PendingApproval";

        //if (objectBase.CurrentObjectState == "Committed" ||
        //    objectBase.CurrentObjectState == "PendingApproval")
        //{
        //    gridCheckOutItem.Enabled = true;
        //    //gridCheckOutItem.HeaderRow
        //    foreach (UIGridViewCommand command in gridCheckOutItem.Commands)
        //    {
        //        command.Visible = false;
        //    }
        //}

        tabDetails.Enabled = objectBase.CurrentObjectState != "Cancelled";

        MoveToStoreID.Visible = IsMovedToAnotherStore.Checked;
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

    protected void IsMovedToAnotherStore_CheckChanged(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void gridCheckOutItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[10].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
                e.Row.Cells[9].Text = Convert.ToDecimal(e.Row.Cells[9].Text).ToString("#,##0");
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

    protected void Work_ControlClicked(object sender, EventArgs e)
    {
        searchWork.Show();
    }

    protected void searchWork_Selected(object sender, EventArgs e)
    {
        OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
        //WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);

        Guid? id = (Guid?)searchWork.SelectedDataKeys[0];
        storeCheckOut.WorkID = id;

        storeCheckOut.StoreCheckOutItems.Clear();

        OWork work = storeCheckOut.Work;
        foreach (OWorkCost wc in work.WorkCost)
        {
            if (wc.CostType == (int)WorkCostType.Material && wc.StoreID == storeCheckOut.StoreID)
            {
                OStoreCheckOutItem newScoi = TablesLogic.tStoreCheckOutItem.Create();
                newScoi.FromWorkCostID = wc.ObjectID;
                newScoi.StoreBinID = wc.StoreBinID;
                newScoi.CatalogueID = wc.CatalogueID;
                newScoi.BaseQuantity = (wc.EstimatedQuantity - wc.ActualQuantity) >= 0 ? (wc.EstimatedQuantity - wc.ActualQuantity) : 0;
                newScoi.ActualQuantity = (wc.EstimatedQuantity - wc.ActualQuantity) >= 0 ? (wc.EstimatedQuantity - wc.ActualQuantity) : 0;
                newScoi.ActualUnitOfMeasureID = wc.UnitOfMeasureID;
                newScoi.ComputeBaseQuantity();
                if (newScoi.BaseQuantity == 0)
                    newScoi.EstimatedUnitCost = 0;
                else
                {
                    newScoi.ComputeEstimatedUnitCost();
                    storeCheckOut.StoreCheckOutItems.Add(newScoi);
                }
            }
        }

        panel.ObjectPanel.BindObjectToControls(storeCheckOut);
    }

    protected void searchWork_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        e.CustomCondition = TablesLogic.tWork.CurrentActivity.CurrentStateName.In("PendingExecution", "PendingContractor", "PendingMaterial", "PendingOthers", "PendingClosure")
            & TablesLogic.tWork.WorkCost.StoreID == new Guid(StoreID.Text)
            & TablesLogic.tWork.WorkCost.EstimatedQuantity != 0;
    }

    protected void WorkID_SelectedValueChanged(object sender, EventArgs e)
    {
        OStoreCheckOut storeCheckOut = panel.SessionObject as OStoreCheckOut;
        storeCheckOut.StoreCheckOutItems.Clear();
        storeCheckOut.WorkID = null;
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
    <ui:UIObjectPanel runat="serveR" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Check Out" BaseTable="tStoreCheckOut"
            ShowWorkflowActionAsButtons="true" SaveButtonsVisible="false" OnPopulateForm="panel_PopulateForm"
            meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Check Out" meta:resourcekey="uitabview1Resource1"
                    BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameVisible="false"
                        ObjectNumberEnabled="false" ObjectNumberCaption="Check-Out Number" meta:resourcekey="objectBase1">
                    </web:base>
                    <ui:UIPanel runat="server" ID="panelDetails" BorderStyle="NotSet" meta:resourcekey="panelDetailsResource1">
                        <ui:UIFieldDropDownList runat="server" ID="StoreID" PropertyName="StoreID" Caption="Store"
                            OnSelectedIndexChanged="StoreID_SelectedIndexChanged" meta:resourcekey="StoreIDResource1"
                            ValidateRequiredField="True" />
                        <ui:UIFieldCheckBox runat="server" ID="IsMovedToAnotherStore" PropertyName="IsMovedToAnotherStore"
                            Caption="Moved to Store" meta:resourcekey="IsMovedToAnotherStoreResource1" OnCheckedChanged="IsMovedToAnotherStore_CheckChanged"
                            TextAlign="Right">
                        </ui:UIFieldCheckBox>
                        <ui:UIFieldDropDownList runat="server" ID="MoveToStoreID" PropertyName="MoveToStoreID"
                            Caption="Store Moved To" meta:resourcekey="MoveToStoreIDResource1" />
                        <ui:UIFieldTextBox runat="server" ID="Description" PropertyName="Description" Caption="Remarks"
                            ToolTip="Remarks for the check in." TextMode="MultiLine" meta:resourcekey="DescriptionResource1"
                            InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat="server" ID="DestinationType" ValidateRequiredField="True"
                            RepeatColumns="0" PropertyName="DestinationType" Caption="Check-Out To" OnSelectedIndexChanged="DestinationType_SelectedIndexChanged"
                            meta:resourcekey="DestinationTypeResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" Selected="True" meta:resourcekey="ListItemResource1" Text="None"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="User"></asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" Text="Work"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelDestinationUser" meta:resourcekey="panelDestinationUserResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldDropDownList runat="server" ID="UserID" PropertyName="UserID" Caption="User"
                                ValidateRequiredField="True" meta:resourcekey="UserIDResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelDestinationWork" meta:resourcekey="panelDestinationWorkResource1"
                            BorderStyle="NotSet">
                            <web:searchdialogbox runat="server" ID="searchWork" Title="Search Work Order" SearchTextBoxPropertyNames="ObjectName,ObjectNumber"
                                SimpleTextboxHint="Enter your search criteria to look for your work order." AllowMultipleSelection="false"
                                BaseTable="tWork" MaximumNumberOfResults="30" AutoSearchOnLoad="true" OnSearched="searchWork_Searched"
                                OnSelected="searchWork_Selected">
                                <Columns>
                                    <ui:UIGridViewButtonColumn AlwaysEnabled="true" ImageUrl="~/images/tick.gif" CommandName="Click"
                                        ButtonType="Image">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Work Number" HeaderStyle-Width="150px" PropertyName="ObjectNumber">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Work Description" HeaderStyle-Width="400px"
                                        PropertyName="ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                            </web:searchdialogbox>
                            <ui:UIFieldDialogSelection runat="server" ID="WorkID" PropertyName="WorkID" PropertyNameItem="Work.ObjectNumber"
                                Span="Half" Caption="Work Order" ImageClearUrl="~/images/cross.gif" ValidateRequiredField="true"
                                OnSelectedValueChanged="WorkID_SelectedValueChanged" OnControlClicked="Work_ControlClicked">
                            </ui:UIFieldDialogSelection>
                            <%--<ui:UIFieldDropDownList runat="server" ID="WorkID" PropertyName="WorkID" Caption="Work"
                                ValidateRequiredField="True" ToolTip="Work order number that this check out is for."
                                meta:resourcekey="WorkIDResource1">
                            </ui:UIFieldDropDownList>--%>
                        </ui:UIPanel>
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                        <ui:UIButton runat="server" ID="buttonAddItems" Text="Add Multiple Items" ImageUrl="~/images/add.gif"
                            CausesValidation="False" OnClick="buttonAddItems_Click" />
                        <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False" OnClick="buttonItemsAdded_Click"
                            meta:resourcekey="buttonItemsAddedResource1" />
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridCheckOutItem" PropertyName="StoreCheckOutItems"
                            Caption="Check Out Items" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="gridCheckOutItemResource1"
                            Width="100%" ValidateRequiredField="True" ShowFooter="True" PageSize="1000" DataKeyNames="ObjectID"
                            GridLines="Both" RowErrorColor="" Style="clear: both;" OnRowDataBound="gridCheckOutItem_RowDataBound">
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
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.ObjectName" HeaderText="Catalog"
                                    meta:resourceKey="UIGridViewColumnResource3" PropertyName="Catalogue.ObjectName"
                                    ResourceAssemblyName="" SortExpression="Catalogue.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.StockCode" HeaderText="Stock Code"
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Catalogue.StockCode"
                                    ResourceAssemblyName="" SortExpression="Catalogue.StockCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StoreBin.ObjectName" HeaderText="Bin" meta:resourceKey="UIGridViewColumnResource4"
                                    PropertyName="StoreBin.ObjectName" ResourceAssemblyName="" SortExpression="StoreBin.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" HeaderText="Base Unit"
                                    meta:resourceKey="UIGridViewColumnResource5" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                    ResourceAssemblyName="" SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ActualQuantity" HeaderText="Check-Out Qty"
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="ActualQuantity" ResourceAssemblyName=""
                                    SortExpression="ActualQuantity" DataFormatString="{0:#,##0.00##}">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ActualUnitOfMeasure.ObjectName" HeaderText="Check-Out Unit"
                                    meta:resourceKey="UIGridViewColumnResource7" PropertyName="ActualUnitOfMeasure.ObjectName"
                                    ResourceAssemblyName="" SortExpression="ActualUnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BaseQuantity" HeaderText="Base Qty" meta:resourcekey="UIGridViewBoundColumnResource2"
                                    PropertyName="BaseQuantity" ResourceAssemblyName="" SortExpression="BaseQuantity"
                                    DataFormatString="{0:#,##0.00##}">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" HeaderText="Base Unit"
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                    ResourceAssemblyName="" SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EstimatedUnitCost" HeaderText="Unit Cost (Estimated)"
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="EstimatedUnitCost"
                                    ResourceAssemblyName="" SortExpression="EstimatedUnitCost">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="SubTotal" FooterAggregate="Sum" HeaderText="Sub Total"
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="SubTotal" ResourceAssemblyName=""
                                    SortExpression="SubTotal">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%--<cc1:UIGridViewTemplateColumn HeaderText="Return Qty" SortExpression="ReturnQuantity">
                                    <HeaderStyle Width="105px" />
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="ReturnQuantity" ShowCaption="false" PropertyName="ReturnQuantity"
                                            Span="Half" InternalControlWidth="80px" FieldLayout="Flow" DataFormatString="{0:#,##0.00##}"
                                            ValidateRequiredField="false">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </cc1:UIGridViewTemplateColumn>--%>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="CheckOutItem_Panel" meta:resourcekey="CheckOutItem_PanelResource1"
                            BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="CheckOutItem_SubPanel" GridViewID="gridCheckOutItem"
                                MultiSelectColumnNames="CatalogueID,StoreBinID,ActualQuantity,ActualUnitOfMeasureID"
                                OnPopulateForm="CheckOutItem_SubPanel_PopulateForm" OnValidateAndUpdate="CheckOutItem_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTreeList runat="server" ID="CheckOut_CatalogueID" PropertyName="CatalogueID"
                                Caption="Catalog Item" ValidateRequiredField="True" OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater"
                                ToolTip="Catalog item to check-out" OnSelectedNodeChanged="CheckOut_CatalogueID_SelectedNodeChanged"
                                meta:resourcekey="CheckOut_CatalogueIDResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldDropDownList runat="server" ID="CheckOut_StoreBinID" PropertyName="StoreBinID"
                                ValidateRequiredField="True" Caption="Bin (Avail Qty)" Span="Half" ToolTip="The bin where this item is checked out from."
                                meta:resourcekey="CheckOut_StoreBinIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldLabel runat="server" ID="CheckOut_ReservedQuantity" Caption="Reserved Quantity"
                                DataFormatString="{0:#,##0.00##}">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="CheckOut_BaseUnitOfMeasure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                Caption="Base Unit" meta:resourcekey="CheckOut_BaseUnitOfMeasureResource1" DataFormatString="" />
                            <ui:UIFieldTextBox runat="server" ID="CheckOut_ActualQuantity" PropertyName="ActualQuantity"
                                ValidateRangeField="True" ValidationRangeType='Currency' ValidationRangeMin="0"
                                ValidationRangeMinInclusive="False" Span="Half" ValidateRequiredField="True"
                                ValidationDataType="Double" Caption="Check-Out Quantity" ToolTip="Check-out quantity."
                                meta:resourcekey="CheckOut_ActualQuantityResource1" InternalControlWidth="95%"
                                DataFormatString="{0:#,##0.00##}" />
                            <ui:UIFieldDropDownList runat="server" ID="CheckOut_ActualUnitOfMeasureID" PropertyName="ActualUnitOfMeasureID"
                                ValidateRequiredField="True" Caption="Check-Out Unit" Span="Half" OnSelectedIndexChanged="CheckOut_ActualUnitOfMeasureID_SelectedIndexChanged"
                                meta:resourcekey="CheckOut_ActualUnitOfMeasureIDResource1">
                            </ui:UIFieldDropDownList>
                            <br />
                            <ui:UIFieldLabel runat="server" ID="CheckOut_ConversionText" PropertyName="ConversionText"
                                Caption="Conversion Example" meta:resourcekey="CheckOut_ConversionTextResource1"
                                DataFormatString="" />
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