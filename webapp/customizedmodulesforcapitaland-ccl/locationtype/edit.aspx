<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

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
        OLocationType locationType = panel.SessionObject as OLocationType;

        if (Request["TREEOBJID"] != null && TablesLogic.tLocationType[Security.DecryptGuid(Request["TREEOBJID"])] != null)
        {
            locationType.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);

            if (locationType.Parent != null && locationType.Parent.IsLeafType == 1)
                locationType.ParentID = null;
        }

        ParentID.Enabled = locationType.IsNew || locationType.ParentID != null;

        ParentID.PopulateTree();
        IsLeafType.Enabled = locationType.IsNew;

        panel.ObjectPanel.BindObjectToControls(locationType);
    }

    /// <summary>
    /// Validates and saves the location type object to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OLocationType locationType = panel.SessionObject as OLocationType;
            panel.ObjectPanel.BindControlsToObject(locationType);

            // Validate
            if (locationType.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (locationType.IsCyclicalReference())
                ParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            locationType.Save();
            c.Commit();
        }
    }



    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        gridPoint.Visible = IsLeafType.Checked;
        panelIncreasingMeter.Visible = LocationTypePoint_IsIncreasingMeter.Checked;
        panelBreach.Visible = radioCreateWorkOnBreach.SelectedValue == "1";

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
    /// Occurs when user clicks on the check box.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsLeafType_CheckedChanged(object sender, EventArgs e) { }

    /// <summary>
    /// Occurs when user clicks on the check box.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void LocationTypePoint_IsIncreasingMeter_CheckedChanged(object sender, EventArgs e) { }

    /// <summary>
    /// Occurs when the user selects an item in Breach radio
    /// button list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioCreateWorkOnBreach_SelectedIndexChanged(object sender, EventArgs e) { }

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

    protected TreePopulater TreeTrigger_AcquireTreePopulater(object sender)
    {
        TriggerManual.Dispose();
        OLocationTypePoint pt = (OLocationTypePoint)LocationTypePoints_SubPanel.SessionObject;
        return new PointTriggerTreePopulater(pt.PointTriggerID, false, true,
            Security.Decrypt(Request["TYPE"]));

    }
    protected void TreeTrigger_SelectedNodeChanged(object sender, EventArgs e)
    {
        OLocationTypePoint pt = (OLocationTypePoint)LocationTypePoints_SubPanel.SessionObject;
        LocationTypePoints_SubPanel.ObjectPanel.BindControlsToObject(pt);
        LocationTypePoints_SubPanel.ObjectPanel.BindObjectToControls(pt);
    }

    /// <summary>
    /// Construct and returns the location type tree view.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new LocationTypePopulater(panel.SessionObject.ParentID, false);
    }

    /// <summary>
    /// Binds data to the unit of measure drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void LocationTypePoints_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OLocationTypePoint LocationTypePoint =
            LocationTypePoints_SubPanel.SessionObject as OLocationTypePoint;

        LocationTypePoint_UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", LocationTypePoint.UnitOfMeasureID));

        // Bind the type of work/services/problem
        // drop down lists.
        //
        dropTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", LocationTypePoint.TypeOfWorkID));
        dropTypeOfService.Bind(OCode.GetCodesByParentID(LocationTypePoint.TypeOfWorkID, LocationTypePoint.TypeOfServiceID));
        dropTypeOfProblem.Bind(OCode.GetCodesByParentID(LocationTypePoint.TypeOfServiceID, LocationTypePoint.TypeOfProblemID));

        // Update the priority's text
        //
        dropPriority.Items[0].Text = Resources.Strings.Priority_0;
        dropPriority.Items[1].Text = Resources.Strings.Priority_1;
        dropPriority.Items[2].Text = Resources.Strings.Priority_2;
        dropPriority.Items[3].Text = Resources.Strings.Priority_3;

        TreeTrigger.PopulateTree();
        LocationTypePoints_SubPanel.ObjectPanel.BindObjectToControls(LocationTypePoint);


    }


    /// <summary>
    /// Adds/updates the Location type point.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void LocationTypePoints_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OLocationType LocationType = panel.SessionObject as OLocationType;
        panel.ObjectPanel.BindControlsToObject(LocationType);

        OLocationTypePoint LocationTypePoint =
            LocationTypePoints_SubPanel.SessionObject as OLocationTypePoint;
        LocationTypePoints_SubPanel.ObjectPanel.BindControlsToObject(LocationTypePoint);

        // Other updates
        //
        if (LocationTypePoint.IsIncreasingMeter == 0)
        {
            LocationTypePoint.MaximumReading = null;
            LocationTypePoint.Factor = null;
        }

        if (LocationTypePoint.PointTriggerID != null)
        {
            LocationTypePoint.TypeOfWorkID = null;
            LocationTypePoint.TypeOfServiceID = null;
            LocationTypePoint.TypeOfProblemID = null;
            LocationTypePoint.Priority = 0;
            LocationTypePoint.WorkDescription = "";
        }


        LocationType.LocationTypePoints.Add(LocationTypePoint);

        panel.ObjectPanel.BindObjectToControls(LocationType);

    }


    /// <summary>
    /// Occurs when the user clicks on a button in the utilties grid.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridUtilities_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "AddNewRow")
        {
            OLocationTypeUtility utility = TablesLogic.tLocationTypeUtility.Create();
            OLocationType locationType = panel.SessionObject as OLocationType;

            tabUtility.BindControlsToObject(locationType);
            locationType.LocationTypeUtilities.Add(utility);
            tabUtility.BindObjectToControls(locationType);
        }
    }


    List<OCode> codesList = null;
    
    /// <summary>
    /// Binds the unit of measures to the dropdown list for selection.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridUtilities_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (codesList == null)
                codesList = OCode.GetCodesByType("UnitOfMeasure", null);

            UIFieldDropDownList dropUnitOfMeasure = e.Row.FindControl("dropUnitOfMeasure") as UIFieldDropDownList;
            if (dropUnitOfMeasure != null)
                dropUnitOfMeasure.Bind(codesList, "ObjectName", "ObjectID");
        }
        
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Location Type" BaseTable="tLocationType"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave"
            meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" 
                meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIFieldTreeList runat="server" ID="ParentID" ValidateRequiredField="True" PropertyName="ParentID"
                        Caption="Belongs Under" OnAcquireTreePopulater="ParentID_AcquireTreePopulater"
                        ToolTip="The type or group under which this item belongs." 
                        meta:resourcekey="ParentIDResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode" />
                    <ui:UIFieldCheckBox runat="server" ID="IsLeafType" PropertyName="IsLeafType" Caption="Location Type"
                        Text="Yes, this is a location type" ToolTip="Indicates if this is a location type or a group."
                        meta:resourcekey="IsLeafTypeResource1" 
                        OnCheckedChanged="IsLeafType_CheckedChanged" TextAlign="Right" />
                    <br />
                    <ui:UIGridView runat="server" ID="gridPoint" PropertyName="LocationTypePoints" Caption="Points"
                        KeyName="ObjectID" meta:resourcekey="gridPointResource1" Width="100%" 
                        PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" 
                        ImageRowErrorUrl="" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="DeleteObject" CommandText="Delete" 
                                ConfirmText="Are you sure you wish to delete the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                meta:resourceKey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                ConfirmText="Are you sure you wish to delete this item?" 
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" 
                                meta:resourceKey="UIGridViewColumnResource3" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                meta:resourceKey="UIGridViewColumnResource4" 
                                PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                SortExpression="UnitOfMeasure.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="IsIncreasingMeterText" 
                                HeaderText="Increasing Meter?" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" 
                                PropertyName="IsIncreasingMeterText" ResourceAssemblyName="" 
                                SortExpression="IsIncreasingMeterText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Factor" HeaderText="Factor" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Factor" 
                                ResourceAssemblyName="" SortExpression="Factor">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="MaximumReading" HeaderText="Maximum" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="MaximumReading" 
                                ResourceAssemblyName="" SortExpression="MaximumReading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="LocationTypePoints_Panel" 
                        meta:resourcekey="LocationTypePoints_PanelResource1" BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="LocationTypePoints_SubPanel" OnPopulateForm="LocationTypePoints_SubPanel_PopulateForm"
                            GridViewID="gridPoint" OnValidateAndUpdate="LocationTypePoints_SubPanel_ValidateAndUpdate" />
                        <ui:UIFieldTextBox runat="server" ID="LocationTypePoint_Name" PropertyName="ObjectName"
                            ValidateRequiredField="True" Caption="Point Name" Span="Half" ToolTip="The name of the point for this Location type."
                            MaxLength="255" meta:resourcekey="LocationTypePoint_NameResource1" 
                            InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDropDownList runat="server" ID="LocationTypePoint_UnitOfMeasureID" PropertyName="UnitOfMeasureID"
                            ValidateRequiredField="True" Caption="Unit of Measure" Span="Half" ToolTip="The unit of measure for the point."
                            meta:resourcekey="LocationTypePoint_UnitOfMeasureIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldCheckBox runat="server" ID="LocationTypePoint_IsIncreasingMeter" PropertyName="IsIncreasingMeter"
                            Caption="Increasing Meter?" Text="Yes, this is an meter whose reading increases in  value over time"
                            OnCheckedChanged="LocationTypePoint_IsIncreasingMeter_CheckedChanged" 
                            meta:resourcekey="LocationTypePoint_IsIncreasingMeterResource1" 
                            TextAlign="Right" />
                        <ui:UIPanel runat="server" ID="panelIncreasingMeter" BorderStyle="NotSet" 
                            meta:resourcekey="panelIncreasingMeterResource1">
                            <ui:UIFieldTextBox runat="server" ID="LocationTypePoint_ReadingMultiplicationFactor"
                                PropertyName="Factor" Span="Half" ValidateDataTypeCheck="True" ValidationDataType='Currency'
                                Caption="Multiplication Factor" ValidateRequiredField="True" 
                                InternalControlWidth="95%" 
                                meta:resourcekey="LocationTypePoint_ReadingMultiplicationFactorResource1" />
                            <ui:UIFieldTextBox runat="server" ID="LocationTypePoint_ReadingMaximum" PropertyName="MaximumReading"
                                Span="Half" ValidateDataTypeCheck="True" ValidationDataType='Currency' Caption="Maximum Reading"
                                ValidateRequiredField="True" InternalControlWidth="95%" 
                                meta:resourcekey="LocationTypePoint_ReadingMaximumResource1" />
                        </ui:UIPanel>
                        <ui:UISeparator Caption="Breach" runat="server" ID="sep1" 
                            meta:resourcekey="sep1Resource1" />
                        <ui:uifieldradiolist runat="server" ID="radioCreateWorkOnBreach" PropertyName="CreateWorkOnBreach"
                            Caption="Breach" CaptionWidth="150px" ValidateRequiredField="True" 
                            OnSelectedIndexChanged="radioCreateWorkOnBreach_SelectedIndexChanged" 
                            meta:resourcekey="radioCreateWorkOnBreachResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" Text="No action triggered when a breach occurs" 
                                    meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Create a Work when a breach occurs" 
                                    meta:resourcekey="ListItemResource2"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <ui:UIPanel runat="server" ID="panelBreach" BorderStyle="NotSet" 
                            meta:resourcekey="panelBreachResource1">
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr>
                                    <td style="width: 128px">
                                        <asp:Label runat="server" ID="labelAcceptableLimit" Text="Acceptable Limit: " 
                                            meta:resourcekey="labelAcceptableLimitResource1"></asp:Label>
                                    </td>
                                    <td>
                                        <ui:UIFieldTextBox runat="server" ID="textMinimumAcceptableReading" PropertyName="MinimumAcceptableReading"
                                            Caption="Minimum Acceptable Reading" Span="Half" CaptionWidth="180px" ValidateRequiredField="True"
                                            ShowCaption="False" FieldLayout="Flow" InternalControlWidth="80px" ValidateCompareField="True"
                                            ValidationCompareControl="textMaximumAcceptableReading" ValidationCompareType="Currency"
                                            ValidationCompareOperator="LessThanEqual" 
                                            meta:resourcekey="textMinimumAcceptableReadingResource1">
                                        </ui:UIFieldTextBox>
                                        <asp:Label runat="server" ID="labelAcceptableLimitTo" Text=" to " 
                                            meta:resourcekey="labelAcceptableLimitToResource1"></asp:Label>
                                        <ui:UIFieldTextBox runat="server" ID="textMaximumAcceptableReading" PropertyName="MaximumAcceptableReading"
                                            Caption="Maximum Acceptable Reading" Span="Half" CaptionWidth="180px" ValidateRequiredField="True"
                                            ShowCaption="False" FieldLayout="Flow" InternalControlWidth="80px" ValidateCompareField="True"
                                            ValidationCompareControl="textMinimumAcceptableReading" ValidationCompareType="Currency"
                                            ValidationCompareOperator="GreaterThanEqual" 
                                            meta:resourcekey="textMaximumAcceptableReadingResource1">
                                        </ui:UIFieldTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width: 128px">
                                        <asp:Label runat="server" ID="labelBreachCondition" Text="Create Work: " 
                                            meta:resourcekey="labelBreachConditionResource1"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="labelCreateWork" 
                                            Text="Create work only after readings breach the acceptable limit after" 
                                            meta:resourcekey="labelCreateWorkResource1"></asp:Label>
                                        <ui:UIFieldTextBox runat="server" ID="NumberOfBreachesToTriggerAction" PropertyName="NumberOfBreachesToTriggerAction"
                                            ShowCaption="False" FieldLayout="Flow" InternalControlWidth="" ValidateRequiredField="True"
                                            Caption="Number of Times Breached" ValidateRangeField="True" ValidationRangeType="Currency"
                                            ValidationRangeMin="1" 
                                            meta:resourcekey="NumberOfBreachesToTriggerActionResource1">
                                        </ui:UIFieldTextBox>
                                        <asp:Label runat="server" ID="labelAfterNumberOfTimes" Text="time(s)" 
                                            meta:resourcekey="labelAfterNumberOfTimesResource1"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <ui:UISeparator runat="server" ID="UISeparator1" Caption="Trigger" 
                                meta:resourcekey="UISeparator1Resource1" />
                            <ui:UIFieldTreeList runat="server" ID="TreeTrigger" Caption="Point Trigger" PropertyName="PointTriggerID"
                                OnAcquireTreePopulater="TreeTrigger_AcquireTreePopulater" 
                                OnSelectedNodeChanged="TreeTrigger_SelectedNodeChanged" 
                                meta:resourcekey="TreeTriggerResource1" ShowCheckBoxes="None" 
                                TreeValueMode="SelectedNode" />
                            <ui:UIPanel runat="server" ID="TriggerTemplate" Visible="False" 
                                BorderStyle="NotSet" meta:resourcekey="TriggerTemplateResource1">
                                <ui:UIFieldLabel runat="server" ID="lbWork" PropertyName="PointTrigger.TypeOfWorkText"
                                    Caption="Type of Work" DataFormatString="" 
                                    meta:resourcekey="lbWorkResource1">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbService" PropertyName="PointTrigger.TypeOfServiceText"
                                    Caption="Type of Service" DataFormatString="" 
                                    meta:resourcekey="lbServiceResource1">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbProblem" PropertyName="PointTrigger.TypeOfProblemText"
                                    Caption="Type of Problem" DataFormatString="" 
                                    meta:resourcekey="lbProblemResource1">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbPriority" PropertyName="PointTrigger.PriorityText"
                                    Caption="Priority" DataFormatString="" 
                                    meta:resourcekey="lbPriorityResource1">
                                </ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbDescription" PropertyName="PointTrigger.WorkDescription"
                                    Caption="Work Description" DataFormatString="" 
                                    meta:resourcekey="lbDescriptionResource1">
                                </ui:UIFieldLabel>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="TriggerManual" BorderStyle="NotSet" 
                                meta:resourcekey="TriggerManualResource1">
                                <ui:UIFieldDropDownList runat="server" ID="dropTypeOfWork" PropertyName="TypeOfWorkID"
                                    Caption="Type of Work" ValidateRequiredField="True" 
                                    OnSelectedIndexChanged="dropTypeOfWork_SelectedIndexChanged" 
                                    meta:resourcekey="dropTypeOfWorkResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropTypeOfService" PropertyName="TypeOfServiceID"
                                    Caption="Type of Service" ValidateRequiredField="True" 
                                    OnSelectedIndexChanged="dropTypeOfService_SelectedIndexChanged" 
                                    meta:resourcekey="dropTypeOfServiceResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropTypeOfProblem" PropertyName="TypeOfProblemID"
                                    Caption="Type of Problem" ValidateRequiredField="True" 
                                    meta:resourcekey="dropTypeOfProblemResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropPriority" PropertyName="Priority"
                                    Caption="Priority" ValidateRequiredField="True" 
                                    meta:resourcekey="dropPriorityResource1">
                                    <Items>
                                        <asp:ListItem Text="0" Value="0" meta:resourcekey="ListItemResource3"></asp:ListItem>
                                        <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource4"></asp:ListItem>
                                        <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource5"></asp:ListItem>
                                        <asp:ListItem Text="3" Value="3" meta:resourcekey="ListItemResource6"></asp:ListItem>
                                    </Items>
                                </ui:UIFieldDropDownList>
                                <ui:uifieldtextbox runat="server" ID="textWorkDescription" PropertyName="WorkDescription"
                                    Caption="Work Description" ValidateRequiredField="True" MaxLength="255" 
                                    InternalControlWidth="95%" meta:resourcekey="textWorkDescriptionResource1">
                                </ui:uifieldtextbox>
                            </ui:UIPanel>
                            <ui:UIHint runat="server" ID="hintWorkDescription" 
                                meta:resourcekey="hintWorkDescriptionResource1"><asp:Table runat="server" 
                                CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell 
                                        runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" 
                                        ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                        runat="server" VerticalAlign="Top"><asp:Label runat="server"> The work description describes the problem in greater detail. To include the reading that breached the limit as part of the description, use the special tag <b>{0}</b>. <br /><br />For example, <br />&nbsp; &nbsp; The aircon temperature (<b>{0}</b> deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. <br /><br />If the reading is 9 degrees Celsius and a work is triggered, the work description will be populated with the following description: <br />&nbsp; &nbsp; The aircon temperature (9 deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
                        </ui:UIPanel>
                        <br />
                        <br />
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:uitabview runat="server" id="tabUtility" Caption="Utilities" 
                    BorderStyle="NotSet" meta:resourcekey="tabUtilityResource1">
                    <ui:uigridview runat="server" id="gridUtilities" PropertyName="LocationTypeUtilities"
                        OnAction="gridUtilities_Action" 
                        OnRowDataBound="gridUtilities_RowDataBound" BindObjectsToRows="True" 
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                        meta:resourcekey="gridUtilitiesResource1" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="AddNewRow" CommandText="Add" ImageUrl="~/images/add.gif" 
                                meta:resourcekey="UIGridViewCommandResource3" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="RemoveObject" CommandText="Remove" 
                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource4" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                ConfirmText="Are you sure you wish to remove this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Utility Name" 
                                meta:resourcekey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textUtilityName" runat="server" Caption="Utility Name" 
                                        FieldLayout="Flow" InternalControlWidth="95%" 
                                        meta:resourcekey="textUtilityNameResource1" PropertyName="ObjectName" 
                                        ShowCaption="False" ValidateRequiredField="True">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Unit of Measure" 
                                meta:resourcekey="UIGridViewTemplateColumnResource2">
                                <ItemTemplate>
                                    <cc1:UIFieldDropDownList ID="dropUnitOfMeasure" runat="server" 
                                        Caption="Unit of Measure" FieldLayout="Flow" 
                                        meta:resourcekey="dropUnitOfMeasureResource1" PropertyName="UnitOfMeasureID" 
                                        ShowCaption="False" ValidateRequiredField="True">
                                    </cc1:UIFieldDropDownList>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:uigridview>
                    <ui:uiobjectpanel runat="server" id="panelUtility" BorderStyle="NotSet" 
                        meta:resourcekey="panelUtilityResource1">
                        <web:subpanel runat="server" id="subpanelUtility" GridViewID="gridUtilities" />
                    </ui:uiobjectpanel>
                </ui:uitabview>
                <ui:UITabView runat="server" ID="uiTabview5" Caption="Attributes" 
                    BorderStyle="NotSet" meta:resourcekey="uiTabview5Resource1">
                    <web:attribute ID="attribute1" runat="server" AttachedObjectName="tLocation" TabViewID="attributeTabView"
                        AttachedPropertyName="LocationTypeID"></web:attribute>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" 
                    meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                    meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
