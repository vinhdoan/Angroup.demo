<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

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
        OTaxCode taxCode = panel.SessionObject as OTaxCode;
        panel.ObjectPanel.BindObjectToControls(taxCode);
    }


    /// <summary>
    /// Validates and saves the tax code object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OTaxCode taxCode = panel.SessionObject as OTaxCode;
            panel.ObjectPanel.BindControlsToObject(taxCode);

            // Save
            //
            taxCode.Save();
            c.Commit();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Tax Code" BaseTable="tTaxCode" 
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details"
                        meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Tax Code"
                            ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTextBox ID="Description" runat="server" PropertyName="Description" Caption="Description"
                            MaxLength="255" meta:resourcekey="DescriptionResource1" />
                        <ui:UIFieldTextBox ID="TaxPercentage" runat="server" Caption="Tax (%)" Span="Half"
                            PropertyName="TaxPercentage" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                            ValidateRangeField="True" ValidationRangeMax="100" ValidationRangeMin="0" ValidationRangeType="Currency"
                            ValidateRequiredField="True" meta:resourcekey="TaxPercentageResource1"></ui:UIFieldTextBox>
                        <div style="clear:both"></div>
                        <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate" 
                            Caption="Valid From:" ValidateRequiredField="true" Span="Half" 
                            ValidationCompareControl="dateStartDate" 
                            ValidationCompareOperator="GreaterThanEqual"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="dateEndDate" PropertyName="EndDate" 
                            Caption="Valid Till:" Span="Half" ValidateCompareField="True" 
                            ValidationCompareControl="dateStartDate" 
                            ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date"></ui:UIFieldDateTime>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
