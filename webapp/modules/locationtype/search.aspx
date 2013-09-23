<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
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
        treeLocationType.PopulateTree();
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeLocationType.SelectedValue != "")
        {
            OLocationType locationType = TablesLogic.tLocationType[new Guid(treeLocationType.SelectedValue)];
            if (locationType != null)
                e.CustomCondition = TablesLogic.tLocationType.HierarchyPath.Like(locationType.HierarchyPath + "%");
        }
    }

    /// <summary>
    /// Constructs and returns the location type tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocationType_AcquireTreePopulater(object sender)
    {
        return new LocationTypePopulater(null, true, false);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Location Type" GridViewID="gridResults"
                BaseTable="tLocationType" OnSearch="panel_Search" meta:resourcekey="panelResource1"
                OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeLocationType" Caption="Location Type"
                            OnAcquireTreePopulater="treeLocationType_AcquireTreePopulater" 
                            meta:resourcekey="treeLocationTypeResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Location Type Name"
                            ToolTip="The location type name as displayed on screen." MaxLength="255" 
                            meta:resourcekey="UIFieldString1Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldRadioList runat='server' ID='UIFieldString2' PropertyName="IsLeafType"
                            Caption="Location Type" ToolTip="Indicates if the item to search for is an location type or a group."
                            meta:resourcekey="UIFieldString2Resource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1" selected="True">Any</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">Group</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3">Location Type</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <%--<ui:UIFieldRadioList runat="server" ID="checkIsReportableType" 
                            PropertyName="IsReportableType" Caption="Reportable Type" 
                            meta:resourcekey="checkIsReportableTypeResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem selected="True" meta:resourcekey="ListItemResource4">Any</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource5">No, locations of this location type are not presented in reports</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource6">Yes, locations of this location type are presented in reports</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>--%>
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" 
                                    HeaderText="Location Type Name" meta:resourceKey="UIGridViewColumnResource4" 
                                    PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
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
