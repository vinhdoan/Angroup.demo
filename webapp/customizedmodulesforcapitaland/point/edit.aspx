﻿<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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
        OPoint point = panel.SessionObject as OPoint;

        dropOPCDAServer.Bind(OOPCDAServer.GetAllOPCDAServers());
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();

        // 2010.05.30
        // Default the meter type to an increasing meter for CapitaLand.
        //
        if (point.IsIncreasingMeter == null)
            point.IsIncreasingMeter = 1;
        if (point.LocationID != null)
        {
            List<OMeter> meters = point.GetMeters(point.LocationID);
            if (meters != null)
                ddlmetername.Bind(meters, "NameAndBarcode", "ObjectID");
            ddlmetername.SelectedValue = point.meterID.ToString();

        }
        //if(point.meterID!=null)
        //{
        //    OMeter meter=point.GetMeter(point.meterID);
        //    ddlmetername.Text = meter.ObjectName + "(" + meter.Barcode + ")";
        //}
        // Bind the type of work/services/problem
        // drop down lists.
        //
        dropTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", point.TypeOfWorkID));
        dropTypeOfService.Bind(OCode.GetCodesByParentID(point.TypeOfWorkID, point.TypeOfServiceID));
        dropTypeOfProblem.Bind(OCode.GetCodesByParentID(point.TypeOfServiceID, point.TypeOfProblemID));
        TypeOfMeterID.Bind(OCode.GetCodesByType("AmosMeterType", point.TypeOfMeterID));
        // Update the priority's text
        //
        dropPriority.Items[0].Text = Resources.Strings.Priority_0;
        dropPriority.Items[1].Text = Resources.Strings.Priority_1;
        dropPriority.Items[2].Text = Resources.Strings.Priority_2;
        dropPriority.Items[3].Text = Resources.Strings.Priority_3;

        dropUnit.Bind(OCode.GetCodesByType("UnitOfMeasure", point.UnitOfMeasureID));
        TreeTrigger.PopulateTree();
        DefaultChargeTypeID.Bind(OChargeType.GetChargeTypeList(), "ObjectName", "ObjectID");
        if (point.LocationID != null)
            TenantLeaseID.Bind(OTenantLease.GetNewTenantLeaseList(point.Location, point.TenantLeaseID), "ObjectName", "ObjectID");
        TenantID.Bind(OUser.GetTenantList(point.TenantID));
        if (point.Location != null)
        {
            ReminderUser1ID.Bind(OUser.GetUsersByRoleAndAboveLocation(point.Location, "WORKSUPERVISOR"));
            ReminderUser2ID.Bind(OUser.GetUsersByRoleAndAboveLocation(point.Location, "WORKSUPERVISOR"));
            ReminderUser3ID.Bind(OUser.GetUsersByRoleAndAboveLocation(point.Location, "WORKSUPERVISOR"));
            ReminderUser4ID.Bind(OUser.GetUsersByRoleAndAboveLocation(point.Location, "WORKSUPERVISOR"));
        }
        TenantLeaseID.Enabled = point.Reading.Count == 0;
        TenantID.Enabled = point.Reading.Count == 0;

        if (point.IsNew)
        {
            point.ChargeTypeID = OApplicationSetting.Current.DefaultChargeTypeID;
            point.TypeOfMeterID = OApplicationSetting.Current.DefaultMeterTypeID;
            point.UnitOfMeasureID = OApplicationSetting.Current.DefaultUnitOfMeasureID;
            point.BillingType = 1;
            point.IsApplicableForLocation = 1;
            point.IsActive = 1;
        }
        if (!point.IsNew)
        {
            textBarcode.Enabled =
               dropUnit.Enabled =
               txtBMSCode.Enabled =
               TypeOfMeterID.Enabled =

               radioIsIncreasingMeter.Enabled =
               textMaximumReading.Enabled =
               textFactor.Enabled = false;
        }
        if (point.TenantID != null)
            TenantContactID.Bind(point.Tenant.TenantContacts);

        if (point.TenantLease != null)
        {
            if (point.TenantLease.TenantID != null)
                TenantContactID.Bind(point.TenantLease.Tenant.TenantContacts);
        }
        panel.ObjectPanel.BindObjectToControls(point);

        TenantLease_panel.Visible = point.TenantID == null;

        if (point.HasReadings())
        {
            panelDetails.Enabled = false;
            panelBillingDetails.Enabled = false;
            panelTariffAndDiscount.Enabled = false;
        }
        if (AppSession.User.HasRole("SYSTEMADMIN"))
        {
            panelTariffAndDiscount.Enabled = true;
        }
    }




    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OPoint point = panel.SessionObject as OPoint;
        OPoint obj = null;

