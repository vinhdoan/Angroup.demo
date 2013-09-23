<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

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
            <web:search runat="server" ID="panel" Caption="Calendar" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tCalendar" meta:resourcekey="panel"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectName"
                            Caption="Calendar Name" ToolTip="The calendar name as displayed on screen." meta:resourcekey="UIFieldTextBox1Resource1"
                            MaxLength="255" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourceKey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" meta:resourceKey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourceKey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Calendar Name"
                                    meta:resourceKey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourceKey="UIGridViewCommandResource1">
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
