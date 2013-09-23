<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="CrystalDecisions.CrystalReports.Engine" %>
<%@ Import Namespace="CrystalDecisions.Shared" %>
<%@ Import Namespace="System.IO" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server" enableviewstate="False">
    private Hashtable EditVisible = new Hashtable();
    private Hashtable ViewVisible = new Hashtable();

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

        // Default purchase order date today
        // Default purchase order type = PO.
        //
        if (purchaseOrder.IsNew)
        {
            purchaseOrder.DateOfOrder = DateTime.Today;
            purchaseOrder.POType = PurchaseOrderType.PO;
        }

        if (purchaseOrder.CampaignID != null)
        {
            OLocation loc = LogicLayer.TablesLogic.tLocation.Load(purchaseOrder.LocationID);
            dropCampaign.Bind(loc.CampaignsForLocations, "ObjectName", "ObjectID");
        }

        if (!IsPostBack)
        {
            BindContractsAndVendors(purchaseOrder);
            BindPurchaseType(purchaseOrder);
            BindLocation(purchaseOrder);
            BindCompaniesAndSignators(purchaseOrder);
            BindPurchaseOrderDates(purchaseOrder);

            SetGridViewCurrencyDataFormatString();
            //20120530 PTB
            //Attempt to fix the budget and line item number bug via UI
            if (purchaseOrder.PurchaseOrderItems.Count > 0 && purchaseOrder.PurchaseOrderItems.Find(lf => lf.RequestForQuotationItemID != null) != null)
            {
                foreach (OPurchaseOrderItem poi in purchaseOrder.PurchaseOrderItems)
                {
                    poi.ItemNumber = poi.RequestForQuotationItem.ItemNumber;
                }
                //int i = 1;
                //foreach (OPurchaseBudget purchaseBudget in purchaseOrder.PurchaseBudgets)
                //{
                //    purchaseBudget.ItemNumber = i++;
                //}
            }
            //END
        }

        if (purchaseOrder.CurrentActivity.ObjectName.Is("PendingReceipt", "PendingInvoiceApproval", "Close"))
        {
            gridInvoices.DataSource = purchaseOrder.NonCancelledPurchaseInvoices;
            gridInvoices.DataBind();
            gridInvoices.Columns[0].Visible = AppSession.User.AllowEditAll("OPurchaseInvoice") || Security.Decrypt(Request["ID"]).StartsWith("EDIT");
            gridInvoices.Columns[1].Visible = AppSession.User.AllowViewAll("OPurchaseInvoice") || Security.Decrypt(Request["ID"]).StartsWith("VIEW");
        }

        /*
         * No longer needed for CapitaCommercial Ltd.
         * Kien Trung, commented out.
         *
        panelCase.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] != "MARCOM");
        List<OPurchaseInvoice> purchaseinvoices = TablesLogic.tPurchaseInvoice.LoadList(
                                                    TablesLogic.tPurchaseInvoice.PurchaseOrderID == purchaseOrder.ObjectID &
                                                    TablesLogic.tPurchaseInvoice.CurrentActivity.CurrentStateName != "Cancelled" &
                                                    TablesLogic.tPurchaseInvoice.CurrentActivity.CurrentStateName != "CancelledAndRevised" &
                                                    TablesLogic.tPurchaseInvoice.IsDeleted == 0);
        */

        /* This is to handle exception thrown by ComputeTempBudgetSummaries()
         * 2011.08.11, Kien Trung, added to handle message in friendlier way.
         *
         */
        try
        {
            if (purchaseOrder.CurrentActivity == null ||
                !purchaseOrder.CurrentActivity.ObjectName.Is("PendingApproval", "PendingReceipt",
                "PendingInvoiceApproval", "Close", "Cancelled",
                "CancelledAndRevised", "PendingCancellation", "PendingCancelAndRevised"))
            {
                purchaseOrder.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }
            else
                gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";
        }
        catch (Exception ex)
        {
            panel.PopupMessage = gridBudget.ErrorMessage = ex.Message;
            panel.ObjectPanel.BindObjectToControls(purchaseOrder);
        }

        panel.ObjectPanel.BindObjectToControls(purchaseOrder);

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="rfq"></param>
    protected void BindPurchaseOrderDates(OPurchaseOrder po)
    {
        OApplicationSetting applicationSetting = OApplicationSetting.Current;

        panel.Caption = po.TypeText;

        if (DateRequired.DateTime == null &&
            DateEnd.DateTime == null &&
            applicationSetting.IsWJDateDefaulted == 1 &&
            !checkIsTermContract.Checked &&
            po.IsNew)
        {
            DateTime today = DateTime.Today;
            switch (applicationSetting.DefaultRequiredUnit)
            {
                case (int)EnumRequestForQuotationDefaultDateUnit.Day:
                    po.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Week:
                    po.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value * 7);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Month:
                    po.DateRequired = today.AddMonths(applicationSetting.DefaultRequiredCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Year:
                    po.DateRequired = today.AddYears(applicationSetting.DefaultRequiredCount.Value);
                    break;
            }

            switch (applicationSetting.DefaultEndUnit)
            {
                case (int)EnumRequestForQuotationDefaultDateUnit.Day:
                    po.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Week:
                    po.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value * 7);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Month:
                    po.DateEnd = today.AddMonths(applicationSetting.DefaultEndCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Year:
                    po.DateEnd = today.AddYears(applicationSetting.DefaultEndCount.Value);
                    break;
            }
        }
    }

    /// <summary>
    /// Bind Contracts and Vendors
    /// </summary>
    /// <param name="purchaseOrder"></param>
    protected void BindContractsAndVendors(OPurchaseOrder purchaseOrder)
    {
        DateOfOrder.Enabled = !purchaseOrder.CurrentActivity.ObjectName.Is("PendingApproval", "PendingReceipt", "PendingInvoiceApproval", "Close");
        dropCase.Bind(OCase.GetAccessibleOpenCases(AppSession.User, Security.Decrypt(Request["TYPE"]), purchaseOrder.CaseID), "Case", "ObjectID");
        //VendorID.Bind(OVendor.GetVendors(DateTime.Today, purchaseOrder.VendorID));
        VendorID.Bind(OVendor.GetVendors(DateTime.Today, purchaseOrder.VendorID, AppSession.User, Security.Decrypt(Request["TYPE"])));
        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), purchaseOrder.StoreID));
        ContractID.Bind(OContract.GetContractsByPurchaseOrder(purchaseOrder));
        dropCurrency.Bind(OCurrency.GetAllCurrencies(purchaseOrder.CurrencyID), "CurrencyNameAndDescription", "ObjectID", true);
        labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="purchaseOrder"></param>
    protected void BindCompaniesAndSignators(OPurchaseOrder purchaseOrder)
    {
        //List<OCapitalandCompany> Companies = OCapitalandCompany.GetCapitalandCompanies(null);
        ddlTrust.Bind(OCapitalandCompany.GetCapitalandCompanies(purchaseOrder.TrustID), "ObjectNameAndAddress", "ObjectID");
        ddlOnBehalfOf.Bind(OCapitalandCompany.GetCapitalandCompanies(purchaseOrder.LOAOnBehalfOfID), "ObjectNameAndAddress", "ObjectID");
        ddlManagementCompany.Bind(OCapitalandCompany.GetCapitalandCompanies(purchaseOrder.ManagementCompanyID), "ObjectNameAndAddress", "ObjectID");
        ddlDeliveryTo.Bind(OCapitalandCompany.GetCapitalandCompanies(purchaseOrder.DeliveryToID), "ObjectNameAndAddress", "ObjectID");
        ddlBillTo.Bind(OCapitalandCompany.GetCapitalandCompanies(purchaseOrder.BillToID), "ObjectNameAndAddress", "ObjectID");

        //List<OUser> signators = OUser.GetUsersByRoleAndAboveLocation(purchaseOrder.Location, "PURCHASEADMIN");
        DeliverToContactPersonID.Bind(OUser.GetUsersByRoleAndAboveLocation(purchaseOrder.DeliverToContactPerson, purchaseOrder.Location, "PURCHASEADMIN"));
        BillToContactPersonID.Bind(OUser.GetUsersByRoleAndAboveLocation(purchaseOrder.BillToContactPerson, purchaseOrder.Location, "PURCHASEADMIN"));
        ddlSignatory.Bind(OUser.GetUsersByRoleAndAboveLocation(purchaseOrder.Signatory, purchaseOrder.Location, "APPROVER"));
    }

    /// <summary>
    /// Bind Purchase Types, Budget Group, Transaction Types Group
    ///
    /// </summary>
    /// <param name="purchaseOrder"></param>
    protected void BindPurchaseType(OPurchaseOrder purchaseOrder)
    {
        // 2011.09.22, Kien Trung, commented:
        // Modified to have applicable transaction types settings on Position modules.
        // This is to seperate transation types for each dept (Ops, Marcom, Admin, etc...)
        //
        //dropPurchaseTypeClassification.Bind(OCode.GetCodesByType("PurchaseTypeClassification", null));
        //dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", purchaseOrder.PurchaseTypeID));
        dropPurchaseTypeClassification.Bind(OCode.GetPurchaseGroupTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), purchaseOrder.TransactionTypeGroupID));
        dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, purchaseOrder.TransactionTypeGroupID, Security.Decrypt(Request["TYPE"]), purchaseOrder.PurchaseTypeID));

        BudgetGroupID.Bind(AppSession.User.GetAllAccessibleBudgetGroup("OPurchaseOrder", purchaseOrder.BudgetGroupID));

        if (purchaseOrder.IsNew && BudgetGroupID.Items.Count == 1)
            purchaseOrder.BudgetGroupID = new Guid(BudgetGroupID.Items[0].Value);

        if (purchaseOrder.BudgetGroupID == null && BudgetGroupID.Items.Count == 1)
            BudgetGroupID.SelectedIndex = 0;

        if (purchaseOrder.TransactionTypeGroupID == null && dropPurchaseTypeClassification.Items.Count == 1)
        {
            dropPurchaseTypeClassification.SelectedIndex = 0;
            dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, new Guid(dropPurchaseTypeClassification.SelectedValue), Security.Decrypt(Request["TYPE"]), purchaseOrder.PurchaseTypeID));
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="purchaseOrder"></param>
    protected void BindLocation(OPurchaseOrder purchaseOrder)
    {
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        List<OLocation> listLocs = OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, purchaseOrder.LocationID);
        listLocs.Sort("ParentPath");
        ddlLocation.Bind(listLocs, "ParentPath", "ObjectID");

        if (purchaseOrder.IsNew && ddlLocation.Items.Count == 2)
        {
            purchaseOrder.LocationID = new Guid(ddlLocation.Items[1].Value);
            purchaseOrder.BillToID = purchaseOrder.Location.BuildingOwnerID;
            purchaseOrder.DeliveryToID = purchaseOrder.Location.BuildingTrustID;
            purchaseOrder.ManagementCompanyID = purchaseOrder.Location.BuildingManagementID;
        }

        OApplicationSetting applicationSetting = OApplicationSetting.Current;
        if (applicationSetting.EnableAllBuildingForGWJ == 1)
            listLocations.Bind(TablesLogic.tLocation.LoadList(TablesLogic.tLocation.LocationType.ObjectName == OApplicationSetting.Current.LocationTypeNameForBuildingActual), "ObjectName", "ObjectID");
        else
            listLocations.Bind(AppSession.User.GetAllAccessibleLocation(OApplicationSetting.Current.LocationTypeNameForBuildingActual, "ORequestForQuotation"), "ObjectName", "ObjectID");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void panel_Validate(object sender, PersistentObject obj)
    {
        OPurchaseOrder purchaseOrder = obj as OPurchaseOrder;

        if (!purchaseOrder.ValidateAllUnitPricesEntered())
            PurchaseOrderItems.ErrorMessage = Resources.Errors.PurchaseOrder_UnitPriceNotEntered;

        string state = objectBase.CurrentObjectState;
        string action = objectBase.SelectedAction;

        // Validate
        //
        if (!objectBase.CurrentObjectState.Is("Close", "Cancelled", "CancelledAndRevised") &&
            !OCase.ValidateCaseNotClosedOrCancelled(purchaseOrder.CaseID) && ConfigurationManager.AppSettings["CustomizedInstance"] != "MARCOM")
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

            // Ensure that all purchase budgets adhere to the
            // budget spending policy.
            //
            string budgetsWithNoPeriod = purchaseOrder.ValidateBudgetSpendingPolicy();
            if (budgetsWithNoPeriod != "")
            {
                gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_BudgetNoPeriod, budgetsWithNoPeriod); ;
            }

            // Ensure that number of quotations is sufficient.
            //
            if (purchaseOrder.ValidateRFQToPOPolicy() == 0)
            {
                PurchaseOrderItems.ErrorMessage =
                    Resources.Errors.PurchaseOrder_NoRFQBeforePO;
            }
        }

        // Validate when this po is submit for approval
        // or it's pending receipt and action is not CLOSE
        //
        if (action.Is("SubmitForApproval") || (state.Is("PendingReceipt") && !action.Is("Close")))
        {
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

        }

        if (objectBase.SelectedAction == "SubmitForApproval") /*||
            (objectBase.SelectedAction == "Approve" && objectBase.CurrentObjectState.Is("PendingApproval")))*/
        {
            // Ensure sufficient budgets
            //

            string insufficientAccounts = purchaseOrder.ValidateSufficientBudget();
            if (insufficientAccounts != "")
            {
                gridBudget.ErrorMessage =
                    String.Format(Resources.Errors.PurchaseOrder_InsufficientBudget, insufficientAccounts);
            }
        }

        if (purchaseOrder.PurchaseOrderItems.Count > 0 &&
            purchaseOrder.PurchaseOrderItems[0].RequestForQuotationItem != null &&
                (action.Is("SubmitForApproval_CancelAndRevise", "SubmitForApproval_Cancellation") ||
                 objectBase.CurrentObjectState.Is("PendingCancelAndRevised", "PendingCancellation")))
        {
            List<OPurchaseOrder> POs = TablesLogic.tPurchaseOrder.LoadList
                (TablesLogic.tPurchaseOrder.RequestForQuotationID == purchaseOrder.RequestForQuotationID &
                TablesLogic.tPurchaseOrder.RequestForQuotationID != null &
                !TablesLogic.tPurchaseOrder.CurrentActivity.CurrentStateName.In("Cancelled", "CancelledAndRevised") &
                TablesLogic.tPurchaseOrder.IsDeleted == 0);

            decimal POAmounts = 0;
            foreach (OPurchaseOrder po in POs)
            {
                POAmounts += po.SubTotal;
            }
            ORequestForQuotation rfq = TablesLogic.tRequestForQuotation.Load(purchaseOrder.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotationID);
            decimal rfqAmount = 0;
            foreach (ORequestForQuotationItem item in rfq.RequestForQuotationItems)
            {
                rfqAmount += LogicLayer.LogicLayerPersistentObject.Round(item.Subtotal).Value;
            }

            // Why check po amount < rfqamount ??
            //
            //if (POAmounts < rfqAmount)
            if (POAmounts > rfqAmount)
            {
                string insufficientAccounts = purchaseOrder.ValidateSufficientBudget();
                if (insufficientAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.PurchaseOrder_InsufficientBudget, insufficientAccounts);
                }
            }
        }

        if (action.Is("Close"))
        {
            // Ensures that all invoices have been closed or cancelled before
            // this PO can be closed.
            //
            if (!purchaseOrder.ValidateInvoicesClosedOrCancelled())
                gridInvoices.ErrorMessage = Resources.Errors.PurchaseOrder_InvoicesNotClosedOrCancelled;
            else
            {
                if (purchaseOrder.SubTotal != purchaseOrder.GetTotalInvoiceAmount)
                    if (purchaseOrder.IsPOAllowedClosure != (int)EnumApplicationGeneral.Yes)
                        gridInvoices.ErrorMessage = Resources.Errors.PurchaseOrder_POAmountNotEqualIRAmount;
            }
        }

        if (objectBase.CurrentObjectState == "PendingReceipt" || objectBase.CurrentObjectState == "PendingInvoiceApproval")
        {
            string bin = purchaseOrder.ValidateStoreBinNotLocked();
            if (bin != "")
            {
                this.PurchaseOrderReceipts.ErrorMessage = String.Format(Resources.Errors.PurchaseOrder_StoreBinsLocked, bin);
            }
        }

        /*
         * This is no longer need to check
         *
        decimal? TotalPOAmount = 0;
        foreach (OPurchaseOrderItem item in purchaseOrder.PurchaseOrderItems)
        {
            TotalPOAmount += item.QuantityOrdered * item.UnitPriceInSelectedCurrency;
        }
        decimal? TotalPaymentScheduleAmount = 0;
        foreach (OPurchaseOrderPaymentSchedule ps in purchaseOrder.PurchaseOrderPaymentSchedules)
        {
            TotalPaymentScheduleAmount += ps.AmountToPay;
        }
        if (TotalPOAmount != TotalPaymentScheduleAmount && objectBase.SelectedAction != "Cancel" && objectBase.SelectedAction != "Reject")
        {
            grid_PaymentSchedules.ErrorMessage = Resources.Errors.PurchaseOrder_POAmountNotEqualPSAmount;
        }
        */

        if (state.Is("PendingReceipt") && !action.Is("Close", "SubmitForApproval_Cancellation"))
        {
            // Ensure sufficient budgets
            //
            string insufficientAccounts = OBudgetPeriod.CheckSufficientBalanceAfterUpdatingUnitpriceAndQuantity(purchaseOrder.PurchaseBudgets);
            if (insufficientAccounts != "")
            {
                gridBudget.ErrorMessage =
                    String.Format(Resources.Errors.PurchaseOrder_InsufficientBudget, insufficientAccounts);
            }
        }

        foreach (OPurchaseOrderItem item in purchaseOrder.PurchaseOrderItems)
        {
            if (item.TaxAmount != null && (item.TaxAmount < 0 || item.TaxAmount > item.Subtotal))
            {
                PurchaseOrderItems.ErrorMessage = Resources.Errors.PurchaseOrder_TaxAmount;
                break;
            }
        }
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

            panel_Validate(sender, purchaseOrder);

            if (!panel.ObjectPanel.IsValid)
                return;

            if (objectBase.CurrentObjectState.Is("PendingReceipt"))
                purchaseOrder.UpdateTransactionAmount();

            purchaseOrder.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Occurs when the user clicks on the Group WJ checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkIsGroupPO_CheckedChanged(object sender, EventArgs e)
    {
    }

    protected void BudgetGroupID_SelectedIndexChanged(object sender, EventArgs e)
    {
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

    /* MODIFIED: To have drop down list for location
     * No longer needed.
     *
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

    ///// <summary>
    ///// Updates the requestor dropdown list when the location changes,
    ///// and clears the selected equipment ID.
    ///// </summary>
    ///// <param name="sender"></param>
    ///// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.EquipmentID = null;
        po.UpdateApplicablePurchaseSettings();

        List<OUser> signators = OUser.GetUsersByRoleAndAboveLocation(po.Location, "PURCHASEADMIN");
        ddlSignatory.Bind(signators);
        if (po.LocationID != null)
        {
            OLocation loc = TablesLogic.tLocation.Load(po.LocationID);
            po.TrustID = loc.BuildingTrustID;
            po.LOAOnBehalfOfID = loc.BuildingOwnerID;
            po.ManagementCompanyID = loc.BuildingManagementID;
            po.DeliveryToID = loc.BuildingOwnerID;
            po.BillToID = loc.BuildingTrustID;
        }

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
            //treeLocation.PopulateTree();
            ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual,false));
        }
        panel.ObjectPanel.BindObjectToControls(po);
    }
    */

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
        po.UpdateItemRecoverables();
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
        {
            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                ((BoundField)PurchaseOrderItems.Columns[8]).DataFormatString = po.Currency.CurrencySymbol + "{0:#,##0.0000}";
            else
                ((BoundField)PurchaseOrderItems.Columns[8]).DataFormatString =
                    po.Currency.DataFormatString;
        }
        else
        {
            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                ((BoundField)PurchaseOrderItems.Columns[8]).DataFormatString = "{0:#,##0.0000}";
            else
                ((BoundField)PurchaseOrderItems.Columns[8]).DataFormatString = "{0:n}";
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
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        po.UpdateItemCurrencies();
        po.UpdateItemRecoverables();
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

        OPurchaseOrder p = panel.SessionObject as OPurchaseOrder;

        // 2011.07.05, Kien Trung
        // Hide or show Charge Amount and Recoverable Amount
        // based on recoverable Type (recoverable from tenant or third party)
        //
        //ChargeAmount.Visible = (purchaseOrder.IsCharged == 1);
        //RecoverableAmount.Visible = rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.Recoverable).ToString();
        RecoverableAmount.Visible = checkRecoverable.Checked;

        // Repopulate Item number dropdownlist when populate new form
        //
        for (int i = 1; i <= p.PurchaseOrderItems.Count + 1; i++)
            ItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (purchaseOrderItem.ItemType == null)
        {
            purchaseOrderItem.ItemType = PurchaseItemType.Others;
            purchaseOrderItem.UnitOfMeasureID = OApplicationSetting.Current.GeneralDefaultUnitOfMeasureID;
        }

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
        OPurchaseOrder p = (OPurchaseOrder)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(p);

        OPurchaseOrderItem i = PurchaseOrderItem_SubPanel.SessionObject as OPurchaseOrderItem;

        // if item number is greater than 1,000,000 i.e,
        // it is set from Mass update page,
        // we need to retain this number for correct reordering later
        //
        int itemNumber = i.ItemNumber.Value;
        if (i.OriginalUnitPrice == null && objectBase.CurrentObjectState == "PendingReceipt")
        {
            i.OriginalUnitPrice = i.UnitPrice;
            i.OriginalUnitPriceInSelectedCurrency = i.UnitPriceInSelectedCurrency;
            i.OriginalQuantity = i.QuantityOrdered;
            i.OriginalRequestForQuotationItemID = i.RequestForQuotationItemID;
        }
        PurchaseOrderItem_SubPanel.ObjectPanel.BindControlsToObject(i);
        p.UpdateSingleItemUnitPrice(i);
        p.UpdateSingleItemRecoverable(i);

        // Validates the price.
        //
        if (!p.ValidateContractPriceWithinVariation(i))
        {
            decimal unitPrice = 0;
            decimal variationPercentage = 0;
            if (i.ItemType == PurchaseItemType.Service)
            {
                unitPrice = p.Contract.GetServiceUnitPrice(i.FixedRateID.Value);
                OContractPriceService cp = p.Contract.GetContractPriceService(i.FixedRateID.Value);
                if (cp.AllowVariation == null || cp.AllowVariation == 0)
                    variationPercentage = 0;
                else
                    variationPercentage = cp.VariationPercentage.Value;
            }
            else if (i.ItemType == PurchaseItemType.Material)
            {
                unitPrice = p.Contract.GetMaterialUnitPrice(i.CatalogueID.Value);
                OContractPriceMaterial cp = p.Contract.GetContractPriceMaterial(i.CatalogueID.Value);
                if (cp.AllowVariation == null || cp.AllowVariation == 0)
                    variationPercentage = 0;
                else
                    variationPercentage = cp.VariationPercentage.Value;
            }

            UnitPrice.ErrorMessage = String.Format(Resources.Errors.PurchaseOrder_LineItemNotWithinContractPriceVariation, variationPercentage, unitPrice);
        }

        // Validates quantity if its a Whole Number according to Catalog Type
        //
        if (CatalogueID.SelectedValue != "")
        {
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(CatalogueID.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(QuantityOrdered.Text) != 0)
            {
                QuantityOrdered.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }
        }

        // Validates if subtotal amount greater than original amount.
        //
        if (objectBase.CurrentObjectState == "PendingReceipt" && (i.UnitPriceInSelectedCurrency * i.QuantityOrdered) > (i.OriginalUnitPriceInSelectedCurrency * i.OriginalQuantity))
        {
            UnitPrice.ErrorMessage = QuantityOrdered.ErrorMessage = Resources.Errors.PurchaseOrder_SubTotalOriginalLineItemAmount;
        }

        if (!PurchaseOrderItem_SubPanel.ObjectPanel.IsValid)
            return;

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
        if (ItemType.SelectedValue == PurchaseItemType.Others.ToString())
        {
            i.AdditionalDescription = "";
        }

        p.PurchaseOrderItems.Add(i);
        p.ReorderItems(i);
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
            OPurchaseOrderItem item = PurchaseOrderItem_SubPanel.SessionObject as OPurchaseOrderItem;

            PurchaseOrderItem_SubPanel.ObjectPanel.BindControlsToObject(item);
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
            List<OStore> list = OStore.FindAccessibleStoresActiveForCheckIn(AppSession.User, Security.Decrypt(Request["TYPE"]), por.StoreID, true, false);
            if (por.StoreID != null)
                dropStoreBin.Bind(OStoreBin.GetStoreBinsByStoreID(por.StoreID.Value, por.StoreBinID));

            dropStore.Bind(list);
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

        OPurchaseOrderReceipt currentPor = (OPurchaseOrderReceipt)PurchaseOrderReceipt_Subpanel.SessionObject;
        PurchaseOrderReceipt_Subpanel.ObjectPanel.BindControlsToObject(currentPor);

        //Validate each item, do not let receive more than ordered amount
        decimal?[] arrTotal = new decimal?[currentPor.PurchaseOrderReceiptItems.Count];
        for (int j = 0; j <= currentPor.PurchaseOrderReceiptItems.Count - 1; j++)
        {
            arrTotal[j] = 0;
        }

        foreach (OPurchaseOrderReceipt por in po.PurchaseOrderReceipts)
        {
            int i = 0;
            foreach (OPurchaseOrderReceiptItem pori in por.PurchaseOrderReceiptItems)
            {
                arrTotal[i] += pori.QuantityDelivered;
                i++;
            }
        }

        int k = 0;
        foreach (OPurchaseOrderReceiptItem pori in currentPor.PurchaseOrderReceiptItems)
        {
            if (pori.PurchaseOrderItem.QuantityOrdered < arrTotal[k] + pori.QuantityDelivered)
            {
                PurchaseOrderReceiptItems.ErrorMessage = Resources.Errors.PurchaseOrder_InvalidReceiptItems;
                return;
            }
            k++;
        }

        po.PurchaseOrderReceipts.Add(currentPor);
        panel.ObjectPanel.BindObjectToControls(po);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="po"></param>
    protected void HideAndShowDetailsTabControls(OPurchaseOrder po)
    {
        ddlLocation.Enabled = gridBudget.Rows.Count == 0 && !subpanelBudget.Visible;

        // Set access control for case the buttons
        //
        buttonViewCase.Visible = AppSession.User.AllowViewAll("OCase") && (po.CaseID != null);
        buttonEditCase.Visible = (AppSession.User.AllowEditAll("OCase") || OActivity.CheckAssignment(AppSession.User, po.CaseID)) && (po.CaseID != null);

        // Set access control for contract the buttons
        //
        buttonViewContract.Visible = AppSession.User.AllowViewAll("OContract") && (po.GeneratedTermContractID != null);
        buttonEditContract.Visible = (AppSession.User.AllowEditAll("OContract") || OActivity.CheckAssignment(AppSession.User, po.GeneratedTermContractID)) && (po.GeneratedTermContractID != null);

        // Set access control for revised WJ the buttons
        //
        buttonViewWJ.Visible = AppSession.User.AllowViewAll("ORequestForQuotation") && (po.RequestForQuotationID != null);

        rfqNumber.Visible = rfqNumber.Text != "";
        ddlLocation.Visible = !checkIsGroupPO.Checked;
        listLocations.Visible = checkIsGroupPO.Checked;
        dropCampaign.Visible = dropCampaign.Items.Count > 1 || (dropCampaign.Items.Count == 1 && dropCampaign.Items[0].Text != "");

        BudgetGroupID.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;

        checkIsTermContract.Enabled = PurchaseOrderItems.Rows.Count == 0 && !this.PurchaseOrderItem_SubPanel.Visible && po.StoreID == null;
        labelTermContract.Visible = (labelTermContract.Text != "");

        StoreID.Visible = StoreID.SelectedValue != "";
        panelWarranty.Visible = (radioHasWarranty.SelectedValue == "1");

        LOAPanel.Visible = rdlPOType.SelectedIndex == PurchaseOrderType.LOA;
        POPanel.Visible = rdlPOType.SelectedIndex == PurchaseOrderType.PO;
        PaymentTerms.Visible = rdlPOType.SelectedIndex == PurchaseOrderType.PO;

        //
        PaymentSchedule_Panel.Enabled = po.PurchaseOrderItems.Count > 0;
        rdlPaidByPercentage.Enabled = po.PurchaseOrderPaymentSchedules.Count <= 0 && subpanel_PaymentSchedules.Visible == false;
        btnDistributeAmount.Enabled = subpanel_PaymentSchedules.Visible == false;
        if (grid_PaymentSchedules.Rows.Count <= 0 && rdlPaidByPercentage.SelectedIndex != 0)
            rdlPaidByPercentage.SelectedIndex = 1;

        //2011 12 27 ptb
        //Set default for LOA/PO
        OCapitalandCompany company1 = TablesLogic.tCapitalandCompany.Load(TablesLogic.tCapitalandCompany.ObjectName == "Test");
        OCapitalandCompany company2 = TablesLogic.tCapitalandCompany.Load(TablesLogic.tCapitalandCompany.ObjectName == "Test");
        if (rdlPOType.SelectedIndex == PurchaseOrderType.LOA)
        {
            panel.ObjectPanel.BindControlsToObject(po);
            po.TrustID = po.TrustID == null ? company1.ObjectID : po.TrustID;
            po.ManagementCompanyID = po.ManagementCompanyID == null ? company2.ObjectID : po.ManagementCompanyID;
            panel.ObjectPanel.BindObjectToControls(po);
        }
        else if (rdlPOType.SelectedIndex == PurchaseOrderType.PO)
        {
            panel.ObjectPanel.BindControlsToObject(po);
            po.DeliveryToID = po.DeliveryToID == null ? company2.ObjectID : po.DeliveryToID;
            po.BillToID = po.BillToID == null ? company1.ObjectID : po.BillToID;
            po.ManagementCompanyID = po.ManagementCompanyID == null ? null : po.ManagementCompanyID;
            panel.ObjectPanel.BindObjectToControls(po);
        }

        //DeliverToContactPersonID.Visible = BillToContactPersonID.Visible = ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM";
        CRVReminder.Text = Resources.Messages.PurchaseOrder_CRVReminder;
        CRVReminder.Visible = po.SubTotal > 200000;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="po"></param>
    protected void HideAndShowBudgetTabControls(OPurchaseOrder po)
    {
        tabBudget.Visible =
            ((!checkIsGroupPO.Checked && ddlLocation.SelectedValue != "") || (checkIsGroupPO.Checked && listLocations.SelectedItem != null)) &&
            DateRequired.DateTime != null && po.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;

        gridBudget.Visible = radioBudgetDistributionMode.SelectedValue != "";
        radioBudgetDistributionMode.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;

        //dropItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString();
        gridBudgetSummary.Visible = gridBudgetSummary.Rows.Count > 0;

        buttonAddBudget.Enabled = !panelBudget.Visible;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="po"></param>
    protected void HideAndShowLineItemTabControls(OPurchaseOrder po)
    {
        // Enable PO Line Items if there is no good receipts.
        //
        PurchaseOrderItems.Enabled = po.PurchaseOrderReceipts.Count == 0 && !PurchaseOrderReceipt_Panel.Visible;

        textForeignToBaseExchangeRate.Enabled = !(OApplicationSetting.Current.AllowChangeOfExchangeRate == 0 && po.IsExchangeRateDefined == 1) && !(objectBase.CurrentObjectState.Is("Start", "Draft") && po != null);

        //
        CatalogueID.Visible = ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        UnitOfMeasure.Visible = ItemType.SelectedValue == PurchaseItemType.Material.ToString();

        UnitOfMeasure2.Visible = ItemType.SelectedValue == PurchaseItemType.Service.ToString();
        FixedRateID.Visible = ItemType.SelectedValue == PurchaseItemType.Service.ToString();

        UnitOfMeasureID.Visible = ItemType.SelectedValue == PurchaseItemType.Others.ToString();
        ItemDescription.Visible = ItemType.SelectedValue == PurchaseItemType.Others.ToString();

        radioReceiptMode.Enabled = ItemType.SelectedValue != PurchaseItemType.Material.ToString();
        QuantityOrdered.Enabled = radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString();

        AdditionalDescription.Visible = ItemType.SelectedValue == PurchaseItemType.Material.ToString() || ItemType.SelectedValue == PurchaseItemType.Service.ToString();

        ItemType.Items[0].Enabled = !checkIsTermContract.Checked;

        PurchaseOrderItemAmountPanel.Enabled = (OApplicationSetting.Current.AllowChangeOfPOAmount == 1) && (po.NonCancelledPurchaseInvoices.Count == 0);
        PurchaseOrderItem_SubPanel.UpdateButtonVisible = (OApplicationSetting.Current.AllowChangeOfPOAmount == 1) && (po.NonCancelledPurchaseInvoices.Count == 0);

        // Option to have tax code per line item enable only when there is no invoice.
        //
        radioTaxCodePerLineItem.Visible = OApplicationSetting.Current.AllowPerLineItemTaxInPO != null && OApplicationSetting.Current.AllowPerLineItemTaxInPO == 1;
        radioTaxCodePerLineItem.Enabled = (po.NonCancelledPurchaseInvoices.Count == 0);

        panelChargeRecoverableAmount.Visible = checkRecoverable.Checked;

        // Update the quotation policy hint.
        //
        hintRFQToPOPolicy.Text = po.ValidateRFQToPOPolicyRequired();
        hintRFQToPOPolicy.Visible = (hintRFQToPOPolicy.Text != "");

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="po"></param>
    protected void HideAndShowGoodReceiptTabControls(OPurchaseOrder po)
    {
        panelAddReceipt.Visible = !PurchaseOrderReceipt_Panel.Visible && !PurchaseOrderItem_Panel.Visible && !po.ContainsUnsavedReceipts() && po.PurchaseOrderItems.Count > 0;
        panelSaveTip.Visible = po.ContainsUnsavedReceipts() && !PurchaseOrderReceipt_Panel.Visible;
        panelInvoiceMatchToPO.Enabled = po.CurrentActivity.ObjectName != "Cancelled" && po.CurrentActivity.ObjectName != "CancelledAndRevised";
        panelInvoiceMatchToReceipt.Visible = false;

        panelVendorAttachments.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="po"></param>
    protected void HideAndShowVendorTabControls(OPurchaseOrder po)
    {
        VendorID.Enabled = ContractID.SelectedIndex == 0;
        //UnitPrice.Enabled = ContractID.SelectedIndex == 0 || (ItemType.SelectedIndex == 2);
        ContractID.Enabled = !this.PurchaseOrderItem_SubPanel.Visible && po.PurchaseOrderItems.Count == 0;
    }

    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        if (po == null)
            return;

        HideAndShowDetailsTabControls(po);

        HideAndShowLineItemTabControls(po);

        HideAndShowVendorTabControls(po);

        HideAndShowBudgetTabControls(po);

        HideAndShowGoodReceiptTabControls(po);

        Workflow_Setting(po);

        //panel.ObjectPanel.BindControlsToObject(po);

        /****************
        if (po.IsNew)
        {
            if (po.BudgetGroupID == null && BudgetGroupID.Items.Count == 1)
                BudgetGroupID.SelectedIndex = 0;

            if (po.TransactionTypeGroupID == null && dropPurchaseTypeClassification.Items.Count == 1)
            {
                dropPurchaseTypeClassification.SelectedIndex = 0;
                //dropPurchaseType.Bind(TablesLogic.tCode.LoadList(TablesLogic.tCode.ParentID == new Guid(dropPurchaseTypeClassification.SelectedValue)));
                dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, new Guid(dropPurchaseTypeClassification.SelectedValue), Security.Decrypt(Request["TYPE"]), po.PurchaseTypeID));
            }
        }
        ******************/

        //if (objectBase.CurrentObjectState.Is("PendingReceipt"))
        //{
        //    ListItem item = objectBase.GetWorkflowRadioListItem("InvoiceSubmittedForApproval");
        //    if (item != null)
        //        item.Enabled = false;
        //    if (OApplicationSetting.Current.AllowChangeOfPOAmount == 1)
        //    {
        //        if (po.NonCancelledPurchaseInvoices.Count == 0)
        //        {
        //            PurchaseOrderItemAmountPanel.Enabled = true;
        //            PurchaseOrderItem_SubPanel.UpdateButtonVisible = true;

        //        }
        //    }
        //}

    }

    /// <summary>
    /// Hides/shows or enables/disables elements based on workflow status.
    /// </summary>
    protected void Workflow_Setting(OPurchaseOrder po)
    {

        string action = objectBase.SelectedAction;
        string currentState = objectBase.CurrentObjectState;

        //tabDetails.Enabled = !objectBase.CurrentObjectState.Is("Close", "Cancelled", "CancelledAndRevised");
        panelPOAndLOA.Enabled = !objectBase.CurrentObjectState.Is("Close", "Cancelled", "CancelledAndRevised");
        panelDetails.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingCancellation", "PendingCancelAndRevised", "PendingReceipt", "PendingInvoiceApproval", "Cancelled", "CancelledAndRevised", "Close");
        panelDetails2.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingCancellation", "PendingCancelAndRevised", "PendingReceipt", "PendingInvoiceApproval", "Cancelled", "CancelledAndRevised", "Close");
        //tabVendor.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "Cancelled", "CancelledAndRevised", "Close");
        panelTabVendor.Enabled = panelVendor1.Enabled = panelVendor2.Enabled = panelCurrency.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "Cancelled", "CancelledAndRevised", "Close");

        tabTerms.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingReceipt", "PendingInvoiceApproval", "Cancelled", "CancelledAndRevised", "Close");
        tabLineItems.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingInvoiceApproval", "Cancelled", "CancelledAndRevised", "Close");
        tabBudget.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "PendingInvoiceApproval", "Cancelled", "CancelledAndRevised", "Close");

        if (objectBase.CurrentObjectState.Is("PendingReceipt"))
        {
            //controls under tab line item
            PurchaseOrderItemAddButtonPanel.Enabled = PurchaseOrderItems.Columns[1].Visible =
            PurchaseOrderItems.ActionButtons[0].Enabled = PurchaseOrderItems.ActionButtons[1].Enabled =
            PurchaseOrderItemDetailsPanel.Enabled = PurchaseOrderItem_SubPanel.UpdateButtonVisible =
            PurchaseOrderItem_SubPanel.UpdateAndNewButtonVisible = PurchaseOrderItemAmountPanel.Enabled = false;

            //controls under tab budget
            radioBudgetDistributionMode.Enabled = buttonAddBudget.Enabled = panelBudget.Enabled =
            gridBudgetSummary.Enabled = buttonAddBudgetHidden.Enabled = popupAddBudget.Enabled =
            gridBudget.ActionButtons[0].Visible = gridBudget.ActionButtons[1].Visible =
            gridBudget.Columns[1].Visible = gridBudget.Columns[0].Visible = objectPanelAddBudget.Visible = false;

        }
        tabInvoice.Visible = objectBase.CurrentObjectState.Is("PendingReceipt", "PendingInvoiceApproval", "Close");

        // 2011.08.17
        //
        //tabPaymentSchedule.Enabled = objectBase.CurrentObjectState.Is("PendingReceipt","Start","Draft");

        tabReceipt.Visible = objectBase.CurrentObjectState.Is("PendingReceipt", "PendingInvoiceApproval", "Cancelled", "CancelledAndRevised", "Close");
        panelAddReceipt.Enabled = objectBase.CurrentObjectState.Is("PendingReceipt");
        DeliveryDate.ValidateRequiredField = !objectBase.SelectedAction.Contains("Cancel");
        ddlBillTo.ValidateRequiredField = !objectBase.SelectedAction.Contains("Cancel");
        ddlDeliveryTo.ValidateRequiredField = !objectBase.SelectedAction.Contains("Cancel");
        ddlManagementCompany.ValidateRequiredField = !objectBase.SelectedAction.Contains("Cancel");
        ddlOnBehalfOf.ValidateRequiredField = !objectBase.SelectedAction.Contains("Cancel");
        ddlTrust.ValidateRequiredField = !objectBase.SelectedAction.Contains("Cancel");
        ddlSignatory.ValidateRequiredField = !objectBase.SelectedAction.Contains("Cancel");

        // Display send po to vendor if
        // po type is 1 (PO) and po is not new.
        // Do not allow user to send PO to vendor via e-mail
        // when po is new. User has to save the po before sending.
        // Allow add invoice when pending receipt.
        // Allow add credit memo when the po is closed.
        //
        buttonAddInvoice.Enabled = !currentState.Is("Close");
        buttonAddCreditMemo.Enabled = currentState.Is("Close");
        buttonAddDebitMemo.Enabled = currentState.Is("Close");
        buttonSendPOToVendor.Visible = (currentState.Is("PendingReceipt")) && (po.POType == PurchaseOrderType.PO);

        ListItem item = objectBase.GetWorkflowRadioListItem("InvoiceSubmittedForApproval");
        if (item != null)
            item.Enabled = !currentState.Is("PendingReceipt");

        ListItem receipt = objectBase.GetWorkflowRadioListItem("SubmitForReceipt");
        if (receipt != null)
            receipt.Enabled = !(objectBase.CurrentObjectState.Is("Start") || objectBase.CurrentObjectState.Is("PendingInvoiceApproval"));

        ListItem close = objectBase.GetWorkflowRadioListItem("Close");
        if (close != null)
            close.Enabled = !objectBase.CurrentObjectState.Is("PendingInvoiceApproval");

        // 2011.10.12, Kien Trung
        // Hide Cancel and Revised if this is Direct PO.
        //
        ListItem cancelrevised = objectBase.GetWorkflowRadioListItem("SubmitForApproval_CancelAndRevise");
        if (cancelrevised != null)
            cancelrevised.Enabled = !(po.RFQNumber == "");

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

        // 2011.08.19, Kien Trung
        // Default Unit Price for inventory catalog.
        // Default Additional Description to Catalogue ObjectName
        if (i.CatalogueID != null)
        {
            i.UnitPriceInSelectedCurrency = i.Catalogue.UnitPrice;
            i.UnitPrice = i.UnitPrice / po.ForeignToBaseExchangeRate;
            i.AdditionalDescription = (i.AdditionalDescription != null && i.AdditionalDescription.Trim() != "" ? i.AdditionalDescription : i.Catalogue.ObjectName);
        }

        if (po.ContractID != null)
        {
            if (i.CatalogueID != null)
            {
                i.UnitPrice = po.Contract.GetMaterialUnitPrice(i.CatalogueID.Value);
                i.UnitPriceInSelectedCurrency = i.UnitPrice / po.ForeignToBaseExchangeRate;
            }
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

        // 2011.08.19, Kien Trung
        // Default Fixed rate unit price.
        //
        if (i.FixedRateID != null)
        {
            i.UnitPriceInSelectedCurrency = i.FixedRate.UnitPrice;
            i.UnitPrice = i.UnitPriceInSelectedCurrency * po.ForeignToBaseExchangeRate;
            i.AdditionalDescription = (i.AdditionalDescription != null && i.AdditionalDescription.Trim() != "" ? i.AdditionalDescription : i.FixedRate.ObjectName);
        }

        if (po.ContractID != null)
        {
            if (i.FixedRateID != null)
            {
                i.UnitPrice = po.Contract.GetServiceUnitPrice(i.FixedRateID.Value);
                i.UnitPriceInSelectedCurrency = i.UnitPrice / po.ForeignToBaseExchangeRate;
            }
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
        po.UpdateItemRecoverables();
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
        po.UpdateItemRecoverables();
        panel.ObjectPanel.BindObjectToControls(po);
    }

    /// <summary>
    /// Populates the budget subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelBudget_PopulateForm(object sender, EventArgs e)
    {
        //OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        //panel.ObjectPanel.BindControlsToObject(po);

        //OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        //dropBudget.Bind(OBudget.GetCoveringBudgets(po.Location, prBudget.BudgetID));
        //if (subpanelBudget.IsAddingObject)
        //{
        //    if (dropBudget.Items.Count == 2)
        //        prBudget.BudgetID = new Guid(dropBudget.Items[1].Value);
        //    prBudget.StartDate = po.DateRequired;
        //    prBudget.EndDate = po.DateEnd;
        //}

        //dropItemNumber.Items.Clear();
        //for (int i = 1; i <= po.PurchaseOrderItems.Count; i++)
        //    dropItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        //populateAccount();
        //subpanelBudget.ObjectPanel.BindObjectToControls(prBudget);

        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        if (BudgetGroupID.SelectedValue != "")
        {
            if (!checkIsGroupPO.Checked)
                dropAddBudget.Bind(OBudget.GetCoveringBudgets(po.Location, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
            else
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in po.GroupPOLocations)
                    locations.Add(location);
                dropAddBudget.Bind(OBudget.GetCoveringBudgets(locations, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
            }
        }

        dropAddBudgetItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString();

        if (subpanelBudget.IsAddingObject)
        {
            dropAddBudgetItemNumber.Items.Clear();
            for (int i = 1; i <= po.PurchaseOrderItems.Count; i++)
                dropAddBudgetItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

            dateAddBudgetStartDate.DateTime = po.DateRequired;
            dateAddBudgetEndDate.DateTime = po.DateEnd;

            if (dropAddBudget.Items.Count == 2)
            {
                dropAddBudget.SelectedIndex = 1;
                treeAddBudgetAccounts.PopulateTree();
            }

            AutoComputeBudgetAmount(po);
        }
        else
        {
            if (dropAddBudget.Items.Count == 2)
            {
                dropAddBudget.SelectedIndex = 1;
                treeAddBudgetAccounts.PopulateTree();
            }

            subpanelBudget.ObjectPanel.BindObjectToControls(prBudget);
        }
    }

    protected void AutoComputeBudgetAmount(OPurchaseOrder po)
    {
        decimal? amount = 0;
        decimal? totalAmount = 0;
        decimal? recoverableAmount = 0;

        if (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.EntireAmount.ToString())
        {
            foreach (OPurchaseBudget pb in po.PurchaseBudgets)
                amount += pb.Amount;

            foreach (OPurchaseOrderItem item in po.PurchaseOrderItems)
            {
                totalAmount += item.Subtotal;
                recoverableAmount += LogicLayerPersistentObject.Round(item.RecoverableAmount);
            }

            if (po.IsRecoverable == (int)EnumRecoverable.Recoverable)
                totalAmount = totalAmount - recoverableAmount;
        }
        else
        {
            int no = Convert.ToInt16(dropAddBudgetItemNumber.SelectedValue);
            OPurchaseOrderItem item = po.PurchaseOrderItems.Find((r) => r.ItemNumber == no);

            if (item != null)
            {
                totalAmount = item.Subtotal;
                recoverableAmount = LogicLayerPersistentObject.Round(item.RecoverableAmount);
            }

            List<OPurchaseBudget> pbList = po.PurchaseBudgets.FindAll((r) => r.ItemNumber == no);
            if (pbList != null)
                foreach (OPurchaseBudget pb in pbList)
                    amount += pb.Amount;

            if (po.IsRecoverable == (int)EnumRecoverable.Recoverable)
                totalAmount = totalAmount - recoverableAmount;
        }

        // Default total amount in budget adding
        //
        decimal remainAmount = totalAmount >= amount ? Convert.ToDecimal(totalAmount - amount) : 0;
        textAddBudgetAmount.Text = Math.Round(remainAmount, 2, MidpointRounding.AwayFromZero).ToString();
    }
    /// <summary>
    /// Populates the account tree view.
    /// </summary>
    protected void populateAccount()
    {
        //OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
        //if (prBudget.StartDate != null && prBudget.BudgetID != null)
        //    treeAccount.PopulateTree();
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

        if (subpanelBudget.IsAddingObject)
        {
            int count = 0;
            decimal amount = Convert.ToDecimal(textAddBudgetAmount.Text);
            for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(1))
                count++;

            int c = 0;
            OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
            for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(1))
            {
                OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
                pb.BudgetID = new Guid(dropAddBudget.SelectedValue);
                pb.StartDate = d;
                pb.EndDate = d;
                pb.AccrualFrequencyInMonths = 1;
                pb.AccountID = new Guid(treeAddBudgetAccounts.SelectedValue);
                if (c != count - 1)
                    pb.Amount = Math.Round(amount / count, 2, MidpointRounding.AwayFromZero);
                else
                    pb.Amount = amount - Math.Round(amount / count, 2, MidpointRounding.AwayFromZero) * (count - 1);

                if (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.EntireAmount.ToString())
                    // 2010.05.24
                    // Kim Foong
                    // This must be set to 1 because the OPurchaseBudget.TransferPurchaseBudgets
                    // will encounter a bug when called by the OPurchaseOrder.AddPOLineItemsFromRFQLineItems
                    // when the BudgetDistributionMode = 0 and the number of line items is greater than 1.
                    //
                    pb.ItemNumber = 1;
                else
                    // 2010.05.24
                    // Kim Foong
                    // Updated so that the correct item number is inserted.
                    pb.ItemNumber = dropAddBudgetItemNumber.SelectedIndex + 1;

                po.PurchaseBudgets.Add(pb);
                c++;
            }

            if (po.CurrentActivity == null ||
                !po.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled", "CancelledAndRevised"))
            {
                po.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";

            }

            //popupAddBudget.Hide();
            //objectPanelAddBudget.Visible = false;

            tabBudget.BindObjectToControls(po);
        }
        else
        {
            OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
            panel.ObjectPanel.BindControlsToObject(po);

            OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
            subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);

            prBudget.EndDate = prBudget.StartDate;
            prBudget.AccrualFrequencyInMonths = 1;

            // Validate
            //

            // Insert
            //
            po.PurchaseBudgets.Add(prBudget);

            if (po.CurrentActivity == null ||
                !po.CurrentActivity.ObjectName.Is("PendingApproval", "PendingReceipt", "PendingInvoiceApproval", "Close", "Cancelled", "CancelledAndRevised"))
            {
                po.ComputeTempBudgetSummaries();
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
            }

            tabBudget.BindObjectToControls(po);
        }
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
            !po.CurrentActivity.ObjectName.Is("PendingApproval", "PendingReceipt", "PendingInvoiceApproval", "Close", "Cancelled", "CancelledAndRevised"))
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
                Window.Open("../../cutomizedmodulesforCapitaland-ccl/budgetperiod/budgetview.aspx?ID=" +
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
        Window.OpenAddObjectPage(this, inv, "");
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
        Window.OpenAddObjectPage(this, inv, "");
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
        Window.OpenAddObjectPage(this, inv, "");
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
            e.Row.Cells[9].Text = e.Row.Cells[8].Text + e.Row.Cells[9].Text;
            e.Row.Cells[10].Text = e.Row.Cells[8].Text + e.Row.Cells[10].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[8].Visible = false;
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
        else if (commandName == "ViewInvoice")
        {
            if (dataKeys.Count > 0)
            {
                Guid id = (Guid)dataKeys[0];
                Window.OpenViewObjectPage(Page, "OPurchaseInvoice", id.ToString(), "");
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

    protected void dropPurchaseTypeClassification_SelectedIndexChanged(object sender, EventArgs e)
    {
        //dropPurchaseType.Bind(TablesLogic.tCode.LoadList(TablesLogic.tCode.ParentID == new Guid(dropPurchaseTypeClassification.SelectedValue)));
        dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, new Guid(dropPurchaseTypeClassification.SelectedValue), Security.Decrypt(Request["TYPE"]), null));
    }

    protected void rdlPOType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void subpanel_PaymentSchedules_PopulateForm(object sender, EventArgs e)
    {

        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseOrderPaymentSchedule paymentSchedule = subpanel_PaymentSchedules.SessionObject as OPurchaseOrderPaymentSchedule;

        if (po.IsPaymentPaidByPercentage == 0)
        {
            AmountToPay.Enabled = true;
            PercentageToPay.Visible = false;
        }
        else
        {
            AmountToPay.Enabled = false;
            PercentageToPay.Visible = true;
        }
        subpanel_PaymentSchedules.ObjectPanel.BindObjectToControls(paymentSchedule);
    }

    protected void btnDistributeAmount_Click(object sender, EventArgs e)
    {

        modalDistributeAmountPopup.Show();
        panelDistributeAmountPopup.Visible = true;
        OPurchaseOrderPaymentSchedule paymentSchedule = subpanel_PaymentSchedules.SessionObject as OPurchaseOrderPaymentSchedule;
        subpanel_PaymentSchedules.ObjectPanel.BindControlsToObject(paymentSchedule);
    }
    public bool IsNumeric(String s)
    {
        char[] ca = s.ToCharArray();
        for (int i = 0; i < ca.Length; i++)
        {
            if (!char.IsNumber(ca[i]) && ca[i] != '.' && ca[i] != ',')
                return false;
        }
        return true;
    }

    /// <summary>
    ///
    /// </summary>
    /// <returns></returns>
    public bool ValidateDistributionAmount()
    {
        if (PaymentSchedule_StartDate.DateTime == null)
        {
            lblErrorMessage.Text = "'Start Date' can not be lelf empty.Please select 'Start Date'.";
            lblErrorMessage.Visible = true;
        }
        else if (PatmentSchedule_EndDate.DateTime == null)
        {
            lblErrorMessage.Text = "'Start Date' can not be lelf empty. Please select 'End Date'.";
            lblErrorMessage.Visible = true;
        }
        else if (txtPaymentFrequency.Text == null || txtPaymentFrequency.Text == string.Empty)
        {
            lblErrorMessage.Text = "'Payment Frequency' can not be left empty. Please enter 'Payment Frequence'.";
            lblErrorMessage.Visible = true;
        }
        else if (!IsNumeric(txtPaymentFrequency.Text))
        {
            lblErrorMessage.Text = "Please specifiy a valid integer for 'Payment Frequence'";
            lblErrorMessage.Visible = true;
        }
        return true;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDistribute_Click(object sender, EventArgs e)
    {
        if (ValidateDistributionAmount())
        {
            OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
            po.PurchaseOrderPaymentSchedules.Clear();
            DateTime startDate = (DateTime)PaymentSchedule_StartDate.DateTime;
            DateTime endDate = (DateTime)PatmentSchedule_EndDate.DateTime;
            int numberOfMonths = 0;
            do
            {
                numberOfMonths++;
                startDate = startDate.AddMonths(Convert.ToInt16(txtPaymentFrequency.Text));
            } while (startDate < endDate);

            decimal totalAmount = 0;
            foreach (OPurchaseOrderItem item in po.PurchaseOrderItems)
            {
                totalAmount += LogicLayerPersistentObject.Round(item.QuantityOrdered.Value * item.UnitPriceInSelectedCurrency.Value);
            }

            int i = 0;
            startDate = (DateTime)PaymentSchedule_StartDate.DateTime;
            decimal amountToPay = 0;
            do
            {
                i++;
                OPurchaseOrderPaymentSchedule ps = TablesLogic.tPurchaseOrderPaymentSchedule.Create();
                ps.DateOfPayment = startDate;
                if (i != numberOfMonths)
                {
                    ps.AmountToPay = Math.Round((decimal)(totalAmount / numberOfMonths), 2, MidpointRounding.AwayFromZero);
                    amountToPay += Math.Round((decimal)(totalAmount / numberOfMonths), 2, MidpointRounding.AwayFromZero);
                }
                else
                {
                    ps.AmountToPay = Math.Round((decimal)(totalAmount - amountToPay), 2, MidpointRounding.AwayFromZero);
                }
                po.PurchaseOrderPaymentSchedules.Add(ps);
                startDate = startDate.AddMonths(Convert.ToInt16(txtPaymentFrequency.Text));
            } while (startDate < endDate);
            po.IsPaymentPaidByPercentage = null;
            PaymentSchedule_Panel.BindObjectToControls(po);
            modalDistributeAmountPopup.Hide();
            panelDistributeAmountPopup.Visible = false;
        }
    }

    protected void subpanel_PaymentSchedules_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseOrder po = (OPurchaseOrder)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(po);

        OPurchaseOrderPaymentSchedule paymentSchedule = (OPurchaseOrderPaymentSchedule)subpanel_PaymentSchedules.SessionObject;

        subpanel_PaymentSchedules.ObjectPanel.BindControlsToObject(paymentSchedule);
        po.PurchaseOrderPaymentSchedules.Add(paymentSchedule);
        PaymentSchedule_Panel.BindObjectToControls(po);
    }

    protected void btnCancelDistribute_Click(object sender, EventArgs e)
    {
        modalDistributeAmountPopup.Hide();
        panelDistributeAmountPopup.Visible = false;
    }

    protected void PercentageToPay_TextChanged(object sender, EventArgs e)
    {
        if (IsNumeric(PercentageToPay.Text))
        {
            OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
            panel.ObjectPanel.BindControlsToObject(po);
            decimal totalPOAmount = 0;
            foreach (OPurchaseOrderItem item in po.PurchaseOrderItems)
                totalPOAmount += LogicLayerPersistentObject.Round((decimal)(item.QuantityOrdered * item.UnitPriceInSelectedCurrency));
            AmountToPay.Text = (Math.Round(totalPOAmount * Convert.ToDecimal(PercentageToPay.Text) / 100, 2, MidpointRounding.AwayFromZero)).ToString();
        }
        else
        {
            PercentageToPay.ErrorMessage = "Please specify a valid decimal number for 'Percentage to pay'";
        }
    }

    /// <summary>
    /// Add budget account.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddBudget_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);

        if (BudgetGroupID.SelectedValue != "")
        {
            if (!checkIsGroupPO.Checked)
            {
                dropAddBudget.Bind(OBudget.GetCoveringBudgets(po.Location, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
            }
            else
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in po.GroupPOLocations)
                    locations.Add(location);
                dropAddBudget.Bind(OBudget.GetCoveringBudgets(locations, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
            }
        }

        dropAddBudgetItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == "1";
        dropAddBudgetItemNumber.Items.Clear();
        for (int i = 1; i <= po.PurchaseOrderItems.Count; i++)
            dropAddBudgetItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        dateAddBudgetStartDate.DateTime = po.DateRequired;
        dateAddBudgetEndDate.DateTime = po.DateEnd;

        if (dropAddBudget.Items.Count == 2)
        {
            dropAddBudget.SelectedIndex = 1;
            treeAddBudgetAccounts.PopulateTree();
        }

        popupAddBudget.Show();
        objectPanelAddBudget.Visible = true;
    }

    /// <summary>
    /// Event
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddBudgetCancel_Click(object sender, EventArgs e)
    {
        popupAddBudget.Hide();
        objectPanelAddBudget.Visible = false;
    }

    /// <summary>
    /// Event
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddBudgetConfirm_Click(object sender, EventArgs e)
    {
        if (!objectPanelAddBudget.IsValid)
            return;

        int count = 0;
        decimal amount = Convert.ToDecimal(textAddBudgetAmount.Text);
        for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(1))
            count++;

        int c = 0;
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(1))
        {
            OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
            pb.BudgetID = new Guid(dropAddBudget.SelectedValue);
            pb.StartDate = d;
            pb.EndDate = d;
            pb.AccrualFrequencyInMonths = 1;
            pb.AccountID = new Guid(treeAddBudgetAccounts.SelectedValue);
            if (c != count - 1)
                pb.Amount = Math.Round(amount / count, 2, MidpointRounding.AwayFromZero);
            else
                pb.Amount = amount - Math.Round(amount / count, 2, MidpointRounding.AwayFromZero) * (count - 1);

            po.PurchaseBudgets.Add(pb);
            c++;
        }

        if (po.CurrentActivity == null ||
            !po.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled", "CancelledAndRevised"))
        {
            po.ComputeTempBudgetSummaries();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";

        }

        popupAddBudget.Hide();
        objectPanelAddBudget.Visible = false;

        tabBudget.BindObjectToControls(po);
    }

    /// <summary>
    /// Occurs when the budget dropdown list changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropAddBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        treeAddBudgetAccounts.PopulateTree();
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeAddBudgetAccounts_AcquireTreePopulater(object sender)
    {
        OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        if (dateAddBudgetStartDate.DateTime != null && dropAddBudget.SelectedValue != "")
        {
            Guid? purchaseTypeID = null;
            if (dropPurchaseType.SelectedValue != "")
                purchaseTypeID = new Guid(dropPurchaseType.SelectedValue);

            Guid budgetId = new Guid(dropAddBudget.SelectedValue);
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, dateAddBudgetStartDate.DateTime.Value);

            if (budgetPeriod != null)
                return new AccountTreePopulaterForCapitaland(prBudget.AccountID, false, true, budgetPeriod.ObjectID, purchaseTypeID);
            else
                return new AccountTreePopulaterForCapitaland(prBudget.AccountID, false, true, null, purchaseTypeID);
        }
        return null;
    }

    protected void ddlLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.EquipmentID = null;
        po.UpdateApplicablePurchaseSettings();
        //OLocation loca = LogicLayer.TablesLogic.tLocation.Load(po.LocationID);
        //dropCampaign.Bind(loca.CampaignsForLocations, "ObjectName", "ObjectID");

        List<OUser> persons = OUser.GetUsersByRoleAndAboveLocation(po.Location, "PURCHASEADMIN");

        ddlSignatory.Bind(persons);
        DeliverToContactPersonID.Bind(persons);
        BillToContactPersonID.Bind(persons);

        //only for marcom

        if (po.LocationID != null)
        {
            OLocation loc = TablesLogic.tLocation.Load(po.LocationID);
            po.TrustID = loc.BuildingTrustID;
            po.LOAOnBehalfOfID = loc.BuildingOwnerID;
            po.ManagementCompanyID = loc.BuildingManagementID;
            po.DeliveryToID = loc.BuildingOwnerID;
            po.BillToID = loc.BuildingTrustID;
            po.DeliverToContactPersonID = AppSession.User.ObjectID;
            po.BillToContactPersonID = AppSession.User.ObjectID;
        }

        panel.ObjectPanel.BindObjectToControls(po);
    }

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void PurchaseOrderItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[6].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
            {
                e.Row.Cells[12].Text = Convert.ToDecimal(e.Row.Cells[12].Text).ToString("#,##0");
                e.Row.Cells[14].Text = Convert.ToDecimal(e.Row.Cells[14].Text).ToString("#,##0");
            }
            //if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            //{
            //    e.Row.Cells[10].Text = Convert.ToDecimal(e.Row.Cells[10].Text).ToString(OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "#,##0.0000");
            //}
            //else
            //    e.Row.Cells[10].Text = Convert.ToDecimal(e.Row.Cells[10].Text).ToString("c");

            Guid poItemID = (Guid)PurchaseOrderItems.DataKeys[e.Row.RowIndex][0];
            OPurchaseOrderItem item = TablesLogic.tPurchaseOrderItem[poItemID];
            if (item != null && item.RequestForQuotationItem != null)
            {
                Guid rfqID = item.RequestForQuotationItem.RequestForQuotationID.Value;
                if (EditVisible[rfqID] == null)
                    EditVisible.Add(rfqID, OPurchaseOrder.IsObjectEditOrView(AppSession.User, rfqID, "ORequestForQuotation", true));
                if (ViewVisible[rfqID] == null)
                    ViewVisible.Add(rfqID, OPurchaseOrder.IsObjectEditOrView(AppSession.User, rfqID, "ORequestForQuotation", false));

                e.Row.Cells[17].Visible = Convert.ToBoolean(EditVisible[rfqID]);
                e.Row.Cells[18].Visible = Convert.ToBoolean(ViewVisible[rfqID]);
            }
            else
            {
                e.Row.Cells[17].Visible = false;
                e.Row.Cells[18].Visible = false;
            }

            UIFieldDropDownList taxcode = ((UIFieldDropDownList)e.Row.FindControl("TaxCodeID"));
            if (taxcode != null)
                taxcode.Bind(OTaxCode.GetAllTaxCodes(DateTime.Today, null));

            e.Row.Cells[15].Visible = e.Row.Cells[16].Visible = radioTaxCodePerLineItem.SelectedValue == "1";

            e.Row.Cells[15].Enabled = e.Row.Cells[16].Enabled = radioTaxCodePerLineItem.Enabled;

            //e.Row.Cells[13].Visible = rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.Recoverable).ToString();

            e.Row.Cells[13].Visible = checkRecoverable.Checked;

        }

        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[15].Visible = e.Row.Cells[16].Visible = radioTaxCodePerLineItem.SelectedValue == "1";
            //e.Row.Cells[13].Visible = rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.Recoverable).ToString();
            e.Row.Cells[13].Visible = checkRecoverable.Checked;
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
    protected void dropCampaign_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void buttonAddCatalog_Click(object sender, EventArgs e)
    {
        OFunction function = OFunction.GetFunctionByObjectType("OCatalogue");
        Window.Open(
            Page.ResolveUrl(function.EditUrl) + "?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("NEW:")) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt("OCatalogue")) +
            "&" + "ButtonID=" + this.repopulateCatalogueButton.ClientID + "&N=1", "AnacleEAM_Window_AddCatalog");
    }

    protected void repopulateCatalogue_Click(object sender, EventArgs e)
    {
        OPurchaseOrderItem purchaseOrderItem = PurchaseOrderItem_SubPanel.SessionObject as OPurchaseOrderItem;
        purchaseOrderItem.CatalogueID = (Guid)Session["NewCatalogID"];
        CatalogueID.PopulateTree();
        CatalogueID.SelectedValue = Session["NewCatalogID"].ToString();
        Session["NewCatalogID"] = null;
    }

    /// <summary>
    /// Opens a window to view the wj object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewWJ_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = (OPurchaseOrder)panel.SessionObject;
        if (po.RequestForQuotationID != null)
        {
            Window.OpenViewObjectPage(this, "ORequestForQuotation", po.RequestForQuotationID.ToString(), "");
        }
    }

    /// <summary>
    /// Sends e-mail to vendor.
    /// This event is fired when button send PO to Vendor via email clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonSendPOToVendor_Click(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        if (po.ContactEmail != null && po.ContactEmail.Trim() != "" &&
            po.DeliverToContactPerson != null &&
            po.DeliverToContactPerson.UserBase.Email != null && po.DeliverToContactPerson.UserBase.Email.Trim() != "")
        {
            gridAdditionalAttachments.DataSource = po.Attachments;
            gridAdditionalAttachments.DataBind();
            dialogAdditionalAttachments.Show();
        }
        else
            panel.Message = Resources.Errors.PurchaseOrder_VendorNoEmailAddress;
    }

    /// <summary>
    /// When OK button is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dialogAdditionalAttachments_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        if (e.CommandName == "Confirm")
            SendPOToVendor(po);
    }

    /// <summary>
    /// Method to send email to vendor
    /// </summary>
    /// <param name="po"></param>
    protected void SendPOToVendor(OPurchaseOrder po)
    {
        try
        {
            string emailReceipients = po.ContactEmail + ";" + po.DeliverToContactPerson.UserBase.Email;
            string ccEmailReceipients = textCCEmail.Text.Trim();
            po.TempEmailMessageAttachments = new List<OAttachment>();
            if (gridAdditionalAttachments.GetSelectedKeys().Count > 0)
                foreach (Guid id in gridAdditionalAttachments.GetSelectedKeys())
                    po.TempEmailMessageAttachments.Add(po.Attachments.Find((a) => a.ObjectID == id));

            po.SendMessage("PurchaseOrder_SendPOToVendor", emailReceipients, ccEmailReceipients, "");

            panel.PopupMessage = Resources.Errors.PurchaseOrder_POSentToVendorSuccessful;
        }
        catch (Exception ex)
        {
            panel.Message = String.Format(Resources.Errors.PurchaseOrder_POSentToVendorFailed, ex.Message + " " + ex.StackTrace);
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIDs"></param>
    protected void PurchaseOrderItems_Action(object sender, string commandName, List<object> objectIDs)
    {

        if (commandName == "EditRFQ")
        {
            Guid? objectID = (Guid?)objectIDs[0];
            OPurchaseOrderItem poItem = TablesLogic.tPurchaseOrderItem[objectID.Value];
            Window.OpenEditObjectPage(this, "ORequestForQuotation", poItem.RequestForQuotationItem.RequestForQuotationID.ToString(), "");
        }
        else if (commandName == "ViewRFQ")
        {
            Guid? objectID = (Guid?)objectIDs[0];
            OPurchaseOrderItem poItem = TablesLogic.tPurchaseOrderItem[objectID.Value];
            Window.OpenViewObjectPage(this, "ORequestForQuotation", poItem.RequestForQuotationItem.RequestForQuotationID.ToString(), "");
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void buttonUpload_Click(object sender, EventArgs e)
    //{
    //    if (inputFile.PostedFile != null && inputFile.PostedFile.ContentLength > 0)
    //    {
    //        OAttachment a = TablesLogic.tAttachment.Create();
    //        byte[] fileBytes = new byte[inputFile.PostedFile.ContentLength];
    //        inputFile.PostedFile.InputStream.Position = 0;
    //        inputFile.PostedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

    //        a.FileBytes = fileBytes;
    //        a.Filename = Path.GetFileName(inputFile.PostedFile.FileName);
    //        a.FileSize = inputFile.PostedFile.ContentLength;
    //        a.ContentType = inputFile.PostedFile.ContentType;

    //        a.FileDescription = this.documentDescription.Text;
    //        OPurchaseOrderReceipt receipt =
    //        PurchaseOrderReceipt_Subpanel.SessionObject as OPurchaseOrderReceipt;
    //        if (receipt != null)
    //        {
    //            receipt.Attachments.Add(a);
    //        }
    //        panelgridAttachments.BindObjectToControls(receipt);
    //        //clear other details
    //        this.documentDescription.Text = "";
    //    }
    //}

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gridDocument_Action(object sender, string commandName, List<object> objectIds)
    {
        OPurchaseOrderReceipt receipt =
                       PurchaseOrderReceipt_Subpanel.SessionObject as OPurchaseOrderReceipt;
        if (commandName == "ViewDocument")
        {
            // View the document, so load it from
            // database and let user download it.
            //
            Guid id = (Guid)objectIds[0];
            OAttachment att = receipt.Attachments.Find(id);
            if (att != null)
                Window.Download(att.FileBytes, att.Filename, att.ContentType);
        }

        // 2011.07.05, Kien Trung
        // Upload Document Command event clicked
        // show File upload dialog box.
        //
        if (commandName == "UploadDocument")
        {
            receiptAttachmentUpload.Show();
        }

        if (commandName == "DeleteDocument")
        {
            // remove the document from the database.
            //
            if (receipt != null)
            {
                foreach (Guid objectId in objectIds)
                    receipt.Attachments.RemoveGuid(objectId);

            }
            panelgridAttachments.BindObjectToControls(receipt);
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseOrderReceipts_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        // 2011.07.05, Kien Trung
        // Display Attachment for good receipt regardless instances.
        //
        if (e.Row.RowType == DataControlRowType.Header && (ConfigurationManager.AppSettings["CustomizedInstance"] != "MARCOM"))
        {
            //e.Row.Cells[7].Visible = false;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //if (ConfigurationManager.AppSettings["CustomizedInstance"] != "MARCOM")
            //    e.Row.Cells[7].Visible = false;
            if (e.Row.Cells[7].Visible)
            {
                Guid receiptId = (Guid)PurchaseOrderReceipts.DataKeys[e.Row.RowIndex][0];
                OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
                OPurchaseOrderReceipt receipt = po.PurchaseOrderReceipts.Find(receiptId);

                DataList listAttachment = (DataList)e.Row.FindControl("listAttachment");
                listAttachment.ItemDataBound += new DataListItemEventHandler(listAttachment_ItemDataBound);
                listAttachment.DataSource = receipt.Attachments;
                listAttachment.DataBind();
            }

        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void listAttachment_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        OAttachment attachment = (OAttachment)e.Item.DataItem;
        UIButton buttonDownloadAttachment = (UIButton)e.Item.FindControl("buttonDownloadAttachment");

        buttonDownloadAttachment.CommandArgument = attachment.ObjectID.ToString();
        buttonDownloadAttachment.Text = attachment.Filename;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonDownloadAttachment_Click(object sender, EventArgs e)
    {
        UIButton buttonAttachment = (UIButton)sender;

        Guid attachmentId = new Guid(buttonAttachment.CommandArgument);

        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;

        foreach (OPurchaseOrderReceipt receipt in po.PurchaseOrderReceipts)
        {
            OAttachment attachment = receipt.Attachments.Find(attachmentId);

            if (attachment != null)
            {
                panel.FocusWindow = false;
                Window.Download(attachment.FileBytes, attachment.Filename, attachment.ContentType);
            }
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioTaxCodePerLineItem_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        PurchaseOrderItemPanel.BindObjectToControls(po);
    }

    /// <summary>
    /// RowDataBound enable/disable budget amount to be changed
    /// enable when there is no active invoices
    /// disable when there is at least one invoice
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridBudget_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (objectBase.CurrentObjectState.Is("PendingReceipt") && OApplicationSetting.Current.AllowChangeOfPOAmount == 1)
            {
                OPurchaseOrder p = panel.SessionObject as OPurchaseOrder;

                if (p.NonCancelledPurchaseInvoices.Count == 0)
                {
                    UIFieldTextBox amount = (UIFieldTextBox)e.Row.FindControl("textAmount");
                    amount.Enabled = true;
                }
                else
                {
                    UIFieldTextBox amount = (UIFieldTextBox)e.Row.FindControl("textAmount");
                    amount.Enabled = false;
                }

            }
            else if (OApplicationSetting.Current.AllowChangeOfPOAmount != 1)
            {
                UIFieldTextBox amount = (UIFieldTextBox)e.Row.FindControl("textAmount");
                amount.Enabled = false;
            }
        }
    }

    /// <summary>
    /// Event handle tax code drop downlist index changed.
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TaxCodeID_SelectedIndexChanged(object sender, EventArgs e)
    {
        UIFieldDropDownList taxcode = (UIFieldDropDownList)sender;
        GridViewRow row = (GridViewRow)taxcode.NamingContainer;
        OPurchaseOrderItem item = TablesLogic.tPurchaseOrderItem.Load(new Guid(PurchaseOrderItems.DataKeys[row.RowIndex][0].ToString()));
        if (item != null)
        {
            UIFieldTextBox taxamount = (UIFieldTextBox)row.FindControl("TaxAmount");
            if (taxcode.SelectedValue != "")
            {
                OTaxCode tax = TablesLogic.tTaxCode.Load(new Guid(taxcode.SelectedValue));
                if (tax != null)
                    taxamount.Text = ((decimal)(item.UnitPrice * item.QuantityOrdered) * (tax.TaxPercentage.Value / 100)).ToString("#,##0.00##");
            }
            else
                taxamount.Text = null;
        }
    }

    //10th March 2011, Joey:
    //only for ops, show the "has warranty" radio box options, and force the user to tick one of them
    //as well as force the user to key in warranty period, when "has warranty" radio option is ticked
    protected void radioHasWarranty_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (radioHasWarranty.SelectedValue == "0")
            textWarranty.Text = txtWarrantyPeriod.Text = "";
    }

    protected void receiptAttachmentUpload_Uploaded(object sender, EventArgs e)
    {
        List<HttpPostedFile> postedFiles = receiptAttachmentUpload.GetUploadFiles();

        foreach (HttpPostedFile postedFile in postedFiles)
        {
            if (postedFile != null && postedFile.ContentLength > 0)
            {
                OAttachment a = TablesLogic.tAttachment.Create();
                byte[] fileBytes = new byte[postedFile.ContentLength];
                postedFile.InputStream.Position = 0;
                postedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

                a.FileDescription = receiptAttachmentUpload.FileUploadDescription;
                a.FileBytes = fileBytes;
                a.Filename = Path.GetFileName(postedFile.FileName);
                a.FileSize = postedFile.ContentLength;
                a.ContentType = postedFile.ContentType;

                OPurchaseOrderReceipt receipt = PurchaseOrderReceipt_Subpanel.SessionObject as OPurchaseOrderReceipt;
                if (receipt != null)
                {
                    receipt.Attachments.Add(a);
                }
                panelgridAttachments.BindObjectToControls(receipt);
            }
        }

    }

    protected void checkRecoverable_CheckedChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.UpdateItemRecoverables();
        panel.ObjectPanel.BindObjectToControls(po);

    }

    protected void rdlRecoverableType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = panel.SessionObject as OPurchaseOrder;
        panel.ObjectPanel.BindControlsToObject(po);
        po.UpdateItemRecoverables();
        panel.ObjectPanel.BindObjectToControls(po);

    }

    protected void gridAdditionalAttachments_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string Attachment = "";
            Attachment = String.Format(Resources.Strings.GeneralDisplayTitleFontColor, e.Row.Cells[3].Text);

            if (e.Row.Cells[1].Text != "&nbsp;" && e.Row.Cells[2].Text != "&nbsp;")
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, Convert.ToDateTime(e.Row.Cells[2].Text).ToFriendlyString(), e.Row.Cells[1].Text);
            else
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, DateTime.Now.AddSeconds(-1).ToFriendlyString(), AppSession.User.ObjectName);

            e.Row.Cells[3].Text = Attachment;
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
        }
    }

    protected void buttonAddUsersEmails_Click(object sender, EventArgs e)
    {
        Window.Open("addusersemails.aspx?POID=" +
            HttpUtility.UrlEncode(Security.Encrypt(panel.SessionObject.ObjectID.ToString())));
        panel.FocusWindow = false;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <%--<link href="../../AAnacle.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../AAnacle.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />--%>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Purchase Order / Letter of Award"
            BaseTable="tPurchaseOrder" ShowWorkflowActionAsButtons="true" SaveButtonsVisible="false"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"
            OnValidate="panel_Validate"></web:object>
        <span style="display: none">
            <ui:UIButton runat="server" ID="repopulateCatalogueButton" OnClick="repopulateCatalogue_Click"
                CausesValidation="false" />
        </span>
        <div class="div-main">
            <ui:UITabStrip ID="tabObject" runat="server" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" BorderStyle="NotSet" Caption="Details"
                    meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" ObjectNameVisible="false"
                        ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false" />
                    <ui:UIPanel ID="panelDetails" runat="server" BorderStyle="NotSet" meta:resourcekey="panelDetailsResource1">
                        <ui:UIFieldLabel runat="server" ID="rfqNumber" PropertyName="RequestForQuotation.ObjectNumber"
                            Caption="Revised WJ Number" meta:resourcekey="RequestForQuotationObjectNumberResource1">
                            <ContextMenuButtons>
                                <ui:UIButton runat="server" ID="buttonViewWJ" ToolTip="View WJ" meta:resourcekey="viewWJFromPOResource1"
                                    Text="View WJ" ConfirmText="Please remember to save this Purchase Order before viewing the WJ.\n\nAre you sure you want to continue?"
                                    ImageUrl="~/images/view.gif" OnClick="buttonViewWJ_Click" />
                            </ContextMenuButtons>
                        </ui:UIFieldLabel>
                        <ui:UIPanel ID="panelCase" runat="server" BorderStyle="NotSet" meta:resourcekey="panelCaseResource1"
                            Visible="false">
                            <ui:UIFieldSearchableDropDownList ID="dropCase" runat="server" Caption="Case" ContextMenuAlwaysEnabled="True"
                                meta:resourcekey="dropCaseResource1" PropertyName="CaseID" SearchInterval="300">
                                <ContextMenuButtons>
                                    <ui:UIButton ID="buttonEditCase" runat="server" AlwaysEnabled="True" ConfirmText="Please remember to save this Purchase Order before editing the Case.\n\nAre you sure you want to continue?"
                                        ImageUrl="~/images/edit.gif" meta:resourcekey="buttonEditCaseResource1" OnClick="buttonEditCase_Click"
                                        Text="Edit Case" />
                                    <ui:UIButton ID="buttonViewCase" runat="server" AlwaysEnabled="True" ConfirmText="Please remember to save this Purchase Order before viewing the Case.\n\nAre you sure you want to continue?"
                                        ImageUrl="~/images/view.gif" meta:resourcekey="buttonViewCaseResource1" OnClick="buttonViewCase_Click"
                                        Text="View Case" />
                                </ContextMenuButtons>
                            </ui:UIFieldSearchableDropDownList>
                        </ui:UIPanel>
                        <ui:UIFieldCheckBox runat="server" ID="checkIsGroupPO" PropertyName="IsGroupPO" Caption="Group PO?"
                            Visible="False" Text="Yes, this is a group PO across multiple properties." OnCheckedChanged="checkIsGroupPO_CheckedChanged"
                            TextAlign="Right" meta:resourcekey="checkIsGroupPOResource1">
                        </ui:UIFieldCheckBox>
                        <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" ValidateRequiredField="True"
                            PropertyName="LocationID" OnSelectedIndexChanged="ddlLocation_SelectedIndexChanged"
                            meta:resourcekey="ddlLocationResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIHint runat="server" ID="CRVReminder" Visible="false" Font-Bold="true"></ui:UIHint>
                        <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" InternalControlWidth="95%"
                            MaxLength="255" meta:resourcekey="DescriptionResource1" PropertyName="Description"
                            ValidateRequiredField="True">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldListBox runat="server" ID="listLocations" PropertyName="GroupPOLocations"
                            Caption="Locations" ValidateRequiredField="True" meta:resourcekey="listLocationsResource1"></ui:UIFieldListBox>
                        <ui:UIFieldDropDownList runat="server" ID="dropCampaign" PropertyName="CampaignID"
                            Caption="Campaign" OnSelectedIndexChanged="dropCampaign_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <br />
                        <ui:UIFieldRadioList runat="server" Caption="Type" PropertyName="POType" ID="rdlPOType"
                            ValidateRequiredField="True" RepeatColumns="2" RepeatDirection="Vertical" OnSelectedIndexChanged="rdlPOType_SelectedIndexChanged"
                            meta:resourcekey="rdlPOTypeResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource10">LOA</asp:ListItem>
                                <asp:ListItem Value="1" Selected="True" meta:resourcekey="ListItemResource11">PO</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldCheckBox runat="server" ID="checkRecoverable" PropertyName="IsRecoverable"
                            Span="Half" Caption="Recoverable?" Text="Yes, this PO is recoverable" Hint="(Uncheck this if this PO is non-recoverable)"
                            OnCheckedChanged="checkRecoverable_CheckedChanged">
                        </ui:UIFieldCheckBox>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelPOAndLOA" BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="LOAPanel" BorderStyle="NotSet" meta:resourcekey="LOAPanelResource1">
                            <ui:UIFieldDropDownList runat="server" Caption="Trust" PropertyName="TrustID" ID="ddlTrust"
                                ValidateRequiredField="True" meta:resourcekey="ddlTrustResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="ddlOnBehalfOf" runat="server" Caption="LOA On Behalf Of"
                                PropertyName="LOAOnBehalfOfID" ValidateRequiredField="True" meta:resourcekey="ddlOnBehalfOfResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="ddlSignatory" runat="server" Caption="Signatory" PropertyName="SignatoryID"
                                ValidateRequiredField="True" meta:resourcekey="ddlSignatoryResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="POPanel" BorderStyle="NotSet" meta:resourcekey="POPanelResource1">
                            <ui:UIDialogBox runat="server" ID="dialogAdditionalAttachments" Title="Are you sure you want to proceed? Click OK to proceed, Cancel otherwise."
                                DialogWidth="520px" Button1AlwaysEnabled="true" Button1AutoClosesDialogBox="true"
                                Button1CausesValidation="false" Button1CommandName="Confirm" Button1Text="OK"
                                Button1ImageUrl="~/images/tick.gif" Button1FontBold="true" Button2AlwaysEnabled="true"
                                Button2AutoClosesDialogBox="true" Button2CausesValidation="false" Button2CommandName="Cancel"
                                Button2Text="Cancel" Button2ImageUrl="~/images/delete.gif" OnButtonClicked="dialogAdditionalAttachments_ButtonClicked">
                                <ui:UIPanel runat="server" ID="panelDialogAdditional" BorderStyle="NotSet">
                                    <ui:UIHint runat="server" ID="hintSendPOToVendor" Text="Please remember to save the Purchase Order before sending it to your Vendor.</br>
                                    Tick additional files below (if any) to send to the vendor">
                                    </ui:UIHint>
                                    <ui:UIGridView runat='server' ID="gridAdditionalAttachments" Caption="Attachments"
                                        ShowHeader="false" ShowFooter="false" AllowPaging="false" PropertyName="Attachments"
                                        CaptionWidth="120px" ShowCaption="false" KeyName="ObjectID" OnRowDataBound="gridAdditionalAttachments_RowDataBound">
                                        <Columns>
                                            <ui:UIGridViewBoundColumn PropertyName="CreatedUser" HeaderText="Created User">
                                            </ui:UIGridViewBoundColumn>
                                            <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Created Date Time">
                                            </ui:UIGridViewBoundColumn>
                                            <ui:UIGridViewBoundColumn PropertyName="Filename" HeaderText="File Name">
                                            </ui:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                    <ui:UIFieldTextBox runat="server" ID="textCCEmail" Caption="I would like to cc. the following email(s) addresses"
                                        CaptionPosition="Top" MaxLength="255" Hint="Please enter e-mail address in your cc list, you may want cc to mulitple e-mails by using ';' as seperator i.e.: peter@yahoo.com; mary@gmail.com">
                                    </ui:UIFieldTextBox>
                                    <ui:UIButton ID="buttonAddUsersEmails" runat="server" AlwaysEnabled="True" CausesValidation="False"
                                        ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddUsersEmailsResource1"
                                        Visible="false" OnClick="buttonAddUsersEmails_Click" Text="Add New Catalog" />
                                </ui:UIPanel>
                            </ui:UIDialogBox>
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr>
                                    <td style='width: 158px'>
                                    </td>
                                    <td>
                                        <ui:UIButton runat='server' ID="buttonSendPOToVendor" Text="Send Purchase Order to Vendor (via e-mail)"
                                            ImageUrl="~/images/email.png" OnClick="buttonSendPOToVendor_Click" ConfirmText="" />
                                        <br />
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldDropDownList runat="server" Caption="Deliver To" PropertyName="DeliveryToID"
                                ID="ddlDeliveryTo" ValidateRequiredField="True" meta:resourcekey="ddlDeliveryToResource1"
                                Hint="This is the company that appears in the Deliver To section of a purchase order.">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" Caption="Deliver To Contact Person" ID="DeliverToContactPersonID"
                                PropertyName="DeliverToContactPersonID" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="ddlBillTo" runat="server" Caption="Bill To" PropertyName="BillToID"
                                ValidateRequiredField="True" meta:resourcekey="ddlBillToResource1" Hint="This is the company that appears in the Bill To section of a purchase order.">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" Caption="Bill To Contact Person" ID="BillToContactPersonID"
                                PropertyName="BillToContactPersonID" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDateTime ID="DeliveryDate" runat="server" Caption="Delivery Date" PropertyName="DeliveryDate"
                                ValidateRequiredField="True" meta:resourcekey="DeliveryDateResource1" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                        </ui:UIPanel>
                        <ui:UIFieldDropDownList ID="ddlManagementCompany" runat="server" Caption="Management Company"
                            PropertyName="ManagementCompanyID" ValidateRequiredField="True" meta:resourcekey="ddlManagementCompanyResource1"
                            Hint="This is the company that appears at the top of your purchase order.">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="PaymentTerms" runat="server" Caption="Payment Terms" InternalControlWidth="95%"
                            meta:resourcekey="PaymentTermsResource1" PropertyName="PaymentTerms">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <br />
                    <br />
                    <ui:UIPanel ID="panelDetails2" runat="server" BorderStyle="NotSet" meta:resourcekey="panelDetails2Resource1">
                        <ui:UIFieldRadioList runat='server' ID="BudgetGroupID" Caption="Budget Group" RepeatColumns="0"
                            PropertyName="BudgetGroupID" ValidateRequiredField="True" meta:resourcekey="BudgetGroupIDResource1"
                            OnSelectedIndexChanged="BudgetGroupID_SelectedIndexChanged" TextAlign="Right">
                        </ui:UIFieldRadioList>
                        <ui:UIFieldRadioList ID="dropPurchaseTypeClassification" runat="server" RepeatColumns="0"
                            Caption="Transaction Type Group" PropertyName="TransactionTypeGroupID" meta:resourcekey="dropPurchaseTypeClassificationResource1"
                            OnSelectedIndexChanged="dropPurchaseTypeClassification_SelectedIndexChanged"
                            ValidateRequiredField="True" TextAlign="Right">
                        </ui:UIFieldRadioList>
                        <ui:UIFieldDropDownList ID="dropPurchaseType" runat="server" Caption="Transaction Type"
                            meta:resourcekey="dropPurchaseTypeResource1" OnSelectedIndexChanged="dropPurchaseType_SelectedIndexChanged"
                            PropertyName="PurchaseTypeID" ValidateRequiredField="True">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDateTime ID="DateOfOrder" runat="server" Caption="Date of PO" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateOfOrderResource1" OnDateTimeChanged="DateOfOrder_DateTimeChanged"
                            PropertyName="DateOfOrder" ShowDateControls="True" ValidateRequiredField="True">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldCheckBox ID="checkIsTermContract" runat="server" Caption="Term Contract?"
                            meta:resourcekey="checkIsTermContractResource1" OnCheckedChanged="checkIsTermContract_CheckedChanged"
                            PropertyName="IsTermContract" Text="Yes, this Purchase Order is for a term contract."
                            TextAlign="Right" Hint="(Uncheck this if it is not for a term contract)">
                        </ui:UIFieldCheckBox>
                        <ui:UIFieldLabel ID="labelTermContract" runat="server" Caption="Generated Contract"
                            ContextMenuAlwaysEnabled="True" DataFormatString="" meta:resourcekey="labelTermContractResource1"
                            PropertyName="GeneratedTermContract.ObjectNumber">
                            <ContextMenuButtons>
                                <ui:UIButton ID="buttonEditContract" runat="server" AlwaysEnabled="True" ConfirmText="Please remember to save this Purchase Order before editing the Contract.\n\nAre you sure you want to continue?"
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="buttonEditContractResource1" OnClick="buttonEditContract_Click"
                                    Text="Edit Contract" />
                                <ui:UIButton ID="buttonViewContract" runat="server" AlwaysEnabled="True" ConfirmText="Please remember to save this Purchase Order before viewing the Contract.\n\nAre you sure you want to continue?"
                                    ImageUrl="~/images/view.gif" meta:resourcekey="buttonViewContractResource1" OnClick="buttonViewContract_Click"
                                    Text="View Contract" />
                            </ContextMenuButtons>
                        </ui:UIFieldLabel>
                        <ui:UIFieldDateTime ID="DateRequired" runat="server" Caption="Date Required" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" OnDateTimeChanged="DateRequired_DateTimeChanged"
                            PropertyName="DateRequired" ShowDateControls="True" Span="Half" ValidateCompareField="True"
                            ValidateRequiredField="True" ValidationCompareControl="DateEnd" ValidationCompareOperator="LessThanEqual"
                            ValidationCompareType="Date">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime ID="DateEnd" runat="server" Caption="Date End" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateEndResource1" PropertyName="DateEnd"
                            ShowDateControls="True" Span="Half" ValidateCompareField="True" ValidateRequiredField="True"
                            ValidationCompareControl="DateRequired" ValidationCompareOperator="GreaterThanEqual"
                            ValidationCompareType="Date">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDropDownList ID="StoreID" runat="server" Caption="Store" Enabled="False"
                            meta:resourcekey="StoreIDResource1" PropertyName="StoreID" Span="Half">
                        </ui:UIFieldDropDownList>
                        <br />
                        <ui:UIFieldDateTime runat="server" ID="WorkCompletionDate" Caption="Work Completion Date"
                            PropertyName="WorkCompletionDate" meta:resourcekey="WorkCompletionDateResource1"
                            ShowDateControls="True">
                        </ui:UIFieldDateTime>
                        <ui:UIPanel runat="server" ID="panelHasWarranty" BorderStyle="NotSet">
                            <ui:UIFieldRadioList runat="server" ID="radioHasWarranty" PropertyName="HasWarranty"
                                Caption="Has Warranty?" OnSelectedIndexChanged="radioHasWarranty_SelectedIndexChanged"
                                ValidateRequiredField="true" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" Text="No, this PO / LOA has no warranty" Selected="True"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Yes, this PO / LOA has warranty"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="panelWarranty" BorderStyle="NotSet">
                                <asp:Label ID="labelWarrantyPeriod" runat="server" Text="Warranty Details*:" CssClass="field-required"
                                    Width="157px"></asp:Label>
                                <ui:UIFieldTextBox runat="server" ID="txtWarrantyPeriod" Caption="Warranty Period"
                                    PropertyName="WarrantyPeriod" ValidateDataTypeCheck="True" ValidationDataType="Integer"
                                    Span="Half" InternalControlWidth="100px" FieldLayout="Flow" ShowCaption="false">
                                </ui:UIFieldTextBox>
                                <ui:UIFieldDropDownList runat="server" ID="ddlWarrantyUnit" Caption="Warranty Unit"
                                    PropertyName="WarrantyUnit" Span="Half" InternalControlWidth="100px" FieldLayout="Flow"
                                    ShowCaption="false">
                                    <Items>
                                        <asp:ListItem Value="0">day(s)</asp:ListItem>
                                        <asp:ListItem Value="1">week(s)</asp:ListItem>
                                        <asp:ListItem Value="2">month(s)</asp:ListItem>
                                        <asp:ListItem Value="3">year(s)</asp:ListItem>
                                    </Items>
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldTextBox runat="server" ID="textWarranty" FieldLayout="Flow" InternalControlWidth="500px"
                                    Caption="Warranty" PropertyName="Warranty" MaxLength="255" ShowCaption="false">
                                </ui:UIFieldTextBox>
                            </ui:UIPanel>
                        </ui:UIPanel>
                        <br />
                        <br />
                        <br />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabVendor" runat="server" BorderStyle="NotSet" Caption="Vendor"
                    meta:resourcekey="tabVendorResource1">
                    <ui:UIPanel ID="panelTabVendor" runat="server" BorderStyle="NotSet" meta:resourcekey="panelTabVendorResource1">
                        <ui:UISeparator ID="sep1" runat="server" Caption="Vendor" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldSearchableDropDownList ID="ContractID" runat="server" Caption="Contract"
                            meta:resourcekey="ContractIDResource1" OnSelectedIndexChanged="ContractID_SelectedIndexChanged"
                            PropertyName="ContractID" SearchInterval="300">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldSearchableDropDownList ID="VendorID" runat="server" Caption="Vendor" meta:resourcekey="VendorIDResource1"
                            MaximumNumberOfItems="100" OnSelectedIndexChanged="VendorID_SelectedIndexChanged"
                            PropertyName="VendorID" SearchInterval="300" ValidateRequiredField="True">
                        </ui:UIFieldSearchableDropDownList>
                    </ui:UIPanel>
                    <ui:UIPanel ID="panelVendor1" runat="server" BorderStyle="NotSet" meta:resourcekey="panelVendorResource1">
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
                    </ui:UIPanel>
                    <ui:UIFieldTextBox ID="ContactEmail" runat="server" Caption="Email" InternalControlWidth="95%"
                        meta:resourcekey="ContactEmailResource1" PropertyName="ContactEmail" Span="Half">
                    </ui:UIFieldTextBox>
                    <ui:UIPanel ID="panelVendor2" runat="server" BorderStyle="NotSet" meta:resourcekey="panelVendorResource1">
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
                    <ui:UISeparator ID="UISeparator2" runat="server" Caption="Currency" meta:resourcekey="UISeparator2Resource1" />
                    <ui:UIPanel ID="panelCurrency" runat="server" BorderStyle="NotSet" meta:resourcekey="panelCurrencyResource1">
                        <ui:UIFieldDropDownList ID="dropCurrency" runat="server" Caption="Main Currency"
                            meta:resourcekey="dropCurrencyResource1" OnSelectedIndexChanged="dropCurrency_SelectedIndexChanged"
                            PropertyName="CurrencyID" ValidateRequiredField="True">
                        </ui:UIFieldDropDownList>
                        <table border="0" cellpadding="0" cellspacing="0" style="clear: both; width: 50%">
                            <tr class="field-required" style="height: 25px">
                                <td style="width: 150px">
                                    <asp:Label ID="labelExchangeRate" runat="server" meta:resourcekey="labelExchangeRateResource1">Exchange Rate*:</asp:Label>
                                </td>
                                <td>
                                    <asp:Label ID="labelER1" runat="server" meta:resourcekey="labelER1Resource1">1</asp:Label>
                                    <ui:UIFieldLabel ID="labelERThisCurrency" runat="server" DataFormatString="" FieldLayout="Flow"
                                        InternalControlWidth="20px" meta:resourcekey="labelERThisCurrencyResource1" PropertyName="Currency.ObjectName"
                                        ShowCaption="False">
                                    </ui:UIFieldLabel>
                                    <asp:Label ID="labelEREquals" runat="server" meta:resourcekey="labelEREqualsResource1">is equal to</asp:Label>
                                    <ui:UIFieldTextBox ID="textForeignToBaseExchangeRate" runat="server" Caption="Exchange Rate"
                                        FieldLayout="Flow" InternalControlWidth="60px" meta:resourcekey="textForeignToBaseExchangeRateResource1"
                                        OnTextChanged="textForeignToBaseExchangeRate_TextChanged" PropertyName="ForeignToBaseExchangeRate"
                                        ShowCaption="False" Span="Half" ValidateDataTypeCheck="True" ValidateRequiredField="True"
                                        ValidationDataType="Currency">
                                    </ui:UIFieldTextBox>
                                    <asp:Label ID="labelERBaseCurrency" runat="server" meta:resourcekey="labelERBaseCurrencyResource1"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabTerms" runat="server" BorderStyle="NotSet" Caption="Terms" Visible="False"
                    meta:resourcekey="tabTermsResource1">
                    <ui:UIPanel ID="panelTerms" runat="server" BorderStyle="NotSet" meta:resourcekey="panelTermsResource1">
                        <ui:UISeparator ID="Terms" runat="server" Caption="Terms" meta:resourcekey="TermsResource2" />
                        <ui:UIFieldTextBox ID="FreightTerms" runat="server" Caption="Freight Terms" InternalControlWidth="95%"
                            meta:resourcekey="FreightTermsResource1" PropertyName="FreightTerms" Rows="3"
                            TextMode="MultiLine">
                        </ui:UIFieldTextBox>
                        <br />
                        <br />
                        <br />
                        <ui:UISeparator ID="UISeparator1" runat="server" Caption="Address" meta:resourcekey="UISeparator1Resource1" />
                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%">
                            <tr>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel1" runat="server" BorderStyle="NotSet" meta:resourcekey="Panel1Resource1">
                                        <asp:Label ID="Label1" runat="server" Font-Bold="True" meta:resourceKey="Label1Resource1"
                                            Text="Ship To:"></asp:Label>
                                        <br />
                                        <ui:UIFieldTextBox ID="ShipToAddress" runat="server" Caption="Address" InternalControlWidth="95%"
                                            meta:resourcekey="ShipToAddressResource1" PropertyName="ShipToAddress" Rows="4"
                                            TextMode="MultiLine">
                                        </ui:UIFieldTextBox>
                                        <ui:UIFieldTextBox ID="ShipToAttention" runat="server" Caption="Attention" InternalControlWidth="95%"
                                            meta:resourcekey="ShipToAttentionResource1" PropertyName="ShipToAttention">
                                        </ui:UIFieldTextBox>
                                    </ui:UIPanel>
                                </td>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel2" runat="server" BorderStyle="NotSet" meta:resourcekey="Panel2Resource1">
                                        <asp:Label ID="Label2" runat="server" Font-Bold="True" meta:resourceKey="Label2Resource1"
                                            Text="Bill To:"></asp:Label>
                                        <br />
                                        <ui:UIFieldTextBox ID="BillToAddress" runat="server" Caption="Address" InternalControlWidth="95%"
                                            meta:resourcekey="BillToAddressResource1" PropertyName="BillToAddress" Rows="4"
                                            TextMode="MultiLine">
                                        </ui:UIFieldTextBox>
                                        <ui:UIFieldTextBox ID="BillToAttention" runat="server" Caption="Attention" InternalControlWidth="95%"
                                            meta:resourcekey="BillToAttentionResource1" PropertyName="BillToAttention">
                                        </ui:UIFieldTextBox>
                                    </ui:UIPanel>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabLineItems" runat="server" BorderStyle="NotSet" Caption="Line Items"
                    meta:resourcekey="tabLineItemsResource1">
                    <ui:UIPanel ID="PurchaseOrderItemPanel" runat="server" BorderStyle="NotSet" meta:resourcekey="PurchaseOrderItemPanelResource1">
                        <ui:UIPanel runat="server" ID="PurchaseOrderItemAddButtonPanel">
                            <ui:UIButton ID="buttonAddMaterialItems" runat="server" CausesValidation="False"
                                ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddMaterialItemsResource1"
                                OnClick="buttonAddMaterialItems_Click" onpopupreturned="addMaterialItems_PopupReturned"
                                Text="Add Multiple Inventory Items" />
                            <ui:UIButton ID="buttonAddFixedRateItems" runat="server" CausesValidation="False"
                                ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddFixedRateItemsResource1"
                                OnClick="buttonAddFixedRateItems_Click" Text="Add Multiple Service Items" />
                            <ui:UIButton ID="buttonItemsAdded" runat="server" CausesValidation="False" meta:resourcekey="buttonItemsAddedResource1"
                                OnClick="buttonItemsAdded_Click" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIFieldRadioList runat="server" ID="radioTaxCodePerLineItem" Caption="Tax" PropertyName="HasTaxCodePerLineItem"
                            OnSelectedIndexChanged="radioTaxCodePerLineItem_SelectedIndexChanged">
                            <Items>
                                <asp:ListItem Value="1" Text="Yes, a different tax code can be specified per line item."></asp:ListItem>
                                <asp:ListItem Value="0" Text="No, the entire PO is subjected to the default vendor’s tax code."
                                    Selected="True"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIGridView ID="PurchaseOrderItems" runat="server" Caption="Items" DataKeyNames="ObjectID"
                            GridLines="Both" keyname="ObjectID" meta:resourcekey="PurchaseOrderItemsResource1"
                            pagingenabled="True" PropertyName="PurchaseOrderItems" RowErrorColor="" ShowFooter="True"
                            SortExpression="ItemNumber" Style="clear: both;" Width="100%" BindObjectsToRows="true"
                            OnRowDataBound="PurchaseOrderItems_RowDataBound" OnAction="PurchaseOrderItems_Action">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                    meta:resourcekey="UIGridViewColumnResource1" AlwaysEnabled="true">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="Number" meta:resourcekey="UIGridViewColumnResource3"
                                    PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="ItemTypeText" HeaderText="Type" meta:resourcekey="UIGridViewColumnResource4"
                                    PropertyName="ItemTypeText" ResourceAssemblyName="" SortExpression="ItemTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="ItemDescription" HeaderText="Description" meta:resourcekey="UIGridViewColumnResource5"
                                    PropertyName="ItemDescription" ResourceAssemblyName="" SortExpression="ItemDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Unit of Measure"
                                    meta:resourcekey="UIGridViewColumnResource6" PropertyName="UnitOfMeasure.ObjectName"
                                    ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="ReceiptModeText" HeaderText="Receipt Mode" meta:resourcekey="UIGridViewBoundColumnResource1"
                                    PropertyName="ReceiptModeText" ResourceAssemblyName="" SortExpression="ReceiptModeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Currency.ObjectName" HeaderText="Currency" meta:resourcekey="UIGridViewBoundColumnResource2"
                                    PropertyName="Currency.ObjectName" ResourceAssemblyName="" SortExpression="Currency.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="UnitPriceInSelectedCurrency" HeaderText="Unit Price"
                                    meta:resourcekey="UIGridViewColumnResource7" PropertyName="UnitPriceInSelectedCurrency"
                                    ResourceAssemblyName="" SortExpression="UnitPriceInSelectedCurrency">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="UnitPrice" HeaderText="Unit Price&lt;br/&gt;(Base Currency)"
                                    HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="UnitPrice"
                                    ResourceAssemblyName="" SortExpression="UnitPrice">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="QuantityOrdered" DataFormatString="{0:#,##0.00##}"
                                    HeaderText="Quantity" meta:resourcekey="UIGridViewColumnResource8" PropertyName="QuantityOrdered"
                                    ResourceAssemblyName="" SortExpression="QuantityOrdered">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Subtotal" DataFormatString="{0:c}" FooterAggregate="Sum"
                                    HeaderText="Subtotal&lt;br/&gt;(Base Currency)" HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource4"
                                    PropertyName="Subtotal" ResourceAssemblyName="" SortExpression="Subtotal">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="RecoverableAmount" DataFormatString="{0:c}"
                                    HeaderText="Recoverable Amount&lt;br/&gt;(Base Currency)" HtmlEncode="False"
                                    PropertyName="RecoverableAmount" ResourceAssemblyName="" SortExpression="RecoverableAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="QuantityDelivered" DataFormatString="{0:#,##0.00##}"
                                    HeaderText="Quantity Delivered" meta:resourcekey="UIGridViewColumnResource10"
                                    PropertyName="QuantityDelivered" ResourceAssemblyName="" SortExpression="QuantityDelivered">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Tax Code">
                                    <HeaderStyle Width="135px" />
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="TaxCodeID" ShowCaption="false" PropertyName="TaxCodeID"
                                            Span="Half" InternalControlWidth="130px" FieldLayout="Flow" OnSelectedIndexChanged="TaxCodeID_SelectedIndexChanged"
                                            ValidateRequiredField="true">
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Tax Amount">
                                    <HeaderStyle Width="125px" />
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="TaxAmount" ShowCaption="false" PropertyName="TaxAmount"
                                            Span="Half" InternalControlWidth="120px" FieldLayout="Flow" DataFormatString="{0:#,##0.00##}"
                                            ValidateRequiredField="true">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditRFQ" ImageUrl="~/images/edit.gif"
                                    AlwaysEnabled="true" ConfirmText="Are you sure you wish to open this Work Justification for editing? Please remember to save the Purchase Order, otherwise changes that you have made will be lost.">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewRFQ" ImageUrl="~/images/view.gif"
                                    AlwaysEnabled="true" ConfirmText="Are you sure you wish to open this Work Justification for viewing? Please remember to save the Purchase Order, otherwise changes that you have made will be lost.">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="CopiedFromObjectNumber" HeaderText="Copied From"
                                    meta:resourcekey="UIGridViewColumnResource11" PropertyName="CopiedFromObjectNumber"
                                    ResourceAssemblyName="" SortExpression="CopiedFromObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <%--<ui:UIGridViewTemplateColumn HeaderText="Copied From" meta:resourcekey="UIGridViewColumnResource11">
                                    <HeaderStyle Font-Bold="true" />
                                    <ItemTemplate>
                                        <ui:UIGridView runat='server' ID="gridRequestForQuotationItems" PropertyName="CopiedFromRequestForQuotations"
                                            SortExpression="ObjectNumber ASC" AllowPaging="false" ShowCaption="false" FieldLayout="Flow"
                                            EnableTheming="false" DataKeyNames="ObjectID" CheckBoxColumnVisible="false" ShowHeader="false">
                                            <Columns>
                                                <cc1:UIGridViewBoundColumn DataField="ObjectID" HeaderText="" meta:resourcekey="UIGridViewBoundColumnResource20"
                                                    PropertyName="ObjectID" ResourceAssemblyName="" SortExpression="ObjectID">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditRFQ" ImageUrl="~/images/edit.gif"
                                                    AlwaysEnabled="true" ConfirmText="Are you sure you wish to open this Work Justification for editing? Please remember to save the Purchase Order, otherwise changes that you have made will be lost.">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </ui:UIGridViewButtonColumn>
                                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewRFQ" ImageUrl="~/images/view.gif"
                                                    AlwaysEnabled="true" ConfirmText="Are you sure you wish to open this Work Justification for viewing? Please remember to save the Purchase Order, otherwise changes that you have made will be lost.">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </ui:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="" meta:resourcekey="UIGridViewBoundColumnResource20"
                                                    PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>--%>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="PurchaseOrderItem_Panel" runat="server" BorderStyle="NotSet"
                            meta:resourcekey="PurchaseOrderItem_PanelResource1">
                            <web:subpanel ID="PurchaseOrderItem_SubPanel" runat="server" GridViewID="PurchaseOrderItems"
                                MultiSelectColumnNames="ItemNumber,ItemType,FixedRateID,CatalogueID,UnitPrice,QuantityOrdered"
                                OnPopulateForm="PurchaseOrderItem_SubPanel_PopulateForm" OnRemoved="PurchaseOrderItem_SubPanel_Removed"
                                OnValidateAndUpdate="PurchaseOrderItem_SubPanel_ValidateAndUpdate" />
                            <ui:UIPanel runat="server" ID="PurchaseOrderItemDetailsPanel">
                                <ui:UIFieldDropDownList ID="ItemNumber" runat="server" Caption="Item Number " meta:resourcekey="ItemNumberResource1"
                                    PropertyName="ItemNumber" Span="Half" ValidateRequiredField="True">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldRadioList ID="ItemType" runat="server" Caption="Item Type" meta:resourcekey="ItemTypeResource1"
                                    OnSelectedIndexChanged="ItemType_SelectedIndexChanged" PropertyName="ItemType"
                                    RepeatColumns="0" TextAlign="Right" ValidateRequiredField="True" Span="Full">
                                    <Items>
                                        <asp:ListItem meta:resourceKey="ListItemResource1" Text="Inventory" Value="0"></asp:ListItem>
                                        <asp:ListItem meta:resourceKey="ListItemResource2" Text="Service" Value="1"></asp:ListItem>
                                        <asp:ListItem meta:resourceKey="ListItemResource3" Text="Others" Value="2"></asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <br />
                                <ui:UIButton ID="buttonAddCatalog" runat="server" AlwaysEnabled="True" CausesValidation="False"
                                    ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddCatalogResource1" OnClick="buttonAddCatalog_Click"
                                    Text="Add New Catalog" />
                                <ui:UIFieldTreeList ID="CatalogueID" runat="server" Caption="Catalog" meta:resourcekey="CatalogueIDResource1"
                                    OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater" OnSelectedNodeChanged="CatalogueID_SelectedNodeChanged"
                                    PropertyName="CatalogueID" ShowCheckBoxes="None" TreeValueMode="SelectedNode"
                                    ValidateRequiredField="True">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate" meta:resourcekey="FixedRateIDResource1"
                                    OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater" OnSelectedNodeChanged="FixedRateID_SelectedNodeChanged"
                                    PropertyName="FixedRateID" ShowCheckBoxes="None" TreeValueMode="SelectedNode"
                                    ValidateRequiredField="True">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldLabel ID="UnitOfMeasure" runat="server" Caption="Unit of Measure" DataFormatString=""
                                    meta:resourcekey="UnitOfMeasureResource1" PropertyName="Catalogue.UnitOfMeasure.ObjectName">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel ID="UnitOfMeasure2" runat="server" Caption="Unit of Measure" DataFormatString=""
                                    meta:resourcekey="UnitOfMeasure2Resource1" PropertyName="FixedRate.UnitOfMeasure.ObjectName">
                                </ui:UIFieldLabel>
                                <ui:UIFieldTextBox ID="ItemDescription" runat="server" Caption="Description" InternalControlWidth="95%"
                                    MaxLength="2000" meta:resourcekey="ItemDescriptionResource1" PropertyName="ItemDescription"
                                    ValidateRequiredField="True">
                                </ui:UIFieldTextBox>
                                <ui:UIFieldTextBox ID="AdditionalDescription" runat="server" Caption="Additional Description"
                                    PropertyName="AdditionalDescription" MaxLength="1000" ValidateRequiredField="true">
                                </ui:UIFieldTextBox>
                                <ui:UIFieldDropDownList ID="UnitOfMeasureID" runat="server" Caption="Unit of Measure"
                                    meta:resourcekey="UnitOfMeasureIDResource1" PropertyName="UnitOfMeasureID" ValidateRequiredField="True">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldRadioList ID="radioReceiptMode" runat="server" Caption="Receipt Mode"
                                    meta:resourcekey="radioReceiptModeResource1" OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged"
                                    PropertyName="ReceiptMode" TextAlign="Right">
                                    <Items>
                                        <asp:ListItem meta:resourcekey="ListItemResource4" Value="0">Receive by Quantity</asp:ListItem>
                                        <asp:ListItem meta:resourcekey="ListItemResource5" Value="1">Receive by Dollar Amount</asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="PurchaseOrderItemAmountPanel">
                                <ui:UIFieldTextBox ID="UnitPrice" runat="server" Caption="Unit Price" InternalControlWidth="95%"
                                    meta:resourcekey="UnitPriceResource1" PropertyName="UnitPriceInSelectedCurrency"
                                    Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True" ValidateRequiredField="True"
                                    ValidationDataType="Currency" ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                    ValidationRangeType="Currency">
                                </ui:UIFieldTextBox>
                                <ui:UIFieldTextBox ID="QuantityOrdered" runat="server" Caption="Quantity" InternalControlWidth="95%"
                                    meta:resourcekey="QuantityOrderedResource1" PropertyName="QuantityOrdered" Span="Half"
                                    ValidateDataTypeCheck="True" ValidateRangeField="True" ValidateRequiredField="True"
                                    ValidationDataType="Currency" ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                    ValidationRangeType="Currency">
                                </ui:UIFieldTextBox>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panelChargeRecoverableAmount" BorderStyle="NotSet">
                                <%--<ui:UIFieldTextBox runat="server" ID="ChargeAmount" Caption="Charge Amount" PropertyName="ChargeAmount" Span="Half" ValidateRequiredField="true"></ui:UIFieldTextBox>--%>
                                <ui:UIFieldTextBox runat="server" ID="RecoverableAmount" Caption="Recoverable Amount"
                                    PropertyName="RecoverableAmountInSelectedCurrency" Span="Half" ValidateDataTypeCheck="True"
                                    ValidateRangeField="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                    ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Currency">
                                </ui:UIFieldTextBox>
                            </ui:UIPanel>
                        </ui:UIObjectPanel>
                        <br />
                        <ui:UIHint ID="hintRFQToPOPolicy" runat="server" ImageUrl="~/images/error.gif" meta:resourcekey="hintRFQToPOPolicyResource1"></ui:UIHint>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabBudget" runat="server" BorderStyle="NotSet" Caption="Budget"
                    meta:resourcekey="tabBudgetResource1">
                    <ui:UIFieldRadioList ID="radioBudgetDistributionMode" runat="server" Caption="Budget Distribution"
                        meta:resourcekey="radioBudgetDistributionModeResource1" OnSelectedIndexChanged="radioBudgetDistributionMode_SelectedIndexChanged"
                        PropertyName="BudgetDistributionMode" TextAlign="Right" ValidateRequiredField="True">
                        <Items>
                            <asp:ListItem meta:resourcekey="ListItemResource6" Value="0">By entire Purchase
                            Order</asp:ListItem>
                            <asp:ListItem meta:resourcekey="ListItemResource7" Value="1">By individual
                            Purchase Order items</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <br />
                    <ui:UIButton runat="server" ID="buttonAddBudget" Text="Add Budget" ImageUrl="~/images/add.gif"
                        OnClick="buttonAddBudget_Click" meta:resourcekey="buttonAddBudgetResource1" Visible="false" />
                    <br />
                    <ui:UIGridView ID="gridBudget" runat="server" Caption="Budgets" DataKeyNames="ObjectID"
                        GridLines="Both" BindObjectsToRows="True" meta:resourcekey="gridBudgetResource1"
                        PageSize="500" PropertyName="PurchaseBudgets" RowErrorColor="" ShowFooter="True"
                        SortExpression="ItemNumber, StartDate, Budget.ObjectName, Account.Path" Style="clear: both;"
                        OnRowDataBound="gridBudget_RowDataBound">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource3" />
                            <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource4" />
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
                            <ui:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="Number" meta:resourcekey="UIGridViewBoundColumnResource5"
                                PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Budget.ObjectName" HeaderText="Budget" meta:resourcekey="UIGridViewBoundColumnResource6"
                                PropertyName="Budget.ObjectName" ResourceAssemblyName="" SortExpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" meta:resourcekey="UIGridViewBoundColumnResource7"
                                PropertyName="Account.Path" ResourceAssemblyName="" SortExpression="Account.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Account.AccountCode" HeaderText="Account Code"
                                meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="Account.AccountCode"
                                ResourceAssemblyName="" SortExpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="StartDate" DataFormatString="{0:MMM-yyyy}" HeaderText="Accrual Date"
                                meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="StartDate" ResourceAssemblyName=""
                                SortExpression="StartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Amount" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <ui:UIFieldTextBox ID="textAmount" runat="server" Caption="Amount" DataFormatString="{0:n}"
                                        FieldLayout="Flow" InternalControlWidth="80px" PropertyName="Amount" ShowCaption="False"
                                        ValidateRangeField="True" ValidateRequiredField="True" ValidationRangeMin="0"
                                        ValidationRangeMinInclusive="False" meta:resourcekey="textAmountResource1">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="panelBudget" runat="server" BorderStyle="NotSet" meta:resourcekey="panelBudgetResource1">
                        <web:subpanel ID="subpanelBudget" runat="server" GridViewID="gridBudget" OnPopulateForm="subpanelBudget_PopulateForm"
                            OnRemoved="subpanelBudget_Removed" OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate"
                            UpdatePopupVisible="true" />
                        <%--<ui:UIFieldDropDownList ID="dropItemNumber" runat="server" Caption="Item Number"
                            meta:resourcekey="dropItemNumberResource1" PropertyName="ItemNumber" ValidateRequiredField="True">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList ID="dropBudget" runat="server" Caption="Budget" meta:resourcekey="dropBudgetResource1"
                            OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" PropertyName="BudgetID"
                            ValidateRequiredField="True">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDateTime ID="dateStartDate" runat="server" Caption="Start Date" meta:resourcekey="dateStartDateResource1"
                            OnDateTimeChanged="dateStartDate_DateTimeChanged" PropertyName="StartDate" ShowDateControls="True" SelectMonthYear="true"
                            Span="Half" ValidateCompareField="True" ValidateRequiredField="True" ValidationCompareControl="dateEndDate"
                            ValidationCompareOperator="LessThanEqual" ValidationCompareType="Date">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTreeList ID="treeAccount" runat="server" Caption="Account" meta:resourcekey="treeAccountResource1"
                            OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" PropertyName="AccountID"
                            ShowCheckBoxes="None" TreeValueMode="SelectedNode" ValidateRequiredField="True">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox ID="textAmount" runat="server" Caption="Amount" InternalControlWidth="95%"
                            meta:resourcekey="textAmountResource1" PropertyName="Amount" Span="Half" ValidateRequiredField="True"
                            ValidationRangeMin="1" ValidationRangeType="Currency">
                        </ui:UIFieldTextBox>--%>
                        <ui:UIFieldDropDownList runat="server" ID="dropAddBudgetItemNumber" Caption="Line Number"
                            PropertyName="ItemNumber" ValidateRequiredField="True" meta:resourcekey="dropAddBudgetItemNumberResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropAddBudget" Caption="Budget" ValidateRequiredField="True"
                            PropertyName="BudgetID" OnSelectedIndexChanged="dropAddBudget_SelectedIndexChanged"
                            meta:resourcekey="dropAddBudgetResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDateTime runat="server" ID="dateAddBudgetStartDate" Caption="Start Date"
                            PropertyName="StartDate" ValidateRequiredField="True" SelectMonthYear="true"
                            meta:resourcekey="dateAddBudgetStartDateResource1" ShowDateControls="True">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="dateAddBudgetEndDate" Caption="End Date" ValidateRequiredField="True"
                            PropertyName="EndDate" meta:resourcekey="dateAddBudgetEndDateResource1" SelectMonthYear="true"
                            ShowDateControls="True">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTreeList runat='server' ID="treeAddBudgetAccounts" Caption="Account" ValidateRequiredField="True"
                            PropertyName="AccountID" OnAcquireTreePopulater="treeAddBudgetAccounts_AcquireTreePopulater"
                            meta:resourcekey="treeAddBudgetAccountsResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID="textAddBudgetAmount" Caption="Amount" ValidateRequiredField="True"
                            ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField='True'
                            PropertyName="Amount" ValidationRangeMin="0" ValidationRangeMinInclusive="True"
                            ValidationRangeType="Currency" InternalControlWidth="95%" meta:resourcekey="textAddBudgetAmountResource1">
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
                            <ui:UIGridViewBoundColumn DataField="Budget.ObjectName" HeaderText="Budget" meta:resourcekey="UIGridViewBoundColumnResource13"
                                PropertyName="Budget.ObjectName" ResourceAssemblyName="" SortExpression="Budget.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="BudgetPeriod.ObjectName" HeaderText="Budget Period"
                                meta:resourcekey="UIGridViewBoundColumnResource14" PropertyName="BudgetPeriod.ObjectName"
                                ResourceAssemblyName="" SortExpression="BudgetPeriod.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="ViewBudget"
                                ImageUrl="~/images/printer.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="Account.ObjectName" HeaderText="Account" meta:resourcekey="UIGridViewBoundColumnResource15"
                                PropertyName="Account.ObjectName" ResourceAssemblyName="" SortExpression="Account.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Account.AccountCode" HeaderText="Account Code"
                                meta:resourcekey="UIGridViewBoundColumnResource16" PropertyName="Account.AccountCode"
                                ResourceAssemblyName="" SortExpression="Account.AccountCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalAvailableAdjusted" DataFormatString="{0:c}"
                                FooterAggregate="Sum" HeaderText="Total After Adjustments" meta:resourcekey="UIGridViewBoundColumnResource17"
                                PropertyName="TotalAvailableAdjusted" ResourceAssemblyName="" SortExpression="TotalAvailableAdjusted">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalAvailableBeforeSubmission" DataFormatString="{0:c}"
                                FooterAggregate="Sum" HeaderText="Total Before Submission" meta:resourcekey="UIGridViewBoundColumnResource18"
                                PropertyName="TotalAvailableBeforeSubmission" ResourceAssemblyName="" SortExpression="TotalAvailableBeforeSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalAvailableAtSubmission" DataFormatString="{0:c}"
                                FooterAggregate="Sum" HeaderText="Total At Submission" meta:resourcekey="UIGridViewBoundColumnResource19"
                                PropertyName="TotalAvailableAtSubmission" ResourceAssemblyName="" SortExpression="TotalAvailableAtSubmission">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalAvailableAfterApproval" DataFormatString="{0:c}"
                                FooterAggregate="Sum" HeaderText="Total After Approval" meta:resourcekey="UIGridViewBoundColumnResource20"
                                PropertyName="TotalAvailableAfterApproval" ResourceAssemblyName="" SortExpression="TotalAvailableAfterApproval">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <asp:LinkButton runat="server" ID="buttonAddBudgetHidden" meta:resourcekey="buttonAddBudgetHiddenResource1" />
                    <asp:ModalPopupExtender runat='server' ID="popupAddBudget" PopupControlID="objectPanelAddBudget"
                        BackgroundCssClass="modalBackground" TargetControlID="buttonAddBudgetHidden"
                        DynamicServicePath="" Enabled="True">
                    </asp:ModalPopupExtender>
                    <ui:UIObjectPanel runat="server" ID="objectPanelAddBudget" Width="400px" BackColor="White"
                        BorderStyle="NotSet" meta:resourcekey="objectPanelAddBudgetResource1">
                        <div style="padding: 8px 8px 8px 8px">
                            <ui:UISeparator ID="Uiseparator3" runat="server" Caption="Add Budget" meta:resourcekey="Uiseparator3Resource1" />
                            <%--<ui:UIFieldDropDownList runat="server" ID="dropAddBudgetItemNumber" Caption="Line Number"
                                ValidateRequiredField="True" meta:resourcekey="dropAddBudgetItemNumberResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropAddBudget" Caption="Budget" ValidateRequiredField="True"
                                OnSelectedIndexChanged="dropAddBudget_SelectedIndexChanged" meta:resourcekey="dropAddBudgetResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDateTime runat="server" ID="dateAddBudgetStartDate" Caption="Start Date"
                                ValidateRequiredField="True" SelectMonthYear="true" meta:resourcekey="dateAddBudgetStartDateResource1"
                                ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="dateAddBudgetEndDate" Caption="End Date" ValidateRequiredField="True"
                                meta:resourcekey="dateAddBudgetEndDateResource1" SelectMonthYear="true" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTreeList runat='server' ID="treeAddBudgetAccounts" Caption="Account" ValidateRequiredField="True"
                                OnAcquireTreePopulater="treeAddBudgetAccounts_AcquireTreePopulater" meta:resourcekey="treeAddBudgetAccountsResource1"
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox runat='server' ID="textAddBudgetAmount" Caption="Amount" ValidateRequiredField="True"
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField='True'
                                ValidationRangeMin="0" ValidationRangeMinInclusive="False" ValidationRangeType="Currency"
                                InternalControlWidth="95%" meta:resourcekey="textAddBudgetAmountResource1">
                            </ui:UIFieldTextBox>--%>
                            <br />
                            <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray;
                                width: 100%">
                                <tr>
                                    <td style='width: 120px'>
                                    </td>
                                    <td>
                                        <ui:UIButton runat='server' ID="buttonAddBudgetConfirm" Text="Add" ImageUrl="~/images/add.gif"
                                            OnClick="buttonAddBudgetConfirm_Click" meta:resourcekey="buttonAddBudgetConfirmResource1" />
                                        <ui:UIButton runat='server' ID="buttonAddBudgetCancel" Text="Cancel" ImageUrl="~/images/delete.gif"
                                            OnClick="buttonAddBudgetCancel_Click" CausesValidation='False' meta:resourcekey="buttonAddBudgetCancelResource1" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabPaymentSchedule" runat="server" BorderStyle="NotSet" Caption="Payment Schedule"
                    Visible="false" meta:resourcekey="tabPaymentScheduleResource1">
                    <ui:UIPanel runat="server" ID="PaymentSchedule_Panel" BorderStyle="NotSet" meta:resourcekey="PaymentSchedule_PanelResource1">
                        <ui:UIButton runat="server" ID="btnDistributeAmount" Width="120px" Text="Auto-Distribute"
                            ConfirmText="This action will remove all the existing payment schedule items. Are you sure you want to continue?"
                            OnClick="btnDistributeAmount_Click" ImageUrl="~/images/add.gif" meta:resourcekey="btnDistributeAmountResource1" />
                        <br />
                        <asp:LinkButton runat="server" ID="buttonHidden" meta:resourcekey="buttonHiddenResource1"></asp:LinkButton>
                        <asp:ModalPopupExtender ID="modalDistributeAmountPopup" runat="server" BackgroundCssClass="modalBackground"
                            PopupControlID="panelDistributeAmountPopup" TargetControlID="buttonHidden" DynamicServicePath=""
                            Enabled="True">
                        </asp:ModalPopupExtender>
                        <ui:UIObjectPanel runat="server" ID="panelDistributeAmountPopup" CssClass="modalPopup"
                            Visible="False" BorderStyle="NotSet" meta:resourcekey="panelDistributeAmountPopupResource1">
                            <ui:UIFieldLabel runat="server" ID="lblErrorMessage" ForeColor="Red" Visible="False"
                                DataFormatString="" meta:resourcekey="lblErrorMessageResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldDateTime runat="server" ID="PaymentSchedule_StartDate" Caption="Start Date"
                                ValidateRequiredField="True" meta:resourcekey="PaymentSchedule_StartDateResource1"
                                ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="PatmentSchedule_EndDate" Caption="End Date"
                                ValidateRequiredField="True" meta:resourcekey="PatmentSchedule_EndDateResource1"
                                ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTextBox runat="server" ID="txtPaymentFrequency" Caption="Payment Frequency"
                                ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="txtPaymentFrequencyResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIButton runat="server" ID="btnDistribute" Text="Distribute" OnClick="btnDistribute_Click"
                                meta:resourcekey="btnDistributeResource1" />
                            <ui:UIButton runat="server" ID="btnCancelDistribute" Text="Cancel" OnClick="btnCancelDistribute_Click"
                                meta:resourcekey="btnCancelDistributeResource1" />
                        </ui:UIObjectPanel>
                        <ui:UIFieldRadioList runat="server" ID="rdlPaidByPercentage" CaptionWidth="1px" RepeatColumns="2"
                            RepeatDirection="Vertical" PropertyName="IsPaymentPaidByPercentage" meta:resourcekey="rdlPaidByPercentageResource1"
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource8">By Percentage</asp:ListItem>
                                <asp:ListItem Value="0" Selected="True" meta:resourcekey="ListItemResource9">By Amount</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIGridView ID="grid_PaymentSchedules" runat="server" Caption="Items" DataKeyNames="ObjectID"
                            GridLines="Both" keyname="ObjectID" pagingenabled="True" PropertyName="PurchaseOrderPaymentSchedules"
                            RowErrorColor="" ShowFooter="True" SortExpression="DateOfPayment" Style="clear: both;"
                            Width="100%" meta:resourcekey="grid_PaymentSchedulesResource1">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource5" />
                                <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                    meta:resourcekey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="DateOfPayment" HeaderText="Date Of Payment"
                                    DataFormatString="{0:dd-MMM-yyyy}" PropertyName="DateOfPayment" ResourceAssemblyName=""
                                    SortExpression="DateOfPayment" meta:resourcekey="UIGridViewBoundColumnResource10">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="PercentageToPay" HeaderText="Percentage to Pay"
                                    PropertyName="PercentageToPay" ResourceAssemblyName="" SortExpression="PercentageToPay"
                                    DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewBoundColumnResource11">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="AmountToPay" HeaderText="Amount To Pay" PropertyName="AmountToPay"
                                    ResourceAssemblyName="" SortExpression="AmountToPay" DataFormatString="{0:#,##0.00}"
                                    meta:resourcekey="UIGridViewBoundColumnResource12">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Description" HeaderText="Description" PropertyName="Description"
                                    ResourceAssemblyName="" meta:resourcekey="UIGridViewBoundColumnResource21" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="objectPanel_PaymentSchedules" runat="server" BorderStyle="NotSet"
                            meta:resourcekey="objectPanel_PaymentSchedulesResource1">
                            <web:subpanel ID="subpanel_PaymentSchedules" runat="server" GridViewID="grid_PaymentSchedules"
                                OnPopulateForm="subpanel_PaymentSchedules_PopulateForm" OnValidateAndUpdate="subpanel_PaymentSchedules_ValidateAndUpdate" />
                            <ui:UIFieldDateTime runat="server" ID="DateOfPayment" Caption="Date of Payment" PropertyName="DateOfPayment"
                                ValidateRequiredField="True" meta:resourcekey="DateOfPaymentResource1" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTextBox runat="server" ID="PercentageToPay" Visible="False" Caption="Percentage to pay"
                                PropertyName="PercentageToPay" ValidateDataTypeCheck="True" ValidationDataType="Double"
                                ValidateRequiredField="True" OnTextChanged="PercentageToPay_TextChanged" InternalControlWidth="95%"
                                meta:resourcekey="PercentageToPayResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="AmountToPay" Caption="Amount to pay" Enabled="False"
                                PropertyName="AmountToPay" ValidationDataType="Double" ValidateDataTypeCheck="True"
                                ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="AmountToPayResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="Desciption" Caption="Description" PropertyName="Description"
                                InternalControlWidth="95%" meta:resourcekey="DesciptionResource1">
                            </ui:UIFieldTextBox>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabReceipt" runat="server" BorderStyle="NotSet" Caption="Receipt"
                    meta:resourcekey="tabReceiptResource1">
                    <ui:UIPanel ID="panelAddReceipt" runat="server" BorderStyle="NotSet" meta:resourcekey="panelAddReceiptResource1">
                        <ui:UIButton ID="buttonAddReceipt" runat="server" ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddReceiptResource1"
                            OnClick="buttonAddReceipt_Click" Text="Receive Items" />
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIPanel ID="panelSaveTip" runat="server" BorderStyle="NotSet" meta:resourcekey="panelSaveTipResource1">
                        <asp:Image ID="imageSaveTip" runat="server" ImageAlign="AbsMiddle" ImageUrl="~/images/information.png"
                            meta:resourceKey="imageSaveTipResource1" />
                        <asp:Label ID="labelSaveTip" runat="server" meta:resourceKey="labelSaveTipResource1"
                            Text="Please save this Purchase Order to commit the receipt."></asp:Label>
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIGridView ID="PurchaseOrderReceipts" runat="server" Caption="Receipts" DataKeyNames="ObjectID"
                        GridLines="Both" keyname="ObjectID" meta:resourcekey="PurchaseOrderReceiptsResource1"
                        pagingenabled="True" PropertyName="PurchaseOrderReceipts" RowErrorColor="" Style="clear: both;"
                        Width="100%" OnRowDataBound="PurchaseOrderReceipts_RowDataBound">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/view.gif"
                                meta:resourcekey="UIGridViewColumnResource12">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="DateOfReceipt" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Date of Receipt" meta:resourcekey="UIGridViewColumnResource13" PropertyName="DateOfReceipt"
                                ResourceAssemblyName="" SortExpression="DateOfReceipt">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Store.ObjectName" HeaderText="Store" meta:resourcekey="UIGridViewColumnResource14"
                                PropertyName="Store.ObjectName" ResourceAssemblyName="" SortExpression="Store.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="StoreBin.ObjectName" HeaderText="Store Bin"
                                meta:resourcekey="UIGridViewColumnResource15" PropertyName="StoreBin.ObjectName"
                                ResourceAssemblyName="" SortExpression="StoreBin.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="DeliveryOrderNumber" HeaderText="DO Number"
                                meta:resourcekey="UIGridViewColumnResource16" PropertyName="DeliveryOrderNumber"
                                ResourceAssemblyName="" SortExpression="DeliveryOrderNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourcekey="UIGridViewColumnResource17"
                                PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Attachments">
                                <ItemTemplate>
                                    <asp:DataList runat="server" ID="listAttachment">
                                        <ItemTemplate>
                                            <ui:UIButton runat="server" ID="buttonDownloadAttachment" AlwaysEnabled="true" OnClick="buttonDownloadAttachment_Click">
                                            </ui:UIButton>
                                        </ItemTemplate>
                                    </asp:DataList>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="PurchaseOrderReceipt_Panel" runat="server" BorderStyle="NotSet"
                        meta:resourcekey="PurchaseOrderReceipt_PanelResource1">
                        <web:subpanel ID="PurchaseOrderReceipt_Subpanel" runat="server" CancelVisible="true"
                            GridViewID="PurchaseOrderReceipts" OnPopulateForm="PurchaseOrderReceipt_SubPanel_PopulateForm"
                            UpdatePopupVisible="false" OnValidateAndUpdate="PurchaseOrderReceipt_Subpanel_ValidateAndUpdate"
                            UpdateAndNewButtonVisible="false" />
                        <ui:UIPanel ID="panelPurchaseOrderReceipt" runat="server" BorderStyle="NotSet" meta:resourcekey="panelPurchaseOrderReceiptResource1">
                            <ui:UIFieldDateTime ID="UIFieldDateTime1" runat="server" Caption="Date of Receipt"
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="UIFieldDateTime1Resource1"
                                PropertyName="DateOfReceipt" ShowDateControls="True" ValidateRequiredField="True">
                            </ui:UIFieldDateTime>
                            <ui:UIPanel ID="panelStore" runat="server" BorderStyle="NotSet" meta:resourcekey="panelStoreResource1">
                                <ui:UIFieldDropDownList ID="dropStore" runat="server" Caption="Store" meta:resourcekey="dropStoreResource1"
                                    OnSelectedIndexChanged="dropStore_SelectedIndexChanged" PropertyName="StoreID"
                                    Span="Half" ValidateRequiredField="True">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList ID="dropStoreBin" runat="server" Caption="Store Bin" meta:resourcekey="PurchaseOrderReceipt_StoreBinIDResource1"
                                    PropertyName="StoreBinID" Span="Half" ValidateRequiredField="True">
                                </ui:UIFieldDropDownList>
                            </ui:UIPanel>
                            <ui:UIFieldTextBox ID="PurchaseOrderReceipt_DeliveryOrderNumber" runat="server" Caption="DO Number"
                                InternalControlWidth="95%" meta:resourcekey="PurchaseOrderReceipt_DeliveryOrderNumberResource1"
                                PropertyName="DeliveryOrderNumber">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="PurchaseOrderReceipt_Description" runat="server" Caption="Description"
                                InternalControlWidth="95%" MaxLength="255" meta:resourcekey="PurchaseOrderReceipt_DescriptionResource1"
                                PropertyName="Description">
                            </ui:UIFieldTextBox>
                            <br />
                            <ui:UISeparator runat="server" ID="sepReceiptItems" Caption="Receipt Item" />
                            <ui:UIPanel ID="panelReceiptItems" runat="server" BorderStyle="NotSet" meta:resourcekey="panelReceiptItemsResource1">
                                <ui:UIGridView ID="PurchaseOrderReceiptItems" runat="server" BindObjectsToRows="True"
                                    Caption="Receipt Items" CheckBoxColumnVisible="False" DataKeyNames="ObjectID"
                                    GridLines="Both" keyname="ObjectID" meta:resourcekey="PurchaseOrderReceiptItemsResource1"
                                    OnRowDataBound="PurchaseOrderReceiptItems_RowDataBound" pagingenabled="True"
                                    PropertyName="PurchaseOrderReceiptItems" RowErrorColor="" SortExpression="PurchaseOrderItem.ItemNumber"
                                    Style="clear: both;" Width="100%">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <Columns>
                                        <ui:UIGridViewBoundColumn DataField="PurchaseOrderItem.ItemNumber" HeaderText="#"
                                            meta:resourcekey="UIGridViewColumnResource18" PropertyName="PurchaseOrderItem.ItemNumber"
                                            ResourceAssemblyName="" SortExpression="PurchaseOrderItem.ItemNumber">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="PurchaseOrderItem.ItemTypeText" HeaderText="Item Type"
                                            meta:resourcekey="UIGridViewColumnResource19" PropertyName="PurchaseOrderItem.ItemTypeText"
                                            ResourceAssemblyName="" SortExpression="PurchaseOrderItem.ItemTypeText">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="PurchaseOrderItem.ItemDescription" HeaderText="Description"
                                            meta:resourcekey="UIGridViewColumnResource20" PropertyName="PurchaseOrderItem.ItemDescription"
                                            ResourceAssemblyName="" SortExpression="PurchaseOrderItem.ItemDescription">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="PurchaseOrderItem.ReceiptModeText" HeaderText="Receipt Mode"
                                            meta:resourcekey="UIGridViewBoundColumnResource21" PropertyName="PurchaseOrderItem.ReceiptModeText"
                                            ResourceAssemblyName="" SortExpression="PurchaseOrderItem.ReceiptModeText">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="PurchaseOrderItem.ReceiptMode" meta:resourcekey="UIGridViewBoundColumnResource22"
                                            PropertyName="PurchaseOrderItem.ReceiptMode" ResourceAssemblyName="" SortExpression="PurchaseOrderItem.ReceiptMode"
                                            Visible="False">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="EquipmentName" meta:resourcekey="UIGridViewBoundColumnResource23"
                                            PropertyName="EquipmentName" ResourceAssemblyName="" SortExpression="EquipmentName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="EquipmentParent.Path" meta:resourcekey="UIGridViewBoundColumnResource24"
                                            PropertyName="EquipmentParent.Path" ResourceAssemblyName="" SortExpression="EquipmentParent.Path">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="PurchaseOrderItem.QuantityOrdered" DataFormatString="{0:#,##0.00##}"
                                            HeaderText="Quantity Ordered" meta:resourcekey="UIGridViewColumnResource21" PropertyName="PurchaseOrderItem.QuantityOrdered"
                                            ResourceAssemblyName="" SortExpression="PurchaseOrderItem.QuantityOrdered">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Quantity Received" meta:resourcekey="UIGridViewColumnResource22">
                                            <ItemTemplate>
                                                <ui:UIFieldTextBox ID="PurchaseOrderReceiptItem_QuantityDelivered" runat="server"
                                                    Caption="Quantity Received" CaptionWidth="1px" FieldLayout="Flow" InternalControlWidth="95%"
                                                    meta:resourcekey="PurchaseOrderReceiptItem_QuantityDeliveredResource1" OnTextChanged="PurchaseOrderReceiptItem_QuantityDelivered_TextChanged"
                                                    PropertyName="QuantityDelivered" ShowCaption="False" ValidateDataTypeCheck="True"
                                                    ValidateRangeField="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                                    ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Currency">
                                                </ui:UIFieldTextBox>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="120px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Unit Price / Dollar Amount Received" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                            <ItemTemplate>
                                                <ui:UIFieldTextBox ID="PurchaseOrderReceiptItem_UnitPrice" runat="server" Caption="Unit Price Received"
                                                    CaptionWidth="1px" FieldLayout="Flow" InternalControlWidth="95%" meta:resourcekey="PurchaseOrderReceiptItem_UnitPriceResource1"
                                                    PropertyName="UnitPrice" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                                    ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                                    ValidationRangeMin="0" ValidationRangeType="Currency">
                                                </ui:UIFieldTextBox>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="120px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Lot Number" meta:resourcekey="UIGridViewColumnResource23">
                                            <ItemTemplate>
                                                <ui:UIFieldTextBox ID="PurchaseOrderReceiptItem_LotNumber" runat="server" Caption="Lot Number"
                                                    CaptionWidth="1px" FieldLayout="Flow" InternalControlWidth="95%" meta:resourcekey="PurchaseOrderReceiptItem_LotNumberResource1"
                                                    PropertyName="LotNumber" ShowCaption="False">
                                                </ui:UIFieldTextBox>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="200px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewTemplateColumn HeaderText="Expiry Date" meta:resourcekey="UIGridViewColumnResource24">
                                            <ItemTemplate>
                                                <ui:UIFieldDateTime ID="PurchaseOrderReceiptItem_ExpiryDate" runat="server" Caption="Expiry Date"
                                                    CaptionWidth="1px" FieldLayout="Flow" ImageClearUrl="~/calendar/dateclr.gif"
                                                    ImageUrl="~/calendar/date.gif" meta:resourcekey="PurchaseOrderReceiptItem_ExpiryDateResource1"
                                                    PropertyName="ExpiryDate" ShowCaption="False" ShowDateControls="True">
                                                </ui:UIFieldDateTime>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" Width="200px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewTemplateColumn>
                                    </Columns>
                                </ui:UIGridView>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panelVendorAttachments">
                                <br />
                                <ui:UIPanel runat="server" ID="panelgridAttachments">
                                    <web:fileuploaddialogbox runat="server" ID="receiptAttachmentUpload" NumberOfFileUploads="5"
                                        Cancelled="false" Title="Attach Good Receipt Document(s)" OnUploaded="receiptAttachmentUpload_Uploaded" />
                                    <ui:UISeparator runat="server" ID="sepReceiptAttachment" Caption="Attachment" />
                                    <ui:UIGridView runat='server' ID="gridDocument" Caption="Good Receipt Attachment(s)"
                                        PropertyName="Attachments" CaptionWidth="120px" KeyName="ObjectID" OnAction="gridDocument_Action">
                                        <Commands>
                                            <ui:UIGridViewCommand CommandName="UploadDocument" CommandText="Upload File" ImageUrl="~/images/upload.png" />
                                            <ui:UIGridViewCommand CommandName="DeleteDocument" CommandText="Delete" ImageUrl="~/images/delete.gif"
                                                ConfirmText="Are you sure you wish to delete the selected documents?" />
                                        </Commands>
                                        <Columns>
                                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewDocument"
                                                HeaderText="" AlwaysEnabled="true">
                                            </ui:UIGridViewButtonColumn>
                                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteDocument"
                                                HeaderText="" ConfirmText="Are you sure you wish to delete this document?">
                                            </ui:UIGridViewButtonColumn>
                                            <ui:UIGridViewBoundColumn PropertyName="Filename" HeaderText="File Name">
                                            </ui:UIGridViewBoundColumn>
                                            <ui:UIGridViewBoundColumn PropertyName="FileSize" HeaderText="File Size (bytes)"
                                                DataFormatString="{0:#,##0}">
                                            </ui:UIGridViewBoundColumn>
                                            <ui:UIGridViewBoundColumn PropertyName="FileDescription" HeaderText="File Description">
                                            </ui:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </ui:UIPanel>
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabInvoice" runat="server" BorderStyle="NotSet" Caption="Invoice"
                    meta:resourcekey="tabInvoiceResource1">
                    <ui:UIPanel ID="panelInvoiceMatchToReceipt" runat="server" BorderStyle="NotSet" meta:resourcekey="panelInvoiceMatchToReceiptResource1">
                        <ui:UIGridView ID="gridReceipts" runat="server" Caption="Receipts" DataKeyNames="ObjectID"
                            GridLines="Both" meta:resourcekey="gridReceiptsResource1" RowErrorColor="" Style="clear: both;">
                            <PagerSettings Mode="NumericFirstLast" />
                        </ui:UIGridView>
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIPanel ID="panelInvoiceMatchToPO" runat="server" BorderStyle="NotSet" meta:resourcekey="panelInvoiceMatchToPOResource1">
                        <ui:UIButton ID="buttonAddInvoice" runat="server" ConfirmText="Are you sure you wish to add an invoice? Please remember to save the Purchase Order, otherwise changes that you have made will be lost."
                            ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddInvoiceResource1" OnClick="buttonAddInvoice_Click"
                            Text="Add Invoice" />
                        <ui:UIButton ID="buttonAddCreditMemo" runat="server" ConfirmText="Are you sure you wish to add an credit memo? Please remember to save the Purchase Order, otherwise changes that you have made will be lost."
                            ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddCreditMemoResource1" OnClick="buttonAddCreditMemo_Click"
                            Text="Add Credit Memo" />
                        <ui:UIButton ID="buttonAddDebitMemo" runat="server" ConfirmText="Are you sure you wish to add an debit memo? Please remember to save the Purchase Order, otherwise changes that you have made will be lost."
                            ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddDebitMemoResource1" OnClick="buttonAddDebitMemo_Click"
                            Text="Add Debit Memo" Visible="False" />
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIGridView ID="gridInvoices" runat="server" Caption="Invoices" DataKeyNames="ObjectID"
                        GridLines="Both" meta:resourcekey="gridInvoicesResource1" OnAction="gridInvoices_Action"
                        ShowFooter="true" OnRowDataBound="gridInvoices_RowDataBound" RowErrorColor=""
                        SortExpression="DateOfInvoice" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditInvoice" ConfirmText="Are you sure you wish to edit this invoice? Please remember to save the Purchase Order, otherwise changes that you have made will be lost."
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewInvoice" ConfirmText="Are you sure you wish to view this invoice? Please remember to save the Purchase Order, otherwise changes that you have made will be lost."
                                ImageUrl="~/images/view.gif" AlwaysEnabled="true">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Invoice Number" meta:resourcekey="UIGridViewBoundColumnResource25"
                                PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="InvoiceTypeText" HeaderText="Invoice Type" meta:resourcekey="UIGridViewBoundColumnResource26"
                                PropertyName="InvoiceTypeText" ResourceAssemblyName="" SortExpression="InvoiceTypeText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="DateOfInvoice" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Date of Invoice" meta:resourcekey="UIGridViewBoundColumnResource27"
                                PropertyName="DateOfInvoice" ResourceAssemblyName="" SortExpression="DateOfInvoice">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource28"
                                PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Currency.ObjectName" HeaderText="Currency" meta:resourcekey="UIGridViewBoundColumnResource29"
                                PropertyName="Currency.ObjectName" ResourceAssemblyName="" SortExpression="Currency.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Currency.CurrencySymbol" meta:resourcekey="UIGridViewBoundColumnResource30"
                                PropertyName="Currency.CurrencySymbol" ResourceAssemblyName="" SortExpression="Currency.CurrencySymbol">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalAmountInSelectedCurrency" DataFormatString="{0:n}"
                                HeaderText="Net Amount" meta:resourcekey="UIGridViewBoundColumnResource31" PropertyName="TotalAmountInSelectedCurrency"
                                ResourceAssemblyName="" SortExpression="TotalAmountInSelectedCurrency">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalTaxInSelectedCurrency" DataFormatString="{0:n}"
                                HeaderText="Tax" meta:resourcekey="UIGridViewBoundColumnResource32" PropertyName="TotalTaxInSelectedCurrency"
                                ResourceAssemblyName="" SortExpression="TotalTaxInSelectedCurrency">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalAmount" DataFormatString="{0:c}" HeaderText="Net Amount&lt;br/&gt;(in Base Currency)"
                                HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource33" PropertyName="TotalAmount"
                                FooterAggregate="Sum" ResourceAssemblyName="" SortExpression="TotalAmount">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalTax" DataFormatString="{0:c}" HeaderText="Tax&lt;br/&gt;(in Base Currency)"
                                HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource34" PropertyName="TotalTax"
                                ResourceAssemblyName="" SortExpression="TotalTax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="TotalAmountAndTax" DataFormatString="{0:c}"
                                HeaderText="Gross" meta:resourcekey="UIGridViewBoundColumnResource35" PropertyName="TotalAmountAndTax"
                                ResourceAssemblyName="" SortExpression="TotalAmountAndTax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status"
                                meta:resourcekey="UIGridViewBoundColumnResource36" PropertyName="CurrentActivity.ObjectName"
                                ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
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