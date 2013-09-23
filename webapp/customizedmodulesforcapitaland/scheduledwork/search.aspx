<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
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
        TypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), null));
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tScheduledWork.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tScheduledWork.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            e.CustomCondition = Query.False;
            foreach (OPosition position in AppSession.User.Positions)
                foreach(OLocation location in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tScheduledWork.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
    }

    /// <summary>
    /// Occurs when user mades selection on the type of work drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        TypeOfServiceID.Items.Clear();
        TypeOfProblemID.Items.Clear();
        if (TypeOfWorkID.SelectedValue != "")
            TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, new Guid(TypeOfWorkID.SelectedValue), Security.Decrypt(Request["TYPE"]), null));
    }

    /// <summary>
    /// A temporary variable to store the selected location ID.
    /// </summary>
    protected Guid? selectedLocationId;

    /// <summary>
    /// Constructs and returns the equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(selectedLocationId, true, true,
        Security.Decrypt(Request["TYPE"]), false, false);
    }

    protected void TypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        TypeOfProblemID.Items.Clear();
        if (TypeOfServiceID.SelectedValue != "")
            TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", new Guid(TypeOfServiceID.SelectedValue), null));
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet" >
            <web:search runat="server" ID="panel" Caption="Scheduled Work" GridViewID="gridResults"
                BaseTable="tScheduledWork" OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"
                EditButtonVisible="false" AssignedCheckboxVisible="true" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" meta:resourcekey="LocationResource1"
                            ToolTip="Use this to select the location that this work applies to." OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UIFieldTreeList ID="treeEquipment" runat="server" Caption="Equipment" meta:resourcekey="EquipmentResource1"
                            OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" ToolTip="Use this to select the equipment that this work applies to." ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UISeparator ID="Uiseparator1" runat="server" Caption="Details" meta:resourcekey="Separator1Resource1" />
                        <ui:UIFieldTextBox ID="ObjectName" runat="server" Caption="Schedule Name" PropertyName="ObjectName"
                            MaxLength="255" Span="Half"  meta:resourcekey="ObjectNameResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="ObjectNumber" runat="server" Caption="Schedule Number" PropertyName="ObjectNumber"
                            MaxLength="255" Span="Half"  meta:resourcekey="ObjectNumberResource1" InternalControlWidth="95%" />
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfWorkID" PropertyName="TypeOfWorkID"
                            Caption="Type of Work" OnSelectedIndexChanged="TypeOfWorkID_SelectedIndexChanged"
                            meta:resourcekey="TypeOfWorkIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfServiceID" PropertyName="TypeOfServiceID"
                            Caption="Type of Service"
                            meta:resourcekey="TypeOfServiceIDResource1" OnSelectedIndexChanged="TypeOfServiceID_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfProblemID" PropertyName="TypeOfProblemID"
                            Caption="Type of Problem"
                            meta:resourcekey="TypeOfProblemIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="WorkDescription" runat="server" Caption="Work Description"
                            PropertyName="WorkDescription" MaxLength="255" meta:resourcekey="WorkDescriptionResource1" InternalControlWidth="95%" />
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkStartDateTime" PropertyName="FirstWorkStartDateTime"
                            Caption="First Work Start" ToolTip="The start date/time of the FIRST work." ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="FirstWorkStartDateTimeResource1" SearchType="Range" ShowDateControls="True"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkEndDateTime" PropertyName="FirstWorkEndDateTime"
                            Caption="First Work End" ToolTip="The end date/time of the FIRST work. Note: This does not indicate the end date/time for the list of works."
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="FirstWorkEndDateTimeResource1" SearchType="Range" ShowDateControls="True"></ui:UIFieldDateTime>
                        <br />
                        <br />
                        <ui:UISeparator ID="Separator4" runat="server" Caption="Contract/Vendor" meta:resourcekey="Separator4Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="ContractName" PropertyName="Contract.ObjectName"
                            Caption="Contract Name" ToolTip="The name of the contract that applies to the works generated by the schedule."
                            MaxLength="255" meta:resourcekey="ContractNameResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="VendorName" PropertyName="Contract.Vendor.ObjectName"
                            Caption="Vendor Name" ToolTip="The vendor responsible for the works generated."
                            MaxLength="255" meta:resourcekey="VendorNameResource1" InternalControlWidth="95%" />
                        <ui:UISeparator ID="UISeparator2" runat="server" Caption="Status"  meta:resourcekey="UISeparator2Resource1" />
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="listStatusResource1" ></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%" SortExpression="ObjectNumber" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Schedule Number" meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Schedule Name" meta:resourceKey="UIGridViewColumnResource5" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TypeOfWork.ObjectName" HeaderText="Type of Work" meta:resourceKey="UIGridViewColumnResource6" PropertyName="TypeOfWork.ObjectName" ResourceAssemblyName="" SortExpression="TypeOfWork.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TypeOfService.ObjectName" HeaderText="Type of Service" meta:resourceKey="UIGridViewColumnResource7" PropertyName="TypeOfService.ObjectName" ResourceAssemblyName="" SortExpression="TypeOfService.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="WorkDescription" HeaderText="Work Description" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="WorkDescription" ResourceAssemblyName="" SortExpression="WorkDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourceKey="UIGridViewColumnResource8" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
