<%@ Page Language="C#" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
</head>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OPointTariff p = panel.SessionObject as OPointTariff;

        dropLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, p.LocationID));
        dropTypeOfMeter.Bind(OCode.GetCodesByType("AmosMeterType", p.TypeOfMeterID));
        
        panel.ObjectPanel.BindObjectToControls(p);
    }

    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OPointTariff p = panel.SessionObject as OPointTariff;

        panel.ObjectPanel.BindControlsToObject(p);

        // Validate
        //
        if (!p.ValidateNoDuplicateLocation())
            dropLocation.ErrorMessage = Resources.Errors.PointTariff_DuplicateLocation;

        if (!panel.ObjectPanel.IsValid)
            return;

        p.Save();
    }

    protected void rdlIsAllTos_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
</script>

<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Point Tariff" BaseTable="tPointTariff"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave"
            meta:resourcekey="panelResource1" SavingConfirmationText="Are you sure you want to save the tariff and discount? The tariffs and the discounts for all ACTIVE and UNLOCKED Points at and under this Location will be updated as well!">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <!--Tab Detail-->
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" Height="267px" BorderStyle="NotSet"
                    meta:resourcekey="tabDetailsResource1">
                    <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNameValidateRequiredField="true"
                        ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:uifielddropdownlist runat="server" id="dropLocation" Caption="Building" PropertyName="LocationID"
                        validaterequiredfield="True" meta:resourcekey="dropLocationResource1">
                    </ui:uifielddropdownlist>
                    <ui:UIFieldTextBox runat="server" ID="textTariff" PropertyName="DefaultTariff" Caption="Tariff"
                        Span="Half" ValidateRangeField="True" ValidationRangeMin="0"
                        ValidateRequiredField="True" ValidateDataTypeCheck="True" 
                        ValidationDataType="Currency" InternalControlWidth="95%" 
                        meta:resourcekey="textTariffResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textDiscount" PropertyName="DefaultDiscount"
                        Caption="Discount %" Span="Half" ValidateRangeField="True" 
                        ValidationRangeMin="0" ValidationRangeMax="100" ValidateRequiredField="True"
                        ValidateDataTypeCheck="True" ValidationDataType="Currency" 
                        InternalControlWidth="95%" meta:resourcekey="textDiscountResource1" />
                     <ui:UIFieldDropDownList runat="server" ID="dropTypeOfMeter" Caption="Type Of Meter" 
                        PropertyName="TypeOfMeterID" ValidateRequiredField="true" Span="Half">
                     </ui:UIFieldDropDownList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" BorderStyle="NotSet"
                    meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
