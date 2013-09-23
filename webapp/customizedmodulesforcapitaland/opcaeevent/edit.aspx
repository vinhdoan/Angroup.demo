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
        OOPCAEEvent opcAeEvent = panel.SessionObject as OOPCAEEvent;

        dropOPCAEServer.Bind(OOPCAEServer.GetAllOPCAEServers());
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();

        // Bind the type of work/services/problem
        // drop down lists.
        //
        dropTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", opcAeEvent.TypeOfWorkID));
        dropTypeOfService.Bind(OCode.GetCodesByParentID(opcAeEvent.TypeOfWorkID, opcAeEvent.TypeOfServiceID));
        dropTypeOfProblem.Bind(OCode.GetCodesByParentID(opcAeEvent.TypeOfServiceID, opcAeEvent.TypeOfProblemID));

        // Update the priority's text
        //
        dropPriority.Items[0].Text = Resources.Strings.Priority_0;
        dropPriority.Items[1].Text = Resources.Strings.Priority_1;
        dropPriority.Items[2].Text = Resources.Strings.Priority_2;
        dropPriority.Items[3].Text = Resources.Strings.Priority_3;

        TreeTrigger.PopulateTree();
    }


    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OOPCAEEvent opcAeEvent = panel.SessionObject as OOPCAEEvent;
        // KNX added: to fix bug that can select location and equipment together
        if (radioIsApplicableForLocation.SelectedIndex == 0)
            opcAeEvent.EquipmentID = null;
        else
            opcAeEvent.LocationID = null;

        if (opcAeEvent.IsDuplicateName())
            objectBase.ObjectName.ErrorMessage = Resources.Errors.OPCAEEvent_DuplicateName;

        if (!opcAeEvent.ValidateNoDuplicateOPCEventSource())
            textOPCEventSource.ErrorMessage = Resources.Errors.OPCAEEvent_DuplicateEventSource;
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
    protected void radioCreateWorkOnEvent_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelLocation.Visible = radioIsApplicableForLocation.SelectedValue == "1";
        panelEquipment.Visible = radioIsApplicableForLocation.SelectedValue == "0";

        panelBreach.Visible = radioCreateWorkOnEvent.SelectedValue == "1";

        if (gridEventHistory.Visible)
            tabEventHistory.Click -= new EventHandler(tabEventHistory_Click);

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
        OOPCAEEvent opcAeEvent = panel.SessionObject as OOPCAEEvent;
        return new EquipmentTreePopulater(opcAeEvent.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OOPCAEEvent opcAeEvent = panel.SessionObject as OOPCAEEvent;
        return new LocationTreePopulaterForCapitaland(opcAeEvent.LocationID, false, true, Security.Decrypt(Request["TYPE"]),false,false);
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
    /// Occurs when the user clicks on the event history tab.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void tabEventHistory_Click(object sender, EventArgs e)
    {
        if (!gridEventHistory.Visible)
        {
            OOPCAEEvent opcAeEvent = panel.SessionObject as OOPCAEEvent;
            gridEventHistory.DataSource = OOPCAEEventHistory.GetEventHistories(opcAeEvent.ObjectID.Value, 1000);
            gridEventHistory.DataBind();
            gridEventHistory.Visible = true;
        }

    }

    /// <summary>
    /// Refreshes the readings.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonRefresh_Click(object sender, EventArgs e)
    {
        OOPCAEEvent opcAeEvent = panel.SessionObject as OOPCAEEvent;
        gridEventHistory.DataSource = OOPCAEEventHistory.GetEventHistories(opcAeEvent.ObjectID.Value, 1000);
        gridEventHistory.DataBind();
    }


    protected TreePopulater TreeTrigger_AcquireTreePopulater(object sender)
    {
        TriggerManual.Dispose();
        OOPCAEEvent opcAeEvent = (OOPCAEEvent)panel.SessionObject;
        return new PointTriggerTreePopulater(opcAeEvent.PointTriggerID, false, true,
            Security.Decrypt(Request["TYPE"]));

    }

    
    /// <summary>
    /// Occurs when the user selects a node in the trigger tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TreeTrigger_SelectedNodeChanged(object sender, EventArgs e)
    {
        OOPCAEEvent opcAeEvent = (OOPCAEEvent)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(opcAeEvent);
        panel.ObjectPanel.BindObjectToControls(opcAeEvent);
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
        <web:object runat="server" ID="panel" meta:resourcekey="panelResource1" Caption="OPC AE Event" BaseTable="tOPCAEEvent" OnPopulateForm="panel_PopulateForm" AutomaticBindingAndSaving="true" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="uitabview1" runat="server" Caption="Details" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Event Source Name" meta:resourcekey="objectBaseResource1" ObjectNumberVisible="false"></web:base>
                    <ui:UIFieldTextBox runat="server" ID="textDescription" 
                        PropertyName="Description" Caption="Description" CaptionWidth="150px" 
                        MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="textDescriptionResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat="server" ID="dropOPCAEServer" 
                        PropertyName="OPCAEServerID" Caption="OPC AE Server" CaptionWidth="150px" 
                        ValidateRequiredField="True" meta:resourcekey="dropOPCAEServerResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat='server' ID="textOPCEventSource" 
                        Caption="OPC Event Source" PropertyName="OPCEventSource" 
                        ValidateRequiredField="True" CaptionWidth="150px" InternalControlWidth="95%" 
                        meta:resourcekey="textOPCEventSourceResource1" >
                    </ui:UIFieldTextBox>
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
                            meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                    </ui:UIPanel>
                    <ui:UIFieldCheckBox runat="server" ID="checkSaveHistoricalEvents" 
                        CaptionWidth="150px" PropertyName="SaveHistoricalEvents" 
                        Caption="Save Historical Events" 
                        Text="Yes, save historical events raised by the AE server into the database" 
                        meta:resourcekey="checkSaveHistoricalEventsResource1" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTrigger" Caption="Trigger" 
                    BorderStyle="NotSet" meta:resourcekey="tabTriggerResource1">
                    <ui:UIFieldRadioList runat="server" ID="radioCreateWorkOnEvent" 
                        PropertyName="CreateWorkOnEvent" Caption="Breach" ValidateRequiredField="True" 
                        OnSelectedIndexChanged="radioCreateWorkOnEvent_SelectedIndexChanged" 
                        meta:resourcekey="radioCreateWorkOnEventResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" Text="No action triggered when this event occurs" 
                                meta:resourcekey="ListItemResource3"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Create a Work when this event occurs" 
                                meta:resourcekey="ListItemResource4"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIPanel runat="server" ID="panelBreach" BorderStyle="NotSet" 
                        meta:resourcekey="panelBreachResource1">
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Conditions" 
                            meta:resourcekey="UISeparator2Resource1" />
                        <ui:UIFieldTextBox runat='server' ID="textConditionNames" 
                            PropertyName="ConditionNames" Caption="Condition Names" 
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textConditionNamesResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat='server' ID="textSubConditionNames" 
                            PropertyName="SubConditionNames" Caption="Sub-Condition Names" 
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textSubConditionNamesResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIHint runat="server" ID="hintConditionNames" 
                            meta:resourcekey="hintConditionNamesResource1"><asp:Table runat="server" 
                            CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell 
                                    runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" 
                                    ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                    runat="server" VerticalAlign="Top"><asp:Label runat="server"> Use a comma to separate the different condition or sub-conditions that will be considered an event. For example, you can enter &quot;SP_LOW,SP_HIGH&quot; if you want these conditions to be considered as an event that will trigger an action. <br /><br />Use &#39;*&#39; to indicate that all conditions or sub-conditions will trigger an action. </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
                        <table cellpadding='0' cellspacing='0' border='0' style="clear: both">
                            <tr>
                                <td style='width: 120px'>
                                    <asp:Label runat='server' ID='label1' meta:resourcekey="label1Resource1">Severity:</asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat='server' ID='labelSeverity1' 
                                        meta:resourcekey="labelSeverity1Resource1">Ranges from</asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textSeverityFrom" 
                                        PropertyName="SeverityFrom" ShowCaption="False" FieldLayout="Flow" 
                                        Caption="Severity (from)" InternalControlWidth="80px" 
                                        ValidateRequiredField="True" ValidateDataTypeCheck="True" 
                                        ValidationDataType="Integer" ValidateRangeField="True" 
                                        ValidationRangeType='Integer' ValidationRangeMin="0" 
                                        ValidateCompareField="True" ValidationCompareControl="textSeverityTo" 
                                        ValidationCompareOperator="LessThanEqual" ValidationCompareType="Integer" 
                                        meta:resourcekey="textSeverityFromResource1">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat='server' ID='labelSeverity2' 
                                        meta:resourcekey="labelSeverity2Resource1">to</asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textSeverityTo" PropertyName="SeverityTo" 
                                        ShowCaption="False" FieldLayout="Flow" Caption="Severity (to)" 
                                        InternalControlWidth="80px" ValidateRequiredField="True" 
                                        ValidateDataTypeCheck="True" ValidationDataType="Integer" 
                                        ValidateRangeField="True" ValidationRangeType='Integer' ValidationRangeMin="0" 
                                        ValidateCompareField="True" ValidationCompareControl="textSeverityFrom" 
                                        ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Integer" 
                                        meta:resourcekey="textSeverityToResource1">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat='server' ID='labelSeverity3' 
                                        meta:resourcekey="labelSeverity3Resource1"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 150px">
                                    <asp:Label runat="server" ID="labelBreachCondition" Text="Create Work: " 
                                        meta:resourcekey="labelBreachConditionResource1"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelCreateWork" 
                                        Text="Create work only after events have been raised after" 
                                        meta:resourcekey="labelCreateWorkResource1"></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textNumberOfEventsToTriggerAction" 
                                        PropertyName="NumberOfEventsToTriggerAction" ShowCaption="False" 
                                        FieldLayout="Flow" InternalControlWidth="" ValidateRequiredField="True" 
                                        Caption="Number of Times Breached" ValidateRangeField="True" 
                                        ValidationRangeType="Currency" ValidationRangeMin="1" 
                                        meta:resourcekey="textNumberOfEventsToTriggerActionResource1">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelAfterNumberOfTimes" Text="time(s)" 
                                        meta:resourcekey="labelAfterNumberOfTimesResource1"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        <ui:UIFieldRadioList runat="server" 
                            ID="checkCreateOnlyIfWorksAreCancelledOrClosed" 
                            PropertyName="CreateOnlyIfWorksAreCancelledOrClosed" Caption="Duplicate Works" 
                            ValidateRequiredField="True" 
                            meta:resourcekey="checkCreateOnlyIfWorksAreCancelledOrClosedResource1" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" 
                                    Text="Create a work regardless of whether works created by this are still open." 
                                    meta:resourcekey="ListItemResource5"></asp:ListItem>
                                <asp:ListItem Value="1" 
                                    Text="Create a work only if works created by this event have all been cancelled or closed." 
                                    meta:resourcekey="ListItemResource6"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <br />
                        <br />
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
                                    <asp:ListItem Text="0" Value="0" meta:resourcekey="ListItemResource7"></asp:ListItem>
                                    <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource8"></asp:ListItem>
                                    <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource9"></asp:ListItem>
                                    <asp:ListItem Text="3" Value="3" meta:resourcekey="ListItemResource10"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox runat="server" ID="textWorkDescription" 
                                PropertyName="WorkDescription" Caption="Work Description" 
                                ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" 
                                meta:resourcekey="textWorkDescriptionResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIHint runat="server" ID="hintWorkDescription" 
                                meta:resourcekey="hintWorkDescriptionResource1"><asp:Table runat="server" 
                                CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell 
                                        runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" 
                                        ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                        runat="server" VerticalAlign="Top"><asp:Label runat="server"> The work description describes the problem in greater detail. <br /><br />For example, &quot;The aircon in basement #1 has raised an alarm.&quot; </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabEventHistory" Caption="Event History" 
                    OnClick="tabEventHistory_Click" BorderStyle="NotSet" 
                    meta:resourcekey="tabEventHistoryResource1">
                    <ui:UIButton runat="server" ID="buttonRefresh" Text="Refresh" 
                        ImageUrl="~/images/refresh.gif" OnClick="buttonRefresh_Click" 
                        meta:resourcekey="buttonRefreshResource1" />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="gridEventHistory" Visible="False" 
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                        meta:resourcekey="gridEventHistoryResource1" RowErrorColor="" 
                        ShowCaption="False" ShowCommands="False" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="DateOfEvent" 
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Date/Time of Event" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="DateOfEvent" 
                                ResourceAssemblyName="" SortExpression="DateOfEvent">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Source" HeaderText="Source" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Source" 
                                ResourceAssemblyName="" SortExpression="Source">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ConditionName" 
                                HeaderText="Condition Name" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                PropertyName="ConditionName" ResourceAssemblyName="" 
                                SortExpression="ConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SubConditionName" 
                                HeaderText="Sub-Condition Name" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" 
                                PropertyName="SubConditionName" ResourceAssemblyName="" 
                                SortExpression="SubConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Message" HeaderText="Message" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="Message" 
                                ResourceAssemblyName="" SortExpression="Message">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreateOnEventWork.ObjectNumber" 
                                HeaderText="Work Number" meta:resourcekey="UIGridViewBoundColumnResource6" 
                                PropertyName="CreateOnEventWork.ObjectNumber" ResourceAssemblyName="" 
                                SortExpression="CreateOnEventWork.ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreateOnEventWork.CurrentActivity.ObjectName" 
                                HeaderText="Work Status" meta:resourcekey="UIGridViewBoundColumnResource7" 
                                PropertyName="CreateOnEventWork.CurrentActivity.ObjectName" 
                                ResourceAssemblyName="" 
                                SortExpression="CreateOnEventWork.CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIHint runat="server" ID="hint1" meta:resourcekey="hint1Resource1"><asp:Table 
                        runat="server" CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow 
                            runat="server"><asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image 
                                runat="server" ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                runat="server" VerticalAlign="Top"><asp:Label runat="server">Only the most recent 1,000 events will be displayed.</asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
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
