<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

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
        OPosition position = (OPosition)panel.SessionObject;

        ddlRoleCode.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID");
        TranslateRoles();
        
        listTypeOfService.Bind(OCode.GetCodesByType("TypeOfService", null), "Path", "ObjectID");
        //listUsers.Bind(OUser.GetAllUsers());
        sddl_UserID.Bind(OUser.GetAllUsers());

        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(position);
    }


    /// <summary>
    /// Translates all the role's text.
    /// </summary>
    protected void TranslateRoles()
    {
        foreach (ListItem item in ddlRoleCode.Items)
        {
            string translatedText = Resources.Roles.ResourceManager.GetString(item.Text, System.Threading.Thread.CurrentThread.CurrentCulture);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
    }

        
    /// <summary>
    /// Hides / shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OPosition position = panel.SessionObject as OPosition;
        panel.ObjectPanel.BindControlsToObject(position);

        listTypeOfService.Visible = !chbIsAllTos.Checked;
        panel.ObjectPanel.BindObjectToControls(position);
    }

    /// <summary>
    /// Construct the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_TreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, "");
    }

    /// <summary>
    /// Occurs when user selects a location on the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPosition position = (OPosition)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(position);
        if (treeLocation.SelectedValue != "")
            position.LocationAccess.AddGuid(new Guid(treeLocation.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(position);
    }

    /// <summary>
    /// Construct the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_TreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, "");
    }

    /// <summary>
    /// Occurs when user selects an equipment on the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPosition position = (OPosition)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(position);
        if (treeEquipment.SelectedValue != "")
            position.EquipmentAccess.AddGuid(new Guid(treeEquipment.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(position);
    }

    /// <summary>
    /// Validates and saves the position object into database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OPosition position = (OPosition)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(position);
            
            
            // Checks for duplicate position name.
            //
            if (position.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.Position_DuplicateName;
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            position.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Occurs when user clicks on the remove button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gridLocationAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OPosition position = (OPosition)panel.SessionObject;
            foreach (Guid id in objectIds)
                position.LocationAccess.RemoveGuid(id);
            panel.ObjectPanel.BindControlsToObject(position);
            panel.ObjectPanel.BindObjectToControls(position);
        }
    }

    /// <summary>
    /// Occurs when user clicks on the remove button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gridEquipmentAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OPosition position = (OPosition)panel.SessionObject;
            foreach (Guid id in objectIds)
                position.EquipmentAccess.RemoveGuid(id);
            panel.ObjectPanel.BindControlsToObject(position);
            panel.ObjectPanel.BindObjectToControls(position);
        }
    }

    protected void chbIsAllTos_CheckedChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Occurs when user clicks on the remove button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gv_Users_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OPosition position = (OPosition)panel.SessionObject;
            foreach (Guid id in objectIds)
                position.Users.RemoveGuid(id);
            
            panel.ObjectPanel.BindControlsToObject(position);
            panel.ObjectPanel.BindObjectToControls(position);
        }
    }

    protected void sddl_UserID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPosition position = (OPosition)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(position);
        if (sddl_UserID.SelectedValue != "")
            position.Users.AddGuid(new Guid(sddl_UserID.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(position);
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
            <web:object runat="server" ID="panel" Caption="Position" BaseTable="tPosition" 
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="tabPosition" runat="server"  Caption="Details"
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Position Name"
                            ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldDropDownList ID="ddlRoleCode" runat="server" Caption="Role" 
                            PropertyName="RoleID" ValidateRequiredField="True" 
                            ToolTip="The unique code for this job" 
                            meta:resourcekey="ddlRoleCodeResource1" />
                        <br />
                        <br />
                        <br />
                        <ui:UIFieldTreeList ID="treeLocation" runat="server" Caption="Location"
                            OnAcquireTreePopulater="treeLocation_TreePopulater" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                            ToolTip="The location that this position is assigned to" 
                            meta:resourcekey="treeLocationResource2" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gridLocationAccess" PropertyName="LocationAccess"
                                        OnAction="gridLocationAccess_Action" 
                                        Caption="List of Accessible Locations" ValidateRequiredField="True"
                                        ToolTip="The locations this position has access to. " KeyName="ObjectID"
                                        meta:resourcekey="gridLocationAccessResource1" BindObjectsToRows="True" 
                                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
                                        style="clear:both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                ConfirmText="Are you sure you wish to remove this item?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource1">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Location Path" 
                                                meta:resourceKey="UIGridViewColumnResource2" PropertyName="Path" 
                                                ResourceAssemblyName="" SortExpression="Path">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <br />
                        <ui:UIFieldTreeList ID="treeEquipment" runat="server" Caption="Equipment"
                            OnAcquireTreePopulater="treeEquipment_TreePopulater" OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged"
                            ToolTip="The equipment that assigned to this position" 
                            meta:resourcekey="treeEquipmentResource2" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gridEquipmentAccess" PropertyName="EquipmentAccess"
                                        OnAction="gridEquipmentAccess_Action" Caption="List of Accessible Equipment"
                                        ValidateRequiredField="True" KeyName="ObjectID" 
                                        meta:resourcekey="gridEquipmentAccessResource1" Width="100%" 
                                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
                                        style="clear:both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                ConfirmText="Are you sure you wish to remove this item?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Equipment Path" 
                                                meta:resourceKey="UIGridViewColumnResource4" PropertyName="Path" 
                                                ResourceAssemblyName="" SortExpression="Path">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <br />
                        <ui:UIFieldCheckBox ID="chbIsAllTos" runat="server" Caption="Types of Services"
                            Text="Apply to all types of services" PropertyName="AppliesToAllTypeOfServices"
                            OnCheckedChanged="chbIsAllTos_CheckedChanged" 
                            meta:resourcekey="chbIsAllTosResource1" TextAlign="Right" />
                        <ui:UIFieldListBox ID="listTypeOfService" runat="server" 
                            PropertyName="TypesOfServiceAccess" 
                            ToolTip="Type of services that assigned to this position" 
                            meta:resourcekey="listTypeOfServiceResource2"></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView ID="tabUser" runat="server"  Caption="Users" BorderStyle="NotSet" 
                        meta:resourcekey="tabUserResource2">
                        <ui:UIFieldSearchableDropDownList ID="sddl_UserID" runat="server" 
                            Caption="Users" OnSelectedIndexChanged="sddl_UserID_SelectedIndexChanged" 
                            meta:resourcekey="sddl_UserIDResource2" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gv_Users" PropertyName="Users"
                                        OnAction="gv_Users_Action" Caption="List of Assigned Users"
                                        ToolTip="The users assigned to this position. " KeyName="ObjectID" 
                                        BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both" 
                                        ImageRowErrorUrl="" meta:resourcekey="gv_UsersResource2" RowErrorColor="" 
                                        style="clear:both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <commands>
                                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                CommandName="RemoveObject" CommandText="Remove" 
                                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                        </commands>
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                ConfirmText="Are you sure you wish to remove this item?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource1">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="ObjectName" 
                                                ResourceAssemblyName="" SortExpression="ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo"  
                        meta:resourcekey="tabMemoResource1" BorderStyle="NotSet">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server"  Caption="Attachments"
                        meta:resourcekey="tabAttachmentsResource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
