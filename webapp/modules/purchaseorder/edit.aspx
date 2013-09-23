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

        if (purchaseOrder.IsNew)
            purchaseOrder.DateOfOrder = DateTime.Today;

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
            !purchaseOrder.CurrentActivity.ObjectName.Is("PendingApproval", "Completed", "PendingReceipt", "Closed", "Cancelled"))
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

        // Set access control for the buttons
        //
        if (purchaseOrder.GeneratedTermContractID != null)
        {
            buttonViewContract.Visible = AppSession.User.AllowViewAll("OContract");
            buttonEditContract.Visible = AppSession.User.AllowEditAll("OContract") || OActivity.CheckAssignment(AppSession.User, purchaseOrder.GeneratedTermContractID);
        }
        else
        {
            buttonViewContract.Visible = false;
            buttonEditContract.Visible = false;
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

            if (objectBase.SelectedAction == "Close")
            {
                // Ensures that all invoices have been closed or cancelled before
                // this PO can be closed.
                //
                if (!purchaseOrder.ValidateInvoicesClosedOrCancelled())
                    gridInvoices.ErrorMessage = Resources.Errors.PurchaseOrder_InvoicesNotClosedOrCancelled;
            }
            

            if (objectBase.CurrentObjectState == "PendingReceipt")
            {
                string bin = purchaseOrder.ValidateStoreBinNotLocked();
                if (bin != "")
                {
                    this.PurchaseOrderReceipts.ErrorMessage = String.Format(Resources.Errors.PurchaseOrder_StoreBinsLocked, bin);
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
        return new LocationTreePopulater(po.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
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

        treeLocation.Enabled = gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;
        
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
        QuantityOrdered.Enabled = radioReceiptMode.SelectedValue == "0";
        tabBudget.Visible = treeLocation.SelectedItem != "" && DateRequired.DateTime != null &&
            po.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;
        gridBudget.Visible = radioBudgetDistributionMode.SelectedValue != "";
        radioBudgetDistributionMode.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        dropItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == "1";
        gridBudgetSummary.Visible = gridBudgetSummary.Rows.Count > 0;
        panelInvoiceMatchToPO.Enabled = po.CurrentActivity.ObjectName != "Close" && po.CurrentActivity.ObjectName != "Cancelled";
        panelInvoiceMatchToReceipt.Visible = false;
        ItemType.Items[0].Enabled = !checkIsTermContract.Checked;
        checkIsTermContract.Enabled = PurchaseOrderItems.Rows.Count == 0 && !this.PurchaseOrderItem_SubPanel.Visible && po.StoreID == null;

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
        tabInvoice.Visible = objectBase.CurrentObjectState.Is("PendingReceipt", "Completed", "Close");
        tabReceipt.Visible = objectBase.CurrentObjectState.Is("PendingReceipt", "Completed", "Cancelled", "Close");
        tabReceipt.Enabled = objectBase.CurrentObjectState.Is("PendingReceipt");

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
            prBudget.EndDate = po.DateEnd;
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
        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);
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
        if (!checkIsTermContract.Checked)
            DateEnd.DateTime = DateRequired.DateTime;
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
            e.Row.Cells[8].Text = e.Row.Cells[7].Text + e.Row.Cells[8].Text;
            e.Row.Cells[9].Text = e.Row.Cells[7].Text + e.Row.Cells[9].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[7].Visible = false;
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


    /// <summary>
    /// Occurs when the user clicks on the term contract checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkIsTermContract_CheckedChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Opens a window to edit the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditContract_Click(object sender, EventArgs e)
    {
        OPurchaseOrder o = (OPurchaseOrder)panel.SessionObject;
        if (o.GeneratedTermContractID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, o.GeneratedTermContractID))
                Window.OpenEditObjectPage(this, "OContract", o.GeneratedTermContractID.ToString(), "");
            else
                panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
        }
    }

    /// <summary>
    /// Opens a window to view the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewContract_Click(object sender, EventArgs e)
    {
        OPurchaseOrder o = (OPurchaseOrder)panel.SessionObject;
        if (o.GeneratedTermContractID != null)
        {
            Window.OpenViewObjectPage(this, "OContract", o.GeneratedTermContractID.ToString(), "");
        }
    }    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet"
        type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BeginningHtml="" BorderStyle="NotSet" EndingHtml="" >
        <web:object runat="server" ID="panel" Caption="Purchase Order"
            BaseTable="tPurchaseOrder" OnPopulateForm="panel_PopulateForm"
            meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:uitabstrip id="tabObject" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="tabObjectResource1">
                <ui:uitabview id="tabDetails" runat="server" beginninghtml="" borderstyle="NotSet" caption="Details" endinghtml="" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" ObjectNameVisible="false" ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false" />
                    <ui:uipanel id="panelDetails" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelDetailsResource1">
                        <ui:uipanel id="panelCase" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelCaseResource1">
                            <ui:uifieldsearchabledropdownlist id="dropCase" runat="server" caption="Case" contextmenualwaysenabled="True" meta:resourcekey="dropCaseResource1" propertyname="CaseID" searchinterval="300">
                                <contextmenubuttons>
                                    <ui:uibutton id="buttonEditCase" runat="server" alwaysenabled="True" confirmtext="Please remember to save this Purchase Order before editing the Case.\n\nAre you sure you want to continue?" imageurl="~/images/edit.gif" meta:resourcekey="buttonEditCaseResource1" onclick="buttonEditCase_Click" text="Edit Case" />
                                    <ui:uibutton id="buttonViewCase" runat="server" alwaysenabled="True" confirmtext="Please remember to save this Purchase Order before viewing the Case.\n\nAre you sure you want to continue?" imageurl="~/images/view.gif" meta:resourcekey="buttonViewCaseResource1" onclick="buttonViewCase_Click" text="View Case" />
                                </contextmenubuttons>
                            </ui:uifieldsearchabledropdownlist>
                        </ui:uipanel>
                        <ui:uiseparator id="UISeparator4" runat="server" meta:resourcekey="UISeparator4Resource1" />
                        <ui:uifieldtreelist id="treeLocation" runat="server" caption="Location" meta:resourcekey="treeLocationResource1" onacquiretreepopulater="treeLocation_AcquireTreePopulater" onselectednodechanged="treeLocation_SelectedNodeChanged" propertyname="LocationID" showcheckboxes="None" treevaluemode="SelectedNode" validaterequiredfield="True">
                        </ui:uifieldtreelist>
                        <ui:uifieldtreelist id="treeEquipment" runat="server" caption="Equipment" meta:resourcekey="treeEquipmentResource1" onacquiretreepopulater="treeEquipment_AcquireTreePopulater" onselectednodechanged="treeEquipment_SelectedNodeChanged" propertyname="EquipmentID" showcheckboxes="None" treevaluemode="SelectedNode">
                        </ui:uifieldtreelist>
                        <ui:uifielddropdownlist id="dropPurchaseType" runat="server" caption="Type" meta:resourcekey="dropPurchaseTypeResource1" onselectedindexchanged="dropPurchaseType_SelectedIndexChanged" propertyname="PurchaseTypeID" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uifieldtextbox id="Description" runat="server" caption="Description" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="DescriptionResource1" propertyname="Description" validaterequiredfield="True">
                        </ui:uifieldtextbox>
                        <ui:uifielddatetime id="DateOfOrder" runat="server" caption="Date of PO" imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" meta:resourcekey="DateOfOrderResource1" ondatetimechanged="DateOfOrder_DateTimeChanged" propertyname="DateOfOrder" showdatecontrols="True" validaterequiredfield="True">
                        </ui:uifielddatetime>
                        <ui:uifieldcheckbox id="checkIsTermContract" runat="server" caption="Term Contract?" meta:resourcekey="checkIsTermContractResource1" oncheckedchanged="checkIsTermContract_CheckedChanged" propertyname="IsTermContract" text="Yes, this Purchase Order is for a term contract." textalign="Right">
                        </ui:uifieldcheckbox>
                        <ui:uifieldlabel id="labelTermContract" runat="server" caption="Generated Contract" contextmenualwaysenabled="True" dataformatstring="" meta:resourcekey="labelTermContractResource1" propertyname="GeneratedTermContract.ObjectNumber">
                            <contextmenubuttons>
                                <ui:uibutton id="buttonEditContract" runat="server" alwaysenabled="True" confirmtext="Please remember to save this Purchase Order before editing the Contract.\n\nAre you sure you want to continue?" imageurl="~/images/edit.gif" meta:resourcekey="buttonEditContractResource1" onclick="buttonEditContract_Click" text="Edit Contract" />
                                <ui:uibutton id="buttonViewContract" runat="server" alwaysenabled="True" confirmtext="Please remember to save this Purchase Order before viewing the Contract.\n\nAre you sure you want to continue?" imageurl="~/images/view.gif" meta:resourcekey="buttonViewContractResource1" onclick="buttonViewContract_Click" text="View Contract" />
                            </contextmenubuttons>
                        </ui:uifieldlabel>
                        <ui:uifielddatetime id="DateRequired" runat="server" caption="Date Required" imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" ondatetimechanged="DateRequired_DateTimeChanged" propertyname="DateRequired" showdatecontrols="True" span="Half" validatecomparefield="True" validaterequiredfield="True" validationcomparecontrol="DateEnd" validationcompareoperator="LessThanEqual" validationcomparetype="Date">
                        </ui:uifielddatetime>
                        <ui:uifielddatetime id="DateEnd" runat="server" caption="Date End" imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" meta:resourcekey="DateEndResource1" propertyname="DateEnd" showdatecontrols="True" span="Half" validatecomparefield="True" validaterequiredfield="True" validationcomparecontrol="DateRequired" validationcompareoperator="GreaterThanEqual" validationcomparetype="Date">
                        </ui:uifielddatetime>
                        <ui:uifielddropdownlist id="StoreID" runat="server" caption="Store" enabled="False" meta:resourcekey="StoreIDResource1" propertyname="StoreID" span="Half">
                        </ui:uifielddropdownlist>
                        <br />
                        <br />
                        <br />
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabVendor" runat="server" beginninghtml="" borderstyle="NotSet" caption="Vendor" endinghtml="" meta:resourcekey="tabVendorResource1">
                    <ui:uipanel id="panelTabVendor" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelTabVendorResource1">
                        <ui:uiseparator id="sep1" runat="server" caption="Vendor" meta:resourcekey="sep1Resource1" />
                        <ui:uifieldsearchabledropdownlist id="ContractID" runat="server" caption="Contract" meta:resourcekey="ContractIDResource1" onselectedindexchanged="ContractID_SelectedIndexChanged" propertyname="ContractID" searchinterval="300">
                        </ui:uifieldsearchabledropdownlist>
                        <ui:uifieldsearchabledropdownlist id="VendorID" runat="server" caption="Vendor" meta:resourcekey="VendorIDResource1" onselectedindexchanged="VendorID_SelectedIndexChanged" propertyname="VendorID" searchinterval="300" validaterequiredfield="True">
                        </ui:uifieldsearchabledropdownlist>
                        <ui:uipanel id="panelVendor" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelVendorResource1">
                            <ui:uifieldtextbox id="ContactAddressCountry" runat="server" caption="Country" internalcontrolwidth="95%" meta:resourcekey="ContactAddressCountryResource1" propertyname="ContactAddressCountry" span="Half">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactAddressState" runat="server" caption="State" internalcontrolwidth="95%" meta:resourcekey="ContactAddressStateResource1" propertyname="ContactAddressState" span="Half">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactAddressCity" runat="server" caption="City" internalcontrolwidth="95%" meta:resourcekey="ContactAddressCityResource1" propertyname="ContactAddressCity" span="Half">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactAddress" runat="server" caption="Address" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="ContactAddressResource1" propertyname="ContactAddress">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactCellPhone" runat="server" caption="Cellphone" internalcontrolwidth="95%" meta:resourcekey="ContactCellPhoneResource1" propertyname="ContactCellPhone" span="Half">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactEmail" runat="server" caption="Email" internalcontrolwidth="95%" meta:resourcekey="ContactEmailResource1" propertyname="ContactEmail" span="Half">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactFax" runat="server" caption="Fax" internalcontrolwidth="95%" meta:resourcekey="ContactFaxResource1" propertyname="ContactFax" span="Half">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactPhone" runat="server" caption="Phone" internalcontrolwidth="95%" meta:resourcekey="ContactPhoneResource1" propertyname="ContactPhone" span="Half">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="ContactPerson" runat="server" caption="Contact Person" internalcontrolwidth="95%" meta:resourcekey="ContactPersonResource1" propertyname="ContactPerson">
                            </ui:uifieldtextbox>
                        </ui:uipanel>
                    </ui:uipanel>
                    <ui:uiseparator id="UISeparator2" runat="server" caption="Currency" meta:resourcekey="UISeparator2Resource1" />
                    <ui:uipanel id="panelCurrency" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelCurrencyResource1">
                        <ui:uifielddropdownlist id="dropCurrency" runat="server" caption="Main Currency" meta:resourcekey="dropCurrencyResource1" onselectedindexchanged="dropCurrency_SelectedIndexChanged" propertyname="CurrencyID" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <table border="0" cellpadding="0" cellspacing="0" style="clear: both;
                            width: 50%">
                            <tr class="field-required" style="height: 25px">
                                <td style="width: 150px">
                                    <asp:Label ID="labelExchangeRate" runat="server" meta:resourceKey="labelExchangeRateResource1">Exchange Rate*:</asp:Label>
                                </td>
                                <td>
                                    <asp:Label ID="labelER1" runat="server" meta:resourceKey="labelER1Resource1">1</asp:Label>
                                    <ui:uifieldlabel id="labelERThisCurrency" runat="server" dataformatstring="" fieldlayout="Flow" internalcontrolwidth="20px" meta:resourcekey="labelERThisCurrencyResource1" propertyname="Currency.ObjectName" showcaption="False">
                                    </ui:uifieldlabel>
                                    <asp:Label ID="labelEREquals" runat="server" meta:resourceKey="labelEREqualsResource1">is equal to</asp:Label>
                                    <ui:uifieldtextbox id="textForeignToBaseExchangeRate" runat="server" caption="Exchange Rate" fieldlayout="Flow" internalcontrolwidth="60px" meta:resourcekey="textForeignToBaseExchangeRateResource1" ontextchanged="textForeignToBaseExchangeRate_TextChanged" propertyname="ForeignToBaseExchangeRate" showcaption="False" span="Half" validatedatatypecheck="True" validaterequiredfield="True" validationdatatype="Currency">
                                    </ui:uifieldtextbox>
                                    <asp:Label ID="labelERBaseCurrency" runat="server" meta:resourceKey="labelERBaseCurrencyResource1"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabTerms" runat="server" beginninghtml="" borderstyle="NotSet" caption="Terms" endinghtml="" meta:resourcekey="tabTermsResource1">
                    <ui:uipanel id="panelTerms" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelTermsResource1">
                        <ui:uiseparator id="Terms" runat="server" caption="Terms" meta:resourcekey="TermsResource2" />
                        <ui:uifieldtextbox id="FreightTerms" runat="server" caption="Freight Terms" internalcontrolwidth="95%" meta:resourcekey="FreightTermsResource1" propertyname="FreightTerms" rows="3" textmode="MultiLine">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="PaymentTerms" runat="server" caption="Payment Terms" internalcontrolwidth="95%" meta:resourcekey="PaymentTermsResource1" propertyname="PaymentTerms" rows="3" textmode="MultiLine">
                        </ui:uifieldtextbox>
                        <br />
                        <br />
                        <br />
                        <ui:uiseparator id="UISeparator1" runat="server" caption="Address" meta:resourcekey="UISeparator1Resource1" />
                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%">
                            <tr>
                                <td style="width: 49.5%">
                                    <ui:uipanel id="Panel1" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="Panel1Resource1">
                                        <asp:Label ID="Label1" runat="server" Font-Bold="True" meta:resourceKey="Label1Resource1" Text="Ship To:"></asp:Label>
                                        <br />
                                        <ui:uifieldtextbox id="ShipToAddress" runat="server" caption="Address" internalcontrolwidth="95%" meta:resourcekey="ShipToAddressResource1" propertyname="ShipToAddress" rows="4" textmode="MultiLine">
                                        </ui:uifieldtextbox>
                                        <ui:uifieldtextbox id="ShipToAttention" runat="server" caption="Attention" internalcontrolwidth="95%" meta:resourcekey="ShipToAttentionResource1" propertyname="ShipToAttention">
                                        </ui:uifieldtextbox>
                                    </ui:uipanel>
                                </td>
                                <td style="width: 49.5%">
                                    <ui:uipanel id="Panel2" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="Panel2Resource1">
                                        <asp:Label ID="Label2" runat="server" Font-Bold="True" meta:resourceKey="Label2Resource1" Text="Bill To:"></asp:Label>
                                        <br />
                                        <ui:uifieldtextbox id="BillToAddress" runat="server" caption="Address" internalcontrolwidth="95%" meta:resourcekey="BillToAddressResource1" propertyname="BillToAddress" rows="4" textmode="MultiLine">
                                        </ui:uifieldtextbox>
                                        <ui:uifieldtextbox id="BillToAttention" runat="server" caption="Attention" internalcontrolwidth="95%" meta:resourcekey="BillToAttentionResource1" propertyname="BillToAttention">
                                        </ui:uifieldtextbox>
                                    </ui:uipanel>
                                </td>
                            </tr>
                        </table>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabLineItems" runat="server" beginninghtml="" borderstyle="NotSet" caption="Line Items" endinghtml="" meta:resourcekey="tabLineItemsResource1">
                    <ui:uipanel id="PurchaseOrderItemPanel" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="PurchaseOrderItemPanelResource1">
                        <ui:uibutton id="buttonAddMaterialItems" runat="server" causesvalidation="False" imageurl="~/images/add.gif" meta:resourcekey="buttonAddMaterialItemsResource1" onclick="buttonAddMaterialItems_Click" onpopupreturned="addMaterialItems_PopupReturned" text="Add Multiple Inventory Items" />
                        <ui:uibutton id="buttonAddFixedRateItems" runat="server" causesvalidation="False" imageurl="~/images/add.gif" meta:resourcekey="buttonAddFixedRateItemsResource1" onclick="buttonAddFixedRateItems_Click" text="Add Multiple Service Items" />
                        <ui:uibutton id="buttonItemsAdded" runat="server" causesvalidation="False" meta:resourcekey="buttonItemsAddedResource1" onclick="buttonItemsAdded_Click" />
                        <br />
                        <br />
                        <ui:uigridview id="PurchaseOrderItems" runat="server" caption="Items" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" keyname="ObjectID" meta:resourcekey="PurchaseOrderItemsResource1" pagingenabled="True" propertyname="PurchaseOrderItems" rowerrorcolor="" showfooter="True" sortexpression="ItemNumber" style="clear:both;" width="100%">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="DeleteObject" commandtext="Delete" confirmtext="Are you sure you wish to delete the selected items?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" confirmtext="Are you sure you wish to delete this item?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:uigridviewboundcolumn datafield="ItemNumber" headertext="Number" meta:resourcekey="UIGridViewColumnResource3" propertyname="ItemNumber" resourceassemblyname="" sortexpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ItemTypeText" headertext="Type" meta:resourcekey="UIGridViewColumnResource4" propertyname="ItemTypeText" resourceassemblyname="" sortexpression="ItemTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ItemDescription" headertext="Description" meta:resourcekey="UIGridViewColumnResource5" propertyname="ItemDescription" resourceassemblyname="" sortexpression="ItemDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="UnitOfMeasure.ObjectName" headertext="Unit of Measure" meta:resourcekey="UIGridViewColumnResource6" propertyname="UnitOfMeasure.ObjectName" resourceassemblyname="" sortexpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ReceiptModeText" headertext="Receipt Mode" meta:resourcekey="UIGridViewBoundColumnResource1" propertyname="ReceiptModeText" resourceassemblyname="" sortexpression="ReceiptModeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="Currency.ObjectName" headertext="Currency" meta:resourcekey="UIGridViewBoundColumnResource2" propertyname="Currency.ObjectName" resourceassemblyname="" sortexpression="Currency.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="UnitPriceInSelectedCurrency" dataformatstring="{0:#,##0.00}" headertext="Unit Price" meta:resourcekey="UIGridViewColumnResource7" propertyname="UnitPriceInSelectedCurrency" resourceassemblyname="" sortexpression="UnitPriceInSelectedCurrency">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="UnitPrice" dataformatstring="{0:c}" headertext="Unit Price&lt;br/&gt;(Base Currency)" htmlencode="False" meta:resourcekey="UIGridViewBoundColumnResource3" propertyname="UnitPrice" resourceassemblyname="" sortexpression="UnitPrice">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="QuantityOrdered" dataformatstring="{0:#,##0.00##}" headertext="Quantity" meta:resourcekey="UIGridViewColumnResource8" propertyname="QuantityOrdered" resourceassemblyname="" sortexpression="QuantityOrdered">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="Subtotal" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Subtotal&lt;br/&gt;(Base Currency)" htmlencode="False" meta:resourcekey="UIGridViewBoundColumnResource4" propertyname="Subtotal" resourceassemblyname="" sortexpression="Subtotal">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="QuantityDelivered" dataformatstring="{0:#,##0.00##}" headertext="Quantity Delivered" meta:resourcekey="UIGridViewColumnResource10" propertyname="QuantityDelivered" resourceassemblyname="" sortexpression="QuantityDelivered">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="CopiedFromObjectNumber" headertext="Copied From" meta:resourcekey="UIGridViewColumnResource11" propertyname="CopiedFromObjectNumber" resourceassemblyname="" sortexpression="CopiedFromObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                            </Columns>
                        </ui:uigridview>
                        <ui:uiobjectpanel id="PurchaseOrderItem_Panel" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="PurchaseOrderItem_PanelResource1">
                            <web:subpanel ID="PurchaseOrderItem_SubPanel" runat="server" GridViewID="PurchaseOrderItems" meta:resourceKey="PurchaseOrderItem_SubPanelResource1" MultiSelectColumnNames="ItemNumber,ItemType,FixedRateID,CatalogueID,UnitPrice,QuantityOrdered" OnPopulateForm="PurchaseOrderItem_SubPanel_PopulateForm" OnRemoved="PurchaseOrderItem_SubPanel_Removed" OnValidateAndUpdate="PurchaseOrderItem_SubPanel_ValidateAndUpdate" />
                            <ui:uifielddropdownlist id="ItemNumber" runat="server" caption="Item Number" meta:resourcekey="ItemNumberResource1" propertyname="ItemNumber" span="Half" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <ui:uifieldradiolist id="ItemType" runat="server" caption="Item Type" meta:resourcekey="ItemTypeResource1" onselectedindexchanged="ItemType_SelectedIndexChanged" propertyname="ItemType" repeatcolumns="0" textalign="Right" validaterequiredfield="True">
                                <Items>
                                    <asp:ListItem meta:resourceKey="ListItemResource1" Text="Inventory" Value="0"></asp:ListItem>
                                    <asp:ListItem meta:resourceKey="ListItemResource2" Text="Service" Value="1"></asp:ListItem>
                                    <asp:ListItem meta:resourceKey="ListItemResource3" Text="Others" Value="2"></asp:ListItem>
                                </Items>
                            </ui:uifieldradiolist>
                            <ui:uifieldtreelist id="CatalogueID" runat="server" caption="Catalog" meta:resourcekey="CatalogueIDResource1" onacquiretreepopulater="CatalogueID_AcquireTreePopulater" onselectednodechanged="CatalogueID_SelectedNodeChanged" propertyname="CatalogueID" showcheckboxes="None" treevaluemode="SelectedNode" validaterequiredfield="True">
                            </ui:uifieldtreelist>
                            <ui:uifieldtreelist id="FixedRateID" runat="server" caption="Fixed Rate" meta:resourcekey="FixedRateIDResource1" onacquiretreepopulater="FixedRateID_AcquireTreePopulater" onselectednodechanged="FixedRateID_SelectedNodeChanged" propertyname="FixedRateID" showcheckboxes="None" treevaluemode="SelectedNode" validaterequiredfield="True">
                            </ui:uifieldtreelist>
                            <ui:uifieldlabel id="UnitOfMeasure" runat="server" caption="Unit of Measure" dataformatstring="" meta:resourcekey="UnitOfMeasureResource1" propertyname="Catalogue.UnitOfMeasure.ObjectName">
                            </ui:uifieldlabel>
                            <ui:uifieldlabel id="UnitOfMeasure2" runat="server" caption="Unit of Measure" dataformatstring="" meta:resourcekey="UnitOfMeasure2Resource1" propertyname="FixedRate.UnitOfMeasure.ObjectName">
                            </ui:uifieldlabel>
                            <ui:uifieldtextbox id="ItemDescription" runat="server" caption="Description" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="ItemDescriptionResource1" propertyname="ItemDescription" validaterequiredfield="True">
                            </ui:uifieldtextbox>
                            <ui:uifielddropdownlist id="UnitOfMeasureID" runat="server" caption="Unit of Measure" meta:resourcekey="UnitOfMeasureIDResource1" propertyname="UnitOfMeasureID" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <ui:uifieldradiolist id="radioReceiptMode" runat="server" caption="Receipt Mode" meta:resourcekey="radioReceiptModeResource1" onselectedindexchanged="radioReceiptMode_SelectedIndexChanged" propertyname="ReceiptMode" textalign="Right">
                                <Items>
                                    <asp:ListItem meta:resourcekey="ListItemResource4" Value="0">Receive by Quantity</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource5" Value="1">Receive by Dollar Amount</asp:ListItem>
                                </Items>
                            </ui:uifieldradiolist>
                            <ui:uifieldtextbox id="UnitPrice" runat="server" caption="Unit Price" internalcontrolwidth="95%" meta:resourcekey="UnitPriceResource1" propertyname="UnitPriceInSelectedCurrency" span="Half" validatedatatypecheck="True" validaterangefield="True" validaterequiredfield="True" validationdatatype="Currency" validationrangemax="99999999999999" validationrangemin="0" validationrangetype="Currency">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="QuantityOrdered" runat="server" caption="Quantity" internalcontrolwidth="95%" meta:resourcekey="QuantityOrderedResource1" propertyname="QuantityOrdered" span="Half" validatedatatypecheck="True" validaterangefield="True" validaterequiredfield="True" validationdatatype="Currency" validationrangemax="99999999999999" validationrangemin="0" validationrangetype="Currency">
                            </ui:uifieldtextbox>
                        </ui:uiobjectpanel>
                        <br />
                        <ui:UIHint runat="server" ID="hintRFQToPOPolicy" ImageUrl="~/images/error.gif"></ui:UIHint>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabBudget" runat="server" beginninghtml="" borderstyle="NotSet" caption="Budget" endinghtml="" meta:resourcekey="tabBudgetResource1">
                    <ui:uifieldradiolist id="radioBudgetDistributionMode" runat="server" caption="Budget Distribution" meta:resourcekey="radioBudgetDistributionModeResource1" onselectedindexchanged="radioBudgetDistributionMode_SelectedIndexChanged" propertyname="BudgetDistributionMode" textalign="Right" validaterequiredfield="True">
                        <Items>
                            <asp:ListItem meta:resourcekey="ListItemResource6" Value="0">By entire Purchase Order</asp:ListItem>
                            <asp:ListItem meta:resourcekey="ListItemResource7" Value="1">By individual Purchase Order items</asp:ListItem>
                        </Items>
                    </ui:uifieldradiolist>
                    <ui:uigridview id="gridBudget" runat="server" caption="Budgets" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" meta:resourcekey="gridBudgetResource1" pagesize="50" propertyname="PurchaseBudgets" rowerrorcolor="" showfooter="True" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="DeleteObject" commandtext="Delete" confirmtext="Are you sure you wish to delete the selected items?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource3" />
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource4" />
                        </commands>
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" confirmtext="Are you sure you wish to delete this item?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ItemNumber" headertext="Number" meta:resourcekey="UIGridViewBoundColumnResource5" propertyname="ItemNumber" resourceassemblyname="" sortexpression="ItemNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Budget.ObjectName" headertext="Budget" meta:resourcekey="UIGridViewBoundColumnResource6" propertyname="Budget.ObjectName" resourceassemblyname="" sortexpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.Path" headertext="Account" meta:resourcekey="UIGridViewBoundColumnResource7" propertyname="Account.Path" resourceassemblyname="" sortexpression="Account.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.AccountCode" headertext="Account Code" meta:resourcekey="UIGridViewBoundColumnResource8" propertyname="Account.AccountCode" resourceassemblyname="" sortexpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="StartDate" dataformatstring="{0:dd-MMM-yyyy}" headertext="Start Date" meta:resourcekey="UIGridViewBoundColumnResource9" propertyname="StartDate" resourceassemblyname="" sortexpression="StartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="EndDate" dataformatstring="{0:dd-MMM-yyyy}" headertext="End Date" meta:resourcekey="UIGridViewBoundColumnResource10" propertyname="EndDate" resourceassemblyname="" sortexpression="EndDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="AccrualFrequencyInMonths" headertext="Accrual Frequency (in months)" meta:resourcekey="UIGridViewBoundColumnResource11" propertyname="AccrualFrequencyInMonths" resourceassemblyname="" sortexpression="AccrualFrequencyInMonths">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Amount" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Amount" meta:resourcekey="UIGridViewBoundColumnResource12" propertyname="Amount" resourceassemblyname="" sortexpression="Amount">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:uiobjectpanel id="panelBudget" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelBudgetResource1">
                        <web:subpanel ID="subpanelBudget" runat="server" GridViewID="gridBudget" meta:resourceKey="subpanelBudgetResource1" OnPopulateForm="subpanelBudget_PopulateForm" OnRemoved="subpanelBudget_Removed" OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate" />
                        <ui:uifielddropdownlist id="dropItemNumber" runat="server" caption="Item Number" meta:resourcekey="dropItemNumberResource1" propertyname="ItemNumber" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uifielddropdownlist id="dropBudget" runat="server" caption="Budget" meta:resourcekey="dropBudgetResource1" onselectedindexchanged="dropBudget_SelectedIndexChanged" propertyname="BudgetID" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uifielddatetime id="dateStartDate" runat="server" caption="Start Date" meta:resourcekey="dateStartDateResource1" ondatetimechanged="dateStartDate_DateTimeChanged" propertyname="StartDate" showdatecontrols="True" span="Half" validatecomparefield="True" validaterequiredfield="True" validationcomparecontrol="dateEndDate" validationcompareoperator="LessThanEqual" validationcomparetype="Date">
                        </ui:uifielddatetime>
                        <ui:uifielddatetime id="dateEndDate" runat="server" caption="End Date" meta:resourcekey="dateEndDateResource1" propertyname="EndDate" showdatecontrols="True" span="Half" validatecomparefield="True" validaterequiredfield="True" validationcomparecontrol="dateStartDate" validationcompareoperator="GreaterThanEqual" validationcomparetype="Date">
                        </ui:uifielddatetime>
                        <ui:uifieldtextbox id="textAccrualFrequency" runat="server" caption="Accrual Frequency (months)" internalcontrolwidth="95%" meta:resourcekey="textAccrualFrequencyResource1" propertyname="AccrualFrequencyInMonths" span="Half" validaterangefield="True" validaterequiredfield="True" validationrangemin="1" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                        <ui:uifieldtreelist id="treeAccount" runat="server" caption="Account" meta:resourcekey="treeAccountResource1" onacquiretreepopulater="treeAccount_AcquireTreePopulater" propertyname="AccountID" showcheckboxes="None" treevaluemode="SelectedNode" validaterequiredfield="True">
                        </ui:uifieldtreelist>
                        <ui:uifieldtextbox id="textAmount" runat="server" caption="Amount" internalcontrolwidth="95%" meta:resourcekey="textAmountResource1" propertyname="Amount" span="Half" validaterequiredfield="True" validationrangemin="1" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                    </ui:uiobjectpanel>
                    <br />
                    <br />
                    <ui:uigridview id="gridBudgetSummary" runat="server" caption="Budget Summary" checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" meta:resourcekey="gridBudgetSummaryResource1" onaction="gridBudgetSummary_Action" pagesize="50" propertyname="PurchaseBudgetSummaries" rowerrorcolor="" showfooter="True" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewboundcolumn datafield="Budget.ObjectName" headertext="Budget" meta:resourcekey="UIGridViewBoundColumnResource13" propertyname="Budget.ObjectName" resourceassemblyname="" sortexpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="BudgetPeriod.ObjectName" headertext="Budget Period" meta:resourcekey="UIGridViewBoundColumnResource14" propertyname="BudgetPeriod.ObjectName" resourceassemblyname="" sortexpression="BudgetPeriod.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" commandname="ViewBudget" imageurl="~/images/printer.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="Account.ObjectName" headertext="Account" meta:resourcekey="UIGridViewBoundColumnResource15" propertyname="Account.ObjectName" resourceassemblyname="" sortexpression="Account.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.AccountCode" headertext="Account Code" meta:resourcekey="UIGridViewBoundColumnResource16" propertyname="Account.AccountCode" resourceassemblyname="" sortexpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAdjusted" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total After Adjustments" meta:resourcekey="UIGridViewBoundColumnResource17" propertyname="TotalAvailableAdjusted" resourceassemblyname="" sortexpression="TotalAvailableAdjusted">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableBeforeSubmission" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total Before Submission" meta:resourcekey="UIGridViewBoundColumnResource18" propertyname="TotalAvailableBeforeSubmission" resourceassemblyname="" sortexpression="TotalAvailableBeforeSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAtSubmission" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total At Submission" meta:resourcekey="UIGridViewBoundColumnResource19" propertyname="TotalAvailableAtSubmission" resourceassemblyname="" sortexpression="TotalAvailableAtSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAfterApproval" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total After Approval" meta:resourcekey="UIGridViewBoundColumnResource20" propertyname="TotalAvailableAfterApproval" resourceassemblyname="" sortexpression="TotalAvailableAfterApproval">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabReceipt" runat="server" beginninghtml="" borderstyle="NotSet" caption="Receipt" endinghtml="" meta:resourcekey="tabReceiptResource1">
                    <ui:uipanel id="panelAddReceipt" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelAddReceiptResource1">
                        <ui:uibutton id="buttonAddReceipt" runat="server" imageurl="~/images/add.gif" meta:resourcekey="buttonAddReceiptResource1" onclick="buttonAddReceipt_Click" text="Receive Items" />
                        <br />
                        <br />
                    </ui:uipanel>
                    <ui:uipanel id="panelSaveTip" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelSaveTipResource1">
                        <asp:Image ID="imageSaveTip" runat="server" ImageAlign="AbsMiddle" ImageUrl="~/images/information.png" meta:resourceKey="imageSaveTipResource1" />
                        <asp:Label ID="labelSaveTip" runat="server" meta:resourceKey="labelSaveTipResource1" Text="Please save this Purchase Order to commit the receipt."></asp:Label>
                        <br />
                        <br />
                    </ui:uipanel>
                    <ui:uigridview id="PurchaseOrderReceipts" runat="server" caption="Receipts" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" keyname="ObjectID" meta:resourcekey="PurchaseOrderReceiptsResource1" pagingenabled="True" propertyname="PurchaseOrderReceipts" rowerrorcolor="" style="clear:both;" width="100%">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" imageurl="~/images/view.gif" meta:resourcekey="UIGridViewColumnResource12">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="DateOfReceipt" dataformatstring="{0:dd-MMM-yyyy}" headertext="Date of Receipt" meta:resourcekey="UIGridViewColumnResource13" propertyname="DateOfReceipt" resourceassemblyname="" sortexpression="DateOfReceipt">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Store.ObjectName" headertext="Store" meta:resourcekey="UIGridViewColumnResource14" propertyname="Store.ObjectName" resourceassemblyname="" sortexpression="Store.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="StoreBin.ObjectName" headertext="Store Bin" meta:resourcekey="UIGridViewColumnResource15" propertyname="StoreBin.ObjectName" resourceassemblyname="" sortexpression="StoreBin.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="DeliveryOrderNumber" headertext="DO Number" meta:resourcekey="UIGridViewColumnResource16" propertyname="DeliveryOrderNumber" resourceassemblyname="" sortexpression="DeliveryOrderNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Description" headertext="Description" meta:resourcekey="UIGridViewColumnResource17" propertyname="Description" resourceassemblyname="" sortexpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:uiobjectpanel id="PurchaseOrderReceipt_Panel" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="PurchaseOrderReceipt_PanelResource1">
                        <web:subpanel ID="PurchaseOrderReceipt_Subpanel" runat="server" CancelVisible="true" GridViewID="PurchaseOrderReceipts" meta:resourceKey="PurchaseOrderReceipt_SubpanelResource1" OnPopulateForm="PurchaseOrderReceipt_SubPanel_PopulateForm" OnValidateAndUpdate="PurchaseOrderReceipt_Subpanel_ValidateAndUpdate" UpdateAndNewButtonVisible="false" />
                        <ui:uipanel id="panelPurchaseOrderReceipt" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelPurchaseOrderReceiptResource1">
                            <ui:uifielddatetime id="UIFieldDateTime1" runat="server" caption="Date of Receipt" imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" meta:resourcekey="UIFieldDateTime1Resource1" propertyname="DateOfReceipt" showdatecontrols="True" validaterequiredfield="True">
                            </ui:uifielddatetime>
                            <ui:uipanel id="panelStore" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelStoreResource1">
                                <ui:uifielddropdownlist id="dropStore" runat="server" caption="Store" meta:resourcekey="dropStoreResource1" onselectedindexchanged="dropStore_SelectedIndexChanged" propertyname="StoreID" span="Half" validaterequiredfield="True">
                                </ui:uifielddropdownlist>
                                <ui:uifielddropdownlist id="dropStoreBin" runat="server" caption="Store Bin" meta:resourcekey="PurchaseOrderReceipt_StoreBinIDResource1" propertyname="StoreBinID" span="Half" validaterequiredfield="True">
                                </ui:uifielddropdownlist>
                            </ui:uipanel>
                            <ui:uifieldtextbox id="PurchaseOrderReceipt_DeliveryOrderNumber" runat="server" caption="DO Number" internalcontrolwidth="95%" meta:resourcekey="PurchaseOrderReceipt_DeliveryOrderNumberResource1" propertyname="DeliveryOrderNumber">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="PurchaseOrderReceipt_Description" runat="server" caption="Description" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="PurchaseOrderReceipt_DescriptionResource1" propertyname="Description">
                            </ui:uifieldtextbox>
                            <br />
                            <br />
                            <ui:uipanel id="panelReceiptItems" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelReceiptItemsResource1">
                                <ui:uigridview id="PurchaseOrderReceiptItems" runat="server" bindobjectstorows="True" caption="Receipt Items" checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" keyname="ObjectID" meta:resourcekey="PurchaseOrderReceiptItemsResource1" onrowdatabound="PurchaseOrderReceiptItems_RowDataBound" pagingenabled="True" propertyname="PurchaseOrderReceiptItems" rowerrorcolor="" sortexpression="PurchaseOrderItem.ItemNumber" style="clear:both;" width="100%">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <Columns>
                                        <ui:uigridviewboundcolumn datafield="PurchaseOrderItem.ItemNumber" headertext="#" meta:resourcekey="UIGridViewColumnResource18" propertyname="PurchaseOrderItem.ItemNumber" resourceassemblyname="" sortexpression="PurchaseOrderItem.ItemNumber">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewboundcolumn datafield="PurchaseOrderItem.ItemTypeText" headertext="Item Type" meta:resourcekey="UIGridViewColumnResource19" propertyname="PurchaseOrderItem.ItemTypeText" resourceassemblyname="" sortexpression="PurchaseOrderItem.ItemTypeText">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewboundcolumn datafield="PurchaseOrderItem.ItemDescription" headertext="Description" meta:resourcekey="UIGridViewColumnResource20" propertyname="PurchaseOrderItem.ItemDescription" resourceassemblyname="" sortexpression="PurchaseOrderItem.ItemDescription">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewboundcolumn datafield="PurchaseOrderItem.ReceiptModeText" headertext="Receipt Mode" meta:resourcekey="UIGridViewBoundColumnResource21" propertyname="PurchaseOrderItem.ReceiptModeText" resourceassemblyname="" sortexpression="PurchaseOrderItem.ReceiptModeText">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewboundcolumn datafield="PurchaseOrderItem.ReceiptMode" meta:resourcekey="UIGridViewBoundColumnResource22" propertyname="PurchaseOrderItem.ReceiptMode" resourceassemblyname="" sortexpression="PurchaseOrderItem.ReceiptMode" visible="False">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewboundcolumn datafield="EquipmentName" meta:resourcekey="UIGridViewBoundColumnResource23" propertyname="EquipmentName" resourceassemblyname="" sortexpression="EquipmentName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewboundcolumn datafield="EquipmentParent.Path" meta:resourcekey="UIGridViewBoundColumnResource24" propertyname="EquipmentParent.Path" resourceassemblyname="" sortexpression="EquipmentParent.Path">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewboundcolumn datafield="PurchaseOrderItem.QuantityOrdered" dataformatstring="{0:#,##0.00##}" headertext="Quantity Ordered" meta:resourcekey="UIGridViewColumnResource21" propertyname="PurchaseOrderItem.QuantityOrdered" resourceassemblyname="" sortexpression="PurchaseOrderItem.QuantityOrdered">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewboundcolumn>
                                        <ui:uigridviewtemplatecolumn headertext="Quantity Received" meta:resourcekey="UIGridViewColumnResource22">
                                            <ItemTemplate>
                                                <ui:uifieldtextbox id="PurchaseOrderReceiptItem_QuantityDelivered" runat="server" caption="Quantity Received" captionwidth="1px" fieldlayout="Flow" internalcontrolwidth="95%" meta:resourcekey="PurchaseOrderReceiptItem_QuantityDeliveredResource1" ontextchanged="PurchaseOrderReceiptItem_QuantityDelivered_TextChanged" propertyname="QuantityDelivered" showcaption="False" validatedatatypecheck="True" validaterangefield="True" validaterequiredfield="True" validationdatatype="Currency" validationrangemax="99999999999999" validationrangemin="0" validationrangetype="Currency">
                                                </ui:uifieldtextbox>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="120px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewtemplatecolumn>
                                        <ui:uigridviewtemplatecolumn headertext="Unit Price / Dollar Amount Received" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                            <ItemTemplate>
                                                <ui:uifieldtextbox id="PurchaseOrderReceiptItem_UnitPrice" runat="server" caption="Unit Price Received" captionwidth="1px" fieldlayout="Flow" internalcontrolwidth="95%" meta:resourcekey="PurchaseOrderReceiptItem_UnitPriceResource1" propertyname="UnitPrice" showcaption="False" validatedatatypecheck="True" validaterangefield="True" validaterequiredfield="True" validationdatatype="Currency" validationrangemax="99999999999999" validationrangemin="0" validationrangetype="Currency">
                                                </ui:uifieldtextbox>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="120px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewtemplatecolumn>
                                        <ui:uigridviewtemplatecolumn headertext="Lot Number" meta:resourcekey="UIGridViewColumnResource23">
                                            <ItemTemplate>
                                                <ui:uifieldtextbox id="PurchaseOrderReceiptItem_LotNumber" runat="server" caption="Lot Number" captionwidth="1px" fieldlayout="Flow" internalcontrolwidth="95%" meta:resourcekey="PurchaseOrderReceiptItem_LotNumberResource1" propertyname="LotNumber" showcaption="False">
                                                </ui:uifieldtextbox>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="200px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewtemplatecolumn>
                                        <ui:uigridviewtemplatecolumn headertext="Expiry Date" meta:resourcekey="UIGridViewColumnResource24">
                                            <ItemTemplate>
                                                <ui:uifielddatetime id="PurchaseOrderReceiptItem_ExpiryDate" runat="server" caption="Expiry Date" captionwidth="1px" fieldlayout="Flow" imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" meta:resourcekey="PurchaseOrderReceiptItem_ExpiryDateResource1" propertyname="ExpiryDate" showcaption="False" showdatecontrols="True">
                                                </ui:uifielddatetime>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="200px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:uigridviewtemplatecolumn>
                                    </Columns>
                                </ui:uigridview>
                            </ui:uipanel>
                        </ui:uipanel>
                    </ui:uiobjectpanel>
                </ui:uitabview>
                <ui:uitabview id="tabInvoice" runat="server" beginninghtml="" borderstyle="NotSet" caption="Invoice" endinghtml="" meta:resourcekey="tabInvoiceResource1">
                    <ui:uipanel id="panelInvoiceMatchToReceipt" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelInvoiceMatchToReceiptResource1">
                        <ui:uigridview id="gridReceipts" runat="server" caption="Receipts" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" meta:resourcekey="gridReceiptsResource1" rowerrorcolor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                        </ui:uigridview>
                        <br />
                        <br />
                        <br />
                    </ui:uipanel>
                    <ui:uipanel id="panelInvoiceMatchToPO" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelInvoiceMatchToPOResource1">
                        <ui:uibutton id="buttonAddInvoice" runat="server" confirmtext="Are you sure you wish to add an invoice? Please remember to save the Purchase Order, otherwise changes that you have made will be lost." imageurl="~/images/add.gif" meta:resourcekey="buttonAddInvoiceResource1" onclick="buttonAddInvoice_Click" text="Add Invoice" />
                        <ui:uibutton id="buttonAddCreditMemo" runat="server" confirmtext="Are you sure you wish to add an credit memo? Please remember to save the Purchase Order, otherwise changes that you have made will be lost." imageurl="~/images/add.gif" meta:resourcekey="buttonAddCreditMemoResource1" onclick="buttonAddCreditMemo_Click" text="Add Credit Memo" />
                        <ui:uibutton id="buttonAddDebitMemo" runat="server" confirmtext="Are you sure you wish to add an debit memo? Please remember to save the Purchase Order, otherwise changes that you have made will be lost." imageurl="~/images/add.gif" meta:resourcekey="buttonAddDebitMemoResource1" onclick="buttonAddDebitMemo_Click" text="Add Debit Memo" />
                        <br />
                        <br />
                    </ui:uipanel>
                    <ui:uigridview id="gridInvoices" runat="server" caption="Invoices" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" meta:resourcekey="gridInvoicesResource1" onaction="gridInvoices_Action" onrowdatabound="gridInvoices_RowDataBound" rowerrorcolor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditInvoice" confirmtext="Are you sure you wish to edit this invoice? Please remember to save the Purchase Order, otherwise changes that you have made will be lost." imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ObjectNumber" headertext="Invoice Number" meta:resourcekey="UIGridViewBoundColumnResource25" propertyname="ObjectNumber" resourceassemblyname="" sortexpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="InvoiceTypeText" headertext="Invoice Type" meta:resourcekey="UIGridViewBoundColumnResource26" propertyname="InvoiceTypeText" resourceassemblyname="" sortexpression="InvoiceTypeText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="DateOfInvoice" dataformatstring="{0:dd-MMM-yyyy}" headertext="Date of Invoice" meta:resourcekey="UIGridViewBoundColumnResource27" propertyname="DateOfInvoice" resourceassemblyname="" sortexpression="DateOfInvoice">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Description" headertext="Description" meta:resourcekey="UIGridViewBoundColumnResource28" propertyname="Description" resourceassemblyname="" sortexpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Currency.ObjectName" headertext="Currency" meta:resourcekey="UIGridViewBoundColumnResource29" propertyname="Currency.ObjectName" resourceassemblyname="" sortexpression="Currency.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Currency.CurrencySymbol" meta:resourcekey="UIGridViewBoundColumnResource30" propertyname="Currency.CurrencySymbol" resourceassemblyname="" sortexpression="Currency.CurrencySymbol">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAmountInSelectedCurrency" dataformatstring="{0:n}" headertext="Net Amount" meta:resourcekey="UIGridViewBoundColumnResource31" propertyname="TotalAmountInSelectedCurrency" resourceassemblyname="" sortexpression="TotalAmountInSelectedCurrency">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalTaxInSelectedCurrency" dataformatstring="{0:n}" headertext="Tax" meta:resourcekey="UIGridViewBoundColumnResource32" propertyname="TotalTaxInSelectedCurrency" resourceassemblyname="" sortexpression="TotalTaxInSelectedCurrency">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAmount" dataformatstring="{0:c}" headertext="Net Amount&lt;br/&gt;(in Base Currency)" htmlencode="False" meta:resourcekey="UIGridViewBoundColumnResource33" propertyname="TotalAmount" resourceassemblyname="" sortexpression="TotalAmount">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalTax" dataformatstring="{0:c}" headertext="Tax&lt;br/&gt;(in Base Currency)" htmlencode="False" meta:resourcekey="UIGridViewBoundColumnResource34" propertyname="TotalTax" resourceassemblyname="" sortexpression="TotalTax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAmountAndTax" dataformatstring="{0:c}" headertext="Gross" meta:resourcekey="UIGridViewBoundColumnResource35" propertyname="TotalAmountAndTax" resourceassemblyname="" sortexpression="TotalAmountAndTax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="CurrentActivity.ObjectName" headertext="Status" meta:resourcekey="UIGridViewBoundColumnResource36" propertyname="CurrentActivity.ObjectName" resourceassemblyname="" resourcename="Resources.WorkflowStates" sortexpression="CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabWorkHistory" runat="server" beginninghtml="" borderstyle="NotSet" caption="Status History" endinghtml="" meta:resourcekey="tabWorkHistoryResource1">
                    <web:ActivityHistory ID="ActivityHistory" runat="server" meta:resourceKey="ActivityHistoryResource1" />
                </ui:uitabview>
                <ui:uitabview id="tabMemo" runat="server" beginninghtml="" borderstyle="NotSet" caption="Memo" endinghtml="" meta:resourcekey="tabMemoResource1">
                    <web:memo ID="memo1" runat="server" meta:resourceKey="memo1Resource1" />
                </ui:uitabview>
                <ui:uitabview id="tabAttachments" runat="server" beginninghtml="" borderstyle="NotSet" caption="Attachments" endinghtml="" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments ID="attachments" runat="server" meta:resourceKey="attachmentsResource1" />
                </ui:uitabview>
            </ui:uitabstrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
