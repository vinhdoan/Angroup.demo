<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" ValidateRequest="false"
    Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        DashboardRoles.Bind(OUser.GetRoles(), "RoleName", "ObjectID");

        ODashboard dashboard = (ODashboard)panel.SessionObject;
        framePreview.Attributes["src"] = "preview.aspx?ID=" + HttpUtility.UrlEncode(Security.EncryptGuid(dashboard.ObjectID.Value));

        panel.ObjectPanel.BindObjectToControls(dashboard);
    }


    /// <summary>
    /// Validates and saves the dashboard object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            ODashboard dashboard = (ODashboard)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(dashboard);

            // Validate
            //
            if (dashboard.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            dashboard.Save();
            tabPreview.Update();

            c.Commit();
        }
    }


    /// <summary>
    /// Occurs when the user checks or unchecks Auto Calibrate checkout.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsAutoCalibrate_CheckedChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Occurs when the user checks/unchecks the Show Dropdown List checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsDropDownAvailable_CheckedChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user checks/unchecks the Populate with Query? checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsPopulatedByQuery_CheckedChanged(object sender, EventArgs e)
    {

    }



    /// <summary>
    /// Occurs when the user selects an item in the Use C# radiobutton list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void UseCSharpQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Hides/shows and enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        int dashboardType = Convert.ToInt32(dropDashboardType.SelectedValue);

        checkDashboard3D.Visible =
            dashboardType == DashboardType.Pie ||
            dashboardType == DashboardType.Basic ||
            dashboardType == DashboardType.Scatter;
        dropDashboardShowHorizontal.Visible =
            dashboardType == DashboardType.Basic;

        dropDashboardPieType.Visible = dashboardType == DashboardType.Pie;
        dropDashboardSeriesType.Visible =
            dashboardType == DashboardType.Basic ||
            dashboardType == DashboardType.Polar ||
            dashboardType == DashboardType.Radar ||
            dashboardType == DashboardType.Scatter;

        panelScale.Visible = dashboardType == DashboardType.Gauge;
        panelChartParameters.Visible = dashboardType != DashboardType.Grid;
        panelBubbleSize.Visible = dashboardType == DashboardType.Bubble;

        dropXAxisType.Visible =
            dropYAxisType.Visible =
            textXAxisLabelText.Visible =
            textYAxisLabelText.Visible =
                dashboardType != DashboardType.Gauge &&
                dashboardType != DashboardType.Pie;

        panelManualScale.Visible = !IsAutoCalibrate.Checked;
        tabPreview.Visible = !panel.SessionObject.IsNew;

        textSeriesColumnName.Visible = radioSeriesByColumns.SelectedValue != "1";
        textYAxisColumnName.Visible = radioSeriesByColumns.SelectedValue != "1";

        DashboardQuery.Visible = UseCSharpQuery.SelectedValue == ((int)EnumApplicationGeneral.No).ToString();
        CSharpMethodName.Visible = UseCSharpQuery.SelectedValue == ((int)EnumApplicationGeneral.Yes).ToString();

        panelPopulatedByQuery.Visible = IsPopulatedByQuery.SelectedValue == ((int)EnumReportFieldPopulateWith.Query).ToString() || 
            IsPopulatedByQuery.SelectedValue == ((int)EnumReportFieldPopulateWith.CSharpMethod).ToString();
        ListQuery.Visible = IsPopulatedByQuery.SelectedValue == ((int)EnumReportFieldPopulateWith.Query).ToString();
        panelNotPopulatedByQuery.Visible = IsPopulatedByQuery.SelectedValue == ((int)EnumReportFieldPopulateWith.ListCommaSeperator).ToString();
        ReportFieldCMethod.Visible = IsPopulatedByQuery.SelectedValue == ((int)EnumReportFieldPopulateWith.CSharpMethod).ToString();

    }


    /// <summary>
    /// Occurs when the user selects an item in the Dashboard Type dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropDashboardType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Populates the report field subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelDashboardField_PopulateForm(object sender, EventArgs e)
    {
        ODashboard dashboard = panel.SessionObject as ODashboard;
        ODashboardField dashboardField = subpanelDashboardField.SessionObject as ODashboardField;

        DisplayOrder.Items.Clear();
        for (int i = 0; i < dashboard.DashboardFields.Count + 1; i++)
            DisplayOrder.Items.Add(new ListItem((i + 1).ToString(), (i + 1).ToString()));

        CascadeControlID.Bind(dashboard.GetDropDownDashboardFields(dashboardField.ControlIdentifier), "ControlCaption", "ObjectID");
        DataType.Bind(OReportField.GetReportDataTypeTable(), "Name", "Value");
        ControlType.Bind(OReportField.GetReportControlTypeTable(), "Name", "Value");
        if (dashboardField.DisplayOrder == null)
            dashboardField.DisplayOrder = DisplayOrder.Items.Count;

        subpanelDashboardField.ObjectPanel.BindObjectToControls(dashboardField);
    }


    /// <summary>
    /// Occurs when the user clicks on the remove button to remove
    /// report fields.
    /// </summary>
    /// <param name="sneder"></param>
    /// <param name="e"></param>
    protected void subpanelDashboardField_Removed(object sneder, EventArgs e)
    {
        ODashboard dashboard = panel.SessionObject as ODashboard;
        tabDetails.BindControlsToObject(dashboard);
        LogicLayer.Global.ReorderItems(dashboard.DashboardFields, null, "DisplayOrder");
        tabDetails.BindObjectToControls(dashboard);
    }


    /// <summary>
    /// Validates and inserts the report field object into the report object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelDashboardField_ValidateAndUpdate(object sender, EventArgs e)
    {
        ODashboard dashboard = panel.SessionObject as ODashboard;
        tabDetails.BindControlsToObject(dashboard);

        ODashboardField dashboardField = subpanelDashboardField.SessionObject as ODashboardField;
        subpanelDashboardField.ObjectPanel.BindControlsToObject(dashboardField);

        // Validate
        //
        if (dashboardField.ControlIdentifier.Contains(" "))
            ControlIdentifier.ErrorMessage = Resources.Errors.Report_IdentifierHasSpaces;
        if (dashboardField.ControlIdentifier.Contains(","))
            ControlIdentifier.ErrorMessage = Resources.Errors.Report_IdentifierHasComma;
        if (dashboard.CascadeHasLoops())
        {
            CascadeControlID.ErrorMessage = Resources.Errors.Report_CascadeControlLoop;
            dashboardField.CascadeControl.Clear();
        }
        if (!dashboard.ValidateNoDuplicateIdentifiers(dashboardField))
            ControlIdentifier.ErrorMessage = Resources.Errors.Dashboard_DuplicateIdentifier;
        if (!subpanelDashboardField.ObjectPanel.IsValid)
            return;

        // Insert
        //
        dashboard.DashboardFields.Add(dashboardField);
        tabDetails.BindObjectToControls(dashboard);

        // Update
        LogicLayer.Global.ReorderItems(dashboard.DashboardFields, dashboardField, "DisplayOrder");
    }


    /// <summary>
    /// Occurs when the populated by query checkbox changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsPopulatedByQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
    }

    
    /// <summary>
    /// Occurs when the series mode changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioSeriesByColumns_SelectedIndexChanged(object sender, EventArgs e)
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
        <web:object runat="server" ID="panel" Caption="Dashboard" BaseTable="tDashboard"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" 
                meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Dashboard Name"
                        ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIGridView ID="gridDashboardFields" runat="server" Caption="Filter Fields" PropertyName="DashboardFields"
                        SortExpression="DisplayOrder" KeyName="ObjectID" Width="100%" 
                        PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" 
                        ImageRowErrorUrl="" meta:resourcekey="gridDashboardFieldsResource1" 
                        RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="RemoveObject" CommandText="Delete" 
                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                ConfirmText="Are you sure you wish to remove this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="DisplayOrder" HeaderText="Display Order" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="DisplayOrder" 
                                ResourceAssemblyName="" SortExpression="DisplayOrder">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ControlCaption" 
                                HeaderText="Control Caption" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                PropertyName="ControlCaption" ResourceAssemblyName="" 
                                SortExpression="ControlCaption">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ControlIdentifier" 
                                HeaderText="Control Identifier" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" 
                                PropertyName="ControlIdentifier" ResourceAssemblyName="" 
                                SortExpression="ControlIdentifier">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="panelDashboardField" runat="server" BorderStyle="NotSet" 
                        meta:resourcekey="panelDashboardFieldResource1" >
                        <web:subpanel runat="server" ID="subpanelDashboardField" GridViewID="gridDashboardFields"
                            OnPopulateForm="subpanelDashboardField_PopulateForm" OnRemoved="subpanelDashboardField_Removed"
                            OnValidateAndUpdate="subpanelDashboardField_ValidateAndUpdate"></web:subpanel>
                        <ui:UIFieldDropDownList ID="DisplayOrder" runat="server" Caption="Display Order"
                            PropertyName="DisplayOrder" Span="Half" ValidateRequiredField="True" 
                            ToolTip="The order of display of the search field. Lower appears first." 
                            meta:resourcekey="DisplayOrderResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="ControlIdentifier" runat="server" Caption="Identifier" PropertyName="ControlIdentifier"
                            ValidateRequiredField="True" 
                            ToolTip="The identifier that can be used in the SQL query to perform a filter." 
                            InternalControlWidth="95%" meta:resourcekey="ControlIdentifierResource1" />
                        <ui:UIFieldTextBox runat="server" ID="textControlCaption" Caption="Control Caption"
                            PropertyName="ControlCaption" InternalControlWidth="95%" 
                            meta:resourcekey="textControlCaptionResource1" />
                        <ui:UIFieldDropDownList ID="ControlType" runat="server" Caption="Control Type" PropertyName="ControlType"
                            Span="Half" ValidateRequiredField="True" 
                            ToolTip="The type of the control that the user inputs." 
                            meta:resourcekey="ControlTypeResource1" >
                            <%--<Items>
                                <asp:ListItem Value="2" Text="DropDownList" 
                                    meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem Value="3" Text="RadioButtonList" 
                                    meta:resourcekey="ListItemResource2"></asp:ListItem>
                            </Items>--%>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList ID="DataType" runat="server" Caption="Data Type" PropertyName="DataType"
                            Span="Half" ValidateRequiredField="True" 
                            ToolTip="The data type of the search field." 
                            meta:resourcekey="DataTypeResource1">
                            <%--<Items>
                                <asp:ListItem Selected="True" Value="0" Text="String" 
                                    meta:resourcekey="ListItemResource3"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Integer" meta:resourcekey="ListItemResource4"></asp:ListItem>
                                <asp:ListItem Value="2" Text="Decimal" meta:resourcekey="ListItemResource5"></asp:ListItem>
                                <asp:ListItem Value="3" Text="Double" meta:resourcekey="ListItemResource6"></asp:ListItem>
                                <asp:ListItem Value="4" Text="DateTime" meta:resourcekey="ListItemResource7"></asp:ListItem>
                                <asp:ListItem Value="5" Text="Object Identifier" 
                                    meta:resourcekey="ListItemResource8"></asp:ListItem>
                            </Items>--%>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldListBox runat="server" ID="CascadeControlID" PropertyName="CascadeControl"
                            Caption="Cascading Control" Span="Half" 
                            ToolTip="Indicates the dropdown list control that is updated if this dropdown list changes." 
                            meta:resourcekey="CascadeControlIDResource1"></ui:UIFieldListBox>
                        <br />
                        <ui:UIPanel ID="panelListQuery" runat="server" BorderStyle="NotSet" 
                            meta:resourcekey="panelListQueryResource1" >
                            <ui:UISeparator runat="server" ID="UISeparator4" Caption="List Query" 
                                meta:resourcekey="UISeparator4Resource1" />
                            <ui:UIFieldRadioList ID="IsPopulatedByQuery" runat="server" Caption="Populate with Query?"
                                PropertyName="IsPopulatedByQuery" 
                                ToolTip="Indicates if the dropdown list should be populated with a query, or populated with a list of comma-separated values."
                                OnSelectedIndexChanged="IsPopulatedByQuery_SelectedIndexChanged" 
                                meta:resourcekey="IsPopulatedByQueryResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource9">Populate with a List of Comma-separated values</asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource10">Populate with a query</asp:ListItem>
                                    <asp:ListItem Value="2" meta:resourcekey="ListItemResource11">Populate with a C# Method</asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldTextBox runat="server" ID="ReportFieldCMethod" ValidateRequiredField="True"
                                Caption="C# Method" PropertyName="CSharpMethodName" 
                                InternalControlWidth="95%" meta:resourcekey="ReportFieldCMethodResource1" />
                            <ui:UIPanel ID="panelNotPopulatedByQuery" runat="server" BorderStyle="NotSet" 
                                meta:resourcekey="panelNotPopulatedByQueryResource1" >
                                <ui:UIFieldTextBox ID="TextList" runat="server" Caption="Text List" PropertyName="TextList"
                                    ValidateRequiredField="True" ToolTip="A comma separated list of text that will appear to the user for selection"
                                    MaxLength="0" InternalControlWidth="95%" 
                                    meta:resourcekey="TextListResource1" />
                                <ui:UIFieldTextBox ID="ValueList" PropertyName="ValueList" runat="server" Caption="Value List"
                                    ToolTip="The comma separated list of values that corresponds to the text list."
                                    MaxLength="0" ValidateRequiredField="True" InternalControlWidth="95%" 
                                    meta:resourcekey="ValueListResource1" />
                            </ui:UIPanel>
                            <ui:UIPanel ID="panelPopulatedByQuery" runat="server" BorderStyle="NotSet" 
                                meta:resourcekey="panelPopulatedByQueryResource1" >
                                <ui:UIFieldTextBox ID="ListQuery" runat="server" Caption="List SQL" PropertyName="ListQuery"
                                    Rows="15" TextMode="MultiLine" ValidateRequiredField="True" MaxLength="0" 
                                    ToolTip="The query in SQL that is used to populate the dropdown list. The default {TreeviewID}, {TreeviewObject}, {UserID} are default fields available for the SQL query." 
                                    InternalControlWidth="95%" meta:resourcekey="ListQueryResource2"/>
                                <ui:UIFieldTextBox ID="DataValueField" runat="server" Caption="Data Value Field"
                                    PropertyName="DataValueField" ValidateRequiredField="True" Span="Half" 
                                    ToolTip="The column of the result of the query that will be displayed to the user." 
                                    InternalControlWidth="95%" meta:resourcekey="DataValueFieldResource1"
                                    />
                                <ui:UIFieldTextBox ID="DataTextField" runat="server" Caption="Data Text Field" PropertyName="DataTextField"
                                    ValidateRequiredField="True" Span="Half" 
                                    ToolTip="The column of the result of the query that will be used as a value in the dashboard query." 
                                    InternalControlWidth="95%" meta:resourcekey="DataTextFieldResource1"
                                    />
                            </ui:UIPanel>
                            &nbsp; &nbsp;
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="UITabView4" Caption="Data" 
                    meta:resourcekey="UITabView4Resource1" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelCSharp" BorderStyle="NotSet" 
                        meta:resourcekey="panelCSharpResource1">
                        <ui:UIFieldRadioList runat="server" ID="UseCSharpQuery" PropertyName="UseCSharpQuery"
                            Caption="Use C#" RepeatColumns="0" 
                            OnSelectedIndexChanged="UseCSharpQuery_SelectedIndexChanged" 
                            meta:resourcekey="UseCSharpQueryResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource12">No</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource13">Yes</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTextBox runat="server" ID="CSharpMethodName" PropertyName="CSharpMethodName"
                            ValidateRequiredField="True" ToolTip="Enter the C# method name in the LogicLayer.Reports class that is to be called to generate the report."
                            Caption="C# Method Name" InternalControlWidth="95%" 
                            meta:resourcekey="CSharpMethodNameResource1">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UIFieldTextBox ID="DashboardQuery" runat="server" Caption="Dashboard SQL" PropertyName="DashboardQuery"
                        Rows="35" TextMode="MultiLine" ValidateRequiredField="True" ToolTip="The query in SQL that is used to populate the dashboard. Note: You can preview your dashboard in the 'Preview' tab."
                        meta:resourcekey="DashboardQueryResource1" InternalControlWidth="95%" MaxLength="0" />
                    <ui:uihint runat="server" id="hintSQL" Text="The query in SQL that is used to populate the dashboard. {UserID}, {DashboardID} are default fields available for the SQL query. <br /><br />Note: You can preview your dashboard in the 'Preview' tab."></ui:uihint>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabDisplay" Caption="Display" 
                    BorderStyle="NotSet" meta:resourcekey="tabDisplayResource1">
                    <ui:UIFieldDropDownList ID="dropDashboardType" runat="server" Caption="Dashboard Type"
                        OnSelectedIndexChanged="dropDashboardType_SelectedIndexChanged" PropertyName="DashboardType"
                        ValidateRequiredField="True" ToolTip="The type of dashboard." Span="Half" 
                        meta:resourcekey="dropDashboardTypeResource1">
                        <Items>
                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource14">Grid</asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource15">Gauge</asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource16">Pie</asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource17">Scatter</asp:ListItem>
                            <asp:ListItem Value="4" meta:resourcekey="ListItemResource18">Bubble</asp:ListItem>
                            <asp:ListItem Value="5" meta:resourcekey="ListItemResource19">Basic (bar chart, line chart, or area chart)</asp:ListItem>
                            <asp:ListItem Value="6" meta:resourcekey="ListItemResource20">Radar</asp:ListItem>
                            <asp:ListItem Value="7" meta:resourcekey="ListItemResource21">Polar</asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <br />
                    <ui:UIPanel runat='server' ID="panelChartParameters" BorderStyle="NotSet" 
                        meta:resourcekey="panelChartParametersResource1">
                        <ui:UIFieldDropDownList runat="server" ID="dropDashboardPieType" Caption="Pie Type"
                            PropertyName="DashboardPieType" ValidateRequiredField="True" 
                            meta:resourcekey="dropDashboardPieTypeResource1">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource22">Multiple Pies</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource23">Nested Pies</asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource24">Multiple Donuts</asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropDashboardSeriesType" Caption="Series Type"
                            PropertyName="DashboardSeriesType" ValidateRequiredField="True" 
                            meta:resourcekey="dropDashboardSeriesTypeResource1">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource25">Bar</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource26">Line</asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource27">Area Line</asp:ListItem>
                                <asp:ListItem Value="3" meta:resourcekey="ListItemResource28">Spline</asp:ListItem>
                                <asp:ListItem Value="4" meta:resourcekey="ListItemResource29">Area Spline</asp:ListItem>
                                <asp:ListItem Value="5" meta:resourcekey="ListItemResource30">Cone</asp:ListItem>
                                <asp:ListItem Value="6" meta:resourcekey="ListItemResource31">Pyramid</asp:ListItem>
                                <asp:ListItem Value="7" meta:resourcekey="ListItemResource32">Cylinder</asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldCheckBox runat="server" ID="checkDashboard3D" Caption="3D" PropertyName="Dashboard3D"
                            Text="Yes, display this dashboard in 3D" 
                            meta:resourcekey="checkDashboard3DResource1" TextAlign="Right">
                        </ui:UIFieldCheckBox>
                        <ui:UIFieldRadioList runat="server" ID="dropDashboardShowHorizontal" Caption="Orientation"
                            PropertyName="DashboardShowHorizontal" ValidateRequiredField="True" 
                            RepeatColumns="0" meta:resourcekey="dropDashboardShowHorizontalResource1" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource33">Vertical </asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource34">Horizontal </asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Category Axis" 
                            meta:resourcekey="UISeparator2Resource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropXAxisType" ValidateRequiredField="True"
                            PropertyName="XAxisType" Span="Half" Caption="Axis Type" 
                            meta:resourcekey="dropXAxisTypeResource1">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource35">Normal</asp:ListItem>
                                <asp:ListItem Value="3" meta:resourcekey="ListItemResource36">Date/Time</asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="XAxisColumnName" runat="server" Caption="Axis Column Name"
                            PropertyName="XAxisColumnName" Span="Half" ValidateRequiredField="True" ToolTip="The column of the result of the query that will be used as the labels in the X-Axis column."
                            meta:resourcekey="XAxisColumnNameResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="textXAxisLabelText" Caption="Axis Label" PropertyName="XAxisLabelText"
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textXAxisLabelTextResource1" />
                        <ui:UIPanel runat="server" ID="panelSeries" BorderStyle="NotSet" 
                            meta:resourcekey="panelSeriesResource1">
                            <ui:UISeparator runat="server" ID="UISeparator1" Caption="Series" 
                                meta:resourcekey="UISeparator1Resource1" />
                            <ui:uifieldradiolist runat="server" id="radioSeriesByColumns" Caption="Mode" 
                                OnSelectedIndexChanged="radioSeriesByColumns_SelectedIndexChanged" 
                                ValidateRequiredField="True" PropertyName="SeriesByColumns" 
                                meta:resourcekey="radioSeriesByColumnsResource1" TextAlign="Right">
                                <Items>
                                    <Asp:ListItem Value="0" 
                                        Text="Names of series defined as data in one specific column" 
                                        meta:resourcekey="ListItemResource37"></Asp:ListItem>
                                    <Asp:ListItem Value="1" 
                                        Text="Names of series defined as the column name in all columns (except for the X-Axis column)" 
                                        meta:resourcekey="ListItemResource38"></Asp:ListItem>
                                </Items>
                            </ui:uifieldradiolist>
                            <ui:UIFieldTextBox ID="textSeriesColumnName" runat="server" Caption="Series Column"
                                PropertyName="SeriesColumnName" Span="Half" 
                                ToolTip="The column of the result of the query that will be used to group the data in a series." 
                                InternalControlWidth="95%" meta:resourcekey="textSeriesColumnNameResource1" />
                        </ui:UIPanel>
                        <ui:UISeparator runat="server" ID="UISeparator3" Caption="Result Axis" 
                            meta:resourcekey="UISeparator3Resource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropYAxisType" ValidateRequiredField="True"
                            PropertyName="YAxisType" Span="Half" Caption="Axis Type" 
                            meta:resourcekey="dropYAxisTypeResource1">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource39">Normal</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource40">Stacked</asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource41">Fully Stacked</asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="textYAxisColumnName" runat="server" Caption="Axis Column Name"
                            PropertyName="YAxisColumnName" Span="Half" ValidateRequiredField="True" ToolTip="The column of the result of the query that will be used as the values."
                            meta:resourcekey="YAxisColumnNameResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="textYAxisLabelText" Caption="Axis Label" PropertyName="YAxisLabelText"
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textYAxisLabelTextResource1" />
                        <ui:UIPanel runat="server" ID="panelScale" 
                            meta:resourcekey="panelScaleResource1" BorderStyle="NotSet">
                            <ui:UISeparator runat="server" Caption="Gauge Scale" ID="sep1" meta:resourcekey="sep1Resource1">
                            </ui:UISeparator>
                            <ui:UIFieldCheckBox ID="IsAutoCalibrate" runat="server" Caption="Auto Calibrate"
                                PropertyName="IsAutoCalibrate" OnCheckedChanged="IsAutoCalibrate_CheckedChanged"
                                Text="Yes, please auto-calibrate the scale" ToolTip="Indicates if the gauge scale should be auto-calibrated based on the values of the result, or manually specified."
                                meta:resourcekey="IsAutoCalibrateResource1" TextAlign="Right" />
                            <ui:UIPanel runat="server" ID="panelManualScale" 
                                meta:resourcekey="panelManualScaleResource1" BorderStyle="NotSet">
                                <ui:UIFieldTextBox ID="YAxisMinimum" runat="server" Caption="Scale Minimum" PropertyName="YAxisMinimum"
                                    Span="Half" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                    ToolTip="The minimum value of the scale. Any values that fall below the minimum will be displayed slightly before the minimum marking."
                                    meta:resourcekey="YAxisMinimumResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox ID="YAxisMaximum" runat="server" Caption="Scale Maximum" PropertyName="YAxisMaximum"
                                    Span="Half" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                    ToolTip="The maximum value of the scale. Any values that go above the maximum will be displayed slightly past the maximum marking."
                                    meta:resourcekey="YAxisMaximumResource1" ValidateCompareField="True" 
                                    ValidationCompareControl="YAxisMinimum" ValidationCompareOperator="GreaterThan" 
                                    ValidationCompareType="Currency" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox ID="YAxisInterval" runat="server" Caption="Scale Interval" PropertyName="YAxisInterval"
                                    Span="Half" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency"
                                    ToolTip="The interval between the minimum and the maximum. This interval should roughly divide the range between the minimum and the maximum to ten. For example, if the minimum and maximum is 0 and 100, the interval could be 10."
                                    ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                    ValidationRangeType="Currency" meta:resourcekey="YAxisIntervalResource1" 
                                    InternalControlWidth="95%" />
                            </ui:UIPanel>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelBubbleSize" BorderStyle="NotSet" 
                            meta:resourcekey="panelBubbleSizeResource1">
                            <ui:UISeparator runat="server" ID="UISeparator5" Caption="Bubble Size" 
                                meta:resourcekey="UISeparator5Resource1" />
                            <ui:UIFieldTextBox runat="server" ID="textSizeColumnName" 
                                PropertyName="SizeColumnName" Caption="Size Column Name" 
                                ValidateRequiredField="True" Span="Half" InternalControlWidth="95%" 
                                meta:resourcekey="textSizeColumnNameResource1"></ui:UIFieldTextBox>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="UITabView5" Caption="Access" 
                    meta:resourcekey="UITabView5Resource1" BorderStyle="NotSet">
                    <ui:UIFieldCheckboxList runat="server" ID="DashboardRoles" PropertyName="Roles" Caption="Roles"
                        ValidateRequiredField="True" ToolTip="Indicates the roles that have access to view this dashboard."
                        meta:resourcekey="DashboardRolesResource1" TextAlign="Right">
                    </ui:UIFieldCheckboxList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabPreview" Caption="Preview" 
                    meta:resourcekey="tabPreviewResource1" BorderStyle="NotSet">
                    <iframe runat="server" id="framePreview" style="width: 600px; height: 500px;" scrolling="no" frameborder="0" >
                    </iframe>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" 
                    meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments" 
                    meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
