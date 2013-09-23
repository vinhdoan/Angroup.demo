<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        treeEquipmentType.PopulateTree();
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;

        // Set up the equipment condition.
        //
        ExpressionCondition eqptCondition = null;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment Equipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (Equipment != null)
                eqptCondition =
                    TablesLogic.tEquipment.HierarchyPath.Like(Equipment.HierarchyPath + "%") &
                    (TablesLogic.tEquipment.IsPhysicalEquipment == 0 |
                    TablesLogic.tEquipment.GetAccessibleEquipmentByAreaAndStoreCondition(AppSession.User, "OEquipment", null));
        }
        else
        {
            eqptCondition = TablesLogic.tEquipment.GetAccessibleEquipmentCondition(AppSession.User, "OEquipment", null);
        }

        // Set up the location condition.
        //
        ExpressionCondition locCondition = null;
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null) 
                locCondition = 
                    TablesLogic.tEquipment.Location.HierarchyPath.Like(location.HierarchyPath + "%") |
                    (TablesLogic.tEquipment.LocationID==null & 
                    TablesLogic.tEquipment.StoreBinItem.StoreBin.Store.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
        }
        else
        {
            locCondition = TablesLogic.tEquipment.GetAccessibleEquipmentByAreaAndStoreCondition(AppSession.User, "OEquipment", null);
        }

        if (locCondition != null)
            e.CustomCondition = e.CustomCondition & locCondition;
        if (eqptCondition != null)
            e.CustomCondition = e.CustomCondition & eqptCondition;

    }

    /// <summary>
    /// Constructs and returns the equipment type tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipmentType_AcquireTreePopulater(object sender)
    {
        return new EquipmentTypeTreePopulater(null, true, true);
    }


    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, "OEquipment");
    }

    
    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        panelEquipment1.Visible = IsPhysicalEquipment.SelectedIndex == 2;
    }

    /// <summary>
    /// Constructs and returns an equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, "OEquipment");
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="Equipment" GridViewID="gridResults"
                BaseTable="tEquipment" OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery"
                meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1">
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" meta:resourcekey="treeEquipmentResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Equipment Name"
                            ToolTip="The equipment name as displayed on screen." Span="Half" meta:resourcekey="UIFieldString1Resource1"
                            MaxLength="255" />
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location"
                            ToolTip="Use this to select the location that this work applies to." 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1"/>
                        <ui:UIFieldRadioList runat="server" ID="IsPhysicalEquipment" PropertyName="IsPhysicalEquipment"
                            Caption="Folder/Physical" ToolTip="Indicates if the item to search for is a folder or a physical equipment."
                            meta:resourcekey="IsPhysicalEquipmentResource1">
                            <Items>
                                <asp:ListItem Value="" meta:resourcekey="ListItemResource1">Any &#160;</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">Folder &#160;</asp:ListItem>
                                <asp:ListItem Selected="True" Value="1" meta:resourcekey="ListItemResource3">Physical Equipment</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelEquipment1" Width="100%" meta:resourcekey="panelEquipment1Resource1">
                            <ui:UIFieldTreeList runat="server" ID="treeEquipmentType" PropertyName="EquipmentType.ObjectID"
                                Caption="Equipment Type" OnAcquireTreePopulater="treeEquipmentType_AcquireTreePopulater"
                                ToolTip="The type of the equipment." meta:resourcekey="treeEquipmentTypeResource1" />
                            <ui:UIFieldTextBox runat="server" ID="SerialNumber" PropertyName="SerialNumber" Span="Half"
                                Caption="Serial Number" ToolTip="The serial number of this equipment." meta:resourcekey="SerialNumberResource1" />
                            <ui:UIFieldTextBox runat="server" ID="ModelNumber" PropertyName="ModelNumber" Span="Half"
                                Caption="Model Number" ToolTip="The model number of this equipment." meta:resourcekey="ModelNumberResource1" />
                            <ui:UIFieldTextBox runat="server" ID="Barcode" PropertyName="Barcode" Span="Half"
                                Caption="Barcode" ToolTip="The barcode identifier of this equipment." meta:resourcekey="BarcodeResource1" />
                            <br />
                            <br />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIFieldDateTime runat="server" ID="DateOfManufacture" PropertyName="DateOfManufacture"
                                Caption="Date of Manufacture" ToolTip="Date of manufacture of the equipment."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="DateOfManufactureResource1"
                                ShowTimeControls="False" SearchType="range" />
                            <ui:UIFieldDateTime runat="server" ID="DateOfOwnership" PropertyName="DateOfOwnership"
                                Caption="Date of Ownership" ToolTip="Date the equipment was purchased." ImageClearUrl="~/calendar/dateclr.gif"
                                ImageUrl="~/calendar/date.gif" meta:resourcekey="DateOfOwnershipResource1" ShowTimeControls="False"
                                SearchType="Range" />
                            <ui:UIFieldTextBox runat="server" ID="PriceAtOwnership" PropertyName="PriceAtOwnership"
                                Span="Half" Caption="Price at Ownership ($)" ToolTip="The price of the equipment when purchased."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                meta:resourcekey="PriceAtOwnershipResource1" SearchType="Range" />
                            <ui:UIFieldTextBox runat="server" ID="LifeSpan" PropertyName="LifeSpan" Span="Half"
                                Caption="Life Span (years)" ToolTip="The estimated life span of the equipment in years."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="LifeSpanResource1"
                                SearchType="Range" />
                            <ui:UIFieldDateTime runat="server" ID="WarrantyExpiryDate" PropertyName="WarrantyExpiryDate"
                                Caption="Warranty Expiry" ToolTip="The date on which the warranty of the equipment expires."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="WarrantyExpiryDateResource1"
                                ShowTimeControls="False" SearchType="Range" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Equipment Name"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Location.Path" HeaderText="Location">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="EquipmentType.ObjectName" HeaderText="Equipment Type"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="SerialNumber" HeaderText="Serial Number"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ModelNumber" HeaderText="Model Number"
                                    meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
