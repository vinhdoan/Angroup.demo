<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

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
        dropCurrency.Bind(OCurrency.GetAllCurrencies());
        dropTaxCode.Bind(OTaxCode.GetAllTaxCodes());
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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelResource1">
        <web:search runat="server" ID="panel" Caption="Vendor" GridViewID="gridResults" BaseTable="tVendor"
            EditButtonVisible="false" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Search" meta:resourcekey="uitabview1Resource1">
                    <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName" Caption="Name"
                        ToolTip="The vendor name." Span="full" meta:resourcekey="NameResource1" MaxLength="255" />
                    <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID"
                        Caption="Default Currency" meta:resourcekey="dropCurrencyResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="dropTaxCode" PropertyName="TaxCodeID"
                        Caption="Default Tax Code" meta:resourcekey="dropTaxCodeResource1">
                    </ui:UIFieldDropDownList>
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="sep1" Caption="Operating Location" meta:resourcekey="sep1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressCountry" PropertyName="OperatingAddressCountry"
                        Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressCountryResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressState" PropertyName="OperatingAddressState"
                        Caption="State" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressStateResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressCity" PropertyName="OperatingAddressCity"
                        Caption="City" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressCityResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddress" PropertyName="OperatingAddress"
                        Caption="Address" MaxLength="255" meta:resourcekey="OperatingAddressResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingCellPhone" PropertyName="OperatingCellPhone"
                        Caption="Cellphone" Span="Half" meta:resourcekey="OperatingCellPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingEmail" PropertyName="OperatingEmail"
                        Caption="Email" Span="Half" meta:resourcekey="OperatingEmailResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingFax" PropertyName="OperatingFax" Caption="Fax"
                        Span="Half" meta:resourcekey="OperatingFaxResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingPhone" PropertyName="OperatingPhone"
                        Caption="Phone" Span="Half" meta:resourcekey="OperatingPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingContactPerson" PropertyName="OperatingContactPerson"
                        Caption="Contact Person" meta:resourcekey="OperatingContactPersonResource1" />
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="Separator2" Caption="Billing Location" meta:resourcekey="Separator2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressCountry" PropertyName="BillingAddressCountry"
                        Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressCountryResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressState" PropertyName="BillingAddressState"
                        Caption="State" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressStateResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressCity" PropertyName="BillingAddressCity"
                        Caption="City" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressCityResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddress" PropertyName="BillingAddress"
                        Caption="Address" MaxLength="255" meta:resourcekey="BillingAddressResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingCellPhone" PropertyName="BillingCellPhone"
                        Caption="Cellphone" Span="Half" meta:resourcekey="BillingCellPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingEmail" PropertyName="BillingEmail" Caption="Email"
                        Span="Half" meta:resourcekey="BillingEmailResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingFax" PropertyName="BillingFax" Caption="Fax"
                        Span="Half" meta:resourcekey="BillingFaxResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingPhone" PropertyName="BillingPhone" Caption="Phone"
                        Span="Half" meta:resourcekey="BillingPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingContactPerson" PropertyName="BillingContactPerson"
                        Caption="Contact Person" meta:resourcekey="BillingContactPersonResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Results" meta:resourcekey="uitabview2Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                        meta:resourcekey="gridResultsResource1" Width="100%">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewObject"
                                HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                HeaderText="" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewColumnResource3">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewColumnResource4">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Email" PropertyName="BillingEmail" meta:resourcekey="UIGridViewColumnResource13">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Phone" PropertyName="BillingPhone" meta:resourcekey="UIGridViewColumnResource14">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Cell Phone" PropertyName="BillingCellPhone"
                                meta:resourcekey="UIGridViewColumnResource15">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Fax" PropertyName="BillingFax" meta:resourcekey="UIGridViewColumnResource16">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Contact Person" PropertyName="BillingContactPerson"
                                meta:resourcekey="UIGridViewColumnResource17">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Currency.ObjectName" HeaderText="Default Currency" meta:resourcekey="UIGridViewBoundColumnResource1">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TaxCode.ObjectName" HeaderText="Default Tax Code" meta:resourcekey="UIGridViewBoundColumnResource2">
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
