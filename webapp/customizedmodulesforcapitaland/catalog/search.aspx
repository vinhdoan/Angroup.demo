<%@ Page Language="C#" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource3" uiculture="auto" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Initializes the controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeCatalogue.PopulateTree();
        dropUnitOfMeasure.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        if (!IsPostBack)
        {
            DefaultChargeOut.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[11].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            UnitPrice.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[10].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
    }


    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeCatalogue.SelectedValue != "")
        {
            OCatalogue Catalogue = TablesLogic.tCatalogue[new Guid(treeCatalogue.SelectedValue)];
            if (Catalogue != null)
                e.CustomCondition = TablesLogic.tCatalogue.HierarchyPath.Like(Catalogue.HierarchyPath + "%");

            List<OStore> s = OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null);
            e.CustomCondition = e.CustomCondition &
                (TablesLogic.tCatalogue.IsSharedAcrossAllStores == 1 | TablesLogic.tCatalogue.Store.ObjectID.In(s));
        }
        else
        {
            ExpressionCondition cond = Query.False;
            List<OStore> d = OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null);
            cond = (TablesLogic.tCatalogue.IsSharedAcrossAllStores == 1 | TablesLogic.tCatalogue.Store.ObjectID.In(d));
            if (e.CustomCondition == null)
                e.CustomCondition = cond;
            else
                e.CustomCondition = e.CustomCondition & cond;
        }       
    }


    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        List<OStore> s = OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), null);
        return new CatalogueTreePopulater(null, true, false, true, true, s);
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                e.Row.Cells[13].Visible = false; 
        }
        if(e.Row.RowType == DataControlRowType.Header)
            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "MARCOM")
                e.Row.Cells[13].Visible = false; 
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Inventory Catalog" GridViewID="gridResults" 
                BaseTable="tCatalogue" OnSearch="panel_Search" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"
                SearchType="ObjectQuery" SearchAssignedOnly="false" ></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeCatalogue" Caption="Inventory Catalog" OnAcquireTreePopulater="treeCatalogue_AcquireTreePopulater" meta:resourcekey="treeCatalogueResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Catalog Name"
                            ToolTip="The Inventory Catalog name as displayed on the screen." Span="Half" meta:resourcekey="UIFieldString1Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldRadioList runat="server" ID="IsCatalogueItem" PropertyName="IsCatalogueItem"
                            Caption="Group/Item" ToolTip="Indicates if the Inventory Catalog to search for is a Inventory Catalog group or item."
                            meta:resourcekey="IsCatalogueItemResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem selected="True" meta:resourcekey="ListItemResource1" Text="Any &#160;"></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2" Text="Inventory Catalog Group&#160;"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3" Text="Inventory Catalog Item"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelCatalogueItem1" meta:resourcekey="panelCatalogueItem1Resource1" BorderStyle="NotSet">
                            <ui:UIFieldTextBox runat="server" ID="StockCode" PropertyName="StockCode" Caption="Stock Code"
                                ToolTip="Stock code of the Inventory Catalog item." meta:resourcekey="StockCodeResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="Manufacturer" PropertyName="Manufacturer" Span="Half"
                                Caption="Manufacturer" ToolTip="Manufacturer of the Inventory Catalog item." meta:resourcekey="ManufacturerResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="Model" PropertyName="Model" Span="Half" Caption="Model"
                                ToolTip="Model of the Inventory Catalog item." meta:resourcekey="ModelResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="UnitPrice" PropertyName="UnitPrice" Span="Half"
                                Caption="Unit Price" ToolTip="Standard unit price of the item." SearchType="Range"
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="UnitPriceResource1" InternalControlWidth="95%" />
                            <ui:UIFieldDropDownList runat="server" ID="dropUnitOfMeasure" PropertyName="UnitOfMeasureID"
                                Span="Half" Caption="Unit of Measure" ToolTip="Unit of measure for this Inventory Catalog item."
                                meta:resourcekey="UnitOfMeasureIDResource1" />
                            <ui:UIFieldTextBox runat='server' ID='DefaultChargeOut' PropertyName="DefaultChargeOut" Visible="false"
                            Caption="Default Charge Out" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" SearchType="Range" InternalControlWidth="95%" meta:resourcekey="DefaultChargeOutResource1" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            SortExpression="ObjectName" RowErrorColor="" DataKeyNames="ObjectID" 
                            GridLines="Both" style="clear:both;" OnRowDataBound="gridResults_RowDataBound">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
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
                                <cc1:UIGridViewBoundColumn DataField="ParentFolder" HeaderText="Folder"  PropertyName="ParentFolder" ResourceAssemblyName="" SortExpression="ParentFolder">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Catalog Name" meta:resourceKey="UIGridViewColumnResource4" PropertyName="Path" ResourceAssemblyName="" SortExpression="Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsCatalogueItemText" HeaderText="Type" meta:resourceKey="UIGridViewColumnResource9" PropertyName="IsCatalogueItemText" ResourceAssemblyName="" SortExpression="IsCatalogueItemText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="InventoryCatalogTypeText" HeaderText="Type" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="InventoryCatalogTypeText" ResourceAssemblyName="" SortExpression="InventoryCatalogTypeText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StockCode" HeaderText="Stock Code" meta:resourceKey="UIGridViewColumnResource5" PropertyName="StockCode" ResourceAssemblyName="" SortExpression="StockCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Manufacturer" HeaderText="Manufacturer" meta:resourceKey="UIGridViewColumnResource6" PropertyName="Manufacturer" ResourceAssemblyName="" SortExpression="Manufacturer">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Model" HeaderText="Model" meta:resourceKey="UIGridViewColumnResource7" PropertyName="Model" ResourceAssemblyName="" SortExpression="Model">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Unit of measure" meta:resourceKey="UIGridViewColumnResource8" PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" DataFormatString="{0:#,##0.00}" HeaderText="Unit Price" meta:resourceKey="UIGridViewColumnResource10" PropertyName="UnitPrice" ResourceAssemblyName="" SortExpression="UnitPrice">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DefaultChargeOut" DataFormatString="{0:#,##0.00}" HeaderText="Default Charge Out" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="DefaultChargeOut" ResourceAssemblyName="" SortExpression="DefaultChargeOut">
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
