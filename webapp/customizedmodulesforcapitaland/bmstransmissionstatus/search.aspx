<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="BMS Transmission Status" GridViewID="gridResults" EditButtonVisible="false"
               BaseTable="tBMSTransmissionStatus"  SearchType="ObjectQuery"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <%--<ui:UIFieldTextBox runat='server' ID='FileName' PropertyName="FileName" Caption="FileName"
                            MaxLength="255" Span="Full" />--%>
                        <ui:UIFieldDateTime runat="server" PropertyName="BMSDate" Caption="BMS Date"></ui:UIFieldDateTime>
                        <ui:UIFieldRadioList runat="server" PropertyName="Status" Caption="Status" RepeatColumns="3" RepeatDirection="Vertical">
                            <Items>
                                <asp:ListItem Value="" Selected="True">Any</asp:ListItem>
                                <asp:ListItem Value="1">Success</asp:ListItem>
                                <asp:ListItem Value="0">Fail</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldDateTime ID="UIFieldDateTime1" runat="server" PropertyName="SucceededDate" Caption="Succeeded Date"></ui:UIFieldDateTime>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" >
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" >
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                
                                <ui:UIGridViewBoundColumn PropertyName="FileName" HeaderText="File Name">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BMSDate" HeaderText="BMS Date">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StatusText" HeaderText="Status">
                                </ui:UIGridViewBoundColumn>
                               <ui:UIGridViewBoundColumn PropertyName="SucceededDate" HeaderText="Succeeded Date">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject">
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
