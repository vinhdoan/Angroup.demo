<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

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
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
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
        e.CustomCondition = e.CustomCondition &
            TablesLogic.tCase.CurrentActivity.ObjectName != "Cancelled" &
            TablesLogic.tCase.CurrentActivity.ObjectName != "Close";

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
        return new LocationEquipmentTreePopulater(null, true, true, true, Security.Decrypt(Request["TYPE"]));
    }

    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "SelectObject")
        {
            if (dataKeys.Count > 0)
            {
                OCase c = TablesLogic.tCase.Load((Guid)dataKeys[0]);
                Window.Opener.Populate(dataKeys[0].ToString());
            }
        }
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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="Select Case" GridViewID="gridResults" BaseTable="tCase"
                OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" meta:resourcekey="LocationResource1"
                            ToolTip="Use this to select the location that this case applies to." OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" />
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" meta:resourcekey="EquipmentResource1"
                            ToolTip="Use this to select the equipment that this case applies to." OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectNumber"
                            Caption="Case Number" MaxLength="255" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" />
                        <ui:UIFieldTextBox ID="textProblemDescription" runat="server" Caption="Problem Description" PropertyName="ProblemDescription" />
                        <ui:UISeparator ID="Uiseparator2" runat="server" Caption="Requestor" />
                        <ui:UIFieldTextBox ID="textObjectNumber" runat="server" Caption="Work Number" PropertyName="ObjectNumber" />
                        <ui:UIFieldTextBox ID="textRequestorName" runat="server" Caption="Name" PropertyName="RequestorName"
                            ToolTip="The name of the caller to refer by." />
                        <ui:UIFieldTextBox ID="textRequestorCellPhone" runat="server" Caption="Cell Phone" PropertyName="RequestorCellPhone"
                            Span="Half" />
                        <ui:UIFieldTextBox ID="textRequestorEmail" runat="server" Caption="Email" PropertyName="RequestorEmail"
                            Span="Half" />
                        <ui:UIFieldTextBox ID="textRequestorFax" runat="server" Caption="Fax" PropertyName="RequestorFax"
                            Span="Half" />
                        <ui:UIFieldTextBox ID="textRequestorPhone" runat="server" Caption="Phone" PropertyName="RequestorPhone"
                            Span="Half" />                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" Width="100%" meta:resourcekey="gridResultsResource1"
                            AllowPaging="True" AllowSorting="True" PagingEnabled="True" SortExpression="ObjectNumber DESC" OnAction="gridResults_Action">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/tick.gif"
                                    CommandName="SelectObject" HeaderText="" >
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Case Number"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ProblemDescription" HeaderText="Problem Description"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status"
                                    ResourceName="Resources.WorkflowStates" meta:resourcekey="UIGridViewColumnResource6">
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
