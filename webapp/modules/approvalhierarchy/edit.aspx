<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

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
        labelApprovalLimit1.Text += " " + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "";
        ApprovalHierarchyLevels.Columns[3].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        
        dropRoles.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID", true);
        dropUsers.Bind(OUser.GetAllUsers(), "ObjectName", "ObjectID", true);
        dropPositions.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID", true);

        panel.ObjectPanel.BindObjectToControls(panel.SessionObject);
    }
    

    

    /// <summary>
    /// Save the approval hierarchy object to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OApprovalHierarchy approvalHierarchy = (OApprovalHierarchy)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(approvalHierarchy);

            // Save
            approvalHierarchy.Save();
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
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
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
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
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
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
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
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
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
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
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
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.Positions.RemoveGuid(id);
            panelPositions.BindObjectToControls(level);
        }

    }
    
    
    /// <summary>
    /// Populates the sub panel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ApprovalHierarchyLevel_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OApprovalHierarchyLevel approvalHierarchyLevel = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;

        ApprovalHierarchyLevel_SubPanel.ObjectPanel.BindObjectToControls(approvalHierarchyLevel);
    }

    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ApprovalHierarchyLevel_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        
        OApprovalHierarchy approvalHierarchy = panel.SessionObject as OApprovalHierarchy;
        panel.ObjectPanel.BindControlsToObject(approvalHierarchy);

        OApprovalHierarchyLevel approvalHierarchyLevel =
            ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
        ApprovalHierarchyLevel_SubPanel.ObjectPanel.BindControlsToObject(approvalHierarchyLevel);

        if (!approvalHierarchyLevel.ValidateUserOrRoleOrPositionSpecified())
        {
            gridUsers.ErrorMessage = Resources.Errors.ApprovalHierarchy_UsersRolesNotSpecified;
            gridRoles.ErrorMessage = Resources.Errors.ApprovalHierarchy_UsersRolesNotSpecified;
            gridPositions.ErrorMessage = Resources.Errors.ApprovalHierarchy_UsersRolesNotSpecified;
        }
        
        if (approvalHierarchyLevel.IsDuplicate(approvalHierarchy, approvalHierarchyLevel))
            ApprovalLimit.ErrorMessage = Resources.Messages.General_DuplicateValue;

        if (!approvalHierarchyLevel.ValidateNumberOfUsersMoreThanNumberOfApprovalsRequired())
            this.textNumberOfApproversRequired.ErrorMessage = Resources.Errors.ApprovalHierarchyLevel_NumberOfUsersLessThanNumberOfApprovalsRequired;
           
        if (!ApprovalHierarchyLevel_Panel.IsValid)
            return;
        
        approvalHierarchy.ApprovalHierarchyLevels.Add(approvalHierarchyLevel);
        approvalHierarchy.UpdateApprovalLevels();
        panel.ObjectPanel.BindObjectToControls(approvalHierarchy);
        
    }

    
    /// <summary>
    /// Occurs when the user removes items from the approval hierarchy level.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ApprovalHierarchyLevel_SubPanel_Removed(object sender, EventArgs e)
    {
        OApprovalHierarchy approvalHierarchy = panel.SessionObject as OApprovalHierarchy;
        approvalHierarchy.UpdateApprovalLevels();
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
        <ui:UIObjectPanel runat="server" ID="panelMain" 
            meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
            <web:object runat="server" ID="panel" Caption="Approval Hierarchy" 
                BaseTable="tApprovalHierarchy" OnValidateAndSave="panel_ValidateAndSave" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Hierarchy Name"
                            ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIGridView ID="ApprovalHierarchyLevels" runat="server" Caption="Approval Hierarchy Levels"
                            PropertyName="ApprovalHierarchyLevels" SortExpression="ApprovalLevel asc" 
                            ValidateRequiredField="True" 
                            meta:resourcekey="ApprovalHierarchyLevelsResource1" DataKeyNames="ObjectID" 
                            GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                    meta:resourceKey="UIGridViewCommandResource2" />
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
                                <cc1:UIGridViewBoundColumn DataField="ApprovalLevel" 
                                    HeaderText="Approval Level" meta:resourceKey="UIGridViewBoundColumnResource1" 
                                    PropertyName="ApprovalLevel" ResourceAssemblyName="" 
                                    SortExpression="ApprovalLevel">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ApprovalLimit" 
                                    DataFormatString="{0:#,##0.00}" HeaderText="Approval Limit" 
                                    meta:resourceKey="UIGridViewBoundColumnResource2" PropertyName="ApprovalLimit" 
                                    ResourceAssemblyName="" SortExpression="ApprovalLimit">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NumberOfApprovalsRequired" 
                                    HeaderText="Approvals Required" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="NumberOfApprovalsRequired" ResourceAssemblyName="" 
                                    SortExpression="NumberOfApprovalsRequired">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserNames" HeaderText="Users" 
                                    meta:resourceKey="UIGridViewBoundColumnResource4" PropertyName="UserNames" 
                                    ResourceAssemblyName="" SortExpression="UserNames">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PositionNames" HeaderText="Positions" 
                                    PropertyName="PositionNames" 
                                    ResourceAssemblyName="" SortExpression="PositionNames">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="RoleNames" HeaderText="Roles" 
                                    meta:resourceKey="UIGridViewBoundColumnResource5" PropertyName="RoleNames" 
                                    ResourceAssemblyName="" SortExpression="RoleNames">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="ApprovalHierarchyLevel_Panel" runat="server" 
                            meta:resourcekey="ApprovalHierarchyLevel_PanelResource1" BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="ApprovalHierarchyLevel_SubPanel" GridViewID="ApprovalHierarchyLevels"
                                ObjectPanelID="ApprovalHierarchyLevel_Panel" 
                                OnPopulateForm="ApprovalHierarchyLevel_SubPanel_PopulateForm" OnValidateAndUpdate="ApprovalHierarchyLevel_SubPanel_ValidateAndUpdate" OnRemoved="ApprovalHierarchyLevel_SubPanel_Removed" meta:resourcekey="ApprovalHierarchyLevelsResource1"></web:subpanel>
                            &nbsp;
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr class='field-required'>
                                    <td style='width: 120px'><asp:label runat="server" id="labelApprovalLimitCaption" 
                                            meta:resourcekey="labelApprovalLimitCaptionResource1">Approval Limit</asp:label></td>
                                    <td>
                                        <asp:label runat="server" id="labelApprovalLimit1" 
                                            meta:resourcekey="labelApprovalLimit1Resource1">The user(s) can approve up to and including </asp:label>
                                        <ui:UIFieldTextBox runat="server" ID="ApprovalLimit" 
                                            PropertyName="ApprovalLimit" DataFormatString="{0:n}"
                                            InternalControlWidth="120px" ShowCaption="False" FieldLayout="Flow"
                                            Caption="Approval Limit" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                                            ValidationNumberOfDecimalPlaces="2" ValidateRangeField="True" ValidationRangeMin="0.01"
                                            ValidationRangeType='Currency' ValidateRequiredField="True" 
                                            meta:resourcekey="ApprovalLimitResource1" />
                                        <asp:label runat="server" id="labelApprovalLimit2" 
                                            meta:resourcekey="labelApprovalLimit2Resource1"> at this level.</asp:label>
                                    </td>
                                </tr>
                            </table>
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr class='field-required'>
                                    <td style='width: 120px'><asp:label runat="server" 
                                            id="labelApprovalsRequiredCaption" 
                                            meta:resourcekey="labelApprovalsRequiredCaptionResource1">Approvals Required*:</asp:label></td>
                                    <td>
                                        <asp:label runat="server" id="labelApprovalsRequired1" 
                                            meta:resourcekey="labelApprovalsRequired1Resource1">This level requires the approval of </asp:label>
                                        <ui:UIFieldTextBox runat="server" ID="textNumberOfApproversRequired" PropertyName="NumberOfApprovalsRequired" 
                                            InternalControlWidth="50px" ShowCaption="False" FieldLayout="Flow"
                                            Caption="Approvals Required" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                                            ValidationNumberOfDecimalPlaces="2" ValidateRangeField="True" ValidationRangeMin="1"
                                            ValidationRangeType='Currency' ValidateRequiredField="True" 
                                            meta:resourcekey="textNumberOfApproversRequiredResource1" />
                                        <asp:label runat="server" id="labelApprovalsRequired2" 
                                            meta:resourcekey="labelApprovalsRequired2Resource1"> approver(s) before it can proceed to the next level.</asp:label>
                                    </td>
                                </tr>
                            </table>
                            <ui:uihint runat="server" id="hintNumberOfApproversRequired" 
                                meta:resourcekey="hintNumberOfApproversRequiredResource1"><asp:Table 
                                runat="server" CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow 
                                    runat="server"><asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image 
                                        runat="server" ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                        runat="server" VerticalAlign="Top"><asp:Label runat="server"> &#39;Approvals Required&#39; is <b>only applicable</b> if this Approval Hierarchy is attached to an Approval Process where the Mode of Forwarding is &#39;Direct&#39;, or &#39;Hierarchical&#39;. All other Modes of Forwarding ignores the value entered in &#39;Approvals Required&#39;, and assumes only one (1) approval is required for that level. </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:uihint>
                            <br />
                        <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                            <tr valign="top">
                                <td style='width: 32%'>
                                    <asp:label runat='server' id="labelUsers" Text="Select Users:"></asp:label>
                                    <ui:UIPanel runat="server" ID="panelUsers" 
                                        meta:resourcekey="panelUsersResource1" BorderStyle="NotSet">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropUsers" 
                                            Caption="Select User" 
                                            ShowCaption="false"
                                            ToolTip="Indicate the actual users who will be assigned for Notification at this level." 
                                            OnSelectedIndexChanged="dropUsers_SelectedIndexChanged" 
                                            meta:resourcekey="dropUsersResource1" SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridUsers" PropertyName="Users" 
                                            Caption="Assigned User(s)" OnAction="gridUsers_Action" 
                                            SortExpression="ObjectName" meta:resourcekey="gridUsersResource1" 
                                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
                                            style="clear:both;">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                    CommandName="RemoveObject" CommandText="Remove Selected" 
                                                    ConfirmText="Are you sure you wish to remove the selected users?" 
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource3" />
                                            </commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                    ConfirmText="Are you sure you wish to remove this user?" 
                                                    ImageUrl="~/images/delete.gif" 
                                                    meta:resourceKey="UIGridViewButtonColumnResource3">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="ObjectName" 
                                                    PropertyName="ObjectName" HeaderText="User Name"
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
                                    <asp:label runat='server' id="label1" Text="Select Roles:"></asp:label>
                                    <ui:UIPanel runat="server" ID="panelRoles" 
                                        meta:resourcekey="panelRolesResource1" BorderStyle="NotSet">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropRoles" 
                                            Caption="Select Role" 
                                            ShowCaption="false"
                                            ToolTip="Indicate the roles that will be assigned for Notification at this level. During the Notification process, the workflow will automatically assign the appropriate position based on the roles selected here." 
                                            OnSelectedIndexChanged="dropRoles_SelectedIndexChanged" 
                                            meta:resourcekey="dropRolesResource1" SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridRoles" PropertyName="Roles" 
                                            Caption="Assigned Role(s)" OnAction="gridRoles_Action" 
                                            SortExpression="RoleName" meta:resourcekey="gridRolesResource1" 
                                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
                                            style="clear:both;">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                    CommandName="RemoveObject" CommandText="Remove Selected" 
                                                    ConfirmText="Are you sure you wish to remove the selected roles?" 
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource4" />
                                            </commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                    ConfirmText="Are you sure you wish to remove this role?" 
                                                    ImageUrl="~/images/delete.gif" 
                                                    meta:resourceKey="UIGridViewButtonColumnResource4">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="RoleName" PropertyName="RoleName" HeaderText="Role Name"
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
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <web:memo runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
