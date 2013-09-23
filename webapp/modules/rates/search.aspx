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
        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        treeFixedRate.PopulateTree();
    }


    /// <summary>
    /// Performs search with custom conditions
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        if (treeFixedRate.SelectedValue != "")
        {
            OFixedRate fixedRate = TablesLogic.tFixedRate[new Guid(treeFixedRate.SelectedValue)];
            if (fixedRate != null)
                e.CustomCondition = TablesLogic.tFixedRate.HierarchyPath.Like(fixedRate.HierarchyPath + "%");
        }

    }


    /// <summary>
    /// Occurs when the user changes the fixed rate dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsFixedRate_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        ratePanel.Visible = IsFixedRate.SelectedIndex == 2;
    }


    /// <summary>
    /// Constructs and returns the fixed rate tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeFixedRate_AcquireTreePopulater(object sender)
    {
        return new FixedRateTreePopulater(null, true, true);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Service Catalog" GridViewID="gridResults"
                BaseTable="tFixedRate" OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm"
                meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeFixedRate" Caption="Service Catalog" 
                            OnAcquireTreePopulater="treeFixedRate_AcquireTreePopulater" 
                            meta:resourcekey="treeFixedRateResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='Name' PropertyName="ObjectName" Caption="Name"
                            ToolTip="The item name as displayed on screen." meta:resourcekey="NameResource1"
                            Span="Half" MaxLength="255" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='ObjectNumber' PropertyName="ObjectNumber" Caption="Item Code"
                            Span="Half" meta:resourcekey="ObjectNumberResource1" 
                            InternalControlWidth="95%" />
                        <ui:UIPanel runat="server" ID="nonBookPanel" Width="100%" 
                            meta:resourcekey="nonBookPanelResource1" BorderStyle="NotSet">
                            <ui:UIFieldRadioList runat="server" ID="IsFixedRate" PropertyName="IsFixedRate" OnSelectedIndexChanged="IsFixedRate_SelectedIndexChanged"
                                Caption="Service Catalog Type" ToolTip="Indicates if this item is a group or a physical fixed rate item."
                                meta:resourcekey="IsFixedRateResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem meta:resourcekey="ListItemResource4" Text="Any "></asp:ListItem>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource5" 
                                        Text="Service Catalog Group "></asp:ListItem>
                                    <asp:ListItem Selected="True" Value="1" meta:resourcekey="ListItemResource6" 
                                        Text="Physical Service Catalog Item "></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="ratePanel" Width="100%" 
                                meta:resourcekey="ratePanelResource1" BorderStyle="NotSet">
                                <ui:UIFieldTextBox runat="server" ID="LongDescription" PropertyName="LongDescription"
                                    Caption="Long Description" TextMode="MultiLine" Rows="3" ToolTip="The long description of this fixed rate item."
                                    meta:resourcekey="LongDescriptionResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="UnitPrice" PropertyName="UnitPrice" Caption="Unit Price ($)"
                                    Span="Half" ToolTip="The unit price of dollars of this fixed rate item." ValidateDataTypeCheck="True"
                                    ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0"
                                    ValidationRangeMax="99999999999999" ValidationRangeType="Currency" meta:resourcekey="UnitPriceResource1"
                                    SearchType="Range" InternalControlWidth="95%" />
                                <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" PropertyName="UnitOfMeasureID"
                                    Caption="Unit of Measure" Span="Half" ToolTip="The unit of measure for this fixed rate item."
                                    meta:resourcekey="UnitOfMeasureIDResource1" />
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                            RowErrorColor="" style="clear:both;">
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Item Code" 
                                    meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="ObjectNumber" 
                                    ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                    HeaderText="Unit of Measure" meta:resourceKey="UIGridViewBoundColumnResource2" 
                                    PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitPrice" HeaderText="Unit Price ($)" 
                                    meta:resourceKey="UIGridViewBoundColumnResource3" PropertyName="UnitPrice" 
                                    ResourceAssemblyName="" SortExpression="UnitPrice">
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
