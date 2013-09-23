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
    /// Populates the form controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OTenantContact tenantContact = panel.SessionObject as OTenantContact;

        ddlTenant.Bind(TablesLogic.tUser.LoadList(TablesLogic.tUser.isTenant==1));
        ddlTenantContactType.Bind(OCode.GetTenantContactTypes(AppSession.User,tenantContact.TenantContactTypeID));
        panel.ObjectPanel.BindObjectToControls(tenantContact);
        ManageAmosField(tenantContact.FromAmos);
    }


    /// <summary>
    /// Validates and saves the user object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OTenantContact tenantContact = (OTenantContact)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(tenantContact);
            tenantContact.Save();
            c.Commit();
        }
    }

    public void ManageAmosField(int? FromAmos)
    {
        ddlTenant.Enabled = !(FromAmos == 1);
        txtEmail.Enabled = !(FromAmos == 1);
        txtCellphone.Enabled = !(FromAmos == 1);
        txtFax.Enabled = !(FromAmos == 1);
        txtPhone.Enabled = !(FromAmos == 1);
        objectBase.ObjectName.Enabled = !(FromAmos == 1);
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Tenant Contact" BaseTable="tTenantContact"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="Tenant Contact Name"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldSearchableDropDownList runat="server" ID="ddlTenant" Caption="Tenant" PropertyName="TenantID" ValidateRequiredField="True" Span="Half" meta:resourcekey="ddlTenantResource1" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="ddlTenantContactType" PropertyName="TenantContactTypeID" ValidateRequiredField="True" Span="Half" Caption="Tenant Contact Type" meta:resourcekey="ddlTenantContactTypeResource1" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="Position"
                        Caption="Position" InternalControlWidth="95%" meta:resourcekey="uifieldstring4Resource2" />
                    <ui:UIFieldTextBox runat="server" ID="textDepartment" PropertyName="Department" Caption="Department" InternalControlWidth="95%" meta:resourcekey="textDepartmentResource1"  />
                    <ui:UIFieldTextBox runat="server" ID="txtDID" PropertyName="DID" Caption="DID" Span="Half" InternalControlWidth="95%" meta:resourcekey="txtDIDResource1"  />
                    <ui:UIFieldTextBox runat="server" ID="txtPhone" PropertyName="Phone" Caption="Phone" Span="Half" InternalControlWidth="95%" meta:resourcekey="txtPhoneResource1"  />
                    <ui:UIFieldTextBox runat="server" ID="txtFax" PropertyName="Fax"
                        Caption="Fax" Span="Half" InternalControlWidth="95%" meta:resourcekey="txtFaxResource1"  />
                    <ui:UIFieldTextBox runat="server" ID="txtCellphone" PropertyName="Cellphone"
                        Caption="Cell Phone" Span="Half" InternalControlWidth="95%" meta:resourcekey="txtCellphoneResource1"  />
                    <ui:UIFieldTextBox runat="server" ID="txtEmail" PropertyName="Email"  Caption="Email" Span="Half" InternalControlWidth="95%" meta:resourcekey="txtEmailResource1"  />
                    <ui:UIFieldTextBox runat="server" ID="txtLikes" PropertyName="Likes" Caption="Likes" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="txtLikesResource1"/>
                    <ui:UIFieldTextBox runat="server" ID="txtDislikes" PropertyName="Dislikes" Caption="Dislikes" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="txtDislikesResource1"/>
                    <ui:UIFieldTextBox runat="server" ID="txtInformation" PropertyName="AdditionalInformation" Caption="Additional Information" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="txtInformationResource1"/>
                </ui:UITabView>
                <ui:uitabview id="tabviewAmos" runat="server" borderstyle="NotSet" caption="Amos" Enabled="False" meta:resourcekey="tabviewAmosResource1">
                <ui:UISeparator runat="server" ID="AmosSeparator" Caption="Amos" meta:resourcekey="AmosSeparatorResource1" />
                    <ui:UIFieldCheckBox runat="server" ID="cbFromAmos" Caption="From Amos" PropertyName="FromAmos" meta:resourcekey="cbFromAmosResource1" TextAlign="Right"/>
                        <ui:uifieldtextbox id="AmosOrgID" runat="server" 
                        caption="Amos Org ID" internalcontrolwidth="95%" 
                        propertyname="AmosOrgID" Span = "Half" Enabled="False" meta:resourcekey="AmosOrgIDResource1"/>
                        <ui:uifieldtextbox id="AmosContactID" runat="server" 
                        caption="Amos Contact ID" internalcontrolwidth="95%" 
                        propertyname="AmosContactID" Span = "Half" Enabled="False" meta:resourcekey="AmosContactIDResource1"/>
                        <ui:uifieldtextbox id="AmosBillAddressID" runat="server" 
                        caption="Amos Bill Address ID" internalcontrolwidth="95%" 
                        propertyname="AmosBillAddressID" Span = "Half" Enabled="False" meta:resourcekey="AmosBillAddressIDResource1"/>
                        <ui:uifieldtextbox id="AddressLine1" runat="server" 
                        caption="Address Line 1" internalcontrolwidth="95%" 
                        propertyname="AddressLine1" Span = "Half" Enabled="False" meta:resourcekey="AddressLine1Resource1"/>
                        <ui:uifieldtextbox id="AddressLine2" runat="server" 
                        caption="Address Line 2" internalcontrolwidth="95%" 
                        propertyname="AddressLine2" Span = "Half" Enabled="False" meta:resourcekey="AddressLine2Resource1"/>
                        <ui:uifieldtextbox id="AddressLine3" runat="server" 
                        caption="Address Line 3" internalcontrolwidth="95%" 
                        propertyname="AddressLine3" Span = "Half" Enabled="False" meta:resourcekey="AddressLine3Resource1"/>
                        <ui:uifieldtextbox id="AddressLine4" runat="server" 
                        caption="Address Line 4" internalcontrolwidth="95%" 
                        propertyname="AddressLine4" Span = "Half" Enabled="False" meta:resourcekey="AddressLine4Resource1"/>
                        <ui:uifieldtextbox id="updatedOn" runat="server" 
                        caption="Updated On" internalcontrolwidth="95%" DataFormatString="{0:dd-MMM-yyyy}"
                        propertyname="updatedOn" Span = "Half" Enabled="False" meta:resourcekey="updatedOnResource1"/>
                </ui:uitabview>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1" BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
