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

    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        
        //ddlLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, null));

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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1"
        BeginningHtml="" EndingHtml="">
        <web:search runat="server" ID="panel" Caption="Survey Planner" GridViewID="gridResults" EditButtonVisible="false"
            SearchType="ObjectQuery" ObjectPanelID="tabSearch" BaseTable="tSurveyPlanner"
            AutoSearchOnLoad="true" MaximumNumberOfResults="300" 
            SearchTextBoxPropertyNames="ObjectName,SurveyPlannerRespondents.SurveyRespondent.EmailAddress,SurveyFormTitle1,SurveyFormTitle2,SurveyFormDescription" AdvancedSearchPanelID="panelAdvanced"
            SearchTextBoxHint="Name, Survey Form Title1, Survey Form Description"
            OnSearch="panel_Search" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1"
                BeginningHtml="" BorderStyle="NotSet" EndingHtml="">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" CssClass="div-form"
                    meta:resourcekey="uitabview3Resource1" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="">--%>
                <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                    <%--<ui:UIFieldTextBox runat="server" ID="textSurveyPlannerNumber" PropertyName="ObjectNumber"
                        Caption="SP Number" MaxLength="255" Span="Half">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="SurveyPlannerName" PropertyName="ObjectName"
                        Caption="SP Name" MaxLength="255" Span="Half">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat="server" ID="ddlLocation" Caption="Location" PropertyName="LocationID" Span="Full">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldRadioList runat="server" ID="radioSurveyTargetType" PropertyName="SurveyTargetType"
                        Caption="Survey Target Type" Width="100%"
                        RepeatColumns="0" RepeatLayout="Flow" RepeatDirection="Vertical"
                        meta:resourcekey="SurveyTypeResource1">
                        <Items>
                            <asp:ListItem Value="" Text="Any" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="0" Text="Tenant Surveys"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Service Surveys for Non Contracted Vendors"></asp:ListItem>
                            <asp:ListItem Value="2" Text="Service Surveys for Contracted Vendors"></asp:ListItem>
                            <asp:ListItem Value="3" Text="Surveys for other reasons"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <br />--%>
                    <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                        Caption="Status" meta:resourcekey="listStatusResource1">
                    </ui:UIFieldListBox>
                </ui:UIPanel>
                <%--</ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" CssClass="div-form"
                    meta:resourcekey="uitabview4Resource1" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="">--%>
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
                            <%--<cc1:UIGridViewBoundColumn DataField="SurveyTargetTypeText" HeaderText="Survey Target Type" meta:resourcekey="UIGridViewBoundColumnResource1"
                                PropertyName="SurveyTargetTypeText" ResourceAssemblyName="" SortExpression="SurveyTargetTypeText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Survey Planner Number"
                                PropertyName="ObjectNumber" ResourceAssemblyName=""
                                SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name"
                                PropertyName="ObjectName" ResourceAssemblyName=""
                                SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyFormTitle1" HeaderText="Survey Form Title"
                                PropertyName="SurveyFormTitle1" ResourceAssemblyName=""
                                SortExpression="SurveyFormTitle1">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ValidStartDate" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Valid From"
                                PropertyName="ValidStartDate" ResourceAssemblyName="" SortExpression="ValidStartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ValidEndDate" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Valid To"
                                PropertyName="ValidEndDate" ResourceAssemblyName="" SortExpression="ValidEndDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status"
                                meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="CurrentActivity.ObjectName"
                                ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
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
