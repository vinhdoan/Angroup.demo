<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>
<%@ Register  src="~/components/menu.ascx" tagPrefix="web" tagName="menu" %>
<%@ Register src="~/components/objectsearchpanel.ascx" tagPrefix="web" tagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    protected DataTable GridDataSource()
    {
        DataTable datatable = TablesLogic.tCatalogue.Select(
                                            TablesLogic.tCatalogue.ObjectID,
                                            TablesLogic.tCatalogue.ObjectName,
                                            TablesLogic.tCatalogue.IsCatalogueItem,
                                            TablesLogic.tCatalogue.StockCode,
                                            TablesLogic.tCatalogue.Manufacturer,
                                            TablesLogic.tCatalogue.Model,
                                            TablesLogic.tCatalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                                            TablesLogic.tCatalogue.UnitPrice
                                           )
                                   .Where(
                                           TablesLogic.tCatalogue.IsDeleted == 1 &
                                         //  TablesLogic.tCatalogue.IsCatalogueItem == 1 &
                                           (
                                               TablesLogic.tCatalogue.ObjectName.Like("%" + CatalogName.Text + "%")
                                               & TablesLogic.tCatalogue.StockCode.Like("%" + StockCode.Text + "%")
                                               & TablesLogic.tCatalogue.Manufacturer.Like("%" + Manufacturer.Text + "%")
                                               & TablesLogic.tCatalogue.Model.Like("%" + Model.Text + "%")
                                               & (UnitOfMeasure.Text == "" ? Query.True : TablesLogic.tCatalogue.UnitOfMeasure.ObjectName.Like("%" + UnitOfMeasure.Text + "%"))
                                               & (UnitPrice.Text == "" ? Query.True : TablesLogic.tCatalogue.UnitPrice >= decimal.Parse(UnitPrice.Text))
                                               & (toUnitPrice.Text == "" ? Query.True : TablesLogic.tCatalogue.UnitPrice <= decimal.Parse(toUnitPrice.Text))
                                           )
                                         );
	    datatable.Columns.Add("IsCatalogueItemText", typeof(string));
        datatable.Columns.Add("Path", typeof(string));
	    foreach(DataRow dr in datatable.Rows)
	    {
		    if((int)dr["IsCatalogueItem"]==0)
			    dr["IsCatalogueItemText"] = "Catalog Type";
		    else
			    dr["IsCatalogueItemText"] = "Catalog Item";

            OCatalogue cat = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.ObjectID == (Guid)dr["ObjectID"], true);
            dr["Path"] = cat.DeletedItemsPath;
	    }
        
        return datatable;
    }
    
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomResultTable = GridDataSource();
    }
    
    protected void btn_OnClick(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            foreach (Guid id in gridResults.GetSelectedKeys())
            {

                List<OCatalogue> list = TablesLogic.tCatalogue[TablesLogic.tCatalogue.ObjectID == id, true, null];
                OCatalogue objCatalogue = list[0];
                objCatalogue.Activate();
                objCatalogue.Save();

                panel.Message = "Catalog undeleted successfully";
            }
            c.Commit();
        }
        gridResults.DataSource = GridDataSource();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Undelete Catalog</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <web:search runat="server" id="panel" Caption="Undelete Catalog" GridViewID="gridResults" BaseTable="tCatalogue" OnSearch="panel_Search"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch">
                <ui:UITabView runat="server" ID="uitabviewSearch" caption="Search">                                    
                    <ui:UIFieldTextBox ID="CatalogName" runat="server" Caption="Catalog Name" Span="full"/>                    
                    <ui:UIFieldTextBox ID="StockCode" runat="server" Caption="Stock Code" Span="half"/>
                    <br />
                    <br />
                    <ui:UIFieldTextBox ID="Manufacturer" runat="server" Caption="Manufacturer" Span="half"/>
                    <ui:UIFieldTextBox ID="Model" runat="server" Caption="Model" Span="half"/>
                    <br />
                    <ui:UIFieldTextBox ID="UnitPrice" runat="server" Caption="Unit Price ($)" Span="half" ValidateDataTypeCheck="true" 
                        ValidationDataType="Double" ValidationRangeType="Double" ValidationRangeMin="0"/>
                    <ui:UIFieldTextBox ID="toUnitPrice" runat="server" Caption="to" Span="half" ValidateDataTypeCheck="true" 
                        ValidationDataType="Double" ValidationRangeType="Double" ValidationRangeMin="0"/>
                    <ui:UIFieldTextBox ID="UnitOfMeasure" runat="server" Caption="Unit of Measure" Span="half"/>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabviewResults" caption="Results">
                    <ui:UIButton runat="server" ID="UndeleteSelectedCatalogs" Text="Undelete Selected Catalogs"
                                ImageUrl="~/images/tick.gif" OnClick="btn_OnClick" /> 
                    <ui:UIGridView runat="server" ID="gridResults">
                        <Columns>                            
                            <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Catalog Name"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Path" HeaderText="Path"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="IsCatalogueItemText" HeaderText="Type"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="StockCode" HeaderText="Stock Code"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Manufacturer" HeaderText="Manufacturer"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Model" HeaderText="Model"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="UnitOfMeasure" HeaderText="Unit of Measure"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="UnitPrice" HeaderText="Unit Price ($)"></ui:UIGridViewBoundColumn>
                        </Columns>
                 </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </form>
</body>
</html>
