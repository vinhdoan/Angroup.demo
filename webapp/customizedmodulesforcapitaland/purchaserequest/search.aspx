<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>

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
        //        e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseOrder.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        //}
        //if (treeLocation.SelectedValue != "")
        //{
        //    OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
        //    if (location != null)
        //        e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseOrder.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        //}
        //if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        //{
        //    e.CustomCondition = Query.False;
        //    foreach (OPosition position in AppSession.User.Positions)
        //        foreach (OLocation location in position.LocationAccess)
        //            e.CustomCondition = e.CustomCondition | TablesLogic.tPurchaseOrder.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        //}
    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, true, Security.Decrypt(Request["TYPE"]), false, false);
    }


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
    /// Generates a request for quotation from a selected
    /// set of purchase requests.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGenerateRFQ_Click(object sender, EventArgs e)
    {
        List<object> idList = gridResults.GetSelectedKeys();
        List<Guid> ids = new List<Guid>();
        foreach (Guid id in idList)
            ids.Add(id);

        ORequestForQuotation rfq = ORequestForQuotation.CreateRFQFromPRs(ids);
        if (rfq != null)
            Window.OpenEditObjectPage(this, "ORequestForQuotation", rfq.ObjectID.ToString(), "");
        else
            panel.Message = Resources.Errors.RequestForQuotation_UnableToGenerate;

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }


    /// <summary>
    /// Generates a purchase order from a selected
    /// set of purchase requests.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePO_Click(object sender, EventArgs e)
    {
        List<object> idList = gridResults.GetSelectedKeys();
        List<Guid> ids = new List<Guid>();
        foreach (Guid id in idList)
            ids.Add(id);

        OPurchaseOrder po = OPurchaseOrder.CreatePOFromPRs(ids);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Purchase Request" GridViewID="gridResults" EditButtonVisible="false" SearchType="ObjectQuery"
                BaseTable="tPurchaseRequest" AssignedCheckboxVisible="true" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectNumber"
                            Caption="WJ Number" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" />
                        <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" PropertyName="LocationID"></ui:UIFieldDropDownList>
                        <%--<ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID" meta:resourcekey="treeLocationResource1"
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" PropertyName="EquipmentID" meta:resourcekey="treeEquipmentResource1"
                            OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater">
                        </ui:UIFieldTreeList>--%>
                        <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" PropertyName="Description"
                            MaxLength="255" meta:resourcekey="DescriptionResource1" />
                        <ui:UIFieldDateTime runat='server' ID="DateRequired" SearchType="Range" Caption="Date Required"
                            ShowTimeControls="False" PropertyName="DateRequired" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" />
                        <br />
                        <br />
                        <br />
                        <table style="width: 100%" cellpadding='0' cellspacing='0' border='0'>
                            <tr>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel1" runat="server" meta:resourcekey="Panel1Resource1">
                                        <asp:Label ID="Label1" runat="server" Font-Bold="True" Text="Ship To:" meta:resourcekey="Label1Resource1"></asp:Label><br />
                                        <ui:UIFieldTextBox ID="ShipToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                            PropertyName="ShipToAddress" meta:resourcekey="ShipToAddressResource1" />
                                        <ui:UIFieldTextBox ID="ShipToAttention" runat="server" Caption="Attention" PropertyName="ShipToAttention"
                                            meta:resourcekey="ShipToAttentionResource1" />
                                    </ui:UIPanel>
                                </td>
                                <td style="width: 49.5%">
                                    <ui:UIPanel ID="Panel2" runat="server" meta:resourcekey="Panel2Resource1">
                                        <asp:Label ID="Label2" runat="server" Font-Bold="True" Text="Bill To:" meta:resourcekey="Label2Resource1"></asp:Label><br />
                                        <ui:UIFieldTextBox ID="BillToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                            PropertyName="BillToAddress" meta:resourcekey="BillToAddressResource1" />
                                        <ui:UIFieldTextBox ID="BillToAttention" runat="server" Caption="Attention" PropertyName="BillToAttention"
                                            meta:resourcekey="BillToAttentionResource1" />
                                    </ui:UIPanel>
                                </td>
                            </tr>
                        </table>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" meta:resourcekey="listStatusResource1"
                            Caption="Status">
                        </ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIButton runat="server" ID="buttonGenerateRFQ" Text="Generate Request for Quotation from Selected Purchase Requests"
                            ImageUrl="~/images/add.gif" OnClick="buttonGenerateRFQ_Click" ConfirmText="Are you sure you wish to generate a Request for Quotation from the selected Purchase Requests?"
                            meta:resourcekey="buttonGenerateRFQResource1" />
                        <ui:UIButton runat="server" ID="buttonGeneratePO" Text="Generate Purchase Order from Selected Purchase Requests"
                            ImageUrl="~/images/add.gif" OnClick="buttonGeneratePO_Click" ConfirmText="Are you sure you wish to generate a Purchase Order from the selected Purchase Requests?"
                            meta:resourcekey="buttonGeneratePOResource1" />
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="ObjectNumber DESC"
                            meta:resourcekey="gridResultsResource1" AllowPaging="True" AllowSorting="True"
                            PagingEnabled="True">
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
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="WJ Number"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Location.Path" HeaderText="Location" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Equipment.Path" HeaderText="Equipment" meta:resourcekey="UIGridViewBoundColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="DateRequired" HeaderText="Date Required"
                                    DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status"
                                    ResourceName="Resources.WorkflowStates" meta:resourcekey="UIGridViewColumnResource7">
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
