<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Sql" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = (OCase)panel.SessionObject;

        objectBase.ObjectNumberVisible = !currentCase.IsNew;

        if (!IsPostBack && currentCase.IsNew)
        {
            currentCase.ReportedDateTime = DateTime.Now;
            currentCase.RequestorID = AppSession.User.ObjectID;
            currentCase.RequestorName = AppSession.User.ObjectName;
            currentCase.RequestorPhone = AppSession.User.UserBase.Phone;
            currentCase.RequestorFax = AppSession.User.UserBase.Fax;

            currentCase.RequestorEmail = AppSession.User.UserBase.Email;
            currentCase.RequestorCellPhone = AppSession.User.UserBase.Cellphone;
        }

        Location.PopulateTree();
        Equipment.PopulateTree();
        RequestorType.Bind(OCode.GetCodesByType("RequestorType", currentCase.RequestorType));
        BindRequestor(currentCase);

        if (!RequestorID.Visible && panel.SessionObject.IsNew)
            currentCase.RequestorID = AppSession.User.ObjectID;

        panel.ObjectPanel.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Validates and saves the work request object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCase currentCase = panel.SessionObject as OCase;
            panel.ObjectPanel.BindControlsToObject(currentCase);

            // Validate
            //
            if ((objectBase.SelectedAction == "Close" || objectBase.SelectedAction == "Cancel") &&
                !currentCase.ValidateAllDocumentsClosedOrCancelled())
            {
                gridWorks.ErrorMessage = Resources.Errors.Case_RelatedDocumentsNotClosedOrCancelled;
                gridRequestForQuotations.ErrorMessage = Resources.Errors.Case_RelatedDocumentsNotClosedOrCancelled;
                gridPurchaseOrders.ErrorMessage = Resources.Errors.Case_RelatedDocumentsNotClosedOrCancelled;
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            if (!RequestorID.Visible && currentCase.IsNew)
                ((OCase)currentCase).RequestorID = AppSession.User.ObjectID;

            currentCase.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Populates the case sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_ObjectPanel_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        OWork work = (OWork)Work_SubPanel.SessionObject;

        work.WorkDescription = currentCase.ProblemDescription;
        work.Priority = currentCase.Priority;
        work.LocationID = currentCase.LocationID;
        work.EquipmentID = currentCase.EquipmentID;

        Work_Location.PopulateTree();
        Work_Equipment.PopulateTree();

        Work_TypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), work.TypeOfWorkID));
        Work_TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), work.TypeOfServiceID));
        Work_TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", work.TypeOfServiceID, work.TypeOfProblemID));
        
        if (work.ScheduledStartDateTime == null)
        {
            work.ScheduledStartDateTime = DateTime.Now;
        }
        if (work.ScheduledEndDateTime == null)
        {
            work.ScheduledEndDateTime = DateTime.Now.AddDays(1);
        }


        if (work.LocationID != null)
        {
            if (work.IsNew)
                pre_selectAssignmentMode(work);
            else
            {
                if (work.AssignmentMode == 1)
                {
                    List<OTechnicianRosterItem> rosterItem = OTechnicianRosterItem.GetTechnicianRosterItems(work.LocationID, work.ScheduledStartDateTime.Value, (work.AssignmentMode - 1).ToString());
                    ddl_TechnicianID.Bind(OTechnicianRosterItem.GetTechnicians(work, rosterItem));
                }
                else
                    ddl_TechnicianID.Bind(OTechnicianRosterItem.GetTechnicians(work, null));
            }
            //ddl_TechnicianID.Bind(OUser.GetUsersByRoleAndAboveLocation(work.Location, "WORKTECHNICIAN"));
            ddl_SupervisorID.Bind(OUser.GetUsersByRoleAndAboveLocation(work.Supervisor, work.Location, "WORKSUPERVISOR"));
        }
        Work_SubPanel.ObjectPanel.BindObjectToControls(work);

        if (work.CurrentActivity != null &&
            work.CurrentActivity.ObjectName != null)
        {
            panelWorkDetails.Enabled = work.CurrentActivity.ObjectName.Is("Start", "Draft");
            radioAction.Visible = work.CurrentActivity.ObjectName.Is("Start", "Draft");
        }

        Location.Enabled = (work.IsNew);
    }

    public void pre_selectAssignmentMode(OWork work)
    {
        List<OTechnicianRosterItem> techRosterItems = null;
        if (work.Location != null && work.ScheduledStartDateTime != null)
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
        if (work.AssignmentMode > 1)
        {
            if (work.WorkCost != null && work.WorkCost.Count > 0)
            {
                for (int i = 0; i < work.WorkCost.Count; i++)
                    if (work.WorkCost[i].CostType == 0)
                        work.WorkCost.RemoveGuid(work.WorkCost[i].ObjectID.Value);
            }

            work.WorkCost.Clear();
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
    /// Binds data to the requestor drop down list.
    /// </summary>
    /// <param name="workRequest"></param>
    protected void BindRequestor(OCase currentCase)
    {
        RequestorID.Bind(OUser.GetCaseRequestorsOrTenants(currentCase.Location));
    }
    

    /// <summary>
    /// Occurs when user mades selection in the requestor drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestorID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OCase currentCase = (OCase)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(currentCase);

        currentCase.RequestorName = "";
        currentCase.RequestorPhone = "";
        currentCase.RequestorEmail = "";
        currentCase.RequestorFax = "";
        currentCase.RequestorCellPhone = "";

        if (currentCase.RequestorID != null)
        {
            OUser user = TablesLogic.tUser[currentCase.RequestorID.Value];
            if (user != null)
            {
                currentCase.RequestorName = user.ObjectName;
                currentCase.RequestorPhone = user.UserBase.Phone;
                currentCase.RequestorEmail = user.UserBase.Email;
                currentCase.RequestorFax = user.UserBase.Fax;
                currentCase.RequestorCellPhone = user.UserBase.Cellphone;
            }
        }
        panel.ObjectPanel.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Hides/shows elements
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        RequestorType.Visible = RequestorID.SelectedIndex == 0;
        Workflow_Setting();

        NotifyWorkSupervisor.Enabled = radioAction.SelectedValue == "SubmitForAssignment";
        NotifyWorkTechnician.Enabled = radioAction.SelectedValue == "SubmitForExecution";
        ddl_SupervisorID.ValidateRequiredField = ddl_SupervisorID.Enabled = radioAction.SelectedValue == "SubmitForAssignment";
        ddl_TechnicianID.Enabled = radioAction.SelectedValue == "SubmitForExecution";
        radioAction.Enabled = gridTechnician.Rows.Count == 0;
    }

    /// <summary>
    /// Hides/shows controls and action selection for transitting to new state.
    /// </summary>
    protected void Workflow_Setting()
    {
        tabDetails.Enabled = objectBase.CurrentObjectState.Is("Start", "PendingHelpdesk", "PendingExecution");
        tabProblem.Enabled = objectBase.CurrentObjectState.Is("Start", "PendingHelpdesk", "PendingExecution");

        tabWorkAndPurchaseOrders.Visible = objectBase.CurrentObjectState.Is("PendingHelpdesk", "PendingExecution", "Close");
        tabWorkAndPurchaseOrders.Enabled = objectBase.CurrentObjectState.Is("PendingHelpdesk", "PendingExecution");

        panelRequestor.Enabled = panelRequestorDetails.Enabled = (objectBase.CurrentObjectState == "Start");

        ListItem item = objectBase.GetWorkflowRadioListItem("SubmitToHelpdesk");
        if (item != null)
            item.Enabled = Workflow.CurrentUser.HasRole("CASEREQUESTOR");

        ListItem item2 = objectBase.GetWorkflowRadioListItem("SubmitForExecution");
        if (item2 != null)
            item2.Enabled = Workflow.CurrentUser.HasRole("CASEHELPDESK") || !item.Enabled;
        objectBase.UpdateWorkflowActionRadionListActualItems();

        RequestorID.Visible = objectBase.SelectedAction != "SubmitToHelpdesk";
        RequestorID.Enabled = objectBase.SelectedAction != "SubmitToHelpdesk";

        if (objectBase.SelectedAction == "SubmitToHelpdesk")
        {
            RequestorID.SelectedValue = Workflow.CurrentUser.ObjectID.ToString();
            RequestorName.Text = Workflow.CurrentUser.ObjectName;
            RequestorCellPhone.Text = Workflow.CurrentUser.UserBase.Cellphone;
            RequestorFax.Text = Workflow.CurrentUser.UserBase.Fax;
            RequestorEmail.Text = Workflow.CurrentUser.UserBase.Email;
            RequestorPhone.Text = Workflow.CurrentUser.UserBase.Phone;
        }
    }

    /// <summary>
    /// Constructs the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Location_AcquireTreePopulater(object sender)
    {
        OCase currentCase = panel.SessionObject as OCase;
        return new LocationEquipmentTreePopulaterForCapitaland(currentCase.LocationID,
            false, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user selects location in the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        panel.ObjectPanel.BindControlsToObject(currentCase);

        currentCase.EquipmentID = null;
        if (Location.SelectedNode != null)
        {
            if (Location.SelectedNode.Parent != null)
            {
                if (Location.SelectedNode.Parent.Value.StartsWith(">"))
                {
                    currentCase.LocationID = new Guid(Location.SelectedNode.Parent.Parent.Value);
                    currentCase.EquipmentID = new Guid(Location.SelectedNode.Value.Replace(">", ""));
                }
            }
        }
        if (currentCase.EquipmentID != null)
            Equipment.PopulateTree();

        Equipment.PopulateTree();
        BindRequestor(currentCase);
        panel.ObjectPanel.BindObjectToControls(currentCase);
    }


    /// <summary>
    /// Constructs the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Work_Location_AcquireTreePopulater(object sender)
    {
        OWork work = Work_SubPanel.SessionObject as OWork;
        return new LocationEquipmentTreePopulaterForCapitaland(work.LocationID,
            false, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user changes the work location.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        OWork work = Work_SubPanel.SessionObject as OWork;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);

        work.EquipmentID = null;
        if (Work_Location.SelectedNode != null)
        {
            if (Work_Location.SelectedNode.Parent != null)
            {
                if (Work_Location.SelectedNode.Parent.Value.StartsWith(">"))
                {
                    work.LocationID = new Guid(Work_Location.SelectedNode.Parent.Parent.Value);
                    work.EquipmentID = new Guid(Work_Location.SelectedNode.Value.Replace(">", ""));
                }
            }
        }
        if (work.EquipmentID != null)
            Work_Equipment.PopulateTree();

        if (work.LocationID != null)
        {
            pre_selectAssignmentMode(work);
            //ddl_TechnicianID.Bind(OUser.GetUsersByRoleAndAboveLocation(work.Location, "WORKTECHNICIAN"));
            ddl_SupervisorID.Bind(OUser.GetUsersByRoleAndAboveLocation(work.Supervisor, work.Location, "WORKSUPERVISOR"));
        }

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Constructs the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Equipment_AcquireTreePopulater(object sender)
    {
        OCase currentCase = panel.SessionObject as OCase;
        return new EquipmentTreePopulater(currentCase.EquipmentID, false,
        true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user selects an equipment in the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Equipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        panel.ObjectPanel.BindControlsToObject(currentCase);

        if (currentCase.Equipment != null)
        {
            currentCase.Location = currentCase.Equipment.Location;
            BindRequestor(currentCase);
        }
        Location.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Constructs the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Work_Equipment_AcquireTreePopulater(object sender)
    {
        OWork work = (OWork)Work_SubPanel.SessionObject;
        return new EquipmentTreePopulater(work.EquipmentID, false,
            true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when the equipment for this work is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_Equipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OWork work = Work_SubPanel.SessionObject as OWork;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);

        if (work.Equipment != null)
            work.Location = work.Equipment.Location;
        Work_Location.PopulateTree();

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when the type of work changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_TypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)Work_SubPanel.SessionObject;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);

        Work_TypeOfServiceID.Items.Clear();
        Work_TypeOfProblemID.Items.Clear();
        if (work.TypeOfWorkID != null)
            Work_TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), null));

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }


    /// <summary>
    /// Occurs when the type of service changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_TypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)Work_SubPanel.SessionObject;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);

        Work_TypeOfProblemID.Items.Clear();
        if (work.TypeOfServiceID != null)
            Work_TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", work.TypeOfServiceID, null));

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }


    /// <summary>
    /// Occurs when the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;

        OWork work = Work_SubPanel.SessionObject as OWork;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);

        bool exist = false;
        gridTechnician.ErrorMessage = "";
        ddl_SupervisorID.ErrorMessage = "";
        foreach (OWorkCost workcost in work.WorkCost)
        {
            if (workcost.Technician != null)
                exist = true;
        }

        if (work.SupervisorID == null && !exist)
        {
            ddl_SupervisorID.ErrorMessage = Resources.Errors.Case_SelectOneSupervisorOrTechnician;
            gridTechnician.ErrorMessage = Resources.Errors.Case_SelectOneSupervisorOrTechnician;
        }
        currentCase.Works.Add(work);
        panelWorks.BindObjectToControls(currentCase);
    }


    /// <summary>
    /// Populates the request for quotation sub panel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelRequestForQuotation_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;

        if (subpanelRequestForQuotation.IsAddingObject)
        {
            rfq.LocationID = currentCase.LocationID;
            rfq.EquipmentID = currentCase.EquipmentID;
        }
        rfq.Description = currentCase.ProblemDescription;

        treeRFQLocation.PopulateTree();
        treeRFQEquipment.PopulateTree();

        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", rfq.PurchaseTypeID));
        subpanelRequestForQuotation.ObjectPanel.BindObjectToControls(rfq);

        if (rfq.CurrentActivity != null &&
            rfq.CurrentActivity.ObjectName != null)
            panelRequestForQuotationDetails.Enabled = rfq.CurrentActivity.ObjectName.Is("Start", "Draft");
    }


    /// <summary>
    /// Occurs when the user updates the case's RFQ.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelRequestForQuotation_ValidateAndUpdate(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        subpanelRequestForQuotation.ObjectPanel.BindControlsToObject(rfq);

        // Validate
        //

        currentCase.RequestForQuotations.Add(rfq);
        panelRequestForQuotations.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Constructs and returns the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeRFQEquipment_AcquireTreePopulater(object sender)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        return new EquipmentTreePopulater(rfq.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeRFQLocation_AcquireTreePopulater(object sender)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        return new LocationTreePopulaterForCapitaland(rfq.LocationID, false, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    /// <summary>
    /// Occurs when the user selects an item in the location treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeRFQLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        subpanelRequestForQuotation.ObjectPanel.BindControlsToObject(rfq);

        rfq.EquipmentID = null;
        if (treeRFQLocation.SelectedNode != null)
        {
            if (treeRFQLocation.SelectedNode.Parent != null)
            {
                if (treeRFQLocation.SelectedNode.Parent.Value.StartsWith(">"))
                {
                    rfq.LocationID = new Guid(treeRFQLocation.SelectedNode.Parent.Parent.Value);
                    rfq.EquipmentID = new Guid(treeRFQLocation.SelectedNode.Value.Replace(">", ""));
                }
            }
        }
        if (rfq.EquipmentID != null)
            treeRFQEquipment.PopulateTree();

        subpanelRequestForQuotation.ObjectPanel.BindObjectToControls(rfq);
    }


    /// <summary>
    /// Occurs when the user selects an item in the equipment treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeRFQEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        subpanelRequestForQuotation.ObjectPanel.BindControlsToObject(rfq);

        if (rfq.Equipment != null)
            rfq.Location = rfq.Equipment.Location;
        treeRFQLocation.PopulateTree();

        subpanelRequestForQuotation.ObjectPanel.BindObjectToControls(rfq);
    }

    /// <summary>
    /// Occurs when the user edits or adds a new PO.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelPurchaseOrder_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;

        if (subpanelPurchaseOrder.IsAddingObject)
        {
            po.LocationID = currentCase.LocationID;
            po.EquipmentID = currentCase.EquipmentID;
        }
        po.DateOfOrder = DateTime.Today;
        po.Description = currentCase.ProblemDescription;

        treePOLocation.PopulateTree();
        treePOEquipment.PopulateTree();

        dropPOPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", po.PurchaseTypeID));
        subpanelPurchaseOrder.ObjectPanel.BindObjectToControls(po);

        if (po.CurrentActivity != null &&
            po.CurrentActivity.ObjectName != null)
            panelPurchaseOrderDetails.Enabled = po.CurrentActivity.ObjectName.Is("Start", "Draft");
    }
    protected void ddl_TechnicianID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)Work_SubPanel.SessionObject;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);

        if (ddl_TechnicianID.SelectedValue != null)
        {
            OUser user = TablesLogic.tUser.Load(new Guid(ddl_TechnicianID.SelectedValue.ToString()));
            if (user != null)
            {
                if (doesUserExistInWC(work.WorkCost, user.ObjectID) == false)
                    work.AddWorkCost(user);
            }
        }
        ddl_TechnicianID.SelectedValue = null;
        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }
    /// <summary>
    /// Occurs when the user updates the PO.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelPurchaseOrder_ValidateAndUpdate(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        subpanelPurchaseOrder.ObjectPanel.BindControlsToObject(po);

        // Validate
        //

        currentCase.PurchaseOrders.Add(po);
        panelPurchaseOrders.BindObjectToControls(currentCase);
    }


    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treePOLocation_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        return new LocationTreePopulaterForCapitaland(po.LocationID, false, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected void treePOLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        subpanelPurchaseOrder.ObjectPanel.BindControlsToObject(po);

        po.EquipmentID = null;
        if (treePOLocation.SelectedNode != null)
        {
            if (treePOLocation.SelectedNode.Parent != null)
            {
                if (treePOLocation.SelectedNode.Parent.Value.StartsWith(">"))
                {
                    po.LocationID = new Guid(treePOLocation.SelectedNode.Parent.Parent.Value);
                    po.EquipmentID = new Guid(treePOLocation.SelectedNode.Value.Replace(">", ""));
                }
            }
        }
        if (po.EquipmentID != null)
            treePOEquipment.PopulateTree();

        subpanelPurchaseOrder.ObjectPanel.BindObjectToControls(po);
    }
    /// <summary>
    /// Occurs when user changes the scheduled start date time.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ScheduledStartDateTime_DateTimeChanged(object sender, EventArgs e)
    {
        OWork work = Work_SubPanel.SessionObject as OWork;
        panelScheduledStart.BindControlsToObject(work);
        if (work.Location != null)
        {
            pre_selectAssignmentMode(work);
            panelAssignmentMode.BindObjectToControls(work);
            if (work.AssignmentMode > 1)
                ddl_TechnicianID.Visible = false;
            else
                ddl_TechnicianID.Visible = true;
        }
        work.ScheduledEndDateTime = work.ScheduledStartDateTime;
    }
    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treePOEquipment_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        return new EquipmentTreePopulater(po.EquipmentID, false, true,
            Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected void treePOEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        subpanelPurchaseOrder.ObjectPanel.BindControlsToObject(po);

        if (po.Equipment != null)
            po.Location = po.Equipment.Location;
        treePOLocation.PopulateTree();

        subpanelPurchaseOrder.ObjectPanel.BindObjectToControls(po);
    }

    protected void rdl_AssignmentMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = Work_SubPanel.SessionObject as OWork;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);
        List<OTechnicianRosterItem> rosterITem = work.AssignmentMode == 0 ? null : OTechnicianRosterItem.GetTechnicianRosterItems(work.LocationID, work.ScheduledStartDateTime, (work.AssignmentMode - 1).ToString());
        List<OUser> technicians = OTechnicianRosterItem.GetTechnicians(work, rosterITem);
        if (work.AssignmentMode == 0 || work.AssignmentMode == 1)
        {

            ddl_TechnicianID.Bind(null);
            ddl_TechnicianID.Bind(technicians);
        }
        else
        {
            if (technicians.Count > 0)
            {
                work.WorkCost.Clear();
                foreach (OUser user in technicians)
                {
                    if (doesUserExistInWC(work.WorkCost, user.ObjectID) == false)
                        work.AddWorkCost(user);
                }
            }
            ddl_TechnicianID.SelectedValue = null;

        }
        if (work.AssignmentMode > 1)
            ddl_TechnicianID.Visible = false;
        else
            ddl_TechnicianID.Visible = true;
        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }

    
    /// <summary>
    /// Occurs when the action radio button changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioAction_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (radioAction.SelectedValue == "SubmitForAssignment")
        {
            NotifyWorkSupervisor.Checked = true;
            NotifyWorkTechnician.Checked = false;
        }
        if (radioAction.SelectedValue == "SubmitForExecution")
        {
            NotifyWorkSupervisor.Checked = false;
            NotifyWorkTechnician.Checked = true;
        }
    }

    protected void gridWorks_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "OpenObject")
        {
            Window.OpenEditObjectPage(this, "OWork", dataKeys[0].ToString(), "");
        }
    }

    
    protected void gridRequestForQuotations_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "OpenObject")
        {
            Window.OpenEditObjectPage(this, "ORequestForQuotation", dataKeys[0].ToString(), "");
        }
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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
        <web:object runat="server" ID="panel" Caption="Case" BaseTable="tCase" OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberCaption="Case Number" ObjectNumberEnabled="false" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:uifielddatetime runat="server" id="dateReportedDateTime" Caption="Reported Date/Time" PRopertyName="ReportedDateTime" ValidaterequiredField="True" ShowTimeControls="True" meta:resourcekey="dateReportedDateTimeResource1" ShowDateControls="True">
                    </ui:uifielddatetime>
                    <ui:UIFieldTreeList runat="server" ID="Location" Caption="Location" OnSelectedNodeChanged="Location_SelectedNodeChanged" ValidateRequiredField="True" OnAcquireTreePopulater="Location_AcquireTreePopulater" ToolTip="Use this to select the location that this case applies to." PropertyName="LocationID" meta:resourcekey="LocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                    <ui:UIFieldTreeList runat="server" ID="Equipment" Caption="Equipment" OnSelectedNodeChanged="Equipment_SelectedNodeChanged" OnAcquireTreePopulater="Equipment_AcquireTreePopulater" ToolTip="Use this to select the equipment that this case applies to." PropertyName="EquipmentID" meta:resourcekey="EquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="LocationHistory" 
                        PropertyName="LocationHistoryForOneMonth" CheckBoxColumnVisible="False" 
                        Caption="Location History" Width="100%" 
                        meta:resourcekey="LocationHistoryResource1" PagingEnabled="True" 
                        RowErrorColor="" DataKeyNames="ObjectID" GridLines="Both" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Case Number" meta:resourceKey="UIGridViewColumnResource9" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" HeaderText="Date/Time" meta:resourceKey="UIGridViewColumnResource10" PropertyName="CreatedDateTime" ResourceAssemblyName="" SortExpression="CreatedDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="RequestorName" HeaderText="Requestor Name" meta:resourceKey="UIGridViewColumnResource11" PropertyName="RequestorName" ResourceAssemblyName="" SortExpression="RequestorName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ProblemDescription" HeaderText="Problem Description" meta:resourceKey="UIGridViewColumnResource12" PropertyName="ProblemDescription" ResourceAssemblyName="" SortExpression="ProblemDescription">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Priority" HeaderText="Priority" meta:resourceKey="UIGridViewColumnResource13" PropertyName="Priority" ResourceAssemblyName="" SortExpression="Priority">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location" HeaderText="Location" meta:resourceKey="UIGridViewColumnResource14" PropertyName="Location" ResourceAssemblyName="" SortExpression="Location">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Equipment" HeaderText="Equipment" meta:resourceKey="UIGridViewColumnResource15" PropertyName="Equipment" ResourceAssemblyName="" SortExpression="Equipment">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="StatusName" HeaderText="Status" meta:resourceKey="UIGridViewColumnResource16" PropertyName="StatusName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="StatusName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabProblem" Caption="Problem" meta:resourcekey="tabWorkResource1" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelRequestor" meta:resourcekey="panelRequestorResource1" BorderStyle="NotSet">
                        <ui:UISeparator ID="sep1" runat="server" Caption="Requestor" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldSearchableDropDownList runat="server" ID="RequestorID" PropertyName="RequestorID" Caption="Requestor" OnSelectedIndexChanged="RequestorID_SelectedIndexChanged" ToolTip="The Requestor that made the request for this work. Leave this empty if the Requestor does not exist in this list. You can key in his or her name below in the 'Name' field." meta:resourcekey="RequestorIDResource2" MaximumNumberOfItems="100" SearchInterval="300">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="RequestorType" PropertyName="RequestorType" Caption="Requestor Type" ToolTip="The type of Requestor." meta:resourcekey="RequestorTypeResource2">
                        </ui:UIFieldDropDownList>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelRequestorDetails" meta:resourcekey="panelRequestorDetailsResource1" BorderStyle="NotSet">
                        <ui:UIFieldTextBox ID="RequestorName" runat="server" Caption="Name" PropertyName="RequestorName" ValidateRequiredField="True" ToolTip="The name of the Requestor to refer by." meta:resourcekey="RequestorNameResource2" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="RequestorCellPhone" runat="server" Caption="Cell Phone" PropertyName="RequestorCellPhone" Span="Half" meta:resourcekey="RequestorCellResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="RequestorEmail" runat="server" Caption="Email" PropertyName="RequestorEmail" Span="Half" meta:resourcekey="RequestorEmailResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="RequestorFax" runat="server" Caption="Fax" PropertyName="RequestorFax" Span="Half" meta:resourcekey="RequestorFaxResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="RequestorPhone" runat="server" Caption="Phone" PropertyName="RequestorPhone" Span="Half" meta:resourcekey="RequestorPhoneResource1" InternalControlWidth="95%" />
                    </ui:UIPanel>
                    <ui:UISeparator ID="Separator1" runat="server" Caption="Problem" meta:resourcekey="Separator1Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="Priority" PropertyName="Priority" Caption="Priority" ValidateRequiredField="True" Span="Half" meta:resourcekey="PriorityResource1">
                        <Items>
                            <asp:ListItem meta:resourcekey="ListItemResource5"></asp:ListItem>
                            <asp:ListItem Text="0 (Lowest)" Selected="True" Value="0" meta:resourcekey="ListItemResource1"></asp:ListItem>
                            <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource2"></asp:ListItem>
                            <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource3"></asp:ListItem>
                            <asp:ListItem Text="3 (Highest)" Value="3" meta:resourcekey="ListItemResource4"></asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox ID="ProblemDescription" runat="server" Caption="Problem Description" PropertyName="ProblemDescription" ValidateRequiredField="True" MaxLength="255" TextMode="MultiLine" Rows="3" meta:resourcekey="ProblemDescriptionResource1" InternalControlWidth="95%" />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="RequestorHistory" 
                        PropertyName="RequestorHistoryForOneMonth" Caption="Requestor History" 
                        Width="100%" CheckBoxColumnVisible="False" 
                        meta:resourcekey="RequestorHistoryResource1" PagingEnabled="True" 
                        RowErrorColor="" DataKeyNames="ObjectID" GridLines="Both" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Case Number" meta:resourceKey="UIGridViewColumnResource17" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" HeaderText="Date/Time" meta:resourceKey="UIGridViewColumnResource18" PropertyName="CreatedDateTime" ResourceAssemblyName="" SortExpression="CreatedDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="RequestorName" HeaderText="Requestor Name" meta:resourceKey="UIGridViewColumnResource19" PropertyName="RequestorName" ResourceAssemblyName="" SortExpression="RequestorName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ProblemDescription" HeaderText="Problem Description" meta:resourceKey="UIGridViewColumnResource20" PropertyName="ProblemDescription" ResourceAssemblyName="" SortExpression="ProblemDescription">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Priority" HeaderText="Priority" meta:resourceKey="UIGridViewColumnResource21" PropertyName="Priority" ResourceAssemblyName="" SortExpression="Priority">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location" HeaderText="Location" meta:resourceKey="UIGridViewColumnResource22" PropertyName="Location" ResourceAssemblyName="" SortExpression="Location">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Equipment" HeaderText="Equipment" meta:resourceKey="UIGridViewColumnResource23" PropertyName="Equipment" ResourceAssemblyName="" SortExpression="Equipment">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="StatusName" HeaderText="Status" meta:resourceKey="UIGridViewColumnResource24" PropertyName="StatusName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="StatusName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabWorkAndPurchaseOrders" Caption="Work" meta:resourcekey="tabWorkAndPurchaseOrdersResource1" BorderStyle="NotSet">
                    <ui:UIFieldCheckBox runat="server" ID="checkIsAutoClose" PropertyName="IsAutoClose" Caption="Auto Closure" Text="Yes, automatically close this case when all related documents below are closed or cancelled." meta:resourcekey="checkIsAutoCloseResource1" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIPanel runat="server" ID="panelWorks" meta:resourcekey="panelWorksResource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridWorks" PropertyName="Works" 
                            Caption="Works" meta:resourcekey="WorksResource1" OnAction="gridWorks_Action" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="OpenObject" ConfirmText="Are you sure you wish to open this Work for editing? Please remember to save the Case, otherwise changes that you have made will be lost." ImageUrl="~/images/folder.png" meta:resourcekey="UIGridViewButtonColumnResource5">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Work Number" meta:resourceKey="UIGridViewColumnResource3" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment" meta:resourceKey="UIGridViewBoundColumnResource2" PropertyName="Equipment.Path" ResourceAssemblyName="" SortExpression="Equipment.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TypeOfWork.ObjectName" HeaderText="Type of Work" meta:resourceKey="UIGridViewColumnResource4" PropertyName="TypeOfWork.ObjectName" ResourceAssemblyName="" SortExpression="TypeOfWork.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TypeOfService.ObjectName" HeaderText="Type of Service" meta:resourceKey="UIGridViewColumnResource5" PropertyName="TypeOfService.ObjectName" ResourceAssemblyName="" SortExpression="TypeOfService.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TypeOfProblem.ObjectName" HeaderText="Type of Problem" meta:resourceKey="UIGridViewBoundColumnResource3" PropertyName="TypeOfProblem.ObjectName" ResourceAssemblyName="" SortExpression="TypeOfProblem.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Priority" HeaderText="Priority" meta:resourceKey="UIGridViewBoundColumnResource4" PropertyName="Priority" ResourceAssemblyName="" SortExpression="Priority">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="WorkDescription" HeaderText="Work Description" meta:resourceKey="UIGridViewColumnResource6" PropertyName="WorkDescription" ResourceAssemblyName="" SortExpression="WorkDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourceKey="UIGridViewColumnResource8" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIPanel>
                    <ui:UIObjectPanel runat="server" ID="Work_ObjectPanel" meta:resourcekey="Work_ObjectPanelResource1" BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="Work_SubPanel" GridViewID="gridWorks" OnPopulateForm="Work_ObjectPanel_PopulateForm" OnValidateAndUpdate="Work_SubPanel_ValidateAndUpdate" meta:resourcekey="Work_SubPanelResource1"></web:subpanel>
                        <ui:UIPanel runat="server" ID="panelWorkDetails" meta:resourcekey="panelWorkDetailsResource1" BorderStyle="NotSet">
                            <ui:uifieldradiolist runat="server" id="radioAction" Caption="Action" ValidaterequiredField="True" OnSelectedIndexChanged="radioAction_SelectedIndexChanged" PropertyName="EventToTrigger" meta:resourcekey="radioActionResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="SubmitForAssignment" Text="Submit for Assignment" meta:resourcekey="ListItemResource6"></asp:ListItem>
                                    <asp:ListItem Value="SubmitForExecution" Text="Submit for Execution" meta:resourcekey="ListItemResource7"></asp:ListItem>
                                </Items>
                            </ui:uifieldradiolist>
                            <ui:UIFieldTreeList runat="server" ID="Work_Location" Caption="Location" OnSelectedNodeChanged="Work_Location_SelectedNodeChanged" OnAcquireTreePopulater="Work_Location_AcquireTreePopulater" ToolTip="Use this to select the location that this work applies to." PropertyName="LocationID" meta:resourcekey="Work_LocationResource1" ValidateRequiredField='True' Span="Half" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldTreeList runat="server" ID="Work_Equipment" Caption="Equipment" OnSelectedNodeChanged="Work_Equipment_SelectedNodeChanged" OnAcquireTreePopulater="Work_Equipment_AcquireTreePopulater" ToolTip="Use this to select the equipment that this work applies to." PropertyName="EquipmentID" meta:resourcekey="Work_EquipmentResource1" Span="Half" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <br />
                            <ui:UIFieldRadioList ID="IsChargedToCaller" runat="server" Caption="Charge" PropertyName="IsChargedToCaller" ToolTip="Indicates if this work should be charged to the caller when it is finally completed." meta:resourcekey="IsChargedToCallerResource2" Width="99%" ValidateRequiredField="True" RepeatColumns="0" TextAlign="Right">
                                <Items>
                                    <asp:listitem value="1" meta:resourcekey="ListItemResource8" Text="Yes "></asp:listitem>
                                    <asp:listitem value="0" meta:resourcekey="ListItemResource13" Text="No "></asp:listitem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:uipanel runat="server" id="panelTypeOfWork" BorderStyle="NotSet" meta:resourcekey="panelTypeOfWorkResource1">
                                <ui:UIFieldDropDownList runat="server" ID="Work_TypeOfWorkID" PropertyName="TypeOfWorkID" Caption="Type of Work" ValidateRequiredField="True" OnSelectedIndexChanged="Work_TypeOfWorkID_SelectedIndexChanged" meta:resourcekey="Work_TypeOfWorkIDResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="Work_TypeOfServiceID" PropertyName="TypeOfServiceID" Caption="Type of Service" ValidateRequiredField="True" OnSelectedIndexChanged="Work_TypeOfServiceID_SelectedIndexChanged" meta:resourcekey="Work_TypeOfServiceIDResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="Work_TypeOfProblemID" PropertyName="TypeOfProblemID" Caption="Type of Problem" ValidateRequiredField="True" meta:resourcekey="Work_TypeOfProblemIDResource1">
                                </ui:UIFieldDropDownList>
                            </ui:uipanel>
                            <ui:UIFieldDropDownList runat="server" ID="UIFieldDropDownList1" PropertyName="Priority" Caption="Priority" ValidateRequiredField="True" Span="Half" meta:resourcekey="PriorityResource1">
                                <Items>
                                    <asp:ListItem meta:resourcekey="ListItemResource14"></asp:ListItem>
                                    <asp:ListItem Text="0 (Lowest)" Selected="True" Value="0" meta:resourceKey="ListItemResource9"></asp:ListItem>
                                    <asp:ListItem Text="1" Value="1" meta:resourceKey="ListItemResource10"></asp:ListItem>
                                    <asp:ListItem Text="2" Value="2" meta:resourceKey="ListItemResource11"></asp:ListItem>
                                    <asp:ListItem Text="3 (Highest)" Value="3" meta:resourceKey="ListItemResource12"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox ID="WorkDescription" runat="server" Caption="Work Description" PropertyName="WorkDescription" ValidateRequiredField="True" MaxLength="255" meta:resourcekey="WorkDescriptionResource2" InternalControlWidth="95%" />
                            <ui:UIPanel runat="server" ID="panelScheduledStart" meta:resourcekey="panelScheduledStartResource1" BorderStyle="NotSet">
                                <ui:UIFieldDateTime runat="server" ID="ScheduledStartDateTime" PropertyName="ScheduledStartDateTime" Caption="Scheduled Start" ValidateRequiredField="True" ShowTimeControls='True' OnDateTimeChanged="ScheduledStartDateTime_DateTimeChanged" ToolTip="The date/time in which the work is scheduled to start." ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="ScheduledStartDateTimeResource2" ValidateCompareField='True' ValidationCompareControl="ScheduledEndDateTime" ValidationCompareType="Date" ValidationCompareOperator="LessThanEqual" ShowDateControls="True" Span="Half">
                                </ui:UIFieldDateTime>
                                <ui:UIFieldDateTime runat="server" ID="ScheduledEndDateTime" PropertyName="ScheduledEndDateTime" Caption="Scheduled End" ValidateRequiredField="True" ShowTimeControls='True' ToolTip="The date/time in which the work is scheduled to complete." ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="ScheduledEndDateTimeResource2" ValidateCompareField="True" ValidationCompareControl="ScheduledStartDateTime" ValidationCompareType="Date" ValidationCompareOperator="GreaterThanEqual" ShowDateControls="True" Span="Half">
                                </ui:UIFieldDateTime>
                            </ui:UIPanel>
                            <ui:uipanel runat="server" id="panelAssignment" BorderStyle="NotSet" meta:resourcekey="panelAssignmentResource1">
                                <ui:UIFieldCheckBox runat="server" ID="NotifyWorkSupervisor" PropertyName="NotifyWorkSupervisor" Caption="Notify Supervisor" meta:resourcekey="NotifyWorkSupervisorResource1" TextAlign="Right" />
                                <ui:UIFieldCheckBox runat="server" ID="NotifyWorkTechnician" PropertyName="NotifyWorkTechnician" Caption="Notify Technician" meta:resourcekey="NotifyWorkTechnicianResource1" TextAlign="Right" />
                                <ui:UIFieldDropDownList runat="server" ID="ddl_SupervisorID" PropertyName="SupervisorID" Caption="Supervisor to Notify" meta:resourcekey="ddl_SupervisorIDResource1" >
                                </ui:UIFieldDropDownList>
                                <ui:UIPanel runat="server" ID="panelAssignmentMode" BorderStyle="NotSet" meta:resourcekey="panelAssignmentModeResource1">
                                    <ui:UIFieldRadioList runat="server" ID="rdl_AssignmentMode" Caption="Assignment Mode" PropertyName="AssignmentMode" OnSelectedIndexChanged="rdl_AssignmentMode_SelectedIndexChanged" meta:resourcekey="rdl_AssignmentModeResource1" TextAlign="Right">
                                        <Items>
                                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource15" 
                                                Text="Manually assign from all available technicians"></asp:ListItem>
                                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource16" 
                                                Text="Manually assign technicians by their roster"></asp:ListItem>
                                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource17" 
                                                Text="Automatically assign technicians by their roster"></asp:ListItem>
                                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource18" 
                                                Text="Automatically Assign One (in Round-Robin Fashion) by Roster"></asp:ListItem>
                                        </Items>
                                    </ui:UIFieldRadioList>
                                    <ui:UIFieldDropDownList runat="server" ID="ddl_TechnicianID" Caption="Technician" OnSelectedIndexChanged="ddl_TechnicianID_SelectedIndexChanged" meta:resourcekey="ddl_TechnicianIDResource1">
                                    </ui:UIFieldDropDownList>
                                    <ui:UIGridView runat="server" ID="gridTechnician" PropertyName="WorkCost" 
                                        BindObjectsToRows="True" Caption="Technician" SortExpression="ObjectName" 
                                        DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;" 
                                        meta:resourcekey="gridTechnicianResource1" ImageRowErrorUrl="">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this user?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource3">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource20" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </ui:UIPanel>
                            </ui:uipanel>
                            <ui:UIObjectPanel runat="server" ID="panelTechnician" BorderStyle="NotSet" meta:resourcekey="panelTechnicianResource1">
                                <web:subpanel runat="server" ID="subpanelTechnician" GridViewID="gridTechnician" />
                            </ui:UIObjectPanel>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelRequestForQuotations" meta:resourcekey="panelRequestForQuotationsResource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridRequestForQuotations" 
                            PropertyName="RequestForQuotations" Caption="Work Justifications" 
                            meta:resourcekey="gridRequestForQuotationsResource1" 
                            OnAction="gridRequestForQuotations_Action" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource3" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource4" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource6">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="OpenObject" ConfirmText="Are you sure you wish to open this Work Justification for editing? Please remember to save the Case, otherwise changes that you have made will be lost." ImageUrl="~/images/folder.png" meta:resourcekey="UIGridViewButtonColumnResource7">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="RFQ Number" meta:resourceKey="UIGridViewBoundColumnResource5" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" meta:resourceKey="UIGridViewBoundColumnResource6" PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment" meta:resourceKey="UIGridViewBoundColumnResource7" PropertyName="Equipment.Path" ResourceAssemblyName="" SortExpression="Equipment.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourceKey="UIGridViewBoundColumnResource8" PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DateRequired" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Date Required" meta:resourceKey="UIGridViewBoundColumnResource9" PropertyName="DateRequired" ResourceAssemblyName="" SortExpression="DateRequired">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" HeaderText="Type" meta:resourceKey="UIGridViewBoundColumnResource10" PropertyName="PurchaseType.ObjectName" ResourceAssemblyName="" SortExpression="PurchaseType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourceKey="UIGridViewBoundColumnResource11" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIPanel>
                    <ui:UIObjectPanel runat="server" ID="panelRequestForQuotation" meta:resourcekey="panelRequestForQuotationResource1" BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="subpanelRequestForQuotation" GridViewID="gridRequestForQuotations" OnPopulateForm="subpanelRequestForQuotation_PopulateForm" OnValidateAndUpdate="subpanelRequestForQuotation_ValidateAndUpdate" meta:resourcekey="subpanelRequestForQuotationResource1"></web:subpanel>
                        <ui:UIPanel runat="server" ID="panelRequestForQuotationDetails" meta:resourcekey="panelRequestForQuotationDetailsResource1" BorderStyle="NotSet">
                            <ui:UIFieldTreeList runat="server" ID="treeRFQLocation" Caption="Location" ToolTip="Use this to select the location that this work applies to." PropertyName="LocationID" ValidateRequiredField='True' OnSelectedNodeChanged="treeRFQLocation_SelectedNodeChanged" OnAcquireTreePopulater="treeRFQLocation_AcquireTreePopulater" meta:resourcekey="treeRFQLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldTreeList runat="server" ID="treeRFQEquipment" Caption="Equipment" ToolTip="Use this to select the equipment that this work applies to." PropertyName="EquipmentID" OnSelectedNodeChanged="treeRFQEquipment_SelectedNodeChanged" OnAcquireTreePopulater="treeRFQEquipment_AcquireTreePopulater" meta:resourcekey="treeRFQEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" MaxLength="255" PropertyName="Description" ValidateRequiredField="True" meta:resourcekey="textDescriptionResource1" InternalControlWidth="95%">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDateTime runat="server" ID="dateDateRequired" Caption="Date Required" PropertyName="DateRequired" ValidateRequiredField="True" meta:resourcekey="dateDateRequiredResource1" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDropDownList runat="server" ID="dropPurchaseType" Caption="Purchase Type" PropertyName="PurchaseTypeID" ValidateRequiredField="True" meta:resourcekey="dropPurchaseTypeResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelPurchaseOrders" meta:resourcekey="panelPurchaseOrdersResource1" visible="False" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridPurchaseOrders" 
                            PropertyName="PurchaseOrders" Caption="Purchase Orders" 
                            meta:resourcekey="gridPurchaseOrdersResource1" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource5" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource6" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource8">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource9">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="PO Number" meta:resourceKey="UIGridViewBoundColumnResource12" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" meta:resourceKey="UIGridViewBoundColumnResource13" PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment" meta:resourceKey="UIGridViewBoundColumnResource14" PropertyName="Equipment.Path" ResourceAssemblyName="" SortExpression="Equipment.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourceKey="UIGridViewBoundColumnResource15" PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DateRequired" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Date Required" meta:resourceKey="UIGridViewBoundColumnResource16" PropertyName="DateRequired" ResourceAssemblyName="" SortExpression="DateRequired">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DateOfOrder" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Date of PO" meta:resourceKey="UIGridViewBoundColumnResource17" PropertyName="DateOfOrder" ResourceAssemblyName="" SortExpression="DateOfOrder">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" HeaderText="Type" meta:resourceKey="UIGridViewBoundColumnResource18" PropertyName="PurchaseType.ObjectName" ResourceAssemblyName="" SortExpression="PurchaseType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourceKey="UIGridViewBoundColumnResource19" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIPanel>
                    <ui:UIObjectPanel runat="server" ID="panelPurchaseOrder" meta:resourcekey="panelPurchaseOrderResource1" BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="subpanelPurchaseOrder" GridViewID="gridPurchaseOrders" OnPopulateForm="subpanelPurchaseOrder_PopulateForm" OnValidateAndUpdate="subpanelPurchaseOrder_ValidateAndUpdate" meta:resourcekey="subpanelPurchaseOrderResource1"></web:subpanel>
                        <ui:UIPanel runat="server" ID="panelPurchaseOrderDetails" meta:resourcekey="panelPurchaseOrderDetailsResource1" BorderStyle="NotSet">
                            <ui:UIFieldTreeList runat="server" ID="treePOLocation" Caption="Location" ToolTip="Use this to select the location that this work applies to." PropertyName="LocationID" ValidateRequiredField='True' OnAcquireTreePopulater="treePOLocation_AcquireTreePopulater" OnSelectedNodeChanged="treePOLocation_SelectedNodeChanged" meta:resourcekey="treePOLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldTreeList runat="server" ID="treePOEquipment" Caption="Equipment" ToolTip="Use this to select the equipment that this work applies to." PropertyName="EquipmentID" OnAcquireTreePopulater="treePOEquipment_AcquireTreePopulater" OnSelectedNodeChanged="treePOEquipment_SelectedNodeChanged" meta:resourcekey="treePOEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldTextBox runat="server" ID="textPODescription" Caption="Description" MaxLength="255" PropertyName="Description" ValidateRequiredField="True" meta:resourcekey="textPODescriptionResource1" InternalControlWidth="95%">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDateTime runat="server" ID="textPODateOfOrder" Caption="Date of PO" PropertyName="DateOfOrder" ValidateRequiredField="True" Span="Half" meta:resourcekey="textPODateOfOrderResource1" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="textPODateRequired" Caption="Date Required" PropertyName="DateRequired" ValidateRequiredField="True" Span="Half" meta:resourcekey="textPODateRequiredResource1" ShowDateControls="True">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDropDownList runat="server" ID="dropPOPurchaseType" Caption="Purchase Type" PropertyName="PurchaseTypeID" ValidateRequiredField="True" meta:resourcekey="dropPOPurchaseTypeResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabStatusHistory" Caption="Status History" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview2Resource2">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                    <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments" meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
