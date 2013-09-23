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
    /// Populates the form controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OUser user = panel.SessionObject as OUser;

        ViewState["WasBanned"] = user.IsBanned;
        frameTheme.Attributes["src"] = "themepreview.aspx?THEME=" + user.ThemeName;

        listPosition.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID");
        Craft.Bind(OCraft.GetAllCraft());
        ThemeName.Bind(GetThemes(), "Name", "Value", false);

        Password1.ValidateRequiredField = user.IsNew;
        Password2.ValidateRequiredField = user.IsNew;

        if (Request["MODE"] != null && Security.Decrypt(Request["MODE"]) == "EDITPROFILE")
        {
            tabMemo.Visible = false;
            tabAttachments.Visible = false;
            tabPosition.Enabled = false;

            panel.DeleteButtonVisible = false;
            checkIsBanned.Visible = false;
            UserLoginName.Enabled = false;
            objectBase.ObjectNameEnabled = false;
            chkResetPassword.Visible = false;
            panel.SaveAndCloseButtonVisible = false;
            panel.SaveAndNewButtonVisible = false;
        }

        ddl_Language.Bind(OLanguage.GetAllLanguages(), "ObjectName", "CultureCode");

        panel.ObjectPanel.BindObjectToControls(user);
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

        textEmail.ValidateRequiredField = chkResetPassword.Checked;

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
        <web:object runat="server" ID="panel" Caption="User" BaseTable="tUser" meta:resourcekey="panel"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="User Name"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="UserBase.Cellphone"
                        Caption="Cell Phone" Span="Half" meta:resourcekey="uifieldstring4Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textEmail" PropertyName="UserBase.Email" Caption="Email"
                        Span="Half" meta:resourcekey="uifieldstring5Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="UserBase.Fax"
                        Caption="Fax" Span="Half" meta:resourcekey="uifieldstring6Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="UserBase.Phone"
                        Caption="Phone" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring7" PropertyName="UserBase.AddressCountry"
                        Caption="Country" Span="Half" meta:resourcekey="uifieldstring7Resource1" MaxLength="255" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring8" PropertyName="UserBase.AddressState"
                        Caption="State" Span="Half" meta:resourcekey="uifieldstring8Resource1" MaxLength="255" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring9" PropertyName="UserBase.AddressCity"
                        Caption="City" Span="Half" meta:resourcekey="uifieldstring9Resource1" MaxLength="255" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring10" PropertyName="UserBase.Address"
                        Caption="Address" Span="Half" meta:resourcekey="uifieldstring10Resource1" MaxLength="255" />
                    <ui:UIFieldDropDownList runat="server" ID="Craft" PropertyName="CraftID" Caption="Craft"
                        DataTextField="Name" Span="Half" ToolTip="The craft this technician belongs to."
                        meta:resourcekey="CraftResource1">
                    </ui:UIFieldDropDownList>
                    <br />
                    <ui:UISeparator runat='server' ID="UISeparator1" />
                    <ui:UIFieldDropDownList runat="server" ID="ddl_Language" PropertyName="LanguageName"
                        Caption="Language" ToolTip="Changes to the theme will only take effect on the next logon."
                        meta:resourcekey="LanguageNameResource1" ValidateRequiredField="true">
                    </ui:UIFieldDropDownList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabPosition" Caption="Positions" CssClass="div-from">
                    <ui:UIFieldListBox runat="server" ID="listPosition" Caption="Positions" PropertyName="Positions"
                        Rows="30" ValidateRequiredField="True"></ui:UIFieldListBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabCredentials" Caption="Credentials" meta:resourcekey="tabCredentialsResource1">
                    <ui:UIFieldCheckBox runat="server" ID="checkIsBanned" PropertyName="IsBanned" Caption="Banned"
                        Text="Yes, this user is currently banned from logging in to the system." Span="full"
                        OnCheckedChanged="checkIsBanned_CheckedChanged">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldTextBox runat="server" ID="UserLoginName" PropertyName="UserBase.LoginName"
                        Caption="Login Name" Span="full" ValidateRequiredField="True" meta:resourcekey="UserLoginNameResource1" />
                    <ui:UISeparator runat="server" ID="sep1" />
                    <ui:UIFieldCheckBox runat="server" ID="chkResetPassword" Caption="Reset Password"
                        Text="Yes, generate a new password and send it via e-mail to the user when I save."
                        OnCheckedChanged="chkResetPassword_CheckedChange" Visible="true" />
                    <ui:UIFieldTextBox runat="server" ID="Password1" Caption="Password" TextMode="Password"
                        Span="Half" meta:resourcekey="Password1Resource1" MaxLength="30" />
                    <ui:UIFieldTextBox runat="server" ID="Password2" Caption="Confirm Password" TextMode="Password"
                        Span="Half" meta:resourcekey="Password2Resource1" MaxLength="30" />
                    <br />
                    <br />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTheme" Caption="Theme" CssClass="div-from">
                    <ui:UIPanel runat="server" ID="panelTheme">
                        <ui:UIFieldDropDownList runat="server" ID="ThemeName" PropertyName="ThemeName" Caption="Theme"
                            ToolTip="Changes to the theme will only take effect on the next logon." meta:resourcekey="ThemeNameResource1"
                            ValidateRequiredField="true" OnSelectedIndexChanged="ThemeName_SelectedIndexChanged">
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
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
