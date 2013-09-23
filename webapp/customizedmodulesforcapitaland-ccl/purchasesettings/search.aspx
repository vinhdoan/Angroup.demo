<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource2" %>
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
        treeLocation.PopulateTree();
        //dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", null));
        //dropPurchaseType.Bind(OCode.GetCodesByTypeOrderByParentPathAsDataTable("PurchaseType"), "Path", "ObjectID");
        
        dropPurchaseType.Bind(OCode.GetPurchaseTypes(AppSession.User, null, Security.Decrypt(Request["TYPE"]), null), "ParentPath", "ObjectID");

        BudgetGroupID.Bind(AppSession.User.GetAllAccessibleBudgetGroup(Security.Decrypt(Request["TYPE"]), null), true);
    }


    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tPurchaseSettings.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "")
        {
            List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
            e.CustomCondition = Query.False;
            foreach (OPosition position in positions)
                foreach (OLocation location in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tPurchaseSettings.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "OPurchaseSettings", false, false);
    }

    protected TreePopulater treeLocation2_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, false, "OPurchaseSettings", false, false);
    }

    /// <summary>
    /// Pops up the massupdate.aspx page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonMassUpdate_Click(object sender, EventArgs e)
    {
        Window.Open("massupdate.aspx", "AnacleEAM_Window");
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
            <web:search runat="server" ID="panel" Caption="Purchase Settings" GridViewID="gridResults" SearchType="ObjectQuery" EditButtonVisible="false"
                BaseTable="tPurchaseSettings" AutoSearchOnLoad="true" SearchTextBoxHint="Location Name, Purchase Type Name" 
                MaximumNumberOfResults="100" SearchTextBoxPropertyNames="Location.ObjectName,PurchaseType.ObjectName"
                AdvancedSearchPanelID="panelAdvanced" AdvancedSearchOnLoad="false"
                OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" meta:resourcekey="LocationResource1"
                            ToolTip="Use this to select the location that this work applies to." 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                            ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UIFieldDropDownList runat="server" ID="dropPurchaseType" meta:resourcekey="dropPurchaseTypeResource1" PropertyName="PurchaseTypeID" Caption="Transaction Type"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat='server' ID="BudgetGroupID" 
                            Caption="Budget Group" PropertyName="BudgetGroupID" 
                            meta:resourcekey="BudgetGroupIDResource1" >
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldRadioList runat='server' ID="radioMinimumNumberOfQuotationsPolicy" 
                            meta:resourcekey="radioMinimumNumberOfQuotationsPolicyResource1" Caption="Quotation Policy" 
                            PropertyName="MinimumNumberOfQuotationsPolicy" RepeatColumns="0" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Text="Any " meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem Text="Not required " Value="0" meta:resourcekey="ListItemResource2"></asp:ListItem>
                                <asp:ListItem Text="Preferred " Value="1" meta:resourcekey="ListItemResource3"></asp:ListItem>
                                <asp:ListItem Text="Required " Value="2" meta:resourcekey="ListItemResource4"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTextBox runat="server" id="textMinimumNumberOfQuotations" 
                            meta:resourcekey="textMinimumNumberOfQuotationsResource1" 
                            PropertyName="MinimumNumberOfQuotations" SearchType="Range" 
                            Caption="Minimum Quotations" span="Half" InternalControlWidth="95%"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" id="textMinimumApplicableRFQAmount" meta:resourcekey="textMinimumApplicableRFQAmountResource1"
                            PropertyName="MinimumApplicableRFQAmount" 
                            Caption="Min Applicable Amount" span="Half" 
                            SearchType="Range" InternalControlWidth="95%"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat='server' ID="radioRFQToPOPolicy" meta:resourcekey="radioRFQToPOPolicyResource1" 
                        Caption="WJ-to-PO Policy" PropertyName="RFQToPOPolicy" RepeatColumns="0" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Text="Any " meta:resourcekey="ListItemResource5"></asp:ListItem>
                                <asp:ListItem Text="Not required " Value="0" meta:resourcekey="ListItemResource6"></asp:ListItem>
                                <asp:ListItem Text="Preferred " meta:resourcekey="ListItemResource7"
                                    Value="1"></asp:ListItem>
                                <asp:ListItem Text="Required " meta:resourcekey="ListItemResource8"
                                    Value="2"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldRadioList runat="server" id="radioBudgetValidationPolicy" 
                            meta:resourcekey="radioBudgetValidationPolicyResource1" 
                            PropertyName="BudgetValidationPolicy" Caption="Budget Validation Policy" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Text="Any" meta:resourcekey="ListItemResource9"></asp:ListItem>
                                <asp:ListItem Value="0" Text="Budget = Line Items" meta:resourcekey="ListItemResource10"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Budget <= Line Items" meta:resourcekey="ListItemResource11"></asp:ListItem>
                                <asp:ListItem Value="2" Text="Budget Not Required" meta:resourcekey="ListItemResource12"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIButton runat="server" ID="buttonMassUpdate" meta:resourcekey="buttonMassUpdateResource1" Text="Update Multiple Settings" OnClick="buttonMassUpdate_Click" ImageUrl="~/images/add.gif" />
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                        meta:resourcekey="tabResultsResource1" BorderStyle="NotSet">--%>
                        <ui:UIGridView runat="server" ID="gridResults" 
                            meta:resourcekey="gridResultsResource1" KeyName="ObjectID" Width="100%" 
                            PageSize="1000" SortExpression="Location.Path, PurchaseType.ObjectName" 
                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
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
                                    meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Location.ObjectName" 
                                    ResourceAssemblyName="" SortExpression="Location.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PurchaseType.ObjectName" 
                                    HeaderText="Transaction Type" meta:resourceKey="UIGridViewBoundColumnResource2" 
                                    PropertyName="PurchaseType.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="PurchaseType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MinimumNumberOfQuotationsPolicyText" 
                                    HeaderText="Minimum Quotations Policy" 
                                    meta:resourceKey="UIGridViewBoundColumnResource3" 
                                    PropertyName="MinimumNumberOfQuotationsPolicyText" ResourceAssemblyName="" 
                                    SortExpression="MinimumNumberOfQuotationsPolicyText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MinimumNumberOfQuotations" 
                                    HeaderText="Minimum Quotations"
                                    meta:resourceKey="UIGridViewBoundColumnResource4" 
                                    PropertyName="MinimumNumberOfQuotations" ResourceAssemblyName="" 
                                    SortExpression="MinimumNumberOfQuotations">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MinimumApplicableRFQAmount" 
                                    DataFormatString="{0:c}" HeaderText="Min WJ Amount" 
                                    meta:resourceKey="UIGridViewBoundColumnResource5" 
                                    PropertyName="MinimumApplicableRFQAmount" ResourceAssemblyName="" 
                                    SortExpression="MinimumApplicableRFQAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="RFQToPOPolicyText" 
                                    HeaderText="WJ-to-PO Policy" meta:resourceKey="UIGridViewBoundColumnResource6" 
                                    PropertyName="RFQToPOPolicyText" ResourceAssemblyName="" 
                                    SortExpression="RFQToPOPolicyText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MinimumApplicablePOAmount" 
                                    DataFormatString="{0:c}" HeaderText="Min PO Amount" 
                                    meta:resourceKey="UIGridViewBoundColumnResource7" 
                                    PropertyName="MinimumApplicablePOAmount" ResourceAssemblyName="" 
                                    SortExpression="MinimumApplicablePOAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BudgetValidationPolicyText" 
                                    HeaderText="Budget Validation Policy" 
                                    meta:resourceKey="UIGridViewBoundColumnResource8" 
                                    PropertyName="BudgetValidationPolicyText" ResourceAssemblyName="" 
                                    SortExpression="BudgetValidationPolicyText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BudgetGroup.ObjectName" 
                                    HeaderText="Budget Group" meta:resourcekey="UIGridViewBoundColumnResource9" 
                                    PropertyName="BudgetGroup.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="BudgetGroup.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsPOAllowedClosureText" 
                                    HeaderText="Allow PO Closure if PO &lt;&gt; IR" 
                                    meta:resourcekey="UIGridViewBoundColumnResource10" 
                                    PropertyName="IsPOAllowedClosureText" ResourceAssemblyName="" 
                                    SortExpression="IsPOAllowedClosureText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsInvoiceLargerThanPOText" 
                                    HeaderText="Allow IR &gt; PO" 
                                    meta:resourcekey="UIGridViewBoundColumnResource11" 
                                    PropertyName="IsInvoiceLargerThanPOText" ResourceAssemblyName="" 
                                    SortExpression="IsInvoiceLargerThanPOText">
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
