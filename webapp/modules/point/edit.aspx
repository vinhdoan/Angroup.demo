<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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



        // Bind the type of work/services/problem
        // drop down lists.
        //
        dropTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", point.TypeOfWorkID));
        dropTypeOfService.Bind(OCode.GetCodesByParentID(point.TypeOfWorkID, point.TypeOfServiceID));
        dropTypeOfProblem.Bind(OCode.GetCodesByParentID(point.TypeOfServiceID, point.TypeOfProblemID));

        // Update the priority's text
        //
        dropPriority.Items[0].Text = Resources.Strings.Priority_0;
        dropPriority.Items[1].Text = Resources.Strings.Priority_1;
        dropPriority.Items[2].Text = Resources.Strings.Priority_2;
        dropPriority.Items[3].Text = Resources.Strings.Priority_3;

        dropUnit.Bind(OCode.GetCodesByType("UnitOfMeasure", point.UnitOfMeasureID));
        TreeTrigger.PopulateTree();
    }




    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OPoint point = panel.SessionObject as OPoint;

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

        if (point.IsDuplicateName())
            objectBase.ObjectName.ErrorMessage = Resources.Errors.Point_DuplicateName;

        if (!point.ValidateNoDuplicateOPCItemName())
            textOPCItemName.ErrorMessage = Resources.Errors.Point_DuplicateOPCItemName;
    }

    protected TreePopulater TreeTrigger_AcquireTreePopulater(object sender)
    {
        TriggerManual.Dispose();
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
        return new LocationTreePopulater(point.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Point" meta:resourcekey="panelResource1" BaseTable="tPoint" OnPopulateForm="panel_PopulateForm" AutomaticBindingAndSaving="true" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="uitabview1" runat="server" Caption="Details" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Point Name" meta:resourcekey="objectBaseResource1" ObjectNumberVisible="false"></web:base>
                    <ui:UIFieldRadioList runat='server' ID="radioIsApplicableForLocation" 
                        PropertyName="IsApplicableForLocation" Caption="Location/Equipment" 
                        CaptionWidth="150px" 
                        OnSelectedIndexChanged="radioIsApplicableForLocation_SelectedIndexChanged" 
                        ValidateRequiredField="True" 
                        meta:resourcekey="radioIsApplicableForLocationResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="1" Text="Location" meta:resourcekey="ListItemResource1"></asp:ListItem>
                            <asp:ListItem Value="0" Text="Equipment" meta:resourcekey="ListItemResource2"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIPanel runat="server" ID="panelLocation" BorderStyle="NotSet" 
                        meta:resourcekey="panelLocationResource1">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" PropertyName="LocationID" 
                            Caption="Location" CaptionWidth="150px" ValidateRequiredField="True" 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                            OnSelectedNodeChanged="treeLocation_SelectedNodeChanged" 
                            meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelEquipment" BorderStyle="NotSet" 
                        meta:resourcekey="panelEquipmentResource1">
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" 
                            PropertyName="EquipmentID" ValidateRequiredField="True" Caption="Equipment" 
                            CaptionWidth="150px" 
                            OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                            OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged" 
                            meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                    </ui:UIPanel>
                    <ui:UIFieldDropDownList runat="server" ID="dropOPCDAServer" 
                        PropertyName="OPCDAServerID" Caption="OPC DA Server" CaptionWidth="150px" 
                        OnSelectedIndexChanged="dropOPCDAServer_SelectedIndexChanged" 
                        meta:resourcekey="dropOPCDAServerResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="textOPCItemName" CaptionWidth="150px" 
                        PropertyName="OPCItemName" Caption="OPC Item Name" ValidateRequiredField="True" 
                        InternalControlWidth="95%" meta:resourcekey="textOPCItemNameResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="textDescription" 
                        PropertyName="Description" Caption="Description" CaptionWidth="150px" 
                        MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="textDescriptionResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="textBarcode" PropertyName="Barcode" 
                        Caption="Barcode" CaptionWidth="150px" InternalControlWidth="95%" 
                        meta:resourcekey="textBarcodeResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat="server" ID="dropUnit" 
                        PropertyName="UnitOfMeasureID" Caption="Unit Of Measure" CaptionWidth="150px" 
                        ValidateRequiredField="True" meta:resourcekey="dropUnitResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UISeparator runat="server" ID="separator" Caption="Behavior" 
                        meta:resourcekey="separatorResource1" />
                    <ui:UIPanel runat="server" ID="panelBehavior" BorderStyle="NotSet" 
                        meta:resourcekey="panelBehaviorResource1">
                        <ui:UIFieldRadioList runat="server" ID="radioIsIncreasingMeter" Caption="Type" 
                            PropertyName="IsIncreasingMeter" ValidateRequiredField="True" 
                            OnSelectedIndexChanged="radioIsIncreasingMeter_SelectedIndexChanged" 
                            meta:resourcekey="radioIsIncreasingMeterResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource3">Absolute Reading (for readings from temperature, vibration sensors, etc that do not increase over time)</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource4">Increasing Reading (for readings from electrical meters, water meters, etc that always increase over time)</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelBehaviorProperties" BorderStyle="NotSet" 
                            meta:resourcekey="panelBehaviorPropertiesResource1">
                            <ui:UIFieldTextBox runat="server" ID="textMaximumReading" 
                                Caption="Maximum Reading" PropertyName="MaximumReading" 
                                ValidateRequiredField='True' ValidateRangeField="True" ValidationRangeMin="0" 
                                ValidationRangeMinInclusive="False" ValidationRangeType='Currency' Span="Half" 
                                InternalControlWidth="95%" meta:resourcekey="textMaximumReadingResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="textFactor" Caption="Factor" 
                                PropertyName="Factor" ValidateRequiredField='True' ValidateRangeField="True" 
                                ValidationRangeType='Currency' ValidationRangeMin="0" 
                                ValidationRangeMinInclusive="False" Span="Half" InternalControlWidth="95%" 
                                meta:resourcekey="textFactorResource1">
                            </ui:UIFieldTextBox>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTrigger" Caption="Trigger" 
                    BorderStyle="NotSet" meta:resourcekey="tabTriggerResource1">
                    <ui:uifieldradiolist runat="server" ID="radioCreateWorkOnBreach" 
                        PropertyName="CreateWorkOnBreach" Caption="Breach" CaptionWidth="150px" 
                        ValidateRequiredField="True" 
                        OnSelectedIndexChanged="radioCreateWorkOnBreach_SelectedIndexChanged" 
                        meta:resourcekey="radioCreateWorkOnBreachResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" Text="No action triggered when a breach occurs" 
                                meta:resourcekey="ListItemResource5"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Create a Work when a breach occurs" 
                                meta:resourcekey="ListItemResource6"></asp:ListItem>
                        </Items>
                    </ui:uifieldradiolist>
                    <ui:UIPanel runat="server" ID="panelBreach" BorderStyle="NotSet" 
                        meta:resourcekey="panelBreachResource1">
                        <ui:UISeparator runat="server" ID="sep1" Caption="Breach" 
                            meta:resourcekey="sep1Resource1" />
                        <table cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style="width: 128px">
                                    <asp:Label runat="server" ID="labelAcceptableLimit" Text="Acceptable Limit: " 
                                        meta:resourcekey="labelAcceptableLimitResource1"></asp:Label>
                                </td>
                                <td>
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumAcceptableReading" 
                                        PropertyName="MinimumAcceptableReading" Caption="Minimum Acceptable Reading" 
                                        Span="Half" CaptionWidth="180px" ValidateRequiredField="True" 
                                        ShowCaption="False" FieldLayout="Flow" InternalControlWidth="80px" 
                                        ValidateCompareField="True" 
                                        ValidationCompareControl="textMaximumAcceptableReading" 
                                        ValidationCompareType="Currency" ValidationCompareOperator="LessThanEqual" 
                                        meta:resourcekey="textMinimumAcceptableReadingResource1">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelAcceptableLimitTo" Text=" to " 
                                        meta:resourcekey="labelAcceptableLimitToResource1"></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textMaximumAcceptableReading" 
                                        PropertyName="MaximumAcceptableReading" Caption="Maximum Acceptable Reading" 
                                        Span="Half" CaptionWidth="180px" ValidateRequiredField="True" 
                                        ShowCaption="False" FieldLayout="Flow" InternalControlWidth="80px" 
                                        ValidateCompareField="True" 
                                        ValidationCompareControl="textMinimumAcceptableReading" 
                                        ValidationCompareType="Currency" ValidationCompareOperator="GreaterThanEqual" 
                                        meta:resourcekey="textMaximumAcceptableReadingResource1">
                                    </ui:UIFieldTextBox>
                                </td>
                            </tr>
                        </table>
                        <ui:uipanel runat="server" id="panelBreachCondition" BorderStyle="NotSet" 
                            meta:resourcekey="panelBreachConditionResource1">
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr>
                                    <td style="width: 128px">
                                        <asp:Label runat="server" ID="labelBreachCondition" Text="Create Work: " 
                                            meta:resourcekey="labelBreachConditionResource1"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="labelCreateWork" 
                                            Text="Create work only after readings breach the acceptable limit after" 
                                            meta:resourcekey="labelCreateWorkResource1"></asp:Label>
                                        <ui:UIFieldTextBox runat="server" ID="NumberOfBreachesToTriggerAction" 
                                            PropertyName="NumberOfBreachesToTriggerAction" ShowCaption="False" 
                                            FieldLayout="Flow" InternalControlWidth="" ValidateRequiredField="True" 
                                            Caption="Number of Times Breached" ValidateRangeField="True" 
                                            ValidationRangeType="Currency" ValidationRangeMin="1" 
                                            meta:resourcekey="NumberOfBreachesToTriggerActionResource1">
                                        </ui:UIFieldTextBox>
                                        <asp:Label runat="server" ID="labelAfterNumberOfTimes" 
                                            Text="time(s) (applicable to readings taken from OPC)" 
                                            meta:resourcekey="labelAfterNumberOfTimesResource1"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </ui:uipanel>
                        <ui:UIFieldRadioList runat="server" 
                            ID="checkCreateOnlyIfWorksAreCancelledOrClosed" 
                            PropertyName="CreateOnlyIfWorksAreCancelledOrClosed" Caption="Duplicate Works" 
                            ValidateRequiredField="True" 
                            meta:resourcekey="checkCreateOnlyIfWorksAreCancelledOrClosedResource1" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" 
                                    Text="Create a work regardless of whether works created by the breach of this point are still open." 
                                    meta:resourcekey="ListItemResource7"></asp:ListItem>
                                <asp:ListItem Value="1" 
                                    Text="Create a work only if works created by the breach of this point have all been cancelled or closed." 
                                    meta:resourcekey="ListItemResource8"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UISeparator runat="server" ID="UISeparator1" Caption="Trigger" 
                            meta:resourcekey="UISeparator1Resource1" />
                        <ui:UIFieldTreeList runat="server" ID="TreeTrigger" Caption="Point Trigger" 
                            PropertyName="PointTriggerID" 
                            OnAcquireTreePopulater="TreeTrigger_AcquireTreePopulater" 
                            OnSelectedNodeChanged="TreeTrigger_SelectedNodeChanged" 
                            meta:resourcekey="TreeTriggerResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode" />
                        <ui:UIPanel runat="server" ID="TriggerTemplate" Visible="False" 
                            BorderStyle="NotSet" meta:resourcekey="TriggerTemplateResource1">
                            <ui:UIFieldLabel runat="server" ID="lbWork" 
                                PropertyName="PointTrigger.TypeOfWorkText" Caption="Type of Work" 
                                DataFormatString="" meta:resourcekey="lbWorkResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbService" 
                                PropertyName="PointTrigger.TypeOfServiceText" Caption="Type of Service" 
                                DataFormatString="" meta:resourcekey="lbServiceResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbProblem" 
                                PropertyName="PointTrigger.TypeOfProblemText" Caption="Type of Problem" 
                                DataFormatString="" meta:resourcekey="lbProblemResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbPriority" 
                                PropertyName="PointTrigger.PriorityText" Caption="Priority" DataFormatString="" 
                                meta:resourcekey="lbPriorityResource1">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel runat="server" ID="lbDescription" 
                                PropertyName="PointTrigger.WorkDescription" Caption="Work Description" 
                                DataFormatString="" meta:resourcekey="lbDescriptionResource1">
                            </ui:UIFieldLabel>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="TriggerManual" BorderStyle="NotSet" 
                            meta:resourcekey="TriggerManualResource1">
                            <ui:UIFieldDropDownList runat="server" ID="dropTypeOfWork" 
                                PropertyName="TypeOfWorkID" Caption="Type of Work" ValidateRequiredField="True" 
                                OnSelectedIndexChanged="dropTypeOfWork_SelectedIndexChanged" 
                                meta:resourcekey="dropTypeOfWorkResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropTypeOfService" 
                                PropertyName="TypeOfServiceID" Caption="Type of Service" 
                                ValidateRequiredField="True" 
                                OnSelectedIndexChanged="dropTypeOfService_SelectedIndexChanged" 
                                meta:resourcekey="dropTypeOfServiceResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropTypeOfProblem" 
                                PropertyName="TypeOfProblemID" Caption="Type of Problem" 
                                ValidateRequiredField="True" meta:resourcekey="dropTypeOfProblemResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="dropPriority" 
                                PropertyName="Priority" Caption="Priority" ValidateRequiredField="True" 
                                meta:resourcekey="dropPriorityResource1">
                                <Items>
                                    <asp:ListItem Text="0" Value="0" meta:resourcekey="ListItemResource9"></asp:ListItem>
                                    <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource10"></asp:ListItem>
                                    <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource11"></asp:ListItem>
                                    <asp:ListItem Text="3" Value="3" meta:resourcekey="ListItemResource12"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:uifieldtextbox runat="server" ID="textWorkDescription" 
                                PropertyName="WorkDescription" Caption="Work Description" 
                                ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" 
                                meta:resourcekey="textWorkDescriptionResource1">
                            </ui:uifieldtextbox>
                        </ui:UIPanel>
                        <ui:UIHint runat="server" ID="hintWorkDescription" 
                            meta:resourcekey="hintWorkDescriptionResource1"><asp:Table runat="server" 
                            CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell 
                                    runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" 
                                    ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                    runat="server" VerticalAlign="Top"><asp:Label runat="server"> The work description describes the problem in greater detail. To include the reading that breached the limit as part of the description, use the special tag <b>{0}</b>. <br /><br />For example, <br />&nbsp; &nbsp; The aircon temperature (<b>{0}</b> deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. <br /><br />If the reading is 9 degrees Celsius and a work is triggered, the work description will be populated with the following description: <br />&nbsp; &nbsp; The aircon temperature (9 deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabReadings" Caption="Reading" 
                    OnClick="tabReadings_Click" BorderStyle="NotSet" 
                    meta:resourcekey="tabReadingsResource1">
                    <ui:UIButton runat="server" ID="buttonRefresh" Text="Refresh" 
                        ImageUrl="~/images/refresh.gif" OnClick="buttonRefresh_Click" 
                        meta:resourcekey="buttonRefreshResource1" />
                    <br />
                    <br />
                    <ui:uigridview runat="server" ID="gridReadings" Visible="False" 
                        SortExpression="DateOfReading DESC" DataKeyNames="ObjectID" GridLines="Both" 
                        ImageRowErrorUrl="" meta:resourcekey="gridReadingsResource1" RowErrorColor="" 
                        ShowCaption="False" ShowCommands="False" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="DateOfReading" 
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Date/Time of Reading" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="DateOfReading" 
                                ResourceAssemblyName="" SortExpression="DateOfReading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Reading" HeaderText="Reading" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Reading" 
                                ResourceAssemblyName="" SortExpression="Reading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Work.ObjectNumber" 
                                HeaderText="Work Number (that recorded this reading)" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" 
                                PropertyName="Work.ObjectNumber" ResourceAssemblyName="" 
                                SortExpression="Work.ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreateBreachOnWork.ObjectNumber" 
                                HeaderText="Work Number (created as a result of a breach)" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" 
                                PropertyName="CreateBreachOnWork.ObjectNumber" ResourceAssemblyName="" 
                                SortExpression="CreateBreachOnWork.ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreateBreachOnWork.CurrentActivity.ObjectName" 
                                HeaderText="Work Status" meta:resourcekey="UIGridViewBoundColumnResource5" 
                                PropertyName="CreateBreachOnWork.CurrentActivity.ObjectName" 
                                ResourceAssemblyName="" 
                                SortExpression="CreateBreachOnWork.CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:UIHint runat="server" ID="hint1" meta:resourcekey="hint1Resource1"><asp:Table 
                        runat="server" CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow 
                            runat="server"><asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image 
                                runat="server" ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                runat="server" VerticalAlign="Top"><asp:Label runat="server">Only the most recent 1,000 readings will be displayed.</asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                    meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" 
                    BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
