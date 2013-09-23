<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Net.Security" %>
<%@ Import Namespace="System.Net" %>
<script runat="server"> 

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    /// 
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OUserUpdate userUpdate = panel.SessionObject as OUserUpdate;
        objectBase.ObjectNumberVisible = !userUpdate.IsNew;
        
        List<OLocation> locations = new List<OLocation>();
        foreach (OPosition p in AppSession.User.GetPositionsByObjectType("OUser"))
            foreach (OLocation location in p.LocationAccess)
                locations.Add(location);
        sddl_PositionID.Bind(OPosition.GetPositionsAtOrBelowLocations(locations), "ObjectName", "ObjectID");
        dropUser.Bind(OUser.GetAllNonTenantUsers());
        gridUserUpdateUser.Bind(userUpdate.UserUpdateUser);
        
        panel.ObjectPanel.BindObjectToControls(userUpdate);
    }

    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        userUpdateUser_subPanel.ObjectPanel.Enabled = !objectBase.CurrentObjectState.Is("Approved", "PendingApproval", "Cancelled");
        gridUserUpdateUser.Columns[9].Visible = objectBase.CurrentObjectState.Is("Start", "PendingApproval", "Draft");
    }
    
    /// <summary>
    /// Validates and saves the craft object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    /// 
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OUserUpdate userUpdate = panel.SessionObject as OUserUpdate;
            panel.ObjectPanel.BindControlsToObject(userUpdate);

            userUpdate.Save();
            c.Commit();
        }
    }

    protected void userUpdateUser_subPanel_PopulateForm(object sender, EventArgs e)
    {
        OUserUpdateUser userUpdateUser = userUpdateUser_subPanel.SessionObject as OUserUpdateUser;
        objectpanelVPVendor.BindObjectToControls(userUpdateUser);
        gridExistingPositions.Visible = objectBase.CurrentObjectState.Is("Start", "PendingApproval", "Draft");
    }

    protected void userUpdateUser_subPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OUserUpdateUser userUpdateUser = userUpdateUser_subPanel.SessionObject as OUserUpdateUser;
        objectpanelVPVendor.BindControlsToObject(userUpdateUser);
        
        OUserUpdate userUpdate = panel.SessionObject as OUserUpdate;
        userUpdate.UserUpdateUser.Add(userUpdateUser);
        panelVPVendor.BindControlsToObject(userUpdate);
        
        panelVPVendor.BindObjectToControls(userUpdate);
    }

    protected void dropUser_SelectedIndexChanged(object sender, EventArgs e)
    {
        OUserUpdate userUpdate = panel.SessionObject as OUserUpdate;
        panel.ObjectPanel.BindControlsToObject(userUpdate);
        if (dropUser.SelectedValue != "")
        {
            OUserUpdateUser userUpdateUser = TablesLogic.tUserUpdateUser.Create();
            userUpdateUser.UserID = new Guid(dropUser.SelectedValue);
            userUpdateUser.PermanentPositions.Clear();
            objectpanelVPVendor.BindObjectToControls(userUpdateUser);
        }

        panel.ObjectPanel.BindObjectToControls(userUpdate);
    }
    
    protected void sddl_PositionID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OUserUpdate userUpdate = panel.SessionObject as OUserUpdate;
        panel.ObjectPanel.BindControlsToObject(userUpdate);
        if (sddl_PositionID.SelectedValue != "" )
        {
            OUserUpdateUser userUpdateUser = userUpdateUser_subPanel.SessionObject as OUserUpdateUser;
            objectpanelVPVendor.BindControlsToObject(userUpdateUser);
            OUserPermanentPosition pp = TablesLogic.tUserPermanentPosition.Create();
            pp.PositionID = new Guid(sddl_PositionID.SelectedValue);
            userUpdateUser.PermanentPositions.Add(pp);
            userUpdateUser_subPanel.ObjectPanel.BindObjectToControls(userUpdateUser);
        }
        panel.ObjectPanel.BindObjectToControls(userUpdate);
    }
        
    protected void gv_Position_Action_New(object sender, string commandName, List<object> objectIds)
    {
        OUserUpdate userUpdate = panel.SessionObject as OUserUpdate;
        panel.ObjectPanel.BindControlsToObject(userUpdate);
        
        if (commandName == "RemoveObject" || commandName == "Remove")
        {
            OUserUpdateUser userUpdateUser = userUpdateUser_subPanel.SessionObject as OUserUpdateUser;
            objectpanelVPVendor.BindControlsToObject(userUpdateUser);
            foreach (Guid id in objectIds)
            {
                OUserPermanentPosition pp = userUpdateUser.PermanentPositions.Find(id);
                userUpdateUser.PermanentPositions.Remove(pp);
            }
            userUpdateUser_subPanel.ObjectPanel.BindObjectToControls(userUpdateUser);
        }
        panel.ObjectPanel.BindObjectToControls(userUpdate);
    }
    
    protected void gridUserUpdateUser_Action(object sender, string commandName, List<object> objectIds)
    {
        OUserUpdate userUpdate = panel.SessionObject as OUserUpdate;
        panel.ObjectPanel.BindControlsToObject(userUpdate);
        
        if (commandName == "ViewObject")
        {
            OUserUpdateUser userUpdateUser = TablesLogic.tUserUpdateUser.Load((Guid)objectIds[0]);
            if (userUpdateUser.UserID != null)
                Window.OpenViewObjectPage(this, "OUser", userUpdateUser.UserID.ToString(), "");
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
            <web:object runat="server" ID="panel" Caption="User Update" BaseTable="tUserUpdate" OnPopulateForm="panel_PopulateForm"
                OnValidateAndSave="panel_ValidateAndSave"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberEnabled="false" 
                        ObjectNumberValidateRequiredField="true" ObjectNumberVisible="false">
                        </web:base>
                        
                    <ui:UIPanel runat="server" ID="panelVPVendor">
                    <ui:UIFieldLabel runat="server" ID="test"></ui:UIFieldLabel>
                        <ui:UIGridView runat="server" id="gridUserUpdateUser" PropertyName="UserUpdateUser" 
                        Caption="User Update Users" ValidateRequiredField="true"
                        OnAction="gridUserUpdateUser_Action">
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
                                <ui:UIGridViewBoundColumn DataField="User.ObjectName" HeaderText="User Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="User.ObjectName" 
                                    ResourceAssemblyName="" SortExpression="User.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="User.LoginName" 
                                    HeaderText="Login Name" meta:resourceKey="UIGridViewColumnResource5" 
                                    PropertyName="User.UserBase.LoginName" ResourceAssemblyName="" 
                                    SortExpression="LoginName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="User.UserBase.CellPhone" 
                                    HeaderText="CellPhone" meta:resourceKey="UIGridViewColumnResource6" 
                                    PropertyName="User.UserBase.Cellphone" ResourceAssemblyName="" 
                                    SortExpression="CellPhone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Email" HeaderText="Email" 
                                    meta:resourceKey="UIGridViewColumnResource7" PropertyName="User.UserBase.Email" 
                                    ResourceAssemblyName="" SortExpression="Email">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Fax" HeaderText="Fax" 
                                    meta:resourceKey="UIGridViewColumnResource8" PropertyName="User.UserBase.Fax" 
                                    ResourceAssemblyName="" SortExpression="Fax">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="Phone" HeaderText="Phone" 
                                    meta:resourceKey="UIGridViewColumnResource9" PropertyName="User.UserBase.Phone" 
                                    ResourceAssemblyName="" SortExpression="UserBase.Phone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentPositionsText" HeaderText="Current Positions" 
                                    meta:resourceKey="CurrentPositionsTextResource1" PropertyName="CurrentPositionsText" 
                                    ResourceAssemblyName="" SortExpression="CurrentPositionsText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="NewPositionsText" HeaderText="New Positions" 
                                    meta:resourceKey="NewPositionsTextResource1" PropertyName="NewPositionsText" 
                                    ResourceAssemblyName="" SortExpression="NewPositionsText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                 </Columns>
                    </ui:UIGridView>
                    <ui:uiobjectpanel runat="server" id="objectpanelVPVendor">
                        <web:subpanel runat="server" id="userUpdateUser_subPanel" GridViewID="gridUserUpdateUser"
                         OnPopulateForm="userUpdateUser_subPanel_PopulateForm" OnValidateAndUpdate="userUpdateUser_subPanel_ValidateAndUpdate" />
                          <ui:UIFieldSearchableDropDownList ID="dropUser" runat="server" Caption="User" PropertyName="UserID" 
                                    OnSelectedIndexChanged="dropUser_SelectedIndexChanged" ValidateRequiredField="true"
                                    meta:resourcekey="dropUserResource1" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        <ui:uifieldtextbox runat="server" id="UserName" PropertyName="User.ObjectName" Caption="User Name" Enabled="false"
                         ValidateRequiredField="false"></ui:uifieldtextbox>
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="User.UserBase.Cellphone"
                        Caption="Cell Phone" Span="Half" Enabled="false" 
                        meta:resourcekey="uifieldstring4Resource1" InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="textEmail" PropertyName="User.UserBase.Email" Caption="Email"
                        Span="Half" meta:resourcekey="uifieldstring5Resource1" Enabled="false" 
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="User.UserBase.Fax"
                        Caption="Fax" Span="Half" meta:resourcekey="uifieldstring6Resource1" Enabled="false"
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="User.UserBase.Phone"
                        Caption="Phone" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" Enabled="false"
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox2" PropertyName="User.UserBase.AddressCountry"
                        Caption="Country" Span="Half" meta:resourcekey="UIFieldTextBox2Resource2" Enabled="false"
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox3" PropertyName="User.UserBase.AddressCity"
                        Caption="City" Span="Half" meta:resourcekey="UIFieldTextBox2Resource3" Enabled="false"
                        InternalControlWidth="95%" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring10" PropertyName="User.UserBase.Address"
                        Caption="Address" Span="Half" meta:resourcekey="uifieldstring10Resource1" Enabled="false"
                        MaxLength="255" InternalControlWidth="95%" />
                    <ui:UISeparator runat='server' ID="UISeparator1"  meta:resourcekey="UISeparator1Resource1" />
                        <ui:UIGridView runat="server" ID="gridExistingPositions"
                                        Caption="Existing Position(s)" 
                                        KeyName="ObjectID" BindObjectsToRows="True" PropertyName="User.PermanentPositions"
                                        meta:resourcekey="gv_PositionResource2" DataKeyNames="ObjectID" 
                                        GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" style="clear:both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                           
                                            <ui:UIGridViewBoundColumn DataField="Position.ObjectName" HeaderText="Name" 
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
                                                        ShowCaption="false" ValidateCompareField="true" Enabled="false"
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
                                                        ShowCaption="false" ValidateCompareField="true" Enabled="false"
                                                        ValidationCompareControl="textStartDate" 
                                                        ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date">
                                                    </ui:UIFieldDateTime>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" Width="150px" />
                                            </ui:UIGridViewTemplateColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                    <br /><br />
                        <ui:UIFieldSearchableDropDownList ID="sddl_PositionID" runat="server" 
                                    Caption="New Position(s)" 
                                    OnSelectedIndexChanged="sddl_PositionID_SelectedIndexChanged"  
                                    meta:resourcekey="sddl_PositionIDResource2" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        
                        <ui:UIGridView runat="server" ID="gridNewPositions"
                                        OnAction="gv_Position_Action_New" Caption="New Position(s)" 
                                        KeyName="ObjectID" BindObjectsToRows="True" PropertyName="PermanentPositions"
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
                                            <ui:UIGridViewBoundColumn DataField="Position.ObjectName" HeaderText="Name" 
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
