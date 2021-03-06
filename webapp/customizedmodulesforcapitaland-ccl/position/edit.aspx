﻿<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
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

        listPurchaseTypes.Bind(OCode.GetPurchaseTypes(AppSession.User, null, Security.Decrypt(Request["TYPE"]), null), "ParentPath", "ObjectID");
        
        //listUsers.Bind(OUser.GetAllUsers());
        //sddl_UserID.Bind(OUser.GetAllUsers());
        ddl_TenantContactType.Bind(OCode.GetCodesByType("TenantContactType", null));
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        
        dropBudgetGroup.Bind(OBudgetGroup.GetListOfBudgetGroupsByListOfPositions(AppSession.User.Positions));
        //listCheckboxBugetGroup.Bind(OBudgetGroup.GetListOfBudgetGroupsByListOfPositions(AppSession.User.Positions));
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
        //OPosition position = panel.SessionObject as OPosition;
        //panel.ObjectPanel.BindControlsToObject(position);

        listTypeOfService.Visible = !chbIsAllTos.Checked;

        listPurchaseTypes.Visible = !chbIsAllTransactions.Checked;
        //panel.ObjectPanel.BindObjectToControls(position);
    }

    /// <summary>
    /// Construct the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_TreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "",false,false);
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
            panel.ObjectPanel.BindControlsToObject(position);
            
            foreach (Guid id in objectIds)
                position.PermanentUsers.RemoveGuid(id);
            
            panel.ObjectPanel.BindObjectToControls(position);
        }

        if (commandName == "AddUsers")
        {
            searchUsers.Show();
        }
    }

    protected void sddl_UserID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPosition position = (OPosition)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(position);
        if (sddl_UserID.SelectedValue != "")
        {
            OUserPermanentPosition p = TablesLogic.tUserPermanentPosition.Create();
            p.UserID = new Guid(sddl_UserID.SelectedValue);
            position.PermanentUsers.Add(p);
        }
        panel.ObjectPanel.BindObjectToControls(position);
    }

    protected void dropBudgetGroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPosition position = (OPosition)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(position);
        if (dropBudgetGroup.SelectedValue != "")
            position.BudgetGroups.AddGuid(new Guid(dropBudgetGroup.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(position);
    }

    protected void gv_BudgetGroup_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OPosition position = (OPosition)panel.SessionObject;
            foreach (Guid id in objectIds)
                position.BudgetGroups.RemoveGuid(id);

            panel.ObjectPanel.BindControlsToObject(position);
            panel.ObjectPanel.BindObjectToControls(position);
        }
    }

    protected void ddl_TenantContactType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPosition position = (OPosition)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(position);
        if (ddl_TenantContactType.SelectedValue != "")
            position.TenantContactTypes.AddGuid(new Guid(ddl_TenantContactType.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(position);
    }

    protected void gvTenantContactTypes_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OPosition position = (OPosition)panel.SessionObject;
            foreach (Guid id in objectIds)
                position.TenantContactTypes.RemoveGuid(id);

            panel.ObjectPanel.BindControlsToObject(position);
            panel.ObjectPanel.BindObjectToControls(position);
        }
    }

    protected void searchUsers_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        e.CustomCondition = TablesLogic.tUser.ObjectID.In(OUser.GetAllUsers());
    }

    protected void searchUsers_Selected(object sender, EventArgs e)
    {
        OPosition position = (OPosition)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(position);
        foreach (Guid id in searchUsers.SelectedDataKeys)
        {
            if (position.PermanentUsers.Find((u) => u.UserID == id) == null)
            {
                OUserPermanentPosition p = TablesLogic.tUserPermanentPosition.Create();
                p.UserID = id;
                position.PermanentUsers.Add(p);
            }
        }
        panel.ObjectPanel.BindObjectToControls(position);

    }

    protected void chbIsAllTransactions_CheckedChanged(object sender, EventArgs e)
    {

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
            meta:resourcekey="panelMainResource3">
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
                            meta:resourcekey="treeLocationResource3" ShowCheckBoxes="None" 
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
                                        DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
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
                            meta:resourcekey="treeEquipmentResource3" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gridEquipmentAccess" PropertyName="EquipmentAccess"
                                        OnAction="gridEquipmentAccess_Action" Caption="List of Accessible Equipment"
                                        ValidateRequiredField="True" KeyName="ObjectID" 
                                        meta:resourcekey="gridEquipmentAccessResource1" Width="100%" 
                                        DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
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
                        <ui:UIFieldCheckBox ID="chbAllDebarredVendors" runat="server" Caption="Allow Debarred Vendor?"
                            Text="Yes, allow this position to access debarred vendors" PropertyName="AppliesToAllDebarredVendors"
                            TextAlign="Right" ForeColor="Red" />
                        <ui:UIFieldCheckBox ID="chbAllNonApprovedVendors" runat="server" Caption="Allow Non-Approved Vendor?"
                            Text="Yes, allow this position to access non-approved vendors" PropertyName="AppliesToAllNonApprovedVendors"
                            TextAlign="Right" ForeColor="Red" />
                        <ui:UIFieldCheckBox ID="chbIsAllTos" runat="server" Caption="Types of Services"
                            Text="Apply to all types of services" PropertyName="AppliesToAllTypeOfServices"
                            OnCheckedChanged="chbIsAllTos_CheckedChanged" 
                            meta:resourcekey="chbIsAllTosResource1" TextAlign="Right" />
                        <ui:UIFieldListBox ID="listTypeOfService" runat="server" 
                            PropertyName="TypesOfServiceAccess" CaptionPosition="Top"
                            ToolTip="Type of services that assigned to this position" 
                            meta:resourcekey="listTypeOfServiceResource3"></ui:UIFieldListBox>
                        <ui:UIFieldCheckBox ID="chbIsAllTransactions" runat="server" Caption="Transaction Types"
                            Text="Apply to all transaction types" PropertyName="AppliesToAllPurchaseTypes"
                            TextAlign="Right" OnCheckedChanged="chbIsAllTransactions_CheckedChanged" />
                        <ui:UIFieldListBox ID="listPurchaseTypes" runat="server"
                            PropertyName="PurchaseTypesAccess" CaptionPosition="Top"
                            ToolTip="Type of Transaction that assigned to this position">
                        </ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView ID="tabUser" runat="server"  Caption="Users" BorderStyle="NotSet" 
                        meta:resourcekey="tabUserResource3">
                        <ui:UIFieldSearchableDropDownList ID="sddl_UserID" runat="server" Visible="false"
                            Caption="Users" OnSelectedIndexChanged="sddl_UserID_SelectedIndexChanged" 
                            meta:resourcekey="sddl_UserIDResource3" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        <web:searchdialogbox runat="server" ID="searchUsers"
                            Title="Assign Users" AllowMultipleSelection="true" BaseTable="tUser"
                            MaximumNumberOfResults="200" SearchTextBoxPropertyNames="ObjectName,UserBase.LoginName,UserBase.Email" 
                            OnSearched="searchUsers_Searched" OnSelected="searchUsers_Selected">
                            <Columns>
                                <ui:UIGridViewBoundColumn HeaderText="User Name" HeaderStyle-Width="300px" PropertyName="ObjectName"></ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Login Name" HeaderStyle-Width="200px" PropertyName="UserBase.LoginName"></ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Email" HeaderStyle-Width="200px" PropertyName="UserBase.Email"></ui:UIGridViewBoundColumn>
                            </Columns>
                        </web:searchdialogbox>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gv_Users" PropertyName="PermanentUsers"
                                        OnAction="gv_Users_Action" Caption="List of Assigned Users"
                                        ToolTip="The users assigned to this position. " KeyName="ObjectID" 
                                        BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both" 
                                        meta:resourcekey="gv_UsersResource3" RowErrorColor="" 
                                        style="clear:both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <commands>
                                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                CommandName="RemoveObject" CommandText="Remove" 
                                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                CommandName="AddUsers" CommandText="Grant Users" 
                                                ImageUrl="~/images/add.gif" />
                                        </commands>
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                ConfirmText="Are you sure you wish to remove this item?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource1">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="User.ObjectName" HeaderText="Name" 
                                                meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="User.ObjectName" 
                                                ResourceAssemblyName="" SortExpression="User.ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <ui:UIGridViewTemplateColumn HeaderText="Start Date" 
                                                meta:resourcekey="UIGridViewTemplateColumnResource1">
                                                <ItemTemplate>
                                                    <ui:UIFieldDateTime runat='server' ID="textStartDate" PropertyName="StartDate" 
                                                        ShowCaption="False" Caption="Start Date" FieldLayout="Flow" 
                                                        InternalControlWidth="130px" ValidateCompareField="True" 
                                                        ValidationCompareControl="textEndDate" 
                                                        ValidationCompareOperator="LessThanEqual" ValidationCompareType="Date" 
                                                        meta:resourcekey="textStartDateResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" Width="150px" />
                                            </ui:UIGridViewTemplateColumn>
                                            <ui:UIGridViewTemplateColumn HeaderText="End Date" 
                                                meta:resourcekey="UIGridViewTemplateColumnResource2">
                                                <ItemTemplate>
                                                    <ui:UIFieldDateTime runat='server' ID="textEndDate" PropertyName="EndDate" 
                                                        ShowCaption="False" Caption="End Date" FieldLayout="Flow" 
                                                        InternalControlWidth="130px" ValidateCompareField="True" 
                                                        ValidationCompareControl="textStartDate" 
                                                        ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" 
                                                        meta:resourcekey="textEndDateResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" Width="150px" />
                                            </ui:UIGridViewTemplateColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                   </ui:UITabView>
                   <ui:UITabView runat="server" ID="tabBudgetGroup" Caption="Budget Groups" 
                        Height="100%" BorderStyle="NotSet" meta:resourcekey="tabBudgetGroupResource2">
                   <ui:UIFieldDropDownList runat="server" Caption="Budget Group" 
                        ID="dropBudgetGroup" OnSelectedIndexChanged="dropBudgetGroup_SelectedIndexChanged" 
                        meta:resourcekey="dropBudgetGroupResource2">
                    </ui:UIFieldDropDownList>
                    <ui:UIGridView runat="server" ID="gv_BudgetGroup" PropertyName="BudgetGroups"
                            Caption="Selected Budget Groups" ValidateRequiredField="False" 
                            KeyName="ObjectID" BindObjectsToRows="True" OnAction="gv_BudgetGroup_Action" 
                            DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gv_BudgetGroupResource2" RowErrorColor="" 
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
                                meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                        
                    </ui:UITabView>
                     <ui:UITabView ID="tabTenantContactType" runat="server"  
                        Caption="Tenant Contact Types" BorderStyle="NotSet" 
                        meta:resourcekey="tabTenantContactTypeResource1" >
                        <ui:UIFieldSearchableDropDownList ID="ddl_TenantContactType" runat="server" 
                            Caption="Tenant Contact Type"
                            SearchInterval="300" 
                             OnSelectedIndexChanged="ddl_TenantContactType_SelectedIndexChanged" 
                             meta:resourcekey="ddl_TenantContactTypeResource1"></ui:UIFieldSearchableDropDownList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gvTenantContactTypes" PropertyName="TenantContactTypes"
                                        Caption="List of Assigned Users"
                                        ToolTip="The tenant contact types assigned to this position. " KeyName="ObjectID" 
                                        BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                                        style="clear:both;" OnAction="gvTenantContactTypes_Action" 
                                        meta:resourcekey="gvTenantContactTypesResource1">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <commands>
                                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                CommandName="RemoveObject" CommandText="Remove" 
                                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                                ImageUrl="~/images/delete.gif" 
                                                meta:resourcekey="UIGridViewCommandResource1" />
                                        </commands>
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                ConfirmText="Are you sure you wish to remove this item?" 
                                                ImageUrl="~/images/delete.gif" 
                                                meta:resourcekey="UIGridViewButtonColumnResource1" >
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Tenant Contact Type" 
                                                PropertyName="ObjectName" 
                                                ResourceAssemblyName="" SortExpression="ObjectName" 
                                                meta:resourcekey="UIGridViewBoundColumnResource6">
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
