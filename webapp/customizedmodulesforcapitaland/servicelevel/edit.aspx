<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
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
        if(!IsPostBack)
            LocationID.PopulateTree();
        OServiceLevel serviceLevel = panel.SessionObject as OServiceLevel;
        panel.ObjectPanel.BindObjectToControls(serviceLevel);
    }

    /// <summary>
    /// Validates and saves the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OServiceLevel serviceLevel = panel.SessionObject as OServiceLevel;
            panel.ObjectPanel.BindControlsToObject(serviceLevel);

            //Validates
            //
            if (serviceLevel.IsDuplicateLocation())
                LocationID.ErrorMessage = Resources.Errors.ServiceLevel_LocationDuplicate;

            if (!panel.ObjectPanel.IsValid)
                return;

            //Saves the service level object
            //
            serviceLevel.Save();
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
    }

    /// <summary>
    /// Constructs the location tree view.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater UIFieldTreeList1_AcquireTreePopulater(object sender)
    {
        OServiceLevel serviceLevel = panel.SessionObject as OServiceLevel;

        return new LocationTreePopulaterForCapitaland(serviceLevel.LocationID, true, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    /// <summary>
    /// Populates the service level sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ServiceLevelDetail_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OServiceLevelDetail serviceLevelDetail = ServiceLevelDetail_SubPanel.SessionObject as OServiceLevelDetail;
        
        TypeOfServiceID.Bind(
            UIBinder.ConstructDataTable(OCode.GetCodesByType("TypeOfService", serviceLevelDetail.TypeOfServiceID), "ObjectID", "Path"),
            "Path", "ObjectID", true);

        ServiceLevelDetail_SubPanel.ObjectPanel.BindObjectToControls(serviceLevelDetail);
    }

    /// <summary>
    /// Validates and insert the service level details into the service level object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ServiceLevelDetail_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OServiceLevel serviceLevel = panel.SessionObject as OServiceLevel;
        //OServiceLevelDetail serviceLevelDetail = panel.SessionObject as OServiceLevelDetail;
        OServiceLevelDetail serviceLevelDetail = ServiceLevelDetail_SubPanel.SessionObject as OServiceLevelDetail;
        ServiceLevelDetail_ObjectPanel.BindControlsToObject(serviceLevelDetail);
        
        if (serviceLevel.HasDuplicateServiceLevelDetail(serviceLevelDetail))
        {
            this.StepNumber.ErrorMessage = Resources.Errors.ServiceLevel_DuplicateServiceLevelDetail;
            this.TypeOfServiceID.ErrorMessage = Resources.Errors.ServiceLevel_DuplicateServiceLevelDetail;
            this.Priority.ErrorMessage = Resources.Errors.ServiceLevel_DuplicateServiceLevelDetail;
        }
        
        panel.ObjectPanel.BindControlsToObject(serviceLevel);
        serviceLevel.ServiceLevelDetails.Add(serviceLevelDetail);
        panel.ObjectPanel.BindObjectToControls(serviceLevel);
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
            <web:object runat="server" ID="panel" Caption="Service Level" BaseTable="tServiceLevel"
                OnValidateAndSave="panel_ValidateAndSave" OnPopulateForm="panel_PopulateForm"
                meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details"
                        meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Service Level Name"
                            ObjectNumberValidateRequiredField="true" ObjectNameValidateRequiredField="true"
                            meta:resourcekey="objectBaseResource1"></web:base>
                        &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;<br />
                        <ui:UIFieldTreeList ID="LocationID" runat="server" Caption="Location" OnAcquireTreePopulater="UIFieldTreeList1_AcquireTreePopulater"
                            PropertyName="LocationID" ValidateRequiredField="True" ToolTip="The location to and under which this service level applies."
                            meta:resourcekey="LocationIDResource1">
                        </ui:UIFieldTreeList>
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <ui:UIGridView ID="ServiceLevelDetails" runat="server" PropertyName="ServiceLevelDetails"
                            KeyName="ObjectID" meta:resourcekey="ServiceLevelDetailsResource1" Width="100%"
                            SortExpression="[TypeOfService.Parent.ObjectName], [TypeOfService.ObjectName], Priority, StepNumber">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TypeOfService.Parent.ObjectName" HeaderText="Type of Work"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TypeOfService.ObjectName" HeaderText="Type of Service"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Priority" HeaderText="Priority" meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StepNumber" HeaderText="Step" meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AcknowledgementLimitInMinutes" HeaderText="Ack Limit (minutes)"
                                    meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ArrivalLimitInMinutes" HeaderText="Arrive Limit (minutes)"
                                    meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CompletionLimitInMinutes" HeaderText="Complete Limit (minutes)"
                                    meta:resourcekey="UIGridViewColumnResource9">
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
                        <ui:UIObjectPanel runat="server" ID="ServiceLevelDetail_ObjectPanel" Width="100%"
                            meta:resourcekey="ServiceLevelDetail_ObjectPanelResource1">
                            <web:subpanel runat="server" ID="ServiceLevelDetail_SubPanel" GridViewID="ServiceLevelDetails"
                                OnPopulateForm="ServiceLevelDetail_SubPanel_PopulateForm"
                                OnValidateAndUpdate="ServiceLevelDetail_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldDropDownList ID="TypeOfServiceID" runat="server" Caption="Type of Service"
                                PropertyName="TypeOfServiceID" ValidateRequiredField="True" ToolTip="The type of service to which this reminder notification applies to."
                                meta:resourcekey="TypeOfServiceIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="Priority" runat="server" Caption="Priority" ValidateRequiredField="True"
                                PropertyName="Priority" meta:resourcekey="PriorityResource1">
                                <Items>
                                    <asp:ListItem Selected="True" meta:resourcekey="ListItemResource6">
                                    </asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource7">0 (Lowest)</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource8">1</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource9">2</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource10">3 (Highest)</asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="StepNumber" runat="server" Caption="Step" PropertyName="StepNumber"
                                Span="Half" ValidateRequiredField="True" ToolTip="The step number of the service level."
                                meta:resourcekey="StepNumberResource1">
                                <Items>
                                    <asp:ListItem Selected="True" meta:resourcekey="ListItemResource1">1</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource2">2</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource3">3</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource4">4</asp:ListItem>
                                    <asp:ListItem meta:resourcekey="ListItemResource5">5</asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox ID="AcknowledgementLimitInMinutes" runat="server" Caption="Ack Limit (mins)"
                                PropertyName="AcknowledgementLimitInMinutes" Span="Half" ValidateRequiredField="True"
                                ToolTip="The time in minutes from the start of the work that the work must be acknowledged before a reminder notification is raised."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="AcknowledgementLimitInMinutesResource1" />
                            <ui:UIFieldTextBox ID="ArrivalLimitInMinutes" runat="server" Caption="Arr Limit (mins)"
                                PropertyName="ArrivalLimitInMinutes" Span="Half" ValidateRequiredField="True"
                                ToolTip="The time in minutes from the start of the work that the work must be responded to before a reminder notification is raised."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="ArrivalLimitInMinutesResource1" />
                            <ui:UIFieldTextBox ID="CompletionLimitInMinutes" runat="server" Caption="Com Limit (mins)"
                                PropertyName="CompletionLimitInMinutes" Span="Half" ValidateRequiredField="True"
                                ToolTip="The time in minutes from the start of the work that the work must be completed before a reminder notification is raised."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="CompletionLimitInMinutesResource1" />
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
