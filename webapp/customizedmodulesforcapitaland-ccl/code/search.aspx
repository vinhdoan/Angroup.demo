<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Initializes the controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeCode.PopulateTree();

        foreach (TreeNode node in treeCode.Nodes)
            node.CollapseAll();

        // 2010.04.29
        // Populates the Code Type dropdown list
        //
        CodeTypeID.Bind(OCodeType.GetAllCodeTypes());
    }


    /// <summary>
    /// Constructs and returns a code tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCode_AcquireTreePopulater(object sender)
    {
        return new CodeTreePopulater(null);
    }



    /// <summary>
    /// Constructs additional conditions for the search.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeCode.SelectedValue != "")
        {
            List<OCode> o =
                TablesLogic.tCode[TablesLogic.tCode.ObjectID == new Guid(treeCode.SelectedValue), true];
            if (o.Count == 0)
                return;

            e.CustomCondition = TablesLogic.tCode.HierarchyPath.Like(o[0].HierarchyPath + "%");
        }
    }


</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Code" GridViewID="gridResults"
                BaseTable="tCode" OnSearch="panel_Search" SearchType="ObjectQuery"
                AutoSearchOnLoad="false" MaximumNumberOfResults="30" AdvancedSearchPanelID="panelAdvanced"
                SearchTextBoxHint="Code Name, Code Type Name" AdvancedSearchOnLoad="true"
                SearchTextBoxPropertyNames="ObjectName,CodeType.ObjectName"
                meta:resourcekey="panelResource1"
                OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
                        
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeCode" Caption="Code" 
                            OnAcquireTreePopulater="treeCode_AcquireTreePopulater" 
                            meta:resourcekey="treeCodeResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <%--<ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Code Name"
                            ToolTip="The code name as displayed on screen." Span="Half" 
                            MaxLength="255" meta:resourcekey="UIFieldString1Resource1" 
                            InternalControlWidth="95%" />--%>
                        <ui:UIFieldDropDownList runat='server' ID='CodeTypeID' PropertyName="CodeTypeID"
                            Caption="Code Type" ToolTip="The type of this code." meta:resourcekey="CodeTypeIDResource1" />
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Code Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CodeType.ObjectName" HeaderText="Code Type Name" 
                                    PropertyName="CodeType.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="CodeType.ObjectName">
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