/*
        if (point.Barcode != null && point.Barcode != "")
            obj = TablesLogic.tPoint.Load(
                TablesLogic.tPoint.Barcode == point.Barcode &
                TablesLogic.tPoint.IsActive == 1 &
                TablesLogic.tPoint.ObjectID != point.ObjectID);
        if (obj != null)
            textBarcode.ErrorMessage = Resources.Errors.Point_DuplicateBarcode;
*/
        if (radioIsApplicableForLocation.SelectedIndex == 0)
            point.EquipmentID = null;
        else
            point.LocationID = null;

        if (radioIsIncreasingMeter.SelectedIndex == 0)
        {
            point.MaximumReading = null;
            point.Factor = null;
        }

        if (point.PointTrigger != null)
        {
            point.TypeOfWorkID = null;
            point.TypeOfServiceID = null;
            point.TypeOfProblemID = null;
            point.Priority = 0;
            point.WorkDescription = "";
        }

        if (point.BillingType == 2)
        {
            point.TenantLeaseID = null;
            point.TenantLease = null;
        }
        else if (point.BillingType == 1)
        {
            point.Tenant = null;
            point.TenantID = null;
        }

        /*
         * 2010.06.02
         * Kim Foong
         * To prevent creation of new points with the same name. 
         * (and this happens often) 
         * 
        if (point.IsDuplicateName())
            objectBase.ObjectName.ErrorMessage = Resources.Errors.Point_DuplicateName;
        */

        if (!point.ValidateNoDuplicateOPCItemName())
            textOPCItemName.ErrorMessage = Resources.Errors.Point_DuplicateOPCItemName;

        if (point.LastReading > point.MaximumReading)
            LastReading.ErrorMessage = Resources.Errors.Point_LastReadingGreaterThanMaximumReading;
        if (ddlmetername.Text != null && ddlmetername.Text !="")
            point.meterID = new Guid(ddlmetername.SelectedValue.ToString());
    }

    protected TreePopulater TreeTrigger_AcquireTreePopulater(object sender)
    {
        OPoint pt = (OPoint)panel.SessionObject;
        return new PointTriggerTreePopulater(pt.PointTriggerID, false, true,
            Security.Decrypt(Request["TYPE"]));

    }

    /// <summary>
    /// Occurs when the Location/Equipment radio button list
    /// is selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioIsApplicableForLocation_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects an item in Breach radio
    /// button list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioCreateWorkOnBreach_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OPoint point = panel.SessionObject as OPoint;
        panel.ObjectPanel.BindControlsToObject(point);

        textOPCItemName.Visible = dropOPCDAServer.SelectedIndex > 0;
        panelLocation.Visible = radioIsApplicableForLocation.SelectedValue == "1";
        panelEquipment.Visible = radioIsApplicableForLocation.SelectedValue == "0";

        panelBreach.Visible = radioCreateWorkOnBreach.SelectedValue == "1";
        panelBreachCondition.Visible = dropOPCDAServer.SelectedIndex > 0;

        if (gridReadings.Visible)
            tabReadings.Click -= new EventHandler(tabReadings_Click);

        panelBehaviorProperties.Visible = radioIsIncreasingMeter.SelectedValue == "1";

        TreeTrigger.SelectedValue = TreeTrigger.SelectedValue;
        if (!TreeTrigger.SelectedValue.Trim().Equals(""))
        {
            TriggerTemplate.Visible = true;
            TriggerManual.Visible = false;
        }
        else
        {
            TriggerManual.Visible = true;
            TriggerTemplate.Visible = false;
        }
        TenantLease_panel.Visible = (BillingType.SelectedValue == "1");
        TenantLeaseID.Visible = (BillingType.SelectedValue == "1");
        TenantID.Visible = (BillingType.SelectedValue == "2");
        LastReading.Visible = radioIsIncreasingMeter.SelectedValue == "1";
        Tariff.Visible = radioIsIncreasingMeter.SelectedValue == "1";
        Tariff.Enabled = Tariff.Text.Trim() == "" || AppSession.User.HasRole("SYSTEMADMIN");
        Discount.Visible = radioIsIncreasingMeter.SelectedValue == "1";
        TenantContactID.Visible = (BillingType.SelectedValue == "1" || BillingType.SelectedValue == "2");
    }


    /// <summary>
    /// Constructs and returns the equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        OPoint point = panel.SessionObject as OPoint;
        return new EquipmentTreePopulater(point.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OPoint point = panel.SessionObject as OPoint;
        return new LocationTreePopulaterForCapitaland(point.LocationID, false
            , true, Security.Decrypt(Request["TYPE"]), false, false);
    }


    /// <summary>
    /// Occurs when the user selects a node in the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPoint point = panel.SessionObject as OPoint;
        panel.ObjectPanel.BindControlsToObject(point);
    }


    /// <summary>
    /// Occurs when the user selects a node in the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPoint point = panel.SessionObject as OPoint;
        panel.ObjectPanel.BindControlsToObject(point);

        if (point.LocationID != null)
            TenantLeaseID.Bind(OTenantLease.GetNewTenantLeaseList(point.Location, null), "ObjectName", "ObjectID");

        if (point.Location != null)
        {
            List<OUser> users = OUser.GetUsersByRoleAndAboveLocation(point.Location, "WORKSUPERVISOR");
            ReminderUser1ID.Bind(users);
            ReminderUser2ID.Bind(users);
            ReminderUser3ID.Bind(users);
            ReminderUser4ID.Bind(users);
        }
        if (point.LocationID != null)
        {
            List<OMeter> meters = point.GetMeters(point.LocationID);
            if(meters!=null)
                ddlmetername.Bind(meters, "NameAndBarcode", "ObjectID"); 
       
        }
        if (point.LocationID != null)
        {
            textBarcode.Enabled =
               dropUnit.Enabled =
               txtBMSCode.Enabled =
               TypeOfMeterID.Enabled =
               radioIsIncreasingMeter.Enabled =
               textMaximumReading.Enabled =
               textFactor.Enabled = true;

            dropUnit.SelectedItem.Text = "Kilowatt Hour";
            point.Barcode = "";
            point.BMSCode = "";
            point.MaximumAcceptableReading = null;
            point.Factor = null;
        }
        point.UpdateDefaultTariffAndDiscount();
        panel.ObjectPanel.BindObjectToControls(point);
    }


    /// <summary>
    /// Occurs when the Type of Work dropdown list is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropTypeOfWork_SelectedIndexChanged(object sender, EventArgs e)
    {
        dropTypeOfService.Items.Clear();
        if (dropTypeOfWork.SelectedValue != "")
            dropTypeOfService.Bind(OCode.GetCodesByParentID(new Guid(dropTypeOfWork.SelectedValue), null));
        dropTypeOfProblem.Items.Clear();
    }


    /// <summary>
    /// Occurs when the Type of Service dropdown list is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropTypeOfService_SelectedIndexChanged(object sender, EventArgs e)
    {
        dropTypeOfProblem.Items.Clear();
        if (dropTypeOfService.SelectedValue != "")
            dropTypeOfProblem.Bind(OCode.GetCodesByParentID(new Guid(dropTypeOfService.SelectedValue), null));
    }


    /// <summary>
    /// Occurs when the readings tab is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void tabReadings_Click(object sender, EventArgs e)
    {
        if (!gridReadings.Visible)
        {
            buttonRefresh_Click(sender, e);
        }
    }

    /// <summary>
    /// Refreshes the readings.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonRefresh_Click(object sender, EventArgs e)
    {
        OPoint point = panel.SessionObject as OPoint;
        gridReadings.DataSource = OReading.GetReadingsByPoint(point.ObjectID.Value, 1000);
        gridReadings.DataBind();
        gridReadings.Visible = true;
    }


    /// <summary>
    /// Occurs when the user selects an item in the increasing meter radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioIsIncreasingMeter_SelectedIndexChanged(object sender, EventArgs e)
    {
    }

    protected void TreeTrigger_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPoint pt = (OPoint)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(pt);
        panel.ObjectPanel.BindObjectToControls(pt);
    }


    /// <summary>
    /// Occurs when the OPC server dropdown list is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropOPCDAServer_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void LastReading_TextChanged(object sender, EventArgs e)
    {
        OPoint pt = (OPoint)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(pt);

        if (pt.LastReading > pt.MaximumReading)
            LastReading.ErrorMessage = Resources.Errors.Point_LastReadingGreaterThanMaximumReading;
        if (pt.LastReading > 0)
            pt.IsActive = 1;

        panel.ObjectPanel.BindObjectToControls(pt);
    }

    protected void BillingType_SelectedIndexChanged(object sender, EventArgs e)
    {
        TenantContactID.Items.Clear();

        OPoint pt = (OPoint)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(pt);
        if (pt.BillingType != null)
        {
            if (pt.BillingType == 1)
            {
                if (pt.TenantID != null)
                    TenantContactID.Bind(pt.Tenant.TenantContacts);
            }
            else if (pt.BillingType == 2)
            {
                if (pt.TenantLease != null)
                {
                    if (pt.TenantLease.TenantID != null)
                        TenantContactID.Bind(pt.TenantLease.Tenant.TenantContacts);
                }
            }
        }
        panel.ObjectPanel.BindObjectToControls(pt);

        if (TenantContactID.SelectedIndex == 0 && TenantContactID.Items.Count > 0)
            TenantContactID.SelectedIndex = 1;
    }

    protected void TenantID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPoint pt = (OPoint)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(pt);
        if (pt.TenantID != null)
            TenantContactID.Bind(pt.Tenant.TenantContacts);
        panel.ObjectPanel.BindObjectToControls(pt);

        if (TenantContactID.SelectedIndex == 0 && TenantContactID.Items.Count > 1)
            TenantContactID.SelectedIndex = 1;
    }

    protected void TenantLeaseID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPoint pt = (OPoint)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(pt);

        if (pt.TenantLease != null)
        {
            if (pt.TenantLease.TenantID != null)
                TenantContactID.Bind(pt.TenantLease.Tenant.TenantContacts);
        }
        panel.ObjectPanel.BindObjectToControls(pt);

        if (TenantContactID.SelectedIndex == 0 && TenantContactID.Items.Count > 1)
            TenantContactID.SelectedIndex = 1;

    }

    protected void ddlmetername_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPoint pt = (OPoint)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(pt);
        if (ddlmetername.SelectedValue == "")
        {
            textBarcode.Text = "";
            txtBMSCode.Text = "";
            textMaximumReading.Text = "";
            textFactor.Text = "";
            dropUnit.SelectedItem.Text = "Kilowatt Hour";
            textBarcode.Enabled =
               dropUnit.Enabled =
               txtBMSCode.Enabled =
               TypeOfMeterID.Enabled =

               radioIsIncreasingMeter.Enabled =
               textMaximumReading.Enabled =
               textFactor.Enabled = true;
            return;
            
        }
        Guid? meterID =new Guid( ddlmetername.SelectedValue);
        OMeter meter = pt.GetMeter(meterID);
        if (meter != null)
        {
            try
            {
                textBarcode.Text = meter.Barcode;
                dropUnit.SelectedValue = meter.UnitOfMeasure.ObjectID.ToString();
                txtBMSCode.Text = meter.BMSCode.ToString();
                TypeOfMeterID.SelectedValue = meter.TypeOfMeter.ObjectID.ToString();
                radioIsIncreasingMeter.SelectedValue = meter.IsIncreasingMeter.ToString();
                textMaximumReading.Text = meter.MaximumReading.ToString();
                textFactor.Text = meter.Factor.ToString();

                textBarcode.Enabled =
                dropUnit.Enabled =
                txtBMSCode.Enabled =
                TypeOfMeterID.Enabled =

                radioIsIncreasingMeter.Enabled =
                textMaximumReading.Enabled =
                textFactor.Enabled = false;
            }
            catch { }
        }
        else
        {

            textBarcode.Enabled =
            dropUnit.Enabled =
            txtBMSCode.Enabled =
            TypeOfMeterID.Enabled =

            radioIsIncreasingMeter.Enabled =
            textMaximumReading.Enabled =
            textFactor.Enabled = true;
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Point" meta:resourcekey="panelResource1" BaseTable="tPoint" OnPopulateForm="panel_PopulateForm" AutomaticBindingAndSaving="true" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="uitabview1" runat="server" Caption="Details" BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                    <ui:uipanel runat="server" id="panelDetails" BorderStyle="NotSet" 
                        meta:resourcekey="panelDetailsResource1">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="Point Name" meta:resourcekey="objectBaseResource1" ObjectNumberVisible="false"></web:base>
                        <ui:UIFieldRadioList runat='server' ID="radioIsApplicableForLocation" PropertyName="IsApplicableForLocation" Caption="Location/Equipment" OnSelectedIndexChanged="radioIsApplicableForLocation_SelectedIndexChanged" ValidateRequiredField="True" meta:resourcekey="radioIsApplicableForLocationResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" Text="Location" meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem Value="0" Text="Equipment" meta:resourcekey="ListItemResource2"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelLocation" BorderStyle="NotSet" meta:resourcekey="panelLocationResource1">
                            <ui:UIFieldTreeList runat="server" ID="treeLocation" PropertyName="LocationID" Caption="Location" ValidateRequiredField="True" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelEquipment" BorderStyle="NotSet" meta:resourcekey="panelEquipmentResource1">
                            <ui:UIFieldTreeList runat="server" ID="treeEquipment" PropertyName="EquipmentID" ValidateRequiredField="True" Caption="Equipment" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged" meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                        </ui:UIPanel>
                        <ui:UIFieldDropDownList runat="server" ID="dropOPCDAServer" PropertyName="OPCDAServerID" Caption="OPC DA Server" OnSelectedIndexChanged="dropOPCDAServer_SelectedIndexChanged" meta:resourcekey="dropOPCDAServerResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="textOPCItemName" PropertyName="OPCItemName" Caption="OPC Item Name" ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="textOPCItemNameResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textDescription" PropertyName="Description" Caption="Description" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="textDescriptionResource1">
                        </ui:UIFieldTextBox>
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Meter" />
                        <ui:UIFieldSearchableDropDownList runat="server" ID="ddlmetername" Caption="Meter Name" OnSelectedIndexChanged="ddlmetername_SelectedIndexChanged"></ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="textBarcode" PropertyName="Barcode" Caption="Barcode" InternalControlWidth="95%" meta:resourcekey="textBarcodeResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDropDownList runat="server" ID="dropUnit" PropertyName="UnitOfMeasureID" Caption="Unit Of Measure" ValidateRequiredField="True" meta:resourcekey="dropUnitResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="txtBMSCode" Caption="BMS Code" 
                            PropertyName="BMSCode" InternalControlWidth="95%" 
                            meta:resourcekey="txtBMSCodeResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfMeterID" PropertyName="TypeOfMeterID" Caption="Type of Meter" ValidateRequiredField="True" meta:resourcekey="TypeOfMeterIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIPanel runat="server" ID="panelBehavior" BorderStyle="NotSet" meta:resourcekey="panelBehaviorResource1">
                            <ui:UIFieldRadioList runat="server" ID="radioIsIncreasingMeter" Caption="Type" PropertyName="IsIncreasingMeter" ValidateRequiredField="True" OnSelectedIndexChanged="radioIsIncreasingMeter_SelectedIndexChanged" meta:resourcekey="radioIsIncreasingMeterResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource3" Text="Absolute Reading (for readings from temperature, vibration sensors, etc that do not increase over time)"></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource4" Text="Increasing Reading (for readings from electrical meters, water meters, etc that always increase over time)"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="panelBehaviorProperties" BorderStyle="NotSet" meta:resourcekey="panelBehaviorPropertiesResource1">
                                <ui:UIFieldTextBox runat="server" ID="textMaximumReading" 
                                    Caption="Maximum Reading" PropertyName="MaximumReading" 
                                    ValidateRangeField="True" 
                                    ValidateDataTypeCheck="True" ValidationDataType="Currency" 
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="False" 
                                    ValidationRangeType='Currency' Span="Half" InternalControlWidth="95%" 
                                    meta:resourcekey="textMaximumReadingResource1">
                                </ui:UIFieldTextBox>
                                <ui:UIFieldTextBox runat="server" ID="textFactor" Caption="Factor" 
                                    PropertyName="Factor" ValidateRequiredField='True' ValidateRangeField="True" 
                                    ValidationRangeType='Currency' ValidateDataTypeCheck="True" 
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="False" Span="Half" 
                                    InternalControlWidth="95%" meta:resourcekey="textFactorResource1">
                                </ui:UIFieldTextBox>
                                <ui:UISeparator runat="server" ID="separator" Caption="Computation" />
                                <ui:UIFieldTextBox runat="server" ID="LastReading" PropertyName="LastReading" 
                                    Caption="First Reading" ValidateDataTypeCheck="True" Span="Half" 
                                    ValidateRequiredField="True" ValidationDataType="Currency" 
                                    OnTextChanged="LastReading_TextChanged" InternalControlWidth="95%" 
                                    ValidateRangeField="True" ValidationRangeMin="0" 
                                    meta:resourcekey="LastReadingResource1" />
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:uipanel>
                    <ui:UIPanel runat="server" ID="panelTariffAndDiscount">
                        <ui:UIFieldTextBox runat="server" ID="Tariff" PropertyName="Tariff"
                            Caption="Tariff" Span="Half" ValidateDataTypeCheck="True" 
                            ValidateRequiredField="True" ValidationDataType="Currency" 
                            InternalControlWidth="95%" ValidateRangeField="True" ValidationRangeMin="0" 
                            meta:resourcekey="TariffResource1" />
                        <ui:UIFieldTextBox runat="server" ID="Discount" PropertyName="Discount" 
                            Caption="Discount%" Span="Half" ValidateDataTypeCheck="True" 
                            ValidateRequiredField="True" ValidationDataType="Currency" 
                            InternalControlWidth="95%" ValidateRangeField="True" ValidationRangeMin="0" 
                            ValidationRangeMax="100" meta:resourcekey="DiscountResource1" />
                        <ui:UIFieldCheckBox runat="server" ID="IsLock" PropertyName="IsLock" 
                            Caption="Is Lock" TextAlign="Right" 
                            Text="Yes, lock the tariff and discount for this Point to prevent mass updates." 
                            meta:resourcekey="IsLockResource1" />
                    </ui:UIPanel>
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelBillingInfo" BorderStyle="NotSet" meta:resourcekey="panelBillingInfoResource1">
                        <ui:uipanel runat="server" id="panelBillingDetails" BorderStyle="NotSet" 
                            meta:resourcekey="panelBillingDetailsResource1">
                            <ui:UISeparator runat="server" ID="UISeparator3" Caption="Tenant Billing" />
                            <ui:UIFieldRadioList runat="server" ID="BillingType" Caption="Type" PropertyName="BillingType" ValidateRequiredField="True" TextAlign="Right" OnSelectedIndexChanged="BillingType_SelectedIndexChanged" meta:resourcekey="BillingTypeResource1">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource13" Text="Not Billed"></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource14" 
                                        Text="Billed to Tenant through Lease"></asp:ListItem>
                                    <asp:ListItem Value="2" meta:resourcekey="ListItemResource15" 
                                        Text="Billed to Tenant directly (for example, Telco's base stations)"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldDropDownList runat="server" ID="DefaultChargeTypeID" PropertyName="ChargeTypeID" caption="Charge Type" ValidateRequiredField="True" meta:resourcekey="DefaultChargeTypeIDResource1" />
                            <ui:UIFieldSearchableDropDownList runat="server" ID="TenantLeaseID" PropertyName="TenantLeaseID" caption="Tenant Lease" ValidateRequiredField="True" OnSelectedIndexChanged="TenantLeaseID_SelectedIndexChanged" meta:resourcekey="TenantLeaseIDResource1" SearchInterval="300" />
                            <ui:UIPanel ID="TenantLease_panel" runat="server" Visible="False" BorderStyle="NotSet" meta:resourcekey="TenantLease_panelResource1">
                                <ui:UIFieldLabel ID="LeaseStartDate" runat="server" PropertyName="TenantLease.LeaseStartDate" DataFormatString="{0:dd-MMM-yyyy}" Enabled="False" Span="Half" Caption="Lease Start Date" meta:resourcekey="LeaseStartDateResource1" />
                                <ui:UIFieldLabel ID="LeaseEndDate" runat="server" PropertyName="TenantLease.LeaseEndDate" DataFormatString="{0:dd-MMM-yyyy}" Enabled="False" Span="Half" Caption="Lease End Date" meta:resourcekey="LeaseEndDateResource1" />
                                <ui:UIFieldLabel ID="Location" runat="server" Caption="Location" PropertyName="TenantLease.Location.Path" Enabled="False" DataFormatString="" meta:resourcekey="LocationResource2" />
                            </ui:UIPanel>
                            <ui:UIFieldSearchableDropDownList runat="server" ID="TenantID" PropertyName="TenantID" caption="Tenant" ValidateRequiredField="True" OnSelectedIndexChanged="TenantID_SelectedIndexChanged" meta:resourcekey="TenantIDResource1" SearchInterval="300" />
                            <ui:UIFieldDropDownList runat="server" ID="TenantContactID" PropertyName="TenantContactID" caption="Tenant Contact" ValidateRequiredField="True" meta:resourcekey="TenantContactIDResource1" />
                        </ui:uipanel>
                        <ui:UISeparator runat="server" ID="UISeparator4" Caption="Reading / Assignment" />
                        <ui:UIFieldDropDownList runat="server" ID="ReadingDay" PropertyName="ReadingDay" caption="Reading Day" ValidateRequiredField="True" meta:resourcekey="ReadingDayResource1">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource16"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource17" 
                                    Text="1st of the month"></asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource18" 
                                    Text="2nd of the month"></asp:ListItem>
                                <asp:ListItem Value="3" meta:resourcekey="ListItemResource19" 
                                    Text="3rd of the month"></asp:ListItem>
                                <asp:ListItem Value="4" meta:resourcekey="ListItemResource20" 
                                    Text="4th of the month"></asp:ListItem>
                                <asp:ListItem Value="5" meta:resourcekey="ListItemResource21" 
                                    Text="5th of the month"></asp:ListItem>
                                <asp:ListItem Value="6" meta:resourcekey="ListItemResource22" 
                                    Text="6th of the month"></asp:ListItem>
                                <asp:ListItem Value="7" meta:resourcekey="ListItemResource23" 
                                    Text="7th of the month"></asp:ListItem>
                                <asp:ListItem Value="8" meta:resourcekey="ListItemResource24" 
                                    Text="8th of the month"></asp:ListItem>
                                <asp:ListItem Value="9" meta:resourcekey="ListItemResource25" 
                                    Text="9th of the month"></asp:ListItem>
                                <asp:ListItem Value="10" meta:resourcekey="ListItemResource26" 
                                    Text="10th of the month"></asp:ListItem>
                                <asp:ListItem Value="11" meta:resourcekey="ListItemResource27" 
                                    Text="11th of the month"></asp:ListItem>
                                <asp:ListItem Value="12" meta:resourcekey="ListItemResource28" 
                                    Text="12th of the month"></asp:ListItem>
                                <asp:ListItem Value="13" meta:resourcekey="ListItemResource29" 
                                    Text="13th of the month"></asp:ListItem>
                                <asp:ListItem Value="14" meta:resourcekey="ListItemResource30" 
                                    Text="14th of the month"></asp:ListItem>
                                <asp:ListItem Value="15" meta:resourcekey="ListItemResource31" 
                                    Text="15th of the month"></asp:ListItem>
                                <asp:ListItem Value="16" meta:resourcekey="ListItemResource32" 
                                    Text="16th of the month"></asp:ListItem>
                                <asp:ListItem Value="17" meta:resourcekey="ListItemResource33" 
                                    Text="17th of the month"></asp:ListItem>
                                <asp:ListItem Value="18" meta:resourcekey="ListItemResource34" 
                                    Text="18th of the month"></asp:ListItem>
                                <asp:ListItem Value="19" meta:resourcekey="ListItemResource35" 
                                    Text="19th of the month"></asp:ListItem>
                                <asp:ListItem Value="20" meta:resourcekey="ListItemResource36" 
                                    Text="20th of the month"></asp:ListItem>
                                <asp:ListItem Value="21" meta:resourcekey="ListItemResource37" 
                                    Text="21th of the month"></asp:ListItem>
                                <asp:ListItem Value="22" meta:resourcekey="ListItemResource38" 
                                    Text="22th of the month"></asp:ListItem>
                                <asp:ListItem Value="23" meta:resourcekey="ListItemResource39" 
                                    Text="23th of the month"></asp:ListItem>
                                <asp:ListItem Value="24" meta:resourcekey="ListItemResource40" 
                                    Text="24th of the month"></asp:ListItem>
                                <asp:ListItem Value="25" meta:resourcekey="ListItemResource41" 
                                    Text="25th of the month"></asp:ListItem>
                                <asp:ListItem Value="26" meta:resourcekey="ListItemResource42" 
                                    Text="26th of the month"></asp:ListItem>
                                <asp:ListItem Value="27" meta:resourcekey="ListItemResource43" 
                                    Text="27th of the month"></asp:ListItem>
                                <asp:ListItem Value="28" meta:resourcekey="ListItemResource44" 
                                    Text="28th of the month"></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource45" 
                                    Text="Last day of the month"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="ReminderUser1ID" PropertyName="ReminderUser1ID" caption="Reminder User 1" ValidateRequiredField="True" meta:resourcekey="ReminderUser1IDResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="ReminderUser2ID" PropertyName="ReminderUser2ID" caption="Reminder User 2" meta:resourcekey="ReminderUser2IDResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="ReminderUser3ID" PropertyName="ReminderUser3ID" caption="Reminder User 3" meta:resourcekey="ReminderUser3IDResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="ReminderUser4ID" PropertyName="ReminderUser4ID" caption="Reminder User 4" meta:resourcekey="ReminderUser4IDResource1" />
                    </ui:UIPanel>
                    <ui:UIFieldCheckBox runat="server" ID="IsActive" PropertyName="IsActive" Caption="Is Active" Text="Yes, this Point is active for the next meter reading" meta:resourcekey="IsActiveResource1" TextAlign="Right" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTrigger" Caption="Trigger" BorderStyle="NotSet" meta:resourcekey="tabTriggerResource1">
                    <ui:uifieldradiolist runat="server" ID="radioCreateWorkOnBreach" PropertyName="CreateWorkOnBreach" Caption="Breach" ValidateRequiredField="True" OnSelectedIndexChanged="radioCreateWorkOnBreach_SelectedIndexChanged" meta:resourcekey="radioCreateWorkOnBreachResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" Text="No action triggered when a breach occurs" meta:resourcekey="ListItemResource5"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Create a Work when a breach occurs" meta:resourcekey="ListItemResource6"></asp:ListItem>
                        </Items>
                    </ui:uifieldradiolist>
                    <ui:UIPanel runat="server" ID="panelBreach" BorderStyle="NotSet" meta:resourcekey="panelBreachResource1">
                        <ui:UISeparator runat="server" ID="sep1" Caption="Breach" meta:resourcekey="sep1Resource1" />
                        <table cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style="width: 128px">
                                    <asp:Label runat="server" ID="labelAcceptableLimit" Text="Acceptable Limit: " meta:resourcekey="labelAcceptableLimitResource1"></asp:Label>
                                </td>
                                <td>
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumAcceptableReading" PropertyName="MinimumAcceptableReading" Caption="Minimum Acceptable Reading" Span="Half" CaptionWidth="180px" ValidateRequiredField="True" ShowCaption="False" FieldLayout="Flow" InternalControlWidth="80px" ValidateCompareField="True" ValidationCompareControl="textMaximumAcceptableReading" ValidationCompareType="Currency" ValidationCompareOperator="LessThanEqual" meta:resourcekey="textMinimumAcceptableReadingResource1">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelAcceptableLimitTo" Text=" to " meta:resourcekey="labelAcceptableLimitToResource1"></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textMaximumAcceptableReading" PropertyName="MaximumAcceptableReading" Caption="Maximum Acceptable Reading" Span="Half" CaptionWidth="180px" ValidateRequiredField="True" ShowCaption="False" FieldLayout="Flow" InternalControlWidth="80px" ValidateCompareField="True" ValidationCompareControl="textMinimumAcceptableReading" ValidationCompareType="Currency" ValidationCompareOperator="GreaterThanEqual" meta:resourcekey="textMaximumAcceptableReadingResource1">
                                    </ui:UIFieldTextBox>
                                </td>
                            </tr>
                        </table>
                        <ui:uipanel runat="server" id="panelBreachCondition" BorderStyle="NotSet" meta:resourcekey="panelBreachConditionResource1">
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr>
                                    <td style="width: 128px">
                                        <asp:Label runat="server" ID="labelBreachCondition" Text="Create Work: " meta:resourcekey="labelBreachConditionResource1"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="labelCreateWork" Text="Create work only after readings breach the acceptable limit after" meta:resourcekey="labelCreateWorkResource1"></asp:Label>
                                        <ui:UIFieldTextBox runat="server" ID="NumberOfBreachesToTriggerAction" PropertyName="NumberOfBreachesToTriggerAction" ShowCaption="False" FieldLayout="Flow" InternalControlWidth="" ValidateRequiredField="True" Caption="Number of Times Breached" ValidateRangeField="True" ValidationRangeType="Currency" ValidationRangeMin="1" meta:resourcekey="NumberOfBreachesToTriggerActionResource1">
                                        </ui:UIFieldTextBox>
                                        <asp:Label runat="server" ID="labelAfterNumberOfTimes" Text="time(s) (applicable to readings taken from OPC)" meta:resourcekey="labelAfterNumberOfTimesResource1"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </ui:uipanel>
                        <ui:UIFieldRadioList runat="server" ID="checkCreateOnlyIfWorksAreCancelledOrClosed" PropertyName="CreateOnlyIfWorksAreCancelledOrClosed" Caption="Duplicate Works" ValidateRequiredField="True" meta:resourcekey="checkCreateOnlyIfWorksAreCancelledOrClosedResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" Text="Create a work regardless of whether works created by the breach of this point are still open." meta:resourcekey="ListItemResource7"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Create a work only if works created by the breach of this point have all been cancelled or closed." meta:resourcekey="ListItemResource8"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UISeparator runat="server" ID="UISeparator1" Caption="Trigger" meta:resourcekey="UISeparator1Resource1" />
                        <ui:UIFieldTreeList runat="server" ID="TreeTrigger" Caption="Point Trigger" PropertyName="PointTriggerID" OnAcquireTreePopulater="TreeTrigger_AcquireTreePopulater" OnSelectedNodeChanged="TreeTrigger_SelectedNodeChanged" meta:resourcekey="TreeTriggerResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UIPanel runat="server" ID="TriggerTemplate" Visible="False" BorderStyle="NotSet" meta:resourcekey="TriggerTemplateResource1">
                            <ui:UIFieldLabel runat="server" ID="lbWork" PropertyName="PointTrigger.TypeOfWorkText" Caption="Type of Work" DataFormatString="" meta:resourcekey="lbWorkResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbService" PropertyName="PointTrigger.TypeOfServiceText" Caption="Type of Service" DataFormatString="" meta:resourcekey="lbServiceResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbProblem" PropertyName="PointTrigger.TypeOfProblemText" Caption="Type of Problem" DataFormatString="" meta:resourcekey="lbProblemResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbPriority" PropertyName="PointTrigger.PriorityText" Caption="Priority" DataFormatString="" meta:resourcekey="lbPriorityResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbDescription" PropertyName="PointTrigger.WorkDescription" Caption="Work Description" DataFormatString="" meta:resourcekey="lbDescriptionResource1">
                            </ui:UIFieldLabel>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="TriggerManual" BorderStyle="NotSet" meta:resourcekey="TriggerManualResource1">
                            <ui:UIFieldDropDownList runat="server" ID="dropTypeOfWork" PropertyName="TypeOfWorkID" Caption="Type of Work" ValidateRequiredField="True" OnSelectedIndexChanged="dropTypeOfWork_SelectedIndexChanged" meta:resourcekey="dropTypeOfWorkResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropTypeOfService" PropertyName="TypeOfServiceID" Caption="Type of Service" ValidateRequiredField="True" OnSelectedIndexChanged="dropTypeOfService_SelectedIndexChanged" meta:resourcekey="dropTypeOfServiceResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropTypeOfProblem" PropertyName="TypeOfProblemID" Caption="Type of Problem" ValidateRequiredField="True" meta:resourcekey="dropTypeOfProblemResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropPriority" PropertyName="Priority" Caption="Priority" ValidateRequiredField="True" meta:resourcekey="dropPriorityResource1">
                                <Items>
                                    <asp:ListItem Text="0" Value="0" meta:resourcekey="ListItemResource9"></asp:ListItem>
                                    <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource10"></asp:ListItem>
                                    <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource11"></asp:ListItem>
                                    <asp:ListItem Text="3" Value="3" meta:resourcekey="ListItemResource12"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:uifieldtextbox runat="server" ID="textWorkDescription" PropertyName="WorkDescription" Caption="Work Description" ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="textWorkDescriptionResource1">
                            </ui:uifieldtextbox>
                        </ui:UIPanel>
                        <ui:UIHint runat="server" ID="hintWorkDescription" 
                            meta:resourcekey="hintWorkDescriptionResource1" Text="">&nbsp;&nbsp;<asp:Table 
                                runat="server" CellPadding="4" CellSpacing="0" 
                                meta:resourcekey="TableResource1" Width="100%">
                                <asp:TableRow runat="server" meta:resourcekey="TableRowResource1">
                                    <asp:TableCell runat="server" meta:resourcekey="TableCellResource1" 
                                        VerticalAlign="Top" Width="16px"><asp:Image runat="server" 
                                        ImageUrl="~/images/information.gif" meta:resourcekey="ImageResource1" />
                                    </asp:TableCell>
                                    <asp:TableCell runat="server" meta:resourcekey="TableCellResource2" 
                                        VerticalAlign="Top"><asp:Label runat="server" 
                                        meta:resourcekey="LabelResource1"> The work description describes the 
                                    problem in greater detail. To include the reading that breached the limit as 
                                    part of the description, use the special tag <b>{0}</b>.
                                    <br />
                                    <br />
                                    For example,
                                    <br />
                                    &nbsp; &nbsp; The aircon temperature (<b>{0}</b> deg Celsius) has exceed acceptable limits 
                                    10 - 25 deg Celsius.
                                    <br />
                                    <br />
                                    If the reading is 9 degrees Celsius and a work is triggered, the work 
                                    description will be populated with the following description:
                                    <br />
                                    &nbsp; &nbsp; The aircon temperature (9 deg Celsius) has exceed acceptable limits 10 - 25 
                                    deg Celsius. </asp:Label>
                                    </asp:TableCell>
                                </asp:TableRow>
                            </asp:Table>
                        </ui:UIHint>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabReadings" Caption="Reading" OnClick="tabReadings_Click" BorderStyle="NotSet" meta:resourcekey="tabReadingsResource1">
                    <ui:UIButton runat="server" ID="buttonRefresh" Text="Refresh" ImageUrl="~/images/refresh.gif" OnClick="buttonRefresh_Click" meta:resourcekey="buttonRefreshResource1" />
                    <br />
                    <br />
                    <ui:uigridview runat="server" ID="gridReadings" Visible="False" 
                        SortExpression="DateOfReading DESC" DataKeyNames="ObjectID" GridLines="Both" 
                        meta:resourcekey="gridReadingsResource1" RowErrorColor="" ShowCaption="False" 
                        ShowCommands="False" style="clear: both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="DateOfReading" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Date/Time of Reading" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="DateOfReading" ResourceAssemblyName="" SortExpression="DateOfReading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Reading" HeaderText="Reading" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Reading" ResourceAssemblyName="" SortExpression="Reading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Work.ObjectNumber" HeaderText="Work Number (that recorded this reading)" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Work.ObjectNumber" ResourceAssemblyName="" SortExpression="Work.ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreateBreachOnWork.ObjectNumber" HeaderText="Work Number (created as a result of a breach)" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="CreateBreachOnWork.ObjectNumber" ResourceAssemblyName="" SortExpression="CreateBreachOnWork.ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreateBreachOnWork.CurrentActivity.ObjectName" HeaderText="Work Status" meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="CreateBreachOnWork.CurrentActivity.ObjectName" ResourceAssemblyName="" SortExpression="CreateBreachOnWork.CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:UIHint runat="server" ID="hint1" meta:resourcekey="hint1Resource1" 
                        Text="Only the most recent 1,000 readings will be displayed."></ui:UIHint>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
