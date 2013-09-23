<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        gridPoint.Visible = IsLeafType.Checked;
        panelIncreasingMeter.Visible = EquipmentTypePoint_IsIncreasingMeter.Checked;
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
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OEquipmentType EquipmentType = panel.SessionObject as OEquipmentType;

        if (Request["TREEOBJID"] != null && TablesLogic.tEquipmentType[Security.DecryptGuid(Request["TREEOBJID"])] != null)
        {
            EquipmentType.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);

            if (EquipmentType.Parent != null && EquipmentType.Parent.IsLeafType == 1)
                EquipmentType.ParentID = null;
        }

        ParentID.Enabled = EquipmentType.IsNew || EquipmentType.ParentID != null;
        
        ParentID.PopulateTree();
        IsLeafType.Enabled = EquipmentType.IsNew;

        panel.ObjectPanel.BindObjectToControls(EquipmentType);
    }

    /// <summary>
    /// Validates and saves the equipment type object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OEquipmentType EquipmentType = (OEquipmentType)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(EquipmentType);

            // Validate
            //
            if (EquipmentType.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (EquipmentType.IsCyclicalReference())
                ParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            EquipmentType.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Constructs and returns the equipment type tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new EquipmentTypeTreePopulater(panel.SessionObject.ParentID, false);
    }

    /// <summary>
    /// Binds data to the unit of measure drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentTypePoints_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OEquipmentTypePoint equipmentTypePoint =
            EquipmentTypePoints_SubPanel.SessionObject as OEquipmentTypePoint;
        
        EquipmentTypePoint_UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", equipmentTypePoint.UnitOfMeasureID));

        // Bind the type of work/services/problem
        // drop down lists.
        //
        dropTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", equipmentTypePoint.TypeOfWorkID));
        dropTypeOfService.Bind(OCode.GetCodesByParentID(equipmentTypePoint.TypeOfWorkID, equipmentTypePoint.TypeOfServiceID));
        dropTypeOfProblem.Bind(OCode.GetCodesByParentID(equipmentTypePoint.TypeOfServiceID, equipmentTypePoint.TypeOfProblemID));

        // Update the priority's text
        //
        dropPriority.Items[0].Text = Resources.Strings.Priority_0;
        dropPriority.Items[1].Text = Resources.Strings.Priority_1;
        dropPriority.Items[2].Text = Resources.Strings.Priority_2;
        dropPriority.Items[3].Text = Resources.Strings.Priority_3;

        TreeTrigger.PopulateTree();
        EquipmentTypePoints_SubPanel.ObjectPanel.BindObjectToControls(equipmentTypePoint);
        
        
    }


    /// <summary>
    /// Adds/updates the equipment type point.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentTypePoints_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OEquipmentType equipmentType = panel.SessionObject as OEquipmentType;
        panel.ObjectPanel.BindControlsToObject(equipmentType);
        
        OEquipmentTypePoint equipmentTypePoint =
            EquipmentTypePoints_SubPanel.SessionObject as OEquipmentTypePoint;
        EquipmentTypePoints_SubPanel.ObjectPanel.BindControlsToObject(equipmentTypePoint);

        // Other updates
        //
        if (equipmentTypePoint.IsIncreasingMeter == 0)
        {
            equipmentTypePoint.MaximumReading = null;
            equipmentTypePoint.Factor = null;
        }

        if (equipmentTypePoint.PointTriggerID != null)
        {
            equipmentTypePoint.TypeOfWorkID = null;
            equipmentTypePoint.TypeOfServiceID = null;
            equipmentTypePoint.TypeOfProblemID = null;
            equipmentTypePoint.Priority = 0;
            equipmentTypePoint.WorkDescription = "";
        }

        
        equipmentType.EquipmentTypePoints.Add(equipmentTypePoint);
        
        panel.ObjectPanel.BindObjectToControls(equipmentType);

    }
    
    /// <summary>
    /// Constructs and returns the catalogue tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater EquipmentTypeSpares_CatalogueID_AcquireTreePopulater(object sender)
    {
        OEquipmentTypeSpare spare = (OEquipmentTypeSpare)EquipmentTypeSpares_SubPanel.SessionObject;
        return new CatalogueTreePopulater(spare.CatalogueID, true, true);
    }

    
    /// <summary>
    /// Occurs when user clicks on the equipment type spares tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentTypeSpares_CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OEquipmentTypeSpare spare = (OEquipmentTypeSpare)EquipmentTypeSpares_SubPanel.SessionObject;

        EquipmentTypeSpares_Panel.BindControlsToObject(spare);
    }

    
    

    /// <summary>
    /// Populates the equipment type spares sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void EquipmentTypeSpares_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OEquipmentTypeSpare equipmentTypeSpare = 
            EquipmentTypeSpares_SubPanel.SessionObject as OEquipmentTypeSpare;
        
        EquipmentTypeSpares_CatalogueID.PopulateTree();

        EquipmentTypeSpares_SubPanel.ObjectPanel.BindObjectToControls(equipmentTypeSpare);
    }


    /// <summary>
    /// Adds/updates the equipment type spares.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentTypeSpares_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OEquipmentType equipmentType = panel.SessionObject as OEquipmentType;
        panel.ObjectPanel.BindControlsToObject(equipmentType);

        OEquipmentTypeSpare equipmentTypeSpare =
            EquipmentTypeSpares_SubPanel.SessionObject as OEquipmentTypeSpare;
        EquipmentTypeSpares_SubPanel.ObjectPanel.BindControlsToObject(equipmentTypeSpare);

        // Validate
        //
        if (equipmentType.HasDuplicateSpares(equipmentTypeSpare))
            EquipmentTypeSpares_CatalogueID.ErrorMessage = Resources.Errors.EquipmentTypeSpares_DuplicateItem;
        if (!EquipmentTypeSpares_SubPanel.ObjectPanel.IsValid)
            return;
        
        // Add an bind to the UI.
        //        
        equipmentType.EquipmentTypeSpares.Add(equipmentTypeSpare);
        panel.ObjectPanel.BindObjectToControls(equipmentType);
    }
        

    /// <summary>
    /// Occurs when user clicks on the check box.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsLeafType_CheckedChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Occurs when user clicks on the check box.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentTypePoint_IsIncreasingMeter_CheckedChanged(object sender, EventArgs e)
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
        OEquipmentTypePoint pt = (OEquipmentTypePoint)EquipmentTypePoints_SubPanel.SessionObject;
        return new PointTriggerTreePopulater(pt.PointTriggerID, false, true,
            Security.Decrypt(Request["TYPE"]));

    }
    protected void TreeTrigger_SelectedNodeChanged(object sender, EventArgs e)
    {
        OEquipmentTypePoint pt = (OEquipmentTypePoint)EquipmentTypePoints_SubPanel.SessionObject;
        EquipmentTypePoints_SubPanel.ObjectPanel.BindControlsToObject(pt);
        EquipmentTypePoints_SubPanel.ObjectPanel.BindObjectToControls(pt);
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
            <web:object runat="server" ID="panel" Caption="Equipment Type" BaseTable="tEquipmentType"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" 
                            Caption="Belongs Under" ValidateRequiredField="True"
                            OnAcquireTreePopulater="ParentID_AcquireTreePopulater" ToolTip="The group or equipment type under which this belongs to."
                            meta:resourcekey="ParentIDResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode" />
                    <ui:uifieldtextbox id="textRunningNumberCode" runat="server" caption="Running Number Code" internalcontrolwidth="95%" meta:resourcekey="textRunningNumberCodeResource1" propertyname="RunningNumberCode">
                    </ui:uifieldtextbox>
                        <ui:UIFieldCheckBox runat="server" ID="IsLeafType" PropertyName="IsLeafType" Caption="Equipment Type"
                            Text="Yes, this is a equipment type" ToolTip="Indicates if this is an equipment type or a group."
                            meta:resourcekey="IsLeafTypeResource1" 
                            OnCheckedChanged="IsLeafType_CheckedChanged" TextAlign="Right" />
                        <br />
                        <ui:UIGridView runat="server" ID="gridPoint" PropertyName="EquipmentTypePoints"
                            Caption="Points" KeyName="ObjectID" meta:resourcekey="gridPointResource1"
                            Width="100%" PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" 
                            RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
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
                        <ui:UIObjectPanel runat="server" ID="EquipmentTypePoints_Panel" 
                            meta:resourcekey="EquipmentTypePoints_PanelResource1" BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="EquipmentTypePoints_SubPanel" OnPopulateForm="EquipmentTypePoints_SubPanel_PopulateForm"
                                GridViewID="gridPoint" OnValidateAndUpdate="EquipmentTypePoints_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTextBox runat="server" ID="EquipmentTypePoint_Name" PropertyName="ObjectName"
                                ValidateRequiredField="True" Caption="Point Name" Span="Half" ToolTip="The name of the point for this equipment type."
                                MaxLength="255" meta:resourcekey="EquipmentTypePoint_NameResource1" 
                                InternalControlWidth="95%"></ui:UIFieldTextBox>
                            <ui:UIFieldDropDownList runat="server" ID="EquipmentTypePoint_UnitOfMeasureID"
                                PropertyName="UnitOfMeasureID" ValidateRequiredField="True" Caption="Unit of Measure"
                                Span="Half" ToolTip="The unit of measure for the point." meta:resourcekey="EquipmentTypePoint_UnitOfMeasureIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldCheckBox runat="server" ID="EquipmentTypePoint_IsIncreasingMeter"
                                PropertyName="IsIncreasingMeter" Caption="Increasing Meter?" 
                                Text="Yes, this is an meter whose reading increases in  value over time" 
                                OnCheckedChanged="EquipmentTypePoint_IsIncreasingMeter_CheckedChanged" 
                                meta:resourcekey="EquipmentTypePoint_IsIncreasingMeterResource1" 
                                TextAlign="Right" />
                            <ui:UIPanel runat="server" ID="panelIncreasingMeter" BorderStyle="NotSet" 
                                meta:resourcekey="panelIncreasingMeterResource1">
                                <ui:UIFieldTextBox runat="server" ID="EquipmentTypePoint_ReadingMultiplicationFactor"
                                    PropertyName="Factor" Span="Half" ValidateDataTypeCheck="True"
                                    ValidationDataType='Currency' Caption="Multiplication Factor" 
                                    ValidateRequiredField="True" InternalControlWidth="95%" 
                                    meta:resourcekey="EquipmentTypePoint_ReadingMultiplicationFactorResource1" />
                                <ui:UIFieldTextBox runat="server" ID="EquipmentTypePoint_ReadingMaximum" PropertyName="MaximumReading"
                                    Span="Half" ValidateDataTypeCheck="True" ValidationDataType='Currency' Caption="Maximum Reading"
                                    ValidateRequiredField="True" InternalControlWidth="95%" 
                                    meta:resourcekey="EquipmentTypePoint_ReadingMaximumResource1" />
                            </ui:UIPanel>
                            <ui:UISeparator Caption="Breach" runat="server" ID="sep1" 
                                meta:resourcekey="sep1Resource1" />
                            <ui:uifieldradiolist runat="server" ID="radioCreateWorkOnBreach" 
                                PropertyName="CreateWorkOnBreach" Caption="Breach"  CaptionWidth="150px" 
                                 ValidateRequiredField="True" 
                                OnSelectedIndexChanged="radioCreateWorkOnBreach_SelectedIndexChanged" 
                                meta:resourcekey="radioCreateWorkOnBreachResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" Text="No action triggered when a breach occurs" 
                                        meta:resourcekey="ListItemResource1"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Create a Work when a breach occurs" 
                                        meta:resourcekey="ListItemResource2"></asp:ListItem>
                                </Items>
                            </ui:uifieldradiolist>
                            <ui:UIPanel  runat="server" ID="panelBreach" BorderStyle="NotSet" 
                                meta:resourcekey="panelBreachResource1">
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
                                        meta:resourcekey="textMinimumAcceptableReadingResource1"></ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelAcceptableLimitTo" Text=" to " 
                                        meta:resourcekey="labelAcceptableLimitToResource1"></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textMaximumAcceptableReading" 
                                        PropertyName="MaximumAcceptableReading" Caption="Maximum Acceptable Reading" 
                                        Span="Half" CaptionWidth="180px" ValidateRequiredField="True" 
                                        ShowCaption="False" FieldLayout="Flow" InternalControlWidth="80px" 
                                        ValidateCompareField="True" 
                                        ValidationCompareControl="textMinimumAcceptableReading" 
                                        ValidationCompareType="Currency" ValidationCompareOperator="GreaterThanEqual" 
                                        meta:resourcekey="textMaximumAcceptableReadingResource1"></ui:UIFieldTextBox>
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
                                    <ui:UIFieldTextBox runat="server" ID="NumberOfBreachesToTriggerAction" 
                                        PropertyName="NumberOfBreachesToTriggerAction" ShowCaption="False" 
                                        FieldLayout="Flow" InternalControlWidth="" ValidateRequiredField="True" Caption="Number of Times Breached"
                                     ValidateRangeField="True" ValidationRangeType="Currency" 
                                        ValidationRangeMin="1" meta:resourcekey="NumberOfBreachesToTriggerActionResource1"
                                    ></ui:UIFieldTextBox>
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
                               
                                <ui:UIFieldLabel runat="server" ID="lbWork" 
                                    PropertyName="PointTrigger.TypeOfWorkText" Caption="Type of Work" 
                                    DataFormatString="" meta:resourcekey="lbWorkResource1" ></ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbService" 
                                    PropertyName="PointTrigger.TypeOfServiceText" Caption="Type of Service" 
                                    DataFormatString="" meta:resourcekey="lbServiceResource1" > </ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbProblem" 
                                    PropertyName="PointTrigger.TypeOfProblemText" Caption="Type of Problem" 
                                    DataFormatString="" meta:resourcekey="lbProblemResource1" ></ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbPriority" 
                                    PropertyName="PointTrigger.PriorityText" Caption="Priority" DataFormatString="" 
                                    meta:resourcekey="lbPriorityResource1" ></ui:UIFieldLabel>
                                <ui:UIFieldLabel runat="server" ID="lbDescription" 
                                    PropertyName="PointTrigger.WorkDescription" Caption="Work Description" 
                                    DataFormatString="" meta:resourcekey="lbDescriptionResource1"  ></ui:UIFieldLabel>
                              
                            </ui:UIPanel>
                            <ui:UIPanel runat=server ID="TriggerManual" BorderStyle="NotSet" 
                                    meta:resourcekey="TriggerManualResource1">
                           
                                <ui:UIFieldDropDownList runat="server" ID="dropTypeOfWork" 
                                    PropertyName="TypeOfWorkID" Caption="Type of Work" ValidateRequiredField="True" 
                                    OnSelectedIndexChanged="dropTypeOfWork_SelectedIndexChanged" 
                                    meta:resourcekey="dropTypeOfWorkResource1"></ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropTypeOfService" 
                                    PropertyName="TypeOfServiceID" Caption="Type of Service" 
                                    ValidateRequiredField="True" 
                                    OnSelectedIndexChanged="dropTypeOfService_SelectedIndexChanged" 
                                    meta:resourcekey="dropTypeOfServiceResource1"></ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropTypeOfProblem" 
                                    PropertyName="TypeOfProblemID" Caption="Type of Problem" 
                                    ValidateRequiredField="True" meta:resourcekey="dropTypeOfProblemResource1"></ui:UIFieldDropDownList>
                                <ui:UIFieldDropDownList runat="server" ID="dropPriority" 
                                    PropertyName="Priority" Caption="Priority" ValidateRequiredField="True" 
                                    meta:resourcekey="dropPriorityResource1">
                                    <Items>
                                        <asp:ListItem Text="0" Value="0" meta:resourcekey="ListItemResource3"></asp:ListItem>
                                        <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource4"></asp:ListItem>
                                        <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource5"></asp:ListItem>
                                        <asp:ListItem Text="3" Value="3" meta:resourcekey="ListItemResource6"></asp:ListItem>
                                    </Items>
                                </ui:UIFieldDropDownList>
                                <ui:uifieldtextbox runat="server" ID="textWorkDescription" 
                                    PropertyName="WorkDescription" Caption="Work Description" 
                                    ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" 
                                    meta:resourcekey="textWorkDescriptionResource1"></ui:uifieldtextbox>
                            </ui:UIPanel>
                        <ui:UIHint runat="server" ID="hintWorkDescription" 
                                    meta:resourcekey="hintWorkDescriptionResource1" Text=""><asp:Table runat="server" 
                                    CellPadding="4" CellSpacing="0" Width="100%" meta:resourcekey="TableResource1"><asp:TableRow runat="server" meta:resourcekey="TableRowResource1"><asp:TableCell 
                                            runat="server" VerticalAlign="Top" Width="16px" meta:resourcekey="TableCellResource1"><asp:Image runat="server" 
                                            ImageUrl="~/images/information.gif" meta:resourcekey="ImageResource1" />
</asp:TableCell>
<asp:TableCell runat="server" VerticalAlign="Top" meta:resourcekey="TableCellResource2"><asp:Label 
                                    runat="server" meta:resourcekey="LabelResource1" 
                                    Text=" The work description describes the problem in greater detail. To include the reading that breached the limit as part of the description, use the special tag &lt;b 
                                    __designer:mapid=&quot;352&quot;&gt;{0}&lt;/b&gt;. &lt;br __designer:mapid=&quot;353&quot; /&gt;&lt;br 
                                    __designer:mapid=&quot;354&quot; /&gt;For example, &lt;br __designer:mapid=&quot;355&quot; /&gt;&amp;#160; &amp;#160; The aircon temperature (&lt;b 
                                    __designer:mapid=&quot;356&quot;&gt;{0}&lt;/b&gt; deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. &lt;br 
                                    __designer:mapid=&quot;357&quot; /&gt;&lt;br __designer:mapid=&quot;358&quot; /&gt;If the reading is 9 degrees Celsius and a work is triggered, the work description will be populated with the following description: &lt;br 
                                    __designer:mapid=&quot;359&quot; /&gt;&amp;#160; &amp;#160; The aircon temperature (9 deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. "></asp:Label>
</asp:TableCell>
</asp:TableRow>
</asp:Table>
</ui:UIHint>
                            </ui:UIPanel>
                            <br />
                            <br />
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview5" Caption="Spares" 
                        meta:resourcekey="uitabview5Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridSpares" PropertyName="EquipmentTypeSpares"
                            Caption="Equipment Type Spares" Width="100%"
                            KeyName="ObjectID" meta:resourcekey="gridSparesResource1" 
                            PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" 
                            RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource3" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                    meta:resourceKey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource8">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource9">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.ObjectName" 
                                    HeaderText="Catalog" meta:resourceKey="UIGridViewColumnResource10" 
                                    PropertyName="Catalogue.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Catalogue.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Catalogue.UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of Measure" meta:resourceKey="UIGridViewColumnResource11" 
                                    PropertyName="Catalogue.UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Catalogue.UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Quantity" 
                                    DataFormatString="{0:#,##0.00##}" HeaderText="Quantity" 
                                    meta:resourceKey="UIGridViewColumnResource12" PropertyName="Quantity" 
                                    ResourceAssemblyName="" SortExpression="Quantity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="EquipmentTypeSpares_Panel" 
                            meta:resourcekey="EquipmentTypeSpares_PanelResource1" BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="EquipmentTypeSpares_SubPanel" GridViewID="gridSpares"
                                OnPopulateForm="EquipmentTypeSpares_SubPanel_PopulateForm" OnValidateAndUpdate="EquipmentTypeSpares_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTreeList runat="server" ID="EquipmentTypeSpares_CatalogueID" PropertyName="CatalogueID"
                                Caption="Catalog Item" ValidateRequiredField="True" OnAcquireTreePopulater="EquipmentTypeSpares_CatalogueID_AcquireTreePopulater"
                                ToolTip="Catalog item for the spares" OnSelectedNodeChanged="EquipmentTypeSpares_CatalogueID_SelectedNodeChanged"
                                meta:resourcekey="EquipmentTypeSpares_CatalogueIDResource1" 
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldLabel Caption="Unit of Measure" ID="EquipmentTypeSpares_UnitOfMeasure"
                                runat="server" PropertyName="Catalogue.UnitOfMeasure.ObjectName" 
                                meta:resourcekey="EquipmentTypeSpares_UnitOfMeasureResource1" 
                                DataFormatString="" />
                            <ui:UIFieldTextBox runat="server" ID="EquipmentTypeSpares_Quantity" PropertyName="Quantity"
                                Span="Half" ValidateRequiredField="True" ValidationDataType="Currency" Caption="Quantity"
                                ToolTip="Quantity to check-in." 
                                meta:resourcekey="EquipmentTypeSpares_QuantityResource1" 
                                InternalControlWidth="95%" />
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Equipment" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="Equipment" PropertyName="Equipment" Caption="Equipment"
                            KeyName="ObjectID" meta:resourcekey="EquipmentResource1" Width="100%" 
                            PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" 
                            RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Equipment Name" 
                                    meta:resourceKey="UIGridViewColumnResource5" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ModelNumber" HeaderText="Model Number" 
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="ModelNumber" 
                                    ResourceAssemblyName="" SortExpression="ModelNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="SerialNumber" HeaderText="Serial Number" 
                                    meta:resourceKey="UIGridViewColumnResource7" PropertyName="SerialNumber" 
                                    ResourceAssemblyName="" SortExpression="SerialNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uiTabview6" Caption="Attributes" 
                        meta:resourcekey="uiTabview6Resource1" BorderStyle="NotSet">
                        <web:attribute ID="attribute1" runat="server" AttachedObjectName="tEquipment" TabViewID="attributeTabView"
                            AttachedPropertyName="EquipmentTypeID"></web:attribute>
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
