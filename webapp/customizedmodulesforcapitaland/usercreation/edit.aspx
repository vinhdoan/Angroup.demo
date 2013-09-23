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
        OUserCreation vendor = panel.SessionObject as OUserCreation;
        objectBase.ObjectNumberVisible = !vendor.IsNew;
        panel.ObjectPanel.BindObjectToControls(vendor);
        List<OLocation> locations = new List<OLocation>();
        foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OUser"))
            foreach (OLocation location in position.LocationAccess)
                locations.Add(location);
        sddl_PositionID.Bind(OPosition.GetPositionsAtOrBelowLocations(locations), "ObjectName", "ObjectID");
        
    }

    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        //tabDetails.Enabled = !objectBase.CurrentObjectState.Is("Approved","Cancelled");

        UserCreationUser_subPanel.ObjectPanel.Enabled = !objectBase.CurrentObjectState.Is("Approved", "PendingApproval", "Cancelled");
        
        if (this.IsActiveDirectoryUser.Checked)
        {
            chkResetPassword.Visible = false;
            //Password1.Visible = false;
            //Password2.Visible = false;
            ActiveDirectoryDomain.Visible = true;
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
    /// Validates and saves the craft object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OUserCreation userCreation = panel.SessionObject as OUserCreation;
            panel.ObjectPanel.BindControlsToObject(userCreation);

            if (objectBase.SelectedAction == "SubmitForApproval" || objectBase.SelectedAction == "Approve")
            {
                string error = "";
                foreach (OUserCreationUser userCreationUser in userCreation.UserCreationUser)
                {
                    OUser u = TablesLogic.tUser.Load(TablesLogic.tUser.ObjectName == userCreationUser.ObjectName |
                    TablesLogic.tUser.UserBase.LoginName == userCreationUser.LoginName);
                    if (u != null)
                        error += (error == "" ? "" : ", ") + userCreationUser.ObjectName;
                }
                if (error != "")
                    gridUserCreationUser.ErrorMessage = string.Format(Resources.Errors.UserCreation_DuplicateUserName, error);
            }
            userCreation.Save();
            c.Commit();

            
        }
    }

    protected void UserCreationUser_subPanel_PopulateForm(object sender, EventArgs e)
    {
        OUserCreationUser userCreationUser = UserCreationUser_subPanel.SessionObject as OUserCreationUser;
        Craft.Bind(OCraft.GetAllCraft());
        ddl_Language.Bind(OLanguage.GetAllLanguages(), "ObjectName", "ObjectID");
        objectpanelVPVendor.BindControlsToObject(userCreationUser);
        textEmail.ValidateRequiredField = OApplicationSetting.Current.IsUserEmailCompulsory.Value == 1 ? true : false;
        
        if (objectBase.CurrentObjectState.Is("Approved"))
            gridNewPositions.Bind(TablesLogic.tUser.Load(userCreationUser.NewUserID).PermanentPositions);
        else
            gridNewPositions.Bind(userCreationUser.PermanentPosition);
    }

    protected void UserCreationUser_subPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OUserCreationUser userCreationUser = UserCreationUser_subPanel.SessionObject as OUserCreationUser;
        objectpanelVPVendor.BindControlsToObject(userCreationUser);

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
                if (OUserPasswordHistory.DoesPasswordExist(userCreationUser.ObjectID.Value, strHashedNewPassword))
                {
                    Password1.ErrorMessage =
                        Password2.ErrorMessage =
                        String.Format(Resources.Errors.User_PasswordHistoryExists,
                        applicationSetting.PasswordHistoryKept);
                }
                
            }
        }
        //check duplicate user email if email is entered
        if (textEmail.Text != String.Empty && textEmail.Text != null && userCreationUser.IsDuplicateUserEmail() == true)
            textEmail.ErrorMessage = Resources.Errors.User_DuplicatedUserEmail;

        if (userCreationUser.PermanentPosition.Count == 0)
            gridNewPositions.ErrorMessage = Resources.Errors.UserCreation_NoPositions;
        
        if (!UserCreationUser_subPanel.ObjectPanel.IsValid)
            return;
        
        OUserCreation userCreation = panel.SessionObject as OUserCreation;
        userCreationUser.Password = Password1.Text;
        userCreation.UserCreationUser.Add(userCreationUser);
        panelVPVendor.BindObjectToControls(userCreation);
    }

    protected void IsActiveDirectoryUser_checkChanged(object sender, EventArgs e)
    {

    }

    protected void chkResetPassword_CheckedChange(object sender, EventArgs e)
    {
        Password1.Text = "";
        Password2.Text = "";
    }

    protected void gv_Position_Action_New(object sender, string commandName, List<object> objectIds)
    {
        OUserCreation userCreation = panel.SessionObject as OUserCreation;
        panel.ObjectPanel.BindControlsToObject(userCreation);
        OUserCreationUser userCreationUser = UserCreationUser_subPanel.SessionObject as OUserCreationUser;
        UserCreationUser_subPanel.ObjectPanel.BindControlsToObject(userCreationUser);
        if (commandName == "RemoveObject" || commandName == "Remove")
        {
            
            foreach (Guid id in objectIds)
            {
                OUserPermanentPosition pp = userCreationUser.PermanentPosition.Find(id);
                userCreationUser.PermanentPosition.Remove(pp);
            }
            
        }
        
        UserCreationUser_subPanel.ObjectPanel.BindObjectToControls(userCreationUser);
        panel.ObjectPanel.BindObjectToControls(userCreation);
        
    }

    protected void sddl_PositionID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OUserCreation userCreation = panel.SessionObject as OUserCreation;
        panel.ObjectPanel.BindControlsToObject(userCreation);
        if (sddl_PositionID.SelectedValue != "")
        {
            OUserCreationUser userCreationUser = UserCreationUser_subPanel.SessionObject as OUserCreationUser;
            UserCreationUser_subPanel.ObjectPanel.BindControlsToObject(userCreationUser);
            OUserPermanentPosition pp = TablesLogic.tUserPermanentPosition.Create();
            pp.PositionID = new Guid(sddl_PositionID.SelectedValue);
            userCreationUser.PermanentPosition.Add(pp);
            UserCreationUser_subPanel.ObjectPanel.BindObjectToControls(userCreationUser);
        }
        panel.ObjectPanel.BindObjectToControls(userCreation);
    }

    protected void gridUserCreationUser_Action(object sender, string commandName, List<object> objectIds)
    {
        OUserCreation userCreation = panel.SessionObject as OUserCreation;
        panel.ObjectPanel.BindControlsToObject(userCreation);
        
        if (commandName == "ViewObject")
        {
            OUserCreationUser userCreationUser = TablesLogic.tUserCreationUser.Load((Guid)objectIds[0]);
            if(userCreationUser.NewUserID != null)
                Window.OpenViewObjectPage(this, "OUser", userCreationUser.NewUserID.ToString(), "");
        }
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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="User Creation" BaseTable="tUserCreation" OnPopulateForm="panel_PopulateForm"
                OnValidateAndSave="panel_ValidateAndSave"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberEnabled="false" 
                        ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false">
                        </web:base>
                        <ui:uipanel id="panelDetails" runat="server" borderstyle="NotSet" >
                        </ui:uipanel>
                    
                     
                     
                        <ui:UIPanel runat="server" ID="panelVPVendor">
                        <ui:UIGridView runat="server" id="gridUserCreationUser" PropertyName="UserCreationUser" Caption="User Creation Users" ValidateRequiredField="true"
                        OnAction="gridUserCreationUser_Action">
                        <Commands>
                            <ui:UIGridViewCommand CommandName="AddObject" ImageUrl="~/images/add.gif" CommandText="Add" />
                            <ui:UIGridViewCommand CommandName="RemoveObject" ImageUrl="~/images/delete.gif" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" />
                        </Commands>
                        <Columns>
                            
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="ObjectName" HeaderText="User Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="LoginName" 
                                    HeaderText="Login Name" meta:resourceKey="UIGridViewColumnResource5" 
                                    PropertyName="LoginName" ResourceAssemblyName="" 
                                    SortExpression="LoginName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CellPhone" 
                                    HeaderText="CellPhone" meta:resourceKey="UIGridViewColumnResource6" 
                                    PropertyName="CellPhone" ResourceAssemblyName="" 
                                    SortExpression="CellPhone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Email" HeaderText="Email" 
                                    meta:resourceKey="UIGridViewColumnResource7" PropertyName="Email" 
                                    ResourceAssemblyName="" SortExpression="UserBase.Email">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Fax" HeaderText="Fax" 
                                    meta:resourceKey="UIGridViewColumnResource8" PropertyName="Fax" 
                                    ResourceAssemblyName="" SortExpression="Fax">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Phone" HeaderText="Phone" 
                                    meta:resourceKey="UIGridViewColumnResource9" PropertyName="Phone" 
                                    ResourceAssemblyName="" SortExpression="UserBase.Phone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="IsActiveDirectoryUserText" 
                                    HeaderText="AD User" meta:resourceKey="UIGridViewColumnResource10" 
                                    PropertyName="IsActiveDirectoryUserText" ResourceAssemblyName="" 
                                    SortExpression="IsActiveDirectoryUserText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                 </Columns>
                    </ui:UIGridView>
                    <ui:uiobjectpanel runat="server" id="objectpanelVPVendor">
                        <web:subpanel runat="server" id="UserCreationUser_subPanel" GridViewID="gridUserCreationUser"
                        OnPopulateForm="UserCreationUser_subPanel_PopulateForm" OnValidateAndUpdate="UserCreationUser_subPanel_ValidateAndUpdate" />
                        <ui:uifieldtextbox runat="server" id="UserName" PropertyName="ObjectName" Caption="User Name" ValidateRequiredField="true"></ui:uifieldtextbox>
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="CellPhone"
                        Caption="Cell Phone" Span="Half" 
                        meta:resourcekey="uifieldstring4Resource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="textEmail" PropertyName="Email" Caption="Email"
                        Span="Half" meta:resourcekey="uifieldstring5Resource1" 
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="Fax"
                        Caption="Fax" Span="Half" meta:resourcekey="uifieldstring6Resource1" 
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="Phone"
                        Caption="Phone" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" 
                        InternalControlWidth="95%" />
                    
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring10" PropertyName="Address"
                        Caption="Address" Span="Half" meta:resourcekey="uifieldstring10Resource1" 
                        MaxLength="255" InternalControlWidth="95%" />
                    <ui:UIFieldDropDownList runat="server" ID="Craft" PropertyName="CraftID" Caption="Craft"
                        DataTextField="Name" Span="Half" ToolTip="The craft this technician belongs to."
                        meta:resourcekey="CraftResource1">
                    </ui:UIFieldDropDownList>
                    <br />
                    <ui:UISeparator runat='server' ID="UISeparator1"  meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="ddl_Language" PropertyName="LanguageID"
                        Caption="Language" ToolTip="Changes to the theme will only take effect on the next logon."
                        meta:resourcekey="LanguageNameResource1" ValidateRequiredField="True">
                    </ui:UIFieldDropDownList>
                    <ui:UISeparator runat="server" Caption="Credentials" ID="sepCredentials" />
                    <ui:UIFieldTextBox runat="server" ID="UserLoginName" PropertyName="LoginName"
                        Caption="Login Name" ValidateRequiredField="True" 
                        meta:resourcekey="UserLoginNameResource1" InternalControlWidth="95%" />
                    <ui:UIFieldCheckBox runat="server" ID="IsActiveDirectoryUser" Caption="Active Directory" PropertyName="IsActiveDirectoryUser"
                        Text="Yes, this user is an Active Directory User" OnCheckedChanged="IsActiveDirectoryUser_checkChanged"
                        meta:resourcekey="IsActiveDirectoryUserResource2" TextAlign="Right">
                        </ui:UIFieldCheckBox>
                    <ui:UIFieldTextBox runat="server" ID="ActiveDirectoryDomain" PropertyName="ActiveDirectoryDomain"
                        Caption="Active Directory Domain" ValidateRequiredField="True" 
                        meta:resourcekey="ActiveDirectoryDomainResource1" InternalControlWidth="95%" />
                    <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource2" />
                    <ui:UIFieldCheckBox runat="server" ID="chkResetPassword" Caption="Reset Password"
                        Text="Yes, generate a new password and send it via e-mail to the user when I save."
                        OnCheckedChanged="chkResetPassword_CheckedChange" 
                        meta:resourcekey="chkResetPasswordResource1" TextAlign="Right" />
                    <ui:UIFieldTextBox runat="server" ID="Password1" Caption="Password" TextMode="Password"
                        Span="Half" meta:resourcekey="Password1Resource1" MaxLength="30" ValidateRequiredField="true"
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="Password2" Caption="Confirm Password" TextMode="Password"
                        Span="Half" meta:resourcekey="Password2Resource1" MaxLength="30" ValidateRequiredField="true" 
                        InternalControlWidth="95%" />
                        <br />
                        <br />
                        <ui:UIFieldSearchableDropDownList ID="sddl_PositionID" runat="server" 
                                    Caption="New Position(s)"
                                    OnSelectedIndexChanged="sddl_PositionID_SelectedIndexChanged"  
                                    meta:resourcekey="sddl_PositionIDResource2" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        <ui:UIGridView runat="server" ID="gridNewPositions"
                                        OnAction="gv_Position_Action_New" Caption="" 
                                        KeyName="ObjectID" BindObjectsToRows="True" PropertyName="PermanentPosition"
                                        meta:resourcekey="gv_PositionResource2" DataKeyNames="ObjectID" 
                                        GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" style="clear:both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <commands>
                                        <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                CommandName="RemoveObject" CommandText="Remove" 
                                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                           
                                        </commands>
                                        <Columns>
                                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                ConfirmText="Are you sure you wish to remove this item?" 
                                                ImageUrl="~/images/delete.gif" 
                                                meta:resourceKey="UIGridViewButtonColumnResource1">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </ui:UIGridViewButtonColumn>
                                            <ui:UIGridViewBoundColumn DataField="PermanentPosition.Position.ObjectName" HeaderText="Name" 
                                                meta:resourceKey="UIGridViewBoundColumnResource1" 
                                                PropertyName="Position.ObjectName" ResourceAssemblyName="" 
                                                SortExpression="Position.ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </ui:UIGridViewBoundColumn>
                                            <ui:UIGridViewTemplateColumn HeaderText="Start Date">
                                                <ItemTemplate>
                                                    <ui:UIFieldDateTime ID="textStartDate" runat="server" Caption="Start Date" 
                                                        FieldLayout="Flow" InternalControlWidth="130px" PropertyName="StartDate" 
                                                        ShowCaption="false" ValidateCompareField="true" 
                                                        ValidationCompareControl="textEndDate" 
                                                        ValidationCompareOperator="LessThanEqual" ValidationCompareType="Date">
                                                    </ui:UIFieldDateTime>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" Width="150px" />
                                            </ui:UIGridViewTemplateColumn>
                                            <ui:UIGridViewTemplateColumn HeaderText="End Date">
                                                <ItemTemplate>
                                                    <ui:UIFieldDateTime ID="textEndDate" runat="server" Caption="End Date" 
                                                        FieldLayout="Flow" InternalControlWidth="130px" PropertyName="EndDate" 
                                                        ShowCaption="false" ValidateCompareField="true" 
                                                        ValidationCompareControl="textStartDate" 
                                                        ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date">
                                                    </ui:UIFieldDateTime>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" Width="150px" />
                                            </ui:UIGridViewTemplateColumn>
                                        </Columns>
                                    </ui:UIGridView>
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
