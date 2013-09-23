<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data.Sql" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            WorkCost_ChargeOut.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost.Columns[7].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost.Columns[10].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost.Columns[11].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost.Columns[14].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost.Columns[15].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost.Columns[17].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost_ActualUnitCost.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost_EstimatedUnitCost.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;

        objectBase.ObjectNumberVisible = !work.IsNew;

        //dropCase.Bind(OCase.GetAccessibleOpenCases(AppSession.User, Security.Decrypt(Request["TYPE"]), work.CaseID), "Case", "ObjectID");
        //List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));

        //RequestorID.Bind(OUser.GetRequestorOrTenantsByPositions(positions, work.Location));
        if (!IsPostBack)
        {
            BindRequestForQuotation(work);
            BindCodes(work);
            BindActualClassification(work);
            BindContract(work);
            BindTenantContact(work);
            BindChargeType(work);
            //BindTaxCode(work);
            Location.PopulateTree();
            Equipment.PopulateTree();
            Checklist.PopulateTree();
        }

        //if (work.IsNew && Request["PARENTID"] != null)
        //{
        //    try { work.ParentID = Security.DecryptGuid(Request["PARENTID"]); }
        //    catch { }
        //}

        if (Request["TREEOBJID"] != null)
        {
            Guid id = Security.DecryptGuid(Request["TREEOBJID"]);

            OLocation location = TablesLogic.tLocation[id];
            if (location == null || location.IsPhysicalLocation == 0)
            {
                OEquipment equipment = TablesLogic.tEquipment[id];
                if (equipment != null && equipment.IsPhysicalEquipment == 1)
                {
                    work.Equipment = equipment;
                    work.Location = equipment.Location;
                }
            }
            else
                work.Location = location;
        }

        if (work.LocationID != null)
        {
            if (work.AssignmentMode == 1)
            {
                List<OTechnicianRosterItem> rosterItem = OTechnicianRosterItem.GetTechnicianRosterItems(work.LocationID, work.ScheduledStartDateTime.Value, (work.AssignmentMode - 1).ToString());
                ddl_TechnicianID.Bind(OTechnicianRosterItem.GetTechnicians(work, rosterItem));
            }
            else
                ddl_TechnicianID.Bind(OTechnicianRosterItem.GetTechnicians(work, null));
            ddl_SupervisorID.Bind(OUser.GetUsersByRoleAndAboveLocation(work.Supervisor, work.Location, "WORKSUPERVISOR"));
        }

        panelScheduledWork.Visible = work.ScheduledWorkID != null;
        buttonViewScheduledWork.Visible = AppSession.User.AllowViewAll("OScheduledWork");
        buttonEditScheduledWork.Visible = AppSession.User.AllowEditAll("OScheduledWork") || OActivity.CheckAssignment(AppSession.User, work.ScheduledWorkID);

        if (work.IsNew)
        {
            work.ScheduledStartDateTime = DateTime.Now;
            work.ScheduledEndDateTime = DateTime.Now.AddDays(1);
            work.NotifyWorkSupervisor = 1;
            work.NotifyWorkTechnician = 1;
        }
        panel.ObjectPanel.BindObjectToControls(work);

        LoadSignature(work);

    }

    protected void LoadSignature(OWork work)
    {
        String html = String.Empty;
        html += @"<TABLE id=table1>
                      <TR>
                        <TD noWrap>{0}</TD>
                        <TD noWrap>{1}</TD>
                      </TR>
                      <TR>
                        {2}
                        {3}
                      </TR>
                  </TABLE>
                        ";
        string usageLabelHtml = "";
        string acceptLabelHtml = "";
        string usageSignatureHtml = "";
        string acceptSignatureHtml = "";
        if (work.UsageSignature != null)
        {
            usageLabelHtml = (String)GetLocalResourceObject("LabelUsage");
            usageSignatureHtml = String.Format("<TD noWrap><SPAN id=UsageSignature><img src=\"../../components/Signature.aspx?ID={0}&Usage=\" border=\"1\" /></SPAN></TD>&nbsp;&nbsp;", HttpUtility.UrlEncode(Security.EncryptGuid(work.ObjectID.Value)), "true");
        }
        else
        {
            usageSignatureHtml = "<TD noWrap><SPAN/></TD>&nbsp;&nbsp;";
        }
        if (work.AcceptSignature != null)
        {
            acceptLabelHtml = (String)GetLocalResourceObject("LabelAccept");
            acceptSignatureHtml = String.Format("<TD noWrap><SPAN id=AcceptSignature><img src=\"../../components/Signature.aspx?ID={0}&Accept=\" border=\"1\" /></SPAN></TD>&nbsp;&nbsp;</TR></TABLE>", HttpUtility.UrlEncode(Security.EncryptGuid(work.ObjectID.Value)), "true");
        }
        else
        {
            acceptSignatureHtml = "<TD noWrap><SPAN id=AcceptSignature></SPAN></TD>";
        }

        SignatureList.Text = String.Format(html, usageLabelHtml, acceptLabelHtml, usageSignatureHtml, acceptSignatureHtml);
    }

    protected void panel_Validate(object sender, PersistentObject obj)
    {
        OWork work = obj as OWork;

        // Validate sufficient Store items
        //
        if (!work.ValidateSufficientStoreItems())
        {
            string list = "";

            foreach (OWorkCost item in work.WorkCost)
                if (item.CostType == WorkCostType.Material && item.Store != null && item.Catalogue != null && item.StoreBin != null && !item.Valid)
                    list += (list == "" ? "" : Resources.Messages.General_CommaSeparator) + item.Catalogue.ObjectName +
                    " (" + item.Store.ObjectName + Resources.Messages.General_CommaSeparator + item.StoreBin.ObjectName + ")";
            WorkCost.ErrorMessage = String.Format(Resources.Errors.Work_InsufficientStoreItems, list);
        }

        if (objectBase.CurrentObjectState.Is("PendingExecution", "PendingContractor", "PendingMaterial", "PendingOthers", "PendingClosure"))
        {
            string bins = work.ValidateStoreBinsNotLocked();
            if (bins != "")
                WorkCost.ErrorMessage = String.Format(Resources.Errors.Work_StoreBinsLocked, bins);
        }

        //if (!objectBase.CurrentObjectState.Is("Close", "Cancelled") &&
        //    !OCase.ValidateCaseNotClosedOrCancelled(work.CaseID))
        //{
        //    dropCase.ErrorMessage = Resources.Errors.Case_CannotBeClosedOrCancelled;
        //}

        if (objectBase.SelectedAction == "SubmitForApproval" ||
            objectBase.SelectedAction == "SubmitForExecution")
        {
            if (!work.ValidateAllStoreBinsSpecified())
                ((UIGridView)Page.FindControl("WorkCost")).ErrorMessage = Resources.Errors.Work_StoreBinsNotSpecified;

            if (!work.ValidateAllTechniciansSpecified())
                ((UIGridView)Page.FindControl("WorkCost")).ErrorMessage = Resources.Errors.Work_TechnicianNotSpecified;
        }

        if (objectBase.SelectedAction == "SubmitForExecution")
        {
            bool exist = false;
            WorkCost.ErrorMessage = "";
            foreach (OWorkCost workcost in work.WorkCost)
            {
                if (workcost.Technician != null)
                    exist = true;
            }
            if (!exist)
                WorkCost.ErrorMessage = "Please select at least one technician.";

        }
    }

    /// <summary>
    /// Validates and saves the work into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {

        using (Connection c = new Connection())
        {
            OWork work = panel.SessionObject as OWork;
            panel.ObjectPanel.BindControlsToObject(work);

            panel_Validate(sender, work);

            work = SaveCheckList(work);

            if (!panel.ObjectPanel.IsValid)
                return;            
            
            // Save the work
            //
            work.Save();

            /////////////////////////////////////////////////////////////////
            //This is a temporally solution, NEED TO BE MOVED TO LOGICLAYER//
            /////////////////////////////////////////////////////////////////
            clearWorkCostReservation();
            
            c.Commit();

        }
    }
    
    /////////////////////////////////////////////////////////////////
    //This is a temporally solution, NEED TO BE MOVED TO LOGICLAYER//
    /////////////////////////////////////////////////////////////////
    private void clearWorkCostReservation()
    {
        try
        {
            List<OStoreBinReservation> listReservations = TablesLogic.tStoreBinReservation.LoadList(TablesLogic.tStoreBinReservation.WorkCostID != null &
                TablesLogic.tStoreBinReservation.WorkCost.WorkID == null);
            foreach (OStoreBinReservation sbr in listReservations)
            {
                sbr.Deactivate();
                sbr.Save();
            }
        }
        catch(Exception ex)
        {
            panel.Message = ex.Message + "<br>" + ex.StackTrace;
        }
    }

    protected void BindRequestForQuotation(OWork work)
    {
        gridWorkJustifications.DataSource = work.NonCancelledRequestForQuotations;
        gridWorkJustifications.DataBind();
    }

    /// <summary>
    /// Binds data to the drop down lists.
    /// </summary>
    /// <param name="work"></param>
    protected void BindCodes(OWork work)
    {
        if (work.TypeOfWorkID == null)
            work.TypeOfServiceID = null;

        if (work.TypeOfServiceID == null)
            work.TypeOfProblemID = null;

        if (work.TypeOfProblemID == null)
            work.CauseOfProblemID = null;

        if (work.CauseOfProblemID == null)
            work.ResolutionID = null;

        TypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), work.TypeOfWorkID));

        TypeOfServiceID.Items.Clear();
        if (work.TypeOfWorkID != null)
            TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), work.TypeOfServiceID));

        TypeOfProblemID.Items.Clear();
        if (work.TypeOfServiceID != null)
            TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", work.TypeOfServiceID, work.TypeOfProblemID));

        CauseOfProblemID.Items.Clear();
        if (work.TypeOfProblemID != null)
            CauseOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("CauseOfProblem", work.TypeOfProblemID, work.CauseOfProblemID));

        ResolutionID.Items.Clear();
        if (work.CauseOfProblemID != null)
            ResolutionID.Bind(OCode.GetCodesByTypeAndParentID("Resolution", work.CauseOfProblemID, work.ResolutionID));

    }

    /// <summary>
    /// Binds data to the drop down lists.
    /// </summary>
    /// <param name="work"></param>
    protected void BindActualClassification(OWork work)
    {
        if (work.ActualTypeOfWorkID == null)
            work.ActualTypeOfServiceID = null;

        if (work.ActualTypeOfServiceID == null)
            work.ActualTypeOfProblemID = null;

        ActualTypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), work.ActualTypeOfWorkID));

        // 2011.08.01, Kien Trung
        // FIX: Default actual type of work,
        // type of service, type of problem.
        //
        ActualTypeOfServiceID.Items.Clear();
        if (work.TypeOfWorkID != null)
            ActualTypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), work.TypeOfServiceID));

        ActualTypeOfProblemID.Items.Clear();
        if (work.TypeOfServiceID != null)
            ActualTypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", work.TypeOfServiceID, work.TypeOfProblemID));

        if (work.WorkClassification == null)
            work.WorkClassification = (int)EnumWorkClassification.Minor;

        if (work.ActualTypeOfWorkID == null)
            work.ActualTypeOfWorkID = work.TypeOfWorkID;

        if (work.ActualTypeOfServiceID == null)
            work.ActualTypeOfServiceID = work.TypeOfServiceID;

        if (work.ActualTypeOfProblemID == null)
            work.ActualTypeOfProblemID = work.TypeOfProblemID;
    }

    protected void BindChargeType(OWork work)
    {
        dropChargeType.Bind(OChargeType.GetChargeTypesByInstanceID(work.LocationID != null ? work.Location.AMOSInstanceID : null), "ObjectName", "ObjectID");
        if (work != null && work.ChargeTypeID == null)
            dropChargeType.SelectedValue = OApplicationSetting.Current.DefaultAMOSWorkChargeTypeID.ToString();

    }

    protected void BindTenantContact(OWork work)
    {

        if (work.RequestorID != null)
            dropTenantContact.Bind(work.Requestor.TenantContacts);
        else
            dropTenantContact.Items.Clear();
        panelTenantDetails.Visible = (work.IsNew);
    }

    /// <summary>
    /// Binds data to the contract drop down list.
    /// </summary>
    /// <param name="work"></param>
    protected void BindContract(OWork work)
    {
        ContractID.Bind(OContract.GetContractsByWork(work));
    }

    /// <summary>
    /// Binds data to the store drop down list.
    /// </summary>
    /// <param name="work"></param>
    protected void BindStore(OWork work)
    {
        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
        WorkCost_StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, "OWork", workCost.StoreID));
        if (WorkCost_StoreID.Items.Count == 2)
            workCost.StoreID = new Guid(WorkCost_StoreID.Items[1].Value);
    }

    /// <summary>
    /// Binds data to the craft and user drop down lists.
    /// </summary>
    /// <param name="work"></param>
    protected void BindTechnician(OWork work)
    {
        WorkCost_CraftID.Bind(OCraft.GetAllCraft());
        // WorkCost_CraftID.Bind(OCraft.GetCraftByLocation(work.Location));
        WorkCost_UserID.Items.Clear();
    }

    /// <summary>
    /// Binds data to the tax code drop down list.
    /// </summary>
    /// <param name="work"></param>
    //protected void BindTaxCode(OWork work)
    //{
    //    dropTaxCode.Bind(OTaxCode.GetAllTaxCodes());
    //    //dropTaxCode.Items.Clear();
    //}
    /// <summary>
    /// Sets value for the estimated unit cost text box.
    /// </summary>
    /// <param name="work"></param>
    /// <param name="workCost"></param>
    protected void UpdateTechRate(OWork work, OWorkCost workCost)
    {
        if (workCost.Craft != null)
        {
            if (workCost.EstimatedOvertime == 0)
                WorkCost_EstimatedUnitCost.Text = workCost.Craft.NormalHourlyRate.Value.ToString("#,##0.00");
            else if (workCost.EstimatedOvertime == 1)
                WorkCost_EstimatedUnitCost.Text = workCost.Craft.OvertimeHourlyRate.Value.ToString("#,##0.00");

            if (workCost.ActualOvertime == 0)
                WorkCost_ActualUnitCost.Text = workCost.Craft.NormalHourlyRate.Value.ToString("#,##0.00");
            else if (workCost.ActualOvertime == 1)
                WorkCost_ActualUnitCost.Text = workCost.Craft.OvertimeHourlyRate.Value.ToString("#,##0.00");
        }
        else
        {
            WorkCost_EstimatedUnitCost.Text = "0.00";
            WorkCost_ActualUnitCost.Text = "0.00";
        }
    }

    /// <summary>
    /// Constructs and returns the location tree
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Location_AcquireTreePopulater(object sender)
    {
        OWork work = panel.SessionObject as OWork;
        return new LocationEquipmentTreePopulaterForCapitaland(work.LocationID, false, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user select a location in the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        panel.ObjectPanel.BindControlsToObject(work);

        work.EquipmentID = null;
        if (Location.SelectedNode != null)
        {
            if (Location.SelectedNode.Parent != null)
            {
                if (Location.SelectedNode.Parent.Value.StartsWith(">"))
                {
                    work.LocationID = new Guid(Location.SelectedNode.Parent.Parent.Value);
                    work.EquipmentID = new Guid(Location.SelectedNode.Value.Replace(">", ""));
                }
            }
        }
        if (work.EquipmentID != null)
            Equipment.PopulateTree();

        BindContract(work);

        work.DeleteAllPointReading();
        if (work.LocationID != null)
        {
            pre_selectAssignmentMode(work);
            //ddl_TechnicianID.Bind(OUser.GetUsersByRoleAndAboveLocation(work.Location, "WORKTECHNICIAN"));
            ddl_SupervisorID.Bind(OUser.GetUsersByRoleAndAboveLocation(work.Supervisor, work.Location, "WORKSUPERVISOR"));
            //OTenantLease lease = TablesLogic.tTenantLease.Load(TablesLogic.tTenantLease.LocationID == work.LocationID);
            if (work.Location.TenantLeases.Count > 0)
            {
                work.Location.TenantLeases.Sort("LeaseEndDate", false);
                work.TenantLeaseID = work.Location.TenantLeases[0].ObjectID;
                work.RequestorID = work.Location.TenantLeases[0].TenantID;
                BindTenantContact(work);
            }

        }
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Constructs and returns the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Equipment_AcquireTreePopulater(object sender)
    {
        OWork work = panel.SessionObject as OWork;
        return new EquipmentTreePopulater(work.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user selects an equipment in the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Equipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        if (work.Equipment != null)
        {
            work.Location = work.Equipment.Location;
        }

        Location.PopulateTree();
        BindContract(work);
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Constructs and returns the check list tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Checklist_AcquireTreePopulater(object sender)
    {
        OWork work = panel.SessionObject as OWork;
        return new ChecklistTreePopulater(work.ChecklistID, false, true, ChecklistType.Work);
    }

    /// <summary>
    /// Occurs when user selects a check list in the check list tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Checklist_SelectedNodeChanged(object sender, EventArgs e)
    {
        // update the checklist
        //
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);
        work.UpdateChecklist();
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Opens the add multiple catalog page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddMaterials_Click(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);
        panel.FocusWindow = false;
        Window.Open("addcatalog.aspx");
    }

    /// <summary>
    /// Occurs when the user adds selected items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;

        panelWorkCost.BindObjectToControls(work);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="work"></param>
    private void HideAndShowWorkCostTabControls(OWork work)
    {

        WorkCost_Panel1.Visible = WorkCost_CostType.SelectedValue == WorkCostType.Technician.ToString();
        WorkCost_Panel3.Visible = WorkCost_CostType.SelectedValue == WorkCostType.AdhocRate.ToString();
        WorkCost_Panel5.Visible = WorkCost_CostType.SelectedValue == WorkCostType.FixedRate.ToString();
        WorkCost_Panel4.Visible = WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString();
        WorkCost_Panel4_1.Visible = WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString();
        //TaxCode_Panel.Visible = WorkCost_CostType.SelectedValue == WorkCostType.TaxCode.ToString();
        //panelEstimatedCost.Visible = panelActualCost.Visible = !TaxCode_Panel.Visible;
        //panelEstimatedCost.Visible = panelActualCost.Visible;
        WorkCost_PanelUOM.Visible = WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString() || WorkCost_CostType.SelectedValue == WorkCostType.AdhocRate.ToString();

        WorkCost_EstimatedUnitCost.Enabled = (WorkCost_CostType.SelectedValue == WorkCostType.AdhocRate.ToString() || WorkCost_CostType.SelectedValue == WorkCostType.FixedRate.ToString());
        WorkCost_ActualUnitCost.Enabled = WorkCost_CostType.SelectedValue == WorkCostType.AdhocRate.ToString();
        WorkCost_EstimatedCostFactor.Enabled = (WorkCost_CostType.SelectedValue != WorkCostType.Technician.ToString() && WorkCost_CostType.SelectedValue != WorkCostType.Material.ToString());
        WorkCost_ActualCostFactor.Enabled = (WorkCost_CostType.SelectedValue != WorkCostType.Technician.ToString() && WorkCost_CostType.SelectedValue != WorkCostType.Material.ToString());
        WorkCost_EstimatedOvertime.Visible = WorkCost_CostType.SelectedValue == WorkCostType.Technician.ToString();
        WorkCost_ActualOvertime.Visible = WorkCost_CostType.SelectedValue == WorkCostType.Technician.ToString();

        WorkCost.Visible = (work.Location != null || work.Equipment != null) && work.TypeOfServiceID != null;
    }

    private void HideAndShowResolutionTabControls(OWork work)
    {
        panelEquipmentDown.Visible = work.EquipmentID != null;
        panelEquipmentDownDateTime.Visible = work.IsEquipmentDown == 1;

        panelTechnician.Visible = (work.Location != null || work.Equipment != null) && work.TypeOfServiceID != null && objectBase.CurrentObjectState.Is("Start", "Draft", "PendingAssignment");
        ddl_TechnicianID.Visible = work.AssignmentMode == null || rdl_AssignmentMode.SelectedValue == "0" || rdl_AssignmentMode.SelectedValue == "1";
        panelAddSpares.Visible = WorkCost.Visible && work.EquipmentID != null;
        panelAddMultiple.Visible = WorkCost.Visible;

    }

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OWork work = panel.SessionObject as OWork;

        if (work == null)
            return;

        //panel.ObjectPanel.BindControlsToObject(work);
        HideAndShowResolutionTabControls(work);

        HideAndShowWorkCostTabControls(work);

        // What the fish is this???
        //
        ActualStartDateTime.ValidateCompareField = ActualEndDateTime.Visible == false;

        Location.Enabled = (work.IsNew);
        Equipment.Enabled = work.WorkCost.Count == 0 || work.AssignmentMode != 0;
        TypeOfWorkID.Enabled = work.WorkCost.Count == 0 || work.AssignmentMode != 0;
        TypeOfServiceID.Enabled = work.WorkCost.Count == 0 || work.AssignmentMode != 0;

        //2011-11-15 ptb,
        WorkCost_ChargeOut.Visible = IsChargedToCaller.SelectedIndex == 0;
        DisplayOrder.Visible = true;
        WorkCost.Grid.Columns[16].Visible = IsChargedToCaller.SelectedIndex == 0;

        Workflow_Setting(work);

        // 2011.07.08, Kien Trung
        // Commented out to enable supervisor dropdown
        // and notify checkbox
        //ddl_SupervisorID.Enabled = (objectBase.SelectedAction == "SubmitForAssignment");
        //NotifyWorkSupervisor.Enabled = (objectBase.SelectedAction == "SubmitForAssignment");
        //NotifyWorkTechnician.Enabled = (objectBase.SelectedAction == "SubmitForExecution");

        RequestorName.ValidateRequiredField =
            //dropTenantContact.ValidateRequiredField =
            panelBilling.Visible = (IsChargedToCaller.SelectedValue == ((int)EnumApplicationGeneral.Yes).ToString());

        searchTenantLease.ButtonClear.Visible = (work.RequestorID != null);
        if (work.RequestorID != null)
            searchTenantLease.ButtonSelectText = "Select Another Tenant Lease";
        else
            searchTenantLease.ButtonSelectText = "Select A Tenant Lease";

        // 2011.07.08, Kien Trung
        // Visible to drop TenantContact
        // if there is tenant Lease selected
        // Commented out
        //dropTenantContact.Visible = (work.TenantLeaseID != null);

        HideAndShowStoreCheckOutPanel(work);
        if (WorkCost.Rows.Count > 0)
            ((CheckBox)WorkCost.HeaderRow.Cells[0].Controls[0]).Style["display"] = "none";

    }

    private void HideAndShowStoreCheckOutPanel(OWork work)
    {
        foreach (OWorkCost wc in work.WorkCost)
        {

        }
    }

    private void Workflow_Setting(OWork work)
    {
        string state = objectBase.CurrentObjectState;
        string stateAction = objectBase.CurrentObjectState + ":" + objectBase.SelectedAction;
        string action = objectBase.SelectedAction;

        tabContract.Enabled = state.Is("Start", "Draft");
        tabCost.Enabled = state.Is("Start", "Draft", "PendingAssignment", "PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure");

        tabChecklist.Enabled = state.Is("Start", "Draft", "PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure", "PendingAssignment");
        tabResolution.Visible = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure", "Close");

        panelScheduledStart.Visible = stateAction != "Start:SubmitForPlanning";
        panelResolution.Visible = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure", "Close");
        panelResolution.Enabled = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure");

        panelEstimatedCost.Enabled = state.Is("Start", "Draft", "PendingAssignment") || WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString();
        panelActualCost.Visible = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure", "Close") && WorkCost_CostType.SelectedValue != WorkCostType.Material.ToString();

        ActualStartDateTime.ValidateRequiredField = state.Is("PendingClosure") || action.Is("SubmitForClosure");
        ActualEndDateTime.ValidateRequiredField = state.Is("PendingClosure") || action.Is("SubmitForClosure");

        panelWorkDetails.Visible = true;
        panelWorkDetails.Enabled = panelCaseDetails.Enabled = !state.Is("Close");

        Notify_Panel.Enabled = !state.Is("PendingClosure", "Close");

        panelWorkDescription.Enabled = panelWorkClassification.Enabled = panelScheduledWork.Enabled = panelScheduledStart.Enabled = state.Is("Start", "Draft");
        panelAckArrTime.Visible = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure", "Close");
        panelAckArrTime.Enabled = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure");
        ActualEndDateTime.Visible = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure", "Close");

        panelButtonGenerateWJ.Enabled = panelGridWorkJustification.Enabled = state.Is("PendingExecution", "PendingMaterial", "PendingContractor", "PendingClosure");

        //if (action.Is("Cancel", "Close"))

        // 2011.09.29, Kien Trung
        // Hide button Submit For Assignment workflow button.
        // (RCS requested, can patch for CCT also)
        //
        ListItem btnSubmitForAssignment = objectBase.GetWorkflowRadioListItem("SubmitForAssignment");
        if (btnSubmitForAssignment != null)
            btnSubmitForAssignment.Enabled = false;
        ListItem btnSubmitForExecution = objectBase.GetWorkflowRadioListItem("SubmitForExecution");

        PanelActualWorkClassificatioin.Enabled = !state.Is("Close");
        ddl_SupervisorID.ValidateRequiredField = (objectBase.SelectedAction == "SubmitForAssignment");

        //WorkCost.Commands[2].Visible = !state.Is("Start", "Draft", "Close");
        //WorkCost.Commands[2].Visible = false;
    }
    /// <summary>
    /// Occurs when user mades selection in the craft drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_CraftID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        OWorkCost workCost = (OWorkCost)WorkCost_SubPanel.SessionObject;
        WorkCost_ObjectPanel.BindControlsToObject(workCost);
        WorkCost_UserID.Bind(OUser.GetUsersByPositionsAndCraft(
            OPosition.GetPositionsByTypeOfServiceLocationAndRole(work.TypeOfService, work.Location, "WORKTECHNICIAN"), workCost.Craft, workCost.UserID));
        UpdateTechRate(work, workCost);
    }

    /// <summary>
    /// Occurs when user clicks on the over time radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_IsOvertime_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        OWorkCost workCost = (OWorkCost)WorkCost_SubPanel.SessionObject;

        WorkCost_ObjectPanel.BindControlsToObject(workCost);
        UpdateTechRate(work, workCost);

        if (workCost.EstimatedOvertime == 0)
            workCost.ChargeOut = workCost.Technician != null ? (workCost.Technician.Craft != null ? workCost.Technician.Craft.DefaultChargeOut : 0) : 0;
        else
            workCost.ChargeOut = workCost.Technician != null ? (workCost.Technician.Craft != null ? workCost.Technician.Craft.DefaultOTChargeOut : 0) : 0;

        WorkCost_ObjectPanel.BindObjectToControls(workCost);

    }

    /// <summary>
    /// Populates the work cost sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;

        BindStore(work);

        WorkCost_CostType.Enabled = WorkCost_SubPanel.IsAddingObject;

        //WorkCost_CatalogueID.Enabled = workCost.IsNew;
        WorkCost_CatalogueDialog.Enabled = (workCost.IsNew && workCost.CostType == WorkCostType.Material);
        WorkCost_UnitOfMeasureID.Enabled = (workCost.IsNew || workCost.CostType == WorkCostType.AdhocRate) && workCost.CostType == WorkCostType.Material;
        WorkCost_StoreID.Enabled = workCost.IsNew && workCost.CostType == WorkCostType.Material;
        WorkCost_StoreBinID.Enabled = workCost.IsNew && workCost.CostType == WorkCostType.Material;
        WorkCost_StoreBinID.Items.Clear();

        // if work is chargeable to tenant. Default work cost is fixed rate.
        // else if (CostType is null) do select others as default.
        //
        if (work.IsChargedToCaller == 1 && workCost.CostType == null)
            workCost.CostType = WorkCostType.FixedRate;
        else if (workCost.CostType == null)
            workCost.CostType = WorkCostType.AdhocRate;

        //FixedRateID.PopulateTree();
        //WorkCost_treeCatalogue.PopulateTree();

        BindCostTypeParameters(work, workCost);

        //2011-11-15 ptb, for displayorder
        DisplayOrder.Items.Clear();
        for (int i = 0; i < work.WorkCost.Count + 1; i++)
            DisplayOrder.Items.Add(new ListItem((i + 1).ToString(), (i + 1).ToString()));

        if (workCost.DisplayOrder == null)
            workCost.DisplayOrder = DisplayOrder.Items.Count;

        //2011-12-06 ptb, hide edit button once checked out.
        WorkCost_EstimatedQuantity.Enabled = workCost.IsCheckOut != 1;
        //Guid id = (Guid)gridChecklist.DataKeys[e.Row.RowIndex][0];
        //OWork work = (OWork)panel.SessionObject;
        //OWorkChecklistItem item = (OWorkChecklistItem)work.WorkChecklistItems.FindObject(id);

        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(workCost);
    }

    /// <summary>
    /// Binds data to the drop down lists.
    /// </summary>
    /// <param name="work"></param>
    /// <param name="workCost"></param>
    protected void BindCostTypeParameters(OWork work, OWorkCost workCost)
    {
        if (workCost.CostType == WorkCostType.Technician)
        {
            WorkCost_CraftID.Bind(OCraft.GetAllCraft());
            //WorkCost_CraftID.Bind(OCraft.GetCraftByLocation(work.Location));
            WorkCost_UserID.Bind(OUser.GetUsersByPositionsAndCraft(
                OPosition.GetPositionsByTypeOfServiceLocationAndRole(
                work.TypeOfService, work.Location, "WORKTECHNICIAN"), workCost.Craft, workCost.UserID));
        }
        else if (workCost.CostType == WorkCostType.FixedRate)
        {
        }
        else if (workCost.CostType == WorkCostType.AdhocRate)
        {
            WorkCost_UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        }
        else if (workCost.CostType == WorkCostType.Material)
        {
            if (workCost.CatalogueID != null)
                WorkCost_UnitOfMeasureID.Bind(OUnitConversion.GetConversions((Guid)workCost.Catalogue.UnitOfMeasureID, workCost.UnitOfMeasureID), "ObjectName", "ToUnitOfMeasureID", false);
            else
                WorkCost_UnitOfMeasureID.Items.Clear();

            if (workCost.StoreID != null && workCost.CatalogueID != null)
                WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)workCost.StoreID, (Guid)workCost.CatalogueID, false, workCost.StoreBinID), "ObjectName", "ObjectID", true);
        }
    }

    /// <summary>
    /// Validates and updates
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        OWorkCost workCost = (OWorkCost)WorkCost_SubPanel.SessionObject;
        WorkCost_ObjectPanel.BindControlsToObject(workCost);

        // Validate
        //
        if (work.IsDuplicateWorkCost(workCost))
        {
            if (workCost.CostType == WorkCostType.Technician)
                WorkCost_UserID.ErrorMessage = Resources.Errors.Work_DuplicateTechnician;
            else if (workCost.CostType == WorkCostType.AdhocRate)
                this.WorkCost_Name.ErrorMessage = Resources.Errors.Work_DuplicateAdhocRate;
            else if (workCost.CostType == WorkCostType.Material)
            {
                //this.WorkCost_CatalogueID.ErrorMessage = Resources.Errors.Work_DuplicateMaterial;
                //2011 12 09 ptb
                //Allow the technician to input duplicate workcost
                //this.WorkCost_CatalogueDialog.ErrorMessage = Resources.Errors.Work_DuplicateMaterial;
                //this.WorkCost_StoreID.ErrorMessage = Resources.Errors.Work_DuplicateMaterial;
                //this.WorkCost_StoreBinID.ErrorMessage = Resources.Errors.Work_DuplicateMaterial;
            }
        }

        // Validates quantity if its a Whole Number according to Catalog Type
        //if (WorkCost_CatalogueID.SelectedValue != "")
        if (this.WorkCost_CatalogueDialog.SelectedValue != "")
        {
            //OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(WorkCost_CatalogueID.SelectedValue));
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(WorkCost_CatalogueDialog.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(WorkCost_EstimatedQuantity.Text) != 0)
            {
                WorkCost_EstimatedQuantity.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }

            //2011 12 21 ptb
            //Check inventory balance
            if (cat != null)
            {
                OStoreBin sbin = TablesLogic.tStoreBin.Load(new Guid(WorkCost_StoreBinID.SelectedValue.ToString()));
                if (sbin.GetTotalPhysicalQuantity((Guid)cat.ObjectID) < Convert.ToDecimal(WorkCost_EstimatedQuantity.Text))
                {
                    WorkCost_EstimatedQuantity.ErrorMessage = String.Format(Resources.Errors.Work_InsufficientStoreItems, "");
                    return;
                }
            }
        }

        // Validate sufficient Store items
        // check the store's bin's available quantity = (physical - reserved)
        //        

        if (workCost.CostType == WorkCostType.Material)
        {
            decimal availableQuantity = workCost.StoreBin.GetTotalAvailableQuantity((Guid)workCost.CatalogueID);
            if (workCost.EstimatedQuantity > availableQuantity)
            {
                WorkCost_EstimatedQuantity.ErrorMessage = String.Format(Resources.Errors.Work_InsufficientStoreItems, "");
                return;
            }

            if (workCost.EstimatedQuantity == 0)
            {
                WorkCost_EstimatedQuantity.ErrorMessage = Resources.Errors.Work_InvalidQuantity;
                return;
            }
        }

        if (!WorkCost_SubPanel.ObjectPanel.IsValid)
            return;

        // Update
        //
        if (workCost.CostType == WorkCostType.Technician)
        {
            workCost.ObjectName = workCost.Technician != null ? workCost.Technician.ObjectName : "";
            workCost.CostDescription = workCost.Technician != null ? workCost.Technician.ObjectName : "";
            workCost.StoreID = null;
            workCost.StoreBinID = null;
            workCost.CatalogueID = null;
            workCost.EstimatedCostFactor = 1.0m;

            if (workCost.EstimatedOvertime == 0)
                workCost.ChargeOut = workCost.Technician != null ? (workCost.Technician.Craft != null ? workCost.Technician.Craft.DefaultChargeOut : 0) : 0;
            else
                workCost.ChargeOut = workCost.Technician != null ? (workCost.Technician.Craft != null ? workCost.Technician.Craft.DefaultOTChargeOut : 0) : 0;
        }

        if (workCost.CostType == WorkCostType.AdhocRate)
        {
            workCost.CostDescription = workCost.ObjectName;
            workCost.StoreID = null;
            workCost.StoreBinID = null;
            workCost.CatalogueID = null;
        }

        if (workCost.CostType == WorkCostType.Material)
        {
            workCost.ObjectName = workCost.Catalogue != null ? workCost.Catalogue.ObjectName : "";
            workCost.CostDescription = workCost.Catalogue != null ? workCost.Catalogue.ObjectName : "";
            workCost.ChargeOut = workCost.Catalogue != null ? workCost.Catalogue.DefaultChargeOut : 0;
        }

        if (workCost.CostType == WorkCostType.FixedRate)
        {
            workCost.ObjectName = workCost.FixedRate != null ? workCost.FixedRate.ObjectName : "";
            workCost.CostDescription = workCost.FixedRate != null ? workCost.FixedRate.ObjectName : "";
            workCost.UnitOfMeasure = workCost.FixedRate.UnitOfMeasure != null ? workCost.FixedRate.UnitOfMeasure : null;
            workCost.ChargeOut = workCost.FixedRate != null ? workCost.FixedRate.DefaultChargeOut : 0;
        }

        //2011-11-15 ptb, for taxcode

        if (workCost.ActualUnitCost == null)
            workCost.ActualUnitCost = workCost.EstimatedUnitCost;
        if (workCost.ActualCostFactor == null)
            workCost.ActualCostFactor = workCost.EstimatedCostFactor;

        workCost.RecomputeEstimatedAndActualTotal();

        // 2011.08.07, Kien Trung
        // Commented out for not check charge out amount.
        //
        /*
        if (workCost.ChargeOut > 0)
        {
            Decimal? subTotal;
            if (workCost.ActualSubTotal != null)
                subTotal = workCost.ActualSubTotal;
            else
                subTotal = workCost.EstimatedSubTotal;

            if (subTotal >= workCost.ChargeOut)
            {
                WorkCost_ChargeOut.ErrorMessage = "Charge Out is less than the sub-total.";
            }
            else
                work.WorkCost.Add(workCost);
        }
        else*/
        work.WorkCost.Add(workCost);

        LogicLayer.Global.ReorderItems(work.WorkCost, null, "DisplayOrder");

        panelWorkCost.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user clicks on the delete button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_SubPanel_Removed(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        OWorkCost workCost = (OWorkCost)WorkCost_SubPanel.SessionObject;
        WorkCost_ObjectPanel.BindControlsToObject(workCost);
        LogicLayer.Global.ReorderItems(work.WorkCost, null, "DisplayOrder");
        panelWorkCost.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user clicks on the cost type radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CostType_SelectedIndexChanged(object sender, EventArgs e)
    {
        WorkCost_ChargeOut.Text = "";
        if (WorkCost_CostType.SelectedValue == WorkCostType.Technician.ToString())
        {
            WorkCost_EstimatedCostFactor.Text = "1.0";
            WorkCost_ActualCostFactor.Text = "1.0";
        }
        else if (WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString())
        {
            WorkCost_EstimatedCostFactor.Text = "1.0";
            WorkCost_ActualCostFactor.Text = "1.0";
        }
        else if (WorkCost_CostType.SelectedValue == WorkCostType.FixedRate.ToString())
        {
            WorkCost_EstimatedCostFactor.Text = "1.0";
            WorkCost_ActualCostFactor.Text = "1.0";
        }

        WorkCost_CatalogueDialog.Enabled = (WorkCost_SubPanel.IsAddingObject && WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString());
        WorkCost_UnitOfMeasureID.Enabled = (WorkCost_SubPanel.IsAddingObject || WorkCost_CostType.SelectedValue == WorkCostType.AdhocRate.ToString()) && WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString();
        WorkCost_StoreID.Enabled = WorkCost_SubPanel.IsAddingObject && WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString();
        WorkCost_StoreBinID.Enabled = WorkCost_SubPanel.IsAddingObject && WorkCost_CostType.SelectedValue == WorkCostType.Material.ToString();
        WorkCost_StoreBinID.Items.Clear();

        OWork work = (OWork)panel.SessionObject;
        OWorkCost workCost = (OWorkCost)this.WorkCost_SubPanel.SessionObject;
        WorkCost_ObjectPanel.BindControlsToObject(workCost);
        BindCostTypeParameters(work, workCost);
    }

    /// <summary>
    /// Occurs when a data row is bound to data.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridChecklist_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid id = (Guid)gridChecklist.DataKeys[e.Row.RowIndex][0];
            OWork work = (OWork)panel.SessionObject;
            OWorkChecklistItem item = (OWorkChecklistItem)work.WorkChecklistItems.FindObject(id);

            if (item != null)
            {
                if (item.ChecklistType == ChecklistItemType.Choice)
                {
                    UIFieldRadioList r = (UIFieldRadioList)e.Row.FindControl("ChecklistItem_SelectedResponseID");
                    if (r != null)
                    {
                        r.Visible = true;
                        if (item.ChecklistResponseSet != null)
                        {
                            r.Bind(item.ChecklistResponseSet.ChecklistResponses.Order(
                                TablesLogic.tChecklistResponse.DisplayOrder.Asc));

                            foreach (ListItem LI in r.Items)
                            {
                                if (new Guid(LI.Value) == item.SelectedResponseID)
                                {
                                    LI.Selected = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                if (item.ChecklistType == ChecklistItemType.Remarks)
                {
                    UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("ChecklistItem_Description");
                    if (t != null)
                    {
                        t.Visible = true;
                    }
                }
            }
        }
    }

    protected OWork SaveCheckList(OWork work)
    {
        try
        {
            //OWork work = panel.SessionObject as OWork;
            //panel.ObjectPanel.BindControlsToObject(work);

            //work.WorkChecklistItems.Clear();
            DataList<OWorkChecklistItem> itemList = work.WorkChecklistItems;
            foreach (GridViewRow row in gridChecklist.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    Guid id = (Guid)(gridChecklist.DataKeys[row.DataItemIndex][0]);
                    //OWorkChecklistItem item = TablesLogic.tWorkChecklistItem.Load(id);

                    OWorkChecklistItem item = (OWorkChecklistItem)itemList.FindObject(id);

                    if (item == null)
                        throw new Exception("Survey checklist item not found!");

                    if (item.ChecklistType == ChecklistItemType.Choice)
                    {
                        UIFieldRadioList rl = (UIFieldRadioList)row.FindControl("ChecklistItem_SelectedResponseID");
                        if (rl != null)
                        {
                            foreach (ListItem LI in rl.Items)
                            {
                                if (LI.Selected == true)
                                    item.SelectedResponseID = new Guid(LI.Value);
                            }
                        }
                    }
                    else if (item.ChecklistType == ChecklistItemType.Remarks)
                    {
                        UIFieldTextBox t = (UIFieldTextBox)row.FindControl("ChecklistItem_Description");
                        if (t != null)
                        {
                            item.Description = t.Text;
                        }
                    }

                    work.WorkChecklistItems.Add(item);
                }
            }
            return work;
        }
        catch (Exception ex)
        {
            gridChecklist.ErrorMessage = ex.Message + "<br>" + ex.StackTrace;
            return null;
        }
    }

    /// <summary>
    /// Occurs when user clicks on the apply check list button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonApplyChecklist_Click(object sender, EventArgs e)
    {
        // remove checklist and apply to this work order.
        //

    }

    /// <summary>
    /// Occurs when user clicks on the add spares button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddSpares_Click(object sender, EventArgs e)
    {
        panel.FocusWindow = false;
        Session["Work"] = panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(panel.SessionObject);

        bool oldVisible = WorkCost_ObjectPanel.Visible;
        WorkCost_ObjectPanel.Visible = true;

        if (((OWork)panel.SessionObject).EquipmentID != null)
            Window.Open("../../popup/selecteqptspares/main.aspx?ID=" +
                HttpUtility.UrlEncode(Security.EncryptGuid(((OWork)panel.SessionObject).EquipmentID.Value)) +
                "&MODE=" + HttpUtility.UrlEncode(Security.Encrypt(panelActualCost.Visible ? "1" : "0")),
                "AnacleEAM_Popup");

        WorkCost_ObjectPanel.Visible = oldVisible;
    }

    /// <summary>
    /// Occurs when user mades selection in the contract drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ContractID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        tabContract.BindControlsToObject(work);
        tabContract.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user changes the scheduled start date time.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ScheduledStartDateTime_DateTimeChanged(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        panelScheduledStart.BindControlsToObject(work);
        tabContract.BindControlsToObject(work);

        work.ScheduledEndDateTime = work.ScheduledStartDateTime;
        if (work.Location != null)
        {
            //auto select assignment mode and bind technician dropdownlist
            pre_selectAssignmentMode(work);
        }
        panelWorkCost.BindObjectToControls(work);
        panelScheduledStart.BindObjectToControls(work);
        tabContract.BindObjectToControls(work);

    }

    public void pre_selectAssignmentMode(OWork work)
    {
        List<OTechnicianRosterItem> techRosterItems = null;
        if (work.Location != null && work.ScheduledStartDateTime != null && TypeOfServiceID.SelectedValue != string.Empty)
        {
            techRosterItems = OTechnicianRosterItem.GetTechnicianRosterItems(work.LocationID, work.ScheduledStartDateTime, null);
            if (techRosterItems.Count > 0)
            {
                work.AssignmentMode = techRosterItems[0].TechnicianRoster.DefaultAssignmentMode + 1;
                this.rdl_AssignmentMode.Visible = true;
            }
            else
            {
                work.AssignmentMode = 0;
                this.rdl_AssignmentMode.Visible = false;
            }
        }
        //else
        //{
        //    if (work.AssignmentMode != null && work.AssignmentMode != 0)
        //        techRosterItems = OTechnicianRosterItem.GetTechnicianRosterItems(work.LocationID, work.ScheduledStartDateTime, (work.AssignmentMode - 1).ToString());
        //}
        List<OUser> technicians = OTechnicianRosterItem.GetTechnicians(work, techRosterItems);

        work.WorkCost.Clear();
        if (work.AssignmentMode > 1)
        {
            if (work.WorkCost != null && work.WorkCost.Count > 0)
            {
                for (int i = 0; i < work.WorkCost.Count; i++)
                    if (work.WorkCost[i].CostType == 0)
                        work.WorkCost.RemoveGuid(work.WorkCost[i].ObjectID.Value);
            }

            foreach (OUser user in technicians)
            {
                if (doesUserExistInWC(work.WorkCost, user.ObjectID) == false)
                    work.AddWorkCost(user);
            }
            ddl_TechnicianID.Bind(null);
        }
        else
        {
            ddl_TechnicianID.Bind(technicians);
        }
    }
    /// <summary>
    /// Occurs when user changes the actual start date time.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ActualStartDateTime_DateTimeChanged(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        panel.ObjectPanel.BindControlsToObject(work);

        BindContract((OWork)panel.SessionObject);

        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user clicks on the edit parent button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditParent_Click(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        panel.ObjectPanel.BindControlsToObject(work);

        if (work.ParentID != null)
            Window.OpenEditObjectPage(this, "OWork", work.ParentID.Value.ToString(), "");
    }

    /// <summary>
    /// Occurs when user clicks on the add/edit button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    void Children_Action(object sender, string commandName, List<object> objectIds)
    {
        OWork work = panel.SessionObject as OWork;
        panel.ObjectPanel.BindControlsToObject(work);

        if (commandName == "AddObject")
        {
            Window.OpenAddObjectPage(this, "OWork", QueryString.New("PARENTID", Security.Encrypt(work.ObjectID.Value.ToString())));
        }
        else if (commandName == "EditObject")
        {
            if (objectIds.Count > 0)
                Window.OpenEditObjectPage(this, "OWork", objectIds[0].ToString(), "");
        }
    }

    /// <summary>
    /// Occurs when user clicks on the acknowledge button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAcknowledge_Click(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        panel.ObjectPanel.BindControlsToObject(work);

        work.AcknowledgementDateTime = DateTime.Now;

        panel.ObjectPanel.BindObjectToControls(work);

    }

    /// <summary>
    /// Occurs when user clicks on the arrival button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonArrival_Click(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        panel.ObjectPanel.BindControlsToObject(work);

        work.ArrivalDateTime = DateTime.Now;

        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Constructs and returns a fixed rate tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater FixedRateID_AcquireTreePopulater(object sender)
    //{
    //    OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
    //    return new FixedRateTreePopulater(workCost.FixedRateID, false, true);
    //}

    /// <summary>
    /// Occurs when the user selects a node in the fixed rate treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void FixedRateID_SelectedNodeChanged(object sender, EventArgs e)
    //{
    //    OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
    //    WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);
    //    workCost.ChargeOut = workCost.FixedRate.DefaultChargeOut != null ? workCost.FixedRate.DefaultChargeOut : 0;
    //    workCost.EstimatedUnitCost = workCost.FixedRate.UnitPrice != null ? workCost.FixedRate.UnitPrice : 0;
    //    WorkCost_SubPanel.ObjectPanel.BindObjectToControls(workCost);
    //}

    /// <summary>
    /// Occurs when user mades change in the catalogue drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CatalogueID_SelectedValueChanged(object sender, EventArgs e)
    {
        // update the bins and the unit of measure conversion
        //
        OWork work = (OWork)this.panel.SessionObject;
        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
        WorkCost_ObjectPanel.BindControlsToObject(workCost);

        if (workCost.CatalogueID != null)
        {
            workCost.CostDescription = workCost.Catalogue.ObjectName;
            WorkCost_UnitOfMeasureID.Bind(OUnitConversion.GetConversions((Guid)workCost.Catalogue.UnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }

        if (workCost.StoreID != null && workCost.CatalogueID != null)
            WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)workCost.StoreID, (Guid)workCost.CatalogueID, false), "ObjectName", "ObjectID", true);

        WorkCost_ObjectPanel.BindObjectToControls(workCost);
    }

    /// <summary>
    /// Occurs when user mades change to the store drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {
        // update the bins
        //
        OWork work = (OWork)this.panel.SessionObject;
        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
        WorkCost_ObjectPanel.BindControlsToObject(workCost);

        if (workCost.StoreID != null && workCost.CatalogueID != null)
        {
            WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)workCost.StoreID, (Guid)workCost.CatalogueID, false), "ObjectName", "ObjectID", true);
        }
        else
            WorkCost_StoreBinID.Items.Clear();

        WorkCost_ObjectPanel.BindObjectToControls(workCost);
    }

    /// <summary>
    /// Occurs when user selects one or more items to add in the pop up window.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void addActualItems_PopupReturned(object sender, EventArgs e)
    {
        WorkCost_SubPanel.MassAdd();
    }

    /// <summary>
    /// Occurs when user mades selection in the type of work drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);
        TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), null));
        TypeOfProblemID.Items.Clear();
        CauseOfProblemID.Items.Clear();
        ResolutionID.Items.Clear();
        if (work.IsNew && work.TypeOfWorkID != null)
        {
            work.ActualTypeOfWorkID = work.TypeOfWorkID;
            ActualTypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.ActualTypeOfWorkID, Security.Decrypt(Request["TYPE"]), null));
            ActualTypeOfProblemID.Items.Clear();
        }
        BindContract(work);
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user selects an item in the type of service dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        TypeOfProblemID.Bind(OCode.GetCodesByParentID(work.TypeOfServiceID, null), true);
        CauseOfProblemID.Items.Clear();
        ResolutionID.Items.Clear();
        pre_selectAssignmentMode(work);
        if (work.IsNew && work.TypeOfServiceID != null)
        {
            work.ActualTypeOfServiceID = work.TypeOfServiceID;
            ActualTypeOfProblemID.Bind(OCode.GetCodesByParentID(work.ActualTypeOfServiceID, null), true);
        }

        // 2010.05.14
        // Kim Foong
        // Binds the contracts to the dropdown list for selection.
        //
        BindContract(work);

        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user selects an item in the type of problem dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfProblemID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);
        if (work.IsNew && work.TypeOfProblemID != null)
            work.ActualTypeOfProblemID = work.TypeOfProblemID;
        CauseOfProblemID.Bind(OCode.GetCodesByParentID(work.TypeOfProblemID, null), true);
        ResolutionID.Items.Clear();

        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user selects an item in the cause of problem dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CauseOfProblemID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        ResolutionID.Bind(OCode.GetCodesByParentID(work.CauseOfProblemID, null), true);

        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user selects an item in the resolution dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ResolutionID_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Opens a window to edit the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditCase_Click(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        if (work.CaseID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, work.CaseID))
                Window.OpenEditObjectPage(this, "OCase", work.CaseID.ToString(), "");
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
        OWork work = (OWork)panel.SessionObject;
        if (work.CaseID != null)
        {
            Window.OpenViewObjectPage(this, "OCase", work.CaseID.ToString(), "");
        }
    }

    /// <summary>
    /// Opens a window to edit the scheduled work object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditScheduledWork_Click(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        if (work.ScheduledWorkID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, work.ScheduledWorkID))
                Window.OpenEditObjectPage(this, "OScheduledWork", work.ScheduledWorkID.ToString(), "");
            else
                panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
        }
    }

    /// <summary>
    /// Opens a window to view the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewScheduledWork_Click(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        if (work.ScheduledWorkID != null)
        {
            Window.OpenViewObjectPage(this, "OScheduledWork", work.ScheduledWorkID.ToString(), "");
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        string controlName = Request.Params.Get("__EVENTTARGET");
        string arguement = Request.Params.Get("__EVENTARGUMENT");

        if (controlName == "Location" && arguement.Contains("SEARCH") && Location.Enabled)
        {
            string[] arg = arguement.Split('_');

            if (arg != null && arg.Length == 2)
                Location.SelectedValue = Security.Decrypt(arg[1]);
        }
    }

    /// <summary>
    /// Occurs when the equipment down check box is set.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsEquipmentDown_CheckedChanged(object sender, EventArgs e)
    {

    }

    protected void dropTaxCode_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void ddl_TechnicianID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        if (ddl_TechnicianID.SelectedValue != null)
        {
            OUser user = TablesLogic.tUser.Load(new Guid(ddl_TechnicianID.SelectedValue.ToString()));
            if (user != null)
            {

                //work.Technicians.Add(user);
                if (doesUserExistInWC(work.WorkCost, user.ObjectID) == false)
                    work.AddWorkCost(user);
            }
        }
        ddl_TechnicianID.SelectedValue = null;
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsChargedToCaller_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;

        if (IsChargedToCaller.SelectedIndex == 0)
            BindChargeType(work);
        else
            dropChargeType.Items.Clear();

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_UserID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
        WorkCost_ObjectPanel.BindControlsToObject(workCost);

        if (workCost.Technician != null)
        {
            if (workCost.Technician.CraftID != null)
            {
                OCraft craft = TablesLogic.tCraft.Load(workCost.Technician.CraftID);
                if (craft != null)
                {
                    if (craft.DefaultChargeOut != null)
                    {
                        if (workCost.EstimatedOvertime == 0)
                            workCost.ChargeOut = craft.DefaultChargeOut;
                        else
                            workCost.ChargeOut = craft.DefaultChargeOut;
                    }
                }
            }
        }
        WorkCost_ObjectPanel.BindObjectToControls(workCost);
    }

    protected void ArrivalDateTime_DateTimeChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        if (work.ActualStartDateTime == null)
            work.ActualStartDateTime = work.ArrivalDateTime;

        if (work.ActualEndDateTime == null)
            work.ActualEndDateTime = work.ArrivalDateTime;

        panel.ObjectPanel.BindObjectToControls(work);
    }

    protected void objectBase_WorkflowTransitionSelected(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        if (objectBase.CurrentObjectState.Is("Start", "Draft"))
        {
            NotifyWorkSupervisor.Checked = objectBase.SelectedAction == "SubmitForAssignment";
            NotifyWorkTechnician.Checked = objectBase.SelectedAction == "SubmitForExecution";
        }
        else if (objectBase.CurrentObjectState.Is("PendingAssignment"))
        {
            NotifyWorkTechnician.Checked = objectBase.SelectedAction == "SubmitForExecution";
        }

    }

    protected void rdl_AssignmentMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        panel.ObjectPanel.BindControlsToObject(work);
        List<OTechnicianRosterItem> rosterITem = work.AssignmentMode == 0 ? null : OTechnicianRosterItem.GetTechnicianRosterItems(work.LocationID, work.ScheduledStartDateTime.Value, (work.AssignmentMode - 1).ToString());
        List<OUser> technicians = OTechnicianRosterItem.GetTechnicians(work, rosterITem);

        work.WorkCost.Clear();
        if (work.AssignmentMode <= 1)//manualy assign technician
        {

            ddl_TechnicianID.Bind(null);
            ddl_TechnicianID.Bind(technicians);
        }
        else//auto assign technician
        {
            //clear all technicians before assign new one if the technicians are auto assigned
            if (work.WorkCost != null && work.WorkCost.Count > 0)
            {
                for (int i = 0; i < work.WorkCost.Count; i++)
                    if (work.WorkCost[i].CostType == 0)
                        work.WorkCost.RemoveGuid(work.WorkCost[i].ObjectID.Value);
            }
            //add new technicians to workcost
            if (technicians != null && technicians.Count > 0)
            {
                foreach (OUser user in technicians)
                {

                    if (doesUserExistInWC(work.WorkCost, user.ObjectID) == false)
                        work.AddWorkCost(user);
                }
            }
            ddl_TechnicianID.SelectedValue = null;

        }

        panel.ObjectPanel.BindObjectToControls(work);

    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="wcList"></param>
    /// <param name="userID"></param>
    /// <returns></returns>
    public bool doesUserExistInWC(DataList<OWorkCost> wcList, Guid? userID)
    {
        foreach (OWorkCost wc in wcList)
        {
            if (wc.UserID == userID)
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void WorkCost_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[6].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
            {
                e.Row.Cells[9].Text = Convert.ToDecimal(e.Row.Cells[9].Text).ToString("#,##0");
                e.Row.Cells[13].Text = Convert.ToDecimal(e.Row.Cells[13].Text).ToString("#,##0");
            }

            //2011-11-15 ptb, for Tax
            UIFieldDropDownList taxcode = ((UIFieldDropDownList)e.Row.FindControl("TaxCodeID"));
            if (taxcode != null)
                taxcode.Bind(OTaxCode.GetAllTaxCodes(DateTime.Today, null));

            //2011-12-06 ptb, hide edit button once checked out.
            Guid id = (Guid)WorkCost.DataKeys[e.Row.RowIndex][0];
            OWork work = (OWork)panel.SessionObject;
            OWorkCost wc = (OWorkCost)work.WorkCost.FindObject(id);
            CheckBox cb = e.Row.Cells[0].Controls[0] as CheckBox;
            if (wc.CostType == WorkCostType.Material)
            {
                if (wc.IsCheckOut != 0)
                {
                    e.Row.BackColor = System.Drawing.Color.LightGray;
                    //cb.Style["display"] = "none";
                }
            }
            else
                cb.Style["display"] = "none";

            //UIFieldCheckBox cbx = e.Row.Cells[0].Controls[0] as UIFieldCheckBox;
            //cbx.Enabled = (wc.IsCheckOut == 0 && wc.CostType == WorkCostType.Material);
            //e.Row.Cells[0].Visible = (wc.IsCheckOut == 0 && wc.CostType == WorkCostType.Material);
            //if (wc.IsCheckOut == 0 && wc.CostType == WorkCostType.Material)
            //{

            //}

            //UIFieldTextBox actQty = ((UIFieldTextBox)e.Row.FindControl("ActualQuantity"));
            //actQty.Enabled = e.Row.Cells[4].Text == Resources.Strings.CostType_Material;
            //Guid? wcID = new Guid(WorkCost.DataKeys[e.Row.RowIndex].Value.ToString());
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
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void searchTenantLease_Selected(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        tabDetails.BindControlsToObject(work);

        Guid id = (Guid)searchTenantLease.SelectedDataKeys[0];
        OTenantLease tenantLease = TablesLogic.tTenantLease[id];

        work.RequestorID = tenantLease.TenantID;
        work.TenantLeaseID = tenantLease.ObjectID;
        //work.LocationID = tenantLease.LocationID;
        //Location.PopulateTree();

        BindTenantContact(work);

        if (tenantLease.Tenant.TenantContacts.Count > 0)
        {
            work.TenantContactID = tenantLease.Tenant.TenantContacts[0].ObjectID;
            work.RequestorName = tenantLease.Tenant.TenantContacts[0].ObjectName;
        }
        else
            work.RequestorName = tenantLease.Tenant.ObjectName;

        tabDetails.BindObjectToControls(work);
    }

    protected void searchTenantLease_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        DateTime readingDateTime =
                new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
        if (DateTime.Now.Day <= OApplicationSetting.Current.PostingEndDay)
            readingDateTime = readingDateTime.AddMonths(-1);
        e.CustomCondition =
            (TablesLogic.tTenantLease.LeaseStatus == EnumLeaseStatus.New |
            (TablesLogic.tTenantLease.LeaseStatus == EnumLeaseStatus.Renewal & TablesLogic.tTenantLease.LeaseEndDate >= readingDateTime) |
            // 2011.01.31
            // Kim Foong
            // To include the leases that are extended
            //
            (TablesLogic.tTenantLease.LeaseStatus == EnumLeaseStatus.Extended & TablesLogic.tTenantLease.LeaseEndDate >= readingDateTime)
            ) &
            TablesLogic.tTenantLease.AmosLeaseID != null;

        if (Location.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(Location.SelectedValue)];
            e.CustomCondition = e.CustomCondition & TablesLogic.tTenantLease.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        else
        {
            ExpressionCondition cond = Query.False;

            List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
            foreach (OPosition position in positions)
                foreach (OLocation location in position.LocationAccess)
                    cond = cond | TablesLogic.tTenantLease.Location.HierarchyPath.Like(location.HierarchyPath + "%");

            e.CustomCondition = e.CustomCondition & cond;
        }

    }

    protected void searchTenantLease_Cleared(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;
        tabDetails.BindControlsToObject(work);

        work.RequestorID = null;
        work.TenantLeaseID = null;
        work.TenantContactID = null;

        tabDetails.BindObjectToControls(work);
    }

    protected void buttonGenerateRFQFromLineItems_Click(object sender, EventArgs e)
    {
        List<object> ids = WorkCost.GetSelectedKeys();
        if (ids.Count > 0)
        {
            // Validate to ensure that none of the selected
            // items have been generated to RFQs.
            //
            List<Guid> ItemIds = new List<Guid>();
            foreach (Guid id in ids)
                ItemIds.Add(id);
            StringBuilder sb = new StringBuilder();
            DataTable dt = OWork.ValidateItemsNotGeneratedToRFQ(ItemIds);
            foreach (DataRow dr in dt.Rows)
                sb.Append(dr["ItemNumber"].ToString() + ". " + dr["ItemDescription"].ToString() + "<br/>");
            string lineItems = sb.ToString();
            if (lineItems.Length != 0)
            {
                panel.Message = String.Format(Resources.Errors.Work_LineItemsAlreadyGeneratedIntoRFQ, lineItems);
                return;
            }
            List<OWorkCost> items = new List<OWorkCost>();
            OWork work = panel.SessionObject as OWork;
            panel.ObjectPanel.BindControlsToObject(work);

            foreach (OWorkCost workcost in work.WorkCost)
            {
                if (ids.Contains(workcost.ObjectID.Value))
                    items.Add(workcost);
            }
            ORequestForQuotation rfq = ORequestForQuotation.CreateRFQFromWorkCosts(items);
            Window.OpenEditObjectPage(this, "ORequestForQuotation", rfq.ObjectID.Value.ToString(), "");
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ActualTypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);
        ActualTypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.ActualTypeOfWorkID, Security.Decrypt(Request["TYPE"]), null));
        ActualTypeOfProblemID.Items.Clear();
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ActualTypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        ActualTypeOfProblemID.Bind(OCode.GetCodesByParentID(work.ActualTypeOfServiceID, null), true);
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddWJ_Click(object sender, EventArgs e)
    {
        OWork work = panel.SessionObject as OWork;

        GenerateRFQ(work);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="work"></param>
    protected void GenerateRFQ(OWork work)
    {
        ORequestForQuotation rfq = ORequestForQuotation.CreateRFQFromWork(work, 1);
        Window.OpenAddObjectPage(this, rfq, "");
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridWorkJustifications_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditWJ")
        {
            Guid id = (Guid)dataKeys[0];
            Window.OpenEditObjectPage(this, "ORequestForQuotation", id.ToString(), "");
        }

        if (commandName == "ViewWJ")
        {
            Guid id = (Guid)dataKeys[0];
            Window.OpenViewObjectPage(this, "ORequestForQuotation", id.ToString(), "");
        }
    }

    protected void buttonShowTenantDetails_Click(object sender, EventArgs e)
    {
        panelTenantDetails.Visible = !panelTenantDetails.Visible;
    }

    //protected TreePopulater WorkCost_treeCatalogue_AcquireTreePopulater(object sender)
    //{
    //    OWorkCost wc = WorkCost_SubPanel.SessionObject as OWorkCost;
    //    return new CatalogueTreePopulater(wc.CatalogueID, true, true, true, false);
    //}

    //protected void WorkCost_treeCatalogue_SelectedNodeChanged(object sender, EventArgs e)
    //{
    //    // update the bins and the unit of measure conversion
    //    //
    //    OWork work = (OWork)this.panel.SessionObject;
    //    OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
    //    WorkCost_ObjectPanel.BindControlsToObject(workCost);

    //    if (workCost.CatalogueID != null)
    //    {
    //        workCost.CostDescription = workCost.Catalogue.ObjectName;
    //        WorkCost_UnitOfMeasureID.Bind(OUnitConversion.GetConversions((Guid)workCost.Catalogue.UnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
    //    }

    //    if (workCost.StoreID != null && workCost.CatalogueID != null)
    //        WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)workCost.StoreID, (Guid)workCost.CatalogueID, false), "ObjectName", "ObjectID", true);

    //    WorkCost_ObjectPanel.BindObjectToControls(workCost);
    //}

    protected void WorkCost_CatalogueDialog_ControlClicked(object sender, EventArgs e)
    {
        //searchTenantLease.Show();
        searchCatalogs.Show();
    }

    protected void searchCatalogs_Selected(object sender, EventArgs e)
    {
        // update the bins and the unit of measure conversion
        //
        OWork work = (OWork)this.panel.SessionObject;
        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);

        Guid? id = (Guid?)searchCatalogs.SelectedDataKeys[0];
        workCost.CatalogueID = id;

        if (workCost.CatalogueID != null)
        {
            workCost.CostDescription = workCost.Catalogue.ObjectName;
            workCost.ChargeOut = workCost.Catalogue.DefaultChargeOut;
            workCost.EstimatedUnitCost = workCost.Catalogue.UnitPrice;
            WorkCost_UnitOfMeasureID.Bind(OUnitConversion.GetConversions((Guid)workCost.Catalogue.UnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);

            if (!objectBase.CurrentObjectState.Is("Start", "Draft"))
                workCost.ActualUnitCost = workCost.EstimatedUnitCost;
        }

        if (workCost.StoreID != null && workCost.CatalogueID != null)
        {
            WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)workCost.StoreID, (Guid)workCost.CatalogueID, false), "ObjectName", "ObjectID", true);

            if (WorkCost_StoreBinID.Items.Count == 2)
                workCost.StoreBinID = new Guid(WorkCost_StoreBinID.Items[1].Value);
        }

        WorkCost_ObjectPanel.BindObjectToControls(workCost);
    }

    protected void searchCatalogs_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        OWork work = (OWork)this.panel.SessionObject;
        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
        panel.ObjectPanel.BindControlsToObject(work);
        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);
        List<Guid?> listCatalogue = new List<Guid?>();
        if (workCost.Store != null)
        {
            foreach (OStoreItem si in workCost.Store.StoreItems)
                listCatalogue.Add(si.CatalogueID);

            e.CustomCondition = TablesLogic.tCatalogue.IsCatalogueItem == 1
                & (TablesLogic.tCatalogue.ObjectID.In(listCatalogue));

            List<ColumnOrder> listColumnOrders = new List<ColumnOrder>();
            listColumnOrders.Add(TablesLogic.tCatalogue.Parent.ObjectName.Asc);
            e.CustomSortOrder = listColumnOrders;
        }
        else
        {
            e.CustomCondition = Query.False;
        }
    }

    protected void WorkCost_FixedRateDialog_ControlClicked(object sender, EventArgs e)
    {
        searchFixedRates.Show();
    }

    protected void searchFixedRates_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        e.CustomCondition = TablesLogic.tFixedRate.IsFixedRate == 1;
        List<ColumnOrder> listColumnOrders = new List<ColumnOrder>();
        listColumnOrders.Add(TablesLogic.tFixedRate.Parent.ObjectName.Asc);
        e.CustomSortOrder = listColumnOrders;
    }

    protected void searchFixedRates_Selected(object sender, EventArgs e)
    {
        OWorkCost workCost = WorkCost_SubPanel.SessionObject as OWorkCost;
        //WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);

        Guid? id = (Guid?)searchFixedRates.SelectedDataKeys[0];
        workCost.FixedRateID = id;

        if (workCost.FixedRateID != null)
        {
            workCost.ChargeOut = workCost.FixedRate.DefaultChargeOut != null ? workCost.FixedRate.DefaultChargeOut : 0;
            workCost.EstimatedUnitCost = workCost.FixedRate.UnitPrice != null ? workCost.FixedRate.UnitPrice : 0;

            if (!objectBase.CurrentObjectState.Is("Start", "Draft"))
                workCost.ActualUnitCost = workCost.EstimatedUnitCost;
        }

        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(workCost);

    }

    /// <summary>
    /// Event handle tax code drop downlist index changed.
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TaxCodeID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)this.panel.SessionObject;
        UIFieldDropDownList taxcode = (UIFieldDropDownList)sender;
        GridViewRow row = (GridViewRow)taxcode.NamingContainer;
        OWorkCost item = work.WorkCost.Find(new Guid(WorkCost.DataKeys[row.RowIndex][0].ToString()));
        //OWorkCost item = TablesLogic.tWorkCost.Load(new Guid(WorkCost.DataKeys[row.RowIndex][0].ToString()));
        if (item != null)
        {
            UIFieldTextBox taxamount = (UIFieldTextBox)row.FindControl("TaxAmount");
            if (taxcode.SelectedValue != "")
            {
                OTaxCode tax = TablesLogic.tTaxCode.Load(new Guid(taxcode.SelectedValue));
                if (tax != null)
                    taxamount.Text = ((decimal)(item.ActualCostTotal * item.ActualQuantity) * (tax.TaxPercentage.Value / 100)).ToString("#,##0.00##");
            }
            else
                taxamount.Text = null;
        }
    }

    /// <summary>
    /// Check out Items
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void WorkCost_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "CheckOutObject")
        {
            panel.Message = "";
            if (objectIds.Count != 0)
            {
                OWork work = (OWork)panel.SessionObject;
                panel.ObjectPanel.BindControlsToObject(work);

                List<ODocumentTemplate> dc = ODocumentTemplate.GetDocumentTemplatesByCode(Resources.Strings.Work_CheckOutTemplate.ToString());
                if (dc.Count != 1)
                    panel.Message = WorkCost.ErrorMessage = Resources.Errors.Work_InvalidTemplate.ToString();
                else
                {
                    List<string> lstID = new List<string>();
                    foreach (object id in objectIds)
                    {
                        lstID.Add(id.ToString());
                        OWorkCost wc = (OWorkCost)work.WorkCost.FindObject(new Guid(id.ToString()));
                        OWorkCost wcInDB = TablesLogic.tWorkCost.Load(new Guid(id.ToString()));
                        if (wcInDB == null)
                        {
                            panel.Message = WorkCost.ErrorMessage = Resources.Errors.Work_SaveBeforeCheckOut.ToString();
                            return;
                        }
                        if (wc.CostType != WorkCostType.Material)
                        {
                            panel.Message = WorkCost.ErrorMessage = Resources.Errors.Work_CannotCheckOut.ToString();
                            return;
                        }
                        else if (wc.EstimatedQuantity == 0)
                        {
                            panel.Message = WorkCost.ErrorMessage = Resources.Errors.Work_InvalidQuantity.ToString();
                            return;
                        }
                        else
                            wc.IsCheckOut = 1;
                    }
                    DataSet ds = work.DocumentTemplateDataSetForCheckOut();
                    DataTable dtCost = ds.Tables["WorkCosts"];
                    for (int i = dtCost.Rows.Count - 1; i >= 0; i--)
                        if (!lstID.Contains(dtCost.Rows[i]["ObjectID"].ToString()))
                            dtCost.Rows.RemoveAt(i);

                    byte[] fileBytes = DocumentGenerator.GenerateFromRDLTemplate(dc[0].FileBytes, ds, DocumentOutputFormat.AcrobatPDF);
                    if (fileBytes != null)
                    {
                        string filename = work.ObjectNumber + ".pdf";
                        Window.Download(fileBytes, filename, dc[0].OutputContentMIMEType);
                    }
                }

                work.ReserveInventoryItems();
                panel.ObjectPanel.BindObjectToControls(work);
            }
            else
            {
                panel.Message = Resources.Errors.Work_CannotCheckOut.ToString();
                return;
            }

            //List<OWorkCost> listWorkCost = new List<OWorkCost>();
            //int i = 0;
            //foreach (Guid id in objectIds)
            //{
            //    OWorkCost wc = work.WorkCost.Find(id);
            //    if (wc.CostType == WorkCostType.Material)
            //    {
            //        //using (Connection c = new Connection())
            //        //{
            //        //    wc.HandleCheckOut();
            //        //    wc.HandleReservation();
            //        //    i++;

            //        //    c.Commit();
            //        //}
            //        listWorkCost.Add(wc);
            //    }
            //}
            //if (listWorkCost.Count != 0)
            //{
            //    OStoreCheckOut sco = OWork.StoreCheckOutFromWork(work, listWorkCost);
            //    Window.OpenEditObjectPage(this, "OStoreCheckOut", sco.ObjectID.ToString(), "");
            //}
            ////panel.Message = String.Format(Resources.Strings.Work_CheckOutItems, i.ToString());
            ////OEquipment eqp = (OEquipment)panel.SessionObject;
            ////panel.ObjectPanel.BindControlsToObject(eqp);

            ////foreach (Guid id in objectIds)
            ////    eqp.ServingAreas.RemoveGuid(id);

            ////panel.ObjectPanel.BindObjectToControls(eqp);
        }
        else if (commandName == "DeleteItem")
        {
            // Disallow deletion if the item is already checked out
            OWork work = (OWork)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(work);
            foreach (object id in objectIds)
            {
                OWorkCost wc = work.WorkCost.Find(lf => lf.ObjectID == (Guid)id);
                if (wc.CostType == (int)WorkCostType.Material)
                {
                    OStoreCheckOut sco = TablesLogic.tStoreCheckOut.Load(TablesLogic.tStoreCheckOut.WorkID == work.ObjectID
                                        & TablesLogic.tStoreCheckOut.StoreCheckOutItems.FromWorkCostID == (Guid)id
                                        & TablesLogic.tStoreCheckOut.CurrentActivity.CurrentStateName != "Cancelled");
                    if (sco != null)
                    {
                        panel.Message = String.Format("The inventory item {0} has already checked out, please unselect this item.", wc.Catalogue.ObjectName);
                        return;
                    }                   
                }
            }

            // Clear reservation                        
            foreach (object id in objectIds)
            {
                work.WorkCost.RemoveGuid((Guid)id);
            }
            panel.ObjectPanel.BindObjectToControls(work);
        }
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Work" BaseTable="tWork" ShowWorkflowActionAsButtons="true"
            SaveButtonsVisible="false" ShowWorkflowDialogBox="true" OnPopulateForm="panel_PopulateForm"
            meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave" OnValidate="panel_Validate">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource2"
                BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="uitabview1Resource2"
                    BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberCaption="Work Number"
                        ObjectNumberEnabled="false" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"
                        OnWorkflowTransitionSelected="objectBase_WorkflowTransitionSelected"></web:base>
                    <ui:UIPanel runat="server" ID="panelWorkDetails" meta:resourcekey="panelWorkDetailsResource1"
                        BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelWorkDescription" BorderStyle="NotSet">
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td nowrap="nowrap">
                                        <ui:UIFieldTreeList runat="server" ID="Location" Caption="Location" PropertyName="LocationID"
                                            OnSelectedNodeChanged="Location_SelectedNodeChanged" ValidateRequiredField="True"
                                            OnAcquireTreePopulater="Location_AcquireTreePopulater" meta:resourcekey="LocationResource1"
                                            ToolTip="Use this to select the location that this work applies to." ShowCheckBoxes="None"
                                            TreeValueMode="SelectedNode" />
                                    </td>
                                    <td width="40px" valign="middle">
                                        <web:map runat="server" ID="buttonMap" TargetControlID="Location"></web:map>
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldTreeList runat="server" ID="Equipment" Caption="Equipment" PropertyName="EquipmentID"
                                OnSelectedNodeChanged="Equipment_SelectedNodeChanged" OnAcquireTreePopulater="Equipment_AcquireTreePopulater"
                                meta:resourcekey="EquipmentResource1" ToolTip="Use this to select the equipment that this work applies to."
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldTextBox ID="WorkDescription" runat="server" Caption="Work Description"
                                PropertyName="WorkDescription" ValidateRequiredField="True" MaxLength="255" meta:resourcekey="WorkDescriptionResource2"
                                InternalControlWidth="95%">
                            </ui:UIFieldTextBox>
                        </ui:UIPanel>
                        <ui:UIFieldRadioList ID="IsChargedToCaller" runat="server" Caption="Is Charged?"
                            PropertyName="IsChargedToCaller" ToolTip="Indicates if this work should be charged to the caller when it is finally completed."
                            ValidateRequiredField="True" RepeatColumns="0" RepeatDirection="Vertical" OnSelectedIndexChanged="IsChargedToCaller_SelectedIndexChanged"
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" Text="Yes, this work is chargeable"></asp:ListItem>
                                <asp:ListItem Value="0" Text="No, this work is non-chargeable"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelBilling" BorderStyle="NotSet">
                            <ui:UIFieldDropDownList runat="server" ID="dropChargeType" Caption="Charge Type"
                                PropertyName="ChargeTypeID" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UISeparator ID="UISeparator1" runat="server" Caption="Requestor" />
                        <ui:UIPanel runat="server" ID="panelCase" BorderStyle="NotSet" meta:resourcekey="panelCaseResource1">
                            <ui:UIPanel runat="server" ID="panelCaseDetails" BorderStyle="NotSet">
                                <ui:UIFieldLabel runat="server" ID="labelRequestor" PropertyName="Requestor.ObjectName"
                                    Caption="Tenant" Span="Half">
                                </ui:UIFieldLabel>
                                <web:searchdialogbox runat='server' ID="searchTenantLease" BaseTable="tTenantLease"
                                    AutoSearchOnLoad="true" AllowMultipleSelection="false" ButtonSelectText="Select tenant from leases"
                                    Title="Select A Tenant Lease" MaximumNumberOfResults="100" SearchTextBoxPropertyNames="Tenant.ObjectName,ShopName"
                                    OnSelected="searchTenantLease_Selected" OnSearched="searchTenantLease_Searched"
                                    OnCleared="searchTenantLease_Cleared">
                                    <Columns>
                                        <ui:UIGridViewButtonColumn AlwaysEnabled="true" CommandName="AddObject" ImageUrl="~/images/tick.gif">
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Tenant Name" HeaderStyle-Width="250px" PropertyName="Tenant.ObjectName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Building" HeaderStyle-Width="150px" PropertyName="Location.Parent.Parent.ObjectName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Unit No" HeaderStyle-Width="150px" PropertyName="Location.ObjectName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Shop Name" HeaderStyle-Width="150px" PropertyName="ShopName">
                                        </ui:UIGridViewBoundColumn>
                                    </Columns>
                                    <AdvancedPanel>
                                    </AdvancedPanel>
                                </web:searchdialogbox>
                                <ui:UIFieldDropDownList runat="server" ID="dropTenantContact" Caption="Tenant Contact"
                                    InternalControlWidth="97%" PropertyName="TenantContactID" Span="Half">
                                </ui:UIFieldDropDownList>
                                <%--<asp:Label runat="server" ID="labelShowTenantDetails" Text="" Width="158px"></asp:Label>--%>
                                <ui:UIButton runat="server" ID="buttonShowTenantDetails" Text="Show me more details on this tenant"
                                    AlwaysEnabled="true" CausesValidation="false" OnClick="buttonShowTenantDetails_Click" />
                                <ui:UIPanel runat="server" ID="panelTenantDetails" BorderStyle="NotSet">
                                    <ui:UIFieldTextBox ID="RequestorUnitNo" runat="server" Caption="Unit" PropertyName="TenantLease.Location.Path"
                                        Enabled="false" Span="Full">
                                    </ui:UIFieldTextBox>
                                    <ui:UIFieldTextBox ID="RequestorName" runat="server" Caption="Name" PropertyName="RequestorName"
                                        ValidateRequiredField="True" Span="Half" ToolTip="The name of the Requestor to refer by."
                                        meta:resourcekey="RequestorNameResource2" InternalControlWidth="95%" />
                                    <ui:UIFieldTextBox ID="RequestorEmail" runat="server" Caption="Email" PropertyName="RequestorEmail"
                                        Span="Half" meta:resourcekey="RequestorEmailResource1" InternalControlWidth="95%" />
                                    <ui:UIFieldTextBox ID="RequestorCellPhone" runat="server" Caption="Cell Phone" PropertyName="RequestorCellPhone"
                                        Span="Half" meta:resourcekey="RequestorCellResource1" InternalControlWidth="95%" />
                                    <ui:UIFieldTextBox ID="RequestorPhone" runat="server" Caption="Phone" PropertyName="RequestorPhone"
                                        Span="Half" meta:resourcekey="RequestorPhoneResource1" InternalControlWidth="95%" />
                                </ui:UIPanel>
                            </ui:UIPanel>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelScheduledWork" BorderStyle="NotSet" meta:resourcekey="panelScheduledWorkResource1">
                            <ui:UIFieldLabel runat="server" ID="labelScheduledWorkNumber" Caption="Schedule Number"
                                PropertyName="ScheduledWork.ObjectNumber" ContextMenuAlwaysEnabled="True" DataFormatString=""
                                meta:resourcekey="labelScheduledWorkNumberResource1">
                                <ContextMenuButtons>
                                    <ui:UIButton runat="server" ID="buttonEditScheduledWork" ImageUrl="~/images/edit.gif"
                                        Text="Edit Scheduled Work" ConfirmText="Please remember to save this Work before editing the Scheduled Work.\n\nAre you sure you want to continue?"
                                        OnClick="buttonEditScheduledWork_Click" AlwaysEnabled="True" CausesValidation="False"
                                        meta:resourcekey="buttonEditScheduledWorkResource1" />
                                    <ui:UIButton runat="server" ID="buttonViewScheduledWork" ImageUrl="~/images/view.gif"
                                        Text="View Scheduled Work" ConfirmText="Please remember to save this Work before viewing the Scheduled Work.\n\nAre you sure you want to continue?"
                                        OnClick="buttonViewScheduledWork_Click" AlwaysEnabled="True" CausesValidation="False"
                                        meta:resourcekey="buttonViewScheduledWorkResource1" />
                                </ContextMenuButtons>
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="labelScheduledWorkDescription" Caption="Schedule Name"
                                PropertyName="ScheduledWork.ObjectName" DataFormatString="" meta:resourcekey="labelScheduledWorkDescriptionResource1">
                            </ui:UIFieldLabel>
                        </ui:UIPanel>
                        <ui:UISeparator ID="Separator1" runat="server" Caption="Problem" meta:resourcekey="Separator1Resource1" />
                        <ui:UIPanel runat="server" ID="panelWorkClassification" meta:resourcekey="panelWorkClassificationResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldDropDownList runat="server" ID="TypeOfWorkID" PropertyName="TypeOfWorkID"
                                Caption="Type of Work" ValidateRequiredField="True" OnSelectedIndexChanged="TypeOfWorkID_SelectedIndexChanged"
                                meta:resourcekey="TypeOfWorkIDResource2">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="TypeOfServiceID" PropertyName="TypeOfServiceID"
                                Caption="Type of Service" ValidateRequiredField="True" meta:resourcekey="TypeOfServiceIDResource2"
                                OnSelectedIndexChanged="TypeOfServiceID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="TypeOfProblemID" PropertyName="TypeOfProblemID"
                                Caption="Type of Problem" ValidateRequiredField="True" meta:resourcekey="TypeOfProblemIDResource2"
                                OnSelectedIndexChanged="TypeOfProblemID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="Priority" PropertyName="Priority" Caption="Priority"
                                ValidateRequiredField="True" Span="Half" meta:resourcekey="PriorityResource1">
                                <Items>
                                    <asp:ListItem meta:resourcekey="ListItemResource8"></asp:ListItem>
                                    <asp:ListItem Text="0 (Lowest)" Selected="True" Value="0" meta:resourceKey="ListItemResource9"></asp:ListItem>
                                    <asp:ListItem Text="1" Value="1" meta:resourceKey="ListItemResource10"></asp:ListItem>
                                    <asp:ListItem Text="2" Value="2" meta:resourceKey="ListItemResource11"></asp:ListItem>
                                    <asp:ListItem Text="3 (Highest)" Value="3" meta:resourceKey="ListItemResource12"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelScheduledStart" meta:resourcekey="panelScheduledStartResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldDateTime runat="server" ID="ScheduledStartDateTime" PropertyName="ScheduledStartDateTime"
                                Caption="Scheduled Start" ValidateRequiredField="True" ShowTimeControls='True'
                                OnDateTimeChanged="ScheduledStartDateTime_DateTimeChanged" ToolTip="The date/time in which the work is scheduled to start."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="ScheduledStartDateTimeResource2"
                                ValidateCompareField='True' ValidationCompareControl="ScheduledEndDateTime" ValidationCompareType="Date"
                                ValidationCompareOperator="LessThanEqual" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="ScheduledEndDateTime" PropertyName="ScheduledEndDateTime"
                                Caption="Scheduled End" ValidateRequiredField="True" ShowTimeControls='True'
                                ToolTip="The date/time in which the work is scheduled to complete." ImageClearUrl="~/calendar/dateclr.gif"
                                ImageUrl="~/calendar/date.gif" meta:resourcekey="ScheduledEndDateTimeResource2"
                                ValidateCompareField="True" ValidationCompareControl="ScheduledStartDateTime"
                                ValidationCompareType="Date" ValidationCompareOperator="GreaterThanEqual" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="Notify_Panel" BorderStyle="NotSet" meta:resourcekey="Notify_PanelResource1">
                        <ui:UIFieldCheckBox runat="server" ID="NotifyWorkSupervisor" PropertyName="NotifyWorkSupervisor"
                            Caption="Notify Supervisor" meta:resourcekey="NotifyWorkSupervisorResource1"
                            TextAlign="Right" />
                        <ui:UIFieldCheckBox runat="server" ID="NotifyWorkTechnician" PropertyName="NotifyWorkTechnician"
                            Caption="Notify Technician" meta:resourcekey="NotifyWorkTechnicianResource1"
                            TextAlign="Right" />
                        <ui:UIFieldDropDownList runat="server" ID="ddl_SupervisorID" PropertyName="SupervisorID"
                            Caption="Supervisor" meta:resourcekey="ddl_SupervisorIDResource1">
                        </ui:UIFieldDropDownList>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelAckArrTime" meta:resourcekey="panelAckArrTimeResource1"
                        BorderStyle="NotSet">
                        <table cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style="width: 450px">
                                    <ui:UIFieldDateTime runat="server" ID="AcknowledgementDateTime" PropertyName="AcknowledgementDateTime"
                                        Caption="Acknowledgement" ShowTimeControls='True' ToolTip="The date/time of acknowledgement of this work. Click 'Acknowledge' to set the date/time automatically. Note: Please remember to save to update the acknowledgement time."
                                        ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="AcknowledgementDateTimeResource1"
                                        ShowDateControls="True">
                                    </ui:UIFieldDateTime>
                                </td>
                                <td>
                                    <ui:UIButton runat="server" ID="buttonAcknowledge" ImageUrl="~/images/tick.gif" Text="Acknowledge"
                                        OnClick="buttonAcknowledge_Click" meta:resourcekey="buttonAcknowledgeResource1" />
                                </td>
                            </tr>
                        </table>
                        <table cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style="width: 450px">
                                    <ui:UIFieldDateTime runat="server" ID="ArrivalDateTime" PropertyName="ArrivalDateTime"
                                        Caption="Arrival" ShowTimeControls='True' ToolTip="The date/time of arrival/response of this work. Click 'Arrive On-Site' to set the date/time automatically. Note: Please remember to save to update the arrival time."
                                        ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="ArrivalDateTimeResource1"
                                        ShowDateControls="True" OnDateTimeChanged="ArrivalDateTime_DateTimeChanged">
                                    </ui:UIFieldDateTime>
                                </td>
                                <td>
                                    <ui:UIButton runat="server" ID="buttonArrival" ImageUrl="~/images/tick.gif" Text="Arrive On-Site"
                                        OnClick="buttonArrival_Click" meta:resourcekey="buttonArrivalResource1" />
                                </td>
                            </tr>
                        </table>
                        <ui:UIFieldTextBox runat="server" Caption="Remarks" MaxLength="255" PropertyName="Remarks"
                            ID="txtRemarks" InternalControlWidth="95%" meta:resourcekey="txtRemarksResource1">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
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
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabResolution" Caption="Resolution" meta:resourcekey="tabResolutionResource1"
                    BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelResolution" meta:resourcekey="panelResolutionResource1"
                        BorderStyle="NotSet">
                        <ui:UISeparator ID="Separator2" runat="server" Caption="Resolution" meta:resourcekey="Separator2Resource1" />
                        <ui:UIPanel runat="server" ID="panelEquipmentDown" meta:resourcekey="panelEquipmentDownResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldCheckBox runat="server" ID="IsEquipmentDown" PropertyName="IsEquipmentDown"
                                Caption="Equipment Down?" Text="Yes, the equipment was down for a period of time"
                                meta:resourcekey="IsEquipmentDownResource1" OnCheckedChanged="IsEquipmentDown_CheckedChanged"
                                TextAlign="Right">
                            </ui:UIFieldCheckBox>
                            <ui:UIPanel runat="server" ID="panelEquipmentDownDateTime" meta:resourcekey="panelEquipmentDownDateTimeResource1"
                                BorderStyle="NotSet">
                                <ui:UIFieldDateTime runat="server" ID="EquipmentDownStartDateTime" PropertyName="EquipmentDownStartDateTime"
                                    ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="EquipmentDownStartDateTimeResource1"
                                    ShowTimeControls="True" ValidateCompareField='True' ValidationCompareControl="EquipmentDownEndDateTime"
                                    ValidationCompareOperator="LessThanEqual" ValidationCompareType="Date" Caption="Start Down Time "
                                    Span="Half" ValidateRequiredField="True" ShowDateControls="True">
                                </ui:UIFieldDateTime>
                                <ui:UIFieldDateTime runat="server" ID="EquipmentDownEndDateTime" PropertyName="EquipmentDownEndDateTime"
                                    ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="EquipmentDownEndDateTimeResource1"
                                    ShowTimeControls="True" ValidateCompareField='True' ValidationCompareControl="EquipmentDownStartDateTime"
                                    ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" Caption="End Down Time"
                                    Span="Half" ValidateRequiredField="True" ShowDateControls="True">
                                </ui:UIFieldDateTime>
                            </ui:UIPanel>
                        </ui:UIPanel>
                        <ui:UIFieldDropDownList runat="server" ID="PercentageComplete" PropertyName="PercentageComplete"
                            Caption="Complete (%)" Span='Half' ToolTip="The percentage of completion of this work."
                            meta:resourcekey="PercentageCompleteResource1">
                            <Items>
                                <asp:ListItem Text="0" Selected="True" meta:resourceKey="ListItemResource13"></asp:ListItem>
                                <asp:ListItem Text="5" meta:resourceKey="ListItemResource14"></asp:ListItem>
                                <asp:ListItem Text="10" meta:resourceKey="ListItemResource15"></asp:ListItem>
                                <asp:ListItem Text="15" meta:resourceKey="ListItemResource16"></asp:ListItem>
                                <asp:ListItem Text="20" meta:resourceKey="ListItemResource17"></asp:ListItem>
                                <asp:ListItem Text="25" meta:resourceKey="ListItemResource18"></asp:ListItem>
                                <asp:ListItem Text="30" meta:resourceKey="ListItemResource19"></asp:ListItem>
                                <asp:ListItem Text="35" meta:resourceKey="ListItemResource20"></asp:ListItem>
                                <asp:ListItem Text="40" meta:resourceKey="ListItemResource21"></asp:ListItem>
                                <asp:ListItem Text="45" meta:resourceKey="ListItemResource22"></asp:ListItem>
                                <asp:ListItem Text="50" meta:resourceKey="ListItemResource23"></asp:ListItem>
                                <asp:ListItem Text="55" meta:resourceKey="ListItemResource24"></asp:ListItem>
                                <asp:ListItem Text="60" meta:resourceKey="ListItemResource25"></asp:ListItem>
                                <asp:ListItem Text="65" meta:resourceKey="ListItemResource26"></asp:ListItem>
                                <asp:ListItem Text="70" meta:resourceKey="ListItemResource27"></asp:ListItem>
                                <asp:ListItem Text="75" meta:resourceKey="ListItemResource28"></asp:ListItem>
                                <asp:ListItem Text="80" meta:resourceKey="ListItemResource29"></asp:ListItem>
                                <asp:ListItem Text="85" meta:resourceKey="ListItemResource30"></asp:ListItem>
                                <asp:ListItem Text="90" meta:resourceKey="ListItemResource31"></asp:ListItem>
                                <asp:ListItem Text="95" meta:resourceKey="ListItemResource32"></asp:ListItem>
                                <asp:ListItem Text="100" meta:resourceKey="ListItemResource33"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="CauseOfProblemID" PropertyName="CauseOfProblemID"
                            Caption="Cause of Problem" meta:resourcekey="CauseOfProblemIDResource1" OnSelectedIndexChanged="CauseOfProblemID_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="ResolutionID" PropertyName="ResolutionID"
                            Caption="Resolution" meta:resourcekey="ResolutionIDResource1" OnSelectedIndexChanged="ResolutionID_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="ResolutionDescription" runat="server" Caption="Resolution Description"
                            PropertyName="ResolutionDescription" meta:resourcekey="ResolutionDescriptionResource1"
                            ToolTip="Details on the resolution of the problem." InternalControlWidth="95%"
                            MaxLength="255" />
                        <ui:UIPanel runat="server" ID="PanelActualWorkClassificatioin" BorderStyle="NotSet">
                            <ui:UIFieldRadioList runat="server" ID="radioClassification" PropertyName="WorkClassification"
                                ToolTip="Indicate classification of this, whether it's minor or major work."
                                Caption="Work Classification" RepeatDirection="Horizontal" RepeatColumns="3">
                                <Items>
                                    <asp:ListItem Value="0" Text="Minor"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Major"></asp:ListItem>
                                    <asp:ListItem Value="2" Text="Critical"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldDropDownList runat="server" ID="ActualTypeOfWorkID" PropertyName="ActualTypeOfWorkID"
                                Caption="Actual Type of Work" ValidateRequiredField="True" OnSelectedIndexChanged="ActualTypeOfWorkID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="ActualTypeOfServiceID" PropertyName="ActualTypeOfServiceID"
                                Caption="Actual Type of Service" ValidateRequiredField="True" OnSelectedIndexChanged="ActualTypeOfServiceID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="ActualTypeOfProblemID" PropertyName="ActualTypeOfProblemID"
                                Caption="Actual Type of Problem" ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UIFieldDateTime runat="server" ID="ActualStartDateTime" PropertyName="ActualStartDateTime"
                            Caption="Actual Start" ValidateRequiredField="True" ShowTimeControls='True' OnDateTimeChanged="ActualStartDateTime_DateTimeChanged"
                            meta:resourcekey="ActualStartDateTimeResource1" ToolTip="The date/time in which the work actually started."
                            ValidateCompareField='True' ValidationCompareControl="ActualEndDateTime" ValidationCompareOperator="LessThanEqual"
                            ValidationCompareType="Date" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            ShowDateControls="True">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="ActualEndDateTime" PropertyName="ActualEndDateTime"
                            Caption="Actual End" ValidateRequiredField="True" ShowTimeControls='True' meta:resourcekey="ActualEndDateTimeResource1"
                            ToolTip="The date/time in which the work actually completed." ValidateCompareField='True'
                            ValidationCompareControl="ActualStartDateTime" ValidationCompareOperator="GreaterThanEqual"
                            ValidationCompareType="Date" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            ShowDateControls="True">
                        </ui:UIFieldDateTime>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabContract" Caption="Contract" meta:resourcekey="tabContractResource1"
                    BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelContract" meta:resourcekey="panelContractResource1"
                        BorderStyle="NotSet">
                        <ui:UISeparator ID="Separator4" runat="server" Caption="Contract/Vendor" meta:resourcekey="Separator4Resource1" />
                        <ui:UIPanel runat="server" ID="panelVendor" meta:resourcekey="panelVendorResource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldDropDownList runat="server" ID="ContractID" PropertyName="ContractID"
                                Caption="Contract" OnSelectedIndexChanged="ContractID_SelectedIndexChanged" meta:resourcekey="ContractIDResource1"
                                ToolTip="The contract/vendor responsible for this work.">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldLabel runat="server" ID="VendorName" PropertyName="Contract.Vendor.ObjectName"
                                Caption="Vendor" meta:resourcekey="VendorNameResource1" DataFormatString="" />
                            <ui:UIFieldLabel runat="server" ID="ContractName" PropertyName="Contract.ObjectName"
                                Caption="Contract Name" meta:resourcekey="ContractNameResource1" DataFormatString="" />
                            <ui:UIFieldLabel runat="server" ID="ContractStartDate" PropertyName="Contract.ContractStartDate"
                                Caption="Contract Start" Span="Half" meta:resourcekey="ContractStartDateResource1"
                                DataFormatString="{0:dd-MMM-yyyy}" />
                            <ui:UIFieldLabel runat="server" ID="ContractEndDate" PropertyName="Contract.ContractEndDate"
                                Caption="Contract End" Span="Half" meta:resourcekey="ContractEndDateResource1"
                                DataFormatString="{0:dd-MMM-yyyy}" />
                            <ui:UIFieldLabel runat="server" ID="ContactPerson" PropertyName="Contract.ContactPerson"
                                Caption="Contact Person" meta:resourcekey="ContactPersonResource1" DataFormatString="" />
                            <ui:UIFieldLabel runat="server" ID="ContactCellphone" PropertyName="Contract.ContactCellphone"
                                Caption="Cellphone" Span="Half" meta:resourcekey="ContactCellphoneResource1"
                                DataFormatString="" />
                            <ui:UIFieldLabel runat="server" ID="ContactEmail" PropertyName="Contract.ContactEmail"
                                Caption="Email" Span="Half" meta:resourcekey="ContactEmailResource1" DataFormatString="" />
                            <ui:UIFieldLabel runat="server" ID="ContactFax" PropertyName="Contract.ContactFax"
                                Caption="Fax" Span="Half" meta:resourcekey="ContactFaxResource1" DataFormatString="" />
                            <ui:UIFieldLabel runat="server" ID="ContactPhone" PropertyName="Contract.ContactPhone"
                                Caption="Phone" Span="Half" meta:resourcekey="ContactPhoneResource1" DataFormatString="" />
                            <br />
                            <br />
                            <br />
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabCost" Caption="Cost / Charge $" meta:resourcekey="uitabview6Resource1"
                    BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelWorkCost" meta:resourcekey="panelWorkCostResource1"
                        BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelTechnician" BorderStyle="NotSet" meta:resourcekey="panelTechnicianResource1">
                            <ui:UIFieldRadioList runat="server" ID="rdl_AssignmentMode" Caption="Assignment Mode"
                                PropertyName="AssignmentMode" OnSelectedIndexChanged="rdl_AssignmentMode_SelectedIndexChanged"
                                meta:resourcekey="rdl_AssignmentModeResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource38">Manually Assign Any Technicians</asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource35" Text="Manually Assign Technicians by Roster"></asp:ListItem>
                                    <asp:ListItem Value="2" meta:resourcekey="ListItemResource36" Text="Automatically Assign All by Roster"></asp:ListItem>
                                    <asp:ListItem Value="3" meta:resourcekey="ListItemResource37" Text="Automatically Assign One (in Round-Robin Fashion) by Roster"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldDropDownList runat="server" ID="ddl_TechnicianID" Caption="Technician"
                                OnSelectedIndexChanged="ddl_TechnicianID_SelectedIndexChanged" meta:resourcekey="ddl_TechnicianIDResource1">
                            </ui:UIFieldDropDownList>
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelAddSpares" BorderStyle="NotSet" meta:resourcekey="panelAddSparesResource1">
                            <ui:UIButton runat="server" ID="buttonAddSpares" Text="Add Equipment Spares" OnClick="buttonAddSpares_Click"
                                ImageUrl="~/images/add.gif" meta:resourcekey="buttonAddSparesResource1" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelAddMultiple" BorderStyle="NotSet" meta:resourcekey="panelAddMultipleResource1">
                            <ui:UIButton runat="server" ID="buttonAddMaterials" Text="Add Multiple Inventory Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonAddMaterials_Click" CausesValidation="False"
                                meta:resourcekey="buttonAddMaterialsResource1" />
                            <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False" OnClick="buttonItemsAdded_Click"
                                meta:resourcekey="buttonItemsAddedResource1"></ui:UIButton>
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIGridView runat="server" ID="WorkCost" Caption="Work Cost and Labor" PropertyName="WorkCost"
                            SortExpression="[DisplayOrder] ASC, [CostTypeName] ASC, [CraftStore] ASC, [CostDescription] ASC"
                            KeyName="ObjectID" meta:resourcekey="WorkCostResource1" Width="100%" DataKeyNames="ObjectID"
                            GridLines="Both" RowErrorColor="" Style="clear: both;" OnRowDataBound="WorkCost_RowDataBound"
                            ImageRowErrorUrl="" BindObjectsToRows="true" OnAction="WorkCost_Action">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteItem"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                    CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="CheckOutObject"
                                    ConfirmText="Are you sure you wish to check out the selected items?" CommandText="Print Inventory Request"
                                    ImageUrl="~/images/printer.gif" meta:resourceKey="UIGridViewCheckOutObjectCommandResource3" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject"
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="DisplayOrder" HeaderText="No." meta:resourceKey="DisplayOrderColumnResource3"
                                    PropertyName="DisplayOrder" ResourceAssemblyName="" SortExpression="DisplayOrder">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CostTypeName" HeaderText="Type" meta:resourceKey="UIGridViewColumnResource3"
                                    PropertyName="CostTypeName" ResourceAssemblyName="" SortExpression="CostTypeName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CraftStore" HeaderText="Craft / Store" PropertyName="CraftStore"
                                    ResourceAssemblyName="" SortExpression="CraftStore" meta:resourcekey="UIGridViewBoundColumnResource8">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CostDescription" HeaderText="Description" meta:resourceKey="UIGridViewColumnResource4"
                                    PropertyName="CostDescription" ResourceAssemblyName="" SortExpression="CostDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasureText" HeaderText="Unit" PropertyName="UnitOfMeasureText"
                                    ResourceAssemblyName="" SortExpression="UnitOfMeasureText" meta:resourcekey="UIGridViewBoundColumnResource9">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EstimatedUnitCost" DataFormatString="{0:c}"
                                    HeaderText="Est. Unit Cost&lt;br/&gt;" HtmlEncode="False" PropertyName="EstimatedUnitCost"
                                    ResourceAssemblyName="" SortExpression="EstimatedUnitCost" meta:resourcekey="UIGridViewBoundColumnResource10">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EstimatedCostFactor" DataFormatString="{0:#,##0.00}"
                                    HeaderText="Est. Factor" meta:resourceKey="UIGridViewColumnResource6" PropertyName="EstimatedCostFactor"
                                    ResourceAssemblyName="" SortExpression="EstimatedCostFactor">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EstimatedQuantity" DataFormatString="{0:#,##0.00}"
                                    HeaderText="Est. Qty" meta:resourceKey="UIGridViewColumnResource7" PropertyName="EstimatedQuantity"
                                    ResourceAssemblyName="" SortExpression="EstimatedQuantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EstimatedSubTotal" DataFormatString="{0:c}"
                                    HeaderText="Total&lt;br/&gt;" HtmlEncode="False" PropertyName="EstimatedSubTotal"
                                    ResourceAssemblyName="" SortExpression="EstimatedSubTotal" meta:resourcekey="UIGridViewBoundColumnResource11">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ActualUnitCost" DataFormatString="{0:c}" HeaderText="Act. Unit Cost&lt;br/&gt;"
                                    HtmlEncode="False" PropertyName="ActualUnitCost" ResourceAssemblyName="" SortExpression="ActualUnitCost"
                                    meta:resourcekey="UIGridViewBoundColumnResource12">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ActualCostFactor" DataFormatString="{0:#,##0.00}"
                                    HeaderText="Act. Factor" meta:resourceKey="UIGridViewColumnResource10" PropertyName="ActualCostFactor"
                                    ResourceAssemblyName="" SortExpression="ActualCostFactor">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ActualQuantity" DataFormatString="{0:#,##0.00}"
                                    HeaderText="Act. Qty" PropertyName="ActualQuantity" ResourceAssemblyName="" SortExpression="ActualQuantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ActualSubTotal" DataFormatString="{0:c}" HeaderText="Total&lt;br/&gt;"
                                    HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="ActualSubTotal"
                                    ResourceAssemblyName="" SortExpression="ActualSubTotal">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ChargeOut" DataFormatString="{0:c}" HeaderText="Charge&lt;br/&gt;"
                                    HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="ChargeOut"
                                    ResourceAssemblyName="" SortExpression="ChargeOut">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Tax Code">
                                    <HeaderStyle Width="75px" Font-Bold="true" />
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="TaxCodeID" ShowCaption="false" PropertyName="TaxCodeID"
                                            Span="Half" InternalControlWidth="70px" FieldLayout="Flow" OnSelectedIndexChanged="TaxCodeID_SelectedIndexChanged"
                                            ValidateRequiredField="false">
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Tax Amount">
                                    <HeaderStyle Width="35px" Font-Bold="true" />
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="TaxAmount" ShowCaption="false" PropertyName="TaxAmount"
                                            Span="Half" InternalControlWidth="30px" FieldLayout="Flow" DataFormatString="{0:#,##0.00##}"
                                            ValidateRequiredField="false">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="WorkCost_ObjectPanel" meta:resourcekey="WorkCost_ObjectPanelResource1"
                            BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="WorkCost_SubPanel" GridViewID="WorkCost" MultiSelectColumnNames="DisplayOrder,CatalogueID,UnitOfMeasureID,StoreID,StoreBinID,EstimatedQuantity,ActualQuantity,ChargeOut,CostType,EstimatedUnitCost"
                                OnPopulateForm="WorkCost_SubPanel_PopulateForm" OnValidateAndUpdate="WorkCost_SubPanel_ValidateAndUpdate"
                                OnRemoved="WorkCost_SubPanel_Removed"></web:subpanel>
                            <ui:UIFieldRadioList runat="server" ID="WorkCost_CostType" PropertyName="CostType"
                                Caption="Type" OnSelectedIndexChanged="CostType_SelectedIndexChanged" meta:resourcekey="WorkCost_CostTypeResource1"
                                RepeatColumns="0" ValidateRequiredField="true" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Text="Craft/Technician" Value="0" meta:resourceKey="ListItemResource1"></asp:ListItem>
                                    <asp:ListItem Text="Fixed Rate" Value="1" meta:resourcekey="ListItemResource34"></asp:ListItem>
                                    <asp:ListItem Text="Inventory" Value="3" meta:resourceKey="ListItemResource2"></asp:ListItem>
                                    <%--<asp:ListItem Text="Tax Code" Value="4" meta:resourceKey="ListItemTaxCodeResource"></asp:ListItem>--%>
                                    <asp:ListItem Text="Others" Value="2" meta:resourceKey="ListItemResource3"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldDropDownList ID="DisplayOrder" runat="server" Caption="Display Order"
                                Enabled="false" PropertyName="DisplayOrder" Span="Half" ValidateRequiredField="True"
                                meta:resourcekey="DisplayOrderResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIPanel runat="server" ID="WorkCost_Panel1" meta:resourcekey="WorkCost_Panel1Resource1"
                                BorderStyle="NotSet">
                                <ui:UIFieldDropDownList runat="server" ID="WorkCost_CraftID" PropertyName="CraftID"
                                    Caption="Craft" OnSelectedIndexChanged="WorkCost_CraftID_SelectedIndexChanged"
                                    meta:resourcekey="WorkCost_CraftIDResource1" ToolTip="The craft of the technician that will be assigned to the work.">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="WorkCost_UserID" PropertyName="UserID"
                                    Caption="Technician" ValidateRequiredField="True" meta:resourcekey="WorkCost_UserIDResource1"
                                    ToolTip="The technician that will be assigned to the work." OnSelectedIndexChanged="WorkCost_UserID_SelectedIndexChanged">
                                </ui:UIFieldDropDownList>
                            </ui:UIPanel>
                            <%--<ui:UIPanel runat="server" ID="TaxCode_Panel" meta:resourcekey="TaxCode_PanelResource1"
                                BorderStyle="NotSet">
                                <ui:UIFieldDropDownList runat="server" ID="dropTaxCode" PropertyName="TaxCodeID"
                                    ValidateRequiredField="True" Caption="TaxCode" OnSelectedIndexChanged="dropTaxCode_SelectedIndexChanged"
                                    meta:resourcekey="dropTaxCodeResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldTextBox ID="textTaxCodeDescription" runat="server" Caption="Description"
                                    PropertyName="TaxCodeDescription" ValidateRequiredField="True" meta:resourcekey="textTaxCodeDescriptionResource1"
                                    MaxLength="255" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox ID="textTaxCodeCost" runat="server" Caption="Tax Cost" PropertyName="ActualUnitCost"
                                    ValidateRequiredField="True" meta:resourcekey="WorkCost_TaxCodeResource1" ToolTip="The tax cost."
                                    ValidateDataTypeCheck="True" ValidateRangeField="True" ValidationDataType="Currency"
                                    ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                    InternalControlWidth="95%" />
                            </ui:UIPanel>--%>
                            <ui:UIPanel runat="server" ID="WorkCost_Panel3" meta:resourcekey="WorkCost_Panel3Resource1"
                                BorderStyle="NotSet">
                                <ui:UIFieldTextBox ID="WorkCost_Name" runat="server" Caption="Description / Name"
                                    PropertyName="ObjectName" ValidateRequiredField="True" meta:resourcekey="WorkCost_NameResource1"
                                    MaxLength="255" InternalControlWidth="95%" />
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="WorkCost_Panel4_1" BorderStyle="NotSet" meta:resourcekey="WorkCost_Panel4_1Resource1">
                                <ui:UIFieldDropDownList runat="server" ID="WorkCost_StoreID" PropertyName="StoreID"
                                    Caption="Store" Span="Full" OnSelectedIndexChanged="StoreID_SelectedIndexChanged"
                                    ValidateRequiredField="true" meta:resourcekey="StoreIDResource1" />
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="WorkCost_Panel4" BorderStyle="NotSet" meta:resourcekey="WorkCost_Panel4Resource1">
                                <web:searchdialogbox runat="server" ID="searchCatalogs" Title="Search Catalogue Item"
                                    AutoSearchOnLoad="true" AllowMultipleSelection="false" BaseTable="tCatalogue"
                                    SimpleTextboxHint="Enter your search criteria to look for your inventory items. e.g: Name, Stock Code,..."
                                    SearchTextBoxPropertyNames="ObjectName,StockCode,ObjectNumber" MaximumNumberOfResults="100"
                                    SearchType="Word" OnSelected="searchCatalogs_Selected" OnSearched="searchCatalogs_Searched">
                                    <Columns>
                                        <ui:UIGridViewButtonColumn AlwaysEnabled="true" ImageUrl="~/images/tick.gif" CommandName="Select"
                                            ButtonType="Image">
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Catalogue" HeaderStyle-Width="330px" PropertyName="ObjectName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Stock Code" HeaderStyle-Width="70px" PropertyName="StockCode">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Unit Price" HeaderStyle-Width="80px" PropertyName="UnitPrice"
                                            DataFormatString="{0:c}">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Charge Price" HeaderStyle-Width="80px" PropertyName="DefaultChargeOut"
                                            DataFormatString="{0:c}">
                                        </ui:UIGridViewBoundColumn>
                                    </Columns>
                                </web:searchdialogbox>
                                <ui:UIFieldDialogSelection runat="server" ID="WorkCost_CatalogueDialog" Caption="Catalog"
                                    Span="Half" PropertyNameItem="Catalogue.Path" PropertyName="CatalogueID" ImageClearUrl="~/images/cross.gif"
                                    ValidateRequiredField="true" OnControlClicked="WorkCost_CatalogueDialog_ControlClicked">
                                </ui:UIFieldDialogSelection>
                                <ui:UIFieldDropDownList runat="server" ID="WorkCost_StoreBinID" PropertyName="StoreBinID"
                                    ValidateRequiredField="True" Caption="Bin (Avail Qty)" meta:resourcekey="StoreBinIDResource1"
                                    Span="Half" ToolTip="The bin where this item is checked out from.">
                                </ui:UIFieldDropDownList>
                                <%--<ui:UIFieldPopupSelection ID="WorkCost_CatalogueID" runat="server" Caption="Catalog" PropertyNameItem="Catalogue.Path" PropertyName="CatalogueID" ValidateRequiredField="True" meta:resourcekey="WorkCost_CatalogueIDResource1" PopupUrl="../../popup/selectcatalogue/main.aspx" OnSelectedValueChanged="CatalogueID_SelectedValueChanged" />--%>
                                <%--<ui:UIFieldTreeList runat="server" ID="WorkCost_treeCatalogue" Caption="Catalog Item" PropertyName="CatalogueID" ValidateRequiredField="true" OnAcquireTreePopulater="WorkCost_treeCatalogue_AcquireTreePopulater" OnSelectedNodeChanged="WorkCost_treeCatalogue_SelectedNodeChanged">
                                </ui:UIFieldTreeList>--%>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="WorkCost_PanelUOM" BorderStyle="NotSet" meta:resourcekey="WorkCost_PanelUOMResource1">
                                <ui:UIFieldDropDownList runat="server" ID="WorkCost_UnitOfMeasureID" PropertyName="UnitOfMeasureID"
                                    ValidateRequiredField="True" Caption="Unit of Measure" meta:resourcekey="WorkCost_UnitOfMeasureIDResource1" />
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="WorkCost_Panel5" meta:resourcekey="WorkCost_Panel1Resource1"
                                BorderStyle="NotSet">
                                <web:searchdialogbox runat="server" ID="searchFixedRates" Title="Search Charge Rates"
                                    SearchTextBoxPropertyNames="ObjectName,ObjectNumber" SimpleTextboxHint="Enter your search criteria to look for your charge code."
                                    AllowMultipleSelection="false" BaseTable="tFixedRate" MaximumNumberOfResults="30"
                                    AutoSearchOnLoad="true" OnSearched="searchFixedRates_Searched" OnSelected="searchFixedRates_Selected">
                                    <Columns>
                                        <ui:UIGridViewButtonColumn AlwaysEnabled="true" ImageUrl="~/images/tick.gif" CommandName="Click"
                                            ButtonType="Image">
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Name" HeaderStyle-Width="400px" PropertyName="ObjectName">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Code" HeaderStyle-Width="70px" PropertyName="ObjectNumber">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn HeaderText="Charge Price" HeaderStyle-Width="90px" PropertyName="DefaultChargeOut"
                                            DataFormatString="{0:c}">
                                        </ui:UIGridViewBoundColumn>
                                    </Columns>
                                </web:searchdialogbox>
                                <ui:UIFieldDialogSelection runat="server" ID="WorkCost_FixedRateDialog" PropertyName="FixedRateID"
                                    PropertyNameItem="FixedRate.Path" Caption="Fixed Rate" ImageClearUrl="~/images/cross.gif"
                                    ValidateRequiredField="true" OnControlClicked="WorkCost_FixedRateDialog_ControlClicked">
                                </ui:UIFieldDialogSelection>
                                <%--<ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate" PropertyName="FixedRateID"
                                    OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater" OnSelectedNodeChanged="FixedRateID_SelectedNodeChanged"
                                    ValidateRequiredField="True" meta:resourcekey="FixedRateIDResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                                </ui:UIFieldTreeList>--%>
                                <ui:UIFieldLabel runat="server" ID="UnitOfMeasure" Caption="Unit of Measure" PropertyName="FixedRate.UnitOfMeasure.ObjectName"
                                    meta:resourcekey="UnitOfMeasureResource1" DataFormatString="" />
                            </ui:UIPanel>
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr>
                                    <td style="width: 50%">
                                        <ui:UIPanel runat="server" ID="panelEstimatedCost" meta:resourcekey="panelEstimatedCostResource1"
                                            BorderStyle="NotSet">
                                            <ui:UIFieldLabel runat="server" ID="WorkCost_Estimated" Caption="Estimated" Font-Bold="True"
                                                meta:resourcekey="WorkCost_EstimatedResource1" DataFormatString="" />
                                            <ui:UIFieldRadioList runat="server" ID="WorkCost_EstimatedOvertime" PropertyName="EstimatedOvertime"
                                                Caption="Overtime Work?" ValidateRequiredField="True" RepeatColumns="2" OnSelectedIndexChanged="WorkCost_IsOvertime_SelectedIndexChanged"
                                                meta:resourcekey="WorkCost_EstimatedOvertimeResource1" TextAlign="Right">
                                                <Items>
                                                    <asp:ListItem Text="Yes" Value="1" meta:resourceKey="ListItemResource4"></asp:ListItem>
                                                    <asp:ListItem Text="No" Value="0" meta:resourceKey="ListItemResource5"></asp:ListItem>
                                                </Items>
                                            </ui:UIFieldRadioList>
                                            <ui:UIFieldTextBox ID="WorkCost_EstimatedUnitCost" runat="server" Caption="Unit Price"
                                                PropertyName="EstimatedUnitCost" ValidateRequiredField="True" meta:resourcekey="WorkCost_EstimatedUnitCostResource1"
                                                ToolTip="The estimated unit price to be incurred when using this cost." ValidateDataTypeCheck="True"
                                                ValidateRangeField="True" ValidationDataType="Currency" ValidationRangeMin="0"
                                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" InternalControlWidth="95%" />
                                            <ui:UIFieldTextBox ID="WorkCost_EstimatedCostFactor" runat="server" Caption="Price Factor"
                                                PropertyName="EstimatedCostFactor" ValidateRequiredField="True" meta:resourcekey="WorkCost_EstimatedCostFactorResource1"
                                                ToolTip="The estimated price factor to be applied when using this cost." ValidateDataTypeCheck="True"
                                                ValidateRangeField="True" ValidationDataType="Currency" ValidationRangeMin="0"
                                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" InternalControlWidth="95%" />
                                            <ui:UIFieldTextBox ID="WorkCost_EstimatedQuantity" runat="server" Caption="Quantity"
                                                PropertyName="EstimatedQuantity" ValidateRequiredField="True" meta:resourcekey="WorkCost_EstimatedQuantityResource1"
                                                ToolTip="The estimated quantity of the item or resource to be used for this work."
                                                ValidateDataTypeCheck="True" ValidateRangeField="True" ValidationDataType="Currency"
                                                ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                                InternalControlWidth="95%" />
                                        </ui:UIPanel>
                                    </td>
                                    <td style="width: 50%">
                                        <ui:UIPanel runat="server" Style="float: left" ID="panelActualCost" meta:resourcekey="panelActualCostResource1"
                                            BorderStyle="NotSet">
                                            <ui:UIFieldLabel runat="server" ID="WorkCost_Actual" Caption="Actual" Font-Bold="True"
                                                meta:resourcekey="WorkCost_ActualResource1" DataFormatString="" />
                                            <ui:UIFieldRadioList runat="server" ID="WorkCost_ActualOvertime" PropertyName="ActualOvertime"
                                                Caption="Overtime Work?" ValidateRequiredField="True" OnSelectedIndexChanged="WorkCost_IsOvertime_SelectedIndexChanged"
                                                meta:resourcekey="WorkCost_ActualOvertimeResource1" TextAlign="Right">
                                                <Items>
                                                    <asp:ListItem Text="Yes" Value="1" meta:resourceKey="ListItemResource4"></asp:ListItem>
                                                    <asp:ListItem Text="No" Value="0" meta:resourceKey="ListItemResource5"></asp:ListItem>
                                                </Items>
                                            </ui:UIFieldRadioList>
                                            <ui:UIFieldTextBox ID="WorkCost_ActualUnitCost" runat="server" Caption="Unit Price"
                                                PropertyName="ActualUnitCost" ValidateRequiredField="True" meta:resourcekey="WorkCost_ActualUnitCostResource1"
                                                ToolTip="The actual unit price incurred when using this cost." ValidateDataTypeCheck="True"
                                                ValidateRangeField="True" ValidationDataType="Currency" ValidationRangeMin="0"
                                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" InternalControlWidth="95%" />
                                            <ui:UIFieldTextBox ID="WorkCost_ActualCostFactor" runat="server" Caption="Price Factor"
                                                PropertyName="ActualCostFactor" ValidateRequiredField="True" meta:resourcekey="WorkCost_ActualCostFactorResource1"
                                                ToolTip="The actual price factor applied when using this cost." ValidateDataTypeCheck="True"
                                                ValidateRangeField="True" ValidationDataType="Currency" ValidationRangeMin="0"
                                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" InternalControlWidth="95%" />
                                            <ui:UIFieldTextBox ID="WorkCost_ActualQuantity" runat="server" Caption="Quantity"
                                                PropertyName="ActualQuantity" ValidateRequiredField="True" meta:resourcekey="WorkCost_ActualQuantityResource1"
                                                ToolTip="The actual quantity of the item or resource used for this work." ValidateDataTypeCheck="True"
                                                ValidateRangeField="True" ValidationDataType="Currency" ValidationRangeMin="0"
                                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" InternalControlWidth="95%" />
                                        </ui:UIPanel>
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldTextBox ID="WorkCost_ChargeOut" runat="server" Caption="Charge Amount"
                                PropertyName="ChargeOut" Span="Half" ValidateRequiredField="True" meta:resourcekey="WorkCost_ChargeOutResource1"
                                ToolTip="The amount in dollars to be charged to the caller." Style="float: left;
                                table-layout: fixed;" border="0" cellpadding="2" cellspacing="0" Height="20px"
                                Width="49.5%" ValidateDataTypeCheck="True" ValidateRangeField="True" ValidationDataType="Currency"
                                ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                AjaxPostBack="False" IsModifiedByAjax="False" InternalControlWidth="95%" />
                        </ui:UIObjectPanel>
                        <asp:Label ID="SignatureList" runat="server" meta:resourcekey="SignatureListResource1"></asp:Label>
                        <ui:UIButton runat="server" ID="buttonGenerateRFQFromLineItems" Text="Generate WJ from Selected Line Items"
                            ImageUrl="~/images/add.gif" OnClick="buttonGenerateRFQFromLineItems_Click" Visible="false" />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabExternalCost" Caption="External Cost / WJ" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelExternalCost" BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelButtonGenerateWJ" BorderStyle="NotSet">
                            <ui:UIButton runat="server" ID="buttonAddWJ" CommandName="AddWJ" Text="Add Work Justification"
                                ImageUrl="~/images/add.gif" AlwaysEnabled="false" ConfirmText="Please save this Work Order before proceeding to generate WJ, otherwise all your changes will be lost"
                                OnClick="buttonAddWJ_Click" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelGridWorkJustification" BorderStyle="NotSet">
                            <ui:UIGridView runat="server" ID="gridWorkJustifications" DataKeyNames="ObjectID"
                                Caption="Work Justification" OnAction="gridWorkJustifications_Action">
                                <Columns>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" ImageUrl="~/images/edit.gif" AlwaysEnabled="true"
                                        CommandName="EditWJ" ConfirmText="Please save this Work Order before proceeding to edit WJ, otherwise all your changes will be lost.">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" ImageUrl="~/images/view.gif" AlwaysEnabled="true"
                                        CommandName="ViewWJ" ConfirmText="Please save this Work Order before proceeding to view WJ, otherwise all your changes will be lost.">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="WJ Number" PropertyName="ObjectNumber">
                                    </ui:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn HeaderText="Location" PropertyName="Location.ObjectName">
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" HeaderText="Transaction Type"
                                        PropertyName="PurchaseType.ObjectName" ResourceAssemblyName="" SortExpression="PurchaseType.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="AwardedVendors" HeaderText="Awarded Vendor(s)"
                                        PropertyName="AwardedVendors" ResourceAssemblyName="" SortExpression="AwardedVendors">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" PropertyName="Description"
                                        ResourceAssemblyName="" SortExpression="Description">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="DateRequired" DataFormatString="{0:dd-MMM-yyyy}"
                                        HeaderText="Date Required" PropertyName="DateRequired" ResourceAssemblyName=""
                                        SortExpression="DateRequired">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Total Amount" PropertyName="TaskAmount" DataFormatString="{0:c}">
                                    </ui:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status"
                                        PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates"
                                        SortExpression="CurrentActivity.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabChecklist" Caption="Checklist" meta:resourcekey="uitabview7Resource1"
                    BorderStyle="NotSet">
                    <ui:UIFieldTreeList runat="server" ID="Checklist" Caption="Select" PropertyName="ChecklistID"
                        OnSelectedNodeChanged="Checklist_SelectedNodeChanged" OnAcquireTreePopulater="Checklist_AcquireTreePopulater"
                        meta:resourcekey="ChecklistResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                    <br />
                    <ui:UIGridView runat="server" ID="gridChecklist" Caption="Checklist" CheckBoxColumnVisible="False"
                        PropertyName="WorkChecklistItems" SortExpression="StepNumber" OnRowDataBound="gridChecklist_RowDataBound"
                        BindObjectsToRows="True" KeyName="ObjectID" PageSize="200" meta:resourcekey="gridChecklistResource1"
                        Width="100%" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                        ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="StepNumber" HeaderText="Step" meta:resourceKey="UIGridViewColumnResource18"
                                PropertyName="StepNumber" ResourceAssemblyName="" SortExpression="StepNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Description" meta:resourceKey="UIGridViewColumnResource19"
                                PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" Width="50%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourceKey="UIGridViewColumnResource20">
                                <ItemTemplate>
                                    <cc1:UIFieldRadioList ID="ChecklistItem_SelectedResponseID" runat="server" CaptionWidth="1px"
                                        meta:resourceKey="SelectedResponseIDResource1" RepeatColumns="0" TextAlign="Right"
                                        Visible="False">
                                    </cc1:UIFieldRadioList>
                                    <cc1:UIFieldTextBox ID="ChecklistItem_Description" runat="server" CaptionWidth="1px"
                                        InternalControlWidth="95%" MaxLength="255" meta:resourcekey="ChecklistItem_DescriptionResource1"
                                        Visible="False">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Status History" BorderStyle="NotSet"
                    meta:resourcekey="uitabview2Resource2">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1"
                    BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" meta:resourcekey="uitabview2Resource1"
                    BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
