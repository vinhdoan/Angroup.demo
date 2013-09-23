<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

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
        if(!IsPostBack)
        {
            ScheduledWorkCost.Columns[5].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            ScheduledWorkCost.Columns[8].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            WorkCost_EstimatedUnitCost.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
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

        // Set the priority text
        //
        if (!IsPostBack)
        {
            Priority.Items[1].Text = Resources.Strings.Work_Priority0;
            Priority.Items[2].Text = Resources.Strings.Work_Priority1;
            Priority.Items[3].Text = Resources.Strings.Work_Priority2;
            Priority.Items[4].Text = Resources.Strings.Work_Priority3;
        }
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
        return new LocationEquipmentTreePopulaterForCapitaland(work.LocationID, true, true, true, Security.Decrypt(Request["TYPE"]));
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
            // 2010.05.14
            // Modified to get all craft instead.
            //
            WorkCost_CraftID.Bind(OCraft.GetAllCraft());
            
            //WorkCost_CraftID.Bind(OCraft.GetCraftByLocation(work.Location));
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

        // 2010.05.14
        // Kim Foong
        // Make sure we bind the data from screen first.
        //
        WorkCost_SubPanel.ObjectPanel.BindControlsToObject(scheduledWorkCost);

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

        // Validates quantity if its a Whole Number according to Catalog Type
        if (WorkCost_CatalogueID.SelectedValue != "")
        {
            OCatalogue cat = TablesLogic.tCatalogue.Load(new Guid(WorkCost_CatalogueID.SelectedValue));
            OCode code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == cat.UnitOfMeasureID);
            if (code != null && code.IsWholeNumberUnit == 1 && NumberDecimalPlaces(WorkCost_EstimatedQuantity.Text) != 0)
            {
                WorkCost_EstimatedQuantity.ErrorMessage = Resources.Errors.CheckIn_WholeNumberQuantityFailed;
                return;
            }
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

        if (scheduledWork.FirstWorkStartDateTime != null)
        {
            scheduledWork.FirstWorkStartDateTime = new DateTime(
                scheduledWork.FirstWorkStartDateTime.Value.Year,
                scheduledWork.FirstWorkStartDateTime.Value.Month,
                scheduledWork.FirstWorkStartDateTime.Value.Day,
                08, 30, 00);
        }
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

    /// <summary>
    /// GridView RowDataBound for formatting of the UnitOfMeasure
    /// </summary>
    protected void gridCheckInItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OCode c = TablesLogic.tCode.Load(
                TablesLogic.tCode.CodeType.ObjectName == "UnitOfMeasure" &
                TablesLogic.tCode.ObjectName == e.Row.Cells[6].Text);
            if (c != null && c.IsWholeNumberUnit == 1)
            {
                e.Row.Cells[8].Text = Convert.ToDecimal(e.Row.Cells[9].Text).ToString("#,##0");
                e.Row.Cells[13].Text = Convert.ToDecimal(e.Row.Cells[13].Text).ToString("#,##0");
            }
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet" >
        <web:object runat="server" ID="panel" Caption="Scheduled Work" BaseTable="tScheduledWork"
            OnValidateAndSave="panel_ValidateAndSave" OnPopulateForm="panel_PopulateForm"
            meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberCaption="Schedule Number" ObjectNumberEnabled="false"
                        ObjectNameVisible="false" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIPanel runat="server" ID='panelDetails' BorderStyle="NotSet" 
                        meta:resourcekey="panelDetailsResource1">
                        <ui:UIFieldTreeList runat="server" ID="Location" Caption="Location" OnSelectedNodeChanged="Location_SelectedNodeChanged"
                            PropertyName="LocationID" OnAcquireTreePopulater="Location_AcquireTreePopulater"
                            ToolTip="Use this to select the location that this work applies to." meta:resourcekey="LocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UIFieldTreeList runat="server" ID="Equipment" Caption="Equipment" OnSelectedNodeChanged="Equipment_SelectedNodeChanged"
                            PropertyName="EquipmentID" OnAcquireTreePopulater="Equipment_AcquireTreePopulater"
                            ToolTip="Use this to select the equipment that this work applies to." meta:resourcekey="EquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabItems" Caption="Items" meta:resourcekey="tabItemsResource1" BorderStyle="NotSet">
                    <ui:UIFieldRadioList runat="server" ID="EquipmentLocation" PropertyName="EquipmentLocation"
                        Caption="Schedule For" ValidateRequiredField="True" OnSelectedIndexChanged="EquipmentLocation_SelectedIndexChanged"
                        ToolTip="Indicates if the works generated are for locations or equipment." meta:resourcekey="EquipmentLocationResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="EquipmentLocation_ListItemResource1" Text="Equipment"></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="EquipmentLocation_ListItemResource2" Text="Location"></asp:ListItem>
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
                        meta:resourcekey="IsStaggeredResource1" OnCheckedChanged="IsStaggered_CheckedChanged" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldListBox runat="server" ID="ScheduledWorkEquipment" PropertyName="ScheduledWorkEquipment"
                        Caption="Equipment List" ValidateRequiredField="True" meta:resourcekey="ScheduledWorkEquipmentResource1"></ui:UIFieldListBox>
                    <ui:UIFieldListBox runat="server" ID="ScheduledWorkLocation" PropertyName="ScheduledWorkLocation"
                        Caption="Location List" ValidateRequiredField="True" meta:resourcekey="ScheduledWorkLocationResource1"></ui:UIFieldListBox>
                    <ui:UIFieldDropDownList runat="server" ID="StaggerBy" PropertyName="StaggerBy" Caption="Stagger By:"
                        ValidateRequiredField="True" Span="Half" ToolTip="Indicates the unit of time by which to stagger the works."
                        meta:resourcekey="StaggerByResource1">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource3" Text="Day(s)"  ></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource4" Text="Week(s)"  ></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource5" Text="Month(s)"  ></asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource6" Text="Year(s)"  ></asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <br />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="ScheduledWorkStaggeredEquipment" PropertyName="ScheduledWorkStaggeredEquipment"
                        Caption="Equipment List" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="ScheduledWorkStaggeredEquipmentResource1"
                        Width="100%" SortExpression="Equipment.ObjectName" 
                        CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both" 
                        RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="Equipment.ObjectName" HeaderText="Equipment" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Equipment.ObjectName" ResourceAssemblyName="" SortExpression="Equipment.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" Width="70%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Stagger" meta:resourceKey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <cc1:UIFieldDropDownList ID="Equipment_UnitsToStagger" runat="server" CaptionWidth="1px" meta:resourceKey="Equipment_UnitsToStaggerResource1" PropertyName="UnitsToStagger">
                                        <Items>
                                            <asp:ListItem meta:resourcekey="ListItemResource7" Selected="True" Text="N/A"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource8" Value="0" Text="00"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource9" Value="1" Text="01"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource10" Value="2" Text="02"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource11" Value="3" Text="03"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource12" Value="4" Text="04"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource13" Value="5" Text="05"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource14" Value="6" Text="06"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource15" Value="7" Text="07"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource16" Value="8" Text="08"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource17" Value="9" Text="09"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource18" Value="10" Text="10"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource20" Value="11" Text="11"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource21" Value="12" Text="12"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource22" Value="13" Text="13"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource23" Value="14" Text="14"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource24" Value="15" Text="15"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource25" Value="16" Text="16"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource26" Value="17" Text="17"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource27" Value="18" Text="18"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource28" Value="19" Text="19"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource29" Value="20" Text="20"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource31" Value="21" Text="21"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource32" Value="22" Text="22"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource33" Value="23" Text="23"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource34" Value="24" Text="24"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource35" Value="25" Text="25"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource36" Value="26" Text="26"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource37" Value="27" Text="27"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource38" Value="28" Text="28"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource39" Value="29" Text="29"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource40" Value="30" Text="30"></asp:ListItem>
                                        </Items>
                                    </cc1:UIFieldDropDownList>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIGridView runat="server" ID="ScheduledWorkStaggeredLocation" PropertyName="ScheduledWorkStaggeredLocation"
                        Caption="Location List" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="ScheduledWorkStaggeredLocationResource1"
                        Width="100%" CheckBoxColumnVisible="False" DataKeyNames="ObjectID" 
                        GridLines="Both" RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="Location.ObjectName" HeaderText="Location" meta:resourceKey="ScheduledWorkStaggeredLocation_UIGridViewResource1" PropertyName="Location.ObjectName" ResourceAssemblyName="" SortExpression="Location.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" Width="70%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Stagger" meta:resourceKey="ScheduledWorkStaggeredLocation_UIGridViewResource2">
                                <ItemTemplate>
                                    <cc1:UIFieldDropDownList ID="Location_UnitsToStagger" runat="server" CaptionWidth="1px" meta:resourceKey="Location_UnitsToStaggerResource1" PropertyName="UnitsToStagger">
                                        <Items>
                                            <asp:ListItem meta:resourcekey="ListItemResource41" Selected="True" Text="N/A"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource42" Value="0" Text="00"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource43" Value="1" Text="01"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource44" Value="2" Text="02"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource45" Value="3" Text="03"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource46" Value="4" Text="04"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource47" Value="5" Text="05"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource48" Value="6" Text="06"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource49" Value="7" Text="07"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource50" Value="8" Text="08"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource51" Value="9" Text="09"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource52" Value="10" Text="10"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource53" Value="11" Text="11"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource54" Value="12" Text="12"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource55" Value="13" Text="13"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource56" Value="14" Text="14"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource57" Value="15" Text="15"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource58" Value="16" Text="16"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource59" Value="17" Text="17"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource60" Value="18" Text="18"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource61" Value="19" Text="19"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource62" Value="20" Text="20"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource63" Value="20" Text="20"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource64" Value="21" Text="21"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource65" Value="22" Text="22"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource66" Value="23" Text="23"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource67" Value="24" Text="24"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource68" Value="25" Text="25"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource69" Value="26" Text="26"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource70" Value="27" Text="27"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource71" Value="28" Text="28"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource72" Value="29" Text="29"></asp:ListItem>
                                            <asp:ListItem meta:resourcekey="ListItemResource73" Value="30" Text="30"></asp:ListItem>
                                        </Items>
                                    </cc1:UIFieldDropDownList>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabRecurrence" Caption="Recurrence" meta:resourcekey="tabRecurrenceResource1" BorderStyle="NotSet">
                
                    <ui:UIButton runat="server" ID="btCalendarPreview" ImageUrl="~/images/calendar.gif" Text="Preview Work Schedule" OnClick="btCalendarPreview_Click" CausesValidation="False" AlwaysEnabled="True" meta:resourcekey="btCalendarPreviewResource1" />
                    <br />
                    <ui:UISeparator ID="Separator1" runat="server" Caption="Work" meta:resourcekey="Separator1Resource1" />
                    <ui:UIPanel runat="server" ID="panelTypeOfWork" meta:resourcekey="panelTypeOfWorkResource1" BorderStyle="NotSet" >
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
                            <asp:ListItem Selected="True" meta:resourcekey="ListItemResource74"  ></asp:ListItem>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource75" Text="0 (Lowest)"  ></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource76" Text="1"  ></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource77" Text="2"  ></asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource78" Text="3 (Highest)"  ></asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="WorkDescription" PropertyName="WorkDescription"
                        Caption="Work Description" ValidateRequiredField="True" MaxLength="255" meta:resourcekey="WorkDescriptionResource1" InternalControlWidth="95%" />
                    <ui:UISeparator ID="Separator2" runat="server" Caption="Schedule" meta:resourcekey="Separator2Resource1" />
                    <ui:UIPanel runat="server" ID="panelDate" meta:resourcekey="panelDateResource1" BorderStyle="NotSet" >
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkStartDateTime" PropertyName="FirstWorkStartDateTime"
                            Caption="First Work's Start" ValidateRequiredField="True" ShowTimeControls='True'
                            OnDateTimeChanged="ScheduledStartDateTime_DateTimeChanged" Span="Half" ToolTip="The start date/time of the FIRST work."
                            ValidationCompareControl="FirstWorkEndDateTime" ValidateCompareField='True' ValidationCompareOperator="LessThanEqual"
                            ValidationCompareType="Date" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            meta:resourcekey="FirstWorkStartDateTimeResource1" ShowDateControls="True">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkEndDateTime" PropertyName="FirstWorkEndDateTime"
                            Caption="First Work's End" ValidateRequiredField="True" ShowTimeControls='True'
                            Span="Half" ToolTip="The end date/time of the FIRST work. Note: This does not indicate the end date/time for the list of works."
                            ValidationCompareControl="FirstWorkStartDateTime" ValidateCompareField='True'
                            ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="FirstWorkEndDateTimeResource1" ShowDateControls="True">
                        </ui:UIFieldDateTime>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat="server" ID="IsFloating" PropertyName="IsFloating" Caption="Fixed/Floating"
                        RepeatDirection="Vertical" ValidateRequiredField="True" ToolTip="Indicates if the works generated are fixed or floating."
                        meta:resourcekey="IsFloatingResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource80" Text="Fixed: create all works immediately."></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource81" Text="Floating: create only first work; all subsequent works are created when the previous completes."></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldDropDownList runat="server" ID="FrequencyCount" PropertyName="FrequencyCount"
                        Caption="Every" ValidateRequiredField="True" Span="Half" meta:resourcekey="FrequencyCountResource1">
                        <Items>
                            <asp:ListItem Selected="True" Value="1" meta:resourcekey="ListItemResource79" Text="01"  ></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource82" Text="02"  ></asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource83" Text="03"  ></asp:ListItem>
                            <asp:ListItem Value="4" meta:resourcekey="ListItemResource84" Text="04"  ></asp:ListItem>
                            <asp:ListItem Value="5" meta:resourcekey="ListItemResource85" Text="05"  ></asp:ListItem>
                            <asp:ListItem Value="6" meta:resourcekey="ListItemResource86" Text="06"  ></asp:ListItem>
                            <asp:ListItem Value="7" meta:resourcekey="ListItemResource87" Text="07"  ></asp:ListItem>
                            <asp:ListItem Value="8" meta:resourcekey="ListItemResource88" Text="08"  ></asp:ListItem>
                            <asp:ListItem Value="9" meta:resourcekey="ListItemResource89" Text="09"  ></asp:ListItem>
                            <asp:ListItem Value="10" meta:resourcekey="ListItemResource90" Text="10"  ></asp:ListItem>
                            <asp:ListItem Value="11" meta:resourcekey="ListItemResource91" Text="11"  ></asp:ListItem>
                            <asp:ListItem Value="12" meta:resourcekey="ListItemResource92" Text="12"  ></asp:ListItem>
                            <asp:ListItem Value="13" meta:resourcekey="ListItemResource93" Text="13"  ></asp:ListItem>
                            <asp:ListItem Value="14" meta:resourcekey="ListItemResource94" Text="14"  ></asp:ListItem>
                            <asp:ListItem Value="15" meta:resourcekey="ListItemResource95" Text="15"  ></asp:ListItem>
                            <asp:ListItem Value="16" meta:resourcekey="ListItemResource96" Text="16"  ></asp:ListItem>
                            <asp:ListItem Value="17" meta:resourcekey="ListItemResource97" Text="17"  ></asp:ListItem>
                            <asp:ListItem Value="18" meta:resourcekey="ListItemResource98" Text="18"  ></asp:ListItem>
                            <asp:ListItem Value="19" meta:resourcekey="ListItemResource99" Text="19"  ></asp:ListItem>
                            <asp:ListItem Value="20" meta:resourcekey="ListItemResource100" Text="20"  ></asp:ListItem>
                            <asp:ListItem Value="21" meta:resourcekey="ListItemResource101" Text="21"  ></asp:ListItem>
                            <asp:ListItem Value="22" meta:resourcekey="ListItemResource102" Text="22"  ></asp:ListItem>
                            <asp:ListItem Value="23" meta:resourcekey="ListItemResource103" Text="23"  ></asp:ListItem>
                            <asp:ListItem Value="24" meta:resourcekey="ListItemResource104" Text="24"  ></asp:ListItem>
                            <asp:ListItem Value="25" meta:resourcekey="ListItemResource105" Text="25"  ></asp:ListItem>
                            <asp:ListItem Value="26" meta:resourcekey="ListItemResource106" Text="26"  ></asp:ListItem>
                            <asp:ListItem Value="27" meta:resourcekey="ListItemResource107" Text="27"  ></asp:ListItem>
                            <asp:ListItem Value="28" meta:resourcekey="ListItemResource108" Text="28"  ></asp:ListItem>
                            <asp:ListItem Value="29" meta:resourcekey="ListItemResource109" Text="29"  ></asp:ListItem>
                            <asp:ListItem Value="30" meta:resourcekey="ListItemResource110" Text="30"  ></asp:ListItem>
                            <asp:ListItem Value="31" meta:resourcekey="ListItemResource111" Text="31"  ></asp:ListItem>
                            <asp:ListItem Value="32" meta:resourcekey="ListItemResource112" Text="32"  ></asp:ListItem>
                            <asp:ListItem Value="33" meta:resourcekey="ListItemResource113" Text="33"  ></asp:ListItem>
                            <asp:ListItem Value="34" meta:resourcekey="ListItemResource114" Text="34"  ></asp:ListItem>
                            <asp:ListItem Value="35" meta:resourcekey="ListItemResource115" Text="35"  ></asp:ListItem>
                            <asp:ListItem Value="36" meta:resourcekey="ListItemResource116" Text="36"  ></asp:ListItem>
                            <asp:ListItem Value="37" meta:resourcekey="ListItemResource117" Text="37"  ></asp:ListItem>
                            <asp:ListItem Value="38" meta:resourcekey="ListItemResource118" Text="38"  ></asp:ListItem>
                            <asp:ListItem Value="39" meta:resourcekey="ListItemResource119" Text="39"  ></asp:ListItem>
                            <asp:ListItem Value="40" meta:resourcekey="ListItemResource120" Text="40"  ></asp:ListItem>
                            <asp:ListItem Value="41" meta:resourcekey="ListItemResource121" Text="41"  ></asp:ListItem>
                            <asp:ListItem Value="42" meta:resourcekey="ListItemResource122" Text="42"  ></asp:ListItem>
                            <asp:ListItem Value="43" meta:resourcekey="ListItemResource123" Text="43"  ></asp:ListItem>
                            <asp:ListItem Value="44" meta:resourcekey="ListItemResource124" Text="44"  ></asp:ListItem>
                            <asp:ListItem Value="45" meta:resourcekey="ListItemResource125" Text="45"  ></asp:ListItem>
                            <asp:ListItem Value="46" meta:resourcekey="ListItemResource126" Text="46"  ></asp:ListItem>
                            <asp:ListItem Value="47" meta:resourcekey="ListItemResource127" Text="47"  ></asp:ListItem>
                            <asp:ListItem Value="48" meta:resourcekey="ListItemResource128" Text="48"  ></asp:ListItem>
                            <asp:ListItem Value="49" meta:resourcekey="ListItemResource129" Text="49"  ></asp:ListItem>
                            <asp:ListItem Value="50" meta:resourcekey="ListItemResource130" Text="50"  ></asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="FrequencyInterval" PropertyName="FrequencyInterval"
                        Caption="Interval" ValidateRequiredField="True" Span="Half" meta:resourcekey="FrequencyIntervalResource1"
                        OnSelectedIndexChanged="FrequencyInterval_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="FrequencyInterval_ListItemResource1" Text="Day(s)"></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="FrequencyInterval_ListItemResource2" Text="Week(s)"></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="FrequencyInterval_ListItemResource3" Text="Month(s)"></asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="FrequencyInterval_ListItemResource4" Text="Year(s)"></asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIPanel runat="server" ID="panelFixedFloatingParameters" Width="100%" BorderStyle="NotSet" meta:resourcekey="panelFixedFloatingParametersResource1">
                        <ui:UIPanel runat="server" ID="panelWeekType" Width="100%" meta:resourcekey="panelWeekTypeResource1" BorderStyle="NotSet">
                            <ui:UIFieldRadioList runat="server" ID="WeekType" PropertyName="WeekType" Caption="Schedule"
                                RepeatDirection="Vertical" ValidateRequiredField="True" meta:resourcekey="WeekTypeResource2"
                                OnSelectedIndexChanged="WeekType_SelectedIndexChanged" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource136" Text="Same day of every week"></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource137" Text="Specific day/days of the week"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="panelWeekTypeDay" Width="100%" meta:resourcekey="panelWeekTypeDayResource1" BorderStyle="NotSet">
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay0" PropertyName="WeekTypeDay0"
                                    Caption="Day of Week*" Text="Sunday" meta:resourcekey="WeekTypeDay0Resource1" TextAlign="Right" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay1" PropertyName="WeekTypeDay1"
                                    Text="Monday" meta:resourcekey="WeekTypeDay1Resource1" TextAlign="Right" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay2" PropertyName="WeekTypeDay2"
                                    Text="Tuesday" meta:resourcekey="WeekTypeDay2Resource1" TextAlign="Right" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay3" PropertyName="WeekTypeDay3"
                                    Text="Wednesday" meta:resourcekey="WeekTypeDay3Resource1" TextAlign="Right" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay4" PropertyName="WeekTypeDay4"
                                    Text="Thursday" meta:resourcekey="WeekTypeDay4Resource1" TextAlign="Right" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay5" PropertyName="WeekTypeDay5"
                                    Text="Friday" meta:resourcekey="WeekTypeDay5Resource1" TextAlign="Right" />
                                <ui:UIFieldCheckBox runat="server" ID="WeekTypeDay6" PropertyName="WeekTypeDay6"
                                    Text="Saturday" meta:resourcekey="WeekTypeDay6Resource1" TextAlign="Right" />
                            </ui:UIPanel>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelMonthType" Width="100%" meta:resourcekey="panelMonthTypeResource1" BorderStyle="NotSet">
                            <ui:UIFieldRadioList runat="server" ID="MonthType" PropertyName="MonthType" Caption="Schedule"
                                RepeatDirection="Vertical" ValidateRequiredField="True" meta:resourcekey="MonthTypeResource2"
                                OnSelectedIndexChanged="MonthType_SelectedIndexChanged" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource138" Text="Same date of every month"></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource139" Text="Specific week/day of the month"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="panelMonthTypeWeekDay" Width="100%" meta:resourcekey="panelMonthTypeWeekDayResource1" BorderStyle="NotSet">
                                <ui:UIFieldRadioList runat="server" ID="MonthTypeWeekNumber" PropertyName="MonthTypeWeekNumber"
                                    Caption="Week of Month" ValidateRequiredField="True" RepeatColumns="0" meta:resourcekey="MonthTypeWeekNumberResource1" TextAlign="Right">
                                    <Items>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource140" Text="1st week &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="2" meta:resourcekey="ListItemResource141" Text="2nd week &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="3" meta:resourcekey="ListItemResource142" Text="3rd week &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="4" meta:resourcekey="ListItemResource143" Text="4th week &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="5" meta:resourcekey="ListItemResource144" Text="Last week &nbsp; "></asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldRadioList runat="server" ID="MonthTypeDay" PropertyName="MonthTypeDay"
                                    Caption="Day of Week" ValidateRequiredField="True" RepeatColumns="0" meta:resourcekey="MonthTypeDayResource1" TextAlign="Right">
                                    <Items>
                                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource145" Text="Sunday &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource146" Text="Monday &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="2" meta:resourcekey="ListItemResource147" Text="Tuesday &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="3" meta:resourcekey="ListItemResource148" Text="Wednesday &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="4" meta:resourcekey="ListItemResource149" Text="Thursday &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="5" meta:resourcekey="ListItemResource150" Text="Friday &nbsp; "></asp:ListItem>
                                        <asp:ListItem Value="6" meta:resourcekey="ListItemResource151" Text="Saturday &nbsp; "></asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat="server" ID="IsScheduledByOccurrence" PropertyName="IsScheduledByOccurrence"
                        RepeatDirection="Vertical" Caption="End" ValidateRequiredField="True" meta:resourcekey="IsScheduledByOccurrenceResource1"
                        OnSelectedIndexChanged="IsScheduledByOccurrence_SelectedIndexChanged" TextAlign="Right">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource152" Text="End when the date of the work reaches the specified End Date."></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource153" Text="End when the same work has been created a specified Number of Times."></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldDateTime runat="server" ID="EndDateTime" PropertyName="EndDateTime" ShowTimeControls="True"
                        ValidateRequiredField="True" Caption="End Date" ToolTip="The end date for the generated works. No works will be generated after this date/time."
                        ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="EndDateTimeResource2" ShowDateControls="True" />
                    <ui:UIFieldTextBox runat="server" ID="EndNumberOfOccurrences" PropertyName="EndNumberOfOccurrences"
                        ValidateRequiredField="True" Caption="Number of Times" ValidateDataTypeCheck='True'
                        ValidationDataType="Integer" ToolTip="The number of works that will be generated from this schedule."
                        ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer"
                        meta:resourcekey="EndNumberOfOccurrencesResource1" InternalControlWidth="95%" />
                    <ui:UISeparator runat="server" ID="UISeparator2" Caption="Scheduler"  meta:resourcekey="UISeparator2Resource1" />
                    <ui:UIFieldRadioList runat="server" ID="radioIsAllFixedWorksCreatedAtOnce" PropertyName="IsAllFixedWorksCreatedAtOnce"
                        OnSelectedIndexChanged="radioIsAllFixedWorksCreatedAtOnce_SelectedIndexChanged"
                        Caption="Work Creation" ValidateRequiredField="True" meta:resourcekey="radioIsAllFixedWorksCreatedAtOnceResource1" TextAlign="Right" >
                        <Items>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource279" Text="Yes, all works are created as soon as the system can." ></asp:ListItem>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource280" Text="No, works are created only a number of days in advance."  ></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIPanel runat="server" ID="panelAdvanceCreation" meta:resourcekey="panelAdvanceCreationResource1" BorderStyle="NotSet" >
                        <table cellpadding='1' cellspacing='0' border='0' style="width: 100%; height: 24px">
                            <tr class="field-required">
                                <td style="width: 150px">
                                    <asp:Label runat="server" ID="label1" Text="Advance Creation*:" meta:resourcekey="label1Resource1"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelNumberOfDaysInAdvanceToCreateFixedWorks1" Text="Create fixed works " meta:resourcekey="labelNumberOfDaysInAdvanceToCreateFixedWorks1Resource1" ></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textNumberOfDaysInAdvanceToCreateFixedWorks"
                                        ShowCaption="False" PropertyName="NumberOfDaysInAdvanceToCreateFixedWorks" Caption="Advance Creation"
                                        ValidateRangeField="True" ValidationRangeType="Integer" ValidationRangeMin="0" FieldLayout="Flow" InternalControlWidth="50px"
                                        ValidateRequiredField="True" meta:resourcekey="textNumberOfDaysInAdvanceToCreateFixedWorksResource1" >
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
                        RepeatDirection="Vertical" Caption="Conflict" ValidateRequiredField="True" meta:resourcekey="CalendarBlockMethodResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource154" Text="Cancel work if there is a conflict"></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource155" Text="Move work forward by one day"></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource156" Text="Move work backward by one day"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabContract" Caption="Contract" meta:resourcekey="tabContractResource1" BorderStyle="NotSet" >
                    <ui:UISeparator ID="Separator4" runat="server" Caption="Contract/Vendor" meta:resourcekey="Separator4Resource1" />
                    <ui:UIPanel runat="server" ID="panelContract" meta:resourcekey="panelContractResource1" BorderStyle="NotSet" >
                        <ui:UIFieldSearchableDropDownList runat="server" ID="ContractID" PropertyName="ContractID"
                            Caption="Contract" OnSelectedIndexChanged="ContractID_SelectedIndexChanged" ToolTip="The vendor that will be responsible for the works generated."
                            ContextMenuAlwaysEnabled="True"
                            meta:resourcekey="ContractIDResource1" SearchInterval="300">
                            <ContextMenuButtons>
                                <ui:UIButton runat="server" ID="buttonEditContract" ImageUrl="~/images/edit.gif" Text="Edit Contract" OnClick="buttonEditContract_Click" ConfirmText="Please remember to save this Scheduled Work before editing the Contract.\n\nAre you sure you want to continue?" AlwaysEnabled="True" CausesValidation="False" meta:resourcekey="buttonEditContractResource1"  />
                                <ui:UIButton runat="server" ID="buttonViewContract" ImageUrl="~/images/view.gif" Text="View Contract" OnClick="buttonViewContract_Click" ConfirmText="Please remember to save this Scheduled Work before viewing the Contract.\n\nAre you sure you want to continue?" AlwaysEnabled="True" CausesValidation="False" meta:resourcekey="buttonViewContractResource1"  />
                            </ContextMenuButtons>
                        </ui:UIFieldSearchableDropDownList>
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
                            Caption="Cellphone" Span="Half" meta:resourcekey="ContactCellphoneResource1" DataFormatString="" />
                        <ui:UIFieldLabel runat="server" ID="ContactEmail" PropertyName="Contract.ContactEmail"
                            Caption="Email" Span="Half" meta:resourcekey="ContactEmailResource1" DataFormatString="" />
                        <ui:UIFieldLabel runat="server" ID="ContactFax" PropertyName="Contract.ContactFax"
                            Caption="Fax" Span="Half" meta:resourcekey="ContactFaxResource1" DataFormatString="" />
                        <ui:UIFieldLabel runat="server" ID="ContactPhone" PropertyName="Contract.ContactPhone"
                            Caption="Phone" Span="Half" meta:resourcekey="ContactPhoneResource1" DataFormatString="" />
                    </ui:UIPanel>
                </ui:uitabview>
                <ui:UITabView runat="server" ID="tabCost" Caption="Cost" meta:resourcekey="uitabview6Resource1" BorderStyle="NotSet">
                    <ui:UIButton runat="server" ID="buttonAddMaterials" Text="Add Multiple Inventory Items"
                        ImageUrl="~/images/add.gif" OnClick="buttonAddMaterials_Clicked" CausesValidation="False"
                         meta:resourcekey="buttonAddMaterialsResource1" />
                    <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False"
                        OnClick="buttonItemsAdded_Click" meta:resourcekey="buttonItemsAddedResource1" ></ui:UIButton>
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="ScheduledWorkCost" Caption="Work Cost" PropertyName="ScheduledWorkCost"
                        SortExpression="Type" KeyName="ObjectID" meta:resourcekey="ScheduledWorkCostResource1"
                        Width="100%" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                        style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="CostTypeName" HeaderText="Type" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="CostTypeName" ResourceAssemblyName="" SortExpression="CostTypeName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CraftStore" HeaderText="Craft / Store" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="CraftStore" ResourceAssemblyName="" SortExpression="CraftStore">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CostDescription" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="CostDescription" ResourceAssemblyName="" SortExpression="CostDescription">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EstimatedUnitCost" DataFormatString="{0:c}" HeaderText="Est. Unit Price&lt;br/&gt;" HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="EstimatedUnitCost" ResourceAssemblyName="" SortExpression="EstimatedUnitCost">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EstimatedCostFactor" DataFormatString="{0:#,##0.00}" HeaderText="Est. Factor" meta:resourceKey="UIGridViewColumnResource6" PropertyName="EstimatedCostFactor" ResourceAssemblyName="" SortExpression="EstimatedCostFactor">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EstimatedQuantity" DataFormatString="{0:#,##0.00}" HeaderText="Est. Qty" meta:resourceKey="UIGridViewColumnResource7" PropertyName="EstimatedQuantity" ResourceAssemblyName="" SortExpression="EstimatedQuantity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EstimatedSubTotal" DataFormatString="{0:c}" HeaderText="Subtotal&lt;br/&gt;" HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="EstimatedSubTotal" ResourceAssemblyName="" SortExpression="EstimatedSubTotal">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="WorkCost_ObjectPanel" meta:resourcekey="WorkCost_ObjectPanelResource1"
                        Width="100%" BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="WorkCost_SubPanel" GridViewID="ScheduledWorkCost"
                            MultiSelectColumnNames="CatalogueID,UnitOfMeasureID,StoreID,StoreBinID,EstimatedQuantity,CostType"
                            OnPopulateForm="WorkCost_SubPanel_PopulateForm" OnValidateAndUpdate="WorkCost_SubPanel_ValidateAndUpdate" meta:resourcekey="WorkCost_SubPanelResource1" >
                        </web:subpanel>
                        <ui:UIFieldRadioList runat="server" ID="WorkCost_CostType" PropertyName="CostType"
                            Caption="Type" OnSelectedIndexChanged="CostType_SelectedIndexChanged" RepeatColumns="0"
                            ValidateRequiredField="True" meta:resourcekey="WorkCost_CostTypeResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Text="Craft/Technician" Value="0" meta:resourcekey="ListItemResource131"  ></asp:ListItem>
                                <asp:ListItem Text="Inventory" Value="3" meta:resourcekey="ListItemResource132"  ></asp:ListItem>
                                <asp:ListItem Text="Others" Value="2" meta:resourcekey="ListItemResource133"  ></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel1" meta:resourcekey="WorkCost_Panel1Resource1"
                            Width="100%" BorderStyle="NotSet">
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_CraftID" PropertyName="CraftID"
                                Caption="Craft" OnSelectedIndexChanged="WorkCost_CraftID_SelectedIndexChanged"
                                ToolTip="The craft of the technician that will be assigned to the work." meta:resourcekey="WorkCost_CraftIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_UserID" PropertyName="UserID"
                                Caption="Technician" ToolTip="The technician that will be assigned to the work." meta:resourcekey="WorkCost_UserIDResource1" >
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldRadioList runat="server" ID="WorkCost_EstimatedOvertime" PropertyName="EstimatedOvertime"
                                Caption="Overtime Work?" ValidateRequiredField="True" OnSelectedIndexChanged="WorkCost_EstimatedOvertime_SelectedIndexChanged"
                                meta:resourcekey="WorkCost_EstimatedOvertimeResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Text="Yes" Value="1" meta:resourcekey="ListItemResource134"  ></asp:ListItem>
                                    <asp:ListItem Text="No" Value="0" meta:resourcekey="ListItemResource135"  ></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel3" meta:resourcekey="WorkCost_Panel3Resource1"
                            Width="100%" BorderStyle="NotSet">
                            <ui:UIFieldTextBox ID="WorkCost_Name" runat="server" Caption="Description" PropertyName="ObjectName"
                                ValidateRequiredField="True" MaxLength="255" meta:resourcekey="WorkCost_NameResource1" InternalControlWidth="95%" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel4" Width="100%" BorderStyle="NotSet" meta:resourcekey="WorkCost_Panel4Resource1">
                            <ui:UIFieldPopupSelection ID="WorkCost_CatalogueID" runat="server" Caption="Catalog"
                                PropertyNameItem="Catalogue.Path" PropertyName="CatalogueID" ValidateRequiredField="True"
                                PopupUrl="../../popup/selectcatalogue/main.aspx" OnSelectedValueChanged="CatalogueID_SelectedValueChanged"  meta:resourcekey="WorkCost_CatalogueIDResource1" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_PanelUOM" Width="100%" BorderStyle="NotSet" meta:resourcekey="WorkCost_PanelUOMResource1">
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_UnitOfMeasureID" PropertyName="UnitOfMeasureID"
                                OnSelectedIndexChanged="UnitOfMeasureID_SelectedIndexChanged" Caption="Check-Out Unit" ValidateRequiredField="True"  meta:resourcekey="WorkCost_UnitOfMeasureIDResource1" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="WorkCost_Panel4_1" Width="100%" BorderStyle="NotSet" meta:resourcekey="WorkCost_Panel4_1Resource1">
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_StoreID" PropertyName="StoreID"
                                Caption="Store" Span="Half" OnSelectedIndexChanged="StoreID_SelectedIndexChanged"  meta:resourcekey="WorkCost_StoreIDResource1" />
                            <ui:UIFieldDropDownList runat="server" ID="WorkCost_StoreBinID" PropertyName="StoreBinID"
                                OnSelectedIndexChanged="StoreBinID_SelectedIndexChanged" Caption="Bin (Avail Qty)"
                                Span="Half" ToolTip="The bin where this item is checked out from." meta:resourcekey="WorkCost_StoreBinIDResource1" >
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <div style="width: 49%; float: left">
                            <ui:UIFieldLabel runat="server" ID="WorkCost_Estimated" Caption="Estimated" Font-Bold="True"
                                meta:resourcekey="WorkCost_EstimatedResource1" DataFormatString="" />
                            <ui:UIFieldTextBox ID="WorkCost_EstimatedUnitCost" runat="server" Caption="Unit Price"
                                PropertyName="EstimatedUnitCost" ValidateRequiredField="True" ToolTip="The unit price incurred when using this cost."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="99999999999" ValidationRangeType="Currency"
                                meta:resourcekey="WorkCost_EstimatedUnitCostResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox ID="WorkCost_EstimatedCostFactor" runat="server" Caption="Price Factor"
                                PropertyName="EstimatedCostFactor" ValidateRequiredField="True" ToolTip="The price factor to be applied when using this cost."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="100" ValidationRangeType="Currency"
                                meta:resourcekey="WorkCost_EstimatedCostFactorResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox ID="WorkCost_EstimatedQuantity" runat="server" Caption="Quantity"
                                PropertyName="EstimatedQuantity" ValidateRequiredField="True" ToolTip="The quantity of the item or resource to be used for the generate works."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="1000000" ValidationRangeType="Currency"
                                meta:resourcekey="WorkCost_EstimatedQuantityResource1" InternalControlWidth="95%" />
                        </div>
                        <br />
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabChecklist" Caption="Checklist" meta:resourcekey="uitabview7Resource1" BorderStyle="NotSet">
                <ui:UIButton runat="server" ID="UIButton1" ImageUrl="~/images/calendar.gif" Text="Preview Work Schedule" OnClick="btCalendarPreview_Click" CausesValidation="False"  meta:resourcekey="UIButton1Resource1" />
                    <br />
                    <ui:UIPanel runat="server" ID="panelParameters" meta:resourcekey="panelParametersResource1"
                        Width="100%" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="ScheduledWorkChecklist" Caption="Checklist Sequencing"
                            PropertyName="ScheduledWorkChecklist" SortExpression="CycleNumber" KeyName="ObjectID"
                            meta:resourcekey="ScheduledWorkChecklistResource1" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="CycleNumber" HeaderText="Cycle Number" meta:resourceKey="UIGridViewColumnResource3" PropertyName="CycleNumber" ResourceAssemblyName="" SortExpression="CycleNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Checklist.ObjectName" HeaderText="Checklist" meta:resourceKey="UIGridViewColumnResource4" PropertyName="Checklist.ObjectName" ResourceAssemblyName="" SortExpression="Checklist.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="ScheduledWorkChecklist_Panel" meta:resourcekey="WorkCost_ObjectPanelResource1"
                            Width="100%" BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="ScheduledWorkChecklist_SubPanel" GridViewID="ScheduledWorkChecklist"
                                OnPopulateForm="ScheduledWorkChecklist_SubPanel_PopulateForm" OnValidateAndUpdate="ScheduledWorkChecklist_SubPanel_ValidateAndUpdate"
                                OnDeleted="ScheduledWorkChecklist_Deleted" OnRemoved="ScheduledWorkChecklist_SubPanel_Removed" meta:resourcekey="ScheduledWorkChecklist_SubPanelResource1" >
                            </web:subpanel>
                            <ui:UIFieldTreeList runat="server" ID="ChecklistID" PropertyName="ChecklistID" OnAcquireTreePopulater="ChecklistID_AcquireTreePopulater"
                                Caption="Checklist" ValidateRequiredField='True' ToolTip="The checklist to be used for this sequence."
                                meta:resourcekey="ChecklistIDResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldDropDownList runat='server' ID="CycleNumber" Span="Half" PropertyName="CycleNumber"
                                Caption="Cycle Number" ValidateRequiredField='True' ToolTip="The cycle number of the sequence. The first work uses cycle number 1, the second cycle number 2, and so on. If there are only 3 checklist sequences, then the fourth work returns to use cycle number 1."
                                meta:resourcekey="CycleNumberResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabWorks" Caption="Works" meta:resourcekey="tabWorksResource1" BorderStyle="NotSet">
                    <ui:UIButton runat="server" ID="buttonShowChart" ImageUrl="~/images/view.gif" OnClick="buttonShowChart_Click"
                        AlwaysEnabled="True" Text="Show Gantt Chart" meta:resourcekey="buttonShowChartResource1">
                    </ui:UIButton>
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="Works" PropertyName="Works" Caption="Works" KeyName="ObjectID"
                        meta:resourcekey="WorksResource1" Width="100%" CheckBoxColumnVisible="False"
                        SortExpression="ObjectNumber" OnAction="Works_Action" 
                        OnRowDataBound="Works_RowDataBound" DataKeyNames="ObjectID" GridLines="Both" 
                        RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject" ConfirmText="Please remember to save this Scheduled Work before editing the Work.\n\nAre you sure you want to continue?" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="ViewObject" ConfirmText="Please remember to save this Scheduled Work before viewing the Work.\n\nAre you sure you want to continue?" ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="WorkDescription" HeaderText="Description" meta:resourceKey="UIGridViewColumnResource9" PropertyName="WorkDescription" ResourceAssemblyName="" SortExpression="WorkDescription">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Work Number" meta:resourceKey="UIGridViewColumnResource10" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.ObjectName" HeaderText="Location" meta:resourceKey="UIGridViewColumnResource11" PropertyName="Location.ObjectName" ResourceAssemblyName="" SortExpression="Location.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Equipment.ObjectName" HeaderText="Equipment" meta:resourceKey="UIGridViewColumnResource12" PropertyName="Equipment.ObjectName" ResourceAssemblyName="" SortExpression="Equipment.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Checklist.ObjectName" HeaderText="Checklist" meta:resourceKey="UIGridViewColumnResource13" PropertyName="Checklist.ObjectName" ResourceAssemblyName="" SortExpression="Checklist.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ScheduledStartDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Start Date/Time" meta:resourceKey="UIGridViewColumnResource14" PropertyName="ScheduledStartDateTime" ResourceAssemblyName="" SortExpression="ScheduledStartDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ScheduledEndDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="End Date/Time" meta:resourceKey="UIGridViewColumnResource15" PropertyName="ScheduledEndDateTime" ResourceAssemblyName="" SortExpression="ScheduledEndDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:uihint runat="server" id="hintWorks" meta:resourcekey="hintWorksResource1" Text="
                        The Works are not generated immediately by the system. It may take several 
                        minutes, or longer, depending on whether the system is busy with generating
                        Works for other Scheduled Works requested previously.
                        &lt;br __designer:mapid=&quot;461c&quot; /&gt;
                        &lt;br __designer:mapid=&quot;461d&quot; /&gt;
                        If you have selected to create works some number of days in advance, those
                        system will generate those Works that many days before the scheduled
                        start date.
                    "></ui:uihint>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview8" Caption="Memo" meta:resourcekey="uitabview8Resource1" BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server" meta:resourcekey="Memo1Resource1" ></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1" ></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
