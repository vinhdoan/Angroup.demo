<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {

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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1"
        BeginningHtml="" EndingHtml="">
        <web:search runat="server" ID="panel" Caption="Survey Planner" GridViewID="gridResults" EditButtonVisible="false"
            SearchType="ObjectQuery" ObjectPanelID="tabSearch" BaseTable="tSurveyPlanner"
            OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1"
                BeginningHtml="" BorderStyle="NotSet" EndingHtml="">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" CssClass="div-form"
                    meta:resourcekey="uitabview3Resource1" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="">
                    <ui:UIFieldTextBox runat="server" ID="SurveyPlannerName" PropertyName="ObjectName"
                        Caption="Survey Planner Name" Width="99%" MaxLength="255" InternalControlWidth="95%"
                        meta:resourcekey="SurveyPlannerNameResource1" />
                    <ui:UIFieldRadioList ID="SurveyType" RepeatColumns="0" RepeatDirection="Vertical" runat="server" Caption="Survey Target Type"
                        PropertyName="SurveyType" meta:resourcekey="SurveyTypeResource1" >
                        <Items>
                            <asp:ListItem Text="Any" Selected="True" meta:resourcekey="ListItemResource1" />
                            <asp:ListItem Value="0" Text="Surveys for Services provided by Contracted Vendors"
                                meta:resourcekey="ListItemResource2" />
                            <asp:ListItem Value="1" Text="Surveys for Services provided by Contracted Vendors evaluated by Managing Agents"
                                meta:resourcekey="ListItemResource3" />
                            <asp:ListItem Value="2" Text="Surveys for Other Reasons" meta:resourcekey="ListItemResource4" />
                        </Items>
                    </ui:UIFieldRadioList>                    
                    <ui:UIFieldDateTime runat="server" ID="PerformancePeriodFrom" PropertyName="PerformancePeriodFrom"
                        Caption="Performance Period To" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                        Width="99%" SearchType="Range" meta:resourcekey="PerformancePeriodFromResource1" />
                    <ui:UIFieldDateTime runat="server" ID="PerformancePeriodTo" PropertyName="PerformancePeriodTo"
                        Caption="Performance Period To" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                        Width="99%" SearchType="Range" meta:resourcekey="PerformancePeriodToResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" CssClass="div-form"
                    meta:resourcekey="uitabview4Resource1" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="">
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                        Width="100%" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" RowErrorColor=""
                        Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete Selected"
                                ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif"
                                meta:resourceKey="UIGridViewCommandResource1" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourceKey="UIGridViewColumnResource1">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                                meta:resourceKey="UIGridViewColumnResource2">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyTypeText" HeaderText="Survey Type" meta:resourcekey="UIGridViewBoundColumnResource1"
                                PropertyName="SurveyTypeText" ResourceAssemblyName="" SortExpression="SurveyTypeText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Survey Planner Name"
                                meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="ObjectName" ResourceAssemblyName=""
                                SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="PerformancePeriodFrom" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Performance Period From" meta:resourcekey="UIGridViewBoundColumnResource4"
                                PropertyName="PerformancePeriodFrom" ResourceAssemblyName="" SortExpression="PerformancePeriodFrom">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="PerformancePeriodTo" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Performance Period To" meta:resourcekey="UIGridViewBoundColumnResource5"
                                PropertyName="PerformancePeriodTo" ResourceAssemblyName="" SortExpression="PerformancePeriodTo">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status"
                                meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="CurrentActivity.ObjectName"
                                ResourceAssemblyName="" ResourceName="Resources.Objects" SortExpression="CurrentActivity.ObjectName">
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
