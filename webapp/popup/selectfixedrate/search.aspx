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
    }
    
    protected void panel_OnControlChange(object sender, EventArgs e)
    {
        
    }
    
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeFixedRate.SelectedValue != "")
        {
            OFixedRate fixedRate = TablesLogic.tFixedRate[new Guid(treeFixedRate.SelectedValue)];
            if (fixedRate != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tFixedRate.HierarchyPath.Like(fixedRate.HierarchyPath + "%");
        }

        e.CustomCondition = e.CustomCondition & TablesLogic.tFixedRate.IsFixedRate == 1;
        
    }

    protected void gridResults_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "SelectObject")
        {
            if (objectIds.Count > 0)
            {
                Window.Opener.Populate(objectIds[0].ToString());
            }
        }
    }

    /// <summary>
    /// Constructs and returns a location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeFixedRate_AcquireTreePopulater(object sender)
    {
        return new FixedRateTreePopulater(null, true, true);
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <web:search runat="server" id="panel" Caption="Fixed Rate" GridViewID="gridResults" BaseTable="tFixedRate" OnSearch="panel_Search" AddButtonVisible="False" EditButtonVisible="false" OnPopulateForm="panel_PopulateForm">
        </web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" id="tabSearch" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview1" caption="Search"  meta:resourcekey="uitabview1Resource1">
                    <ui:uifieldtreelist runat="server" id="treeFixedRate" Caption="Fixed Rate" OnAcquireTreePopulater="treeFixedRate_AcquireTreePopulater"></ui:uifieldtreelist>
                    <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName" Caption="Name"  CaptionWidth="120px"  ToolTip="The checklist response set as displayed on screen." meta:resourcekey="NameResource1" />
                    <ui:UIFieldTextBox runat='server' ID='LongDescription' PropertyName="LongDescription" Caption="Long Description"  CaptionWidth="120px"  />
                    <ui:UIFieldDropDownList runat='server' ID='UnitOfMeasureID' PropertyName="UnitOfMeasureID" Caption="Unit of Measure"  CaptionWidth="120px"  />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" caption="Results"  meta:resourcekey="uitabview2Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" OnAction="gridResults_Action" CaptionWidth="120px" KeyName="ObjectID" meta:resourcekey="gridResultsResource1" Width="100%" CheckBoxColumnVisible="false" ><Columns>
<ui:UIGridViewButtonColumn ImageUrl="~/images/tick.gif" CommandName="SelectObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1"></ui:UIGridViewButtonColumn>
<ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewColumnResource2"></ui:UIGridViewBoundColumn>
<ui:UIGridViewBoundColumn PropertyName="LongDescription" HeaderText="Long Description" ></ui:UIGridViewBoundColumn>
<ui:UIGridViewBoundColumn PropertyName="UnitOfMeasure.ObjectName" HeaderText="Unit of Measure" meta:resourcekey="UIGridViewColumnResource2"></ui:UIGridViewBoundColumn>
</Columns>
</ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </form>
    
</body>
</html>
