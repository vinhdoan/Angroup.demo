<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectpanel.ascx" TagPrefix="web" TagName="object" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
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
        OContract contract = panel.SessionObject as OContract;

        buttonAddScheduledWork.Visible = AppSession.User.AllowCreate("OScheduledWork");

        Vendor.Bind(OVendor.GetVendors());
        //ContractTypeOfService.Bind(OCode.GetCodesByTypeOrderByParentPath("TypeOfService"), "ParentPath", "ObjectID");
        sddl_ContractTypeOfServiceID.Bind(OCode.GetCodesByTypeOrderByParentPath("TypeOfService"), "ParentPath", "ObjectID");
        Reminder1UserID.Bind(OUser.GetUsersByRole("CONTRACTADMIN"));
        Reminder2UserID.Bind(OUser.GetUsersByRole("CONTRACTADMIN"));
        Reminder3UserID.Bind(OUser.GetUsersByRole("CONTRACTADMIN"));
        Reminder4UserID.Bind(OUser.GetUsersByRole("CONTRACTADMIN"));
        treeLocationAccess.PopulateTree();
        SurveyGroupID.Bind(OSurveyGroup.GetSurveyGroupByType(1), "ObjectName", "ObjectID", true);

        // Set access control for the buttons
        //
        if (contract.PurchaseOrderID != null)
        {
            buttonViewPurchaseOrder.Visible = AppSession.User.AllowViewAll("OPurchaseOrder");
            buttonEditPurchaseOrder.Visible = AppSession.User.AllowEditAll("OPurchaseOrder") || OActivity.CheckAssignment(AppSession.User, contract.PurchaseOrderID);
        }
        else
        {
            buttonViewPurchaseOrder.Visible = false;
            buttonEditPurchaseOrder.Visible = false;
        }

        gridScheduledWorks.Columns[1].Visible = AppSession.User.AllowViewAll("OScheduledWork");
        panel.ObjectPanel.BindObjectToControls(contract);
    }


    /// <summary>
    /// Validates and saves the object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OContract contract = panel.SessionObject as OContract;
            panel.ObjectPanel.BindControlsToObject(contract);

            // Save
            //        
            contract.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Occurs when the user selects a node on the location treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocationAccess_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeLocationAccess.SelectedValue != "")
        {
            OContract contract = panel.SessionObject as OContract;
            panelLocationAccess.BindControlsToObject(contract);
            contract.Locations.AddGuid(new Guid(treeLocationAccess.SelectedValue));
            panelLocationAccess.BindObjectToControls(contract);
        }
    }


    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocationAccess_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, "OContract");
    }

    /// <summary>
    /// Constructs and returns the fixed rate tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ContractPriceServices_FixedRateID_AcquireTreePopulater(object sender)
    {
        OContractPriceService c = ContractPriceServices_SubPanel.SessionObject as OContractPriceService;
        return new FixedRateTreePopulater(c.FixedRateID, true, true);
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ContractPriceMaterials_CatalogID_AcquireTreePopulater(object sender)
    {
        OContractPriceMaterial c = ContractPriceMaterials_SubPanel.SessionObject as OContractPriceMaterial;
        return new CatalogueTreePopulater(c.CatalogueID, true, false);
    }


    /// <summary>
    /// Occurs when the user clicks on a button or a command
    /// in the location grid view.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gridLocationAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OContract contract = panel.SessionObject as OContract;
            panelLocationAccess.BindControlsToObject(contract);
            foreach (Guid id in objectIds)
                contract.Locations.RemoveGuid(id);
            panelLocationAccess.BindObjectToControls(contract);
        }
    }


    /// <summary>
    /// Occurs when the user selects a different vendor from
    /// the drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Vendor_SelectedIndexChanged(object sender, EventArgs e)
    {
        OContract contract = panel.SessionObject as OContract;
        tabVendor.BindControlsToObject(contract);
        tabVendor.BindObjectToControls(contract);
    }


    /// <summary>
    /// Occurs when the user clicks on the Purchase Agreement checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ProvidePricingAgreement_CheckedChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Occurs when the user clicks on the Maintenance checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ProvideMaintenance_CheckedChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OContract contract = panel.SessionObject as OContract;

        panelMaintenance.Visible = ProvideMaintenance.Checked;
        panelPricingAgreement.Visible = ProvidePricingAgreement.Checked;
        panelMaintenanceCommon.Visible = ProvideMaintenance.Checked || ProvidePricingAgreement.Checked;
        treeLocationAccess.Visible = (ProvideMaintenance.Checked || ProvidePricingAgreement.Checked);
        gridLocationAccess.Visible = (ProvideMaintenance.Checked || ProvidePricingAgreement.Checked);
        SurveyGroupID.Enabled = AppSession.User.HasRole("SYSTEMADMIN") || AppSession.User.HasRole("CONTRACTADMIN");
        tabVendor.Enabled = contract.PurchaseOrderID == null;
        labelPurchaseOrder.Visible = contract.PurchaseOrderID != null;

        Workflow_Setting();
    }


    /// <summary>
    /// Hides/shows or enables/disables elements based on the workflow.
    /// </summary>
    protected void Workflow_Setting()
    {
        string state = objectBase.CurrentObjectState;
        string action = objectBase.SelectedAction;
        string stateAndAction = state + ":" + action;

        if (state.Is("InProgress"))
        {
            ContractStartDate.Enabled = false;
            ContractEndDate.Enabled = false;
            panelPeopleToRemind.Enabled = false;
            panelEndReminder.Enabled = false;
        }
        else
        {
            ContractStartDate.Enabled = true;
            ContractEndDate.Enabled = true;
            panelPeopleToRemind.Enabled = true;
            panelEndReminder.Enabled = true;
        }

        if (stateAndAction.Is("InProgress:SubmitForModification"))
        {
            ContractStartDate.Enabled = true;
            ContractEndDate.Enabled = true;
            panelPeopleToRemind.Enabled = true;
            panelEndReminder.Enabled = true;
        }

        if (state.Is("Close"))
        {
            tabDetails.Enabled = false;
            tabReminders.Enabled = false;
            tabVendor.Enabled = false;
            //tabFixedRates.Enabled = false;
            tabService.Enabled = false;
            tabMemo.Enabled = false;
            tabAttachments.Enabled = false;
        }
    }


    /// <summary>
    /// Populates the materials subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ContractPriceMaterials_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OContractPriceMaterial contractPriceMaterial = ContractPriceMaterials_SubPanel.SessionObject as OContractPriceMaterial;

        ContractPriceMaterials_CatalogID.PopulateTree();
        ContractPriceMaterials_SubPanel.ObjectPanel.BindObjectToControls(contractPriceMaterial);
    }


    /// <summary>
    /// Populates the services subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ContractPriceServices_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OContractPriceService contractPriceService = ContractPriceServices_SubPanel.SessionObject as OContractPriceService;

        ContractPriceServices_FixedRateID.PopulateTree();
        ContractPriceServices_SubPanel.ObjectPanel.BindObjectToControls(contractPriceService);
    }


    /// <summary>
    /// Validates and adds the contract price material object into the contract.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ContractPriceMaterials_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OContractPriceMaterial contractPriceMaterial = ContractPriceMaterials_SubPanel.SessionObject as OContractPriceMaterial;
        ContractPriceMaterials_SubPanel.ObjectPanel.BindControlsToObject(contractPriceMaterial);

        OContract contract = panel.SessionObject as OContract;
        panelPricingAgreement.BindControlsToObject(contract);
        contract.ContractPriceMaterials.Add(contractPriceMaterial);
        panelPricingAgreement.BindObjectToControls(contract);
    }


    /// <summary>
    /// Validates and adds the contract price service object into the contract.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ContractPriceServices_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OContractPriceService contractPriceService = ContractPriceServices_SubPanel.SessionObject as OContractPriceService;
        ContractPriceServices_SubPanel.ObjectPanel.BindControlsToObject(contractPriceService);

        OContract contract = panel.SessionObject as OContract;
        panelPricingAgreement.BindControlsToObject(contract);
        contract.ContractPriceServices.Add(contractPriceService);
        panelPricingAgreement.BindObjectToControls(contract);
    }



    /// <summary>
    /// If the SubmitForModification event is selected, then
    /// disable all other events.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void objectBase_WorkflowTransitionSelected(object sender, EventArgs e)
    {
        if (objectBase.SelectedAction == "SubmitForModification")
            foreach (ListItem item in objectBase.WorkflowActionRadioList.Items)
                if (item.Value != "SubmitForModification")
                    item.Enabled = false;

    }


    /// <summary>
    /// Opens a window to edit the case object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditPurchaseOrder_Click(object sender, EventArgs e)
    {
        OContract o = (OContract)panel.SessionObject;
        if (o.PurchaseOrderID != null)
        {
            if (OActivity.CheckAssignment(AppSession.User, o.PurchaseOrderID))
                Window.OpenEditObjectPage(this, "OPurchaseOrder", o.PurchaseOrderID.ToString(), "");
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
        OContract o = (OContract)panel.SessionObject;
        if (o.PurchaseOrderID != null)
        {
            Window.OpenViewObjectPage(this, "OPurchaseOrder", o.PurchaseOrderID.ToString(), "");
        }
    }


    /// <summary>
    /// Adds a new scheduled work by redirecting the user to 
    /// the Scheduled Work edit page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddScheduledWork_Click(object sender, EventArgs e)
    {
        OContract o = (OContract)panel.SessionObject;

        Window.OpenAddObjectPage(this, "OScheduledWork", "ContractID=" +
            HttpUtility.UrlEncode(Security.Encrypt(o.ObjectID.ToString())));
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridScheduledWorks_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ViewObject")
        {
            Guid selectedId = (Guid)dataKeys[0];
            Window.OpenViewObjectPage(this, "OScheduledWork", selectedId.ToString(), "");
        }
        else if (commandName == "EditObject")
        {
            Guid selectedId = (Guid)dataKeys[0];

            if (OActivity.CheckAssignment(AppSession.User, selectedId))
                Window.OpenEditObjectPage(this, "OScheduledWork", selectedId.ToString(), "");
            else
                panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
        }
    }

    protected void gv_ContractTypeOfService_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OContract c = (OContract)panel.SessionObject;
            foreach (Guid id in objectIds)
                c.TypeOfServices.RemoveGuid(id);

            panel.ObjectPanel.BindControlsToObject(c);
            panel.ObjectPanel.BindObjectToControls(c);
        }
    }

    protected void sddl_ContractTypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OContract c = (OContract)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(c);
        if (sddl_ContractTypeOfServiceID.SelectedValue != "")
            c.TypeOfServices.AddGuid(new Guid(sddl_ContractTypeOfServiceID.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(c);
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
        <web:object runat="server" ID="panel" Caption="Contract" BaseTable="tContract" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="Contract Name" meta:resourcekey="objectBaseResource1" OnWorkflowTransitionSelected="objectBase_WorkflowTransitionSelected"></web:base>
                    <ui:UIFieldLabel runat="server" ID="labelPurchaseOrder" PropertyName="PurchaseOrder.ObjectNumber" Caption="Source Purchase Order" ContextMenuAlwaysEnabled="true" meta:resourcekey="labelPurchaseOrderResource1">
                        <ContextMenuButtons>
                            <ui:UIButton runat="server" ID="buttonEditPurchaseOrder" ImageUrl="~/images/edit.gif" Text="Edit Purchase Order" OnClick="buttonEditPurchaseOrder_Click" ConfirmText="Please remember to save this Contract before editing the Purchase Order.\n\nAre you sure you want to continue?" AlwaysEnabled="true" />
                            <ui:UIButton runat="server" ID="buttonViewPurchaseOrder" ImageUrl="~/images/view.gif" Text="View Purchase Order" OnClick="buttonViewPurchaseOrder_Click" ConfirmText="Please remember to save this Contract before viewing the Purchase Order.\n\nAre you sure you want to continue?" AlwaysEnabled="true" />
                        </ContextMenuButtons>
                    </ui:UIFieldLabel>
                    <ui:UIFieldTextBox runat="server" ID="Description" PropertyName="Description" Caption="Description" MaxLength="255" ToolTip="The description of the contract in detail." meta:resourcekey="DescriptionResource1" />
                    <ui:UIFieldDateTime runat="server" ID="ContractStartDate" PropertyName="ContractStartDate" Caption="Start Date" Span="Half" ValidateRequiredField="True" ToolTip="The date in which the contract starts. Works that begin within the start and end of this contract can be assigned to this contract's vendor." ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="ContractStartDateResource1" ShowTimeControls="False" ValidateCompareField="True" ValidationCompareControl="ContractEndDate" ValidationCompareType="Date" ValidationCompareOperator="LessThanEqual" />
                    <ui:UIFieldDateTime runat="server" ID="ContractEndDate" PropertyName="ContractEndDate" Caption="End Date" Span="Half" ValidateRequiredField="True" ToolTip="The date in which the contract end. Works that begin within the start and end of this contract can be assigned to this contract's vendor." ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="ContractEndDateResource1" ShowTimeControls="False" ValidateCompareField="True" ValidationCompareControl="ContractStartDate" ValidationCompareType="Date" ValidationCompareOperator="GreaterThanEqual" />
                    <ui:UIFieldTextBox runat="server" ID="Terms" PropertyName="Terms" Caption="Terms" Rows="5" ToolTip="The terms of this contract." meta:resourcekey="TermsResource1" MaxLength="255" />
                    <ui:UIFieldTextBox runat="server" ID="Warranty" PropertyName="Warranty" Caption="Warranty" Rows="5" ToolTip="The warranty information pertaining to this contract." meta:resourcekey="WarrantyResource1" MaxLength="255" />
                    <ui:UIFieldTextBox runat="server" ID="Insurance" PropertyName="Insurance" Caption="Insurance" Rows="5" ToolTip="The information on the insurance of this contract." meta:resourcekey="InsuranceResource1" MaxLength="255" />
                    <ui:UIFieldTextBox runat="server" ID="ContractSum" PropertyName="ContractSum" Caption="Contract Sum ($)" Span="Half" ValidateRequiredField="True" ToolTip="The contract sum paid or that will be paid to the vendor in dollars." ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency" meta:resourcekey="ContractSumResource1" />
                    <br />
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="Separator2" Caption="Contact Person for this Contract" meta:resourcekey="Separator2Resource1"></ui:UISeparator>
                    <ui:UIFieldTextBox runat="server" ID="ContactPerson" PropertyName="ContactPerson" Caption="Name" ValidateRequiredField="True" MaxLength="255" ToolTip="The name of the vendor's contact person." meta:resourcekey="ContactPersonResource1" />
                    <ui:UIFieldTextBox runat="server" ID="ContactCellphone" PropertyName="ContactCellphone" Caption="Cellphone" Span="Half" Rows="5" ToolTip="The cellphone number of the contact person." meta:resourcekey="ContactCellphoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="ContactEmail" PropertyName="ContactEmail" Caption="Email" Span="Half" Rows="5" ToolTip="The e-mail address of the contact person." meta:resourcekey="ContactEmailResource1" />
                    <ui:UIFieldTextBox runat="server" ID="ContactFax" PropertyName="ContactFax" Caption="Fax" Span="Half" Rows="5" ToolTip="The fax number of the contact person." meta:resourcekey="ContactFaxResource1" />
                    <ui:UIFieldTextBox runat="server" ID="ContactPhone" PropertyName="ContactPhone" Caption="Phone" Span="Half" ToolTip="The telephone number of the contact person." meta:resourcekey="ContactPhoneResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabReminders" Caption="Reminders" meta:resourcekey="tabRemindersResource1">
                    <ui:UISeparator runat="server" ID="UISeparator1" Caption="People to Remind" meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIPanel runat="server" ID="panelPeopleToRemind" Width="100%" meta:resourcekey="panelPeopleToRemindResource1">
                        <ui:UIFieldDropDownList runat='server' ID="Reminder1UserID" PropertyName="Reminder1UserID" Caption="Person 1" ToolTip="The person to send a notification (via e-mail) when the contract nears its end date. Note: All persons specified in this list will be notified." meta:resourcekey="Reminder1UserIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="Reminder2UserID" PropertyName="Reminder2UserID" Caption="Person 2" ToolTip="The person to send a notification (via e-mail) when the contract nears its end date. Note: All persons specified in this list will be notified." meta:resourcekey="Reminder2UserIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="Reminder3UserID" PropertyName="Reminder3UserID" Caption="Person 3" ToolTip="The person to send a notification (via e-mail) when the contract nears its end date. Note: All persons specified in this list will be notified." meta:resourcekey="Reminder3UserIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="Reminder4UserID" PropertyName="Reminder4UserID" Caption="Person 4" ToolTip="The person to send a notification (via e-mail) when the contract nears its end date. Note: All persons specified in this list will be notified." meta:resourcekey="Reminder4UserIDResource1">
                        </ui:UIFieldDropDownList>
                    </ui:UIPanel>
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="sep1" Caption="Reminder Time" meta:resourcekey="sep1Resource1" />
                    <ui:UIPanel runat="server" ID="panelEndReminder" Width="50%" meta:resourcekey="panelEndReminderResource1">
                        <ui:UIFieldLabel runat="server" ID="label1" CaptionWidth="300px" Caption="Reminder before Contract End Date (Days)" meta:resourcekey="label1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="EndReminderDays1" PropertyName="EndReminderDays1" Caption="First" ValidateDataTypeCheck="True" ValidationDataType="Integer" ToolTip="The number of days prior to the end date to send the reminder notification. You may specify up to four reminders." ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="EndReminderDays1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="EndReminderDays2" PropertyName="EndReminderDays2" Caption="Second" ValidateDataTypeCheck="True" ValidationDataType="Integer" ToolTip="The number of days prior to the end date to send the reminder notification. You may specify up to four reminders." ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="EndReminderDays2Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="EndReminderDays3" PropertyName="EndReminderDays3" Caption="Third" ValidateDataTypeCheck="True" ValidationDataType="Integer" ToolTip="The number of days prior to the end date to send the reminder notification. You may specify up to four reminders." ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="EndReminderDays3Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="EndReminderDays4" PropertyName="EndReminderDays4" Caption="Fourth" ValidateDataTypeCheck="True" ValidationDataType="Integer" ToolTip="The number of days prior to the end date to send the reminder notification. You may specify up to four reminders." ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="EndReminderDays4Resource1" />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabVendor" Caption="Vendor" meta:resourcekey="tabVendorResource1">
                    <ui:UIFieldSearchableDropDownList runat='server' ID="Vendor" Caption="Vendor" PropertyName="VendorID" OnSelectedIndexChanged="Vendor_SelectedIndexChanged" ToolTip="The vendor responsible for carrying out the work as indicated by this contract." meta:resourcekey="VendorResource1">
                    </ui:UIFieldSearchableDropDownList>
                    <br />
                    <ui:UISeparator runat="server" ID="Separator3" Caption="Operating Location" meta:resourcekey="Separator3Resource1"></ui:UISeparator>
                    <ui:UIFieldLabel runat="server" ID="OperatingAddressCountry" PropertyName="Vendor.OperatingAddressCountry" Caption="Country" Span="Half" meta:resourcekey="OperatingAddressCountryResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingAddressState" PropertyName="Vendor.OperatingAddressState" Caption="State" Span="Half" meta:resourcekey="OperatingAddressStateResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingAddressCity" PropertyName="Vendor.OperatingAddressCity" Caption="City" Span="Half" meta:resourcekey="OperatingAddressCityResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingAddress" PropertyName="Vendor.OperatingAddress" Caption="Address" meta:resourcekey="OperatingAddressResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingCellPhone" PropertyName="Vendor.OperatingCellPhone" Caption="Cellphone" Span="Half" meta:resourcekey="OperatingCellPhoneResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingEmail" PropertyName="Vendor.OperatingEmail" Caption="Email" Span="Half" meta:resourcekey="OperatingEmailResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingFax" PropertyName="Vendor.OperatingFax" Caption="Fax" Span="Half" meta:resourcekey="OperatingFaxResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingPhone" PropertyName="Vendor.OperatingPhone" Caption="Phone" Span="Half" meta:resourcekey="OperatingPhoneResource1" />
                    <ui:UIFieldLabel runat="server" ID="OperatingContactPerson" PropertyName="Vendor.OperatingContactPerson" Caption="Contact Person" meta:resourcekey="OperatingContactPersonResource1" />
                    <ui:UISeparator runat="server" ID="Separator4" Caption="Billing Location" meta:resourcekey="Separator4Resource1"></ui:UISeparator>
                    <ui:UIFieldLabel runat="server" ID="BillingAddressCountry" PropertyName="Vendor.BillingAddressCountry" Caption="Country" Span="Half" meta:resourcekey="BillingAddressCountryResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingAddressState" PropertyName="Vendor.BillingAddressState" Caption="State" Span="Half" meta:resourcekey="BillingAddressStateResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingAddressCity" PropertyName="Vendor.BillingAddressCity" Caption="City" Span="Half" meta:resourcekey="BillingAddressCityResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingAddress" PropertyName="Vendor.BillingAddress" Caption="Address" meta:resourcekey="BillingAddressResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingCellPhone" PropertyName="Vendor.BillingCellPhone" Caption="Cellphone" Span="Half" meta:resourcekey="BillingCellPhoneResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingEmail" PropertyName="Vendor.BillingEmail" Caption="Email" Span="Half" meta:resourcekey="BillingEmailResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingFax" PropertyName="Vendor.BillingFax" Caption="Fax" Span="Half" meta:resourcekey="BillingFaxResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingPhone" PropertyName="Vendor.BillingPhone" Caption="Phone" Span="Half" meta:resourcekey="BillingPhoneResource1" />
                    <ui:UIFieldLabel runat="server" ID="BillingContactPerson" PropertyName="Vendor.BillingContactPerson" Caption="Contact Person" meta:resourcekey="BillingContactPersonResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabService" Caption="Maintenance and Purchase" meta:resourcekey="tabServiceResource1">
                    <ui:UIFieldCheckBox runat="server" ID="ProvideMaintenance" PropertyName="ProvideMaintenance" Caption="Maintenance" Text="Yes, to vendor of this contract provides fully-paid maintenance work (for eg., warranty, maintenance support)" OnCheckedChanged="ProvideMaintenance_CheckedChanged" meta:resourcekey="ProvideMaintenanceResource1" />
                    <ui:UIPanel runat="server" ID="panelMaintenance" meta:resourcekey="panelMaintenanceResource1">
                        <%--
                        <ui:UIFieldListBox runat="server" ID="ContractTypeOfService" Caption="Type of Service"
                            PropertyName="TypeOfServices" ValidateRequiredField="True" ToolTip="The type of services provided by the specified vendor."
                            meta:resourcekey="ContractTypeOfServiceResource1"></ui:UIFieldListBox>
--%>
                        <ui:UIFieldSearchableDropDownList ID="sddl_ContractTypeOfServiceID" runat="server" Caption="Type of Service" Propertyname="" OnSelectedIndexChanged="sddl_ContractTypeOfServiceID_SelectedIndexChanged" meta:resourcekey="ContractTypeOfServiceResource1">
                        </ui:UIFieldSearchableDropDownList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gv_ContractTypeOfService" PropertyName="TypeOfServices" OnAction="gv_ContractTypeOfService_Action" Caption="Selected Type of Service" ValidateRequiredField="True" ToolTip="The type of services provided by the specified vendor." CaptionWidth="120px" KeyName="ObjectID" Span="Full" BindObjectsToRows="true" meta:resourcekey="ContractTypeOfServiceResource1">
                                        <Columns>
                                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                            </ui:UIGridViewButtonColumn>
                                            <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Name">
                                            </ui:UIGridViewBoundColumn>
                                        </Columns>
                                        <Commands>
                                            <ui:UIGridViewCommand CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                                        </Commands>
                                    </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                        <br />
                    </ui:UIPanel>
                    <ui:UIFieldCheckBox runat="server" ID="ProvidePricingAgreement" PropertyName="ProvidePricingAgreement" Caption="Purchase Agreement" Text="Yes, the vendor of this contract agrees to a purchase agreement" OnCheckedChanged="ProvidePricingAgreement_CheckedChanged" meta:resourcekey="ProvidePricingAgreementResource1" />
                    <ui:UIPanel runat="server" ID="panelPricingAgreement" meta:resourcekey="panelPricingAgreementResource1">
                        <ui:UIGridView runat="server" ID="ContractPriceServices" PropertyName="ContractPriceServices" Caption="Purchase Agreement for Services" KeyName="ObjectID" Width="100%" AllowPaging="True" AllowSorting="True" meta:resourcekey="ContractPriceServicesResource1" PagingEnabled="True">
                            <Commands>
                                <ui:UIGridViewCommand CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject" meta:resourcekey="UIGridViewCommandResource3"></ui:UIGridViewCommand>
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?" HeaderText="" meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRate.Path" HeaderText="Service(s)" meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="PriceFactor" HeaderText="Price Factor" DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewColumnResource9">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="ContractPriceServices_Panel" meta:resourcekey="ContractPriceServices_PanelResource1">
                            <web:subpanel runat="server" ID="ContractPriceServices_SubPanel" GridViewID="ContractPriceServices" OnPopulateForm="ContractPriceServices_SubPanel_PopulateForm" OnValidateAndUpdate="ContractPriceServices_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTreeList runat="server" ID="ContractPriceServices_FixedRateID" PropertyName="FixedRateID" Caption="Fixed Rate" ValidateRequiredField="True" OnAcquireTreePopulater="ContractPriceServices_FixedRateID_AcquireTreePopulater" meta:resourcekey="ContractPriceServices_FixedRateIDResource1">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox runat="server" ID="ContractPriceServices_PriceFactor" PropertyName="PriceFactor" Caption="Price Factor" Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="ContractPriceServices_PriceFactorResource1" />
                            <br />
                            <br />
                            <br />
                        </ui:UIObjectPanel>
                        <br />
                        <ui:UIGridView runat="server" ID="ContractPriceMaterials" PropertyName="ContractPriceMaterials" Caption="Purchase Agreement for Materials" KeyName="ObjectID" Width="100%" AllowPaging="True" AllowSorting="True" meta:resourcekey="ContractPriceMaterialsResource1" PagingEnabled="True">
                            <Commands>
                                <ui:UIGridViewCommand CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource4" />
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject" meta:resourcekey="UIGridViewCommandResource5"></ui:UIGridViewCommand>
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource10">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?" HeaderText="" meta:resourcekey="UIGridViewColumnResource11">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Catalogue.Path" HeaderText="Material(s)" meta:resourcekey="UIGridViewColumnResource12">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="PriceFactor" HeaderText="Price Factor" DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewColumnResource13">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="ContractPriceMaterials_Panel" meta:resourcekey="ContractPriceMaterials_PanelResource1">
                            <web:subpanel runat="server" ID="ContractPriceMaterials_SubPanel" GridViewID="ContractPriceMaterials" OnPopulateForm="ContractPriceMaterials_SubPanel_PopulateForm" OnValidateAndUpdate="ContractPriceMaterials_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTreeList runat="server" ID="ContractPriceMaterials_CatalogID" PropertyName="CatalogueID" Caption="Catalog" ValidateRequiredField="True" OnAcquireTreePopulater="ContractPriceMaterials_CatalogID_AcquireTreePopulater" meta:resourcekey="ContractPriceMaterials_CatalogIDResource1">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox runat="server" ID="ContractPriceMaterials_PriceFactor" PropertyName="PriceFactor" Caption="Price Factor" Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="ContractPriceMaterials_PriceFactorResource1" />
                            <br />
                            <br />
                            <br />
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelMaintenanceCommon">
                        <br />
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Maintenance Information" meta:resourcekey="UISeparator2Resource1"/>
                        <ui:UIFieldDropDownList runat="server" ID="SurveyGroupID" PropertyName="SurveyGroupID" Caption="Survey Group" meta:resourcekey="SurveyGroupIDResource1" ToolTip="The survey group that this contract belongs to." AjaxPostBack="False" IsModifiedByAjax="False">
                        </ui:UIFieldDropDownList>
                        <ui:UIPanel runat="server" ID="panelLocationAccess">
                            <ui:UIFieldTreeList runat="server" ID="treeLocationAccess" Caption="Location" OnAcquireTreePopulater="treeLocationAccess_AcquireTreePopulater" OnSelectedNodeChanged="treeLocationAccess_SelectedNodeChanged" ToolTip="The location under which the vendor provides his services." meta:resourcekey="treeLocationAccessResource1" />
                            <ui:UIGridView runat="server" ID="gridLocationAccess" PropertyName="Locations" OnAction="gridLocationAccess_Action" Caption="List of Serviced Locations" ValidateRequiredField="True" KeyName="ObjectID" meta:resourcekey="gridLocationAccessResource1" Width="100%" AllowPaging="True" AllowSorting="True" PagingEnabled="True">
                                <Commands>
                                    <ui:UIGridViewCommand CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                </Commands>
                                <Columns>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject" ConfirmText="Are you sure you wish to delete this item?" HeaderText="" meta:resourcekey="UIGridViewColumnResource5">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn PropertyName="Path" HeaderText="Location Path" meta:resourcekey="UIGridViewColumnResource2">
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabScheduledWork" Caption="Schedulesd Works" meta:resourcekey="tabScheduledWorkResource1">
                    <ui:uibutton runat="server" ID="buttonAddScheduledWork" ImageUrl="~/images/add.gif" Text="Add Scheduled Work" ConfirmText="Please remember to save this Contract before creating a new Scheduled Work.\n\nAre you sure you want to continue?" OnClick="buttonAddScheduledWork_Click" meta:resourcekey="buttonAddScheduledWorkResource1" />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="gridScheduledWorks" PropertyName="ScheduledWorks" Caption="Scheduled Works" CheckBoxColumnVisible="false" OnAction="gridScheduledWorks_Action" meta:resourcekey="gridScheduledWorksResource1">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" CausesValidation="false" CommandText="Edit" AlwaysEnabled="true" ConfirmText="Please remember to save this Contract before editing the Scheduled Work.\n\nAre you sure you want to continue?">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewObject" CausesValidation="false" CommandText="View" AlwaysEnabled="true" ConfirmText="Please remember to save this Contract before viewing the Scheduled Work.\n\nAre you sure you want to continue?">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Scheduled Work Number" meta:resourcekey="UIGridViewBoundColumnResource1">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TypeOfWork.ObjectName" HeaderText="Type of Work" meta:resourcekey="UIGridViewBoundColumnResource2">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TypeOfService.ObjectName" HeaderText="Type of Service" meta:resourcekey="UIGridViewBoundColumnResource3">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TypeOfProblem.ObjectName" HeaderText="Type of Problem" meta:resourcekey="UIGridViewBoundColumnResource4">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource5">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabWorkStatusHistory" Caption="Status History" meta:resourcekey="tabWorkStatusHistoryResource1">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
