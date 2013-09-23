<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    
    protected static class GridViewResults
    {
        public static int IsInterestedParty = 11;
        public static int IsInActive = 13;
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        dropCurrency.Bind(OCurrency.GetAllCurrencies());
        dropTaxCode.Bind(OTaxCode.GetAllTaxCodes());
    }


    /// <summary>
    /// Occurs everytime the row is databound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Footer ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[GridViewResults.IsInterestedParty].Visible = false;
            e.Row.Cells[GridViewResults.IsInActive].Visible = false;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[GridViewResults.IsInActive].Text == "1")
                e.Row.ForeColor = Color.Gray;
            else if (e.Row.Cells[GridViewResults.IsInterestedParty].Text == "1")
                e.Row.ForeColor = Color.Red;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelResource1"
        BorderStyle="NotSet">
        <web:search runat="server" ID="panel" Caption="Vendor" GridViewID="gridResults" BaseTable="tVendor"
            SearchType="ObjectQuery" AutoSearchOnLoad="false" MaximumNumberOfResults="100"
            SearchTextBoxHint="E.g. Vendor Name, Contact Email, Contact Person, Company Registration Number" SearchTextBoxPropertyNames="ObjectName,OperatingEmail,OperatingContactPerson, CompanyRegistrationNumber"
            AdvancedSearchPanelID="panelAdvanced" EditButtonVisible="false" meta:resourcekey="panelResource1"
            OnPopulateForm="panel_PopulateForm"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Search" meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <%--<ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName" Caption="Name"
                        ToolTip="The vendor name." meta:resourcekey="NameResource1" MaxLength="255" InternalControlWidth="95%" />--%>
                <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID"
                    Caption="Default Currency" meta:resourcekey="dropCurrencyResource1">
                </ui:UIFieldDropDownList>
                <ui:UIFieldDropDownList runat="server" ID="dropTaxCode" PropertyName="TaxCodeID"
                    Caption="Default Tax Code" meta:resourcekey="dropTaxCodeResource1">
                </ui:UIFieldDropDownList>
                <ui:UIFieldCheckBox runat="server" ID="checkIsInterestedParty" PropertyName="IsInterestedParty"
                    Caption="Interested Party?" ForeColor="Red" Text="Yes, this vendor is an Interested Party and takes part in IPT with your company"
                    TextAlign="Right">
                </ui:UIFieldCheckBox>
                <ui:UIFieldRadioList ID="IsInActive" runat="server" Span="Half"
                            Caption="Active?" RepeatDirection="Vertical"
                            PropertyName="IsInActive" TextAlign="Right">
                            <Items>                                
                                <asp:ListItem Value="0" Text="Yes"></asp:ListItem>
                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                            </Items>
                </ui:UIFieldRadioList>
                <ui:UIFieldRadioList ID="IsApproved" runat="server" Span="Half"
                            Caption="Approve?" RepeatDirection="Vertical"
                            PropertyName="IsApproved" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                <asp:ListItem Value="0" Text="No"></asp:ListItem>
                            </Items>
                </ui:UIFieldRadioList>
                <ui:UIFieldRadioList ID="IsDebarred" runat="server" Span="Half"
                            Caption="Debarred?" RepeatDirection="Vertical"
                            PropertyName="IsDebarred" TextAlign="Right">
                            <Items>                                
                                <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                <asp:ListItem Value="0" Text="No"></asp:ListItem>
                            </Items>
                </ui:UIFieldRadioList>
                <br />
                <%--<ui:UISeparator runat="server" ID="sep1" Caption="Operating Location" meta:resourcekey="sep1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressCountry" PropertyName="OperatingAddressCountry"
                        Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressCountryResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressState" PropertyName="OperatingAddressState"
                        Caption="State" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressStateResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressCity" PropertyName="OperatingAddressCity"
                        Caption="City" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressCityResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddress" PropertyName="OperatingAddress"
                        Caption="Address" MaxLength="255" meta:resourcekey="OperatingAddressResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingCellPhone" PropertyName="OperatingCellPhone"
                        Caption="Cellphone" Span="Half" meta:resourcekey="OperatingCellPhoneResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingEmail" PropertyName="OperatingEmail"
                        Caption="Email" Span="Half" meta:resourcekey="OperatingEmailResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingFax" PropertyName="OperatingFax" Caption="Fax"
                        Span="Half" meta:resourcekey="OperatingFaxResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingPhone" PropertyName="OperatingPhone"
                        Caption="Phone" Span="Half" meta:resourcekey="OperatingPhoneResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingContactPerson" PropertyName="OperatingContactPerson"
                        Caption="Contact Person" meta:resourcekey="OperatingContactPersonResource1" InternalControlWidth="95%" />
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="Separator2" Caption="Billing Location" meta:resourcekey="Separator2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressCountry" PropertyName="BillingAddressCountry"
                        Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressCountryResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressState" PropertyName="BillingAddressState"
                        Caption="State" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressStateResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressCity" PropertyName="BillingAddressCity"
                        Caption="City" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressCityResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddress" PropertyName="BillingAddress"
                        Caption="Address" MaxLength="255" meta:resourcekey="BillingAddressResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingCellPhone" PropertyName="BillingCellPhone"
                        Caption="Cellphone" Span="Half" meta:resourcekey="BillingCellPhoneResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingEmail" PropertyName="BillingEmail" Caption="Email"
                        Span="Half" meta:resourcekey="BillingEmailResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingFax" PropertyName="BillingFax" Caption="Fax"
                        Span="Half" meta:resourcekey="BillingFaxResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingPhone" PropertyName="BillingPhone" Caption="Phone"
                        Span="Half" meta:resourcekey="BillingPhoneResource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="BillingContactPerson" PropertyName="BillingContactPerson"
                        Caption="Contact Person" meta:resourcekey="BillingContactPersonResource1" InternalControlWidth="95%" />--%>
            </ui:UIPanel>
            <%--</ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Results" meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                meta:resourcekey="gridResultsResource1" Width="100%" DataKeyNames="ObjectID"
                GridLines="Both" RowErrorColor="" Style="clear: both;" OnRowDataBound="gridResults_RowDataBound"
                ImageRowErrorUrl="">
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
                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" meta:resourceKey="UIGridViewColumnResource4"
                        PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <%--<cc1:UIGridViewBoundColumn DataField="OperatingEmail" HeaderText="Operating Email" PropertyName="OperatingEmail" ResourceAssemblyName="" SortExpression="OperatingEmail">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="OperatingPhone" HeaderText="Phone" meta:resourceKey="UIGridViewColumnResource14" PropertyName="OperatingPhone" ResourceAssemblyName="" SortExpression="OperatingPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="OperatingCellPhone" HeaderText="Cell Phone" meta:resourceKey="UIGridViewColumnResource15" PropertyName="OperatingCellPhone" ResourceAssemblyName="" SortExpression="OperatingCellPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="OperatingFax" HeaderText="Fax" meta:resourceKey="UIGridViewColumnResource16" PropertyName="OperatingFax" ResourceAssemblyName="" SortExpression="OperatingFax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                    <cc1:UIGridViewBoundColumn DataField="OperatingAddressPostalCode" HeaderText="Postal Code"
                        meta:resourceKey="OperatingAddressPostalCodeResource" PropertyName="OperatingAddressPostalCode"
                        ResourceAssemblyName="" SortExpression="OperatingAddressPostalCode">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <%--<cc1:UIGridViewBoundColumn DataField="OperatingContactPerson" HeaderText="Contact Person" meta:resourceKey="UIGridViewColumnResource17" PropertyName="OperatingContactPerson" ResourceAssemblyName="" SortExpression="OperatingContactPerson">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                    <%--<cc1:UIGridViewBoundColumn DataField="BillingEmail" HeaderText="Billing Email" meta:resourceKey="UIGridViewColumnResource13" PropertyName="BillingEmail" ResourceAssemblyName="" SortExpression="BillingEmail">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="BillingPhone" HeaderText="Phone" meta:resourceKey="UIGridViewColumnResource14" PropertyName="BillingPhone" ResourceAssemblyName="" SortExpression="BillingPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="BillingCellPhone" HeaderText="Cell Phone" meta:resourceKey="UIGridViewColumnResource15" PropertyName="BillingCellPhone" ResourceAssemblyName="" SortExpression="BillingCellPhone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="BillingFax" HeaderText="Fax" meta:resourceKey="UIGridViewColumnResource16" PropertyName="BillingFax" ResourceAssemblyName="" SortExpression="BillingFax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                    <%--<cc1:UIGridViewBoundColumn DataField="BillingContactPerson" HeaderText="Contact Person" meta:resourceKey="UIGridViewColumnResource17" PropertyName="BillingContactPerson" ResourceAssemblyName="" SortExpression="BillingContactPerson">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                    <cc1:UIGridViewBoundColumn DataField="Currency.ObjectName" HeaderText="Default Currency"
                        meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Currency.ObjectName"
                        ResourceAssemblyName="" SortExpression="Currency.ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="TaxCode.ObjectName" HeaderText="Default Tax Code"
                        meta:resourceKey="UIGridViewBoundColumnResource2" PropertyName="TaxCode.ObjectName"
                        ResourceAssemblyName="" SortExpression="TaxCode.ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsApprovedText" HeaderText="Approved?" PropertyName="IsApprovedText"
                        ResourceAssemblyName="" SortExpression="IsApprovedText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsDebarredText" HeaderText="Debarred?" PropertyName="IsDebarredText"
                        ResourceAssemblyName="" SortExpression="IsDebarredText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsInterestedPartyText" HeaderText="Interested Party"
                        PropertyName="IsInterestedPartyText" ResourceAssemblyName="" SortExpression="IsInterestedPartyText"
                        meta:resourcekey="UIGridViewBoundColumnResource3">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsInterestedParty" PropertyName="IsInterestedParty"
                        ResourceAssemblyName="" SortExpression="IsInterestedParty" meta:resourcekey="UIGridViewBoundColumnResource4">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsActiveText" HeaderText="Active?" PropertyName="IsActiveText"
                        ResourceAssemblyName="" SortExpression="IsActiveText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsInActive" PropertyName="IsInActive" ResourceAssemblyName=""
                        SortExpression="IsInActive">
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
