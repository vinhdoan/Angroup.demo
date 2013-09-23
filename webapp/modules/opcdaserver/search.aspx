<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="OPC DA Server" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tOPCDAServer" SearchType="ObjectQuery" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTextBox runat="server" ID="textObjectName" Caption="Server Name" 
                            PropertyName="ObjectName" InternalControlWidth="95%" 
                            meta:resourcekey="textObjectNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat="server" ID="radioAutomaticPollingEnabled" 
                            Caption="Polling Enabled" PropertyName="AutomaticPollingEnabled" 
                            RepeatColumns="0" meta:resourcekey="radioAutomaticPollingEnabledResource1" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1">Any</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Yes</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource3">No</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Server Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AutomaticPollingEnabledText" 
                                    HeaderText="Polling Enabled" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="AutomaticPollingEnabledText" ResourceAssemblyName="" 
                                    SortExpression="AutomaticPollingEnabledText">
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
