<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.Drawing.Drawing2D" %>


<script runat="server">
    
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        OPurchaseInvoice obj = panel.SessionObject as OPurchaseInvoice;
        
        if (!IsPostBack)
        {
            labelTotalAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelTotalTax.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalTax.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalCreditDebitMemoAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            labelOriginalTotalAfterCreditDebitMemoAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            lblCreditNoteAmount.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            lblCreditNoteTax.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            panel.Caption = obj.InvoiceTypeText;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="invoice"></param>
    protected void BindLocation(OPurchaseInvoice invoice)
    {
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        
        ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, invoice.LocationID));
        
        if (invoice.IsNew && ddlLocation.Items.Count == 2)
            invoice.LocationID = new Guid(ddlLocation.Items[1].Value);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="invoice"></param>
    protected void BindVendorPurchaseType(OPurchaseInvoice invoice)
    {
        BudgetGroupID.Bind(AppSession.User.GetAllAccessibleBudgetGroup("OPurchaseInvoice", invoice.BudgetGroupID));

        if (invoice.IsNew && BudgetGroupID.Items.Count == 1)
            invoice.BudgetGroupID = new Guid(BudgetGroupID.Items[0].Value);
        
        dropVendor.Bind(OVendor.GetVendors(DateTime.Today, invoice.VendorID, AppSession.User, Security.Decrypt(Request["TYPE"])));

        dropPurchaseTypeClassification.Bind(OCode.GetPurchaseGroupTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), invoice.TransactionTypeGroupID));
        
        dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, invoice.TransactionTypeGroupID, Security.Decrypt(Request["TYPE"]), invoice.PurchaseTypeID));
        if (invoice.TransactionTypeGroupID != null)
            dropPaymentType.Bind(OCode.GetCodesByTypeAndParentID("PaymentType", invoice.TransactionTypeGroupID, null));
        
        if (invoice.TransactionTypeGroupID == null && dropPurchaseTypeClassification.Items.Count == 1)
        {
            invoice.TransactionTypeGroupID = new Guid(dropPurchaseTypeClassification.Items[0].Value);
            dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, new Guid(dropPurchaseTypeClassification.Items[0].Value), Security.Decrypt(Request["TYPE"]), invoice.PurchaseTypeID));
            dropPaymentType.Bind(OCode.GetCodesByTypeAndParentID("PaymentType", new Guid(dropPurchaseTypeClassification.Items[0].Value), null));
        }

        // 2011.08.10, Kien Trung
        // Default payment type
        //
        if (invoice.PaymentTypeID == null && dropPaymentType.Items.Count == 2)
            invoice.PaymentTypeID = new Guid(dropPaymentType.Items[1].Value);

        if (invoice.IsNew)
            invoice.DateOfInvoice = DateTime.Today;

        dropTaxCode.Bind(OTaxCode.GetAllTaxCodes(invoice.DateOfInvoice, invoice.TaxCodeID));

        if (invoice.CurrencyID == null)
        {
            invoice.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;
            invoice.ForeignToBaseExchangeRate = 1.0M;
        }
        
        dropCurrency.Bind(OCurrency.GetAllCurrencies(invoice.CurrencyID), "CurrencyNameAndDescription", "ObjectID", true);

        labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;
    }
    
    /// <summary>
    /// Occurs when the form loads.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

        objectBase.ObjectNumberVisible = !invoice.IsNew;
        
        if (!IsPostBack)
        {
            BindLocation(invoice);
            BindVendorPurchaseType(invoice);
            BindOriginalInvoices(invoice);
        }
        
        if (invoice.PurchaseOrderID != null)
            dropPOMatchedInvoice.PropertyName = "CreditDebitMemoOnInvoiceID";
        else
        {
            popupDirectInvoice.PropertyName = "CreditDebitMemoOnInvoiceID";
            popupDirectInvoice.PropertyNameItem = "CreditDebitMemoOnInvoice.ObjectNumber";
        }

        
        // 2011.07.30, Kien Trung
        // FIX: Display error unable to transafer amount
        // in friendlier manner.
        //
        try
        {
            if (invoice.CurrentActivity == null ||
                !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
            {
                invoice.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
            else
                gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";
        }
        catch (Exception ex)
        {
            panel.PopupMessage = gridBudget.ErrorMessage = ex.Message + Resources.Errors.PurchaseInvoice_UnableToTransferAmountFromTransactionLog;
            panel.ObjectPanel.BindObjectToControls(invoice);

        }
        
        panel.ObjectPanel.BindObjectToControls(invoice);
        
        
       
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="invoice"></param>
    protected void BindOriginalInvoices(OPurchaseInvoice invoice)
    {
        dropPOMatchedInvoice.Bind(OPurchaseInvoice.GetPOMatchedStandardInvoices(invoice.PurchaseOrderID, invoice.CreditDebitMemoOnInvoiceID), "ObjectNumberAndDescription", "ObjectID");
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void panel_Validate(object sender, PersistentObject obj)
    {
        string action = objectBase.SelectedAction;
        string state = objectBase.CurrentObjectState;        
        
        OPurchaseInvoice invoice = obj as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        // Validate
        //            
        if (action.Is("SubmitForApproval"))
        {
            
            if (panelAddBudgets.Visible && 
                invoice.PurchaseBudgets.Count == 0)
                buttonApplyBudgets_Click(sender, EventArgs.Empty);

            // 2011.08.10, Kien Trung
            // NEW: Validate invoice enter has duplicate reference number
            //
            // TODO: 20120209 PTB Update in LogicLayer and reserve back
            //Boolean isDuplicatateInvoiceNumber =
            //TablesLogic.tPurchaseInvoice.Load
            //    (TablesLogic.tPurchaseInvoice.ObjectID != invoice.ObjectID &
            //    (TablesLogic.tPurchaseInvoice.ReferenceNumber == invoice.ReferenceNumber) &
            //    TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName != "Cancelled" &
            //    TablesLogic.tPurchaseInvoice.VendorID == invoice.VendorID) == null;
            if (invoice.IsDuplicateInvoiceNumber)
            //if (!isDuplicatateInvoiceNumber)
                textReferenceNumber.ErrorMessage = Resources.Errors.PurchaseInvoice_DuplicateInvoiceNumber;
            // END

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
            //string closedBudgets = OPurchaseBudget.ValidateBudgetPeriodsActiveAndOpened(invoice.PurchaseBudgets);
            //if (closedBudgets != "")
            //    gridBudget.ErrorMessage = String.Format(Resources.Errors.PurchaseInvoice_BudgetPeriodsClosed, closedBudgets);


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
            decimal totalinvoiceamount = 0;
            if (invoice.PurchaseOrder != null)
            {
                totalinvoiceamount = (decimal)TablesLogic.tPurchaseInvoice.Select(
                    TablesLogic.tPurchaseInvoice.TotalAmountInSelectedCurrency.Sum())
                    .Where
                    (TablesLogic.tPurchaseInvoice.PurchaseOrderID == invoice.PurchaseOrderID &
                    TablesLogic.tPurchaseInvoice.ObjectID != invoice.ObjectID &
                    TablesLogic.tPurchaseInvoice.IsDeleted == 0);
            }

            if (invoice.PurchaseOrder == null ||
                (invoice.PurchaseOrder != null && 
                (totalinvoiceamount + invoice.TotalAmountInSelectedCurrency) > invoice.PurchaseOrder.SubTotalInSelectedCurrency))
            {
                string insufficientAccounts = invoice.ValidateSufficientBudget();
                if (insufficientAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseInvoice_InsufficientBudget, insufficientAccounts);
                }
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

            // If the IsInvoiceGreaterThanPOAllowed is == 1 return true else
            // Validates if the invoice amount is lesser than the POAmount
            if (!invoice.ValidateInvoiceLessThanOrEqualsToPOAmount())
                textTotalAmountInSelectedCurrency.ErrorMessage = Resources.Errors.PurchaseInvoice_ValidateInvoiceLessThanOrEqualsToPOAmountFailed;

            if (invoice.IsContainsCreditNote == (int)EnumApplicationGeneral.Yes)
            {
                decimal? budgetAmount = 0M;
                foreach (OPurchaseBudget budget in invoice.PurchaseBudgets)
                    budgetAmount += budget.Amount.Value;

                // Took out this check || (budgetAmount < invoice.CreditNoteAmount)
                // Due to there's already a check that Invoice Amount == Budget Amount
                if (invoice.TotalAmountInSelectedCurrency < invoice.CreditNoteAmountInSelectedCurrency)
                    txtCreditNoteAmountInSelectedCurrency.ErrorMessage = Resources.Errors.PurchaseInvoice_InsufficientAutoCreditNoteNetAmount;
                
                if (invoice.TotalTaxInSelectedCurrency < invoice.CreditNoteTaxInSelectedCurrency)
                    txtCreditNoteTaxAmountInSelectedCurrency.ErrorMessage = Resources.Errors.PurchaseInvoice_InsufficientAutoCreditNoteTaxAmount;    
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
            //panel.ObjectPanel.BindControlsToObject(invoice);

            panel_Validate(sender, invoice);

            if (!panel.ObjectPanel.IsValid)
                return;
            
            if (invoice.AutoGeneratedCreditNoteID != null && objectBase.SelectedAction.Is("-", "SubmitForApproval"))
            {
                OPurchaseInvoice creditnote = invoice.UpdateAutoGeneratedCreditNote();
                creditnote.Save();
            }

            // Save Original invoice image.
            //
            /*
             * Kien Trung, commented out, no longer necessary.
             * 
            if (invoice.PurchaseInvoiceVendorItem != null)
                invoice.PurchaseInvoiceVendorItem.Save();            
            */

            // Save
            //
            invoice.Save();

            c.Commit();
        }
    }


    protected void BudgetGroupID_SelectedIndexChanged(object sender, EventArgs e)
    {
    }

    /***************************
    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        return new LocationTreePopulaterForCapitaland(invoice.LocationID, false, true, 
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


    ///// <summary>
    ///// Updates the location to the location of the selected equipment.
    ///// </summary>
    ///// <param name="sender"></param>
    ///// <param name="e"></param>
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
    ****************************/


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
        /**********
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        foreach (OPurchaseOrderItem poItem in po.PurchaseOrderItems)
            poItem.CurrencyID = po.CurrencyID;
        ********/
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
            Guid? purchaseTypeID = null;
            if (dropPurchaseType.SelectedValue != "")
                purchaseTypeID = new Guid(dropPurchaseType.SelectedValue);

            Guid budgetId = prBudget.BudgetID.Value;
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, prBudget.StartDate.Value);

            if (budgetPeriod != null)
                return new AccountTreePopulaterForCapitaland(prBudget.AccountID, false, true, budgetPeriod.ObjectID, purchaseTypeID);
            else
                return new AccountTreePopulaterForCapitaland(prBudget.AccountID, false, true, null, purchaseTypeID);
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
            catch (Exception ex)
            {
                panel.PopupMessage = gridBudget.ErrorMessage = ex.Message + Resources.Errors.PurchaseInvoice_UnableToTransferAmountFromTransactionLog;
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
        try
        {
            if (invoice.CurrentActivity == null ||
                !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
            {
                invoice.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
        }
        catch (Exception ex)
        {
            panel.PopupMessage = gridBudget.ErrorMessage = ex.Message + Resources.Errors.PurchaseInvoice_UnableToTransferAmountFromTransactionLog;
            return; 
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
                Window.Open("../../customizedmodulesforcapitaland-ccl/budgetperiod/budgetview.aspx?ID=" +
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

        // Hide/Show controls with purchase invoice type
        //
        HideShowDetailsTabControls(invoice);

        HideShowBudgetTabControls(invoice);

        Workflow_Setting(invoice);
        
        base.OnPreRender(e);
    }

    /// <summary>
    /// Hide and show controls in Budget Tab
    /// </summary>
    /// <param name="invoice"></param>
    protected void HideShowBudgetTabControls(OPurchaseInvoice invoice)
    {
        // if date of invoice selected enable budget gridview
        // user can only add budget if there is location selected.
        //
        tabBudget.Visible = gridBudget.Enabled = (ddlLocation.SelectedValue != "" && dateDateOfInvoice.DateTime != null);

        gridBudget.Commands[1].Visible =
            !subpanelBudget.Visible && radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() &&
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();

        panelAddBudgets.Visible = invoice.PurchaseOrderID != null && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();

        panelAddInvoiceBudgets.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();
        
        BudgetGroupID.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible && invoice.PurchaseOrderID == null;

        panelBudget2.Visible = invoice.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;

        hintBudgetNotRequired.Visible = invoice.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired;
    }
    
    /// <summary>
    /// Hide and show controls in invoice details tab
    /// </summary>
    /// <param name="invoice"></param>
    private void HideShowDetailsTabControls(OPurchaseInvoice invoice)
    {
        dateDateOfInvoice.Enabled = gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;
        panelInvoice.Enabled = gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;

        // Set access control for the buttons
        //
        buttonViewPurchaseOrder.Visible = AppSession.User.AllowViewAll("OPurchaseOrder") && (invoice.PurchaseOrderID != null);
        buttonEditPurchaseOrder.Visible = (AppSession.User.AllowEditAll("OPurchaseOrder") || OActivity.CheckAssignment(AppSession.User, invoice.PurchaseOrderID)) && (invoice.PurchaseOrderID != null);
        dropPOMatchedInvoice.Visible = (invoice.PurchaseOrderID != null);
        popupDirectInvoice.Visible = (invoice.PurchaseOrderID == null);
        
        // if it's matching direct invoice and it's standard invoice type enable purchase type, enable dropdown location
        // if there is no purchase budget.
        //
        panelVendor.Enabled = 
            dropPurchaseType.Enabled = 
            radioInvoiceType.Enabled = (radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString());

        ddlLocation.Enabled = (radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString()) && (gridBudget.Rows.Count == 0 && !subpanelBudget.Visible);

        // display credit note detail if checkbox indicate if invoice submit together with a credit note checked.
        //
        panelCreditNoteDetails.Visible = cb_IsContainsCreditNote.Checked;
        
        // Enable Purchase Type Classification
        // if It's direct invoice not matching with PO.
        //
        dropPurchaseTypeClassification.Enabled = invoice.PurchaseOrderID == null;
        labelPurchaseOrderNumber.Visible = invoice.PurchaseOrderID != null;
        
        // Hide/Show Purchase Type or Payment Type
        //
        dropPurchaseType.Visible = radioMatchType.SelectedValue != Convert.ToString(PurchaseMatchType.DirectInvoice);
        dropPaymentType.Visible = dropPurchaseTypeClassification.Visible = radioInvoiceType.SelectedValue == Convert.ToString(PurchaseInvoiceType.StandardInvoice) || (radioInvoiceType.SelectedValue == Convert.ToString(PurchaseInvoiceType.CreditMemo));

        // 2011.03.11, Joey
        // hides the credit memo panel in the vendor amount tab 
        // when user selects "credit memo" in details tab
        //
        sepCreditMemo.Visible = panelCreditNote.Visible = (radioInvoiceType.SelectedValue != PurchaseInvoiceType.CreditMemo.ToString());
        dateStartDate.Enabled = radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString();
        
        radioMatchType.Enabled = false;
        
        dropCurrency.Enabled = textForeignToBaseExchangeRate.Enabled =
            radioMatchType.SelectedValue == PurchaseMatchType.DirectInvoice.ToString() &&
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();
        
        panelInvoice.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();
        
        hintCreditDebitMemo.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();
        
        panelOriginalInvoice.Visible =
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.CreditMemo.ToString() ||
            radioInvoiceType.SelectedValue == PurchaseInvoiceType.DebitMemo.ToString();

        /****************
        if (invoice.IsNew)
        {
            if (invoice.BudgetGroupID == null && BudgetGroupID.Items.Count == 1)
                BudgetGroupID.SelectedIndex = 0;

            if (invoice.TransactionTypeGroupID == null && dropPurchaseTypeClassification.Items.Count == 1)
            {
                dropPurchaseTypeClassification.SelectedIndex = 0;
                //dropPurchaseType.Bind(OCode.GetCodesByTypeAndParentID("PurchaseType", new Guid(dropPurchaseTypeClassification.SelectedValue), null));
                dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, new Guid(dropPurchaseTypeClassification.SelectedValue), Security.Decrypt(Request["TYPE"]), invoice.PurchaseTypeID));
                dropPaymentType.Bind(OCode.GetCodesByTypeAndParentID("PaymentType", new Guid(dropPurchaseTypeClassification.SelectedValue), null));
            }

            if (invoice.PaymentTypeID == null && dropPaymentType.Items.Count == 2)
            {
                dropPaymentType.SelectedIndex = 1;
                invoice.PaymentTypeID = new Guid(dropPaymentType.SelectedValue);
            }
        }
        *****************/

        panelDetails.Enabled = tabVendor.Enabled = tabBudget.Enabled = 
            !(invoice.IsAutoGeneratedFromInvoice == 1);
    }
    
    /// <summary>
    /// Workflow Setting ()
    /// Hide/Show workflow controls
    /// 
    /// </summary>
    private void Workflow_Setting(OPurchaseInvoice invoice)
    {
        string action = objectBase.SelectedAction;
        string currentState = objectBase.CurrentObjectState;
        
        // Display button to create credit (debit) memo
        // if status of invoice is Approved and
        // invoice type = standard invoice.
        //
        panelCreateCreditDebitMemos.Visible =
            currentState.Is("Approved") && radioInvoiceType.SelectedValue == PurchaseInvoiceType.StandardInvoice.ToString();

        panelDetails.Enabled = tabMemo.Enabled = tabAttachments.Enabled = !currentState.Is("PendingApproval", "Approved", "Cancelled", "Close");
    

        // 2011.07.07, Kien Trung
        // Enable details, vendor, budget tabs
        // if current status is at Start, Draft or RejectedForRework.
        //
        panelDetails.Enabled = tabVendor.Enabled =
            tabBudget.Enabled = currentState.Is("Start", "Draft", "RejectedforRework");

        // 2011.07.07, Kien Trung
        // Hide SubmitForApproval_Invoice button
        // 
        ListItem item = objectBase.GetWorkflowRadioListItem("SubmitForApproval_Invoice");
        if (item != null)
            item.Enabled = !currentState.Is("Start", "Draft", "RejectedforRework");
        

        // Kien Trung
        // Hide Cancel button when it's Pending Approval and Approved.
        // Hide because CCL did not adopt Invoice online approvel yet.
        // Unhide when this feature be implemented.
        //
        ListItem cancel = objectBase.GetWorkflowRadioListItem("Cancel");
        if (cancel != null)
            cancel.Enabled = !currentState.Is("PendingApproval");

        ListItem submitCancel = objectBase.GetWorkflowRadioListItem("SubmitForApproval_InvoiceCancellation");
        if (submitCancel != null)
            submitCancel.Enabled = !currentState.Is("Approved");

        dropTaxCode.ValidateRequiredField =
            textTotalTaxInSelectedCurrency.ValidateRequiredField = 
            textReferenceNumber.ValidateRequiredField =
            dropPOMatchedInvoice.ValidateRequiredField = (!action.Is("Cancel"));   

        if (objectBase.CurrentObjectState.Is("Start", "Draft"))
        {
            textForeignToBaseExchangeRate.Enabled = OApplicationSetting.Current.AllowChangeOfExchangeRate == 2;
        }

        attachments.ValidateRequiredField = action.Is("SubmitForApproval");
        
        //lblFileName.ValidateRequiredField = action.Is("SubmitForApproval") && (invoice.PurchaseInvoiceVendorItem == null);
    }


    protected void dropPurchaseTypeClassification_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropPurchaseTypeClassification.SelectedValue != "")
        {
            //dropPurchaseType.Bind(OCode.GetCodesByTypeAndParentID("PurchaseType", new Guid(dropPurchaseTypeClassification.SelectedValue), null));
            dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, new Guid(dropPurchaseTypeClassification.SelectedValue), Security.Decrypt(Request["TYPE"]), null));
            dropPaymentType.Bind(OCode.GetCodesByTypeAndParentID("PaymentType", new Guid(dropPurchaseTypeClassification.SelectedValue), null));
        }
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

        if (cb_IsContainsCreditNote.Checked)
        {
            invoice.UpdateCreditNoteTax();
            invoice.UpdateCreditNoteAmountAndTaxInBaseCurrency();
            panelCreditNoteDetails.BindObjectToControls(invoice);
        }
        
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
            panel.FocusWindow = false;
            Window.OpenViewObjectPageInNewWindow(this, "OPurchaseOrder", po.PurchaseOrderID.ToString(), "N=1");
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
        decimal recoverableAmount = 0.0M;
        if (invoice.PurchaseOrder != null &&
                invoice.PurchaseOrder.IsRecoverable == (int)EnumRecoverable.Recoverable)
            recoverableAmount = LogicLayerPersistentObject.Round(invoice.TotalAmount.Value * invoice.PurchaseOrder.TotalRecoverableAmount.Value / invoice.PurchaseOrder.SubTotal);
        
        List<OPurchaseBudget> purchaseBudgets =
            OPurchaseBudget.TransferPartialPurchaseBudgets(
            invoice.PurchaseOrder.PurchaseBudgets, null, (invoice.TotalAmount.Value - recoverableAmount));
        invoice.PurchaseBudgets.Clear();
        invoice.PurchaseBudgets.AddRange(purchaseBudgets);
        try
        {
            if (invoice.CurrentActivity == null ||
                !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
            {
                invoice.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
        }
        catch (Exception ex)
        {
            textAmount.ErrorMessage = ex.Message;
            return;
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
            invoice.CreditDebitMemoOnInvoice.PurchaseBudgets, null, invoice.TotalAmount.Value);
        invoice.PurchaseBudgets.Clear();
        invoice.PurchaseBudgets.AddRange(purchaseBudgets);
        
        tabBudget.BindObjectToControls(invoice);
        try
        {
            if (invoice.CurrentActivity == null ||
                !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
            {
                invoice.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
        }
        catch (Exception ex)
        {
            panel.PopupMessage =gridBudget.ErrorMessage = ex.Message + 
                "<br />Please revise the amount before proceeding to submit for approval. This happens when the total amount exceeded budget amount committed of previous purchase document.";
            return;
        }
        
        
        
        
    }



    /// <summary>
    /// Add budgets from the purchase order.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddBudgets_Click(object sender, EventArgs e)
    {
        //Window.Open("addpobudgets.aspx", "AnacleEAM_Popup");
        //panel.FocusWindow = false;
        searchPurchaseOrderBudgets.Show();
    }


    protected void radioInvoiceType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
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
        {
            List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
            //treeLocation.PopulateTree();
            ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, invoice.LocationID));
        }
        //if (invoice.EquipmentID != null)
        //    treeEquipment.PopulateTree();
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

    protected void ddlLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.EquipmentID = null;
        invoice.UpdateApplicablePurchaseSettings();
        panel.ObjectPanel.BindObjectToControls(invoice);
    }

    protected void objectBase_PreRender(object sender, EventArgs e)
    {

    }

    protected void gridBudget_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "AddBudget")
        {
            buttonAddBudget_Click(sender, EventArgs.Empty);
        }
    }
    /// <summary>
    /// Add budget account.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddBudget_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice pi = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(pi);

        if (BudgetGroupID.SelectedValue != "")
            dropAddBudget.Bind(OBudget.GetCoveringBudgets(pi.Location, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));


        dateAddBudgetDate.DateTime = pi.DateOfInvoice;

        if (dropAddBudget.Items.Count == 2)
        {
            dropAddBudget.SelectedIndex = 1;
            treeAddBudgetAccounts.PopulateTree();
        }
        Guid? accountID = GetApplicableAccountID();
        if (accountID != null)
            treeAddBudgetAccounts.SelectedValue = accountID.ToString();
        
        AutoComputeBudgetAmount(pi);
        popupAddBudget.Show();
        objectPanelAddBudget.Visible = true;
    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    protected Guid? GetApplicableAccountID()
    {
        if (dropAddBudget.SelectedValue != "")
        {
            Guid budgetId = new Guid(dropAddBudget.SelectedValue);
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, dateAddBudgetDate.DateTime.Value);
            if (budgetPeriod != null)
            {
                List<OBudgetPeriodOpeningBalance> bpOpeningBalances = budgetPeriod.BudgetPeriodOpeningBalances.FindAll((r) => r.IsActive == 1);
                if (bpOpeningBalances.Count == 1)
                    return bpOpeningBalances[0].AccountID;
            }
        }
        return null;
    }



    protected void dropAddBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        treeAddBudgetAccounts.PopulateTree();
    }

    protected TreePopulater treeAddBudgetAccounts_AcquireTreePopulater(object sender)
    {
        if (dateAddBudgetDate.DateTime != null && dropAddBudget.SelectedValue != "")
        {
            Guid? purchaseTypeID = null;
            if (dropPurchaseType.SelectedValue != "")
                purchaseTypeID = new Guid(dropPurchaseType.SelectedValue);

            Guid budgetId = new Guid(dropAddBudget.SelectedValue);
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, dateAddBudgetDate.DateTime.Value);

            if (budgetPeriod != null)
                return new AccountTreePopulaterForCapitaland(null, false, true, budgetPeriod.ObjectID, purchaseTypeID);
            else
                return new AccountTreePopulaterForCapitaland(null, false, true, null, purchaseTypeID);
        }
        return null;
    }

    protected void buttonAddBudgetConfirm_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
        pb.LocationID = invoice.LocationID;
        pb.BudgetID = new Guid(dropAddBudget.SelectedValue);
        pb.StartDate = dateAddBudgetDate.DateTime.Value;
        pb.EndDate = dateAddBudgetDate.DateTime.Value;
        pb.AccrualFrequencyInMonths = 1;
        pb.AccountID = new Guid(treeAddBudgetAccounts.SelectedValue);
        pb.Amount = Convert.ToDecimal(textAddBudgetAmount.Text);
        pb.AccrualFrequencyInMonths = 1;
        invoice.PurchaseBudgets.Add(pb);
        if (invoice.CurrentActivity == null ||
            !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            try
            {
                invoice.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
            catch (Exception ex)
            {
                textAmount.ErrorMessage = ex.Message;
                return;
            }
        }


        popupAddBudget.Hide();
        objectPanelAddBudget.Visible = false;
        tabBudget.BindObjectToControls(invoice);
    }

    protected void buttonAddBudgetCancel_Click(object sender, EventArgs e)
    {
        popupAddBudget.Hide();
        objectPanelAddBudget.Visible = false;
    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="invoice"></param>
    protected void AutoComputeBudgetAmount(OPurchaseInvoice invoice)
    {
        decimal? amount = 0;
        decimal? totalAmount = 0;
        totalAmount = invoice.TotalAmount;
        foreach (OPurchaseBudget pb in invoice.PurchaseBudgets)
            amount += pb.Amount;
        decimal remainAmount = totalAmount >= amount ? Convert.ToDecimal(totalAmount - amount) : 0;
        textAddBudgetAmount.Text = Math.Round(remainAmount, 2, MidpointRounding.AwayFromZero).ToString();
    }

    protected void cb_IsContainsCreditNote_CheckedChanged(object sender, EventArgs e)
    {

    }


    protected void txtCreditNoteTaxAmountInSelectedCurrency_TextChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateCreditNoteAmountAndTaxInBaseCurrency();
        panelCreditNoteDetails.BindObjectToControls(invoice);
    }

    protected void txtCreditNoteAmountInSelectedCurrency_TextChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        invoice.UpdateCreditNoteTax();
        invoice.UpdateCreditNoteAmountAndTaxInBaseCurrency();
        panelCreditNoteDetails.BindObjectToControls(invoice);
    }

    

    /// <summary>
    /// Occurs when the users clicks on the download button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonDownload_Click(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = (OPurchaseInvoice)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(invoice);
        panel.FocusWindow = false;
        Window.Download(invoice.PurchaseInvoiceVendorItem.FileBytes, invoice.PurchaseInvoiceVendorItem.ObjectName, invoice.PurchaseInvoiceVendorItem.ContentType);
    }

    protected void searchPurchaseOrderBudgets_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        
        e.CustomCondition =
            TablesLogic.tBudgetTransactionLog.PurchaseBudget.PurchaseOrderID == invoice.PurchaseOrderID;
    }

    protected void searchPurchaseOrderBudgets_Selected(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

        // 2011.01.07
        // Kim Foong
        // Hash table to store budget periods related to the transaction logs.
        // 
        Hashtable relatedBudgetPeriods = new Hashtable();

        List<OPurchaseBudget> purchaseBudgets = new List<OPurchaseBudget>();
        
        foreach (GridViewRow gvr in searchPurchaseOrderBudgets.SelectedRows)
        {
            // Create an add object
            //
            Guid id = (Guid)searchPurchaseOrderBudgets.SearchUIGridView.DataKeys[gvr.RowIndex][0];
            
            OBudgetTransactionLog log = TablesLogic.tBudgetTransactionLog.Load(id);

            purchaseBudgets = OPurchaseBudget.TransferPartialPurchaseBudgets(invoice.PurchaseOrder.PurchaseBudgets, log.PurchaseBudget.ItemNumber, log.TransactionAmount);
            
            invoice.PurchaseBudgets.AddRange(purchaseBudgets);
            
        }

        try
        {
            if (invoice.CurrentActivity == null ||
                !invoice.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
            {
                invoice.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
        }
        catch (Exception ex)
        {
            textAmount.ErrorMessage = ex.Message;
            return;
        }
        
        tabBudget.BindObjectToControls(invoice);
    }

    //protected void buttonFileInvoice_Click(object sender, EventArgs e)
    //{
    //    if (buttonFileInvoice.Attributes["ObjectID"] != "")
    //    {
    //        OPurchaseInvoice invoice = (OPurchaseInvoice)panel.SessionObject;
    //        panel.ObjectPanel.BindControlsToObject(invoice);
    //        panel.FocusWindow = false;
    //        Window.Download(invoice.PurchaseInvoiceVendorItem.FileBytes, invoice.PurchaseInvoiceVendorItem.ObjectName, invoice.PurchaseInvoiceVendorItem.ContentType);
    //    }
    //}

    //protected void fileUploadInvoice_Uploaded(object sender, EventArgs e)
    //{
    //    List<HttpPostedFile> postedFiles = fileUploadInvoice.GetUploadFiles();

    //    foreach (HttpPostedFile postedFile in postedFiles)
    //    {
    //        if (postedFile != null && postedFile.ContentLength > 0)
    //        {
    //            if (postedFile.ContentLength > 2048000)
    //                panel.Message = "Attached image should not be larger than 2 megabytes" + "<br/>";
    //            else if (!postedFile.FileName.ToUpper().EndsWith(".PNG") &&
    //                !postedFile.FileName.ToUpper().EndsWith(".JPG") &&
    //                !postedFile.FileName.ToUpper().EndsWith(".GIF"))
    //                panel.Message = "The photo is not of a correct format. Please upload only JPEGs, PNGs, or GIFs." + "<br/>";
    //            else
    //            {
    //                OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;

    //                byte[] fileBytes = new byte[postedFile.ContentLength];
    //                postedFile.InputStream.Position = 0;
    //                postedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

    //                OPurchaseInvoiceVendorItem item = invoice.PurchaseInvoiceVendorItem;

    //                if (item == null)
    //                    item = TablesLogic.tPurchaseInvoiceVendorItem.Create();
    //                item.FileBytes = fileBytes;
    //                item.PurchaseInvoiceID = invoice.ObjectID;
    //                item.ObjectName = Path.GetFileName(postedFile.FileName);
    //                item.FileSize = postedFile.ContentLength;
    //                item.ContentType = postedFile.ContentType;

    //                invoice.PurchaseInvoiceVendorItemID = item.ObjectID;
    //                invoice.PurchaseInvoiceVendorItem = item;
    //                Session["PurchaseInvoiceImage_" + invoice.PurchaseInvoiceVendorItemID] = item;

    //                if (invoice.PurchaseInvoiceVendorItem != null)
    //                {
    //                    buttonFileInvoice.Text = invoice.PurchaseInvoiceVendorItem.ObjectName;
    //                    buttonFileInvoice.Enabled = true;
    //                    buttonFileInvoice.Attributes["ObjectID"] = invoice.PurchaseInvoiceVendorItemID.ToString();
    //                }
    //                else
    //                {
    //                    buttonFileInvoice.Text = "No Original Invoice Uploaded";
    //                    buttonFileInvoice.Enabled = false;
    //                    buttonFileInvoice.Attributes["ObjectID"] = "";
    //                }
    //            }
    //        }
    //    }
    //}

    //protected void buttonUploadInvoice_Click(object sender, EventArgs e)
    //{
    //    fileUploadInvoice.Show();
    //}

    protected void dropPaymentType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = panel.SessionObject as OPurchaseInvoice;
        panel.ObjectPanel.BindControlsToObject(invoice);
        //BindVendorddl(invoice);
        panel.ObjectPanel.BindObjectToControls(invoice);
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Purchase Invoice" BaseTable="tPurchaseInvoice"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" ShowWorkflowActionAsButtons="true" SaveButtonsVisible="false"
            meta:resourcekey="panelResource1" OnValidate="panel_Validate"></web:object>
        <div class="div-main">
            <ui:UITabStrip ID="tabObject" runat="server" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" BorderStyle="NotSet" Caption="Details"
                    meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1"
                        ObjectNameVisible="false" ObjectNumberCaption="Invoice Number" ObjectNumberEnabled="false"
                        ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false" />
                    <ui:UIPanel ID="panelDetails" runat="server" BorderStyle="NotSet" meta:resourcekey="panelDetailsResource1"
                        Width="100%">
                        <ui:UIFieldRadioList ID="radioMatchType" runat="server" Caption="Match Type" meta:resourcekey="radioMatchTypeResource1"
                            PropertyName="MatchType" TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourceKey="ListItemResource1" Text="Direct invoice (not matched to any purchase document)."
                                    Value="0"></asp:ListItem>
                                <asp:ListItem meta:resourceKey="ListItemResource2" Text="Matched to Purchase Order."
                                    Value="1"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldRadioList ID="radioInvoiceType" runat="server" Caption="Invoice Type"
                            meta:resourcekey="radioInvoiceTypeResource1" OnSelectedIndexChanged="radioInvoiceType_SelectedIndexChanged"
                            PropertyName="InvoiceType" RepeatColumns="0" TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourceKey="ListItemResource3" Text="Standard Invoice" Value="0"></asp:ListItem>
                                <asp:ListItem meta:resourceKey="ListItemResource4" Text="Credit Memo" Value="1"></asp:ListItem>
                                <asp:ListItem meta:resourceKey="ListItemResource5" Text="Debit Memo" Value="2"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel ID="panelCreateCreditDebitMemos" runat="server" BorderStyle="NotSet"
                            meta:resourcekey="panelCreateCreditDebitMemosResource1">
                            <table>
                                <tr>
                                    <td style="width: 150px">
                                    </td>
                                    <td>
                                        <ui:UIButton ID="buttonCreateCreditMemo" runat="server" AlwaysEnabled="True" CausesValidation="False"
                                            ConfirmText="Please remember to save this Purchase Invoice before creating a credit memo.\n\nAre you sure you want to continue?"
                                            ImageUrl="~/images/tick.gif" meta:resourcekey="buttonCreateCreditMemoResource1"
                                            OnClick="buttonCreateCreditMemo_Click" Text="Create Credit Memo" />
                                        <ui:UIButton ID="buttonCreateDebitMemo" runat="server" AlwaysEnabled="True" CausesValidation="False"
                                            ConfirmText="Please remember to save this Purchase Invoice before creating a debit memo.\n\nAre you sure you want to continue?"
                                            ImageUrl="~/images/tick.gif" meta:resourcekey="buttonCreateDebitMemoResource1"
                                            OnClick="buttonCreateDebitMemo_Click" Text="Create Debit Memo" />
                                    </td>
                                </tr>
                            </table>
                        </ui:UIPanel>
                        <ui:UIPanel ID="panelInvoice" runat="server" BorderStyle="NotSet" meta:resourcekey="panelInvoiceResource1">
                            <ui:UIFieldDropDownList ID="dropPOMatchedInvoice" runat="server" Caption="Original Invoice"
                                meta:resourcekey="dropPOMatchedInvoiceResource1" OnSelectedIndexChanged="dropPOMatchedInvoice_SelectedIndexChanged"
                                ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldPopupSelection ID="popupDirectInvoice" runat="server" Caption="Original Invoice"
                                meta:resourcekey="popupDirectInvoiceResource1" OnSelectedValueChanged="popupDirectInvoice_SelectedValueChanged"
                                PopupUrl="searchstdinvoice.aspx" ValidateRequiredField="True">
                            </ui:UIFieldPopupSelection>
                        </ui:UIPanel>
                        <ui:UIFieldLabel ID="labelPurchaseOrderNumber" runat="server" Caption="Purchase Order"
                            ContextMenuAlwaysEnabled="True" DataFormatString="" meta:resourcekey="labelPurchaseOrderNumberResource1"
                            PropertyName="PurchaseOrder.ObjectNumber">
                            <ContextMenuButtons>
                                <ui:UIButton ID="buttonEditPurchaseOrder" runat="server" AlwaysEnabled="True" ConfirmText="Please remember to save this Purchase Invoice before editing the Purchase Order.\n\nAre you sure you want to continue?"
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="buttonEditPurchaseOrderResource1"
                                    OnClick="buttonEditPurchaseOrder_Click" Text="Edit Purchase Order" />
                                <ui:UIButton ID="buttonViewPurchaseOrder" runat="server" AlwaysEnabled="True" ConfirmText="Please remember to save this Purchase Invoice before viewing the Purchase Order.\n\nAre you sure you want to continue?"
                                    ImageUrl="~/images/view.gif" meta:resourcekey="buttonViewPurchaseOrderResource1"
                                    OnClick="buttonViewPurchaseOrder_Click" Text="View Purchase Order" />
                            </ContextMenuButtons>
                        </ui:UIFieldLabel>
                        <ui:UIPanel ID="panelLocationEquipment" runat="server" BorderStyle="NotSet" meta:resourcekey="panelLocationEquipmentResource1">
                            <ui:UIFieldDropDownList ID="ddlLocation" runat="server" Caption="Location" meta:resourcekey="ddlLocationResource1"
                                OnSelectedIndexChanged="ddlLocation_SelectedIndexChanged" PropertyName="LocationID"
                                ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UIFieldTextBox ID="textReferenceNumber" runat="server" Caption="Vendor Invoice Number"
                            InternalControlWidth="95%" meta:resourcekey="textReferenceNumberResource1" PropertyName="ReferenceNumber"
                            Span="Half" ValidateRequiredField="True">
                        </ui:UIFieldTextBox>
                        <br />
                        <ui:UIFieldDateTime ID="dateDateOfInvoice" runat="server" Caption="Date of Invoice"
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="dateDateOfInvoiceResource1"
                            OnDateTimeChanged="dateDateOfInvoice_DateTimeChanged" PropertyName="DateOfInvoice"
                            ShowDateControls="True" Span="Half" ValidateRequiredField="True">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldRadioList ID="BudgetGroupID" runat="server" Caption="Budget Group" meta:resourcekey="BudgetGroupIDResource1"
                            OnSelectedIndexChanged="BudgetGroupID_SelectedIndexChanged" PropertyName="BudgetGroupID"
                            RepeatColumns="0" TextAlign="Right" ValidateRequiredField="True">
                        </ui:UIFieldRadioList>
                        <ui:UIFieldRadioList ID="dropPurchaseTypeClassification" runat="server" Caption="Transaction Type Group"
                            meta:resourcekey="dropPurchaseTypeClassificationResource1" OnSelectedIndexChanged="dropPurchaseTypeClassification_SelectedIndexChanged"
                            PropertyName="TransactionTypeGroupID" RepeatColumns="0" TextAlign="Right" ValidateRequiredField="True">
                        </ui:UIFieldRadioList>
                        <ui:UIFieldDropDownList ID="dropPurchaseType" runat="server" Caption="Transaction Type"
                            meta:resourcekey="dropPurchaseTypeResource1" OnSelectedIndexChanged="dropPurchaseType_SelectedIndexChanged"
                            PropertyName="PurchaseTypeID" ValidateRequiredField="True">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropPaymentType" Caption="Expense Type" PropertyName="PaymentTypeID" ValidateRequiredField="false" OnSelectedIndexChanged="dropPaymentType_SelectedIndexChanged"></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="textDescription" runat="server" Caption="Description" InternalControlWidth="95%"
                            MaxLength="255" meta:resourcekey="textDescriptionResource1" PropertyName="Description"
                            ValidateRequiredField="True">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <%--<ui:UIPanel runat="server" ID="panelUploadFile" BorderStyle="NotSet" 
                        meta:resourcekey="panelUploadFileResource1">
                        <web:fileuploaddialogbox runat="server" ID="fileUploadInvoice" FileUploadMultiple="false" Title="Upload Scanned Original Invoice Image" OnUploaded="fileUploadInvoice_Uploaded" />
                        <ui:UISeparator runat="server" ID="Separator1" Caption="Original Invoice Image" meta:resourcekey="Separator1Resource1" />
                        <ui:UIHint runat="server" ID="hintInvoiceUpload" Text="Please make sure orignal invoice scanned in JPG(s), PNG(s), GIF(s) format."></ui:UIHint>
                        <ui:UIFieldLabel runat="server" ID="lblFileName" Caption="Orignal Invoice Image" Text="" Span="Half" ValidateRequiredField="false" FieldLayout="Table" Width="157px" ></ui:UIFieldLabel>
                        <ui:UIButton runat="server" ID="buttonFileInvoice" Text="" Font-Bold="true" CausesValidation="false" OnClick="buttonFileInvoice_Click" /><br /><br />
                        <asp:Label runat="server" ID="lblDownloadButton" Text="" Width="157px"></asp:Label>
                        <ui:UIButton runat="server" ID="buttonUploadInvoice" Text="Upload original Invoice" ImageUrl="~/images/upload.png" Font-Bold="true" CausesValidation="false" OnClick="buttonUploadInvoice_Click" />
                    </ui:UIPanel>--%>
                </ui:UITabView>
                <ui:UITabView ID="tabVendor" runat="server" BorderStyle="NotSet" Caption="Vendor and Amount"
                    meta:resourcekey="tabVendorResource1">
                    <ui:UIPanel ID="panelTabVendor" runat="server" BorderStyle="NotSet" meta:resourcekey="panelTabVendorResource1">
                        <ui:UISeparator ID="sep1" runat="server" Caption="Vendor" meta:resourcekey="sep1Resource1" />
                        <ui:UIPanel ID="panelVendor" runat="server" BorderStyle="NotSet" meta:resourcekey="panelVendorResource1">
                            <ui:UIFieldSearchableDropDownList ID="dropVendor" runat="server" Caption="Vendor"
                                meta:resourcekey="dropVendorResource1" OnSelectedIndexChanged="dropVendor_SelectedIndexChanged"
                                PropertyName="VendorID" SearchInterval="300" ValidateRequiredField="True">
                            </ui:UIFieldSearchableDropDownList>
                            <ui:UIFieldTextBox ID="ContactAddressCountry" runat="server" Caption="Country" InternalControlWidth="95%"
                                meta:resourcekey="ContactAddressCountryResource1" PropertyName="ContactAddressCountry"
                                Span="Half">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactAddressState" runat="server" Caption="State" InternalControlWidth="95%"
                                meta:resourcekey="ContactAddressStateResource1" PropertyName="ContactAddressState"
                                Span="Half">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactAddressCity" runat="server" Caption="City" InternalControlWidth="95%"
                                meta:resourcekey="ContactAddressCityResource1" PropertyName="ContactAddressCity"
                                Span="Half">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactAddress" runat="server" Caption="Address" InternalControlWidth="95%"
                                MaxLength="255" meta:resourcekey="ContactAddressResource1" PropertyName="ContactAddress">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactCellPhone" runat="server" Caption="Cellphone" InternalControlWidth="95%"
                                meta:resourcekey="ContactCellPhoneResource1" PropertyName="ContactCellPhone"
                                Span="Half">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactEmail" runat="server" Caption="Email" InternalControlWidth="95%"
                                meta:resourcekey="ContactEmailResource1" PropertyName="ContactEmail" Span="Half">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactFax" runat="server" Caption="Fax" InternalControlWidth="95%"
                                meta:resourcekey="ContactFaxResource1" PropertyName="ContactFax" Span="Half">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactPhone" runat="server" Caption="Phone" InternalControlWidth="95%"
                                meta:resourcekey="ContactPhoneResource1" PropertyName="ContactPhone" Span="Half">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="ContactPerson" runat="server" Caption="Contact Person" InternalControlWidth="95%"
                                meta:resourcekey="ContactPersonResource1" PropertyName="ContactPerson">
                            </ui:UIFieldTextBox>
                        </ui:UIPanel>
                        <ui:UIPanel ID="panelTaxAmount" runat="server" BorderStyle="NotSet" meta:resourcekey="panelTaxAmountResource1">
                            <ui:UISeparator ID="UISeparator1" runat="server" Caption="Currency" meta:resourcekey="UISeparator1Resource1" />
                            <ui:UIFieldDropDownList ID="dropCurrency" runat="server" Caption="Currency" meta:resourcekey="dropCurrencyResource1"
                                OnSelectedIndexChanged="dropCurrency_SelectedIndexChanged" PropertyName="CurrencyID"
                                Span="Half" ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            <table border="0" cellpadding="0" cellspacing="0" style="clear: both;">
                                <tr class="field-required" style="height: 25px">
                                    <td style="width: 150px">
                                        <asp:Label ID="labelExchangeRate" runat="server" meta:resourceKey="labelExchangeRateResource1"
                                            Text="Exchange Rate*:"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="labelER1" runat="server" meta:resourceKey="labelER1Resource1" Text="1"></asp:Label>
                                        <ui:UIFieldLabel ID="labelERThisCurrency" runat="server" DataFormatString="" FieldLayout="Flow"
                                            InternalControlWidth="20px" meta:resourcekey="labelERThisCurrencyResource1" PropertyName="Currency.ObjectName"
                                            ShowCaption="False">
                                        </ui:UIFieldLabel>
                                        <asp:Label ID="labelEREquals" runat="server" meta:resourceKey="labelEREqualsResource1"
                                            Text="is equal to"></asp:Label>
                                        <ui:UIFieldTextBox ID="textForeignToBaseExchangeRate" runat="server" Caption="Exchange Rate"
                                            FieldLayout="Flow" InternalControlWidth="60px" meta:resourcekey="textForeignToBaseExchangeRateResource1"
                                            OnTextChanged="textForeignToBaseExchangeRate_TextChanged" PropertyName="ForeignToBaseExchangeRate"
                                            ShowCaption="False" Span="Half" ValidateDataTypeCheck="True" ValidateRequiredField="True"
                                            ValidationDataType="Currency">
                                        </ui:UIFieldTextBox>
                                        <asp:Label ID="labelERBaseCurrency" runat="server" meta:resourceKey="labelERBaseCurrencyResource1"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <ui:UISeparator ID="UISeparator4" runat="server" Caption="Invoice Amount" meta:resourcekey="UISeparator4Resource1" />
                            <ui:UIPanel ID="panelCreditDebitMemoDetails" runat="server" BorderStyle="NotSet"
                                meta:resourcekey="panelCreditDebitMemoDetailsResource1">
                                <ui:UIHint ID="hintCreditDebitMemo" runat="server" meta:resourcekey="hintCreditDebitMemoResource1"
                                    Text="NOTE: This is a credit/debit memo">
                                </ui:UIHint>
                            </ui:UIPanel>
                            <ui:UIPanel ID="panelSelectedCurrency" runat="server" BorderStyle="NotSet" meta:resourcekey="panelSelectedCurrencyResource1">
                                <ui:UIFieldDropDownList ID="dropTaxCode" runat="server" Caption="Tax Code" CaptionWidth="150px"
                                    meta:resourcekey="dropTaxCodeResource1" OnSelectedIndexChanged="dropTaxCode_SelectedIndexChanged"
                                    PropertyName="TaxCodeID" ValidateRequiredField="True">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldTextBox ID="textTotalAmountInSelectedCurrency" runat="server" Caption="Total Net Amount"
                                    CaptionWidth="150px" DataFormatString="{0:#,##0.00}" InternalControlWidth="95%"
                                    meta:resourcekey="textTotalAmountInSelectedCurrencyResource1" OnTextChanged="textTotalAmountInSelectedCurrency_TextChanged"
                                    PropertyName="TotalAmountInSelectedCurrency" Span="Half" ValidateRangeField="True"
                                    ValidateRequiredField="True" ValidationRangeMin="0" ValidationRangeType="Currency">
                                </ui:UIFieldTextBox>
                                <ui:UIFieldTextBox ID="textTotalTaxInSelectedCurrency" runat="server" Caption="Total Tax Amount"
                                    CaptionWidth="150px" DataFormatString="{0:#,##0.00}" InternalControlWidth="95%"
                                    meta:resourcekey="textTotalTaxInSelectedCurrencyResource1" OnTextChanged="textTotalTaxInSelectedCurrency_TextChanged"
                                    PropertyName="TotalTaxInSelectedCurrency" Span="Half" ValidateRangeField="True"
                                    ValidateRequiredField="True" ValidationRangeMin="0" ValidationRangeType="Currency">
                                </ui:UIFieldTextBox>
                            </ui:UIPanel>
                            <ui:UIPanel ID="panelBaseCurrency" runat="server" BorderStyle="NotSet" meta:resourcekey="panelBaseCurrencyResource1">
                                <ui:UIFieldLabel ID="labelTotalAmount" runat="server" Caption="Total Net Amount"
                                    CaptionWidth="150px" DataFormatString="{0:n}" meta:resourcekey="labelTotalAmountResource1"
                                    PropertyName="TotalAmount" Span="Half">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel ID="labelTotalTax" runat="server" Caption="Total Tax Amount" CaptionWidth="150px"
                                    DataFormatString="{0:n}" meta:resourcekey="labelTotalTaxResource1" PropertyName="TotalTax"
                                    Span="Half">
                                </ui:UIFieldLabel>
                            </ui:UIPanel>
                            <ui:UIPanel ID="panelOriginalInvoice" runat="server" BorderStyle="NotSet" meta:resourcekey="panelOriginalInvoiceResource1">
                                <ui:UISeparator ID="UISeparator3" runat="server" Caption="Original Invoice Amount"
                                    meta:resourcekey="UISeparator3Resource1" />
                                <ui:UIFieldLabel ID="labelOriginalTotalAmount" runat="server" Caption="Total Net Amount"
                                    CaptionWidth="150px" DataFormatString="{0:n}" meta:resourcekey="labelOriginalTotalAmountResource1"
                                    PropertyName="CreditDebitMemoOnInvoice.TotalAmount" Span="Half">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel ID="labelOriginalTotalTax" runat="server" Caption="Total Net Amount"
                                    CaptionWidth="150px" DataFormatString="{0:n}" meta:resourcekey="labelOriginalTotalTaxResource1"
                                    PropertyName="CreditDebitMemoOnInvoice.TotalTax" Span="Half">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel ID="labelOriginalTotalCreditDebitMemoAmount" runat="server" Caption="Credit/Debit Memos"
                                    CaptionWidth="150px" DataFormatString="{0:n}" ForeColor="Red" meta:resourcekey="labelOriginalTotalCreditDebitMemoAmountResource1"
                                    PropertyName="CreditDebitMemoOnInvoice.TotalCreditDebitMemoAmount">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel ID="labelOriginalTotalAfterCreditDebitMemoAmount" runat="server"
                                    Caption="Total Balance" CaptionWidth="150px" DataFormatString="{0:n}" meta:resourcekey="labelOriginalTotalAfterCreditDebitMemoAmountResource1"
                                    PropertyName="CreditDebitMemoOnInvoice.TotalAmountAfterCreditDebitMemos">
                                </ui:UIFieldLabel>
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelCreditNote" Visible="true">
                        <ui:UISeparator ID="sepCreditMemo" runat="server" Caption="Credit Memo" Visible="true"/>
                        <ui:UIFieldCheckBox runat="server" ID="cb_IsContainsCreditNote" PropertyName="IsContainsCreditNote" Text="     Yes,the invoice is submitted with a credit note" CaptionWidth="1" OnCheckedChanged="cb_IsContainsCreditNote_CheckedChanged" ></ui:UIFieldCheckBox>
                        <ui:UIPanel runat="server" ID="panelCreditNoteDetails">
                            <ui:UIFieldDateTime runat="server" ID="DateOfCreditNote" Caption="Date of Credit Note" PropertyName="DateOfCreditNote" ValidateRequiredField="true"></ui:UIFieldDateTime>
                            <ui:UIFieldTextBox runat="server" ID="txtCreditNoteReferenceNumber" Caption="Vendor Credit Note Number" ValidateRequiredField="true"
                                    PropertyName="CreditNoteReferenceNumber" Span="Half"></ui:UIFieldTextBox>
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="txtCreditNoteAmountInSelectedCurrency" Caption="Net Amount" Span="Half" DataFormatString="{0:n}"
                                    PropertyName="CreditNoteAmountInSelectedCurrency" ValidateDataTypeCheck="true" ValidationDataType="Currency" ValidateRequiredField="true" OnTextChanged="txtCreditNoteAmountInSelectedCurrency_TextChanged"></ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="txtCreditNoteTaxAmountInSelectedCurrency" Caption="Tax Amount" Span="Half" ValidateRequiredField="true" DataFormatString="{0:n}"
                                    PropertyName="CreditNoteTaxInSelectedCurrency" ValidateDataTypeCheck="true" ValidationDataType="Currency" OnTextChanged="txtCreditNoteTaxAmountInSelectedCurrency_TextChanged"></ui:UIFieldTextBox>
                            <ui:UIFieldLabel runat="server" ID="lblCreditNoteAmount" Caption="Net Amount"
                                    Span="Half" PropertyName="CreditNoteAmount"  DataFormatString="{0:n}"> </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lblCreditNoteTax" Caption="Tax Amount"
                                    Span="Half" PropertyName="CreditNoteTax" DataFormatString="{0:n}"> </ui:UIFieldLabel>
                            <ui:UIFieldTextBox runat="server" ID="txtCreditNoteDescription" Caption="Credit Note Description" Span="Full" 
                                    PropertyName="CreditNoteDescription" MaxLength="255" ValidateRequiredField="true"></ui:UIFieldTextBox>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabBudget" runat="server" BorderStyle="NotSet" Caption="Budget"
                    meta:resourcekey="tabBudgetResource1">
                    <ui:UIHint runat="server" ID="hintBudgetNotRequired" Text="Budget is not required for this Invoice."></ui:UIHint>
                    <ui:UIPanel runat="server" ID="panelBudget2">
                        <ui:UIPanel ID="panelAddBudgets" runat="server" BorderStyle="NotSet" meta:resourcekey="panelAddBudgetsResource1">
                            <ui:UIButton ID="buttonApplyBudgets" runat="server" CausesValidation="False" ImageUrl="~/images/add.gif"
                                meta:resourcekey="buttonApplyBudgetsResource1" OnClick="buttonApplyBudgets_Click"
                                Text="Automatically apply budgets from Purchase Order" />
                            <ui:UIButton ID="buttonAddBudgets" runat="server" CausesValidation="False" ImageUrl="~/images/add.gif"
                                meta:resourcekey="buttonAddBudgetsResource1" OnClick="buttonAddBudgets_Click"
                                Text="Selectively add budgets from Purchase Order" />
                            <web:searchdialogbox runat="server" ID="searchPurchaseOrderBudgets" 
                                SearchTextBoxPropertyNames="Account.Path,Budget.ObjectName"
                                AllowMultipleSelection="true" BaseTable="tBudgetTransactionLog" AutoSearchOnLoad="true"
                                OnSearched="searchPurchaseOrderBudgets_Searched" 
                                OnSelected="searchPurchaseOrderBudgets_Selected">
                                <Columns>
                                    <ui:UIGridViewBoundColumn PropertyName="PurchaseBudget.ItemNumber" HeaderStyle-Width="50px" HeaderText="Number" />
                                    <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" HeaderStyle-Width="110px" HeaderText="Budget" />
                                    <ui:UIGridViewBoundColumn PropertyName="Account.Path" HeaderStyle-Width="350px" HeaderText="Account" />
                                    <ui:UIGridViewBoundColumn PropertyName="DateOfExpenditure" HeaderStyle-Width="130px" HeaderText="Expenditure Date" DataFormatString="{0:dd-MMM-yy}" />
                                    <ui:UIGridViewBoundColumn PropertyName="TransactionAmount" HeaderStyle-Width="70px" HeaderText="Amount" />
                                </Columns>
                                <AdvancedPanel>
                                    <ui:UIFieldTextBox runat="server" ID="textItemNumber" SearchType="Range"
                                        CaptionWidth="100px" Caption="Item Number"
                                        PropertyName="PurchaseBudget.ItemNumber" Span="Half">
                                    </ui:UIFieldTextBox>
                                    <br />
                                    <ui:uifielddatetime runat="server" id="dateDateOfExpenditure"
                                        CaptionWidth="100px" SearchType="Range" Caption="Expenditure Date"
                                        PropertyName="DateOfExpenditure" Span="Half" ImageUrl="../../images/cross.gif">
                                    </ui:uifielddatetime>
                                </AdvancedPanel>
                            </web:searchdialogbox>
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIPanel ID="panelAddInvoiceBudgets" runat="server" BorderStyle="NotSet" meta:resourcekey="panelAddInvoiceBudgetsResource1">
                            <ui:UIButton ID="buttonApplyInvoiceBudgets" runat="server" CausesValidation="False"
                                ImageUrl="~/images/add.gif" meta:resourcekey="buttonApplyInvoiceBudgetsResource1"
                                OnClick="buttonApplyInvoiceBudgets_Click" Text="Automatically apply budgets from matched invoice" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIGridView ID="gridBudget" runat="server" BindObjectsToRows="True" Caption="Budgets"
                            DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridBudgetResource1"
                            PageSize="50" PropertyName="PurchaseBudgets" RowErrorColor="" ShowFooter="True"
                            Style="clear: both;" OnAction="gridBudget_Action">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <%--                            <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
--%>
                                <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddBudget"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                    meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="No."
                                    PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Budget.ObjectName" HeaderText="Budget" meta:resourcekey="UIGridViewBoundColumnResource1"
                                    PropertyName="Budget.ObjectName" ResourceAssemblyName="" SortExpression="Budget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" meta:resourcekey="UIGridViewBoundColumnResource2"
                                    PropertyName="Account.Path" ResourceAssemblyName="" SortExpression="Account.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Account.AccountCode" HeaderText="Account Code"
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Account.AccountCode"
                                    ResourceAssemblyName="" SortExpression="Account.AccountCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="StartDate" DataFormatString="{0:dd-MMM-yyyy}"
                                    HeaderText="Accrual Date" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="StartDate"
                                    ResourceAssemblyName="" SortExpression="StartDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Amount" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox ID="textAmount" runat="server" Caption="Amount" DataFormatString="{0:n}"
                                            FieldLayout="Flow" InternalControlWidth="80px" meta:resourcekey="textAmountResource2"
                                            PropertyName="Amount" ShowCaption="False" ValidateRangeField="True" ValidateRequiredField="True"
                                            ValidationRangeMin="0" ValidationRangeMinInclusive="False">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="panelBudget" runat="server" BorderStyle="NotSet" meta:resourcekey="panelBudgetResource1">
                            <web:subpanel ID="subpanelBudget" runat="server" GridViewID="gridBudget" OnPopulateForm="subpanelBudget_PopulateForm"
                                OnRemoved="subpanelBudget_Removed" OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate" />
                            <ui:UIFieldDropDownList ID="dropBudget" runat="server" Caption="Budget" meta:resourcekey="dropBudgetResource1"
                                OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" PropertyName="BudgetID"
                                ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDateTime ID="dateStartDate" runat="server" Caption="Accrual Date" meta:resourcekey="dateStartDateResource1"
                                PropertyName="StartDate" ShowDateControls="True" Span="Half" ValidateRequiredField="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTreeList ID="treeAccount" runat="server" Caption="Account" meta:resourcekey="treeAccountResource1"
                                OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" PropertyName="AccountID"
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" ValidateRequiredField="True">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox ID="textAmount" runat="server" Caption="Amount" InternalControlWidth="95%"
                                meta:resourcekey="textAmountResource1" PropertyName="Amount" Span="Half" ValidateRequiredField="True"
                                ValidationRangeMin="1" ValidationRangeType="Currency">
                            </ui:UIFieldTextBox>
                        </ui:UIObjectPanel>
                        <br />
                        <br />
                        <ui:UIGridView ID="gridBudgetSummary" runat="server" Caption="Budget Summary" CheckBoxColumnVisible="False"
                            DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridBudgetSummaryResource1"
                            OnAction="gridBudgetSummary_Action" PageSize="50" PropertyName="PurchaseBudgetSummaries"
                            RowErrorColor="" ShowFooter="True" Style="clear: both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <ui:UIGridViewBoundColumn DataField="Budget.ObjectName" HeaderText="Budget" meta:resourcekey="UIGridViewBoundColumnResource6"
                                    PropertyName="Budget.ObjectName" ResourceAssemblyName="" SortExpression="Budget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="BudgetPeriod.ObjectName" HeaderText="Budget Period"
                                    meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="BudgetPeriod.ObjectName"
                                    ResourceAssemblyName="" SortExpression="BudgetPeriod.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="ViewBudget"
                                    ImageUrl="~/images/printer.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="Account.ObjectName" HeaderText="Account" meta:resourcekey="UIGridViewBoundColumnResource8"
                                    PropertyName="Account.ObjectName" ResourceAssemblyName="" SortExpression="Account.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Account.AccountCode" HeaderText="Account Code"
                                    meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="Account.AccountCode"
                                    ResourceAssemblyName="" SortExpression="Account.AccountCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="TotalAvailableAdjusted" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Total After Adjustments" meta:resourcekey="UIGridViewBoundColumnResource10"
                                    PropertyName="TotalAvailableAdjusted" ResourceAssemblyName="" SortExpression="TotalAvailableAdjusted">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="TotalAvailableBeforeSubmission" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Total Before Submission" meta:resourcekey="UIGridViewBoundColumnResource11"
                                    PropertyName="TotalAvailableBeforeSubmission" ResourceAssemblyName="" SortExpression="TotalAvailableBeforeSubmission">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="TotalAvailableAtSubmission" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Total At Submission" meta:resourcekey="UIGridViewBoundColumnResource12"
                                    PropertyName="TotalAvailableAtSubmission" ResourceAssemblyName="" SortExpression="TotalAvailableAtSubmission">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="TotalAvailableAfterApproval" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Total After Approval" meta:resourcekey="UIGridViewBoundColumnResource13"
                                    PropertyName="TotalAvailableAfterApproval" ResourceAssemblyName="" SortExpression="TotalAvailableAfterApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <asp:LinkButton runat="server" ID="buttonAddBudgetHidden" />
                        <asp:ModalPopupExtender runat='server' ID="popupAddBudget" PopupControlID="objectPanelAddBudget"
                            BackgroundCssClass="modalBackground" TargetControlID="buttonAddBudgetHidden">
                        </asp:ModalPopupExtender>
                        <ui:UIObjectPanel runat="server" ID="objectPanelAddBudget" Width="400px" BackColor="White">
                            <div style="padding: 8px 8px 8px 8px">
                                <ui:UISeparator ID="Uiseparator2" runat="server" Caption="Add Budget" />
                                <ui:UIFieldDropDownList runat="server" ID="dropAddBudget" Caption="Budget" ValidateRequiredField="true"
                                    OnSelectedIndexChanged="dropAddBudget_SelectedIndexChanged">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDateTime runat="server" ID="dateAddBudgetDate" Caption="Date" ValidateRequiredField="true"
                                    SelectMonthYear="true">
                                </ui:UIFieldDateTime>
                                <ui:UIFieldTreeList runat='server' ID="treeAddBudgetAccounts" Caption="Account" ValidateRequiredField="true"
                                    OnAcquireTreePopulater="treeAddBudgetAccounts_AcquireTreePopulater">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldTextBox runat='server' ID="textAddBudgetAmount" Caption="Amount" ValidateRequiredField="true"
                                    ValidateDataTypeCheck="true" ValidationDataType="Currency" ValidateRangeField='true'
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="false" ValidationRangeType="Currency">
                                </ui:UIFieldTextBox>
                                <br />
                                <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray;
                                    width: 100%">
                                    <tr>
                                        <td style='width: 120px'>
                                        </td>
                                        <td>
                                            <ui:UIButton runat='server' ID="buttonAddBudgetConfirm" Text="Add" ImageUrl="~/images/add.gif"
                                                CausesValidation="true" OnClick="buttonAddBudgetConfirm_Click" />
                                            <ui:UIButton runat='server' ID="buttonAddBudgetCancel" Text="Cancel" ImageUrl="~/images/delete.gif"
                                                CausesValidation='false' OnClick="buttonAddBudgetCancel_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabWorkHistory" runat="server" BorderStyle="NotSet" Caption="Status History"
                    meta:resourcekey="tabWorkHistoryResource1">
                    <web:ActivityHistory ID="ActivityHistory" runat="server" />
                </ui:UITabView>
                <ui:UITabView ID="tabMemo" runat="server" BorderStyle="NotSet" Caption="Memo" meta:resourcekey="tabMemoResource1">
                    <web:memo ID="memo1" runat="server" />
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" BorderStyle="NotSet" Caption="Attachments"
                    meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
