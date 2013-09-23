<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource2" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Tenant Activity" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tTenantActivity" meta:resourcekey="panelResource1" SearchType="ObjectQuery">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" BorderStyle="NotSet" meta:resourcekey="uitabview3Resource2" >
                        <ui:uifielddatetime runat="server" id="dateDateTimeOfActivity" PropertyName="DateTimeOfActivity" Caption="Date" SearchType="Range" meta:resourcekey="dateDateTimeOfActivityResource2" ShowDateControls="True"></ui:uifielddatetime>
                        <ui:uifieldtextbox runat="server" id="textTenant" PropertyName="Tenants.ObjectName" CAption="Tenant" InternalControlWidth="95%" meta:resourcekey="textTenantResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textNameOfStaff" PropertyName="NameOfStaff" CAption="Name of Staff" InternalControlWidth="95%" meta:resourcekey="textNameOfStaffResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textAgenda" PropertyName="Agenda" CAption="Agenda" InternalControlWidth="95%" meta:resourcekey="textAgendaResource2"></ui:uifieldtextbox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" BorderStyle="NotSet" meta:resourcekey="uitabview4Resource2" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID" GridLines="Both"  meta:resourcekey="gridResultsResource1" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="DateTimeOfActivity" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Date/Time" meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="DateTimeOfActivity" ResourceAssemblyName="" SortExpression="DateTimeOfActivity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ActivityType.ObjectName" HeaderText="Activity Type" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="ActivityType.ObjectName" ResourceAssemblyName="" SortExpression="ActivityType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="NameOfStaff" HeaderText="Name of Staff" meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="NameOfStaff" ResourceAssemblyName="" SortExpression="NameOfStaff">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Agenda" HeaderText="Agenda" meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="Agenda" ResourceAssemblyName="" SortExpression="Agenda">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                               
                                <cc1:UIGridViewBoundColumn HeaderText="Tenant Names" DataField="TenantNames"   PropertyName="TenantNames" ResourceAssemblyName="" SortExpression="TenantNames" >
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
