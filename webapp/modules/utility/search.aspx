<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectpanel.ascx" TagPrefix="web" TagName="object" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocationAccess_AcquireTreePopulater(object sender)
    {
        List<OLocation> oLocation = TablesLogic.tLocation[Query.True];
        return new LocationTreePopulater(oLocation, true, true, "");
    }

    /// <summary>
    /// Occurs when a data row is bound to data.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void GridViewUtility_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string strItemType = e.Row.Cells[3].Text;
            if (strItemType != null & strItemType != "")
                e.Row.Cells[3].Text = GetLocationPath(strItemType);
        }
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = TablesLogic.tUtility.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
    }

    /// <summary>
    /// Get Path with each Location ID
    /// </summary>
    /// <param name="strObjectID"></param>
    /// <returns></returns>
    private string GetLocationPath(string strObjectID)
    {
        string strTemp = "";
        OLocation oLocation = TablesLogic.tLocation[new Guid(strObjectID)];
        if (oLocation != null)
            strTemp = oLocation.Path;
        return strTemp;
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Utility" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tUtility" AssignedCheckboxVisible="false" OnSearch="panel_Search"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="UtilityStrip" meta:resourcekey="UtilityStripResource1">
                    <ui:UITabView runat="server" ID="tabSearch" Caption="Search" 
                        meta:resourcekey="tabSearchResource2">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocationAccess_AcquireTreePopulater"
                            meta:resourcekey="treeLocationResource2">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldDateTime runat='server' ID='StartDate' PropertyName="StartDate" Caption="Start Date"
                            ShowTimeControls="False" SearchType="Range" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="StartDateResource1" />
                        <ui:UIFieldDateTime runat='server' ID='EndDate' PropertyName="EndDate" Caption="End Date"
                            ShowTimeControls="False" SearchType="Range" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" meta:resourcekey="EndDateResource1" />
                        <ui:UIFieldTextBox runat="server" ID="Description" Caption="Description" PropertyName="Description"
                            meta:resourcekey="DescriptionResource1"></ui:UIFieldTextBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabResults" Caption="Results" 
                        meta:resourcekey="tabResultsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" OnRowDataBound="GridViewUtility_RowDataBound"
                            BorderColor="Black" KeyName="ObjectID" AllowPaging="True" AllowSorting="True"
                            meta:resourcekey="gridResultsResource1" PagingEnabled="True" Width="100%" ImageRowErrorUrl=""
                            RowErrorColor="">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource9">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="LocationID" HeaderText="Location" meta:resourcekey="UIGridViewColumnResource10">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description"
                                    meta:resourcekey="UIGridViewColumnResource11">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataFormatString="{0:dd-MMM-yyyy}" PropertyName="StartDate"
                                    HeaderText="Start Date" meta:resourcekey="UIGridViewColumnResource12">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataFormatString="{0:dd-MMM-yyyy}" PropertyName="EndDate"
                                    HeaderText="End Date" meta:resourcekey="UIGridViewColumnResource13">
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
