<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
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
    }

    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeLocation.SelectedValue != "")
        {
            OLocation Location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (Location != null)
                e.CustomCondition = TablesLogic.tStore.Location.HierarchyPath.Like(Location.HierarchyPath + "%");
        }
        else
        {
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OStore"))
            {
                foreach (OLocation location in position.LocationAccess)
                {
                    if (e.CustomCondition == null)
                        e.CustomCondition = TablesLogic.tStore.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                    else
                        e.CustomCondition = e.CustomCondition | TablesLogic.tStore.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                }
            }
        }
    }

    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected TreePopulater EquipmentTypeID_AcquireTreePopulater(object sender)
    {
        return new CatalogueTreePopulater(null, true, true);
    }

    protected void gridResults_Action(object sender, string commandName, System.Collections.Generic.List<object> objectIds)
    {
    }

    /// <summary>
    /// Constructs and returns a location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, Security.Decrypt(Request["TYPE"]), false, false);
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
        <web:search runat="server" ID="panel" Caption="Store" AutoSearchOnLoad="true" SearchTextBoxHint="Store Name, Location"
            MaximumNumberOfResults="25" SearchTextBoxPropertyNames="ObjectName,Location.ObjectName"
            AdvancedSearchPanelID="panelAdvanced" AdvancedSearchOnLoad="true" GridViewID="gridResults"
            BaseTable="tStore" OnSearch="panel_Search" EditButtonVisible="false" meta:resourcekey="panelResource1"
            OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" id="tabSearch"
                meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" caption="Search"
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                    meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                </ui:UIFieldTreeList>
                <ui:UIFieldRadioList runat="server" ID="radioStoreType" Caption="Store Type" PropertyName="StoreType"
                    meta:resourcekey="radioStoreTypeResource1" TextAlign="Right">
                    <Items>
                        <asp:ListItem meta:resourcekey="ListItemResource1" Text="Any" Value=""></asp:ListItem>
                        <asp:ListItem Value="0" Selected="True" meta:resourcekey="ListItemResource2" Text="A physical storeroom that you can check inventory into or out of."></asp:ListItem>
                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource3" Text="An issue location that you can transfer non-consumables and equipments to."></asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
                <%--<ui:UIFieldTextBox runat='server' ID='StoreName' PropertyName="ObjectName"
                        Caption="Store Name"   ToolTip="The store name as displayed on the screen."
                        meta:resourcekey="StoreNameResource1" InternalControlWidth="95%"  />--%>
                <ui:UIFieldRadioList runat="server" ID="IsActiveForCheckIn" Caption="Is Active For Check-In"
                    PropertyName="IsActiveForCheckIn" meta:resourcekey="IsActiveForCheckInResource1"
                    TextAlign="Right" RepeatColumns="3">
                    <Items>
                        <asp:ListItem meta:resourcekey="IsActiveForCheckInResourceAny" Text="Any" Value=""
                            Selected="True"></asp:ListItem>
                        <asp:ListItem Value="0" meta:resourcekey="IsActiveForCheckInListItemResource1" Text="No"></asp:ListItem>
                        <asp:ListItem Value="1" meta:resourcekey="IsActiveForCheckInListItemResource2" Text="Yes"></asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
            </ui:UIPanel>
            <%--</ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" caption="Results"
                    meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" OnAction="gridResults_Action"
                SortExpression="ObjectName" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                Width="100%" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Commands>
                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                        CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                </Commands>
                <Columns>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" CommandText="Edit"
                        ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                        meta:resourceKey="UIGridViewColumnResource2">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Store Name" meta:resourceKey="UIGridViewColumnResource4"
                        PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" meta:resourceKey="UIGridViewColumnResource5"
                        PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="StoreTypeText" HeaderText="Store Type" meta:resourcekey="UIGridViewBoundColumnResource1"
                        PropertyName="StoreTypeText" ResourceAssemblyName="" SortExpression="StoreTypeText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="IsActiveForCheckInText" HeaderText="Is Active for Check-In"
                        meta:resourcekey="IsActiveForCheckInTextResource1" PropertyName="IsActiveForCheckInText"
                        ResourceAssemblyName="" SortExpression="IsActiveForCheckInText">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
            <%--</ui:UITabView>
            </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>