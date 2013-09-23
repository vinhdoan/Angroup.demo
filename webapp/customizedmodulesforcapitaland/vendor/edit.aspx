<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectpanel.ascx" TagPrefix="web" TagName="object" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

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

        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
        {
            OperatingAddressPostalCode.Visible = false;
            BillingAddressPostalCode.Visible = false;
        }
        
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


    protected void VendorContact_subpanel_PopulateForm(object sender, EventArgs e)
    {
        OVendorContact vContact = VendorContact_subpanel.SessionObject as OVendorContact;
        objectpanelVendorContact.BindObjectToControls(vContact);
    }

    protected void VendorContact_subpanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OVendorContact vContact = VendorContact_subpanel.SessionObject as OVendorContact;
        objectpanelVendorContact.BindControlsToObject(vContact);
        OVendor vendor = panel.SessionObject as OVendor;
        vendor.VendorContacts.Add(vContact);
        panelVendorContact.BindObjectToControls(vendor);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelResource1" BorderStyle="NotSet">
            <web:object runat="server" ID="panel" Caption="Vendor" BaseTable="tVendor" AutomaticBindingAndSaving="true"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidate="panel_Validate">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="Vendor Name"
                            meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIFieldTextBox runat="server" ID="GSTRegistrationNumber" 
                            PropertyName="GSTRegistrationNumber" Span="Half"
                         Caption="GST Registration Number" 
                            meta:resourcekey="GSTRegistrationNumberResource1" InternalControlWidth="95%"></ui:UIFieldTextBox>
                         <ui:UIFieldTextBox runat="server" ID="CompanyRegistrationNumber" 
                            PropertyName="CompanyRegistrationNumber" Span="Half"
                         Caption="Company Registration Number" 
                            meta:resourcekey="CompanyRegistrationNumberResource1" 
                            InternalControlWidth="95%"></ui:UIFieldTextBox>
                         <ui:UIFieldCheckBox runat="server" ID="checkIsInterestedParty" 
                            PropertyName="IsInterestedParty" Caption="Interested Party?" 
                            Text="Yes, this vendor is an Interested Party and takes part in IPT with your company" 
                            ForeColor="Red" meta:resourcekey="checkIsInterestedPartyResource1" 
                            TextAlign="Right"></ui:UIFieldCheckBox>
                        <ui:UIFieldCheckboxList runat="server" ID="VendorType" Caption="Vendor Type" PropertyName="VendorTypes" meta:resourcekey="VendorTypeResource1" TextAlign="Right"/>
                        <ui:UIFieldDropDownList runat="server" ID="VendorClassification" Caption="Vendor Classification"
                            PropertyName="VendorClassificationID" Span="Half" meta:resourcekey="VendorClassificationResource1"/>
                        <ui:UIFieldTextBox runat="server" ID="textVendorSAPCode" Caption="SAP Code" PropertyName="VendorSAPCode" Span="Half"></ui:UIFieldTextBox>
                        <br />
                        <br />
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Currency and Tax" meta:resourcekey="UISeparator2Resource1"/>
                        <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID" Caption="Default Currency" ValidateRequiredField="True" meta:resourcekey="dropCurrencyResource1">
                            </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropTaxCode" PropertyName="TaxCodeID" Caption="Default Tax Code" meta:resourcekey="dropTaxCodeResource1"></ui:UIFieldDropDownList>
                        <ui:UISeparator runat="server" ID="sep1" Caption="Operating Location" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="OperatingAddressCountry" PropertyName="OperatingAddressCountry" ValidateRequiredField="true"
                            Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressCountryResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="OperatingAddressState" PropertyName="OperatingAddressState"
                            Caption="State" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressStateResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="OperatingAddressCity" PropertyName="OperatingAddressCity"
                            Caption="City" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressCityResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="OperatingAddressPostalCode" PropertyName="OperatingAddressPostalCode" ValidateRequiredField="true"
                            Caption="Postal Code" Span="Half" MaxLength="255" meta:resourcekey="OperatingAddressPostalCodeResource1" InternalControlWidth="95%" />    
                        <ui:UIFieldTextBox runat="server" ID="OperatingAddress" PropertyName="OperatingAddress" ValidateRequiredField="true"
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
                        <ui:UISeparator runat="server" ID="Separator1" Caption="Billing Location" meta:resourcekey="Separator1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="BillingAddressCountry" PropertyName="BillingAddressCountry"
                            Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressCountryResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="BillingAddressState" PropertyName="BillingAddressState"
                            Caption="State" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressStateResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="BillingAddressCity" PropertyName="BillingAddressCity"
                            Caption="City" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressCityResource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="BillingAddressPostalCode" PropertyName="BillingAddressPostalCode"
                            Caption="Postal Code" Span="Half" MaxLength="255" meta:resourcekey="BillingAddressPostalCodeResource1" InternalControlWidth="95%" />
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
                            Caption="Contact Person" meta:resourcekey="BillingContactPersonResource1" InternalControlWidth="95%" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabDebarment" Caption="Debarment" meta:resourcekey="tabDebarmentResource1" BorderStyle="NotSet">
                        <ui:UIFieldCheckBox runat="server" ID="Debarment" Caption="Debarment" PropertyName="IsDebarred"
                            Text="Yes, this vendor is debarred" OnCheckedChanged="Debarment_CheckedChanged" meta:resourcekey="DebarmentResource2" TextAlign="Right"/>
                        <ui:UIPanel runat="server" ID="panel1" meta:resourcekey="tabDebarmentResource1" BorderStyle="NotSet">
                            <ui:UIFieldDateTime runat="server" ID="StartDate" Caption="Start Date" PropertyName="DebarmentStartDate"
                                Span="Half" ValidationCompareType="Date" ValidateCompareField="True" ValidationCompareControl="EndDate"
                                ValidationCompareOperator="LessThanEqual" ValidateRequiredField="True" 
                                meta:resourcekey="StartDateResource1" ShowDateControls="True" ImageUrl=""/>
                            <ui:UIFieldDateTime runat="server" ID="EndDate" Caption="End Date" PropertyName="DebarmentEndDate"
                                Span="Half" ValidationCompareType="Date" ValidateCompareField="True" ValidationCompareControl="StartDate"
                                ValidationCompareOperator="GreaterThanEqual" ValidateRequiredField="True" 
                                meta:resourcekey="EndDateResource1" ShowDateControls="True" ImageUrl=""/>
                            <ui:UIFieldTextBox runat="server" ID="DebarmentReason" Caption="Reason" PropertyName="DebarmentReason"
                                TextMode="MultiLine" Rows="3" ValidateRequiredField="True" meta:resourcekey="DebarmentReasonResource1" InternalControlWidth="95%"/>
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
                                CaptionWidth="400px" meta:resourcekey="lbResource1" DataFormatString=""/>
                            <ui:UIFieldTextBox runat="server" ID="First" Caption="First" PropertyName="DebarmentNotification1Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="FirstResource1" InternalControlWidth="95%"/>
                            <br />
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="Second" Caption="Second" PropertyName="DebarmentNotification2Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" ValidateCompareField="True"
                                ValidationCompareControl="First" ValidationCompareType="Integer" ValidationCompareOperator="LessThanEqual" meta:resourcekey="SecondResource1" InternalControlWidth="95%" />
                            <br />
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="Third" Caption="Third" PropertyName="DebarmentNotification3Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" ValidateCompareField="True"
                                ValidationCompareControl="Second" ValidationCompareType="Integer" ValidationCompareOperator="LessThanEqual"  meta:resourcekey="ThirdResource1" InternalControlWidth="95%"/>
                            <br />
                            <br />
                            <ui:UIFieldTextBox runat="server" ID="Fourth" Caption="Fourth" PropertyName="DebarmentNotification4Days"
                                ValidationDataType="Integer" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" ValidateCompareField="True"
                                ValidationCompareControl="Third" ValidationCompareType="Integer" ValidationCompareOperator="LessThanEqual" meta:resourcekey="FourthResource1" InternalControlWidth="95%" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabVendorContact" Caption="Vendor Contact" BorderStyle="NotSet" meta:resourcekey="tabVendorContactResource1">
                         <ui:uipanel runat="server" id="panelVendorContact" BorderStyle="NotSet" meta:resourcekey="panelVendorContactResource1">
                    <ui:UIGridView runat="server" id="gridVendorContact" PropertyName="VendorContacts" 
                                 Caption="Vendor Contacts" DataKeyNames="ObjectID" GridLines="Both" 
                                 meta:resourcekey="gridVendorContactResource1" RowErrorColor="" 
                                 style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" CommandText="Edit" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Position" HeaderText="Position" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Position" ResourceAssemblyName="" SortExpression="Position">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ClientDept" HeaderText="Client Dept" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="ClientDept" ResourceAssemblyName="" SortExpression="ClientDept">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Phone" HeaderText="Phone" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Phone" ResourceAssemblyName="" SortExpression="Phone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Cellphone" HeaderText="Cellphone" meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="Cellphone" ResourceAssemblyName="" SortExpression="Cellphone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Fax" HeaderText="Fax" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="Fax" ResourceAssemblyName="" SortExpression="Fax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Email" HeaderText="Email" meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="Email" ResourceAssemblyName="" SortExpression="Email">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:uiobjectpanel runat="server" id="objectpanelVendorContact" BorderStyle="NotSet" meta:resourcekey="objectpanelVendorContactResource1">
                        <web:subpanel runat="server" id="VendorContact_subpanel" GridViewID="gridVendorContact"   OnPopulateForm="VendorContact_subpanel_PopulateForm" OnValidateAndUpdate="VendorContact_subpanel_ValidateAndUpdate" />
                        <ui:UIFieldTextBox runat="server" ID="txtContactName" PropertyName="ObjectName" Caption="Name" ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="txtContactNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="Position" Caption="Position" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox1Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox2" PropertyName="ClientDept" Caption="Client Dept" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox2Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox3" PropertyName="Phone" Caption="Phone" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox3Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox4" PropertyName="Cellphone" Caption="Cellphone" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox4Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox5" PropertyName="Fax" Caption="Fax" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox5Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox6" PropertyName="Email" Caption="Email" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox6Resource1"></ui:UIFieldTextBox>
                    </ui:uiobjectpanel>
                    </ui:uipanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview8" Caption="Memo"  meta:resourcekey="uitabview8Resource1" BorderStyle="NotSet">
                        <web:memo ID="Memo1" runat="server" meta:resourcekey="uitabview8Resource1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview5" Caption="Attachments" 
                        meta:resourcekey="uitabview5Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
