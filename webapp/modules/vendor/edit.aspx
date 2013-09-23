<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectpanel.ascx" TagPrefix="web" TagName="object" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
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
        OVendor vendor = panel.SessionObject as OVendor;

        if (vendor.IsNew)
            vendor.CurrencyID = OApplicationSetting.Current.BaseCurrencyID;        
        
        dropCurrency.Bind(OCurrency.GetAllCurrencies());
        dropTaxCode.Bind(OTaxCode.GetAllTaxCodes(DateTime.Today, null));
        VendorType.Bind(OCode.GetCodesByType("VendorType", null));
        VendorClassification.Bind(OCode.GetCodesByType("VendorClassification", vendor.VendorClassificationID));

        List<OUser> listUser = OUser.GetUsersByRole("VENDORADMIN");
        Person1.Bind(listUser);
        Person2.Bind(listUser);
        Person3.Bind(listUser);
        Person4.Bind(listUser);
    }


    /// <summary>
    /// Validates the vendor object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_Validate(object sender, PersistentObject o)
    {
        OVendor vendor = panel.SessionObject as OVendor;

        // Validate
        //
        if (vendor.IsDuplicateName())
            objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
    }
    
    
    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (Debarment.Checked)
        {
            panel1.Visible = true;
        }
        else
        {
            panel1.Visible = false;
        }
    }

    /// <summary>
    /// Occurs when the user updates the Debarment checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Debarment_CheckedChanged(object sender, EventArgs e)
    {
    }

    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelResource1">
            <web:object runat="server" ID="panel" Caption="Vendor" BaseTable="tVendor" AutomaticBindingAndSaving="true"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidate="panel_Validate">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="Vendor Name"
                            meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIFieldCheckboxList runat="server" ID="VendorType" Caption="Vendor Type" PropertyName="VendorTypes" meta:resourcekey="VendorTypeResource1"/>
                        <ui:UIFieldDropDownList runat="server" ID="VendorClassification" Caption="Vendor Classification"
                            PropertyName="VendorClassificationID" Span="Half" meta:resourcekey="VendorClassificationResource1"/>
                        <br />
                        <br />
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Currency and Tax" meta:resourcekey="UISeparator2Resource1"/>
                        <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID" Caption="Default Currency" ValidateRequiredField="true" meta:resourcekey="dropCurrencyResource1">
                            </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropTaxCode" PropertyName="TaxCodeID" Caption="Default Tax Code" ValidateRequiredField="true" meta:resourcekey="dropTaxCodeResource1"></ui:UIFieldDropDownList>
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
                        <ui:UISeparator runat="server" ID="Separator1" Caption="Billing Location" meta:resourcekey="Separator1Resource1" />
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
                    <ui:UITabView runat="server" ID="tabDebarment" Caption="Debarment" meta:resourcekey="tabDebarmentResource1">
                        <ui:UIFieldCheckBox runat="server" ID="Debarment" Caption="Debarment" PropertyName="IsDebarred"
                            Text="Yes, this vendor is debarred" OnCheckedChanged="Debarment_CheckedChanged" meta:resourcekey="DebarmentResource2"/>
                        <ui:UIPanel runat="server" ID="panel1" meta:resourcekey="tabDebarmentResource1">
                            <ui:UIFieldDateTime runat="server" ID="StartDate" Caption="Start Date" PropertyName="DebarmentStartDate"
                                Span="Half" ValidationCompareType="Date" ValidateCompareField="True" ValidationCompareControl="EndDate"
                                ValidationCompareOperator="LessThanEqual" ValidateRequiredField="true" meta:resourcekey="StartDateResource1"/>
                            <ui:UIFieldDateTime runat="server" ID="EndDate" Caption="End Date" PropertyName="DebarmentEndDate"
                                Span="Half" ValidationCompareType="Date" ValidateCompareField="True" ValidationCompareControl="StartDate"
                                ValidationCompareOperator="GreaterThanEqual" ValidateRequiredField="true" meta:resourcekey="EndDateResource1"/>
                            <ui:UIFieldTextBox runat="server" ID="DebarmentReason" Caption="Reason" PropertyName="DebarmentReason"
                                TextMode="MultiLine" Rows="3" ValidateRequiredField="true" meta:resourcekey="DebarmentReasonResource1"/>
                            <br />
                            <ui:UISeparator runat="server" ID="UISeparator1" Caption="People to Notify " meta:resourcekey="UISeparator1Resource1"/>
                            <ui:UIFieldDropDownList runat="server" ID="Person1" Caption="Person1" PropertyName="NotifyUser1ID"
                                Span="Half" meta:resourcekey="Person1Resource1"/>
                            <br />
                            <br />
                            <ui:UIFieldDropDownList runat="server" ID="Person2" Caption="Person2" PropertyName="NotifyUser2ID"
                                Span="Half" meta:resourcekey="Person2Resource1"/>
                            <br />
                            <br />
                            <ui:UIFieldDropDownList runat="server" ID="Person3" Caption="Person3" PropertyName="NotifyUser3ID"
                                Span="Half" meta:resourcekey="Person3Resource1"/>
                            <br />
                            <br />
                            <ui:UIFieldDropDownList runat="server" ID="Person4" Caption="Person4" PropertyName="NotifyUser4ID"
                                Span="Half" meta:resourcekey="Person4Resource1"/>
                            <br />
                            <ui:UISeparator runat="server" ID="Separator2" Caption="Notification Time" meta:resourcekey="Separator2Resource2"/>
                            <ui:UIFieldLabel runat="server" ID="lb" Caption="Notification before Debarment End Date (Days)"
                                CaptionWidth="400px" meta:resourcekey="lbResource1"/>
                            <ui:UIFieldTextBox runat="server" ID="First" Caption="First" PropertyName="DebarmentNotification1Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="true" ValidateRangeField="true"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="FirstResource1"/>
                            <br />
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="Second" Caption="Second" PropertyName="DebarmentNotification2Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="true" ValidateRangeField="true"
                                ValidationRangeMin="0" ValidationRangeType="Integer" ValidateCompareField="true"
                                ValidationCompareControl="First" ValidationCompareType="Integer" ValidationCompareOperator="LessThanEqual" meta:resourcekey="SecondResource1" />
                            <br />
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="Third" Caption="Third" PropertyName="DebarmentNotification3Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="true" ValidateRangeField="true"
                                ValidationRangeMin="0" ValidationRangeType="Integer" ValidateCompareField="true"
                                ValidationCompareControl="Second" ValidationCompareType="Integer" ValidationCompareOperator="LessThanEqual"  meta:resourcekey="ThirdResource1"/>
                            <br />
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="Fourth" Caption="Fourth" PropertyName="DebarmentNotification4Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="true" ValidateRangeField="true"
                                ValidationRangeMin="0" ValidationRangeType="Integer" ValidateCompareField="true"
                                ValidationCompareControl="Third" ValidationCompareType="Integer" ValidationCompareOperator="LessThanEqual" meta:resourcekey="FourthResource1" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview8" Caption="Memo"  meta:resourcekey="uitabview8Resource1">
                        <web:memo ID="Memo1" runat="server" meta:resourcekey="uitabview8Resource1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview5" Caption="Attachments" 
                        meta:resourcekey="uitabview5Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
