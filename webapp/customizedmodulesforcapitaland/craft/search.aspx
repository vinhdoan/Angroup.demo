<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            UIFieldTextBox2.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            UIFieldTextBox3.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            DefaultChargeOut.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            DefaultOTChargeOut.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[4].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[5].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[6].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[7].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="Craft" GridViewID="gridResults"  EditButtonVisible="false"
                BaseTable="tCraft" meta:resourcekey="panelResource1"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox1' PropertyName="ObjectName"
                            Caption="Name" ToolTip="The craft name set as displayed on screen." MaxLength="255"
                            meta:resourcekey="UIFieldTextBox1Resource1" />
                        <br />
                        <br />
                        <br />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox2' PropertyName="NormalHourlyRate"
                            Caption="Normal Rate ($)" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                            ToolTip="The pay per hour (non-overtime) that technicians of the craft receives when working."
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" meta:resourcekey="UIFieldTextBox2Resource1" SearchType="Range" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldTextBox3' PropertyName="OvertimeHourlyRate"
                            Caption="Overtime Rate ($)" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                            ToolTip="The pay per hour (overtime) that technicians of the craft receives when working."
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" meta:resourcekey="UIFieldTextBox3Resource1" SearchType="Range" />
                        <ui:UIFieldTextBox runat='server' ID='DefaultChargeOut' PropertyName="DefaultChargeOut"
                            Caption="Default Charge Out" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" SearchType="Range" />
                        <ui:UIFieldTextBox runat='server' ID='DefaultOTChargeOut' PropertyName="DefaultOTChargeOut"
                            Caption="Default OT Charge Out" Span="Half" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" SearchType="Range" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%">
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
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="NormalHourlyRate" HeaderText="Normal Rate" DataFormatString="{0:#,##0.00}"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="OvertimeHourlyRate" HeaderText="Overtime Rate" DataFormatString="{0:#,##0.00}"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="DefaultChargeOut" HeaderText="Default Charge Out" DataFormatString="{0:#,##0.00}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="DefaultOTChargeOut" HeaderText="Default  OT Charge Out" DataFormatString="{0:#,##0.00}">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
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
