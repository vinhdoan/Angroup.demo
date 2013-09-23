<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

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
        dropUsers.Bind(OUser.GetAllNonTenantUsers(), "ObjectName", "ObjectID", true);
        dropCarbonCopyPositions.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID", true);
        dropPositions.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID", true);
        dropSecretary.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID", true);
        dropSecretaryRoles.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID", true);
        dropCarbonCopyRoles.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID", true);
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
    /// Occurs when the user selects a user.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropCarbonCopyPositions_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropCarbonCopyPositions.SelectedValue != "")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            level.CarbonCopyPositions.AddGuid(new Guid(dropCarbonCopyPositions.SelectedValue));
            panelCarbonCopyPositions.BindObjectToControls(level);

            dropCarbonCopyPositions.SelectedValue = "";
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
    /// Occurs when the user selects a user.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropCarbonCopyRoles_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropCarbonCopyRoles.SelectedValue != "")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            level.CarbonCopyRoles.AddGuid(new Guid(dropCarbonCopyRoles.SelectedValue));
            panelCarbonCopyRoles.BindObjectToControls(level);

            dropCarbonCopyRoles.SelectedValue = "";
        }
    }

    /// <summary>
    /// Occurs when the user selects a user.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropSecretaryRoles_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropSecretaryRoles.SelectedValue != "")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            level.SecretaryRoles.AddGuid(new Guid(dropSecretaryRoles.SelectedValue));
            panelSecretaryRoles.BindObjectToControls(level);

            dropSecretaryRoles.SelectedValue = "";
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
    protected void gridCarbonCopyPositions_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.CarbonCopyPositions.RemoveGuid(id);
            panelCarbonCopyPositions.BindObjectToControls(level);
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
    /// Occurs when the user clicks a button on the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridCarbonCopyRoles_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.CarbonCopyRoles.RemoveGuid(id);
            panelCarbonCopyRoles.BindObjectToControls(level);
        }

    }


    /// <summary>
    /// Occurs when the user clicks a button on the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridSecretaryRoles_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.SecretaryRoles.RemoveGuid(id);
            panelSecretaryRoles.BindObjectToControls(level);
        }

    }


    /// <summary>
    /// Populates the sub panel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ApprovalHierarchyLevel_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OApprovalHierarchy approvalHierarchy = panel.SessionObject as OApprovalHierarchy;
        panel.ObjectPanel.BindControlsToObject(approvalHierarchy);
        
        OApprovalHierarchyLevel approvalHierarchyLevel = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;

        dropApprovalLevel.Items.Clear();

        for (int i = 1; i <= approvalHierarchy.ApprovalHierarchyLevels.Count + 1; i++)
            dropApprovalLevel.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (approvalHierarchyLevel.IsNew && approvalHierarchyLevel.ApprovalLevel == null)
            approvalHierarchyLevel.ApprovalLevel = approvalHierarchy.ApprovalHierarchyLevels.Count + 1;
        
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

        /*
        // Capitaland customization, if secretary is selected, then make sure that there's
        // only one approval user.
        //
        if (approvalHierarchyLevel.SecretaryUsers.Count > 0 && (approvalHierarchyLevel.Users.Count != 1 || approvalHierarchyLevel.Roles.Count != 0))
        {
            gridRoles.ErrorMessage = Resources.Errors.ApprovalHierarchyLevel_SecretaryRequiresExactlyOneApprover;
            gridUsers.ErrorMessage = Resources.Errors.ApprovalHierarchyLevel_SecretaryRequiresExactlyOneApprover;
        }
         * */

        if (!ApprovalHierarchyLevel_Panel.IsValid)
            return;

        approvalHierarchy.ApprovalHierarchyLevels.Add(approvalHierarchyLevel);
        //approvalHierarchy.UpdateApprovalLevels();

        LogicLayer.Global.ReorderItems(approvalHierarchy.ApprovalHierarchyLevels, approvalHierarchyLevel, "ApprovalLevel");

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

    protected void dropSecretary_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropSecretary.SelectedValue != "")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            level.SecretaryPositions.AddGuid(new Guid(dropSecretary.SelectedValue));
            panelSecretaryUsers.BindObjectToControls(level);

            dropSecretary.SelectedValue = "";
        }
    }


    /// <summary>
    /// Occurs when the user clicks a button on the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridSecretaryUsers_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveObject")
        {
            OApprovalHierarchyLevel level = ApprovalHierarchyLevel_SubPanel.SessionObject as OApprovalHierarchyLevel;
            foreach (Guid id in dataKeys)
                level.SecretaryPositions.RemoveGuid(id);
            panelSecretaryUsers.BindObjectToControls(level);
        }
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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1"
        BorderStyle="NotSet">
        <web:object runat="server" ID="panel" Caption="Approval Hierarchy" BaseTable="tApprovalHierarchy"
            OnValidateAndSave="panel_ValidateAndSave" OnPopulateForm="panel_PopulateForm"
            meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <ui:UITabView ID="uitabview1" runat="server" Caption="Details" meta:resourcekey="uitabview1Resource1"
                    BorderStyle="NotSet">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Hierarchy Name"
                        ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIGridView ID="ApprovalHierarchyLevels" runat="server" Caption="Approval Hierarchy Levels"
                        PropertyName="ApprovalHierarchyLevels" SortExpression="ApprovalLevel asc" ValidateRequiredField="True"
                        meta:resourcekey="ApprovalHierarchyLevelsResource1" DataKeyNames="ObjectID" GridLines="Both"
                        RowErrorColor="" Style="clear: both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject"
                                CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ImageUrl="~/images/delete.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ApprovalLevel" HeaderText="Approval Level"
                                meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="ApprovalLevel"
                                ResourceAssemblyName="" SortExpression="ApprovalLevel">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ApprovalLimit" DataFormatString="{0:#,##0.00}"
                                HeaderText="Approval Limit" meta:resourceKey="UIGridViewBoundColumnResource2"
                                PropertyName="ApprovalLimit" ResourceAssemblyName="" SortExpression="ApprovalLimit">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="NumberOfApprovalsRequired" HeaderText="Approvals Required"
                                PropertyName="NumberOfApprovalsRequired" ResourceAssemblyName="" SortExpression="NumberOfApprovalsRequired"
                                meta:resourcekey="UIGridViewBoundColumnResource5">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="UserNames" HeaderText="Users" PropertyName="UserNames"
                                ResourceAssemblyName="" SortExpression="UserNames" meta:resourcekey="UIGridViewBoundColumnResource6">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="PositionNames" HeaderText="Positions" PropertyName="PositionNames"
                                ResourceAssemblyName="" SortExpression="PositionNames" meta:resourcekey="UIGridViewBoundColumnResource8">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn HeaderText="Copy to Positions" PropertyName="CarbonCopyPositionNames"
                                ResourceAssemblyName="" DataField="CarbonCopyPositionNames" meta:resourcekey="UIGridViewBoundColumnResource12"
                                SortExpression="CarbonCopyPositionNames">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn HeaderText="Copy to Roles" PropertyName="CarbonCopyRoleNames"
                                ResourceAssemblyName="" DataField="CarbonCopyRoleNames" SortExpression="CarbonCopyRoleNames">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SecretaryPositionNames" HeaderText="Secretary Positions"
                                PropertyName="SecretaryPositionNames" ResourceAssemblyName="" SortExpression="UserNames"
                                meta:resourcekey="UIGridViewBoundColumnResource7">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SecretaryRoleNames" HeaderText="Secretary Roles"
                                PropertyName="SecretaryRoleNames" ResourceAssemblyName="" SortExpression="SecretaryRoleNames">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="RoleNames" HeaderText="Roles" PropertyName="RoleNames"
                                ResourceAssemblyName="" SortExpression="RoleNames" meta:resourcekey="UIGridViewBoundColumnResource9">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel ID="ApprovalHierarchyLevel_Panel" runat="server" meta:resourcekey="ApprovalHierarchyLevel_PanelResource1"
                        BorderStyle="NotSet">
                        <web:subpanel runat="server" ID="ApprovalHierarchyLevel_SubPanel" GridViewID="ApprovalHierarchyLevels"
                            ObjectPanelID="ApprovalHierarchyLevel_Panel" OnPopulateForm="ApprovalHierarchyLevel_SubPanel_PopulateForm"
                            OnValidateAndUpdate="ApprovalHierarchyLevel_SubPanel_ValidateAndUpdate" OnRemoved="ApprovalHierarchyLevel_SubPanel_Removed"
                            meta:resourcekey="ApprovalHierarchyLevelsResource1"></web:subpanel>
                        <ui:UIFieldDropDownList runat="server" ID="dropApprovalLevel" Caption="Approval Level"
                            PropertyName="ApprovalLevel" Span="Half" ValidateRequiredField="true">
                        </ui:UIFieldDropDownList>
                        <br />
                        &nbsp;
                        <table cellpadding='0' cellspacing='0' border='0'>
                            <tr class='field-required'>
                                <td style='width: 158px'>
                                    <asp:Label runat="server" ID="labelApprovalLimitCaption" meta:resourcekey="labelApprovalLimitCaptionResource1"
                                        Text="Approval Limit"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelApprovalLimit1" meta:resourcekey="labelApprovalLimit1Resource1"
                                        Text="The user(s) can approve up to and including "></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="ApprovalLimit" PropertyName="ApprovalLimit"
                                        DataFormatString="{0:n}" InternalControlWidth="120px" ShowCaption="False" FieldLayout="Flow"
                                        Caption="Approval Limit" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                                        ValidationNumberOfDecimalPlaces="2" ValidateRangeField="True" ValidationRangeMin="0.01"
                                        ValidationRangeType='Currency' ValidateRequiredField="True" meta:resourcekey="ApprovalLimitResource1" />
                                    <asp:Label runat="server" ID="labelApprovalLimit2" meta:resourcekey="labelApprovalLimit2Resource1"
                                        Text=" at this level."></asp:Label>
                                </td>
                            </tr>
                        </table>
                        <table cellpadding='0' cellspacing='0' border='0'>
                            <tr class='field-required'>
                                <td style='width: 158px'>
                                    <asp:Label runat="server" ID="labelApprovalsRequiredCaption" meta:resourcekey="labelApprovalsRequiredCaptionResource1"
                                        Text="Approvals Required*:"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelApprovalsRequired1" meta:resourcekey="labelApprovalsRequired1Resource1"
                                        Text="This level requires the approval of "></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textNumberOfApproversRequired" PropertyName="NumberOfApprovalsRequired"
                                        InternalControlWidth="50px" ShowCaption="False" FieldLayout="Flow" Caption="Approvals Required"
                                        Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidationNumberOfDecimalPlaces="2"
                                        ValidateRangeField="True" ValidationRangeMin="1" ValidationRangeType='Currency'
                                        ValidateRequiredField="True" meta:resourcekey="textNumberOfApproversRequiredResource1" />
                                    <asp:Label runat="server" ID="labelApprovalsRequired2" meta:resourcekey="labelApprovalsRequired2Resource1"
                                        Text=" approver(s) before it can proceed to the next level."></asp:Label>
                                </td>
                            </tr>
                        </table>
                        <ui:UIHint runat="server" ID="hintNumberOfApproversRequired" meta:resourcekey="hintNumberOfApproversRequiredResource1"
                            Text="
                        &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;">
                        </ui:UIHint>
                        <br />
                        <table cellpadding='0' cellspacing='0' style="width: 100%" border="0">
                            <tr valign="top">
                                <td style='width: 24%'>
                                    <asp:Label runat='server' ID="labelPositions" Text="Select Positions:" meta:resourcekey="labelPositionsResource1"></asp:Label>
                                    <ui:UIPanel runat="server" ID="panelPositions" BorderStyle="NotSet" meta:resourcekey="panelPositionsResource1">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropPositions" ShowCaption="False"
                                            ToolTip="Indicate the positions that will be assigned for Notification at this level. During the Notification process, the workflow will automatically assign the appropriate position based on the roles selected here."
                                            OnSelectedIndexChanged="dropPositions_SelectedIndexChanged" SearchInterval="300"
                                            meta:resourcekey="dropPositionsResource1">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridPositions" PropertyName="Positions" Caption="Assigned Positions(s)"
                                            OnAction="gridPositions_Action" SortExpression="ObjectName" DataKeyNames="ObjectID"
                                            GridLines="Both" meta:resourcekey="gridPositionsResource1" RowErrorColor="" Style="clear: both;">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <Commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                    CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected positions?"
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource6" />
                                            </Commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this position?"
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource6">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Position Name" DataField="ObjectName"
                                                    meta:resourcekey="UIGridViewBoundColumnResource11" ResourceAssemblyName="" SortExpression="ObjectName">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                                <td style='width: 1%'>
                                </td>
                                <td style='width: 24%'>
                                    <asp:Label runat='server' ID="label2" Text="Select Positions to Carbon Copy:" meta:resourcekey="label2Resource1"></asp:Label>
                                    <ui:UIPanel runat="server" ID="panelCarbonCopyPositions" BorderStyle="NotSet" meta:resourcekey="panelCarbonCopyPositionsResource1">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropCarbonCopyPositions" Caption="Select Positions to Carbon Copy"
                                            ShowCaption="False" ToolTip="Indicate the actual users who will be assigned for Notification at this level."
                                            OnSelectedIndexChanged="dropCarbonCopyPositions_SelectedIndexChanged" SearchInterval="300"
                                            meta:resourcekey="dropCarbonCopyPositionsResource1">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridCarbonCopyPositions" PropertyName="CarbonCopyPositions"
                                            Caption="Copy to Position(s)" OnAction="gridCarbonCopyPositions_Action" SortExpression="ObjectName"
                                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                                            meta:resourcekey="gridCarbonCopyPositionsResource1" ImageRowErrorUrl="">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <Commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                    CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected users?"
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource7" />
                                            </Commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this user?"
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource7">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="User Name" PropertyName="ObjectName"
                                                    ResourceAssemblyName="" SortExpression="ObjectName" meta:resourcekey="UIGridViewBoundColumnResource13">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                                <td style='width: 1%'>
                                </td>
                                <td style='width: 24%'>
                                    <asp:Label runat='server' ID="labelSecretaries" Text="Select Secretary Position:"
                                        meta:resourcekey="labelSecretariesResource1"></asp:Label>
                                    <ui:UIPanel runat='server' ID="panelSecretaryUsers" BorderStyle="NotSet" meta:resourcekey="panelSecretaryUsersResource1">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropSecretary" Caption="Secretary"
                                            ShowCaption="False" OnSelectedIndexChanged="dropSecretary_SelectedIndexChanged"
                                            meta:resourcekey="dropSecretaryResource1" SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridSecretaryUsers" PropertyName="SecretaryPositions"
                                            Caption="Assigned Secretary Position(s)" OnAction="gridSecretaryUsers_Action"
                                            SortExpression="ObjectName" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor=""
                                            Style="clear: both;" meta:resourcekey="gridSecretaryUsersResource1" ImageRowErrorUrl="">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <Commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                    CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected users?"
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource5" />
                                            </Commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this user?"
                                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource5">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="ObjectName" PropertyName="ObjectName" ResourceAssemblyName=""
                                                    HeaderText="Secretary Name" SortExpression="ObjectName" meta:resourcekey="UIGridViewBoundColumnResource10">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                    <ui:UIHint runat="server" ID="hintSecretaryUsers" Text="Secretaries can approve on behalf of the approver. The secretaries are applicable only if the Mode of Forwarding is 'Direct' or 'Hierarchical'."
                                        meta:resourcekey="hintSecretaryUsersResource2"></ui:UIHint>
                                </td>
                            </tr>
                        </table>
                        <table cellpadding='0' cellspacing='0' style="width: 100%" border="0">
                            <tr>
                                <td colspan="3">
                                    <ui:UISeparator runat='server' ID="Uiseparator1" meta:resourcekey="Uiseparator1Resource1" />
                                </td>
                            </tr>
                        </table>
                        <table cellpadding='0' cellspacing='0' style="width: 100%" border="0">
                            <tr valign="top">
                                <td style='width: 24%'>
                                    <asp:Label runat='server' ID="labelUsers" Text="Select Users:" meta:resourcekey="labelUsersResource1"></asp:Label>
                                    <ui:UIPanel runat="server" ID="panelUsers" meta:resourcekey="panelUsersResource1"
                                        BorderStyle="NotSet">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropUsers" Caption="Select User"
                                            ShowCaption="False" ToolTip="Indicate the actual users who will be assigned for Notification at this level."
                                            OnSelectedIndexChanged="dropUsers_SelectedIndexChanged" meta:resourcekey="dropUsersResource1"
                                            SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridUsers" PropertyName="Users" Caption="Assigned User(s)"
                                            OnAction="gridUsers_Action" SortExpression="ObjectName" meta:resourcekey="gridUsersResource1"
                                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                                            ImageRowErrorUrl="">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <Commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                    CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected users?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource3" />
                                            </Commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this user?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource3">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="ObjectName" meta:resourceKey="UIGridViewBoundColumnResource3"
                                                    HeaderText="User Name" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                                <td style='width: 1%'>
                                </td>
                                <td style='width: 24%'>
                                    <asp:Label runat='server' ID="label1" Text="Select Roles:" meta:resourcekey="label1Resource1"></asp:Label>
                                    <ui:UIPanel runat="server" ID="panelRoles" meta:resourcekey="panelRolesResource1"
                                        BorderStyle="NotSet">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropRoles" Caption="Select Role"
                                            ShowCaption="False" ToolTip="Indicate the roles that will be assigned for Notification at this level. During the Notification process, the workflow will automatically assign the appropriate position based on the roles selected here."
                                            OnSelectedIndexChanged="dropRoles_SelectedIndexChanged" meta:resourcekey="dropRolesResource1"
                                            SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridRoles" PropertyName="Roles" Caption="Assigned Role(s)"
                                            OnAction="gridRoles_Action" SortExpression="RoleName" meta:resourcekey="gridRolesResource1"
                                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                                            ImageRowErrorUrl="">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <Commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                    CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected roles?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource4" />
                                            </Commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this role?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource4">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="RoleName" meta:resourceKey="UIGridViewBoundColumnResource4"
                                                    PropertyName="RoleName" ResourceAssemblyName="" SortExpression="RoleName" HeaderText="Role Name">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                                <td style='width: 1%'>
                                </td>
                                <td style='width: 24%'>
                                    <asp:Label runat='server' ID="label3" Text="Select Carbon Copy to Roles:"></asp:Label>
                                    <ui:UIPanel runat="server" ID="panelCarbonCopyRoles" meta:resourcekey="panelRolesResource1"
                                        BorderStyle="NotSet">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropCarbonCopyRoles" Caption="Select Copy Role"
                                            ShowCaption="False" ToolTip="Indicate the roles that will be assigned for Notification at this level. During the Notification process, the workflow will automatically assign the appropriate position based on the roles selected here."
                                            OnSelectedIndexChanged="dropCarbonCopyRoles_SelectedIndexChanged" SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridCarbonCopyRoles" PropertyName="CarbonCopyRoles"
                                            Caption="Copy to Role(s)" OnAction="gridCarbonCopyRoles_Action" SortExpression="RoleName"
                                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                                            ImageRowErrorUrl="">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <Commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                    CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected roles?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource4" />
                                            </Commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this role?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource4">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="RoleName" meta:resourceKey="UIGridViewBoundColumnResource4"
                                                    PropertyName="RoleName" ResourceAssemblyName="" SortExpression="RoleName" HeaderText="Role Name">
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewBoundColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                    </ui:UIPanel>
                                </td>
                                <td style='width: 1%'>
                                </td>
                                <td style='width: 24%'>
                                    <asp:Label runat='server' ID="label4" Text="Select Secretary Roles:"></asp:Label>
                                    <ui:UIPanel runat="server" ID="panelSecretaryRoles" meta:resourcekey="panelRolesResource1"
                                        BorderStyle="NotSet">
                                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropSecretaryRoles" Caption="Select Secretary Role"
                                            ShowCaption="False" ToolTip="Indicate the roles that will be assigned for Notification at this level. During the Notification process, the workflow will automatically assign the appropriate position based on the roles selected here."
                                            OnSelectedIndexChanged="dropSecretaryRoles_SelectedIndexChanged" SearchInterval="300">
                                        </ui:UIFieldSearchableDropDownList>
                                        <ui:UIGridView runat="server" ID="gridSecretaryRoles" PropertyName="SecretaryRoles"
                                            Caption="Secretary Role(s)" OnAction="gridSecretaryRoles_Action" SortExpression="RoleName"
                                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;"
                                            ImageRowErrorUrl="">
                                            <PagerSettings Mode="NumericFirstLast" />
                                            <Commands>
                                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject"
                                                    CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected roles?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource4" />
                                            </Commands>
                                            <Columns>
                                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this role?"
                                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource4">
                                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                    <ItemStyle HorizontalAlign="Left" />
                                                </cc1:UIGridViewButtonColumn>
                                                <cc1:UIGridViewBoundColumn DataField="RoleName" meta:resourceKey="UIGridViewBoundColumnResource4"
                                                    PropertyName="RoleName" ResourceAssemblyName="" SortExpression="RoleName" HeaderText="Role Name">
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
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1"
                    BorderStyle="NotSet">
                    <web:memo runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments" meta:resourcekey="uitabview2Resource1"
                    BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
