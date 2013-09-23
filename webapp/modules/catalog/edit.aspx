<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
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
        OCatalogue catalogue = panel.SessionObject as OCatalogue;

        if (Request["TREEOBJID"] != null && TablesLogic.tCatalogue[Security.DecryptGuid(Request["TREEOBJID"])] != null)
        {
            catalogue.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);

            if (catalogue.Parent != null && catalogue.Parent.IsCatalogueItem == 1)
                catalogue.ParentID = null;
        }

        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", catalogue.UnitOfMeasureID));
        ParentID.PopulateTree();

        // Disable certain fields once the inventory catalog 
        // has been saved, as modifying them has implications
        // due to their links to other modules.
        //
        radioInventoryCatalogType.Enabled = catalogue.IsNew;
        ParentID.Enabled = catalogue.IsNew;
        IsCatalogueItem.Enabled = catalogue.IsNew;

        // Create items on the inventory catalog type list
        //
        radioInventoryCatalogType.Items.Clear();
        radioInventoryCatalogType.Items.Add(new ListItem(Resources.Strings.InventoryCatalogType_Consumables, "0"));
        radioInventoryCatalogType.Items.Add(new ListItem(Resources.Strings.InventoryCatalogType_NonConsumables, "1"));
        if (catalogue.IsGeneratedFromEquipmentType == 1)
            radioInventoryCatalogType.Items.Add(new ListItem(Resources.Strings.InventoryCatalogType_Equipment, "2"));

        panel.ObjectPanel.BindObjectToControls(catalogue);
    }


    /// <summary>
    /// Validates and saves the catalog object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCatalogue catalogue = panel.SessionObject as OCatalogue;
            panel.ObjectPanel.BindControlsToObject(catalogue);

            // Save
            //        
            catalogue.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Occurs when the user selects an item in the "Catalog Item/Type"
    /// radio button list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsCatalogueItem_SelectedIndexChanged(object sender, EventArgs e)
    {
        OCatalogue catalogue = panel.SessionObject as OCatalogue;

        if (catalogue.Parent != null && catalogue.Parent.IsCatalogueItem == 1)
        {
            IsCatalogueItem.SelectedIndex = 1;
            IsCatalogueItem.Enabled = false;
        }
    }


    /// <summary>
    /// Occurs when the user selects an item in the Belongs Under tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        OCatalogue catalog = panel.SessionObject as OCatalogue;

        if (catalog.IsGeneratedFromEquipmentType == 1)
            return new CatalogueTreePopulater(panel.SessionObject.ParentID, false, false, true, true);
        else
            return new CatalogueTreePopulater(panel.SessionObject.ParentID, false, false, true, false);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        OCatalogue catalog = panel.SessionObject as OCatalogue;

        base.OnPreRender(e);
        panelCatalogueItem1.Visible = IsCatalogueItem.SelectedIndex == 1;
        objectBase.ObjectNameEnabled = catalog.IsGeneratedFromEquipmentType == 0;
        panelGeneratedFromEquipmentType.Visible = catalog.IsGeneratedFromEquipmentType == 1;


        if ((catalog.IsGeneratedFromEquipmentType == 0 ||
            catalog.IsGeneratedFromEquipmentType == null) &&
            radioInventoryCatalogType.Items.Count > 2)
            radioInventoryCatalogType.Items[2].Enabled = false;
    }



    /// <summary>
    /// Constructs and returns the equipment type tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipmentType_AcquireTreePopulater(object sender)
    {
        OCatalogue catalog = panel.SessionObject as OCatalogue;
        return new EquipmentTypeTreePopulater(catalog.EquipmentTypeID, true, true);
    }


    /// <summary>
    /// Occurs when the user clicks on a context menu item in the
    /// Equipment Type treeview control.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipmentType_Command(object sender, CommandEventArgs e)
    {
        if (e.CommandName == "AddEquipmentType")
        {
            OCatalogue catalog = panel.SessionObject as OCatalogue;
            panel.ObjectPanel.BindControlsToObject(catalog);

            Window.Open("../eqpttype/editlight.aspx?N=1" +
                "&ID=" + HttpUtility.UrlEncode(Security.Encrypt("NEW:")) +
                "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt("OEquipmentType")), "AnacleEAM_Window1");
        }
    }


    /// <summary>
    /// Occurs when the user selects the inventory catalog type.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioInventoryCatalogType_SelectedIndexChanged(object sender, EventArgs e)
    {

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
            <web:object runat="server" ID="panel" Caption="Inventory Catalog" BaseTable="tCatalogue"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                    BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false"></web:base>
                        <ui:UIPanel runat="server" ID="panelGeneratedFromEquipmentType">
                            <img src="../../images/information.png" style="border: 0px" alt='' />
                            <asp:label runat="server" ID="labelGeneratedFromEquipmentType" Text="This record has been generated from an Equipment Type record" ></asp:label>
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            ValidateRequiredField="True" OnAcquireTreePopulater="ParentID_AcquireTreePopulater"
                            ToolTip="The group which this Inventory Catalog belongs to" meta:resourcekey="ParentIDResource1" />
                        <ui:UIFieldRadioList runat="server" ID="IsCatalogueItem" PropertyName="IsCatalogueItem"
                            Caption="Group/Item" OnSelectedIndexChanged="IsCatalogueItem_SelectedIndexChanged"
                            ValidateRequiredField="True" ToolTip="Indicates if this item is a Inventory Catalog group or item."
                            meta:resourcekey="IsCatalogueItemResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Inventory Catalog Group&#160;">
                                </asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Inventory Catalog Item">
                                </asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelCatalogueItem1" meta:resourcekey="panelCatalogueItem1Resource1"
                            BorderStyle="NotSet">
                            <ui:UIFieldTextBox runat="server" ID="StockCode" PropertyName="StockCode" 
                                Caption="Stock Code" ToolTip="Stock code of the Inventory Catalog item." meta:resourcekey="StockCodeResource1" />
                            <ui:UIFieldTextBox runat="server" ID="Manufacturer" PropertyName="Manufacturer" Span="Half"
                                Caption="Manufacturer" ToolTip="Manufacturer of the Inventory Catalog item."
                                meta:resourcekey="ManufacturerResource1" />
                            <ui:UIFieldTextBox runat="server" ID="Model" PropertyName="Model" Span="Half" Caption="Model"
                                ToolTip="Model of the Inventory Catalog item." meta:resourcekey="ModelResource1" />
                            <ui:UIFieldTextBox runat="server" ID="UnitPrice" PropertyName="UnitPrice" Span="Half"
                                Caption="Unit Price ($)" ToolTip="Standard unit price of this item." ValidateDataTypeCheck="True"
                                ValidationDataType='Currency' meta:resourcekey="UnitPriceResource1" 
                                ValidateRangeField="True" ValidationRangeMin="0" 
                                ValidationRangeMinInclusive="False" ValidationRangeType="Currency" />
                            <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" PropertyName="UnitOfMeasureID"
                                ValidateRequiredField="True" Span="Half" Caption="Unit of Measure" ToolTip="Unit of measure for this Inventory Catalog item."
                                meta:resourcekey="UnitOfMeasureIDResource1" />
                            <ui:UIFieldLabel runat='server' ID="labelEmpty" />
                            <ui:UIFieldRadioList runat="server" ID="radioInventoryCatalogType" Caption="Type"
                                PropertyName="InventoryCatalogType" OnSelectedIndexChanged="radioInventoryCatalogType_SelectedIndexChanged"
                                ValidateRequiredField="true">
                            </ui:UIFieldRadioList>
                            <ui:UIFieldLabel runat='server' ID="labelInventoryCatalogType" Text="Select the appropriate type for this inventory catalog. This cannot be changed once the inventory catalog is saved." />
                            <br />
                            <br />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Memo"  meta:resourcekey="uitabview2Resource1">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Attachments" 
                        meta:resourcekey="uitabview3Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
