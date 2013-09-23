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
        return new LocationTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
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
            ExpressionCondition locCondition = Query.False;
            ExpressionCondition eqptCondition = TablesLogic.tPoint.EquipmentID == null;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OPoint"))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tPoint.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                foreach (OEquipment equipment in position.EquipmentAccess)
                    eqptCondition = eqptCondition | TablesLogic.tPoint.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            e.CustomCondition = locCondition | eqptCondition;
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
                        <div style="clear: both"></div>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" Caption="Results" 
                            KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID" GridLines="Both" 
                            ImageRowErrorUrl="" meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
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
                                <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Location.Path" 
                                    ResourceAssemblyName="" SortExpression="Location.Path">
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
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
