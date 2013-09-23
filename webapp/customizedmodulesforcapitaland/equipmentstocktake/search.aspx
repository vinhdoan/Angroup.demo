<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        
    }

    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Equipment Stock Take" GridViewID="gridResults" EditButtonVisible="false" meta:resourcekey="panelResource1"
            ObjectPanelID="tabSearch" BaseTable="tLocationStockTake" AssignedCheckboxVisible="true" OnSearch="panel_Search" SearchType="ObjectQuery" OnPopulateForm="panel_PopulateForm"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" 
                meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    CssClass="div-form" meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                    <ui:UIFieldTextBox ID="ObjectNumber" runat="server" Caption="Stock Take Number" PropertyName="ObjectNumber"
                            InternalControlWidth="95%" meta:resourcekey="ObjectNumberResource1" />
                    <ui:UIFieldDateTime runat="server" ID="LocationStockTakeStartDateTime" PropertyName="LocationStockTakeStartDateTime"
                            Caption="Start Date" ToolTip="Start of Stock Take"
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="LocationStockTakeStartDateSearchTimeResource1"
                            SearchType="Range" ShowDateControls="True" />
                    <ui:UIFieldDateTime runat="server" ID="LocationStockTakeEndDateTime" PropertyName="LocationStockTakeEndDateTime"
                            Caption="End Date" ToolTip="End Of Stock Take"
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="LocationStockTakeEndDateSearchTimeResource1"
                            SearchType="Range" ShowDateControls="True" />
                    <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                            Caption="Status" meta:resourcekey="listStatusResource1" ></ui:UIFieldListBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    CssClass="div-form" meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                    <ui:UIGridView runat="server" ID="gridResults" BindObjectsToRows="True" KeyName="ObjectID"
                        Width="100%" AjaxPostBack="False" IsModifiedByAjax="False" 
                        SortExpression="ObjectNumber desc" meta:resourcekey="gridResultsResource1" 
                        DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                        style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="DeleteObject" CommandText="Delete Selected" 
                                ConfirmText="Are you sure you wish to delete the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                        </commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewBoundColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewBoundColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                ConfirmText="Are you sure you wish to delete this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourceKey="UIGridViewBoundColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="ObjectNumber"
                                HeaderText="Stockt Take Number" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="ObjectNumber" 
                                ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <ControlStyle Width="10px" />
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Reason"
                                HeaderText="Reason" PropertyName="Reason" 
                                ResourceAssemblyName="" SortExpression="Reason" meta:resourcekey="UIGridViewBoundColumnResource5">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LocationStockTakeStartDateTime" 
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Start Date" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" 
                                PropertyName="LocationStockTakeStartDateTime" ResourceAssemblyName="" 
                                SortExpression="LocationStockTakeStartDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LocationStockTakeEndDateTime" 
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="End Date" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" 
                                PropertyName="LocationStockTakeEndDateTime" ResourceAssemblyName="" 
                                SortExpression="LocationStockTakeEndDateTime">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource8" 
                                PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                ResourceName="Resources.WorkflowStates" 
                                SortExpression="CurrentActivity.ObjectName">
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
