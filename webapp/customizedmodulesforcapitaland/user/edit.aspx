<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

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

        List<OLocation> locations = new List<OLocation>();
        List<ORole> assignableRoles = new List<ORole>();
        foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OUser"))
        {
            foreach (OLocation location in position.LocationAccess)
                locations.Add(location);
        }
        foreach (OPosition position in AppSession.User.Positions)
            foreach (ORole assignableRole in position.Role.AssignableRoles)
                assignableRoles.Add(assignableRole);

        sddl_PositionID.Bind(OPosition.GetPositionsAtOrBelowLocations(locations, assignableRoles), "ObjectName", "ObjectID");
        Craft.Bind(OCraft.GetAllCraft());
        ThemeName.Bind(GetThemes(), "Name", "Value", false);

        // Hide the password textboxes
        // if the system is configured to use Windows Authentication
        // for logging on users.
        //
        if (ConfigurationManager.AppSettings["AuthenticateWithWindowsLogon"].ToLower() == "true")
        {
            panelPassword.Visible = false;
        }
        else
        {
            Password1.ValidateRequiredField = user.IsNew;
            Password2.ValidateRequiredField = user.IsNew;
        }

        if (Request["MODE"] != null && Security.Decrypt(Request["MODE"]) == "EDITPROFILE")
        {
            tabMemo.Visible = false;
            tabAttachments.Visible = false;
            tabPosition.Enabled = false;
            sddl_PositionID.Visible = false;

            panel.DeleteButtonVisible = false;
            checkIsBanned.Visible = false;
            UserLoginName.Enabled = false;
            objectBase.ObjectNameEnabled = false;
            chkResetPassword.Visible = false;
            IsActiveDirectoryUser.Enabled = false;
            ActiveDirectoryDomain.Enabled = false;
            panel.SaveAndCloseButtonVisible = false;
            panel.SaveAndNewButtonVisible = false;
        }
        else
            hintDelegation.Visible = false;

        if (user.IsNew)
            user.IsActiveDirectoryUser = 0;

        ddl_Language.Bind(OLanguage.GetAllLanguages(), "ObjectName", "CultureCode");

        panel.ObjectPanel.BindObjectToControls(user);
        gv_Position.Commands[1].Visible
           = gridDelegatedToOthersPositions.Visible
            = gridDelegatedByOthersPositions.Visible
            = (ConfigurationManager.AppSettings["CustomizedInstance"] == "IT");
        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "IT")
            tdDelegation.Style["display"] = "";
        else
            tdDelegation.Style["display"] = "none";
        //gv_Position.Commands[1].Visible
        //    = gridDelegatedToOthersPositions.Visible
        //    = gridDelegatedByOthersPositions.Visible
        //    = (ConfigurationManager.AppSettings["CustomizedInstance"] == "IT");
        if (OApplicationSetting.Current.ActiveDirectoryDomain != null && OApplicationSetting.Current.ActiveDirectoryDomain != string.Empty)
            ActiveDirectoryDomain.Text = OApplicationSetting.Current.ActiveDirectoryDomain.ToString();
        
        // Disable themes for China.
        //
        if (ConfigurationManager.AppSettings["CustomizedInstannce"] == "CHINAOPS")
            tabTheme.Visible = false;
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
            /*
            //check duplicate user email if email is entered
            if (textEmail.Text != String.Empty && textEmail.Text != null && user.IsDuplicateUserEmail() == true)
                textEmail.ErrorMessage = Resources.Errors.User_DuplicatedUserEmail;
             * */

            if (!panel.ObjectPanel.IsValid)
                return;

            if (chkResetPassword.Checked && !IsActiveDirectoryUser.Checked)
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
                    //user.SetNewPasswordForCapitaland(Password1.Text.ToString(), true);
                    user.SetNewPassword(Password1.Text.ToString(), true);
                }


            }

            // Save
            // 
            user.ActivateAndSaveCurrentPositions();
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
        OApplicationSetting applicationSetting = OApplicationSetting.Current;
        textEmail.ValidateRequiredField = chkResetPassword.Checked || applicationSetting.IsUserEmailCompulsory == 1;

        Password1.Visible = !chkResetPassword.Checked;
        Password2.Visible = !chkResetPassword.Checked;

        if (this.IsActiveDirectoryUser.Checked)
        {
            chkResetPassword.Visible = false;
            //Password1.Visible = false;
            //Password2.Visible = false;
            ActiveDirectoryDomain.Visible = false;
        }
        else
        {
            if (Request["MODE"] == null)
                chkResetPassword.Visible = true;
            //Password1.Visible = true;
            //Password2.Visible = true;
            ActiveDirectoryDomain.Visible = false;
        }
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

    protected void gv_Position_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OUser u = (OUser)panel.SessionObject;
            foreach (Guid id in objectIds)
            {
                OUserPermanentPosition permanentPosition = u.PermanentPositions.Find(id);

                // Removes all delegated positions (with the same position ID)
                // to other users 
                //
                for (int i = u.DelegatedToOthersPositions.Count - 1; i >= 0; i--)
                    if (u.DelegatedToOthersPositions[i].PositionID == permanentPosition.PositionID)
                        u.DelegatedToOthersPositions.Remove(u.DelegatedToOthersPositions[i]);

                u.PermanentPositions.Remove(permanentPosition);
            }

            panel.ObjectPanel.BindControlsToObject(u);
            panel.ObjectPanel.BindObjectToControls(u);
        }
        if (commandName == "DelegatePosition")
        {
            if (dropGrantedToUser.Items.Count == 0)
                dropGrantedToUser.Bind(OUser.GetAllNonTenantUsersExceptSpecified(AppSession.User.ObjectID));
            dropGrantedToUser.SelectedIndex = 0;

            popupDelegatePositions.Show();
        }
    }

    protected void sddl_PositionID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OUser u = (OUser)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(u);
        if (sddl_PositionID.SelectedValue != "")
        {
            OUserPermanentPosition p = TablesLogic.tUserPermanentPosition.Create();
            p.PositionID = new Guid(sddl_PositionID.SelectedValue);
            u.PermanentPositions.Add(p);
        }
        panel.ObjectPanel.BindObjectToControls(u);
    }

    protected void buttonDelegateCancel_Click(object sender, EventArgs e)
    {
        popupDelegatePositions.Hide();
    }

    protected void buttonDelegateConfirm_Click(object sender, EventArgs e)
    {
        if (!objectPanelDelegatePositions.IsValid)
            return;

        OUser u = (OUser)panel.SessionObject;
        tabPosition.BindControlsToObject(u);

        List<object> permanentPositionIds = gv_Position.GetSelectedKeys();

        foreach (Guid permanentPositionId in permanentPositionIds)
        {
            OUserPermanentPosition permanentPosition = u.PermanentPositions.Find(permanentPositionId);

            if (permanentPosition != null)
            {
                OUserDelegatedPosition dp = TablesLogic.tUserDelegatedPosition.Create();
                dp.DelegatedByUserID = u.ObjectID;
                dp.UserID = new Guid(dropGrantedToUser.SelectedValue);
                dp.PositionID = permanentPosition.PositionID;
                dp.StartDate = dateDelegateStartDate.DateTime;
                dp.EndDate = dateDelegateEndDate.DateTime;
                u.DelegatedToOthersPositions.Add(dp);
            }
        }
        tabPosition.BindObjectToControls(u);

        popupDelegatePositions.Hide();
    }

    protected void IsActiveDirectoryUser_checkChanged(object sender, EventArgs e)
    {

    }

    protected void gridDelegatedToOthersPositions_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            OUser u = (OUser)panel.SessionObject;
            tabPosition.BindControlsToObject(u);

            foreach (Guid id in gridDelegatedToOthersPositions.GetSelectedKeys())
                u.DelegatedToOthersPositions.RemoveGuid(id);

            tabPosition.BindObjectToControls(u);
        }
    }


    Hashtable assignableRolesHash = null;
    
    /// <summary>
    /// Occurs when the row is data bound to the grid view.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gv_Position_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (assignableRolesHash == null)
            {
                assignableRolesHash = new Hashtable();
                foreach (OPosition position in AppSession.User.Positions)
                    foreach (ORole assignableRole in position.Role.AssignableRoles)
                        assignableRolesHash[assignableRole.ObjectID.Value] = 1;
            }

            // Hide the delete button if the user has no rights to revoke
            // the position.
            //
            OUser u = (OUser)panel.SessionObject;
            Guid userPermanentPositionId = (Guid)gv_Position.DataKeys[e.Row.RowIndex][0];
            OUserPermanentPosition userPermanentPosition = u.PermanentPositions.Find(userPermanentPositionId);
            if (userPermanentPosition == null || assignableRolesHash[userPermanentPosition.Position.RoleID.Value] == null)
                e.Row.Cells[1].Controls[0].Visible = false;
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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
        <web:object runat="server" ID="panel" Caption="User" BaseTable="tUser" meta:resourcekey="panel" OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="User Name" ObjectNameMaxLength="50" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:uifieldtextbox runat="server" id="textDescription" PropertyName="Description" Caption="Description" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="textDescriptionResource1">
                    </ui:uifieldtextbox>
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="UserBase.Cellphone" Caption="Cell Phone" Span="Half" meta:resourcekey="uifieldstring4Resource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="textEmail" PropertyName="UserBase.Email" Caption="Email" Span="Half" meta:resourcekey="uifieldstring5Resource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="UserBase.Fax" Caption="Fax" Span="Half" meta:resourcekey="uifieldstring6Resource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="UserBase.Phone" Caption="Phone" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring7" PropertyName="UserBase.AddressCountry" Caption="Country" Span="Half" meta:resourcekey="uifieldstring7Resource1" MaxLength="255" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring8" PropertyName="UserBase.AddressState" Caption="State" Span="Half" meta:resourcekey="uifieldstring8Resource1" MaxLength="255" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring9" PropertyName="UserBase.AddressCity" Caption="City" Span="Half" meta:resourcekey="uifieldstring9Resource1" MaxLength="255" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring10" PropertyName="UserBase.Address" Caption="Address" Span="Half" meta:resourcekey="uifieldstring10Resource1" MaxLength="255" InternalControlWidth="95%" />
                    <ui:UIFieldDropDownList runat="server" ID="Craft" PropertyName="CraftID" Caption="Craft" DataTextField="Name" Span="Half" ToolTip="The craft this technician belongs to." meta:resourcekey="CraftResource1">
                    </ui:UIFieldDropDownList>
                    <br />
                    <ui:UISeparator runat='server' ID="UISeparator1" meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="ddl_Language" PropertyName="LanguageName" Caption="Language" ToolTip="Changes to the theme will only take effect on the next logon." meta:resourcekey="LanguageNameResource1" ValidateRequiredField="True">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldCheckBox runat="server" Enabled="False" ID="cbIsTenant" Caption="Is Tenant" PropertyName="isTenant" meta:resourcekey="cbIsTenantResource1" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabPosition" Caption="Positions" CssClass="div-from" meta:resourcekey="tabPositionResource1" BorderStyle="NotSet">
                    <ui:UIFieldSearchableDropDownList ID="sddl_PositionID" runat="server" Caption="Position" OnSelectedIndexChanged="sddl_PositionID_SelectedIndexChanged" meta:resourcekey="sddl_PositionIDResource1" SearchInterval="300">
                    </ui:UIFieldSearchableDropDownList>
                    <ui:UIHint runat="server" ID="hintDelegation" meta:resourcekey="hintDelegationResource1" Visible="false" Text="
                            &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;If you are going on leave from work and are unable to access your account, 
                            you can delegate all or part of your granted positions to someone else in your 
                            company.&lt;br __designer:mapid=&quot;a0&quot; /&gt;&lt;br __designer:mapid=&quot;a1&quot; /&gt; 
                            To do so, select the positions you want to delegate and click on the 'Delegate Selected Positions' button. Then select the person in your company followed by the valid period (usually the time that you are away) you'd like that person to take over those positions.&lt;br __designer:mapid=&quot;a2&quot; /&gt;&lt;br __designer:mapid=&quot;a3&quot; /&gt;
                            NOTE: You can only delegate positions that you have been granted.
                        "></ui:UIHint>
                        <table>
                            <tr valign='top'>
                                <td style='width: 50%'>
                                <ui:UIGridView runat="server" ID="gv_Position" PropertyName="PermanentPositions" OnAction="gv_Position_Action" Caption="Granted Positions" ValidateRequiredField="True" KeyName="ObjectID" BindObjectsToRows="True" meta:resourcekey="gv_PositionResource1" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" style="clear: both;" ImageRowErrorUrl="" OnRowDataBound="gv_Position_RowDataBound">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <commands>
                                        <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                        <cc1:UIGridViewCommand AlwaysEnabled="True" CausesValidation="False"  CommandName="DelegatePosition" CommandText="Delegate Selected Positions" ImageUrl="~/images/right.png" meta:resourcekey="UIGridViewCommandResource1" />
                                    </commands>
                                    <Columns>
                                        <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource1">
                                            <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewButtonColumn>
                                        <cc1:UIGridViewBoundColumn DataField="Position.ObjectName" HeaderText="Name" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Position.ObjectName" ResourceAssemblyName="" SortExpression="Position.ObjectName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewTemplateColumn HeaderText="Start Date" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                            <ItemTemplate>
                                                <cc1:UIFieldDateTime ID="textStartDate" runat="server" Caption="Start Date" FieldLayout="Flow" InternalControlWidth="130px" PropertyName="StartDate" ShowCaption="False" ValidateCompareField="True" ValidationCompareControl="textEndDate" ValidationCompareOperator="LessThanEqual" ValidationCompareType="Date" meta:resourcekey="textStartDateResource1" ShowDateControls="True">
                                                </cc1:UIFieldDateTime>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" Width="150px" />
                                        </cc1:UIGridViewTemplateColumn>
                                        <cc1:UIGridViewTemplateColumn HeaderText="End Date" meta:resourcekey="UIGridViewTemplateColumnResource2">
                                            <ItemTemplate>
                                                <cc1:UIFieldDateTime ID="textEndDate" runat="server" Caption="End Date" FieldLayout="Flow" InternalControlWidth="130px" PropertyName="EndDate" ShowCaption="False" ValidateCompareField="True" ValidationCompareControl="textStartDate" ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" meta:resourcekey="textEndDateResource1" ShowDateControls="True">
                                                </cc1:UIFieldDateTime>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" Width="150px" />
                                        </cc1:UIGridViewTemplateColumn>
                                    </Columns>
                                </ui:UIGridView>
                                <br />
                                <br />
                                <ui:UIGridView runat='server' ID="gridDelegatedByOthersPositions" PropertyName="DelegatedByOthersPositions" Caption="Positions Delegated to Me" CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" style="clear:both;" meta:resourcekey="gridDelegatedByOthersPositionsResource1"  Visible="true">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <Columns>
                                        <cc1:UIGridViewBoundColumn DataField="Position.ObjectName" HeaderText="Position" PropertyName="Position.ObjectName" ResourceAssemblyName="" SortExpression="Position.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource2">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="StartDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Start Date" PropertyName="StartDate" ResourceAssemblyName="" SortExpression="StartDate" meta:resourcekey="UIGridViewBoundColumnResource3">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="EndDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="End Date" PropertyName="EndDate" ResourceAssemblyName="" SortExpression="EndDate" meta:resourcekey="UIGridViewBoundColumnResource4">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                    </Columns>
                                </ui:UIGridView>
                                </td>
                                <td style='width: 50%' runat="server" id="tdDelegation">
                                <ui:UIGridView runat='server' ID="gridDelegatedToOthersPositions" PropertyName="DelegatedToOthersPositions" Caption="Positions Delegated to Other Users" OnAction="gridDelegatedToOthersPositions_Action" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" style="clear: both;" ImageRowErrorUrl="" meta:resourcekey="gridDelegatedToOthersPositionsResource1" Visible="true">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <commands>
                                        <cc1:UIGridViewCommand AlwaysEnabled="True" CausesValidation="False" CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                    </commands>
                                    <Columns>
                                        <cc1:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                            <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewButtonColumn>
                                        <cc1:UIGridViewBoundColumn DataField="User.ObjectName" HeaderText="User" PropertyName="User.ObjectName" ResourceAssemblyName="" SortExpression="User.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource5">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="Position.ObjectName" HeaderText="Position" PropertyName="Position.ObjectName" ResourceAssemblyName="" SortExpression="Position.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource6">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="StartDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Start Date" PropertyName="StartDate" ResourceAssemblyName="" SortExpression="StartDate" meta:resourcekey="UIGridViewBoundColumnResource7">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="EndDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="End Date" PropertyName="EndDate" ResourceAssemblyName="" SortExpression="EndDate" meta:resourcekey="UIGridViewBoundColumnResource8">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                    </Columns>
                                </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabCredentials" Caption="Credentials" meta:resourcekey="tabCredentialsResource1" BorderStyle="NotSet">
                    <ui:UIFieldCheckBox runat="server" ID="checkIsBanned" PropertyName="IsBanned" Caption="Banned" Text="Yes, this user is currently banned from logging in to the system." OnCheckedChanged="checkIsBanned_CheckedChanged" meta:resourcekey="checkIsBannedResource1" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldTextBox runat="server" ID="UserLoginName" PropertyName="UserBase.LoginName" Caption="Login Name" ValidateRequiredField="True" meta:resourcekey="UserLoginNameResource1" InternalControlWidth="95%" />
                    <ui:UIFieldCheckBox runat="server" ID="IsActiveDirectoryUser" Caption="Active Directory" PropertyName="IsActiveDirectoryUser" Text="Yes, this user is an Active Directory User" OnCheckedChanged="IsActiveDirectoryUser_checkChanged" meta:resourcekey="IsActiveDirectoryUserResource2" TextAlign="Right" Visible="false">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldTextBox runat="server" ID="ActiveDirectoryDomain" PropertyName="ActiveDirectoryDomain" Caption="Active Directory Domain" ValidateRequiredField="True" meta:resourcekey="ActiveDirectoryDomainResource1" InternalControlWidth="95%" />
                    <ui:UIPanel runat="server" ID="panelPassword">
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource2" />
                        <ui:UIFieldCheckBox runat="server" ID="chkResetPassword" Caption="Reset Password" Text="Yes, generate a new password and send it via e-mail to the user when I save." OnCheckedChanged="chkResetPassword_CheckedChange" meta:resourcekey="chkResetPasswordResource1" TextAlign="Right" />
                        <ui:UIFieldTextBox runat="server" ID="Password1" Caption="Password" TextMode="Password" Span="Half" meta:resourcekey="Password1Resource1" MaxLength="30" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="Password2" Caption="Confirm Password" TextMode="Password" Span="Half" meta:resourcekey="Password2Resource1" MaxLength="30" InternalControlWidth="95%" />
                    </ui:UIPanel>
                    <br />
                    <br />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTheme" Caption="Theme" CssClass="div-from" meta:resourcekey="tabThemeResource1" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelTheme" meta:resourcekey="panelThemeResource1" BorderStyle="NotSet">
                        <ui:UIFieldDropDownList runat="server" ID="ThemeName" PropertyName="ThemeName" Caption="Theme" ToolTip="Changes to the theme will only take effect on the next logon." meta:resourcekey="ThemeNameResource1" ValidateRequiredField="True" OnSelectedIndexChanged="ThemeName_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                            <tr>
                                <td style="width: 150px">
                                </td>
                                <td>
                                    <iframe runat="server" id="frameTheme" width="600px" height="300px" style="border: solid 1px gray" frameborder="0" scrolling="no"></iframe>
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
            <asp:LinkButton runat="server" ID="buttonDelegatePositionsHidden" meta:resourcekey="buttonDelegatePositionsHiddenResource1" />
            <asp:ModalPopupExtender runat='server' id="popupDelegatePositions" PopupControlID="objectPanelDelegatePositions" BackgroundCssClass="modalBackground" TargetControlID="buttonDelegatePositionsHidden" DynamicServicePath="" Enabled="True">
            </asp:ModalPopupExtender>
            <ui:uiobjectpanel runat="server" id="objectPanelDelegatePositions" Width="400px" BackColor="White" BorderStyle="NotSet" meta:resourcekey="objectPanelDelegatePositionsResource1">
                <div style="padding: 8px 8px 8px 8px">
                    <ui:uiseparator id="Uiseparator3" runat="server" caption="Delegate Selected Positions" meta:resourcekey="Uiseparator3Resource1" />
                    <ui:uifieldsearchabledropdownlist runat="server" id="dropGrantedToUser" Caption="User" validaterequiredfield="True" meta:resourcekey="dropGrantedToUserResource1" SearchInterval="300">
                    </ui:uifieldsearchabledropdownlist>
                    <ui:uifielddatetime runat="server" id="dateDelegateStartDate" Caption="Start Date" ValidaterequiredField="True" meta:resourcekey="dateDelegateStartDateResource1" ShowDateControls="True">
                    </ui:uifielddatetime>
                    <ui:uifielddatetime runat="server" id="dateDelegateEndDate" Caption="End Date" ValidaterequiredField="True" meta:resourcekey="dateDelegateEndDateResource1" ShowDateControls="True">
                    </ui:uifielddatetime>
                    <br />
                    <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray; width: 100%">
                        <tr>
                            <td style='width: 120px'>
                            </td>
                            <td>
                                <ui:uibutton runat='server' id="buttonDelegateConfirm" Text="Confirm" Imageurl="~/images/add.gif" OnClick="buttonDelegateConfirm_Click" meta:resourcekey="buttonDelegateConfirmResource1" />
                                <ui:uibutton runat='server' id="buttonDelegateCancel" Text="Cancel" Imageurl="~/images/delete.gif" CausesValidation='False' OnClick="buttonDelegateCancel_Click" meta:resourcekey="buttonDelegateCancelResource1" />
                            </td>
                        </tr>
                    </table>
                </div>
            </ui:uiobjectpanel>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
