<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
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

        gridResults.Commands[0].Visible = AppSession.User.AllowEditAll("OReading");
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
                e.CustomCondition = e.CustomCondition & TablesLogic.tReading.Point.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & (TablesLogic.tReading.Point.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tReading.Point.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            ExpressionCondition locCondition = Query.False;
            ExpressionCondition eqptCondition = TablesLogic.tReading.Point.EquipmentID == null;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OReading"))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tReading.Point.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tReading.Point.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                foreach (OEquipment equipment in position.EquipmentAccess)
                    eqptCondition = eqptCondition | TablesLogic.tReading.Point.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            e.CustomCondition = locCondition & eqptCondition;
        }
    }


    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "UpdateObject")
        {
            String str = "";
            if (dataKeys.Count == 0)
            {
                panel.Message = Resources.Errors.General_SelectOneOrMoreItemsToAdd;
                return;
            }
            foreach (object ob in dataKeys)
                str += (ob.ToString() + ";");
            Session["SelectedReading"] = str;
            Window.Open("editMassive.aspx", "");
        }
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int count = 0;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (gridResults.DataKeys[e.Row.RowIndex][0] != DBNull.Value)
            {
                OReading reading = TablesLogic.tReading.Load(new Guid(gridResults.DataKeys[e.Row.RowIndex][0].ToString()));
                if (reading != null)
                {
                    if (reading.Point != null)
                    {
                        if (reading.Point.TenantLease != null)
                        {
                            if (reading.Point.TenantLease.LeaseStatus != "N")
                            {
                                e.Row.BackColor = System.Drawing.Color.LightPink;
                                count++;
                            }
                        }
                    }
                }
            }
        }
        if (count > 0)
        {
            Hint.Visible = true;
            Hint.Text = String.Format(Resources.Messages.Reading_Hint, count);
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
        <web:search runat="server" ID="panel" Caption="Reading" GridViewID="gridResults"
            EditButtonVisible="false" BaseTable="tReading" OnSearch="panel_Search" SearchType="ObjectQuery"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldRadioList runat='server' ID="radioIsApplicableForLocation" PropertyName="Point.IsApplicableForLocation"
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
                        TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:uifieldtreelist runat="server" id="treeEquipment" Caption="Equipment" 
                        OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                        meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:UIFieldRadioList runat='server' ID="radioSource" PropertyName="Source" Caption="Source"
                        RepeatColumns="0" meta:resourcekey="radioSourceResource1" 
                        TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Any" Selected="True" meta:resourcekey="ListItemResource4"></asp:ListItem>
                            <asp:ListItem Value="0" Text="Direct" meta:resourcekey="ListItemResource5"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Work" meta:resourcekey="ListItemResource6"></asp:ListItem>
                            <asp:ListItem Value="3" Text="PDA" meta:resourcekey="ListItemResource7"></asp:ListItem>
                            <asp:ListItem Value="2" Text="OPC" meta:resourcekey="ListItemResource8"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:uifielddatetime runat="server" id="dateDateOfReading" Caption="Date of Reading"
                        PropertyName="DateOfReading" ShowTimeControls="True" SearchType="Range" 
                        meta:resourcekey="dateDateOfReadingResource1" ShowDateControls="True">
                    </ui:uifielddatetime>
                    <ui:UIFieldTextBox runat="server" ID="textObjectName" PropertyName="Point.ObjectName"
                        Caption="Point Name" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textObjectNameResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat="server" ID="dropOPCDAServer" PropertyName="Point.OPCDAServerID"
                        Caption="OPC DA Server" meta:resourcekey="dropOPCDAServerResource1">
                    </ui:UIFieldDropDownList>
                    <div style="clear: both">
                    </div>
                    <ui:UIFieldTextBox runat="server" ID="textDescription" PropertyName="Point.Description"
                        Caption="Description" InternalControlWidth="95%" 
                        meta:resourcekey="textDescriptionResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="textCreateOnBreachWork" PropertyName="CreateOnBreachWork.ObjectNumber"
                        Caption="Work Number (created during breach)" CaptionWidth="200px" 
                        InternalControlWidth="95%" meta:resourcekey="textCreateOnBreachWorkResource1">
                    </ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1">
                    <ui:UIHint runat="server" ID="Hint" Visible="False" 
                        meta:resourcekey="HintResource1" Text="
                    &amp;nbsp;">
                    </ui:UIHint>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" OnAction="gridResults_Action"
                        SortExpression="DateOfReading DESC" DataKeyNames="ObjectID" 
                        GridLines="Both" meta:resourcekey="gridResultsResource1" PageSize="500"
                        RowErrorColor="" style="clear:both;" 
                        OnRowDataBound="gridResults_RowDataBound" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="UpdateObject" CommandText="Update Selected" 
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="DeleteObject" CommandText="Delete Selected" 
                                ConfirmText="Are you sure you wish to delete the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                ConfirmText="Are you sure you wish to delete this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="SourceName" HeaderText="Source" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="SourceName" 
                                ResourceAssemblyName="" SortExpression="SourceName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.ObjectName" HeaderText="Point" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" 
                                PropertyName="Point.ObjectName" ResourceAssemblyName="" 
                                SortExpression="Point.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.LocationOrEquipmentPath" 
                                HeaderText="Location/Equipment" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" 
                                PropertyName="Point.LocationOrEquipmentPath" ResourceAssemblyName="" 
                                SortExpression="Point.LocationOrEquipmentPath">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.OPCDAServer.ObjectName" 
                                HeaderText="OPC DA Server" meta:resourcekey="UIGridViewBoundColumnResource4" 
                                PropertyName="Point.OPCDAServer.ObjectName" ResourceAssemblyName="" 
                                SortExpression="Point.OPCDAServer.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Reading" HeaderText="Reading" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="Reading" 
                                ResourceAssemblyName="" SortExpression="Reading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="DateOfReading" 
                                HeaderText="Date Of Reading" meta:resourcekey="UIGridViewBoundColumnResource6" 
                                PropertyName="DateOfReading" ResourceAssemblyName="" 
                                SortExpression="DateOfReading" DataFormatString="{0:dd-MMM-yyyy}">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreateOnBreachWork.ObjectNumber" 
                                HeaderText="Work Number (created during breach)" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" 
                                PropertyName="CreateOnBreachWork.ObjectNumber" ResourceAssemblyName="" 
                                SortExpression="CreateOnBreachWork.ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantName" 
                                HeaderText="Tenant Name" 
                                PropertyName="Point.TenantName" ResourceAssemblyName="" 
                                SortExpression="Point.TenantName" meta:resourcekey="UIGridViewBoundColumnResource8">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantLease.LeaseStartDate" 
                                HeaderText="Lease Start Date" 
                                PropertyName="Point.TenantLease.LeaseStartDate" ResourceAssemblyName="" 
                                SortExpression="Point.TenantLease.LeaseStartDate" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource9">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantLease.LeaseEndDate" 
                                HeaderText="Lease End Date" 
                                PropertyName="Point.TenantLease.LeaseEndDate" ResourceAssemblyName="" 
                                SortExpression="Point.TenantLease.LeaseEndDate" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource10">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantLease.Status" 
                                HeaderText="Lease Status" 
                                PropertyName="Point.TenantLease.Status" ResourceAssemblyName="" 
                                SortExpression="Point.TenantLease.Status" meta:resourcekey="UIGridViewBoundColumnResource11">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="BillToAMOSStatusText" 
                                HeaderText="Bill To AMOS Status" 
                                PropertyName="BillToAMOSStatusText" ResourceAssemblyName="" 
                                SortExpression="BillToAMOSStatusText" meta:resourcekey="UIGridViewBoundColumnResource12">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
