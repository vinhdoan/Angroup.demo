<%@ Page Language="C#" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource2"
    UICulture="auto" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Initializes the controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
        if (Request["POID"] != null)
        {
            try
            {
                Guid poID = new Guid(Security.Decrypt(Request["POID"]));

                OPurchaseOrder po = TablesLogic.tPurchaseOrder[poID];
                if (po != null)
                {
                    treeLocation.SelectedValue = po.LocationID.Value.ToString();
                }
            }
            catch { }
        }
        //listRoles.Bind(ORole.GetRolesByRoleCode("APPROVER"), "RoleName", "ObjectID");
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }

    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        if (Request["POID"] != null)
        {
            try
            {
                Guid poID = new Guid(Security.Decrypt(Request["POID"]));

                OPurchaseOrder po = TablesLogic.tPurchaseOrder[poID];
                if (po != null)
                {
                    return new LocationTreePopulater(po.Location.ObjectID, true, true, "OUser");
                }
            }
            catch { }
        }
        return new LocationTreePopulater(null, true, true, "OUser");
    }

    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        //e.CustomCondition = searchCatalog.GetCustomCondition();
        e.CustomCondition = TablesLogic.tUser.isTenant == 0;

        // Set up the location condition.
        //
        ExpressionCondition locCondition = null;
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                //locCondition = ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tUser.Positions.LocationAccess.HierarchyPath + "%");
                locCondition = TablesLogic.tUser.Positions.LocationAccess.HierarchyPath.Like(((ExpressionDataString)location.HierarchyPath) + "%");
            //locCondition = location.HierarchyPath.Like(TablesLogic.tUser.Positions.LocationAccess.HierarchyPath + "%");
        }

        if (locCondition != null)
            e.CustomCondition = e.CustomCondition & locCondition;
    }

    /// <summary>
    /// Adds the WJ item object into the session object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OPurchaseOrder po = Session["::SessionObject::"] as OPurchaseOrder;
        int itemNumber = 0;
        foreach (OPurchaseOrderItem poi in po.PurchaseOrderItems)
            if (poi.ItemNumber > itemNumber && poi.ItemNumber != null)
                itemNumber = poi.ItemNumber.Value;
        itemNumber++;

        List<OPurchaseOrderItem> items = new List<OPurchaseOrderItem>();
        foreach (GridViewRow row in gridResults.GetSelectedRows())
        {
            // Create an add object
            //
            OCatalogue catalogue = TablesLogic.tCatalogue.Load((Guid)gridResults.DataKeys[row.RowIndex][0]);
            OPurchaseOrderItem poi = TablesLogic.tPurchaseOrderItem.Create();
            poi.ItemNumber = itemNumber++;
            poi.ItemType = PurchaseItemType.Material;
            poi.CatalogueID = catalogue.ObjectID;
            poi.ItemDescription = catalogue.ObjectName;
            poi.UnitOfMeasureID = catalogue.UnitOfMeasureID;
            poi.ReceiptMode = ReceiptModeType.Quantity;
            gridResults.BindRowToObject(poi, row);
            items.Add(poi);
        }
        if (!panelMain.IsValid)
            return;

        po.PurchaseOrderItems.AddRange(items);
        Window.Opener.ClickUIButton("buttonItemsAdded");
        Window.Close();
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
        <web:search runat="server" ID="panel" Caption="User" GridViewID="gridResults" BaseTable="tUser"
            EditButtonVisible="false" SearchType="ObjectQuery" MaximumNumberOfResults="50"
            AddSelectedButtonVisible="true" AddButtonVisible="false" SearchTextBoxHint="E.g. User Name, Login Name, Email, Cellphone, Phone, Description"
            AutoSearchOnLoad="true" AdvancedSearchOnLoad="true" AdvancedSearchPanelID="panelAdvanced"
            SearchTextBoxPropertyNames="ObjectName,UserBase.LoginName,UserBase.Email,UserBase.Cellphone,UserBase.Phone,Description,Positions.Role.RoleCode"
            meta:resourcekey="panel" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search">
        </web:search>
        <div class="div-form">
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" ToolTip="Use this to select the location that this work applies to."
                    OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1"
                    ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                </ui:UIFieldTreeList>
                <%--<ui:UIFieldListBox runat="server" ID="listRoles" PropertyName="PermanentPositions.Position.RoleID"
                    Caption="Roles" meta:resourcekey="listRolesResource1"></ui:UIFieldListBox>--%>
            </ui:UIPanel>
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                meta:resourcekey="gridResultsResource1" Width="100%" DataKeyNames="ObjectID"
                GridLines="Both" RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Columns>
                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="User Name" meta:resourceKey="UIGridViewColumnResource4"
                        PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="UserBase.LoginName" HeaderText="Login Name"
                        meta:resourceKey="UIGridViewColumnResource5" PropertyName="UserBase.LoginName"
                        ResourceAssemblyName="" SortExpression="UserBase.LoginName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="UserBase.Email" HeaderText="Email" meta:resourceKey="UIGridViewColumnResource7"
                        PropertyName="UserBase.Email" ResourceAssemblyName="" SortExpression="UserBase.Email">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
            <br />
            <asp:Label runat="server" ID="labelUserLicense" meta:resourcekey="labelUserLicenseResource1"
                Text="Licenses: "></asp:Label>
            <asp:Label runat="server" ID="labelUserLicenseCount" meta:resourcekey="labelUserLicenseCountResource1"></asp:Label>
            <%--</ui:UITabView>
                </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>