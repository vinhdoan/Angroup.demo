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
        LocationTypeID.PopulateTree();
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
        return new LocationTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="Location" GridViewID="gridResults" EditButtonVisible="true"
                BaseTable="tLocation" TreeviewUrl="../../tree/location.aspx" OnSearch="panel_Search" SearchType="ObjectQuery"
                meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1">
                        <table cellpadding="0" cellspacing="0" border="0">
                                <tr><td nowrap >
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1">
                        </ui:UIFieldTreeList>
                        </td>
                                <td width="40px" valign="middle">
                                    <web:map runat="server" id="buttonMap" TargetControlID="treeLocation">
                                    </web:map>
                                </td></tr>
                                </table>
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Location Name"
                            ToolTip="The location name as displayed on screen." MaxLength="255" meta:resourcekey="UIFieldString1Resource1" />
                        <ui:UIFieldRadioList runat="server" ID="IsPhysicalLocation" PropertyName="IsPhysicalLocation"
                            Caption="Folder/Physical" ToolTip="Indicates if the item to search for is a folder or a physical location."
                            meta:resourcekey="IsPhysicalLocationResource1" OnSelectedIndexChanged="IsPhysicalLocation_SelectedIndexChanged">
                            <Items>
                                <asp:ListItem Value="" meta:resourcekey="ListItemResource1">Any &#160;</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">Folder &#160;</asp:ListItem>
                                <asp:ListItem Selected="True" Value="1" meta:resourcekey="ListItemResource3">Physical Location</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelLocation1" Width="100%" meta:resourcekey="panelLocation1Resource1">
                            <ui:UIFieldTreeList runat="server" ID="LocationTypeID" PropertyName="LocationTypeID"
                                Caption="Location Type" OnAcquireTreePopulater="LocationTypeID_AcquireTreePopulater"
                                meta:resourcekey="LocationTypeIDResource1" />
                            <ui:UIFieldTextBox runat="server" ID="AddressCountry" PropertyName="AddressCountry"
                                Caption="Country" MaxLength="255" meta:resourcekey="AddressCountryResource1" />
                            <ui:UIFieldTextBox runat="server" ID="AddressState" PropertyName="AddressState" Caption="State"
                                MaxLength="255" meta:resourcekey="AddressStateResource1" />
                            <ui:UIFieldTextBox runat="server" ID="AddressCity" PropertyName="AddressCity" Caption="City"
                                MaxLength="255" meta:resourcekey="AddressCityResource1" />
                            <ui:UIFieldTextBox runat="server" ID="Address" PropertyName="Address" Caption="Address"
                                MaxLength="255" meta:resourcekey="AddressResource1" />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIFieldDateTime runat="server" ID="DateOfOwnership" PropertyName="DateOfOwnership"
                                Caption="Date of Ownership" ToolTip="The date from which this location was acquired."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="DateOfOwnershipResource1"
                                ShowTimeControls="False" SearchType="Range" />
                            <ui:UIFieldTextBox runat="server" ID="PriceAtOwnership" PropertyName="PriceAtOwnership"
                                SearchType="range" Span="Half" Caption="Price at Ownership ($)" ToolTip="The price of the location when acquired."
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                meta:resourcekey="PriceAtOwnershipResource1" />
                            <ui:UIFieldTextBox runat="server" ID="LifeSpan" PropertyName="LifeSpan" SearchType="range"
                                Span="Half" Caption="Life Span (years)" ToolTip="The life span of this location in years."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="LifeSpanResource1" />
                            <ui:UIFieldTextBox runat="server" ID="GrossFloorArea" PropertyName="GrossFloorArea"
                                SearchType="range" Span="Half" Caption="Gross Floor Area" ValidateDataTypeCheck="True"
                                ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0"
                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" meta:resourcekey="GrossFloorAreaResource1" />
                            <ui:UIFieldTextBox runat="server" ID="NetLettableArea" PropertyName="NetLettableArea"
                                SearchType="range" Span="Half" Caption="Net Lettable Area" ValidateDataTypeCheck="True"
                                ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0"
                                ValidationRangeMax="99999999999999" ValidationRangeType="Currency" meta:resourcekey="NetLettableAreaResource1" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%">
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
                                <ui:UIGridViewBoundColumn PropertyName="FastPath" HeaderText="Location Path"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="LocationType.ObjectName" HeaderText="Location Type"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataFormatString="{0:dd-MMM-yyyy}" PropertyName="DateOfOwnership"
                                    HeaderText="Date of Ownership" meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="GrossFloorArea" HeaderText="Gross Floor Area"
                                    meta:resourcekey="UIGridViewColumnResource7">
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
