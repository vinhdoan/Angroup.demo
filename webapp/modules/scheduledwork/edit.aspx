<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
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
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;

        if (Request["TREEOBJID"] != null)
        {
            Guid id = Security.DecryptGuid(Request["TREEOBJID"]);

            OLocation location = TablesLogic.tLocation[id];
            if (location == null || location.IsPhysicalLocation == 0)
            {
                OEquipment equipment = TablesLogic.tEquipment[id];
                if (equipment != null && equipment.IsPhysicalEquipment == 1)
                {
                    scheduledWork.Equipment = equipment;
                    scheduledWork.Location = equipment.Location;
                }
            }
            else
                scheduledWork.Location = location;
        }
        if (Request["ContractID"] != null)
        {
            Guid id = Security.DecryptGuid(Request["ContractID"]);
            scheduledWork.ContractID = id;
            panelContract.Enabled = false;
        }

        objectBase.ObjectNumberVisible = !scheduledWork.IsNew;

        Location.PopulateTree();
        Equipment.PopulateTree();
        CalendarID.Bind(OCalendar.GetAllCalendars());

        BindCodes(scheduledWork);
        ContractID.Bind(OContract.GetContractsByScheduledWork(scheduledWork, scheduledWork.ContractID), "Contract", "ObjectID");
        //BindParameters(scheduledWork);
        BindEquipmentLocationType(scheduledWork);
        BindEquipmentLocationListWithoutStagger(scheduledWork);

        Works.Columns[1].Visible = AppSession.User.AllowViewAll("OWork");

        panel.ObjectPanel.BindObjectToControls(scheduledWork);

    }

    /// <summary>
    /// Binds data to the schedule work equipment list box.
    /// </summary>
    /// <param name="scheduledWork"></param>
    protected void BindEquipmentLocationListWithoutStagger(OScheduledWork scheduledWork)
    {
        if (scheduledWork.EquipmentLocation == 0)
        {
            // schedule for equipment
            //
            if (scheduledWork.Equipment != null)
                ScheduledWorkEquipment.Bind(scheduledWork.Equipment.GetEquipmentByEquipmentType(scheduledWork.EquipmentType));
            else if (scheduledWork.Location != null)
                ScheduledWorkEquipment.Bind(scheduledWork.Location.GetEquipmentByEquipmentType(scheduledWork.EquipmentType));
        }
        else
        {
            // schedule for location
            //
            if (scheduledWork.Location != null)
                ScheduledWorkLocation.Bind(scheduledWork.Location.GetLocationByLocationType(scheduledWork.LocationType));
        }
    }

    /// <summary>
    /// Binds data to the schedule work equipment list box.
    /// </summary>
    /// <param name="scheduledWork"></param>
    protected void BindEquipmentLocationList(OScheduledWork scheduledWork)
    {
        scheduledWork.CreateStaggeredEquipmentLocation();
        if (scheduledWork.EquipmentLocation == 0)
        {
            // schedule for equipment
            //
            if (scheduledWork.Equipment != null)
                ScheduledWorkEquipment.Bind(scheduledWork.Equipment.GetEquipmentByEquipmentType(scheduledWork.EquipmentType));
            else if (scheduledWork.Location != null)
                ScheduledWorkEquipment.Bind(scheduledWork.Location.GetEquipmentByEquipmentType(scheduledWork.EquipmentType));
        }
        else
        {
            // schedule for location
            //
            if (scheduledWork.Location != null)
                ScheduledWorkLocation.Bind(scheduledWork.Location.GetLocationByLocationType(scheduledWork.LocationType));
        }
    }

    /// <summary>
    /// Binds data to the location and equipment drop down lists.
    /// </summary>
    /// <param name="scheduledWork"></param>
    protected void BindEquipmentLocationType(OScheduledWork scheduledWork)
    {
        if (scheduledWork.Equipment != null)
            EquipmentTypeID.Bind(scheduledWork.Equipment.GetEquipmentTypes());
        else if (scheduledWork.Location != null)
        {
            EquipmentTypeID.Bind(scheduledWork.Location.GetEquipmentTypes());
            LocationTypeID.Bind(scheduledWork.Location.GetLocationTypes());

        }
        ScheduledWorkLocation.Items.Clear();
        ScheduledWorkEquipment.Items.Clear();
    }

    ///// <summary>
    ///// Binds data to the schedule work location type list box.
    ///// </summary>
    ///// <param name="scheduledWork"></param>
    //protected void BindParameters(OScheduledWork scheduledWork)
    //{
    //    if (scheduledWork.LocationType != null)
    //    {
    //        ScheduledWorkLocationTypeParameters.Bind(scheduledWork.LocationType.LocationTypeParameters);
    //    }
    //    if (scheduledWork.EquipmentType != null)
    //    {
    //        ScheduledWorkEquipmentTypeParameters.Bind(scheduledWork.EquipmentType.EquipmentTypeParameters);
    //    }
    //}

    /// <summary>
    /// Sets value to the estimated unit cost text box.
    /// </summary>
    /// <param name="work"></param>
    /// <param name="workCost"></param>
    protected void UpdateTechRate(OScheduledWork work, OScheduledWorkCost workCost)
    {
        if (workCost.Craft != null)
        {
            if (workCost.EstimatedOvertime == 0)
                WorkCost_EstimatedUnitCost.Text = workCost.Craft.NormalHourlyRate.Value.ToString("#,##0.00");
            else
                WorkCost_EstimatedUnitCost.Text = workCost.Craft.OvertimeHourlyRate.Value.ToString("#,##0.00");
        }
        else
        {
            WorkCost_EstimatedUnitCost.Text = "0.00";
        }
    }

    /// <summary>
    /// Validates and saves the schedule work into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OScheduledWork work = (OScheduledWork)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(work);

            // Validate
            //
            if (!work.ValidateStaggerEquipmentSelected())
            {
                this.ScheduledWorkStaggeredEquipment.ErrorMessage = Resources.Errors.ScheduledWork_StaggeredEquipmentNotSpecified;
            }
            if (!work.ValidateStaggerLocationSelected())
            {
                this.ScheduledWorkStaggeredLocation.ErrorMessage = Resources.Errors.ScheduledWork_StaggeredLocationNotSpecified;
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            work.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Location_AcquireTreePopulater(object sender)
    {
        OScheduledWork work = (OScheduledWork)panel.SessionObject;
        return new LocationEquipmentTreePopulater(work.LocationID, true, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user select the location in the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        OScheduledWork work = (OScheduledWork)panel.SessionObject;
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
        
        if (panelContract.Enabled)
            ContractID.Bind(OContract.GetContractsByScheduledWork(work, null), "Contract", "ObjectID");
        //BindParameters(work);
        BindEquipmentLocationType(work);
        BindEquipmentLocationList(work);

        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Constructs and returns the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Equipment_AcquireTreePopulater(object sender)
    {
        OScheduledWork work = (OScheduledWork)panel.SessionObject;
        return new EquipmentTreePopulater(work.EquipmentID, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user selects an equipment in the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Equipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OScheduledWork work = (OScheduledWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(work);

        if (work.Equipment != null)
            work.Location = work.Equipment.Location;

        if (panelContract.Enabled)
            ContractID.Bind(OContract.GetContractsByScheduledWork(work, null), "Contract", "ObjectID");
        //BindParameters(work);
        BindEquipmentLocationType(work);
        BindEquipmentLocationList(work);
        Location.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(work);
    }


    /// <summary>
    /// Occurs when user mades selection on the equipment drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentTypeID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = panel.SessionObject as OScheduledWork;
        panel.ObjectPanel.BindControlsToObject(scheduledWork);

        BindEquipmentLocationList(scheduledWork);
        panel.ObjectPanel.BindObjectToControls(scheduledWork);
        //BindParameters(scheduledWork);
    }

    /// <summary>
    /// Occurs when user mades selection on the location type drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void LocationTypeID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = panel.SessionObject as OScheduledWork;
        panel.ObjectPanel.BindControlsToObject(scheduledWork);

        BindEquipmentLocationList(scheduledWork);
        panel.ObjectPanel.BindObjectToControls(scheduledWork);
        //BindParameters(scheduledWork);
    }


    //protected void Checklist_SelectedNodeChanged(object sender, EventArgs e)
    //{
    //    // update the checklist
    //    //
    //    OScheduledWork work = (OScheduledWork)panel.SessionObject;
    //    panel.CurrentObject = work;
    //}

    /// <summary>
    /// Binds data to various cost type parameters drop down lists.
    /// </summary>
    /// <param name="work"></param>
    /// <param name="workCost"></param>
    protected void BindCostTypeParameters(OScheduledWork work, OScheduledWorkCost workCost)
    {
        if (workCost.CostType == WorkCostType.Technician)
        {
            WorkCost_CraftID.Bind(OCraft.GetCraftByLocation(work.Location));
            WorkCost_UserID.Bind(OUser.GetUsersByPositionsAndCraft(
                OPosition.GetPositionsByTypeOfServiceLocationAndRole(work.TypeOfService, work.Location, "WORKTECHNICIAN"), workCost.Craft, workCost.UserID));
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
                WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)workCost.StoreID, (Guid)workCost.CatalogueID, false), "ObjectName", "ObjectID", true);
            else
                WorkCost_StoreBinID.Items.Clear();
        }
    }

    /// <summary>
    /// Sets value to the estimated text box.
    /// </summary>
    /// <param name="cost"></param>
    protected void BindEstimatedCost(OScheduledWorkCost cost)
    {
        if (cost.UnitOfMeasureID != null && cost.CatalogueID != null)
        {
            WorkCost_EstimatedUnitCost.Text = OStore.ComputeAverageUnitCost(
                (Guid)cost.CatalogueID,
                cost.StoreID,
                cost.StoreBinID,
                (Guid)cost.UnitOfMeasureID).ToString("#,##0.00");
        }
        else
            WorkCost_EstimatedUnitCost.Text = "";
    }

    /// <summary>
    /// Occurs when user selects catalogue.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CatalogueID_SelectedValueChanged(object sender, EventArgs e)
    {
        // update the bins and the unit of measure conversion
        //
        OScheduledWorkCost scheduledWorkCost = (OScheduledWorkCost)this.WorkCost_SubPanel.SessionObject;
        this.WorkCost_SubPanel.ObjectPanel.BindControlsToObject(scheduledWorkCost);

        if (scheduledWorkCost.CatalogueID != null)
        {
            scheduledWorkCost.CostDescription = scheduledWorkCost.Catalogue.ObjectName;
            this.WorkCost_UnitOfMeasureID.Bind(OUnitConversion.GetConversions((Guid)scheduledWorkCost.Catalogue.UnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }

        if (scheduledWorkCost.StoreID != null && scheduledWorkCost.CatalogueID != null)
            WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)scheduledWorkCost.StoreID, (Guid)scheduledWorkCost.CatalogueID, false), "ObjectName", "ObjectID", true);

        BindEstimatedCost(scheduledWorkCost);

        this.WorkCost_SubPanel.ObjectPanel.BindObjectToControls(scheduledWorkCost);
    }

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        WorkCost_Panel1.Visible = WorkCost_CostType.SelectedIndex == 0;
        WorkCost_Panel3.Visible = WorkCost_CostType.SelectedIndex == 2;
        WorkCost_Panel4.Visible = WorkCost_CostType.SelectedIndex == 1;
        WorkCost_Panel4_1.Visible = WorkCost_CostType.SelectedIndex == 1;
        WorkCost_PanelUOM.Visible = WorkCost_CostType.SelectedIndex == 1 || WorkCost_CostType.SelectedIndex == 2;

        WorkCost_EstimatedUnitCost.Enabled = WorkCost_CostType.SelectedIndex == 2;
        WorkCost_EstimatedCostFactor.Enabled = WorkCost_CostType.SelectedIndex != 0 && WorkCost_CostType.SelectedIndex != 1;

        ScheduledWorkCost.Visible = ((OScheduledWork)panel.SessionObject).Location != null || ((OScheduledWork)panel.SessionObject).Equipment != null;
        buttonAddMaterials.Visible = ((OScheduledWork)panel.SessionObject).Location != null || ((OScheduledWork)panel.SessionObject).Equipment != null;

        Location.Enabled = ((OScheduledWork)panel.SessionObject).ScheduledWorkCost.Count == 0;
        Equipment.Enabled = ((OScheduledWork)panel.SessionObject).ScheduledWorkCost.Count == 0;
        if (((OScheduledWork)panel.SessionObject).EquipmentID == null)
        {
            EquipmentLocation.Enabled = true;
        }
        else
        {
            EquipmentLocation.SelectedIndex = 0;
            EquipmentLocation.Enabled = false;
        }

        panelFixedFloatingParameters.Visible = IsFloating.SelectedIndex == 0;
        panelWeekType.Visible = FrequencyInterval.SelectedIndex == 1;
        panelWeekTypeDay.Visible = WeekType.SelectedIndex == 1;
        panelMonthType.Visible = FrequencyInterval.SelectedIndex == 2;
        panelMonthTypeWeekDay.Visible = MonthType.SelectedIndex == 1;
        panelAdvanceCreation.Visible = radioIsAllFixedWorksCreatedAtOnce.SelectedValue == "0";

        EndDateTime.Visible = IsScheduledByOccurrence.SelectedIndex == 0;
        EndNumberOfOccurrences.Visible = IsScheduledByOccurrence.SelectedIndex == 1;

        EquipmentTypeID.Visible = EquipmentLocation.SelectedIndex == 0;
        LocationTypeID.Visible = EquipmentLocation.SelectedIndex == 1;
        ScheduledWorkEquipment.Visible = EquipmentLocation.SelectedIndex == 0 && !IsStaggered.Checked;
        ScheduledWorkLocation.Visible = EquipmentLocation.SelectedIndex == 1 && !IsStaggered.Checked;
        StaggerBy.Visible = IsStaggered.Checked;
        ScheduledWorkStaggeredEquipment.Visible = EquipmentLocation.SelectedIndex == 0 && IsStaggered.Checked;
        ScheduledWorkStaggeredLocation.Visible = EquipmentLocation.SelectedIndex == 1 && IsStaggered.Checked;

        tabWorks.Visible = !((OScheduledWork)panel.SessionObject).IsNew;
        Works.Visible = !((OScheduledWork)panel.SessionObject).IsNew;
        //ScheduledWorkEquipmentTypeParameters.Visible = EquipmentLocation.SelectedIndex == 0;
        //ScheduledWorkLocationTypeParameters.Visible = EquipmentLocation.SelectedIndex == 1;
        CalendarBlockMethod.Visible = CalendarID.SelectedIndex != 0;

        // 2010.04.09
        // Disable only specific tabs so that user can cancel
        // the scheduled work.
        //
        //tabObject.Enabled = objectBase.CurrentObjectState.Is("Start");
        panelDetails.Enabled =
            tabItems.Enabled =
            tabRecurrence.Enabled =
            tabContract.Enabled =
            tabCost.Enabled =
            tabWorks.Enabled =
            objectBase.CurrentObjectState.Is("Start");
    }

    /// <summary>
    /// Binds data to the drop down lists.
    /// </summary>
    /// <param name="scheduledWork"></param>
    void BindCodes(OScheduledWork scheduledWork)
    {
        if (scheduledWork.TypeOfWorkID == null)
            scheduledWork.TypeOfServiceID = null;

        if (scheduledWork.TypeOfServiceID == null)
            scheduledWork.TypeOfProblemID = null;

        TypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), scheduledWork.TypeOfWorkID));
        TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, scheduledWork.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), scheduledWork.TypeOfServiceID));
        TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", scheduledWork.TypeOfServiceID, scheduledWork.TypeOfProblemID));
    }

    /// <summary>
    /// Occurs when user mades selection on the craft drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_CraftID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        OScheduledWorkCost scheduledWorkCost = (OScheduledWorkCost)WorkCost_SubPanel.SessionObject;

        WorkCost_UserID.Bind(OUser.GetUsersByPositionsAndCraft(
            OPosition.GetPositionsByTypeOfServiceLocationAndRole(scheduledWork.TypeOfService, scheduledWork.Location, "WORKTECHNICIAN"),
            scheduledWorkCost.Craft, scheduledWorkCost.UserID));
        UpdateTechRate(scheduledWork, scheduledWorkCost);
        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(scheduledWorkCost);
    }

    /// <summary>
    /// Occurs when user clicks on the radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_EstimatedOvertime_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        OScheduledWorkCost scheduledWorkCost = (OScheduledWorkCost)WorkCost_SubPanel.SessionObject;

        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(scheduledWorkCost);
        UpdateTechRate(scheduledWork, scheduledWorkCost);
        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(scheduledWorkCost);
    }

    /// <summary>
    /// Occurs when user mades selection on the type of work drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        panelTypeOfWork.BindControlsToObject(scheduledWork);
        panelContract.BindControlsToObject(scheduledWork);

        TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, scheduledWork.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), null));
        TypeOfProblemID.Items.Clear();

        if (panelContract.Enabled)
            ContractID.Bind(OContract.GetContractsByScheduledWork(scheduledWork, null), "Contract", "ObjectID");

        panelTypeOfWork.BindObjectToControls(scheduledWork);
        panelContract.BindObjectToControls(scheduledWork);
    }

    /// <summary>
    /// Occurs when user mades selection on the type of work drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        panelTypeOfWork.BindControlsToObject(scheduledWork);
        panelContract.BindControlsToObject(scheduledWork);

        TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", scheduledWork.TypeOfServiceID, null));

        if (panelContract.Enabled)
            ContractID.Bind(OContract.GetContractsByScheduledWork(scheduledWork, null), "Contract", "ObjectID");

        panelTypeOfWork.BindObjectToControls(scheduledWork);
        panelContract.BindObjectToControls(scheduledWork);
    }

    /// <summary>
    /// Binds data to the store bin drop down list.
    /// </summary>
    /// <param name="work"></param>
    protected void BindStore(OScheduledWork work)
    {
        OScheduledWorkCost workCost = (OScheduledWorkCost)WorkCost_SubPanel.SessionObject;
        WorkCost_StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, "OScheduledWork", workCost.StoreID));
    }

    /// <summary>
    /// Populates the schedule work sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OScheduledWork work = (OScheduledWork)panel.SessionObject;
        OScheduledWorkCost workCost = (OScheduledWorkCost)WorkCost_SubPanel.SessionObject;

        BindStore(work);

        WorkCost_CostType.Enabled = workCost.IsNew;

        //WorkCost_CraftID.Enabled = workCost.IsNew;
        //WorkCost_UserID.Enabled = workCost.IsNew;
        if (workCost.CostType == WorkCostType.Material)
        {
            WorkCost_CatalogueID.Enabled = workCost.IsNew;
            WorkCost_UnitOfMeasureID.Enabled = workCost.IsNew || workCost.CostType == WorkCostType.AdhocRate;
            WorkCost_StoreID.Enabled = workCost.IsNew;
            WorkCost_StoreBinID.Enabled = workCost.IsNew;
        }

        BindCostTypeParameters(work, workCost);
        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(workCost);
    }

    /// <summary>
    /// Updates and inserts the work cost to the work.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WorkCost_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        tabCost.BindControlsToObject(scheduledWork);
        OScheduledWorkCost workCost = (OScheduledWorkCost)WorkCost_SubPanel.SessionObject;
        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);

        // Validate
        //
        if (scheduledWork.IsDuplicateWorkCost(workCost))
        {
            if (workCost.CostType == WorkCostType.AdhocRate)
                this.WorkCost_Name.ErrorMessage = Resources.Errors.ScheduledWork_DuplicateAdhocRate;
            else if (workCost.CostType == WorkCostType.Material)
                this.WorkCost_CatalogueID.ErrorMessage = Resources.Errors.ScheduledWork_DuplicateMaterial;
        }
        if (!panel.ObjectPanel.IsValid)
            return;

        // Update
        if (workCost.CostType == 0)
        {
            workCost.ObjectName = workCost.Technician != null ? workCost.Technician.ObjectName : "";
            workCost.CostDescription = workCost.Technician != null ? workCost.Technician.ObjectName : "";
            workCost.StoreID = null;
            workCost.StoreBinID = null;
            workCost.CatalogueID = null;
            workCost.FixedRateID = null;
            workCost.EstimatedCostFactor = 1.0m;
        }

        if (workCost.CostType == 1)
        {
            workCost.ObjectName = workCost.FixedRate != null ? workCost.FixedRate.ObjectName : "";
            workCost.CostDescription = workCost.FixedRate != null ? workCost.FixedRate.LongDescription : "";
            workCost.UnitOfMeasureID = workCost.FixedRate != null ? workCost.FixedRate.UnitOfMeasureID : null;
            workCost.StoreID = null;
            workCost.StoreBinID = null;
            workCost.CatalogueID = null;
        }

        if (workCost.CostType == 2)
        {
            workCost.CostDescription = workCost.ObjectName;
            workCost.StoreID = null;
            workCost.StoreBinID = null;
            workCost.CatalogueID = null;
            workCost.FixedRateID = null;
        }

        if (workCost.CostType == 3)
        {
            workCost.ObjectName = workCost.Catalogue != null ? workCost.Catalogue.ObjectName : "";
            workCost.CostDescription = workCost.Catalogue != null ? workCost.Catalogue.ObjectName : "";
            workCost.FixedRateID = null;
        }

        workCost.RecomputeEstimatedTotal();
        scheduledWork.ScheduledWorkCost.Add(workCost);
        tabCost.BindObjectToControls(scheduledWork);
    }

    /// <summary>
    /// Occurs when user clicks on the cost type radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CostType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (WorkCost_CostType.SelectedIndex == 0)
        {
            WorkCost_EstimatedCostFactor.Text = "1.00";
        }
        else if (WorkCost_CostType.SelectedIndex == 3)
        {
            WorkCost_EstimatedCostFactor.Text = "1.00";
        }

        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        OScheduledWorkCost scheduledWorkCost = (OScheduledWorkCost)WorkCost_SubPanel.SessionObject;
        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(scheduledWorkCost);
        BindCostTypeParameters(scheduledWork, scheduledWorkCost);
        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(scheduledWorkCost);
    }

    /// <summary>
    /// Occurs when user mades selection on the contract drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ContractID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        panelContract.BindControlsToObject(scheduledWork);
        panelContract.BindObjectToControls(scheduledWork);
    }

    /// <summary>
    /// Occurs when user changes the scheduled start datetime.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ScheduledStartDateTime_DateTimeChanged(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;

        panelDate.BindControlsToObject(scheduledWork);
        panelContract.BindControlsToObject(scheduledWork);

        scheduledWork.FirstWorkEndDateTime = scheduledWork.FirstWorkStartDateTime;

        if (panelContract.Enabled)
            ContractID.Bind(OContract.GetContractsByScheduledWork(panel.SessionObject as OScheduledWork, null), "Contract", "ObjectID");

        panelContract.BindObjectToControls(scheduledWork);
        panelDate.BindObjectToControls(scheduledWork);
    }

    /// <summary>
    /// Populates the scheduled work check list sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ScheduledWorkChecklist_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        ChecklistID.PopulateTree();
        CycleNumber.Items.Clear();

        OScheduledWork scheduledWork = panel.SessionObject as OScheduledWork;
        for (int i = 1; i <= scheduledWork.ScheduledWorkChecklist.Count + 1; i++)
            CycleNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        OScheduledWorkChecklist scheduledWorkChecklist = ScheduledWorkChecklist_SubPanel.SessionObject as OScheduledWorkChecklist;

        if (scheduledWorkChecklist.IsNew && scheduledWorkChecklist.CycleNumber == null)
        {
            scheduledWorkChecklist.CycleNumber = scheduledWork.ScheduledWorkChecklist.Count + 1;
        }
        ScheduledWorkChecklist_SubPanel.ObjectPanel.BindObjectToControls(scheduledWorkChecklist);
    }

    /// <summary>
    /// Update the scheduled work check list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ScheduledWorkChecklist_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        tabChecklist.BindControlsToObject(scheduledWork);

        OScheduledWorkChecklist scheduledWorkChecklist = ScheduledWorkChecklist_SubPanel.SessionObject as OScheduledWorkChecklist;
        ScheduledWorkChecklist_SubPanel.ObjectPanel.BindControlsToObject(scheduledWorkChecklist);
        scheduledWork.ScheduledWorkChecklist.Add(scheduledWorkChecklist);
        scheduledWork.ReorderChecklistSequence(scheduledWorkChecklist);

        tabChecklist.BindObjectToControls(scheduledWork);
    }

    /// <summary>
    /// Occurs when the user removes a checklist from the sequence.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ScheduledWorkChecklist_SubPanel_Removed(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        scheduledWork.ReorderChecklistSequence(null);
    }

    /// <summary>
    /// Constructs and returns the check list tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ChecklistID_AcquireTreePopulater(object sender)
    {
        OScheduledWorkChecklist scheduledWorkChecklist = ScheduledWorkChecklist_SubPanel.SessionObject as OScheduledWorkChecklist;
        return new ChecklistTreePopulater(scheduledWorkChecklist.ChecklistID, false, true);
    }

    /// <summary>
    /// Occurs when user clicks on the equipment/location radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWork work = panel.SessionObject as OScheduledWork;
        panel.ObjectPanel.BindControlsToObject(work);
        BindEquipmentLocationList(work);
        panel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when user clicks on the show chart button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonShowChart_Click(object sender, EventArgs e)
    {
        if (panel.SessionObject != null)
        {
            Session["GANTT"] = (panel.SessionObject as OScheduledWork).GetWorksDataTable();

            panel.FocusWindow = false;

            Window.Open("../../components/gantt.aspx?S=" +
                HttpUtility.UrlEncode(Security.Encrypt("Gantt_ScheduledStartDateTime")) +
                "&E=" + HttpUtility.UrlEncode(Security.Encrypt("Gantt_ScheduledEndDateTime")) +
                "&T=" + HttpUtility.UrlEncode(Security.Encrypt("Gantt_WorkNumber")) +
                "&C=" + HttpUtility.UrlEncode(Security.Encrypt("Gantt_PercentageComplete")) + "", "AnacleEAM_Gantt");
        }
    }

    /// <summary>
    /// Occurs when user mades selection on the store drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {
        // update the bins 
        //
        OScheduledWork work = (OScheduledWork)this.panel.SessionObject;
        OScheduledWorkCost workCost = (OScheduledWorkCost)this.WorkCost_SubPanel.SessionObject;
        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);

        if (workCost.StoreID != null && workCost.CatalogueID != null)
        {
            WorkCost_StoreBinID.Bind(OStore.FindBinsByCatalogue((Guid)workCost.StoreID, (Guid)workCost.CatalogueID, false, workCost.StoreBinID), "ObjectName", "ObjectID", true);
        }
        else
            WorkCost_StoreBinID.Items.Clear();

        this.WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);

        BindEstimatedCost(workCost);
        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(workCost);
    }

    /// <summary>
    /// Occurs when user mades selection on the unit of measure drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void UnitOfMeasureID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWorkCost workCost = (OScheduledWorkCost)this.WorkCost_SubPanel.SessionObject;

        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);
        BindEstimatedCost(workCost);
        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(workCost);
    }

    /// <summary>
    /// Occurs when user mades selection on the store bin drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreBinID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OScheduledWorkCost workCost = (OScheduledWorkCost)this.WorkCost_SubPanel.SessionObject;

        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(workCost);
        BindEstimatedCost(workCost);
        WorkCost_SubPanel.ObjectPanel.BindObjectToControls(workCost);
    }

    /// <summary>
    /// Occurs after user clicks on the delete button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ScheduledWorkChecklist_Deleted(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        scheduledWork.ReorderChecklistSequence(null);
        panel.ObjectPanel.BindObjectToControls(scheduledWork);
    }

    /// <summary>
    /// Occurs when user clicks on the add item button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddMaterials_Clicked(object sender, EventArgs e)
    {
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(scheduledWork);
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
        OScheduledWork scheduledWork = (OScheduledWork)panel.SessionObject;

        tabCost.BindObjectToControls(scheduledWork);
    }
    
        
    /// <summary>
    /// Occurs when user selects one or more items in the pop up window.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void addItems_PopupReturned(object sender, EventArgs e)
    {
        WorkCost_SubPanel.MassAdd();
    }


    /// <summary>
    /// Occurs when the frequency interval changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void FrequencyInterval_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Occurs when the week type changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WeekType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Occurs when the end condition is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsScheduledByOccurrence_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the monty type changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void MonthType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects how the scheduler creates the works.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioIsAllFixedWorksCreatedAtOnce_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects a calendar.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CalendarID_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Opens a window to edit the Contract object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditContract_Click(object sender, EventArgs e)
    {
        OScheduledWork o = (OScheduledWork)panel.SessionObject;
        if (o.ContractID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, o.ContractID))
                Window.OpenEditObjectPage(this, "OContract", o.ContractID.ToString(), "");
            else
                panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
        }
    }

    
    /// <summary>
    /// Opens a window to view the Contract object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewContract_Click(object sender, EventArgs e)
    {
        OScheduledWork o = (OScheduledWork)panel.SessionObject;
        if (o.ContractID != null)
        {
            Window.OpenViewObjectPage(this, "OContract", o.ContractID.ToString(), "");
        }
    }

    protected void btCalendarPreview_Click(object sender, EventArgs e)
    {
        OScheduledWork sw = panel.SessionObject as OScheduledWork;
        panel.ObjectPanel.BindControlsToObject(sw);
        panel.FocusWindow = false;
        Window.Open("preview.aspx", "AnacleEAM_Popup");
    }

    
    /// <summary>
    /// Occurs when the staggered checkbox is checked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsStaggered_CheckedChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Occurs when the user clicks on the edit or view button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void Works_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditObject")
            Window.OpenEditObjectPage(this, "OWork", dataKeys[0].ToString(), "");
        if (commandName == "ViewObject")
            Window.OpenViewObjectPage(this, "OWork", dataKeys[0].ToString(), "");
    }

    
    /// <summary>
    /// Hide/Show the edit button depending on whether
    /// the works are assigned to the current user.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Works_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int rowIndex = e.Row.RowIndex;

            Guid workId = (Guid)Works.DataKeys[rowIndex][0];

            e.Row.Cells[1].Controls[0].Visible =
                AppSession.User.AllowEditAll("OWork") ||
                OActivity.CheckAssignment(AppSession.User, workId);
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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" >
        <web:object runat="server" ID="panel" Caption="Scheduled Work" BaseTable="tScheduledWork"
            OnValidateAndSave="panel_ValidateAndSave" OnPopulateForm="panel_PopulateForm"
            meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1">
                    <web:base runat="server" ID="objectBase" ObjectNumberCaption="Schedule Number" ObjectNumberEnabled="false"
                        ObjectNameVisible="false" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:uipanel runat="server" id="panelDetails">
                        <ui:UIFieldTreeList runat="server" ID="Location" Caption="Location" OnSelectedNodeChanged="Location_SelectedNodeChanged"
                            PropertyName="LocationID" OnAcquireTreePopulater="Location_AcquireTreePopulater"
                            ToolTip="Use this to select the location that this work applies to." meta:resourcekey="LocationResource1" />
                        <ui:UIFieldTreeList runat="server" ID="Equipment" Caption="Equipment" OnSelectedNodeChanged="Equipment_SelectedNodeChanged"
                            PropertyName="EquipmentID" OnAcquireTreePopulater="Equipment_AcquireTreePopulater"
                            ToolTip="Use this to select the equipment that this work applies to." meta:resourcekey="EquipmentResource1" />
                    </ui:uipanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabItems" Caption="Items" meta:resourcekey="tabItemsResource1">
                    <ui:UIFieldRadioList runat="server" ID="EquipmentLocation" PropertyName="EquipmentLocation"
                        Caption="Schedule For" ValidateRequiredField="True" OnSelectedIndexChanged="EquipmentLocation_SelectedIndexChanged"
                        ToolTip="Indicates if the works generated are for locations or equipment." meta:resourcekey="EquipmentLocationResource1">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="EquipmentLocation_ListItemResource1">Equipment</asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="EquipmentLocation_ListItemResource2">Location</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldDropDownList runat="server" ID="EquipmentTypeID" PropertyName="EquipmentTypeID"
                        Caption="Equipment Type" ValidateRequiredField="True" OnSelectedIndexChanged="EquipmentTypeID_SelectedIndexChanged"
                        meta:resourcekey="EquipmentTypeIDResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="LocationTypeID" PropertyName="LocationTypeID"
                        Caption="Location Type" ValidateRequiredField="True" OnSelectedIndexChanged="LocationTypeID_SelectedIndexChanged"
                        meta:resourcekey="LocationTypeIDResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldCheckBox runat="server" ID="IsStaggered" Caption="Stagger" PropertyName="IsStaggered"
                        Text="Yes, stagger the works for each equipment/location" ToolTip="Indicates if the works for each equipment/location should be staggered by a specified time."
                        meta:resourcekey="IsStaggeredResource1" OnCheckedChanged="IsStaggered_CheckedChanged">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldListBox runat="server" ID="ScheduledWorkEquipment" PropertyName="ScheduledWorkEquipment"
                        Caption="Equipment List" ValidateRequiredField="True" meta:resourcekey="ScheduledWorkEquipmentResource1"></ui:UIFieldListBox>
                    <ui:UIFieldListBox runat="server" ID="ScheduledWorkLocation" PropertyName="ScheduledWorkLocation"
                        Caption="Location List" ValidateRequiredField="True" meta:resourcekey="ScheduledWorkLocationResource1"></ui:UIFieldListBox>
                    <ui:UIFieldDropDownList runat="server" ID="StaggerBy" PropertyName="StaggerBy" Caption="Stagger By:"
                        ValidateRequiredField="True" Span="Half" ToolTip="Indicates the unit of time by which to stagger the works."
                        meta:resourcekey="StaggerByResource1">
                        <Items>
                            <asp:ListItem Selected="True" Value="0"  >Day(s)</asp:ListItem>
                            <asp:ListItem Value="1"  >Week(s)</asp:ListItem>
                            <asp:ListItem Value="2"  >Month(s)</asp:ListItem>
                            <asp:ListItem Value="3"  >Year(s)</asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <br />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="ScheduledWorkStaggeredEquipment" PropertyName="ScheduledWorkStaggeredEquipment"
                        Caption="Equipment List" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="ScheduledWorkStaggeredEquipmentResource1"
                        Width="100%" SortExpression="Equipment.ObjectName" CheckBoxColumnVisible="false">
                        <Columns>
                            <ui:UIGridViewBoundColumn HeaderStyle-Width="70%" PropertyName="Equipment.ObjectName"
                                HeaderText="Equipment" meta:resourcekey="UIGridViewBoundColumnResource1">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Stagger" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <ui:UIFieldDropDownList runat="server" CaptionWidth="1px" PropertyName="UnitsToStagger"
                                        ID="Equipment_UnitsToStagger" meta:resourcekey="Equipment_UnitsToStaggerResource1">
                                        <Items>
                                            <asp:ListItem Selected="True" Value=""  >N/A</asp:ListItem>
                                            <asp:ListItem Value="0"  >00</asp:ListItem>
                                            <asp:ListItem Value="1"  >01</asp:ListItem>
                                            <asp:ListItem Value="2"  >02</asp:ListItem>
                                            <asp:ListItem Value="3"  >03</asp:ListItem>
                                            <asp:ListItem Value="4"  >04</asp:ListItem>
                                            <asp:ListItem Value="5"  >05</asp:ListItem>
                                            <asp:ListItem Value="6"  >06</asp:ListItem>
                                            <asp:ListItem Value="7"  >07</asp:ListItem>
                                            <asp:ListItem Value="8"  >08</asp:ListItem>
                                            <asp:ListItem Value="9"  >09</asp:ListItem>
                                            <asp:ListItem Value="10"  >10</asp:ListItem>
                                            <asp:ListItem Value="10"  >10</asp:ListItem>
                                            <asp:ListItem Value="11"  >11</asp:ListItem>
                                            <asp:ListItem Value="12"  >12</asp:ListItem>
                                            <asp:ListItem Value="13"  >13</asp:ListItem>
                                            <asp:ListItem Value="14"  >14</asp:ListItem>
                                            <asp:ListItem Value="15"  >15</asp:ListItem>
                                            <asp:ListItem Value="16"  >16</asp:ListItem>
                                            <asp:ListItem Value="17"  >17</asp:ListItem>
                                            <asp:ListItem Value="18"  >18</asp:ListItem>
                                            <asp:ListItem Value="19"  >19</asp:ListItem>
                                            <asp:ListItem Value="20"  >20</asp:ListItem>
                                            <asp:ListItem Value="20"  >20</asp:ListItem>
                                            <asp:ListItem Value="21"  >21</asp:ListItem>
                                            <asp:ListItem Value="22"  >22</asp:ListItem>
                                            <asp:ListItem Value="23"  >23</asp:ListItem>
                                            <asp:ListItem Value="24"  >24</asp:ListItem>
                                            <asp:ListItem Value="25"  >25</asp:ListItem>
                                            <asp:ListItem Value="26"  >26</asp:ListItem>
                                            <asp:ListItem Value="27"  >27</asp:ListItem>
                                            <asp:ListItem Value="28"  >28</asp:ListItem>
                                            <asp:ListItem Value="29"  >29</asp:ListItem>
                                            <asp:ListItem Value="30"  >30</asp:ListItem>
                                        </Items>
                                    </ui:UIFieldDropDownList>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIGridView runat="server" ID="ScheduledWorkStaggeredLocation" PropertyName="ScheduledWorkStaggeredLocation"
                        Caption="Location List" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="ScheduledWorkStaggeredLocationResource1"
                        Width="100%" CheckBoxColumnVisible="false">
                        <Columns>
                            <ui:UIGridViewBoundColumn HeaderStyle-Width="70%" PropertyName="Location.ObjectName"
                                HeaderText="Location" meta:resourcekey="ScheduledWorkStaggeredLocation_UIGridViewResource1">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Stagger" meta:resourcekey="ScheduledWorkStaggeredLocation_UIGridViewResource2">
                                <ItemTemplate>
                                    <ui:UIFieldDropDownList runat="server" CaptionWidth="1px" PropertyName="UnitsToStagger"
                                        ID="Location_UnitsToStagger" meta:resourcekey="Location_UnitsToStaggerResource1">
                                        <Items>
                                            <asp:ListItem Selected="True" Value=""  >N/A</asp:ListItem>
                                            <asp:ListItem Value="0"  >00</asp:ListItem>
                                            <asp:ListItem Value="1"  >01</asp:ListItem>
                                            <asp:ListItem Value="2"  >02</asp:ListItem>
                                            <asp:ListItem Value="3"  >03</asp:ListItem>
                                            <asp:ListItem Value="4"  >04</asp:ListItem>
                                            <asp:ListItem Value="5"  >05</asp:ListItem>
                                            <asp:ListItem Value="6"  >06</asp:ListItem>
                                            <asp:ListItem Value="7"  >07</asp:ListItem>
                                            <asp:ListItem Value="8"  >08</asp:ListItem>
                                            <asp:ListItem Value="9"  >09</asp:ListItem>
                                            <asp:ListItem Value="10"  >10</asp:ListItem>
                                            <asp:ListItem Value="11"  >11</asp:ListItem>
                                            <asp:ListItem Value="12"  >12</asp:ListItem>
                                            <asp:ListItem Value="13"  >13</asp:ListItem>
                                            <asp:ListItem Value="14"  >14</asp:ListItem>
                                            <asp:ListItem Value="15"  >15</asp:ListItem>
                                            <asp:ListItem Value="16"  >16</asp:ListItem>
                                            <asp:ListItem Value="17"  >17</asp:ListItem>
                                            <asp:ListItem Value="18"  >18</asp:ListItem>
                                            <asp:ListItem Value="19"  >19</asp:ListItem>
                                            <asp:ListItem Value="20"  >20</asp:ListItem>
                                            <asp:ListItem Value="20"  >20</asp:ListItem>
                                            <asp:ListItem Value="21"  >21</asp:ListItem>
                                            <asp:ListItem Value="22"  >22</asp:ListItem>
                                            <asp:ListItem Value="23"  >23</asp:ListItem>
                                            <asp:ListItem Value="24"  >24</asp:ListItem>
                                            <asp:ListItem Value="25"  >25</asp:ListItem>
                                            <asp:ListItem Value="26"  >26</asp:ListItem>
                                            <asp:ListItem Value="27"  >27</asp:ListItem>
                                            <asp:ListItem Value="28"  >28</asp:ListItem>
                                            <asp:ListItem Value="29"  >29</asp:ListItem>
                                            <asp:ListItem Value="30"  >30</asp:ListItem>
                                        </Items>
                                    </ui:UIFieldDropDownList>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabRecurrence" Caption="Recurrence" meta:resourcekey="tabRecurrenceResource1">
                
                    <ui:UIButton runat="server" ID="btCalendarPreview" ImageUrl="~/images/calendar.gif" Text="Preview Work Schedule" OnClick="btCalendarPreview_Click" CausesValidation="false" AlwaysEnabled="true" meta:resourcekey="btCalendarPreviewResource1" />
                    <br />
                    <ui:UISeparator ID="Separator1" runat="server" Caption="Work" meta:resourcekey="Separator1Resource1" />
                    <ui:UIPanel runat="server" ID="panelTypeOfWork" meta:resourcekey="panelTypeOfWorkResource1" >
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfWorkID" PropertyName="TypeOfWorkID"
                            Caption="Type of Work" ValidateRequiredField="True" OnSelectedIndexChanged="TypeOfWorkID_SelectedIndexChanged"
                            meta:resourcekey="TypeOfWorkIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfServiceID" PropertyName="TypeOfServiceID"
                            Caption="Type of Service" ValidateRequiredField="True" OnSelectedIndexChanged="TypeOfServiceID_SelectedIndexChanged"
                            meta:resourcekey="TypeOfServiceIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfProblemID" PropertyName="TypeOfProblemID"
                            Caption="Type of Problem" ValidateRequiredField="True" meta:resourcekey="TypeOfProblemIDResource1">
                        </ui:UIFieldDropDownList>
                    </ui:UIPanel>
                    <ui:UIFieldDropDownList runat="server" ID="Priority" PropertyName="Priority" Caption="Priority"
                        ValidateRequiredField="True" meta:resourcekey="PriorityResource1">
                        <Items>
                            <asp:ListItem Selected="True"  >
                            </asp:ListItem>
                            <asp:ListItem Value="0"  >0 (Lowest)</asp:ListItem>
                            <asp:ListItem Value="1"  >1</asp:ListItem>
                            <asp:ListItem Value="2"  >2</asp:ListItem>
                            <asp:ListItem Value="3"  >3 (Highest)</asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="WorkDescription" PropertyName="WorkDescription"
                        Caption="Work Description" ValidateRequiredField="True" MaxLength="255" meta:resourcekey="WorkDescriptionResource1" />
                    <ui:UISeparator ID="Separator2" runat="server" Caption="Schedule" meta:resourcekey="Separator2Resource1" />
                    <ui:UIPanel runat="server" ID="panelDate" meta:resourcekey="panelDateResource1" >
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkStartDateTime" PropertyName="FirstWorkStartDateTime"
                            Caption="First Work's Start" ValidateRequiredField="True" ShowTimeControls='True'
                            OnDateTimeChanged="ScheduledStartDateTime_DateTimeChanged" Span="Half" ToolTip="The start date/time of the FIRST work."
                            ValidationCompareControl="FirstWorkEndDateTime" ValidateCompareField='true' ValidationCompareOperator="lessthanequal"
                            ValidationCompareType="date" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            meta:resourcekey="FirstWorkStartDateTimeResource1">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkEndDateTime" PropertyName="FirstWorkEndDateTime"
                            Caption="First Work's End" ValidateRequiredField="True" ShowTimeControls='True'
                            Span="Half" ToolTip="The end date/time of the FIRST work. Note: This does not indicate the end date/time for the list of works."
                            ValidationCompareControl="FirstWorkStartDateTime" ValidateCompareField='true'
                            ValidationCompareOperator="greaterthanequal" ValidationCompareType="date" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="FirstWorkEndDateTimeResource1">
                        </ui:UIFieldDateTime>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat="server" ID="IsFloating" PropertyName="IsFloating" Caption="Fixed/Floating"
                        RepeatDirection="Vertical" ValidateRequiredField="True" ToolTip="Indicates if the works generated are fixed or floating."
                        meta:resourcekey="IsFloatingResource1">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource80">Fixed: create all works immediately.</asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource81">Floating: create only first work; all subsequent works are created when the previous completes.</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldDropDownList runat="server" ID="FrequencyCount" PropertyName="FrequencyCount"
                        Caption="Every" ValidateRequiredField="True" Span="Half" meta:resourcekey="FrequencyCountResource1">
                        <Items>
                            <asp:ListItem Selected="True" Value="1"  >01</asp:ListItem>
                            <asp:ListItem Value="2"  >02</asp:ListItem>
                            <asp:ListItem Value="3"  >03</asp:ListItem>
                            <asp:ListItem Value="4"  >04</asp:ListItem>
                            <asp:ListItem Value="5"  >05</asp:ListItem>
                            <asp:ListItem Value="6"  >06</asp:ListItem>
                            <asp:ListItem Value="7"  >07</asp:ListItem>
                            <asp:ListItem Value="8"  >08</asp:ListItem>
                            <asp:ListItem Value="9"  >09</asp:ListItem>
                            <asp:ListItem Value="10"  >10</asp:ListItem>
                            <asp:ListItem Value="11"  >11</asp:ListItem>
                            <asp:ListItem Value="12"  >12</asp:ListItem>
                            <asp:ListItem Value="13"  >13</asp:ListItem>
                            <asp:ListItem Value="14"  >14</asp:ListItem>
                            <asp:ListItem Value="15"  >15</asp:ListItem>
                            <asp:ListItem Value="16"  >16</asp:ListItem>
                            <asp:ListItem Value="17"  >17</asp:ListItem>
                            <asp:ListItem Value="18"  >18</asp:ListItem>
                            <asp:ListItem Value="19"  >19</asp:ListItem>
                            <asp:ListItem Value="20"  >20</asp:ListItem>
                            <asp:ListItem Value="21"  >21</asp:ListItem>
                            <asp:ListItem Value="22"  >22</asp:ListItem>
                            <asp:ListItem Value="23"  >23</asp:ListItem>
                            <asp:ListItem Value="24"  >24</asp:ListItem>
                            <asp:ListItem Value="25"  >25</asp:ListItem>
                            <asp:ListItem Value="26"  >26</asp:ListItem>
                            <asp:ListItem Value="27"  >27</asp:ListItem>
                            <asp:ListItem Value="28"  >28</asp:ListItem>
                            <asp:ListItem Value="29"  >29</asp:ListItem>
                            <asp:ListItem Value="30"  >30</asp:ListItem>
                            <asp:ListItem Value="31"  >31</asp:ListItem>
                            <asp:ListItem Value="32"  >32</asp:ListItem>
                            <asp:ListItem Value="33"  >33</asp:ListItem>
                            <asp:ListItem Value="34"  >34</asp:ListItem>
                            <asp:ListItem Value="35"  >35</asp:ListItem>
                            <asp:ListItem Value="36"  >36</asp:ListItem>
                            <asp:ListItem Value="37"  >37</asp:ListItem>
                            <asp:ListItem Value="38"  >38</asp:ListItem>
                            <asp:ListItem Value="39"  >39</asp:ListItem>
                            <asp:ListItem Value="40"  >40</asp:ListItem>
                            <asp:ListItem Value="41"  >41</asp:ListItem>
                            <asp:ListItem Value="42"  >42</asp:ListItem>
                            <asp:ListItem Value="43"  >43</asp:ListItem>
                            <asp:ListItem Value="44"  >44</asp:ListItem>
                            <asp:ListItem Value="45"  >45</asp:ListItem>
                            <asp:ListItem Value="46"  >46</asp:ListItem>
                            <asp:ListItem Value="47"  >47</asp:ListItem>
                            <asp:ListItem Value="48"  >48</asp:ListItem>
                            <asp:ListItem Value="49"  >49</asp:ListItem>
                            <asp:ListItem Value="50"  >50</asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="FrequencyInterval" PropertyName="FrequencyInterval"
                        Caption="Interval" ValidateRequiredField="True" Span="Half" meta:resourcekey="FrequencyIntervalResource1"
                        OnSelectedIndexChanged="FrequencyInterval_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="FrequencyInterval_ListItemResource1">Day(s)</asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="FrequencyInterval_ListItemResource2">Week(s)</asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="FrequencyInterval_ListItemResource3">Month(s)</asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="FrequencyInterval_ListItemResource4">Year(s)</asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIPanel runat="server" ID="panelFixedFloatingParameters" Width="100%">
                        <ui:UIPanel runat="server" ID="panelWeekType" Width="100%" meta:resourcekey="panelWeekTypeResource1">
                            <ui:UIFieldRadioList runat="server" ID="WeekType" PropertyName="WeekType" Caption="Schedule"
                                RepeatDirection="Vertical" ValidateRequiredField="True" meta:resourcekey="WeekTypeResource2"
                                OnSelectedIndexChanged="WeekType_SelectedIndexChanged">
                                <Items>
                                    <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource136">Same day of every week</asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource137">Specific day/days of the week</asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="panelWeekTypeDay" Width="100%" meta:resourcekey="panelWeekTypeDayResource1">
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay0" PropertyName="WeekTypeDay0"
                                    Caption="Day of Week*" Text="Sunday" meta:resourcekey="WeekTypeDay0Resource1" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay1" PropertyName="WeekTypeDay1"
                                    Text="Monday" meta:resourcekey="WeekTypeDay1Resource1" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay2" PropertyName="WeekTypeDay2"
                                    Text="Tuesday" meta:resourcekey="WeekTypeDay2Resource1" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay3" PropertyName="WeekTypeDay3"
                                    Text="Wednesday" meta:resourcekey="WeekTypeDay3Resource1" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay4" PropertyName="WeekTypeDay4"
                                    Text="Thursday" meta:resourcekey="WeekTypeDay4Resource1" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay5" PropertyName="WeekTypeDay5"
                                    Text="Friday" meta:resourcekey="WeekTypeDay5Resource1" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay6" PropertyName="WeekTypeDay6"
                                    Text="Saturday" meta:resourcekey="WeekTypeDay6Resource1" />
                            </ui:UIPanel>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelMonthType" Width="100%" meta:resourcekey="panelMonthTypeResource1">
                            <ui:UIFieldRadioList runat="server" ID="MonthType" PropertyName="MonthType" Caption="Schedule"
                                RepeatDirection="Vertical" ValidateRequiredField="True" meta:resourcekey="MonthTypeResource2"
                                OnSelectedIndexChanged="MonthType_SelectedIndexChanged">
                                <Items>
                                    <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource138">Same date of every month</asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource139">Specific week/day of the month</asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="panelMonthTypeWeekDay" Width="100%" meta:resourcekey="panelMonthTypeWeekDayResource1">
                                <ui:UIFieldRadioList runat="server" ID="MonthTypeWeekNumber" PropertyName="MonthTypeWeekNumber"
                                    Caption="Week of Month" ValidateRequiredField="True" RepeatColumns="0" meta:resourcekey="MonthTypeWeekNumberResource1">
                                    <Items>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource140">1st week &#160; </asp:ListItem>
                                        <asp:ListItem Value="2" meta:resourcekey="ListItemResource141">2nd week &#160; </asp:ListItem>
                                        <asp:ListItem Value="3" meta:resourcekey="ListItemResource142">3rd week &#160; </asp:ListItem>
                                        <asp:ListItem Value="4" meta:resourcekey="ListItemResource143">4th week &#160; </asp:ListItem>
                                        <asp:ListItem Value="5" meta:resourcekey="ListItemResource144">Last week &#160; </asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldRadioList runat="server" ID="MonthTypeDay" PropertyName="MonthTypeDay"
                                    Caption="Day of Week" ValidateRequiredField="True" RepeatColumns="0" meta:resourcekey="MonthTypeDayResource1">
                                    <Items>
                                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource145">Sunday &#160; </asp:ListItem>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource146">Monday &#160; </asp:ListItem>
                                        <asp:ListItem Value="2" meta:resourcekey="ListItemResource147">Tuesday &#160; </asp:ListItem>
                                        <asp:ListItem Value="3" meta:resourcekey="ListItemResource148">Wednesday &#160; </asp:ListItem>
                                        <asp:ListItem Value="4" meta:resourcekey="ListItemResource149">Thursday &#160; </asp:ListItem>
                                        <asp:ListItem Value="5" meta:resourcekey="ListItemResource150">Friday &#160; </asp:ListItem>
                                        <asp:ListItem Value="6" meta:resourcekey="ListItemResource151">Saturday &#160; </asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat="server" ID="IsScheduledByOccurrence" PropertyName="IsScheduledByOccurrence"
                        RepeatDirection="Vertical" Caption="End" ValidateRequiredField="True" meta:resourcekey="IsScheduledByOccurrenceResource1"
                        OnSelectedIndexChanged="IsScheduledByOccurrence_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource152">End when the date of the work reaches the specified End Date.</asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource153">End when the same work has been created a specified Number of Times.</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldDateTime runat="server" ID="EndDateTime" PropertyName="EndDateTime" ShowTimeControls="True"
                        ValidateRequiredField="True" Caption="End Date" ToolTip="The end date for the generated works. No works will be generated after this date/time."
                        ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="EndDateTimeResource2" />
                    <ui:UIFieldTextBox runat="server" ID="EndNumberOfOccurrences" PropertyName="EndNumberOfOccurrences"
                        ValidateRequiredField="True" Caption="Number of Times" ValidateDataTypeCheck='True'
                        ValidationDataType="Integer" ToolTip="The number of works that will be generated from this schedule."
                        ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer"
                        meta:resourcekey="EndNumberOfOccurrencesResource1" />
                    <ui:UISeparator runat="server" ID="UISeparator2" Caption="Scheduler"  meta:resourcekey="UISeparator2Resource1" />
                    <ui:UIFieldRadioList runat="server" ID="radioIsAllFixedWorksCreatedAtOnce" PropertyName="IsAllFixedWorksCreatedAtOnce"
                        OnSelectedIndexChanged="radioIsAllFixedWorksCreatedAtOnce_SelectedIndexChanged"
                        Caption="Work Creation" ValidateRequiredField="true" meta:resourcekey="radioIsAllFixedWorksCreatedAtOnceResource1" >
                        <Items>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource279" >Yes, all works are created as soon as the system can.</asp:ListItem>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource280"  >No, works are created only a number of days in advance.</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIPanel runat="server" ID="panelAdvanceCreation" meta:resourcekey="panelAdvanceCreationResource1" >
                        <table cellpadding='1' cellspacing='0' border='0' style="width: 100%; height: 24px">
                            <tr class="field-required">
                                <td style="width: 150px">
                                    <asp:Label runat="server" ID="label1" Text="Advance Creation*:" meta:resourcekey="label1Resource1"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelNumberOfDaysInAdvanceToCreateFixedWorks1" Text="Create fixed works " meta:resourcekey="labelNumberOfDaysInAdvanceToCreateFixedWorks1Resource1" ></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textNumberOfDaysInAdvanceToCreateFixedWorks"
                                        ShowCaption="false" PropertyName="NumberOfDaysInAdvanceToCreateFixedWorks" Caption="Advance Creation"
                                        ValidateRangeField="true" ValidationRangeType="Integer" ValidationRangeMin="0"
                                        ValidationRangeMinInclusive="true" FieldLayout="Flow" InternalControlWidth="50px"
                                        ValidateRequiredField="true" meta:resourcekey="textNumberOfDaysInAdvanceToCreateFixedWorksResource1" >
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelNumberOfDaysInAdvanceToCreateFixedWorks2" Text=" day(s) in advance before the cycles start." meta:resourcekey="labelNumberOfDaysInAdvanceToCreateFixedWorks2Resource1" ></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" Caption="Calendar" ID="Uiseparator1" meta:resourcekey="Uiseparator1Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="CalendarID" PropertyName="CalendarID"
                        Caption="Calendar" ToolTip="The calendar that shall be used to generate the works."
                        meta:resourcekey="CalendarIDResource1" OnSelectedIndexChanged="CalendarID_SelectedIndexChanged" />
                    <ui:UIFieldRadioList runat="server" ID="CalendarBlockMethod" PropertyName="CalendarBlockMethod"
                        RepeatDirection="Vertical" Caption="Conflict" ValidateRequiredField="True" meta:resourcekey="CalendarBlockMethodResource1">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource154">Cancel work if there is a conflict</asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource155">Move work forward by one day</asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource156">Move work backward by one day</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabContract" Caption="Contract" meta:resourcekey="tabContractResource1" >
                    <ui:UISeparator ID="Separator4" runat="server" Caption="Contract/Vendor" meta:resourcekey="Separator4Resource1" />
                    <ui:UIPanel runat="server" ID="panelContract" meta:resourcekey="panelContractResource1" >
                        <ui:UIFieldSearchableDropDownList runat="server" ID="ContractID" PropertyName="ContractID"
                            Caption="Contract" OnSelectedIndexChanged="ContractID_SelectedIndexChanged" ToolTip="The vendor that will be responsible for the works generated."
                            ContextMenuAlwaysEnabled="true"
                            meta:resourcekey="ContractIDResource1">
                            <ContextMenuButtons>
                                <ui:UIButton runat="server" ID="buttonEditContract" ImageUrl="~/images/edit.gif" Text="Edit Contract" OnClick="buttonEditContract_Click" ConfirmText="Please remember to save this Scheduled Work before editing the Contract.\n\nAre you sure you want to continue?" AlwaysEnabled="true" CausesValidation="false"  />
                                <ui:UIButton runat="server" ID="buttonViewContract" ImageUrl="~/images/view.gif" Text="View Contract" OnClick="buttonViewContract_Click" ConfirmText="Please remember to save this Scheduled Work before viewing the Contract.\n\nAre you sure you want to continue?" AlwaysEnabled="true" CausesValidation="false"  />
                            </ContextMenuButtons>
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldLabel runat="server" ID="VendorName" PropertyName="Contract.Vendor.ObjectName"
                            Caption="Vendor" meta:resourcekey="VendorNameResource1" />
                        <ui:UIFieldLabel runat="server" ID="ContractName" PropertyName="Contract.ObjectName"
                            Caption="Contract Name" meta:resourcekey="ContractNameResource1" />
                        <ui:UIFieldLabel runat="server" ID="ContractStartDate" PropertyName="Contract.ContractStartDate"
                            Caption="Contract Start" Span="Half" meta:resourcekey="ContractStartDateResource1"
                            DataFormatString="{0:dd-MMM-yyyy}" />
                        <ui:UIFieldLabel runat="server" ID="ContractEndDate" PropertyName="Contract.ContractEndDate"
                            Caption="Contract End" Span="Half" meta:resourcekey="ContractEndDateResource1"
                            DataFormatString="{0:dd-MMM-yyyy}" />
                        <ui:UIFieldLabel runat="server" ID="ContactPerson" PropertyName="Contract.ContactPerson"
                            Caption="Contact Person" meta:resourcekey="ContactPersonResource1" />
                        <ui:UIFieldLabel runat="server" ID="ContactCellphone" PropertyName="Contract.ContactCellphone"
                            Caption="Cellphone" Span="Half" meta:resourcekey="ContactCellphoneResource1" />
                        <ui:UIFieldLabel runat="server" ID="ContactEmail" PropertyName="Contract.ContactEmail"
                            Caption="Email" Span="Half" meta:resourcekey="ContactEmailResource1" />
                        <ui:UIFieldLabel runat="server" ID="ContactFax" PropertyName="Contract.ContactFax"
                            Caption="Fax" Span="Half" meta:resourcekey="ContactFaxResource1" />
                        <ui:UIFieldLabel runat="server" ID="ContactPhone" PropertyName="Contract.ContactPhone"
                            Caption="Phone" Span="Half" meta:resourcekey="ContactPhoneResource1" />
                    </ui:UIPanel>
                </ui:uitabview>
                <ui:UITabView runat="server" ID="tabCost" Caption="Cost" meta:resourcekey="uitabview6Resource1">
                    <ui:UIButton runat="server" ID="buttonAddMaterials" Text="Add Multiple Inventory Items"
                        ImageUrl="~/images/add.gif" OnClick="buttonAddMaterials_Clicked" CausesValidation="false"
                         meta:resourcekey="buttonAddMaterialsResource1" />
                    <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="false"
                        OnClick="buttonItemsAdded_Click" meta:resourcekey="buttonItemsAddedResource1" ></ui:UIButton>
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="ScheduledWorkCost" Caption="Work Cost" PropertyName="ScheduledWorkCost"
                        SortExpression="Type" KeyName="ObjectID" meta:resourcekey="ScheduledWorkCostResource1"
                        Width="100%">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" AlwaysEnabled="true"
                                HeaderText="" meta:resourceKey="UIGridViewColumnResource1" >
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                ConfirmText="Are you sure you wish to delete this item?" HeaderText="" meta:resourceKey="UIGridViewColumnResource2" >
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CostTypeName" HeaderText="Type"  >
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CraftStore" HeaderText="Craft / Store"  >
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CostDescription" HeaderText="Description"  >
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataFormatString="{0:c}" PropertyName="EstimatedUnitCost"
                                HeaderText="Est. Unit Price<br/>(Base Currency)" HtmlEncode="false">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataFormatString="{0:#,##0.00}" PropertyName="EstimatedCostFactor"
                                HeaderText="Est. Factor" meta:resourceKey="UIGridViewColumnResource6"  >
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataFormatString="{0:#,##0.00}" PropertyName="EstimatedQuantity"
                                HeaderText="Est. Qty" meta:resourceKey="UIGridViewColumnResource7"  >
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataFormatString="{0:c}" PropertyName="EstimatedSubTotal"
                                HeaderText="Subtotal<br/>(Base Currency)" HtmlEncode="false">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                        <Commands>
                            <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourceKey="UIGridViewCommandResource1">
                            </ui:UIGridViewCommand>
                            <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"
                                meta:resourceKey="UIGridViewCommandResource2"></ui:UIGridViewCommand>
                        </Commands>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="WorkCost_ObjectPanel" meta:resourcekey="WorkCost_ObjectPanelResource1"
                        Width="100%">
                        <web:subpanel runat="server" ID="WorkCost_SubPanel" GridViewID="ScheduledWorkCost"
                            MultiSelectColumnNames="CatalogueID,UnitOfMeasureID,StoreID,StoreBinID,EstimatedQuantity,CostType"
                            OnPopulateForm="WorkCost_SubPanel_PopulateForm" OnValidateAndUpdate="WorkCost_SubPanel_ValidateAndUpdate" meta:resourcekey="WorkCost_SubPanelResource1" >
                        </web:subpanel>
                        <ui:UIFieldRadioList runat="server" ID="WorkCost_CostType" PropertyName="CostType"
                            Caption="Type" OnSelectedIndexChanged="CostType_SelectedIndexChanged" RepeatColumns="0"
                            ValidateRequiredField="true" meta:resourcekey="WorkCost_CostTypeResource1">
                            <Items>
                                <asp:ListItem Text="Craft/Technician" Value="0"  >
                                </asp:ListItem>
                                <asp:ListItem Text="Inventory" Value="3"  >
                                </asp:ListItem>
                                <asp:ListItem Text="Others" Value="2"  >
                                </asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel1" meta:resourcekey="WorkCost_Panel1Resource1"
                            Width="100%">
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_CraftID" PropertyName="CraftID"
                                Caption="Craft" OnSelectedIndexChanged="WorkCost_CraftID_SelectedIndexChanged"
                                ToolTip="The craft of the technician that will be assigned to the work." meta:resourcekey="WorkCost_CraftIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_UserID" PropertyName="UserID"
                                Caption="Technician" ToolTip="The technician that will be assigned to the work." meta:resourcekey="WorkCost_UserIDResource1" >
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldRadioList runat="server" ID="WorkCost_EstimatedOvertime" PropertyName="EstimatedOvertime"
                                Caption="Overtime Work?" ValidateRequiredField="True" OnSelectedIndexChanged="WorkCost_EstimatedOvertime_SelectedIndexChanged"
                                meta:resourcekey="WorkCost_EstimatedOvertimeResource1">
                                <Items>
                                    <asp:ListItem Text="Yes" Value="1"  >
                                    </asp:ListItem>
                                    <asp:ListItem Text="No" Value="0"  >
                                    </asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel3" meta:resourcekey="WorkCost_Panel3Resource1"
                            Width="100%">
                            <ui:UIFieldTextBox ID="WorkCost_Name" runat="server" Caption="Description" PropertyName="ObjectName"
                                ValidateRequiredField="True" MaxLength="255" meta:resourcekey="WorkCost_NameResource1" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel4" Width="100%">
                            <ui:UIFieldPopupSelection ID="WorkCost_CatalogueID" runat="server" Caption="Catalog"
                                PropertyNameItem="Catalogue.Path" PropertyName="CatalogueID" ValidateRequiredField="True"
                                PopupUrl="../../popup/selectcatalogue/main.aspx" OnSelectedValueChanged="CatalogueID_SelectedValueChanged"  meta:resourcekey="WorkCost_CatalogueIDResource1" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_PanelUOM" Width="100%">
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_UnitOfMeasureID" PropertyName="UnitOfMeasureID"
                                OnSelectedIndexChanged="UnitOfMeasureID_SelectedIndexChanged" Caption="Check-Out Unit"
                                Span="full" ValidateRequiredField="true"  meta:resourcekey="WorkCost_UnitOfMeasureIDResource1" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel4_1" Width="100%">
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_StoreID" PropertyName="StoreID"
                                Caption="Store" Span="half" OnSelectedIndexChanged="StoreID_SelectedIndexChanged"  meta:resourcekey="WorkCost_StoreIDResource1" />
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_StoreBinID" PropertyName="StoreBinID"
                                OnSelectedIndexChanged="StoreBinID_SelectedIndexChanged" Caption="Bin (Avail Qty)"
                                Span="half" ToolTip="The bin where this item is checked out from." meta:resourcekey="WorkCost_StoreBinIDResource1" >
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <div style="width: 49%; float: left">
                            <ui:UIFieldLabel runat="server" ID="WorkCost_Estimated" Caption="Estimated" Font-Bold="True"
                                meta:resourcekey="WorkCost_EstimatedResource1" />
                            <ui:UIFieldTextBox ID="WorkCost_EstimatedUnitCost" runat="server" Caption="Unit Price"
                                PropertyName="EstimatedUnitCost" ValidateRequiredField="True" ToolTip="The unit price incurred when using this cost."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="99999999999" ValidationRangeType="Currency"
                                meta:resourcekey="WorkCost_EstimatedUnitCostResource1" />
                            <ui:UIFieldTextBox ID="WorkCost_EstimatedCostFactor" runat="server" Caption="Price Factor"
                                PropertyName="EstimatedCostFactor" ValidateRequiredField="True" ToolTip="The price factor to be applied when using this cost."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="100" ValidationRangeType="Currency"
                                meta:resourcekey="WorkCost_EstimatedCostFactorResource1" />
                            <ui:UIFieldTextBox ID="WorkCost_EstimatedQuantity" runat="server" Caption="Quantity"
                                PropertyName="EstimatedQuantity" ValidateRequiredField="True" ToolTip="The quantity of the item or resource to be used for the generate works."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="1000000" ValidationRangeType="Currency"
                                meta:resourcekey="WorkCost_EstimatedQuantityResource1" />
                        </div>
                        <br />
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabChecklist" Caption="Checklist" meta:resourcekey="uitabview7Resource1">
                <ui:UIButton runat="server" ID="UIButton1" ImageUrl="~/images/calendar.gif" Text="Preview Work Schedule" OnClick="btCalendarPreview_Click" CausesValidation="false"  meta:resourcekey="UIButton1Resource1" />
                    <br />
                    <ui:UIPanel runat="server" ID="panelParameters" meta:resourcekey="panelParametersResource1"
                        Width="100%">
                        <%--<ui:UIFieldListBox runat="server" ID="ScheduledWorkEquipmentTypeParameters" PropertyName="ScheduledWorkEquipmentTypeParameters"
                            Caption="Parameters" ToolTip="The list of parameters to perform readings on. Ctrl-Click to select multiple parameters."
                            meta:resourcekey="listParametersResource1"></ui:UIFieldListBox>
                        <ui:UIFieldListBox runat="server" ID="ScheduledWorkLocationTypeParameters" PropertyName="ScheduledWorkLocationTypeParameters"
                            Caption="Parameters" ToolTip="The list of parameters to perform readings on. Ctrl-Click to select multiple parameters."
                            meta:resourcekey="listParametersResource1"></ui:UIFieldListBox>
                        <ui:UISeparator runat='server' ID='sep1' meta:resourcekey="sep1Resource1" />--%>
                        <ui:UIGridView runat="server" ID="ScheduledWorkChecklist" Caption="Checklist Sequencing"
                            PropertyName="ScheduledWorkChecklist" SortExpression="CycleNumber" KeyName="ObjectID"
                            meta:resourcekey="ScheduledWorkChecklistResource1" Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                    HeaderText="" meta:resourceKey="UIGridViewColumnResource1"  >
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                    ConfirmText="Are you sure you wish to delete this item?" HeaderText="" meta:resourceKey="UIGridViewColumnResource2"  >
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CycleNumber" HeaderText="Cycle Number" meta:resourceKey="UIGridViewColumnResource3"  >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Checklist.ObjectName" HeaderText="Checklist"
                                    meta:resourceKey="UIGridViewColumnResource4"  >
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourceKey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"
                                    meta:resourceKey="UIGridViewCommandResource2"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="ScheduledWorkChecklist_Panel" meta:resourcekey="WorkCost_ObjectPanelResource1"
                            Width="100%">
                            <web:subpanel runat="server" ID="ScheduledWorkChecklist_SubPanel" GridViewID="ScheduledWorkChecklist"
                                OnPopulateForm="ScheduledWorkChecklist_SubPanel_PopulateForm" OnValidateAndUpdate="ScheduledWorkChecklist_SubPanel_ValidateAndUpdate"
                                OnDeleted="ScheduledWorkChecklist_Deleted" OnRemoved="ScheduledWorkChecklist_SubPanel_Removed" meta:resourcekey="ScheduledWorkChecklist_SubPanelResource1" >
                            </web:subpanel>
                            <ui:UIFieldTreeList runat="server" ID="ChecklistID" PropertyName="ChecklistID" OnAcquireTreePopulater="ChecklistID_AcquireTreePopulater"
                                Caption="Checklist" ValidateRequiredField='True' ToolTip="The checklist to be used for this sequence."
                                meta:resourcekey="ChecklistIDResource1">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldDropDownList runat='server' ID="CycleNumber" Span="Half" PropertyName="CycleNumber"
                                Caption="Cycle Number" ValidateRequiredField='True' ToolTip="The cycle number of the sequence. The first work uses cycle number 1, the second cycle number 2, and so on. If there are only 3 checklist sequences, then the fourth work returns to use cycle number 1."
                                meta:resourcekey="CycleNumberResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <%--<ui:UITabView runat="server" ID="tabPreview" Caption="Preview" meta:resourcekey="tabPreviewResource1" OnClick="tabPreview_Click">
                <iframe runat="server" src="about::blank" width="100%" height="100%" id="framePreview"
                        style="border: solid 1px silver" name="framePreview"></iframe>
                </ui:UITabView>--%>
                <ui:UITabView runat="server" ID="tabWorks" Caption="Works" meta:resourcekey="tabWorksResource1">
                    <ui:UIButton runat="server" ID="buttonShowChart" ImageUrl="~/images/view.gif" OnClick="buttonShowChart_Click"
                        AlwaysEnabled="true" Text="Show Gantt Chart" meta:resourcekey="buttonShowChartResource1">
                    </ui:UIButton>
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="Works" PropertyName="Works" Caption="Works" KeyName="ObjectID"
                        meta:resourcekey="WorksResource1" Width="100%" CheckBoxColumnVisible="false"
                        SortExpression="ObjectNumber" OnAction="Works_Action" OnRowDataBound="Works_RowDataBound">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" HeaderText="" ConfirmText="Please remember to save this Scheduled Work before editing the Work.\n\nAre you sure you want to continue?" AlwaysEnabled="true">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewObject" HeaderText="" ConfirmText="Please remember to save this Scheduled Work before viewing the Work.\n\nAre you sure you want to continue?" AlwaysEnabled="true">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="WorkDescription" HeaderText="Description"
                                meta:resourcekey="UIGridViewColumnResource9">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Work Number" meta:resourcekey="UIGridViewColumnResource10">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Location.ObjectName" HeaderText="Location"
                                meta:resourcekey="UIGridViewColumnResource11">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Equipment.ObjectName" HeaderText="Equipment"
                                meta:resourcekey="UIGridViewColumnResource12">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Checklist.ObjectName" HeaderText="Checklist"
                                meta:resourcekey="UIGridViewColumnResource13">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ScheduledStartDateTime" HeaderText="Start Date/Time"
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" meta:resourcekey="UIGridViewColumnResource14">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ScheduledEndDateTime" HeaderText="End Date/Time"
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" meta:resourcekey="UIGridViewColumnResource15">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status"
                                ResourceName="Resources.WorkflowStates"  >
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:uihint runat="server" id="hintWorks" meta:resourcekey="hintWorksResource1">
                        The Works are not generated immediately by the system. It may take several 
                        minutes, or longer, depending on whether the system is busy with generating
                        Works for other Scheduled Works requested previously.
                        <br />
                        <br />
                        If you have selected to create works some number of days in advance, those
                        system will generate those Works that many days before the scheduled
                        start date.
                    </ui:uihint>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview8" Caption="Memo" meta:resourcekey="uitabview8Resource1">
                    <web:memo ID="Memo1" runat="server" meta:resourcekey="Memo1Resource1" ></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" meta:resourcekey="uitabview2Resource1">
                    <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1" ></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
