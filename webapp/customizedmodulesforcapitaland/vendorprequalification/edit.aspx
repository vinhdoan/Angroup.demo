<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>
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
        OVendorPrequalification vendor = panel.SessionObject as OVendorPrequalification;
        objectBase.ObjectNumberVisible = !vendor.IsNew;

        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            gridVPVendor.Columns[7].HeaderText = "Justification";

        panel.ObjectPanel.BindObjectToControls(vendor);

    }

    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        tabDetails.Enabled = tabVendors.Enabled = !objectBase.CurrentObjectState.Is("Approved", "Cancelled");
        panelDetails.Enabled = !objectBase.CurrentObjectState.Is("Approved", "PendingApproval", "Cancelled");

        // For MARCOM only
        //
        if (ConfigurationManager.AppSettings["CustomizedInstance"]=="MARCOM")
        {
            txtsubject.Visible = false;
            txtpurpose.Visible = false;
            background.Visible = false;
            scope.Visible = false;
            justification.Visible = false;
            Evaluation.Visible = false;
            txtEstimatedContractSum.Visible = false;
            txtRemarks.Visible = false;
            panelBillingLocation.Visible = false;
            txtFinancialEvaluation.Caption = "Justification";
            txtFinancialEvaluation.ValidateRequiredField = true;
            gridVPVendor.Columns[7].HeaderText = "Justification";
        }
    }
    
    /// <summary>
    /// Validates and saves the craft object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OVendorPrequalification vendor = panel.SessionObject as OVendorPrequalification;
            panel.ObjectPanel.BindControlsToObject(vendor);
            
            if (objectBase.SelectedAction.Is("Approve","SubmitForApproval"))
            {
                string error = "";
                foreach (OVendorPrequalificationVendor v in vendor.VendorPrequalificationVendors)
                {
                    OVendor existing = TablesLogic.tVendor.Load(
                        TablesLogic.tVendor.ObjectName == v.ObjectName);
                    if (existing != null)
                        error += (error == "" ? "" : ", ") + existing.ObjectName;
                }
                if (error != "")
                    gridVPVendor.ErrorMessage = string.Format(Resources.Errors.VendorPrequalification_DuplicateVendorName, error);
            }
            if (objectBase.SelectedAction.Is("SubmitForApproval"))
            {
                bool atLeastOneRecommended = false;
                foreach (OVendorPrequalificationVendor v in vendor.VendorPrequalificationVendors)
                {
                    if (v.IsRecommended == 1)
                    {
                        atLeastOneRecommended = true;
                        break;
                    }
                }
                if (!atLeastOneRecommended)
                    gridVPVendor.ErrorMessage = Resources.Errors.VendorPrequalification_AtLeastOneRecommendedFailed;
            }
            
            vendor.Save();
            c.Commit();
        }
    }

    protected void VPVendor_subPanel_PopulateForm(object sender, EventArgs e)
    {
        OVendorPrequalificationVendor vpVendor = VPVendor_subPanel.SessionObject as OVendorPrequalificationVendor;
        dropCurrency.Bind(OCurrency.GetAllCurrencies());
        dropTaxCode.Bind(OTaxCode.GetAllTaxCodes(DateTime.Today, null));
        cblVendorType.Bind(OCode.GetCodesByType("VendorType", null));
        ddlVendorClassification.Bind(OCode.GetCodesByType("VendorClassification", vpVendor.VendorClassificationID));

        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
            PerformanceAppraisal.Visible = false;
        objectpanelVPVendor.BindObjectToControls(vpVendor);
    }

    protected void VPVendor_subPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OVendorPrequalificationVendor vpVendor = VPVendor_subPanel.SessionObject as OVendorPrequalificationVendor;
        objectpanelVPVendor.BindControlsToObject(vpVendor);
        OVendorPrequalification vendor = panel.SessionObject as OVendorPrequalification;
        vendor.VendorPrequalificationVendors.Add(vpVendor);
        panelVPVendor.BindObjectToControls(vendor);
    }

    protected void gridVPVendor_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[9].Visible = false;
            }
            if (e.Row.RowType == DataControlRowType.Header)
                e.Row.Cells[9].Visible = false;
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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Vendor Prequalification" BaseTable="tVendorPrequalification" OnPopulateForm="panel_PopulateForm"
                OnValidateAndSave="panel_ValidateAndSave"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberEnabled="false" 
                        ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false">
                        </web:base>
                        <ui:uipanel id="panelDetails" runat="server" borderstyle="NotSet" >
                        <ui:UIFieldTextBox runat="server" ID="txtsubject" Caption="Subject" PropertyName="Subject" ValidateRequiredField="true" MaxLength="255"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="txtpurpose" Caption="Purpose" PropertyName="Purpose" MaxLength="255"></ui:UIFieldTextBox>
                        <ui:UIFieldRichTextBox runat="server" ID="background" Caption="Background" PropertyName="Background" InternalControlHeight="100px"></ui:UIFieldRichTextBox>
                        <ui:UIFieldRichTextBox runat="server" ID="scope" Caption="Scope" PropertyName="Scope" InternalControlHeight="100px"></ui:UIFieldRichTextBox> 
                        <ui:UIFieldRichTextBox runat="server" ID="justification" Caption="Performance Appraisal" PropertyName="Justification" InternalControlHeight="100px"></ui:UIFieldRichTextBox>
                        <ui:UIFieldRichTextBox runat="server" ID="Evaluation" Caption="Evaluation" PropertyName="Evaluation" InternalControlHeight="100px"></ui:UIFieldRichTextBox> 
                        <ui:UIFieldTextBox runat="server" ID="txtEstimatedContractSum" Caption="Estimated Contract Sum" PropertyName="EstimatedContractSum" ValidateRequiredField="true" ValidationDataType="Currency" ValidateDataTypeCheck="true"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="txtRemarks" Caption="Remarks" PropertyName="Remarks" MaxLength="255"></ui:UIFieldTextBox>
                        </ui:uipanel>
                    </ui:UITabView>
                     <ui:UITabView runat="server" ID="tabVendors" Caption="Vendors" >
                        <%--<ui:UISeparator runat="server" ID="sep1"/>--%>
                        <ui:UIPanel runat="server" ID="panelVPVendor">
                        <ui:UIGridView runat="server" id="gridVPVendor" PropertyName="VendorPrequalificationVendors" Caption="Vendor Prequalification Vendors" ValidateRequiredField="true" OnRowDataBound="gridVPVendor_RowDataBound">
                        <Commands>
                            <ui:UIGridViewCommand CommandName="AddObject" ImageUrl="~/images/add.gif" CommandText="Add" />
                            <ui:UIGridViewCommand CommandName="RemoveObject" ImageUrl="~/images/delete.gif" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" />
                        </Commands>
                        <Columns>
                            <Ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" CommandText="Edit" AlwaysEnabled="true"></Ui:UIGridViewButtonColumn>
                            <Ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove this item?"></Ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Vendor Name"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Currency.ObjectName" HeaderText="Currency"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="TaxCode.ObjectName" HeaderText="Tax"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="VendorClassification.ObjectName" HeaderText="Vendor Classification"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="FinancialEvaluation" HeaderText="Financial Evaluation"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="PerformanceAppraisal" HeaderText="Justification"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="IsRecommendedText" HeaderText = "Recommended"></ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:uiobjectpanel runat="server" id="objectpanelVPVendor">
                        <web:subpanel runat="server" id="VPVendor_subPanel" GridViewID="gridVPVendor"  OnPopulateForm="VPVendor_subPanel_PopulateForm" OnValidateAndUpdate="VPVendor_subPanel_ValidateAndUpdate" />
                        <ui:uifieldtextbox runat="server" id="txtVendorName" PropertyName="ObjectName" Caption="Vendor Name" ValidateRequiredField="true"></ui:uifieldtextbox>
                        <ui:UIFieldTextBox runat="server" ID="GSTRegistrationNumber" PropertyName="GSTRegistrationNumber" Span="Half"
                         Caption="GST Registration Number" MaxLength="50" meta:resourcekey="GSTRegistrationNumberResource1"></ui:UIFieldTextBox>
                         <ui:UIFieldTextBox runat="server" ID="CompanyRegistrationNumber" PropertyName="CompanyRegistrationNumber" Span="Half"
                         Caption="Company Registration Number" MaxLength="50" meta:resourcekey="CompanyRegistrationNumberResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldCheckboxList runat="server" ID="cblVendorType" Caption="Vendor Type" PropertyName="VendorPrequalificationTypes"/>
                        <ui:UIFieldDropDownList runat="server" ID="ddlVendorClassification" Caption="Vendor Classification"
                            PropertyName="VendorClassificationID" Span="Half" />
                        <ui:UIFieldTextBox runat="server" ID="txtFinancialEvaluation" PropertyName="FinancialEvaluation"
                            Caption="Financial Evaluation" MaxLength="255"/>
                        <ui:UIFieldTextBox runat="server" ID="PerformanceAppraisal" PropertyName="PerformanceAppraisal"
                            Caption="Performance Appraisal" MaxLength="255"/>
                        <ui:UIFieldRadioList runat="server" ID="rdl_IsRecommended" PropertyName="IsRecommended" Caption="Recommended?" ValidateRequiredField="true">
                            <Items>
                                <asp:ListItem Value="1">Yes</asp:ListItem>
                                <asp:ListItem Value="0">No</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Currency and Tax" meta:resourcekey="UISeparator2Resource1"/>
                        <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID" Caption="Default Currency" ValidateRequiredField="true" meta:resourcekey="dropCurrencyResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropTaxCode" PropertyName="TaxCodeID" Caption="Default Tax Code" ValidateRequiredField="true" meta:resourcekey="dropTaxCodeResource1"></ui:UIFieldDropDownList>
                        <ui:UISeparator runat="server" ID="sep1" Caption="Operating Location" meta:resourcekey="sep1Resource1" />
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
                        <ui:UIPanel runat="server" ID="panelBillingLocation">
                        <ui:UISeparator runat="server" ID="Separator1" Caption="Billing Location" meta:resourcekey="Separator1Resource1" />
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
                            Caption="Contact Person" meta:resourcekey="BillingContactPersonResource1" InternalControlWidth="95%" />
                        </ui:UIPanel>
                        <ui:UISeparator runat="server" ID="UISeparator1" Caption="Others" />
                        <ui:UIFieldTextBox runat="server" ID="txtDescriptioin" PropertyName="Description"
                            Caption="Description" MaxLength="255"/>
                    </ui:uiobjectpanel>
                    </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
