﻿<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    // NOTE:
    // For Marcom's Edit Page, do the following:
    //    1. Move the panelRequestForQuotationItems into the details tab.
    private Hashtable EditVisible;
    private Hashtable ViewVisible;
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        ORequestForQuotation requestForQuotation = panel.SessionObject as ORequestForQuotation;
        //tessa comment out
        //if (requestForQuotation.AutoCalculateReallocationTo == null)
        //    requestForQuotation.AutoCalculateReallocationTo = 1;
        //tessa end
        if (requestForQuotation.CurrentActivity == null ||
            requestForQuotation.CurrentActivity.ObjectName.Is("Draft", "PendingInvitation", "PendingQuotation", "PendingEvaluation"))
            requestForQuotation.UpdateApplicablePurchaseSettings();

        objectBase.ObjectNumberVisible = !requestForQuotation.IsNew;

        // sets the default requestor id
        //
        if (requestForQuotation.RequestorID == null && ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            requestForQuotation.RequestorID = AppSession.User.ObjectID;
        if (requestForQuotation.CampaignID != null && requestForQuotation.IsGroupWJ == 1)
        {
            List<OLocation> locs = new List<OLocation>();
            ArrayList al_LocationIDs = new ArrayList();

            for (int i = 0; i < listLocations.Items.Count; i++)
            {
                if (listLocations.Items[i].Selected)
                {
                    al_LocationIDs.Add(new Guid(listLocations.Items[i].Value));
                }
            }
            if (al_LocationIDs.Count > 0)
            {
                locs = TablesLogic.tLocation.LoadList(
                    TablesLogic.tLocation.ObjectID.In(al_LocationIDs)
                    );
            }

            //List<OCampaign> cams = OLocation.GetCampaignsContainsInLocations(locs);
            //dropCampaign.Bind(cams, "ObjectName", "ObjectID");
        }
        if (requestForQuotation.CampaignID != null && requestForQuotation.IsGroupWJ == 0)
        {
            //OLocation loc = LogicLayer.TablesLogic.tLocation.Load(requestForQuotation.LocationID);
            //dropCampaign.Bind(loc.CampaignsForLocations, "ObjectName", "ObjectID");
        }
        if (requestForQuotation.RequestorName == null)
            requestForQuotation.RequestorName = AppSession.User.ObjectName;

        if (!IsPostBack)
        {
            gridChildWJs.Columns[4].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            dropBackgroundType.Bind(OCode.GetCodesByType("BackgroundType", requestForQuotation.BackgroundTypeID));
            dropCase.Bind(OCase.GetAccessibleOpenCases(AppSession.User, Security.Decrypt(Request["TYPE"]), requestForQuotation.CaseID), "Case", "ObjectID");
            dropVendorToAward.Bind(requestForQuotation.GetVendorsWithSubmittedQuotations());
            dropPurchaseTypeClassification.Bind(OCode.GetCodesByType("PurchaseTypeClassification", null));

            if (requestForQuotation.TransactionTypeGroupID != null)
                dropPurchaseType.Bind(OCode.GetCodesByParentID(requestForQuotation.TransactionTypeGroupID, requestForQuotation.PurchaseTypeID));
            else
                dropPurchaseType.Items.Clear();
            BudgetGroupID.Bind(AppSession.User.GetAllAccessibleBudgetGroup("ORequestForQuotation", requestForQuotation.BudgetGroupID));
            List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
            ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, requestForQuotation.LocationID));

            if (requestForQuotation.IsNew && ddlLocation.Items.Count == 2)
            {
                requestForQuotation.LocationID = new Guid(ddlLocation.Items[1].Value);
                requestForQuotation.EmployerCompanyID = requestForQuotation.Location.BuildingTrustID;
            }
            BindRequestorID(requestForQuotation);

            OApplicationSetting applicationSetting = OApplicationSetting.Current;

            if (applicationSetting.EnableAllBuildingForGWJ == 1 || AppSession.User.EnableAllBuildingForGWJ == 1)
                listLocations.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, null), "ObjectName", "ObjectID");
            else
                listLocations.Bind(AppSession.User.GetAllAccessibleLocation(OApplicationSetting.Current.LocationTypeNameForBuildingActual, "ORequestForQuotation"), "ObjectName", "ObjectID");            
                
        }

        //treeLocation.PopulateTree();
        //treeEquipment.PopulateTree();
        buttonViewGroupWJ.Visible = AppSession.User.AllowViewAll("ORequestForQuotation");
        buttonEditGroupWJ.Visible = AppSession.User.AllowEditAll("ORequestForQuotation ") ||
            OActivity.CheckAssignment(AppSession.User, requestForQuotation.GroupRequestForQuotationID);

        labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;

        if (requestForQuotation.CurrentActivity == null ||
            !requestForQuotation.CurrentActivity.ObjectName.Is("PendingApproval", "Awarded", "Close", "Cancelled"))
        {
            requestForQuotation.ComputeTempBudgetSummaries();
            //tessa comment out for the hiding of budget reallocation
            //requestForQuotation.ComputeBudgetReallocationToPeriods();
            //requestForQuotation.UpdateTempBudgetSummaryWithReallocation();
            requestForQuotation.ComputeFromBudgetSummary();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";
        }
        else
            gridBudgetSummary.PropertyName = "PurchaseBudgetSummaries";

        PopulateDropFromBudget(requestForQuotation);

        requestForQuotation.ComputeLowestQuotation();

        // Set access control for the button
        //
        buttonViewCase.Visible = AppSession.User.AllowViewAll("OCase");
        buttonEditCase.Visible = AppSession.User.AllowEditAll("OCase") || OActivity.CheckAssignment(AppSession.User, requestForQuotation.CaseID);
        ddl_EmployerCompany.Bind(TablesLogic.tCapitalandCompany.LoadAll(), "ObjectNameAndAddress", "ObjectID");
        IsGroupApproval.Visible = requestForQuotation.IsGroupWJ == 1;

        EditVisible = new Hashtable();
        ViewVisible = new Hashtable();

        panelCase.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] != "MARCOM");
        IsDelegatedToHOD.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] == "IT");
        
        panel.ObjectPanel.BindObjectToControls(requestForQuotation);
        
    }



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
                        
            //requestForQuotation.UpdateBudgetReallocation();

            // Validate
            //            
            if (!objectBase.CurrentObjectState.Is("Close", "Cancelled") &&
                !OCase.ValidateCaseNotClosedOrCancelled(requestForQuotation.CaseID) &&
                ConfigurationManager.AppSettings["CustomizedInstance"] != "MARCOM")
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

            if (objectBase.SelectedAction == "SubmitForApproval" || objectBase.SelectedAction == "CreateChildRFQs")
            {
                string acrossPeriod;
                string periodsNotEqual;

                requestForQuotation.ComputeTempBudgetSummaries();
                //tessa comment out because of the hiding of budget reallocation
                //requestForQuotation.ComputeBudgetReallocationToPeriods();
                //requestForQuotation.UpdateTempBudgetSummaryWithReallocation();
                requestForQuotation.ComputeFromBudgetSummary();
                //requestForQuotation.UpdateBudgetReallocation();

                //tessa comment out because of the hiding of budget reallocation

                //if (requestForQuotation.IsReallocateAcrossBudgetPeriod(out acrossPeriod))
                //{
                //    string errorMessage = String.Format(
                //               Resources.Errors.RequestForQuotation_BudgetReallocationAcrossBudgetPeriod, acrossPeriod);

                //    gridReallocationToPeriod.ErrorMessage = errorMessage;
                //    gridReallocationFromPeriod.ErrorMessage = errorMessage;
                //}
                //else if (!requestForQuotation.IsEqualReallocateAmount(out periodsNotEqual))
                //{

                //    string errorMessage = String.Format(
                //               Resources.Errors.RequestForQuotation_CheckTotalAmountItemsFromEqualTotalAmountItemsTo1, periodsNotEqual);

                //    gridReallocationToPeriod.ErrorMessage = errorMessage;
                //    gridReallocationFromPeriod.ErrorMessage = errorMessage;
                //}
                //string accounts = requestForQuotation.CheckSufficientAvailableAmountForReallocation();
                //if (accounts != "")
                //{
                //    string errorMessage = String.Format(
                //        Resources.Errors.BudgetReallocation_InsufficientAmount, accounts);
                //    this.gridReallocationFromPeriod.ErrorMessage = errorMessage;
                //    this.gridReallocationToPeriod.ErrorMessage = errorMessage;

                //}
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
                    //string itemNumberText = "";
                    //if (itemNumber > 0)
                    //    itemNumberText = String.Format(Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount_LineItem, itemNumber);
                    //else
                    //    itemNumberText = Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount_EntireRFQ;

                    //if (requestForQuotation.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems)
                    //    gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_ItemAmountNotEqualsBudgetAmount, itemNumberText);
                    //else if (requestForQuotation.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems)
                    //    gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_ItemAmountLessThanBudgetAmount, itemNumberText);
                }


                // Ensure that all purchase budgets adhere to the 
                // budget spending policy.
                //
                string budgetsWithNoPeriod = requestForQuotation.ValidateBudgetSpendingPolicy();
                if (budgetsWithNoPeriod != "")
                {
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_BudgetNoPeriod, budgetsWithNoPeriod); ;
                }


                // Ensure that number of quotations is sufficient.
                if (requestForQuotation.ValidateSufficientNumberOfQuotations() == 0)
                {
                    RequestForQuotationVendors.ErrorMessage =
                        String.Format(Resources.Errors.RequestForQuotation_InsufficientQuotations, requestForQuotation.MinimumNumberOfQuotations);
                }
                // ensure that awarded vendors have an attachment uploaded
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
                //tessa comment out because of the hiding of budget reallocation
                //string reallocation = requestForQuotation.ValidateReallocationAcrossGroups();
                //if (reallocation != "")
                //{
                //    gridBudgetSummary.ErrorMessage = reallocation;
                //    return;
                //}
                
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

            if (objectBase.SelectedAction == "SubmitForApproval"/* ||
                objectBase.SelectedAction == "Approve"*/
                                                        )
            {
                // Ensure budget is sufficient.
                //
                //tessa comment out because budget reallocation is hidden
                string insufficientAccounts = requestForQuotation.ValidateSufficientBudgetWithBudgetReallocation();
                if (insufficientAccounts != "")
                {
                    gridBudget.ErrorMessage =
                        String.Format(Resources.Errors.RequestForQuotation_InsufficientBudget, insufficientAccounts);
                }
                //tessa end
                
                       
                // Ensure that the budget periods covering the start date of
                // the purchase order exists, and has not yet been closed.
                //
                string closedBudgets = OPurchaseBudget.ValidateBudgetPeriodsActiveAndOpened(requestForQuotation.PurchaseBudgets);
                if (closedBudgets != "")
                    gridBudget.ErrorMessage = String.Format(Resources.Errors.RequestForQuotation_BudgetPeriodsClosed, closedBudgets);

            }

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            if (requestForQuotation.IsGroupWJ == 1)
            {
                ExpressionCondition ec = Query.True;
                foreach (OLocation l in requestForQuotation.GroupWJLocations)
                    ec = ec & l.HierarchyPath.Like(TablesLogic.tLocation.HierarchyPath + "%");

                requestForQuotation.LocationID = TablesLogic.tLocation.SelectTop(1,
                    TablesLogic.tLocation.ObjectID)
                    .Where(TablesLogic.tLocation.IsDeleted == 0 &
                    ec)
                    .OrderBy(TablesLogic.tLocation.HierarchyPath.Desc);
            }
            

            requestForQuotation.Save();
            c.Commit();
        }
    }







    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    //{
    //    ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
    //    return new LocationTreePopulaterForCapitaland(rfq.LocationID, false, true, Security.Decrypt(Request["TYPE"]), false, false);
    //}


    /// <summary>
    /// Updates the requestor dropdown list when the location changes,
    /// and clears the selected equipment ID.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    //{
    //    ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
    //    panel.ObjectPanel.BindControlsToObject(rfq);
    //    rfq.EquipmentID = null;
    //    rfq.UpdateApplicablePurchaseSettings();
    //    BindRequestorID(rfq);
    //    panel.ObjectPanel.BindObjectToControls(rfq);
    //}


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    //{
    //    ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
    //    return new EquipmentTreePopulater(rfq.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    //}


    /// <summary>
    /// Updates the location to the location of the selected equipment.
    /// </summary>
    /// <param name="sender"></param>
    ///// <param name="e"></param>
    //protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    //{
    //    ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
    //    panel.ObjectPanel.BindControlsToObject(rfq);

    //    if (rfq.Equipment != null)
    //    {
    //        rfq.LocationID = rfq.Equipment.LocationID;
    //        treeLocation.PopulateTree();
    //    }
    //    panel.ObjectPanel.BindObjectToControls(rfq);
    //}


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
        if (listLocations.SelectedItem != null)
        {
            if (requestForQuotationItem.IsNew)
            {
                foreach (ListItem li in listLocations.Items)
                {
                    if (li.Selected)
                    {
                        OLocation loc = TablesLogic.tLocation.Load(new Guid(li.Value));
                        if (loc != null)
                        {
                            ORequestForQuotationItemLocation rfqitemLocation =
                                TablesLogic.tRequestForQuotationItemLocation.Create();
                            rfqitemLocation.RequestForQuotationItemID = requestForQuotationItem.ObjectID;
                            rfqitemLocation.LocationID = loc.ObjectID;
                            bool exist = false;
                            foreach (ORequestForQuotationItemLocation rfqlocation in requestForQuotationItem.RequestForQuotationItemLocation)
                            {
                                if (rfqitemLocation.LocationID == rfqlocation.LocationID)
                                    exist = true;
                            }
                            if (!exist)
                                requestForQuotationItem.RequestForQuotationItemLocation.Add(rfqitemLocation);
                        }
                    }
                }
            }
        }
        for (int i = 1; i <= p.RequestForQuotationItems.Count + 1; i++)
            ItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (requestForQuotationItem.ItemType == null)
        {
            requestForQuotationItem.ItemType = 2;
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
        if (ItemType.SelectedValue == "2")
        {
            i.AdditionalDescription = "";
        }
        int? amount = 0;
        foreach (ORequestForQuotationItemLocation ofqil in i.RequestForQuotationItemLocation)
        {
            amount += ofqil.QuantityRequired;
            //if (ofqil.Quantity < 0) 
        }

        if (checkIsGroupWJ.Checked && (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString()))
        {
            i.QuantityRequired = amount;
        }
        else if (checkIsGroupWJ.Checked && (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString()))
        {
            i.QuantityRequired = 1;

        }
        if (p.RequestForQuotationVendors != null && p.RequestForQuotationVendors.Count > 0)
        {
            p.UpdateLineItemsToRFQVendors(i);
            p.UpdateVendorAwardedItemsUnitPrice();
            UpdateBudgetAmount(p);
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

        //7th March 2011, Joey:
        //if the vendor to be added is an IPT vendor, ensure that there is at least one attachment uploaded
        if (
            requestForQuotationVendor.IsSubmitted == 1
            &&
            requestForQuotationVendor.Vendor.IsInterestedParty == 1             
            && 
            requestForQuotationVendor.Attachments.Count < 1
            )
            gridDocument.ErrorMessage = Resources.Errors.RequestForQuotation_SingleIptVendorAttachmentNoExist;        
        
        if (!RequestForQuotationVendors_SubPanel.ObjectPanel.IsValid)
            return;
        
        // Update the ORequestForQuotationVendorItems' unit price 
        // (in base currency).
        //
        requestForQuotationVendor.UpdateItemsUnitPrice();
        requestForQuotation.UpdateVendorAwardedItemsUnitPrice();

        ////update budget amount
        if (requestForQuotation.RequestForQuotationItems.Count > 0)
        {
            ORequestForQuotationItem vendorItem = requestForQuotation.RequestForQuotationItems.Find((r) => r.AwardedVendorID == requestForQuotationVendor.VendorID);
            if (vendorItem != null)
                UpdateBudgetAmount(requestForQuotation);
        }

        // Add
        //
        requestForQuotation.RequestForQuotationVendors.Add(requestForQuotationVendor);
        requestForQuotation.ComputeLowestQuotation();
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
        if (objectBase.CurrentObjectState.Is("Start", "Draft"))
        {
            ListItem itemAward = objectBase.GetWorkflowRadioListItem("Award");
            if (itemAward != null)
                itemAward.Enabled = false;
            ListItem itemSubmit = objectBase.GetWorkflowRadioListItem("SubmitForApproval");
            if (itemSubmit != null)
                itemSubmit.Enabled = !(checkIsGroupWJ.Checked && !IsGroupApproval.Checked);

            ListItem itemCreate = objectBase.GetWorkflowRadioListItem("CreateChildRFQs");
            if (itemCreate != null)
                itemCreate.Enabled = checkIsGroupWJ.Checked && !IsGroupApproval.Checked;




            //10th March 2011, Joey:
            //only for ops, show the "has warranty" radio box options, and force the user to tick one of them
            //as well as force the user to key in warranty period, when "has warranty" radio option is ticked
            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "OPS")
            {
                UIFieldRadioListHasWarranty.Visible = true;
                lblWarrantyPeriod.ForeColor = System.Drawing.Color.Blue;
                lblWarrantyPeriod.Text = "Warranty Period*:";
                
                if (UIFieldRadioListHasWarranty.SelectedIndex == 0)
                {
                    txtWarrantyPeriod.Text = string.Empty;
                    Warranty.Text = string.Empty;
                }
            }
        }
        else
        {
            //10th March 2011, Joey:
            //only for ops, show the "has warranty" radio box options, and force the user to tick one of them
            //as well as force the user to key in warranty period, when "has warranty" radio option is ticked            
            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "OPS")
            {
                if ((txtWarrantyPeriod.Text.Trim().Length > 0) || Warranty.Text.Trim().Length > 0)
                {
                    UIFieldRadioListHasWarranty.SelectedIndex = 1;
                }
                else
                {
                    if(UIFieldRadioListHasWarranty.SelectedIndex == -1)
                        UIFieldRadioListHasWarranty.SelectedIndex = 0;
                }
            }                
        }

        //14th March 2011, Joey:
        //hide the hint when the add item panel is shown
        hintRfqItemsAddDelete.Visible = !RequestForQuotationItem_Panel.Visible;
        
        
        //14th March 2011, Joey:
        //show context menu to allow user to view / edit the previous cancelled purchase order if this rfq was generated from a previous cancelled purchase order
        if (rfq.CancelledPurchaseOrderID != null)
        {
            CancelledPurchaseOrder.Visible = true;

            buttonViewPurchaseOrder.Visible =
                (
                    AppSession.User.AllowViewAll("OPurchaseOrder")
                    ||
                    OActivity.CheckAssignment(AppSession.User, rfq.CancelledPurchaseOrderID)
                );

            buttonEditPurchaseOrder.Visible =
                (
                    AppSession.User.AllowEditAll("OPurchaseOrder")
                    ||
                    OActivity.CheckAssignment(AppSession.User, rfq.CancelledPurchaseOrderID)
                );
        }
        
        
        //10th March 2011, Joey:
        //only for ops, show the "has warranty" radio box options, and force the user to tick one of them
        //as well as force the user to key in warranty period, when "has warranty" radio option is ticked        
        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "OPS")
        {
            txtWarrantyPeriod.ValidateRequiredField = panelWarranty.Visible = (UIFieldRadioListHasWarranty.SelectedIndex == 1);            
        }
        
        if (objectBase.CurrentObjectState.Is("Awarded"))
        {
            ListItem itemSubmit = objectBase.GetWorkflowRadioListItem("SubmitForApproval");
            if (itemSubmit != null)
                itemSubmit.Enabled = !(checkIsGroupWJ.Checked && IsGroupApproval.Checked);
            ListItem itemCreate = objectBase.GetWorkflowRadioListItem("CreateChildRFQs");
            if (itemCreate != null)
                itemCreate.Enabled = checkIsGroupWJ.Checked && IsGroupApproval.Checked;
        }
        tabChildWJs.Visible = checkIsGroupWJ.Checked;
        textQuantityRequired.Visible = !checkIsGroupWJ.Checked;
        gridRequestForQuotationItemLocations.Visible = checkIsGroupWJ.Checked;

        if (GroupRequestForQuotationID.Text == "" || GroupRequestForQuotationID.Text == null)
            GroupRequestForQuotationID.Visible = false;
        else
            GroupRequestForQuotationID.Visible = true;
        panelGroupWJ.Enabled = gridBudget.Rows.Count == 0;
        CatalogueID.Visible = ItemType.SelectedIndex == 0;
        buttonAddCatalog.Visible = ItemType.SelectedIndex == 0;
        UnitOfMeasure.Visible = ItemType.SelectedIndex == 0;
        UnitOfMeasure2.Visible = ItemType.SelectedIndex == 1;
        FixedRateID.Visible = ItemType.SelectedIndex == 1;
        UnitOfMeasureID.Visible = ItemType.SelectedIndex == 2;
        ItemDescription.Visible = ItemType.SelectedIndex == 2;
        //dropCampaign.Visible = dropCampaign.Items.Count >1||(dropCampaign.Items.Count==1&&dropCampaign.Items[0].Text!="");
        radioReceiptMode.Enabled = ItemType.SelectedValue != PurchaseItemType.Material.ToString();
        textQuantityRequired.Enabled = radioReceiptMode.SelectedValue != ReceiptModeType.Dollar.ToString() || ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        buttonAddFixedrateItems.Enabled = !RequestForQuotationItem_SubPanel.Visible;
        buttonAddMaterialItems.Enabled = !RequestForQuotationItem_SubPanel.Visible;
        buttonAddMultipleVendors.Enabled = !RequestForQuotationVendors_SubPanel.Visible;
        panelQuotationOptionalDetails.Visible = checkShowOptionalDetails.Checked;
        //panelBudget2.Visible =
        //    ((!checkIsGroupWJ.Checked && treeLocation.SelectedItem != "") || (checkIsGroupWJ.Checked && listLocations.SelectedItem != null)) &&
        //    DateRequired.DateTime != null &&
        //    rfq.ValidateSufficientNumberOfQuotations() != 0 &&
        //    rfq.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;
        panelBudget2.Visible =
            ((!checkIsGroupWJ.Checked && ddlLocation.SelectedValue != "") || (checkIsGroupWJ.Checked && listLocations.SelectedItem != null)) &&
            DateRequired.DateTime != null &&
            rfq.ValidateSufficientNumberOfQuotations() != 0 &&
            rfq.BudgetValidationPolicy != PurchaseBudgetValidationPolicy.BudgetNotRequired;
        hintBudgetNotRequired.Visible = rfq.BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired;
        gridBudget.Visible = radioBudgetDistributionMode.SelectedValue != "";
        radioBudgetDistributionMode.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible && rfq.NumberOfAwardedVendors <= 1;
        dropItemNumber.Visible = radioBudgetDistributionMode.SelectedValue == "1";
        gridBudgetSummary.Visible = gridBudgetSummary.Rows.Count > 0;
        StoreID.Visible = rfq.StoreID != null;
        panelQuotationDetails.Visible = panelVendorAttachments.Visible = checkIsSubmitted.Checked;
        buttonGeneratePOFromLineItems.Visible = radioBudgetDistributionMode.SelectedValue == "1" && !checkIsTermContract.Checked;
        buttonGenerateLOAFromLineItems.Visible = radioBudgetDistributionMode.SelectedValue == "1" && checkIsTermContract.Checked;
        buttonGeneratePO.Visible = radioBudgetDistributionMode.SelectedValue == "0" && !checkIsTermContract.Checked;
        buttonGenerateLOA.Visible = radioBudgetDistributionMode.SelectedValue == "0" && checkIsTermContract.Checked;
        gridAwardItems.CheckBoxColumnVisible = !objectBase.CurrentObjectState.Is("Awarded") || radioBudgetDistributionMode.SelectedValue == "1";
        //ItemType.Items[0].Enabled = !checkIsTermContract.Checked;
        //checkIsTermContract.Enabled = RequestForQuotationItems.Rows.Count == 0 && !RequestForQuotationItem_SubPanel.Visible && rfq.StoreID == null;
        //treeEquipment.Visible = treeLocation.Visible = !checkIsGroupWJ.Checked;
        ddlLocation.Visible = !checkIsGroupWJ.Checked;
        listLocations.Visible = checkIsGroupWJ.Checked;
        IsGroupApproval.Visible = checkIsGroupWJ.Checked;
        dropLocation.Visible = checkIsGroupWJ.Checked;
        if (dropAddBudget.Text == "")
        {
            dropLocation.Text = "";
            //textAddBudgetAmount.Text = "0"; 
        }
        //dropPurchaseType.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        //dropPurchaseTypeClassification.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        //BudgetGroupID.Enabled = gridBudget.Rows.Count == 0 && !panelBudget.Visible;
        //buttonAddBudget.Enabled = !panelBudget.Visible;
        txtRFQTitle.ValidateRequiredField = checkIsTermContract.Checked;

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
        if (rfqVendor != null && objectBase.CurrentObjectState.Is("Start", "Draft"))
        {
            if (rfqVendor.IsExchangeRateDefined == 1 && OApplicationSetting.Current.AllowChangeOfExchangeRate == 0)
                textForeignToBaseExchangeRate.Enabled = false;
            else
                textForeignToBaseExchangeRate.Enabled = true;
        }
        //panelRequestForQuotationItems.Enabled = RequestForQuotationVendors.Grid.Rows.Count == 0 && !RequestForQuotationVendors_Panel.Visible;

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

        OApplicationSetting applicationSetting = OApplicationSetting.Current;

        if (rfq.BudgetGroupID == null && BudgetGroupID.Items.Count == 1)
            BudgetGroupID.SelectedIndex = 0;

        if (rfq.IsNew)
        {
            if (rfq.TransactionTypeGroupID == null && dropPurchaseTypeClassification.Items.Count == 1)
            {
                dropPurchaseTypeClassification.SelectedIndex = 0;
                dropPurchaseType.Bind(TablesLogic.tCode.LoadList(TablesLogic.tCode.ParentID == new Guid(dropPurchaseTypeClassification.SelectedValue)));
            }

            if (DateRequired.DateTime == null && DateEnd.DateTime == null
                && applicationSetting.IsWJDateDefaulted == 1 && !checkIsTermContract.Checked)
            {
                DateTime today = DateTime.Today;
                switch (applicationSetting.DefaultRequiredUnit)
                {
                    case 0:
                        DateRequired.DateTime = today.AddDays(applicationSetting.DefaultRequiredCount.Value);
                        break;
                    case 1:
                        DateRequired.DateTime = today.AddDays(applicationSetting.DefaultRequiredCount.Value * 7);
                        break;
                    case 2:
                        DateRequired.DateTime = today.AddMonths(applicationSetting.DefaultRequiredCount.Value);
                        break;
                    case 3:
                        DateRequired.DateTime = today.AddYears(applicationSetting.DefaultRequiredCount.Value);
                        break;
                }

                switch (applicationSetting.DefaultEndUnit)
                {
                    case 0:
                        DateEnd.DateTime = today.AddDays(applicationSetting.DefaultEndCount.Value);
                        break;
                    case 1:
                        DateEnd.DateTime = today.AddDays(applicationSetting.DefaultEndCount.Value * 7);
                        break;
                    case 2:
                        DateEnd.DateTime = today.AddMonths(applicationSetting.DefaultEndCount.Value);
                        break;
                    case 3:
                        DateEnd.DateTime = today.AddYears(applicationSetting.DefaultEndCount.Value);
                        break;
                }
            }


            /*
            if (rfq.RequestorID == null && RequestorID.Items.Count > 0)
            {
                ListItem li = RequestorID.Items.FindByValue(AppSession.User.ObjectID.Value.ToString());

                if (li != null)
                    RequestorID.SelectedValue = li.Value;
                else if (RequestorID.Items.Count == 2)
                    RequestorID.SelectedIndex = 1;
            }*/

        }
        //tessa comment out because budget reallocation is hidden
        //panelReallocateFrom.Visible = (rfq.RFQBudgetReallocationToPeriods != null && rfq.RFQBudgetReallocationToPeriods.Count > 0)
        //    || (rfq.RFQBudgetReallocationFromPeriods != null && rfq.RFQBudgetReallocationFromPeriods.Count > 0);

        //gridReallocationToPeriod.Visible = rfq.RFQBudgetReallocationToPeriods != null && rfq.RFQBudgetReallocationToPeriods.Count > 0;
        

        //bool fromBudgetSummaryVisible = rfq.PurchaseBudgetSummaries != null && rfq.PurchaseBudgetSummaries.Count > 0;
        //gridReallocationFromPeriod.Columns[5].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[6].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[7].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[8].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[9].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[10].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[11].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[12].Visible = !fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[13].Visible = !fromBudgetSummaryVisible;

        //gridReallocationFromPeriod.Columns[14].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[15].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[16].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[17].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[18].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[19].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[20].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[21].Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriod.Columns[22].Visible = fromBudgetSummaryVisible;
        //tessa end
        
        //gridReallocationFromPeriodSummary.Visible = fromBudgetSummaryVisible;
        //gridReallocationFromPeriodTempSummary.Visible = !fromBudgetSummaryVisible;

        ddlLocation.Enabled = rfq.IsNew;
        //SetReallocationTo();//tessa comment out //tessa end

        Workflow_Setting();

        // If Storeid is null disable the following controls
        checkIsGroupWJ.Enabled = (rfq.StoreID == null) && !(RequestForQuotationItems.Rows.Count != 0 || RequestForQuotationItem_SubPanel.Visible == true);
        listLocations.Enabled = (rfq.StoreID == null) && !(RequestForQuotationItems.Rows.Count != 0 || RequestForQuotationItem_SubPanel.Visible == true);
        gridRequestForQuotationItemLocations.Columns[3].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString());
        gridRequestForQuotationItemLocations.Columns[1].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString());
        gridRequestForQuotationItemLocations.Columns[2].Visible = (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString());
        AdditionalDescription.Visible = ItemType.SelectedValue == "0" || ItemType.SelectedValue == "1";
        checkIsTermContract.Enabled = (rfq.StoreID != null) ? false : true;
        RequestForQuotationItems.Enabled = !RequestForQuotationVendors_SubPanel.Visible;
        RequestForQuotationVendors.Enabled = !RequestForQuotationItem_SubPanel.Visible;

        
        // For MARCOM.
        // (copy this to the simplifiedRFQedit.aspx page for this
        // to take effect.)
        // 
        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
        {
            textBackground.Visible = false;
            textScope.Visible = false;
            textEvaluation.Visible = false;
            textAwardedJustification.ValidateRequiredField = false;
            panelWarranty.Visible = false;
            textCampaign.Visible = true;
            tabLineItems.Visible = false;
        }

        if (objectBase.SelectedAction.Is("Reject"))
        {
            textBackground.Enabled = true;
            textScope.Enabled = true;
            panelAward.Enabled = true;
        }

        // 2010.12.22
        // Kim Foong
        // For IT only,
        // Show the delegate to HOD hint if the WJ amount is equal or above
        // $100,000. Note that this figure is currently harcoded
        // for simplicity.
        //
        IsDelegatedToHODHint.Visible = (ConfigurationManager.AppSettings["CustomizedInstance"] == "IT") &&
            rfq.TaskAmount >= 100000;
    }

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
    /// Hides/shows or enables/disables elements according to workflow.
    /// </summary>
    protected void Workflow_Setting()
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        ORequestForQuotationVendor rfqVendor = RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;

        string stateAndAction = objectBase.CurrentObjectState + "::" + objectBase.SelectedAction;

        tabDetails.Enabled = !objectBase.CurrentObjectState.Is("Close", "Cancelled");
        panelDetails.Enabled = panelRequestorDate.Enabled = textBackground.Enabled = textScope.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        tabLineItems.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        tabQuotations.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelBudget2.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        panelAwardVendor.Visible = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");

        //textAwardedJustification.ValidateRequiredField = objectBase.SelectedAction.Is("SubmitForApproval") ||
            //objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Cancelled", "Close");

        panelAward.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        textAwardedJustification.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
        //textAwardedJustification.Enabled = objectBase.SelectedAction.Is("Reject");
        panelGeneratePOButton.Visible = objectBase.CurrentObjectState.Is("Awarded");

        dropPurchaseType.ValidateRequiredField = !(objectBase.CurrentObjectState.Is("Draft") && objectBase.SelectedAction.Is("Cancel"));

        panelReallocateFrom.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval", "Awarded", "Close", "Cancelled");
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
            {
                RFQIL.QuantityRequired = 1;
            }
            RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(RFQI);


        }
        if (radioReceiptMode.SelectedValue == ReceiptModeType.Quantity.ToString())
        {
            ORequestForQuotationItem RFQI = RequestForQuotationItem_SubPanel.SessionObject as ORequestForQuotationItem;
            if (!RFQI.IsNew)
            {
                ORequestForQuotationItem Rfqitem = TablesLogic.tRequestForQuotationItem.Load(RFQI.ObjectID);
                RequestForQuotationItem_SubPanel.ObjectPanel.BindObjectToControls(Rfqitem);
            }
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
            if (rfqi.AwardedVendorID != null)
                items.Add(rfqi);
        OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQLineItems(items, purchaseOrderType);
        Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.Value.ToString(), "");
    }


    /// <summary>
    /// Occurs when the user clicks on the Generate PO from RFQ button.
    /// This generates a PO from all the line items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePO_Click(object sender, EventArgs e)
    {
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

            OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQLineItems(items, purchaseOrderType);
            Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.Value.ToString(), "");
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
        GeneratePOFromLineItems(PurchaseOrderType.LOA);
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

        UIFieldTextBox unitprice = e.Row.FindControl("UnitPrice") as UIFieldTextBox;
        if (unitprice != null)
        {
            unitprice.DataFormatString = "{0:#,##0.00##}";
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
        UpdateBudgetAmount(rfq);
        panel.ObjectPanel.BindObjectToControls(rfq);

        dropVendorToAward.SelectedIndex = 0;
    }
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

        if (BudgetGroupID.SelectedValue != "")
        {
            if (!checkIsGroupWJ.Checked)
            {
                dropBudget.Bind(OBudget.GetCoveringBudgets(rfq.Location, prBudget.BudgetID, new Guid(BudgetGroupID.SelectedValue)));
            }
            else
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in rfq.GroupWJLocations)
                    locations.Add(location);
                dropBudget.Bind(OBudget.GetCoveringBudgets(locations, prBudget.BudgetID, new Guid(BudgetGroupID.SelectedValue)));
            }
        }

        if (subpanelBudget.IsAddingObject)
        {
            if (dropBudget.Items.Count == 2)
                prBudget.BudgetID = new Guid(dropBudget.Items[1].Value);
            prBudget.StartDate = rfq.DateRequired;
            prBudget.EndDate = rfq.DateRequired;
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
            //rfq.ComputeBudgetReallocationToPeriods();
            //rfq.UpdateTempBudgetSummaryWithReallocation();
            gridBudgetSummary.PropertyName = "TempPurchaseBudgetSummaries";

            PopulateDropFromBudget(rfq);

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
            //tessa comment out because of the hiding of budget reallocation
            //rfq.ComputeBudgetReallocationToPeriods();
            //rfq.UpdateTempBudgetSummaryWithReallocation();
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
            e.Row.Cells[14].Text = e.Row.Cells[13].Text + e.Row.Cells[14].Text;
        }
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[13].Visible = false;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid rfqVendorId = (Guid)RequestForQuotationVendors.DataKeys[e.Row.RowIndex][0];
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            ORequestForQuotationVendor rfqVendor = rfq.RequestForQuotationVendors.Find(rfqVendorId);

            DataList listAttachment = (DataList)e.Row.FindControl("listAttachment");
            listAttachment.ItemDataBound += new DataListItemEventHandler(listAttachment_ItemDataBound);
            listAttachment.DataSource = rfqVendor.Attachments;
            listAttachment.DataBind();

            /*            
            listAttachment
            rfqVendor.Attachments;

            foreach (OAttachment attachment in rfqVendor.Attachments)
            {
                if (!attachment.IsNew)
                {
                    string html = "<a href='../../components/downloadattachment.aspx?AttachmentID=" +
                        Security.Encrypt(attachment.ObjectID.ToString()) + "'>" +
                        attachment.Filename + "</a>; ";
                    e.Row.Cells[17].Text += html;
                }
            }
             * */
        }
    }

    void listAttachment_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        OAttachment attachment = (OAttachment)e.Item.DataItem;
        UIButton buttonDownloadAttachment = (UIButton)e.Item.FindControl("buttonDownloadAttachment");

        buttonDownloadAttachment.CommandArgument = attachment.ObjectID.ToString();
        buttonDownloadAttachment.Text = attachment.Filename;
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
                Window.Open("../../customizedmodulesforcapitaland/budgetperiod/budgetview.aspx?ID=" +
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
            //unitprice in selected currency
            if (e.Row.Cells[10].Text != "&nbsp;")
            {
                //if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                    e.Row.Cells[10].Text = Convert.ToDecimal(e.Row.Cells[10].Text).ToString("#,##0.00##");
                //else
                //    e.Row.Cells[10].Text = Convert.ToDecimal(e.Row.Cells[10].Text).ToString("c");
            }
            //unitprice in base currency
            if (e.Row.Cells[11].Text != "&nbsp;")
            {
                //if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                    e.Row.Cells[11].Text = Convert.ToDecimal(e.Row.Cells[11].Text).ToString(OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "#,##0.00##");
                //else
                //    e.Row.Cells[11].Text = Convert.ToDecimal(e.Row.Cells[11].Text).ToString("c");
            }
            e.Row.Cells[10].Text = e.Row.Cells[9].Text + e.Row.Cells[10].Text;
            Guid rfqItemID = (Guid)gridAwardItems.DataKeys[e.Row.RowIndex][0];
            ORequestForQuotationItem item = TablesLogic.tRequestForQuotationItem.Load(rfqItemID);
            if (item!=null && item.PurchaseOrderItem != null)
            {
                Guid poID = item.PurchaseOrderItem.PurchaseOrderID.Value;
                if (EditVisible[poID] == null)
                    EditVisible.Add(poID, OPurchaseOrder.IsObjectEditOrView(AppSession.User, poID, "OPurchaseOrder", true));
                if (ViewVisible[poID] == null)
                    ViewVisible.Add(poID, OPurchaseOrder.IsObjectEditOrView(AppSession.User, poID, "OPurchaseOrder", false));

                e.Row.Cells[13].Visible = Convert.ToBoolean(EditVisible[poID]);
                e.Row.Cells[14].Visible = Convert.ToBoolean(ViewVisible[poID]);
            }
            else
            {
                e.Row.Cells[13].Visible = false;
                e.Row.Cells[14].Visible = false;
            }
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
        txtWarrantyPeriod.ValidateRequiredField = panelWarranty.Visible = (UIFieldRadioListHasWarranty.SelectedIndex == 1);
    }
    
    protected void dropPurchaseTypeClassification_SelectedIndexChanged(object sender, EventArgs e)
    {

        if (dropPurchaseTypeClassification.SelectedValue != "")
            dropPurchaseType.Bind(TablesLogic.tCode.LoadList(TablesLogic.tCode.ParentID == new Guid(dropPurchaseTypeClassification.SelectedValue)));
        else
            dropPurchaseType.Items.Clear();
    }

    protected void listLocations_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        List<OLocation> locs = new List<OLocation>();
        ArrayList al_LocationIDs = new ArrayList();

        for (int i = 0; i < listLocations.Items.Count; i++)
        {
            if (listLocations.Items[i].Selected)
            {
                al_LocationIDs.Add(new Guid(listLocations.Items[i].Value));
                //Guid locationID = new Guid(); 
                //  locationID=(Guid)listLocations.Items[i].Value;
                //OLocation loc = LogicLayer.TablesLogic.tLocation.Create();
                //loc = LogicLayer.TablesLogic.tLocation.Load(locationID);
                //locs.Add(loc);
            }
        }
        if (al_LocationIDs.Count > 0)
        {
            locs = TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ObjectID.In(al_LocationIDs)
                );
        }

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


            if (rfq.ValidateFromAccountIdDoesNotExist(budgetId, budgetPeriodId, accountId))
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

                rfq.ComputeFromBudgetSummary();

                panel.ObjectPanel.BindObjectToControls(rfq);
                panel.Message = "";
            }
            else
                panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;

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
        if (Convert.ToInt16(rdlTerm.SelectedValue) == 0)
            terms = 1;
        else if (Convert.ToInt16(rdlTerm.SelectedValue) == 1)
            terms = 3;
        else if (Convert.ToInt16(rdlTerm.SelectedValue) == 2)
            terms = 6;
        else if (Convert.ToInt16(rdlTerm.SelectedValue) == 3)
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
            !rfq.CurrentActivity.ObjectName.Is("PendingApproval", "Approved", "Closed", "Cancelled"))
        {
            rfq.ComputeTempBudgetSummaries();
            //tessa comment out because of the hiding of budget reallocation
            //rfq.ComputeBudgetReallocationToPeriods();
            //rfq.UpdateTempBudgetSummaryWithReallocation();
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
        if (dropAddBudget.SelectedIndex != 0)
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
            dropLocation.Items.Clear();
        
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
        if (dateAddBudgetStartDate.DateTime != null && dropAddBudget.SelectedValue != "")
        {
            Guid? purchaseTypeID = null;
            if (dropPurchaseType.SelectedValue != "")
                purchaseTypeID = new Guid(dropPurchaseType.SelectedValue);

            Guid budgetId = new Guid(dropAddBudget.SelectedValue);
            OBudgetPeriod budgetPeriod = OBudgetPeriod.GetBudgetPeriodByBudgetIDAndDate(budgetId, dateAddBudgetStartDate.DateTime.Value);

            if (budgetPeriod != null)
                return new AccountTreePopulaterForCapitaland(null, false, true, budgetPeriod.ObjectID, purchaseTypeID);
            else
                return new AccountTreePopulaterForCapitaland(null, false, true, null, purchaseTypeID);
        }
        return null;
    }
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

    protected void AutoCalculateReallocationTo_CheckedChanged(object sender, EventArgs e)
    {

    }

    protected void buttonUpload_Click(object sender, EventArgs e)
    {
        if (inputFile.PostedFile != null && inputFile.PostedFile.ContentLength > 0)
        {
            OAttachment a = TablesLogic.tAttachment.Create();
            byte[] fileBytes = new byte[inputFile.PostedFile.ContentLength];
            inputFile.PostedFile.InputStream.Position = 0;
            inputFile.PostedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

            a.FileBytes = fileBytes;
            a.Filename = Path.GetFileName(inputFile.PostedFile.FileName);
            a.FileSize = inputFile.PostedFile.ContentLength;
            a.ContentType = inputFile.PostedFile.ContentType;

            a.FileDescription = this.documentDescription.Text;
            ORequestForQuotationVendor rfqVendor =
            RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
            if (rfqVendor != null)
            {
                rfqVendor.Attachments.Add(a);
            }
            panelgridAttachments.BindObjectToControls(rfqVendor);
            //clear other details
            this.documentDescription.Text = "";
        }
    }
    /// <summary>
    /// Initializes the control.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        // Register the buttonUpload button to force a full
        // postback whenever a file is uploaded.
        //
        if (Page is UIPageBase)
        {
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttonUpload);
        }
    }

    protected void gridDocument_Action(object sender, string commandName, List<object> objectIds)
    {
        ORequestForQuotationVendor rfqVendor =
                        RequestForQuotationVendors_SubPanel.SessionObject as ORequestForQuotationVendor;
        if (commandName == "ViewDocument")
        {
            // View the document, so load it from
            // database and let user download it.
            //
            using (Connection c = new Connection())
            {
                foreach (Guid objectId in objectIds)
                {
                    string contentType = "";
                    string fileName = "";

                    if (rfqVendor != null)
                        foreach (OAttachment b in rfqVendor.Attachments)
                            if (b.ObjectID.Value == objectId)
                            {
                                Window.Download(b.FileBytes, b.Filename, b.ContentType);
                                break;
                            }
                }
            }
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

    protected void ddlLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
            panel.ObjectPanel.BindControlsToObject(rfq);
            //OLocation loc = LogicLayer.TablesLogic.tLocation.Load(rfq.LocationID);
            //dropCampaign.Bind(loc.CampaignsForLocations, "ObjectName", "ObjectID");
            rfq.EquipmentID = null;
            rfq.UpdateApplicablePurchaseSettings();
            if (rfq.Location != null)
                rfq.EmployerCompanyID = rfq.Location.BuildingTrustID;
            BindRequestorID(rfq);
            panel.ObjectPanel.BindObjectToControls(rfq);
        }
        catch (Exception ex)
        { }

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
                {
                    rfq.RemoveLineItemsFromRFQVendors(item);
                }
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
            /*if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            {
                e.Row.Cells[10].Text = Convert.ToDecimal(e.Row.Cells[10].Text).ToString(OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "#,##0.0000");
            }
            else
                e.Row.Cells[10].Text = Convert.ToDecimal(e.Row.Cells[10].Text).ToString("c");*/
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


    protected void AutoComputeBudgetAmount(ORequestForQuotation rfq)
    {
        if (rfq.IsGroupWJ == 0)
        {
            decimal? amount = 0;
            decimal? totalAmount = 0;
            if (radioBudgetDistributionMode.SelectedValue == "0")
            {
                foreach (OPurchaseBudget pb in rfq.PurchaseBudgets)
                {
                    amount += pb.Amount;
                }
                foreach (ORequestForQuotationItem item in rfq.RequestForQuotationItems)
                    if (item.Subtotal != null)
                        totalAmount += item.Subtotal;
            }
            else
            {
                int no = Convert.ToInt16(dropAddBudgetItemNumber.SelectedValue);

                ORequestForQuotationItem item = rfq.RequestForQuotationItems.Find((r) => r.ItemNumber == no);
                if (item != null)
                    totalAmount = item.Subtotal;
                List<OPurchaseBudget> pbList = rfq.PurchaseBudgets.FindAll((r) => r.ItemNumber == no);
                if (pbList != null)
                {
                    foreach (OPurchaseBudget pb in pbList)
                        amount += pb.Amount;
                }

            }
            decimal remainAmount = totalAmount >= amount ? Convert.ToDecimal(totalAmount - amount) : 0;
            textAddBudgetAmount.Text = Math.Round(remainAmount, 2, MidpointRounding.AwayFromZero).ToString();
        }
        else if (rfq.IsGroupWJ == 1)
        {
            if (radioBudgetDistributionMode.SelectedValue == "0")
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
                            totalLineItemAmounts[rfqil.LocationID] = (decimal)totalLineItemAmounts[rfqil.LocationID] + rfqitem.UnitPrice.Value * rfqil.QuantityRequired.Value;
                        }
                    }
                    else
                    {
                        decimal? totalratio = 0m;
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalratio += rfqil.AmountRatio;
                        }
                        foreach (ORequestForQuotationItemLocation rfqil in rfqitem.RequestForQuotationItemLocation)
                        {
                            totalLineItemAmounts[rfqil.LocationID] = (decimal)totalLineItemAmounts[rfqil.LocationID] + rfqitem.UnitPrice.Value * rfqil.AmountRatio / totalratio;
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
                    decimal remainAmount = (decimal)totalLineItemAmounts[budget.ObjectID] >= (decimal)totalBudgetAmounts[budget.ObjectID] ? Convert.ToDecimal((decimal)totalLineItemAmounts[budget.ObjectID] - (decimal)totalBudgetAmounts[budget.ObjectID]) : 0;
                    textAddBudgetAmount.Text = Math.Round(remainAmount, 2, MidpointRounding.AwayFromZero).ToString();
                }
            }


            else if (radioBudgetDistributionMode.SelectedValue == "1")
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

                    if (rfqitem.ReceiptMode.Value == 1)
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

    protected void dropAddBudgetItemNumber_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        AutoComputeBudgetAmount(rfq);
    }



    protected void buttonViewGroupWJ_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        Window.OpenViewObjectPage(this.Page, "ORequestForQuotation", rfq.GroupRequestForQuotation.ObjectID.ToString(), "");
    }

    protected void buttonEditGroupWJ_Click(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        Window.OpenEditObjectPage(this.Page, "ORequestForQuotation", rfq.GroupRequestForQuotation.ObjectID.ToString(), "");
    }

    protected void gridChildWJs_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditObject")
        {
            Window.OpenEditObjectPage(this.Page, "ORequestForQuotation", dataKeys[0].ToString(), "");
        }
        if (commandName == "ViewObject")
            Window.OpenViewObjectPage(this.Page, "ORequestForQuotation", dataKeys[0].ToString(), "");
    }

    protected void dropLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = panel.SessionObject as ORequestForQuotation;
        panel.ObjectPanel.BindControlsToObject(rfq);
        AutoComputeBudgetAmount(rfq);
    }

    protected void IsGroupApproval_CheckedChanged(object sender, EventArgs e)
    {

    }

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

        if (commandName == "EditPO")
        {
            Guid? objectID = (Guid?)objectIDs[0];
            ORequestForQuotationItem rfqItem = TablesLogic.tRequestForQuotationItem[objectID.Value];
            Window.OpenEditObjectPage(this, "OPurchaseOrder", rfqItem.PurchaseOrderItem.PurchaseOrderID.ToString(), "");
        }
        else if (commandName == "ViewPO")
        {
            Guid? objectID = (Guid?)objectIDs[0];
            ORequestForQuotationItem rfqItem = TablesLogic.tRequestForQuotationItem[objectID.Value];
            Window.OpenViewObjectPage(this, "OPurchaseOrder", rfqItem.PurchaseOrderItem.PurchaseOrderID.ToString(), "");
        }
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

    <script type='text/javascript'>
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
    <ui:UIObjectPanel runat="server" BorderStyle="NotSet" meta:resourcekey="UIObjectPanelResource1">    
        <web:object runat="server" ID="panel" Caption="Work Justification" BaseTable="tRequestForQuotation"
            SpellCheckButtonVisible="true" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"
            OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <span style="display: none">
            <ui:UIButton runat="server" ID="repopulateCatalogueButton" OnClick="repopulateCatalogue_Click"
                CausesValidation="false" />
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
                            <ui:UIPanel runat="server" ID="panelCase">
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
                            <ui:UISeparator ID="UISeparator1" runat="server" meta:resourcekey="UISeparator1Resource1" />
                            <ui:UIPanel runat="server" ID="panelGroupWJ" BorderStyle="NotSet" meta:resourcekey="panelGroupWJResource1">
                                <ui:UIFieldCheckBox runat="server" ID="checkIsGroupWJ" PropertyName="IsGroupWJ" Caption="Group WJ?"
                                    Visible="true" Text="Yes, this is a group WJ across multiple properties." OnCheckedChanged="checkIsGroupWJ_CheckedChanged"
                                    meta:resourcekey="checkIsGroupWJResource1" TextAlign="Right">
                                </ui:UIFieldCheckBox>
                                <ui:UIFieldCheckBox runat="server" ID="IsGroupApproval" PropertyName="IsGroupApproval"
                                    Caption="Group Approval?" Visible="true" Text="Yes, shall be approved by a group Approval Hierarchy"
                                    TextAlign="Right" OnCheckedChanged="IsGroupApproval_CheckedChanged">
                                </ui:UIFieldCheckBox>
                                <%--  <ui:UIFieldLabel Caption="Parent WJ Number" ID="GroupRequestForQuotationID" runat="server" PropertyName="GroupRequestForQuotation.ObjectNumber">
                            <ContextMenuButtons>
                             <ui:UIButton runat="server" ID="buttonViewGroupWJ" ImageUrl="~/images/view.gif" Text="view Group WJ" OnClick="buttonViewGroupWJ_Click" AlwaysEnabled="true" />
                             <ui:UIButton runat="server" ID="buttonEditGroupWJ" ImageUrl="~/images/edit.gif" Text="edit Group WJ" OnClick="buttonEditGroupWJ_Click" AlwaysEnabled="true"/>
                            </ContextMenuButtons>
                            </ui:UIFieldLabel>--%>
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
                                <%--<ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                                OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                                ValidateRequiredField="True" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None"
                                TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" PropertyName="EquipmentID"
                                OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged"
                                meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>--%>
                                <ui:UIFieldListBox runat="server" ID="listLocations" PropertyName="GroupWJLocations"
                                    SelectionMode="Multiple" Caption="Locations" ValidateRequiredField="True" OnSelectedIndexChanged="listLocations_SelectedIndexChanged"
                                    meta:resourcekey="listLocationsResource1"></ui:UIFieldListBox>
                                <UI:UIFieldTextBox ID = "CancelledPurchaseOrder" runat = "server" Caption ="Revised from cancelled PO" PropertyName="CancelledPurchaseOrder.ObjectNumber"
                                    Span="Half" Visible="false" Enabled="false" ContextMenuAlwaysEnabled="true">
                                    <ContextMenuButtons>
                                        <ui:UIButton visible="false" runat="server" id="buttonViewPurchaseOrder" Text="View Purchase Order" AlwaysEnabled="True" ImageUrl="~/images/view.gif" ConfirmText="Please remember to save this Work Justification before viewing the Purchase Order.\n\nAre you sure you want to continue?" OnClick="buttonViewPurchaseOrder_Click" meta:resourcekey="buttonViewPurchaseOrderResource1"/>
                                        <ui:UIButton visible="false" runat="server" id="buttonEditPurchaseOrder" Text="Edit Purchase Order" AlwaysEnabled="True" ImageUrl="~/images/edit.gif" ConfirmText="Please remember to save this Work Justification before editing the Purchase Order.\n\nAre you sure you want to continue?" OnClick="buttonEditPurchaseOrder_Click" meta:resourcekey="buttonEditPurchaseOrderResource1"/>
                                    </ContextMenuButtons>                                    
                                </UI:UIFieldTextBox>                                    
                            </ui:UIPanel>
                            <ui:UIFieldTextBox runat='server' ID="textCampaign" PropertyName="Campaign" Caption="Campaign"
                                Span="Half" Visible="false">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="Description" runat="server" Caption="Header Description" PropertyName="Description"
                                MaxLength="255" ValidateRequiredField="True" meta:resourcekey="DescriptionResource1"
                                InternalControlWidth="95%" />
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
                            <ui:UIFieldCheckBox runat="server" ID="checkIsTermContract" PropertyName="IsTermContract"
                                Caption="Term Contract?" Text="Yes, this WJ is for a term contract." OnCheckedChanged="checkIsTermContract_CheckedChanged"
                                meta:resourcekey="checkIsTermContractResource1" TextAlign="Right">
                            </ui:UIFieldCheckBox>
                            <ui:UIFieldLabel ID="StoreID" runat="server" Caption="Store" Span="Full" PropertyName="Store.ObjectName"
                                Enabled="False" meta:resourcekey="StoreIDResource1">
                            </ui:UIFieldLabel>
                        </ui:UIPanel>
                        </ui:UIPanel>
                        <ui:UIFieldRichTextBox ID="textBackground" runat="server" Caption="Background" PropertyName="Background"
                            EditorHeight="100px">
                        </ui:UIFieldRichTextBox>
                        <ui:UIFieldRichTextBox ID="textScope" runat="server" Caption="Scope" PropertyName="Scope"
                            EditorHeight="100px">
                        </ui:UIFieldRichTextBox>
                        <ui:UIPanel runat="server" ID="panelRequestorDate">
                        <ui:UIFieldTextBox ID="textRequestorName" runat="server" Caption="Requestor Name"
                            PropertyName="RequestorName">
                        </ui:UIFieldTextBox>                                                   
                            <ui:UIFieldRadioList runat="server" ID="UIFieldRadioListHasWarranty" PropertyName="hasWarranty"
                                Caption="Has Warranty?" OnSelectedIndexChanged="radioHasWarranty_SelectedIndexChanged" ValidateRequiredField="true" Visible="false"
                                TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" Text="No Warranty"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Has Warranty"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>                      
                        <ui:UIPanel runat="server" ID="panelWarranty">                                                   
                            <ui:UIFieldTextBox runat="server" ID="Warranty" Caption="Warranty" PropertyName="Warranty"
                                MaxLength="255">
                            </ui:UIFieldTextBox>
                            <table>                                
                                <tr>
                                    <td>
                                        <asp:Label ID="lblWarrantyPeriod" runat="server" Text="Warranty Period" Width="120px"></asp:Label>
                                    </td>
                                    <td>
                                        <ui:UIFieldTextBox runat="server" ID="txtWarrantyPeriod" Caption="Warranty Period"
                                            PropertyName="WarrantyPeriod" ValidateDataTypeCheck="True" ValidationDataType="Integer"
                                            Span="Half" InternalControlWidth="100px" FieldLayout="Flow" ShowCaption="false">
                                        </ui:UIFieldTextBox>
                                        <ui:UIFieldDropDownList runat="server" ID="ddlWarrantyUnit" Caption="Warranty Unit"
                                            PropertyName="WarrantyPeriodInterval" Span="Half" InternalControlWidth="100px"
                                            FieldLayout="Flow" ShowCaption="false">
                                            <Items>
                                                <asp:ListItem Value="0">day(s)</asp:ListItem>
                                                <asp:ListItem Value="1">week(s)</asp:ListItem>
                                                <asp:ListItem Value="2">month(s)</asp:ListItem>
                                                <asp:ListItem Value="3">year(s)</asp:ListItem>
                                            </Items>
                                        </ui:UIFieldDropDownList>
                                    </td>
                                </tr>
                            </table>
                        </ui:UIPanel>
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
                                <ui:UIGridViewBoundColumn DataField="TaskAmount" HeaderText="Total Amount" PropertyName="TaskAmount"
                                    ResourceAssemblyName="" SortExpression="TaskAmount">
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
                            Width="100%" PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor=""
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
                                <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="Number" meta:resourceKey="UIGridViewColumnResource3"
                                    PropertyName="ItemNumber" ResourceAssemblyName="" SortExpression="ItemNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemTypeText" HeaderText="Type" meta:resourceKey="UIGridViewColumnResource4"
                                    PropertyName="ItemTypeText" ResourceAssemblyName="" SortExpression="ItemTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemDescription" HeaderText="Line Item Description" meta:resourceKey="UIGridViewColumnResource5"
                                    PropertyName="ItemDescription" ResourceAssemblyName="" SortExpression="ItemDescription">
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
                        <ui:UIHint runat="server" ID="hintRfqItemsAddDelete" 
                            meta:resourcekey="hintRfqItemsAddDeleteResource1">
                                This list of items here should be the list of items that will appear in your PO once this WJ is approved.
                        </ui:UIHint>
                        
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
                            <ui:UIFieldTextBox ID="ItemDescription" runat="server" Caption="Line Item Description" PropertyName="ItemDescription"
                                MaxLength="2000" ValidateRequiredField="True" meta:resourcekey="ItemDescriptionResource1"
                                InternalControlWidth="95%" />
                            <ui:UIFieldTextBox ID="AdditionalDescription" runat="server" Caption="Additional Description"
                                PropertyName="AdditionalDescription" MaxLength="255">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" Caption="Unit of Measure"
                                PropertyName="UnitOfMeasureID" meta:resourcekey="UnitOfMeasureIDResource1" />
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
                            <ui:UIGridView runat="server" ID="gridRequestForQuotationItemLocations" PropertyName="RequestForQuotationItemLocation"
                                Caption="" BindObjectsToRows="true">
                                <Columns>
                                    <ui:UIGridViewBoundColumn HeaderText="Location" PropertyName="Location.ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewTemplateColumn HeaderText="Quantity Required">
                                        <ItemTemplate>
                                            <ui:UIFieldLabel runat="server" Text="1" ID="LabelLocationQuantityRequired" Width="150px">
                                            </ui:UIFieldLabel>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>
                                    <ui:UIGridViewTemplateColumn HeaderText="Quantity Required">
                                        <ItemTemplate>
                                            <ui:UIFieldTextBox runat="server" ID="textLocationQuantityRequired" Width="150px"
                                                Caption="Quantity Required" PropertyName="QuantityRequired" ShowCaption="false"
                                                ValidateRequiredField="true" ValidateDataTypeCheck="true" ValidationDataType="Integer"
                                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer">
                                            </ui:UIFieldTextBox>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>
                                    <ui:UIGridViewTemplateColumn HeaderText="Dollar Amount">
                                        <ItemTemplate>
                                            <ui:UIFieldTextBox runat="server" ID="textLocationDollarRequired" Width="150px" Caption="Dollar Required"
                                                PropertyName="AmountRatio" ShowCaption="false" ValidateRegexField="true" ValidateDataTypeCheck="true"
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
                    <ui:UIFieldTextBox ID="txtRFQTitle" runat="server" MaxLength="255" Caption="RFQ Title" PropertyName="RFQTitle"
                        InternalControlWidth="95%">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat="server" ID="ddl_EmployerCompany" Caption="Employer Company"
                        PropertyName="EmployerCompanyID">
                    </ui:UIFieldDropDownList>
                    <br />
                    <br />
                    <ui:UIButton ID="buttonAddMultipleVendors" runat="server" ImageUrl="~/images/add.gif"
                        Text="Add Multiple Vendors" CausesValidation="False" OnClick="buttonAddMultipleVendors_Click"
                        meta:resourcekey="buttonAddMultipleVendorsResource1" />
                    <ui:UIButton runat="server" ID="buttonVendorsAdded" CausesValidation="False" OnClick="buttonVendorsAdded_Click"
                        meta:resourcekey="buttonVendorsAddedResource1"></ui:UIButton>
                    <br />
                    <br />
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
                            <cc1:UIGridViewBoundColumn DataField="ContactEmail" HeaderText="Email" meta:resourceKey="UIGridViewColumnResource13"
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
                            </cc1:UIGridViewBoundColumn>
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
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Quotation Ref No."
                                PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
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
                            <cc1:UIGridViewBoundColumn DataField="TotalQuotation" DataFormatString="{0:c}" HeaderText="Quotation (Base Currency)"
                                meta:resourceKey="UIGridViewColumnResource18" PropertyName="TotalQuotation" ResourceAssemblyName=""
                                SortExpression="TotalQuotation">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn HeaderText="Percentage Above Minimum" PropertyName="PercentageAboveMinimumQuoteText">
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
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="RequestForQuotationVendors_Panel" runat="server" meta:resourcekey="RequestForQuotationVendors_PanelResource1"
                        BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="RequestForQuotationVendors_SubPanel" GridViewID="RequestForQuotationVendors"
                            OnValidateAndUpdate="RequestForQuotationVendors_SubPanel_ValidateAndUpdate" OnPopulateForm="RequestForQuotationVendors_SubPanel_PopulateForm"
                            OnRemoved="RequestForQuotationVendors_SubPanel_Removed" />
                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropVendor" PropertyName="VendorID"
                            Caption="Vendor" OnSelectedIndexChanged="dropVendor_SelectedIndexChanged" ValidateRequiredField='True'
                            MaximumNumberOfItems="100" meta:resourcekey="dropVendorResource1" SearchInterval="300">
                        </ui:UIFieldSearchableDropDownList>
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
                            <table cellpadding='0' cellspacing='0' border='0' style="clear: both; width: 50%">
                                <tr style="height: 25px" class='field-required'>
                                    <td style='width: 120px'>
                                        <asp:Label runat="server" ID="labelExchangeRate" meta:resourcekey="labelExchangeRateResource1"
                                            Text="Exchange Rate*:"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="labelER1" meta:resourcekey="labelER1Resource1" Text="1"></asp:Label>
                                        <ui:UIFieldLabel runat="server" ID="labelERThisCurrency" ShowCaption="False" FieldLayout="Flow"
                                            InternalControlWidth="20px" PropertyName="Currency.ObjectName" DataFormatString=""
                                            meta:resourcekey="labelERThisCurrencyResource1">
                                        </ui:UIFieldLabel>
                                        <asp:Label runat="server" ID="labelEREquals" meta:resourcekey="labelEREqualsResource1"
                                            Text="is equal to"></asp:Label>
                                        <ui:UIFieldTextBox runat="server" ID="textForeignToBaseExchangeRate" PropertyName="ForeignToBaseExchangeRate"
                                            Caption="Exchange Rate" Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True"
                                            ValidationDataType="Currency" FieldLayout="Flow" InternalControlWidth="60px"
                                            ShowCaption="False" meta:resourcekey="textForeignToBaseExchangeRateResource1" />
                                        <asp:Label runat="server" ID="labelERBaseCurrency" meta:resourcekey="labelERBaseCurrencyResource1"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <ui:UIGridView ID="RequestForQuotationVendorItems" runat="server" Caption="Quotation"
                                BindObjectsToRows="True" CheckBoxColumnVisible="False" PageSize="1000" PropertyName="RequestForQuotationVendorItems"
                                SortExpression="[ItemNumber] ASC" KeyName="ObjectID" meta:resourcekey="RequestForQuotationVendorItemsResource1"
                                Width="100%" PagingEnabled="True" OnRowDataBound="RequestForQuotationVendorItems_RowDataBound"
                                DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                                ImageRowErrorUrl="">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Columns>
                                    <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="Number" meta:resourceKey="UIGridViewColumnResource19"
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
                                    <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" HeaderText="Unit of Measure"
                                        meta:resourceKey="UIGridViewColumnResource22" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                        ResourceAssemblyName="" SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Quantity Provided" meta:resourceKey="UIGridViewColumnResource23">
                                        <ItemTemplate>
                                            <cc1:UIFieldTextBox ID="QuantityProvided" runat="server" Caption="Quantity" CaptionWidth="1px"
                                                DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="QuantityProvidedResource1"
                                                PropertyName="QuantityProvided" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                                ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                                ValidationRangeMin="0" ValidationRangeType="Currency">
                                            </cc1:UIFieldTextBox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                    <cc1:UIGridViewTemplateColumn HeaderText="Unit Price" meta:resourceKey="UIGridViewColumnResource24">
                                        <ItemTemplate>
                                            <cc1:UIFieldTextBox ID="UnitPrice" runat="server" Caption="Unit Price" CaptionWidth="1px"
                                                FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="UnitPriceResource1"
                                                PropertyName="UnitPriceInSelectedCurrency" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                                ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                                ValidationRangeMin="0" ValidationRangeType="Currency" ValidationNumberOfDecimalPlaces="4" >
                                            </cc1:UIFieldTextBox>
                                        </ItemTemplate>
                                        <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewTemplateColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelVendorAttachments">
                            <ui:UISeparator ID="UISeparator4" runat="server" Caption="Attachments" />
                            <ui:UIFieldInputFile runat="server" ID="inputFile" Caption="File">
                            </ui:UIFieldInputFile>
                            <ui:UIFieldTextBox runat="server" ID="documentDescription" Caption="Document Description"
                                Span="full" MaxLength="255">
                            </ui:UIFieldTextBox>
                            <ui:UIPanel runat="server" ID="panelUpload">
                                <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                    <tr>
                                        <td style="width: 150px">
                                        </td>
                                        <td>
                                            <ui:UIButton runat="server" Text="Upload File" ID="buttonUpload" ImageUrl="~/images/upload.png"
                                                OnClick="buttonUpload_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panelgridAttachments">
                                <ui:UIGridView runat='server' ID="gridDocument" Caption="Attachments" PropertyName="Attachments"
                                    CaptionWidth="120px" KeyName="ObjectID" OnAction="gridDocument_Action">
                                    <Commands>
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
                                        <ui:UIGridViewBoundColumn PropertyName="AttachmentType.ObjectName" HeaderText="Attachment Type">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="Filename" HeaderText="File Name" meta:resourcekey="UIGridViewColumnResource3">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="FileSize" HeaderText="File Size (bytes)"
                                            DataFormatString="{0:#,##0}" meta:resourcekey="UIGridViewColumnResource4">
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
                            Width="100%" PagingEnabled="True" OnRowDataBound="gridAwardItems_RowDataBound"
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
                                <cc1:UIGridViewBoundColumn DataField="UnitPriceInSelectedCurrency"
                                    HeaderText="Unit Price" meta:resourcekey="UIGridViewBoundColumnResource16" PropertyName="UnitPriceInSelectedCurrency"
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
                                 <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditPO" ImageUrl="~/images/edit.gif" AlwaysEnabled="true" 
                                        ConfirmText="Are you sure you wish to open this PO/LOA for editing? Please remember to save the Work Justification, otherwise changes that you have made will be lost.">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewPO" ImageUrl="~/images/view.gif" AlwaysEnabled="true"
                                     ConfirmText="Are you sure you wish to open this PO/LOA for viewing? Please remember to save the Work Justification, otherwise changes that you have made will be lost.">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="CopiedToObjectNumber" HeaderText="Copied To"
                                    meta:resourcekey="UIGridViewBoundColumnResource20" PropertyName="CopiedToObjectNumber"
                                    ResourceAssemblyName="" SortExpression="CopiedToObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIHint runat="server" ID="hintQuotationPolicy" ImageUrl="~/images/error.gif"
                            meta:resourcekey="hintQuotationPolicyResource1" Text="">
                        </ui:UIHint>
                        <br />
                        <ui:UIPanel runat="server" ID="panelAwardVendor" meta:resourcekey="panelAwardResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldDropDownList runat="server" ID="dropVendorToAward" Caption="Select to Award to Vendor"
                                CaptionWidth="150px" OnSelectedIndexChanged="dropVendorToAward_SelectedIndexChanged"
                                meta:resourcekey="dropVendorToAwardResource1">
                            </ui:UIFieldDropDownList>
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
                                ImageUrl="~/images/add.gif" OnClick="buttonGeneratePOFromLineItems_Click" ConfirmText="Are you sure you wish to generate a Purchase Order from the selected line items?"
                                meta:resourcekey="buttonGeneratePOResource1" />
                            <ui:UIButton runat="server" ID="buttonGenerateLOAFromLineItems" Text="Generate LOA from Selected Line Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGenerateLOAFromLineItems_Click" ConfirmText="Are you sure you wish to generate a Purchase Order from the selected line items?" />
                            <ui:UIButton runat="server" ID="buttonGeneratePO" Text="Generate PO for all items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGeneratePO_Click" ConfirmText="Are you sure you wish to generate a Purchase Order?"
                                meta:resourcekey="buttonGeneratePOResource2" />
                            <ui:UIButton runat="server" ID="buttonGenerateLOA" Text="Generate LOA for all items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGenerateLOA_Click" ConfirmText="Are you sure you wish to generate a Letter of Award?" />
                            <ui:UIButton runat="server" ID="buttonGenerateGroupWJPO" Text="Generate PO for Group WJ"
                                Visible="false" meta:resourcekey="buttonGenerateGroupWJPOResource1" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" Caption="Justification" meta:resourcekey="sep1Resource1" />
                    </ui:UIPanel>
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
                            ShowFooter="True" PageSize="500" SortExpression="ItemNumber, StartDate, Budget.ObjectName, Account.Path"
                            BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridBudgetResource1"
                            RowErrorColor="" Style="clear: both;" ImageRowErrorUrl="" OnAction="gridBudget_Action">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource5" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddBudgets"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource6" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                    meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ItemNumber" HeaderText="Number" meta:resourcekey="UIGridViewBoundColumnResource21"
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
                            <web:subpanel runat="server" ID="subpanelBudget" GridViewID="gridBudget" OnPopulateForm="subpanelBudget_PopulateForm"
                                OnValidateAndUpdate="subpanelBudget_ValidateAndUpdate" OnRemoved="subpanelBudget_Removed" />
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
                        <br />
                        <br />
                        <ui:UIPanel runat="server" ID="panelReallocateFrom" meta:resourcekey="panelReallocateFromResource1" Visible="false">
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
                                BindObjectsToRows="true" Span="Full">
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
                                    <ui:UIGridViewTemplateColumn HeaderText="Total" ControlStyle-Width="80" ItemStyle-BackColor="#eeeeee"
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
                            Visible="false" BindObjectsToRows="true" Span="Full">
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
                            ShowFooter="True" PageSize="500" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridBudgetSummaryResource1"
                            RowErrorColor="" Style="clear: both;" ImageRowErrorUrl="">
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
                                <ui:UIFieldDropDownList runat="server" ID="dropAddBudgetItemNumber" Caption="Line Number"
                                    ValidateRequiredField="true" OnSelectedIndexChanged="dropAddBudgetItemNumber_SelectedIndexChanged">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropAddBudget" Caption="Budget" ValidateRequiredField="true"
                                    OnSelectedIndexChanged="dropAddBudget_SelectedIndexChanged">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropLocation" Caption="Location" ValidateRequiredField="true"
                                    OnSelectedIndexChanged="dropLocation_SelectedIndexChanged">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDateTime runat="server" ID="dateAddBudgetStartDate" Caption="Start Date"
                                    ValidateRequiredField="true" SelectMonthYear="true">
                                </ui:UIFieldDateTime>
                                <ui:UIFieldDateTime runat="server" ID="dateAddBudgetEndDate" Caption="End Date" ValidateRequiredField="true"
                                    SelectMonthYear="true">
                                </ui:UIFieldDateTime>
                                <ui:UIFieldTreeList runat='server' ID="treeAddBudgetAccounts" Caption="Account" ValidateRequiredField="true"
                                    OnAcquireTreePopulater="treeAddBudgetAccounts_AcquireTreePopulater">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldTextBox runat='server' ID="textAddBudgetAmount" Caption="Amount" ValidateRequiredField="true"
                                    ValidateDataTypeCheck="true" ValidationDataType="Currency" ValidateRangeField='true'
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="false" ValidationRangeType="Currency">
                                </ui:UIFieldTextBox>
                                <ui:UIFieldRadioList runat="server" ID="rdlTerm" Caption="Terms" ValidateRequiredField="true"
                                    RepeatColumns="4" RepeatDirection="Horizontal">
                                    <Items>
                                        <asp:ListItem Value="0" Selected="True">Monthly</asp:ListItem>
                                        <asp:ListItem Value="1">Quaterly</asp:ListItem>
                                        <asp:ListItem Value="2">Half-Yearly</asp:ListItem>
                                        <asp:ListItem Value="3">Yearly</asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <br />
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
                                </table>
                            </div>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Work Status History" BorderStyle="NotSet"
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
