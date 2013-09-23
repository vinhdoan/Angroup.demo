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
        OUser user = panel.SessionObject as OUser;

        ViewState["WasBanned"] = user.IsBanned;
        frameTheme.Attributes["src"] = "themepreview.aspx?THEME=" + user.ThemeName;
        ThemeName.Bind(GetThemes(), "Name", "Value", false);

        Password1.ValidateRequiredField = user.IsNew;
        Password2.ValidateRequiredField = user.IsNew;

        if (Request["MODE"] != null && Security.Decrypt(Request["MODE"]) == "EDITPROFILE")
        {
            tabMemo.Visible = false;
            tabAttachments.Visible = false;

            panel.DeleteButtonVisible = false;
            checkIsBanned.Visible = false;
            UserLoginName.Enabled = false;
            objectBase.ObjectNameEnabled = false;
            chkResetPassword.Visible = false;
            panel.SaveAndCloseButtonVisible = false;
            panel.SaveAndNewButtonVisible = false;
        }
        ddlTenantType.Bind(OCode.GetCodesByType("TenantType",user.TenantTypeID));
        ddl_Language.Bind(OLanguage.GetAllLanguages(), "ObjectName", "CultureCode");
        gridActivities.Bind(OUser.TenantActivityList(user.ObjectID));
        gridCases.Bind(OUser.CaseList(user.ObjectID));
        panel.ObjectPanel.BindObjectToControls(user);
        ManageAmosField(user.FromAmos);
    }


    /// <summary>
    /// 
    /// Validates and saves the user object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OUser user = (OUser)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(user);

            // Ensure no duplicate users with the same
            // name and login ID.
            //
            if (user.IsDuplicateUser())
            {
                this.UserLoginName.ErrorMessage = Resources.Errors.User_DuplicateUser;
                this.objectBase.ObjectName.ErrorMessage = Resources.Errors.User_DuplicateUser;
            }


            // Validate's the user password
            //
            if (Password1.Text.ToString() != "" || Password2.Text.ToString() != "")
            {
                if (Password1.Text.ToString() != Password2.Text.ToString())
                {
                    Password1.ErrorMessage = Resources.Errors.User_PasswordDifferent;
                    Password2.ErrorMessage = Resources.Errors.User_PasswordDifferent;
                }
                else
                {
                    OApplicationSetting applicationSetting = OApplicationSetting.Current;

                    // Ensures that the password adheres to the minimum
                    // length requirement.
                    //
                    if (applicationSetting.PasswordMinimumLength != null &&
                        Password1.Text.Length < applicationSetting.PasswordMinimumLength.Value)
                    {
                        Password1.ErrorMessage =
                            Password2.ErrorMessage =
                            String.Format(Resources.Errors.User_PasswordMinimumLength,
                            applicationSetting.PasswordMinimumLength.Value);
                    }

                    // Ensures that the password has the required
                    // valid characters.
                    //
                    if (!OUserPasswordHistory.ValidatePasswordCharacters(Password1.Text))
                    {
                        if (applicationSetting.PasswordRequiredCharacters == 1)
                            Password1.ErrorMessage =
                                Password2.ErrorMessage =
                                Resources.Errors.User_PasswordMustContainAlphaNumericCharacters;
                        else if (applicationSetting.PasswordRequiredCharacters == 2)
                            Password1.ErrorMessage =
                                Password2.ErrorMessage =
                                Resources.Errors.User_PasswordMustContainAlphaNumericSpecialCharacters;
                    }

                    // Ensures that the password does not exist
                    // in the history of passwords.
                    //
                    string strHashedNewPassword = Security.HashString(Password1.Text);
                    if (OUserPasswordHistory.DoesPasswordExist(user.ObjectID.Value, strHashedNewPassword))
                    {
                        Password1.ErrorMessage =
                            Password2.ErrorMessage =
                            String.Format(Resources.Errors.User_PasswordHistoryExists,
                            applicationSetting.PasswordHistoryKept);
                    }
                }
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            //new user object
            if (user.IsNew)
            {
                user.ResetPassword();
            }
            // only superadmin or useradmin can reset password from profile
            // and this reset function is not subjected to any checks of minimum password age
            else if (chkResetPassword.Checked)
            {
                user.ResetPassword();
                chkResetPassword.Checked = false;
            }
            else
            {
                // Sets the user password
                //
                if (Password1.Text.ToString() != "" &&
                    Password2.Text.ToString() != "" &&
                    Password1.Text.ToString() == Password2.Text.ToString())
                {
                    user.SetNewPassword(Password1.Text.ToString(), true);
                }
            }
            user.isTenant = 1;
            // Save
            // 
            user.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Occurs when the user checks the reset password checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void chkResetPassword_CheckedChange(object sender, EventArgs e)
    {
        Password1.Text = "";
        Password2.Text = "";
    }


    /// <summary>
    /// Occurs when the user checks the Banned checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkIsBanned_CheckedChanged(object sender, EventArgs e)
    {
        int? wasBanned = (int?)ViewState["WasBanned"];

        if (wasBanned == 1 && !checkIsBanned.Checked)
        {
            OUser user = (OUser)panel.SessionObject;
            user.LoginRetries = 0;
        }
    }


    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        Password1.Visible = !chkResetPassword.Checked;
        Password2.Visible = !chkResetPassword.Checked;
    }


    /// <summary>
    /// Update the theme preview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ThemeName_SelectedIndexChanged(object sender, EventArgs e)
    {
        frameTheme.Attributes["src"] = "themepreview.aspx?THEME=" + ThemeName.SelectedValue;
    }

    protected void subpanelTenantContacts_PopulateForm(object sender, EventArgs e)
    {
        OTenantContact tenantContact = subpanelTenantContacts.SessionObject as OTenantContact;
        ManageAmosField(tenantContact.FromAmos);
        ddlTenantContactType.Bind(OCode.GetCodesByType("TenantContactType",tenantContact.TenantContactTypeID));
        objectpanelTenantContacts.BindObjectToControls(tenantContact);
    }



    protected void subpanelTenantContacts_ValidateAndUpdate(object sender, EventArgs e)
    {
        OUser tenant = panel.SessionObject as OUser;
        OTenantContact tenantContact = subpanelTenantContacts.SessionObject as OTenantContact;
        objectpanelTenantContacts.BindControlsToObject(tenantContact);

        tenant.TenantContacts.Add(tenantContact);
        panelTenantContacts.BindObjectToControls(tenant);
    }

    protected void subpanelTenantLease_PopulateForm(object sender, EventArgs e)
    {
        ddlStatus.Bind(OTenantLease.dtStatusList(), "Status", "Abr");
        OTenantLease tenantLease = subpanelTenantLease.SessionObject as OTenantLease;
        treeLocation.PopulateTree();
        objectpanelTenantLease.BindObjectToControls(tenantLease);
        objectpanelTenantLease.Enabled = !(tenantLease.FromAmos == 1);
        
    }

    protected void subpanelTenantLease_ValidateAndUpdate(object sender, EventArgs e)
    {
        OUser tenant = panel.SessionObject as OUser;
        OTenantLease tenantLease = subpanelTenantLease.SessionObject as OTenantLease;
        objectpanelTenantLease.BindControlsToObject(tenantLease);
        tenant.TenantLeases.Add(tenantLease);
        panelLease.BindObjectToControls(tenant);
    }

    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OTenantLease tenantLease = subpanelTenantLease.SessionObject as OTenantLease;
        return new LocationTreePopulaterForCapitaland(tenantLease.LocationID, false, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    protected void gridActivities_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ObjectEdit")
        {
            Window.OpenEditObjectPage(this, "OTenantActivity", dataKeys[0].ToString(), "");
        }
        else if (commandName == "ObjectView")
        { 
            OUser user = panel.SessionObject as OUser;
            Window.OpenViewObjectPage(this, "OTenantActivity", dataKeys[0].ToString(), "");
        }
    }

    protected void gridCases_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ObjectEdit")
        {
            Window.OpenEditObjectPage(this, "OCase", dataKeys[0].ToString(), "");
        }
        else if (commandName == "ObjectView")
        {
            OUser user = panel.SessionObject as OUser;
            Window.OpenViewObjectPage(this, "OCase", dataKeys[0].ToString(), "");
        }
    }
    public void ManageAmosField(int? FromAmos)
    {
        textContactEmail.Enabled = !(FromAmos==1);
        textContactCellphone.Enabled = !(FromAmos == 1);
        textContactFax.Enabled = !(FromAmos == 1);
        txtPhone.Enabled = !(FromAmos == 1);
        objectBase.ObjectName.Enabled = !(FromAmos == 1);
        textContactObjectName.Enabled = !(FromAmos == 1);
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
        <web:object runat="server" ID="panel" Caption="Tenant" BaseTable="tUser" meta:resourcekey="panelResource1"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="Tenant Name"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <br />  
                    <ui:UIFieldDropDownList runat="server" ID="ddlTenantType" Caption="Tenant Type" ValidateRequiredField="True" Span="Half" PropertyName="TenantTypeID" meta:resourcekey="ddlTenantTypeResource1"></ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="txtIndustryTrade" Caption="Industry Trade" PropertyName="IndustryTrade" InternalControlWidth="95%" meta:resourcekey="txtIndustryTradeResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtAddress" Caption="Address" PropertyName="UserBase.Address" InternalControlWidth="95%" meta:resourcekey="txtAddressResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtWebsite" Caption="Website" PropertyName="Website" InternalControlWidth="95%" meta:resourcekey="txtWebsiteResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtEmail" Caption="Email" PropertyName="UserBase.Email" InternalControlWidth="95%" meta:resourcekey="txtEmailResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtTelephone" Caption="Teletphone" PropertyName="UserBase.Phone" Span="Half" InternalControlWidth="95%" meta:resourcekey="txtTelephoneResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtFax" Caption="Fax" PropertyName="UserBase.Fax" Span="Half" InternalControlWidth="95%" meta:resourcekey="txtFaxResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtOperationHour" Caption="Operation Hours" PropertyName="OperationHours" InternalControlWidth="95%" meta:resourcekey="txtOperationHourResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtTenantProfile" Caption="Tenant Profile" PropertyName="TenantProfile" Rows="5" TextMode="MultiLine" InternalControlWidth="95%" meta:resourcekey="txtTenantProfileResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="txtHighlight" Caption="Highlights" PropertyName="Highlights" Rows="5" TextMode="MultiLine" InternalControlWidth="95%" meta:resourcekey="txtHighlightResource1"></ui:UIFieldTextBox>
                    <ui:UIFieldCheckBox runat="server" ID="cbFromAmos" Caption="From Amos" Enabled="False" PropertyName="FromAmos" meta:resourcekey="cbFromAmosResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                    <ui:uifieldtextbox id="AmosOrgID" runat="server" 
                        caption="Amos Org ID" internalcontrolwidth="95%"
                        propertyname="AmosOrgID" Span = "Half" Enabled="False" meta:resourcekey="AmosOrgIDResource1"/>
                        <ui:UIFieldDateTime id="updatedOn" runat="server" 
                        caption="Updated On" internalcontrolwidth="95%"
                        propertyname="updatedOn" Span = "Half" Enabled="False" meta:resourcekey="updatedOnResource1" ShowDateControls="True"/>
                        <ui:UISeparator runat='server' ID="UISeparator1" meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="ddl_Language" PropertyName="LanguageName"
                        Caption="Language" ToolTip="Changes to the theme will only take effect on the next logon."
                        meta:resourcekey="LanguageNameResource1" ValidateRequiredField="True" Visible="false">
                    </ui:UIFieldDropDownList>

                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabContact" Caption="Contact" CssClass="div-from" BorderStyle="NotSet" meta:resourcekey="tabContactResource1">
                    <ui:uipanel runat="server" id="panelTenantContacts" BorderStyle="NotSet" meta:resourcekey="panelTenantContactsResource1">
                    <ui:UIGridView runat="server" id="gridTenantContacts" PropertyName="TenantContacts" Caption="Tenant Contacts" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridTenantContactsResource2" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource3" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource4" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" CommandText="Edit" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantContactType.ObjectName" HeaderText="Tenant Contact Type" meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="TenantContactType.ObjectName" ResourceAssemblyName="" SortExpression="TenantContactType.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Position" HeaderText="Position" meta:resourcekey="UIGridViewBoundColumnResource10" PropertyName="Position" ResourceAssemblyName="" SortExpression="Position">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Department" HeaderText="Department" meta:resourcekey="UIGridViewBoundColumnResource11" PropertyName="Department" ResourceAssemblyName="" SortExpression="Department">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="DID" HeaderText="DID" meta:resourcekey="UIGridViewBoundColumnResource12" PropertyName="DID" ResourceAssemblyName="" SortExpression="DID">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Cellphone" HeaderText="Cellphone" meta:resourcekey="UIGridViewBoundColumnResource13" PropertyName="Cellphone" ResourceAssemblyName="" SortExpression="Cellphone">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Fax" HeaderText="Fax" meta:resourcekey="UIGridViewBoundColumnResource14" PropertyName="Fax" ResourceAssemblyName="" SortExpression="Fax">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Email" HeaderText="Email" meta:resourcekey="UIGridViewBoundColumnResource15" PropertyName="Email" ResourceAssemblyName="" SortExpression="Email">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="FromAmosText" HeaderText="From Amos" meta:resourcekey="UIGridViewBoundColumnResource16" PropertyName="FromAmosText" ResourceAssemblyName="" SortExpression="FromAmosText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="AmosContactID" HeaderText="Amos Contact ID" meta:resourcekey="UIGridViewBoundColumnResource17" PropertyName="AmosContactID" ResourceAssemblyName="" SortExpression="AmosContactID">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:uiobjectpanel runat="server" id="objectpanelTenantContacts" BorderStyle="NotSet" meta:resourcekey="objectpanelTenantContactsResource1">
                        <web:subpanel runat="server" id="subpanelTenantContacts" OnPopulateForm="subpanelTenantContacts_PopulateForm" OnValidateAndUpdate="subpanelTenantContacts_ValidateAndUpdate" GridViewID="gridTenantContacts"  />
                        <ui:uifieldtextbox runat="server" id="textContactObjectName" PropertyName="ObjectName" Caption="Name" MaxLength="255" ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="textContactObjectNameResource2"></ui:uifieldtextbox>
                        <ui:UIFieldDropDownList runat="server" ID="ddlTenantContactType" PropertyName="TenantContactTypeID" ValidateRequiredField="True" Span="Half" Caption="Tenant Contact Type" meta:resourcekey="ddlTenantContactTypeResource1" />
                        <ui:uifieldtextbox runat="server" id="textContactPosition" PropertyName="Position" Caption="Position" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="textContactPositionResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textContactDepartment" PropertyName="Department" Caption="Department" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="textContactDepartmentResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="txtDID" PropertyName="DID" Caption="DID" InternalControlWidth="95%" meta:resourcekey="txtDIDResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="txtPhone" PropertyName="Phone" Caption="Phone" InternalControlWidth="95%" meta:resourcekey="txtPhoneResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textContactCellphone" PropertyName="Cellphone" Caption="Cellphone" Span="Half" InternalControlWidth="95%" meta:resourcekey="textContactCellphoneResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textContactFax" PropertyName="Fax" Caption="Fax" Span="Half" InternalControlWidth="95%" meta:resourcekey="textContactFaxResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textContactEmail" PropertyName="Email" Caption="Email" Span="Half" InternalControlWidth="95%" meta:resourcekey="textContactEmailResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textLikes" PropertyName="Likes" Caption="Likes" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="textLikesResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textDislikes" PropertyName="Dislikes" Caption="Dislikes" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="textDislikesResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textInformation" PropertyName="AdditionalInformation" Caption="Additional Information" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="textInformationResource1"></ui:uifieldtextbox>

                    <ui:UIPanel id="panelAmos" runat="server" borderstyle="NotSet" caption="Amos" Enabled="False" meta:resourcekey="panelAmosResource1">
                        <ui:UISeparator runat="server" ID="AmosSeparator" Caption="Amos" meta:resourcekey="AmosSeparatorResource1" />
                            <ui:UIFieldCheckBox runat="server" ID="UIFieldCheckBox1" Caption="From Amos" PropertyName="FromAmos" meta:resourcekey="UIFieldCheckBox1Resource1" TextAlign="Right"/>
                                <ui:uifieldtextbox id="ContactAmosOrgID" runat="server" 
                                caption="Amos Org ID" internalcontrolwidth="95%" 
                                propertyname="AmosOrgID" Span = "Half" Enabled="False" meta:resourcekey="ContactAmosOrgIDResource1"/>
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
                                <ui:uifieldtextbox id="contactUpdatedOn" runat="server" 
                                caption="Updated On" internalcontrolwidth="95%" DataFormatString="{0:dd-MMM-yyyy}"
                                propertyname="updatedOn" Span = "Half" Enabled="False" meta:resourcekey="contactUpdatedOnResource1"/>
                        </ui:UIPanel>
                    </ui:uiobjectpanel>
                    </ui:uipanel>
                    </ui:UITabView>
                    
                    <ui:UITabView runat="server" ID="tabLease" Caption="Lease" CssClass="div-from" BorderStyle="NotSet" meta:resourcekey="tabLeaseResource1">
                    <ui:uipanel runat="server" id="panelLease" BorderStyle="NotSet" meta:resourcekey="panelLeaseResource1">
                    <ui:UIGridView runat="server" id="gridTenantLease" PropertyName="TenantLeases" Caption="Tenant Leases" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridTenantLeaseResource1" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" CommandText="Edit" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource5">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource6">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" meta:resourcekey="UIGridViewBoundColumnResource18" PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="ShopName" HeaderText="Shop Name" PropertyName="ShopName" ResourceAssemblyName="" SortExpression="ShopName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="LeaseStartDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Start Date" meta:resourcekey="UIGridViewBoundColumnResource19" PropertyName="LeaseStartDate" ResourceAssemblyName="" SortExpression="LeaseStartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="LeaseEndDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="End Date" meta:resourcekey="UIGridViewBoundColumnResource20" PropertyName="LeaseEndDate" ResourceAssemblyName="" SortExpression="LeaseEndDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Status" HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource21" PropertyName="Status" ResourceAssemblyName="" SortExpression="Status">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:uiobjectpanel runat="server" id="objectpanelTenantLease" BorderStyle="NotSet" meta:resourcekey="objectpanelTenantLeaseResource1">
                        <web:subpanel runat="server" id="subpanelTenantLease" GridViewID="gridTenantLease"  OnPopulateForm="subpanelTenantLease_PopulateForm" OnValidateAndUpdate="subpanelTenantLease_ValidateAndUpdate" />
                        <ui:UIFieldCheckBox runat="server" ID="UIFieldCheckBox2" Caption="From Amos" 
                        PropertyName="FromAmos" Enabled="False" meta:resourcekey="UIFieldCheckBox2Resource1" TextAlign="Right"/>
                        <ui:uifieldtreelist id="treeLocation" runat="server" caption="Location" 
                            propertyname="LocationID" showcheckboxes="None" treevaluemode="SelectedNode" 
                            validaterequiredfield="True" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1">
                        </ui:uifieldtreelist>
                        <ui:UIFieldDateTime runat="server" ID="StartDate" Caption="Start Date" PropertyName="LeaseStartDate" Span="Half" meta:resourcekey="StartDateResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="EndDate" Caption="End Date" PropertyName="LeaseEndDate"  Span="Half" meta:resourcekey="EndDateResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                        <ui:UIFieldDropDownList runat="server" ID="ddlStatus" Caption="Status" PropertyName="LeaseStatus" meta:resourcekey="ddlStatusResource1"></ui:UIFieldDropDownList>
                        
                        <ui:uifieldtextbox id="LeaseStatusDate" runat="server" 
                        caption="Lease Status date" internalcontrolwidth="95%" DataFormatString="{0:dd-MMM-yyyy}"
                        propertyname="LeaseStatusDate" Span = "Half" Enabled="False" meta:resourcekey="LeaseStatusDateResource1"/>
                        <ui:uifieldtextbox id="LeaseAmosOrgID" runat="server" 
                        caption="Amos Org ID" internalcontrolwidth="95%" 
                        propertyname="AmosOrgID" Span = "Half" Enabled="False" meta:resourcekey="LeaseAmosOrgIDResource1"/>
                        <ui:uifieldtextbox id="AmosAssetID" runat="server" 
                        caption="Amos Asset ID" internalcontrolwidth="95%" 
                        propertyname="AmosAssetID" Span = "Half" Enabled="False" meta:resourcekey="AmosAssetIDResource1"/>
                        <ui:uifieldtextbox id="AmosSuiteID" runat="server" 
                        caption="Amos Suite ID" internalcontrolwidth="95%" 
                        propertyname="AmosSuiteID" Span = "Half" Enabled="False" meta:resourcekey="AmosSuiteIDResource1"/>
                        <ui:uifieldtextbox id="AmosLeaseID" runat="server" 
                        caption="Amos Lease ID" internalcontrolwidth="95%" 
                        propertyname="AmosLeaseID" Span = "Half" Enabled="False" meta:resourcekey="AmosLeaseIDResource1"/>
                        
                        <ui:uifieldtextbox id="leaseUpdatedOn" runat="server" 
                        caption="Updated On" internalcontrolwidth="95%" DataFormatString="{0:dd-MMM-yyyy}"
                        propertyname="updatedOn" Span = "Half" Enabled="False" meta:resourcekey="leaseUpdatedOnResource1"/>
                    </ui:uiobjectpanel>
                    </ui:uipanel>
                    </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTenantActivity" Caption="Activities" BorderStyle="NotSet" meta:resourcekey="tabTenantActivityResource1">
                     <ui:UIGridView runat="server" id="gridActivities" Caption="Activities" KeyName="ObjectID" OnAction="gridActivities_Action" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridActivitiesResource1" RowErrorColor="" style="clear:both;">
                        
                         <PagerSettings Mode="NumericFirstLast" />
                         <Columns>
                             <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ObjectEdit" CommandText="Edit" ConfirmText="Please remember to save this Tenant before editing the Tenant Activity.\n\nAre you sure you want to continue?" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource7">
                                 <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewButtonColumn>
                             <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ObjectView" CommandText="Remove" ConfirmText="Please remember to save this Tenant before going to the Tenant Activity page.\n\nAre you sure you want to continue?" ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource8">
                                 <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewButtonColumn>
                             <cc1:UIGridViewBoundColumn DataField="ActivityType" HeaderText="Activity Type" meta:resourcekey="UIGridViewBoundColumnResource22" PropertyName="ActivityType" ResourceAssemblyName="" SortExpression="ActivityType">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="DateTimeOfActivity" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Date/Time" meta:resourcekey="UIGridViewBoundColumnResource23" PropertyName="DateTimeOfActivity" ResourceAssemblyName="" SortExpression="DateTimeOfActivity">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="NameOfStaff" HeaderText="Name of Staff" meta:resourcekey="UIGridViewBoundColumnResource24" PropertyName="NameOfStaff" ResourceAssemblyName="" SortExpression="NameOfStaff">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="Agenda" HeaderText="Agenda" meta:resourcekey="UIGridViewBoundColumnResource25" PropertyName="Agenda" ResourceAssemblyName="" SortExpression="Agenda">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                         </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabCase" Caption="Cases/Works" BorderStyle="NotSet" meta:resourcekey="tabCaseResource1">
                     <ui:UIGridView runat="server" id="gridCases" Caption="Cases/Works" KeyName="ObjectID" OnAction="gridCases_Action" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridCasesResource1" RowErrorColor="" style="clear:both;">
                        
                         <PagerSettings Mode="NumericFirstLast" />
                         <Columns>
                             <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ObjectEdit" CommandText="Edit" ConfirmText="Please remember to save this Tenant before editing the Case.\n\nAre you sure you want to continue?" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource9">
                                 <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewButtonColumn>
                             <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ObjectView" CommandText="Remove" ConfirmText="Please remember to save this Tenant before going to the Case page.\n\nAre you sure you want to continue?" ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource10">
                                 <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewButtonColumn>
                             <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Case Number" meta:resourcekey="UIGridViewBoundColumnResource26" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="ProblemDescription" HeaderText="Case's Problem Description" meta:resourcekey="UIGridViewBoundColumnResource27" PropertyName="ProblemDescription" ResourceAssemblyName="" SortExpression="ProblemDescription">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="CaseStatus" HeaderText="CaseStatus" meta:resourcekey="UIGridViewBoundColumnResource28" PropertyName="CaseStatus" ResourceAssemblyName="" SortExpression="CaseStatus">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="WorkNumber" HeaderText="Work Number" meta:resourcekey="UIGridViewBoundColumnResource29" PropertyName="WorkNumber" ResourceAssemblyName="" SortExpression="WorkNumber">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="TypeOfWork" HeaderText="Type of Work" meta:resourcekey="UIGridViewBoundColumnResource30" PropertyName="TypeOfWork" ResourceAssemblyName="" SortExpression="TypeOfWork">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="TypeOfService" HeaderText="Typeof Service" meta:resourcekey="UIGridViewBoundColumnResource31" PropertyName="TypeOfService" ResourceAssemblyName="" SortExpression="TypeOfService">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="TypeOfProblem" HeaderText="Type Of Problem" meta:resourcekey="UIGridViewBoundColumnResource32" PropertyName="TypeOfProblem" ResourceAssemblyName="" SortExpression="TypeOfProblem">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="WorkDescription" HeaderText="Work Description" meta:resourcekey="UIGridViewBoundColumnResource33" PropertyName="WorkDescription" ResourceAssemblyName="" SortExpression="WorkDescription">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                             <cc1:UIGridViewBoundColumn DataField="WorkStatus" HeaderText="Work Status" meta:resourcekey="UIGridViewBoundColumnResource34" PropertyName="WorkStatus" ResourceAssemblyName="" SortExpression="WorkStatus">
                                 <HeaderStyle HorizontalAlign="Left" />
                                 <ItemStyle HorizontalAlign="Left" />
                             </cc1:UIGridViewBoundColumn>
                         </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabCredentials" Caption="Credentials" meta:resourcekey="tabCredentialsResource1" BorderStyle="NotSet" Visible="false">
                    <ui:UIFieldCheckBox runat="server" ID="checkIsBanned" PropertyName="IsBanned" Caption="Banned"
                        Text="Yes, this user is currently banned from logging in to the system."
                        OnCheckedChanged="checkIsBanned_CheckedChanged" meta:resourcekey="checkIsBannedResource2" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldTextBox runat="server" ID="UserLoginName" PropertyName="UserBase.LoginName"
                        Caption="Login Name" ValidateRequiredField="True" meta:resourcekey="UserLoginNameResource1" InternalControlWidth="95%" />
                    <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
                    <ui:UIFieldCheckBox runat="server" ID="chkResetPassword" Caption="Reset Password"
                        Text="Yes, generate a new password and send it via e-mail to the user when I save."
                        OnCheckedChanged="chkResetPassword_CheckedChange" meta:resourcekey="chkResetPasswordResource2" TextAlign="Right" />
                    <ui:UIFieldTextBox runat="server" ID="Password1" Caption="Password" TextMode="Password"
                        Span="Half" meta:resourcekey="Password1Resource1" MaxLength="30" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="Password2" Caption="Confirm Password" TextMode="Password"
                        Span="Half" meta:resourcekey="Password2Resource1" MaxLength="30" InternalControlWidth="95%" />
                    <br />
                    <br />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTheme" Caption="Theme" CssClass="div-from" BorderStyle="NotSet" meta:resourcekey="tabThemeResource2" Visible="false">
                    <ui:UIPanel runat="server" ID="panelTheme" BorderStyle="NotSet" meta:resourcekey="panelThemeResource1">
                        <ui:UIFieldDropDownList runat="server" ID="ThemeName" PropertyName="ThemeName" Caption="Theme"
                            ToolTip="Changes to the theme will only take effect on the next logon." meta:resourcekey="ThemeNameResource1"
                            ValidateRequiredField="True" OnSelectedIndexChanged="ThemeName_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <table cellpadding='0' cellspacing='0' border='0' style="width:100%">
                            <tr>
                                <td style="width: 150px">
                                </td>
                                <td>
                                    <iframe runat="server" id="frameTheme" width="600px" height="300px" style="border: solid 1px gray"
                                        frameborder="0" scrolling="no"></iframe>
                                        
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                </ui:UITabView>
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
