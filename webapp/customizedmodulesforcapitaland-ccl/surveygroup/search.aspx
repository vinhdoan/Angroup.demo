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
        <web:search runat="server" ID="panel" Caption="Survey Service Level" GridViewID="gridResults" EditButtonVisible="false"
            AutoSearchOnLoad="true" MaximumNumberOfResults="300" 
            SearchTextBoxPropertyNames="ObjectName,SurveyChecklist.ObjectName" AdvancedSearchPanelID=""
            SearchTextBoxHint="Tenant Name, Contact Information, DID, Cellphone, etc..."
            BaseTable="tSurveyServiceLevel" meta:resourcekey="panelResource1"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="uitabview3Resource1">--%>
                    <%--<ui:UIFieldTextBox runat="server" ID="searchSurveyGroupName" PropertyName="ObjectName"
                        Caption="Survey Group Name" InternalControlWidth="95%" meta:resourcekey="searchSurveyGroupNameResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldRadioList runat="server" ID="SurveyContractedVendor" PropertyName="SurveyContractedVendor"
                        CaptionWidth="450" Caption="Surveys for Services provided by Contract Vendors"
                        meta:resourcekey="SurveyContractedVendorResource1" TextAlign="Right" RepeatColumns="0"
                        RepeatDirection="Horizontal">
                        <Items>
                            <asp:ListItem Text="Yes" Value="1" meta:resourcekey="ListItemResource1"></asp:ListItem>
                            <asp:ListItem Text="No" Value="0" meta:resourcekey="ListItemResource2"></asp:ListItem>
                            <asp:ListItem Text="Any" Value="" Selected="True" meta:resourcekey="ListItemResource3"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldRadioList runat="server" ID="SurveyContractedVendorEvaluatedByMA" PropertyName="SurveyContractedVendorEvaluatedByMA"
                        Caption="Surveys for Services provided by Contract Vendors evaluated by Managing Agents"
                        meta:resourcekey="SurveyContractedVendorEvaluatedByMAResource1" CaptionWidth="450"
                        TextAlign="Right" RepeatColumns="0" RepeatDirection="Horizontal">
                        <Items>
                            <asp:ListItem Text="Yes" Value="1" meta:resourcekey="ListItemResource4"></asp:ListItem>
                            <asp:ListItem Text="No" Value="0" meta:resourcekey="ListItemResource5"></asp:ListItem>
                            <asp:ListItem Text="Any" Value="" Selected="True" meta:resourcekey="ListItemResource6"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldRadioList runat="server" ID="SurveyOthers" PropertyName="SurveyOthers"
                        Caption="Surveys for Other Reasons" meta:resourcekey="SurveyOthersResource1"
                        CaptionWidth="450" TextAlign="Right" RepeatColumns="0" RepeatDirection="Horizontal">
                        <Items>
                            <asp:ListItem Text="Yes" Value="1" meta:resourcekey="ListItemResource7"></asp:ListItem>
                            <asp:ListItem Text="No" Value="0" meta:resourcekey="ListItemResource8"></asp:ListItem>
                            <asp:ListItem Text="Any" Value="" Selected="True" meta:resourcekey="ListItemResource9"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldRadioList runat="server" ID="ContractMandatory" PropertyName="ContractMandatory"
                        Caption="Contract Mandatory" meta:resourcekey="ContractMandatoryResource1" CaptionWidth="450"
                        TextAlign="Right" RepeatColumns="0" RepeatDirection="Horizontal">
                        <Items>
                            <asp:ListItem Text="Yes" Value="1" meta:resourcekey="ListItemResource10"></asp:ListItem>
                            <asp:ListItem Text="No" Value="0" meta:resourcekey="ListItemResource11"></asp:ListItem>
                            <asp:ListItem Text="Any" Value="" Selected="True" meta:resourcekey="ListItemResource12"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>--%>
                <%--</ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="uitabview4Resource1">--%>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%"
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridResultsResource1"
                        RowErrorColor="" Style="clear: both;">
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
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Service Level Name"
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" ResourceAssemblyName=""
                                SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyChecklist.ObjectName" HeaderText="Default Survey Checklist"
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="SurveyChecklist.ObjectName"
                                ResourceAssemblyName="" SortExpression="SurveyChecklist.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreatedUser" HeaderText="Created User"
                                meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="CreatedUser"
                                ResourceAssemblyName="" SortExpression="CreatedUser">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                <%--</ui:UITabView>
            </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
