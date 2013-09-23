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
        OPurchaseRequest purchaseRequest = (OPurchaseRequest)panel.SessionObject;

        if (purchaseRequest.CurrentActivity == null ||
                    purchaseRequest.CurrentActivity.ObjectName.Is("Draft", "PendingInvitation", "PendingQuotation", "PendingEvaluation"))
            purchaseRequest.UpdateApplicablePurchaseSettings();
        
        PurchaseRequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(
            purchaseRequest.PurchaseRequestor, purchaseRequest.Location, "PURCHASEREQUESTOR"));
        
        dropPurchaseTypeClassification.Bind(OCode.GetCodesByType("PurchaseTypeClassification", null));
        if (purchaseRequest.TransactionTypeGroupID != null)
            dropPurchaseType.Bind(TablesLogic.tCode.LoadList(TablesLogic.tCode.ParentID == purchaseRequest.TransactionTypeGroupID));
        else
            dropPurchaseType.Items.Clear();
        BudgetGroupID.Bind(AppSession.User.GetAllAccessibleBudgetGroup("OPurchaseRequest", purchaseRequest.BudgetGroupID), true);
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, purchaseRequest.LocationID));
        //treeLocation.PopulateTree();
        //treeEquipment.PopulateTree();
        treeQuickAddAccount.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(purchaseRequest);
    }

    /// <summary>
    /// Validates and saves the purchase request.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
            panel.ObjectPanel.BindControlsToObject(purchaseRequest);

            if (objectBase.SelectedAction == "Cancel")
            {
                // Validate to ensure that none of the selected
                // WJ items have been generated to RFQs/POs.
                //
                List<Guid> prItemIds = new List<Guid>();
                foreach (OPurchaseRequestItem pri in purchaseRequest.PurchaseRequestItems)
                    prItemIds.Add(pri.ObjectID.Value);
                string lineItems = OPurchaseRequest.ValidatePRLineItemsNotGeneratedToRFQOrPO(prItemIds);
                if (lineItems.Length != 0)
                    PurchaseRequestItems.ErrorMessage = Resources.Errors.PurchaseRequest_CannotBeCancelledItemsGeneratedToRFQOrPO;
            }
            
            if (objectBase.SelectedAction == "SubmitForApproval")
            {
                // Ensure that all budget accounts in the budget
                // line items are set as active.
                //
                string inactiveAccounts = OPurchaseBudget.ValidateBudgetAccountsAreActive(purchaseRequest.PurchaseBudgets);
                if (inactiveAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseRequest_BudgetAccountsNotActive, inactiveAccounts);
                }

                // Ensure that the budget periods covering the start date of
                // the purchase order exists, and has not yet been closed.
                //
                string closedBudgets = OPurchaseBudget.ValidateBudgetPeriodsActiveAndOpened(purchaseRequest.PurchaseBudgets);
                if (closedBudgets != "")
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseRequest_BudgetPeriodsClosed, closedBudgets);

                // Ensure that the budget line items match the
                // RFQ line items in amount.
                //
                int itemNumber = purchaseRequest.ValidateBudgetAmountEqualsLineItemAmount();
                if (itemNumber >= 0)
                {
                    string itemNumberText = "";
                    if (itemNumber > 0)
                        itemNumberText = String.Format(Resources.Errors.PurchaseRequest_ItemAmountNotEqualsBudgetAmount_LineItem, itemNumber);
                    else
                        itemNumberText = Resources.Errors.PurchaseRequest_ItemAmountNotEqualsBudgetAmount_EntirePR;

                    if (purchaseRequest.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems)
                        gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseRequest_ItemAmountNotEqualsBudgetAmount, itemNumberText);
                    else if (purchaseRequest.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems)
                        gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseRequest_ItemAmountLessThanBudgetAmount, itemNumberText);
                }

                // Ensure that all purchase budgets adhere to the 
                // budget spending policy.
                //
                string budgetsWithNoPeriod = purchaseRequest.ValidateBudgetSpendingPolicy();
                if (budgetsWithNoPeriod != "")
                {
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseRequest_BudgetNoPeriod, budgetsWithNoPeriod); ;
                }

                // Ensure budget is sufficient.
                //
                string insufficientAccounts = purchaseRequest.ValidateSufficientBudget();
                if (insufficientAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseRequest_InsufficientBudget, insufficientAccounts);
                }

                //// Ensure that number of quotations is sufficient.
                //if (requestForQuotation.ValidateSufficientNumberOfQuotations() == 0)
                //{
                //    RequestForQuotationVendors.ErrorMessage =
                //        String.Format(Resources.Errors.RequestForQuotation_InsufficientQuotations, requestForQuotation.MinimumNumberOfQuotations);
                //}
            }
            
            if (!panel.ObjectPanel.IsValid)
                return;
            
            // Save
            //
            purchaseRequest.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Populates the purchase request item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseRequestItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;

        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", purchaseRequestItem.UnitOfMeasureID));
        CatalogueID.PopulateTree();
        FixedRateID.PopulateTree();

        ItemNumber.Items.Clear();
        for (int i = 1; i <= purchaseRequest.PurchaseRequestItems.Count + 1; i++)
            ItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (purchaseRequestItem.IsNew && purchaseRequestItem.ItemNumber == null)
            purchaseRequestItem.ItemNumber = purchaseRequest.PurchaseRequestItems.Count + 1;

        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(purchaseRequestItem);
    }

    /// <summary>
    /// Validates and inserts the purchase request item into the 
    /// purchase request object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseRequestItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseRequestItem i = (OPurchaseRequestItem)PurchaseRequestItem_SubPanel.SessionObject;

        int itemNumber = i.ItemNumber.Value;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(i);

        // Update certain fields.
        //
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

        // Add
        //        
        OPurchaseRequest p = (OPurchaseRequest)panel.SessionObject;
        p.PurchaseRequestItems.Add(i);
        p.ReorderItems(i);
        panelLineItems.BindObjectToControls(p);
    }

    //---------------------------------------------------------------    
    // event
    //---------------------------------------------------------------
    protected void PurchaseRequestItem_SubPanel_Deleted(object sender, EventArgs e)
    {
        OPurchaseRequest p = (OPurchaseRequest)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(p);
        p.ReorderItems(null);

        panel.ObjectPanel.BindObjectToControls(p);
    }

    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OPurchaseRequest obj = (OPurchaseRequest)panel.SessionObject;
        objectBase.ObjectNumberVisible = !obj.IsNew;

        StoreID.Visible = obj.StoreID != null;
        CatalogueID.Visible = ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        UnitOfMeasure.Visible = ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        UnitOfMeasure2.Visible = ItemType.SelectedValue == PurchaseItemType.Service.ToString();
        FixedRateID.Visible = ItemType.SelectedValue == PurchaseItemType.Service.ToString();
        UnitOfMeasureID.Visible = ItemType.SelectedValue == PurchaseItemType.Others.ToString();
        ItemDescription.Visible = ItemType.SelectedValue == PurchaseItemType.Others.ToString();
        radioReceiptMode.Enabled = ItemType.SelectedValue != PurchaseItemType.Material.ToString();
        textQuantityRequired.Enabled = radioReceiptMode.SelectedValue != ReceiptModeType.Dollar.ToString() || ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        tabBudget.Visible =
                    //treeLocation.SelectedItem != "" &&
                    ddlLocation.SelectedValue != "" &&
                    DateRequired.DateTime != null
                    //&& obj.ValidateSufficientNumberOfQuotations() != 0 
                    && obj.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;
        
        if (obj.TransactionTypeGroupID == null && dropPurchaseTypeClassification.Items.Count == 2)
        {
            dropPurchaseTypeClassification.SelectedIndex = 1;
            dropPurchaseType.Bind(TablesLogic.tCode.LoadList(TablesLogic.tCode.ParentID == new Guid(dropPurchaseTypeClassification.SelectedValue)));
        }
        dropPurchaseType.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        dropPurchaseTypeClassification.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        BudgetGroupID.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        
        Workflow_Setting();
    }


    /// <summary>
    /// Hides/shows or enables/disables elements based on the workflow.
    /// </summary>
    protected void Workflow_Setting()
    {
        tabDetails.Enabled = !objectBase.CurrentObjectState.Is("Closed", "Cancelled");
        panelDetails.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");
        panelLineItems.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");

        panelButtons.Visible = objectBase.CurrentObjectState.Is("Approved");
        panelAddMultipleItems.Visible = objectBase.CurrentObjectState.Is("Start", "Draft");
        dropPurchaseType.ValidateRequiredField = !(objectBase.CurrentObjectState.Is("Draft") && objectBase.SelectedAction.Is("Cancel"));
    }
    protected void dropPurchaseTypeClassification_SelectedIndexChanged(object sender, EventArgs e)
    {

        if (dropPurchaseTypeClassification.SelectedValue != "")
            dropPurchaseType.Bind(TablesLogic.tCode.LoadList(TablesLogic.tCode.ParentID == new Guid(dropPurchaseTypeClassification.SelectedValue)));
        else
            dropPurchaseType.Items.Clear();
    }

    /// <summary>
    /// Occurs when the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ItemType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(purchaseRequestItem);

        // If the item is a material item type, then
        // set the receipt mode to quantity, and 
        // disable the receipt mode radio button list.
        //
        if (purchaseRequestItem.ItemType == PurchaseItemType.Material)
            purchaseRequestItem.ReceiptMode = ReceiptModeType.Quantity;
        else if (purchaseRequestItem.ItemType == PurchaseItemType.Service)
        {
            purchaseRequestItem.ReceiptMode = ReceiptModeType.Dollar;
            purchaseRequestItem.QuantityRequired = 1.0M;
        }

        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(purchaseRequestItem);
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CatalogueID_AcquireTreePopulater(object sender)
    {
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;
        return new CatalogueTreePopulater(purchaseRequestItem.CatalogueID, true, true, true, true);
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
    /// Occurs when the user selects a node in the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseRequestItem i = (OPurchaseRequestItem)PurchaseRequestItem_SubPanel.SessionObject;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(i);
        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Constructs and returns a fixed rate tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater FixedRateID_AcquireTreePopulater(object sender)
    {
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;
        return new FixedRateTreePopulater(purchaseRequestItem.FixedRateID, false, true);
    }


    /// <summary>
    /// Occurs when the user selects a node in the fixed rate treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void FixedRateID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseRequestItem i = (OPurchaseRequestItem)PurchaseRequestItem_SubPanel.SessionObject;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(i);
        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Occurs when the user clicks on the Generate Request for Quotation button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGenerateRFQ_Click(object sender, EventArgs e)
    {
        List<object> ids = PurchaseRequestItems.GetSelectedKeys();

        PurchaseRequestItems.ErrorMessage = "";
        panel.Message = "";
        if (ids.Count > 0)
        {
            // Validate to ensure that none of the selected
            // WJ items have been generated to RFQs/POs.
            //
            List<Guid> prItemIds = new List<Guid>();
            foreach (Guid id in ids)
                prItemIds.Add(id);
            string lineItems = OPurchaseRequest.ValidatePRLineItemsNotGeneratedToRFQOrPO(prItemIds);
            if (lineItems.Length != 0)
            {
                panel.Message = String.Format(Resources.Errors.PurchaseRequest_LineItemsAlreadyGeneratedIntoRFQOrPOs, lineItems);
                return;
            }
            
            List<OPurchaseRequestItem> items = new List<OPurchaseRequestItem>(); ;
            OPurchaseRequest pr = panel.SessionObject as OPurchaseRequest;
            panel.ObjectPanel.BindControlsToObject(pr);

            foreach (OPurchaseRequestItem pri in pr.PurchaseRequestItems)
            {
                if (ids.Contains(pri.ObjectID.Value))
                    items.Add(pri);
            }

            ORequestForQuotation obj = ORequestForQuotation.CreateRFQFromPRLineItemsWithBudget(items);
            Window.OpenEditObjectPage(this, "ORequestForQuotation", obj.ObjectID.Value.ToString(), "");
        }
        else
        {
            PurchaseRequestItems.ErrorMessage = Resources.Errors.PurchaseRequest_NoItemsSelected;
            panel.Message = Resources.Errors.PurchaseRequest_NoItemsSelected;
        }

    }


    /// <summary>
    /// Occurs when the user clicks on the Generate Purchase Order button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePO_Click(object sender, EventArgs e)
    {
        List<object> ids = PurchaseRequestItems.GetSelectedKeys();

        PurchaseRequestItems.ErrorMessage = "";
        panel.Message = "";
        if (ids.Count > 0)
        {
            // Validate to ensure that none of the selected
            // WJ items have been generated to RFQs/POs.
            //
            List<Guid> prItemIds = new List<Guid>();
            foreach (Guid id in ids)
                prItemIds.Add(id);
            string lineItems = OPurchaseRequest.ValidatePRLineItemsNotGeneratedToRFQOrPO(prItemIds);
            if (lineItems.Length != 0)
            {
                panel.Message = String.Format(Resources.Errors.PurchaseRequest_LineItemsAlreadyGeneratedIntoRFQOrPOs, lineItems);
                return;
            }
            
            List<OPurchaseRequestItem> items = new List<OPurchaseRequestItem>(); ;
            OPurchaseRequest pr = panel.SessionObject as OPurchaseRequest;
            panel.ObjectPanel.BindControlsToObject(pr);

            foreach (OPurchaseRequestItem pri in pr.PurchaseRequestItems)
            {
                if (ids.Contains(pri.ObjectID.Value))
                    items.Add(pri);
            }

            OPurchaseOrder po = OPurchaseOrder.CreatePOFromPRLineItemsWithBudget(items);
            Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.Value.ToString(), "");
        }
        else
        {
            PurchaseRequestItems.ErrorMessage = Resources.Errors.PurchaseRequest_NoItemsSelected;
            panel.Message = Resources.Errors.PurchaseRequest_NoItemsSelected;
        }
    }



    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    //{
    //    OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
    //    return new LocationTreePopulaterForCapitaland(purchaseRequest.LocationID, false, true, Security.Decrypt(Request["TYPE"]), false, false);
    //}


    /// <summary>
    /// Updates the requestor dropdown list when the location changes,
    /// and clears the selected equipment ID.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    //{
    //    OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
    //    panel.ObjectPanel.BindControlsToObject(purchaseRequest);

    //    PurchaseRequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(
    //        purchaseRequest.Location, "PURCHASEREQUESTOR"));

    //    purchaseRequest.EquipmentID = null;
    //    panel.ObjectPanel.BindObjectToControls(purchaseRequest);
    //}


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    //{
    //    OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
    //    return new EquipmentTreePopulater(purchaseRequest.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    //}


    /// <summary>
    /// Updates the location to the location of the selected equipment.
    /// </summary>
    /// <param name="sender"></param>
    ///// <param name="e"></param>
    //protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    //{
    //    OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
    //    panel.ObjectPanel.BindControlsToObject(purchaseRequest);

    //    if (purchaseRequest.Equipment != null)
    //    {
    //        purchaseRequest.LocationID = purchaseRequest.Equipment.LocationID;
    //        PurchaseRequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(
    //            purchaseRequest.Location, "PURCHASEREQUESTOR"));
    //        treeLocation.PopulateTree();
    //    }
    //    panel.ObjectPanel.BindObjectToControls(purchaseRequest);
    //}


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
    /// Occurs when the user selects the date required.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DateRequired_DateTimeChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Pops up a search page to add fixed rates.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddFixedRateItems_Click(object sender, EventArgs e)
    {
        Window.Open("addfixedrate.aspx");
        panel.FocusWindow = false;
    }

    /// <summary>
    /// Pops up a search page to add material items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddMaterialItems_Click(object sender, EventArgs e)
    {
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
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;

        panelLineItems.BindObjectToControls(purchaseRequest);
    }

    protected TreePopulater treeQuickAddAccount_AcquireTreePopulater(object sender)
    {
        OPurchaseRequest pr = panel.SessionObject as OPurchaseRequest;
        return new AccountTreePopulaterForCapitaland(null, false, true, null, pr.PurchaseTypeID);
    }

    protected void treeQuickAddAccount_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeQuickAddAccount.SelectedValue != "")
        {
            OPurchaseRequest obj = panel.SessionObject as OPurchaseRequest;
            panel.ObjectPanel.BindControlsToObject(obj);

            //if (obj.IsGroupWJ == 0)
            //{
            OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
            List<Guid> budgetIds = OBudget.GetCoveringBudgetIDs(obj.Location);
            if (budgetIds.Count > 0)
                pb.BudgetID = budgetIds[0];
            pb.ItemNumber = 1;
            pb.AccountID = new Guid(treeQuickAddAccount.SelectedValue);
            pb.StartDate = obj.DateRequired;
            pb.EndDate = obj.DateRequired;
            pb.AccrualFrequencyInMonths = 1;
            pb.Amount = 0;
            obj.PurchaseBudgets.Add(pb);
            panel.ObjectPanel.BindObjectToControls(obj);
            //}
            //else
            //{

            //foreach (OLocation location in obj.GroupWJLocations)
            //{
            //    OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
            //    List<Guid> budgetIds = OBudget.GetCoveringBudgetIDs(location);
            //    if (budgetIds.Count > 0)
            //        pb.BudgetID = budgetIds[0];
            //    pb.ItemNumber = 1;
            //    pb.AccountID = new Guid(treeQuickAddAccount.SelectedValue);
            //    pb.StartDate = obj.DateRequired;
            //    pb.EndDate = obj.DateEnd;
            //    pb.AccrualFrequencyInMonths = 1;
            //    pb.Amount = 0;
            //    obj.PurchaseBudgets.Add(pb);
            //}

            //panel.ObjectPanel.BindObjectToControls(obj);
            //}

        }
    }

    /// <summary>
    /// Populates the budget subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseRequest obj = panel.SessionObject as OPurchaseRequest;
        panel.ObjectPanel.BindControlsToObject(obj);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        if (BudgetGroupID.SelectedValue != "")
        {
            //if (!checkIsGroupWJ.Checked)
            //{
            dropBudget.Bind(OBudget.GetCoveringBudgets(obj.Location, prBudget.BudgetID, new Guid(BudgetGroupID.SelectedValue)));
            //}
            //else
            //{
                //List<OLocation> locations = new List<OLocation>();
                //foreach (OLocation location in obj.GroupWJLocations)
                //    locations.Add(location);
                //dropBudget.Bind(OBudget.GetCoveringBudgets(locations, prBudget.BudgetID, new Guid(BudgetGroupID.SelectedValue)));
            //}
        }

        if (subpanelBudget.IsAddingObject)
        {
            if (dropBudget.Items.Count == 2)
                prBudget.BudgetID = new Guid(dropBudget.Items[1].Value);
            prBudget.StartDate = obj.DateRequired;
            prBudget.EndDate = obj.DateRequired;
        }

        dropItemNumber.Items.Clear();
        for (int i = 1; i <= obj.PurchaseRequestItems.Count; i++)
            dropItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        populateAccount();
        subpanelBudget.ObjectPanel.BindObjectToControls(prBudget);
    }
    /// <summary>
    /// Validates and inserts record.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseRequest obj = panel.SessionObject as OPurchaseRequest;
        panel.ObjectPanel.BindControlsToObject(obj);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);
        
        prBudget.EndDate = prBudget.StartDate;
        prBudget.AccrualFrequencyInMonths = 1;

        // Validate
        //

        // Insert
        //
        obj.PurchaseBudgets.Add(prBudget);

        if (obj.CurrentActivity == null ||
            !obj.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled"))
        {
            obj.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }

        panel.ObjectPanel.BindObjectToControls(obj);
    }
    /// <summary>
    /// Occurs when the user removes one or more budget distribution.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_Removed(object sender, EventArgs e)
    {
        OPurchaseRequest obj = panel.SessionObject as OPurchaseRequest;
        panel.ObjectPanel.BindControlsToObject(obj);

        if (obj.CurrentActivity == null ||
            !obj.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled"))
        {
            obj.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        panel.ObjectPanel.BindObjectToControls(obj);
    }

    /// <summary>
    /// Occurs when the user selects the budget distribution mode.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
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
    /// Constructs and returns the account tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeAccount_AcquireTreePopulater(object sender)
    {
        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        if (prBudget.StartDate != null && prBudget.BudgetID != null)
        {
            Guid? purchaseTypeID = null;
            if (dropPurchaseType.SelectedValue != "")
                purchaseTypeID = new Guid(dropPurchaseType.SelectedValue);
            
            Guid budgetId = prBudget.BudgetID.Value;
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, prBudget.StartDate.Value);

            if (budgetPeriod != null)
                return new AccountTreePopulaterForCapitaland(prBudget.AccountID, false, true, budgetPeriod.ObjectID, purchaseTypeID);
            else
                return new AccountTreePopulaterForCapitaland(prBudget.AccountID, false, true);
        }
        return null;

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
            OPurchaseRequest obj = panel.SessionObject as OPurchaseRequest;
            OPurchaseBudgetSummary budgetSummary = obj.PurchaseBudgetSummaries.Find(id);
            if (budgetSummary == null)
                budgetSummary = obj.TempPurchaseBudgetSummaries.Find((r) => r.ObjectID == id);
            if (budgetSummary != null)
                Window.Open("../../customizedmodulesforcapitaland/budgetperiod/budgetview.aspx?ID=" +
                    HttpUtility.UrlEncode(Security.Encrypt(budgetSummary.BudgetPeriodID.ToString())));

            panel.FocusWindow = false;
        }
    }

    protected void ddlLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
        panel.ObjectPanel.BindControlsToObject(purchaseRequest);

        PurchaseRequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(
            purchaseRequest.Location, "PURCHASEREQUESTOR"));

        purchaseRequest.EquipmentID = null;
        panel.ObjectPanel.BindObjectToControls(purchaseRequest);
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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Purchase Request" BaseTable="tPurchaseRequest"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave" >
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="tabDetails" runat="server"  Caption="Details"
                        meta:resourcekey="tabDetailsResource1">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false"
                            ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIPanel runat="server" ID="panelDetails" Width="100%" meta:resourcekey="panelDetailsResource1">
                            <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" PropertyName="LocationID" ValidateRequiredField="true" OnSelectedIndexChanged="ddlLocation_SelectedIndexChanged"></ui:UIFieldDropDownList>
                            <%--<ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID" meta:resourcekey="treeLocationResource1"
                                OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                                ValidateRequiredField="true">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTreeList runat="server" ID="treeEquipment" meta:resourcekey="treeEquipmentResource1" Caption="Equipment" PropertyName="EquipmentID"
                                OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged">
                            </ui:UIFieldTreeList>--%>
                            <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" PropertyName="Description"
                                MaxLength="255" ValidateRequiredField="True" meta:resourcekey="DescriptionResource1" />
                            <ui:UIFieldDateTime runat='server' ID="DateRequired" Caption="Date Required" ShowTimeControls="False"
                                PropertyName="DateRequired" ValidateRequiredField="True" ImageClearUrl="~/calendar/dateclr.gif"
                                ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" OnDateTimeChanged="DateRequired_DateTimeChanged" />
                            <ui:UIFieldDropDownList runat="server" ID="PurchaseRequestorID" Caption="Purchasing Requestor"
                                ValidateRequiredField="True" PropertyName="PurchaseRequestorID" meta:resourcekey="PurchaseRequestorIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="StoreID" runat="server" Caption="Store" Span="Half" PropertyName="StoreID"
                                meta:resourcekey="StoreIDResource1">
                            </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="BudgetGroupID" Caption="Budget Group" PropertyName="BudgetGroupID" ValidateRequiredField="true">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="dropPurchaseTypeClassification" PropertyName="TransactionTypeGroupID" Caption="Transaction Type Group" ValidateRequiredField="true" OnSelectedIndexChanged="dropPurchaseTypeClassification_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType" Caption="Transaction Type" PropertyName="PurchaseTypeID" ValidateRequiredField="true">
                        </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox ID="txtBackground" runat="server" Caption="Background" meta:resourcekey="txtBackgroundResource1" PropertyName="Background" TextMode="MultiLine" Rows="3"></ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="txtScope" meta:resourcekey="txtScopeResource1" runat="server" Caption="Scope" PropertyName="Scope" TextMode="MultiLine" Rows="3"></ui:UIFieldTextBox>
                            <br />
                            <br />
                            <br />
                            <table cellpadding='0' cellspacing='0' style="width: 100%">
                                <tr>
                                    <td style="width: 50%">
                                        <ui:UIPanel ID="Panel1" runat="server" meta:resourcekey="Panel1Resource1">
                                            <asp:Label ID="Label1" runat="server" Font-Bold="True" Text="Ship To:" meta:resourcekey="Label1Resource1"></asp:Label><br />
                                            <ui:UIFieldTextBox ID="ShipToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                                PropertyName="ShipToAddress" meta:resourcekey="ShipToAddressResource1" />
                                            <ui:UIFieldTextBox ID="ShipToAttention" runat="server" Caption="Attention" PropertyName="ShipToAttention"
                                                meta:resourcekey="ShipToAttentionResource1" />
                                        </ui:UIPanel>
                                    </td>
                                    <td style="width: 50%">
                                        <ui:UIPanel ID="Panel2" runat="server" meta:resourcekey="Panel2Resource1">
                                            <asp:Label ID="Label2" runat="server" Font-Bold="True" Text="Bill To:" meta:resourcekey="Label2Resource1"></asp:Label><br />
                                            <ui:UIFieldTextBox ID="BillToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                                PropertyName="BillToAddress" meta:resourcekey="BillToAddressResource1" />
                                            <ui:UIFieldTextBox ID="BillToAttention" runat="server" Caption="Attention" PropertyName="BillToAttention"
                                                meta:resourcekey="BillToAttentionResource1" />
                                        </ui:UIPanel>
                                    </td>
                                </tr>
                            </table>
                            <br />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Line Items" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIPanel runat="server" ID="panelButtons" meta:resourcekey="panelButtonsResource1">
                            <ui:UIButton runat="server" ID="buttonGenerateRFQ" Text="Generate RFQ from Selected Line Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGenerateRFQ_Click" ConfirmText="Are you sure you wish to generate a Request for Quotation from the selected line items?"
                                meta:resourcekey="buttonGenerateRFQResource1" />
                            <ui:UIButton runat="server" ID="buttonGeneratePO" Text="Generate PO from Selected Line Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGeneratePO_Click" ConfirmText="Are you sure you wish to generate a Purchase Order from the selected line items?"
                                meta:resourcekey="buttonGeneratePOResource1" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelLineItems" meta:resourcekey="panelLineItemsResource1">
                            <ui:UIPanel runat="server" ID="panelAddMultipleItems" meta:resourcekey="panelAddMultipleItemsResource1">
                                <ui:UIButton runat="server" ID="buttonAddMaterialItems" meta:resourcekey="buttonAddMaterialItemsResource1" ImageUrl="~/images/add.gif" Text="Add Multiple Inventory Items" OnClick="buttonAddMaterialItems_Click" CausesValidation='false' />
                                <ui:UIButton runat="server" ID="buttonAddFixedRateItems" meta:resourcekey="buttonAddFixedRateItemsResource1" ImageUrl="~/images/add.gif" Text="Add Multiple Service Items" OnClick="buttonAddFixedRateItems_Click" CausesValidation='false' />
                                <ui:uibutton runat="server" id="buttonItemsAdded" meta:resourcekey="buttonItemsAddedResource1" CausesValidation="false" OnClick="buttonItemsAdded_Click"></ui:uibutton>
                                <br />
                                <br />
                            </ui:UIPanel>
                            <ui:UIGridView ID="PurchaseRequestItems" runat="server" Caption="Items" PropertyName="PurchaseRequestItems"
                                SortExpression="ItemNumber" KeyName="ObjectID" meta:resourcekey="PurchaseRequestItemsResource1"
                                Width="100%" AllowPaging="True" AllowSorting="True" PagingEnabled="True">
                                <Commands>
                                    <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                        ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                    </ui:UIGridViewCommand>
                                    <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"
                                        meta:resourcekey="UIGridViewCommandResource2"></ui:UIGridViewCommand>
                                </Commands>
                                <Columns>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                        CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                        ConfirmText="Are you sure you wish to delete this item?" CommandName="DeleteObject"
                                        HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Number" PropertyName="ItemNumber" meta:resourcekey="UIGridViewColumnResource3">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Type" PropertyName="ItemTypeText" meta:resourcekey="UIGridViewColumnResource4">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Description" PropertyName="ItemDescription" 
                                        meta:resourcekey="UIGridViewColumnResource5">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Unit of Measure" PropertyName="UnitOfMeasure.ObjectName"
                                        meta:resourcekey="UIGridViewColumnResource6">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Quantity Required" PropertyName="QuantityRequired"
                                        DataFormatString="{0:#,##0.00##}" meta:resourcekey="UIGridViewColumnResource7">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Copied To" PropertyName="CopiedToObjectNumber" 
                                        meta:resourcekey="UIGridViewColumnResource8">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Estimated Unit Price" PropertyName="EstimatedUnitPrice" 
                                        DataFormatString="{0:c}"/>
                                    <ui:UIGridViewBoundColumn HeaderText="Estimated SubTotal" PropertyName="Subtotal" 
                                        DataFormatString="{0:c}"/>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel ID="PurchaseRequestItem_Panel" runat="server" meta:resourcekey="PurchaseRequestItem_PanelResource1">
                                <web:subpanel runat="server" ID="PurchaseRequestItem_SubPanel" GridViewID="PurchaseRequestItems"
                                    OnDeleted="PurchaseRequestItem_SubPanel_Deleted"
                                    OnPopulateForm="PurchaseRequestItem_SubPanel_PopulateForm"
                                    MultiSelectColumnNames="ItemNumber,ItemType,CatalogueID,FixedRateID,QuantityRequired"
                                    OnValidateAndUpdate="PurchaseRequestItem_SubPanel_ValidateAndUpdate" />
                                <ui:UIFieldDropDownList ID="ItemNumber" runat="server" Caption="Item Number" PropertyName="ItemNumber"
                                    Span="Half" ValidateRequiredField="True" meta:resourcekey="ItemNumberResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldRadioList ID="ItemType" runat="server" Caption="Item Type" PropertyName="ItemType"
                                    RepeatColumns="0" OnSelectedIndexChanged="ItemType_SelectedIndexChanged" ValidateRequiredField="True"
                                    meta:resourcekey="ItemTypeResource1">
                                    <Items>
                                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Inventory">
                                        </asp:ListItem>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Service">
                                        </asp:ListItem>
                                        <asp:ListItem Value="2" meta:resourcekey="ListItemResource3">Others</asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldTreeList ID="CatalogueID" runat="server" Caption="Catalog" PropertyName="CatalogueID"
                                    OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater" OnSelectedNodeChanged="CatalogueID_SelectedNodeChanged"
                                    ValidateRequiredField="True" meta:resourcekey="CatalogueIDResource1">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate" PropertyName="FixedRateID"
                                    OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater" OnSelectedNodeChanged="FixedRateID_SelectedNodeChanged"
                                    ValidateRequiredField="True" meta:resourcekey="FixedRateIDResource1">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldLabel runat="server" ID="UnitOfMeasure" Caption="Unit of Measure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                    meta:resourcekey="UnitOfMeasureResource1" />
                                <ui:UIFieldLabel runat="server" ID="UnitOfMeasure2" Caption="Unit of Measure" PropertyName="FixedRate.UnitOfMeasure.ObjectName"
                                    meta:resourcekey="UnitOfMeasure2Resource1" />
                                <ui:UIFieldTextBox ID="ItemDescription" runat="server" Caption="Description" PropertyName="ItemDescription"
                                    MaxLength="255" ValidateRequiredField="True" meta:resourcekey="ItemDescriptionResource1" />
                                <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" Caption="Unit of Measure"
                                    PropertyName="UnitOfMeasureID" ValidateRequiredField="True" meta:resourcekey="UnitOfMeasureIDResource1" />
                                <ui:UIFieldRadioList runat="server" ID="radioReceiptMode" meta:resourcekey="radioReceiptModeResource1" PropertyName="ReceiptMode" Caption="Receipt Mode" OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged">
                                    <Items>
                                        <asp:ListItem value="0" meta:resourcekey="ListItemResource4">Receive by Quantity</asp:ListItem>
                                        <asp:ListItem value="1" meta:resourcekey="ListItemResource5">Receive by Dollar Amount</asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldTextBox ID="textQuantityRequired" runat="server" Caption="Quantity Required" DataFormatString="{0:#,##0.00##}"
                                    PropertyName="QuantityRequired" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                    ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                    ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="UIFieldTextBox1Resource1" />
                                    <ui:UIFieldTextBox ID="EstimatedUnitPrice" runat="server" Caption="Estimated Unit Price"
                                    PropertyName="EstimatedUnitPrice" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                    ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                    ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="EstimatedUnitPriceResource1" />
                            </ui:UIObjectPanel>
                        </ui:UIPanel>
                    </ui:UITabView>
