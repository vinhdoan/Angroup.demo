<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Data" %>
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
        ONotificationProcess obj = (ONotificationProcess)panel.SessionObject;

        dropNotificationMilestones.Bind(ONotificationMilestones.GetAllMilestones(obj.NotificationMilestonesID));
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        dropNotificationHierarchy.Bind(ONotificationHierarchy.GetAllNotificationHierarchies());

        ddl_TypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), obj.TypeOfWorkID));
        ddl_TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, obj.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), obj.TypeOfServiceID));

        DataTable dt = OMessageTemplate.GetGeneralMessageTemplates();
        dropMessageTemplate1.Bind(dt, "ObjectName", "ObjectID");
        dropMessageTemplate2.Bind(dt, "ObjectName", "ObjectID");
        dropMessageTemplate3.Bind(dt, "ObjectName", "ObjectID");
        dropMessageTemplate4.Bind(dt, "ObjectName", "ObjectID");

        obj.LinkNotificationProcessTimings();

        // populate the notification level limit's dropdownlist
        //
        dropNotificationLevelAsLimit.Items.Clear();
        if (obj.NotificationHierarchy != null)
        {
            for (int i = 1; i <= obj.NotificationHierarchy.NotificationHierarchyLevels.Count; i++)
                dropNotificationLevelAsLimit.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }
        
        panel.ObjectPanel.BindObjectToControls(obj);
        BindMilestonesDetails();
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
            ONotificationProcess obj = (ONotificationProcess)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(obj);

            // Validate
            //
            if (!obj.ValidateNonDefaultNotificationProcessTimings())
                gridNotificationHierarchy.ErrorMessage = Resources.Errors.NotificationProcess_TimingsOutOfOrder;
            if (obj.IsApplicableToPriority0 == 0 &&
                obj.IsApplicableToPriority1 == 0 &&
                obj.IsApplicableToPriority2 == 0 &&
                obj.IsApplicableToPriority3 == 0)
                checkIsApplicableToPriority0.ErrorMessage = Resources.Errors.NotificationProcess_NoApplicablePrioritiesSet;
            
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            obj.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Occurs when the user selects a new item in the notification
    /// hierarchy dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropNotificationHierarchy_SelectedIndexChanged(object sender, EventArgs e)
    {
        ONotificationProcess obj = (ONotificationProcess)panel.SessionObject;
        
        panelNotificationHierarchy.BindControlsToObject(obj);
        obj.LinkNotificationProcessTimings();
        
        // populate the notification level limit's dropdownlist
        //
        dropNotificationLevelAsLimit.Items.Clear();
        for (int i = 1; i <= obj.NotificationHierarchy.NotificationHierarchyLevels.Count; i++)
            dropNotificationLevelAsLimit.Items.Add(new ListItem(i.ToString(), i.ToString()));
        
        panelNotificationHierarchy.BindObjectToControls(obj);
    }


    /// <summary>
    /// Constructs and returns a location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        ONotificationProcess obj = (ONotificationProcess)panel.SessionObject;
        return new LocationTreePopulaterForCapitaland(obj.LocationID, true, true, Security.Decrypt(Request["TYPE"]), false, false);
    }


    /// <summary>
    /// Constructs and returns a equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        ONotificationProcess obj = (ONotificationProcess)panel.SessionObject;
        return new EquipmentTreePopulater(obj.EquipmentID, true, true, Security.Decrypt(Request["TYPE"]));
    }


    protected void ShowHideGridViewRowColumns(GridViewRow row)
    {
        if (row != null)
        {
            row.Cells[2].Visible = checkUseDefaultTimings.Checked;
            row.Cells[3].Visible = checkUseDefaultTimings.Checked;
            row.Cells[4].Visible = checkUseDefaultTimings.Checked;
            row.Cells[5].Visible = checkUseDefaultTimings.Checked;

            row.Cells[6].Visible = !checkUseDefaultTimings.Checked;
            row.Cells[7].Visible = !checkUseDefaultTimings.Checked;
            row.Cells[8].Visible = !checkUseDefaultTimings.Checked;
            row.Cells[9].Visible = !checkUseDefaultTimings.Checked;
        }
    }
    

    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        ShowHideGridViewRowColumns(gridNotificationHierarchy.HeaderRow);
        foreach (GridViewRow row in gridNotificationHierarchy.Rows)
            ShowHideGridViewRowColumns(row);

        panel_WorkObjectDetails.Visible = lbl_MilestonesDetails.Text.EndsWith(": Work");
    }

    
    /// <summary>
    /// Occurs when the checkbox for default timings is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkUseDefaultTimings_CheckedChanged(object sender, EventArgs e)
    {

    }

    protected void BindMilestonesDetails()
    {
        lbl_MilestonesDetails.Text = string.Empty;
        if (dropNotificationMilestones.SelectedValue != string.Empty && dropNotificationMilestones.SelectedValue != null)
        {
            ONotificationMilestones NM = TablesLogic.tNotificationMilestones.Load(new Guid(dropNotificationMilestones.SelectedValue));
            if (NM != null)
            {
                string ObjectTypeName = Resources.Objects.ResourceManager.GetString(NM.ObjectTypeName);
                lbl_MilestonesDetails.Text = "Object Type Name: " + (ObjectTypeName == null || ObjectTypeName == string.Empty ? NM.ObjectTypeName : ObjectTypeName);
            }
        }
    }

    protected void dropNotificationMilestones_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindMilestonesDetails();
    }

    protected void ddl_TypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddl_TypeOfWorkID.SelectedValue == "" || ddl_TypeOfWorkID.SelectedValue == null)
        {
            ddl_TypeOfServiceID.SelectedValue = null;
        }
        
        ONotificationProcess obj = (ONotificationProcess)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(obj);
        ddl_TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, obj.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), obj.TypeOfServiceID));
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
        <web:object runat="server" ID="panel" Caption="Notification Process" BaseTable="tNotificationProcess"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                    BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIFieldDropDownList runat="server" ID="dropNotificationMilestones" 
                        ValidateRequiredField="True" PropertyName="NotificationMilestonesID" 
                        Caption="Milestones" 
                        OnSelectedIndexChanged="dropNotificationMilestones_SelectedIndexChanged" 
                        meta:resourcekey="dropNotificationMilestonesResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldLabel ID="lbl_MilestonesDetails" runat="server" DataFormatString="" 
                        meta:resourcekey="lbl_MilestonesDetailsResource1"></ui:UIFieldLabel>
                    <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" PropertyName="Description"
                        MaxLength="255" ValidateRequiredField="True" InternalControlWidth="95%" 
                        meta:resourcekey="textDescriptionResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                        PropertyName="LocationID" ValidateRequiredField="True" 
                        meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater"
                        PropertyName="EquipmentID" ValidateRequiredField="True" 
                        meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIPanel ID="panel_WorkObjectDetails" runat="server" BorderStyle="NotSet" 
                        meta:resourcekey="panel_WorkObjectDetailsResource1">
                    <ui:UIFieldDropDownList runat="server" ID="ddl_TypeOfWorkID" PropertyName="TypeOfWorkID"
                        Caption="Type Of Work" 
                            OnSelectedIndexChanged="ddl_TypeOfWorkID_SelectedIndexChanged" 
                            meta:resourcekey="ddl_TypeOfWorkIDResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="ddl_TypeOfServiceID" PropertyName="TypeOfServiceID"
                        Caption="Type Of Service" meta:resourcekey="ddl_TypeOfServiceIDResource1">
                    </ui:UIFieldDropDownList>
                    </ui:UIPanel>                    
                    <table cellpadding='1' cellspacing='0' style="width:100%">
                        <tr class='field-required'>
                            <td style='width:120px'>
                                <asp:Label runat='server' ID="labelApplicableToPriority" 
                                    Text="Applicable Priorities*:" 
                                    meta:resourcekey="labelApplicableToPriorityResource1"></asp:Label>
                            </td>
                            <td>
                                <ui:UIFieldCheckBox runat="server" ID="checkIsApplicableToPriority0" 
                                    PropertyName="IsApplicableToPriority0" FieldLayout="Flow" Text="0 " 
                                    ShowCaption="False" InternalControlWidth="" 
                                    meta:resourcekey="checkIsApplicableToPriority0Resource1" TextAlign="Right"></ui:UIFieldCheckBox>
                                <ui:UIFieldCheckBox runat="server" ID="checkIsApplicableToPriority1" 
                                    PropertyName="IsApplicableToPriority1" FieldLayout="Flow" Text="1 " 
                                    ShowCaption="False" InternalControlWidth="" 
                                    meta:resourcekey="checkIsApplicableToPriority1Resource1" TextAlign="Right"></ui:UIFieldCheckBox>
                                <ui:UIFieldCheckBox runat="server" ID="checkIsApplicableToPriority2" 
                                    PropertyName="IsApplicableToPriority2" FieldLayout="Flow" Text="2 " 
                                    ShowCaption="False" InternalControlWidth="" 
                                    meta:resourcekey="checkIsApplicableToPriority2Resource1" TextAlign="Right"></ui:UIFieldCheckBox>
                                <ui:UIFieldCheckBox runat="server" ID="checkIsApplicableToPriority3" 
                                    PropertyName="IsApplicableToPriority3" FieldLayout="Flow" Text="3 " 
                                    ShowCaption="False" InternalControlWidth="" 
                                    meta:resourcekey="checkIsApplicableToPriority3Resource1" TextAlign="Right"></ui:UIFieldCheckBox>
                            </td>
                        </tr>
                    </table>
                    <ui:UIPanel runat="server" ID="panelNotificationHierarchy" BorderStyle="NotSet" 
                        meta:resourcekey="panelNotificationHierarchyResource1">
                        <ui:UISeparator runat="server" ID="sep1" Caption="Notification Hierarchy" 
                            meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropNotificationHierarchy" ValidateRequiredField="True"
                            PropertyName="NotificationHierarchyID" Caption="Notification Hierarchy" 
                            OnSelectedIndexChanged="dropNotificationHierarchy_SelectedIndexChanged" 
                            meta:resourcekey="dropNotificationHierarchyResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldCheckBox runat="server" ID="checkUseDefaultTimings" 
                            PropertyName="UseDefaultTimings" Caption="Use Default Timings" 
                            Text="Yes, use default timings specified in the selected Notification Hierarchy above." 
                            OnCheckedChanged="checkUseDefaultTimings_CheckedChanged" 
                            meta:resourcekey="checkUseDefaultTimingsResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                        <br />
                        <table>
                        <tr>
                            <td style='width: 120px'><asp:label runat="server" 
                                    id="labelNotificationLevelAsLimit" 
                                    meta:resourcekey="labelNotificationLevelAsLimitResource1" Text="Limit:"></asp:label></td>
                            <td>
                                <asp:label runat="server" id="labelNotificationLevelAsLimit1" 
                                    meta:resourcekey="labelNotificationLevelAsLimit1Resource1" Text="Use notification level "></asp:label>
                                <ui:uifielddropdownlist runat="server" id="dropNotificationLevelAsLimit" 
                                    PropertyName="NotificationLevelAsLimit" Caption="Limit Level" 
                                    ShowCaption="False" InternalControlWidth="50px" FieldLayout="Flow" 
                                    meta:resourcekey="dropNotificationLevelAsLimitResource1"></ui:uifielddropdownlist>
                                <asp:label runat="server" id="labelNotificationLevelAsLimit2" 
                                    meta:resourcekey="labelNotificationLevelAsLimit2Resource1" Text="as the timings for the service level limit."></asp:label>
                            </td>
                        </tr>
                        </table>
                        
                        <ui:UIGridView runat="server" ID="gridNotificationHierarchy" 
                            PropertyName="NotificationHierarchy.NotificationHierarchyLevels" CheckBoxColumnVisible="False"
                            SortExpression="NotificationLevel ASC" BindObjectsToRows="True" 
                            DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridNotificationHierarchyResource1" RowErrorColor="" 
                            style="clear:both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="NotificationLevel" HeaderText="Level" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="NotificationLevel" ResourceAssemblyName="" 
                                    SortExpression="NotificationLevel">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes1" 
                                    HeaderText="Time" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="NotificationTimeInMinutes1" ResourceAssemblyName="" 
                                    SortExpression="NotificationTimeInMinutes1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes2" 
                                    HeaderText="Time" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="NotificationTimeInMinutes2" ResourceAssemblyName="" 
                                    SortExpression="NotificationTimeInMinutes2">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes3" 
                                    HeaderText="Time" meta:resourcekey="UIGridViewBoundColumnResource4" 
                                    PropertyName="NotificationTimeInMinutes3" ResourceAssemblyName="" 
                                    SortExpression="NotificationTimeInMinutes3">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NotificationTimeInMinutes4" 
                                    HeaderText="Time" meta:resourcekey="UIGridViewBoundColumnResource5" 
                                    PropertyName="NotificationTimeInMinutes4" ResourceAssemblyName="" 
                                    SortExpression="NotificationTimeInMinutes4">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Time" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textNotificationTimeInMinutes1" runat="server" 
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textNotificationTimeInMinutes1Resource1" 
                                            PropertyName="TempNotificationProcessingTiming.NotificationTimeInMinutes1" 
                                            ShowCaption="False">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Time" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textNotificationTimeInMinutes2" runat="server" 
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textNotificationTimeInMinutes2Resource1" 
                                            PropertyName="TempNotificationProcessingTiming.NotificationTimeInMinutes2" 
                                            ShowCaption="False">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Time" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource3">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textNotificationTimeInMinutes3" runat="server" 
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textNotificationTimeInMinutes3Resource1" 
                                            PropertyName="TempNotificationProcessingTiming.NotificationTimeInMinutes3" 
                                            ShowCaption="False">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Time" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource4">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textNotificationTimeInMinutes4" runat="server" 
                                            FieldLayout="Flow" InternalControlWidth="50px" 
                                            meta:resourcekey="textNotificationTimeInMinutes4Resource1" 
                                            PropertyName="TempNotificationProcessingTiming.NotificationTimeInMinutes4" 
                                            ShowCaption="False">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="50px" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserNames" HeaderText="Users" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="UserNames" 
                                    ResourceAssemblyName="" SortExpression="UserNames">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PositionNames" HeaderText="Positions" meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="PositionNames" ResourceAssemblyName="" SortExpression="PositionNames">
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
                        <ui:UISeparator runat="server" ID="sep2" Caption="Message Templates" 
                            meta:resourcekey="sep2Resource1" />
                        <ui:uifieldsearchabledropdownlist runat="server" id="dropMessageTemplate1" 
                            PropertyName="MessageTemplate1ID" Caption="Milestone 1" 
                            meta:resourcekey="dropMessageTemplate1Resource1" SearchInterval="300"></ui:uifieldsearchabledropdownlist>
                        <ui:uifieldsearchabledropdownlist runat="server" id="dropMessageTemplate2" 
                            PropertyName="MessageTemplate2ID" Caption="Milestone 2" 
                            meta:resourcekey="dropMessageTemplate2Resource1" SearchInterval="300"></ui:uifieldsearchabledropdownlist>
                        <ui:uifieldsearchabledropdownlist runat="server" id="dropMessageTemplate3" 
                            PropertyName="MessageTemplate3ID" Caption="Milestone 3" 
                            meta:resourcekey="dropMessageTemplate3Resource1" SearchInterval="300"></ui:uifieldsearchabledropdownlist>
                        <ui:uifieldsearchabledropdownlist runat="server" id="dropMessageTemplate4" 
                            PropertyName="MessageTemplate4ID" Caption="Milestone 4" 
                            meta:resourcekey="dropMessageTemplate4Resource1" SearchInterval="300"></ui:uifieldsearchabledropdownlist>
                    </ui:UIPanel>
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
