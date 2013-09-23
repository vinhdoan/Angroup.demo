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
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", null));

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
                e.CustomCondition = e.CustomCondition & TablesLogic.tRequestForQuotation.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            e.CustomCondition = Query.False;
            foreach (OPosition position in AppSession.User.Positions)
                foreach (OLocation location in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, false, true, Security.Decrypt(Request["TYPE"]));
    }


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
        /*
        OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQs(ids);
        if (po != null)
            Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.ToString(), "");
        else
            panel.Message = Resources.Errors.PurchaseOrder_UnableToGenerate;
         * */
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
            <web:search runat="server" ID="panel" Caption="Request for Quotation" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tRequestForQuotation" SearchType="ObjectQuery"
                AssignedCheckboxVisible="true" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectNumber"
                            Caption="RFQ Number" Span="Half" 
                            meta:resourcekey="UIFieldTextBox1Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='textCaseNumber' PropertyName="Case.ObjectNumber"
                            Caption="Case Number" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textCaseNumberResource1" />
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                            meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode" >
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" PropertyName="EquipmentID"
                            OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                            meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
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
                        <ui:UIButton runat="server" ID="buttonGeneratePO" Text="Generate Purchase Order from Selected Request for Quotations"
                            ImageUrl="~/images/add.gif" OnClick="buttonGeneratePO_Click" ConfirmText="Are you sure you wish to generate a Purchase Order from the selected Request for Quotation?"
                            meta:resourcekey="buttonGeneratePOResource1" />
                        <br />
                        <br />
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="RFQ Number" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" 
                                    ResourceAssemblyName="" SortExpression="ObjectNumber">
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
                                <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" 
                                    HeaderText="Type" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="PurchaseType.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="PurchaseType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Location.Path" 
                                    ResourceAssemblyName="" SortExpression="Location.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Equipment.Path" 
                                    ResourceAssemblyName="" SortExpression="Equipment.Path">
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
                                <cc1:UIGridViewBoundColumn DataField="DateEnd" 
                                    DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Date End" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="DateEnd" 
                                    ResourceAssemblyName="" SortExpression="DateEnd">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BudgetDistributionModeText" 
                                    HeaderText="Budget Distribution Mode" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" 
                                    PropertyName="BudgetDistributionModeText" ResourceAssemblyName="" 
                                    SortExpression="BudgetDistributionModeText">
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
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