<ui:UITabView runat="server" ID="tabBudget" Caption="Budget">
                    <ui:UIFieldRadioList runat="server" ID="radioBudgetDistributionMode" PropertyName="BudgetDistributionMode" Caption="Budget Distribution" ValidateRequiredField="true" OnSelectedIndexChanged="radioBudgetDistributionMode_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Value="0">By entire Request for Quotation</asp:ListItem>
                            <asp:ListItem Value="1">By individual Request for Quotation items</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:uipanel runat="server" id="panelAccount">
                        <ui:uifieldtreelist runat="server" id="treeQuickAddAccount" Caption="Select Account to Add" CaptionWidth="180px" OnAcquireTreePopulater="treeQuickAddAccount_AcquireTreePopulater" OnSelectedNodeChanged="treeQuickAddAccount_SelectedNodeChanged">
                        </ui:uifieldtreelist>
                    </ui:uipanel>
                    <ui:UIGridView runat="server" ID="gridBudget" PropertyName="PurchaseBudgets" Caption="Budgets" ShowFooter="true" PageSize="50" SortExpression="ItemNumber ASC" BindObjectsToRows="true">
                        <Commands>
                            <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                            <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"></ui:UIGridViewCommand>
                        </Commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to delete this item?" CommandName="DeleteObject" HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ItemNumber" HeaderText="Number">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" HeaderText="Budget">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.Path" HeaderText="Account">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.AccountCode" HeaderText="Account Code">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="StartDate" HeaderText="Start Date" DataFormatString="{0:dd-MMM-yyyy}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Amount">
                                <ItemTemplate>
                                    <ui:uifieldtextbox runat="server" id="textAmount" PropertyName="Amount" Caption="Amount" FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateRequiredField='true' ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive="false" DataFormatString="{0:n}">
                                    </ui:uifieldtextbox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="panelBudget">
                        <web:subpanel runat="server" ID="subpanelBudget" GridViewID="gridBudget" OnPopulateForm="subpanelBudget_PopulateForm" OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate" OnRemoved="subpanelBudget_Removed" />
                        <ui:UIFieldDropDownList runat="server" ID="dropItemNumber" PropertyName="ItemNumber" Caption="Item Number" ValidateRequiredField="true">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="dropBudget" PropertyName="BudgetID" Caption="Budget" ValidateRequiredField="true" OnSelectedIndexChanged="dropBudget_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate" Caption="Start Date" Span="Half" ValidateRequiredField="true" OnDateTimeChanged="dateStartDate_DateTimeChanged">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTreeList runat="server" ID="treeAccount" PropertyName="AccountID" Caption="Account" ValidateRequiredField="true" OnAcquireTreePopulater="treeAccount_AcquireTreePopulater">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat="server" ID="textAmount" PropertyName="Amount" Caption="Amount" DataFormatString="{0:n}" Span="Half" ValidateRequiredField="true" ValidationRangeMin="1" ValidationRangeMinInclusive="true" ValidationRangeType="Currency">
                        </ui:UIFieldTextBox>
                    </ui:UIObjectPanel>
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="gridBudgetSummary" PropertyName="PurchaseBudgetSummaries" Caption="Budget Summary" CheckBoxColumnVisible="false" OnAction="gridBudgetSummary_Action" ShowFooter="true" PageSize="50">
                        <Columns>
                            <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" HeaderText="Budget">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="BudgetPeriod.ObjectName" HeaderText="Budget Period">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/printer.gif" CommandName="ViewBudget" AlwaysEnabled="true">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.ObjectName" HeaderText="Account">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Account.AccountCode" HeaderText="Account Code">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableAdjusted" HeaderText="Total After Adjustments" DataFormatString="{0:c}" FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableBeforeSubmission" HeaderText="Total Before Submission" DataFormatString="{0:c}" FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableAtSubmission" HeaderText="Total At Submission" DataFormatString="{0:c}" FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TotalAvailableAfterApproval" HeaderText="Total After Approval" DataFormatString="{0:c}" FooterAggregate="Sum">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Work Status History" meta:resourcekey="uitabview1Resource1">
                        <web:ActivityHistory runat="server" ID="ActivityHistory" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>

