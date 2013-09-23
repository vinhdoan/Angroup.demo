<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
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
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        treeEquipmentType.PopulateTree();
        listStatus.Bind(OEquipment.EquipmentStatusTable(), "StatusName", "StatusValue");
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
        //if (rdlIsWritenOff.SelectedValue == "1")
        //    e.CustomCondition = e.CustomCondition & (TablesLogic.tEquipment.IsWrittenOff == 1);
        //else if (rdlIsWritenOff.SelectedValue == "0")
        //    e.CustomCondition = e.CustomCondition & (TablesLogic.tEquipment.IsWrittenOff == 0 | TablesLogic.tEquipment.IsWrittenOff == null);

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
        return new LocationTreePopulaterForCapitaland(null, true, true, "OEquipment", false, false);
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

    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "PrintBarcode")
        {
            try
            {
                if (dataKeys.Count == 0)
                {
                    //panel.Message = Resources.Messages.General_NoItemSelectedForAction;
                    return;
                }
                ArrayList al_EquipmentID = new ArrayList();
                foreach (object EquipmentID in dataKeys)
                {
                    al_EquipmentID.Add(new Guid(EquipmentID.ToString()));
                    //OEquipment temp = TablesLogic.tEquipment.Load(new Guid(EquipmentID.ToString()));
                    //if (temp != null)
                    //    temp.IsTagNumberPrinted = 1;
                    //using (Connection c = new Connection())
                    //{
                    //    temp.Save();
                    //    c.Commit();
                    //}
                }
                DiskCache.Add("ReportTable", OEquipment.GenerateBarcodePrintOutData(al_EquipmentID));


                Window.Open(Page.Request.ApplicationPath +
                    "/modules/reportviewer/reportviewer.aspx?PDF=1&ReportDataSetName=" +
                    HttpUtility.UrlEncode(Security.Encrypt("Body")) + "&ReportVirtualPath=" + HttpUtility.UrlEncode(Security.Encrypt("~/customizedmodulesforcapitaland/eqpt/BarcodePrintOut.rdlc")), "Barcode_Window");

                Window.Opener.Refresh();

            }
            catch (System.Data.Odbc.OdbcException ex)
            {
                panel.Message = Resources.Errors.General_OdbcException;
            }
            catch (Exception ex)
            {
                panel.Message = ex.Message;
            }
        }
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource2">
            <web:search runat="server" ID="panel" Caption="Equipment" GridViewID="gridResults"
                BaseTable="tEquipment" OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery"
                meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Equipment Name"
                            ToolTip="The equipment name as displayed on screen." Span="Half" meta:resourcekey="UIFieldString1Resource1"
                            MaxLength="255" InternalControlWidth="95%" />
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location"
                            ToolTip="Use this to select the location that this work applies to." 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode"/>
                        <ui:UIFieldRadioList runat="server" ID="IsPhysicalEquipment" PropertyName="IsPhysicalEquipment"
                            Caption="Folder/Physical" ToolTip="Indicates if the item to search for is a folder or a physical equipment."
                            meta:resourcekey="IsPhysicalEquipmentResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1" Text="Any "></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2" Text="Folder &nbsp;"></asp:ListItem>
                                <asp:ListItem Selected="True" Value="1" meta:resourcekey="ListItemResource3" Text="Physical Equipment"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelEquipment1" Width="100%" meta:resourcekey="panelEquipment1Resource1" BorderStyle="NotSet">
                            <ui:UIFieldTreeList runat="server" ID="treeEquipmentType" PropertyName="EquipmentType.ObjectID"
                                Caption="Equipment Type" OnAcquireTreePopulater="treeEquipmentType_AcquireTreePopulater"
                                ToolTip="The type of the equipment." meta:resourcekey="treeEquipmentTypeResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIFieldTextBox runat="server" ID="SerialNumber" PropertyName="SerialNumber" Span="Half"
                                Caption="Serial Number" ToolTip="The serial number of this equipment." meta:resourcekey="SerialNumberResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="ModelNumber" PropertyName="ModelNumber" Span="Half"
                                Caption="Model Number" ToolTip="The model number of this equipment." meta:resourcekey="ModelNumberResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="Barcode" PropertyName="Barcode" Span="Half"
                                Caption="Barcode" ToolTip="The barcode identifier of this equipment." meta:resourcekey="BarcodeResource1" InternalControlWidth="95%" />
                            <br />
                            <br />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIFieldDateTime runat="server" ID="DateOfManufacture" PropertyName="DateOfManufacture"
                                Caption="Date of Manufacture" ToolTip="Date of manufacture of the equipment."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="DateOfManufactureResource1" SearchType="Range" ShowDateControls="True" />
                            <ui:UIFieldDateTime runat="server" ID="DateOfOwnership" PropertyName="DateOfOwnership"
                                Caption="Date of Ownership" ToolTip="Date the equipment was purchased." ImageClearUrl="~/calendar/dateclr.gif"
                                ImageUrl="~/calendar/date.gif" meta:resourcekey="DateOfOwnershipResource1"
                                SearchType="Range" ShowDateControls="True" />
                            <ui:UIFieldTextBox runat="server" ID="PriceAtOwnership" PropertyName="PriceAtOwnership"
                                Span="Half" Caption="Price at Ownership ($)" ToolTip="The price of the equipment when purchased."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                meta:resourcekey="PriceAtOwnershipResource1" SearchType="Range" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="LifeSpan" PropertyName="LifeSpan" Span="Half"
                                Caption="Life Span (years)" ToolTip="The estimated life span of the equipment in years."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="LifeSpanResource1"
                                SearchType="Range" InternalControlWidth="95%" />
                            <ui:UIFieldDateTime runat="server" ID="WarrantyExpiryDate" PropertyName="WarrantyExpiryDate"
                                Caption="Warranty Expiry" ToolTip="The date on which the warranty of the equipment expires."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="WarrantyExpiryDateResource1" SearchType="Range" ShowDateControls="True" />
                        </ui:UIPanel>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="Status"
                            Caption="Status" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
                    </ui:UITabView> 
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            OnAction="gridResults_Action" DataKeyNames="ObjectID" GridLines="Both" 
                            RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
                            
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="PrintBarcode" CommandText="Print Selected Barcode" ConfirmText="Are you sure you wish to print barcode of the selected items?" ImageUrl="~/images/printer.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Equipment Name" meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EquipmentType.ObjectName" HeaderText="Equipment Type" meta:resourceKey="UIGridViewColumnResource5" PropertyName="EquipmentType.ObjectName" ResourceAssemblyName="" SortExpression="EquipmentType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="SerialNumber" HeaderText="Serial Number" meta:resourceKey="UIGridViewColumnResource6" PropertyName="SerialNumber" ResourceAssemblyName="" SortExpression="SerialNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ModelNumber" HeaderText="Model Number" meta:resourceKey="UIGridViewColumnResource7" PropertyName="ModelNumber" ResourceAssemblyName="" SortExpression="ModelNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="EquipmentStatus" HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="EquipmentStatus" ResourceAssemblyName="" SortExpression="EquipmentStatus">
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
