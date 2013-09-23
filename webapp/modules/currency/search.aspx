<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Currency" GridViewID="gridResults"
            EditButtonVisible="false" SearchTextBoxHint="E.g.: Currency Name, Description, Currency Symbol"
            AutoSearchOnLoad="true" MaximumNumberOfResults="100" SearchTextBoxPropertyNames="ObjectName,Description,CurrencySymbol"
            AdvancedSearchPanelID="" BaseTable="tCurrency" meta:resourcekey="panelResource1">
        </web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldTextBox runat="server" ID="textCurrencyName" Caption="Currency Abbreviation"
                        PropertyName="ObjectName" ToolTip="Specify the ISO 4217 three-letter currency abbreviation. Examples of currency abbreviations are: USD, AUD, EUR, NZD, RMB, RM, SGD."
                        meta:resourcekey="textCurrencyNameResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" PropertyName="Description"
                        Span="Half" meta:resourcekey="textDescriptionResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textCurrencySymbol" Caption="Currency Symbol"
                        PropertyName="CurrencySymbol" Span="Half" meta:resourcekey="textCurrencySymbolResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" meta:resourcekey="uitabview4Resource1">--%>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="ObjectName"
                        meta:resourcekey="gridResultsResource1">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" CommandName="ViewObject"
                                HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                HeaderText="" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource3">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Currency Abbreviation"
                                meta:resourcekey="UIGridViewBoundColumnResource1">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource2">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CurrencySymbol" HeaderText="Currency Symbol"
                                meta:resourcekey="UIGridViewBoundColumnResource3">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                        <Commands>
                            <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                            </ui:UIGridViewCommand>
                        </Commands>
                    </ui:UIGridView>
                <%--</ui:UITabView>
            </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
