<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>
<%@ Register src="~/components/menu.ascx" tagPrefix="web" tagName="menu" %>
<%@ Register src="~/components/objectsearchpanel.ascx" tagPrefix="web" tagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="pragma" content="no-cache" />


<script runat="server">
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        treeCatalog.PopulateTree();
    }
    
    protected void panel_OnControlChange(object sender, EventArgs e)
    {
        
    }
    
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        // Search for only consumables to add to a work
        //
        e.CustomCondition =
            TablesLogic.tCatalogue.IsCatalogueItem == 1 &
            (TablesLogic.tCatalogue.InventoryCatalogType == InventoryCatalogType.Consumable) &
            TablesLogic.tCatalogue.EquipmentTypeID == null;

        if (treeCatalog.SelectedValue != "")
        {
            OCatalogue catalogue = TablesLogic.tCatalogue[new Guid(treeCatalog.SelectedValue)];
            if (catalogue != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tCatalogue.HierarchyPath.Like(catalogue.HierarchyPath + "%");
        }

        e.CustomCondition = e.CustomCondition & TablesLogic.tCatalogue.IsCatalogueItem == 1;
    }

    
    protected void gridResults_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "SelectObject")
        {
            if (objectIds.Count > 0)
            {
                OCatalogue catalog = TablesLogic.tCatalogue.Load((Guid)objectIds[0]);
                Window.Opener.Populate(objectIds[0].ToString());
            }
        }
    }

    /// <summary>
    /// Constructs and returns a location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCatalog_AcquireTreePopulater(object sender)
    {
        return new CatalogueTreePopulater(null, true, true);
    }


</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelSeach">
        <web:search runat="server" id="panel" Caption="Catalogue" GridViewID="gridResults" BaseTable="tCatalogue" OnSearch="panel_Search" TreeViewURL="tree.aspx" AddButtonVisible="False" EditButtonVisible="false" onSelectedNodeChanged="panel_OnControlChange" OnPopulateForm="panel_PopulateForm">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" id="tabSearch" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview1" caption="Search"  meta:resourcekey="uitabview1Resource1">
                    <ui:uifieldtreelist runat="server" id="treeCatalog" Caption="Catalog" OnAcquireTreePopulater="treeCatalog_AcquireTreePopulater"></ui:uifieldtreelist>
                    <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName" Caption="Name"  CaptionWidth="120px"  ToolTip="The checklist response set as displayed on screen." meta:resourcekey="NameResource1" />
                        <ui:UIFieldTextBox runat="server" ID="StockCode" PropertyName="StockCode" Span="full" Caption="Stock Code" ToolTip="Stock code of the Catalog item."/>
                        <ui:UIFieldTextBox runat="server" ID="Manufacturer" PropertyName="Manufacturer" Span="half" Caption="Manufacturer" ToolTip="Manufacturer of the Catalog item." />
                        <ui:UIFieldTextBox runat="server" ID="Model" PropertyName="Model" Span="half" Caption="Model" ToolTip="Model of the Catalog item." />
                        <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" PropertyName ="UnitOfMeasureID" Span="full" Caption="Unit of Measure" ToolTip="Unit of measure for this Catalog item."/>                        
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" caption="Results"  meta:resourcekey="uitabview2Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" OnAction="gridResults_Action" CaptionWidth="120px" KeyName="ObjectID" meta:resourcekey="gridResultsResource1" Width="100%" CheckBoxColumnVisible="false" >
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/tick.gif" CommandName="SelectObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1"></ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn  PropertyName="ObjectName" HeaderText="Catalog Name" />
                            <ui:UIGridViewBoundColumn  PropertyName="StockCode" HeaderText="Stock Code" />
                            <ui:UIGridViewBoundColumn  PropertyName="Manufacturer" HeaderText="Manufacturer" />
                            <ui:UIGridViewBoundColumn  PropertyName="Model" HeaderText="Model" />
                            <ui:UIGridViewBoundColumn  PropertyName="UnitOfMeasure.ObjectName" HeaderText="Unit of measure" />
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
        </ui:UIObjectPanel>
    </form>
    
</body>
</html>
