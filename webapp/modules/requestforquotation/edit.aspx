<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
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
        ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;

        if (requestForQuotation.CurrentActivity == null ||
            requestForQuotation.CurrentActivity.ObjectName.Is("Draft", "PendingInvitation", "PendingQuotation", "PendingEvaluation"))
            requestForQuotation.UpdateApplicablePurchaseSettings();

        objectBase.ObjectNumberVisible = !requestForQuotation.IsNew;
        dropCase.Bind(OCase.GetAccessibleOpenCases(AppSession.User, Security.Decrypt(Request["TYPE"]), requestForQuotation.CaseID), "Case", "ObjectID");
        dropVendorToAward.Bind(requestForQuotation.GetVendorsWithSubmittedQuotations());
        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", requestForQuotation.PurchaseTypeID));

        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;

        if (requestForQuotation.CurrentActivity == null ||
            !requestForQuotation.CurrentActivity.ObjectName.Is("PendingApproval", "Awarded", "Close", "Cancelled"))
        {
            requestForQuotation.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        else
            gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";

        // Set access control for the button
        //
        buttonViewCase.Visible = AppSession.User.AllowViewAll("OCase");
        buttonEditCase.Visible = AppSession.User.AllowEditAll("OCase") || OActivity.CheckAssignment(AppSession.User, requestForQuotation.CaseID);

        panel.ObjectPanel.BindObjectToControls(requestForQuotation);
    }


    /// <summary>
    /// Validates and saves the purchase request into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(requestForQuotation);

            // Validate
            //
            if (!objectBase.CurrentObjectState.Is("Close", "Cancelled") &&
                !OCase.ValidateCaseNotClosedOrCancelled(requestForQuotation.CaseID))
            {
                dropCase.ErrorMessage = Resources.Errors.Case_CannotBeClosedOrCancelled;
            }

            if (objectBase.SelectedAction == "Cancel")
            {
                // Validate to ensure that none of the selected
                // RFQ items have been generated to POs.
                //
                List<Guid> rfqItemIds = new List<Guid>();
                foreach (ORequestForQuotationItem rfqi in requestForQuotation.RequestForQuotationItems)
                    rfqItemIds.Add(rfqi.ObjectID.Value);
                string lineItems = ORequestForQuotation.ValidateRFQLineItemsNotGeneratedToPO(rfqItemIds);
                if (lineItems.Length != 0)
                {
                    RequestForQuotationItems.ErrorMessage = 
                        String.Format(Resources.Errors.RequestForQuotation_CannotBeCancelledItemsGeneratedToRFQOrPO, lineItems);
                    return;
                }
            }
            
            if (objectBase.SelectedAction == "SubmitForApproval")
            {
                // Ensure that all budget accounts in the budget
                // line items are set as active.
                //
                string inactiveAccounts = OPurchaseBudget.ValidateBudgetAccountsAreActive(requestForQuotation.PurchaseBudgets);
                if (inactiveAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.RequestForQuotation_BudgetAccountsNotActive, inactiveAccounts);
                }

                // Ensure that the budget periods covering the start date of
                // the purchase order exists, and has not yet been closed.
                //
                string closedBudgets = OPurchaseBudget.ValidateBudgetPeriodsActiveAndOpened(requestForQuotation.PurchaseBudgets);
                if (closedBudgets != "")
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_BudgetPeriodsClosed, closedBudgets);
                
                // Ensure that at least one item in the RFQ has been
                // awarded before we can submit for approval.
                //
                if (!requestForQuotation.ValidateAtLeastOneItemAwarded())
                    gridAwardItems.ErrorMessage = Resources.Errors.RequestForQuotation_NoLineItemsAwarded;

                // Ensure that the budget line items match the
                // RFQ line items in amount.
                //
                string itemNumber = requestForQuotation.ValidateBudgetAmountEqualsLineItemAmount();
                if (itemNumber != null)
                {
                    string itemNumberText = "";
                    if (itemNumber != null)
                        itemNumberText = String.Format(Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount_LineItem, itemNumber);
                    else
                        itemNumberText = Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount_EntireRFQ;
                    
                    if (requestForQuotation.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems)
                        gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount, itemNumberText);
                    else if (requestForQuotation.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems)
                        gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_ItemAmountLessThanBudgetAmount, itemNumberText);
                }

                // Ensure budget is sufficient.
                //
                string insufficientAccounts = requestForQuotation.ValidateSufficientBudget();
                if (insufficientAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.RequestForQuotation_InsufficientBudget, insufficientAccounts);
                }
                
                // Ensure that number of quotations is sufficient.
                if (requestForQuotation.ValidateSufficientNumberOfQuotations() == 0)
                {
                    RequestForQuotationVendors.ErrorMessage = 
                        String.Format(Resources.Errors.RequestForQuotation_InsufficientQuotations, requestForQuotation.MinimumNumberOfQuotations);
                }
            }

            if (!panel.ObjectPanel.IsValid)
                return;
            
            // Save
            //
            requestForQuotation.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        return new LocationTreePopulater(rfq.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Updates the requestor dropdown list when the location changes,
    /// and clears the selected equipment ID.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        rfq.EquipmentID = null;
        rfq.UpdateApplicablePurchaseSettings();
        panel.ObjectPanel.BindObjectToControls(rfq);
    }


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        return new EquipmentTreePopulater(rfq.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Updates the location to the location of the selected equipment.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        if (rfq.Equipment != null)
        {
            rfq.LocationID = rfq.Equipment.LocationID;
            treeLocation.PopulateTree();
        }
        panel.ObjectPanel.BindObjectToControls(rfq);
    }


    /// <summary>
    /// Populates the RFQ item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        ORequestForQuotationItem requestForQuotationItem =
            RequestForQuotationItem_SubPanel.SessionObject as ORequestForQuotationItem;

        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", requestForQuotationItem.UnitOfMeasureID));
        CatalogueID.PopulateTree();
        FixedRateID.PopulateTree();

        ItemNumber.Items.Clear();
        ORequestForQuotation p = (ORequestForQuotation)panel.SessionObject;
        for (int i = 1; i <= p.RequestForQuotationItems.Count + 1; i++)
            ItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (requestForQuotationItem.IsNew && requestForQuotationItem.ItemNumber == null)
            requestForQuotationItem.ItemNumber = p.RequestForQuotationItems.Count + 1;

        RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(requestForQuotationItem);
    }


    /// <summary>
    /// Validates and inserts the RFQ item into the RFQ.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        ORequestForQuotation p = (ORequestForQuotation)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(p);

        ORequestForQuotationItem i = (ORequestForQuotationItem)RequestForQuotationItem_SubPanel.SessionObject;
        RequestForQuotationItem_SubPanel.ObjectPanel.BindControlsToObject(i);

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
        else
        {
            RequestForQuotationItem_SubPanel.ObjectPanel.BindControlsToObject(i);
            i.CatalogueID = null;
            i.FixedRateID = null;

        }


        p.RequestForQuotationItems.Add(i);
        p.ReorderItems(i);
        panel.ObjectPanel.BindObjectToControls(p);
    }


    /// <summary>
    /// Occurs when the user removes items from the list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationItem_SubPanel_Removed(object sender, EventArgs e)
    {
        ORequestForQuotation p = (ORequestForQuotation)panel.SessionObject;
        p.ReorderItems(null);
    }


    /// <summary>
    /// Validates and inserts the RFQ Vendor's quotation into
    /// the RFQ object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationVendors_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        // Bind from UI
        //
        ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(requestForQuotation);
        ORequestForQuotationVendor requestForQuotationVendor =
            RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(requestForQuotationVendor);

        // Validate
        //
        if (requestForQuotation.IsDuplicateVendor(requestForQuotationVendor))
            dropVendor.ErrorMessage = Resources.Errors.RequestForQuotation_DuplicateVendor;
        if (!RequestForQuotationVendors_SubPanel.ObjectPanel.IsValid)
            return;

        // Update the ORequestForQuotationVendorItems' unit price 
        // (in base currency).
        //
        requestForQuotationVendor.UpdateItemsUnitPrice();
        requestForQuotation.UpdateVendorAwardedItemsUnitPrice();

        // Add
        //
        requestForQuotation.RequestForQuotationVendors.Add(requestForQuotationVendor);
        panel.ObjectPanel.BindObjectToControls(requestForQuotation);

        // Re-bind the vendor dropdown list.
        //
        dropVendorToAward.Bind(requestForQuotation.GetVendorsWithSubmittedQuotations());

    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;

        treeLocation.Enabled = gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;
        CatalogueID.Visible = ItemType.SelectedIndex == 0;
        UnitOfMeasure.Visible = ItemType.SelectedIndex == 0;
        UnitOfMeasure2.Visible = ItemType.SelectedIndex == 1;
        FixedRateID.Visible = ItemType.SelectedIndex == 1;
        UnitOfMeasureID.Visible = ItemType.SelectedIndex == 2;
        ItemDescription.Visible = ItemType.SelectedIndex == 2;
        radioReceiptMode.Enabled = ItemType.SelectedValue != PurchaseItemType.Material.ToString();
        textQuantityRequired.Enabled = radioReceiptMode.SelectedValue != ReceiptModeType.Dollar.ToString() || ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        buttonAddFixedrateItems.Enabled = !RequestForQuotationItem_SubPanel.Visible;
        buttonAddMaterialItems.Enabled = !RequestForQuotationItem_SubPanel.Visible;
        buttonAddMultipleVendors.Enabled = !RequestForQuotationVendors_SubPanel.Visible;
        panelQuotationOptionalDetails.Visible = checkShowOptionalDetails.Checked;
        tabBudget.Visible = treeLocation.SelectedItem != "" && DateRequired.DateTime != null &&
            rfq.ValidateSufficientNumberOfQuotations() != 0 &&
            rfq.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;
        gridBudget.Visible = radioBudgetDistributionMode.SelectedValue != "";
        radioBudgetDistributionMode.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible && rfq.NumberOfAwardedVendors <= 1;
        dropItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == "1";
        gridBudgetSummary.Visible = gridBudgetSummary.Rows.Count > 0;
        StoreID.Visible = StoreID.SelectedIndex > 0;
        panelQuotationDetails.Visible = checkIsSubmitted.Checked;
        buttonGeneratePOFromLineItems.Visible = radioBudgetDistributionMode.SelectedValue == "1";
        buttonGeneratePO.Visible = radioBudgetDistributionMode.SelectedValue == "0";
        gridAwardItems.CheckBoxColumnVisible = !objectBase.CurrentObjectState.Is("Awarded") || radioBudgetDistributionMode.SelectedValue == "1";
        ItemType.Items[0].Enabled = !checkIsTermContract.Checked;
        checkIsTermContract.Enabled = RequestForQuotationItems.Rows.Count == 0 && !RequestForQuotationItem_SubPanel.Visible && rfq.StoreID == null;

        foreach (GridViewRow gridViewRow in gridAwardItems.Rows)
        {
            if (gridViewRow.RowType == DataControlRowType.DataRow)
            {
                CheckBox checkbox = gridViewRow.Cells[0].Controls[0] as CheckBox;
                if (checkbox != null)
                {
                    if (gridViewRow.Cells[7].Text == "&nbsp;")
                        checkbox.Checked = true;
                }
            }
        }

        ORequestForQuotationVendor rfqVendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        if (rfqVendor != null)
            textForeignToBaseExchangeRate.Enabled = rfqVendor.IsExchangeRateDefined == 0;

        panelRequestForQuotationItems.Enabled = RequestForQuotationVendors.Grid.Rows.Count == 0 && !RequestForQuotationVendors_Panel.Visible;

        // Update the quotation policy hint.
        //
        if (rfq.ValidateSufficientNumberOfQuotations() == -1)
        {
            hintQuotationPolicy.Text = String.Format(
                Resources.Messages.RequestForQuotation_MinimumQuotationsPreferred,
                rfq.MinimumNumberOfQuotations);
        }
        else if (rfq.ValidateSufficientNumberOfQuotations() == 0)
        {
            hintQuotationPolicy.Text = String.Format(
                Resources.Messages.RequestForQuotation_MinimumQuotationsRequired,
                rfq.MinimumNumberOfQuotations);
        }
        else
        {
            hintQuotationPolicy.Text = "";
        }
        hintQuotationPolicy.Visible = hintQuotationPolicy.Text != "";

        Workflow_Setting();
    }


    /// <summary>
    /// Hides/shows or enables/disables elements according to workflow.
    /// </summary>
    protected void Workflow_Setting()
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        ORequestForQuotationVendor rfqVendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;

        string stateAndAction = objectBase.CurrentObjectState + "::" + objectBase.SelectedAction;

        tabDetails.Enabled = !objectBase.CurrentObjectState.Is("Close", "Cancelled");
        panelDetails.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        tabLineItems.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        tabQuotations.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        tabBudget.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelAwardVendor.Visible = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");

        AwardedJustification.ValidateRequiredField = objectBase.SelectedAction.Is("SubmitForApproval") ||
            objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Cancelled", "Close");
        
        panelAward.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelGeneratePOButton.Visible = objectBase.CurrentObjectState.Is("Awarded");

        dropPurchaseType.ValidateRequiredField = !(objectBase.CurrentObjectState.Is("Draft") && objectBase.SelectedAction.Is("Cancel"));
    }


    /// <summary>
    /// Occurs when the user selects an item in the Item Type
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ItemType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotationItem requestForQuotationItem = RequestForQuotationItem_SubPanel.SessionObject as ORequestForQuotationItem;
        RequestForQuotationItem_SubPanel.ObjectPanel.BindControlsToObject(requestForQuotationItem);

        // If the item is a material item type, then
        // set the receipt mode to quantity, and 
        // disable the receipt mode radio button list.
        //
        if (requestForQuotationItem.ItemType == PurchaseItemType.Material)
            requestForQuotationItem.ReceiptMode = ReceiptModeType.Quantity;
        else if (requestForQuotationItem.ItemType == PurchaseItemType.Service)
        {
            requestForQuotationItem.ReceiptMode = ReceiptModeType.Dollar;
            requestForQuotationItem.QuantityRequired  = 1.0M;
        }

        RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(requestForQuotationItem);
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
            textQuantityRequired.Text = "1.00";
        }
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CatalogueID_AcquireTreePopulater(object sender)
    {
        ORequestForQuotationItem i = (ORequestForQuotationItem)RequestForQuotationItem_SubPanel.SessionObject;
        return new CatalogueTreePopulater(i.CatalogueID, true, true, true, true);
    }


    /// <summary>
    /// Occurs when the user selects a node in the catalog treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotationItem i = (ORequestForQuotationItem)RequestForQuotationItem_SubPanel.SessionObject;
        RequestForQuotationItem_SubPanel.ObjectPanel.BindControlsToObject(i);
        RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Constructs and returns a fixed rate treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater FixedRateID_AcquireTreePopulater(object sender)
    {
        ORequestForQuotationItem i = (ORequestForQuotationItem)RequestForQuotationItem_SubPanel.SessionObject;
        return new FixedRateTreePopulater(i.FixedRateID, false, true);
    }


    /// <summary>
    /// Occurs when the user selects a node in the fixed rate treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void FixedRateID_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotationItem i = (ORequestForQuotationItem)RequestForQuotationItem_SubPanel.SessionObject;
        RequestForQuotationItem_SubPanel.ObjectPanel.BindControlsToObject(i);
        RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Opens the add vendors window.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddMultipleVendors_Click(object sender, EventArgs e)
    {
        Window.Open("addvendor.aspx");
        panel.FocusWindow = false;
    }


    /// <summary>
    /// Occurs when the user adds selected items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonVendorsAdded_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;

        tabQuotations.BindObjectToControls(rfq);
        tabAward.BindObjectToControls(rfq);
    }
    

    /// <summary>
    /// Occurs when the user clicks a button or a command in the
    /// Vendors' Quotations gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void RequestForQuotationVendor_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "DeleteObject")
        {
            RequestForQuotationVendors.Grid.DataBound += new EventHandler(Grid_DataBound);
        }
    }


    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    void Grid_DataBound(object sender, EventArgs e)
    {
        ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(requestForQuotation);

        RequestForQuotationVendors.Grid.DataBound -= new EventHandler(Grid_DataBound);
    }


    /// <summary>
    /// Occurs when the user clicks on the Generate PO from RFQ button.
    /// This generates a PO from all the line items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePO_Click(object sender, EventArgs e)
    {
        List<object> ids = RequestForQuotationItems.GetSelectedKeys();

        List<ORequestForQuotationItem> items = new List<ORequestForQuotationItem>(); ;
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        
        // Validate to ensure that none of the selected
        // RFQ items have been generated to POs.
        //
        List<Guid> rfqItemIds = new List<Guid>();
        foreach (ORequestForQuotationItem rfqi in rfq.RequestForQuotationItems)
            rfqItemIds.Add(rfqi.ObjectID.Value);
        string lineItems = ORequestForQuotation.ValidateRFQLineItemsNotGeneratedToPO(rfqItemIds);
        if (lineItems.Length != 0)
        {
            panel.Message = String.Format(Resources.Errors.RequestForQuotation_LineItemsAlreadyGeneratedIntoRFQOrPOs, lineItems);
            return;
        }
        
        // Validates that all line items are awarded to a single vendor.
        //
        if (!ORequestForQuotation.ValidateRFQLineItemsAwardedToSingleVendor(rfqItemIds))
        {
            panel.Message = Resources.Errors.RequestForQuotation_LineItemsNotAwardedToASingleVendor;
            return;
        }


        // Then generate the new PO.
        //
        foreach (ORequestForQuotationItem rfqi in rfq.RequestForQuotationItems)
            items.Add(rfqi);
        /*
        OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQLineItems(items);
        if (po != null)
            Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.Value.ToString(), "");
        else
            panel.Message = Resources.Errors.PurchaseOrder_UnableToGenerate;*/
    }


    /// <summary>
    /// Occurs when the user clicks on the Generate PO from Selected Line Items
    /// button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePOFromLineItems_Click(object sender, EventArgs e)
    {
        List<object> ids = gridAwardItems.GetSelectedKeys();

        RequestForQuotationItems.ErrorMessage = "";
        panel.Message = "";
        if (ids.Count > 0)
        {
            // Validate to ensure that none of the selected
            // RFQ items have been generated to POs.
            //
            List<Guid> rfqItemIds = new List<Guid>();
            foreach (Guid id in ids)
                rfqItemIds.Add(id);
            string lineItems = ORequestForQuotation.ValidateRFQLineItemsNotGeneratedToPO(rfqItemIds);
            if (lineItems.Length != 0)
            {
                panel.Message = String.Format(Resources.Errors.RequestForQuotation_LineItemsAlreadyGeneratedIntoRFQOrPOs, lineItems);
                return;
            }

            // Validates that all line items are awarded to a single vendor.
            //
            if (!ORequestForQuotation.ValidateRFQLineItemsAwardedToSingleVendor(rfqItemIds))
            {
                panel.Message = Resources.Errors.RequestForQuotation_LineItemsNotAwardedToASingleVendor;
                return;
            }
            
            
            // Then generate the new PO.
            //
            List<ORequestForQuotationItem> items = new List<ORequestForQuotationItem>();
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);

            foreach (ORequestForQuotationItem rfqi in rfq.RequestForQuotationItems)
            {
                if (ids.Contains(rfqi.ObjectID.Value))
                    items.Add(rfqi);
            }

            /*
            OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQLineItems(items);
            Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.Value.ToString(), "");*/
        }
        else
        {
            RequestForQuotationItems.ErrorMessage = Resources.Errors.RequestForQuotation_NoRFQItemsSelected;
            panel.Message = Resources.Errors.RequestForQuotation_NoRFQItemsSelected;
        }
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
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;

        panelRequestForQuotationItems.BindObjectToControls(rfq);
        tabAward.BindObjectToControls(rfq);
    }
    
    
    /// <summary>
    /// Populates the vendor quotation subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationVendors_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        ORequestForQuotationVendor rfqVendor =
            RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;

        dropVendor.Bind(OVendor.GetVendors(DateTime.Today, rfqVendor.VendorID));
        dropCurrency.Bind(OCurrency.GetAllCurrencies(rfqVendor.CurrencyID), "CurrencyNameAndDescription", "ObjectID", true);

        if (RequestForQuotationVendors_SubPanel.IsAddingObject)
        {
            rfqVendor.UpdateExchangeRate();
            rfq.CreateRequestForQuotationVendorItems(rfqVendor);
        }
        SetGridViewCurrency();

        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(rfqVendor);
    }


    /// <summary>
    /// Occurs when a vendor is selected from the dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropVendor_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropVendor.SelectedValue != "")
        {
            ORequestForQuotationVendor rfqVendor =
                RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
            RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(rfqVendor);

            Guid vendorId = new Guid(dropVendor.SelectedValue);
            OVendor vendor = TablesLogic.tVendor[vendorId];

            if (vendor != null)
            {
                rfqVendor.ContactAddress = vendor.OperatingAddress;
                rfqVendor.ContactAddressCity = vendor.OperatingAddressCity;
                rfqVendor.ContactAddressCountry = vendor.OperatingAddressCountry;
                rfqVendor.ContactAddressState = vendor.OperatingAddressState;
                rfqVendor.ContactCellPhone = vendor.OperatingCellPhone;
                rfqVendor.ContactEmail = vendor.OperatingEmail;
                rfqVendor.ContactFax = vendor.OperatingFax;
                rfqVendor.ContactPhone = vendor.OperatingPhone;
                rfqVendor.ContactPerson = vendor.OperatingContactPerson;
                if (vendor.CurrencyID != null)
                {
                    if (rfqVendor.CurrencyID != vendor.CurrencyID)
                    {
                        rfqVendor.CurrencyID = vendor.CurrencyID;
                        rfqVendor.UpdateExchangeRate();
                    }
                }
                else
                {
                    rfqVendor.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;
                    rfqVendor.ForeignToBaseExchangeRate = 1.0M;
                    rfqVendor.IsExchangeRateDefined = 1;
                }
            }

            rfqVendor.UpdateItemCurrencies();
            RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(rfqVendor);
        }
    }


    /// <summary>
    /// Finds and updates the exchange rate.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropCurrency_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotationVendor rfqVendor =
            RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(rfqVendor);
        rfqVendor.UpdateExchangeRate();
        rfqVendor.UpdateItemCurrencies();
        SetGridViewCurrency();
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(rfqVendor);
    }
    
    
    /// <summary>
    /// Sets the currency that appears at the header text of the grid view.
    /// </summary>
    protected void SetGridViewCurrency()
    {
        ORequestForQuotationVendor rfqVendor =
            RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        
        DataControlField c = RequestForQuotationVendorItems.Columns[5];

        string[] headerText = c.HeaderText.Split('(');

        if (rfqVendor.Currency != null)
            c.HeaderText = headerText[0].Trim() + " (" + rfqVendor.Currency.CurrencySymbol + ")";
        else
            c.HeaderText = headerText[0].Trim();
    }


    /// <summary>
    /// Finds and updates the exchange rate.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dateDateOfQuotation_DateTimeChanged(object sender, EventArgs e)
    {
        ORequestForQuotationVendor rfqVendor =
            RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(rfqVendor);
        rfqVendor.UpdateExchangeRate();
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(rfqVendor);
    }


    OCurrency baseCurrency = null;

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationVendorItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ORequestForQuotationVendor rfqVendor =
            RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;

        if (baseCurrency == null)
            baseCurrency = OApplicationSetting.Current.BaseCurrency;
        OCurrency altCurrency = rfqVendor.Currency;

        UIFieldDropDownList dropItemCurrency = e.Row.FindControl("dropItemCurrency") as UIFieldDropDownList;
        if (dropItemCurrency != null)
        {
            dropItemCurrency.Items.Clear();
            if (altCurrency != null)
                dropItemCurrency.Items.Add(new ListItem(altCurrency.ObjectName, altCurrency.ObjectID.ToString()));
        }
    }


    /// <summary>
    /// Occurs when the user clicks on the optional details.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkShowOptionalDetails_CheckedChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user checks the quotation submitted checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkIsSubmitted_CheckedChanged(object sender, EventArgs e)
    {
        ORequestForQuotationVendor rfqVendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(rfqVendor);
        if (rfqVendor.IsSubmitted == 1 && rfqVendor.DateOfQuotation == null)
        {
            rfqVendor.DateOfQuotation = DateTime.Today;
            rfqVendor.UpdateExchangeRate();
        }
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(rfqVendor);
    }


    /// <summary>
    /// Award selected items to the selected vendor.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropVendorToAward_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropVendorToAward.SelectedValue == "")
        {
            return;
        }
        if (gridAwardItems.GetSelectedKeys().Count == 0)
        {
            dropVendorToAward.SelectedIndex = 0;
            return;
        }

        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        List<object> keys = gridAwardItems.GetSelectedKeys();
        List<Guid> rfqItemIds = new List<Guid>();
        foreach (Guid rfqItemId in keys)
            rfqItemIds.Add(rfqItemId);

        Guid vendorId = new Guid(dropVendorToAward.SelectedValue);
        rfq.AwardLineItemsToVendor(vendorId, rfqItemIds);

        panel.ObjectPanel.BindObjectToControls(rfq);

        dropVendorToAward.SelectedIndex = 0;
    }
    
    
    /// <summary>
    /// Clear awards on selected items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonClearAwardOnSelectedItems_Click(object sender, EventArgs e)
    {
        if (gridAwardItems.GetSelectedKeys().Count == 0)
        {
            return;
        }

        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        List<object> keys = gridAwardItems.GetSelectedKeys();
        List<Guid> rfqItemIds = new List<Guid>();
        foreach (Guid rfqItemId in keys)
            rfqItemIds.Add(rfqItemId);

        rfq.ClearAwardLineItems(rfqItemIds);

        panel.ObjectPanel.BindObjectToControls(rfq);
    }

    /// <summary>
    /// Populates the budget subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_PopulateForm(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        dropBudget.Bind(OBudget.GetCoveringBudgets(rfq.Location, prBudget.BudgetID));
        if (subpanelBudget.IsAddingObject)
        {
            if (dropBudget.Items.Count == 2)
                prBudget.BudgetID = new Guid(dropBudget.Items[1].Value);
            prBudget.StartDate = rfq.DateRequired;
            prBudget.EndDate = rfq.DateEnd;
        }

        dropItemNumber.Items.Clear();
        for (int i = 1; i <= rfq.RequestForQuotationItems.Count; i++)
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
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);

        // Validate
        //

        // Insert
        //
        rfq.PurchaseBudgets.Add(prBudget);

        if (rfq.CurrentActivity == null ||
            !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled"))
        {
            rfq.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        
        panel.ObjectPanel.BindObjectToControls(rfq);
    }

    /// <summary>
    /// Occurs when the user removes one or more budget distribution.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_Removed(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        
        if (rfq.CurrentActivity == null ||
            !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled"))
        {
            rfq.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        panel.ObjectPanel.BindObjectToControls(rfq);
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
    /// Occurs when the user selects a new required date.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DateRequired_DateTimeChanged(object sender, EventArgs e)
    {
        if (!checkIsTermContract.Checked)
            DateEnd.DateTime = DateRequired.DateTime;
    }

    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropPurchaseType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        rfq.UpdateApplicablePurchaseSettings();
        panel.ObjectPanel.BindObjectToControls(rfq);
    }

    /// <summary>
    /// Occurs when a vendor's quotation is removed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationVendors_SubPanel_Removed(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        rfq.UpdateVendorAwardedItemsUnitPrice();

        dropVendorToAward.Bind(rfq.GetVendorsWithSubmittedQuotations());
    }


    /// <summary>
    /// Occurs when the items in the RFQ vendor grid is data bound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestForQuotationVendors_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[13].Text = e.Row.Cells[12].Text + e.Row.Cells[13].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[12].Visible = false;
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
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            OPurchaseBudgetSummary budgetSummary = rfq.PurchaseBudgetSummaries.Find(id);
            if (budgetSummary == null)
                budgetSummary = rfq.TempPurchaseBudgetSummaries.Find((r) => r.ObjectID == id);
            if (budgetSummary != null)
                Window.Open("../../modules/budgetperiod/budgetview.aspx?ID=" +
                    HttpUtility.UrlEncode(Security.Encrypt(budgetSummary.BudgetPeriodID.ToString())));

            panel.FocusWindow = false;
        }
    }


    /// <summary>
    /// Occurs when the award items gridview is data bound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridAwardItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[10].Text = e.Row.Cells[9].Text + e.Row.Cells[10].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[9].Visible = false;
    }


    /// <summary>
    /// Opens a window to edit the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditCase_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = (ORequestForQuotation)panel.SessionObject;
        if (rfq.CaseID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, rfq.CaseID))
                Window.OpenEditObjectPage(this, "OCase", rfq.CaseID.ToString(), "");
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
        ORequestForQuotation rfq = (ORequestForQuotation)panel.SessionObject;
        if (rfq.CaseID != null)
        {
            Window.OpenViewObjectPage(this, "OCase", rfq.CaseID.ToString(), "");
        }
    }

    
    /// <summary>
    /// Occurs when the user clicks on the term contract checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkIsTermContract_CheckedChanged(object sender, EventArgs e)
    {

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" BorderStyle="NotSet" 
        meta:resourcekey="UIObjectPanelResource1">
        <web:object runat="server" ID="panel" Caption="Request for Quotation" BaseTable="tRequestForQuotation"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:uitabstrip id="tabObject" runat="server" borderstyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:uitabview id="tabDetails" runat="server" borderstyle="NotSet" 
                    caption="Details" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" 
                        ObjectNameVisible="false" ObjectNumberEnabled="false" 
                        ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false" />
                    <ui:uipanel id="panelDetails" runat="server" borderstyle="NotSet" 
                        meta:resourcekey="panelDetailsResource1">
                        <ui:uiseparator id="UISeparator2" runat="server" caption="Case" 
                            meta:resourcekey="UISeparator2Resource1" />
                        <ui:uifieldsearchabledropdownlist id="dropCase" runat="server" caption="Case" 
                            contextmenualwaysenabled="True" meta:resourcekey="dropCaseResource1" 
                            propertyname="CaseID" searchinterval="300">
                            <contextmenubuttons>
                                <ui:uibutton id="buttonEditCase" runat="server" alwaysenabled="True" 
                                    confirmtext="Please remember to save this Work before editing the Case.\n\nAre you sure you want to continue?" 
                                    imageurl="~/images/edit.gif" meta:resourcekey="buttonEditCaseResource1" 
                                    onclick="buttonEditCase_Click" text="Edit Case" />
                                <ui:uibutton id="buttonViewCase" runat="server" alwaysenabled="True" 
                                    confirmtext="Please remember to save this Work before viewing the Case.\n\nAre you sure you want to continue?" 
                                    imageurl="~/images/view.gif" meta:resourcekey="buttonViewCaseResource1" 
                                    onclick="buttonViewCase_Click" text="View Case" />
                            </contextmenubuttons>
                        </ui:uifieldsearchabledropdownlist>
                        <ui:uiseparator id="UISeparator1" runat="server" 
                            meta:resourcekey="UISeparator1Resource1" />
                        <ui:uifieldtreelist id="treeLocation" runat="server" caption="Location" 
                            meta:resourcekey="treeLocationResource1" 
                            onacquiretreepopulater="treeLocation_AcquireTreePopulater" 
                            onselectednodechanged="treeLocation_SelectedNodeChanged" 
                            propertyname="LocationID" showcheckboxes="None" treevaluemode="SelectedNode" 
                            validaterequiredfield="True">
                        </ui:uifieldtreelist>
                        <ui:uifieldtreelist id="treeEquipment" runat="server" caption="Equipment" 
                            meta:resourcekey="treeEquipmentResource1" 
                            onacquiretreepopulater="treeEquipment_AcquireTreePopulater" 
                            onselectednodechanged="treeEquipment_SelectedNodeChanged" 
                            propertyname="EquipmentID" showcheckboxes="None" treevaluemode="SelectedNode">
                        </ui:uifieldtreelist>
                        <ui:uifielddropdownlist id="dropPurchaseType" runat="server" caption="Type" 
                            meta:resourcekey="dropPurchaseTypeResource1" 
                            onselectedindexchanged="dropPurchaseType_SelectedIndexChanged" 
                            propertyname="PurchaseTypeID" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uifieldtextbox id="Description" runat="server" caption="Subject" 
                            internalcontrolwidth="95%" maxlength="255" 
                            meta:resourcekey="DescriptionResource1" propertyname="Description" 
                            validaterequiredfield="True">
                        </ui:uifieldtextbox>
                        <ui:uifieldcheckbox id="checkIsTermContract" runat="server" 
                            caption="Term Contract?" meta:resourcekey="checkIsTermContractResource1" 
                            oncheckedchanged="checkIsTermContract_CheckedChanged" 
                            propertyname="IsTermContract" 
                            text="Yes, this Request for Quotation is for a term contract." 
                            textalign="Right">
                        </ui:uifieldcheckbox>
                        <ui:uifielddatetime id="DateRequired" runat="server" caption="Date Required" 
                            imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" 
                            meta:resourcekey="DateRequiredResource1" 
                            ondatetimechanged="DateRequired_DateTimeChanged" propertyname="DateRequired" 
                            showdatecontrols="True" span="Half" validaterequiredfield="True">
                        </ui:uifielddatetime>
                        <ui:uifielddatetime id="DateEnd" runat="server" caption="Date End" 
                            imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" 
                            meta:resourcekey="DateEndResource1" propertyname="DateEnd" 
                            showdatecontrols="True" span="Half" validaterequiredfield="True">
                        </ui:uifielddatetime>
                        <ui:uifielddropdownlist id="StoreID" runat="server" caption="Store" 
                            enabled="False" meta:resourcekey="StoreIDResource1" propertyname="StoreID" 
                            span="Half">
                        </ui:uifielddropdownlist>
                        <ui:uifieldtextbox id="txtBackground" runat="server" caption="Background" 
                            internalcontrolwidth="95%" meta:resourcekey="txtBackgroundResource1" 
                            propertyname="Background" rows="3" textmode="MultiLine">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="txtScope" runat="server" caption="Scope" 
                            internalcontrolwidth="95%" meta:resourcekey="txtScopeResource1" 
                            propertyname="Scope" rows="3" textmode="MultiLine">
                        </ui:uifieldtextbox>
                        <br />
                        <br />
                        <br />
                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%">
                            <tr>
                                <td style="width: 49.5%">
                                    <ui:uipanel id="Panel1" runat="server" borderstyle="NotSet" 
                                        meta:resourcekey="Panel1Resource1">
                                        <asp:Label ID="Label1" runat="server" Font-Bold="True" 
                                            meta:resourceKey="Label1Resource1" Text="Ship To:"></asp:Label>
                                        <br />
                                        <ui:uifieldtextbox id="ShipToAddress" runat="server" caption="Address" 
                                            internalcontrolwidth="95%" meta:resourcekey="ShipToAddressResource1" 
                                            propertyname="ShipToAddress" rows="4" textmode="MultiLine">
                                        </ui:uifieldtextbox>
                                        <ui:uifieldtextbox id="ShipToAttention" runat="server" caption="Attention" 
                                            internalcontrolwidth="95%" meta:resourcekey="ShipToAttentionResource1" 
                                            propertyname="ShipToAttention">
                                        </ui:uifieldtextbox>
                                    </ui:uipanel>
                                </td>
                                <td style="width: 49.5%">
                                    <ui:uipanel id="Panel2" runat="server" borderstyle="NotSet" 
                                        meta:resourcekey="Panel2Resource1">
                                        <asp:Label ID="Label2" runat="server" Font-Bold="True" 
                                            meta:resourceKey="Label2Resource1" Text="Bill To:"></asp:Label>
                                        <br />
                                        <ui:uifieldtextbox id="BillToAddress" runat="server" caption="Address" 
                                            internalcontrolwidth="95%" meta:resourcekey="BillToAddressResource1" 
                                            propertyname="BillToAddress" rows="4" textmode="MultiLine">
                                        </ui:uifieldtextbox>
                                        <ui:uifieldtextbox id="BillToAttention" runat="server" caption="Attention" 
                                            internalcontrolwidth="95%" meta:resourcekey="BillToAttentionResource1" 
                                            propertyname="BillToAttention">
                                        </ui:uifieldtextbox>
                                    </ui:uipanel>
                                </td>
                            </tr>
                        </table>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabLineItems" runat="server" borderstyle="NotSet" 
                    caption="Line Items" meta:resourcekey="tabLineItemsResource1">
                    <ui:uipanel id="panelRequestForQuotationItems" runat="server" borderstyle="NotSet" 
                        meta:resourcekey="panelRequestForQuotationItemsResource1">
                        <ui:uibutton id="buttonAddMaterialItems" runat="server" causesvalidation="False" 
                            imageurl="~/images/add.gif" meta:resourcekey="buttonAddMaterialItemsResource1" 
                            onclick="buttonAddMaterialItems_Click" text="Add Multiple Inventory Items" />
                        <ui:uibutton id="buttonAddFixedrateItems" runat="server" causesvalidation="False" 
                            imageurl="~/images/add.gif" meta:resourcekey="buttonAddFixedrateItemsResource1" 
                            onclick="buttonAddFixedRateItems_Click" text="Add Multiple Service Items" />
                        <ui:uibutton id="buttonItemsAdded" runat="server" causesvalidation="False" 
                            meta:resourcekey="buttonItemsAddedResource1" onclick="buttonItemsAdded_Click" />
                        <br />
                        <br />
                        <ui:uigridview id="RequestForQuotationItems" runat="server" caption="Items" 
                            datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" keyname="ObjectID" 
                            meta:resourcekey="RequestForQuotationItemsResource2" pagingenabled="True" 
                            propertyname="RequestForQuotationItems" rowerrorcolor="" 
                            sortexpression="ItemNumber" style="clear:both;" width="100%">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" 
                                    commandname="DeleteObject" commandtext="Delete" 
                                    confirmtext="Are you sure you wish to delete the selected items?" 
                                    imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" 
                                    commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" 
                                    meta:resourcekey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" 
                                    imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" 
                                    confirmtext="Are you sure you wish to delete this item?" 
                                    imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:uigridviewboundcolumn datafield="ItemNumber" headertext="Number" 
                                    meta:resourcekey="UIGridViewColumnResource3" propertyname="ItemNumber" 
                                    resourceassemblyname="" sortexpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ItemTypeText" headertext="Type" 
                                    meta:resourcekey="UIGridViewColumnResource4" propertyname="ItemTypeText" 
                                    resourceassemblyname="" sortexpression="ItemTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ItemDescription" headertext="Description" 
                                    meta:resourcekey="UIGridViewColumnResource5" propertyname="ItemDescription" 
                                    resourceassemblyname="" sortexpression="ItemDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="UnitOfMeasure.ObjectName" 
                                    headertext="Unit of Measure" meta:resourcekey="UIGridViewColumnResource6" 
                                    propertyname="UnitOfMeasure.ObjectName" resourceassemblyname="" 
                                    sortexpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ReceiptModeText" headertext="Receipt Mode" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    propertyname="ReceiptModeText" resourceassemblyname="" 
                                    sortexpression="ReceiptModeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="QuantityRequired" 
                                    dataformatstring="{0:#,##0.00##}" headertext="Quantity Required" 
                                    meta:resourcekey="UIGridViewColumnResource7" propertyname="QuantityRequired" 
                                    resourceassemblyname="" sortexpression="QuantityRequired">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                            </Columns>
                        </ui:uigridview>
                        <ui:uiobjectpanel id="RequestForQuotationItem_Panel" runat="server" 
                            borderstyle="NotSet" meta:resourcekey="RequestForQuotationItem_PanelResource1">
                            <web:subpanel ID="RequestForQuotationItem_SubPanel" runat="server" 
                                GridViewID="RequestForQuotationItems" 
                                OnPopulateForm="RequestForQuotationItem_SubPanel_PopulateForm" 
                                OnRemoved="RequestForQuotationItem_SubPanel_Removed" 
                                OnValidateAndUpdate="RequestForQuotationItem_SubPanel_ValidateAndUpdate" />
                            <ui:uifielddropdownlist id="ItemNumber" runat="server" caption="Item Number" 
                                meta:resourcekey="ItemNumberResource1" propertyname="ItemNumber" span="Half" 
                                validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <ui:uifieldradiolist id="ItemType" runat="server" caption="Item Type" 
                                meta:resourcekey="ItemTypeResource1" 
                                onselectedindexchanged="ItemType_SelectedIndexChanged" propertyname="ItemType" 
                                repeatcolumns="0" textalign="Right" validaterequiredfield="True">
                                <Items>
                                    <asp:ListItem meta:resourceKey="ListItemResource1" Text="Inventory" Value="0"></asp:ListItem>
                                    <asp:ListItem meta:resourceKey="ListItemResource2" Text="Service" Value="1"></asp:ListItem>
                                    <asp:ListItem meta:resourceKey="ListItemResource3" Value="2">Others</asp:ListItem>
                                </Items>
                            </ui:uifieldradiolist>
                            <ui:uifieldtreelist id="CatalogueID" runat="server" caption="Catalog" 
                                meta:resourcekey="CatalogueIDResource1" 
                                onacquiretreepopulater="CatalogueID_AcquireTreePopulater" 
                                onselectednodechanged="CatalogueID_SelectedNodeChanged" 
                                propertyname="CatalogueID" showcheckboxes="None" treevaluemode="SelectedNode" 
                                validaterequiredfield="True">
                            </ui:uifieldtreelist>
                            <ui:uifieldtreelist id="FixedRateID" runat="server" caption="Fixed Rate" 
                                meta:resourcekey="FixedRateIDResource1" 
                                onacquiretreepopulater="FixedRateID_AcquireTreePopulater" 
                                onselectednodechanged="FixedRateID_SelectedNodeChanged" 
                                propertyname="FixedRateID" showcheckboxes="None" treevaluemode="SelectedNode" 
                                validaterequiredfield="True">
                            </ui:uifieldtreelist>
                            <ui:uifieldlabel id="UnitOfMeasure" runat="server" caption="Unit of Measure" 
                                dataformatstring="" meta:resourcekey="UnitOfMeasureResource1" 
                                propertyname="Catalogue.UnitOfMeasure.ObjectName">
                            </ui:uifieldlabel>
                            <ui:uifieldlabel id="UnitOfMeasure2" runat="server" caption="Unit of Measure" 
                                dataformatstring="" meta:resourcekey="UnitOfMeasure2Resource1" 
                                propertyname="FixedRate.UnitOfMeasure.ObjectName">
                            </ui:uifieldlabel>
                            <ui:uifieldtextbox id="ItemDescription" runat="server" caption="Description" 
                                internalcontrolwidth="95%" maxlength="255" 
                                meta:resourcekey="ItemDescriptionResource1" propertyname="ItemDescription" 
                                validaterequiredfield="True">
                            </ui:uifieldtextbox>
                            <ui:uifielddropdownlist id="UnitOfMeasureID" runat="server" 
                                caption="Unit of Measure" meta:resourcekey="UnitOfMeasureIDResource1" 
                                propertyname="UnitOfMeasureID" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <ui:uifieldradiolist id="radioReceiptMode" runat="server" caption="Receipt Mode" 
                                meta:resourcekey="radioReceiptModeResource1" 
                                onselectedindexchanged="radioReceiptMode_SelectedIndexChanged" 
                                propertyname="ReceiptMode" textalign="Right">
                                <Items>
                                    <asp:ListItem meta:resourcekey="ListItemResource4" Value="0">Receive by Quantity</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource5" Value="1">Receive by Dollar 
                                    Amount</asp:ListItem>
                                </Items>
                            </ui:uifieldradiolist>
                            <ui:uifieldtextbox id="textQuantityRequired" runat="server" 
                                caption="Quantity Required" internalcontrolwidth="95%" 
                                meta:resourcekey="QuantityRequiredResource1" propertyname="QuantityRequired" 
                                span="Half" validatedatatypecheck="True" validaterangefield="True" 
                                validaterequiredfield="True" validationdatatype="Currency" 
                                validationrangemax="99999999999999" validationrangemin="0" 
                                validationrangetype="Currency">
                            </ui:uifieldtextbox>
                        </ui:uiobjectpanel>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabQuotations" runat="server" borderstyle="NotSet" 
                    caption="Vendors &amp; Quotations" meta:resourcekey="tabQuotationsResource1">
                    <ui:uibutton id="buttonAddMultipleVendors" runat="server" causesvalidation="False" 
                        imageurl="~/images/add.gif" 
                        meta:resourcekey="buttonAddMultipleVendorsResource1" 
                        onclick="buttonAddMultipleVendors_Click" text="Add Multiple Vendors" />
                    <ui:uibutton id="buttonVendorsAdded" runat="server" causesvalidation="False" 
                        meta:resourcekey="buttonVendorsAddedResource1" 
                        onclick="buttonVendorsAdded_Click" />
                    <br />
                    <br />
                    <ui:uigridview id="RequestForQuotationVendors" runat="server" 
                        caption="Vendors' Quotations" datakeynames="ObjectID" gridlines="Both" 
                        imagerowerrorurl="" keyname="ObjectID" 
                        meta:resourcekey="RequestForQuotationVendorsResource1" 
                        onaction="RequestForQuotationVendor_Action" 
                        onrowdatabound="RequestForQuotationVendors_RowDataBound" pagingenabled="True" 
                        propertyname="RequestForQuotationVendors" rowerrorcolor="" 
                        sortexpression="Vendor.ObjectName" style="clear:both;" width="100%">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" 
                                commandname="DeleteObject" commandtext="Delete" 
                                confirmtext="Are you sure you wish to delete the selected items?" 
                                imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource3" />
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" 
                                commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" 
                                meta:resourcekey="UIGridViewCommandResource4" />
                        </commands>
                        <Columns>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" 
                                commandname="EditObject" imageurl="~/images/edit.gif" 
                                meta:resourcekey="UIGridViewColumnResource10">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" 
                                confirmtext="Are you sure you wish to delete this item?" 
                                imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource11">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="Vendor.ObjectName" headertext="Vendor Name" 
                                meta:resourcekey="UIGridViewColumnResource12" propertyname="Vendor.ObjectName" 
                                resourceassemblyname="" sortexpression="Vendor.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ContactEmail" headertext="Email" 
                                meta:resourcekey="UIGridViewColumnResource13" propertyname="ContactEmail" 
                                resourceassemblyname="" sortexpression="ContactEmail">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ContactPhone" headertext="Phone" 
                                meta:resourcekey="UIGridViewColumnResource14" propertyname="ContactPhone" 
                                resourceassemblyname="" sortexpression="ContactPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ContactCellPhone" headertext="Cell Phone" 
                                meta:resourcekey="UIGridViewColumnResource15" propertyname="ContactCellPhone" 
                                resourceassemblyname="" sortexpression="ContactCellPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ContactFax" headertext="Fax" 
                                meta:resourcekey="UIGridViewColumnResource16" propertyname="ContactFax" 
                                resourceassemblyname="" sortexpression="ContactFax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ContactPerson" headertext="Contact Person" 
                                meta:resourcekey="UIGridViewColumnResource17" propertyname="ContactPerson" 
                                resourceassemblyname="" sortexpression="ContactPerson">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="IsSubmittedText" headertext="Submitted" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" 
                                propertyname="IsSubmittedText" resourceassemblyname="" 
                                sortexpression="IsSubmittedText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="DateOfQuotation" 
                                dataformatstring="{0:dd-MMM-yyyy}" headertext="Date of Quotation" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" 
                                propertyname="DateOfQuotation" resourceassemblyname="" 
                                sortexpression="DateOfQuotation">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Currency.ObjectName" headertext="Currency" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" 
                                propertyname="Currency.ObjectName" resourceassemblyname="" 
                                sortexpression="Currency.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Currency.CurrencySymbol" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" 
                                propertyname="Currency.CurrencySymbol" resourceassemblyname="" 
                                sortexpression="Currency.CurrencySymbol">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalQuotationInSelectedCurrency" 
                                dataformatstring="{0:n}" headertext="Quotation" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" 
                                propertyname="TotalQuotationInSelectedCurrency" resourceassemblyname="" 
                                sortexpression="TotalQuotationInSelectedCurrency">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalQuotation" dataformatstring="{0:c}" 
                                headertext="Quotation" meta:resourcekey="UIGridViewColumnResource18" 
                                propertyname="TotalQuotation" resourceassemblyname="" 
                                sortexpression="TotalQuotation">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:uiobjectpanel id="RequestForQuotationVendors_Panel" runat="server" 
                        borderstyle="NotSet" 
                        meta:resourcekey="RequestForQuotationVendors_PanelResource1">
                        <web:subpanel ID="RequestForQuotationVendors_SubPanel" runat="server" 
                            GridViewID="RequestForQuotationVendors" 
                            OnPopulateForm="RequestForQuotationVendors_SubPanel_PopulateForm" 
                            OnRemoved="RequestForQuotationVendors_SubPanel_Removed" 
                            OnValidateAndUpdate="RequestForQuotationVendors_SubPanel_ValidateAndUpdate" />
                        <ui:uifieldsearchabledropdownlist id="dropVendor" runat="server" caption="Vendor" 
                            meta:resourcekey="dropVendorResource1" 
                            onselectedindexchanged="dropVendor_SelectedIndexChanged" 
                            propertyname="VendorID" searchinterval="300" validaterequiredfield="True">
                        </ui:uifieldsearchabledropdownlist>
                        <ui:uifieldcheckbox id="checkIsSubmitted" runat="server" caption="Submitted" 
                            meta:resourcekey="checkIsSubmittedResource1" 
                            oncheckedchanged="checkIsSubmitted_CheckedChanged" propertyname="IsSubmitted" 
                            text="Yes, a quotation has been submitted by the vendor." textalign="Right">
                        </ui:uifieldcheckbox>
                        <ui:uipanel id="panelQuotationDetails" runat="server" borderstyle="NotSet" 
                            meta:resourcekey="panelQuotationDetailsResource1">
                            <ui:uifielddatetime id="dateDateOfQuotation" runat="server" 
                                caption="Date of Quotation" meta:resourcekey="dateDateOfQuotationResource1" 
                                ondatetimechanged="dateDateOfQuotation_DateTimeChanged" 
                                propertyname="DateOfQuotation" showdatecontrols="True" 
                                validaterequiredfield="True">
                            </ui:uifielddatetime>
                            <ui:uifieldcheckbox id="checkShowOptionalDetails" runat="server" caption="Details" 
                                meta:resourcekey="checkShowOptionalDetailsResource1" 
                                oncheckedchanged="checkShowOptionalDetails_CheckedChanged" 
                                text="Yes, I want to see/update more detailed information about this quotation." 
                                textalign="Right">
                            </ui:uifieldcheckbox>
                            <ui:uipanel id="panelQuotationOptionalDetails" runat="server" borderstyle="NotSet" 
                                meta:resourcekey="panelQuotationOptionalDetailsResource1">
                                <ui:uifieldtextbox id="ContactAddressCountry" runat="server" caption="Country" 
                                    internalcontrolwidth="95%" maxlength="255" 
                                    meta:resourcekey="ContactAddressCountryResource1" 
                                    propertyname="ContactAddressCountry" span="Half">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactAddressState" runat="server" caption="State" 
                                    internalcontrolwidth="95%" maxlength="255" 
                                    meta:resourcekey="ContactAddressStateResource1" 
                                    propertyname="ContactAddressState" span="Half">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactAddressCity" runat="server" caption="City" 
                                    internalcontrolwidth="95%" maxlength="255" 
                                    meta:resourcekey="ContactAddressCityResource1" 
                                    propertyname="ContactAddressCity" span="Half">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactAddress" runat="server" caption="Address" 
                                    internalcontrolwidth="95%" maxlength="255" 
                                    meta:resourcekey="ContactAddressResource1" propertyname="ContactAddress">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactCellPhone" runat="server" caption="Cellphone" 
                                    internalcontrolwidth="95%" meta:resourcekey="ContactCellPhoneResource1" 
                                    propertyname="ContactCellPhone" span="Half">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactEmail" runat="server" caption="Email" 
                                    internalcontrolwidth="95%" meta:resourcekey="ContactEmailResource1" 
                                    propertyname="ContactEmail" span="Half">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactFax" runat="server" caption="Fax" 
                                    internalcontrolwidth="95%" meta:resourcekey="ContactFaxResource1" 
                                    propertyname="ContactFax" span="Half">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactPhone" runat="server" caption="Phone" 
                                    internalcontrolwidth="95%" meta:resourcekey="ContactPhoneResource1" 
                                    propertyname="ContactPhone" span="Half">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="ContactPerson" runat="server" caption="Contact Person" 
                                    internalcontrolwidth="95%" meta:resourcekey="ContactPersonResource1" 
                                    propertyname="ContactPerson">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="FreightTerms" runat="server" caption="Freight Terms" 
                                    internalcontrolwidth="95%" meta:resourcekey="FreightTermsResource1" 
                                    propertyname="FreightTerms" rows="3" textmode="MultiLine">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="PaymentTerms" runat="server" caption="Payment Terms" 
                                    internalcontrolwidth="95%" meta:resourcekey="PaymentTermsResource1" 
                                    propertyname="PaymentTerms" rows="3" textmode="MultiLine">
                                </ui:uifieldtextbox>
                            </ui:uipanel>
                            <ui:uifielddropdownlist id="dropCurrency" runat="server" caption="Main Currency" 
                                meta:resourcekey="dropCurrencyResource1" 
                                onselectedindexchanged="dropCurrency_SelectedIndexChanged" 
                                propertyname="CurrencyID" span="Half" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <table border="0" cellpadding="0" cellspacing="0" 
                                style="clear: both; width: 50%">
                                <tr class="field-required" style="height: 25px">
                                    <td style="width: 150px">
                                        <asp:Label ID="labelExchangeRate" runat="server" 
                                            meta:resourcekey="labelExchangeRateResource1">Exchange Rate*:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="labelER1" runat="server" meta:resourcekey="labelER1Resource1">1</asp:Label>
                                        <ui:uifieldlabel id="labelERThisCurrency" runat="server" dataformatstring="" 
                                            fieldlayout="Flow" internalcontrolwidth="20px" 
                                            meta:resourcekey="labelERThisCurrencyResource1" 
                                            propertyname="Currency.ObjectName" showcaption="False">
                                        </ui:uifieldlabel>
                                        <asp:Label ID="labelEREquals" runat="server" 
                                            meta:resourcekey="labelEREqualsResource1">is equal to</asp:Label>
                                        <ui:uifieldtextbox id="textForeignToBaseExchangeRate" runat="server" 
                                            caption="Exchange Rate" fieldlayout="Flow" internalcontrolwidth="60px" 
                                            meta:resourcekey="textForeignToBaseExchangeRateResource1" 
                                            propertyname="ForeignToBaseExchangeRate" showcaption="False" span="Half" 
                                            validatedatatypecheck="True" validaterequiredfield="True" 
                                            validationdatatype="Currency">
                                        </ui:uifieldtextbox>
                                        <asp:Label ID="labelERBaseCurrency" runat="server" 
                                            meta:resourcekey="labelERBaseCurrencyResource1"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <ui:uigridview id="RequestForQuotationVendorItems" runat="server" 
                                bindobjectstorows="True" caption="Quotation" checkboxcolumnvisible="False" 
                                datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" keyname="ObjectID" 
                                meta:resourcekey="RequestForQuotationVendorItemsResource1" 
                                onrowdatabound="RequestForQuotationVendorItems_RowDataBound" pagesize="1000" 
                                pagingenabled="True" propertyname="RequestForQuotationVendorItems" 
                                rowerrorcolor="" sortexpression="[ItemNumber] ASC" style="clear:both;" 
                                width="100%">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Columns>
                                    <ui:uigridviewboundcolumn datafield="ItemNumber" headertext="Number" 
                                        meta:resourcekey="UIGridViewColumnResource19" propertyname="ItemNumber" 
                                        resourceassemblyname="" sortexpression="ItemNumber">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:uigridviewboundcolumn>
                                    <ui:uigridviewboundcolumn datafield="ItemTypeText" headertext="Type" 
                                        meta:resourcekey="UIGridViewColumnResource20" propertyname="ItemTypeText" 
                                        resourceassemblyname="" sortexpression="ItemTypeText">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:uigridviewboundcolumn>
                                    <ui:uigridviewboundcolumn datafield="ItemDescription" headertext="Description" 
                                        meta:resourcekey="UIGridViewColumnResource21" propertyname="ItemDescription" 
                                        resourceassemblyname="" sortexpression="ItemDescription">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:uigridviewboundcolumn>
                                    <ui:uigridviewboundcolumn datafield="Catalogue.UnitOfMeasure.ObjectName" 
                                        headertext="Unit of Measure" meta:resourcekey="UIGridViewColumnResource22" 
                                        propertyname="Catalogue.UnitOfMeasure.ObjectName" resourceassemblyname="" 
                                        sortexpression="Catalogue.UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:uigridviewboundcolumn>
                                    <ui:uigridviewtemplatecolumn headertext="Quantity Provided" 
                                        meta:resourcekey="UIGridViewColumnResource23">
                                        <ItemTemplate>
                                            <ui:uifieldtextbox id="QuantityProvided" runat="server" caption="Quantity" 
                                                captionwidth="1px" fieldlayout="Flow" internalcontrolwidth="60px" 
                                                meta:resourcekey="QuantityProvidedResource1" propertyname="QuantityProvided" 
                                                validatedatatypecheck="True" validaterangefield="True" 
                                                validaterequiredfield="True" validationdatatype="Currency" 
                                                validationrangemax="99999999999999" validationrangemin="0" 
                                                validationrangetype="Currency">
                                            </ui:uifieldtextbox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:uigridviewtemplatecolumn>
                                    <ui:uigridviewtemplatecolumn headertext="Unit Price" 
                                        meta:resourcekey="UIGridViewColumnResource24">
                                        <ItemTemplate>
                                            <ui:uifieldtextbox id="UnitPrice" runat="server" caption="Unit Price" 
                                                captionwidth="1px" fieldlayout="Flow" internalcontrolwidth="60px" 
                                                meta:resourcekey="UnitPriceResource1" 
                                                propertyname="UnitPriceInSelectedCurrency" validatedatatypecheck="True" 
                                                validaterangefield="True" validaterequiredfield="True" 
                                                validationdatatype="Currency" validationrangemax="99999999999999" 
                                                validationrangemin="0" validationrangetype="Currency">
                                            </ui:uifieldtextbox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </ui:uigridviewtemplatecolumn>
                                </Columns>
                            </ui:uigridview>
                        </ui:uipanel>
                    </ui:uiobjectpanel>
                </ui:uitabview>
                <ui:uitabview id="tabAward" runat="server" borderstyle="NotSet" caption="Award" 
                    meta:resourcekey="tabAwardResource1">
                    <ui:uigridview id="gridAwardItems" runat="server" caption="Items" 
                        datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" keyname="ObjectID" 
                        meta:resourcekey="gridAwardItemsResource1" 
                        onrowdatabound="gridAwardItems_RowDataBound" pagesize="200" 
                        pagingenabled="True" propertyname="RequestForQuotationItems" rowerrorcolor="" 
                        showfooter="True" sortexpression="ItemNumber" style="clear:both;" width="100%">
                        <PagerSettings Mode="NumericFirstLast" Visible="False" />
                        <Columns>
                            <ui:uigridviewboundcolumn datafield="ItemNumber" headertext="Number" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" propertyname="ItemNumber" 
                                resourceassemblyname="" sortexpression="ItemNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ItemTypeText" headertext="Type" 
                                meta:resourcekey="UIGridViewBoundColumnResource8" propertyname="ItemTypeText" 
                                resourceassemblyname="" sortexpression="ItemTypeText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ItemDescription" headertext="Description" 
                                meta:resourcekey="UIGridViewBoundColumnResource9" 
                                propertyname="ItemDescription" resourceassemblyname="" 
                                sortexpression="ItemDescription">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="UnitOfMeasure.ObjectName" 
                                headertext="Unit of Measure" meta:resourcekey="UIGridViewBoundColumnResource10" 
                                propertyname="UnitOfMeasure.ObjectName" resourceassemblyname="" 
                                sortexpression="UnitOfMeasure.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ReceiptModeText" headertext="Receipt Mode" 
                                meta:resourcekey="UIGridViewBoundColumnResource11" 
                                propertyname="ReceiptModeText" resourceassemblyname="" 
                                sortexpression="ReceiptModeText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="QuantityRequired" 
                                dataformatstring="{0:#,##0.00##}" headertext="Quantity Required" 
                                meta:resourcekey="UIGridViewBoundColumnResource12" 
                                propertyname="QuantityRequired" resourceassemblyname="" 
                                sortexpression="QuantityRequired">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="AwardedVendor.ObjectName" 
                                headertext="Vendor Awarded" meta:resourcekey="UIGridViewBoundColumnResource13" 
                                propertyname="AwardedVendor.ObjectName" resourceassemblyname="" 
                                sortexpression="AwardedVendor.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Currency.ObjectName" headertext="Currency" 
                                meta:resourcekey="UIGridViewBoundColumnResource14" 
                                propertyname="Currency.ObjectName" resourceassemblyname="" 
                                sortexpression="Currency.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Currency.CurrencySymbol" 
                                meta:resourcekey="UIGridViewBoundColumnResource15" 
                                propertyname="Currency.CurrencySymbol" resourceassemblyname="" 
                                sortexpression="Currency.CurrencySymbol">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="UnitPriceInSelectedCurrency" 
                                dataformatstring="{0:n}" headertext="Unit Price" 
                                meta:resourcekey="UIGridViewBoundColumnResource16" 
                                propertyname="UnitPriceInSelectedCurrency" resourceassemblyname="" 
                                sortexpression="UnitPriceInSelectedCurrency">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="UnitPrice" dataformatstring="{0:c}" 
                                headertext="Unit Price&lt;br/&gt;(Base Currency)" htmlencode="False" 
                                meta:resourcekey="UIGridViewBoundColumnResource17" propertyname="UnitPrice" 
                                resourceassemblyname="" sortexpression="UnitPrice">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="QuantityProvided" 
                                dataformatstring="{0:#,##0.00##}" headertext="Quantity Provided" 
                                meta:resourcekey="UIGridViewBoundColumnResource18" 
                                propertyname="QuantityProvided" resourceassemblyname="" 
                                sortexpression="QuantityProvided">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Subtotal" dataformatstring="{0:c}" 
                                footeraggregate="Sum" headertext="Subtotal&lt;br/&gt;(Base Currency)" 
                                htmlencode="False" meta:resourcekey="UIGridViewBoundColumnResource19" 
                                propertyname="Subtotal" resourceassemblyname="" sortexpression="Subtotal">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="CopiedToObjectNumber" headertext="Copied To" 
                                meta:resourcekey="UIGridViewBoundColumnResource20" 
                                propertyname="CopiedToObjectNumber" resourceassemblyname="" 
                                sortexpression="CopiedToObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:uihint id="hintQuotationPolicy" runat="server" imageurl="~/images/error.gif" 
                        meta:resourcekey="hintQuotationPolicyResource1">
                        <asp:Table runat="server" CellPadding="4" CellSpacing="0" Width="100%">
                            <asp:TableRow runat="server">
                                <asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image 
                                    runat="server" ImageUrl="~/images/error.gif" />
                                </asp:TableCell>
                                <asp:TableCell runat="server" VerticalAlign="Top"><asp:Label runat="server"></asp:Label>
                                </asp:TableCell>
                            </asp:TableRow>
                        </asp:Table>
                    </ui:uihint>
                    <br />
                    <ui:uipanel id="panelAwardVendor" runat="server" borderstyle="NotSet" 
                        meta:resourcekey="panelAwardResource1">
                        <ui:uifielddropdownlist id="dropVendorToAward" runat="server" 
                            caption="Select to Award to Vendor" captionwidth="150px" 
                            meta:resourcekey="dropVendorToAwardResource1" 
                            onselectedindexchanged="dropVendorToAward_SelectedIndexChanged">
                        </ui:uifielddropdownlist>
                        <table border="0" cellpadding="0" cellspacing="0" style="clear:both">
                            <tr>
                                <td>
                                    <ui:uibutton id="buttonClearAwardOnSelectedItems" runat="server" 
                                        causesvalidation="False" imageurl="~/images/delete.gif" 
                                        meta:resourcekey="buttonClearAwardOnSelectedItemsResource1" 
                                        onclick="buttonClearAwardOnSelectedItems_Click" 
                                        text="Clear the award for selected items" />
                                </td>
                            </tr>
                        </table>
                        <br />
                        <br />
                    </ui:uipanel>
                    <ui:uipanel id="panelGeneratePOButton" runat="server" borderstyle="NotSet" 
                        meta:resourcekey="panelGeneratePOButtonResource1">
                        <ui:uibutton id="buttonGeneratePOFromLineItems" runat="server" 
                            confirmtext="Are you sure you wish to generate a Purchase Order from the selected line items?" 
                            imageurl="~/images/add.gif" meta:resourcekey="buttonGeneratePOResource1" 
                            onclick="buttonGeneratePOFromLineItems_Click" 
                            text="Generate PO from Selected Line Items" />
                        <ui:uibutton id="buttonGeneratePO" runat="server" 
                            confirmtext="Are you sure you wish to generate a Purchase Order from this Request for Quotation?" 
                            imageurl="~/images/add.gif" meta:resourcekey="buttonGeneratePOResource2" 
                            onclick="buttonGeneratePO_Click" text="Generate PO for all items in this RFQ" />
                        <br />
                        <br />
                    </ui:uipanel>
                    <br />
                    <ui:uiseparator id="sep1" runat="server" caption="Justification" 
                        meta:resourcekey="sep1Resource1" />
                    <ui:uipanel id="panelAward" runat="server" borderstyle="NotSet" 
                        meta:resourcekey="panelAwardResource1">
                        <ui:uipanel id="panelAwardSelection" runat="server" borderstyle="NotSet" 
                            meta:resourcekey="panelAwardSelectionResource1">
                            <ui:uifieldtextbox id="AwardedJustification" runat="server" 
                                caption="Justification" internalcontrolwidth="95%" maxlength="1024" 
                                meta:resourcekey="AwardedJustificationResource1" 
                                propertyname="AwardedJustification" validaterequiredfield="True">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="txtWarranty" runat="server" caption="Warranty" 
                                internalcontrolwidth="95%" meta:resourcekey="txtWarrantyResource1" 
                                propertyname="Warranty">
                            </ui:uifieldtextbox>
                            <ui:uifieldtextbox id="txtEvaluation" runat="server" caption="Evaluation" 
                                internalcontrolwidth="95%" meta:resourcekey="txtEvaluationResource1" 
                                propertyname="Evaluation" rows="3" textmode="MultiLine">
                            </ui:uifieldtextbox>
                            <br />
                        </ui:uipanel>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabBudget" runat="server" borderstyle="NotSet" caption="Budget" 
                    meta:resourcekey="tabBudgetResource1">
                    <ui:uifieldradiolist id="radioBudgetDistributionMode" runat="server" 
                        caption="Budget Distribution" 
                        meta:resourcekey="radioBudgetDistributionModeResource1" 
                        onselectedindexchanged="radioBudgetDistributionMode_SelectedIndexChanged" 
                        propertyname="BudgetDistributionMode" textalign="Right" 
                        validaterequiredfield="True">
                        <Items>
                            <asp:ListItem meta:resourcekey="ListItemResource6" Value="0">By entire Request 
                            for Quotation</asp:ListItem>
                            <asp:ListItem meta:resourcekey="ListItemResource7" Value="1">By individual 
                            Request for Quotation items</asp:ListItem>
                        </Items>
                    </ui:uifieldradiolist>
                    <ui:uigridview id="gridBudget" runat="server" caption="Budgets" 
                        datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" 
                        meta:resourcekey="gridBudgetResource1" pagesize="50" 
                        propertyname="PurchaseBudgets" rowerrorcolor="" showfooter="True" 
                        sortexpression="ItemNumber ASC" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" 
                                commandname="DeleteObject" commandtext="Delete" 
                                confirmtext="Are you sure you wish to delete the selected items?" 
                                imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource5" />
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" 
                                commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" 
                                meta:resourcekey="UIGridViewCommandResource6" />
                        </commands>
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" 
                                imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" 
                                confirmtext="Are you sure you wish to delete this item?" 
                                imageurl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ItemNumber" headertext="Number" 
                                meta:resourcekey="UIGridViewBoundColumnResource21" propertyname="ItemNumber" 
                                resourceassemblyname="" sortexpression="ItemNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Budget.ObjectName" headertext="Budget" 
                                meta:resourcekey="UIGridViewBoundColumnResource22" 
                                propertyname="Budget.ObjectName" resourceassemblyname="" 
                                sortexpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.Path" headertext="Account" 
                                meta:resourcekey="UIGridViewBoundColumnResource23" propertyname="Account.Path" 
                                resourceassemblyname="" sortexpression="Account.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.AccountCode" 
                                headertext="Account Code" meta:resourcekey="UIGridViewBoundColumnResource24" 
                                propertyname="Account.AccountCode" resourceassemblyname="" 
                                sortexpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="StartDate" dataformatstring="{0:dd-MMM-yyyy}" 
                                headertext="Start Date" meta:resourcekey="UIGridViewBoundColumnResource25" 
                                propertyname="StartDate" resourceassemblyname="" sortexpression="StartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="EndDate" dataformatstring="{0:dd-MMM-yyyy}" 
                                headertext="End Date" meta:resourcekey="UIGridViewBoundColumnResource26" 
                                propertyname="EndDate" resourceassemblyname="" sortexpression="EndDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="AccrualFrequencyInMonths" 
                                headertext="Accrual Frequency (in months)" 
                                meta:resourcekey="UIGridViewBoundColumnResource27" 
                                propertyname="AccrualFrequencyInMonths" resourceassemblyname="" 
                                sortexpression="AccrualFrequencyInMonths">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Amount" dataformatstring="{0:#,##0.00}" 
                                footeraggregate="Sum" headertext="Amount" 
                                meta:resourcekey="UIGridViewBoundColumnResource28" propertyname="Amount" 
                                resourceassemblyname="" sortexpression="Amount">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:uiobjectpanel id="panelBudget" runat="server" borderstyle="NotSet" 
                        meta:resourcekey="panelBudgetResource1">
                        <web:subpanel ID="subpanelBudget" runat="server" GridViewID="gridBudget" 
                            OnPopulateForm="subpanelBudget_PopulateForm" OnRemoved="subpanelBudget_Removed" 
                            OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate" />
                        <ui:uifielddropdownlist id="dropItemNumber" runat="server" caption="Item Number" 
                            meta:resourcekey="dropItemNumberResource1" propertyname="ItemNumber" 
                            validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uifielddropdownlist id="dropBudget" runat="server" caption="Budget" 
                            meta:resourcekey="dropBudgetResource1" 
                            onselectedindexchanged="dropBudget_SelectedIndexChanged" 
                            propertyname="BudgetID" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uifielddatetime id="dateStartDate" runat="server" caption="Start Date" 
                            meta:resourcekey="dateStartDateResource1" 
                            ondatetimechanged="dateStartDate_DateTimeChanged" propertyname="StartDate" 
                            showdatecontrols="True" span="Half" validaterequiredfield="True" 
                            validationcomparecontrol="dateEndDate" 
                            validationcompareoperator="LessThanEqual" validationcomparetype="Date">
                        </ui:uifielddatetime>
                        <ui:uifielddatetime id="dateEndDate" runat="server" caption="End Date" 
                            meta:resourcekey="dateEndDateResource1" propertyname="EndDate" 
                            showdatecontrols="True" span="Half" validatecomparefield="True" 
                            validaterequiredfield="True" validationcomparecontrol="dateStartDate" 
                            validationcompareoperator="GreaterThanEqual" validationcomparetype="Date">
                        </ui:uifielddatetime>
                        <ui:uifieldtextbox id="textAccrualFrequency" runat="server" 
                            caption="Accrual Frequency (months)" internalcontrolwidth="95%" 
                            meta:resourcekey="textAccrualFrequencyResource1" 
                            propertyname="AccrualFrequencyInMonths" span="Half" validaterangefield="True" 
                            validaterequiredfield="True" validationrangemin="1" 
                            validationrangetype="Currency">
                        </ui:uifieldtextbox>
                        <ui:uifieldtreelist id="treeAccount" runat="server" caption="Account" 
                            meta:resourcekey="treeAccountResource1" 
                            onacquiretreepopulater="treeAccount_AcquireTreePopulater" 
                            propertyname="AccountID" showcheckboxes="None" treevaluemode="SelectedNode" 
                            validaterequiredfield="True">
                        </ui:uifieldtreelist>
                        <ui:uifieldtextbox id="textAmount" runat="server" caption="Amount" 
                            internalcontrolwidth="95%" meta:resourcekey="textAmountResource1" 
                            propertyname="Amount" span="Half" validaterequiredfield="True" 
                            validationrangemin="1" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                    </ui:uiobjectpanel>
                    <br />
                    <br />
                    <ui:uigridview id="gridBudgetSummary" runat="server" caption="Budget Summary" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" 
                        imagerowerrorurl="" meta:resourcekey="gridBudgetSummaryResource1" 
                        onaction="gridBudgetSummary_Action" pagesize="50" 
                        propertyname="PurchaseBudgetSummaries" rowerrorcolor="" showfooter="True" 
                        style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewboundcolumn datafield="Budget.ObjectName" headertext="Budget" 
                                meta:resourcekey="UIGridViewBoundColumnResource29" 
                                propertyname="Budget.ObjectName" resourceassemblyname="" 
                                sortexpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="BudgetPeriod.ObjectName" 
                                headertext="Budget Period" meta:resourcekey="UIGridViewBoundColumnResource30" 
                                propertyname="BudgetPeriod.ObjectName" resourceassemblyname="" 
                                sortexpression="BudgetPeriod.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" 
                                commandname="ViewBudget" imageurl="~/images/printer.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="Account.ObjectName" headertext="Account" 
                                meta:resourcekey="UIGridViewBoundColumnResource31" 
                                propertyname="Account.ObjectName" resourceassemblyname="" 
                                sortexpression="Account.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.AccountCode" 
                                headertext="Account Code" meta:resourcekey="UIGridViewBoundColumnResource32" 
                                propertyname="Account.AccountCode" resourceassemblyname="" 
                                sortexpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAdjusted" 
                                dataformatstring="{0:c}" footeraggregate="Sum" 
                                headertext="Total After Adjustments" 
                                meta:resourcekey="UIGridViewBoundColumnResource33" 
                                propertyname="TotalAvailableAdjusted" resourceassemblyname="" 
                                sortexpression="TotalAvailableAdjusted">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableBeforeSubmission" 
                                dataformatstring="{0:c}" footeraggregate="Sum" 
                                headertext="Total Before Submission" 
                                meta:resourcekey="UIGridViewBoundColumnResource34" 
                                propertyname="TotalAvailableBeforeSubmission" resourceassemblyname="" 
                                sortexpression="TotalAvailableBeforeSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAtSubmission" 
                                dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total At Submission" 
                                meta:resourcekey="UIGridViewBoundColumnResource35" 
                                propertyname="TotalAvailableAtSubmission" resourceassemblyname="" 
                                sortexpression="TotalAvailableAtSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAfterApproval" 
                                dataformatstring="{0:c}" footeraggregate="Sum" 
                                headertext="Total After Approval" 
                                meta:resourcekey="UIGridViewBoundColumnResource36" 
                                propertyname="TotalAvailableAfterApproval" resourceassemblyname="" 
                                sortexpression="TotalAvailableAfterApproval">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="uitabview1" runat="server" borderstyle="NotSet" 
                    caption="Status History" meta:resourcekey="uitabview1Resource1">
                    <web:ActivityHistory ID="ActivityHistory" runat="server" />
                </ui:uitabview>
                <ui:uitabview id="tabMemo" runat="server" borderstyle="NotSet" caption="Memo" 
                    meta:resourcekey="tabMemoResource1">
                    <web:memo ID="memo1" runat="server" />
                </ui:uitabview>
                <ui:uitabview id="tabAttachments" runat="server" borderstyle="NotSet" 
                    caption="Attachments" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:uitabview>
            </ui:uitabstrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
