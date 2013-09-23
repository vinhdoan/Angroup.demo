<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

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
    <ui:UIObjectPanel runat="server" ID="panelMain" BeginningHtml="" BorderStyle="NotSet"
        EndingHtml="" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Survey Respondent" GridViewID="gridResults" EditButtonVisible="false"
            BaseTable="tSurveyRespondent" meta:resourcekey="panelResource1"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldTextBox runat="server" ID="SurveyRespondentName" PropertyName="ObjectName"
                        Caption="Survey Respondent Name" Width="99%" MaxLength="255" InternalControlWidth="95%"
                        meta:resourcekey="SurveyRespondentNameResource1" />
                    <ui:UIFieldDropDownList runat="server" ID="SurveyType" PropertyName="SurveyRespondentPortfolios.SurveyType"
                        Caption="Survey Type" meta:resourcekey="SurveyTypeResource1">
                        <Items>
                            <asp:ListItem meta:resourcekey="ListItemResource1" />
                            <asp:ListItem Value="0" Text="Surveys for Services provided by Contracted Vendors"
                                meta:resourcekey="ListItemResource2" />
                            <asp:ListItem Value="1" Text="Surveys for Services provided by Contracted Vendors evaluated by Managing Agents"
                                meta:resourcekey="ListItemResource3" />
                            <asp:ListItem Value="2" Text="Surveys for Other Reasons" meta:resourcekey="ListItemResource4" />
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="Email" PropertyName="SurveyRespondentPortfolios.EmailAddress"
                        Caption="Survey Respondent Email" InternalControlWidth="95%" meta:resourcekey="EmailResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="uitabview4Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID"
                        GridLines="Both" meta:resourcekey="gridResultsResource1" RowErrorColor="" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete Selected"
                                ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif"
                                meta:resourcekey="UIGridViewCommandResource1" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Survey Respondent Name"
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" ResourceAssemblyName=""
                                SortExpression="ObjectName">
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
