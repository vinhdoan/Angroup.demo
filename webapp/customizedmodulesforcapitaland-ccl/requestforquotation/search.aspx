<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        //treeLocation.PopulateTree();
        //treeEquipment.PopulateTree();

        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        if (AppSession.User.EnableAllBuildingForGWJ == 1)
            ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, null), "ObjectName", "ObjectID");
        else
            ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, null));

        dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, null, Security.Decrypt(Request["TYPE"]), null), "ParentPath", "ObjectID");

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

        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));

        ExpressionCondition cond = Query.True;
        Guid? selectedLocationID = ddlLocation.SelectedValue == "" ? (Guid?)null : new Guid(ddlLocation.SelectedValue);
        switch (radioIsGroupWJ.SelectedValue)
        {
            case "0":
                if (selectedLocationID != null)
                    cond = TablesLogic.tRequestForQuotation.IsGroupWJ != 1 &
                        TablesLogic.tRequestForQuotation.LocationID == selectedLocationID;
                else
                {
                    cond = Query.False;
                    foreach (OPosition position in positions)
                        foreach (OLocation location in position.LocationAccess)
                            cond = cond | (TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%") &
                                                             TablesLogic.tRequestForQuotation.IsGroupWJ != 1);

                    // for Malaysia,
                    // Add condition to let the user with group WJ enabled
                    // can search all the Purchase Order.
                    if (AppSession.User.EnableAllBuildingForGWJ == 1)
                        cond = cond | TablesLogic.tRequestForQuotation.IsGroupWJ != 1;
                }
                break;
            case "1":
                if (selectedLocationID != null)

                    cond = (TablesLogic.tRequestForQuotation.IsGroupWJ == 1 &
                        TablesLogic.tRequestForQuotation.GroupWJLocations.ObjectID == selectedLocationID);
                else
                {
                    cond = Query.False;
                    foreach (OPosition position in positions)
                        foreach (OLocation location in position.LocationAccess)
                            cond = cond |
                                (TablesLogic.tRequestForQuotation.GroupWJLocations.ObjectID.In(TablesLogic.tLocation.Select(TablesLogic.tLocation.ObjectID).Where(TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%"))) &
                                TablesLogic.tRequestForQuotation.IsGroupWJ == 1);

                    // Add condition to let the user with group WJ enabled
                    // can search all the Purchase Order.
                    if (AppSession.User.EnableAllBuildingForGWJ == 1)
                        cond = cond | TablesLogic.tRequestForQuotation.IsGroupWJ == 1;
                }
                break;
            default:
                if (selectedLocationID != null)
                    cond =
                       (TablesLogic.tRequestForQuotation.IsGroupWJ == 1 &
                           TablesLogic.tRequestForQuotation.GroupWJLocations.ObjectID == selectedLocationID)
                       |
                           (TablesLogic.tRequestForQuotation.IsGroupWJ != 1 &
                           TablesLogic.tRequestForQuotation.LocationID == selectedLocationID);

                else
                {
                    cond = Query.False;
                    foreach (OPosition position in positions)
                        foreach (OLocation location in position.LocationAccess)
                            cond = cond |
                                ((TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%") &
                                TablesLogic.tRequestForQuotation.IsGroupWJ != 1) |
                                (TablesLogic.tRequestForQuotation.GroupWJLocations.ObjectID.In(TablesLogic.tLocation.Select(TablesLogic.tLocation.ObjectID).Where(TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%"))) &
                                TablesLogic.tRequestForQuotation.IsGroupWJ == 1));

                    // Add condition to let the user with group WJ enabled
                    // can search all the Purchase Order.
                    if (AppSession.User.EnableAllBuildingForGWJ == 1)
                        cond = cond | Query.True;
                }
                break;
        }

        // 2011.08.12, Kien Trung
        // Add Custom Sort Order columns here.
        //
        List<ColumnOrder> customSortOrders = new List<ColumnOrder>();
        customSortOrders.Add(TablesLogic.tRequestForQuotation.CreatedDateTime.Desc);

        // Custom Condition & sort order.
        //
        e.CustomSortOrder = customSortOrders;
        e.CustomCondition = e.CustomCondition & cond;

    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    //{
    //    return new LocationTreePopulaterForCapitaland(null, false, true, Security.Decrypt(Request["TYPE"]),false,false);
    //}


    ///// <summary>
    ///// Constructs the equipment tree populator
    ///// </summary>
    ///// <param name="sender"></param>
    ///// <returns></returns>
    //protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    //{
    //    return new EquipmentTreePopulater(null, false, true, Security.Decrypt(Request["TYPE"]));
    //}


    /// <summary>
    /// Occurs when the user clicks on the Generate Purchase Order button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePO_Click(object sender, EventArgs e)
    {
        panel.Message = "";

        List<object> idList = gridResults.GetSelectedKeys();
        List<Guid> ids = new List<Guid>();
        foreach (Guid id in idList)
            ids.Add(id);

        // Make sure that we do not generate POs from 
        // RFQs that have different properties, because we have no way
        // to merge two RFQs with different properties into
        // one single PO.
        //
        if (!ORequestForQuotation.ValidateRFQsHaveSameProperties(ids))
        {
            panel.Message = String.Format(Resources.Errors.RequestForQuotation_RFQHaveDifferentProperties);
            return;
        }


        // Make sure that we generate POs from 
        // RFQs that have been awarded.
        //
        string rfqNumbers = ORequestForQuotation.ValidateRFQsAwarded(ids);
        if (rfqNumbers != "")
        {
            panel.Message = String.Format(Resources.Errors.RequestForQuotation_RFQNotAwarded, rfqNumbers);
            return;
        }


        // Make sure that we generate POs
        // from RFQs that have been awarded
        // to a single vendor.
        //
        rfqNumbers = ORequestForQuotation.ValidateRFQsAwardedToSingleVendor(ids);
        if (rfqNumbers != "")
        {
            panel.Message = String.Format(Resources.Errors.RequestForQuotation_RFQNotAwardedToSingleVendor, rfqNumbers);
            return;
        }


        // Ensure that if there are more than
        // 1 RFQs, the budget distribution must
        // be by line item.
        rfqNumbers = ORequestForQuotation.ValidateRFQsDistributionMode(ids);
        if (rfqNumbers != "")
        {
            panel.Message = String.Format(Resources.Errors.RequestForQuotation_RFQBudgetDistributionModeMustBeLineItem, rfqNumbers);
            return;
        }

        // Create the PO.
        //
        OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQs(ids, PurchaseOrderType.PO);
        if (po != null)
            Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.ToString(), "");
        else
            panel.Message = Resources.Errors.PurchaseOrder_UnableToGenerate;
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (!e.Row.Cells[11].Text.Is(Resources.WorkflowStates.PendingApproval))
            {
                e.Row.Cells[12].Text = "";
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource2">
        <web:search runat="server" ID="panel" Caption="Work Justification" GridViewID="gridResults"
            BaseTable="tRequestForQuotation" SearchType="ObjectQuery" AssignedCheckboxVisible="true"
            AutoSearchOnLoad="true" MaximumNumberOfResults="100" AdvancedSearchPanelID="panelAdvanced"
            SearchTextBoxHint="E.g. WJ Number, Description, Created User, etc..." SearchTextBoxPropertyNames="ObjectNumber,Description,CreatedUser"
            OnSearch="panel_Search" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm">
        </web:search>
        <div class="div-form">
            <ui:UIPanel runat="server" ID="panelAdvanced">
                <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" meta:resourcekey="treeLocationResource1">
                </ui:UIFieldDropDownList>
                <ui:UIFieldRadioList runat="server" ID="radioIsGroupWJ" Caption="Single WJ/Group WJ"
                    TextAlign="Right" RepeatDirection="Horizontal" RepeatColumns="3" meta:resourcekey="radioIsGroupWJResource1">
                    <Items>
                        <asp:ListItem Text="Any" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="0" Text="Single WJ"></asp:ListItem>
                        <asp:ListItem Value="1" Text="Group WJ"></asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
                <ui:UIFieldRadioList runat="server" ID="radioIsRecoverable" Caption="Recoverable?"
                    meta:resourcekey="radioIsRecoverableResource1" TextAlign="Right" RepeatDirection="Horizontal"
                    RepeatColumns="3" PropertyName="IsRecoverable">
                    <Items>
                        <asp:ListItem Text="Any" Selected="True" Value=""></asp:ListItem>
                        <asp:ListItem Value="0" Text="Non-Recoverable WJ"></asp:ListItem>
                        <asp:ListItem Value="1" Text="Recoverable WJ"></asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
                <%--<ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                        OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                        meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode" >
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" PropertyName="EquipmentID"
                        OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                        meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>--%>
                <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType" Caption="Type" PropertyName="PurchaseTypeID"
                    meta:resourcekey="dropPurchaseTypeResource1">
                </ui:UIFieldDropDownList>
                <%--<ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" PropertyName="Description"
                        MaxLength="255" meta:resourcekey="DescriptionResource1" 
                        InternalControlWidth="95%" />--%>
                <ui:UIFieldDateTime runat='server' ID="DateRequired" SearchType="Range" Caption="Date Required"
                    Span="Half" PropertyName="DateRequired" ImageClearUrl="~/calendar/dateclr.gif"
                    ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" ShowDateControls="True" />
                <ui:UIFieldDateTime runat='server' ID="DateEnd" SearchType="Range" Caption="Date End"
                    Span="Half" PropertyName="DateEnd" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                    meta:resourcekey="DateEndResource1" ShowDateControls="True" />
                <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                    Caption="Status" meta:resourcekey="listStatusResource1" Rows="5" Span="Full"></ui:UIFieldListBox>
            </ui:UIPanel>
            <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="CreatedDateTime DESC"
                meta:resourcekey="gridResultsResource1" PagingEnabled="True" DataKeyNames="ObjectID"
                GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" Style="clear: both;" OnRowDataBound="gridResults_RowDataBound">
                <PagerSettings Mode="NumericFirstLast" />
                <Commands>
                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                        CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                </Commands>
                <Columns>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                        meta:resourceKey="UIGridViewColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                        meta:resourceKey="UIGridViewColumnResource2">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="WJ Number" meta:resourceKey="UIGridViewColumnResource4"
                        PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsGroupWJText" HeaderText="Group WJ?" PropertyName="IsGroupWJText"
                        ResourceAssemblyName="" SortExpression="IsGroupWJText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn HeaderText="Location" PropertyName="Location.ObjectName">
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" HeaderText="Transaction Type"
                        meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="PurchaseType.ObjectName"
                        ResourceAssemblyName="" SortExpression="PurchaseType.ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="AwardedVendors" HeaderText="Awarded Vendor(s)"
                        PropertyName="AwardedVendors" ResourceAssemblyName="" SortExpression="AwardedVendors">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourceKey="UIGridViewColumnResource5"
                        PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="DateRequired" DataFormatString="{0:dd-MMM-yyyy}"
                        HeaderText="Date Required" meta:resourceKey="UIGridViewColumnResource6" PropertyName="DateRequired"
                        ResourceAssemblyName="" SortExpression="DateRequired">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status"
                        meta:resourceKey="UIGridViewColumnResource8" PropertyName="CurrentActivity.ObjectName"
                        ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <%--<cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" 
                                HeaderText="Assigned User(s)" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" 
                                SortExpression="CurrentActivity.AssignedUserText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                    <cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText"
                        HeaderText="Assigned Position(s)" PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText"
                        ResourceAssemblyName="" SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="CreatedUser" HeaderText="Created User" PropertyName="CreatedUser"
                        ResourceAssemblyName="" SortExpression="CreatedUser">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" HeaderText="Created Date Time"
                        Visible="false" PropertyName="CreatedDateTime" ResourceAssemblyName="" SortExpression="CreatedDateTime">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
            <%--</ui:UITabView>
                </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
