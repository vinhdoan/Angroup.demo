<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        dropOPCDAServer.Bind(OOPCDAServer.GetAllOPCDAServers());
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
    }

    /// <summary>
    /// Constructs the equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }


    /// <summary>
    /// Searches the panel.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tPoint.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tPoint.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            ExpressionCondition locCondition = TablesLogic.tPoint.LocationID == null;
            ExpressionCondition eqptCondition = TablesLogic.tPoint.EquipmentID == null;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OPoint"))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tPoint.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                foreach (OEquipment equipment in position.EquipmentAccess)
                    eqptCondition = eqptCondition | TablesLogic.tPoint.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            // 2010.11.18
            // Kim Foong
            // Fixed a bug that shows all points regardless of access control.
            //
            //e.CustomCondition = locCondition | eqptCondition;
            e.CustomCondition = locCondition & eqptCondition;
        }

        if (IsActive.SelectedIndex < 0)
            e.CustomCondition &= TablesLogic.tPoint.IsActive == 1;
    }

    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "MassUpdate")
        {
            if (dataKeys.Count == 0)
            {
                gridResults.ErrorMessage = Resources.Errors.Point_SelectAtLeastOne;
                panel.Message = gridResults.ErrorMessage;
            }
            else
            {
                gridResults.ErrorMessage = "";
                panel.Message = gridResults.ErrorMessage;
                popupMassUpdate.Show();
                objectPanelMassUpdate.Visible = true;
            }
        }

        if (commandName == "MassAssign")
        {
            if (dataKeys.Count == 0)
            {
                gridResults.ErrorMessage = Resources.Errors.Point_SelectAtLeastOne;
                panel.Message = gridResults.ErrorMessage;
            }
            else
            {
                gridResults.ErrorMessage = "";
                panel.Message = gridResults.ErrorMessage;
                popupMassAssignReminderUser.Show();
                objectPanelMassAssignReminderUser.Visible = true;
                
                ArrayList ids = TablesLogic.tPoint.Select(TablesLogic.tPoint.LocationID)
                    .Where(TablesLogic.tPoint.ObjectID.In(dataKeys));
                List<OLocation> locations = 
                    TablesLogic.tLocation.LoadList(
                    TablesLogic.tLocation.ObjectID.In(ids));
                List<OUser> users = OUser.GetUsersByRoleAndAboveLocation(null, locations, "WORKSUPERVISOR");

                dropUser1.Bind(users, true);
                dropUser2.Bind(users, true);
                dropUser3.Bind(users, true);
                dropUser4.Bind(users, true);
            }
        }
    }

    protected void buttonCancelReminderUser_Click(object sender, EventArgs e)
    {
        dropUser1.SelectedIndex = 0;
        dropUser2.SelectedIndex = 0;
        dropUser3.SelectedIndex = 0;
        dropUser4.SelectedIndex = 0;
        popupMassAssignReminderUser.Hide();
        objectPanelMassAssignReminderUser.Visible = false;
    }

    protected void buttonAssignReminderUser_Click(object sender, EventArgs e)
    {
        if (objectPanelMassAssignReminderUser.IsValid)
        {
            List<object> objectids = gridResults.GetSelectedKeys();

            foreach (object objectid in objectids)
            {
                using (Connection c = new Connection())
                {
                    OPoint point = TablesLogic.tPoint.Load(new Guid(objectid.ToString()));
                    if (point != null)
                    {
                        objectPanelMassAssignReminderUser.BindControlsToObject(point);
                        point.Save();
                    }
                    c.Commit();
                }
            }

            panel.Message = String.Format(Resources.Messages.Point_ReminderUsersUpdated, objectids.Count);
        }
        
        dropUser1.SelectedIndex = 0;
        dropUser2.SelectedIndex = 0;
        dropUser3.SelectedIndex = 0;
        dropUser4.SelectedIndex = 0;
        popupMassAssignReminderUser.Hide();
        objectPanelMassAssignReminderUser.Visible = false;
    }

    protected void buttonMassUpdateCancel_Click(object sender, EventArgs e)
    {
        MassTariff.Text = "";
        MassDiscount.Text = "";
        popupMassUpdate.Hide();
        objectPanelMassUpdate.Visible = false;
    }

    protected void buttonMassUpdateConfirm_Click(object sender, EventArgs e)
    {
        MassTariff.Validate();
        MassDiscount.Validate();

        if (objectPanelMassUpdate.IsValid)
        {
            Decimal? tariff = Convert.ToDecimal(MassTariff.Text);
            Decimal? discount = Convert.ToDecimal(MassDiscount.Text);
            
            List<object> objectids = gridResults.GetSelectedKeys();

            int countSuccess = 0;
            string lockedPoints = "";
            foreach (object objectid in objectids)
            {
                using (Connection c = new Connection())
                {
                    OPoint point = TablesLogic.tPoint.Load(new Guid(objectid.ToString()));
                    if (point != null)
                    {
                        if (point.IsLock != 1)
                        {
                            point.Tariff = tariff;
                            point.Discount = discount;
                            point.Save();
                            countSuccess += 1;
                        }
                        else
                            lockedPoints += point.ObjectName + "; ";
                    }
                    c.Commit();
                }
            }

            MassTariff.Text = "";
            MassDiscount.Text = "";
            popupMassUpdate.Hide();
            objectPanelMassUpdate.Visible = false;
            panel.PerformSearch();

            panel.Message = String.Format(Resources.Messages.Point_TariffDiscountUpdated, countSuccess);
            if(lockedPoints!="")
                panel.Message += String.Format(Resources.Messages.Point_TariffDiscountNotUpdatedDueToLock, lockedPoints);
        } 
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Point" meta:resourcekey="panelResource1" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tPoint" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" OnSearch="panel_Search">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTextBox runat="server" ID="textObjectName" PropertyName="ObjectName" 
                            Caption="Point Name" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textObjectNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat='server' ID="radioIsApplicableForLocation" PropertyName="IsApplicableForLocation"
                            Caption="Location/Equipment" 
                            meta:resourcekey="radioIsApplicableForLocationResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Text="Any" Selected="True" meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Location" meta:resourcekey="ListItemResource2"></asp:ListItem>
                                <asp:ListItem Value="0" Text="Equipment" meta:resourcekey="ListItemResource3"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:uifieldtreelist runat="server" id="treeLocation" Caption="Location" 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                            meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode"></ui:uifieldtreelist>
                        <ui:uifieldtreelist runat="server" id="treeEquipment" Caption="Equipment" 
                            OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                            meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode"></ui:uifieldtreelist>
                        <ui:UIFieldDropDownList runat="server" ID="dropOPCDAServer" PropertyName="OPCDAServerID"
                            Caption="OPC DA Server" meta:resourcekey="dropOPCDAServerResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" id="textOPCItemName" 
                            PropertyName="OPCItemName" Caption="OPC Item Name" InternalControlWidth="95%" 
                            meta:resourcekey="textOPCItemNameResource1"  ></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textDescription" 
                            PropertyName="Description"  Caption="Description" InternalControlWidth="95%" 
                            meta:resourcekey="textDescriptionResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textBarcode" PropertyName="Barcode"  
                            Caption="Barcode" InternalControlWidth="95%" 
                            meta:resourcekey="textBarcodeResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="Tenant" PropertyName="Tenant.ObjectName"  
                            Caption="Tenant" InternalControlWidth="95%" meta:resourcekey="TenantResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat="server" ID="IsActive" 
                            PropertyName="IsActive" 
                            Caption="Is Active" meta:resourcekey="IsActiveResource1" 
                            TextAlign="Right" >
                            <Items>
                                <asp:ListItem Value="1" 
                                    Text="Yes, this Point is active for the next meter reading (default)" 
                                    meta:resourcekey="ListItemResource4"></asp:ListItem>
                                <asp:ListItem Value="0" 
                                    Text="No, this Point is not active for the next meter reading" 
                                    meta:resourcekey="ListItemResource5"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        
                        <div style="clear: both"></div>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" Caption="Results" 
                            KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" PageSize="200" 
                            style="clear:both;" OnAction="gridResults_Action" 
                            ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="MassUpdate" CommandText="Mass Update (Tariff and Discount)" ImageUrl="~/images/tick.gif" meta:resourcekey="UIGridViewCommandResource2" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="MassAssign" CommandText="Mass Assign (Reminder Users)" 
                                    ImageUrl="~/images/tick.gif" meta:resourcekey="UIGridViewCommandResource3" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="OPCDAServer.ObjectName" 
                                    HeaderText="OPC DA Server" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="OPCDAServer.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="OPCDAServer.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="OPCItemName" HeaderText="OPC Item Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="OPCItemName" 
                                    ResourceAssemblyName="" SortExpression="OPCItemName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.FastPath" HeaderText="Location" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Location.FastPath" 
                                    ResourceAssemblyName="" SortExpression="Location.FastPath">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="Equipment.Path" 
                                    ResourceAssemblyName="" SortExpression="Equipment.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit Of Measure" meta:resourcekey="UIGridViewBoundColumnResource6" 
                                    PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TenantName" 
                                    HeaderText="Tenant"
                                    PropertyName="TenantName" ResourceAssemblyName="" 
                                    SortExpression="TenantName" meta:resourcekey="UIGridViewBoundColumnResource7">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                 <cc1:UIGridViewBoundColumn DataField="TenantLease.ShopName" 
                                    HeaderText="Shop Name"
                                    PropertyName="TenantLease.ShopName" ResourceAssemblyName="" 
                                    SortExpression="TenantLease.ShopName" >
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TenantLease.LeaseStartDate" 
                                    HeaderText="Lease Start Date" DataFormatString="{0:dd-MMM-yyyy}"
                                    PropertyName="TenantLease.LeaseStartDate" ResourceAssemblyName="" 
                                    SortExpression="TenantLease.LeaseStartDate" meta:resourcekey="UIGridViewBoundColumnResource8">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TenantLease.LeaseEndDate" 
                                    HeaderText="Lease End Date" DataFormatString="{0:dd-MMM-yyyy}"
                                    PropertyName="TenantLease.LeaseEndDate" ResourceAssemblyName="" 
                                    SortExpression="TenantLease.LeaseEndDate" meta:resourcekey="UIGridViewBoundColumnResource9">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TenantLease.Status" 
                                    HeaderText="Lease Status"
                                    PropertyName="TenantLease.Status" ResourceAssemblyName="" 
                                    SortExpression="TenantLease.Status" meta:resourcekey="UIGridViewBoundColumnResource10">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Factor" 
                                    HeaderText="Factor" DataFormatString="{0:#,##0.00}"
                                    PropertyName="Factor" ResourceAssemblyName="" 
                                    SortExpression="Factor" meta:resourcekey="UIGridViewBoundColumnResource11">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Tariff" 
                                    HeaderText="Tariff" 
                                    PropertyName="Tariff" ResourceAssemblyName="" 
                                    SortExpression="Tariff" meta:resourcekey="UIGridViewBoundColumnResource12">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Discount" 
                                    HeaderText="Discount" DataFormatString="{0:#,##0.00}"
                                    PropertyName="Discount" ResourceAssemblyName="" 
                                    SortExpression="Discount" meta:resourcekey="UIGridViewBoundColumnResource13">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Barcode" 
                                    HeaderText="Barcode" 
                                    PropertyName="Barcode" ResourceAssemblyName="" 
                                    SortExpression="Barcode" 
                                    meta:resourcekey="UIGridViewBoundColumnResource14">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsActiveText" 
                                    HeaderText="Is Active" 
                                    PropertyName="IsActiveText" ResourceAssemblyName="" 
                                    SortExpression="IsActiveText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource15">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsLockText" 
                                    HeaderText="Is Lock" 
                                    PropertyName="IsLockText" ResourceAssemblyName="" 
                                    SortExpression="IsLockText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource16">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <asp:LinkButton runat="server" ID="buttonMassUpdateHidden" meta:resourcekey="buttonMassUpdateHiddenResource1" />
                    <asp:ModalPopupExtender runat='server' id="popupMassUpdate" PopupControlID="objectPanelMassUpdate" BackgroundCssClass="modalBackground" TargetControlID="buttonMassUpdateHidden" DynamicServicePath="" Enabled="True" ></asp:ModalPopupExtender>
                    <ui:uiobjectpanel runat="server" id="objectPanelMassUpdate" Width="400px" BackColor="White" BorderStyle="NotSet" meta:resourcekey="objectPanelMassUpdateResource1" >
                        <div style="padding: 8px 8px 8px 8px">
                        <ui:uiseparator id="Uiseparator3" runat="server" caption="Mass Update" meta:resourcekey="Uiseparator3Resource1" />
                        <ui:UIFieldTextBox runat="server" id="MassTariff" Caption="Tariff" ValidationDataType="Currency" ValidaterequiredField="True" InternalControlWidth="95%" meta:resourcekey="MassTariffResource1" />
                        <ui:UIFieldTextBox runat="server" id="MassDiscount" Caption="Discount (%)" ValidationDataType="Currency" ValidaterequiredField="True" InternalControlWidth="95%" meta:resourcekey="MassDiscountResource1" />
                        <br />
                        <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray; width: 100%">
                            <tr>
                                <td style='width: 120px'></td>
                                <td>
                                    <ui:uibutton runat='server' id="buttonMassUpdateConfirm" Text="Save" Imageurl="~/images/tick.gif" OnClick="buttonMassUpdateConfirm_Click" meta:resourcekey="buttonMassUpdateConfirmResource1" />
                                    <ui:uibutton runat='server' id="buttonMassUpdateCancel" Text="Cancel" Imageurl="~/images/delete.gif" CausesValidation='False' OnClick="buttonMassUpdateCancel_Click" meta:resourcekey="buttonMassUpdateCancelResource1" />
                                </td>
                            </tr>
                        </table>
                        </div>
                    </ui:uiobjectpanel>   
                    <asp:LinkButton runat="server" ID="buttonMassAssignReminderUser" 
                            meta:resourcekey="buttonMassAssignReminderUserResource1" />
                    <asp:ModalPopupExtender runat='server' id="popupMassAssignReminderUser" PopupControlID="objectPanelMassAssignReminderUser" BackgroundCssClass="modalBackground" TargetControlID="buttonMassAssignReminderUser" DynamicServicePath="" Enabled="True" ></asp:ModalPopupExtender>
                    <ui:uiobjectpanel runat="server" id="objectPanelMassAssignReminderUser" 
                            Width="400px" BackColor="White" BorderStyle="NotSet" 
                            meta:resourcekey="objectPanelMassAssignReminderUserResource1" >
                        <div style="padding: 8px 8px 8px 8px">
                        <ui:uiseparator id="Uiseparator1" runat="server" 
                                caption="Mass Assign Reminder Users" meta:resourcekey="Uiseparator1Resource1" />
                        <ui:UIFieldDropDownList runat="server" id="dropUser1" Caption="Reminder User 1" 
                                PropertyName="ReminderUser1ID" ValidaterequiredField="True" 
                                meta:resourcekey="dropUser1Resource1" />
                        <ui:UIFieldDropDownList runat="server" id="dropUser2" Caption="Reminder User 2" 
                                PropertyName="ReminderUser2ID" meta:resourcekey="dropUser2Resource1" />
                        <ui:UIFieldDropDownList runat="server" id="dropUser3" Caption="Reminder User 3" 
                                PropertyName="ReminderUser3ID" meta:resourcekey="dropUser3Resource1" />
                        <ui:UIFieldDropDownList runat="server" id="dropUser4" Caption="Reminder User 4" 
                                PropertyName="ReminderUser4ID" meta:resourcekey="dropUser4Resource1" />
                        <br />
                        <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray; width: 100%">
                            <tr>
                                <td style='width: 120px'></td>
                                <td>
                                    <ui:uibutton runat='server' id="buttonAssignReminderUser" Text="Save" 
                                        Imageurl="~/images/tick.gif" OnClick="buttonAssignReminderUser_Click" 
                                        meta:resourcekey="buttonAssignReminderUserResource1" />
                                    <ui:uibutton runat='server' id="buttonCancelReminderUser" Text="Cancel" 
                                        Imageurl="~/images/delete.gif" CausesValidation='False' 
                                        OnClick="buttonCancelReminderUser_Click" 
                                        meta:resourcekey="buttonCancelReminderUserResource1" />
                                </td>
                            </tr>
                        </table>
                        </div>
                    </ui:uiobjectpanel>   
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
