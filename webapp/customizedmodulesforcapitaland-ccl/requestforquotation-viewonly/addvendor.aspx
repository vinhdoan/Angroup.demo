<%@ Page Language="C#" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Initializes the controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        dropCurrency.Bind(OCurrency.GetAllCurrencies());
    }


    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
    }

    /// <summary>
    /// Adds the WJ item object into the session object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = Session["::SessionObject::"] as ORequestForQuotation;

        int count = 0;
        StringBuilder duplicateVendors = new StringBuilder();
        List<ORequestForQuotationVendor> vendors = new List<ORequestForQuotationVendor>();
        foreach (GridViewRow row in gridResults.GetSelectedRows())
        {
            // Create an add object
            //
            Guid vendorId = (Guid)gridResults.DataKeys[row.RowIndex][0];

            if (!rfq.IsDuplicateVendorID(vendorId))
            {
                ORequestForQuotationVendor rfqVendor = rfq.CreateRequestForQuotationVendor(vendorId);
                vendors.Add(rfqVendor);
                count++;
            }
            else
            {
                OVendor vendor = TablesLogic.tVendor.Load(vendorId);
                if (duplicateVendors.Length != 0)
                    duplicateVendors.Append(", ");
                duplicateVendors.Append(vendor.ObjectName);
            }
        }

        if (duplicateVendors.Length > 0)
            panel.Message = String.Format(Resources.Errors.RequestForQuotation_DuplicateVendors, duplicateVendors.ToString());

        if ((panel.Message != null && panel.Message != "") || !panelAddVendors.IsValid)
            return;

        rfq.RequestForQuotationVendors.AddRange(vendors);
        Window.Opener.ClickUIButton("buttonVendorsAdded");
        Window.Close();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet"
        type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Add Vendors" GridViewID="gridResults" meta:resourcekey="panelResource1"
            AddSelectedButtonVisible="true" AddButtonVisible="false"
            EditButtonVisible="false" BaseTable="tVendor" OnSearch="panel_Search"
            OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery"
            SearchAssignedOnly="false" OnValidateAndAddSelected="panel_ValidateAndAddSelected">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                    <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName"
                        Caption="Name" ToolTip="The vendor name." MaxLength="255" 
                        InternalControlWidth="95%" meta:resourcekey="NameResource1" />
                    <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID"
                        Caption="Currency" meta:resourcekey="dropCurrencyResource1">
                    </ui:UIFieldDropDownList>
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="sep1" Caption="Operating Location" 
                        meta:resourcekey="sep1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressCountry"
                        PropertyName="OperatingAddressCountry" Caption="Country"
                        Span="Half" MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingAddressCountryResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressState"
                        PropertyName="OperatingAddressState" Caption="State" Span="Half"
                        MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingAddressStateResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddressCity" PropertyName="OperatingAddressCity"
                        Caption="City" Span="Half" MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingAddressCityResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingAddress" PropertyName="OperatingAddress"
                        Caption="Address" MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingAddressResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingCellPhone" PropertyName="OperatingCellPhone"
                        Caption="Cellphone" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingCellPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingEmail" PropertyName="OperatingEmail"
                        Caption="Email" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingEmailResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingFax" PropertyName="OperatingFax"
                        Caption="Fax" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingFaxResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingPhone" PropertyName="OperatingPhone"
                        Caption="Phone" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="OperatingPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="OperatingContactPerson"
                        PropertyName="OperatingContactPerson" Caption="Contact Person" 
                        InternalControlWidth="95%" meta:resourcekey="OperatingContactPersonResource1" />
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="Separator2" Caption="Billing Location" 
                        meta:resourcekey="Separator2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressCountry"
                        PropertyName="BillingAddressCountry" Caption="Country" Span="Half"
                        MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="BillingAddressCountryResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressState" PropertyName="BillingAddressState"
                        Caption="State" Span="Half" MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="BillingAddressStateResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddressCity" PropertyName="BillingAddressCity"
                        Caption="City" Span="Half" MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="BillingAddressCityResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingAddress" PropertyName="BillingAddress"
                        Caption="Address" MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="BillingAddressResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingCellPhone" PropertyName="BillingCellPhone"
                        Caption="Cellphone" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="BillingCellPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingEmail" PropertyName="BillingEmail"
                        Caption="Email" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="BillingEmailResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingFax" PropertyName="BillingFax"
                        Caption="Fax" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="BillingFaxResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingPhone" PropertyName="BillingPhone"
                        Caption="Phone" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="BillingPhoneResource1" />
                    <ui:UIFieldTextBox runat="server" ID="BillingContactPerson" PropertyName="BillingContactPerson"
                        Caption="Contact Person" InternalControlWidth="95%" 
                        meta:resourcekey="BillingContactPersonResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview2Resource1">
                    <ui:UIObjectPanel runat="server" ID="panelAddVendors" BorderStyle="NotSet" 
                        meta:resourcekey="panelAddVendorsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            BindObjectsToRows="True" Width="100%" SortExpression="ObjectName"
                            RowErrorColor="" SetValidationGroupForSelectedRowsOnly="True" 
                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                            meta:resourcekey="gridResultsResource1" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BillingEmail" HeaderText="Email" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="BillingEmail" 
                                    ResourceAssemblyName="" SortExpression="BillingEmail">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BillingPhone" HeaderText="Phone" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="BillingPhone" 
                                    ResourceAssemblyName="" SortExpression="BillingPhone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BillingCellPhone" HeaderText="Cell Phone" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" 
                                    PropertyName="BillingCellPhone" ResourceAssemblyName="" 
                                    SortExpression="BillingCellPhone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BillingFax" HeaderText="Fax" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="BillingFax" 
                                    ResourceAssemblyName="" SortExpression="BillingFax">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="BillingContactPerson" 
                                    HeaderText="Contact Person" meta:resourcekey="UIGridViewBoundColumnResource6" 
                                    PropertyName="BillingContactPerson" ResourceAssemblyName="" 
                                    SortExpression="BillingContactPerson">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Currency.ObjectName" 
                                    HeaderText="Currency" meta:resourcekey="UIGridViewBoundColumnResource7" 
                                    PropertyName="Currency.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Currency.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIObjectPanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
