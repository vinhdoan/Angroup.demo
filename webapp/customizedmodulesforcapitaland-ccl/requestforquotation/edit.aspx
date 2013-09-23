<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    
    class gridAwardItemsColumn
    {
        public static int AwardedDate = 14;
    }

    // NOTE:
    // For Marcom's Edit Page, do the following:
    //    1. Move the panelRequestForQuotationItems into the details tab.
    private Hashtable EditVisible;
    private Hashtable ViewVisible;

    protected override void OnLoad(EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        base.OnLoad(e);
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;

        //tessa comment out
        if (requestForQuotation.AutoCalculateReallocationTo == null)
            requestForQuotation.AutoCalculateReallocationTo = 1;
        //tessa end

        if (requestForQuotation.CurrentActivity == null ||
            requestForQuotation.CurrentActivity.ObjectName.Is("Draft", "PendingInvitation", "PendingQuotation", "PendingEvaluation"))
            requestForQuotation.UpdateApplicablePurchaseSettings();

        objectBase.ObjectNumberVisible = !requestForQuotation.IsNew;

        if (!IsPostBack)
        {
            gridChildWJs.Columns[4].HeaderText += String.Format(" ({0})", OApplicationSetting.Current.BaseCurrency.CurrencySymbol);

            //dropCase.Bind(OCase.GetAccessibleOpenCases(AppSession.User, Security.Decrypt(Request["TYPE"]), requestForQuotation.CaseID), "Case", "ObjectID");
            BindVendorToAward(requestForQuotation);
            BindBackgroundPurchaseType(requestForQuotation);
            BindRequestorID(requestForQuotation);
            BindLocation(requestForQuotation);
            BindCancelledPurchaseOrder(requestForQuotation);
            BindWorkJustificationDate(requestForQuotation);
            BindTenantContact(requestForQuotation);

            labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;
        }

        //treeLocation.PopulateTree();
        //treeEquipment.PopulateTree();

        buttonViewGroupWJ.Visible = AppSession.User.AllowViewAll("ORequestForQuotation");
        buttonEditGroupWJ.Visible = AppSession.User.AllowEditAll("ORequestForQuotation ") || OActivity.CheckAssignment(AppSession.User, requestForQuotation.GroupRequestForQuotationID);

        if (requestForQuotation.CurrentActivity == null ||
            !requestForQuotation.CurrentActivity.ObjectName.Is("PendingApproval", "Awarded", "Close", "Cancelled"))
        {
            requestForQuotation.ComputeTempBudgetSummaries();

            //tessa comment out for the hiding of budget reallocation
            requestForQuotation.ComputeBudgetReallocationToPeriods();
            requestForQuotation.UpdateTempBudgetSummaryWithReallocation();
            requestForQuotation.ComputeFromBudgetSummary();

            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        else
            gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";

        PopulateDropFromBudget(requestForQuotation);

        requestForQuotation.ComputeLowestQuotation();

        EditVisible = new Hashtable();
        ViewVisible = new Hashtable();

        IsDelegatedToHOD.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] == "IT");

        BindRequestor(requestForQuotation);

        panel.ObjectPanel.BindObjectToControls(requestForQuotation);

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="rfq"></param>
    protected void BindVendorToAward(ORequestForQuotation rfq)
    {
        dropVendorToAward.Bind(rfq.GetVendorsWithSubmittedQuotations());
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="work"></param>
    protected void BindTenantContact(ORequestForQuotation rfq)
    {

        if (rfq.TenantLease != null && rfq.TenantLease.TenantID != null)
            dropTenantContact.Bind(rfq.TenantLease.Tenant.TenantContacts);
        else
            dropTenantContact.Items.Clear();
        panelTenantDetails.Visible = (rfq.IsNew);
    }

    /// <summary>
    /// Bind Location controls
    /// </summary>
    /// <param name="rfq"></param>
    protected void BindLocation(ORequestForQuotation rfq)
    {
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));

        List<OLocation> listLocs = OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, rfq.LocationID);
        listLocs.Sort("ParentPath");
        ddlLocation.Bind(listLocs, "ParentPath", "ObjectID");

        ddl_EmployerCompany.Bind(TablesLogic.tCapitalandCompany.LoadList(TablesLogic.tCapitalandCompany.IsDeactivated == 0)
                                    , "ObjectNameAndAddress", "ObjectID");

        // Default Location and Employer Company
        // if user is accessiable to 1 location.
        //
        if (rfq.IsNew && ddlLocation.Items.Count == 2)
        {
            rfq.LocationID = new Guid(ddlLocation.Items[1].Value);
            rfq.EmployerCompanyID = rfq.Location.BuildingTrustID;
        }

        OApplicationSetting applicationSetting = OApplicationSetting.Current;

        // Allow to create group WJ if
        // application setting is set to enable
        // or the user is allowed to enable for all buildings
        //
        if (applicationSetting.EnableAllBuildingForGWJ == 1 ||
            AppSession.User.EnableAllBuildingForGWJ == 1)
        {
            List<OLocation> lstLocs = OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, null);
            lstLocs.Sort("ParentPath");
            listLocations.Bind(lstLocs, "ParentPath", "ObjectID");
        }
        else
        {
            List<OLocation> lstLocs = AppSession.User.GetAllAccessibleLocation(OApplicationSetting.Current.LocationTypeNameForBuildingActual, "ORequestForQuotation");
            lstLocs.Sort("ParentPath");
            listLocations.Bind(lstLocs, "ParentPath", "ObjectID");
        }
        // disable location dropdown
        // when rfq is not new.
        //
        ddlLocation.Enabled = rfq.IsNew;
    }

    /// <summary>
    /// Bind Background, PurchaseType control dropdownlist
    /// </summary>
    /// <param name="rfq"></param>
    protected void BindBackgroundPurchaseType(ORequestForQuotation rfq)
    {
        BudgetGroupID.Bind(AppSession.User.GetAllAccessibleBudgetGroup("ORequestForQuotation", rfq.BudgetGroupID));

        if (rfq.BudgetGroupID == null && BudgetGroupID.Items.Count == 1)
            rfq.BudgetGroupID = new Guid(BudgetGroupID.Items[0].Value);

        dropBackgroundType.Bind(OCode.GetCodesByType("BackgroundType", rfq.BackgroundTypeID));

        //dropPurchaseTypeClassification.Bind(OCode.GetCodesByType("PurchaseTypeClassification", rfq.TransactionTypeGroupID));
        List<OCode> purchaseGroupTypes = OCode.GetPurchaseGroupTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), rfq.TransactionTypeGroupID);
        dropPurchaseTypeClassification.Bind(purchaseGroupTypes);

        if (rfq.TransactionTypeGroupID != null)
            //dropPurchaseType.Bind(OCode.GetCodesByTypeAndParentID("PurchaseType", rfq.TransactionTypeGroupID, rfq.PurchaseTypeID));
            dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, rfq.TransactionTypeGroupID, Security.Decrypt(Request["TYPE"]), rfq.PurchaseTypeID));
        else if (purchaseGroupTypes.Count == 1)
            dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, purchaseGroupTypes[0].ObjectID, Security.Decrypt(Request["TYPE"]), rfq.PurchaseTypeID));
        else
            dropPurchaseType.Items.Clear();

        if (rfq.IsNew && dropPurchaseTypeClassification.Items.Count == 1)
            rfq.TransactionTypeGroupID = new Guid(dropPurchaseTypeClassification.Items[0].Value);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="rfq"></param>
    protected void BindCancelledPurchaseOrder(ORequestForQuotation rfq)
    {
        // 2011.03.14, Joey:
        // show context menu to allow user
        // to view / edit the previous cancelled purchase order if this rfq was generated from a previous cancelled purchase order
        //
        if (rfq.CancelledPurchaseOrderID != null)
        {
            CancelledPurchaseOrder.Visible = true;

            buttonViewPurchaseOrder.Visible =
                (AppSession.User.AllowViewAll("OPurchaseOrder") || OActivity.CheckAssignment(AppSession.User, rfq.CancelledPurchaseOrderID));

            buttonEditPurchaseOrder.Visible =
                (AppSession.User.AllowEditAll("OPurchaseOrder") || OActivity.CheckAssignment(AppSession.User, rfq.CancelledPurchaseOrderID));
        }

        //20120209 ptb
        //add billTo for ADMIN
        ddlBillTo.Bind(OCapitalandCompany.GetCapitalandCompanies(rfq.BillToID), "ObjectNameAndAddress", "ObjectID");
        BillToContactPersonID.Bind(OUser.GetUsersByRoleAndAboveLocation(rfq.BillToContactPerson, rfq.Location, "PURCHASEADMIN"));
        ddlDeliveryTo.Bind(OCapitalandCompany.GetCapitalandCompanies(rfq.DeliveryToID), "ObjectNameAndAddress", "ObjectID");
        DeliverToContactPersonID.Bind(OUser.GetUsersByRoleAndAboveLocation(rfq.DeliverToContactPerson, rfq.Location, "PURCHASEADMIN"));
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="rfq"></param>
    private void PopulateDropFromBudget(ORequestForQuotation rfq)
    {
        if (rfq == null)
            return;

        dropFromBudget.Items.Clear();
        dropFromBudgetPeriod.Items.Clear();

        treeAccountFrom.PopulateTree();

        List<Guid> BudgetIDList = new List<Guid>();

        if (rfq.RFQBudgetReallocationToPeriods != null)
        {
            foreach (ORFQBudgetReallocationToPeriod period in rfq.RFQBudgetReallocationToPeriods)
            {
                if (!BudgetIDList.Contains(period.ToBudgetID.Value))
                    BudgetIDList.Add(period.ToBudgetID.Value);
            }

            if (BudgetIDList.Count > 0)
            {
                List<OBudget> budgetList = TablesLogic.tBudget.LoadList(TablesLogic.tBudget.ObjectID.In(BudgetIDList));
                dropFromBudget.Bind(budgetList);
            }
        }
    }

    private void BindRequestorID(ORequestForQuotation rfq)
    {
        if (rfq.RequestorID == null)
            rfq.RequestorID = AppSession.User.ObjectID;
        if (rfq.RequestorName == null)
            rfq.RequestorName = AppSession.User.ObjectName;
        /*
        if (rfq.IsGroupWJ != 1)
        {
            RequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(rfq.Requestor, rfq.Location, "PURCHASEREQUESTOR"), true);
        }
        else
        {
            List<OLocation> locations = new List<OLocation>();
            foreach (OLocation location in rfq.GroupWJLocations)
                locations.Add(location);
            RequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(rfq.Requestor, locations, "PURCHASEREQUESTOR"), true);
        }*/
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="rfq"></param>
    protected void BindWorkJustificationDate(ORequestForQuotation rfq)
    {
        OApplicationSetting applicationSetting = OApplicationSetting.Current;

        if (DateRequired.DateTime == null &&
            DateEnd.DateTime == null &&
            applicationSetting.IsWJDateDefaulted == 1 &&
            !checkIsTermContract.Checked &&
            rfq.IsNew)
        {
            DateTime today = DateTime.Today;
            switch (applicationSetting.DefaultRequiredUnit)
            {
                case (int)EnumRequestForQuotationDefaultDateUnit.Day:
                    rfq.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Week:
                    rfq.DateRequired = today.AddDays(applicationSetting.DefaultRequiredCount.Value * 7);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Month:
                    rfq.DateRequired = today.AddMonths(applicationSetting.DefaultRequiredCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Year:
                    rfq.DateRequired = today.AddYears(applicationSetting.DefaultRequiredCount.Value);
                    break;
            }

            switch (applicationSetting.DefaultEndUnit)
            {
                case (int)EnumRequestForQuotationDefaultDateUnit.Day:
                    rfq.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Week:
                    rfq.DateEnd = today.AddDays(applicationSetting.DefaultEndCount.Value * 7);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Month:
                    rfq.DateEnd = today.AddMonths(applicationSetting.DefaultEndCount.Value);
                    break;
                case (int)EnumRequestForQuotationDefaultDateUnit.Year:
                    rfq.DateEnd = today.AddYears(applicationSetting.DefaultEndCount.Value);
                    break;
            }
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void panel_Validate(object sender, PersistentObject obj)
    {
        ORequestForQuotation requestForQuotation = obj as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(requestForQuotation);

        string state = objectBase.CurrentObjectState;
        string action = objectBase.SelectedAction;

        requestForQuotation.UpdateBudgetReallocation();

        // Validate
        // Not Applicable to CCL
        //
        //if (!objectBase.CurrentObjectState.Is("Close", "Cancelled") &&
        //    !OCase.ValidateCaseNotClosedOrCancelled(requestForQuotation.CaseID) &&
        //    ConfigurationManager.AppSettings["CustomizedInstance"] != "MARCOM")
        //{
        //    dropCase.ErrorMessage = Resources.Errors.Case_CannotBeClosedOrCancelled;
        //}

        if (action.Is("Cancel"))
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

        if (action.Is("SubmitForApproval", "CreateChildRFQs"))
        {
            string acrossPeriod;
            string periodsNotEqual;

            requestForQuotation.ComputeTempBudgetSummaries();

            // tessa comment out because of the hiding of budget reallocation
            requestForQuotation.ComputeBudgetReallocationToPeriods();
            requestForQuotation.UpdateTempBudgetSummaryWithReallocation();
            requestForQuotation.ComputeFromBudgetSummary();
            requestForQuotation.UpdateBudgetReallocation();

            // tessa comment out because of the hiding of budget reallocation
            //
            if (requestForQuotation.IsReallocateAcrossBudgetPeriod(out acrossPeriod))
            {
                string errorMessage = String.Format(
                           Resources.Errors.RequestForQuotation_BudgetReallocationAcrossBudgetPeriod, acrossPeriod);

                gridReallocationToPeriod.ErrorMessage = errorMessage;
                gridReallocationFromPeriod.ErrorMessage = errorMessage;
            }
            else if (!requestForQuotation.IsEqualReallocateAmount(out periodsNotEqual))
            {

                string errorMessage = String.Format(
                           Resources.Errors.RequestForQuotation_CheckTotalAmountItemsFromEqualTotalAmountItemsTo1, periodsNotEqual);

                gridReallocationToPeriod.ErrorMessage = errorMessage;
                gridReallocationFromPeriod.ErrorMessage = errorMessage;
                return;
            }

            string accounts = requestForQuotation.CheckSufficientAvailableAmountForReallocation();

            if (accounts != "")
            {
                string errorMessage = String.Format(
                    Resources.Errors.BudgetReallocation_InsufficientAmount, accounts);
                this.gridReallocationFromPeriod.ErrorMessage = errorMessage;
                this.gridReallocationToPeriod.ErrorMessage = errorMessage;
                return;

            }
            //tessa end

            // Ensure that all budget accounts in the budget
            // line items are set as active.
            //
            string inactiveAccounts = OPurchaseBudget.ValidateBudgetAccountsAreActive(requestForQuotation.PurchaseBudgets);
            if (inactiveAccounts != "")
            {
                gridBudget.ErrorMessage =
                    String.Format(Resources.Errors.RequestForQuotation_BudgetAccountsNotActive, inactiveAccounts);
            }

            // Ensure that the budget line items match the
            // RFQ line items in amount.
            //
            string itemNumber = requestForQuotation.ValidateBudgetAmountEqualsLineItemAmount();
            if (itemNumber != null)
            {
                if (itemNumber == "account")
                    gridBudget.ErrorMessage = Resources.Errors.RequestForQuotation_AccountIsNotMatch;
                else
                    gridBudget.ErrorMessage = string.Format(Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount, itemNumber);

                /****************
                string itemNumberText = "";
                if (itemNumber > 0)
                    itemNumberText = String.Format(Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount_LineItem, itemNumber);
                else
                    itemNumberText = Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount_EntireRFQ;

                if (requestForQuotation.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems)
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount, itemNumberText);
                else if (requestForQuotation.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems)
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_ItemAmountLessThanBudgetAmount, itemNumberText);
                 ****************/
            }

            // Ensure that all purchase budgets adhere to the
            // budget spending policy.
            //
            string budgetsWithNoPeriod = requestForQuotation.ValidateBudgetSpendingPolicy();
            if (budgetsWithNoPeriod != "")
            {
                gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_BudgetNoPeriod, budgetsWithNoPeriod);
                return;
            }

            // Ensure that number of quotations is sufficient.
            if (requestForQuotation.ValidateSufficientNumberOfQuotations() == 0)
            {
                RequestForQuotationVendors.ErrorMessage =
                    String.Format(Resources.Errors.RequestForQuotation_InsufficientQuotations, requestForQuotation.MinimumNumberOfQuotations);
                return;
            }

            // 2011.08.25, Kien Trung. Make sure all the submitted vendor quotations attachment uploaded.
            //
            if (!requestForQuotation.ValidateRFQVendorAttachmentsUploaded())
            {
                RequestForQuotationVendors.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_VendorAttachment);
                return;
            }

            // 2011.08.25 ,Kien Trung
            // ensure at least one line item awarded.
            //
            if (!requestForQuotation.ValidateAtLeastOneItemAwarded())
            {
                gridAwardItems.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_NoLineItemsAwarded);
                return;
            }

            /****************
            foreach (ORequestForQuotationItem item in requestForQuotation.RequestForQuotationItems)
            {
                if (item.AwardedVendor != null)
                {
                    foreach (ORequestForQuotationVendor rfqvendor in requestForQuotation.RequestForQuotationVendors)
                    {

                        if (rfqvendor.VendorID == item.AwardedVendorID && rfqvendor.Attachments.Count <= 0)
                        {
                            RequestForQuotationVendors.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_VendorAttachment);
                            break;
                        }
                    }
                }
                // 2010.12.27
                // Kien Trung
                // Ensure the line item(s) awarded before submit for approval
                //
                else
                {
                    gridAwardItems.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_NoLineItemsAwarded);
                    break;
                }
            }
            *******************/

            // tessa comment out because of the hiding of budget reallocation
            // validate reallocation accross groups
            string reallocation = requestForQuotation.ValidateReallocationAcrossGroups();
            if (reallocation != "")
            {
                gridBudgetSummary.ErrorMessage = reallocation;
                return;
            }

            // Ensure budget is sufficient.
            //
            //tessa comment out because budget reallocation is hidden
            string insufficientAccounts = requestForQuotation.ValidateSufficientBudgetWithBudgetReallocation();
            if (insufficientAccounts != "")
            {
                gridBudget.ErrorMessage =
                    String.Format(Resources.Errors.RequestForQuotation_InsufficientBudget, insufficientAccounts);
                return;
            }
            //tessa end

            // Ensure that the budget periods covering the start date of
            // the purchase order exists, and has not yet been closed.
            //
            string closedBudgets = OPurchaseBudget.ValidateBudgetPeriodsActiveAndOpened(requestForQuotation.PurchaseBudgets);
            if (closedBudgets != "")
            {
                gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_BudgetPeriodsClosed, closedBudgets);
                return;
            }

            // 2010.12.22
            // Kim Foong
            // Ensure that there is at least 1 attachment, if the delegated
            // to HOD is checked.
            //
            if (IsDelegatedToHOD.Checked && requestForQuotation.Attachments.Count == 0)
            {
                attachments.ErrorMessage = Resources.Errors.RequestForQuotation_AtLeastOneAttachmentRequired;
                return;
            }
        }

        //Check all Line Items, make sure that Quantity Required are all filled up
        if (requestForQuotation.RequestForQuotationItems != null)
        {
            foreach (ORequestForQuotationItem requestForQuotationItem in requestForQuotation.RequestForQuotationItems)
            {
                if (requestForQuotationItem.RequestForQuotationItemLocation != null)
                {
                    foreach (ORequestForQuotationItemLocation requestForQuotationItemLocation in requestForQuotationItem.RequestForQuotationItemLocation)
                    {
                        if (requestForQuotationItemLocation.QuantityRequired == null)
                            RequestForQuotationItems.ErrorMessage = Resources.Errors.RequestForQuotation_LineItemsQuantityNotFilled.ToString();
                    }
                }
            }
        }
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

            panel_Validate(sender, requestForQuotation);

            string state = objectBase.CurrentObjectState;
            string action = objectBase.SelectedAction;

            CRVTenderSync(requestForQuotation);//Nguyen Quoc Phuong 28-Nov-2012

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            if (requestForQuotation.IsGroupWJ == 1)
            {
                ExpressionCondition cond = Query.True;
                foreach (OLocation l in requestForQuotation.GroupWJLocations)
                    cond = cond & l.HierarchyPath.Like(TablesLogic.tLocation.HierarchyPath + "%");

                requestForQuotation.LocationID = TablesLogic.tLocation.SelectTop(1,
                    TablesLogic.tLocation.ObjectID)
                    .Where(TablesLogic.tLocation.IsDeleted == 0 & cond)
                    .OrderBy(TablesLogic.tLocation.HierarchyPath.Desc);
            }

            //20120209 ptb
            //capture the submitter userID            
            if (state.Is("Start", "Draft") && action.StartsWith("SubmitForApproval"))
                requestForQuotation.SubmitterID = AppSession.User.ObjectID;

            requestForQuotation.Save();
            c.Commit();
        }
    }

    //Nguyen Quoc Phuong 28-Nov-2012
    private void CRVTenderSync(ORequestForQuotation requestForQuotation)
    {
        string state = objectBase.CurrentObjectState;
        string action = objectBase.SelectedAction;

        string ErrorMessage = string.Empty;

        if (requestForQuotation.GroupRequestForQuotation == null
            && requestForQuotation.isSyncCRV && state.Is("Start", "Draft")
            && action.StartsWith("SubmitForApproval"))
            ErrorMessage += requestForQuotation.CRVTenderApproveRFQSync();

        if (requestForQuotation.GroupRequestForQuotation == null
            && requestForQuotation.isSyncCRV && state.Is("Start", "Draft")
            && action.StartsWith("CreateChildRFQs"))
        {
            ErrorMessage += requestForQuotation.CRVTenderApproveRFQSync();
            ErrorMessage += requestForQuotation.CRVTenderAwardedRFQSync();
        }

        if (requestForQuotation.isSyncCRV && state.Is("RejectedforRework") && action.StartsWith("SubmitForApproval"))
            ErrorMessage = requestForQuotation.CRVTenderApproveRFQFromRejectSync();
        //if (isSyncCRV && state.Is("PendingApproval") && action.StartsWith("Reject"))
        //    ErrorMessage = requestForQuotation.CRVTenderRejectRFQSync();
        //if (isSyncCRV && state.Is("PendingCancellation") && action.StartsWith("Approve") && requestForQuotation.IsFinalApprover())
        //    ErrorMessage = requestForQuotation.CRVTenderCancelRFQSync();
        if (!string.IsNullOrEmpty(ErrorMessage)) dropCRVSerialNumbers.ErrorMessage = ErrorMessage;
    }
    //End Nguyen Quoc Phuong 28-Nov-2012

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

        if (p.GroupWJLocations.Count != 0)
        {
            //if (requestForQuotationItem.IsNew)
            //{
            //foreach (ListItem li in listLocations.Items)
            //{
            //    if (li.Selected)
            //    {
            //        if (requestForQuotationItem.RequestForQuotationItemLocation != null &&
            //            requestForQuotationItem.RequestForQuotationItemLocation.Find((l) => l.LocationID == new Guid(li.Value)) == null)
            //        {
            //            ORequestForQuotationItemLocation rfqitemLocation =
            //                TablesLogic.tRequestForQuotationItemLocation.Create();
            //            rfqitemLocation.LocationID = new Guid(li.Value);
            //            requestForQuotationItem.RequestForQuotationItemLocation.Add(rfqitemLocation);
            //        }
            //    }
            //}

            foreach (OLocation l in p.GroupWJLocations)
            {
                if (requestForQuotationItem.RequestForQuotationItemLocation != null &&
                    requestForQuotationItem.RequestForQuotationItemLocation.Find((lf) => lf.LocationID == l.ObjectID) == null)
                {
                    ORequestForQuotationItemLocation rfqitemLocation =
                        TablesLogic.tRequestForQuotationItemLocation.Create();
                    rfqitemLocation.LocationID = l.ObjectID;
                    requestForQuotationItem.RequestForQuotationItemLocation.Add(rfqitemLocation);

                }
            }
            //}
        }

        for (int i = 1; i <= p.RequestForQuotationItems.Count + 1; i++)
            ItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (requestForQuotationItem.ItemType == null)
        {
            requestForQuotationItem.ItemType = PurchaseItemType.Others;
            requestForQuotationItem.UnitOfMeasureID = OApplicationSetting.Current.GeneralDefaultUnitOfMeasureID;
        }

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

        // Validates quantity if its a Whole Number according to Catalog Type
        if (CatalogueID.SelectedValue != "")
        {
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(CatalogueID.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(textQuantityRequired.Text) != 0)
            {
                textQuantityRequired.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }
        }
        if (ItemType.SelectedValue == PurchaseItemType.Others.ToString())
        {
            i.AdditionalDescription = "";
        }

        // 2011.08.20, Kien Trung
        // Fixed: use decimal instead of int.
        //
        decimal? amount = 0.0M;
        foreach (ORequestForQuotationItemLocation ofqil in i.RequestForQuotationItemLocation)
            amount += ofqil.QuantityRequired;

        if (checkIsGroupWJ.Checked && (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString()))
            i.QuantityRequired = amount;
        else if (checkIsGroupWJ.Checked && (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString()))
            i.QuantityRequired = 1;

        if (p.RequestForQuotationVendors != null && p.RequestForQuotationVendors.Count > 0)
        {
            p.UpdateLineItemsToRFQVendors(i);
            p.UpdateVendorAwardedItemsUnitPrice();
            p.UpdateBudgetAmount();
            //panel.Message = Resources.Messages.RequestForQuotation_UpdateRFQVendorITem;
        }

        p.RequestForQuotationItems.Add(i);
        p.ReorderItems(i);
        //add new item to rfqvendor

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
        //return;
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

        // 2011.03.07, Joey
        // if the vendor to be added is an IPT vendor,
        // ensure that there is at least one attachment uploaded
        //
        if (requestForQuotationVendor.IsSubmitted == 1 &&
            requestForQuotationVendor.Vendor.IsInterestedParty == 1 &&
            requestForQuotationVendor.Attachments.Count < 1)
            gridDocument.ErrorMessage = Resources.Errors.RequestForQuotation_SingleIptVendorAttachmentNoExist;

        if (!RequestForQuotationVendors_SubPanel.ObjectPanel.IsValid)
            return;

        // Update the ORequestForQuotationVendorItems' unit price
        // (in base currency).
        //
        requestForQuotationVendor.UpdateItemsUnitPrice();
        requestForQuotationVendor.UpdateItemsRecoverable();
        requestForQuotation.UpdateVendorAwardedItemsUnitPrice();

        // Add
        //
        requestForQuotation.RequestForQuotationVendors.Add(requestForQuotationVendor);

        // update budget amount
        //
        if (requestForQuotation.RequestForQuotationItems.Count > 0)
        {
            ORequestForQuotationItem vendorItem = requestForQuotation.RequestForQuotationItems.Find((r) => r.AwardedVendorID == requestForQuotationVendor.VendorID);
            if (vendorItem != null)
                requestForQuotation.UpdateBudgetAmount();
        }

        requestForQuotation.ComputeLowestQuotation();
        panel.ObjectPanel.BindObjectToControls(requestForQuotation);

        // Re-bind the vendor dropdown list.
        //
        dropVendorToAward.Bind(requestForQuotation.GetVendorsWithSubmittedQuotations());

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="RFQ"></param>
    protected void HideShowTabLineItemsControls(ORequestForQuotation RFQ)
    {
        tabChildWJs.Visible = (checkIsGroupWJ.Checked && RFQ.ChildRequestForQuotation.Count > 0);

        textQuantityRequired.Visible = !checkIsGroupWJ.Checked;

        gridRequestForQuotationItemLocations.Visible = checkIsGroupWJ.Checked;

        CatalogueID.Visible =
            buttonAddCatalog.Visible =
            UnitOfMeasure.Visible = (ItemType.SelectedValue == PurchaseItemType.Material.ToString());
        UnitOfMeasure2.Visible =
            FixedRateID.Visible = (ItemType.SelectedValue == PurchaseItemType.Service.ToString());
        UnitOfMeasureID.Visible =
            ItemDescription.Visible = (ItemType.SelectedValue == PurchaseItemType.Others.ToString());
        radioReceiptMode.Enabled = ItemType.SelectedValue != PurchaseItemType.Material.ToString();

        textQuantityRequired.Enabled =
            (radioReceiptMode.SelectedValue != ReceiptModeType.Dollar.ToString() ||
            ItemType.SelectedValue == PurchaseItemType.Material.ToString());

        buttonAddFixedrateItems.Enabled =
            buttonAddMaterialItems.Enabled = !RequestForQuotationItem_SubPanel.Visible;

        //gridRequestForQuotationItemLocations.Columns[2].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString());
        //gridRequestForQuotationItemLocations.Columns[2].c. = (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString());
        //gridRequestForQuotationItemLocations.Columns[3].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString());

        AdditionalDescription.Visible = ItemType.SelectedValue == (PurchaseItemType.Material.ToString()) || ItemType.SelectedValue == (PurchaseItemType.Service.ToString());

        RequestForQuotationItems.Enabled = !RequestForQuotationVendors_SubPanel.Visible;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="RFQ"></param>
    protected void HideShowTabDetailsControls(ORequestForQuotation RFQ)
    {
        hintRfqItemsAddDelete.Visible = !RequestForQuotationItem_Panel.Visible;

        checkIsCharged.Visible = (checkIsCharged.Checked);
        checkIsCharged.Enabled = !(checkIsCharged.Checked);
        buttonShowTenantDetails.Visible = checkIsCharged.Visible;

        checkIsTermContract.Enabled = !(RFQ.StoreID != null);

        //panelGroupWJ.Enabled = (gridBudget.Rows.Count == 0);

        StoreID.Visible = (StoreID.Text != "");

        GroupRequestForQuotationID.Visible = !(GroupRequestForQuotationID.Text == "" || GroupRequestForQuotationID.Text == null);

        panelWork.Visible = !(textWorkID.Text == "" || textWorkID.Text == null);

        ddlLocation.Visible = ddlLocation.Enabled = !checkIsGroupWJ.Checked;
        listLocations.Visible = gridLocations.Visible = checkIsGroupWJ.Checked;
        IsGroupApproval.Visible = checkIsGroupWJ.Checked;
        dropLocation.Visible = checkIsGroupWJ.Checked;

        //rdlRecoverableType.Enabled = (RequestForQuotationVendors.Rows.Count == 0);
        //checkRecoverable.Enabled = (RequestForQuotationVendors.Rows.Count == 0);

        radioHasWarranty.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] == "OPS");

        panelWarranty.Visible = (radioHasWarranty.SelectedValue == "1");

        checkIsGroupWJ.Enabled = (StoreID.Text == "") && !(RequestForQuotationItems.Rows.Count != 0 || RequestForQuotationItem_SubPanel.Visible);
        //listLocations.Enabled = (StoreID.Text == "") && !(RequestForQuotationItems.Rows.Count != 0 || RequestForQuotationItem_SubPanel.Visible);
        //checkIsGroupWJ.Enabled = (StoreID.Text == "") && !RequestForQuotationItem_SubPanel.Visible;
        listLocations.Enabled = (StoreID.Text == "") && !RequestForQuotationItem_SubPanel.Visible;
        gridLocations.Enabled = (StoreID.Text == "") && !RequestForQuotationItem_SubPanel.Visible;

        //20120209 ptb
        //only show BillTo/Contact once location is selected and only for ADMIN
        cbDeliverToOther.Visible = BillToContactPersonID.Visible = ddlBillTo.Visible = ddlLocation.Items[ddlLocation.SelectedIndex].Text.StartsWith("Admin");
        ddlDeliveryTo.Visible = DeliverToContactPersonID.Visible = (!cbDeliverToOther.Checked && cbDeliverToOther.Visible);
        DeliverToAddress.Visible = DeliverToPerson.Visible = (cbDeliverToOther.Checked && cbDeliverToOther.Visible);

        //Add CRV Link
        CRVWarning.Visible = CRVLink.Visible = RFQ.isSyncCRV;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="RFQ"></param>
    protected void HideShowTabAwardsControls(ORequestForQuotation RFQ)
    {
        // Show checkbox when status is not awarded
        // or budget distribution by line item.
        //
        gridAwardItems.CheckBoxColumnVisible =
            (!objectBase.CurrentObjectState.Is("Awarded") ||
            radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString());

        // 2011.06.29, Kien Trung
        // Allow user to decide to generate PO or LOA
        // regardless it's term contract or not. removed: !checkIsTermContract.Checked;
        // Customized for CCL
        //
        buttonGeneratePOFromLineItems.Visible = (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString());
        buttonGenerateLOAFromLineItems.Visible = (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString());
        buttonGeneratePO.Visible = (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.EntireAmount.ToString());
        buttonGenerateLOA.Visible = (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.EntireAmount.ToString());

        // Update the quotation policy hint.
        //
        hintQuotationPolicy.Text = RFQ.ValidateSufficientNumberOfQuotationsRequired();
        hintQuotationPolicy.Visible = (hintQuotationPolicy.Text != "");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="RFQ"></param>
    protected void HideShowTabVendorQuotationControls(ORequestForQuotation RFQ)
    {

        txtRFQTitle.ValidateRequiredField = checkIsTermContract.Checked;

        panelQuotationOptionalDetails.Visible = checkShowOptionalDetails.Checked;

        panelQuotationDetails.Visible =
            panelVendorAttachments.Visible = checkIsSubmitted.Checked;

        RequestForQuotationVendors.Enabled = !RequestForQuotationItem_SubPanel.Visible;

        ORequestForQuotationVendor rfqVendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        if (rfqVendor != null)
            textForeignToBaseExchangeRate.Enabled = !(rfqVendor.IsExchangeRateDefined == 1) && objectBase.CurrentObjectState.Is("Start", "Draft");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="RFQ"></param>
    protected void HideShowTabBudgetControls(ORequestForQuotation RFQ)
    {
        panelBudget2.Visible =
            ((!checkIsGroupWJ.Checked && ddlLocation.SelectedValue != "") || (checkIsGroupWJ.Checked && RFQ.GroupWJLocations != null)) &&
            DateRequired.DateTime != null && RFQ.NumberOfAwardedVendors > 0 &&
            //RFQ.ValidateSufficientNumberOfQuotations() != 0 &&
            RFQ.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;

        hintBudgetNotRequired.Visible = (RFQ.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired);

        //gridBudget.Visible = radioBudgetDistributionMode.SelectedValue != "";
        radioBudgetDistributionMode.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible && RFQ.NumberOfAwardedVendors <= 1;

        dropItemNumber.Visible = (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString());

        gridBudgetSummary.Visible = (gridBudgetSummary.Rows.Count > 0);

        // Allow approvers to amend budget account and accrual month in WJ
        if (objectBase.CurrentObjectState == "PendingApproval")
        {
            gridBudget.Enabled = rdlTerm.Enabled = checkUpFrontPayment.Enabled =
                textAddBudgetAmount.Enabled = dropLocation.Enabled =
                dropAddBudget.Enabled = dropAddBudgetItemNumber.Enabled = false;

            dateAddBudgetStartDate.Enabled = dateAddBudgetEndDate.Enabled =
                treeAddBudgetAccounts.Enabled = true;
        }
    }

    protected void HideShowTabBudgetReallocationControls(ORequestForQuotation RFQ)
    {
        //tessa comment out because budget reallocation is hidden
        panelReallocateFrom.Visible = (RFQ.RFQBudgetReallocationToPeriods != null && RFQ.RFQBudgetReallocationToPeriods.Count > 0)
            || (RFQ.RFQBudgetReallocationFromPeriods != null && RFQ.RFQBudgetReallocationFromPeriods.Count > 0) && RFQ.AutoCalculateReallocationTo == 1;

        gridReallocationToPeriod.Visible = RFQ.RFQBudgetReallocationToPeriods != null && RFQ.RFQBudgetReallocationToPeriods.Count > 0;

        bool fromBudgetSummaryVisible = RFQ.PurchaseBudgetSummaries != null && RFQ.PurchaseBudgetSummaries.Count > 0;
        gridReallocationFromPeriod.Columns[5].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[6].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[7].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[8].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[9].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[10].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[11].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[12].Visible = !fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[13].Visible = !fromBudgetSummaryVisible;

        gridReallocationFromPeriod.Columns[14].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[15].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[16].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[17].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[18].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[19].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[20].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[21].Visible = fromBudgetSummaryVisible;
        gridReallocationFromPeriod.Columns[22].Visible = fromBudgetSummaryVisible;
        //tessa end

        //gridReallocationFromPeriodSummary.Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriodTempSummary.Visible = !fromBudgetSummaryVisible;

        //ddlLocation.Enabled = rfq.IsNew;
        SetReallocationTo();//tessa comment out //tessa end
    }

    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        //panel.ObjectPanel.BindControlsToObject(rfq);

        // Hide and show controls under detail tabs
        //
        HideShowTabDetailsControls(rfq);

        // Hide and show controls under Line Item tab.
        //
        HideShowTabLineItemsControls(rfq);

        // Hide and show controls under award tab.
        //
        HideShowTabAwardsControls(rfq);

        // Hide and show controls under vendor quotation tab.
        //
        HideShowTabVendorQuotationControls(rfq);

        // Hide and show controls under budget tab.
        //
        HideShowTabBudgetControls(rfq);

        // Budget reallocation panel
        //
        HideShowTabBudgetReallocationControls(rfq);

        Workflow_Setting(rfq);

        if (dropAddBudget.Text == "")
        {
            dropLocation.Text = "";
            //textAddBudgetAmount.Text = "0";
        }

        // 2010.12.22
        // Kim Foong
        // For IT only,
        // Show the delegate to HOD hint if the WJ amount is equal or above
        // $100,000. Note that this figure is currently harcoded
        // for simplicity.
        //
        //IsDelegatedToHODHint.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] == "IT") &&
        //    rfq.TaskAmount >= 100000;
        IsDelegatedToHODHint.Visible = false;

        //Panel_Requestor.Visible = !checkIsGroupWJ.Checked;

        Panel_Requestor.Visible = checkIsCharged.Checked;
        searchTenantLease.ButtonClear.Visible = (rfq.RequestorID != null);

        CRVSetting(rfq);//Nguyen Quoc Phuong 21-Nov-2012
    }

    //Nguyen Quoc Phuong 20-Nov-2012
    private void BindCRVSerialNumbers()
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;

        if (string.IsNullOrEmpty(rfq.SystemCode)) return;
        OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
        string[] ActiveCRVSerialNumbers = CRVTenderService.GetActiveCRVSerialNumbers(rfq.SystemCode);
        if (ActiveCRVSerialNumbers == null)
        {
            panel.Message = Resources.Errors.CRVTenderService_ConnectionFail;
            dropCRVSerialNumbers.ErrorMessage = Resources.Errors.CRVTenderService_ConnectionFail;
            return;
        }
        DataTable ActiveCRVSerialNumberDT = new DataTable();
        ActiveCRVSerialNumberDT.TableName = "CRVTenders";
        ActiveCRVSerialNumberDT.Columns.Add("CRVSerialNumber");
        ActiveCRVSerialNumberDT.Columns.Add("CRVProjectReferenceNo");
        ActiveCRVSerialNumberDT.Columns.Add("CRVProjectTitle");
        ActiveCRVSerialNumberDT.Columns.Add("CRVProjectDescription");
        foreach (string str in ActiveCRVSerialNumbers)
        {
            string[] parts = str.Split('|');
            DataRow dr = ActiveCRVSerialNumberDT.NewRow();
            dr["CRVSerialNumber"] = parts[0];
            dr["CRVProjectReferenceNo"] = parts[2];
            dr["CRVProjectTitle"] = parts[4];
            dr["CRVProjectDescription"] = parts[6];
            ActiveCRVSerialNumberDT.Rows.Add(dr);
        }
        dropCRVSerialNumbers.Bind(ActiveCRVSerialNumberDT, "CRVSerialNumber", "CRVSerialNumber");
        dropCRVSerialNumbers.SelectedValue = rfq.CRVSerialNumber;

        Session["CRVTendersDataTable"] = ActiveCRVSerialNumberDT;
        //panel.ObjectPanel.BindObjectToControls(rfq);
    }
    //End Nguyen Quoc Phuong 20-Nov-2012

    //Nguyen Quoc Phuong 20-Nov-2012
    protected void dropCRVSerialNumbers_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(dropCRVSerialNumbers.SelectedValue))
        {
            buttonClearTenders_Click(buttonClearTenders, null);
            return;
        }
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        DataTable ActiveCRVSerialNumberDT = Session["CRVTendersDataTable"] as DataTable;
        DataRow[] rows = ActiveCRVSerialNumberDT.Select("CRVSerialNumber = '" + dropCRVSerialNumbers.SelectedValue + "'");
        rfq.CRVProjectTitle = rows[0]["CRVProjectTitle"].ToString();
        rfq.CRVProjectReferenceNo = rows[0]["CRVProjectReferenceNo"].ToString();
        rfq.CRVProjectDescription = rows[0]["CRVProjectDescription"].ToString();
        panel.ObjectPanel.BindObjectToControls(rfq);

        buttonClearTenders_Click(buttonClearTenders, e);
    }
    //End Nguyen Quoc Phuong 20-Nov-2012

    //Nguyen Quoc Phuong 21-Nov-2012
    protected void buttonRetrieveTenders_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(dropCRVSerialNumbers.SelectedValue)) return;
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        List<string> CRVVendorIDNotFoundInCAMPS = ORequestForQuotationVendor.CreateRFQVendorFromCRVTender(dropCRVSerialNumbers.SelectedValue, rfq);
        if (CRVVendorIDNotFoundInCAMPS == null)
            panel.Message = Resources.Errors.CRVTenderService_ConnectionFail;
        if (CRVVendorIDNotFoundInCAMPS.Count > 0)
            panel.Message = string.Format(Resources.Strings.CRVVendorIDNotFoundInCAMPS, string.Join(", ", (CRVVendorIDNotFoundInCAMPS.ToArray() as string[])));
        //else RequestForQuotationVendors.ErrorMessage = string.Empty;

        panel.ObjectPanel.BindObjectToControls(rfq);
    }
    //End Nguyen Quoc Phuong 21-Nov-2012

    //Nguyen Quoc Phuong 21-Nov-2012
    protected void buttonClearTenders_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        if (rfq.isSyncCRV)
        {
            rfq.RequestForQuotationVendors.Clear();
            panel.ObjectPanel.BindObjectToControls(rfq);
        }
    }
    //End Nguyen Quoc Phuong 21-Nov-2012

    //Nguyen Quoc Phuong 21-Nov-2012
    public void CRVSetting(ORequestForQuotation rfq)
    {
        //panel.ObjectPanel.BindControlsToObject(rfq);
        if (!IsPostBack && rfq.isSyncCRV)
        {
            Session["CRVTendersDataTable"] = null;
            //ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;

            if (rfq.GroupRequestForQuotation == null && rfq.CurrentActivity.ObjectName.Is("Draft", "Start")) BindCRVSerialNumbers();
            else
            {
                DataTable ActiveCRVSerialNumberDT = new DataTable();
                ActiveCRVSerialNumberDT.TableName = "CRVTenders";
                ActiveCRVSerialNumberDT.Columns.Add("CRVSerialNumber");
                ActiveCRVSerialNumberDT.Columns.Add("CRVProjectReferenceNo");
                ActiveCRVSerialNumberDT.Columns.Add("CRVProjectTitle");
                ActiveCRVSerialNumberDT.Columns.Add("CRVProjectDescription");
                DataRow dr = ActiveCRVSerialNumberDT.NewRow();
                dr["CRVSerialNumber"] = rfq.CRVSerialNumber;
                dr["CRVProjectReferenceNo"] = rfq.CRVProjectReferenceNo;
                dr["CRVProjectTitle"] = rfq.CRVProjectTitle;
                dr["CRVProjectDescription"] = rfq.CRVProjectDescription;
                ActiveCRVSerialNumberDT.Rows.Add(dr);

                dropCRVSerialNumbers.Bind(ActiveCRVSerialNumberDT, "CRVSerialNumber", "CRVSerialNumber");
                Session["CRVTendersDataTable"] = ActiveCRVSerialNumberDT;
                panel.ObjectPanel.BindObjectToControls(rfq);
            }
        }
        //RequestForQuotationVendors.Visible = rfq.PurchaseType != null ? rfq.PurchaseType.RequiredCRVSerialNumber != 1 : true;
        dropVendor.Enabled =
        RequestForQuotationVendors.Columns[1].Visible =
        RequestForQuotationVendors.Commands[0].Visible =
        RequestForQuotationVendors.Commands[1].Visible =
        RequestForQuotationVendors.Commands[2].Visible =
        RequestForQuotationVendors_SubPanel.UpdateAndNewButtonVisible = !rfq.isSyncCRV;
        //gridAwardItems.Columns[gridAwardItemsColumn.AwardedDate].Visible =
        //AwardedDate.Visible =
        panelCRV.Visible = rfq.isSyncCRV;
        panelCRV.Enabled = rfq.GroupRequestForQuotation == null;//Nguyen Quoc Phuong 17-Dec-2012
        //if (string.IsNullOrEmpty(dropCRVSerialNumbers.SelectedValue)) buttonClearTenders_Click(buttonClearTenders, null);
    }
    //End Nguyen Quoc Phuong 21-Nov-2012

    /// <summary>
    /// Hides/shows or enables/disables elements according to workflow.
    /// </summary>
    protected void Workflow_Setting(ORequestForQuotation RFQ)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        ORequestForQuotationVendor rfqVendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;

        string stateAndAction = objectBase.CurrentObjectState + "::" + objectBase.SelectedAction;

        string state = objectBase.CurrentObjectState;
        string action = objectBase.SelectedAction;

        panelDetails2.Enabled = !state.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelDateRequired.Enabled = !state.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelHasWarranty.Enabled = !state.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        tabLineItems.Enabled = !state.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        tabQuotations.Enabled = !state.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelBudget2.Enabled = !state.Is("Awarded", "Close", "Cancelled");
        panelReallocateFrom.Enabled = !state.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelAwardVendor.Visible = !state.Is("PendingApproval", "Awarded", "Close", "Cancelled");

        panelAward.Enabled = !state.Is("Awarded", "Close", "Cancelled");
        panelBackgroundScope.Enabled = !state.Is("Awarded", "Close", "Cancelled");
        //panelGeneratePOButton.Visible = state.Is("Awarded");
        panelGeneratePOButton.Visible = state.Is("Awarded") && rfq.IsGroupWJ != 1;//Nguyen Quoc Phuong 17-Dec-2012

        textAwardedJustification.ValidateRequiredField =
            dropBackgroundType.ValidateRequiredField =
            dropPurchaseTypeClassification.ValidateRequiredField =
            dropPurchaseType.ValidateRequiredField =
            DateRequired.ValidateRequiredField =
            DateEnd.ValidateRequiredField =
            radioHasWarranty.ValidateRequiredField =
            BudgetGroupID.ValidateRequiredField =
            ddlBillTo.ValidateRequiredField =
            BillToContactPersonID.ValidateRequiredField =
            ddlDeliveryTo.ValidateRequiredField =
            DeliverToContactPersonID.ValidateRequiredField =
            cbDeliverToOther.ValidateRequiredField =
            dropCRVSerialNumbers.ValidateRequiredField = action.Is("SubmitForApproval", "Approve");

        gridBudget.ValidateRequiredField =
            !(RFQ.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired) &&
            action.Is("SubmitForApproval", "CreateChildRFQs");

        //dropPurchaseType.ValidateRequiredField = !(state.Is("Draft") && action.Is("Cancel"));

        // Hide Cancel button when it's in Pending Approval.
        //
        ListItem cancel = objectBase.GetWorkflowRadioListItem("Cancel");
        if (cancel != null)
            cancel.Enabled = !state.Is("PendingApproval");

        // Hide Close Button when it's in Approved.
        // 2011.10.13, Kien Trung
        //
        ListItem close = objectBase.GetWorkflowRadioListItem("Close");
        if (close != null)
            close.Enabled = !state.Is("Awarded");

        // Hide Award action regardless any status.
        //
        ListItem itemAward = objectBase.GetWorkflowRadioListItem("Award");
        if (itemAward != null)
            itemAward.Enabled = false;

        //
        ListItem submitforapproval = objectBase.GetWorkflowRadioListItem("SubmitForApproval");
        if (submitforapproval != null)
            submitforapproval.Enabled =
                ((!checkIsGroupWJ.Checked && IsGroupApproval.Checked) ||
                !(checkIsGroupWJ.Checked && !IsGroupApproval.Checked)) &&
                !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");

        //
        ListItem createchildrfq = objectBase.GetWorkflowRadioListItem("CreateChildRFQs");
        if (createchildrfq != null)
            createchildrfq.Enabled = (checkIsGroupWJ.Checked && !IsGroupApproval.Checked && state.Is("Start", "Draft") ||
                (checkIsGroupWJ.Checked && IsGroupApproval.Checked && state.Is("Awarded")));

        buttonRefreshCRVSerialNumbers.Visible = 
            dropCRVSerialNumbers.Enabled = rfq.CurrentActivity.ObjectName.Is("Start", "Draft");

    }

    /// <summary>
    /// Binds data to the requestor drop down list.
    /// </summary>
    /// <param name="currentRFQ"></param>
    protected void BindRequestor(ORequestForQuotation currentRFQ)
    {
        //RequestorID.Bind(OUser.GetCaseRequestorsOrTenants(currentRFQ.Location));
    }

    /// <summary>
    ///
    /// </summary>
    private void SetReallocationTo()
    {
        bool enable = !AutoCalculateReallocationTo.Checked;

        foreach (GridViewRow gvr in gridReallocationToPeriod.Rows)
        {
            UIFieldTextBox tb = gvr.FindControl("textTotalAmount") as UIFieldTextBox;
            if (tb != null)
                tb.Enabled = enable;
        }
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
            requestForQuotationItem.QuantityRequired = 1.0M;
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
            ORequestForQuotationItem RFQI = RequestForQuotationItem_SubPanel.SessionObject as ORequestForQuotationItem;

            RequestForQuotationItem_SubPanel.ObjectPanel.BindControlsToObject(RFQI);

            foreach (ORequestForQuotationItemLocation RFQIL in RFQI.RequestForQuotationItemLocation)
                RFQIL.QuantityRequired = 1;

            RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(RFQI);
        }

        //
        //
        if (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString())
        {
            ORequestForQuotationItem RFQI = RequestForQuotationItem_SubPanel.SessionObject as ORequestForQuotationItem;
            RequestForQuotationItem_SubPanel.ObjectPanel.BindControlsToObject(RFQI);
            RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(RFQI);
            //if (!RFQI.IsNew)
            //{
            //    ORequestForQuotationItem Rfqitem = TablesLogic.tRequestForQuotationItem.Load(RFQI.ObjectID);
            //    RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(Rfqitem);
            //}
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

        // 2011.09.20, Kien Trung
        // Default Additional Description if additional description is blank.
        //
        if (i.CatalogueID != null)
            i.AdditionalDescription =
                (i.AdditionalDescription != null && i.AdditionalDescription.Trim() != "" ? i.AdditionalDescription : i.Catalogue.ObjectName);

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

        // 2011.09.20, Kien Trung
        // Default Additional description from the selected fixed rate if it's blank.
        //
        if (i.FixedRateID != null)
            i.AdditionalDescription =
                (i.AdditionalDescription != null && i.AdditionalDescription.Trim() != "" ? i.AdditionalDescription : i.FixedRate.ObjectName);

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
        else if (commandName == "PrintRFQ")
        {
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            ORequestForQuotationVendor rfqVendor = null;
            foreach (ORequestForQuotationVendor vendor in rfq.RequestForQuotationVendors)
            {
                if (vendor.ObjectID == new Guid(objectIds[0].ToString()))
                {
                    rfqVendor = vendor;
                    break;
                }
            }
            Session["RFQVendor"] = rfqVendor;
            panel.FocusWindow = false;
            Window.Open("../../components/document.aspx" +
                "?templateID=" + HttpUtility.UrlEncode(Security.EncryptToHex("F5545B3A-E0D1-4D40-A958-527EB02ACC08")) +
                "&session=" + "RFQVendor" +
                "&format=" + HttpUtility.UrlEncode(Security.Encrypt("word")));
        }

        if (commandName == "AddVendors")
        {
            searchMultipleVendor.Show();
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

        ORequestForQuotationVendor IPTVendor =
            requestForQuotation.RequestForQuotationVendors.Find(lf => lf.Vendor.IsInterestedParty == 1);

        if (IPTVendor == null) IPTVendorGridWarning.Visible = false;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="purchaseOrderType"></param>
    protected void GeneratePO(int purchaseOrderType)
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
        {
            if (rfqi.AwardedVendorID != null)
            {
                items.Add(rfqi);
                rfqItemIds.Add(rfqi.ObjectID.Value);
            }
        }

        DataTable dt = ORequestForQuotation.ValidateRFQLineItemsNotGeneratedToPOforCCL(rfqItemIds);
        foreach (DataRow dr in dt.Rows)
        {
            rfqItemIds.Remove(new Guid(dr["RequestForQuotationItemID"].ToString()));
            foreach (ORequestForQuotationItem rfqi in rfq.RequestForQuotationItems)
            {
                if (rfqi.ObjectID.ToString() == dr["RequestForQuotationItemID"].ToString())
                    items.Remove(rfqi);
            }
        }

        if (rfqItemIds.Count == 0)
        {
            StringBuilder sb = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
                sb.Append(dr["ItemNumber"].ToString() + ". " + dr["ItemDescription"].ToString() + "<br/>");
            string lineItems = sb.ToString();
            if (lineItems.Length != 0)
            {
                panel.Message = String.Format(Resources.Errors.RequestForQuotation_LineItemsAlreadyGeneratedIntoRFQOrPOs, lineItems);
                return;
            }
        }

        // Validates that all line items are awarded to a single vendor.
        //
        if (!ORequestForQuotation.ValidateRFQLineItemsAwardedToSingleVendor(rfqItemIds))
        {
            panel.Message = Resources.Errors.RequestForQuotation_LineItemsNotAwardedToASingleVendor;
            return;
        }

        ViewState["PurchaseOrderType"] = purchaseOrderType;

        popupGeneratePO.Show();

        gridGeneratePO.Bind(items);

    }

    /// <summary>
    /// Occurs when the user clicks on the Generate PO from RFQ button.
    /// This generates a PO from all the line items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePO_Click(object sender, EventArgs e)
    {
        popupGeneratePO.Title = "Are you sure you wish to generate Purchase Order for these Work Justification items?";
        GeneratePO(PurchaseOrderType.PO);
    }

    /// <summary>
    /// Occurs when the user clicks on the Generate PO from RFQ button.
    /// This generates a PO from all the line items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGenerateLOA_Click(object sender, EventArgs e)
    {
        popupGeneratePO.Title = "Are you sure you wish to generate LOA for these Work Justification items?";
        GeneratePO(PurchaseOrderType.LOA);
    }

    protected void GeneratePOFromLineItems(int purchaseOrderType)
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

            StringBuilder sb = new StringBuilder();
            DataTable dt = ORequestForQuotation.ValidateRFQLineItemsNotGeneratedToPOforCCL(rfqItemIds);
            foreach (DataRow dr in dt.Rows)
                sb.Append(dr["ItemNumber"].ToString() + ". " + dr["ItemDescription"].ToString() + "<br/>");
            string lineItems = sb.ToString();
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

            ViewState["PurchaseOrderType"] = purchaseOrderType;

            popupGeneratePO.Show();
            gridGeneratePO.Bind(items);

        }
        else
        {
            RequestForQuotationItems.ErrorMessage = Resources.Errors.RequestForQuotation_NoRFQItemsSelected;
            panel.Message = Resources.Errors.RequestForQuotation_NoRFQItemsSelected;
        }
    }

    /// <summary>
    /// Occurs when the user clicks on the Generate PO from Selected Line Items
    /// button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePOFromLineItems_Click(object sender, EventArgs e)
    {
        popupGeneratePO.Title = "Are you sure you wish to generate Purchase Order for these Purchase Requisition items?";
        GeneratePOFromLineItems(PurchaseOrderType.PO);
    }

    /// <summary>
    /// Occurs when the user clicks on the Generate PO from Selected Line Items
    /// button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGenerateLOAFromLineItems_Click(object sender, EventArgs e)
    {
        popupGeneratePO.Title = "Are you sure you wish to generate LOA for these Purchase Requisition items?";
        GeneratePOFromLineItems(PurchaseOrderType.LOA);
    }

    /// <summary>
    /// Occurs when use click bottom right dialog box
    /// to generate PO or LOA.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void popupGeneratePO_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        if (e.CommandName == "Confirm")
        {
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);

            //Nguyen Quoc Phuong 10-Dec-2012
            if (rfq.isSyncCRV)
            {
                if (string.IsNullOrEmpty(rfq.SystemCode))
                {
                    panel.Message = Resources.Errors.CRVTenderService_SystemCodeNotFound;
                    return;
                }
                OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
                int? CRVNoOfContracts = CRVTenderService.GetTenderNoOfContracts(rfq.SystemCode, rfq.CRVSerialNumber);
                if (CRVNoOfContracts == null)
                {
                    panel.Message = Resources.Errors.CRVTenderService_ConnectionFail;
                    return;
                }
                //else if (CRVNoOfContracts == (int)EnumCRVGetTenderNoOfContracts.TENDERNOTFOUND)
                //{
                //    panel.Message = Resources.Errors.CRVTenderService_TenderNotFound;
                //    return;
                //}
                else if (rfq.NumberOfPOGenerated >= CRVNoOfContracts)
                {
                    panel.Message = Resources.Errors.CRVTenderService_NumberOfContractsLimitationReached;
                    return;
                }
            }
            //End Nguyen Quoc Phuong 10-Dec-2012

            List<ORequestForQuotationItem> items = new List<ORequestForQuotationItem>();
            items.Clear();
            foreach (GridViewRow row in gridGeneratePO.Rows)
            {
                Guid itemID = (Guid)gridGeneratePO.DataKeys[row.RowIndex][0];
                ORequestForQuotationItem item = TablesLogic.tRequestForQuotationItem.Load(itemID);

                UIFieldTextBox tb = row.FindControl("generateQty") as UIFieldTextBox;
                if (tb != null && tb.Text == "")
                {
                    tb.ErrorMessage = "'Order Quantity' is required.";
                    return;
                }

                decimal orderQuantity = Convert.ToDecimal(tb.Text);
                decimal quantityRequired = Convert.ToDecimal(row.Cells[4].Text);
                decimal quantityOrdered = Convert.ToDecimal(row.Cells[5].Text);

                if (orderQuantity > (quantityRequired - quantityOrdered))
                {
                    tb.ErrorMessage = "Quantity exceeded the quantity available to order.";
                    return;
                }

                if (orderQuantity < 0)
                {
                    tb.ErrorMessage = "Order Quantity cannot be below zero.";
                    return;
                }

                item.OrderQuantity = orderQuantity;
                items.Add(item);
            }

            // Get PO or LOA Type.
            //
            int? purchaseOrderType = ViewState["PurchaseOrderType"] as int?;

            // Generate PO object.
            //
            if (rfq.IsGroupWJ == 1)
            {
                List<ORequestForQuotation> childWJs = new List<ORequestForQuotation>();
                using (Connection c = new Connection())
                {
                    childWJs = ORequestForQuotation.CreateRFQFromGroupRFQ(rfq);
                    rfq.TriggerWorkflowEvent("Close");
                    c.Commit();
                }

                foreach (ORequestForQuotation wj in childWJs)
                {
                    List<ORequestForQuotationItem> childItems = new List<ORequestForQuotationItem>();
                    foreach (ORequestForQuotationItem item in wj.RequestForQuotationItems)
                    {
                        item.OrderQuantity = item.QuantityProvided;
                        childItems.Add(item);
                    }
                    OPurchaseOrder.CreatePOFromRFQLineItems(childItems, purchaseOrderType.Value);
                }

                panel.Message = "Child PO(s) have been generated sucessfully.";
            }
            else
            {
                OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQLineItems(items, purchaseOrderType.Value);

                // Open edit object page.
                //
                if (po != null)
                    Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.Value.ToString(), "");
                else
                    //panel.Message = "Unable to generate PO / LOA because there is no avaiable items to issue.";
                    panel.Message = "Unable to generate PO / LOA.";
            }

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

        //dropVendor.Bind(OVendor.GetVendors(DateTime.Today, rfqVendor.VendorID));
        dropVendor.Bind(OVendor.GetVendors(DateTime.Today, rfqVendor.VendorID, AppSession.User, Security.Decrypt(Request["TYPE"])));
        if (rfqVendor.Vendor != null)
            ddlContactPerson.Bind(rfqVendor.Vendor.VendorContacts);
        dropCurrency.Bind(OCurrency.GetAllCurrencies(rfqVendor.CurrencyID), "CurrencyNameAndDescription", "ObjectID", true);

        if (RequestForQuotationVendors_SubPanel.IsAddingObject)
        {
            rfqVendor.UpdateExchangeRate();
            rfq.CreateRequestForQuotationVendorItems(rfqVendor);
        }

        SetGridViewCurrency();

        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(rfqVendor);

        // 2010.10.18
        // Kim Foong
        // For ops, make the Quotation Reference Number compulsory.
        //
        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "OPS")
            textQuotationReferenceNumber.ValidateRequiredField = true;

        IPTVendorSubpanelWarning.Visible = false;
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
                ddlContactPerson.Bind(vendor.VendorContacts);
                ddlContactPerson.Items[0].Text = Resources.Strings.RFQVendor_ContactPerson;
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

                if (vendor.IsInterestedParty.HasValue)
                {
                    IPTVendorSubpanelWarning.Visible = vendor.IsInterestedParty == 1;
                }
                else
                    IPTVendorSubpanelWarning.Visible = false;
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

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldTextBox recoverableamount = e.Row.FindControl("RecoverableAmount") as UIFieldTextBox;
            UIFieldTextBox quantityprovided = e.Row.FindControl("QuantityProvided") as UIFieldTextBox;
            UIFieldTextBox unitprice = e.Row.FindControl("UnitPrice") as UIFieldTextBox;
            UIFieldLabel subtotal = e.Row.FindControl("labelSubTotal") as UIFieldLabel;

            if (recoverableamount != null)
            {
                e.Row.Cells[8].Visible = checkRecoverable.Checked;
                //e.Row.Cells[8].Visible = (rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.Recoverable).ToString());
                recoverableamount.DataFormatString = "{0:#,##0.00##}";
            }

            //
            if (unitprice != null)
            {
                unitprice.DataFormatString = "{0:#,##0.00##}";

                string onchange = "computeSubTotal('" + unitprice.Control.ClientID + "','" + quantityprovided.Control.ClientID + "','" + subtotal.Control.ClientID + "'); ";

                if (checkRecoverable.Checked)
                    onchange += "computeRecoverable('" + unitprice.Control.ClientID + "','" + quantityprovided.Control.ClientID + "','" + recoverableamount.Control.ClientID + "'); ";

                unitprice.Control.Attributes["onchange"] = onchange;
                quantityprovided.Control.Attributes["onchange"] = onchange;
            }

        }

        // Hide or show charge amount, recoverable amount header
        //
        if (e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.DataRow)
        {
            //e.Row.Cells[7].Visible = checkIsCharged.Checked;
            //e.Row.Cells[8].Visible = rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.Recoverable).ToString();
            e.Row.Cells[8].Visible = checkRecoverable.Checked;
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
    /// When checked, rich text box will appear to let user key in Address / Contact Name
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void cbDeliverToOther_CheckedChanged(object sender, EventArgs e)
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
            // 2010.10.18
            // Kim Foong
            // For ops, do NOT default the quotation date; it must be left blank.
            //
            if (ConfigurationManager.AppSettings["CustomizedInstance"] != "OPS")
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
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        if (dropVendorToAward.SelectedValue == "")
        {
            return;
        }
        if (gridAwardItems.GetSelectedKeys().Count == 0)
        {
            dropVendorToAward.SelectedIndex = 0;
            return;
        }
        //if (rfq.isSyncCRV && AwardedDate.DateTime == null)
        //{
        //    AwardedDate.ErrorMessage = Resources.Errors.RequestForQuotation_AwardedDateMissing;
        //    dropVendorToAward.SelectedIndex = 0;
        //    return;
        //}

        List<object> keys = gridAwardItems.GetSelectedKeys();
        List<Guid> rfqItemIds = new List<Guid>();
        foreach (Guid rfqItemId in keys)
            rfqItemIds.Add(rfqItemId);

        Guid vendorId = new Guid(dropVendorToAward.SelectedValue);
        rfq.AwardLineItemsToVendor(vendorId, rfqItemIds, null);
        rfq.UpdateBudgetAmount();
        panel.ObjectPanel.BindObjectToControls(rfq);

        dropVendorToAward.SelectedIndex = 0;

        OVendor awardedVendor = TablesLogic.tVendor.Load(vendorId);
        if (awardedVendor.IsInterestedParty.HasValue && awardedVendor.IsInterestedParty == 1)
            IPTVendorAwardWarning.Visible = true;
    }

    /// <summary>
    /// Update Budget Amount.
    /// </summary>
    /// <param name="requestForQuotation"></param>
    protected void UpdateBudgetAmount(ORequestForQuotation requestForQuotation)
    {
        if (requestForQuotation.PurchaseBudgets.Count == 1)
        {
            decimal? amount = 0;
            foreach (ORequestForQuotationItem item in requestForQuotation.RequestForQuotationItems)
                if (item.Subtotal != null)
                    amount += item.Subtotal;
            requestForQuotation.PurchaseBudgets[0].Amount = amount;
        }
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

        ORequestForQuotationItem IPTVendorAwardedItem =
            rfq.RequestForQuotationItems.Find(lf => lf.AwardedVendor != null
                                                 && lf.AwardedVendor.IsInterestedParty == 1);

        if (IPTVendorAwardedItem == null) IPTVendorAwardWarning.Visible = false;
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

        if (subpanelBudget.IsAddingObject)
        {
            if (BudgetGroupID.SelectedValue != "")
            {
                if (!checkIsGroupWJ.Checked)
                    dropAddBudget.Bind(OBudget.GetCoveringBudgets(rfq.Location, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
                else
                {
                    List<OLocation> locations = new List<OLocation>();
                    foreach (OLocation location in rfq.GroupWJLocations)
                        locations.Add(location);
                    dropAddBudget.Bind(OBudget.GetCoveringBudgets(locations, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
                }
            }

            dropAddBudgetItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString();
            dropAddBudgetItemNumber.Items.Clear();
            for (int i = 1; i <= rfq.RequestForQuotationItems.Count; i++)
                dropAddBudgetItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

            dateAddBudgetStartDate.DateTime = rfq.DateRequired;
            dateAddBudgetEndDate.DateTime = rfq.DateEnd;

            if (dropAddBudget.Items.Count == 2)
            {

                dropAddBudget.SelectedIndex = 1;
                treeAddBudgetAccounts.PopulateTree();
                if (checkIsGroupWJ.Checked)
                {
                    OBudget budget = LogicLayer.TablesLogic.tBudget.Load(new Guid(dropAddBudget.SelectedValue));
                    dropLocation.Bind(budget.ApplicableLocations);
                    if (budget.ApplicableLocations.Count == 1)
                    {
                        //dropLocation.Text == budget.ApplicableLocations[0].ObjectName();
                        dropLocation.SelectedValue = budget.ApplicableLocations[0].ObjectID.Value.ToString();
                    }
                }
            }

            Guid? accountID = GetApplicableAccountID();
            if (accountID != null)
                treeAddBudgetAccounts.SelectedValue = accountID.ToString();

            AutoComputeBudgetAmount(rfq);

        }

        else
        {
            if (BudgetGroupID.SelectedValue != "")
            {
                if (!checkIsGroupWJ.Checked)
                {
                    dropAddBudget.Bind(OBudget.GetCoveringBudgets(rfq.Location, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
                }
                else
                {
                    List<OLocation> locations = new List<OLocation>();
                    foreach (OLocation location in rfq.GroupWJLocations)
                        locations.Add(location);
                    dropAddBudget.Bind(OBudget.GetCoveringBudgets(locations, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
                }
            }

            dropAddBudgetItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == "1";
            dropAddBudgetItemNumber.Items.Clear();
            for (int i = 1; i <= rfq.RequestForQuotationItems.Count; i++)
                dropAddBudgetItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

            dateAddBudgetStartDate.DateTime = rfq.DateRequired;
            dateAddBudgetEndDate.DateTime = rfq.DateEnd;

            if (dropAddBudget.Items.Count == 2)
            {
                dropAddBudget.SelectedIndex = 1;
                treeAddBudgetAccounts.PopulateTree();
                if (checkIsGroupWJ.Checked)
                {
                    OBudget budget = LogicLayer.TablesLogic.tBudget.Load(new Guid(dropAddBudget.SelectedValue));
                    dropLocation.Bind(budget.ApplicableLocations);
                    if (budget.ApplicableLocations.Count == 1)
                    {
                        //dropLocation.Text == budget.ApplicableLocations[0].ObjectName();
                        dropLocation.SelectedValue = budget.ApplicableLocations[0].ObjectID.Value.ToString();
                    }
                }
            }
            //Guid? accountId = GetApplicableAccountID();
            //if (accountId != null)
            treeAddBudgetAccounts.SelectedValue = prBudget.AccountID.ToString();

            subpanelBudget.ObjectPanel.BindObjectToControls(prBudget);
        }

        rdlTerm.Visible = checkUpFrontPayment.Visible = subpanelBudget.IsAddingObject;
        //populateAccount();

        //ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        //panel.ObjectPanel.BindControlsToObject(rfq);

        //OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;

        //if (BudgetGroupID.SelectedValue != "")
        //{
        //    if (!checkIsGroupWJ.Checked)
        //    {
        //        dropBudget.Bind(OBudget.GetCoveringBudgets(rfq.Location, prBudget.BudgetID, new Guid(BudgetGroupID.SelectedValue)));
        //    }
        //    else
        //    {
        //        List<OLocation> locations = new List<OLocation>();
        //        foreach (OLocation location in rfq.GroupWJLocations)
        //            locations.Add(location);
        //        dropBudget.Bind(OBudget.GetCoveringBudgets(locations, prBudget.BudgetID, new Guid(BudgetGroupID.SelectedValue)));
        //    }
        //}

        //if (subpanelBudget.IsAddingObject)
        //{
        //    if (dropBudget.Items.Count == 2)
        //        prBudget.BudgetID = new Guid(dropBudget.Items[1].Value);
        //    prBudget.StartDate = rfq.DateRequired;
        //    prBudget.EndDate = rfq.DateRequired;
        //}

        //dropItemNumber.Items.Clear();
        //for (int i = 1; i <= rfq.RequestForQuotationItems.Count; i++)
        //    dropItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        //populateAccount();
        //subpanelBudget.ObjectPanel.BindObjectToControls(prBudget);
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
            bool upFrontPaid = checkUpFrontPayment.Checked;
            int count = 0;
            decimal amount = Convert.ToDecimal(textAddBudgetAmount.Text);
            int terms = 1;
            if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.Monthly)
                terms = 1;
            else if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.Quaterly)
                terms = 3;
            else if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.HalfYearly)
                terms = 6;
            else if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.Yearly)
                terms = 12;
            for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(terms))
                count++;

            int c = 0;
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(terms))
            {
                OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
                if (dropLocation.SelectedValue != "")
                    pb.LocationID = new Guid(dropLocation.SelectedValue);
                else
                    pb.LocationID = null;
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
                pb.BudgetID = new Guid(dropAddBudget.SelectedValue);
                pb.StartDate = d;
                pb.EndDate = d;
                pb.AccrualFrequencyInMonths = terms;
                pb.AccountID = new Guid(treeAddBudgetAccounts.SelectedValue);
                pb.Amount = 0.0M;

                if (c == 0 && upFrontPaid)
                    pb.Amount = amount;
                else if ((c != count - 1) && !upFrontPaid)
                    pb.Amount = Math.Round(amount / count, 2, MidpointRounding.AwayFromZero);
                else if (!upFrontPaid)
                    pb.Amount = amount - Math.Round(amount / count, 2, MidpointRounding.AwayFromZero) * (count - 1);

                rfq.PurchaseBudgets.Add(pb);
                c++;
            }

            if (rfq.CurrentActivity == null ||
                !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
            {
                rfq.ComputeTempBudgetSummaries();
                //tessa comment out because of the hiding of budget reallocation
                rfq.ComputeBudgetReallocationToPeriods();
                rfq.UpdateTempBudgetSummaryWithReallocation();//tessa end
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";

                PopulateDropFromBudget(rfq);
            }

            tabBudget.BindObjectToControls(rfq);
        }
        else
        {
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);

            OPurchaseBudget prBudget = subpanelBudget.SessionObject as OPurchaseBudget;
            subpanelBudget.ObjectPanel.BindControlsToObject(prBudget);

            prBudget.EndDate = prBudget.StartDate;
            prBudget.AccrualFrequencyInMonths = 1;

            // Validate
            //

            // Insert
            //
            rfq.PurchaseBudgets.Add(prBudget);

            if (rfq.CurrentActivity == null ||
                !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled"))
            {
                rfq.ComputeTempBudgetSummaries();
                //tessa comment out because of the hiding of budget reallocation
                rfq.ComputeBudgetReallocationToPeriods();
                rfq.UpdateTempBudgetSummaryWithReallocation();//tessa end
                gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";

                PopulateDropFromBudget(rfq);

            }

            panel.ObjectPanel.BindObjectToControls(rfq);
        }
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
            !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            rfq.ComputeTempBudgetSummaries();
            //tessa comment out because of the hiding of budget reallocation
            rfq.ComputeBudgetReallocationToPeriods();
            rfq.UpdateTempBudgetSummaryWithReallocation();//tessa end
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

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropPurchaseType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        //int IsRequireCRVSerialNumberBefore = rfq.PurchaseType == null ? 0 : (rfq.PurchaseType.RequiredCRVSerialNumber == 1 ? 1 : 0);//Nguyen Quoc Phuong 20-Nov-2012
        bool IsRequireCRVSerialNumberBefore = rfq.isSyncCRV;//Nguyen Quoc Phuong 17-Dec-2012
        panel.ObjectPanel.BindControlsToObject(rfq);
        rfq.UpdateApplicablePurchaseSettings();
        //Nguyen Quoc Phuong 20-Nov-2012
        //int IsRequireCRVSerialNumberAfter = rfq.PurchaseType == null ? 0 : (rfq.PurchaseType.RequiredCRVSerialNumber == 1 ? 1 : 0);
        bool IsRequireCRVSerialNumberAfter = rfq.isSyncCRV;//Nguyen Quoc Phuong 17-Dec-2012
        if (IsRequireCRVSerialNumberBefore != IsRequireCRVSerialNumberAfter) rfq.RequestForQuotationVendors.Clear();
        BindCRVSerialNumbers();
        //Nguyen Quoc Phuong 20-Nov-2012
        
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
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[9].Visible = false;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[10].Text = e.Row.Cells[9].Text + e.Row.Cells[10].Text;

            Guid rfqVendorId = (Guid)RequestForQuotationVendors.DataKeys[e.Row.RowIndex][0];

            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            ORequestForQuotationVendor rfqVendor = rfq.RequestForQuotationVendors.Find(rfqVendorId);

            DataList listAttachment = (DataList)e.Row.FindControl("listAttachment");
            listAttachment.ItemDataBound += new DataListItemEventHandler(listAttachment_ItemDataBound);
            listAttachment.DataSource = rfqVendor.Attachments;
            listAttachment.DataBind();

            if (rfqVendor.Vendor.IsInterestedParty.HasValue && rfqVendor.Vendor.IsInterestedParty == 1)
            {
                e.Row.ForeColor = System.Drawing.Color.Red;
                IPTVendorGridWarning.Visible = true;
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
        //buttonDownloadAttachment.Text = attachment.Filename.Substring(0, 15) + " ...";
        buttonDownloadAttachment.Text = attachment.Filename;
        buttonDownloadAttachment.ToolTip = attachment.Filename;
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
                Window.Open("../../customizedmodulesforcapitaland-ccl/budgetperiod/budgetview.aspx?ID=" +
                    HttpUtility.UrlEncode(Security.Encrypt(budgetSummary.BudgetPeriodID.ToString())) +
                    "&AccountID=" + HttpUtility.UrlEncode(Security.Encrypt(budgetSummary.AccountID.ToString())));

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
            // Unit price in selected currency
            //
            if (e.Row.Cells[11].Text != "&nbsp;")
                e.Row.Cells[11].Text = Convert.ToDecimal(e.Row.Cells[11].Text).ToString("#,##0.00##");

            // Unit Price in base currency
            //
            if (e.Row.Cells[12].Text != "&nbsp;")
                e.Row.Cells[12].Text = Convert.ToDecimal(e.Row.Cells[12].Text).ToString(OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "#,##0.00##");

            e.Row.Cells[11].Text = e.Row.Cells[10].Text + e.Row.Cells[11].Text;

            // Show Recoverable Amount column
            // if this WJ is recoverable
            // otherwise, hide the column.
            //
            //e.Row.Cells[14].Visible = rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.Recoverable).ToString();
            e.Row.Cells[14].Visible = checkRecoverable.Checked;

            // Default to check the box if item has no awarded vendor.
            //
            CheckBox checkbox = e.Row.Cells[0].Controls[0] as CheckBox;
            if (checkbox != null)
            {
                if (e.Row.Cells[8].Text == "&nbsp;")
                    checkbox.Checked = true;
            }

        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            // Hide currency symbol
            //
            e.Row.Cells[10].Visible = false;

            // Show Recoverable Amount column
            // if this WJ is recoverable
            // otherwise, hide the column.
            //
            //e.Row.Cells[14].Visible = rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.Recoverable).ToString();
            e.Row.Cells[14].Visible = checkRecoverable.Checked;
        }
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
        //Nguyen Quoc Phuong 17-Dec-2012
        ORequestForQuotation rfq = (ORequestForQuotation)panel.SessionObject;
        bool IsRequireCRVSerialNumberBefore = rfq.isSyncCRV;
        panel.ObjectPanel.BindControlsToObject(rfq);
        rfq.UpdateApplicablePurchaseSettings();
        bool IsRequireCRVSerialNumberAfter = rfq.isSyncCRV;
        if (IsRequireCRVSerialNumberBefore != IsRequireCRVSerialNumberAfter) rfq.RequestForQuotationVendors.Clear();
        BindCRVSerialNumbers();
        panel.ObjectPanel.BindObjectToControls(rfq);
        //End Nguyen Quoc Phuong 17-Dec-2012
    }

    /// <summary>
    /// Occurs when the user clicks on the Group WJ checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkIsGroupWJ_CheckedChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        BindRequestorID(rfq);
    }

    //10th March 2011, Joey:
    //only for ops, show the "has warranty" radio box options, and force the user to tick one of them
    //as well as force the user to key in warranty period, when "has warranty" radio option is ticked
    protected void radioHasWarranty_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (radioHasWarranty.SelectedValue == "0")
            textWarranty.Text = txtWarrantyPeriod.Text = "";
    }

    protected void dropPurchaseTypeClassification_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropPurchaseTypeClassification.SelectedValue != "")
            //dropPurchaseType.Bind(OCode.GetCodesByTypeAndParentID("PurchaseType", new Guid(dropPurchaseTypeClassification.SelectedValue), null));
            dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, new Guid(dropPurchaseTypeClassification.SelectedValue), Security.Decrypt(Request["TYPE"]), null));
        else
            dropPurchaseType.Items.Clear();
    }

    protected void listLocations_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        //List<OLocation> locs = new List<OLocation>();
        //ArrayList al_LocationIDs = new ArrayList();

        //for (int i = 0; i < listLocations.Items.Count; i++)
        //{
        //    if (listLocations.Items[i].Selected)
        //    {
        //        al_LocationIDs.Add(new Guid(listLocations.Items[i].Value));
        //        //Guid locationID = new Guid();
        //        //  locationID=(Guid)listLocations.Items[i].Value;
        //        //OLocation loc = LogicLayer.TablesLogic.tLocation.Create();
        //        //loc = LogicLayer.TablesLogic.tLocation.Load(locationID);
        //        //locs.Add(loc);
        //    }
        //}
        //if (al_LocationIDs.Count > 0)
        //{
        //    locs = TablesLogic.tLocation.LoadList(
        //        TablesLogic.tLocation.ObjectID.In(al_LocationIDs)
        //        );
        //}

        //List<OCampaign> cams = OLocation.GetCampaignsContainsInLocations(locs);
        //dropCampaign.Bind(cams, "ObjectName", "ObjectID");
        BindRequestorID(rfq);
    }

    /// <summary>
    /// Occurs when the user selects an item in the From Budget
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropFromBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;

        Guid? budgetId = null;
        if (dropFromBudget.SelectedValue != "")
            budgetId = new Guid(dropFromBudget.SelectedValue);

        List<Guid> periodIdList = new List<Guid>();

        if (rfq.RFQBudgetReallocationToPeriods != null)
        {
            foreach (ORFQBudgetReallocationToPeriod period in rfq.RFQBudgetReallocationToPeriods)
            {
                if (period.ToBudgetID == budgetId)
                {
                    if (!periodIdList.Contains(period.ToBudgetPeriodID.Value))
                        periodIdList.Add(period.ToBudgetPeriodID.Value);
                }
            }

            if (periodIdList.Count > 0)
            {
                List<OBudgetPeriod> periodList = TablesLogic.tBudgetPeriod.LoadList(TablesLogic.tBudgetPeriod.ObjectID.In(periodIdList));
                dropFromBudgetPeriod.Bind(periodList);
            }
        }
    }

    /// <summary>
    /// Occurs when the user selects an item in the From Budget Period
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropFromBudgetPeriod_SelectedIndexChanged(object sender, EventArgs e)
    {
        treeAccountFrom.PopulateTree();
    }

    protected TreePopulater treeAccountFrom_AcquireTreePopulater(object sender)
    {
        if (dropFromBudgetPeriod.SelectedValue == "")
            return null;

        return new AccountTreePopulater(null, false, true, new Guid(dropFromBudgetPeriod.SelectedValue));
    }

    /// <summary>
    /// Occurs when the user selects a node in the account tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeAccountFrom_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeAccountFrom.SelectedValue != "" && dropFromBudget.SelectedValue != ""
            && dropFromBudgetPeriod.SelectedValue != "")
        {
            Guid budgetId = new Guid(dropFromBudget.SelectedValue);
            Guid budgetPeriodId = new Guid(dropFromBudgetPeriod.SelectedValue);
            Guid accountId = new Guid(treeAccountFrom.SelectedValue);

            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);

            //if (rfq.ValidateFromAccountIdDoesNotExist(budgetId, budgetPeriodId, accountId))
            //{
            //    ORFQBudgetReallocationFromPeriod period = TablesLogic.tRFQBudgetReallocationFromPeriod.Create();
            //    period.RequestForQuotationID = rfq.ObjectID;
            //    period.FromBudgetID = new Guid(dropFromBudget.SelectedValue);
            //    period.FromBudgetPeriodID = new Guid(dropFromBudgetPeriod.SelectedValue);
            //    rfq.RFQBudgetReallocationFromPeriods.Add(period);

            //    ORFQBudgetReallocationFrom from = TablesLogic.tRFQBudgetReallocationFrom.Create();
            //    from.AccountID = accountId;
            //    from.RFQBudgetReallocationFromPeriod = period;
            //    period.RFQBudgetReallocationFroms.Add(from);

            //    rfq.ComputeFromBudgetSummary();

            //    panel.ObjectPanel.BindObjectToControls(rfq);
            //    panel.Message = "";
            //}
            //else
            //    panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;

            //Validate if budgetreallocationtoAccounts are of the same main category (Capex/Opex)

            panel.Message = "";
            bool flag = rfq.RFQBudgetReallocationToPeriods[0].RFQBudgetReallocationTos[0].Account.IsCapex();
            foreach (ORFQBudgetReallocationToPeriod rfqtoperiod in rfq.RFQBudgetReallocationToPeriods)
            {
                foreach (ORFQBudgetReallocationTo rfqreallocationto in rfqtoperiod.RFQBudgetReallocationTos)
                    if (rfqreallocationto.Account.IsCapex() != flag)
                        panel.Message = gridBudgetSummary.ErrorMessage = Resources.Errors.RequestForQuotation_InvalidBudgetReallocationTo;
            }

            if (panel.Message == "")
            {
                if (rfq.ValidateFromAccountIdDoesNotExist(budgetId, budgetPeriodId, accountId))
                {
                    OAccount fromAcc = TablesLogic.tAccount.Load(accountId);
                    if (rfq.RFQBudgetReallocationFromPeriods.Count == 0 || rfq.RFQBudgetReallocationFromPeriods[0].RFQBudgetReallocationFroms[0].Account.SubCategoryID == fromAcc.SubCategoryID)
                    {
                        ORFQBudgetReallocationFromPeriod period = TablesLogic.tRFQBudgetReallocationFromPeriod.Create();
                        period.RequestForQuotationID = rfq.ObjectID;
                        period.FromBudgetID = new Guid(dropFromBudget.SelectedValue);
                        period.FromBudgetPeriodID = new Guid(dropFromBudgetPeriod.SelectedValue);
                        rfq.RFQBudgetReallocationFromPeriods.Add(period);

                        ORFQBudgetReallocationFrom from = TablesLogic.tRFQBudgetReallocationFrom.Create();
                        from.AccountID = accountId;
                        from.RFQBudgetReallocationFromPeriod = period;
                        period.RFQBudgetReallocationFroms.Add(from);

                        OAccount toAcc = rfq.RFQBudgetReallocationToPeriods[0].RFQBudgetReallocationTos[0].Account;
                        List<OApprovalProcess> lstApp = OApprovalProcess.GetApprovalProcessForBudgetReallocation(rfq, fromAcc, toAcc);
                        if (lstApp.Count == 0 && rfq.RFQBudgetReallocationToPeriods.Count > 0)
                        {
                            panel.Message = Resources.Errors.BudgetReallocation_InvalidCapexToOpex;
                            period.RFQBudgetReallocationFroms.Remove(from);
                            rfq.RFQBudgetReallocationFromPeriods.Remove(period);
                        }
                        else
                        {
                            rfq.ComputeFromBudgetSummary();

                            panel.ObjectPanel.BindObjectToControls(rfq);
                            panel.Message = "";
                        }
                    }
                    else
                        panel.Message = Resources.Errors.BudgetReallocation_InvalidNumberOfSubCategory;
                }
                else
                    panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;
            }

            treeAccountFrom.SelectedValue = "";
        }
    }

    protected void BudgetGroupID_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
    }

    /// <summary>
    /// Add budget account.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddBudget_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        if (BudgetGroupID.SelectedValue != "")
        {
            if (!checkIsGroupWJ.Checked)
            {
                dropAddBudget.Bind(OBudget.GetCoveringBudgets(rfq.Location, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
            }
            else
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in rfq.GroupWJLocations)
                    locations.Add(location);
                dropAddBudget.Bind(OBudget.GetCoveringBudgets(locations, (Guid?)null, new Guid(BudgetGroupID.SelectedValue)));
            }
        }

        dropAddBudgetItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == "1";
        dropAddBudgetItemNumber.Items.Clear();
        for (int i = 1; i <= rfq.RequestForQuotationItems.Count; i++)
            dropAddBudgetItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        dateAddBudgetStartDate.DateTime = rfq.DateRequired;
        dateAddBudgetEndDate.DateTime = rfq.DateEnd;

        if (dropAddBudget.Items.Count == 2)
        {
            dropAddBudget.SelectedIndex = 1;
            treeAddBudgetAccounts.PopulateTree();
            if (checkIsGroupWJ.Checked)
            {
                OBudget budget = LogicLayer.TablesLogic.tBudget.Load(new Guid(dropAddBudget.SelectedValue));
                dropLocation.Bind(budget.ApplicableLocations);
                if (budget.ApplicableLocations.Count == 1)
                {
                    //dropLocation.Text == budget.ApplicableLocations[0].ObjectName();
                    dropLocation.SelectedValue = budget.ApplicableLocations[0].ObjectID.Value.ToString();
                }
            }
        }
        Guid? accountID = GetApplicableAccountID();
        if (accountID != null)
            treeAddBudgetAccounts.SelectedValue = accountID.ToString();
        AutoComputeBudgetAmount(rfq);
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
        panel.Message = "";
        if (!objectPanelAddBudget.IsValid)
        {
            panel.Message = objectPanelAddBudget.CheckErrorMessages();
            return;
        }

        int count = 0;
        decimal amount = Convert.ToDecimal(textAddBudgetAmount.Text);
        int terms = 1;
        if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.Monthly)
            terms = 1;
        else if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.Quaterly)
            terms = 3;
        else if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.HalfYearly)
            terms = 6;
        else if (Convert.ToInt16(rdlTerm.SelectedValue) == (int)EnumBudgetDistributionTerm.Yearly)
            terms = 12;
        for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(terms))
            count++;

        int c = 0;
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        for (DateTime d = dateAddBudgetStartDate.DateTime.Value; d <= dateAddBudgetEndDate.DateTime.Value; d = d.AddMonths(terms))
        {
            OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
            if (dropLocation.SelectedValue != "")
                pb.LocationID = new Guid(dropLocation.SelectedValue);
            else
                pb.LocationID = null;
            if (radioBudgetDistributionMode.SelectedValue == "0")
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
            pb.BudgetID = new Guid(dropAddBudget.SelectedValue);
            pb.StartDate = d;
            pb.EndDate = d;
            pb.AccrualFrequencyInMonths = terms;
            pb.AccountID = new Guid(treeAddBudgetAccounts.SelectedValue);
            if (c != count - 1)
                pb.Amount = Math.Round(amount / count, 2, MidpointRounding.AwayFromZero);
            else
                pb.Amount = amount - Math.Round(amount / count, 2, MidpointRounding.AwayFromZero) * (count - 1);

            rfq.PurchaseBudgets.Add(pb);
            c++;
        }

        if (rfq.CurrentActivity == null ||
            !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Close", "Cancelled"))
        {
            rfq.ComputeTempBudgetSummaries();
            //tessa comment out because of the hiding of budget reallocation
            rfq.ComputeBudgetReallocationToPeriods();
            rfq.UpdateTempBudgetSummaryWithReallocation();//tessa end
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";

            PopulateDropFromBudget(rfq);
        }

        popupAddBudget.Hide();
        objectPanelAddBudget.Visible = false;

        tabBudget.BindObjectToControls(rfq);
    }

    /// <summary>
    /// Occurs when the budget dropdown list changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropAddBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        treeAddBudgetAccounts.PopulateTree();

        // 2011.03.07
        // Kim Foong
        // Fix to ensure that no exception is thrown if the user selects the
        // first item.
        if (dropAddBudget.SelectedValue != "")
        {
            OBudget budget = LogicLayer.TablesLogic.tBudget.Load(new Guid(dropAddBudget.SelectedValue));

            dropLocation.Bind(budget.ApplicableLocations);
            if (budget.ApplicableLocations.Count == 1)
            {
                //dropLocation.Text == budget.ApplicableLocations[0].ObjectName();
                dropLocation.SelectedValue = budget.ApplicableLocations[0].ObjectID.Value.ToString();
            }
        }
        else
        {
            //try
            //{
            //    dropAddBudget.SelectedIndex = 1;
            //    OBudget budget = LogicLayer.TablesLogic.tBudget.Load(new Guid(dropAddBudget.SelectedValue));

            //    dropLocation.Bind(budget.ApplicableLocations);
            //    if (budget.ApplicableLocations.Count == 1)
            //    {
            //        //dropLocation.Text == budget.ApplicableLocations[0].ObjectName();
            //        dropLocation.SelectedValue = budget.ApplicableLocations[0].ObjectID.Value.ToString();
            //    }
            //}
            //catch (Exception ex)
            //{
            //    dropAddBudget.SelectedIndex = 0;
            //    dropLocation.Items.Clear();
            //}
            dropLocation.Items.Clear();
        }

        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        AutoComputeBudgetAmount(rfq);

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

    /// <summary>
    ///
    /// </summary>
    /// <returns></returns>
    protected Guid? GetApplicableAccountID()
    {
        if (dropAddBudget.SelectedValue != "")
        {
            Guid budgetId = new Guid(dropAddBudget.SelectedValue);
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, dateAddBudgetStartDate.DateTime.Value);
            if (budgetPeriod != null)
            {
                List<OBudgetPeriodOpeningBalance> bpOpeningBalances = budgetPeriod.BudgetPeriodOpeningBalances.FindAll((r) => r.IsActive == 1);
                if (bpOpeningBalances.Count == 1)
                    return bpOpeningBalances[0].AccountID;
            }
        }
        return null;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void AutoCalculateReallocationTo_CheckedChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Initializes the control.
    /// </summary>
    /// <param name="e"></param>
    //protected override void OnInit(EventArgs e)
    //{
    //    base.OnInit(e);

    //    // Register the buttonUpload button to force a full
    //    // postback whenever a file is uploaded.
    //    //
    //    if (Page is UIPageBase)
    //    {
    //        ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttonUpload);
    //    }
    //}

    protected void gridDocument_Action(object sender, string commandName, List<object> objectIds)
    {
        ORequestForQuotationVendor rfqVendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;

        if (commandName == "ViewDocument")
        {
            // View the document, so load it from
            // database and let user download it.
            //
            Guid id = (Guid)objectIds[0];

            if (rfqVendor != null && rfqVendor.Attachments.Count > 0)
            {
                OAttachment att = rfqVendor.Attachments.Find(id);
                if (att != null)
                    Window.Download(att.FileBytes, att.Filename, att.ContentType);
            }

        }
        if (commandName == "UploadDocument")
        {
            fileUploadVendorQuotation.Show();
        }

        if (commandName == "DeleteDocument")
        {
            // remove the document from the database.
            //
            if (rfqVendor != null)
            {
                foreach (Guid objectId in objectIds)
                    rfqVendor.Attachments.RemoveGuid(objectId);

            }
            panelgridAttachments.BindObjectToControls(rfqVendor);
        }

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);
            rfq.EquipmentID = null;

            rfq.UpdateApplicablePurchaseSettings();
            if (rfq.Location != null)
                rfq.EmployerCompanyID = rfq.Location.BuildingTrustID;

            BindRequestorID(rfq);
            BindRequestor(rfq);
            //20120209 ptb
            //update BillToContact ddl
            BillToContactPersonID.Bind(OUser.GetUsersByRoleAndAboveLocation(rfq.BillToContactPerson, rfq.Location, "PURCHASEADMIN"));

            panel.ObjectPanel.BindObjectToControls(rfq);
        }
        catch (Exception ex)
        {
        }

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridBudget_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "AddBudgets")
        {
            buttonAddBudget_Click(sender, EventArgs.Empty);
        }
    }

    protected void RequestForQuotationItems_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "DeleteObject")
        {
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);

            foreach (object id in objectIds)
            {
                ORequestForQuotationItem item = rfq.RequestForQuotationItems.Find((r) => r.ObjectID == (Guid)id);
                if (item != null)
                    rfq.RemoveLineItemsFromRFQVendors(item);
            }
            RequestForQuotationItems.Grid.DataBound += new EventHandler(Grid_DataBound);

        }
    }

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void RequestForQuotationItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[6].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
                e.Row.Cells[8].Text = Convert.ToDecimal(e.Row.Cells[8].Text).ToString("#,##0");

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

    /// <summary>
    ///
    /// </summary>
    /// <param name="rfq"></param>
    protected void AutoComputeBudgetAmount(ORequestForQuotation rfq)
    {
        if (rfq.IsGroupWJ == 0)
        {
            decimal? amount = 0;
            decimal? totalAmount = 0;
            decimal? recoverableAmount = 0;

            if (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.EntireAmount.ToString())
            {
                foreach (OPurchaseBudget pb in rfq.PurchaseBudgets)
                    amount += pb.Amount;

                foreach (ORequestForQuotationItem item in rfq.RequestForQuotationItems)
                {
                    totalAmount += item.Subtotal;
                    recoverableAmount += LogicLayerPersistentObject.Round(item.RecoverableAmount);
                }

                if (rfq.IsRecoverable == (int)EnumRecoverable.Recoverable)
                    totalAmount = totalAmount - recoverableAmount;
            }
            else
            {
                int no = Convert.ToInt16(dropAddBudgetItemNumber.SelectedValue);
                ORequestForQuotationItem item = rfq.RequestForQuotationItems.Find((r) => r.ItemNumber == no);

                if (item != null)
                {
                    totalAmount = item.Subtotal;
                    recoverableAmount = LogicLayerPersistentObject.Round(item.RecoverableAmount);
                }

                List<OPurchaseBudget> pbList = rfq.PurchaseBudgets.FindAll((r) => r.ItemNumber == no);
                if (pbList != null)
                    foreach (OPurchaseBudget pb in pbList)
                        amount += pb.Amount;
            }

            // Default total amount in budget adding
            //
            decimal remainAmount = totalAmount >= amount ? Convert.ToDecimal(totalAmount - amount) : 0;
            textAddBudgetAmount.Text = Math.Round(remainAmount, 2, MidpointRounding.AwayFromZero).ToString();
        }
        else if (rfq.IsGroupWJ == 1)
        {
            if (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.EntireAmount.ToString())
            {
                Hashtable totalLineItemAmounts = new Hashtable();
                foreach (OLocation ol in rfq.GroupWJLocations)
                {
                    totalLineItemAmounts[ol.ObjectID] = 0M;
                }
                Hashtable totalBudgetAmounts = new Hashtable();

                foreach (OLocation olo in rfq.GroupWJLocations)
                {
                    totalBudgetAmounts[olo.ObjectID] = 0M;
                }
                foreach (ORequestForQuotationItem rfqitem in rfq.RequestForQuotationItems)
                {
                    if (rfqitem.ReceiptMode.Value == 0)
                    {
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqil.LocationID] = (decimal)totalLineItemAmounts[rfqil.LocationID] + LogicLayerPersistentObject.Round(rfqitem.UnitPrice * rfqil.QuantityRequired);
                        }
                    }
                    else
                    {
                        decimal? totalratio = 0M;
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalratio += rfqil.AmountRatio;
                        }
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqil.LocationID] = (decimal)totalLineItemAmounts[rfqil.LocationID] + LogicLayerPersistentObject.Round(rfqitem.UnitPrice * rfqil.AmountRatio / totalratio);
                        }
                    }
                }
                foreach (OPurchaseBudget pb in rfq.PurchaseBudgets)
                {
                    totalBudgetAmounts[pb.LocationID] = (decimal)totalBudgetAmounts[pb.LocationID] + pb.Amount.Value;
                }

                if (dropAddBudget.SelectedValue != "" && dropLocation.SelectedValue != "")
                {
                    OLocation budget = LogicLayer.TablesLogic.tLocation.Load(new Guid(dropLocation.SelectedValue));
                    decimal remainAmount = (decimal)totalLineItemAmounts[budget.ObjectID] >= (decimal)totalBudgetAmounts[budget.ObjectID] ?
                        (decimal)totalLineItemAmounts[budget.ObjectID] - (decimal)totalBudgetAmounts[budget.ObjectID] : 0;
                    textAddBudgetAmount.Text = Math.Round(remainAmount, 2, MidpointRounding.AwayFromZero).ToString();
                }
            }

            else if (radioBudgetDistributionMode.SelectedValue == BudgetDistribution.LineItem.ToString())
            {
                Hashtable totalLineItemAmounts = new Hashtable();
                foreach (ORequestForQuotationItem rfqitem in rfq.RequestForQuotationItems)
                {
                    foreach (OLocation ol in rfq.GroupWJLocations)
                    {
                        totalLineItemAmounts[ol.ObjectID + ":" + rfqitem.ItemNumber] = 0M;
                    }
                }
                Hashtable totalBudgetAmounts = new Hashtable();
                foreach (ORequestForQuotationItem rfqitem in rfq.RequestForQuotationItems)
                {
                    foreach (OLocation ol in rfq.GroupWJLocations)
                    {
                        totalBudgetAmounts[ol.ObjectID + ":" + rfqitem.ItemNumber] = 0M;
                    }
                }

                foreach (ORequestForQuotationItem rfqitem in rfq.RequestForQuotationItems)
                {

                    if (rfqitem.ReceiptMode.Value == ReceiptModeType.Dollar)
                    {
                        decimal? totalratio = 0m;
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalratio += rfqil.AmountRatio;
                        }

                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitem.ItemNumber] = (decimal)totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitem.ItemNumber] + rfqitem.UnitPrice * rfqiLocation.AmountRatio.Value / totalratio;
                        }
                    }
                    else
                    {
                        foreach (ORequestForQuotationItemLocation rfqiLocation in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitem.ItemNumber] = (decimal)totalLineItemAmounts[rfqiLocation.LocationID + ":" + rfqitem.ItemNumber] + rfqitem.UnitPrice.Value * rfqiLocation.QuantityRequired.Value;
                        }
                    }
                }
                foreach (OPurchaseBudget pb in rfq.PurchaseBudgets)
                {
                    totalBudgetAmounts[pb.LocationID + ":" + pb.ItemNumber] = (decimal)totalBudgetAmounts[pb.LocationID + ":" + pb.ItemNumber] + pb.Amount.Value;
                }
                if (dropAddBudget.SelectedValue != "" && dropLocation.SelectedValue != "")
                {
                    OLocation budget = LogicLayer.TablesLogic.tLocation.Load(new Guid(dropLocation.SelectedValue));
                    decimal remainAmount = (decimal)totalLineItemAmounts[budget.ObjectID + ":" + dropAddBudgetItemNumber.SelectedValue] >= (decimal)totalBudgetAmounts[budget.ObjectID + ":" + dropAddBudgetItemNumber.SelectedValue]
                        ? Convert.ToDecimal((decimal)totalLineItemAmounts[budget.ObjectID + ":" + dropAddBudgetItemNumber.SelectedValue] - (decimal)totalBudgetAmounts[budget.ObjectID + ":" + dropAddBudgetItemNumber.SelectedValue]) : 0;
                    textAddBudgetAmount.Text = Math.Round(remainAmount, 2, MidpointRounding.AwayFromZero).ToString();
                }

            }
        }

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropAddBudgetItemNumber_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        AutoComputeBudgetAmount(rfq);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewGroupWJ_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        Window.OpenViewObjectPage(this.Page, "ORequestForQuotation", rfq.GroupRequestForQuotation.ObjectID.ToString(), "");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditGroupWJ_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        Window.OpenEditObjectPage(this.Page, "ORequestForQuotation", rfq.GroupRequestForQuotation.ObjectID.ToString(), "");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridChildWJs_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditObject")
        {
            Window.OpenEditObjectPage(this.Page, "ORequestForQuotation", dataKeys[0].ToString(), "");
        }
        if (commandName == "ViewObject")
            Window.OpenViewObjectPage(this.Page, "ORequestForQuotation", dataKeys[0].ToString(), "");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridLocations_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "DeleteLocations")
        {
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);

            foreach (object id in dataKeys)
            {
                rfq.GroupWJLocations.RemoveGuid(new Guid(id.ToString()));
                UpdateLineItems(rfq);
            }
            UpdateGroupLocation(rfq);//Nguyen Quoc Phuong 17-Dec-2012

            if (rfq.RequestForQuotationItems.Count != 0)
            {
                foreach (ORequestForQuotationItem i in rfq.RequestForQuotationItems)
                {
                    decimal? amount = 0.0M;
                    foreach (ORequestForQuotationItemLocation ofqil in i.RequestForQuotationItemLocation)
                        amount += ofqil.QuantityRequired;

                    if (checkIsGroupWJ.Checked && (i.ReceiptMode == ReceiptModeType.Quantity))
                        i.QuantityRequired = amount;
                    else if (checkIsGroupWJ.Checked && (i.ReceiptMode == ReceiptModeType.Dollar))
                        i.QuantityRequired = 1;

                    if (rfq.RequestForQuotationVendors != null && rfq.RequestForQuotationVendors.Count > 0)
                    {
                        rfq.UpdateLineItemsToRFQVendors(i);
                        rfq.UpdateVendorAwardedItemsUnitPrice();
                        rfq.UpdateBudgetAmount();
                        //panel.Message = Resources.Messages.RequestForQuotation_UpdateRFQVendorITem;
                    }
                }
            }

            panel.ObjectPanel.BindObjectToControls(rfq);
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        AutoComputeBudgetAmount(rfq);
    }

    protected void IsGroupApproval_CheckedChanged(object sender, EventArgs e)
    {

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

        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;

        foreach (ORequestForQuotationVendor rfqVendor in rfq.RequestForQuotationVendors)
        {
            OAttachment attachment = rfqVendor.Attachments.Find(attachmentId);

            if (attachment != null)
            {
                panel.FocusWindow = false;
                Window.Download(attachment.FileBytes, attachment.Filename, attachment.ContentType);
            }
        }
    }

    protected void dropCampaign_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddCatalog_Click(object sender, EventArgs e)
    {
        OFunction function = OFunction.GetFunctionByObjectType("OCatalogue");
        Window.Open(
            Page.ResolveUrl(function.EditUrl) + "?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("NEW:")) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt("OCatalogue")) +
            "&" + "ButtonID=" + this.repopulateCatalogueButton.ClientID + "&N=1", "AnacleEAM_Window_AddCatalog");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void repopulateCatalogue_Click(object sender, EventArgs e)
    {
        ORequestForQuotationItem requestForQuotationItem =
            RequestForQuotationItem_SubPanel.SessionObject as ORequestForQuotationItem;
        requestForQuotationItem.CatalogueID = (Guid)Session["NewCatalogID"];
        CatalogueID.PopulateTree();
        CatalogueID.SelectedValue = Session["NewCatalogID"].ToString();
        Session["NewCatalogID"] = null;
    }

    //14th March 2011, Joey:
    //allow user to view / edit the previous cancelled purchase order if this rfq was generated from a previous cancelled purchase order
    protected void buttonViewPurchaseOrder_Click(object sender, EventArgs e)
    {
        if (CancelledPurchaseOrder.Text.Trim().Length > 0)
        {
            ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;
            if (requestForQuotation.CancelledPurchaseOrder != null)
                Window.OpenViewObjectPage(this, "OPurchaseOrder", requestForQuotation.CancelledPurchaseOrder.ObjectID.ToString(), "");
        }
    }

    //14th March 2011, Joey:
    //allow user to view / edit the previous cancelled purchase order if this rfq was generated from a previous cancelled purchase order
    protected void buttonEditPurchaseOrder_Click(object sender, EventArgs e)
    {
        if (CancelledPurchaseOrder.Text.Trim().Length > 0)
        {
            ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;
            if (requestForQuotation.CancelledPurchaseOrder != null)
                Window.OpenEditObjectPage(this, "OPurchaseOrder", requestForQuotation.CancelledPurchaseOrder.ObjectID.ToString(), "");
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlContactPerson_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotationVendor rfqVendor =
                RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(rfqVendor);
        if (ddlContactPerson.SelectedValue == null || ddlContactPerson.SelectedValue == "")
        {
            Guid vendorId = new Guid(dropVendor.SelectedValue);
            OVendor vendor = TablesLogic.tVendor[vendorId];

            if (vendor != null)
            {
                ddlContactPerson.Bind(vendor.VendorContacts);
                ddlContactPerson.Items[0].Text = Resources.Strings.RFQVendor_ContactPerson;
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
            return;
        }
        Guid VendorContactID = new Guid(ddlContactPerson.SelectedValue);
        OVendorContact vendorContact = TablesLogic.tVendorContact[VendorContactID];

        if (vendorContact != null)
        {
            rfqVendor.ContactCellPhone = vendorContact.Cellphone;
            rfqVendor.ContactEmail = vendorContact.Email;
            rfqVendor.ContactFax = vendorContact.Fax;
            rfqVendor.ContactPhone = vendorContact.Phone;
            rfqVendor.ContactPerson = vendorContact.ObjectName;
        }

        rfqVendor.UpdateItemCurrencies();
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(rfqVendor);
    }

    protected void gridAwardItems_Action(object sender, string commandName, List<object> objectIDs)
    {

        //if (commandName == "EditPO")
        //{
        //    Guid? objectID = (Guid?)objectIDs[0];
        //    ORequestForQuotationItem rfqItem = TablesLogic.tRequestForQuotationItem[objectID.Value];
        //    Window.OpenEditObjectPage(this, "OPurchaseOrder", rfqItem.PurchaseOrderItem.PurchaseOrderID.ToString(), "");
        //}
        //else if (commandName == "ViewPO")
        //{
        //    Guid? objectID = (Guid?)objectIDs[0];
        //    ORequestForQuotationItem rfqItem = TablesLogic.tRequestForQuotationItem[objectID.Value];
        //    Window.OpenViewObjectPage(this, "OPurchaseOrder", rfqItem.PurchaseOrderItem.PurchaseOrderID.ToString(), "");
        //}
    }

    protected void searchMultipleVendor_Selected(object sender, EventArgs e)
    {
        ORequestForQuotation rfq =
                panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        List<ORequestForQuotationVendor> vendors = new List<ORequestForQuotationVendor>();
        int count = 0;
        foreach (object key in searchMultipleVendor.SelectedDataKeys)
        {
            Guid id = (Guid)key;

            if (!rfq.IsDuplicateVendorID(id))
            {
                ORequestForQuotationVendor rfqVendor = rfq.CreateRequestForQuotationVendor(id);
                vendors.Add(rfqVendor);
                count++;
            }
        }

        rfq.RequestForQuotationVendors.AddRange(vendors);

        tabQuotations.BindObjectToControls(rfq);
        tabAward.BindObjectToControls(rfq);
        //panel.ObjectPanel.BindObjectToControls(rfq);

    }

    protected void searchMultipleVendor_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        ExpressionCondition allowDebarred = (OVendor.AllowAccessDebarredVendors(AppSession.User, Security.Decrypt(Request["TYPE"])) ? Query.True : Query.False);
        ExpressionCondition allowNonApproved = (OVendor.AllowAccessNonApprovedVendors(AppSession.User, Security.Decrypt(Request["TYPE"])) ? Query.True : Query.False);

        e.CustomCondition = (TablesLogic.tVendor.IsDeleted == 0 &
                (
                    allowDebarred |
                    TablesLogic.tVendor.IsDebarred == 0 |
                    TablesLogic.tVendor.DebarmentStartDate > DateTime.Today |
                    TablesLogic.tVendor.DebarmentEndDate < DateTime.Today
                ) &
                (
                    allowNonApproved |
                    TablesLogic.tVendor.IsApproved == 1
                ) &
                TablesLogic.tVendor.IsInActive == 0 //Nguyen Quoc Phuong 19-Nov-2012
            );

        e.CustomSortOrder = new List<ColumnOrder>();
        e.CustomSortOrder.Add(TablesLogic.tVendor.ObjectName.Asc);
        //e.CustomSortOrder.Add(TablesLogic.tVendor.OperatingContactPerson.Asc);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridPurchaseOrderItems_RowCommand(object sender, GridViewCommandEventArgs e)
    {

        if (e.CommandName == "EditPO")
        {
            Guid? objectID = new Guid(((GridView)sender).Rows[Convert.ToInt16(e.CommandArgument)].Cells[1].Text);
            Window.OpenEditObjectPage(this, "OPurchaseOrder", objectID.ToString(), "");
        }
        else if (e.CommandName == "ViewPO")
        {
            Guid? objectID = new Guid(((GridView)sender).Rows[Convert.ToInt16(e.CommandArgument)].Cells[1].Text);
            Window.OpenViewObjectPage(this, "OPurchaseOrder", objectID.ToString(), "");
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridPurchaseOrderItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        e.Row.Cells[1].Visible = false;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid? poId = new Guid(e.Row.Cells[1].Text);
            if (EditVisible[poId] == null)
                EditVisible.Add(poId, OPurchaseOrder.IsObjectEditOrView(AppSession.User, poId.Value, "OPurchaseOrder", true));
            if (ViewVisible[poId] == null)
                ViewVisible.Add(poId, OPurchaseOrder.IsObjectEditOrView(AppSession.User, poId.Value, "OPurchaseOrder", false));

            e.Row.Cells[2].Visible = Convert.ToBoolean(EditVisible[poId]);
            e.Row.Cells[3].Visible = Convert.ToBoolean(ViewVisible[poId]);
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridGeneratePO_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            if (e.Row.Cells[4].Text != "" && e.Row.Cells[4].Text != "&nbsp;")
            {
                UIFieldTextBox tb = e.Row.FindControl("generateQty") as UIFieldTextBox;
                if (e.Row.Cells[5].Text != "&nbsp;" && tb != null)
                {
                    tb.Text = (Convert.ToDecimal(e.Row.Cells[4].Text) - Convert.ToDecimal(e.Row.Cells[5].Text)).ToString();
                }
                else if (e.Row.Cells[5].Text == "&nbsp;" & tb != null)
                {
                    tb.Text = e.Row.Cells[5].Text;
                }

                // 2011.07.30, Kien Trung
                // In case, disable of tb is needed.
                // do it here.
                //
                tb.Enabled = !checkRecoverable.Checked;
                //(rdlRecoverableType.SelectedValue == ((int)EnumRecoverableType.NonRecoverable).ToString());

            }
            if (e.Row.Cells[7].Text != "&nbsp;")
            {
                e.Row.Cells[7].Text = Convert.ToDecimal(e.Row.Cells[7].Text).ToString("#,##0.00##");
                e.Row.Cells[7].Text = e.Row.Cells[6].Text + e.Row.Cells[7].Text;
            }
            //if (e.Row.Cells[6].Text != "&nbsp;")
            //    e.Row.Cells[6].Text = Convert.ToDecimal(e.Row.Cells[6].Text).ToString(OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "#,##0.00##");

        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[6].Visible = false;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="e"></param>
    protected void searchTenantLease_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        e.CustomCondition &= TablesLogic.tTenantLease.LeaseStatus == "N";
        if (ddlLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(ddlLocation.SelectedValue)];
            e.CustomCondition &= TablesLogic.tTenantLease.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        else
            e.CustomCondition &= Query.False;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void searchTenantLease_Selected(object sender, EventArgs e)
    {
        ORequestForQuotation obj = panel.SessionObject as ORequestForQuotation;
        tabDetails.BindControlsToObject(obj);

        Guid id = (Guid)searchTenantLease.SelectedDataKeys[0];
        OTenantLease tenantLease = TablesLogic.tTenantLease[id];

        obj.TenantID = tenantLease.TenantID;
        obj.TenantLeaseID = tenantLease.ObjectID;

        //if (tenantLease.Tenant.TenantContacts.Count > 0)
        //    obj.RequestorName = tenantLease.Tenant.TenantContacts[0].ObjectName;
        //else
        //    obj.RequestorName = tenantLease.Tenant.ObjectName;

        tabDetails.BindObjectToControls(obj);

    }

    protected void searchTenantLease_Cleared(object sender, EventArgs e)
    {
        ORequestForQuotation obj = panel.SessionObject as ORequestForQuotation;
        tabDetails.BindControlsToObject(obj);

        obj.TenantID = null;
        obj.TenantLeaseID = null;

        tabDetails.BindObjectToControls(obj);

    }

    protected void checkRecoverable_CheckedChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        // update vendor awarded item unit price.
        //
        rfq.UpdateVendorAwardedItemsUnitPrice();

        // update budget amount
        //
        rfq.UpdateBudgetAmount();

        if (rfq.CurrentActivity == null ||
            !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Awarded", "Close", "Cancelled"))
        {
            rfq.ComputeTempBudgetSummaries();

            //tessa comment out for the hiding of budget reallocation
            rfq.ComputeBudgetReallocationToPeriods();
            rfq.UpdateTempBudgetSummaryWithReallocation();
            rfq.ComputeFromBudgetSummary();

            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        else
            gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";

        panel.ObjectPanel.BindObjectToControls(rfq);

    }

    protected void rdlRecoverableType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        // update vendor awarded item unit price.
        //
        rfq.UpdateVendorAwardedItemsUnitPrice();

        // update budget amount
        //
        rfq.UpdateBudgetAmount();

        panel.ObjectPanel.BindObjectToControls(rfq);

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void fileUploadVendorQuotation_Uploaded(object sender, EventArgs e)
    {
        List<HttpPostedFile> postedFiles = fileUploadVendorQuotation.GetUploadFiles();
        ORequestForQuotationVendor vendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(vendor);
        if (vendor != null)
            vendor.Attachments.AddRange(fileUploadVendorQuotation.GetAttachmentFiles());
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(vendor);
        /*
        RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(vendor);
        foreach (HttpPostedFile postedFile in postedFiles)
        {
            if (postedFile != null && postedFile.ContentLength > 0)
            {
                OAttachment a = TablesLogic.tAttachment.Create();
                byte[] fileBytes = new byte[postedFile.ContentLength];
                postedFile.InputStream.Position = 0;
                postedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

                a.FileDescription = fileUploadVendorQuotation.FileUploadDescription;
                a.FileBytes = fileBytes;
                a.Filename = Path.GetFileName(postedFile.FileName);
                a.FileSize = postedFile.ContentLength;
                a.ContentType = postedFile.ContentType;

                ORequestForQuotationVendor vendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
                RequestForQuotationVendors_SubPanel.ObjectPanel.BindControlsToObject(vendor);
                if (vendor != null)
                {
                    vendor.Attachments.Add(a);
                }
                RequestForQuotationVendors_SubPanel.ObjectPanel.BindObjectToControls(vendor);
                //panelgridAttachments.BindObjectToControls(vendor);
            }
        }
         */
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonShowTenantDetails_Click(object sender, EventArgs e)
    {
        panelTenantDetails.Visible = !panelTenantDetails.Visible;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridDocument_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string Attachment = "";
            Attachment = String.Format(Resources.Strings.GeneralDisplayTitleFontColor, e.Row.Cells[5].Text);

            if (e.Row.Cells[4].Text != "&nbsp;" && e.Row.Cells[3].Text != "&nbsp;")
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, Convert.ToDateTime(e.Row.Cells[4].Text).ToFriendlyString(), e.Row.Cells[3].Text);
            else
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, DateTime.Now.AddSeconds(-1).ToFriendlyString(), AppSession.User.ObjectName);

            e.Row.Cells[5].Text = Attachment;
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[4].Visible = false;
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void searchInventory_Selected(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        int itemNumber = 0;
        foreach (ORequestForQuotationItem rfqi in rfq.RequestForQuotationItems)
            if (rfqi.ItemNumber > itemNumber && rfqi.ItemNumber != null)
                itemNumber = rfqi.ItemNumber.Value;
        itemNumber++;

        List<ORequestForQuotationItem> items = new List<ORequestForQuotationItem>();
        foreach (GridViewRow row in searchInventory.SelectedRows)
        {
            // Create an add object
            //
            OCatalogue catalogue = TablesLogic.tCatalogue.Load((Guid)searchInventory.SelectedDataKeys[row.RowIndex]);
            ORequestForQuotationItem rfqi = TablesLogic.tRequestForQuotationItem.Create();
            rfqi.ItemNumber = itemNumber++;
            rfqi.ItemType = PurchaseItemType.Material;
            rfqi.CatalogueID = catalogue.ObjectID;
            rfqi.ItemDescription = catalogue.ObjectName;
            rfqi.UnitOfMeasureID = catalogue.UnitOfMeasureID;
            rfqi.ReceiptMode = ReceiptModeType.Quantity;
            searchInventory.SearchUIGridView.BindRowToObject(rfqi, row);
            if (rfqi.QuantityRequired != null &&
                rfqi.QuantityRequired > 0)
                items.Add(rfqi);

        }
        rfq.RequestForQuotationItems.AddRange(items);
        panel.ObjectPanel.BindObjectToControls(rfq);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="e"></param>
    protected void searchInventory_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        //e.CustomCondition = TablesLogic.tCatalogue.IsCatalogueItem == 1;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditWork_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        Window.OpenEditObjectPage(this, "OWork", rfq.WorkID.ToString(), "");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewWork_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        Window.OpenViewObjectPage(this, "OWork", rfq.WorkID.ToString(), "");
    }

    protected void UnitPrice_TextChanged(object sender, EventArgs e)
    {
        UIFieldTextBox textbox = (UIFieldTextBox)sender;
        GridViewRow gvr = (GridViewRow)textbox.NamingContainer;
        UIFieldLabel subtotal = (UIFieldLabel)gvr.FindControl("labelSubTotal");
        UIFieldTextBox recoverableamount = gvr.FindControl("RecoverableAmount") as UIFieldTextBox;
        UIFieldTextBox quantityprovided = gvr.FindControl("QuantityProvided") as UIFieldTextBox;
        UIFieldTextBox unitprice = gvr.FindControl("UnitPrice") as UIFieldTextBox;
        if (unitprice.Validate() == null)
        {
            subtotal.Text = LogicLayerPersistentObject.Round(Convert.ToDecimal(unitprice.Text) * Convert.ToDecimal(quantityprovided.Text)).ToString("#,##0.0000");
            subtotal.DataFormatString = "{0:#,##0.0000}";
            recoverableamount.Text = subtotal.Text;
        }
    }

    protected void gridRequestForQuotationItemLocations_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldTextBox txtQuantity = e.Row.FindControl("textLocationQuantityRequired") as UIFieldTextBox;
            UIFieldTextBox txtAmount = e.Row.FindControl("textLocationDollarRequired") as UIFieldTextBox;

            if (txtQuantity != null && txtAmount != null)
            {
                e.Row.Cells[2].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString());
                e.Row.Cells[3].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString());

                txtQuantity.Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString());
                txtAmount.Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString());

                if (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString())
                    txtQuantity.Text = "1.00";
            }
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[2].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString());
            e.Row.Cells[3].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString());
        }
    }

    protected void subpanelLocations_ValidateAndUpdate(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);

        foreach (ListItem li in listLocations.Items)
        {
            if (li.Selected)
                rfq.GroupWJLocations.AddGuid(new Guid(li.Value));
        }

        // Clear all the Locations that gets removed from the Locations list.
        UpdateLineItems(rfq);
        UpdateGroupLocation(rfq);//Nguyen Quoc Phuong 17-Dec-2012

        panel.ObjectPanel.BindObjectToControls(rfq);
    }

    //Nguyen Quoc Phuong 17-Dec-2012
    protected void UpdateGroupLocation(ORequestForQuotation rfq)
    {
        if (rfq.IsGroupWJ == 1)
        {
            ExpressionCondition cond = Query.True;
            foreach (OLocation l in rfq.GroupWJLocations)
                cond = cond & l.HierarchyPath.Like(TablesLogic.tLocation.HierarchyPath + "%");

            rfq.LocationID = TablesLogic.tLocation.SelectTop(1,
                TablesLogic.tLocation.ObjectID)
                .Where(TablesLogic.tLocation.IsDeleted == 0 & cond)
                .OrderBy(TablesLogic.tLocation.HierarchyPath.Desc);
            rfq.Location = TablesLogic.tLocation.Load(rfq.LocationID);
        }        
    }
    //End Nguyen Quoc Phuong 17-Dec-2012

    protected void subpanelLocations_PopulateForm(object sender, EventArgs e)
    {

    }

    private void UpdateLineItems(ORequestForQuotation rfq)
    {
        // Clear all the Locations that gets removed from the Locations list.
        foreach (ORequestForQuotationItem requestForQuotationItem in rfq.RequestForQuotationItems)
        {
            if (requestForQuotationItem.RequestForQuotationItemLocation != null)
            {
                for (int i = requestForQuotationItem.RequestForQuotationItemLocation.Count - 1; i >= 0; i--)
                {
                    if (rfq.GroupWJLocations.Find(lf => lf.ObjectID == requestForQuotationItem.RequestForQuotationItemLocation[i].LocationID) == null)
                    {
                        requestForQuotationItem.RequestForQuotationItemLocation.Remove(requestForQuotationItem.RequestForQuotationItemLocation[i]);
                    }
                }
            }
        }

        foreach (OLocation l in rfq.GroupWJLocations)
        {
            foreach (ORequestForQuotationItem requestForQuotationItem in rfq.RequestForQuotationItems)
            {
                if (requestForQuotationItem.RequestForQuotationItemLocation != null &&
                    requestForQuotationItem.RequestForQuotationItemLocation.Find((lf) => lf.LocationID == l.ObjectID) == null)
                {
                    ORequestForQuotationItemLocation rfqitemLocation =
                        TablesLogic.tRequestForQuotationItemLocation.Create();
                    rfqitemLocation.LocationID = l.ObjectID;
                    requestForQuotationItem.RequestForQuotationItemLocation.Add(rfqitemLocation);
                }
            }
        }
    }
    ////Nguyen Quoc Phuong 17-Dec-2012
    protected void buttonRefreshCRVSerialNumbers_Click(object sender, EventArgs e)
    {
        BindCRVSerialNumbers();
    }
    ////End Nguyen Quoc Phuong 17-Dec-2012

    /// <summary>
    /// Occurs when the user clicks on the CRV Button
    /// button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CRVLink_Click(object sender, EventArgs e)
    {
        string crvURL = OApplicationSetting.Current.CRVURL;
        Window.Open(crvURL);
        panel.FocusWindow = false;
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

    <script type='text/javascript'>
        function computeSubTotal(sourceControlId1, sourceControlId2, targetControlId) {
            var val = parseFloat(document.getElementById(sourceControlId1).value.replace(/,/g, ''));
            var factor = parseFloat(document.getElementById(sourceControlId2).value.replace(/,/g, ''));
            if (!isNaN(factor * val)) { document.getElementById(targetControlId).innerHTML = (factor * val).toFixed(2); }
            if (!isNaN(val)) { document.getElementById(sourceControlId1).value = val.toFixed(2); }
            if (!isNaN(factor)) { document.getElementById(sourceControlId2).value = factor.toFixed(2); }
        }

        function computeRecoverable(sourceControlId1, sourceControlId2, targetControlId) {
            var val = parseFloat(document.getElementById(sourceControlId1).value.replace(/,/g, ''));
            var factor = parseFloat(document.getElementById(sourceControlId2).value.replace(/,/g, ''));

            //if (!isNaN(factor * val)) {
            document.getElementById(targetControlId).value = (factor * val).toFixed(2);
            //}
            if (!isNaN(val)) { document.getElementById(sourceControlId1).value = val.toFixed(2); }
            if (!isNaN(factor)) { document.getElementById(sourceControlId2).value = factor.toFixed(2); }
        }

        function computeTotal(inputControlPrefix, totalControlId) {
            var inputs = document.getElementsByTagName("input");
            var total = 0.0;
            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf(inputControlPrefix) >= 0 &&
                        inputs[i].id != totalControlId) {
                    var v = parseFloat(inputs[i].value.replace(/,/g, ""));
                    if (!isNaN(v)) {
                        total += v;
                    }
                }
            }

            var totalControl = document.getElementById(totalControlId);
            totalControl.value = Math.round(total);
        }

        function distributeTotal(inputControlPrefix, totalControlId, divisor, errMsg) {
            var totalControl = document.getElementById(totalControlId);
            var t = parseFloat(totalControl.value.replace(/,/g, ""));

            try {
                if (!isNaN(t)) {
                    if (t >= 0) {
                        var tavg = Math.floor(t / divisor);
                        var tlast = t - (tavg * (divisor - 1));

                        var inputs = document.getElementsByTagName("input");
                        var rowInputs = new Array();
                        for (var i = 0; i < inputs.length; i++) {
                            if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf(inputControlPrefix) >= 0 &&
                        inputs[i].id != totalControlId) {
                                rowInputs[rowInputs.length] = inputs[i];
                            }
                        }
                        for (var i = 0; i < rowInputs.length; i++) {
                            if (i != rowInputs.length - 1)
                                rowInputs[i].value = tavg;
                            else
                                rowInputs[i].value = tlast;
                        }
                    }
                    else {
                        throw "Err";
                    }

                }

            }
            catch (err) {
                if (err = "Err") {
                    alert(errMsg);
                }

            }
        }
    </script>

    <ui:UIObjectPanel ID="UIObjectPanel1" runat="server" BorderStyle="NotSet" meta:resourcekey="UIObjectPanelResource1">
        <web:object runat="server" ID="panel" Caption="Work Justification" BaseTable="tRequestForQuotation"
            SpellCheckButtonVisible="true" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"
            SaveButtonsVisible="false" ShowWorkflowActionAsButtons="true" OnValidateAndSave="panel_ValidateAndSave"
            OnValidate="panel_Validate"></web:object>
        <span style="display: none">
            <ui:UIButton runat="server" ID="repopulateCatalogueButton" OnClick="repopulateCatalogue_Click"
                CausesValidation="False" meta:resourcekey="repopulateCatalogueButtonResource1" />
        </span>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" meta:resourcekey="tabDetailsResource1"
                    BorderStyle="NotSet">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false"
                        ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIPanel runat="server" ID="panelDetails" meta:resourcekey="panelDetailsResource1"
                        BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelDetails2">
                            <ui:UIPanel runat="server" ID="panelCase" Visible="false">
                                <ui:UISeparator ID="UISeparator2" runat="server" Caption="Case" meta:resourcekey="UISeparator2Resource1" />
                                <ui:UIFieldSearchableDropDownList runat="server" ID="dropCase" PropertyName="CaseID"
                                    Caption="Case" ContextMenuAlwaysEnabled="True" meta:resourcekey="dropCaseResource1"
                                    SearchInterval="300">
                                    <ContextMenuButtons>
                                        <ui:UIButton runat="server" ID="buttonEditCase" ImageUrl="~/images/edit.gif" Text="Edit Case"
                                            OnClick="buttonEditCase_Click" ConfirmText="Please remember to save this Work before editing the Case.\n\nAre you sure you want to continue?"
                                            AlwaysEnabled="True" meta:resourcekey="buttonEditCaseResource1" />
                                        <ui:UIButton runat="server" ID="buttonViewCase" ImageUrl="~/images/view.gif" Text="View Case"
                                            OnClick="buttonViewCase_Click" ConfirmText="Please remember to save this Work before viewing the Case.\n\nAre you sure you want to continue?"
                                            AlwaysEnabled="True" meta:resourcekey="buttonViewCaseResource1" />
                                    </ContextMenuButtons>
                                </ui:UIFieldSearchableDropDownList>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panelWork" BorderStyle="NotSet">
                                <ui:UIFieldTextBox runat="server" ID="textWorkID" PropertyName="Work.ObjectNumber"
                                    Enabled="false" Caption="Work Order" ContextMenuAlwaysEnabled="true" ValidateRequiredField="true">
                                    <ContextMenuButtons>
                                        <ui:UIButton runat="server" ID="buttonEditWork" ConfirmText="Please remember to save this WJ before editing the WJ.\n\nAre you sure you want to continue?"
                                            ImageUrl="~/images/edit.gif" Text="Edit Work Order" AlwaysEnabled="true" OnClick="buttonEditWork_Click" />
                                        <ui:UIButton runat="server" ID="buttonViewWork" ConfirmText="Please remember to save this WJ before editing the WJ.\n\nAre you sure you want to continue?"
                                            ImageUrl="~/images/view.gif" Text="View Work Order" AlwaysEnabled="true" OnClick="buttonViewWork_Click" />
                                    </ContextMenuButtons>
                                </ui:UIFieldTextBox>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panelGroupWJ" BorderStyle="NotSet" meta:resourcekey="panelGroupWJResource1">
                                <ui:UIFieldCheckBox runat="server" ID="checkIsGroupWJ" PropertyName="IsGroupWJ" Caption="Group WJ?"
                                    Visible="true" Text="Yes, this is a group WJ across multiple properties." OnCheckedChanged="checkIsGroupWJ_CheckedChanged"
                                    meta:resourcekey="checkIsGroupWJResource1" TextAlign="Right">
                                </ui:UIFieldCheckBox>
                                <ui:UIFieldCheckBox runat="server" ID="IsGroupApproval" PropertyName="IsGroupApproval"
                                    Caption="Group Approval?" Visible="true" Text="Yes, shall be approved by a group Approval Hierarchy"
                                    TextAlign="Right" OnCheckedChanged="IsGroupApproval_CheckedChanged">
                                </ui:UIFieldCheckBox>
                                <ui:UIFieldTextBox ID="GroupRequestForQuotationID" runat="server" Caption="Parent Group WJ"
                                    PropertyName="GroupRequestForQuotation.ObjectNumber" ContextMenuAlwaysEnabled="True"
                                    ValidateRequiredField="true">
                                    <ContextMenuButtons>
                                        <ui:UIButton ID="buttonEditGroupWJ" runat="server" ConfirmText="Please remember to save this WJ before editing the parent WJ.\n\nAre you sure you want to continue?"
                                            ImageUrl="~/images/edit.gif" OnClick="buttonEditGroupWJ_Click" Text="Edit Group WJ"
                                            AlwaysEnabled="true" />
                                        <ui:UIButton ID="buttonViewGroupWJ" runat="server" ConfirmText="Please remember to save this WJ before viewing the parent WJ.\n\nAre you sure you want to continue?"
                                            ImageUrl="~/images/view.gif" OnClick="buttonViewGroupWJ_Click" Text="View Group WJ"
                                            AlwaysEnabled="true" />
                                    </ContextMenuButtons>
                                </ui:UIFieldTextBox>
                                <br />
                                <br />
                                <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" PropertyName="LocationID"
                                    ValidateRequiredField="true" OnSelectedIndexChanged="ddlLocation_SelectedIndexChanged">
                                </ui:UIFieldDropDownList>
                                <%--<ui:UIFieldListBox runat="server" ID="listLocations" PropertyName="GroupWJLocations"
                                    SelectionMode="Multiple" Caption="Locations" ValidateRequiredField="True" OnSelectedIndexChanged="listLocations_SelectedIndexChanged"
                                    meta:resourcekey="listLocationsResource1"></ui:UIFieldListBox>--%>
                                <ui:UIGridView runat="server" ID="gridLocations" Caption="Locations" OnAction="gridLocations_Action"
                                    ValidateRequiredField="true" PropertyName="GroupWJLocations" BindObjectsToRows="true">
                                    <Commands>
                                        <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="True" CommandName="DeleteLocations"
                                            CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                            ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                        <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                            CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                    </Commands>
                                    <Columns>
                                        <ui:UIGridViewBoundColumn DataField="FastPath" HeaderText="Path" PropertyName="FastPath"
                                            ResourceAssemblyName="" SortExpression="FastPath">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Location" PropertyName="ObjectName"
                                            ResourceAssemblyName="" SortExpression="ObjectName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                    </Columns>
                                </ui:UIGridView>
                                <ui:UIObjectPanel runat="server" ID="gridLocations_panel" BorderStyle="NotSet">
                                    <web:subpanel runat="server" GridViewID="gridLocations" ID="subpanelLocations" OnValidateAndUpdate="subpanelLocations_ValidateAndUpdate"
                                        OnPopulateForm="subpanelLocations_PopulateForm" UpdatePopupVisible="true" />
                                    <ui:UIFieldListBox runat="server" ID="listLocations" PropertyName="GroupWJLocations"
                                        SelectionMode="Multiple" Caption="Locations" ValidateRequiredField="True" OnSelectedIndexChanged="listLocations_SelectedIndexChanged"
                                        meta:resourcekey="listLocationsResource1"></ui:UIFieldListBox>
                                </ui:UIObjectPanel>
                                <ui:UIFieldTextBox ID="CancelledPurchaseOrder" runat="server" Caption="Revised from cancelled PO"
                                    PropertyName="CancelledPurchaseOrder.ObjectNumber" Span="Half" Visible="false"
                                    Enabled="false" ContextMenuAlwaysEnabled="true">
                                    <ContextMenuButtons>
                                        <ui:UIButton Visible="false" runat="server" ID="buttonViewPurchaseOrder" Text="View Purchase Order"
                                            AlwaysEnabled="True" ImageUrl="~/images/view.gif" ConfirmText="Please remember to save this Work Justification before viewing the Purchase Order.\n\nAre you sure you want to continue?"
                                            OnClick="buttonViewPurchaseOrder_Click" meta:resourcekey="buttonViewPurchaseOrderResource1" />
                                        <ui:UIButton Visible="false" runat="server" ID="buttonEditPurchaseOrder" Text="Edit Purchase Order"
                                            AlwaysEnabled="True" ImageUrl="~/images/edit.gif" ConfirmText="Please remember to save this Work Justification before editing the Purchase Order.\n\nAre you sure you want to continue?"
                                            OnClick="buttonEditPurchaseOrder_Click" meta:resourcekey="buttonEditPurchaseOrderResource1" />
                                    </ContextMenuButtons>
                                </ui:UIFieldTextBox>
                            </ui:UIPanel>
                            <ui:UIFieldTextBox runat='server' ID="textCampaign" PropertyName="Campaign" Caption="Campaign"
                                Span="Half" Visible="false">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="Description" runat="server" Caption="Header Description" PropertyName="Description"
                                MaxLength="255" ValidateRequiredField="True" meta:resourcekey="DescriptionResource1"
                                InternalControlWidth="95%" />
                            <ui:UIFieldCheckBox runat="server" ID="checkRecoverable" PropertyName="IsRecoverable"
                                Span="Half" Caption="Recoverable?" Text="Yes, this WJ is recoverable" Hint="(Uncheck if this WJ is non-recoverable)"
                                OnCheckedChanged="checkRecoverable_CheckedChanged">
                            </ui:UIFieldCheckBox>
                            <%--<ui:UIFieldRadioList runat="server" ID="rdlRecoverableType" PropertyName="RecoverableType" Span="Half"
                                ValidateRequiredField="true" Caption="Recoverable" OnSelectedIndexChanged="rdlRecoverableType_SelectedIndexChanged">
                                <Items>
                                    <asp:ListItem Text="No, the WJ is non-recoverable." Value="0" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Yes, the WJ is recoverable." Value="1"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>--%>
                            <ui:UIFieldCheckBox runat="server" ID="checkIsCharged" Caption="" ForeColor="Red"
                                PropertyName="IsCharged" Span="Half" Text="Yes, this WJ is charged out to tenant.">
                            </ui:UIFieldCheckBox>
                            <ui:UIPanel runat="server" ID="Panel_Requestor" Enabled="false" Visible="false">
                                <ui:UISeparator runat="server" ID="RequestorSeparator" Caption="Requestor / Tenant" />
                                <ui:UIFieldLabel runat="server" ID="labelRequestor" PropertyName="TenantLease.Tenant.ObjectName"
                                    Caption="Tenant" Span="Half">
                                </ui:UIFieldLabel>
                                <web:searchdialogbox runat='server' ID="searchTenantLease" BaseTable="tTenantLease"
                                    AutoSearchOnLoad="false" AllowMultipleSelection="false" ButtonSelectText="Select tenant from leases"
                                    Title="Select A Tenant Lease" MaximumNumberOfResults="100" SearchTextBoxPropertyNames="Tenant.ObjectName,ShopName"
                                    OnSelected="searchTenantLease_Selected" OnSearched="searchTenantLease_Searched"
                                    OnCleared="searchTenantLease_Cleared">
                                    <Columns>
                                        <ui:UIGridViewButtonColumn AlwaysEnabled="true" CommandName="AddObject" ImageUrl="~/images/tick.gif">
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Tenant Name" HeaderStyle-Width="300px" PropertyName="Tenant.ObjectName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Unit No" HeaderStyle-Width="180px" PropertyName="Location.ObjectName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Shop Name" HeaderStyle-Width="180px" PropertyName="ShopName">
                                        </ui:UIGridViewBoundColumn>
                                        <%--<ui:UIGridViewBoundColumn HeaderText="Lease Start Date" HeaderStyle-Width="80px" PropertyName="LeaseStartDate" DataFormatString="{0:dd-MMM-yy}"></ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Lease End Date" HeaderStyle-Width="80px" PropertyName="LeaseEndDate" DataFormatString="{0:dd-MMM-yy}"></ui:UIGridViewBoundColumn>--%>
                                    </Columns>
                                    <AdvancedPanel>
                                        <ui:UIFieldTreeList runat="server" ID="treeTenantUnit" Caption="Location" CaptionWidth="100px"
                                            PropertyName="" Span="Half">
                                        </ui:UIFieldTreeList>
                                        <br />
                                        <ui:UIFieldDateTime runat="server" ID="dateLeaseStart" Caption="Lease Start" CaptionWidth="100px"
                                            Span="Half" SearchType="Range" PropertyName="LeaseStartDate">
                                        </ui:UIFieldDateTime>
                                        <br />
                                        <ui:UIFieldDateTime runat="server" ID="dateLeaseEnd" Caption="Lease End" CaptionWidth="100px"
                                            Span="Half" SearchType="Range" PropertyName="LeaseEndDate">
                                        </ui:UIFieldDateTime>
                                    </AdvancedPanel>
                                </web:searchdialogbox>
                                <ui:UIFieldDropDownList runat="server" ID="dropTenantContact" Caption="Tenant Contact"
                                    Span="Half" InternalControlWidth="97%" PropertyName="TenantContactID">
                                </ui:UIFieldDropDownList>
                                <ui:UIButton runat="server" ID="buttonShowTenantDetails" CausesValidation="false"
                                    Text="Show me more details on this tenant." OnClick="buttonShowTenantDetails_Click"
                                    AlwaysEnabled="true" />
                                <ui:UIPanel runat="server" ID="panelTenantDetails" BorderStyle="NotSet">
                                    <ui:UIFieldTextBox ID="RequestorUnitNo" runat="server" Caption="Unit" PropertyName="TenantLease.Location.Path"
                                        Enabled="false" Span="Full">
                                    </ui:UIFieldTextBox>
                                    <%--<ui:UIFieldTextBox ID="RequestorName" runat="server" Caption="Name" PropertyName="RequestorName"
                                        ValidateRequiredField="True" Span="Half" ToolTip="The name of the Requestor to refer by."
                                        meta:resourcekey="RequestorNameResource2" InternalControlWidth="95%" />--%>
                                    <ui:UIFieldTextBox ID="RequestorEmail" runat="server" Caption="Email" PropertyName="RequestorEmail"
                                        Span="Half" meta:resourcekey="RequestorEmailResource1" InternalControlWidth="95%" />
                                    <ui:UIFieldTextBox ID="RequestorCellPhone" runat="server" Caption="Cell Phone" PropertyName="RequestorCellPhone"
                                        Span="Half" meta:resourcekey="RequestorCellResource1" InternalControlWidth="95%" />
                                    <ui:UIFieldTextBox ID="RequestorPhone" runat="server" Caption="Phone" PropertyName="RequestorPhone"
                                        Span="Half" meta:resourcekey="RequestorPhoneResource1" InternalControlWidth="95%" />
                                </ui:UIPanel>
                            </ui:UIPanel>
                            <ui:UISeparator runat="server" ID="sepOtherInfo" Caption="Other Information" />
                            <ui:UIFieldDropDownList runat='server' ID="dropBackgroundType" PropertyName="BackgroundTypeID"
                                Caption="Background Type" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldRadioList runat='server' ID="BudgetGroupID" Caption="Budget Group" PropertyName="BudgetGroupID"
                                ValidateRequiredField="True" meta:resourcekey="BudgetGroupIDResource1" OnSelectedIndexChanged="BudgetGroupID_SelectedIndexChanged"
                                RepeatDirection="Horizontal" RepeatColumns="0">
                            </ui:UIFieldRadioList>
                            <ui:UIFieldRadioList runat='server' ID="dropPurchaseTypeClassification" PropertyName="TransactionTypeGroupID"
                                RepeatDirection="Horizontal" RepeatColumns="0" Caption="Transaction Type Group"
                                ValidateRequiredField="True" OnSelectedIndexChanged="dropPurchaseTypeClassification_SelectedIndexChanged"
                                meta:resourcekey="dropPurchaseTypeClassificationResource1">
                            </ui:UIFieldRadioList>
                            <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType" Caption="Transaction Type"
                                PropertyName="PurchaseTypeID" ValidateRequiredField="True" OnSelectedIndexChanged="dropPurchaseType_SelectedIndexChanged"
                                meta:resourcekey="dropPurchaseTypeResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIHint runat="server" ID="CRVWarning" Font-Bold="true" Visible="false"
                                Text="This Transaction Type will require CRV Serial Number. Please make sure that Tender/Quotation in CRV is created first."></ui:UIHint>
                            <ui:UIButton runat="server" ID="CRVLink" Caption="Click here to go to CRV" Visible="false" OnClick="CRVLink_Click"
                                ImageUrl="~/images/window_add.png" Text="Click here to go to CRV" Font-Size="Large"
                                ConfirmText="Please remember to save this WJ before opening the CRV.\n\nAre you sure you want to continue?" /><br />
                            <ui:UIFieldCheckBox runat="server" ID="checkIsTermContract" PropertyName="IsTermContract"
                                Hint="(Uncheck this if it is not a term contract)" Caption="Term Contract?" Text="Yes, this WJ is for a term contract."
                                OnCheckedChanged="checkIsTermContract_CheckedChanged" meta:resourcekey="checkIsTermContractResource1"
                                TextAlign="Right">
                            </ui:UIFieldCheckBox>
                            <ui:UIFieldLabel ID="StoreID" runat="server" Caption="Store" Span="Full" PropertyName="Store.ObjectName"
                                Enabled="False" meta:resourcekey="StoreIDResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldTextBox ID="textRequestorName" runat="server" Caption="Requestor Name"
                                PropertyName="RequestorName">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDropDownList ID="ddlBillTo" runat="server" Caption="Bill To" PropertyName="BillToID"
                                ValidateRequiredField="True" meta:resourcekey="ddlBillToResource1" Hint="This is the company that appears in the Bill To section of a purchase order.">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" Caption="Bill To Contact Person" ID="BillToContactPersonID"
                                PropertyName="BillToContactPersonID" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldCheckBox runat="server" ID="cbDeliverToOther" Caption="Deliver to Other?"
                                Visible="true" OnCheckedChanged="cbDeliverToOther_CheckedChanged" PropertyName="IsDeliverToOther"
                                Text="Yes, I want to input the delivery address and contact person by myself."
                                meta:resourcekey="DeliverToOtherResource1" TextAlign="Right">
                            </ui:UIFieldCheckBox>
                            <ui:UIFieldTextBox ID="DeliverToAddress" runat="server" Caption="Deliver To" TextMode="MultiLine"
                                Rows="3" PropertyName="DeliverToAddress" Visible="false">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="DeliverToPerson" runat="server" Caption="Deliver To Contact Person"
                                PropertyName="DeliverToPerson" Visible="false">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDropDownList ID="ddlDeliveryTo" runat="server" Caption="Deliver To" PropertyName="DeliveryToID"
                                ValidateRequiredField="True" meta:resourcekey="ddlDeliverToResource1" Hint="This is the company that appears in the Deliver To section of a purchase order.">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" Caption="Deliver To Contact Person" ID="DeliverToContactPersonID"
                                PropertyName="DeliverToContactPersonID" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelDateRequired" BorderStyle="NotSet">
                        <ui:UIFieldDateTime runat='server' ID="DateRequired" Caption="Date Required" Span="Half"
                            PropertyName="DateRequired" ValidateRequiredField="True" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" OnDateTimeChanged="DateRequired_DateTimeChanged"
                            ValidateCompareField="True" ValidationCompareControl="DateEnd" ValidationCompareType="Date"
                            ValidationCompareOperator="LessThanEqual" ShowDateControls="True" />
                        <ui:UIFieldDateTime runat='server' ID="DateEnd" Caption="Date End" Span="Half" PropertyName="DateEnd"
                            ValidateRequiredField="True" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            ValidateCompareField="True" ValidationCompareControl="DateRequired" ValidationCompareType="Date"
                            ValidationCompareOperator="GreaterThanEqual" meta:resourcekey="DateEndResource1"
                            ShowDateControls="True" />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelBackgroundScope" BorderStyle="NotSet">
                        <ui:UIFieldRichTextBox ID="textBackground" runat="server" Caption="Background" PropertyName="Background"
                            EditorHeight="100px">
                        </ui:UIFieldRichTextBox>
                        <ui:UIFieldRichTextBox ID="textScope" runat="server" Caption="Scope" PropertyName="Scope"
                            EditorHeight="100px">
                        </ui:UIFieldRichTextBox>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelHasWarranty" BorderStyle="NotSet">
                        <ui:UIFieldRadioList runat="server" ID="radioHasWarranty" PropertyName="hasWarranty"
                            Caption="Has Warranty?" OnSelectedIndexChanged="radioHasWarranty_SelectedIndexChanged"
                            ValidateRequiredField="true" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" Text="No, this WJ has no warranty" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Yes, this WJ has warranty"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelWarranty">
                            <asp:Label ID="lblWarrantyPeriod" runat="server" Text="Warranty Details*:" CssClass="field-required"
                                Width="158px">
                            </asp:Label>
                            <ui:UIFieldTextBox runat="server" ID="txtWarrantyPeriod" Caption="Warranty Period"
                                PropertyName="WarrantyPeriod" ValidateDataTypeCheck="True" ValidationDataType="Integer"
                                Span="Half" InternalControlWidth="100px" FieldLayout="Flow" ShowCaption="false">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDropDownList runat="server" ID="ddlWarrantyUnit" Caption="Warranty Unit"
                                PropertyName="WarrantyPeriodInterval" Span="Half" InternalControlWidth="100px"
                                ValidateRequiredField="true" FieldLayout="Flow" ShowCaption="false">
                                <Items>
                                    <asp:ListItem Value="0">day(s)</asp:ListItem>
                                    <asp:ListItem Value="1">week(s)</asp:ListItem>
                                    <asp:ListItem Value="2">month(s)</asp:ListItem>
                                    <asp:ListItem Value="3">year(s)</asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox runat="server" ID="textWarranty" Caption="Warranty" PropertyName="Warranty"
                                MaxLength="255" FieldLayout="Flow" ShowCaption="false" InternalControlWidth="500px">
                            </ui:UIFieldTextBox>
                            <%--</td>
                                </tr>
                            </table>--%>
                        </ui:UIPanel>
                        <br />
                        <br />
                        <br />
                    </ui:UIPanel>
                    <!-- For MARCOM add the "panelRequestForQuotationItems" panel here -->
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
                <ui:UITabView runat="server" ID="tabChildWJs" Caption="Child PRs" meta:resourcekey="tabChildWJsResource1"
                    BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelChildWJs" meta:resourcekey="panelChildWJsResource1"
                        BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridChildWJs" Caption="Child PRs" OnAction="gridChildWJs_Action"
                            PropertyName="ChildRequestForQuotation">
                            <Columns>
                                <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject"
                                    ImageUrl="~/images/edit.gif">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="ViewObject"
                                    ImageUrl="~/images/view.gif">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="WJ Number" PropertyName="ObjectNumber"
                                    ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Location.ObjectName" HeaderText="Location" PropertyName="Location.ObjectName"
                                    ResourceAssemblyName="" SortExpression="Location.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="DateRequired" HeaderText="Date Required" PropertyName="DateRequired"
                                    ResourceAssemblyName="" SortExpression="DateRequired" DataFormatString="{0:dd-MMM-yyyy}">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="TaskAmount" HeaderText="Total Amount" PropertyName="TaskAmount"
                                    ResourceAssemblyName="" SortExpression="TaskAmount" DataFormatString="{0:#,##0.00}">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status"
                                    PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates"
                                    SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabLineItems" Caption="Line Items" meta:resourcekey="tabLineItemsResource1"
                    BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelRequestForQuotationItems" meta:resourcekey="panelRequestForQuotationItemsResource1"
                        BorderStyle="NotSet">
                        <web:searchdialogbox runat="server" ID="searchInventory" AllowMultipleSelection="true"
                            BaseTable="tCatalogue" SearchTextBoxPropertyNames="ObjectName,StockCode" ButtonSelectText=""
                            MaximumNumberOfResults="100" OnSelected="searchInventory_Selected" OnSearched="searchInventory_Searched">
                            <Columns>
                                <ui:UIGridViewBoundColumn HeaderText="Catalogue" HeaderStyle-Width="200px" PropertyName="Path">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Stock Code" HeaderStyle-Width="200px" PropertyName="StockCode">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Unit Price" HeaderStyle-Width="200px" PropertyName="UnitPrice">
                                </ui:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Quantity" HeaderStyle-Width="100px">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textQuantity" runat="server" Caption="Quantity" FieldLayout="Flow"
                                            InternalControlWidth="95%" PropertyName="QuantityRequired" ShowCaption="False"
                                            ValidateDataTypeCheck="True" ValidateRangeField="True" ValidateRequiredField="True"
                                            ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeMinInclusive="False"
                                            ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </web:searchdialogbox>
                        <ui:UIButton runat="server" ID="buttonAddMaterialItems" Text="Add Multiple Inventory Items"
                            CausesValidation='False' ImageUrl="~/images/add.gif" OnClick="buttonAddMaterialItems_Click"
                            meta:resourcekey="buttonAddMaterialItemsResource1" />
                        <ui:UIButton runat="server" ID="buttonAddFixedrateItems" Text="Add Multiple Service Items"
                            CausesValidation="False" ImageUrl="~/images/add.gif" OnClick="buttonAddFixedRateItems_Click"
                            meta:resourcekey="buttonAddFixedrateItemsResource1" />
                        <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False" OnClick="buttonItemsAdded_Click"
                            meta:resourcekey="buttonItemsAddedResource1"></ui:UIButton>
                        <br />
                        <br />
                        <ui:UIGridView ID="RequestForQuotationItems" runat="server" Caption="Items" PropertyName="RequestForQuotationItems"
                            SortExpression="ItemNumber" KeyName="ObjectID" meta:resourcekey="RequestForQuotationItemsResource2"
                            Width="100%" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" AllowPaging="false"
                            Style="clear: both;" ImageRowErrorUrl="" OnAction="RequestForQuotationItems_Action"
                            OnRowDataBound="RequestForQuotationItems_RowDataBound">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                    AlwaysEnabled="true" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="Item Number" meta:resourceKey="UIGridViewColumnResource3"
                                    PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemTypeText" HeaderText="Type" meta:resourceKey="UIGridViewColumnResource4"
                                    PropertyName="ItemTypeText" ResourceAssemblyName="" SortExpression="ItemTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemDescription" HeaderText="Line Item Description"
                                    meta:resourceKey="UIGridViewColumnResource5" PropertyName="ItemDescription" ResourceAssemblyName=""
                                    SortExpression="ItemDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Unit of Measure"
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="UnitOfMeasure.ObjectName"
                                    ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ReceiptModeText" HeaderText="Receipt Mode"
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ReceiptModeText"
                                    ResourceAssemblyName="" SortExpression="ReceiptModeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="QuantityRequired" DataFormatString="{0:n}"
                                    HeaderText="Quantity Required" meta:resourceKey="UIGridViewColumnResource7" PropertyName="QuantityRequired"
                                    ResourceAssemblyName="" SortExpression="QuantityRequired">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIHint runat="server" ID="hintRfqItemsAddDelete" meta:resourcekey="hintRfqItemsAddDeleteResource1"
                            Text="This list of items here should be the list of items that will appear in your PO once this WJ is approved. E.g: scope of work, items to purchase, etc.."></ui:UIHint>
                        <ui:UIObjectPanel ID="RequestForQuotationItem_Panel" runat="server" meta:resourcekey="RequestForQuotationItem_PanelResource1"
                            BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="RequestForQuotationItem_SubPanel" GridViewID="RequestForQuotationItems"
                                OnPopulateForm="RequestForQuotationItem_SubPanel_PopulateForm" OnRemoved="RequestForQuotationItem_SubPanel_Removed"
                                OnValidateAndUpdate="RequestForQuotationItem_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldDropDownList ID="ItemNumber" runat="server" Caption="Item Number" PropertyName="ItemNumber"
                                Span="Half" ValidateRequiredField="True" meta:resourcekey="ItemNumberResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldRadioList ID="ItemType" runat="server" Span="Full" Caption="Item Type"
                                PropertyName="ItemType" RepeatColumns="0" OnSelectedIndexChanged="ItemType_SelectedIndexChanged"
                                ValidateRequiredField="True" meta:resourcekey="ItemTypeResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Inventory"></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Service"></asp:ListItem>
                                    <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" Text="Others"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <br />
                            <ui:UIButton ID="buttonAddCatalog" runat="server" AlwaysEnabled="True" CausesValidation="False"
                                ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddCatalogResource1" OnClick="buttonAddCatalog_Click"
                                Text="Add New Catalog" />
                            <ui:UIFieldTreeList ID="CatalogueID" runat="server" Caption="Catalog" PropertyName="CatalogueID"
                                OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater" OnSelectedNodeChanged="CatalogueID_SelectedNodeChanged"
                                ValidateRequiredField="True" meta:resourcekey="CatalogueIDResource1" ShowCheckBoxes="None"
                                TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate" PropertyName="FixedRateID"
                                OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater" OnSelectedNodeChanged="FixedRateID_SelectedNodeChanged"
                                ValidateRequiredField="True" meta:resourcekey="FixedRateIDResource1" ShowCheckBoxes="None"
                                TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldLabel runat="server" ID="UnitOfMeasure" Caption="Unit of Measure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                meta:resourcekey="UnitOfMeasureResource1" DataFormatString="" />
                            <ui:UIFieldLabel runat="server" ID="UnitOfMeasure2" Caption="Unit of Measure" PropertyName="FixedRate.UnitOfMeasure.ObjectName"
                                meta:resourcekey="UnitOfMeasure2Resource1" DataFormatString="" />
                            <ui:UIFieldTextBox ID="ItemDescription" runat="server" Caption="Line Item Description"
                                PropertyName="ItemDescription" MaxLength="2000" ValidateRequiredField="True"
                                meta:resourcekey="ItemDescriptionResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox ID="AdditionalDescription" runat="server" Caption="Additional Description"
                                Hint="This description will appear on the PO Printout instead of Inventory/Fixed Rate Catalogue description (max length 1000 characters)."
                                PropertyName="AdditionalDescription" MaxLength="1000" ValidateRequiredField="true">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" Caption="Unit of Measure"
                                PropertyName="UnitOfMeasureID" ValidateRequiredField="true" meta:resourcekey="UnitOfMeasureIDResource1" />
                            <ui:UIFieldRadioList runat="server" ID="radioReceiptMode" PropertyName="ReceiptMode"
                                Caption="Receipt Mode" OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged"
                                meta:resourcekey="radioReceiptModeResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource5" Text="Receive by Quantity"></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource6" Text="Receive by Dollar Amount"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldTextBox ID="textQuantityRequired" runat="server" Caption="Quantity Required"
                                PropertyName="QuantityRequired" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="QuantityRequiredResource1"
                                InternalControlWidth="95%" />
                            <br />
                            <%--<ui:UIFieldTextBox ID="ChargeAmount" runat="server" Caption="Charge Amount"
                                PropertyName="ChargeAmount" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="QuantityRequiredResource1"
                                InternalControlWidth="95%" />
                            <ui:UIFieldTextBox ID="RecoverableAmount" runat="server" Caption="Recoverable Amount"
                                PropertyName="ChargeAmount" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="QuantityRequiredResource1"
                                InternalControlWidth="95%" />--%>
                            <ui:UIGridView runat="server" ID="gridRequestForQuotationItemLocations" PropertyName="RequestForQuotationItemLocation"
                                Caption="" BindObjectsToRows="true" CheckBoxColumnVisible="false" DataKeyNames="ObjectID"
                                ShowCaption="false" ShowHeader="false" AllowPaging="false" OnRowDataBound="gridRequestForQuotationItemLocations_RowDataBound">
                                <Columns>
                                    <ui:UIGridViewBoundColumn HeaderText="Location" PropertyName="Location.ObjectName">
                                        <ItemStyle Width="153px" />
                                    </ui:UIGridViewBoundColumn>
                                    <%--<ui:UIGridViewTemplateColumn HeaderText="Quantity Required">
                                        <ItemTemplate>
                                            <ui:UIFieldLabel runat="server" Text="1" ID="LabelLocationQuantityRequired" Width="150px">
                                            </ui:UIFieldLabel>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>--%>
                                    <ui:UIGridViewTemplateColumn HeaderText="Quantity Required">
                                        <ItemTemplate>
                                            <ui:UIFieldTextBox runat="server" ID="textLocationQuantityRequired" Width="170px"
                                                Caption="Quantity Required" CaptionPosition="Top" PropertyName="QuantityRequired"
                                                ValidateRequiredField="true" ValidateDataTypeCheck="true" ValidationDataType="Integer"
                                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer">
                                            </ui:UIFieldTextBox>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>
                                    <ui:UIGridViewTemplateColumn HeaderText="Ratio">
                                        <ItemTemplate>
                                            <ui:UIFieldTextBox runat="server" ID="textLocationDollarRequired" Width="170px" Caption="Ratio"
                                                PropertyName="AmountRatio" CaptionPosition="Top" ValidateRegexField="true" ValidateDataTypeCheck="true"
                                                ValidationDataType="Currency" ValidateRangeField="true" ValidationRangeMin="0"
                                                ValidationRangeType="Currency">
                                            </ui:UIFieldTextBox>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabQuotations" Caption="Vendors & Quotations" meta:resourcekey="tabQuotationsResource1"
                    BorderStyle="NotSet">
                    <ui:UIFieldTextBox ID="txtRFQTitle" runat="server" MaxLength="255" Caption="RFQ Title"
                        PropertyName="RFQTitle" InternalControlWidth="95%">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat="server" ID="ddl_EmployerCompany" Caption="Employer Company"
                        PropertyName="EmployerCompanyID">
                    </ui:UIFieldDropDownList>
                    <br />
                    <br />
                    <%--<ui:UIButton ID="buttonAddMultipleVendors" runat="server" ImageUrl="~/images/add.gif"
                        Text="Add Multiple Vendors" CausesValidation="False" OnClick="buttonAddMultipleVendors_Click"
                        meta:resourcekey="buttonAddMultipleVendorsResource1" />
                    <ui:UIButton runat="server" ID="buttonVendorsAdded" CausesValidation="False" OnClick="buttonVendorsAdded_Click"
                        meta:resourcekey="buttonVendorsAddedResource1"></ui:UIButton>--%>
                    <web:searchdialogbox runat="server" ID="searchMultipleVendor" AllowMultipleSelection="true"
                        BaseTable="tVendor" Title="Add Multiple Vendor" AutoSearchOnLoad="false" ButtonSelectText=""
                        MaximumNumberOfResults="200" SearchTextBoxPropertyNames="ObjectName" OnSelected="searchMultipleVendor_Selected"
                        OnSearched="searchMultipleVendor_Searched">
                        <Columns>
                            <ui:UIGridViewBoundColumn HeaderText="Vendor Name" PropertyName="ObjectName" DataField="ObjectName"
                                HeaderStyle-Width="200px">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Operating Address" PropertyName="OperatingAddress"
                                DataField="OperatingAddress" HeaderStyle-Width="300px">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Contact Person" PropertyName="OperatingContactPerson"
                                DataField="OperatingContactPerson" HeaderStyle-Width="150px">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                        <AdvancedPanel>
                            <ui:UIFieldTextBox runat="server" ID="textSearchOperatingContactPerson" PropertyName="OperatingContactPerson"
                                Caption="Operating Contact Person" CaptionWidth="120px" Span="Half">
                            </ui:UIFieldTextBox>
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="textSearchOperatingAddress" PropertyName="OperatingAddress"
                                Caption="Operating Address" CaptionWidth="120px" Span="Half">
                            </ui:UIFieldTextBox>
                        </AdvancedPanel>
                    </web:searchdialogbox>
                    <ui:UIPanel runat="server" ID="panelCRV">
                        <ui:UISeparator ID="UISeparator1" runat="server" Caption="CRV" />
                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropCRVSerialNumbers" PropertyName="CRVSerialNumber"
                            Span="Half" ValidateRequiredField="true" Caption="CRV Serial Numbers" OnSelectedIndexChanged="dropCRVSerialNumbers_SelectedIndexChanged">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIButton runat="server" ID="buttonRefreshCRVSerialNumbers" ImageUrl="~/images/refresh.gif"
                            OnClick="buttonRefreshCRVSerialNumbers_Click" />
                        <br />
                        <ui:UIFieldTextBox runat="server" ID="textCRVProjectTitle" PropertyName="CRVProjectTitle"
                            Caption="Project Title" Enabled="false">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textCRVProjectRefNo" PropertyName="CRVProjectReferenceNo" Visible="false"
                            Caption="Project Reference Number" Enabled="false">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textCRVProjectDescription" PropertyName="CRVProjectDescription"
                            Caption="Project Description" Enabled="false">
                        </ui:UIFieldTextBox>
                        <ui:UIButton runat="server" ID="buttonRetrieveTenders" Text="Retrieve Tenders" OnClick="buttonRetrieveTenders_Click" ImageUrl="~/images/Symbol-Refresh-big.gif" />
                        <ui:UIButton runat="server" ID="buttonClearTenders" Text="Clear Tenders" OnClick="buttonClearTenders_Click" ImageUrl="~/images/cross.gif" />
                    </ui:UIPanel>
                    <ui:UIHint runat="server" ID="IPTVendorGridWarning" Text="<font color='red'>Selected IPT Vendors are highlighted in red.</font>"
                        Visible="false" ForeColor="Red"></ui:UIHint>
                    <ui:UIGridView ID="RequestForQuotationVendors" runat="server" PropertyName="RequestForQuotationVendors"
                        SortExpression="Vendor.ObjectName" Caption="Vendors' Quotations" OnAction="RequestForQuotationVendor_Action"
                        KeyName="ObjectID" meta:resourcekey="RequestForQuotationVendorsResource1" Width="100%"
                        PagingEnabled="True" OnRowDataBound="RequestForQuotationVendors_RowDataBound"
                        DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                        ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource3" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource4" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddVendors"
                                CommandText="Add Multiple Vendor" ImageUrl="~/images/add.gif" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject"
                                ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource10">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource11">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="PrintRFQ"
                                ImageUrl="~/images/printer.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="Vendor.ObjectName" HeaderText="Vendor Name"
                                meta:resourceKey="UIGridViewColumnResource12" PropertyName="Vendor.ObjectName"
                                ResourceAssemblyName="" SortExpression="Vendor.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <%--<cc1:UIGridViewBoundColumn DataField="ContactEmail" HeaderText="Email" meta:resourceKey="UIGridViewColumnResource13"
                                PropertyName="ContactEmail" ResourceAssemblyName="" SortExpression="ContactEmail">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ContactPhone" HeaderText="Phone" meta:resourceKey="UIGridViewColumnResource14"
                                PropertyName="ContactPhone" ResourceAssemblyName="" SortExpression="ContactPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ContactCellPhone" HeaderText="Cell Phone" meta:resourceKey="UIGridViewColumnResource15"
                                PropertyName="ContactCellPhone" ResourceAssemblyName="" SortExpression="ContactCellPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ContactFax" HeaderText="Fax" meta:resourceKey="UIGridViewColumnResource16"
                                PropertyName="ContactFax" ResourceAssemblyName="" SortExpression="ContactFax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ContactPerson" HeaderText="Contact Person"
                                meta:resourceKey="UIGridViewColumnResource17" PropertyName="ContactPerson" ResourceAssemblyName=""
                                SortExpression="ContactPerson">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                            <cc1:UIGridViewBoundColumn DataField="IsSubmittedText" HeaderText="Submitted" meta:resourcekey="UIGridViewBoundColumnResource2"
                                PropertyName="IsSubmittedText" ResourceAssemblyName="" SortExpression="IsSubmittedText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="DateOfQuotation" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Date of Quotation" meta:resourcekey="UIGridViewBoundColumnResource3"
                                PropertyName="DateOfQuotation" ResourceAssemblyName="" SortExpression="DateOfQuotation">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Quotation&lt;br/&gt; Ref No."
                                PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber"
                                HtmlEncode="false">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Currency.ObjectName" HeaderText="Currency"
                                meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Currency.ObjectName"
                                ResourceAssemblyName="" SortExpression="Currency.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Currency.CurrencySymbol" meta:resourcekey="UIGridViewBoundColumnResource5"
                                PropertyName="Currency.CurrencySymbol" ResourceAssemblyName="" SortExpression="Currency.CurrencySymbol">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TotalQuotationInSelectedCurrency" DataFormatString="{0:n}"
                                HeaderText="Quotation" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="TotalQuotationInSelectedCurrency"
                                ResourceAssemblyName="" SortExpression="TotalQuotationInSelectedCurrency">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TotalQuotation" DataFormatString="{0:c}" HeaderText="Quotation&lt;br/&gt;(Base Currency)"
                                meta:resourceKey="UIGridViewColumnResource18" PropertyName="TotalQuotation" ResourceAssemblyName=""
                                SortExpression="TotalQuotation" HtmlEncode="false">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn HeaderText="Percentage&lt;br/&gt;Above Minimum" PropertyName="PercentageAboveMinimumQuoteText"
                                HtmlEncode="false">
                            </cc1:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Attachments">
                                <ItemTemplate>
                                    <asp:DataList runat="server" ID="listAttachment">
                                        <ItemTemplate>
                                            <ui:UIButton runat="server" ID="buttonDownloadAttachment" AlwaysEnabled="true" OnClick="buttonDownloadAttachment_Click">
                                            </ui:UIButton>
                                        </ItemTemplate>
                                    </asp:DataList>
                                </ItemTemplate>
                                <ItemStyle VerticalAlign="Middle" />
                                <HeaderStyle Font-Bold="true" />
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="RequestForQuotationVendors_Panel" runat="server" meta:resourcekey="RequestForQuotationVendors_PanelResource1"
                        BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="RequestForQuotationVendors_SubPanel" GridViewID="RequestForQuotationVendors"
                            UpdatePopupVisible="false" OnValidateAndUpdate="RequestForQuotationVendors_SubPanel_ValidateAndUpdate"
                            OnPopulateForm="RequestForQuotationVendors_SubPanel_PopulateForm" OnRemoved="RequestForQuotationVendors_SubPanel_Removed" />
                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropVendor" PropertyName="VendorID"
                            Caption="Vendor" OnSelectedIndexChanged="dropVendor_SelectedIndexChanged" ValidateRequiredField='True'
                            MaximumNumberOfItems="100" meta:resourcekey="dropVendorResource1" SearchInterval="300">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldLabel runat="server" ID="IPTVendorSubpanelWarning" Text="You have selected an IPT Vendor."
                            ForeColor="Red" Visible="false">
                        </ui:UIFieldLabel>
                        <ui:UIFieldDropDownList runat="server" ID="ddlContactPerson" Caption="Contact Person"
                            PropertyName="VendorContactID" OnSelectedIndexChanged="ddlContactPerson_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldCheckBox runat="server" ID="checkIsSubmitted" PropertyName="IsSubmitted"
                            Caption="Submitted" Text="Yes, a quotation has been submitted by the vendor."
                            OnCheckedChanged="checkIsSubmitted_CheckedChanged" meta:resourcekey="checkIsSubmittedResource1"
                            TextAlign="Right">
                        </ui:UIFieldCheckBox>
                        <ui:UIPanel runat="server" ID="panelQuotationDetails" BorderStyle="NotSet" meta:resourcekey="panelQuotationDetailsResource1">
                            <ui:UIFieldDateTime runat="server" ID="dateDateOfQuotation" PropertyName="DateOfQuotation"
                                Caption="Date of Quotation" OnDateTimeChanged="dateDateOfQuotation_DateTimeChanged"
                                ValidateRequiredField="True" meta:resourcekey="dateDateOfQuotationResource1"
                                ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTextBox runat="server" ID="textQuotationReferenceNumber" PropertyName="ObjectNumber"
                                Caption="Quotation Ref No.">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldCheckBox runat="server" ID="checkShowOptionalDetails" Caption="Details"
                                Text="Yes, I want to see/update more detailed information about this quotation."
                                OnCheckedChanged="checkShowOptionalDetails_CheckedChanged" meta:resourcekey="checkShowOptionalDetailsResource1"
                                TextAlign="Right">
                            </ui:UIFieldCheckBox>
                            <ui:UIPanel runat="server" ID="panelQuotationOptionalDetails" BorderStyle="NotSet"
                                meta:resourcekey="panelQuotationOptionalDetailsResource1">
                                <ui:UIFieldTextBox runat="server" ID="ContactAddressCountry" PropertyName="ContactAddressCountry"
                                    Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="ContactAddressCountryResource1"
                                    InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactAddressState" PropertyName="ContactAddressState"
                                    Caption="State" Span="Half" MaxLength="255" meta:resourcekey="ContactAddressStateResource1"
                                    InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactAddressCity" PropertyName="ContactAddressCity"
                                    Caption="City" Span="Half" MaxLength="255" meta:resourcekey="ContactAddressCityResource1"
                                    InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactAddress" PropertyName="ContactAddress"
                                    Caption="Address" MaxLength="255" meta:resourcekey="ContactAddressResource1"
                                    InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactCellPhone" PropertyName="ContactCellPhone"
                                    Caption="Cellphone" Span="Half" meta:resourcekey="ContactCellPhoneResource1"
                                    InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactEmail" PropertyName="ContactEmail" Caption="Email"
                                    Span="Half" meta:resourcekey="ContactEmailResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactFax" PropertyName="ContactFax" Caption="Fax"
                                    Span="Half" meta:resourcekey="ContactFaxResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactPhone" PropertyName="ContactPhone" Caption="Phone"
                                    Span="Half" meta:resourcekey="ContactPhoneResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="ContactPerson" PropertyName="ContactPerson"
                                    Caption="Contact Person" meta:resourcekey="ContactPersonResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="FreightTerms" PropertyName="FreightTerms" Caption="Freight Terms"
                                    TextMode="MultiLine" Rows="3" meta:resourcekey="FreightTermsResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="PaymentTerms" PropertyName="PaymentTerms" Caption="Payment Terms"
                                    TextMode="MultiLine" Rows="3" meta:resourcekey="PaymentTermsResource1" InternalControlWidth="95%" />
                            </ui:UIPanel>
                            <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID"
                                Span="Half" Caption="Main Currency" ValidateRequiredField="True" OnSelectedIndexChanged="dropCurrency_SelectedIndexChanged"
                                meta:resourcekey="dropCurrencyResource1">
                            </ui:UIFieldDropDownList>
                            <br />
                            <asp:Label runat="server" ID="labelExchangeRate" meta:resourcekey="labelExchangeRateResource1"
                                Text="Exchange Rate*:" CssClass="field-required" Width="157px"></asp:Label>
                            <asp:Label runat="server" ID="labelER1" meta:resourcekey="labelER1Resource1" Text="1"></asp:Label>
                            <ui:UIFieldLabel runat="server" ID="labelERThisCurrency" ShowCaption="False" FieldLayout="Flow"
                                InternalControlWidth="20px" PropertyName="Currency.ObjectName" DataFormatString=""
                                CssClass="field-required" meta:resourcekey="labelERThisCurrencyResource1">
                            </ui:UIFieldLabel>
                            <asp:Label runat="server" ID="labelEREquals" meta:resourcekey="labelEREqualsResource1"
                                Text="is equal to" CssClass="field-required"></asp:Label>
                            <ui:UIFieldTextBox runat="server" ID="textForeignToBaseExchangeRate" PropertyName="ForeignToBaseExchangeRate"
                                Caption="Exchange Rate" Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True"
                                ValidationDataType="Currency" FieldLayout="Flow" InternalControlWidth="60px"
                                ShowCaption="False" meta:resourcekey="textForeignToBaseExchangeRateResource1" />
                            <asp:Label runat="server" ID="labelERBaseCurrency" CssClass="field-required" meta:resourcekey="labelERBaseCurrencyResource1"></asp:Label>
                            <ui:UISeparator runat="server" ID="sepVendorQuotationItems" Caption="Vendor Quotation Items" />
                            <ui:UIGridView ID="RequestForQuotationVendorItems" runat="server" Caption="Quotation"
                                AllowPaging="false" BindObjectsToRows="True" CheckBoxColumnVisible="False" PropertyName="RequestForQuotationVendorItems"
                                SortExpression="[ItemNumber] ASC" KeyName="ObjectID" meta:resourcekey="RequestForQuotationVendorItemsResource1"
                                Width="100%" PagingEnabled="True" OnRowDataBound="RequestForQuotationVendorItems_RowDataBound"
                                DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                                ImageRowErrorUrl="">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Columns>
                                    <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="No." meta:resourceKey="UIGridViewColumnResource19"
                                        PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ItemTypeText" HeaderText="Type" meta:resourceKey="UIGridViewColumnResource20"
                                        PropertyName="ItemTypeText" ResourceAssemblyName="" SortExpression="ItemTypeText">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ItemDescription" HeaderText="Description" meta:resourceKey="UIGridViewColumnResource21"
                                        PropertyName="ItemDescription" ResourceAssemblyName="" SortExpression="ItemDescription">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Unit of Measure"
                                        meta:resourceKey="UIGridViewColumnResource22" PropertyName="UnitOfMeasure.ObjectName"
                                        ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <%--<cc1:UIGridViewBoundColumn DataField="QuantityProvided" HeaderText="Quantity Provided"
                                        meta:resourceKey="UIGridViewColumnResource23" PropertyName="QuantityProvided"
                                        ResourceAssemblyName="" SortExpression="QuantityProvided">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>--%>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Quantity Provided" meta:resourceKey="UIGridViewColumnResource23">
                                        <ItemTemplate>
                                            <cc1:UIFieldTextBox ID="QuantityProvided" runat="server" Caption="Quantity" CaptionWidth="1px"
                                                ShowCaption="false" DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="70px"
                                                meta:resourceKey="QuantityProvidedResource1" PropertyName="QuantityProvided"
                                                ValidateDataTypeCheck="True" ValidateRangeField="True" ValidateRequiredField="True"
                                                ValidationDataType="Currency" ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                                ValidationRangeType="Currency">
                                            </cc1:UIFieldTextBox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="100px" Font-Bold="true" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Unit Price&lt;br/&gt;" meta:resourceKey="UIGridViewColumnResource24">
                                        <ItemTemplate>
                                            <cc1:UIFieldTextBox ID="UnitPrice" runat="server" Caption="Unit Price" CaptionWidth="1px"
                                                ShowCaption="false" FieldLayout="Flow" InternalControlWidth="70px" meta:resourceKey="UnitPriceResource1"
                                                PropertyName="UnitPriceInSelectedCurrency" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                                ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                                ValidationRangeType="Currency" ValidationNumberOfDecimalPlaces="4">
                                            </cc1:UIFieldTextBox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="100px" Font-Bold="true" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Sub Total&lt;br/&gt;">
                                        <ItemTemplate>
                                            <ui:UIFieldLabel runat="server" ID="labelSubTotal" ShowCaption="false" FieldLayout="Flow"
                                                PropertyName="SubtotalInSelectedCurrency" DataFormatString="{0:#,##0.00}" InternalControlWidth="70px">
                                            </ui:UIFieldLabel>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="70px" Font-Bold="true" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Recoverable Amount&lt;br/&gt;">
                                        <ItemTemplate>
                                            <cc1:UIFieldTextBox ID="RecoverableAmount" runat="server" Caption="Recoverable Amount"
                                                CaptionWidth="1px" ShowCaption="false" FieldLayout="Flow" InternalControlWidth="70px"
                                                ValidationCompareType="Currency" PropertyName="RecoverableAmountInSelectedCurrency"
                                                ValidateDataTypeCheck="True" ValidateRangeField="True" ValidateRequiredField="True"
                                                ValidationDataType="Currency" ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                                ValidationRangeType="Currency" ValidationNumberOfDecimalPlaces="4">
                                            </cc1:UIFieldTextBox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="100px" Font-Bold="true" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIPanel>
                        <br />
                        <br />
                        <ui:UIPanel runat="server" ID="panelVendorAttachments">
                            <ui:UISeparator ID="UISeparator4" runat="server" Caption="Attachments" />
                            <web:fileuploaddialogbox runat="server" ID="fileUploadVendorQuotation" NumberOfFileUploads="2"
                                Title="Attach Vendor Quotation(s)" OnUploaded="fileUploadVendorQuotation_Uploaded" />
                            <ui:UIPanel runat="server" ID="panelgridAttachments">
                                <ui:UIGridView runat='server' ID="gridDocument" Caption="Vendor quotations attachments"
                                    PropertyName="Attachments" CaptionWidth="120px" KeyName="ObjectID" OnAction="gridDocument_Action"
                                    OnRowDataBound="gridDocument_RowDataBound">
                                    <Commands>
                                        <ui:UIGridViewCommand CommandName="UploadDocument" CommandText="Upload" ImageUrl="~/images/upload.png" />
                                        <ui:UIGridViewCommand CommandName="DeleteDocument" CommandText="Delete" ImageUrl="~/images/delete.gif"
                                            ConfirmText="Are you sure you wish to delete the selected documents?" />
                                    </Commands>
                                    <Columns>
                                        <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewDocument"
                                            HeaderText="" meta:resourcekey="UIGridViewColumnResource1" AlwaysEnabled="true">
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteDocument"
                                            HeaderText="" ConfirmText="Are you sure you wish to delete this document?" meta:resourcekey="UIGridViewColumnResource2">
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="CreatedUser" HeaderText="Created User">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Created Date Time">
                                        </ui:UIGridViewBoundColumn>
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
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAward" Caption="Award" meta:resourcekey="tabAwardResource1"
                    BorderStyle="NotSet">
                    <ui:UIPanel runat='server' ID="panelQuotations">
                        <ui:UIGridView ID="gridAwardItems" runat="server" Caption="Items" PropertyName="RequestForQuotationItems"
                            SortExpression="ItemNumber" KeyName="ObjectID" ShowFooter="True" PageSize="200"
                            BindObjectsToRows="true" Width="100%" PagingEnabled="True" OnRowDataBound="gridAwardItems_RowDataBound"
                            DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridAwardItemsResource1"
                            RowErrorColor="" Style="clear: both;" ImageRowErrorUrl="" OnAction="gridAwardItems_Action">
                            <PagerSettings Mode="NumericFirstLast" Visible="False" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="Number" meta:resourcekey="UIGridViewBoundColumnResource7"
                                    PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemTypeText" HeaderText="Type" meta:resourcekey="UIGridViewBoundColumnResource8"
                                    PropertyName="ItemTypeText" ResourceAssemblyName="" SortExpression="ItemTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemDescription" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource9"
                                    PropertyName="ItemDescription" ResourceAssemblyName="" SortExpression="ItemDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Unit of Measure"
                                    meta:resourcekey="UIGridViewBoundColumnResource10" PropertyName="UnitOfMeasure.ObjectName"
                                    ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ReceiptModeText" HeaderText="Receipt Mode"
                                    meta:resourcekey="UIGridViewBoundColumnResource11" PropertyName="ReceiptModeText"
                                    ResourceAssemblyName="" SortExpression="ReceiptModeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="QuantityRequired" DataFormatString="{0:#,##0.00##}"
                                    HeaderText="Quantity Required" meta:resourcekey="UIGridViewBoundColumnResource12"
                                    PropertyName="QuantityRequired" ResourceAssemblyName="" SortExpression="QuantityRequired">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="QuantityOrdered" DataFormatString="{0:#,##0.00##}"
                                    HeaderText="Quantity Ordered" PropertyName="QuantityOrdered" ResourceAssemblyName=""
                                    SortExpression="QuantityOrdered">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AwardedVendor.ObjectName" HeaderText="Vendor Awarded"
                                    meta:resourcekey="UIGridViewBoundColumnResource13" PropertyName="AwardedVendor.ObjectName"
                                    ResourceAssemblyName="" SortExpression="AwardedVendor.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Currency.ObjectName" HeaderText="Currency"
                                    meta:resourcekey="UIGridViewBoundColumnResource14" PropertyName="Currency.ObjectName"
                                    ResourceAssemblyName="" SortExpression="Currency.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Currency.CurrencySymbol" meta:resourcekey="UIGridViewBoundColumnResource15"
                                    PropertyName="Currency.CurrencySymbol" ResourceAssemblyName="" SortExpression="Currency.CurrencySymbol">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPriceInSelectedCurrency" HeaderText="Unit Price"
                                    meta:resourcekey="UIGridViewBoundColumnResource16" PropertyName="UnitPriceInSelectedCurrency"
                                    ResourceAssemblyName="" SortExpression="UnitPriceInSelectedCurrency">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" HeaderText="Unit Price&lt;br/&gt;(Base Currency)"
                                    HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource17" PropertyName="UnitPrice"
                                    ResourceAssemblyName="" SortExpression="UnitPrice">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Subtotal" DataFormatString="{0:c}" FooterAggregate="Sum"
                                    HeaderText="Subtotal&lt;br/&gt;(Base Currency)" HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource19"
                                    PropertyName="Subtotal" ResourceAssemblyName="" SortExpression="Subtotal">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="RecoverableAmount" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Recoverable&lt;br/&gt;(Base Currency)" HtmlEncode="False"
                                    PropertyName="RecoverableAmount" ResourceAssemblyName="" SortExpression="RecoverableAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%--<cc1:UIGridViewTemplateColumn HeaderText="Awarded Date" SortExpression="AwardedDate">
                                    <ItemTemplate>
                                        <ui:UIFieldDateTime runat="server" ID="AwardedDate" PropertyName="AwardedDate" DateFormatString="dd-MMM-yyyy"
                                            FieldLayout="Flow" Enabled="false">
                                        </ui:UIFieldDateTime>
                                    </ItemTemplate>
                                </cc1:UIGridViewTemplateColumn>--%>
                                <ui:UIGridViewTemplateColumn HeaderText="Copied To">
                                    <HeaderStyle Font-Bold="true" />
                                    <ItemTemplate>
                                        <ui:UIGridView runat='server' ID="gridPurchaseOrderItems" PropertyName="PurchaseOrderItems"
                                            SortExpression="PurchaseOrder.ObjectNumber ASC" AllowPaging="false" ShowCaption="false"
                                            FieldLayout="Flow" EnableTheming="false" DataKeyNames="ObjectID" CheckBoxColumnVisible="false"
                                            ShowHeader="false" OnRowCommand="gridPurchaseOrderItems_RowCommand" OnRowDataBound="gridPurchaseOrderItems_RowDataBound">
                                            <Columns>
                                                <cc1:UIGridViewBoundColumn DataField="PurchaseOrderID" HeaderText="" meta:resourcekey="UIGridViewBoundColumnResource20"
                                                    PropertyName="PurchaseOrderID" ResourceAssemblyName="" SortExpression="PurchaseOrderID">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditPO" ImageUrl="~/images/edit.gif"
                                                    AlwaysEnabled="true" ConfirmText="Are you sure you wish to open this PO/LOA for editing? Please remember to save the Purchase Requisition, otherwise changes that you have made will be lost.">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </ui:UIGridViewButtonColumn>
                                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewPO" ImageUrl="~/images/view.gif"
                                                    AlwaysEnabled="true" ConfirmText="Are you sure you wish to open this PO/LOA for viewing? Please remember to save the Purchase Requisition, otherwise changes that you have made will be lost.">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </ui:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="PurchaseOrder.ObjectNumber" HeaderText="" meta:resourcekey="UIGridViewBoundColumnResource20"
                                                    PropertyName="PurchaseOrder.ObjectNumber" ResourceAssemblyName="" SortExpression="PurchaseOrder.ObjectNumber">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIHint runat="server" ID="hintQuotationPolicy" ImageUrl="~/images/error.gif"
                            meta:resourcekey="hintQuotationPolicyResource1" Text="">
                        </ui:UIHint>
                        <br />
                        <ui:UIPanel runat="server" ID="panelAwardVendor" meta:resourcekey="panelAwardResource1"
                            BorderStyle="NotSet">
                            <%--<ui:UIFieldDateTime runat="server" ID="AwardedDate" Caption="Awarded Date" ShowDateControls="true"
                                ShowTimeControls="false">
                            </ui:UIFieldDateTime>--%>
                            <ui:UIFieldDropDownList runat="server" ID="dropVendorToAward" Caption="Select to Award to Vendor"
                                CaptionWidth="150px" OnSelectedIndexChanged="dropVendorToAward_SelectedIndexChanged"
                                meta:resourcekey="dropVendorToAwardResource1">
                            </ui:UIFieldDropDownList>
                            <br />
                            <ui:UIHint runat="server" ID="IPTVendorAwardWarning" Text="<font color='red'>You have awarded an IPT Vendor.</font>"
                                Visible="false"></ui:UIHint>
                            <br />
                            <table cellpadding='0' cellspacing='0' border='0' style="clear: both">
                                <tr>
                                    <td>
                                        <ui:UIButton runat="server" ID="buttonClearAwardOnSelectedItems" Text="Clear the award for selected items"
                                            ImageUrl="~/images/delete.gif" CausesValidation='False' OnClick="buttonClearAwardOnSelectedItems_Click"
                                            meta:resourcekey="buttonClearAwardOnSelectedItemsResource1" />
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelGeneratePOButton" meta:resourcekey="panelGeneratePOButtonResource1"
                            BorderStyle="NotSet">
                            <ui:UIButton runat="server" ID="buttonGeneratePOFromLineItems" Text="Generate PO from Selected Line Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGeneratePOFromLineItems_Click" meta:resourcekey="buttonGeneratePOResource1" />
                            <ui:UIButton runat="server" ID="buttonGenerateLOAFromLineItems" Text="Generate LOA from Selected Line Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGenerateLOAFromLineItems_Click" />
                            <ui:UIButton runat="server" ID="buttonGeneratePO" Text="Generate PO for all items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGeneratePO_Click" meta:resourcekey="buttonGeneratePOResource2" />
                            <ui:UIButton runat="server" ID="buttonGenerateLOA" Text="Generate LOA for all items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGenerateLOA_Click" />
                            <ui:UIButton runat="server" ID="buttonGenerateGroupWJPO" Text="Generate PO for Group WJ"
                                Visible="false" meta:resourcekey="buttonGenerateGroupWJPOResource1" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" Caption="Justification" meta:resourcekey="sep1Resource1" />
                    </ui:UIPanel>
                    <ui:UIDialogBox runat="server" ID="popupGeneratePO" Title="Are you sure you wish to generate Purchase Order / LOA for these Purchase Requisition items?"
                        DialogWidth="670px" Button1CausesValidation="true" Button1AutoClosesDialogBox="true"
                        Button1Text="OK" Button1AlwaysEnabled="true" Button1CommandName="Confirm" Button1FontBold="true"
                        Button1ImageUrl="~/images/add.gif" Button2CausesValidation="false" Button2AutoClosesDialogBox="true"
                        Button2Text="Cancel" Button2AlwaysEnabled="true" Button2CommandName="Cancel"
                        Button2FontBold="true" Button2ImageUrl="~/images/delete.gif" OnButtonClicked="popupGeneratePO_ButtonClicked">
                        <ui:UIGridView ID="gridGeneratePO" runat="server" Caption="Items" KeyName="ObjectID"
                            ScrollableRows="true" ShowFooter="False" PageSize="200" CheckBoxColumnVisible="false"
                            ScrollableHeight="200px" OnRowDataBound="gridGeneratePO_RowDataBound" DataKeyNames="ObjectID"
                            GridLines="Both" AllowPaging="false" SortExpression="ItemNumber ASC" RowErrorColor=""
                            Style="clear: both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" Visible="False" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="No." PropertyName="ItemNumber"
                                    ResourceAssemblyName="" SortExpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" Width="20px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemDescription" HeaderText="Description" PropertyName="ItemDescription"
                                    ResourceAssemblyName="" SortExpression="ItemDescription">
                                    <HeaderStyle HorizontalAlign="Left" Width="250px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ReceiptModeText" HeaderText="Receipt Mode"
                                    meta:resourcekey="UIGridViewBoundColumnResource11" PropertyName="ReceiptModeText"
                                    ResourceAssemblyName="" SortExpression="ReceiptModeText">
                                    <HeaderStyle HorizontalAlign="Left" Width="50px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="QuantityProvided" DataFormatString="{0:#,##0.00}"
                                    HeaderText="Qty Provided" PropertyName="QuantityProvided" ResourceAssemblyName=""
                                    SortExpression="QuantityProvided">
                                    <HeaderStyle HorizontalAlign="Left" Width="50px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="QuantityOrdered" DataFormatString="{0:#,##0.00}"
                                    HeaderText="Qty Ordered" PropertyName="QuantityOrdered" ResourceAssemblyName=""
                                    SortExpression="QuantityOrdered">
                                    <HeaderStyle HorizontalAlign="Left" Width="70px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Currency.CurrencySymbol" meta:resourcekey="UIGridViewBoundColumnResource15"
                                    PropertyName="Currency.CurrencySymbol" ResourceAssemblyName="" SortExpression="Currency.CurrencySymbol">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%--<cc1:UIGridViewBoundColumn DataField="UnitPriceInSelectedCurrency" HeaderText="Unit Price"
                                    meta:resourcekey="UIGridViewBoundColumnResource16" PropertyName="UnitPriceInSelectedCurrency"
                                    ResourceAssemblyName="" SortExpression="UnitPriceInSelectedCurrency">
                                    <HeaderStyle HorizontalAlign="Left" Width="60px" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>--%>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" HeaderText="Unit Price&lt;br/&gt;(Base Currency)"
                                    HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource17" PropertyName="UnitPrice"
                                    ResourceAssemblyName="" SortExpression="UnitPrice">
                                    <HeaderStyle HorizontalAlign="Left" Width="85px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Qty to Order">
                                    <HeaderStyle Font-Bold="true" Width="75px" />
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox ID="generateQty" runat="server" ShowCaption="false" CaptionWidth="1px"
                                            FieldLayout="Flow" InternalControlWidth="60px" PropertyName="" ValidateDataTypeCheck="True"
                                            ValidateRangeField="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                            ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <br />
                        <br />
                    </ui:UIDialogBox>
                    <ui:UIPanel runat="server" ID="panelAward" meta:resourcekey="panelAwardResource1"
                        BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelAwardSelection" meta:resourcekey="panelAwardSelectionResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldRichTextBox runat="server" ID="textEvaluation" Caption="Evaluation" PropertyName="Evaluation"
                                EditorHeight="150px">
                            </ui:UIFieldRichTextBox>
                            <ui:UIFieldRichTextBox runat="server" ID="textAwardedJustification" Caption="Justification / Recommendation"
                                PropertyName="AwardedJustification" EditorHeight="150px">
                            </ui:UIFieldRichTextBox>
                            <br />
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabBudget" Caption="Budget" BorderStyle="NotSet"
                    meta:resourcekey="tabBudgetResource1">
                    <ui:UIHint runat="server" ID="hintBudgetNotRequired" Text="Budget is not required for this Work Justification."></ui:UIHint>
                    <ui:UIPanel runat="server" ID="panelBudget2">
                        <ui:UIFieldRadioList runat="server" ID="radioBudgetDistributionMode" PropertyName="BudgetDistributionMode"
                            Caption="Budget Distribution" ValidateRequiredField="True" OnSelectedIndexChanged="radioBudgetDistributionMode_SelectedIndexChanged"
                            meta:resourcekey="radioBudgetDistributionModeResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource7" Text="By entire Work Justification (you can only generate 1 PO from this WJ if you select this)"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource8" Text="By individual Work Justification Items (you can only generate multiple POs from this WJ if you select this)"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldCheckBox runat="server" ID="AutoCalculateReallocationTo" PropertyName="AutoCalculateReallocationTo"
                            Checked="true" Text="Auto Calculate Budget Reallocation To Amount" OnCheckedChanged="AutoCalculateReallocationTo_CheckedChanged"
                            Visible="false">
                        </ui:UIFieldCheckBox>
                        <ui:UIFieldCheckBox runat="server" ID="IsDelegatedToHOD" PropertyName="IsDelegatedToHOD"
                            Checked="true" Caption="Delegated?" Text="Yes, this WJ will be delegated to the HOD for approval. (Upload of scanned approval paper required)"
                            Visible="false">
                        </ui:UIFieldCheckBox>
                        <ui:UIHint runat="server" ID="IsDelegatedToHODHint" Visible="false" Text="Your WJ is greater than $100,000. Please remember to tick the checkbox above if the Approval Paper has been signed offline and the HOD is delegated to approve this in the system."></ui:UIHint>
                        <br />
                        <ui:UIGridView runat="server" ID="gridBudget" PropertyName="PurchaseBudgets" Caption="Budgets"
                            AllowPaging="false" ShowFooter="True" PageSize="500" SortExpression="ItemNumber, StartDate, Budget.ObjectName, Account.Path"
                            BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridBudgetResource1"
                            RowErrorColor="" Style="clear: both;" ImageRowErrorUrl="" OnAction="gridBudget_Action">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource5" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource6" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                    AlwaysEnabled="true" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="No." meta:resourcekey="UIGridViewBoundColumnResource21"
                                    PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Budget.ObjectName" HeaderText="Budget" meta:resourcekey="UIGridViewBoundColumnResource22"
                                    PropertyName="Budget.ObjectName" ResourceAssemblyName="" SortExpression="Budget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" meta:resourcekey="UIGridViewBoundColumnResource23"
                                    PropertyName="Account.Path" ResourceAssemblyName="" SortExpression="Account.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Account.AccountCode" HeaderText="Account Code"
                                    meta:resourcekey="UIGridViewBoundColumnResource24" PropertyName="Account.AccountCode"
                                    ResourceAssemblyName="" SortExpression="Account.AccountCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StartDate" DataFormatString="{0:MMM-yyyy}"
                                    HeaderText="Accrual Date" meta:resourcekey="UIGridViewBoundColumnResource25"
                                    PropertyName="StartDate" ResourceAssemblyName="" SortExpression="StartDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Amount" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textAmount" runat="server" Caption="Amount" DataFormatString="{0:n}"
                                            FieldLayout="Flow" InternalControlWidth="80px" meta:resourcekey="textAmountResource1"
                                            PropertyName="Amount" ShowCaption="False" ValidateRangeField="True" ValidateRequiredField="True"
                                            ValidationRangeMin="0" ValidationRangeMinInclusive="False">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelBudget" BorderStyle="NotSet" meta:resourcekey="panelBudgetResource1">
                            <web:subpanel runat="server" ID="subpanelBudget" GridViewID="gridBudget" UpdatePopupVisible="true"
                                OnPopulateForm="subpanelBudget_PopulateForm" OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate"
                                OnRemoved="subpanelBudget_Removed" />
                            <ui:UIFieldDropDownList runat="server" ID="dropAddBudgetItemNumber" Caption="Line Number"
                                PropertyName="ItemNumber" ValidateRequiredField="true" OnSelectedIndexChanged="dropAddBudgetItemNumber_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropAddBudget" Caption="Budget" PropertyName="BudgetID"
                                ValidateRequiredField="true" OnSelectedIndexChanged="dropAddBudget_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropLocation" Caption="Location" ValidateRequiredField="true"
                                OnSelectedIndexChanged="dropLocation_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDateTime runat="server" ID="dateAddBudgetStartDate" Caption="Start Date"
                                PropertyName="StartDate" ValidateRequiredField="true" SelectMonthYear="true">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="dateAddBudgetEndDate" Caption="End Date" ValidateRequiredField="true"
                                PropertyName="EndDate" SelectMonthYear="true">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTreeList runat='server' ID="treeAddBudgetAccounts" Caption="Account" ValidateRequiredField="true"
                                PropertyName="AccountID" OnAcquireTreePopulater="treeAddBudgetAccounts_AcquireTreePopulater">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox runat='server' ID="textAddBudgetAmount" Caption="Amount" ValidateRequiredField="true"
                                PropertyName="Amount" ValidateDataTypeCheck="true" ValidationDataType="Currency"
                                ValidateRangeField='true' ValidationRangeMin="0" ValidationRangeMinInclusive="true"
                                ValidationRangeType="Currency">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldCheckBox runat="server" ID="checkUpFrontPayment" Caption="" Text="Yes, this WJ is up-front payment">
                            </ui:UIFieldCheckBox>
                            <ui:UIFieldRadioList runat="server" ID="rdlTerm" Caption="Terms" ValidateRequiredField="true"
                                RepeatColumns="5" RepeatDirection="Horizontal">
                                <Items>
                                    <asp:ListItem Value="0" Selected="True">Monthly</asp:ListItem>
                                    <asp:ListItem Value="1">Quarterly</asp:ListItem>
                                    <asp:ListItem Value="2">Half-Yearly</asp:ListItem>
                                    <asp:ListItem Value="3">Yearly</asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <%--<br />
                                <br />
                                <br />
                                <br />
                                <br />
                                <br />
                                <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray;
                                    width: 100%">
                                    <tr>
                                        <td style='width: 120px'>
                                        </td>
                                        <td>
                                            <ui:UIButton runat='server' ID="buttonAddBudgetConfirm" Text="Add" ImageUrl="~/images/add.gif"
                                                OnClick="buttonAddBudgetConfirm_Click" CausesValidation="true" />
                                            <ui:UIButton runat='server' ID="buttonAddBudgetCancel" Text="Cancel" ImageUrl="~/images/delete.gif"
                                                OnClick="buttonAddBudgetCancel_Click" CausesValidation='false' />
                                        </td>
                                    </tr>
                                </table>--%>
                        </ui:UIObjectPanel>
                        <br />
                        <br />
                        <ui:UIObjectPanel runat="server" ID="panelInvisible" Visible="false">
                            <ui:UIFieldDropDownList runat="server" ID="dropItemNumber" PropertyName="ItemNumber"
                                Caption="Item Number" ValidateRequiredField="True" meta:resourcekey="dropItemNumberResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat='server' ID="dropBudget" PropertyName="BudgetID" Caption="Budget"
                                ValidateRequiredField="True" OnSelectedIndexChanged="dropBudget_SelectedIndexChanged"
                                meta:resourcekey="dropBudgetResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate" Caption="Accrual Date"
                                Span="Half" ValidateRequiredField="True" OnDateTimeChanged="dateStartDate_DateTimeChanged"
                                meta:resourcekey="dateStartDateResource1" ShowDateControls="True" SelectMonthYear="true">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTreeList runat="server" ID="treeAccount" PropertyName="AccountID" Caption="Account"
                                ValidateRequiredField="True" OnAcquireTreePopulater="treeAccount_AcquireTreePopulater"
                                meta:resourcekey="treeAccountResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox runat="server" ID="textAmount" PropertyName="Amount" Caption="Amount"
                                DataFormatString="{0:n}" Span="Half" ValidateRequiredField="True" ValidationRangeMin="1"
                                ValidationRangeType="Currency" InternalControlWidth="95%" meta:resourcekey="textAmountResource2">
                            </ui:UIFieldTextBox>
                        </ui:UIObjectPanel>
                        <ui:UIPanel runat="server" ID="panelReallocateFrom" meta:resourcekey="panelReallocateFromResource1">
                            <ui:UIFieldDropDownList ID="dropFromBudget" runat="server" Caption="From Budget"
                                OnSelectedIndexChanged="dropFromBudget_SelectedIndexChanged" ValidateRequiredField="false"
                                meta:resourcekey="dropFromBudgetResource1" />
                            <ui:UIFieldDropDownList runat="server" ID="dropFromBudgetPeriod" Caption="From Budget Period"
                                ValidateRequiredField="false" OnSelectedIndexChanged="dropFromBudgetPeriod_SelectedIndexChanged"
                                meta:resourcekey="dropFromBudgetPeriodResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTreeList runat="server" ID="treeAccountFrom" Caption="Add Account" OnAcquireTreePopulater="treeAccountFrom_AcquireTreePopulater"
                                OnSelectedNodeChanged="treeAccountFrom_SelectedNodeChanged" meta:resourcekey="treeAccountFromResource1">
                            </ui:UIFieldTreeList>
                            <ui:UIGridView runat="server" ID="gridReallocationFromPeriod" PropertyName="RFQBudgetReallocationFromPeriods"
                                CheckBoxColumnVisible="true" DataKeyNames="ObjectID" Caption="Reallocation From"
                                AllowPaging="false" BindObjectsToRows="true" Span="Full">
                                <Columns>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                        ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="From Budget" PropertyName="FromBudget.ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="From Budget Period" PropertyName="FromBudgetPeriod.ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="From Budget Account" PropertyName="FromBudgetAccount">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewTemplateColumn HeaderText="Amount" ControlStyle-Width="80" ItemStyle-BackColor="#eeeeee"
                                        meta:resourcekey="UIGridViewTemplateColumnResource37">
                                        <ItemTemplate>
                                            <ui:UIFieldTextBox runat="server" ID="textTotalAmount" ValidateRequiredField="true"
                                                InternalControlWidth="80px" ValidateRangeField="true" ValidationRangeMin="0"
                                                ValidationRangeMinInclusive='true' ValidationRangeType="Currency" PropertyName="TotalAmount"
                                                Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}"
                                                ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textTotalAmountResource1">
                                            </ui:UIFieldTextBox>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(1) Opening Balance" PropertyName="TotalOpeningBalance"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(2) Adjusted Amount" PropertyName="TotalAdjustedAmount"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(3) Reallocated Amount" PropertyName="TotalReallocatedAmount"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(4) Total After Adjustments<br />(1)+(2)+(3)"
                                        HtmlEncode="false" PropertyName="TotalBalanceAfterVariation" DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(5) Total Pending Approval" PropertyName="TotalPendingApproval"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(6) Total Approved" PropertyName="TotalApproved"
                                        DataFormatString="{0:c}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(7) Total Direct Invoice Pending Approval"
                                        PropertyName="TotalDirectInvoicePendingApproval" DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(8) Total Direct Invoice Approved" PropertyName="TotalDirectInvoiceApproved"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(9) Total Available<br />(4)-(5)-(6)-(7)-(8)"
                                        HtmlEncode="false" PropertyName="TotalAvailableBalance" DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(1) Opening Balance" PropertyName="TotalOpeningBalanceAtSubmission"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(2) Adjusted Amount" PropertyName="TotalAdjustedAmountAtSubmission"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(3) Reallocated Amount" PropertyName="TotalReallocatedAmountAtSubmission"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(4) Total After Adjustments<br />(1)+(2)+(3)"
                                        HtmlEncode="false" PropertyName="TotalBalanceAfterVariationAtSubmission" DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(5) Total Pending Approval" PropertyName="TotalPendingApprovalAtSubmission"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(6) Total Approved" PropertyName="TotalApprovedAtSubmission"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(7) Total Direct Invoice Pending Approval"
                                        PropertyName="TotalDirectInvoicePendingApprovalAtSubmission" DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(8) Total Direct Invoice Approved" PropertyName="TotalDirectInvoiceApprovedAtSubmission"
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="(9) Total Available<br />(4)-(5)-(6)-(7)-(8)"
                                        HtmlEncode="false" PropertyName="TotalAvailableBalanceAtSubmission" DataFormatString="{0:#,##0.00}">
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                                <Commands>
                                    <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                        ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                    </ui:UIGridViewCommand>
                                </Commands>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="panelBudgetReallocationFromPeriods">
                                <web:subpanel runat="server" ID="subpanelBudgetReallocationFromPeriods" GridViewID="gridReallocationFromPeriod" />
                            </ui:UIObjectPanel>
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIGridView runat="server" ID="gridReallocationToPeriod" PropertyName="RFQBudgetReallocationToPeriods"
                            CheckBoxColumnVisible="False" DataKeyNames="ObjectID" Caption="Reallocation To"
                            AllowPaging="false" Visible="false" BindObjectsToRows="true" Span="Full">
                            <Columns>
                                <ui:UIGridViewBoundColumn HeaderText="To Budget" PropertyName="ToBudget.ObjectName">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="To Budget Period" PropertyName="ToBudgetPeriod.ObjectName">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="To Budget Account" PropertyName="ToBudgetAccount">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Total" ItemStyle-BackColor="#eeeeee" meta:resourcekey="UIGridViewTemplateColumnResource37">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textTotalAmount" ValidateRequiredField="true"
                                            Enabled="false" ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="TotalAmount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True"
                                            ValidationDataType="Currency" meta:resourcekey="textTotalAmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIGridView runat="server" ID="gridBudgetSummary" PropertyName="PurchaseBudgetSummaries"
                            Caption="Budget Summary" CheckBoxColumnVisible="False" OnAction="gridBudgetSummary_Action"
                            AllowPaging="false" ShowFooter="True" PageSize="500" DataKeyNames="ObjectID"
                            GridLines="Both" meta:resourcekey="gridBudgetSummaryResource1" RowErrorColor=""
                            Style="clear: both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="Budget.ObjectName" HeaderText="Budget" meta:resourcekey="UIGridViewBoundColumnResource28"
                                    PropertyName="Budget.ObjectName" ResourceAssemblyName="" SortExpression="Budget.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BudgetPeriod.ObjectName" HeaderText="Budget Period"
                                    meta:resourcekey="UIGridViewBoundColumnResource29" PropertyName="BudgetPeriod.ObjectName"
                                    ResourceAssemblyName="" SortExpression="BudgetPeriod.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="ViewBudget"
                                    ImageUrl="~/images/printer.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Account.ObjectName" HeaderText="Account" meta:resourcekey="UIGridViewBoundColumnResource30"
                                    PropertyName="Account.ObjectName" ResourceAssemblyName="" SortExpression="Account.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Account.AccountCode" HeaderText="Account Code"
                                    meta:resourcekey="UIGridViewBoundColumnResource31" PropertyName="Account.AccountCode"
                                    ResourceAssemblyName="" SortExpression="Account.AccountCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableAdjusted" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Original Budget (after Adjustment)" meta:resourcekey="UIGridViewBoundColumnResource32"
                                    PropertyName="TotalAvailableAdjusted" ResourceAssemblyName="" SortExpression="TotalAvailableAdjusted">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableBeforeSubmission" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Budget (before Submission)" meta:resourcekey="UIGridViewBoundColumnResource33"
                                    PropertyName="TotalAvailableBeforeSubmission" ResourceAssemblyName="" SortExpression="TotalAvailableBeforeSubmission">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableAtSubmission" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Available Budget (after Submission)" meta:resourcekey="UIGridViewBoundColumnResource34"
                                    PropertyName="TotalAvailableAtSubmission" ResourceAssemblyName="" SortExpression="TotalAvailableAtSubmission">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalReallocation" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Total Shortfall" PropertyName="TotalReallocation"
                                    ResourceAssemblyName="" SortExpression="TotalReallocation">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" ForeColor="Red" Font-Bold="true" />
                                    <FooterStyle ForeColor="Red" Font-Bold="true" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableAfterApproval" DataFormatString="{0:c}"
                                    FooterAggregate="Sum" HeaderText="Total After Approval" meta:resourcekey="UIGridViewBoundColumnResource35"
                                    PropertyName="TotalAvailableAfterApproval" ResourceAssemblyName="" SortExpression="TotalAvailableAfterApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <asp:LinkButton runat="server" ID="buttonAddBudgetHidden" />
                        <asp:ModalPopupExtender runat='server' ID="popupAddBudget" PopupControlID="objectPanelAddBudget"
                            BackgroundCssClass="modalBackground" TargetControlID="buttonAddBudgetHidden">
                        </asp:ModalPopupExtender>
                        <ui:UIObjectPanel runat="server" ID="objectPanelAddBudget" Width="400px" BackColor="White">
                            <div style="padding: 8px 8px 8px 8px">
                                <ui:UISeparator ID="Uiseparator3" runat="server" Caption="Add Budget" />
                            </div>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Status History" BorderStyle="NotSet"
                    meta:resourcekey="uitabview1Resource1">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1"
                    BorderStyle="NotSet">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1"
                    BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
