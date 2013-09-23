<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the search form.
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
        //dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", null));
        
        dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, null, Security.Decrypt(Request["TYPE"]), null), "ParentPath", "ObjectID");
        
        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
        List<OCapitalandCompany> Companies = TablesLogic.tCapitalandCompany.LoadAll();
        ddlTrust.Bind(Companies, "ObjectName", "ObjectID");
        ddlOnBehalfOf.Bind(Companies, "ObjectName", "ObjectID");
        ddlManagementCompany.Bind(Companies, "ObjectName", "ObjectID");
        ddlDeliveryTo.Bind(Companies, "ObjectName", "ObjectID");
        ddlBillTo.Bind(Companies, "ObjectName", "ObjectID");
        List<OUser> signators = OUser.GetUsersByRole("PURCHASEADMIN");
        ddlSignatory.Bind(signators);
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
        //        e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseOrder.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        //}
        if (ddlLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(ddlLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseOrder.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (ddlLocation.SelectedValue == "")
        {
            e.CustomCondition = Query.False;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"])))
                foreach (OLocation location in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tPurchaseOrder.Location.HierarchyPath.Like(location.HierarchyPath + "%");
            
            // for Malaysia,
            // Add condition to let the user with group WJ enabled
            // can search all the Purchase Order.
            if (AppSession.User.EnableAllBuildingForGWJ == 1)
                e.CustomCondition = e.CustomCondition | Query.True;
        }

        ExpressionCondition cond = Query.True;

        TPurchaseOrder po = TablesLogic.tPurchaseOrder;
        TPurchaseOrderItem poi = TablesLogic.tPurchaseOrderItem;
        TPurchaseInvoice inv = TablesLogic.tPurchaseInvoice;
        TPurchaseOrderReceipt receipt = TablesLogic.tPurchaseOrderReceipt;
        ExpressionCondition havingCondition = Query.True;

        if (radioInvoice.SelectedIndex == 2) //show POs that are not invoiced completely
        {
            cond = cond &
                poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == po.ObjectID)
                != Case.IsNull(inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == po.ObjectID & inv.IsDeleted == 0 & inv.CurrentActivity.ObjectName == "Approved"), 0);
        }
        else if (radioInvoice.SelectedIndex == 1) //show POs that are 100% Invoiced
        {
            cond = cond & 
                poi.Select((poi.UnitPrice * poi.QuantityOrdered).Sum()).Where(poi.PurchaseOrderID == po.ObjectID)
                == Case.IsNull(inv.Select(inv.TotalAmount.Sum()).Where(inv.PurchaseOrderID == po.ObjectID & inv.IsDeleted == 0 & inv.CurrentActivity.ObjectName == "Approved"), 0);
        }
        
        List<ColumnOrder> customSortOrders = new List<ColumnOrder>();
        customSortOrders.Add(TablesLogic.tPurchaseOrder.CreatedDateTime.Desc);

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
    //    return new LocationTreePopulaterForCapitaland(null, false, true, 
    //        Security.Decrypt(Request["TYPE"]),false,false);
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


    protected void Page_PreRender(object sender, EventArgs e)
    {
        LOAPanel.Visible = rdlPOType.SelectedIndex == PurchaseOrderType.LOA;
        POPanel.Visible = rdlPOType.SelectedIndex == PurchaseOrderType.PO;
    }

    protected void rdlPOType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (!e.Row.Cells[13].Text.Is(Resources.WorkflowStates.PendingApproval, 
                Resources.WorkflowStates.PendingCancellation, 
                Resources.WorkflowStates.PendingCancelAndRevised))
            {
                e.Row.Cells[14].Text = "";
            }
            //Guid objectId = (Guid)gridResults.DataKeys[e.Row.RowIndex][0];
            //OPurchaseOrder po = TablesLogic.tPurchaseOrder.Load(objectId);
            //if (po.CurrentActivityID != null)
            //{
            //    //e.Row.Cells[16].Text = po.CurrentActivity.AssignedUserText;
            //    //e.Row.Cells[15].Text = po.CurrentActivity.AssignedUserPositionsWithUserNamesText;
            //}
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Purchase Order / Letter of Award" GridViewID="gridResults"
                AutoSearchOnLoad="true" SearchTextBoxHint="E.g. PO / LOA Number, Vendor Name, Description, etc..."
                MaximumNumberOfResults="30" SearchTextBoxPropertyNames="ObjectNumber,Vendor.ObjectName,Description"
                AdvancedSearchPanelID="panelAdvanced"
                BaseTable="tPurchaseOrder" OnSearch="panel_Search" SearchType="ObjectQuery" EditButtonVisible="false"
                AssignedCheckboxVisible="true" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <%--<ui:UIFieldTextBox runat='server' ID='textObjectNumber' PropertyName="ObjectNumber"
                            Caption="PO/LOA Number" Span="Half" 
                            meta:resourcekey="UIFieldTextBox1Resource1" InternalControlWidth="95%" />--%>
                        <%--<ui:UIFieldTextBox runat='server' ID='textCaseNumber' PropertyName="Case.ObjectNumber"
                            Caption="Case Number" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textCaseNumberResource1" />--%>
                        <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" 
                            PropertyName="LocationID" meta:resourcekey="ddlLocationResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType" Caption="Transaction Type" 
                            PropertyName="PurchaseTypeID" meta:resourcekey="dropPurchaseTypeResource1"></ui:UIFieldDropDownList>
                        <%--<ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" PropertyName="Description"
                            MaxLength="255" meta:resourcekey="DescriptionResource1" 
                            InternalControlWidth="95%" />--%>
                        <ui:UIFieldDateTime runat='server' ID="DateRequired" SearchType="Range" 
                            Caption="Date Required" PropertyName="DateRequired" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" 
                            ShowDateControls="True" />
                        <ui:UIFieldDateTime runat='server' ID="DateEnd" SearchType="Range" 
                            Caption="Date End" PropertyName="DateEnd" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif"
                            ShowDateControls="True" meta:resourcekey="DateEndResource1" />
                        <%--<ui:UIFieldTextBox ID="VendorName" runat="server" Caption="Vendor Name" PropertyName="Vendor.ObjectName"
                            meta:resourcekey="VendorNameResource1" InternalControlWidth="95%"></ui:UIFieldTextBox>--%>
                        <ui:UIFieldRadioList runat="server" Caption ="Type" PropertyName="POType" 
                            ID="rdlPOType" RepeatColumns="3" RepeatDirection="Vertical" 
                            OnSelectedIndexChanged="rdlPOType_SelectedIndexChanged" 
                            meta:resourcekey="rdlPOTypeResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Selected="True" meta:resourcekey="ListItemResource1">All</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">LOA</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3">PO</asp:ListItem>  
                            </Items>
                        </ui:UIFieldRadioList>
                        <br />
                        <ui:UIPanel runat="server" ID="LOAPanel" BorderStyle="NotSet" 
                            meta:resourcekey="LOAPanelResource1">
                            <ui:UIFieldDropDownList runat="server" Caption="Trust" PropertyName="TrustID" 
                                ID="ddlTrust" meta:resourcekey="ddlTrustResource1" ></ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="ddlOnBehalfOf" runat="server" 
                                Caption="LOA On Behalf Of" PropertyName="LOAOnBehalfOfID" 
                                meta:resourcekey="ddlOnBehalfOfResource1" ></ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="ddlSignatory" runat="server" Caption="Signatory" 
                                PropertyName="SignatoryID" meta:resourcekey="ddlSignatoryResource1" ></ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="POPanel" BorderStyle="NotSet" 
                            meta:resourcekey="POPanelResource1"> 
                            <ui:UIFieldDropDownList runat="server" Caption="Delivery To" 
                                PropertyName="DeliveryToID" ID="ddlDeliveryTo" 
                                meta:resourcekey="ddlDeliveryToResource1" ></ui:UIFieldDropDownList>
                            <ui:UIFieldDateTime ID="DeliveryDate" runat="server" Caption="Delivery Date" 
                                PropertyName="DeliveryDate" SearchType = "Range" 
                                meta:resourcekey="DeliveryDateResource1" ShowDateControls="True" ></ui:UIFieldDateTime>
                            <ui:UIFieldDropDownList ID="ddlBillTo" runat="server" Caption="Bill To" 
                                PropertyName="BillToID" meta:resourcekey="ddlBillToResource1" ></ui:UIFieldDropDownList>
                        </ui:UIPanel>
                         <ui:UIFieldDropDownList ID="ddlManagementCompany" runat="server" 
                            Caption="Management Company" PropertyName="ManagementCompanyID" 
                            meta:resourcekey="ddlManagementCompanyResource1" ></ui:UIFieldDropDownList>
                        <br />
                        <br />
                        <ui:UIFieldRadioList runat="server" ID="radioInvoice" Caption="Invoiced" 
                            meta:resourcekey="radioInvoiceResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" Selected="True" meta:resourcekey="ListItemResource4">All</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource5">Only show POs that are 100% invoiced</asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource6">Only show POs that are not invoiced completely</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" Rows="4" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">--%>
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" 
                            SortExpression="CreatedDateTime DESC" meta:resourcekey="gridResultsResource1"
                            PagingEnabled="True" DataKeyNames="ObjectID" GridLines="Both" 
                            RowErrorColor="" style="clear:both;" 
                            OnRowDataBound="gridResults_RowDataBound" ImageRowErrorUrl="">
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="PO Number" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" 
                                    ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%--<cc1:UIGridViewBoundColumn DataField="Case.ObjectNumber" 
                                    HeaderText="Case Number" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="Case.ObjectNumber" ResourceAssemblyName="" 
                                    SortExpression="Case.ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>--%>
                                <cc1:UIGridViewBoundColumn PropertyName="Location.ObjectName" 
                                    HeaderText="Location" DataField="Location.ObjectName" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" ResourceAssemblyName="" 
                                    SortExpression="Location.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" 
                                    HeaderText="Transaction Type" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="PurchaseType.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="PurchaseType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Vendor.ObjectName" HeaderText="Vendor" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" 
                                    PropertyName="Vendor.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Vendor.ObjectName">
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
                                <%--<ui:UIGridViewBoundColumn PropertyName="DateEnd" HeaderText="Date End" 
                                    DataFormatString="{0:dd-MMM-yyyy}" DataField="DateEnd" 
                                    meta:resourcekey="UIGridViewBoundColumnResource7" ResourceAssemblyName="" 
                                    SortExpression="DateEnd">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>--%>
                                <ui:UIGridViewBoundColumn PropertyName="SubTotal" 
                                    HeaderText="Total PO Amount" DataFormatString="{0:n}" DataField="SubTotal" 
                                    meta:resourcekey="UIGridViewBoundColumnResource8" ResourceAssemblyName="" 
                                    SortExpression="SubTotal">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TotalInvoiced" 
                                    HeaderText="Total Invoiced" DataFormatString="{0:n}" DataField="TotalInvoiced" 
                                    meta:resourcekey="UIGridViewBoundColumnResource9" ResourceAssemblyName="" 
                                    SortExpression="TotalInvoiced">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TotalCreditDebit" 
                                    HeaderText="Total Credit/Debit Memos" DataFormatString="{0:n}" 
                                    DataField="TotalCreditDebit" meta:resourcekey="UIGridViewBoundColumnResource10" 
                                    ResourceAssemblyName="" SortExpression="TotalCreditDebit">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                    HeaderText="Status" meta:resourceKey="UIGridViewColumnResource7" 
                                    PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                    ResourceName="Resources.WorkflowStates" 
                                    SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%--<ui:UIGridViewBoundColumn HeaderText="Assigned User(s)" 
                                    meta:resourcekey="UIGridViewBoundColumnResource11" ResourceAssemblyName="">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>--%>
                               <ui:UIGridViewBoundColumn HeaderText="Assigned Position(s)" PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText"
                                    meta:resourcekey="UIGridViewBoundColumnResource12" ResourceAssemblyName="">
                                   <HeaderStyle HorizontalAlign="Left" />
                                   <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Created Date Time" PropertyName="CreatedDateTime"
                                    Visible="false" meta:resourcekey="UIGridViewBoundColumnResource12" ResourceAssemblyName="">
                                   <HeaderStyle HorizontalAlign="Left" />
                                   <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    <%--</ui:UITabView>
                </ui:UITabStrip>--%>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
