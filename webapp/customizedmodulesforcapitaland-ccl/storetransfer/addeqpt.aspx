<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase"
    Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    /// <summary>
    /// Populates the search controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeCatalogue.PopulateTree();
    }


    /// <summary>
    /// Constructs custom condition for the search.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        OStoreTransfer storeTransfer = Session["::SessionObject::"] as OStoreTransfer;

        textFromStoreID.Text = storeTransfer.FromStoreID.ToString() + "," + storeTransfer.FromStoreType.ToString();
        textToStoreID.Text = storeTransfer.ToStoreID.ToString() + "," + storeTransfer.ToStoreType.ToString();

        e.CustomCondition =
            TablesLogic.tStoreBinItem.StoreBin.StoreID == storeTransfer.FromStoreID &
            TablesLogic.tStoreBinItem.Catalogue.IsGeneratedFromEquipmentType == 1 &
            TablesLogic.tStoreBinItem.Catalogue.IsCatalogueItem == 1;

        if (treeCatalogue.SelectedValue != "")
            e.CustomCondition &=
                TablesLogic.tStoreBinItem.Catalogue.HierarchyPath.Like(
                TablesLogic.tStoreBinItem.Catalogue.Load(new Guid(treeCatalogue.SelectedValue)).HierarchyPath + "%");
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        return new CatalogueTreePopulater(null, true, false, false, true);
    }


    /// <summary>
    /// Binds the store bin dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OStoreTransfer storeTransfer = Session["::SessionObject::"] as OStoreTransfer;
            if (storeTransfer != null)
            {
                Guid catalogId = (Guid)((DataRowView)e.Row.DataItem)["ObjectID"];

                DataTable storeBins = OStore.FindBinsByCatalogue(storeTransfer.ToStoreID.Value, catalogId, true);

                UIFieldDropDownList dropStoreBin = ((UIFieldDropDownList)e.Row.FindControl("dropStoreBin"));
                dropStoreBin.Bind(storeBins, "ObjectName", "ObjectID", true);
                if (dropStoreBin.Items.Count == 2)
                    dropStoreBin.SelectedIndex = 1;
            }
        }
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OStoreTransfer storeTransfer = Session["::SessionObject::"] as OStoreTransfer;
        List<OStoreTransferItem> items = new List<OStoreTransferItem>();

        if (storeTransfer.CurrentActivity.ObjectName == "Start" ||
            storeTransfer.CurrentActivity.ObjectName == "Draft")
        {
            // Creates and binds the StoreCheckIn item objects.
            //
            foreach (GridViewRow row in gridResults.GetSelectedRows())
            {
                // Creates, binds and adds the StoreCheckInItem to the
                // StoreCheckIn object.
                //
                OStoreTransferItem item = TablesLogic.tStoreTransferItem.Create();
                item.StoreBinItemID = (Guid)gridResults.DataKeys[row.RowIndex][0];
                item.Quantity = 1;

                OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(item.StoreBinItemID);
                item.FromStoreBinID = storeBinItem.StoreBinID;
                item.CatalogueID = storeBinItem.CatalogueID;

                gridResults.BindRowToObject(item, row);

                if (textFromStoreID.Text != storeTransfer.FromStoreID.ToString() + "," + storeTransfer.FromStoreType.ToString() ||
                    textToStoreID.Text != storeTransfer.ToStoreID.ToString() + "," + storeTransfer.ToStoreType.ToString())
                {
                    UIFieldDropDownList dropStoreBin = ((UIFieldDropDownList)row.FindControl("dropStoreBin"));
                    dropStoreBin.ErrorMessage = Resources.Errors.Transfer_FromStoreToStoreChanged;
                }

                items.Add(item);
            }
            if (!panelAddEquipment.IsValid)
                return;

            // Adds the items into the StoreTransfer object
            //
            foreach (OStoreTransferItem item in items)
            {
                item.ComputeEstimatedUnitCost();
                storeTransfer.StoreTransferItems.Add(item);
            }
            Window.Opener.ClickUIButton("buttonItemsAdded");
            Window.Close();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Add Equipment"
            GridViewID="gridResults" BaseTable="tStoreBinItem" CloseWindowButtonVisible="true"
            OnPopulateForm="panel_PopulateForm" AddSelectedButtonVisible="true"
            AddButtonVisible="false" EditButtonVisible="false" OnSearch="panel_Search"
            OnValidateAndAddSelected="panel_ValidateAndAddSelected">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabstrip" BorderStyle="NotSet" 
                meta:resourcekey="tabstripResource1">
                <ui:UITabView runat="server" ID="tabSearch" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                    <asp:TextBox runat="server" ID="textFromStoreID" Visible="False" 
                        meta:resourcekey="textFromStoreIDResource1"></asp:TextBox>
                    <asp:TextBox runat="server" ID="textToStoreID" Visible="False" 
                        meta:resourcekey="textToStoreIDResource1"></asp:TextBox>
                    <ui:UIFieldTreeList runat='server' ID="treeCatalogue" OnAcquireTreePopulater="treeCatalogue_AcquireTreePopulater"
                        Caption="Catalog" meta:resourcekey="treeCatalogueResource1" 
                        ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTextBox runat="server" ID="textCatalogName" PropertyName="ObjectName"
                        Caption="Catalog Name" Span="Half" 
                        ToolTip="Part of the name of catalog items to search for" 
                        InternalControlWidth="95%" meta:resourcekey="textCatalogNameResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textModelNumber" Span="Half"
                        Caption="Model Number" PropertyName="Equipment.ModelNumber" 
                        InternalControlWidth="95%" meta:resourcekey="textModelNumberResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textSerialNumber" Span="Half"
                        Caption="Serial Number" PropertyName="Equipment.SerialNumber" 
                        InternalControlWidth="95%" meta:resourcekey="textSerialNumberResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="tabResultsResource1">
                    <ui:UIObjectPanel runat="server" ID="panelAddEquipment" BorderStyle="NotSet" 
                        meta:resourcekey="panelAddEquipmentResource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black"
                            SetValidationGroupForSelectedRowsOnly="True" KeyName="ObjectID"
                            Width="100%" SortExpression="Equipment.EquipmentType.ObjectName ASC"
                            OnRowDataBound="gridResults_RowDataBound" DataKeyNames="ObjectID" 
                            GridLines="Both" meta:resourcekey="gridResultsResource1" 
                            RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.EquipmentType.ObjectName" 
                                    HeaderText="Equipment Type" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="Equipment.EquipmentType.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Equipment.EquipmentType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.ObjectName" 
                                    HeaderText="Equipment Name" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="Equipment.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="Equipment.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.ModelNumber" 
                                    HeaderText="ModelNumber" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="Equipment.ModelNumber" ResourceAssemblyName="" 
                                    SortExpression="Equipment.ModelNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Equipment.SerialNumber" 
                                    HeaderText="SerialNumber" meta:resourcekey="UIGridViewBoundColumnResource4" 
                                    PropertyName="Equipment.SerialNumber" ResourceAssemblyName="" 
                                    SortExpression="Equipment.SerialNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StoreBin.ObjectName" 
                                    HeaderText="From Store Bin" meta:resourcekey="UIGridViewBoundColumnResource5" 
                                    PropertyName="StoreBin.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="StoreBin.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="To Store Bin" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldDropDownList ID="dropStoreBin" runat="server" Caption="Store Bin" 
                                            FieldLayout="Flow" InternalControlWidth="100px" 
                                            meta:resourcekey="dropStoreBinResource1" PropertyName="ToStoreBinID" 
                                            ShowCaption="False" ValidateRequiredField="True">
                                        </cc1:UIFieldDropDownList>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIObjectPanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
