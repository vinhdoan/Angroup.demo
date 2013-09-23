<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

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
            <web:search runat="server" ID="panel" Caption="Equipment Write-Off" GridViewID="gridResults" EditButtonVisible="false"
               BaseTable="tEquipmentWriteOff"  SearchType="ObjectQuery" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' 
                            PropertyName="ObjectNumber" Caption="Equipment Write-Off Number"
                            MaxLength="255" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="UIFieldTextBox1Resource1" />
                        <ui:UIFieldTextBox runat='server' ID='Description' PropertyName="ObjectName" Caption="Description"
                            MaxLength="255" Span="Half" InternalControlWidth="95%" meta:resourcekey="DescriptionResource1" />
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" 
                            meta:resourcekey="gridResultsResource1" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
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
                                 <cc1:UIGridViewBoundColumn DataField="ObjectNumber" 
                                    HeaderText="Equipment Write-Off Number" PropertyName="ObjectNumber" 
                                    ResourceAssemblyName="" SortExpression="ObjectNumber" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourceKey="UIGridViewColumnResource5" PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                    HeaderText="Current Status" PropertyName="CurrentActivity.ObjectName" 
                                    ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" 
                                    SortExpression="CurrentActivity.ObjectName" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserText" 
                                    HeaderText="Assigned User(s)" 
                                    PropertyName="CurrentActivity.AssignedUserText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataField="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    HeaderText="Assigned Position(s)" 
                                    
                                    PropertyName="CurrentActivity.AssignedUserPositionsWithUserNamesText" ResourceAssemblyName="" 
                                    SortExpression="CurrentActivity.AssignedUserPositionsWithUserNamesText" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4">
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
