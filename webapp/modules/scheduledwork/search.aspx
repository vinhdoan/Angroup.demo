<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
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
        if (TypeOfWorkID.SelectedValue != "")
            TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, new Guid(TypeOfWorkID.SelectedValue), Security.Decrypt(Request["TYPE"]), null));

        TypeOfProblemID.Items.Clear();
        if (TypeOfServiceID.SelectedValue != "")
            TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", new Guid(TypeOfServiceID.SelectedValue), null));
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
        return new LocationTreePopulater(selectedLocationId, true, true, Security.Decrypt(Request["TYPE"]));
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" >
            <web:search runat="server" ID="panel" Caption="Scheduled Work" GridViewID="gridResults"
                BaseTable="tScheduledWork" OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"
                EditButtonVisible="false" AssignedCheckboxVisible="true" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" meta:resourcekey="LocationResource1"
                            ToolTip="Use this to select the location that this work applies to." OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" />
                        <ui:UIFieldTreeList ID="treeEquipment" runat="server" Caption="Equipment" meta:resourcekey="EquipmentResource1"
                            OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" ToolTip="Use this to select the equipment that this work applies to.">
                        </ui:UIFieldTreeList>
                        <ui:UISeparator ID="Uiseparator1" runat="server" Caption="Details" meta:resourcekey="Separator1Resource1" />
                        <ui:UIFieldTextBox ID="ObjectName" runat="server" Caption="Schedule Name" PropertyName="ObjectName"
                            MaxLength="255" Span="half"  meta:resourcekey="ObjectNameResource1" />
                        <ui:UIFieldTextBox ID="ObjectNumber" runat="server" Caption="Schedule Number" PropertyName="ObjectNumber"
                            MaxLength="255" Span="half"  meta:resourcekey="ObjectNumberResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfWorkID" PropertyName="TypeOfWorkID"
                            Caption="Type of Work" OnSelectedIndexChanged="TypeOfWorkID_SelectedIndexChanged"
                            meta:resourcekey="TypeOfWorkIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfServiceID" PropertyName="TypeOfServiceID"
                            Caption="Type of Service" OnSelectedIndexChanged="TypeOfWorkID_SelectedIndexChanged"
                            meta:resourcekey="TypeOfServiceIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="TypeOfProblemID" PropertyName="TypeOfProblemID"
                            Caption="Type of Problem" OnSelectedIndexChanged="TypeOfWorkID_SelectedIndexChanged"
                            meta:resourcekey="TypeOfProblemIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="WorkDescription" runat="server" Caption="Work Description"
                            PropertyName="WorkDescription" MaxLength="255" meta:resourcekey="WorkDescriptionResource1" />
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkStartDateTime" PropertyName="FirstWorkStartDateTime"
                            Caption="First Work Start" ToolTip="The start date/time of the FIRST work." ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="FirstWorkStartDateTimeResource1"
                            ShowTimeControls="False" SearchType="Range"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="FirstWorkEndDateTime" PropertyName="FirstWorkEndDateTime"
                            Caption="First Work End" ToolTip="The end date/time of the FIRST work. Note: This does not indicate the end date/time for the list of works."
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="FirstWorkEndDateTimeResource1"
                            ShowTimeControls="False" SearchType="Range"></ui:UIFieldDateTime>
                        <br />
                        <br />
                        <ui:UISeparator ID="Separator4" runat="server" Caption="Contract/Vendor" meta:resourcekey="Separator4Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="ContractName" PropertyName="Contract.ObjectName"
                            Caption="Contract Name" ToolTip="The name of the contract that applies to the works generated by the schedule."
                            MaxLength="255" meta:resourcekey="ContractNameResource1" />
                        <ui:UIFieldTextBox runat="server" ID="VendorName" PropertyName="Contract.Vendor.ObjectName"
                            Caption="Vendor Name" ToolTip="The vendor responsible for the works generated."
                            MaxLength="255" meta:resourcekey="VendorNameResource1" />
                        <ui:UISeparator ID="UISeparator2" runat="server" Caption="Status"  meta:resourcekey="UISeparator2Resource1" />
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="listStatusResource1" >
                        </ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%" SortExpression="ObjectNumber">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Schedule Number"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Schedule Name"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TypeOfWork.ObjectName" HeaderText="Type of Work"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TypeOfService.ObjectName" HeaderText="Type of Service"
                                    meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="WorkDescription" HeaderText="Work Description" meta:resourcekey="UIGridViewBoundColumnResource1" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status"
                                    ResourceName="Resources.WorkflowStates" meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
