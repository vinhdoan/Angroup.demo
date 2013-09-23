<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            labelTotalAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelTotalTax.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalTax.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalCreditDebitMemoAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalAfterCreditDebitMemoAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
    }


    /// <summary>
    /// Occurs when the form loads.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        dropVendor.Bind(OVendor.GetVendors(DateTime.Today, invoice.VendorID));
        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", invoice.PurchaseTypeID));

        if (invoice.CurrentActivity == null ||
            !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            invoice.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        else
            gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";

        if (invoice.CurrencyID == null)
        {
            invoice.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;
            invoice.ForeignToBaseExchangeRate = 1.0M;
        }
        if (invoice.IsNew)
        {
            invoice.DateOfInvoice = DateTime.Today;
        }
        dropTaxCode.Bind(OTaxCode.GetAllTaxCodes(invoice.DateOfInvoice, invoice.TaxCodeID));
        dropCurrency.Bind(OCurrency.GetAllCurrencies(invoice.CurrencyID), "CurrencyNameAndDescription", "ObjectID", true);
        labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;

        // Set access control for the buttons
        //
        if (invoice.PurchaseOrderID != null)
        {
            buttonViewPurchaseOrder.Visible = AppSession.User.AllowViewAll("OPurchaseOrder");
            buttonEditPurchaseOrder.Visible = AppSession.User.AllowEditAll("OPurchaseOrder") || OActivity.CheckAssignment(AppSession.User, invoice.PurchaseOrderID);
            dropPOMatchedInvoice.Visible = true;
            popupDirectInvoice.Visible = false;
            dropPOMatchedInvoice.Bind(OPurchaseInvoice.GetPOMatchedStandardInvoices(invoice.PurchaseOrderID, invoice.CreditDebitMemoOnInvoiceID), "ObjectNumberAndDescription", "ObjectID");
            dropPOMatchedInvoice.PropertyName = "CreditDebitMemoOnInvoiceID";
        }
        else
        {
            buttonViewPurchaseOrder.Visible = false;
            buttonEditPurchaseOrder.Visible = false;
            dropPOMatchedInvoice.Visible = false;
            popupDirectInvoice.Visible = true;
            popupDirectInvoice.PropertyName = "CreditDebitMemoOnInvoiceID";
            popupDirectInvoice.PropertyNameItem = "CreditDebitMemoOnInvoice.ObjectNumber";
        }

        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Saves the invoice
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
            panel.ObjectPanel.BindControlsToObject(invoice);

            // Validate
            //
            if (objectBase.SelectedAction == "SubmitForApproval")
            {
                // Ensure that all budget accounts in the budget
                // line items are set as active.
                //
                // Ensure that all budget accounts in the budget
                // line items are set as active.
                //
                string inactiveAccounts = OPurchaseBudget.ValidateBudgetAccountsAreActive(invoice.PurchaseBudgets);
                if (inactiveAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseInvoice_BudgetAccountsNotActive, inactiveAccounts);
                }

                // Ensure that the budget periods covering the start date of
                // the purchase order exists, and has not yet been closed.
                //
                string closedBudgets = OPurchaseBudget.ValidateBudgetPeriodsActiveAndOpened(invoice.PurchaseBudgets);
                if (closedBudgets != "")
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseInvoice_BudgetPeriodsClosed, closedBudgets);


                // Checks if the invoice budget distributions is equal
                // to the total invoice amount (in base currency)
                //
                if (!invoice.ValidateBudgetAmountEqualsTotalAmount())
                {
                    this.labelTotalAmount.ErrorMessage = Resources.Errors.PurchaseInvoice_BudgetAmountNotEqualsTotalAmount;
                    this.gridBudget.ErrorMessage = Resources.Errors.PurchaseInvoice_BudgetAmountNotEqualsTotalAmount;
                }

                // Ensure sufficient budgets.
                //
                string insufficientAccounts = invoice.ValidateSufficientBudget();
                if (insufficientAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseInvoice_InsufficientBudget, insufficientAccounts);
                }

                // For credit/debit memos, ensure that 
                // the total amount and tax is less
                // than the original invoice.
                //
                if (!invoice.ValidateTotalCreditDebitMemoAmountLessThanOriginalInvoiceAmount())
                {
                    this.textTotalAmountInSelectedCurrency.ErrorMessage = Resources.Errors.PurchaseInvoice_TotalCreditAmountAndTaxMoreThanOriginalInvoice;
                    this.textTotalTaxInSelectedCurrency.ErrorMessage = Resources.Errors.PurchaseInvoice_TotalCreditAmountAndTaxMoreThanOriginalInvoice;
                }
            }
            else if (objectBase.SelectedAction == "Cancel")
            {
                if (invoice.InvoiceType == PurchaseInvoiceType.StandardInvoice)
                {
                    // For Standard Invoices:
                    // Validates that there are no credit/debit
                    // memos matched to this current invoice.
                    //
                    string creditDebitMemoNumbers = invoice.ValidateNoCreditOrDebitMemos();
                    if (creditDebitMemoNumbers != "")
                    {
                        labelOriginalTotalCreditDebitMemoAmount.ErrorMessage = String.Format(Resources.Errors.PurchaseInvoice_CannotCancelDueToExistingCreditDebitMemos, creditDebitMemoNumbers);
                    }
                }
                else
                {
                    // For Credit/Debit Memos:
                    // Validates that there are no credit/debit
                    // memos matched to this current invoice.
                    //
                    string insufficientAccounts = invoice.ValidateSufficientBudgetForCancellation();
                    if (insufficientAccounts != "")
                    {
                        gridBudget.ErrorMessage =
                            String.Format(Resources.Errors.PurchaseInvoice_InsufficientBudgetForCancellation, insufficientAccounts);
                    }
                }
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            invoice.Save();

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
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        return new LocationTreePopulater(invoice.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Updates the requestor dropdown list when the location changes,
    /// and clears the selected equipment ID.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.EquipmentID = null;
        invoice.UpdateApplicablePurchaseSettings();
        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        return new EquipmentTreePopulater(invoice.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Updates the location to the location of the selected equipment.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);

        if (invoice.Equipment != null)
        {
            invoice.LocationID = invoice.Equipment.LocationID;
            treeLocation.PopulateTree();
        }
        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Finds and updates the exchange rate.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropCurrency_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateExchangeRate();
        //invoice.UpdateItemCurrencies();
        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Updates the dropdown lists of all rows in the RequestForQuotationVendorItems
    /// grid view. Also updates the currencyID of each ORequestForQuotationVendorItem
    /// objects.
    /// </summary>
    protected void UpdateItemCurrencies()
    {
        /*
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        foreach (OPurchaseOrderItem poItem in po.PurchaseOrderItems)
            poItem.CurrencyID = po.CurrencyID;
         * */
    }


    //---------------------------------------------------------------    
    // event
    //---------------------------------------------------------------
    protected void dropVendor_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);

        invoice.UpdateVendorDetails();

        panel.ObjectPanel.BindObjectToControls(invoice);
    }

    /// <summary>
    /// Populates the budget subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        dropBudget.Bind(OBudget.GetCoveringBudgets(invoice.Location, prBudget.BudgetID));
        if (subpanelBudget.IsAddingObject)
        {
            if (dropBudget.Items.Count == 2)
                prBudget.BudgetID = new Guid(dropBudget.Items[1].Value);
            prBudget.StartDate = invoice.DateOfInvoice;
            prBudget.EndDate = invoice.DateOfInvoice;
        }

        if (prBudget.TransferFromBudgetTransactionLogID != null)
        {
            dropBudget.Enabled = false;
            treeAccount.Enabled = false;
        }

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
        {
            treeAccount.PopulateTree();
        }
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
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);

        // Validate
        //


        // Insert
        //
        prBudget.EndDate = prBudget.StartDate;
        prBudget.AccrualFrequencyInMonths = 1;
        invoice.PurchaseBudgets.Add(prBudget);

        if (invoice.CurrentActivity == null ||
            !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            try
            {
                invoice.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
            catch(Exception ex)
            {
                textAmount.ErrorMessage = ex.Message;
                return;
            }
        }

        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Occurs when the user removes a budget from the list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_Removed(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

        if (invoice.CurrentActivity == null ||
            !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            invoice.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        tabBudget.BindObjectToControls(invoice);
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
            OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
            OPurchaseBudgetSummary budgetSummary = invoice.PurchaseBudgetSummaries.Find(id);
            if (budgetSummary == null)
                budgetSummary = invoice.TempPurchaseBudgetSummaries.Find((r) => r.ObjectID == id);
            if (budgetSummary != null)
                Window.Open("../../modules/budgetperiod/budgetview.aspx?ID=" +
                    HttpUtility.UrlEncode(Security.Encrypt(budgetSummary.BudgetPeriodID.ToString())));

            panel.FocusWindow = false;
        }
    }


    /// <summary>
    /// Hides and shows controls.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

        labelPurchaseOrderNumber.Visible = invoice.PurchaseOrderID != null;
        objectBase.ObjectNumberVisible = !invoice.IsNew;
        dateDateOfInvoice.Enabled = gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;
        panelInvoice.Enabled = gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;
        gridBudget.Enabled = dateDateOfInvoice.DateTime != null;
        dropPurchaseType.Enabled = radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        radioInvoiceType.Enabled = radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        tabBudget.Visible = treeLocation.SelectedValue != "" && dateDateOfInvoice.DateTime != null;
        treeLocation.Enabled = radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString() && gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;
        treeEquipment.Enabled = radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        panelVendor.Enabled = radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        radioMatchType.Enabled = false;
        dropCurrency.Enabled =
            textForeignToBaseExchangeRate.Enabled =
            radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() &&
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        panelAddBudgets.Visible = invoice.PurchaseOrderID != null && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        panelAddInvoiceBudgets.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();
        panelInvoice.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();
        gridBudget.Commands[1].Visible =
            !subpanelBudget.Visible &&
            radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() &&
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        hintCreditDebitMemo.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();
        panelOriginalInvoice.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();
        panelCreateCreditDebitMemos.Visible =
            objectBase.CurrentObjectState == "Approved" &&
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();

        // Workflow 
        //
        string currentState = objectBase.CurrentObjectState;
        tabDetails.Enabled = !currentState.Is("Cancelled", "Close");
        tabMemo.Enabled = !currentState.Is("Cancelled", "Close");
        tabAttachments.Enabled = !currentState.Is("Cancelled", "Close");
        panelDetails.Enabled = currentState.Is("Start", "Draft");
        tabVendor.Enabled = currentState.Is("Start", "Draft");
        tabBudget.Enabled = currentState.Is("Start", "Draft");
        dropTaxCode.ValidateRequiredField = objectBase.SelectedAction != "Cancelled";
        textTotalTaxInSelectedCurrency.ValidateRequiredField = objectBase.SelectedAction != "Cancelled";


        base.OnPreRender(e);
    }


    /// <summary>
    /// Occurs when the user selects the date of invoice.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dateDateOfInvoice_DateTimeChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        dropTaxCode.Bind(OTaxCode.GetAllTaxCodes(invoice.DateOfInvoice, invoice.TaxCodeID));
        if (invoice.MatchType == PurchaseMatchType.DirectInvoice)
            invoice.UpdateExchangeRate();
        panel.ObjectPanel.BindObjectToControls(invoice);
    }

    /// <summary>
    /// Automatically computes the tax amount.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropTaxCode_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateTax();
        invoice.UpdateTotalAmountAndTaxInBaseCurrency();
        panelSelectedCurrency.BindObjectToControls(invoice);
        panelBaseCurrency.BindObjectToControls(invoice);
    }

    /// <summary>
    /// Opens a window to edit the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditPurchaseOrder_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice po = (OPurchaseInvoice)panel.SessionObject;
        if (po.PurchaseOrderID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, po.PurchaseOrderID))
                Window.OpenEditObjectPage(this, "OPurchaseOrder", po.PurchaseOrderID.ToString(), "");
            else
                panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
        }
    }

    /// <summary>
    /// Opens a window to view the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewPurchaseOrder_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice po = (OPurchaseInvoice)panel.SessionObject;
        if (po.PurchaseOrderID != null)
        {
            Window.OpenViewObjectPage(this, "OPurchaseOrder", po.PurchaseOrderID.ToString(), "");
        }
    }


    /// <summary>
    /// Occurs when the purchase type is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropPurchaseType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateApplicablePurchaseSettings();
        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Occurs when the user changes the total amount
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void textTotalAmountInSelectedCurrency_TextChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateTax();
        invoice.UpdateTotalAmountAndTaxInBaseCurrency();
        panelSelectedCurrency.BindObjectToControls(invoice);
        panelBaseCurrency.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Occurs when the user changes the total tax
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void textTotalTaxInSelectedCurrency_TextChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateTotalAmountAndTaxInBaseCurrency();
        panelBaseCurrency.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Add budgets from the purchase order.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonApplyBudgets_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);

        // Check that the invoice amount is entered.
        //
        panel.Message = "";
        labelTotalAmount.ErrorMessage = "";
        if (invoice.TotalAmount == null)
        {
            panel.Message = Resources.Errors.PurchaseInvoice_CannotApplyBudgetsDueToUnknownAmount;
            labelTotalAmount.ErrorMessage = Resources.Errors.PurchaseInvoice_CannotApplyBudgetsDueToUnknownAmount;
            return;
        }

        // Creates the new purchase budgets and 
        // all the transaction logs (in the Approved)
        // state.
        //
        List<OPurchaseBudget> purchaseBudgets =
            OPurchaseBudget.TransferPartialPurchaseBudgets(
            invoice.PurchaseOrder.PurchaseBudgets, null, invoice.TotalAmount);
        invoice.PurchaseBudgets.Clear();
        invoice.PurchaseBudgets.AddRange(purchaseBudgets);

        if (invoice.CurrentActivity == null ||
            !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            invoice.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }

        tabBudget.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Add budgets from the purchase order.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonApplyInvoiceBudgets_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        panel.Message = "";

        // Check that the invoice amount is entered.
        //
        panel.Message = "";
        labelTotalAmount.ErrorMessage = "";
        if (invoice.TotalAmount == null)
        {
            panel.Message = Resources.Errors.PurchaseInvoice_CannotApplyBudgetsDueToUnknownAmount;
            labelTotalAmount.ErrorMessage = Resources.Errors.PurchaseInvoice_CannotApplyBudgetsDueToUnknownAmount;
            return;
        }

        // Checks to ensure that the invoice 
        //
        if (invoice.CreditDebitMemoOnInvoice == null)
        {
            panel.Message = Resources.Errors.PurchaseInvoice_CreditDebitMeomoOnInvoiceNotSelected;
            return;
        }

        // Creates the new purchase budgets and 
        // all the transaction logs (in the Approved)
        // state.
        //
        List<OPurchaseBudget> purchaseBudgets =
            OPurchaseBudget.TransferPartialPurchaseBudgets(
            invoice.CreditDebitMemoOnInvoice.PurchaseBudgets, null, invoice.TotalAmount);
        invoice.PurchaseBudgets.Clear();
        invoice.PurchaseBudgets.AddRange(purchaseBudgets);

        if (invoice.CurrentActivity == null ||
            !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            invoice.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }

        tabBudget.BindObjectToControls(invoice);
    }



    /// <summary>
    /// Add budgets from the purchase order.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddBudgets_Click(object sender, EventArgs e)
    {
        Window.Open("addpobudgets.aspx", "AnacleEAM_Popup");
        panel.FocusWindow = false;
    }


    protected void radioInvoiceType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user changes the exchange rate.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void textForeignToBaseExchangeRate_TextChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateTotalAmountAndTaxInBaseCurrency();
        panelBaseCurrency.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Occurs when the invoice is selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void popupDirectInvoice_SelectedValueChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        Guid? previousLocationID = invoice.LocationID;

        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateDetailsFromStandardInvoice();

        if (invoice.LocationID != previousLocationID)
            treeLocation.PopulateTree();
        if (invoice.EquipmentID != null)
            treeEquipment.PopulateTree();
        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropPOMatchedInvoice_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateDetailsFromStandardInvoice();
        panel.ObjectPanel.BindObjectToControls(invoice);
    }


    /// <summary>
    /// Creates credit memo for this invoice.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonCreateCreditMemo_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice originalInvoice = panel.SessionObject as OPurchaseInvoice;
        OPurchaseInvoice inv = OPurchaseInvoice.CreateCreditMemoFromStandardInvoice(originalInvoice);
        if (inv != null)
            Window.OpenEditObjectPage(this, "OPurchaseInvoice", inv.ObjectID.ToString(), "");
    }


    /// <summary>
    /// Creates debit memo for this invoice.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonCreateDebitMemo_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice originalInvoice = panel.SessionObject as OPurchaseInvoice;
        OPurchaseInvoice inv = OPurchaseInvoice.CreateDebitMemoFromStandardInvoice(originalInvoice);
        if (inv != null)
            Window.OpenEditObjectPage(this, "OPurchaseInvoice", inv.ObjectID.ToString(), "");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Purchase Invoice" BaseTable="tPurchaseInvoice" OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:uitabstrip id="tabObject" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="tabObjectResource1">
                <ui:uitabview id="tabDetails" runat="server" beginninghtml="" borderstyle="NotSet" caption="Details" endinghtml="" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberCaption="Invoice Number" ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1" />
                    <ui:uipanel id="panelDetails" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelDetailsResource1" width="100%">
                        <ui:uifieldradiolist id="radioMatchType" runat="server" caption="Match Type" meta:resourcekey="radioMatchTypeResource1" propertyname="MatchType" textalign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1" Text="Direct invoice (not matched to any purchase document)." Value="0"></asp:ListItem>
                                <asp:ListItem meta:resourcekey="ListItemResource2" Text="Matched to Purchase Order." Value="1"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <ui:uifieldradiolist id="radioInvoiceType" runat="server" caption="Invoice Type" meta:resourcekey="radioInvoiceTypeResource1" onselectedindexchanged="radioInvoiceType_SelectedIndexChanged" propertyname="InvoiceType" repeatcolumns="0" textalign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource3" Text="Standard Invoice" Value="0"></asp:ListItem>
                                <asp:ListItem meta:resourcekey="ListItemResource4" Text="Credit Memo" Value="1"></asp:ListItem>
                                <asp:ListItem meta:resourcekey="ListItemResource5" Text="Debit Memo" Value="2"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <ui:uipanel id="panelCreateCreditDebitMemos" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelCreateCreditDebitMemosResource1">
                            <table>
                                <tr>
                                    <td style="width: 150px">
                                    </td>
                                    <td>
                                        <ui:uibutton id="buttonCreateCreditMemo" runat="server" alwaysenabled="True" causesvalidation="False" confirmtext="Please remember to save this Purchase Invoice before creating a credit memo.\n\nAre you sure you want to continue?" imageurl="~/images/tick.gif" meta:resourcekey="buttonCreateCreditMemoResource1" onclick="buttonCreateCreditMemo_Click" text="Create Credit Memo" />
                                        <ui:uibutton id="buttonCreateDebitMemo" runat="server" alwaysenabled="True" causesvalidation="False" confirmtext="Please remember to save this Purchase Invoice before creating a debit memo.\n\nAre you sure you want to continue?" imageurl="~/images/tick.gif" meta:resourcekey="buttonCreateDebitMemoResource1" onclick="buttonCreateDebitMemo_Click" text="Create Debit Memo" />
                                    </td>
                                </tr>
                            </table>
                        </ui:uipanel>
                        <ui:uipanel id="panelInvoice" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelInvoiceResource1">
                            <ui:uifielddropdownlist id="dropPOMatchedInvoice" runat="server" caption="Original Invoice" meta:resourcekey="dropPOMatchedInvoiceResource1" onselectedindexchanged="dropPOMatchedInvoice_SelectedIndexChanged" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <ui:uifieldpopupselection id="popupDirectInvoice" runat="server" caption="Original Invoice" meta:resourcekey="popupDirectInvoiceResource1" onselectedvaluechanged="popupDirectInvoice_SelectedValueChanged" popupurl="searchstdinvoice.aspx" validaterequiredfield="True">
                            </ui:uifieldpopupselection>
                        </ui:uipanel>
                        <ui:uifieldlabel id="labelPurchaseOrderNumber" runat="server" caption="Purchase Order" contextmenualwaysenabled="True" dataformatstring="" meta:resourcekey="labelPurchaseOrderNumberResource1" propertyname="PurchaseOrder.ObjectNumber">
                            <contextmenubuttons>
                                <ui:uibutton id="buttonEditPurchaseOrder" runat="server" alwaysenabled="True" confirmtext="Please remember to save this Purchase Invoice before editing the Purchase Order.\n\nAre you sure you want to continue?" imageurl="~/images/edit.gif" meta:resourcekey="buttonEditPurchaseOrderResource1" onclick="buttonEditPurchaseOrder_Click" text="Edit Purchase Order" />
                                <ui:uibutton id="buttonViewPurchaseOrder" runat="server" alwaysenabled="True" confirmtext="Please remember to save this Purchase Invoice before viewing the Purchase Order.\n\nAre you sure you want to continue?" imageurl="~/images/view.gif" meta:resourcekey="buttonViewPurchaseOrderResource1" onclick="buttonViewPurchaseOrder_Click" text="View Purchase Order" />
                            </contextmenubuttons>
                        </ui:uifieldlabel>
                        <ui:uifielddropdownlist id="dropPurchaseType" runat="server" caption="Purchase Type" meta:resourcekey="dropPurchaseTypeResource1" onselectedindexchanged="dropPurchaseType_SelectedIndexChanged" propertyname="PurchaseTypeID" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uipanel id="panelLocationEquipment" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelLocationEquipmentResource1">
                            <ui:uifieldtreelist id="treeLocation" runat="server" caption="Location" meta:resourcekey="treeLocationResource1" onacquiretreepopulater="treeLocation_AcquireTreePopulater" onselectednodechanged="treeLocation_SelectedNodeChanged" propertyname="LocationID" showcheckboxes="None" treevaluemode="SelectedNode" validaterequiredfield="True">
                            </ui:uifieldtreelist>
                            <ui:uifieldtreelist id="treeEquipment" runat="server" caption="Equipment" meta:resourcekey="treeEquipmentResource1" onacquiretreepopulater="treeEquipment_AcquireTreePopulater" onselectednodechanged="treeEquipment_SelectedNodeChanged" propertyname="EquipmentID" showcheckboxes="None" treevaluemode="SelectedNode">
                            </ui:uifieldtreelist>
                        </ui:uipanel>
                        <ui:uifielddatetime id="dateDateOfInvoice" runat="server" caption="Date of Invoice" imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" meta:resourcekey="dateDateOfInvoiceResource1" ondatetimechanged="dateDateOfInvoice_DateTimeChanged" propertyname="DateOfInvoice" showdatecontrols="True" span="Half" validaterequiredfield="True">
                        </ui:uifielddatetime>
                        <ui:uifieldtextbox id="textReferenceNumber" runat="server" caption="Reference Number" internalcontrolwidth="95%" meta:resourcekey="textReferenceNumberResource1" propertyname="ReferenceNumber" span="Half">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="textDescription" runat="server" caption="Description" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="textDescriptionResource1" propertyname="Description" validaterequiredfield="True">
                        </ui:uifieldtextbox>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabVendor" runat="server" beginninghtml="" borderstyle="NotSet" caption="Vendor and Amount" endinghtml="" meta:resourcekey="tabVendorResource1">
                    <ui:uipanel id="panelTabVendor" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelTabVendorResource1">
                        <ui:uiseparator id="sep1" runat="server" caption="Vendor" meta:resourcekey="sep1Resource1" />
                        <ui:uipanel id="panelVendor" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelVendorResource1">
                            <ui:uifieldsearchabledropdownlist id="dropVendor" runat="server" caption="Vendor" meta:resourcekey="dropVendorResource1" onselectedindexchanged="dropVendor_SelectedIndexChanged" propertyname="VendorID" searchinterval="300" validaterequiredfield="True">
                            </ui:uifieldsearchabledropdownlist>
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
                        <ui:uipanel id="panelTaxAmount" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelTaxAmountResource1">
                            <ui:uiseparator id="UISeparator1" runat="server" caption="Currency" meta:resourcekey="UISeparator1Resource1" />
                            <ui:uifielddropdownlist id="dropCurrency" runat="server" caption="Currency" meta:resourcekey="dropCurrencyResource1" onselectedindexchanged="dropCurrency_SelectedIndexChanged" propertyname="CurrencyID" span="Half" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <table border="0" cellpadding="0" cellspacing="0" style="clear: both;">
                                <tr class="field-required" style="height: 25px">
                                    <td style="width: 150px">
                                        <asp:Label ID="labelExchangeRate" runat="server" meta:resourcekey="labelExchangeRateResource1">Exchange Rate*:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="labelER1" runat="server" meta:resourcekey="labelER1Resource1">1</asp:Label>
                                        <ui:uifieldlabel id="labelERThisCurrency" runat="server" dataformatstring="" fieldlayout="Flow" internalcontrolwidth="20px" meta:resourcekey="labelERThisCurrencyResource1" propertyname="Currency.ObjectName" showcaption="False">
                                        </ui:uifieldlabel>
                                        <asp:Label ID="labelEREquals" runat="server" meta:resourcekey="labelEREqualsResource1">is equal to</asp:Label>
                                        <ui:uifieldtextbox id="textForeignToBaseExchangeRate" runat="server" caption="Exchange Rate" fieldlayout="Flow" internalcontrolwidth="60px" meta:resourcekey="textForeignToBaseExchangeRateResource1" ontextchanged="textForeignToBaseExchangeRate_TextChanged" propertyname="ForeignToBaseExchangeRate" showcaption="False" span="Half" validatedatatypecheck="True" validaterequiredfield="True" validationdatatype="Currency">
                                        </ui:uifieldtextbox>
                                        <asp:Label ID="labelERBaseCurrency" runat="server" meta:resourcekey="labelERBaseCurrencyResource1"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <ui:uiseparator id="UISeparator4" runat="server" caption="Invoice Amount" meta:resourcekey="UISeparator4Resource1" />
                            <ui:uipanel id="panelCreditDebitMemoDetails" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelCreditDebitMemoDetailsResource1">
                                <ui:uihint id="hintCreditDebitMemo" runat="server" meta:resourcekey="hintCreditDebitMemoResource1">
                            <asp:Table runat="server" CellPadding="4" CellSpacing="0" Width="100%">
                                <asp:TableRow runat="server">
                                    <asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" ImageUrl="~/images/information.gif" /></asp:TableCell>
                                    <asp:TableCell runat="server" VerticalAlign="Top"><asp:Label runat="server"> NOTE: This is a credit/debit memo </asp:Label></asp:TableCell>
                                </asp:TableRow>
                            </asp:Table>
                                </ui:uihint>
                            </ui:uipanel>
                            <ui:uipanel id="panelSelectedCurrency" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelSelectedCurrencyResource1">
                                <ui:uifielddropdownlist id="dropTaxCode" runat="server" caption="Tax Code" captionwidth="150px" meta:resourcekey="dropTaxCodeResource1" onselectedindexchanged="dropTaxCode_SelectedIndexChanged" propertyname="TaxCodeID" validaterequiredfield="True">
                                </ui:uifielddropdownlist>
                                <ui:uifieldtextbox id="textTotalAmountInSelectedCurrency" runat="server" caption="Total Net Amount" captionwidth="150px" dataformatstring="{0:#,##0.00}" internalcontrolwidth="95%" meta:resourcekey="textTotalAmountInSelectedCurrencyResource1" ontextchanged="textTotalAmountInSelectedCurrency_TextChanged" propertyname="TotalAmountInSelectedCurrency" span="Half" validaterangefield="True" validaterequiredfield="True" validationrangemin="0" validationrangetype="Currency">
                                </ui:uifieldtextbox>
                                <ui:uifieldtextbox id="textTotalTaxInSelectedCurrency" runat="server" caption="Total Tax Amount" captionwidth="150px" dataformatstring="{0:#,##0.00}" internalcontrolwidth="95%" meta:resourcekey="textTotalTaxInSelectedCurrencyResource1" ontextchanged="textTotalTaxInSelectedCurrency_TextChanged" propertyname="TotalTaxInSelectedCurrency" span="Half" validaterangefield="True" validaterequiredfield="True" validationrangemin="0" validationrangetype="Currency">
                                </ui:uifieldtextbox>
                            </ui:uipanel>
                            <ui:uipanel id="panelBaseCurrency" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelBaseCurrencyResource1">
                                <ui:uifieldlabel id="labelTotalAmount" runat="server" caption="Total Net Amount" captionwidth="150px" dataformatstring="{0:n}" meta:resourcekey="labelTotalAmountResource1" propertyname="TotalAmount" span="Half">
                                </ui:uifieldlabel>
                                <ui:uifieldlabel id="labelTotalTax" runat="server" caption="Total Tax Amount" captionwidth="150px" dataformatstring="{0:n}" meta:resourcekey="labelTotalTaxResource1" propertyname="TotalTax" span="Half">
                                </ui:uifieldlabel>
                            </ui:uipanel>
                            <ui:uipanel id="panelOriginalInvoice" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelOriginalInvoiceResource1">
                                <ui:uiseparator id="UISeparator3" runat="server" caption="Original Invoice Amount" meta:resourcekey="UISeparator3Resource1" />
                                <ui:uifieldlabel id="labelOriginalTotalAmount" runat="server" caption="Total Net Amount" captionwidth="150px" dataformatstring="{0:n}" meta:resourcekey="labelOriginalTotalAmountResource1" propertyname="CreditDebitMemoOnInvoice.TotalAmount" span="Half">
                                </ui:uifieldlabel>
                                <ui:uifieldlabel id="labelOriginalTotalTax" runat="server" caption="Total Net Amount" captionwidth="150px" dataformatstring="{0:n}" meta:resourcekey="labelOriginalTotalTaxResource1" propertyname="CreditDebitMemoOnInvoice.TotalTax" span="Half">
                                </ui:uifieldlabel>
                                <ui:uifieldlabel id="labelOriginalTotalCreditDebitMemoAmount" runat="server" caption="Credit/Debit Memos" captionwidth="150px" dataformatstring="{0:n}" forecolor="Red" meta:resourcekey="labelOriginalTotalCreditDebitMemoAmountResource1" propertyname="CreditDebitMemoOnInvoice.TotalCreditDebitMemoAmount">
                                </ui:uifieldlabel>
                                <ui:uifieldlabel id="labelOriginalTotalAfterCreditDebitMemoAmount" runat="server" caption="Total Balance" captionwidth="150px" dataformatstring="{0:n}" meta:resourcekey="labelOriginalTotalAfterCreditDebitMemoAmountResource1" propertyname="CreditDebitMemoOnInvoice.TotalAmountAfterCreditDebitMemos">
                                </ui:uifieldlabel>
                            </ui:uipanel>
                        </ui:uipanel>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabBudget" runat="server" beginninghtml="" borderstyle="NotSet" caption="Budget" endinghtml="" meta:resourcekey="tabBudgetResource1">
                    <ui:uipanel id="panelAddBudgets" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelAddBudgetsResource1">
                        <ui:uibutton id="buttonApplyBudgets" runat="server" causesvalidation="False" imageurl="~/images/add.gif" meta:resourcekey="buttonApplyBudgetsResource1" onclick="buttonApplyBudgets_Click" text="Automatically apply budgets from Purchase Order" />
                        <ui:uibutton id="buttonAddBudgets" runat="server" causesvalidation="False" imageurl="~/images/add.gif" meta:resourcekey="buttonAddBudgetsResource1" onclick="buttonAddBudgets_Click" text="Selectively add budgets from Purchase Order" />
                        <br />
                        <br />
                    </ui:uipanel>
                    <ui:uipanel id="panelAddInvoiceBudgets" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelAddInvoiceBudgetsResource1">
                        <ui:uibutton id="buttonApplyInvoiceBudgets" runat="server" causesvalidation="False" imageurl="~/images/add.gif" meta:resourcekey="buttonApplyInvoiceBudgetsResource1" onclick="buttonApplyInvoiceBudgets_Click" text="Automatically apply budgets from matched invoice" />
                        <br />
                        <br />
                    </ui:uipanel>
                    <ui:uigridview id="gridBudget" runat="server" caption="Budgets" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" meta:resourcekey="gridBudgetResource1" pagesize="50" propertyname="PurchaseBudgets" rowerrorcolor="" showfooter="True" style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="DeleteObject" commandtext="Delete" confirmtext="Are you sure you wish to delete the selected items?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
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
                            <ui:uigridviewboundcolumn datafield="Budget.ObjectName" headertext="Budget" meta:resourcekey="UIGridViewBoundColumnResource1" propertyname="Budget.ObjectName" resourceassemblyname="" sortexpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.Path" headertext="Account" meta:resourcekey="UIGridViewBoundColumnResource2" propertyname="Account.Path" resourceassemblyname="" sortexpression="Account.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.AccountCode" headertext="Account Code" meta:resourcekey="UIGridViewBoundColumnResource3" propertyname="Account.AccountCode" resourceassemblyname="" sortexpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="StartDate" dataformatstring="{0:dd-MMM-yyyy}" headertext="Accrual Date" meta:resourcekey="UIGridViewBoundColumnResource4" propertyname="StartDate" resourceassemblyname="" sortexpression="StartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Amount" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Amount" meta:resourcekey="UIGridViewBoundColumnResource5" propertyname="Amount" resourceassemblyname="" sortexpression="Amount">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:uiobjectpanel id="panelBudget" runat="server" beginninghtml="" borderstyle="NotSet" endinghtml="" meta:resourcekey="panelBudgetResource1">
                        <web:subpanel ID="subpanelBudget" runat="server" GridViewID="gridBudget" OnPopulateForm="subpanelBudget_PopulateForm" OnRemoved="subpanelBudget_Removed" OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate" />
                        <ui:uifielddropdownlist id="dropBudget" runat="server" caption="Budget" meta:resourcekey="dropBudgetResource1" onselectedindexchanged="dropBudget_SelectedIndexChanged" propertyname="BudgetID" validaterequiredfield="True">
                        </ui:uifielddropdownlist>
                        <ui:uifielddatetime id="dateStartDate" runat="server" caption="Accrual Date" enabled="False" meta:resourcekey="dateStartDateResource1" propertyname="StartDate" showdatecontrols="True" span="Half" validaterequiredfield="True">
                        </ui:uifielddatetime>
                        <ui:uifieldtreelist id="treeAccount" runat="server" caption="Account" meta:resourcekey="treeAccountResource1" onacquiretreepopulater="treeAccount_AcquireTreePopulater" propertyname="AccountID" showcheckboxes="None" treevaluemode="SelectedNode" validaterequiredfield="True">
                        </ui:uifieldtreelist>
                        <ui:uifieldtextbox id="textAmount" runat="server" caption="Amount" internalcontrolwidth="95%" meta:resourcekey="textAmountResource1" propertyname="Amount" span="Half" validaterequiredfield="True" validationrangemin="1" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                    </ui:uiobjectpanel>
                    <br />
                    <br />
                    <ui:uigridview id="gridBudgetSummary" runat="server" caption="Budget Summary" checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" meta:resourcekey="gridBudgetSummaryResource1" onaction="gridBudgetSummary_Action" pagesize="50" propertyname="PurchaseBudgetSummaries" rowerrorcolor="" showfooter="True" style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewboundcolumn datafield="Budget.ObjectName" headertext="Budget" meta:resourcekey="UIGridViewBoundColumnResource6" propertyname="Budget.ObjectName" resourceassemblyname="" sortexpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="BudgetPeriod.ObjectName" headertext="Budget Period" meta:resourcekey="UIGridViewBoundColumnResource7" propertyname="BudgetPeriod.ObjectName" resourceassemblyname="" sortexpression="BudgetPeriod.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" commandname="ViewBudget" imageurl="~/images/printer.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="Account.ObjectName" headertext="Account" meta:resourcekey="UIGridViewBoundColumnResource8" propertyname="Account.ObjectName" resourceassemblyname="" sortexpression="Account.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Account.AccountCode" headertext="Account Code" meta:resourcekey="UIGridViewBoundColumnResource9" propertyname="Account.AccountCode" resourceassemblyname="" sortexpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAdjusted" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total After Adjustments" meta:resourcekey="UIGridViewBoundColumnResource10" propertyname="TotalAvailableAdjusted" resourceassemblyname="" sortexpression="TotalAvailableAdjusted">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableBeforeSubmission" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total Before Submission" meta:resourcekey="UIGridViewBoundColumnResource11" propertyname="TotalAvailableBeforeSubmission" resourceassemblyname="" sortexpression="TotalAvailableBeforeSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAtSubmission" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total At Submission" meta:resourcekey="UIGridViewBoundColumnResource12" propertyname="TotalAvailableAtSubmission" resourceassemblyname="" sortexpression="TotalAvailableAtSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="TotalAvailableAfterApproval" dataformatstring="{0:c}" footeraggregate="Sum" headertext="Total After Approval" meta:resourcekey="UIGridViewBoundColumnResource13" propertyname="TotalAvailableAfterApproval" resourceassemblyname="" sortexpression="TotalAvailableAfterApproval">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabWorkHistory" runat="server" beginninghtml="" borderstyle="NotSet" caption="Status History" endinghtml="" meta:resourcekey="tabWorkHistoryResource1">
                    <web:ActivityHistory ID="ActivityHistory" runat="server" />
                </ui:uitabview>
                <ui:uitabview id="tabMemo" runat="server" beginninghtml="" borderstyle="NotSet" caption="Memo" endinghtml="" meta:resourcekey="tabMemoResource1">
                    <web:memo ID="memo1" runat="server" />
                </ui:uitabview>
                <ui:uitabview id="tabAttachments" runat="server" beginninghtml="" borderstyle="NotSet" caption="Attachments" endinghtml="" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:uitabview>
            </ui:uitabstrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
