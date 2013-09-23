<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
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
        treeLocation.PopulateTree();
    }

    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = TablesLogic.tServiceLevel.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        else
        {
            foreach (OPosition position in AppSession.User.Positions)
            {
                foreach (OLocation location in position.LocationAccess)
                {
                    if (e.CustomCondition == null)
                        e.CustomCondition = TablesLogic.tServiceLevel.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                    else
                        e.CustomCondition = e.CustomCondition | TablesLogic.tServiceLevel.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                }
            }
        }
    }

    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="Service Level" GridViewID="gridResults"
                BaseTable="tServiceLevel" OnSearch="panel_Search" EditButtonVisible="false" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectName"
                            Caption="Service Level Name" ToolTip="The service level name as displayed on screen."
                            MaxLength="255" meta:resourcekey="UIFieldTextBox1Resource1" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Location.ObjectName" HeaderText="Location"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Service Level Name"
                                    meta:resourcekey="UIGridViewColumnResource5">
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
