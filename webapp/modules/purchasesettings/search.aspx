<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", null));
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
            e.CustomCondition = Query.False;
            foreach (OPosition position in AppSession.User.Positions)
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
        return new LocationTreePopulater(null, true, true, "OPurchaseSettings");
    }

    protected TreePopulater treeLocation2_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, false, false, "OPurchaseSettings");
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Purchase Settings" GridViewID="gridResults" SearchType="ObjectQuery" EditButtonVisible="false"
                BaseTable="tPurchaseSettings" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1">
                        
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" meta:resourcekey="LocationResource1"
                            ToolTip="Use this to select the location that this work applies to." OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" />
                        <ui:UIFieldDropDownList runat="server" ID="dropPurchaseType" meta:resourcekey="dropPurchaseTypeResource1" PropertyName="PurchaseTypeID" Caption="Purchase Type"></ui:UIFieldDropDownList>
                        <ui:UIFieldRadioList runat='server' ID="radioMinimumNumberOfQuotationsPolicy" meta:resourcekey="radioMinimumNumberOfQuotationsPolicyResource1" Caption="Quotation Policy" 
                            PropertyName="MinimumNumberOfQuotationsPolicy" RepeatColumns="0" RepeatDirection="Horizontal">
                            <Items>
                                <asp:ListItem Text="Any " Value="" meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem Text="Not required " Value="0" meta:resourcekey="ListItemResource2"></asp:ListItem>
                                <asp:ListItem Text="Preferred " Value="1" meta:resourcekey="ListItemResource3"></asp:ListItem>
                                <asp:ListItem Text="Required " Value="2" meta:resourcekey="ListItemResource4"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTextBox runat="server" id="textMinimumNumberOfQuotations" meta:resourcekey="textMinimumNumberOfQuotationsResource1" PropertyName="MinimumNumberOfQuotations" SearchType="Range" 
                            Caption="Minimum Quotations" span="Half"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" id="textMinimumApplicableRFQAmount" meta:resourcekey="textMinimumApplicableRFQAmountResource1"
                            PropertyName="MinimumApplicableRFQAmount" 
                            Caption="Min Applicable Amount" span="Half" 
                            SearchType="Range"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat='server' ID="radioRFQToPOPolicy" meta:resourcekey="radioRFQToPOPolicyResource1" 
                        Caption="RFQ-to-PO Policy"
                            CaptionWidth="120px" PropertyName="RFQToPOPolicy" RepeatColumns="0" RepeatDirection="Horizontal">
                            <Items>
                                <asp:ListItem Text="Any " Value="" meta:resourcekey="ListItemResource5"></asp:ListItem>
                                <asp:ListItem Text="Not required " Value="0" meta:resourcekey="ListItemResource6"></asp:ListItem>
                                <asp:ListItem Text="Preferred " meta:resourcekey="ListItemResource7"
                                    Value="1"></asp:ListItem>
                                <asp:ListItem Text="Required " meta:resourcekey="ListItemResource8"
                                    Value="2"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldRadioList runat="server" id="radioBudgetValidationPolicy" meta:resourcekey="radioBudgetValidationPolicyResource1" PropertyName="BudgetValidationPolicy" Caption="Budget Validation Policy">
                            <Items>
                                <asp:ListItem Value="" Text="Any" meta:resourcekey="ListItemResource9"></asp:ListItem>
                                <asp:ListItem Value="0" Text="Budget = Line Items" meta:resourcekey="ListItemResource10"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Budget <= Line Items" meta:resourcekey="ListItemResource11"></asp:ListItem>
                                <asp:ListItem Value="2" Text="Budget Not Required" meta:resourcekey="ListItemResource12"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabResults" Caption="Results" meta:resourcekey="tabResultsResource1">
                        <ui:UIButton runat="server" ID="buttonMassUpdate" meta:resourcekey="buttonMassUpdateResource1" Text="Update Multiple Settings" OnClick="buttonMassUpdate_Click" ImageUrl="~/images/add.gif" />
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridResults" meta:resourcekey="gridResultsResource1" KeyName="ObjectID" Width="100%" PageSize="1000" SortExpression="Location.Path, PurchaseType.ObjectName">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1"
                                    CommandName="EditObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2"
                                    CommandName="ViewObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3"
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Location.Path" HeaderText="Location" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="PurchaseType.ObjectName" HeaderText="Purchase Type" meta:resourcekey="UIGridViewBoundColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="MinimumNumberOfQuotationsPolicyText" HeaderText="Minimum Quotations Policy" meta:resourcekey="UIGridViewBoundColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="MinimumNumberOfQuotations" HeaderText="Minimum Quotations" meta:resourcekey="UIGridViewBoundColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="MinimumApplicableRFQAmount" HeaderText="Min RFQ Amount" DataFormatString="{0:c}" meta:resourcekey="UIGridViewBoundColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="RFQToPOPolicyText" HeaderText="RFQ-to-PO Policy" meta:resourcekey="UIGridViewBoundColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="MinimumApplicablePOAmount" HeaderText="Min PO Amount" DataFormatString="{0:c}" meta:resourcekey="UIGridViewBoundColumnResource7">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BudgetValidationPolicyText" HeaderText="Budget Validation Policy" meta:resourcekey="UIGridViewBoundColumnResource8">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1"></ui:UIGridViewCommand> 
                            </Commands>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
