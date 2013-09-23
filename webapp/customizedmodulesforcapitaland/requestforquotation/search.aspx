<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

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
        ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, null));
        //dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", null));
        dropPurchaseType.Bind(OCode.GetCodesByTypeOrderByParentPathAsDataTable("PurchaseType"), "Path", "ObjectID");

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
        //if (treeEquipment.SelectedValue != "")
        //{
        //    OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
        //    if (oEquipment != null)
        //        e.CustomCondition = e.CustomCondition & TablesLogic.tRequestForQuotation.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        //}
        //if (treeLocation.SelectedValue != "")
        //{
        //    OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
        //    if (location != null)
        //        e.CustomCondition = e.CustomCondition & TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        //}
        //if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        //{
        //    e.CustomCondition = Query.False;
        //    foreach (OPosition position in AppSession.User.Positions)
        //        foreach (OLocation location in position.LocationAccess)
        //            e.CustomCondition = e.CustomCondition | TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        //}


        ExpressionCondition cond = Query.True;
        Guid? selectedLocationID = ddlLocation.SelectedValue == string.Empty? (Guid?)null : new Guid(ddlLocation.SelectedValue);
        switch (radioIsGroupWJ.SelectedValue)
        {
            case "0":
                if(selectedLocationID!=null)
                    cond = TablesLogic.tRequestForQuotation.IsGroupWJ != 1 &
                        TablesLogic.tRequestForQuotation.LocationID == selectedLocationID;
                else
                {
                    cond = Query.False;
                    foreach (OPosition position in AppSession.User.Positions)
                        foreach (OLocation location in position.LocationAccess)
                            cond = cond | (TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%") &
                                                             TablesLogic.tRequestForQuotation.IsGroupWJ != 1);
                }
                break;
            case "1":
                if (selectedLocationID != null)

                    cond = TablesLogic.tRequestForQuotation.IsGroupWJ == 1 &
                    (selectedLocationID == null? Query.True : 
                    TablesLogic.tRequestForQuotation.GroupWJLocations.ObjectID == selectedLocationID);
                else
                {
                    cond = Query.False;
                    foreach (OPosition position in AppSession.User.Positions)
                        foreach (OLocation location in position.LocationAccess)
                            cond = cond | (TablesLogic.tRequestForQuotation.GroupWJLocations.HierarchyPath.Like(location.HierarchyPath + "%") &
                                                             TablesLogic.tRequestForQuotation.IsGroupWJ == 1);
                }
                break;
            default:
                if (selectedLocationID != null)
                     cond = 
                        (TablesLogic.tRequestForQuotation.IsGroupWJ == 1 &
                            (selectedLocationID == null ? Query.True :
                            TablesLogic.tRequestForQuotation.GroupWJLocations.ObjectID == selectedLocationID)) 
                        | 
                            (TablesLogic.tRequestForQuotation.IsGroupWJ != 1 &
                            (selectedLocationID == null ? Query.True :
                            TablesLogic.tRequestForQuotation.LocationID == selectedLocationID));
                  
                else
                {
                    cond = Query.False;
                    foreach (OPosition position in AppSession.User.Positions)
                        foreach (OLocation location in position.LocationAccess)
                           cond = cond |
                                    (TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%") &
                                                                         TablesLogic.tRequestForQuotation.IsGroupWJ != 1)
                                    |
                                         (TablesLogic.tRequestForQuotation.GroupWJLocations.HierarchyPath.Like(location.HierarchyPath + "%") &
                                                             TablesLogic.tRequestForQuotation.IsGroupWJ == 1);
                }
                break;
        }
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

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource2">
            <web:search runat="server" ID="panel" Caption="Work Justification" GridViewID="gridResults"
                BaseTable="tRequestForQuotation" SearchType="ObjectQuery" OnSearch="panel_Search"
                AssignedCheckboxVisible="true" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectNumber"
                            Caption="WJ Number" Span="Half" 
                            meta:resourcekey="UIFieldTextBox1Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='textCaseNumber' PropertyName="Case.ObjectNumber"
                            Caption="Case Number" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textCaseNumberResource1" />
                       <ui:UIFieldRadioList runat="server" ID="radioIsGroupWJ" Caption="single WJ/Group WJ" 
                        TextAlign="Right">
                            <Items>
                                <asp:ListItem Text="Any" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="0" Text="Single WJ"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Group WJ"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location"></ui:UIFieldDropDownList>
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
                        <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType" Caption="Type" 
                            PropertyName="PurchaseTypeID" meta:resourcekey="dropPurchaseTypeResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" PropertyName="Description"
                            MaxLength="255" meta:resourcekey="DescriptionResource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldDateTime runat='server' ID="DateRequired" SearchType="Range" 
                            Caption="Date Required" Span="Half" PropertyName="DateRequired" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" 
                            ShowDateControls="True" />
                        <ui:UIFieldDateTime runat='server' ID="DateEnd" SearchType="Range" 
                            Caption="Date End" Span="Half" PropertyName="DateEnd" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateEndResource1" 
                            ShowDateControls="True" />
                        <br />
                        <br />
                        <br />
                        <table style="width: 100%" cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel1" runat="server" meta:resourcekey="Panel1Resource1" 
                                        BorderStyle="NotSet">
                                        <asp:Label ID="Label1" runat="server" Font-Bold="True" Text="Ship To:" meta:resourcekey="Label1Resource1"></asp:Label><br />
                                        <ui:UIFieldTextBox ID="ShipToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                            PropertyName="ShipToAddress" meta:resourcekey="ShipToAddressResource1" 
                                            InternalControlWidth="95%" />
                                        <ui:UIFieldTextBox ID="ShipToAttention" runat="server" Caption="Attention" PropertyName="ShipToAttention"
                                            meta:resourcekey="ShipToAttentionResource1" InternalControlWidth="95%" />
                                    </ui:UIPanel>
                                </td>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel2" runat="server" meta:resourcekey="Panel2Resource1" 
                                        BorderStyle="NotSet">
                                        <asp:Label ID="Label2" runat="server" Font-Bold="True" Text="Bill To:" meta:resourcekey="Label2Resource1"></asp:Label><br />
                                        <ui:UIFieldTextBox ID="BillToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                            PropertyName="BillToAddress" meta:resourcekey="BillToAddressResource1" 
                                            InternalControlWidth="95%" />
                                        <ui:UIFieldTextBox ID="BillToAttention" runat="server" Caption="Attention" PropertyName="BillToAttention"
                                            meta:resourcekey="BillToAttentionResource1" InternalControlWidth="95%" />
                                    </ui:UIPanel>
                                </td>
                            </tr>
                        </table>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="ObjectNumber DESC"
                            meta:resourcekey="gridResultsResource1"
                            PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" 
                            ImageRowErrorUrl="" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="WJ Number" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" 
                                    ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsGroupWJText" HeaderText="Group WJ?" 
                                    PropertyName="IsGroupWJText" ResourceAssemblyName="" SortExpression="IsGroupWJText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Case.ObjectNumber" 
                                    HeaderText="Case Number" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="Case.ObjectNumber" ResourceAssemblyName="" 
                                    SortExpression="Case.ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn HeaderText="Location" PropertyName="Location.ObjectName"></cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PurchaseType.ParentPath" 
                                    HeaderText="Transaction Type" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="PurchaseType.ParentPath" ResourceAssemblyName="" 
                                    SortExpression="PurchaseType.ParentPath">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AwardedVendors" HeaderText="Vendor(s)" 
                                    PropertyName="AwardedVendors" 
                                    ResourceAssemblyName="" SortExpression="AwardedVendors">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                    meta:resourceKey="UIGridViewColumnResource5" PropertyName="Description" 
                                    ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DateRequired" 
                                    DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Date Required" 
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="DateRequired" 
                                    ResourceAssemblyName="" SortExpression="DateRequired">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                    HeaderText="Status" meta:resourceKey="UIGridViewColumnResource8" 
                                    PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                    ResourceName="Resources.WorkflowStates" 
                                    SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" 
                                    HeaderText="Assigned User(s)" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    HeaderText="Assigned Position(s)" 
                                    PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedUser" 
                                    HeaderText="Created User" 
                                    PropertyName="CreatedUser" ResourceAssemblyName="" 
                                    SortExpression="CreatedUser">
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
