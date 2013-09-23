<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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
        ONotificationHierarchy notificationHierarchy = (ONotificationHierarchy)panel.SessionObject;
        
        dropRoles.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID", true);
        dropUsers.Bind(OUser.GetAllUsers(), "ObjectName", "ObjectID", true);
        dropPositions.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID", true);
        
        panel.ObjectPanel.BindObjectToControls(notificationHierarchy);
    }


    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            ONotificationHierarchy notificationHierarchy = (ONotificationHierarchy)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(notificationHierarchy);

            // Validate
            //
            // if(!xxxx.ValidationSomething)
            //    someControl.ErrorMessage = "Please enter a valid value.";
            //
            // if (!panel.ObjectPanel.IsValid)
            //     return;

            // Save
            //
            notificationHierarchy.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Occurs when the user selects a role.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropRoles_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropRoles.SelectedValue != "")
        {
            ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
            level.Roles.AddGuid(new Guid(dropRoles.SelectedValue));
            panelRoles.BindObjectToControls(level);

            dropRoles.SelectedValue = "";
        }
    }


    /// <summary>
    /// Occurs when the user selects a user.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropUsers_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropUsers.SelectedValue != "")
        {
            ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
            level.Users.AddGuid(new Guid(dropUsers.SelectedValue));
            panelUsers.BindObjectToControls(level);

            dropUsers.SelectedValue = "";
        }
    }


    /// <summary>
    /// Occurs when the user selects a position.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropPositions_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropPositions.SelectedValue != "")
        {
            ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
            level.Positions.AddGuid(new Guid(dropPositions.SelectedValue));
            panelPositions.BindObjectToControls(level);

            dropPositions.SelectedValue = "";
        }
    }


    /// <summary>
    /// Occurs when the user clicks a button on the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridRoles_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.Roles.RemoveGuid(id);
            panelRoles.BindObjectToControls(level);
        }
    }


    /// <summary>
    /// Occurs when the user clicks a button on the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridUsers_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.Users.RemoveGuid(id);
            panelUsers.BindObjectToControls(level);
        }

    }


    /// <summary>
    /// Occurs when the user clicks a button on the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridPositions_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.Positions.RemoveGuid(id);
            panelPositions.BindObjectToControls(level);
        }

    }

    /// <summary>
    /// Occurs when the user creates or edits a notification hierarchy level.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelNotificationHierarchyLevel_PopulateForm(object sender, EventArgs e)
    {
        ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
        subpanelNotificationHierarchyLevel.ObjectPanel.BindObjectToControls(level);
    }
    
    
    /// <summary>
    /// Occurs when the user updates the notification level.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelNotificationHierarchyLevel_ValidateAndUpdate(object sender, EventArgs e)
    {
        ONotificationHierarchy notificationHierarchy = (ONotificationHierarchy)panel.SessionObject;
        tabDetails.BindControlsToObject(notificationHierarchy);
        
        ONotificationHierarchyLevel level = subpanelNotificationHierarchyLevel.SessionObject as ONotificationHierarchyLevel;
        subpanelNotificationHierarchyLevel.ObjectPanel.BindControlsToObject(level);

        if (!level.ValidateUserOrRoleOrPositionSpecified())
        {
            gridUsers.ErrorMessage = Resources.Errors.NotificationHierarchy_UsersRolesNotSpecified;
            gridRoles.ErrorMessage = Resources.Errors.NotificationHierarchy_UsersRolesNotSpecified;
            gridPositions.ErrorMessage = Resources.Errors.NotificationHierarchy_UsersRolesNotSpecified;
        }
        if (!subpanelNotificationHierarchyLevel.ObjectPanel.IsValid)
            return;

        notificationHierarchy.NotificationHierarchyLevels.Add(level);
        notificationHierarchy.UpdateNotificationLevels();
        tabDetails.BindObjectToControls(notificationHierarchy);
    }

    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Notification Hierarchy" BaseTable="tNotificationHierarchy"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                    BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Hierarchy Name"
                        ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1" ></web:base>
                    <ui:UIGridView ID="gridNotificationHierarchyLevels" runat="server" Caption="Notification Hierarchy Levels"
                        PropertyName="NotificationHierarchyLevels" SortExpression="NotificationLevel asc"
                        ValidateRequiredField="True" DataKeyNames="ObjectID" GridLines="Both" 
                        ImageRowErrorUrl="" meta:resourcekey="gridNotificationHierarchyLevelsResource1" 
                        RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="DeleteObject" CommandText="Delete" 
                                ConfirmText="Are you sure you wish to delete the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="NotificationLevel" 
                                HeaderText="Notification Level" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" 
                                PropertyName="NotificationLevel" ResourceAssemblyName="" 
                                SortExpression="NotificationLevel">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes1" 
                                HeaderText="Notification Time 1" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" 
                                PropertyName="NotificationTimeInMinutes1" ResourceAssemblyName="" 
                                SortExpression="NotificationTimeInMinutes1">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes2" 
                                HeaderText="Notification Time 2" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" 
                                PropertyName="NotificationTimeInMinutes2" ResourceAssemblyName="" 
                                SortExpression="NotificationTimeInMinutes2">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes3" 
                                HeaderText="Notification Time 3" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" 
                                PropertyName="NotificationTimeInMinutes3" ResourceAssemblyName="" 
                                SortExpression="NotificationTimeInMinutes3">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes4" 
                                HeaderText="Notification Time 4" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" 
                                PropertyName="NotificationTimeInMinutes4" ResourceAssemblyName="" 
                                SortExpression="NotificationTimeInMinutes4">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="UserNames" HeaderText="Users" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="UserNames" 
                                ResourceAssemblyName="" SortExpression="UserNames">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="PositionNames" HeaderText="Positions">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="RoleNames" HeaderText="Roles" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="RoleNames" 
                                ResourceAssemblyName="" SortExpression="RoleNames">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="panelNotificationHierarchyLevel" runat="server" 
                        BorderStyle="NotSet" 
                        meta:resourcekey="panelNotificationHierarchyLevelResource1">
                        <web:subpanel runat="server" ID="subpanelNotificationHierarchyLevel" GridViewID="gridNotificationHierarchyLevels" OnValidateAndUpdate="subpanelNotificationHierarchyLevel_ValidateAndUpdate" OnPopulateForm="subpanelNotificationHierarchyLevel_PopulateForm" />
                        <ui:UIFieldTextBox runat="server" ID="textNotificationTimeInMinutes1" PropertyName="NotificationTimeInMinutes1" 
                            Caption="Minutes" InternalControlWidth="95%" 
                            meta:resourcekey="textNotificationTimeInMinutes1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="textNotificationTimeInMinutes2" PropertyName="NotificationTimeInMinutes2" 
                            Caption="Minutes" InternalControlWidth="95%" 
                            meta:resourcekey="textNotificationTimeInMinutes2Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="textNotificationTimeInMinutes3" PropertyName="NotificationTimeInMinutes3" 
                            Caption="Minutes" InternalControlWidth="95%" 
                            meta:resourcekey="textNotificationTimeInMinutes3Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="textNotificationTimeInMinutes4" PropertyName="NotificationTimeInMinutes4" 
                            Caption="Minutes" InternalControlWidth="95%" 
                            meta:resourcekey="textNotificationTimeInMinutes4Resource1" />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
                        <table cellpadding='0' cellspacing='0' style="width: 100%">
                            <tr valign="top">
                                <td style='width: 32%'>
                                    <asp:label runat='server' id="labelUsers" Text="Select Users:"></asp:label>
                                    <ui:UIPanel runat="server" ID="panelUsers" BorderStyle="NotSet" 
                                        meta:resourcekey="panelUsersResource1">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropUsers" 
                                            ShowCaption="false"
                                            ToolTip="Indicate the actual users who will be assigned for Notification at this level." 
                                            OnSelectedIndexChanged="dropUsers_SelectedIndexChanged" 
                                            meta:resourcekey="dropUsersResource1" SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridUsers" PropertyName="Users" 
                                            Caption="Assigned User(s)" OnAction="gridUsers_Action" 
                                            SortExpression="ObjectName" DataKeyNames="ObjectID" GridLines="Both" 
                                            ImageRowErrorUrl="" meta:resourcekey="gridUsersResource1" RowErrorColor="" 
                                            style="clear:both;">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                    CommandName="RemoveObject" CommandText="Remove Selected" 
                                                    ConfirmText="Are you sure you wish to remove the selected users?" 
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource3" />
                                            </commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                    ConfirmText="Are you sure you wish to remove this user?" 
                                                    ImageUrl="~/images/delete.gif" 
                                                    meta:resourcekey="UIGridViewButtonColumnResource3">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="ObjectName" 
                                                    meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="ObjectName" 
                                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                                <td style='width: 2%'>
                                </td>
                                <td style='width: 32%'>
                                    <asp:label runat='server' id="labelPositions" Text="Select Positions:"></asp:label>
                                    <ui:UIPanel runat="server" ID="panelPositions" BorderStyle="NotSet">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropPositions" 
                                            ShowCaption="false"
                                            ToolTip="Indicate the positions that will be assigned for Notification at this level. During the Notification process, the workflow will automatically assign the appropriate position based on the roles selected here." 
                                            OnSelectedIndexChanged="dropPositions_SelectedIndexChanged" 
                                            SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridPositions" PropertyName="Positions" 
                                            Caption="Assigned Positions(s)" OnAction="gridPositions_Action" 
                                            SortExpression="ObjectName" 
                                            DataKeyNames="ObjectID">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                    CommandName="RemoveObject" CommandText="Remove Selected" 
                                                    ConfirmText="Are you sure you wish to remove the selected positions?" 
                                                    ImageUrl="~/images/delete.gif" />
                                            </commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                    ConfirmText="Are you sure you wish to remove this position?" 
                                                    ImageUrl="~/images/delete.gif" >
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Position Name">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                                <td style='width: 2%'>
                                </td>
                                <td style='width: 32%'>
                                    <asp:label runat='server' id="labelRoles" Text="Select Roles:"></asp:label>
                                    <ui:UIPanel runat="server" ID="panelRoles" BorderStyle="NotSet" 
                                        meta:resourcekey="panelRolesResource1">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropRoles" 
                                            ShowCaption="false"
                                            ToolTip="Indicate the roles that will be assigned for Notification at this level. During the Notification process, the workflow will automatically assign the appropriate position based on the roles selected here." 
                                            OnSelectedIndexChanged="dropRoles_SelectedIndexChanged" 
                                            meta:resourcekey="dropRolesResource1" SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridRoles" PropertyName="Roles" 
                                            Caption="Assigned Role(s)" OnAction="gridRoles_Action" 
                                            SortExpression="RoleName" DataKeyNames="ObjectID" GridLines="Both" 
                                            ImageRowErrorUrl="" meta:resourcekey="gridRolesResource1" RowErrorColor="" 
                                            style="clear:both;">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                    CommandName="RemoveObject" CommandText="Remove Selected" 
                                                    ConfirmText="Are you sure you wish to remove the selected roles?" 
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource4" />
                                            </commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                    ConfirmText="Are you sure you wish to remove this role?" 
                                                    ImageUrl="~/images/delete.gif" 
                                                    meta:resourcekey="UIGridViewButtonColumnResource4">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="RoleName" 
                                                    meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="RoleName" 
                                                    ResourceAssemblyName="" SortExpression="RoleName">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                            </tr>
                        </table>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                    meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" 
                    BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
