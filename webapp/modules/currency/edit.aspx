<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

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
        OCurrency currency = (OCurrency)panel.SessionObject;

        labelERBaseCurrency.Text = OApplicationSetting.Current.BaseCurrency.ObjectName;
        panel.ObjectPanel.BindObjectToControls(currency);
    }


    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCurrency currency = (OCurrency)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(currency);

            // Validate

            // Save
            //
            currency.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Populates the currency exchange rate subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelCurrencyExchangeRate_PopulateForm(object sender, EventArgs e)
    {
        OCurrency currency = panel.SessionObject as OCurrency;
        OCurrencyExchangeRate currencyExchangeRate = subpanelCurrencyExchangeRate.SessionObject as OCurrencyExchangeRate;
        subpanelCurrencyExchangeRate.ObjectPanel.BindObjectToControls(currencyExchangeRate);

        labelERThisCurrency.Text = currency.ObjectName;
    }


    /// <summary>
    /// Validates and inserts the currency exchange rate into
    /// the list of exchange rates.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelCurrencyExchangeRate_ValidateAndUpdate(object sender, EventArgs e)
    {
        // Bind from user interface
        //
        OCurrency currency = panel.SessionObject as OCurrency;
        panel.ObjectPanel.BindControlsToObject(currency);

        OCurrencyExchangeRate currencyExchangeRate = subpanelCurrencyExchangeRate.SessionObject as OCurrencyExchangeRate;
        subpanelCurrencyExchangeRate.ObjectPanel.BindControlsToObject(currencyExchangeRate);

        // Validate
        //
        if (currency.IsDuplicateName())
            objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
        
        if (!currency.ValidateExchangeRateHasNoOverlaps(currencyExchangeRate))
        {
            dateEffectiveStartDate.ErrorMessage = Resources.Errors.Currency_ExchangeRateDateOverlaps;
            dateEffectiveEndDate.ErrorMessage = Resources.Errors.Currency_ExchangeRateDateOverlaps;
        }
        if (!subpanelCurrencyExchangeRate.ObjectPanel.IsValid)
            return;

        // Add to list
        //
        currency.CurrencyExchangeRates.Add(currencyExchangeRate);

        // Bind to user interface
        //
        panel.ObjectPanel.BindObjectToControls(currency);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OCurrency currency = panel.SessionObject as OCurrency;
        OApplicationSetting applicationSetting = OApplicationSetting.Current;

        panelCurrencyExchangeRates.Visible = (applicationSetting.BaseCurrency != null && applicationSetting.BaseCurrencyID != currency.ObjectID);
        panelExchangeRateHint.Visible = (applicationSetting.BaseCurrency == null && applicationSetting.BaseCurrencyID != currency.ObjectID);
        panelExchangeRateCannotBeSetup.Visible = applicationSetting.BaseCurrencyID == currency.ObjectID;
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Currency" BaseTable="tCurrency" OnPopulateForm="panel_PopulateForm"
                OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="Currency Abbreviation" ObjectNameMaxLength="3"
                            ObjectNumberVisible="false" ObjectNameTooltip="Specify the ISO 4217 three-letter currency abbreviation. Examples of currency abbreviations are: USD, AUD, EUR, NZD, RMB, RM, SGD." meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTextBox runat="server" ID="textDescription" MaxLength="255" Caption="Description"
                            ValidateRequiredField="true" PropertyName="Description" meta:resourcekey="textDescriptionResource1"/>
                        <ui:UIFieldTextBox runat="server" ID="textCurrencySymbol" MaxLength="5" Caption="Currency Symbol"
                            ValidateRequiredField="true" PropertyName="CurrencySymbol" Span="half" meta:resourcekey="textCurrencySymbolResource1"/>
                    </ui:UITabView>
                    <ui:UITabView runat='server' ID="tabExchangeRate" Caption="Exchange Rate" meta:resourcekey="tabExchangeRateResource1">
                        <ui:UIPanel runat="server" ID="panelCurrencyExchangeRates" meta:resourcekey="panelCurrencyExchangeRatesResource1">
                            <ui:UIGridView runat="server" ID="gridCurrencyExchangeRate" PropertyName="CurrencyExchangeRates" SortExpression="EffectiveStartDate" Caption="Exchange Rates" meta:resourcekey="gridCurrencyExchangeRateResource1">
                                <Commands>
                                    <ui:UIGridViewCommand CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                    <ui:UIGridViewCommand CommandName="RemoveObject" CommandText="Remove" ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to remove the selected items?" meta:resourcekey="UIGridViewCommandResource2" />
                                </Commands>
                                <Columns>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject" ConfirmText="Are you sure you wish to remove this item?" meta:resourcekey="UIGridViewButtonColumnResource1"></ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" ></ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Effective Start Date" DataFormatString="{0:dd-MMM-yyyy}"
                                        PropertyName="EffectiveStartDate" meta:resourcekey="UIGridViewBoundColumnResource1">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Effective End Date" DataFormatString="{0:dd-MMM-yyyy}"
                                        PropertyName="EffectiveEndDate" meta:resourcekey="UIGridViewBoundColumnResource2">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Exchange Rate" DataFormatString="{0:0.000}" PropertyName="ForeignToBaseExchangeRate" meta:resourcekey="UIGridViewBoundColumnResource3">
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="panelCurrencyExchangeRate" meta:resourcekey="panelCurrencyExchangeRateResource1">
                                <web:subpanel runat="server" ID="subpanelCurrencyExchangeRate" OnPopulateForm="subpanelCurrencyExchangeRate_PopulateForm"
                                    OnValidateAndUpdate="subpanelCurrencyExchangeRate_ValidateAndUpdate" GridViewID="gridCurrencyExchangeRate" meta:resourcekey="subpanelCurrencyExchangeRateResource1" />
                                <ui:UIFieldDateTime runat="server" ID="dateEffectiveStartDate" PropertyName="EffectiveStartDate"
                                    Caption="Effective Start Date" Span="half" ValidateRequiredField="true" ValidateCompareField="true"
                                    ValidationCompareControl="dateEffectiveEndDate" ValidationCompareType="Date"
                                    ValidationCompareOperator="LessThanEqual" meta:resourcekey="dateEffectiveStartDateResource1" />
                                <ui:UIFieldDateTime runat="server" ID="dateEffectiveEndDate" PropertyName="EffectiveEndDate"
                                    Caption="Effective End Date" Span="half" ValidateCompareField="true" ValidationCompareControl="dateEffectiveEndDate"
                                    ValidationCompareType="Date" ValidationCompareOperator="LessThanEqual" meta:resourcekey="dateEffectiveEndDateResource1" />
                                <table cellpadding='0' cellspacing='0' border='0' style="clear:both">
                                    <tr style="height:25px" class='field-required'>
                                        <td style='width:120px'>
                                            <asp:Label runat="server" id="labelExchangeRate" meta:resourcekey="labelExchangeRateResource1">Exchange Rate*:</asp:Label>
                                        </td>
                                        <td>
                                            <asp:Label runat="server" id="labelER1" meta:resourcekey="labelER1Resource1">1</asp:Label>
                                            <asp:Label runat="server" id="labelERThisCurrency" meta:resourcekey="labelERThisCurrencyResource1"></asp:Label>
                                            <asp:Label runat="server" id="labelEREquals" meta:resourcekey="labelEREqualsResource1">is equal to</asp:Label>
                                            <ui:UIFieldTextBox runat="serveR" ID="textExchangeRate" PropertyName="ForeignToBaseExchangeRate"
                                                Caption="Exchange Rate" Span="half" ValidateRequiredField="true" ValidateDataTypeCheck="true" 
                                                ValidationDataType="Currency" FieldLayout="Flow" 
                                                InternalControlWidth="60px" ShowCaption="false" ValidateRangeField="True" 
                                                ValidationRangeMin="0.01" ValidationRangeType="Currency" meta:resourcekey="textExchangeRateResource1" />
                                            <asp:Label runat="server" id="labelERBaseCurrency" meta:resourcekey="labelERBaseCurrencyResource1"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </ui:UIObjectPanel>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelExchangeRateHint">
                            <ui:UIHint runat="server" ID="UIHint1" meta:resourcekey="UIHint1Resource1">
                                The system's base currency has not yet been defined.<br/><br/>
                                Your administrator must specify the system base currency before the exchange rates for foreign currencies can be defined.
                            </ui:UIHint>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelExchangeRateCannotBeSetup" meta:resourcekey="panelExchangeRateCannotBeSetupResource1">
                            <ui:UIHint runat="server" ID="hint1" meta:resourcekey="hint1Resource1">
                                The exchange rate for this currency cannot be set up because it has been defined as the system's base currency.
                            </ui:UIHint>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1">
                        <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments" meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
