<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
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
        treeLocation.PopulateTree();
        LocationTypeID.PopulateTree();
        ddl_BuildingOwner.Bind(TablesLogic.tCapitalandCompany.LoadAll(), "ObjectName", "ObjectID");
        ddl_BuildingTrust.Bind(TablesLogic.tCapitalandCompany.LoadAll(), "ObjectName", "ObjectID");
        ddl_BuildingManagement.Bind(TablesLogic.tCapitalandCompany.LoadAll(), "ObjectName", "ObjectID");
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
                e.CustomCondition = TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        else
        {
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"])))
            {
                foreach (OLocation location in position.LocationAccess)
                {
                    if (e.CustomCondition == null)
                        e.CustomCondition = TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%");
                    else
                        e.CustomCondition = e.CustomCondition | TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%");
                }
            }
        }
        if (e.CustomCondition == null)
            e.CustomCondition = Query.True;   
            
        if(!IncludeInactive.Checked)
            e.CustomCondition = e.CustomCondition & TablesLogic.tLocation.IsActive == 1;
    }

    /// <summary>
    /// Constructs the location type tree view.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater LocationTypeID_AcquireTreePopulater(object sender)
    {
        return new LocationTypePopulater(null, true, true);
    }

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelLocation1.Visible = IsPhysicalLocation.SelectedIndex == 2;
    }

    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true,
            Security.Decrypt(Request["TYPE"]), IncludeInactive.Checked, true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string controlName = Request.Params.Get("__EVENTTARGET");
        string arguement = Request.Params.Get("__EVENTARGUMENT");

        if (controlName == "treeLocation" && arguement.Contains("SEARCH") && treeLocation.Enabled)
        {
            string[] arg = arguement.Split('_');

            if (arg != null && arg.Length == 2)
                treeLocation.SelectedValue = Security.Decrypt(arg[1]);
        }
    }

    protected void IsPhysicalLocation_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void IncludeInactive_CheckedChanged(object sender, EventArgs e)
    {

        treeLocation.PopulateTree();
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
            <web:search runat="server" ID="panel" Caption="Location" GridViewID="gridResults" EditButtonVisible="true"
                BaseTable="tLocation" TreeviewUrl="../../tree/location.aspx" OnSearch="panel_Search" SearchType="ObjectQuery"
                meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <table cellpadding="0" cellspacing="0" border="0">
                                <tr><td nowrap >
                        <ui:UIFieldCheckBox id="IncludeInactive" runat="server" 
                        caption="Show Inactive area as well" TextAlign="Right" Span = "Half" OnCheckedChanged="IncludeInactive_CheckedChanged" meta:resourcekey="IncludeInactiveResource1" />
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" 
                                        OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                                        meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                                        TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        </td>
                                <td width="40px" valign="middle">
                                    <web:map runat="server" id="buttonMap" TargetControlID="treeLocation">
                                    </web:map>
                                </td></tr>
                                </table>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Location Name"
                            ToolTip="The location name as displayed on screen." MaxLength="255" 
                            meta:resourcekey="UIFieldString1Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldRadioList runat="server" ID="IsPhysicalLocation" PropertyName="IsPhysicalLocation"
                            Caption="Folder/Physical" ToolTip="Indicates if the item to search for is a folder or a physical location."
                            meta:resourcekey="IsPhysicalLocationResource1" 
                            OnSelectedIndexChanged="IsPhysicalLocation_SelectedIndexChanged" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1" Text="Any &nbsp;"></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2" Text="Folder &nbsp;"></asp:ListItem>
                                <asp:ListItem Selected="True" Value="1" meta:resourcekey="ListItemResource3" Text="Physical Location"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelLocation1" Width="100%" 
                            meta:resourcekey="panelLocation1Resource1" BorderStyle="NotSet">
                            <ui:UIFieldTreeList runat="server" ID="LocationTypeID" PropertyName="LocationTypeID"
                                Caption="Location Type" OnAcquireTreePopulater="LocationTypeID_AcquireTreePopulater"
                                meta:resourcekey="LocationTypeIDResource1" ShowCheckBoxes="None" 
                                TreeValueMode="SelectedNode" />
                            <ui:UIFieldTextBox runat="server" ID="AddressCountry" PropertyName="AddressCountry"
                                Caption="Country" MaxLength="255" 
                                meta:resourcekey="AddressCountryResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="AddressState" PropertyName="AddressState" Caption="State"
                                MaxLength="255" meta:resourcekey="AddressStateResource1" 
                                InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="AddressCity" PropertyName="AddressCity" Caption="City"
                                MaxLength="255" meta:resourcekey="AddressCityResource1" 
                                InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="Address" PropertyName="Address" Caption="Address"
                                MaxLength="255" meta:resourcekey="AddressResource1" 
                                InternalControlWidth="95%" />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIFieldDateTime runat="server" ID="DateOfOwnership" PropertyName="DateOfOwnership"
                                Caption="Date of Ownership" ToolTip="The date from which this location was acquired."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                meta:resourcekey="DateOfOwnershipResource1" SearchType="Range" 
                                ShowDateControls="True" />
                            <ui:UIFieldTextBox runat="server" ID="PriceAtOwnership" PropertyName="PriceAtOwnership"
                                SearchType="Range" Span="Half" Caption="Price at Ownership ($)" ToolTip="The price of the location when acquired."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                meta:resourcekey="PriceAtOwnershipResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="LifeSpan" PropertyName="LifeSpan" SearchType="Range"
                                Span="Half" Caption="Life Span (years)" ToolTip="The life span of this location in years."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" 
                                meta:resourcekey="LifeSpanResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="GrossFloorArea" PropertyName="GrossFloorArea"
                                SearchType="Range" Span="Half" Caption="Gross Floor Area" ValidateDataTypeCheck="True"
                                ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0"
                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" 
                                meta:resourcekey="GrossFloorAreaResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="NetLettableArea" PropertyName="NetLettableArea"
                                SearchType="Range" Span="Half" Caption="Net Lettable Area" ValidateDataTypeCheck="True"
                                ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0"
                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" 
                                meta:resourcekey="NetLettableAreaResource1" InternalControlWidth="95%" />
                                
                            <br />
                        <br />
                        <ui:UIFieldDropDownList runat="server" ID="ddl_BuildingOwner" 
                                PropertyName="BuildingOwnerID" Caption="Building Owner" 
                                meta:resourcekey="ddl_BuildingOwnerResource1" >
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="ddl_BuildingTrust" 
                                PropertyName="BuildingTrustID" Caption="Building Trust" 
                                meta:resourcekey="ddl_BuildingTrustResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="ddl_BuildingManagement" 
                                PropertyName="BuildingManagementID" Caption="Building Management" 
                                meta:resourcekey="ddl_BuildingManagementResource1" >
                        </ui:UIFieldDropDownList>
                        
                        <br /><br />
                        <ui:UISeparator runat="server" ID="AmosSeparator" Caption="Amos" meta:resourcekey="AmosSeparatorResource1" />
                        
                        <ui:UIFieldRadioList runat="server" Caption="From Amos" ID="rdlFromAmos" RepeatColumns="3" RepeatDirection="Vertical" PropertyName="FromAmos" meta:resourcekey="rdlFromAmosResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource4" Text="All"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource5" Text="Yes"></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource6" Text="No"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:uifieldtextbox id="AmosAssetID" runat="server" 
                        caption="Amos Asset ID" SearchType="Range" 
                        ValidationRangeType="Integer"
                        propertyname="AmosAssetID" Span = "Half" InternalControlWidth="95%" meta:resourcekey="AmosAssetIDResource1"/>
                        <ui:uifieldtextbox id="AmosSuiteID" runat="server" 
                        caption="Amos Suite ID" SearchType="Range" 
                        ValidationRangeType="Integer"
                        propertyname="AmosSuiteID" Span = "Half" InternalControlWidth="95%" meta:resourcekey="AmosSuiteIDResource1" />
                        <ui:uifieldtextbox id="AmosLevelID" runat="server" 
                        caption="Amos Level ID" SearchType="Range" 
                        ValidationRangeType="Integer" 
                        propertyname="AmosLevelID" Span = "Half" InternalControlWidth="95%" meta:resourcekey="AmosLevelIDResource1" />
                        <ui:uifieldtextbox id="AmosAssetTypeID" runat="server" 
                        caption="Amos Asset Type ID" SearchType="Range" 
                        ValidationRangeType="Integer"
                        propertyname="AmosAssetTypeID" Span = "Half" InternalControlWidth="95%" meta:resourcekey="AmosAssetTypeIDResource1" />
                        <ui:UIFieldDateTime id="LeaseableFrom" runat="server" SearchType="Range"
                        caption="Leaseable From"
                        propertyname="LeaseableFrom" Span = "Half" meta:resourcekey="LeaseableFromResource1" ShowDateControls="True" />
                        <ui:uifieldtextbox id="LeaseableTo" runat="server" 
                        caption="Leaseable To" SearchType="Range"
                        propertyname="LeaseableTo" Span = "Half" InternalControlWidth="95%" meta:resourcekey="LeaseableToResource1" />
                        <ui:uifieldtextbox id="LeaseableArea" runat="server" 
                        caption="Leaseable Area" SearchType=Range
                        propertyname="LeaseableArea" Span = "Half" InternalControlWidth="95%" meta:resourcekey="LeaseableAreaResource1" />
                        <ui:UIFieldDateTime id="updatedOn" runat="server" 
                        caption="Updated On" SearchType="Range"
                        propertyname="updatedOn" Span = "Half" meta:resourcekey="updatedOnResource1" ShowDateControls="True" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Location Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="LocationType.ObjectName" 
                                    HeaderText="Location Type" meta:resourceKey="UIGridViewColumnResource5" 
                                    PropertyName="LocationType.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="LocationType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="DateOfOwnership" 
                                    DataFormatString="{0:dd-MMM-yyyy}" HeaderText="Date of Ownership" 
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="DateOfOwnership" 
                                    ResourceAssemblyName="" SortExpression="DateOfOwnership">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="GrossFloorArea" 
                                    HeaderText="Gross Floor Area" meta:resourceKey="UIGridViewColumnResource7" 
                                    PropertyName="GrossFloorArea" ResourceAssemblyName="" 
                                    SortExpression="GrossFloorArea">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsActiveText" 
                                    HeaderText="Is Active"
                                    PropertyName="IsActiveText" ResourceAssemblyName="" 
                                    SortExpression="IsActiveText" meta:resourcekey="UIGridViewBoundColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FromAmosText" 
                                    HeaderText="From AMOS?" DataField="FromAmosText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    ResourceAssemblyName="" SortExpression="FromAmosText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AmosAssetID" HeaderText="AMOS Asset ID" DataField="AmosAssetID" meta:resourcekey="UIGridViewBoundColumnResource3" ResourceAssemblyName="" SortExpression="AmosAssetID">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AmosLevelID" HeaderText="AMOS Level ID" DataField="AmosLevelID" meta:resourcekey="UIGridViewBoundColumnResource4" ResourceAssemblyName="" SortExpression="AmosLevelID">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AmosSuiteID" HeaderText="AMOS Suite ID" DataField="AmosSuiteID" meta:resourcekey="UIGridViewBoundColumnResource5" ResourceAssemblyName="" SortExpression="AmosSuiteID">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
