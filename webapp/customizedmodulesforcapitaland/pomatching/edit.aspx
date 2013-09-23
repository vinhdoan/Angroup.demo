<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase"
    Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseOrder purchaseOrder = panel.SessionObject as OPurchaseOrder;

        if (purchaseOrder.CurrentActivity == null ||
            purchaseOrder.CurrentActivity.ObjectName.Is("Draft"))
            purchaseOrder.UpdateApplicablePurchaseSettings();

        objectBase.ObjectNumberVisible = !purchaseOrder.IsNew;

        dropCase.Bind(OCase.GetAccessibleOpenCases(AppSession.User, Security.Decrypt(Request["TYPE"]), purchaseOrder.CaseID), "Case", "ObjectID");
        VendorID.Bind(OVendor.GetVendors(DateTime.Today, purchaseOrder.VendorID));
        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), purchaseOrder.StoreID));
        ContractID.Bind(OContract.GetContractsByPurchaseOrder(purchaseOrder));
        dropCurrency.Bind(OCurrency.GetAllCurrencies(purchaseOrder.CurrencyID), "CurrencyNameAndDescription", "ObjectID", true);
        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", purchaseOrder.PurchaseTypeID));

        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;

        if (purchaseOrder.CurrentActivity == null ||
            !purchaseOrder.CurrentActivity.ObjectName.Is("PendingApproval", "PendingReceipt", "Closed", "Cancelled"))
        {
            purchaseOrder.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        else
            gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";

        if (purchaseOrder.CurrentActivity.ObjectName.Is("PendingReceipt", "Close"))
        {
            gridInvoices.DataSource = OPurchaseInvoice.GetNonCancelledInvoicesByPurchaseOrder(purchaseOrder);
            gridInvoices.DataBind();
        }
        SetGridViewCurrencyDataFormatString();

        // Set access control for the buttons
        //
        if (purchaseOrder.CaseID != null)
        {
            buttonViewCase.Visible = AppSession.User.AllowViewAll("OCase");
            buttonEditCase.Visible = AppSession.User.AllowEditAll("OCase") || OActivity.CheckAssignment(AppSession.User, purchaseOrder.CaseID);
        }
        else
        {
            buttonViewCase.Visible = false;
            buttonEditCase.Visible = false;
        }
        gridInvoices.Columns[0].Visible = AppSession.User.AllowEditAll("OPurchaseInvoice");
        

        panel.ObjectPanel.BindObjectToControls(purchaseOrder);
    }


    /// <summary>
    /// Validates and saves the purchase order.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OPurchaseOrder purchaseOrder = panel.SessionObject as OPurchaseOrder;
            panel.ObjectPanel.BindControlsToObject(purchaseOrder);

            if (!purchaseOrder.ValidateAllUnitPricesEntered())
                PurchaseOrderItems.ErrorMessage = Resources.Errors.PurchaseOrder_UnitPriceNotEntered;

            // Validate
            //
            if (!objectBase.CurrentObjectState.Is("Close", "Cancelled") &&
                !OCase.ValidateCaseNotClosedOrCancelled(purchaseOrder.CaseID))
            {
                dropCase.ErrorMessage = Resources.Errors.Case_CannotBeClosedOrCancelled;
            }


            if (objectBase.SelectedAction == "Cancel")
            {
                // Ensures that the purchase order cannot be cancelled
                // once an invoice or receipt has been created against
                // this purchase order.
                //
                if (!OPurchaseOrder.ValidateNoGoodsReceiptAndInvoices(purchaseOrder.ObjectID))
                {
                    gridReceipts.ErrorMessage = Resources.Errors.PurchaseOrder_CannotBeCancelledGoodsReceiptAndInvoiceGenerated;
                    gridInvoices.ErrorMessage = Resources.Errors.PurchaseOrder_CannotBeCancelledGoodsReceiptAndInvoiceGenerated;
                }
            }


            if (objectBase.SelectedAction == "SubmitForApproval")
            {
                // Ensure that all budget accounts in the budget
                // line items are set as active.
                //
                string inactiveAccounts = OPurchaseBudget.ValidateBudgetAccountsAreActive(purchaseOrder.PurchaseBudgets);
                if (inactiveAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseOrder_BudgetAccountsNotActive, inactiveAccounts);
                }
               
                
                // Ensure that the budget periods covering the start date of
                // the purchase order exists, and has not yet been closed.
                //
                string closedBudgets = OPurchaseBudget.ValidateBudgetPeriodsActiveAndOpened(purchaseOrder.PurchaseBudgets);
                if (closedBudgets != "")
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseOrder_BudgetPeriodsClosed, closedBudgets);

                // Ensure budget amounts and line item amounts are equal.
                //
                int itemNumber = purchaseOrder.ValidateBudgetAmountEqualsLineItemAmount();
                if (itemNumber >= 0)
                {
                    string itemNumberText = "";
                    if (itemNumber > 0)
                        itemNumberText = String.Format(Resources.Errors.PurchaseOrder_ItemAmountNotEqualsBudgetAmount_LineItem, itemNumber);
                    else
                        itemNumberText = Resources.Errors.PurchaseOrder_ItemAmountNotEqualsBudgetAmount_EntirePO;

                    if (purchaseOrder.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems)
                        gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseOrder_ItemAmountNotEqualsBudgetAmount, itemNumberText);
                    else if (purchaseOrder.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems)
                        gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseOrder_ItemAmountLessThanBudgetAmount, itemNumberText);
                }

                // Ensure sufficient budgets.
                //
                string insufficientAccounts = purchaseOrder.ValidateSufficientBudget();
                if (insufficientAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseOrder_InsufficientBudget, insufficientAccounts);
                }

                // Ensure that number of quotations is sufficient.
                //
                if (purchaseOrder.ValidateRFQToPOPolicy() == 0)
                {
                    PurchaseOrderItems.ErrorMessage =
                        Resources.Errors.PurchaseOrder_NoRFQBeforePO;
                }
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            purchaseOrder.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropPurchaseType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.UpdateApplicablePurchaseSettings();
        panel.ObjectPanel.BindObjectToControls(po);
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        return new LocationTreePopulaterForCapitaland(po.LocationID, false, true, 
            Security.Decrypt(Request["TYPE"]),false,false);
    }


    /// <summary>
    /// Updates the requestor dropdown list when the location changes,
    /// and clears the selected equipment ID.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.EquipmentID = null;
        po.UpdateApplicablePurchaseSettings();
        panel.ObjectPanel.BindObjectToControls(po);
    }


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        return new EquipmentTreePopulater(po.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Updates the location to the location of the selected equipment.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        if (po.Equipment != null)
        {
            po.LocationID = po.Equipment.LocationID;
            treeLocation.PopulateTree();
        }
        panel.ObjectPanel.BindObjectToControls(po);
    }


    /// <summary>
    /// Finds and updates the exchange rate.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropCurrency_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.UpdateExchangeRate();
        po.UpdateItemCurrencies();
        SetGridViewCurrencyDataFormatString();
        panel.ObjectPanel.BindObjectToControls(po);
    }


    /// <summary>
    /// Sets the grid view's currency to show the unit
    /// price with the correct currency symbol.
    /// </summary>
    protected void SetGridViewCurrencyDataFormatString()
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        if (po.Currency != null)
            ((BoundField)PurchaseOrderItems.Columns[8]).DataFormatString =
                po.Currency.DataFormatString;
        else
            ((BoundField)PurchaseOrderItems.Columns[8]).DataFormatString = "{0:n}";
    }


    /// <summary>
    /// Occurs when the user clicks on the Add Multiple Inventory Items
    /// button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddMaterialItems_Click(object sender, EventArgs e)
    {
        Window.Open("addcatalog.aspx");
        panel.FocusWindow = false;
    }


    /// <summary>
    /// Occurs when the user clicks on the Add Multiple Service Items
    /// button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddFixedRateItems_Click(object sender, EventArgs e)
    {
        Window.Open("addfixedrate.aspx");
        panel.FocusWindow = false;
    }


    /// <summary>
    /// Occurs when the user adds selected items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        po.UpdateItemCurrencies();
        PurchaseOrderItemPanel.BindObjectToControls(po);
    }
    
        
    /// <summary>
    /// Occurs when the user selects the budget distribution mode.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioBudgetDistributionMode_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Temporary variable to house the base currency object.
    /// </summary>
    OCurrency baseCurrency;


    /// <summary>
    /// Populates the PO Item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseOrder purchaseOrder = panel.SessionObject as OPurchaseOrder;
        OPurchaseOrderItem purchaseOrderItem = PurchaseOrderItem_SubPanel.SessionObject as OPurchaseOrderItem;

        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", purchaseOrderItem.UnitOfMeasureID));
        CatalogueID.PopulateTree();
        FixedRateID.PopulateTree();

        ItemNumber.Items.Clear();
        OPurchaseOrder p = (OPurchaseOrder)panel.SessionObject;
        for (int i = 1; i <= p.PurchaseOrderItems.Count + 1; i++)
            ItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (purchaseOrderItem.IsNew && purchaseOrderItem.ItemNumber == null)
            purchaseOrderItem.ItemNumber = p.PurchaseOrderItems.Count + 1;
        purchaseOrderItem.CurrencyID = purchaseOrder.CurrencyID;

        PurchaseOrderItem_SubPanel.ObjectPanel.BindObjectToControls(purchaseOrderItem);
    }


    /// <summary>
    /// Validates and inserts the PO Item into the PO.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseOrderItem i = (OPurchaseOrderItem)PurchaseOrderItem_SubPanel.SessionObject;
        //if item number is greater than 1,000,000 i.e, it is set from Mass update page, we need to retain this number for correct reordering later
        int itemNumber = i.ItemNumber.Value;

        PurchaseOrderItem_SubPanel.ObjectPanel.BindControlsToObject(i);

        if (i.ItemType == PurchaseItemType.Material)
        {
            if (i.CatalogueID != null)
            {
                i.ItemDescription = i.Catalogue.ObjectName;
                i.UnitOfMeasureID = i.Catalogue.UnitOfMeasureID;
            }
        }
        else if (i.ItemType == PurchaseItemType.Service)
        {
            if (i.FixedRateID != null)
            {
                i.ItemDescription = i.FixedRate.ObjectName;
                i.UnitOfMeasureID = i.FixedRate.UnitOfMeasureID;
            }
        }
        else if (i.ItemType == PurchaseItemType.Others)
        {
            i.CatalogueID = null;
            i.FixedRateID = null;
        }

        OPurchaseOrder p = (OPurchaseOrder)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(p);
        p.PurchaseOrderItems.Add(i);
        p.ReorderItems(i);
        p.UpdateSingleItemUnitPrice(i);
        PurchaseOrderItemPanel.BindObjectToControls(p);
    }


    /// <summary>
    /// Occurs when the user clicks on the Remove button in the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderItem_SubPanel_Removed(object sender, EventArgs e)
    {
        OPurchaseOrder p = (OPurchaseOrder)panel.SessionObject;

        p.ReorderItems(null);
    }


    /// <summary>
    /// Occurs when the user changes the receipt mode.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioReceiptMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString())
        {
            QuantityOrdered.Text = "1.00";
        }
    }


    /// <summary>
    /// Populates the PO Receipt subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderReceipt_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseOrder po = (OPurchaseOrder)panel.SessionObject;
        OPurchaseOrderReceipt por = (OPurchaseOrderReceipt)PurchaseOrderReceipt_Subpanel.SessionObject;

        PurchaseOrderReceipt_Subpanel.UpdateButtonsVisible = por.IsNew;

        if (po.HasMaterialItems())
        {
            dropStore.Visible = true;
            dropStoreBin.Visible = true;
            dropStore.Bind(OStore.FindAccessibleStores(AppSession.User,
                Security.Decrypt(Request["TYPE"]),
                por.StoreID));
            if (por.StoreID != null)
                dropStoreBin.Bind(OStoreBin.GetStoreBinsByStoreID(por.StoreID.Value, por.StoreBinID));
        }
        else
        {
            dropStore.Visible = false;
            dropStoreBin.Visible = false;
        }
        panelPurchaseOrderReceipt.Enabled = por.IsNew;
        panelStore.Visible = po.IsReceivingMaterialItems(por);

        PurchaseOrderReceipt_Subpanel.ObjectPanel.BindObjectToControls(por);
    }


    /// <summary>
    /// Validates and inserts the PO Receipt into the PO.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderReceipt_Subpanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseOrder po = (OPurchaseOrder)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseOrderReceipt por = (OPurchaseOrderReceipt)PurchaseOrderReceipt_Subpanel.SessionObject;
        PurchaseOrderReceipt_Subpanel.ObjectPanel.BindControlsToObject(por);

        po.PurchaseOrderReceipts.Add(por);
        panel.ObjectPanel.BindObjectToControls(po);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OPurchaseOrder po = (OPurchaseOrder)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(po);

        panelAddReceipt.Visible = !PurchaseOrderReceipt_Panel.Visible && !PurchaseOrderItem_Panel.Visible && !po.ContainsUnsavedReceipts() && po.PurchaseOrderItems.Count > 0;
        panelSaveTip.Visible = po.ContainsUnsavedReceipts() && !PurchaseOrderReceipt_Panel.Visible;

        PurchaseOrderItems.Enabled = po.PurchaseOrderReceipts.Count == 0 && !PurchaseOrderReceipt_Panel.Visible;

        CatalogueID.Visible = ItemType.SelectedIndex == 0;
        UnitOfMeasure.Visible = ItemType.SelectedIndex == 0;
        UnitOfMeasure2.Visible = ItemType.SelectedIndex == 1;
        FixedRateID.Visible = ItemType.SelectedIndex == 1;
        UnitOfMeasureID.Visible = ItemType.SelectedIndex == 2;
        ItemDescription.Visible = ItemType.SelectedIndex == 2;
        VendorID.Enabled = ContractID.SelectedIndex == 0;
        UnitPrice.Enabled = ContractID.SelectedIndex == 0 || (ItemType.SelectedIndex == 2);
        ContractID.Enabled = !this.PurchaseOrderItem_SubPanel.Visible && po.PurchaseOrderItems.Count == 0;
        StoreID.Visible = StoreID.SelectedIndex > 0;
        radioReceiptMode.Enabled = ItemType.SelectedValue != "0";
        tabBudget.Visible = treeLocation.SelectedItem != "" && DateRequired.DateTime != null &&
            po.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;
        gridBudget.Visible = radioBudgetDistributionMode.SelectedValue != "";
        radioBudgetDistributionMode.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        dropItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == "1";
        gridBudgetSummary.Visible = gridBudgetSummary.Rows.Count > 0;
        panelInvoiceMatchToPO.Visible = true;
        panelInvoiceMatchToReceipt.Visible = false;

        if (po != null)
            textForeignToBaseExchangeRate.Enabled = po.IsExchangeRateDefined == 0;

        // Update the quotation policy hint.
        //
        if (po.ValidateRFQToPOPolicy() == -1)
        {
            hintRFQToPOPolicy.Text = Resources.Messages.PurchaseOrder_RFQToPOPreferred;
        }
        else if (po.ValidateRFQToPOPolicy() == 0)
        {
            hintRFQToPOPolicy.Text = Resources.Messages.PurchaseOrder_RFQToPORequired;
        }
        else
        {
            hintRFQToPOPolicy.Text = "";
        }
        hintRFQToPOPolicy.Visible = hintRFQToPOPolicy.Text != "";

        Workflow_Setting();
    }


    /// <summary>
    /// Hides/shows or enables/disables elements based on workflow status.
    /// </summary>
    protected void Workflow_Setting()
    {
        tabDetails.Enabled = !objectBase.CurrentObjectState.Is("Close", "Cancelled");
        panelDetails.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "Cancelled", "Close");
        tabVendor.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "Cancelled", "Close");
        tabTerms.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "Cancelled", "Close");
        tabLineItems.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "Cancelled", "Close");
        tabBudget.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "Cancelled", "Close");
        tabInvoice.Visible = objectBase.CurrentObjectState.Is("PendingReceipt", "Close");

        tabReceipt.Visible = objectBase.CurrentObjectState.Is("PendingReceipt", "Cancelled", "Close");

        dropCurrency.ValidateRequiredField =
            textForeignToBaseExchangeRate.ValidateRequiredField =
            VendorID.ValidateRequiredField = !(objectBase.CurrentObjectState.Is("Start", "Draft") && objectBase.SelectedAction.Is("-"));
        if (textForeignToBaseExchangeRate.ValidateRequiredField)
        {
            rowExchangeRate.Attributes["class"] = "field-required";
            labelExchangeRate.Text = labelExchangeRate.Text.Replace(":", "").Replace("*", "") + "*:";
        }
        else
        {
            rowExchangeRate.Attributes["class"] = "";
            labelExchangeRate.Text = labelExchangeRate.Text.Replace(":", "").Replace("*", "") + ":";
        }

        if (objectBase.CurrentObjectState.Is("Start"))
            objectBase.GetWorkflowRadioListItem("SubmitForReceipt").Enabled = false;
    }


    /// <summary>
    /// Occurs when the user selects an item type in the dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ItemType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrderItem purchaseOrderItem = PurchaseOrderItem_SubPanel.SessionObject as OPurchaseOrderItem;
        PurchaseOrderItem_SubPanel.ObjectPanel.BindControlsToObject(purchaseOrderItem);

        // If the item is a material item type, then
        // set the receipt mode to quantity, and 
        // disable the receipt mode radio button list.
        //
        if (purchaseOrderItem.ItemType == PurchaseItemType.Material)
            purchaseOrderItem.ReceiptMode = ReceiptModeType.Quantity;
        else if (purchaseOrderItem.ItemType == PurchaseItemType.Service)
        {
            purchaseOrderItem.ReceiptMode = ReceiptModeType.Dollar;
            purchaseOrderItem.QuantityOrdered = 1.0M;
        }

        PurchaseOrderItem_SubPanel.ObjectPanel.BindObjectToControls(purchaseOrderItem);
    }


    /// <summary>
    /// Constructs and returns a catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CatalogueID_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        OPurchaseOrderItem poi = PurchaseOrderItem_SubPanel.SessionObject as OPurchaseOrderItem;

        if (po.ContractID != null)
            return new CatalogueTreePopulater(poi.CatalogueID, null, po.ContractID.Value, true, true, true, true);
        else
            return new CatalogueTreePopulater(poi.CatalogueID, true, true, true, true);
    }


    /// <summary>
    /// Occurs when the user selects a node in the catalog treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseOrderItem i = (OPurchaseOrderItem)PurchaseOrderItem_SubPanel.SessionObject;
        PurchaseOrderItem_SubPanel.ObjectPanel.BindControlsToObject(i);

        if (po.ContractID != null)
        {
            if (i.CatalogueID != null)
                i.UnitPrice = po.Contract.GetMaterialUnitPrice(i.CatalogueID.Value);
            else
                i.UnitPrice = null;
        }
        PurchaseOrderItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Constructs and returns a fixed rate tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater FixedRateID_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        OPurchaseOrderItem poi = PurchaseOrderItem_SubPanel.SessionObject as OPurchaseOrderItem;

        if (po.ContractID != null)
            return new FixedRateTreePopulater(poi.FixedRateID, po.ContractID.Value);
        else
            return new FixedRateTreePopulater(poi.FixedRateID, false, true);
    }


    /// <summary>
    /// Occurs when the user selects a node on the fixed rate treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void FixedRateID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseOrderItem i = (OPurchaseOrderItem)PurchaseOrderItem_SubPanel.SessionObject;
        PurchaseOrderItem_SubPanel.ObjectPanel.BindControlsToObject(i);

        if (po.ContractID != null)
        {
            if (i.FixedRateID != null)
                i.UnitPrice = po.Contract.GetServiceUnitPrice(i.FixedRateID.Value);
            else
                i.UnitPrice = null;
        }
        PurchaseOrderItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Occurs when the user clicks on the Receive Items button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddReceipt_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseOrderReceipt receipt = po.CreateReceipt();
        if (receipt != null)
        {
            panel.ObjectPanel.BindObjectToControls(po);
            PurchaseOrderReceipt_Subpanel.AddObject(receipt);
        }
    }


    /// <summary>
    /// Occurs when the user selects a date for the Date of PO field.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DateOfOrder_DateTimeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.UpdateExchangeRate();
        po.UpdateItemCurrencies();
        ContractID.Bind(OContract.GetContractsByPurchaseOrder(po));

        panel.ObjectPanel.BindObjectToControls(po);
    }


    /// <summary>
    /// Update the vendor details.
    /// </summary>
    /// <param name="po"></param>
    protected void UpdateVendorDetails(OPurchaseOrder po)
    {
        if (po.VendorID == null)
        {
            po.ContactAddress = "";
            po.ContactAddressCity = "";
            po.ContactAddressCountry = "";
            po.ContactAddressState = "";
            po.ContactCellPhone = "";
            po.ContactEmail = "";
            po.ContactFax = "";
            po.ContactPerson = "";
            po.ContactPhone = "";
        }
        else
        {
            po.ContactAddress = po.Vendor.OperatingAddress;
            po.ContactAddressCity = po.Vendor.OperatingAddressCity;
            po.ContactAddressCountry = po.Vendor.OperatingAddressCountry;
            po.ContactAddressState = po.Vendor.OperatingAddressState;
            po.ContactCellPhone = po.Vendor.OperatingCellPhone;
            po.ContactEmail = po.Vendor.OperatingEmail;
            po.ContactFax = po.Vendor.OperatingFax;
            po.ContactPerson = po.Vendor.OperatingContactPerson;
            po.ContactPhone = po.Vendor.OperatingPhone;

            if (po.Vendor.CurrencyID != null)
            {
                if (po.CurrencyID != po.Vendor.CurrencyID)
                {
                    po.CurrencyID = po.Vendor.CurrencyID;
                    po.UpdateExchangeRate();
                }
            }
            else
            {
                po.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;
                po.ForeignToBaseExchangeRate = 1.0M;
                po.IsExchangeRateDefined = 1;
            }
        }
    }


    /// <summary>
    /// Occurs when the user selects a contract in the contract
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ContractID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        if (po.ContractID != null)
        {
            po.VendorID = po.Contract.VendorID;
            UpdateVendorDetails(po);
            panel.ObjectPanel.BindObjectToControls(po);
        }
        FixedRateID.PopulateTree();
        CatalogueID.PopulateTree();

    }


    /// <summary>
    /// Occurs when the user selects a vendor in the vendor dropdown
    /// list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void VendorID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        UpdateVendorDetails(po);
        panel.ObjectPanel.BindObjectToControls(po);
    }


    /// <summary>
    /// Occurs when the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void textForeignToBaseExchangeRate_TextChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.UpdateItemCurrencies();
        panel.ObjectPanel.BindObjectToControls(po);
    }


    /// <summary>
    /// Populates the budget subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        dropBudget.Bind(OBudget.GetCoveringBudgets(po.Location, prBudget.BudgetID));
        if (subpanelBudget.IsAddingObject)
        {
            if (dropBudget.Items.Count == 2)
                prBudget.BudgetID = new Guid(dropBudget.Items[1].Value);
            prBudget.StartDate = po.DateRequired;
            prBudget.EndDate = po.DateRequired;
        }

        dropItemNumber.Items.Clear();
        for (int i = 1; i <= po.PurchaseOrderItems.Count; i++)
            dropItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        populateAccount();
        subpanelBudget.ObjectPanel.BindObjectToControls(prBudget);
    }

    /// <summary>
    /// Populates the account tree view.
    /// </summary>
    protected void populateAccount()
    {
        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        if (prBudget.StartDate != null && prBudget.BudgetID != null)
            treeAccount.PopulateTree();
    }

    /// <summary>
    /// Occurs when the start date of the budget commitment is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dateStartDate_DateTimeChanged(object sender, EventArgs e)
    {
        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);
        populateAccount();
    }

    /// <summary>
    /// Occurs when the budget dropdown list changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        populateAccount();
    }

    /// <summary>
    /// Constructs and returns the account tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeAccount_AcquireTreePopulater(object sender)
    {
        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        if (prBudget.StartDate != null && prBudget.BudgetID != null)
        {
            Guid budgetId = prBudget.BudgetID.Value;
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, prBudget.StartDate.Value);

            if (budgetPeriod != null)
                return new AccountTreePopulater(prBudget.AccountID, false, true, budgetPeriod.ObjectID);
        }
        return null;

    }

    /// <summary>
    /// Validates and inserts record.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);

        // Validate
        //

        // Insert
        //
        po.PurchaseBudgets.Add(prBudget);

        if (po.CurrentActivity == null ||
            !po.CurrentActivity.ObjectName.Is("PendingApproval", "PendingReceipt", "Close", "Cancelled"))
        {
            po.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }

        tabBudget.BindObjectToControls(po);
    }


    /// <summary>
    /// Occurs when the user removes a purchase budget item
    /// from the PO.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_Removed(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        if (po.CurrentActivity == null ||
            !po.CurrentActivity.ObjectName.Is("PendingApproval", "PendingReceipt", "Close", "Cancelled"))
        {
            po.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        tabBudget.BindObjectToControls(po);
    }


    /// <summary>
    /// Occurs when the data is bound to the row.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderReceiptItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = (DataRowView)e.Row.DataItem;
            if ((int)drv["PurchaseOrderItem.ReceiptMode"] == ReceiptModeType.Quantity)
            {
                UIFieldTextBox textQuantityDelivered = e.Row.FindControl("PurchaseOrderReceiptItem_QuantityDelivered") as UIFieldTextBox;
                UIFieldTextBox textUnitPrice = e.Row.FindControl("PurchaseOrderReceiptItem_UnitPrice") as UIFieldTextBox;
                textUnitPrice.Enabled = false;
            }
            else
            {
                UIFieldTextBox textQuantityDelivered = e.Row.FindControl("PurchaseOrderReceiptItem_QuantityDelivered") as UIFieldTextBox;
                UIFieldTextBox textUnitPrice = e.Row.FindControl("PurchaseOrderReceiptItem_UnitPrice") as UIFieldTextBox;
                textQuantityDelivered.Enabled = false;
            }
        }
    }

    /// <summary>
    /// Occurs when the store is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropStore_SelectedIndexChanged(object sender, EventArgs e)
    {
        dropStoreBin.Items.Clear();
        if (dropStore.SelectedIndex != 0)
        {
            Guid storeId = new Guid(dropStore.SelectedValue);
            dropStoreBin.Bind(OStoreBin.GetStoreBinsByStoreID(storeId, null));
        }
    }

    /// <summary>
    /// Occurs when the user clicks on a button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridBudgetSummary_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ViewBudget")
        {
            Guid id = (Guid)dataKeys[0];
            OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
            OPurchaseBudgetSummary budgetSummary = po.PurchaseBudgetSummaries.Find(id);
            if (budgetSummary == null)
                budgetSummary = po.TempPurchaseBudgetSummaries.Find((r) => r.ObjectID == id);
            if (budgetSummary != null)
                Window.Open("../../modules/budgetperiod/budgetview.aspx?ID=" +
                    HttpUtility.UrlEncode(Security.Encrypt(budgetSummary.BudgetPeriodID.ToString())));

            panel.FocusWindow = false;
        }
    }


    /// <summary>
    /// Occurs when the user changes the date.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DateRequired_DateTimeChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Creates a new invoice and redirects the user to the invoice page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddInvoice_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        OPurchaseInvoice inv = OPurchaseInvoice.CreateInvoiceFromPO(po, PurchaseInvoiceType.StandardInvoice);
        Window.OpenEditObjectPage(this, "OPurchaseInvoice", inv.ObjectID.ToString(), "");
    }


    /// <summary>
    /// Creates a new invoice and redirects the user to the invoice page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddCreditMemo_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        OPurchaseInvoice inv = OPurchaseInvoice.CreateInvoiceFromPO(po, PurchaseInvoiceType.CreditMemo);
        Window.OpenEditObjectPage(this, "OPurchaseInvoice", inv.ObjectID.ToString(), "");
    }


    /// <summary>
    /// Creates a new invoice and redirects the user to the invoice page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddDebitMemo_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        OPurchaseInvoice inv = OPurchaseInvoice.CreateInvoiceFromPO(po, PurchaseInvoiceType.DebitMemo);
        Window.OpenEditObjectPage(this, "OPurchaseInvoice", inv.ObjectID.ToString(), "");
    }


    /// <summary>
    /// Occurs when the invoices gridview is data bound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridInvoices_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[7].Text = e.Row.Cells[6].Text + e.Row.Cells[7].Text;
            e.Row.Cells[8].Text = e.Row.Cells[6].Text + e.Row.Cells[8].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[6].Visible = false;
    }

    /// <summary>
    /// Opens a window to edit the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditCase_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = (OPurchaseOrder)panel.SessionObject;
        if (po.CaseID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, po.CaseID))
                Window.OpenEditObjectPage(this, "OCase", po.CaseID.ToString(), "");
            else
                panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
        }
    }

    /// <summary>
    /// Opens a window to view the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewCase_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = (OPurchaseOrder)panel.SessionObject;
        if (po.CaseID != null)
        {
            Window.OpenViewObjectPage(this, "OCase", po.CaseID.ToString(), "");
        }
    }


    /// <summary>
    /// Populates the receipt item sub-panel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelReceiptItem_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseOrderReceiptItem receiptItem = subpanelReceiptItem.SessionObject as OPurchaseOrderReceiptItem;

        treeEquipmentParentID.PopulateTree();
        
        subpanelReceiptItem.ObjectPanel.BindObjectToControls(receiptItem);
    }



    /// <summary>
    /// Constructs and returns a equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipmentParentID_AcquireTreePopulater(object sender)
    {
        OPurchaseOrderReceiptItem receiptItem = subpanelReceiptItem.SessionObject as OPurchaseOrderReceiptItem;
        return new EquipmentTreePopulater(receiptItem.EquipmentParentID, true, true, "OStoreCheckIn");
    }

    
    /// <summary>
    /// Validates and updates the receipt item details.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelReceiptItem_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseOrderReceiptItem receiptItem = subpanelReceiptItem.SessionObject as OPurchaseOrderReceiptItem;
        subpanelReceiptItem.ObjectPanel.BindControlsToObject(receiptItem);

        panelReceiptItems.BindObjectToControls(PurchaseOrderReceipt_Subpanel.SessionObject);
        
    }

    
    /// <summary>
    /// Occurs when the user clicks a button in the invoice gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridInvoices_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditInvoice")
        {
            if (dataKeys.Count > 0)
            {
                Guid id = (Guid)dataKeys[0];
                Window.OpenEditObjectPage(Page, "OPurchaseInvoice", id.ToString(), "");
            }
        }
    }


    
    /// <summary>
    /// Occurs when the user types in something in the quantity
    /// delivered text box.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderReceiptItem_QuantityDelivered_TextChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        
        OPurchaseOrderReceipt por = this.PurchaseOrderReceipt_Subpanel.SessionObject as OPurchaseOrderReceipt;
        this.PurchaseOrderReceipt_Subpanel.ObjectPanel.BindControlsToObject(por);

        panelStore.Visible = po.IsReceivingMaterialItems(por);
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet"
        type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:object runat="server" ID="panel" Caption="Purchase Order"
            BaseTable="tPurchaseOrder" OnPopulateForm="panel_PopulateForm"
            meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details"
                    meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false"
                        ObjectNameVisible="false" ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIPanel runat="server" ID="panelDetails" meta:resourcekey="panelDetailsResource1">
                        <ui:UIPanel runat="server" ID="panelCase">
                            <ui:UIFieldSearchableDropDownList runat="server" ID="dropCase"
                                PropertyName="CaseID" Caption="Case" ContextMenuAlwaysEnabled="true">
                                <ContextMenuButtons>
                                    <ui:UIButton runat="server" ID="buttonEditCase" ImageUrl="~/images/edit.gif"
                                        Text="Edit Case" OnClick="buttonEditCase_Click" ConfirmText="Please remember to save this Purchase Order before editing the Case.\n\nAre you sure you want to continue?"
                                        AlwaysEnabled="true" />
                                    <ui:UIButton runat="server" ID="buttonViewCase" ImageUrl="~/images/view.gif"
                                        Text="View Case" OnClick="buttonViewCase_Click" ConfirmText="Please remember to save this Purchase Order before viewing the Case.\n\nAre you sure you want to continue?"
                                        AlwaysEnabled="true" />
                                </ContextMenuButtons>
                            </ui:UIFieldSearchableDropDownList>
                        </ui:UIPanel>
                        <ui:UISeparator ID="UISeparator4" runat="server" />
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location"
                            PropertyName="LocationID" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                            ValidateRequiredField="true">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment"
                            PropertyName="EquipmentID" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType"
                            Caption="Type" PropertyName="PurchaseTypeID" ValidateRequiredField="true"
                            OnSelectedIndexChanged="dropPurchaseType_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description"
                            PropertyName="Description" MaxLength="255" ValidateRequiredField="True"
                            meta:resourcekey="DescriptionResource1" />
                        <ui:UIFieldDateTime runat='server' ID="DateOfOrder" Caption="Date of PO"
                            ShowTimeControls="False" OnDateTimeChanged="DateOfOrder_DateTimeChanged"
                            PropertyName="DateOfOrder" ValidateRequiredField="True" Span="Half"
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            meta:resourcekey="DateOfOrderResource1" />
                        <ui:UIFieldDateTime runat='server' ID="DateRequired" Caption="Date Required"
                            ShowTimeControls="False" PropertyName="DateRequired" ValidateRequiredField="True"
                            Span="Half" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            meta:resourcekey="DateRequiredResource1" OnDateTimeChanged="DateRequired_DateTimeChanged" />
                        <ui:UIFieldDropDownList ID="StoreID" runat="server" Caption="Store"
                            Span="Half" PropertyName="StoreID" Enabled="false" meta:resourcekey="StoreIDResource1">
                        </ui:UIFieldDropDownList>
                        <br />
                        <br />
                        <br />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabVendor" Caption="Vendor"
                    meta:resourcekey="tabVendorResource1">
                    <ui:UIPanel runat="server" ID="panelTabVendor" meta:resourcekey="panelTabVendorResource1">
                        <ui:UISeparator ID="sep1" runat="server" Caption="Vendor" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldSearchableDropDownList runat="server" ID="ContractID" PropertyName="ContractID"
                            Caption="Contract" OnSelectedIndexChanged="ContractID_SelectedIndexChanged"
                            meta:resourcekey="ContractIDResource1">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldSearchableDropDownList runat="server" ID="VendorID" PropertyName="VendorID"
                            Caption="Vendor" OnSelectedIndexChanged="VendorID_SelectedIndexChanged"
                            meta:resourcekey="VendorIDResource1">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIPanel runat="server" ID="panelVendor" meta:resourcekey="panelVendorResource1">
                            <ui:UIFieldTextBox runat="server" ID="ContactAddressCountry"
                                PropertyName="ContactAddressCountry" Caption="Country" Span="Half"
                                meta:resourcekey="ContactAddressCountryResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactAddressState" PropertyName="ContactAddressState"
                                Caption="State" Span="Half" meta:resourcekey="ContactAddressStateResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactAddressCity" PropertyName="ContactAddressCity"
                                Caption="City" Span="Half" meta:resourcekey="ContactAddressCityResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactAddress" PropertyName="ContactAddress"
                                Caption="Address" MaxLength="255" meta:resourcekey="ContactAddressResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactCellPhone" PropertyName="ContactCellPhone"
                                Caption="Cellphone" Span="Half" meta:resourcekey="ContactCellPhoneResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactEmail" PropertyName="ContactEmail"
                                Caption="Email" Span="Half" meta:resourcekey="ContactEmailResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactFax" PropertyName="ContactFax"
                                Caption="Fax" Span="Half" meta:resourcekey="ContactFaxResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactPhone" PropertyName="ContactPhone"
                                Caption="Phone" Span="Half" meta:resourcekey="ContactPhoneResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContactPerson" PropertyName="ContactPerson"
                                Caption="Contact Person" meta:resourcekey="ContactPersonResource1" />
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <ui:UISeparator ID="UISeparator2" runat="server" Caption="Currency" />
                    <ui:UIPanel runat="server" ID="panelCurrency">
                        <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID"
                            Caption="Main Currency" OnSelectedIndexChanged="dropCurrency_SelectedIndexChanged"
                            ValidateRequiredField="true">
                        </ui:UIFieldDropDownList>
                        <table cellpadding='0' cellspacing='0' border='0' style="clear: both;
                            width: 50%">
                            <tr runat="server" id="rowExchangeRate" style="height: 25px"
                                class='field-required'>
                                <td style='width: 120px'>
                                    <asp:Label runat="server" ID="labelExchangeRate">Exchange Rate*:</asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelER1">1</asp:Label>
                                    <ui:UIFieldLabel runat="server" ID="labelERThisCurrency" ShowCaption="false"
                                        FieldLayout="Flow" InternalControlWidth="20px" PropertyName="Currency.ObjectName">
                                    </ui:UIFieldLabel>
                                    <asp:Label runat="server" ID="labelEREquals">is equal to</asp:Label>
                                    <ui:UIFieldTextBox runat="serveR" ID="textForeignToBaseExchangeRate"
                                        PropertyName="ForeignToBaseExchangeRate" Caption="Exchange Rate"
                                        Span="half" ValidateRequiredField="true" ValidateDataTypeCheck="true"
                                        ValidationDataType="Currency" FieldLayout="Flow" InternalControlWidth="60px"
                                        ShowCaption="false" OnTextChanged="textForeignToBaseExchangeRate_TextChanged" />
                                    <asp:Label runat="server" ID="labelERBaseCurrency"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTerms" Caption="Terms" meta:resourcekey="tabTermsResource1">
                    <ui:UIPanel runat="server" ID="panelTerms" meta:resourcekey="panelTermsResource1">
                        <ui:UISeparator ID="Terms" runat="server" Caption="Terms" meta:resourcekey="TermsResource2" />
                        <ui:UIFieldTextBox runat="server" ID="FreightTerms" PropertyName="FreightTerms"
                            Caption="Freight Terms" TextMode="MultiLine" Rows="3" meta:resourcekey="FreightTermsResource1" />
                        <ui:UIFieldTextBox runat="server" ID="PaymentTerms" PropertyName="PaymentTerms"
                            Caption="Payment Terms" TextMode="MultiLine" Rows="3" meta:resourcekey="PaymentTermsResource1" />
                        <br />
                        <br />
                        <br />
                        <ui:UISeparator ID="UISeparator1" runat="server" Caption="Address"
                            meta:resourcekey="UISeparator1Resource1" />
                        <table style="width: 100%" cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel1" runat="server" meta:resourcekey="Panel1Resource1">
                                        <asp:Label ID="Label1" runat="server" Font-Bold="True" Text="Ship To:"
                                            meta:resourcekey="Label1Resource1"></asp:Label><br />
                                        <ui:UIFieldTextBox ID="ShipToAddress" runat="server" Caption="Address"
                                            Rows="4" TextMode="MultiLine" PropertyName="ShipToAddress"
                                            meta:resourcekey="ShipToAddressResource1" />
                                        <ui:UIFieldTextBox ID="ShipToAttention" runat="server" Caption="Attention"
                                            PropertyName="ShipToAttention" meta:resourcekey="ShipToAttentionResource1" />
                                    </ui:UIPanel>
                                </td>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel2" runat="server" meta:resourcekey="Panel2Resource1">
                                        <asp:Label ID="Label2" runat="server" Font-Bold="True" Text="Bill To:"
                                            meta:resourcekey="Label2Resource1"></asp:Label><br />
                                        <ui:UIFieldTextBox ID="BillToAddress" runat="server" Caption="Address"
                                            Rows="4" TextMode="MultiLine" PropertyName="BillToAddress"
                                            meta:resourcekey="BillToAddressResource1" />
                                        <ui:UIFieldTextBox ID="BillToAttention" runat="server" Caption="Attention"
                                            PropertyName="BillToAttention" meta:resourcekey="BillToAttentionResource1" />
                                    </ui:UIPanel>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabLineItems" Caption="Line Items"
                    meta:resourcekey="tabLineItemsResource1">
                    <ui:UIPanel runat="server" ID="PurchaseOrderItemPanel" meta:resourcekey="PurchaseOrderItemPanelResource1">
                        <ui:UIButton runat="server" ID="buttonAddMaterialItems" Text="Add Multiple Inventory Items"
                            ImageUrl="~/images/add.gif" OnClick="buttonAddMaterialItems_Click"
                            OnPopupReturned="addMaterialItems_PopupReturned" CausesValidation="false" />
                        <ui:UIButton runat="server" ID="buttonAddFixedRateItems" Text="Add Multiple Service Items"
                            ImageUrl="~/images/add.gif" OnClick="buttonAddFixedRateItems_Click"
                            CausesValidation="false" />
                        <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="false"
                            OnClick="buttonItemsAdded_Click"></ui:UIButton>
                        <br />
                        <br />
                        <ui:UIGridView ID="PurchaseOrderItems" runat="server" Caption="Items"
                            PropertyName="PurchaseOrderItems" SortExpression="ItemNumber"
                            KeyName="ObjectID" meta:resourcekey="PurchaseOrderItemsResource1"
                            Width="100%" AllowPaging="True" AllowSorting="True" PagingEnabled="True"
                            ShowFooter="true">
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                    meta:resourcekey="UIGridViewCommandResource1"></ui:UIGridViewCommand>
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif"
                                    CommandName="AddObject" meta:resourcekey="UIGridViewCommandResource2">
                                </ui:UIGridViewCommand>
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                    HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to delete this item?"
                                    CommandName="DeleteObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Number" PropertyName="ItemNumber"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Type" PropertyName="ItemTypeText"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Description" PropertyName="ItemDescription"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Unit of Measure" PropertyName="UnitOfMeasure.ObjectName"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Receipt Mode" PropertyName="ReceiptModeText">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Currency" PropertyName="Currency.ObjectName">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Unit Price" PropertyName="UnitPriceInSelectedCurrency"
                                    DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Unit Price<br/>(Base Currency)"
                                    HtmlEncode="false" PropertyName="UnitPrice" DataFormatString="{0:c}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Quantity" PropertyName="QuantityOrdered"
                                    DataFormatString="{0:#,##0.00##}" meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Subtotal<br/>(Base Currency)"
                                    HtmlEncode="false" PropertyName="Subtotal" DataFormatString="{0:c}"
                                    FooterAggregate="Sum">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Quantity Delivered" PropertyName="QuantityDelivered"
                                    DataFormatString="{0:#,##0.00##}" meta:resourcekey="UIGridViewColumnResource10">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Copied From" PropertyName="CopiedFromObjectNumber"
                                    meta:resourcekey="UIGridViewColumnResource11">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="PurchaseOrderItem_Panel" runat="server"
                            meta:resourcekey="PurchaseOrderItem_PanelResource1">
                            <web:subpanel runat="server" ID="PurchaseOrderItem_SubPanel"
                                GridViewID="PurchaseOrderItems" OnRemoved="PurchaseOrderItem_SubPanel_Removed"
                                OnPopulateForm="PurchaseOrderItem_SubPanel_PopulateForm"
                                MultiSelectColumnNames="ItemNumber,ItemType,FixedRateID,CatalogueID,UnitPrice,QuantityOrdered"
                                OnValidateAndUpdate="PurchaseOrderItem_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldDropDownList ID="ItemNumber" runat="server" Caption="Item Number"
                                PropertyName="ItemNumber" Span="Half" ValidateRequiredField="True"
                                meta:resourcekey="ItemNumberResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldRadioList ID="ItemType" runat="server" Caption="Item Type"
                                PropertyName="ItemType" RepeatColumns="0" OnSelectedIndexChanged="ItemType_SelectedIndexChanged"
                                ValidateRequiredField="True" meta:resourcekey="ItemTypeResource1">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource1"
                                        Text="Material">
                                    </asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource2"
                                        Text="Service">
                                    </asp:ListItem>
                                    <asp:ListItem Value="2" meta:resourcekey="ListItemResource3">Others</asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldTreeList ID="CatalogueID" runat="server" Caption="Catalog"
                                PropertyName="CatalogueID" OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater"
                                OnSelectedNodeChanged="CatalogueID_SelectedNodeChanged" ValidateRequiredField="True"
                                meta:resourcekey="CatalogueIDResource1">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate"
                                PropertyName="FixedRateID" OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater"
                                OnSelectedNodeChanged="FixedRateID_SelectedNodeChanged" ValidateRequiredField="True"
                                meta:resourcekey="FixedRateIDResource1">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldLabel runat="server" ID="UnitOfMeasure" Caption="Unit of Measure"
                                PropertyName="Catalogue.UnitOfMeasure.ObjectName" meta:resourcekey="UnitOfMeasureResource1" />
                            <ui:UIFieldLabel runat="server" ID="UnitOfMeasure2" Caption="Unit of Measure"
                                PropertyName="FixedRate.UnitOfMeasure.ObjectName" meta:resourcekey="UnitOfMeasure2Resource1" />
                            <ui:UIFieldTextBox ID="ItemDescription" runat="server" Caption="Description"
                                PropertyName="ItemDescription" MaxLength="255" ValidateRequiredField="True"
                                meta:resourcekey="ItemDescriptionResource1" />
                            <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" Caption="Unit of Measure"
                                PropertyName="UnitOfMeasureID" meta:resourcekey="UnitOfMeasureIDResource1" />
                            <ui:UIFieldRadioList runat="server" ID="radioReceiptMode" PropertyName="ReceiptMode"
                                Caption="Receipt Mode" OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged">
                                <Items>
                                    <asp:ListItem Value="0">Receive by Quantity</asp:ListItem>
                                    <asp:ListItem Value="1">Receive by Dollar Amount</asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldTextBox ID="UnitPrice" runat="server" Caption="Unit Price"
                                PropertyName="UnitPriceInSelectedCurrency" Span="Half" ValidateDataTypeCheck="True"
                                ValidateRangeField="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                ValidationRangeType="Currency" meta:resourcekey="UnitPriceResource1" />
                            <ui:UIFieldTextBox ID="QuantityOrdered" runat="server" Caption="Quantity"
                                PropertyName="QuantityOrdered" Span="Half" ValidateDataTypeCheck="True"
                                ValidateRangeField="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                ValidationRangeType="Currency" meta:resourcekey="QuantityOrderedResource1" />
                        </ui:UIObjectPanel>
                        <br />
                        <ui:UIHint runat="server" ID="hintRFQToPOPolicy" ImageUrl="~/images/error.gif"></ui:UIHint>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabBudget" Caption="Budget">
                    <ui:UIFieldRadioList runat="server" ID="radioBudgetDistributionMode"
                        PropertyName="BudgetDistributionMode" Caption="Budget Distribution"
                        ValidateRequiredField="true" OnSelectedIndexChanged="radioBudgetDistributionMode_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Value="0">By entire Purchase Order</asp:ListItem>
                            <asp:ListItem Value="1">By individual Purchase Order items</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIGridView runat="server" ID="gridBudget" PropertyName="PurchaseBudgets"
                        Caption="Budgets" ShowFooter="true" PageSize="50">
                        <Commands>
                            <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" CommandName="DeleteObject">
                            </ui:UIGridViewCommand>
                            <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif"
                                CommandName="AddObject"></ui:UIGridViewCommand>
                        </Commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to delete this item?"
                                CommandName="DeleteObject" HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ItemNumber" HeaderText="Number">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" HeaderText="Budget">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.Path" HeaderText="Account">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.AccountCode"
                                HeaderText="Account Code">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="StartDate" HeaderText="Start Date"
                                DataFormatString="{0:dd-MMM-yyyy}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="EndDate" HeaderText="End Date"
                                DataFormatString="{0:dd-MMM-yyyy}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="AccrualFrequencyInMonths"
                                HeaderText="Accrual Frequency (in months)">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Amount" HeaderText="Amount"
                                DataFormatString="{0:c}" FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="panelBudget">
                        <web:subpanel runat="server" ID="subpanelBudget" GridViewID="gridBudget"
                            OnPopulateForm="subpanelBudget_PopulateForm" OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate"
                            OnRemoved="subpanelBudget_Removed" />
                        <ui:UIFieldDropDownList runat="server" ID="dropItemNumber" PropertyName="ItemNumber"
                            Caption="Item Number" ValidateRequiredField="true">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="dropBudget" PropertyName="BudgetID"
                            Caption="Budget" ValidateRequiredField="true" OnSelectedIndexChanged="dropBudget_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate"
                            Caption="Start Date" Span="Half" ValidateRequiredField="true"
                            ValidateCompareField="true"
                            ValidationCompareControl="dateEndDate" ValidationCompareOperator="LessThanEqual" ValidationCompareType="Date"
                            OnDateTimeChanged="dateStartDate_DateTimeChanged">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="dateEndDate" PropertyName="EndDate"
                            ValidateCompareField="true"
                            ValidationCompareControl="dateStartDate" ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date"
                            Caption="End Date" Span="Half" ValidateRequiredField="true">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTextBox runat="server" ID="textAccrualFrequency" PropertyName="AccrualFrequencyInMonths"
                            Caption="Accrual Frequency (months)" Span="Half" ValidateRequiredField="true"
                            ValidateRangeField="true" ValidationRangeMin="1" ValidationRangeMinInclusive="true"
                            ValidationRangeType="Currency">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTreeList runat="server" ID="treeAccount" PropertyName="AccountID"
                            Caption="Account" ValidateRequiredField="true" OnAcquireTreePopulater="treeAccount_AcquireTreePopulater">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat="server" ID="textAmount" PropertyName="Amount"
                            Caption="Amount" Span="Half" ValidateRequiredField="true"
                            ValidationRangeMin="1" ValidationRangeMinInclusive="true"
                            ValidationRangeType="Currency">
                        </ui:UIFieldTextBox>
                    </ui:UIObjectPanel>
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="gridBudgetSummary" PropertyName="PurchaseBudgetSummaries"
                        Caption="Budget Summary" CheckBoxColumnVisible="false" ShowFooter="true"
                        PageSize="50" OnAction="gridBudgetSummary_Action">
                        <Columns>
                            <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" HeaderText="Budget">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="BudgetPeriod.ObjectName"
                                HeaderText="Budget Period">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/printer.gif" CommandName="ViewBudget"
                                AlwaysEnabled="true">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.ObjectName" HeaderText="Account">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.AccountCode"
                                HeaderText="Account Code">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableAdjusted"
                                HeaderText="Total After Adjustments" DataFormatString="{0:c}"
                                FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableBeforeSubmission"
                                HeaderText="Total Before Submission" DataFormatString="{0:c}"
                                FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableAtSubmission"
                                HeaderText="Total At Submission" DataFormatString="{0:c}"
                                FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableAfterApproval"
                                HeaderText="Total After Approval" DataFormatString="{0:c}"
                                FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabReceipt" Caption="Receipt"
                    meta:resourcekey="tabReceiptResource1">
                    <ui:UIPanel runat="server" ID="panelAddReceipt" meta:resourcekey="panelAddReceiptResource1">
                        <ui:UIButton runat="server" ID="buttonAddReceipt" Text="Receive Items"
                            ImageUrl="~/images/add.gif" OnClick="buttonAddReceipt_Click"
                            meta:resourcekey="buttonAddReceiptResource1" />
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelSaveTip" meta:resourcekey="panelSaveTipResource1">
                        <asp:Image runat="server" ID="imageSaveTip" ImageUrl="~/images/information.png"
                            ImageAlign="AbsMiddle" meta:resourcekey="imageSaveTipResource1" />
                        <asp:Label runat="server" ID="labelSaveTip" Text="Please save this Purchase Order to commit the receipt."
                            meta:resourcekey="labelSaveTipResource1"></asp:Label>
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIGridView ID="PurchaseOrderReceipts" runat="server" Caption="Receipts"
                        PropertyName="PurchaseOrderReceipts" KeyName="ObjectID" meta:resourcekey="PurchaseOrderReceiptsResource1"
                        Width="100%" AllowPaging="True" AllowSorting="True" PagingEnabled="True">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="EditObject"
                                HeaderText="" meta:resourcekey="UIGridViewColumnResource12">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Date of Receipt" PropertyName="DateOfReceipt"
                                DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewColumnResource13">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Store" PropertyName="Store.ObjectName"
                                meta:resourcekey="UIGridViewColumnResource14">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Store Bin" PropertyName="StoreBin.ObjectName"
                                meta:resourcekey="UIGridViewColumnResource15">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="DO Number" PropertyName="DeliveryOrderNumber"
                                meta:resourcekey="UIGridViewColumnResource16">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Description" PropertyName="Description"
                                meta:resourcekey="UIGridViewColumnResource17">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="PurchaseOrderReceipt_Panel" runat="server"
                        meta:resourcekey="PurchaseOrderReceipt_PanelResource1">
                        <web:subpanel runat="server" ID="PurchaseOrderReceipt_Subpanel"
                            GridViewID="PurchaseOrderReceipts" UpdateAndNewButtonVisible="false"
                            CancelVisible="true" OnPopulateForm="PurchaseOrderReceipt_SubPanel_PopulateForm"
                            OnValidateAndUpdate="PurchaseOrderReceipt_Subpanel_ValidateAndUpdate" />
                        <ui:UIPanel runat="server" ID="panelPurchaseOrderReceipt" meta:resourcekey="panelPurchaseOrderReceiptResource1">
                            <ui:UIFieldDateTime ID="UIFieldDateTime1" runat="server" Caption="Date of Receipt"
                                PropertyName="DateOfReceipt" ValidateRequiredField="True"
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                                meta:resourcekey="UIFieldDateTime1Resource1" ShowTimeControls="False" />
                            <ui:UIPanel runat="server" ID="panelStore" meta:resourcekey="panelStoreResource1">
                                <ui:UIFieldDropDownList runat="server" ID="dropStore" Caption="Store"
                                    PropertyName="StoreID" Span="half" OnSelectedIndexChanged="dropStore_SelectedIndexChanged"
                                    ValidateRequiredField="true">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList ID="dropStoreBin" runat="server" Caption="Store Bin"
                                    ValidateRequiredField="true" Span="Half" PropertyName="StoreBinID"
                                    meta:resourcekey="PurchaseOrderReceipt_StoreBinIDResource1">
                                </ui:UIFieldDropDownList>
                            </ui:UIPanel>
                            <ui:UIFieldTextBox ID="PurchaseOrderReceipt_DeliveryOrderNumber"
                                runat="server" Caption="DO Number" Span="Full" PropertyName="DeliveryOrderNumber"
                                meta:resourcekey="PurchaseOrderReceipt_DeliveryOrderNumberResource1" />
                            <ui:UIFieldTextBox ID="PurchaseOrderReceipt_Description" runat="server"
                                Caption="Description" PropertyName="Description" MaxLength="255"
                                meta:resourcekey="PurchaseOrderReceipt_DescriptionResource1" />
                            <br />
                            <br />
                            <ui:UIPanel runat="server" ID="panelReceiptItems">
                                <ui:UIGridView ID="PurchaseOrderReceiptItems" runat="server"
                                    Caption="Receipt Items" CheckBoxColumnVisible="false" PropertyName="PurchaseOrderReceiptItems"
                                    BindObjectsToRows="True" KeyName="ObjectID" SortExpression="PurchaseOrderItem.ItemNumber"
                                    meta:resourcekey="PurchaseOrderReceiptItemsResource1" Width="100%"
                                    AllowPaging="True" AllowSorting="True" PagingEnabled="True"
                                    OnRowDataBound="PurchaseOrderReceiptItems_RowDataBound">
                                    <Columns>
                                        <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" AlwaysEnabled="true" CommandName="EditObject">
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="#" PropertyName="PurchaseOrderItem.ItemNumber"
                                            meta:resourcekey="UIGridViewColumnResource18">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Item Type" PropertyName="PurchaseOrderItem.ItemTypeText"
                                            meta:resourcekey="UIGridViewColumnResource19">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Description" PropertyName="PurchaseOrderItem.ItemDescription"
                                            meta:resourcekey="UIGridViewColumnResource20">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Receipt Mode" PropertyName="PurchaseOrderItem.ReceiptModeText">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="PurchaseOrderItem.ReceiptMode"
                                            Visible="false">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="EquipmentName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="EquipmentParent.Path">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Quantity Ordered" PropertyName="PurchaseOrderItem.QuantityOrdered"
                                            DataFormatString="{0:#,##0.00##}" meta:resourcekey="UIGridViewColumnResource21">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Quantity Received" HeaderStyle-Width="120px"
                                            meta:resourcekey="UIGridViewColumnResource22">
                                            <ItemTemplate>
                                                <ui:UIFieldTextBox runat="server" ID="PurchaseOrderReceiptItem_QuantityDelivered"
                                                    FieldLayout="Flow" ShowCaption="false" CaptionWidth="1px"
                                                    Caption="Quantity Received" PropertyName="QuantityDelivered"
                                                    OnTextChanged="PurchaseOrderReceiptItem_QuantityDelivered_TextChanged" 
                                                    ValidateRequiredField="True" ValidateDataTypeCheck="True"
                                                    ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMax="99999999999999"
                                                    ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="PurchaseOrderReceiptItem_QuantityDeliveredResource1" />
                                            </ItemTemplate>
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Unit Price / Dollar Amount Received"
                                            HeaderStyle-Width="120px">
                                            <ItemTemplate>
                                                <ui:UIFieldTextBox runat="server" ID="PurchaseOrderReceiptItem_UnitPrice"
                                                    FieldLayout="Flow" ShowCaption="false" CaptionWidth="1px"
                                                    Caption="Unit Price Received" PropertyName="UnitPrice" ValidateRequiredField="True"
                                                    ValidateDataTypeCheck="True" ValidationDataType="Currency"
                                                    ValidateRangeField="True" ValidationRangeMax="99999999999999"
                                                    ValidationRangeMin="0" ValidationRangeType="Currency" />
                                            </ItemTemplate>
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Lot Number" HeaderStyle-Width="200px"
                                            meta:resourcekey="UIGridViewColumnResource23">
                                            <ItemTemplate>
                                                <ui:UIFieldTextBox runat='server' ID="PurchaseOrderReceiptItem_LotNumber"
                                                    PropertyName="LotNumber" FieldLayout="Flow" ShowCaption="false"
                                                    Caption="Lot Number" CaptionWidth="1px" meta:resourcekey="PurchaseOrderReceiptItem_LotNumberResource1" />
                                            </ItemTemplate>
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Expiry Date" HeaderStyle-Width="200px"
                                            meta:resourcekey="UIGridViewColumnResource24">
                                            <ItemTemplate>
                                                <ui:UIFieldDateTime runat='server' ID="PurchaseOrderReceiptItem_ExpiryDate"
                                                    PropertyName="ExpiryDate" FieldLayout="Flow" ShowCaption="false"
                                                    Caption="Expiry Date" CaptionWidth="1px" ImageClearUrl="~/calendar/dateclr.gif"
                                                    ImageUrl="~/calendar/date.gif" meta:resourcekey="PurchaseOrderReceiptItem_ExpiryDateResource1"
                                                    ShowTimeControls="False" />
                                            </ItemTemplate>
                                        </ui:UIGridViewTemplateColumn>
                                    </Columns>
                                </ui:UIGridView>
                                <ui:UIObjectPanel runat="server" ID="panelReceiptItem">
                                    <web:subpanel runat="server" ID="subpanelReceiptItem" OnPopulateForm="subpanelReceiptItem_PopulateForm"
                                        OnValidateAndUpdate="subpanelReceiptItem_ValidateAndUpdate"
                                        GridViewID="PurchaseOrderReceiptItems" />
                                    <ui:UIPanel runat="server" ID="panelEquipment">
                                        <ui:UIFieldTextBox runat="server" ID="textEquipmentName" Caption="Equipment Name"
                                            PropertyName="EquipmentName" ValidateRequiredField="true">
                                        </ui:UIFieldTextBox>
                                        <ui:UIFieldTreeList runat="server" ID="treeEquipmentParentID"
                                            Caption="Belongs Under" PropertyName="EquipmentParentID"
                                            OnAcquireTreePopulater="treeEquipmentParentID_AcquireTreePopulater"
                                            ValidateRequiredField="true">
                                        </ui:UIFieldTreeList>
                                        <ui:UIFieldTextBox runat="server" ID="textEquipmentModelNumber"
                                            Span="Half" Caption="Model Number" PropertyName="EquipmentModelNumber">
                                        </ui:UIFieldTextBox>
                                        <ui:UIFieldTextBox runat="server" ID="textEquipmentSerialNumber"
                                            Span="Half" Caption="Serial Number" PropertyName="EquipmentSerialNumber">
                                        </ui:UIFieldTextBox>
                                        <ui:UIFieldTextBox runat="server" ID="textEquipmentBarcode" Caption="Barcode"
                                            PropertyName="EquipmentBarcode">
                                        </ui:UIFieldTextBox>
                                        <ui:UIFieldDateTime runat="server" ID="textEquipmentWarrantyExpiryDate"
                                            Span="Half" Caption="Warranty Expiry Date" PropertyName="EquipmentWarrantyExpiryDate">
                                        </ui:UIFieldDateTime>
                                        <ui:UIFieldDateTime runat="server" ID="textEquipmentDateOfManufacture" Span="Half"
                                            Caption="Date of Manufacture" PropertyName="EquipmentDateOfManufacture">
                                        </ui:UIFieldDateTime>
                                    </ui:UIPanel>
                                </ui:UIObjectPanel>
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabInvoice" Caption="Invoice">
                    <ui:UIPanel runat="server" ID="panelInvoiceMatchToReceipt">
                        <ui:UIGridView runat="server" ID="gridReceipts" Caption="Receipts">
                        </ui:UIGridView>
                        <br />
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelInvoiceMatchToPO">
                        <ui:UIButton runat="server" ID="buttonAddInvoice" Text="Add Invoice"
                            ImageUrl="~/images/add.gif" OnClick="buttonAddInvoice_Click"
                            ConfirmText="Are you sure you wish to add an invoice? Please remember to save the Purchase Order, otherwise changes that you have made will be lost." />
                        <ui:UIButton runat="server" ID="buttonAddCreditMemo" Text="Add Credit Memo"
                            ImageUrl="~/images/add.gif" OnClick="buttonAddCreditMemo_Click"
                            ConfirmText="Are you sure you wish to add an credit memo? Please remember to save the Purchase Order, otherwise changes that you have made will be lost." />
                        <ui:UIButton runat="server" ID="buttonAddDebitMemo" Text="Add Debit Memo"
                            ImageUrl="~/images/add.gif" OnClick="buttonAddDebitMemo_Click"
                            ConfirmText="Are you sure you wish to add an debit memo? Please remember to save the Purchase Order, otherwise changes that you have made will be lost." />
                    </ui:UIPanel>
                    <ui:UIGridView runat="server" ID="gridInvoices" Caption="Invoices"
                        OnRowDataBound="gridInvoices_RowDataBound" OnAction="gridInvoices_Action">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditInvoice" ConfirmText="Are you sure you wish to edit this invoice? Please remember to save the Purchase Order, otherwise changes that you have made will be lost.">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Invoice Number">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="InvoiceTypeText" HeaderText="Invoice Type">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="DateOfInvoice" HeaderText="Date of Invoice"
                                DataFormatString="{0:dd-MMM-yyyy}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Currency.ObjectName"
                                HeaderText="Currency" ItemStyle-ForeColor="#777777">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Currency.CurrencySymbol"
                                HeaderText="" ItemStyle-ForeColor="#777777">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAmountInSelectedCurrency"
                                HeaderText="Net Amount" ItemStyle-ForeColor="#777777" DataFormatString="{0:n}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalTaxInSelectedCurrency"
                                HeaderText="Tax" ItemStyle-ForeColor="#777777" DataFormatString="{0:n}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAmount" HeaderText="Net Amount<br/>(in Base Currency)"
                                HtmlEncode="false" DataFormatString="{0:c}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalTax" HeaderText="Tax<br/>(in Base Currency)"
                                HtmlEncode="false" DataFormatString="{0:c}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAmountAndTax" HeaderText="Gross"
                                DataFormatString="{0:c}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName"
                                HeaderText="Status" ResourceName="Resources.WorkflowStates">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabWorkHistory" Caption="Status History">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments"
                    meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
