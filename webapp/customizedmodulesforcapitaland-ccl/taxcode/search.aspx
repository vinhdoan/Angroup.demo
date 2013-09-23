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
            <web:search runat="server" ID="panel" Caption="Tax Code" GridViewID="gridResults" EditButtonVisible="false"
                meta:resourcekey="panelResource1" BaseTable="tTaxCode" 
                AutoSearchOnLoad="true" MaximumNumberOfResults="30" AdvancedSearchPanelID="panelAdvanced"
                SearchTextBoxHint="Tax Code, Description" AdvancedSearchOnLoad="false"
                SearchTextBoxPropertyNames="ObjectName,Description"
                SearchType="ObjectQuery"></web:search>
            <div class="div-form">
                <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTextBox runat='server' ID='ObjectName' PropertyName="ObjectName" Caption="Tax Code"
                            ToolTip="The tax code as displayed on screen." MaxLength="255" Span="Half" meta:resourcekey="ObjectNameResource1" />
                        <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" meta:resourcekey="DescriptionResource1" />--%>
                    <ui:UIFieldTextBox ID="TaxPercentage" runat="server" Caption="Tax (%)" Span="Half" SearchType="Range" ValidateDataTypeCheck='True' ValidationDataType="Currency" meta:resourcekey="TaxPercentageResource1" /><br />
                    <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate" Caption="Valid From:" Span="Half" SearchType="Range"></ui:UIFieldDateTime><br />
                    <ui:UIFieldDateTime runat="server" ID="dateEndDate" PropertyName="EndDate" Caption="Valid Till:" Span="Half" SearchType="Range"></ui:UIFieldDateTime>
                </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">--%>
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" meta:resourcekey="gridResultsResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Tax Code" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Description" HeaderText="Description"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TaxPercentage" HeaderText="Tax (%)" DataFormatString="{0:0.00}"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StartDate" DataFormatString="{0:dd-MMM-yyyy}"></ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="EndDate" DataFormatString="{0:dd-MMM-yyyy}"></ui:UIGridViewBoundColumn>
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
