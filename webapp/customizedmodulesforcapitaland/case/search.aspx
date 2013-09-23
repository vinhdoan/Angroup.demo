<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

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
                e.CustomCondition = e.CustomCondition & TablesLogic.tCase.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tCase.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            e.CustomCondition = Query.False;
            foreach (OPosition position in AppSession.User.Positions)
                foreach (OLocation location in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tCase.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
    }

    /// <summary>
    /// A temporary variable to store the selected location ID.
    /// </summary>
    protected Guid? selectedLocationId;

    /// <summary>
    /// Constructs the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationEquipmentTreePopulaterForCapitaland(selectedLocationId, true, true, true, Security.Decrypt(Request["TYPE"]));
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet" >
            <web:search runat="server" ID="panel" Caption="Case" GridViewID="gridResults" BaseTable="tCase"
                OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm" EditButtonVisible="false" meta:resourcekey="panelResource1" ></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectNumber"
                            Caption="Case Number" MaxLength="255" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" InternalControlWidth="95%" />
                        <ui:uifielddatetime runat="server" id="dateReportedDateTime" Caption="Reported Date/Time" PropertyName="ReportedDateTime" SearchType="Range" meta:resourcekey="dateReportedDateTimeResource1" ShowDateControls="True">
                            </ui:uifielddatetime>
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" meta:resourcekey="LocationResource1"
                            ToolTip="Use this to select the location that this case applies to." OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" meta:resourcekey="EquipmentResource1"
                            ToolTip="Use this to select the equipment that this case applies to." OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UISeparator ID="Uiseparator2" runat="server" Caption="Requestor"  meta:resourcekey="Uiseparator2Resource1" />
                        <ui:UIFieldTextBox ID="textObjectNumber" runat="server" Caption="Work Number" PropertyName="ObjectNumber"  meta:resourcekey="textObjectNumberResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="textRequestorName" runat="server" Caption="Name" PropertyName="RequestorName"
                            ToolTip="The name of the caller to refer by."  meta:resourcekey="textRequestorNameResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="textRequestorCellPhone" runat="server" Caption="Cell Phone" PropertyName="RequestorCellPhone"
                            Span="Half"  meta:resourcekey="textRequestorCellPhoneResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="textRequestorEmail" runat="server" Caption="Email" PropertyName="RequestorEmail"
                            Span="Half"  meta:resourcekey="textRequestorEmailResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="textRequestorFax" runat="server" Caption="Fax" PropertyName="RequestorFax"
                            Span="Half"  meta:resourcekey="textRequestorFaxResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox ID="textRequestorPhone" runat="server" Caption="Phone" PropertyName="RequestorPhone"
                            Span="Half"  meta:resourcekey="textRequestorPhoneResource1" InternalControlWidth="95%" />                        
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="listStatusResource1" ></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" Width="100%" 
                            meta:resourcekey="gridResultsResource1" PagingEnabled="True" 
                            SortExpression="ObjectNumber DESC" DataKeyNames="ObjectID" GridLines="Both" 
                            RowErrorColor="" style="clear:both;">
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Case Number" meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ReportedDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Reported Date/Time" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="ReportedDateTime" ResourceAssemblyName="" SortExpression="ReportedDateTime">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ProblemDescription" HeaderText="Problem Description" meta:resourceKey="UIGridViewColumnResource5" PropertyName="ProblemDescription" ResourceAssemblyName="" SortExpression="ProblemDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourceKey="UIGridViewColumnResource6" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
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
