<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCraft craft = panel.SessionObject as OCraft;
        panel.ObjectPanel.BindObjectToControls(craft);

        if (!IsPostBack)
        {
            NormalHourlyRate.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            OvertimeHourlyRate.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            DefaultChargeOut.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            DefaultOTChargeOut.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
    }


    /// <summary>
    /// Validates and saves the craft object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCraft craft = (OCraft)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(craft);

            // Validate
            //
            if (craft.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            craft.Save();
            c.Commit();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Craft" BaseTable="tCraft" OnPopulateForm="panel_PopulateForm"
                meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTextBox ID="NormalHourlyRate" runat="server" 
                            Caption="Normal Rate" DataFormatString="{0:#,##0.00}"
                            PropertyName="NormalHourlyRate" Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True"
                            ValidationDataType="Currency" ToolTip="The pay per hour (non-overtime) that technicians of this craft receives when working."
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" 
                            meta:resourcekey="NormalHourlyRateResource1" 
                            ValidationCompareOperator="GreaterThanEqual" />
                        <ui:UIFieldTextBox ID="OvertimeHourlyRate" runat="server" 
                            Caption="Overtime Rate" DataFormatString="{0:#,##0.00}"
                            PropertyName="OvertimeHourlyRate" Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True"
                            ValidationDataType="Currency" ToolTip="The pay per hour (overtime) that technicians of this craft receives when working."
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency" 
                            meta:resourcekey="OvertimeHourlyRateResource1" ValidateCompareField="True" 
                            ValidationCompareControl="NormalHourlyRate" 
                            ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Currency" />
                        <ui:UIFieldTextBox ID="DefaultChargeOut" runat="server" 
                            Caption="Default Charge Out" DataFormatString="{0:#,##0.00}"
                            PropertyName="DefaultChargeOut" Span="Half" ValidateDataTypeCheck="True"
                            ValidationDataType="Currency"
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency"/>
                        <ui:UIFieldTextBox ID="DefaultOTChargeOut" runat="server" 
                            Caption="Default OT Charge Out" DataFormatString="{0:#,##0.00}"
                            PropertyName="DefaultOTChargeOut" Span="Half" ValidateDataTypeCheck="True"
                            ValidationDataType="Currency"
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                            ValidationRangeType="Currency"/>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
