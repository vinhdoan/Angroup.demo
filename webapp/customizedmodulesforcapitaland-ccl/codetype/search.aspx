<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeCodeType.PopulateTree();
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeCodeType.SelectedValue != "")
        {
            List<OCodeType> codeTypes =
                TablesLogic.tCodeType[TablesLogic.tCodeType.ObjectID == new Guid(treeCodeType.SelectedValue), true];
            if (codeTypes.Count == 0)
                return;

            e.CustomCondition = TablesLogic.tCodeType.HierarchyPath.Like(codeTypes[0].HierarchyPath + "%");
        }
    }


    /// <summary>
    /// Constructs and returns the code type tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeCodeType_AcquireTreePopulater(object sender)
    {
        return new CodeTypeTreePopulater(null);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Code Types" GridViewID="gridResults"
                ObjectPanelID="tabSearch" BaseTable="tCodeType" 
                AutoSearchOnLoad="false" MaximumNumberOfResults="30" AdvancedSearchPanelID="panelAdvanced"
                SearchTextBoxHint="Code Type Name" AdvancedSearchOnLoad="true"
                SearchTextBoxPropertyNames="ObjectName"
                OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"
                meta:resourcekey="panelResource1"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeCodeType" Caption="Code Type" 
                            OnAcquireTreePopulater="treeCodeType_AcquireTreePopulater" 
                            meta:resourcekey="treeCodeTypeResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <%--<ui:UIFieldTextBox runat='server' ID='UIFieldString2' PropertyName="ObjectName" Caption="Code Type Name"
                            ToolTip="The display name of the code" MaxLength="255" 
                            meta:resourcekey="UIFieldString2Resource1" InternalControlWidth="95%" />--%>
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Code Type Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
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
