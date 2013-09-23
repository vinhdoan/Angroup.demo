<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource2" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
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
        
        if (AppSession.User.EnableAllBuildingForGWJ == 1)
            ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, null), "ObjectName", "ObjectID");
        else
            ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, null));
        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        
        dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, null, Security.Decrypt(Request["TYPE"]), null), "ParentPath", "ObjectID");
        
        dropPaymentType.Bind(OCode.GetCodesByTypeOrderByParentPathAsDataTable("PaymentType"), "Path", "ObjectID");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }


    /// <summary>
    /// Implements custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        //if (treeEquipment.SelectedValue != "")
        //{
        //    OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
        //    if (oEquipment != null)
        //        e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseInvoice.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        //}
        ExpressionCondition cond = Query.False;
        if (ddlLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(ddlLocation.SelectedValue)];
            if (location != null)
                cond = cond | TablesLogic.tPurchaseInvoice.Location.HierarchyPath.Like(location.HierarchyPath + "%");
            
        }
        if (ddlLocation.SelectedValue == "")
        {
            //e.CustomCondition = Query.False;
            List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
            
            foreach (OPosition position in positions)
                foreach (OLocation location in position.LocationAccess)
                    cond = cond | TablesLogic.tPurchaseInvoice.Location.HierarchyPath.Like(location.HierarchyPath + "%");

            // for Malaysia,
            // Add condition to let the user with group WJ enabled
            // can search all the Purchase Order.
            if (AppSession.User.EnableAllBuildingForGWJ == 1)
                cond = cond | Query.True;
        }

        List<ColumnOrder> customSortOrders = new List<ColumnOrder>();
        customSortOrders.Add(TablesLogic.tPurchaseInvoice.CreatedDateTime.Desc);

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

    
    /// <summary>
    /// Occurs when the results are bound to the result gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //e.Row.Cells[14].Text = e.Row.Cells[13].Text + e.Row.Cells[14].Text;
            //e.Row.Cells[15].Text = e.Row.Cells[13].Text + e.Row.Cells[15].Text;
            if (!e.Row.Cells[16].Text.Is(Resources.WorkflowStates.PendingApproval, Resources.WorkflowStates.PendingApproval_Invoice))
                e.Row.Cells[17].Text = "";
        }
        
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
            e.Row.Cells[13].Visible = false;
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
        <ui:UIObjectPanel runat="server" ID="panelMain" 
            meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
            <web:search runat="server" ID="panel" Caption="Purchase Invoice" GridViewID="gridResults" EditButtonVisible="false" AssignedCheckboxVisible="true"
                BaseTable="tPurchaseInvoice" AutoSearchOnLoad="true" SearchTextBoxHint="E.g. Invoice Number, Vendor Name, Description, etc..." 
                MaximumNumberOfResults="30" SearchTextBoxPropertyNames="ObjectNumber,Vendor.ObjectName,Description"
                AdvancedSearchPanelID="panelAdvanced" AdvancedSearchOnLoad="false"
                OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" OnSearch="panel_Search" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet" >--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldCheckBoxList runat="server" ID="checklistMatchType" 
                            meta:resourcekey="checklistMatchTypeResource1" PropertyName="MatchType"
                            Caption="Match Type" TextAlign="Right" RepeatColumns="3">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Direct invoice (not matched to any purchase document)."></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Matched to Purchase Order."></asp:ListItem>
                            </Items>
                        </ui:UIFieldCheckBoxList>
                        <ui:UIFieldCheckBoxList runat="server" ID="checklistInvoiceType" 
                            meta:resourcekey="checklistInvoiceTypeResource1" PropertyName="InvoiceType"
                            Caption="Invoice Type" TextAlign="Right" RepeatColumns="3">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource3" Text="Standard Invoice"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource4" Text="Credit Memo"></asp:ListItem>
                                <asp:ListItem Value="2" Text="Debit Memo" meta:resourcekey="ListItemResource5"></asp:ListItem>
                            </Items>
                        </ui:UIFieldCheckBoxList>
                        <ui:UIPanel runat="server" ID="panelLocationEquipment" 
                            meta:resourcekey="panelLocationEquipmentResource1" BorderStyle="NotSet">
                             <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" 
                                 PropertyName="LocationID" meta:resourcekey="ddlLocationResource1"></ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <ui:UIFieldDateTime runat='server' ID="dateDateOfInvoice" 
                            meta:resourcekey="dateDateOfInvoiceResource1" Caption="Date of Invoice" 
                            PropertyName="DateOfInvoice" SearchType="Range"
                            Span="Half" ShowDateControls="True" />
                        <div style="clear: both">
                        </div>
                         <ui:UIFieldDropDownList runat='server' ID="dropPurchaseType" Caption="Transaction Type" 
                            PropertyName="PurchaseTypeID" meta:resourcekey="dropPurchaseTypeResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="dropPaymentType" Caption="Payment Type" 
                            PropertyName="PaymentTypeID" ></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="textReferenceNumber" 
                            meta:resourcekey="textReferenceNumberResource1" Caption="Vendor Invoice Number"
                            PropertyName="ReferenceNumber" Span="Half" InternalControlWidth="95%" >
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textPurchaseOrderNumber" 
                            Caption="PO / LOA Number"
                            PropertyName="PurchaseOrder.ObjectNumber" Span="Half" InternalControlWidth="95%" >
                        </ui:UIFieldTextBox>
                        <%--<ui:UIFieldTextBox runat="server" ID="textDescription" 
                            meta:resourcekey="textDescriptionResource1" Caption="Description" 
                            PropertyName="Description" MaxLength="255" InternalControlWidth="95%">
                        </ui:UIFieldTextBox>--%>
                        <%--<ui:UIFieldTextBox runat="server" ID="textVendorName" Caption="Vendor Name" 
                            meta:resourcekey="textVendorNameResource1" PropertyName="Vendor.ObjectName" 
                            MaxLength="255" InternalControlWidth="95%">
                        </ui:UIFieldTextBox>--%>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" meta:resourcekey="listStatusResource1"
                            Caption="Status" Rows="4"></ui:UIFieldListBox>
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet" >--%>
                        <ui:UIGridView runat="server" ID="gridResults" 
                            meta:resourcekey="gridResultsResource1" KeyName="ObjectID" Width="100%" 
                            SortExpression="CreatedDateTime DESC" OnRowDataBound="gridResults_RowDataBound" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourceKey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.ObjectName" HeaderText="Location" 
                                    PropertyName="Location.ObjectName" 
                                    ResourceAssemblyName="" SortExpression="Location.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PurchaseOrder.ObjectNumber" HeaderText="PO / LOA Number" 
                                    PropertyName="PurchaseOrder.ObjectNumber" 
                                    ResourceAssemblyName="" SortExpression="PurchaseOrder.ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MatchTypeText" HeaderText="Match Type" 
                                    meta:resourceKey="UIGridViewBoundColumnResource2" PropertyName="MatchTypeText" 
                                    ResourceAssemblyName="" SortExpression="MatchTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="InvoiceTypeText" 
                                    HeaderText="Invoice Type" meta:resourceKey="UIGridViewBoundColumnResource3" 
                                    PropertyName="InvoiceTypeText" ResourceAssemblyName="" 
                                    SortExpression="InvoiceTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" 
                                    HeaderText="Transaction Type" meta:resourceKey="UIGridViewBoundColumnResource4" 
                                    PropertyName="PurchaseType.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="PurchaseType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                    meta:resourceKey="UIGridViewBoundColumnResource5" PropertyName="Description" 
                                    ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Vendor.ObjectName" 
                                    HeaderText="Vendor Name" meta:resourceKey="UIGridViewBoundColumnResource6" 
                                    PropertyName="Vendor.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Vendor.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ReferenceNumber" 
                                    HeaderText="Vendor Invoice Number" 
                                    PropertyName="ReferenceNumber" ResourceAssemblyName="" 
                                    SortExpression="ReferenceNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Currency.ObjectName" 
                                    HeaderText="Currency" meta:resourceKey="UIGridViewBoundColumnResource7" 
                                    PropertyName="Currency.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Currency.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Currency.CurrencySymbol" 
                                    meta:resourceKey="UIGridViewBoundColumnResource8" 
                                    PropertyName="Currency.CurrencySymbol" ResourceAssemblyName="" 
                                    SortExpression="Currency.CurrencySymbol">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%--<cc1:UIGridViewBoundColumn DataField="TotalAmountInSelectedCurrency" 
                                    DataFormatString="{0:n}" HeaderText="Total Amount" 
                                    meta:resourceKey="UIGridViewBoundColumnResource9" 
                                    PropertyName="TotalAmountInSelectedCurrency" ResourceAssemblyName="" 
                                    SortExpression="TotalAmountInSelectedCurrency">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalTaxInSelectedCurrency" 
                                    DataFormatString="{0:n}" HeaderText="Total Tax" 
                                    meta:resourceKey="UIGridViewBoundColumnResourcee10" 
                                    PropertyName="TotalTaxInSelectedCurrency" ResourceAssemblyName="" 
                                    SortExpression="TotalTaxInSelectedCurrency">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle ForeColor="#777777" HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>--%>
                                <cc1:UIGridViewBoundColumn DataField="TotalAmount" DataFormatString="{0:c}" 
                                    HeaderText="Total Amount&lt;br/&gt;(Base Currency)" HtmlEncode="False" 
                                    meta:resourceKey="UIGridViewBoundColumnResource11" PropertyName="TotalAmount" 
                                    ResourceAssemblyName="" SortExpression="TotalAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalTax" DataFormatString="{0:c}" 
                                    HeaderText="Total Tax&lt;br/&gt;(Base Currency)" HtmlEncode="False" 
                                    meta:resourceKey="UIGridViewBoundColumnResource12" PropertyName="TotalTax" 
                                    ResourceAssemblyName="" SortExpression="TotalTax">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                    HeaderText="Status" meta:resourceKey="UIGridViewBoundColumnResource13" 
                                    PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                    ResourceName="Resources.WorkflowStates" 
                                    SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <%--<cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" 
                                    HeaderText="Assigned User(s)" 
                                    meta:resourcekey="UIGridViewBoundColumnResource14" 
                                    PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>--%>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    HeaderText="Assigned Position(s)" meta:resourcekey="UIGridViewBoundColumnResource15" 
                                    PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    ResourceAssemblyName="" SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" 
                                    HeaderText="Created Date Time" meta:resourcekey="UIGridViewBoundColumnResource15" 
                                    PropertyName="CreatedDateTime" Visible="false"
                                    ResourceAssemblyName="" SortExpression="CreatedDateTime">
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
