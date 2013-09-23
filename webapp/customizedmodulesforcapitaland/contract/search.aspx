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
    /// Initializes the controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();

        listStatus.Bind(OActivity.GetStatuses("OContract"), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
        if (!IsPostBack)
        {
            UIFieldTextBox1.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[8].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")"; 
        }
    }


    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        TContract c = TablesLogic.tContract;
        TContract c2 = new TContract();
        
        ExpressionCondition locationCondition = Query.False;
        
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                locationCondition = locationCondition | c2.Locations.HierarchyPath.Like(location.HierarchyPath+"%");
        }
        else
        {
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OContract"))
                foreach (OLocation location in position.LocationAccess)
                    locationCondition = locationCondition | c2.Locations.HierarchyPath.Like(location.HierarchyPath+"%");
        }

        e.CustomCondition =
            (c.ProvideMaintenance == 0 &
            c.ProvidePricingAgreement == 0) |
            (c2.Select(c2.Locations.ObjectID.Count()).Where(c2.ObjectID == c.ObjectID & c2.Locations.IsDeleted == 0) ==
            c2.Select(c2.Locations.ObjectID.Count()).Where(c2.ObjectID == c.ObjectID & c2.Locations.IsDeleted == 0 & locationCondition));
    }


    /// <summary>
    /// Constructs and returns a location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "OContract", false, false);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelResource1" BorderStyle="NotSet">
            <web:search runat="server" ID="panel" Caption="Contract" GridViewID="gridResults"
                BaseTable="tContract" EditButtonVisible="false" AssignedCheckboxVisible="true" OnpopulateForm="panel_PopulateForm"
                OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Contract Name"
                            ToolTip="The name of the contract as displayed on screen." Span="Half" meta:resourcekey="UIFieldString1Resource1"
                            MaxLength="255" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox7' PropertyName="ObjectNumber" Caption="Contract Number"
                            Span="Half" MaxLength="255" meta:resourcekey="UIFieldTextBox7Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox2' PropertyName="Description"
                            Caption="Description" ToolTip="The description of the contract in detail." MaxLength="255"
                            meta:resourcekey="UIFieldTextBox2Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldDateTime runat='server' ID='uifieldatetime1' PropertyName="ContractStartDate"
                            Caption="Start Date" ToolTip="The date in which the contract starts. Works that begin within the start and end of this contract can be assigned to this contract's vendor."
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="uifieldatetime1Resource1" SearchType="Range" ShowDateControls="True" />
                        <ui:UIFieldDateTime runat='server' ID='uifieldatetime2' PropertyName="ContractEndDate"
                            Caption="End Date" ToolTip="The date in which the contract ends. Works that begin within the start and end of this contract can be assigned to this contract's vendor."
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="uifieldatetime2Resource1" SearchType="Range" ShowDateControls="True" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox3' PropertyName="Terms" Caption="Terms"
                            ToolTip="The terms of this contract." MaxLength="255" meta:resourcekey="UIFieldTextBox3Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox5' PropertyName="Insurance" Caption="Insurance"
                            ToolTip="The information on the insurance of this contract." MaxLength="255"
                            meta:resourcekey="UIFieldTextBox5Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox6' PropertyName="Warranty" Caption="Warranty"
                            ToolTip="The warranty information pertaining to this contract." MaxLength="255"
                            meta:resourcekey="UIFieldTextBox6Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ContractSum"
                            Caption="Contract Sum" Span="Half" ValidateDataTypeCheck='True' ValidationDataType="Currency"
                            ToolTip="The contract sum paid or that will be paid to the vendor in dollars."
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" meta:resourcekey="UIFieldTextBox1Resource1" SearchType="Range" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox4' PropertyName="Vendor.ObjectName"
                            Caption="Vendor Name" ToolTip="The vendor responsible for carrying out the work as indicated by this contract."
                            MaxLength="255" meta:resourcekey="UIFieldTextBox4Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="listStatusResource1" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Contract Number" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Contract Name" meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Vendor.ObjectName" HeaderText="Vendor" meta:resourceKey="UIGridViewColumnResource5" PropertyName="Vendor.ObjectName" ResourceAssemblyName="" SortExpression="Vendor.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ContractStartDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Start Date" meta:resourceKey="UIGridViewColumnResource6" PropertyName="ContractStartDate" ResourceAssemblyName="" SortExpression="ContractStartDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ContractEndDate" DataFormatString="{0:dd-MMM-yyyy}" HeaderText="End Date" meta:resourceKey="UIGridViewColumnResource7" PropertyName="ContractEndDate" ResourceAssemblyName="" SortExpression="ContractEndDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ContractSum" DataFormatString="{0:n}" HeaderText="Contract Sum" PropertyName="ContractSum" ResourceAssemblyName="" SortExpression="ContractSum">
                                    <HeaderStyle HorizontalAlign="Right" />
                                    <ItemStyle HorizontalAlign="Right" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourceKey="UIGridViewColumnResource8" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
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
