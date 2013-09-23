<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Drawing" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Registers the upload button to do a full postback.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        ScriptManager.RegisterPostBackControl(buttonUploadFile);
    }


    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OApplicationSetting applicationSetting = (OApplicationSetting)panel.SessionObject;

        AssetLocationTypeID.PopulateTree();
        LevelLocationTypeID.PopulateTree();
        SuiteLocationTypeID.PopulateTree();
        
        dropBaseCurrency.Bind(OCurrency.GetAllCurrencies());
        dropEquipmentUnitOfMeasure.Bind(OCode.GetCodesByType("UnitOfMeasure", applicationSetting.EquipmentUnitOfMeasureID));
        TenantContactTypeID.Bind(OCode.GetCodesByType("TenantContactType", null));
        dropDefaultTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", null));
        dropDefaultScheduledWorkTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", null));
        dropGeneralDefaultUnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", applicationSetting.EquipmentUnitOfMeasureID));
        DefaultChargeTypeID.Bind(OChargeType.GetChargeTypeList());
        panel.ObjectPanel.BindObjectToControls(applicationSetting);
        DefaultUnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        DefaultMeterTypeID.Bind(OCode.GetCodesByType("AmosMeterType",null));

        panel.ObjectPanel.BindObjectToControls(applicationSetting);
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
            OApplicationSetting applicationSetting = (OApplicationSetting)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(applicationSetting);

            if (textMessageSmtpServerPassword.Text != "")
                applicationSetting.MessageSmtpServerPassword = Security.Encrypt(textMessageSmtpServerPassword.Text);
            if (EmailPassword.Text != "")
                applicationSetting.EmailPassword = Security.Encrypt(EmailPassword.Text);

            if (applicationSetting.IsWJDateDefaulted == 1)
            {
                if (applicationSetting.DefaultRequiredUnit >= applicationSetting.DefaultEndUnit &&
                    applicationSetting.DefaultRequiredCount > applicationSetting.DefaultEndCount)
                    DefaultRequiredCount.ErrorMessage = Resources.Errors.Capitaland_ApplicationSetting_InvalidWJDate;
                else
                {
                    int minRequiredUnit = 1;
                    int maxEndUnit = 1;
                    
                    switch (applicationSetting.DefaultRequiredUnit)
                    {
                        case 0:
                            minRequiredUnit = 1;
                            break;
                        case 1:
                            minRequiredUnit = 7;
                            break;
                        case 2:
                            minRequiredUnit = 28;
                            break;
                        case 3:
                            minRequiredUnit = 365;
                            break;
                    }

                    switch (applicationSetting.DefaultEndUnit)
                    {
                        case 0:
                            maxEndUnit = 1;
                            break;
                        case 1:
                            maxEndUnit = 7;
                            break;
                        case 2:
                            maxEndUnit = 31;
                            break;
                        case 3:
                            maxEndUnit = 366;
                            break;
                    }

                    if (minRequiredUnit * applicationSetting.DefaultRequiredCount > maxEndUnit * applicationSetting.DefaultEndCount)
                        DefaultRequiredCount.ErrorMessage = Resources.Errors.Capitaland_ApplicationSetting_InvalidWJDate;
                }
                    
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            applicationSetting.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelEmail.Visible = checkEnableEmail.Checked;
        panelReceiveEmail.Visible = EnableReceiveEmail.Checked;
        if (checkEnableSMS.Checked)
        {
            SMSSendType.Visible = checkEnableSMS.Checked;
            panelSMS.Visible = (SMSSendType.SelectedValue == "0");
            SMSRelayWSURL.Visible = (SMSSendType.SelectedValue == "1");
        }
        else
        {
            panelSMS.Visible = checkEnableSMS.Checked;
            SMSSendType.Visible = checkEnableSMS.Checked;
            SMSRelayWSURL.Visible = checkEnableSMS.Checked;
        }

        textMessageSmtpServerUserName.Visible =
            textMessageSmtpServerPassword.Visible =
            checkMessageSmtpRequiresAuthentication.Checked;

        panelWJDate.Visible = IsWJDateDefaulted.Checked;
        DefaultRequiredCount.ValidateRequiredField = IsWJDateDefaulted.Checked;
        DefaultRequiredUnit.ValidateRequiredField = IsWJDateDefaulted.Checked;
        DefaultEndCount.ValidateRequiredField = IsWJDateDefaulted.Checked;
        DefaultEndUnit.ValidateRequiredField = IsWJDateDefaulted.Checked;

        EmailServer.Visible = (EmailServerType.SelectedValue == "0");
        EmailPort.Visible = (EmailServerType.SelectedValue == "0");
        EmailExchangeWebServiceUrl.Visible = (EmailServerType.SelectedValue == "1");
        EmailDomain.Visible = (EmailServerType.SelectedValue == "1");
    }


    /// <summary>
    /// Occurs when the user selects the Enable Email checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkEnableEmail_CheckedChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects the Enable SMS checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkEnableSMS_CheckedChanged(object sender, EventArgs e)
    {

    }
    
    /// <summary>
    /// Occrus when the user change the Incoming email server type
    /// </summary>
    protected void EmailServerType_SelectedIndexChanged(object sender, EventArgs e)
    { 
    
    }

    /// <summary>
    /// Performs action.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridSmsKeywordHandlers_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "AddRow")
        {
            OApplicationSettingSmsKeywordHandler handler = TablesLogic.tApplicationSettingSmsKeywordHandler.Create();
            OApplicationSetting applicationSetting = panel.SessionObject as OApplicationSetting;
            panel.ObjectPanel.BindControlsToObject(applicationSetting);
            applicationSetting.ApplicationSettingSmsKeywordHandlers.Add(handler);
            panel.ObjectPanel.BindObjectToControls(applicationSetting);
        }
    }


    /// <summary>
    /// Receives the uploaded file from the file input control.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUploadFile_Click(object sender, EventArgs e)
    {
        OApplicationSetting applicationSetting = panel.SessionObject as OApplicationSetting;
        panel.ObjectPanel.BindControlsToObject(applicationSetting);
        panel.Message = "";
        fileLoginLogo.ErrorMessage = "";

        try
        {
            System.Drawing.Image i = Bitmap.FromStream(fileLoginLogo.PostedFile.InputStream);

            if (!fileLoginLogo.PostedFile.FileName.ToUpper().EndsWith(".JPG") &&
                !fileLoginLogo.PostedFile.FileName.ToUpper().EndsWith(".GIF") &&
                !fileLoginLogo.PostedFile.FileName.ToUpper().EndsWith(".PNG"))
                throw new Exception();

            if (i.Width != 600 && i.Height != 400)
            {
                panel.Message = Resources.Errors.ApplicationSettings_ResolutionIncorrect;
                fileLoginLogo.ErrorMessage = Resources.Errors.ApplicationSettings_ResolutionIncorrect;
                return;
            }
        }
        catch (Exception ex)
        {
            panel.Message = Resources.Errors.ApplicationSettings_LoginLogoIcorrectFormat;
            fileLoginLogo.ErrorMessage = Resources.Errors.ApplicationSettings_LoginLogoIcorrectFormat;
            return;
        }
        panel.Message = Resources.Messages.ApplicationSettings_LogoUploaded;
        applicationSetting.LoginLogo = fileLoginLogo.FileBytes;
        panel.ObjectPanel.BindObjectToControls(applicationSetting);
    }


    /// <summary>
    /// Occurs when the user clicks on any button in the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridServices_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "AddRow")
        {
            OApplicationSettingService service = TablesLogic.tApplicationSettingService.Create();
            OApplicationSetting applicationSetting = panel.SessionObject as OApplicationSetting;
            panel.ObjectPanel.BindControlsToObject(applicationSetting);
            applicationSetting.ApplicationSettingServices.Add(service);
            panel.ObjectPanel.BindObjectToControls(applicationSetting);
        }
    }

    protected void SMSSendType_SelectedIndexChanged(object sender, EventArgs e)
    {
        panelSMS.Visible = (SMSSendType.SelectedValue == "0");
        SMSRelayWSURL.Visible = (SMSSendType.SelectedValue == "1");
    }

    protected void IsWJDateDefaulted_CheckedChanged(object sender, EventArgs e)
    {

    }
    protected void EnableReceiveEmail_CheckedChanged(object sender, EventArgs e)
    {
    }
    /// <summary>
    /// Constructs and returns the location type tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater AssetLocationTypeID_AcquireTreePopulater(object sender)
    {
        return new LocationTypePopulater(null, true, true);
    }
    /// <summary>
    /// Constructs and returns the location type tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater LevelLocationTypeID_AcquireTreePopulater(object sender)
    {
        return new LocationTypePopulater(null, true, true);
    }
    /// <summary>
    /// Constructs and returns the location type tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater SuiteLocationTypeID_AcquireTreePopulater(object sender)
    {
        return new LocationTypePopulater(null, true, true);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Application Settings" BaseTable="tApplicationSetting"
            CloseWindowButtonVisible="false" DeleteButtonVisible="false" SaveAndCloseButtonVisible="false"
            SaveAndNewButtonVisible="false" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabApplication" runat="server" Caption="Application"
                    BorderStyle="NotSet" meta:resourcekey="tabApplicationResource1">
                    <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberVisible="false" />
                    <ui:UIFieldTextBox runat="server" ID="SystemUrl" PropertyName="SystemUrl" 
                        Caption="System Url" MaxLength="255"
                    meta:resourcekey="SystemUrlresource1" InternalControlWidth="95%"></ui:UIFieldTextBox>
                    <ui:UISeparator runat="server" ID="sep1" Caption="Password Policy" meta:resourcekey="sep1Resource1" />
                    <ui:UIFieldRadioList runat="server" ID="radioPasswordRequiredCharacters" PropertyName="PasswordRequiredCharacters"
                        CaptionWidth="180px" Caption="Password Complexity" ValidateRequiredField="True"
                        meta:resourcekey="radioPasswordRequiredCharactersResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" 
                                Text="No restriction"></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" 
                                Text="Must contain at least one alphabet, and one numeric character"></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" 
                                Text="Must contain at least one alphabet, one numeric character and one special character (eg. ~ ! @ # $ % etc)"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldTextBox runat="server" ID="textPasswordMinimumLength" Span="Half" PropertyName="PasswordMinimumLength"
                        CaptionWidth="180px" Caption="Minimum Length" ToolTip="Sets the minimum length for users' passwords in the system. Leave this blank to indicate that there will be no restriction."
                        ValidateRangeField="True" ValidationRangeMin="1" ValidationRangeType="Integer"
                        InternalControlWidth="95%" meta:resourcekey="textPasswordMinimumLengthResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textPasswordMaximumTries" Span="Half" PropertyName="PasswordMaximumTries"
                        CaptionWidth="180px" Caption="Maximum Tries" ToolTip="Sets the maximum number of log in tries before a user is locked out of his account. Leave this blank to indicate that there will be no restriction."
                        ValidateRangeField="True" ValidationRangeMin="1" ValidationRangeType="Integer"
                        InternalControlWidth="95%" meta:resourcekey="textPasswordMaximumTriesResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textPasswordMinimumAge" Span="Half" PropertyName="PasswordMinimumAge"
                        CaptionWidth="180px" Caption="Minimum Password Age (Days)" ToolTip="Sets the minimum number of days after the password was changed before it can be changed again. Leave this blank to indicate that there will be no restriction."
                        ValidateRangeField="True" ValidationRangeMin="1" ValidationRangeType="Integer"
                        InternalControlWidth="95%" meta:resourcekey="textPasswordMinimumAgeResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textPasswordHistoryKept" Span="Half" PropertyName="PasswordHistoryKept"
                        CaptionWidth="180px" Caption="Password History" ToolTip="Sets the number of previous passwords that the users to change their new passwords to. Leave this blank to indicate that there will be no restriction."
                        ValidateRangeField="True" ValidationRangeMin="1" ValidationRangeType="Integer"
                        InternalControlWidth="95%" meta:resourcekey="textPasswordHistoryKeptResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textPasswordDaysToExpiry" Span="Half" PropertyName="PasswordDaysToExpiry"
                        CaptionWidth="180px" Caption="Password Expiry (Days)" ToolTip="Sets the number each password is valid for before it expires. Leave this blank to indicate that there will be no restriction."
                        ValidateRangeField="True" ValidationRangeMin="1" ValidationRangeType="Integer"
                        InternalControlWidth="95%" meta:resourcekey="textPasswordDaysToExpiryResource1" />
                    <ui:UIFieldCheckBox runat="server" ID="cbIsUserEmailCompulsory" Caption="Is User's Email compulsory" PropertyName="IsUserEmailCompulsory" meta:resourcekey="cbIsUserEmailCompulsoryResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                    <ui:UISeparator runat="server" ID="UISeparator2" Caption="Historical Data" meta:resourcekey="UISeparator2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textNumberOfDaysToKeepMessageHistory" Span="Half"
                        PropertyName="NumberOfDaysToKeepMessageHistory" Caption="Number of Days to Keep Message History"
                        CaptionWidth="250px" ValidateRequiredField="True" InternalControlWidth="95%"
                        meta:resourcekey="textNumberOfDaysToKeepMessageHistoryResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="textNumberOfDaysToKeepLoginHistory" Span="Half"
                        PropertyName="NumberOfDaysToKeepLoginHistory" Caption="Number of Days to Keep Login History"
                        CaptionWidth="250px" ValidateRequiredField="True" InternalControlWidth="95%"
                        meta:resourcekey="textNumberOfDaysToKeepLoginHistoryResource1">
                    </ui:UIFieldTextBox>
                    <ui:UISeparator runat="server" ID="UISeparator1" Caption="Currency Setting" meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="dropBaseCurrency" Caption="Base Currency"
                        PropertyName="BaseCurrencyID" Span="Half" ValidateRequiredField="True" meta:resourcekey="dropBaseCurrencyResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldRadioList ID="radioAllowChangeOfExchangeRate" Caption="Global Exchange Rate"
                     PropertyName="AllowChangeOfExchangeRate" runat="server" TextAlign="Right" 
                        meta:resourcekey="radioAllowChangeOfExchangeRateResource1">
                     <Items>
                     <asp:ListItem  Value="0" meta:resourcekey="ListItemResource71">Do not allow user to modify the exchange rate in a purchase document,
                     if the exchange rate is set up in the Currency module.</asp:ListItem>
                     <asp:ListItem Value="1" meta:resourcekey="ListItemResource72">Allow user to modify the exchange rate in a purchase document,
                     if the exchange rate is set up in the Currency module.</asp:ListItem>
                     </Items>
                     </ui:UIFieldRadioList>
                    <ui:UISeparator runat="server" ID="UISeparator6" Caption="Work" meta:resourcekey="UISeparator6Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="dropDefaultTypeOfWork" PropertyName="DefaultTypeOfWorkID"
                        Caption="Default Type of Work" CaptionWidth="210px" 
                        meta:resourcekey="dropDefaultTypeOfWorkResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="dropDefaultScheduledWorkTypeOfWork" PropertyName="DefaultScheduledWorkTypeOfWorkID"
                        Caption="Default Type of Work (Scheduled Work)" CaptionWidth="210px"
                        meta:resourcekey="dropDefaultScheduledWorkTypeOfWorkResource1">
                    </ui:UIFieldDropDownList>
                    <table cellpadding='1' cellspacing='0' border='0' style="width: 100%; height: 24px">
                        <tr class="field-required">
                            <td style="width: 120px">
                                <asp:Label runat="server" ID="label1" Text="Advance Creation*:" meta:resourcekey="label1Resource1"></asp:Label>
                            </td>
                            <td>
                                <asp:Label runat="server" ID="labelNumberOfDaysInAdvanceToCreateFixedWorks1" Text="By default, create fixed works "
                                    meta:resourcekey="labelNumberOfDaysInAdvanceToCreateFixedWorks1Resource1"></asp:Label>
                                <ui:UIFieldTextBox runat="server" ID="textNumberOfDaysInAdvanceToCreateFixedWorks"
                                    ShowCaption="False" PropertyName="DefaultNumberOfDaysInAdvanceToCreateFixedWorks"
                                    Caption="Advance Creation" ValidateRangeField="True" ValidationRangeType="Integer"
                                    ValidationRangeMin="0" FieldLayout="Flow" InternalControlWidth="50px" ValidateRequiredField="True"
                                    meta:resourcekey="textNumberOfDaysInAdvanceToCreateFixedWorksResource1">
                                </ui:UIFieldTextBox>
                                <asp:Label runat="server" ID="labelNumberOfDaysInAdvanceToCreateFixedWorks2" Text=" day(s) in advance before the cycles start."
                                    meta:resourcekey="labelNumberOfDaysInAdvanceToCreateFixedWorks2Resource1"></asp:Label>
                            </td>
                        </tr>
                    </table>
                    <ui:UISeparator runat="server" ID="UISeparator8" Caption="Work Justification" 
                        meta:resourcekey="UISeparator8Resource1" />
                    <ui:uifielddropdownlist runat="server" id="dropGeneralDefaultUnitOfMeasureID" PropertyName="GeneralDefaultUnitOfMeasureID" Caption="Default Unit of Measure" meta:resourcekey="dropGeneralDefaultUnitOfMeasureIDResource3"></ui:uifielddropdownlist>
                    <ui:UIFieldCheckBox runat="server" ID="EnableAllBuildingForGWJ" PropertyName="EnableAllBuildingForGWJ"
                        Caption="Location" Text="Yes, allow to select all buildings in a group WJ regardless of where the user is assigned to."
                        TextAlign="Right" meta:resourcekey="EnableAllBuildingForGWJResource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox runat="server" ID="IsWJDateDefaulted" PropertyName="IsWJDateDefaulted"
                        Caption="Default WJ Date" Text="Yes, all non-term contract WJ dates are set automatically."
                        TextAlign="Right" OnCheckedChanged="IsWJDateDefaulted_CheckedChanged" 
                        meta:resourcekey="IsWJDateDefaultedResource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIPanel ID="panelWJDate" runat="server" BorderStyle="NotSet" 
                        meta:resourcekey="panelWJDateResource1">
                        <table border="0" width="99%" cellpadding="0">
                            <tr>
                                <td nowrap="nowrap" style="width: 240px">
                                    <ui:UIFieldTextBox ID="DefaultRequiredCount" runat="server" Caption="Date Required"
                                        PropertyName="DefaultRequiredCount" ValidateDataTypeCheck="True" 
                                        ValidationRangeMin="0" ValidateRangeField="True" ValidationRangeType="Integer"
                                        ValidationDataType="Integer" Width="240px" InternalControlWidth="95%" 
                                        meta:resourcekey="DefaultRequiredCountResource1">
                                    </ui:UIFieldTextBox>
                                </td>
                                <td nowrap="nowrap">
                                    <ui:UIFieldDropDownList runat="server" ID="DefaultRequiredUnit" PropertyName="DefaultRequiredUnit"
                                        CaptionWidth="0px" FieldLayout="Flow" Width="70px" 
                                        meta:resourcekey="DefaultRequiredUnitResource1">
                                        <Items>
                                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource54" Text="Day(s)"></asp:ListItem>
                                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource55" Text="Week(s)"></asp:ListItem>
                                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource56" Text="Month(s)"></asp:ListItem>
                                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource57" Text="Year(s)"></asp:ListItem>
                                        </Items>
                                    </ui:UIFieldDropDownList>
                                    <asp:Label runat="server" Text="after the day the WJ is created." 
                                        meta:resourcekey="LabelResource1"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        <table border="0" width="99%" cellpadding="0">
                            <tr>
                                <td nowrap="nowrap" style="width: 240px">
                                    <ui:UIFieldTextBox ID="DefaultEndCount" runat="server" Caption="Default End"
                                        PropertyName="DefaultEndCount" ValidateDataTypeCheck="True" 
                                        ValidationRangeMin="0" ValidateRangeField="True" ValidationRangeType="Integer"
                                        ValidationDataType="Integer" Width="240px" InternalControlWidth="95%" 
                                        meta:resourcekey="DefaultEndCountResource1">
                                    </ui:UIFieldTextBox>
                                </td>
                                <td nowrap="nowrap">
                                    <ui:UIFieldDropDownList runat="server" ID="DefaultEndUnit" PropertyName="DefaultEndUnit"
                                        CaptionWidth="0px" FieldLayout="Flow" Width="70px" 
                                        meta:resourcekey="DefaultEndUnitResource1">
                                        <Items>
                                            <asp:ListItem Selected="True" Value="0" meta:resourcekey="ListItemResource58" Text="Day(s)"></asp:ListItem>
                                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource59" Text="Week(s)"></asp:ListItem>
                                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource60" Text="Month(s)"></asp:ListItem>
                                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource61" Text="Year(s)"></asp:ListItem>
                                        </Items>
                                    </ui:UIFieldDropDownList>
                                    <asp:Label ID="Label3" runat="server" Text="after the day the WJ is created." 
                                        meta:resourcekey="Label3Resource1"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        <ui:uifieldradiolist runat="server" id="radioDefaultBudgetSpendingPolicy" PropertyName="DefaultBudgetSpendingPolicy" Caption="Budget Spending Policy" meta:resourcekey="radioDefaultBudgetSpendingPolicyResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem value="0" Text="Disallow spending from budget periods that have not been created." meta:resourcekey="ListItemResource64"></asp:ListItem>
                                <asp:ListItem value="1" Text="Allow spending from budget periods that have not been created." meta:resourcekey="ListItemResource65"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <ui:uifieldradiolist runat="server" id="radioDefaultBudgetDeductionPolicy" PropertyName="DefaultBudgetDeductionPolicy" Caption="Budget Deduction Policy" meta:resourcekey="radioDefaultBudgetDeductionPolicyResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem value="0" Text="Deducted at the point of submission of any purchase object." meta:resourcekey="ListItemResource66"></asp:ListItem>
                                <asp:ListItem value="1" Text="Deducted at the point of approval of any purchase object." meta:resourcekey="ListItemResource67"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <ui:UISeparator runat="server" ID="sepPurchaseOrder" Caption="Purchase Order" />
                        <ui:UIFieldCheckBox runat="server" ID="checkAllowChangeOfPOAmount" Caption="Allow Change of PO Amount?" Text="Yes, allow the user to change the PO amount (provided it is less than the original, and no invoices have been received yet)." PropertyName="AllowChangeOfPOAmount"></ui:UIFieldCheckBox>
						<ui:UIFieldCheckBox runat="server" ID="AllowPerLineItemTaxInPO" Caption="Allow Per Line Item Tax In PO" PropertyName="AllowPerLineItemTaxInPO"></ui:UIFieldCheckBox>
                        <ui:UISeparator runat="server" ID="UISeparator12" Caption="Invoice" />
                        <ui:UIFieldCheckBox runat="server" ID="checkAllowInvoiceToUseCurrentYearBudgetIfPreviousIsClosed" Caption="Force Next Year Budget?" Text="Yes, force the invoice to use the following year's budget if the previous budget is closed as at the date the invoice is submitted." PropertyName="AllowInvoiceToUseCurrentYearBudgetIfPreviousIsClosed"></ui:UIFieldCheckBox>
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" ID="UISeparator7" Caption="Performance Survey URL"
                        meta:resourcekey="UISeparator7Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="SurveyURL" PropertyName="SurveyURL" Caption="Survey URL"
                        InternalControlWidth="95%" MaxLength="255" meta:resourcekey="SurveyURLResource1">
                    </ui:UIFieldTextBox>
                    <ui:UISeparator ID="UISeparator11" runat="server" Caption="Vendor" meta:resourcekey="UISeparator11Resource1" />
                    <ui:UIFieldCheckBox runat="server" ID="cbIsAutoInsertPrequalifiedVendors" Caption ="Is Auto Insert Prequalified Vendors" PropertyName="IsAutoInsertPrequalifiedVendors" meta:resourcekey="cbIsAutoInsertPrequalifiedVendorsResource1" TextAlign="Right" />
                    <br />
                    <br />
                    <ui:UIFieldTextBox runat="server" ID="txtLocationTypeNameForBuilding" 
                        Span="Half" Caption = "Location Type Name For Building" 
                        PropertyName="LocationTypeNameForBuilding" InternalControlWidth="95%" 
                        meta:resourcekey="txtLocationTypeNameForBuildingResource1"></ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView ID="tabviewAmos" runat="server" Caption="AMOS"
                    BorderStyle="NotSet" meta:resourcekey="tabviewAmosResource1">
                    <ui:UIFieldTreeList runat="server" ID="AssetLocationTypeID" Caption="Asset Location Type"
                        OnAcquireTreePopulater="AssetLocationTypeID_AcquireTreePopulater" PropertyName="AssetLocationTypeID"
                        ShowCheckBoxes="None" ValidateRequiredField="True"
                        TreeValueMode="SelectedNode" meta:resourcekey="AssetLocationTypeIDResource1">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTreeList runat="server" ID="LevelLocationTypeID" Caption="Level Location Type"
                        OnAcquireTreePopulater="LevelLocationTypeID_AcquireTreePopulater" PropertyName="LevelLocationTypeID"
                        ShowCheckBoxes="None" ValidateRequiredField="True"
                        TreeValueMode="SelectedNode" meta:resourcekey="LevelLocationTypeIDResource1">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTreeList runat="server" ID="SuiteLocationTypeID" Caption="Suite Location Type"
                        OnAcquireTreePopulater="SuiteLocationTypeID_AcquireTreePopulater" PropertyName="SuiteLocationTypeID"
                        ShowCheckBoxes="None" ValidateRequiredField="True"
                        TreeValueMode="SelectedNode" meta:resourcekey="SuiteLocationTypeIDResource1">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldDropDownList runat="server" ID="TenantContactTypeID" PropertyName="TenantContactTypeID" ValidaterequiredField="True"
                        caption="Tenant Contact Type" meta:resourcekey="TenantContactTypeIDResource3" />
                    <ui:UIFieldDropDownList runat="server" ID="DefaultChargeTypeID" PropertyName="DefaultChargeTypeID"
                        caption="Default Charge Type" meta:resourcekey="DefaultChargeTypeIDResource1"/>
                    <ui:UIFieldDropDownList runat="server" ID="DefaultUnitOfMeasureID" 
                        PropertyName="DefaultUnitOfMeasureID" Caption="Deafult Unit Of Measure" CaptionWidth="150px" meta:resourcekey="DefaultUnitOfMeasureIDResource1" >
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="DefaultMeterTypeID" 
                        PropertyName="DefaultMeterTypeID" Caption="Default Type of Meter" CaptionWidth="150px" meta:resourcekey="DefaultMeterTypeIDResource1" />
                    <ui:UIFieldTextBox runat="server" ID="PostingStartDay" PropertyName="PostingStartDay"
                        caption="Posting Start Day" ToolTip="Start day of the month allow posting."
                        ValidateDataTypeCheck="True" ValidateRequiredField = "True" ValidationDataType="Integer"
                        ValidationRangeType="Integer" ValidateRangeField="True"
                        ValidationRangeMax = 28 ValidationRangeMin=1 Span="Half" InternalControlWidth="95%" meta:resourcekey="PostingStartDayResource1"/>
                    <ui:UIFieldTextBox runat="server" ID="PostingEndDay" PropertyName="PostingEndDay"
                        caption="Posting End Day" ToolTip="End day of the month allow posting."
                        ValidateDataTypeCheck="True" ValidateRequiredField = "True" ValidationDataType="Integer"
                        ValidationRangeType="Integer" ValidateRangeField="True"
                        ValidationRangeMax = 28 ValidationRangeMin=1 Span="Half" InternalControlWidth="95%" meta:resourcekey="PostingEndDayResource1"/>
                    <ui:UIFieldTextBox runat="server" ID="EmailForAMOSFailure" PropertyName="EmailForAMOSFailure"
                        caption="E-mail" ToolTip="E-mail to be sent to an in incident of AMOS fails." InternalControlWidth="95%" meta:resourcekey="EmailForAMOSFailureResource1"/>
                </ui:UITabView>
                <ui:UITabView ID="tabInventory" runat="server" Caption="Inventory"
                    BorderStyle="NotSet" meta:resourcekey="tabInventoryResource1">
                    <ui:UIFieldDropDownList runat="server" ID="dropEquipmentUnitOfMeasure" PropertyName="EquipmentUnitOfMeasureID"
                        Caption="Equipment UOM" ToolTip="The default unit of measure that will be used for equipment catalogs in the Inventory center."
                        ValidateRequiredField="True" meta:resourcekey="dropEquipmentUnitOfMeasureResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldRadioList runat="server" ID="radioDefaultCostingType" PropertyName="InventoryDefaultCostingType"
                        ValidateRequiredField="True" Caption="Costing Type" ToolTip="The default costing type that store items will be set to when they are first checked in to a store."
                        RepeatColumns="0" meta:resourcekey="radioDefaultCostingTypeResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" Selected="True" Text="FIFO" meta:resourcekey="ListItemResource4"></asp:ListItem>
                            <asp:ListItem Value="1" Text="LIFO" meta:resourcekey="ListItemResource5"></asp:ListItem>
                            <asp:ListItem Value="3" Text="Standard Costing" meta:resourcekey="ListItemResource6"></asp:ListItem>
                            <asp:ListItem Value="4" Text="Average Costing" meta:resourcekey="ListItemResource7"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMessage" Caption="Messages"
                    BorderStyle="NotSet" meta:resourcekey="tabMessageResource1">
                    <ui:UIFieldTextBox runat="server" ID="textMessageNumberOfTries" PropertyName="MessageNumberOfTries"
                        Caption="Number of times to retry failed messages" ValidateRequiredField='True'
                        ValidateDataTypeCheck="True" ValidationDataType="Integer" CaptionWidth="260px"
                        InternalControlWidth="95%" meta:resourcekey="textMessageNumberOfTriesResource1">
                    </ui:UIFieldTextBox>
                    <ui:UISeparator runat="server" ID="UISeparator3" Caption="Email" meta:resourcekey="UISeparator3Resource1" />
                    <ui:UIFieldCheckBox runat="server" ID="checkEnableEmail" Caption="Email" PropertyName="EnableEmail"
                        Text="Enable sending of e-mails" OnCheckedChanged="checkEnableEmail_CheckedChanged"
                        meta:resourcekey="checkEnableEmailResource1" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIPanel runat="server" ID="panelEmail" BorderStyle="NotSet" 
                        meta:resourcekey="panelEmailResource1">
                        <ui:UIFieldTextBox runat="server" ID="textMessageEmailSender" Caption="Email Sender"
                            PropertyName="MessageEmailSender" Span="Half" ValidateRequiredField="True" 
                            meta:resourcekey="textMessageEmailSenderResource1" InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpServer" Caption="SMTP Server"
                            PropertyName="MessageSmtpServer" ValidateRequiredField="True" InternalControlWidth="95%"
                            meta:resourcekey="textMessageSmtpServerResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpPort" Caption="SMTP Port" PropertyName="MessageSmtpPort"
                            ValidateRequiredField="True" ValidateDataTypeCheck="True" ValidationDataType="Integer"
                            InternalControlWidth="95%" meta:resourcekey="textMessageSmtpPortResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldCheckBox runat="server" ID="checkMessageSmtpRequiresAuthentication" PropertyName="MessageSmtpRequiresAuthentication"
                            Caption="Authentication?" 
                            Text="Yes, this SMTP server requires authentication" 
                            meta:resourcekey="checkMessageSmtpRequiresAuthenticationResource1" 
                            TextAlign="Right"></ui:UIFieldCheckBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpServerUserName" Caption="User Name"
                            PropertyName="MessageSmtpServerUserName" InternalControlWidth="95%" meta:resourcekey="textMessageSmtpServerUserNameResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpServerPassword" Caption="Password"
                            TextMode="Password" InternalControlWidth="95%"
                            meta:resourcekey="textMessageSmtpServerPasswordResource1">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UIFieldCheckBox runat="server" ID="EnableReceiveEmail" 
                        Caption="Receive Email" PropertyName="EnableReceiveEmail"
                        Text="Enable receive of e-mails" TextAlign="Right" 
                        OnCheckedChanged="EnableReceiveEmail_CheckedChanged" 
                        meta:resourcekey="EnableReceiveEmailResource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIPanel runat="server" ID="panelReceiveEmail" BorderStyle="NotSet" 
                        meta:resourcekey="panelReceiveEmailResource1">
                        <ui:UIFieldRadioList runat="server" ID="EmailServerType" ValidateRequiredField="True"
                        Caption="Incoming Email Server Type" PropertyName="EmailServerType" 
                            meta:resourcekey="EmailServerTypeResource1" TextAlign="Right" OnSelectedIndexChanged="EmailServerType_SelectedIndexChanged">
                            <Items>
                                <asp:ListItem Value="0" Text="POP3" meta:resourcekey="ListItemResource62" />
                                <asp:ListItem Value="1" Text="Microsoft Exchange Server 2007" 
                                    meta:resourcekey="ListItemResource63" />
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTextBox runat="server" ID="EmailServer" PropertyName="EmailServer"
                        caption="Incoming Email Server" ValidateRequiredField="True" MaxLength="255" 
                            InternalControlWidth="95%" meta:resourcekey="EmailServerResource1"/>
                        <ui:UIFieldTextBox runat="server" ID="EmailPort" PropertyName="EmailPort"
                        caption="Incoming Email Port" ValidateRequiredField="True" 
                            InternalControlWidth="95%" meta:resourcekey="EmailPortResource1" />
                        <ui:UIFieldTextBox runat="server" ID="EmailExchangeWebServiceUrl" PropertyName="EmailExchangeWebServiceUrl"
                        caption="Exchange Web Service URL" ValidateRequiredField="True" MaxLength="255"
                            InternalControlWidth="95%" 
                            meta:resourcekey="EmailExchangeWebServiceUrlResource1" />
                        <ui:UIFieldTextBox runat="server" ID="EmailDomain" PropertyName="EmailDomain"
                        caption="Email Domain" ValidateRequiredField="True"
                            InternalControlWidth="95%" meta:resourcekey="EmailDomainResource1" />    
                        <ui:UIFieldTextBox runat="server" ID="EmailUserName" PropertyName="EmailUserName"
                        caption="Incoming Email User Name" InternalControlWidth="95%" 
                            meta:resourcekey="EmailUserNameResource1" />
                        <ui:UIFieldTextBox runat="server" ID="EmailPassword" 
                            caption="Incoming Email Password" TextMode="Password" 
                            InternalControlWidth="95%" meta:resourcekey="EmailPasswordResource1" />
                        
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" ID="UISeparator4" Caption="SMS" meta:resourcekey="UISeparator4Resource1" />
                    <ui:UIFieldCheckBox runat="server" ID="checkEnableSMS" Caption="SMS" PropertyName="EnableSms"
                        Text="Enable sending of SMSes" OnCheckedChanged="checkEnableSMS_CheckedChanged"
                        meta:resourcekey="checkEnableSMSResource1" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldRadioList runat="server" ID="SMSSendType" Caption="SMS Sent" PropertyName="SMSSendType"
                        OnSelectedIndexChanged="SMSSendType_SelectedIndexChanged" 
                        meta:resourcekey="SMSSendTypeResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Direct to modem in this server" Value="0" Selected="True" meta:resourcekey="ListItemResource52" />
                            <asp:ListItem Text="Relay to another web service" Value="1" meta:resourcekey="ListItemResource53" />
                            <asp:ListItem Text="Relay to VisualGSM" Value="2" meta:resourcekey="ListItemResource70"/>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldTextBox runat="server" ID="SMSRelayWSURL" Caption="SMS Relay WS URL" PropertyName="SMSRelayWSURL"
                        Visible="False" ValidateRequiredField="True" MaxLength="255" 
                        meta:resourcekey="SMSRelayWSURLResource1" InternalControlWidth="95%">
                    </ui:UIFieldTextBox>
                    <ui:UIPanel runat="server" ID="panelSMS" BorderStyle="NotSet"
                        meta:resourcekey="panelSMSResource1">
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsLocalNumberDigits" PropertyName="MessageSmsLocalNumberDigits"
                            Caption="Number of Digits for Local Numbers" ValidateRequiredField="True"
                            CaptionWidth="180px" 
                            meta:resourcekey="textMessageSmsLocalNumberDigitsResource1" 
                            InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsComPort" PropertyName="MessageSmsComPort"
                            Caption="COM Port" Span="Half" ValidateRequiredField="True" 
                            meta:resourcekey="dropMessageSmsComPortResource1" InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDropDownList runat="server" ID="dropMessageSmsBaudRate" PropertyName="MessageSmsBaudRate"
                            Caption="Baud Rate" Span="Half" ValidateRequiredField="True" meta:resourcekey="dropMessageSmsBaudRateResource1">
                            <Items>
                                <asp:ListItem Text="300" Value="300" meta:resourcekey="ListItemResource16"></asp:ListItem>
                                <asp:ListItem Text="600" Value="600" meta:resourcekey="ListItemResource17"></asp:ListItem>
                                <asp:ListItem Text="1200" Value="1200" meta:resourcekey="ListItemResource18"></asp:ListItem>
                                <asp:ListItem Text="2400" Value="2400" meta:resourcekey="ListItemResource19"></asp:ListItem>
                                <asp:ListItem Text="4800" Value="4800" meta:resourcekey="ListItemResource20"></asp:ListItem>
                                <asp:ListItem Text="7200" Value="7200" meta:resourcekey="ListItemResource21"></asp:ListItem>
                                <asp:ListItem Text="9600" Value="9600" meta:resourcekey="ListItemResource22"></asp:ListItem>
                                <asp:ListItem Text="14400" Value="14400" meta:resourcekey="ListItemResource23"></asp:ListItem>
                                <asp:ListItem Text="19200" Value="19200" meta:resourcekey="ListItemResource24"></asp:ListItem>
                                <asp:ListItem Text="28800" Value="28800" meta:resourcekey="ListItemResource25"></asp:ListItem>
                                <asp:ListItem Text="33600" Value="33600" meta:resourcekey="ListItemResource26"></asp:ListItem>
                                <asp:ListItem Text="57600" Value="57600" meta:resourcekey="ListItemResource27"></asp:ListItem>
                                <asp:ListItem Text="115200" Value="115200" meta:resourcekey="ListItemResource28"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropMessageSmsParity" PropertyName="MessageSmsParity"
                            Caption="Parity" Span="Half" ValidateRequiredField="True" meta:resourcekey="dropMessageSmsParityResource1">
                            <Items>
                                <asp:ListItem Text="Even" Value="Even" meta:resourcekey="ListItemResource29"></asp:ListItem>
                                <asp:ListItem Text="Mark" Value="Mark" meta:resourcekey="ListItemResource30"></asp:ListItem>
                                <asp:ListItem Text="None" Value="None" meta:resourcekey="ListItemResource31"></asp:ListItem>
                                <asp:ListItem Text="Odd" Value="Odd" meta:resourcekey="ListItemResource32"></asp:ListItem>
                                <asp:ListItem Text="Space" Value="Space" meta:resourcekey="ListItemResource33"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropMessageSmsDataBits" PropertyName="MessageSmsDataBits"
                            Caption="Number of Data Bits" Span="Half" ValidateRequiredField="True" meta:resourcekey="dropMessageSmsDataBitsResource1">
                            <Items>
                                <asp:ListItem Text="6" Value="6" meta:resourcekey="ListItemResource34"></asp:ListItem>
                                <asp:ListItem Text="7" Value="7" meta:resourcekey="ListItemResource35"></asp:ListItem>
                                <asp:ListItem Text="8" Value="8" meta:resourcekey="ListItemResource36"></asp:ListItem>
                                <asp:ListItem Text="9" Value="9" meta:resourcekey="ListItemResource37"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropMessageSmsStopBits" PropertyName="MessageSmsStopBits"
                            Caption="Stop Bit" Span="Half" ValidateRequiredField="True" meta:resourcekey="dropMessageSmsStopBitsResource1">
                            <Items>
                                <asp:ListItem Text="None" Value="None" meta:resourcekey="ListItemResource38"></asp:ListItem>
                                <asp:ListItem Text="One" Value="One" meta:resourcekey="ListItemResource39"></asp:ListItem>
                                <asp:ListItem Text="OnePointFive" Value="OnePointFive" meta:resourcekey="ListItemResource40"></asp:ListItem>
                                <asp:ListItem Text="Two" Value="Two" meta:resourcekey="ListItemResource41"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropMessageSmsHandshake" PropertyName="MessageSmsHandshake"
                            Caption="Handshaking" Span="Half" ValidateRequiredField="True" meta:resourcekey="dropMessageSmsHandshakeResource1">
                            <Items>
                                <asp:ListItem Text="None" Value="None" meta:resourcekey="ListItemResource42"></asp:ListItem>
                                <asp:ListItem Text="RequestToSend" Value="RequestToSend" meta:resourcekey="ListItemResource43"></asp:ListItem>
                                <asp:ListItem Text="RequestToSendXOnXOff" Value="RequestToSendXOnXOff" meta:resourcekey="ListItemResource44"></asp:ListItem>
                                <asp:ListItem Text="XOnXOff" Value="XOnXOff" meta:resourcekey="ListItemResource45"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UISeparator runat="server" ID="UISeparator5" Caption="Modem AT Commands" meta:resourcekey="UISeparator5Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsInitCommands" PropertyName="MessageSmsInitCommands"
                            Caption="Init Commands" Span="Half" ValidateRequiredField="True" CaptionWidth="180px"
                            InternalControlWidth="95%" meta:resourcekey="textMessageSmsInitCommandsResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsSendCommands" PropertyName="MessageSmsSendCommands"
                            Caption="Send SMS Command" Span="Half" ValidateRequiredField="True" CaptionWidth="180px"
                            InternalControlWidth="95%" meta:resourcekey="textMessageSmsSendCommandsResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsReceiveCommands" PropertyName="MessageSmsReceiveCommands"
                            Caption="Receive SMS Command" Span="Half" ValidateRequiredField="True" CaptionWidth="180px"
                            InternalControlWidth="95%" meta:resourcekey="textMessageSmsReceiveCommandsResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsDeleteCommands" PropertyName="MessageSmsDeleteCommands"
                            Caption="Delete SMS Command" Span="Half" ValidateRequiredField="True" CaptionWidth="180px"
                            InternalControlWidth="95%" meta:resourcekey="textMessageSmsDeleteCommandsResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsInitASCIICommand" PropertyName="MessageSmsInitASCIICommand"
                            Caption="Initialize ASCII Command" Span="Half" ValidateRequiredField="True" CaptionWidth="180px"
                            InternalControlWidth="95%" meta:resourcekey="textMessageSmsInitASCIICommandResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsInitUCS2Command" PropertyName="MessageSmsInitUCS2Command"
                            Caption="Initialize Unicode Command" Span="Half" ValidateRequiredField="True"
                            CaptionWidth="180px" InternalControlWidth="95%" meta:resourcekey="textMessageSmsInitUCS2CommandResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsNewLine" PropertyName="MessageSmsNewLine"
                            Caption="New Line" Span="Half" ValidateRequiredField="True" CaptionWidth="180px"
                            MaxLength="5" InternalControlWidth="95%" meta:resourcekey="textMessageSmsNewLineResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsLogFilePath" PropertyName="MessageSmsLogFilePath"
                            Caption="SMS Log File Path" CaptionWidth="180px" InternalControlWidth="95%" meta:resourcekey="textMessageSmsLogFilePathResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIGridView runat="server" ID="gridSmsKeywordHandlers" Caption="Incoming SMS Keyword Handlers"
                            BindObjectsToRows="True" PropertyName="ApplicationSettingSmsKeywordHandlers"
                            OnAction="gridSmsKeywordHandlers_Action" DataKeyNames="ObjectID" 
                            GridLines="Both" meta:resourcekey="gridSmsKeywordHandlersResource1" RowErrorColor=""
                            Style="clear: both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="AddRow" CommandText="Add"
                                    ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource1" 
                                    CausesValidation="False" />
                                <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="RemoveObject" CommandText="Remove Selected"
                                    ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif"
                                    meta:resourcekey="UIGridViewCommandResource2" CausesValidation="False" />
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                    meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ImageUrl="~/images/delete.gif"
                                    meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Keywords" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox ID="textKeywords" runat="server" Caption="Keywords" MaxLength="255"
                                            FieldLayout="Flow" InternalControlWidth="95%" meta:resourcekey="textKeywordsResource1"
                                            PropertyName="Keywords" ShowCaption="False" ToolTip="Specify a list of keywords separated by commas">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Handler URL" meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox ID="textHandlerURL" runat="server" Caption="Handler URL" FieldLayout="Flow"
                                            InternalControlWidth="95%" MaxLength="255" meta:resourcekey="textHandlerURLResource1"
                                            PropertyName="HandlerUrl" ShowCaption="False" ToolTip="Specify the URL used to process the keyword">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelSmsKeywordHandlers" 
                            BorderStyle="NotSet" meta:resourcekey="panelSmsKeywordHandlersResource1">
                            <web:subpanel runat="server" ID="subpanelSmsKeywordHandlers" GridViewID="gridSmsKeywordHandlers" />
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabServices" Caption="Background Services"
                    BorderStyle="NotSet" meta:resourcekey="tabServicesResource1">
                    <ui:UIGridView runat="server" ID="gridServices" PropertyName="ApplicationSettingServices"
                        Caption="Services Settings" BindObjectsToRows="True" OnAction="gridServices_Action"
                        DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridServicesResource1"
                        RowErrorColor="" Style="clear: both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="AddRow" CommandText="Add"
                                ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource3" 
                                CausesValidation="False" />
                            <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete Selected"
                                ImageUrl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewCommandResource4" CausesValidation="False" />
                        </Commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ImageUrl="~/images/delete.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Service Name" meta:resourcekey="UIGridViewTemplateColumnResource3">
                                <ItemTemplate>
                                    <ui:UIFieldTextBox ID="textServiceName" runat="server" Caption="Service Name" FieldLayout="Flow"
                                        InternalControlWidth="200px" meta:resourcekey="textServiceNameResource1" PropertyName="ServiceName"
                                        ShowCaption="False" ValidateRequiredField="True">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Enabled?" meta:resourcekey="UIGridViewTemplateColumnResource4">
                                <ItemTemplate>
                                    <ui:UIFieldCheckBox ID="checkIsEnabled" runat="server" Caption="Enabled" FieldLayout="Flow"
                                        meta:resourcekey="checkIsEnabledResource1" PropertyName="IsEnabled" ShowCaption="False"
                                        TextAlign="Right">
                                    </ui:UIFieldCheckBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Timer Interval" meta:resourcekey="UIGridViewTemplateColumnResource5">
                                <ItemTemplate>
                                    <ui:UIFieldTextBox ID="textTimerInterval" runat="server" Caption="Timer Interval" Maxlength="100"
                                        FieldLayout="Flow" InternalControlWidth="400px" meta:resourcekey="textTimerIntervalResource1"
                                        PropertyName="TimerInterval" ShowCaption="False" ValidateRequiredField="True">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="panelApplicationSettingService"
                        BorderStyle="NotSet" 
                        meta:resourcekey="panelApplicationSettingServiceResource1">
                        <web:subpanel runat="server" ID="subpanelApplicationSettingService" GridViewID="gridServices" />
                    </ui:UIObjectPanel>
                    <ui:UIHint runat="server" ID="hintServiceTiming" 
                        meta:resourcekey="hintServiceTimingResource1" Text="
                        The timing for the services must be specified in one of the following 
                        formats:&lt;br __designer:mapid=&quot;180f&quot; /&gt;
                        &lt;br __designer:mapid=&quot;1810&quot; /&gt;
                        &lt;b __designer:mapid=&quot;1811&quot;&gt;x sec(onds)&lt;/b&gt;&lt;br __designer:mapid=&quot;1812&quot; /&gt;
                        &lt;br __designer:mapid=&quot;1813&quot; /&gt;
                        For example, 5 sec, or 5 seconds will indicate that the service runs every 5 
                        seconds.
                        &lt;hr style=&quot;height:1px&quot; __designer:mapid=&quot;1814&quot; /&gt;
                        &lt;b __designer:mapid=&quot;1815&quot;&gt;x min(utes)&lt;/b&gt;&lt;br __designer:mapid=&quot;1816&quot; /&gt;
                        &lt;br __designer:mapid=&quot;1817&quot; /&gt;
                        For example, 5 min, or 5 minutes will indicate that the service runs every 5 
                        minutes.
                        &lt;hr style=&quot;height:1px&quot; __designer:mapid=&quot;1818&quot; /&gt;
                        &lt;b __designer:mapid=&quot;1819&quot;&gt;x day(s)&lt;/b&gt;&lt;br __designer:mapid=&quot;181a&quot; /&gt;
                        &lt;b __designer:mapid=&quot;181b&quot;&gt;x day(s) HH:MM HH:MM HH:MM...&lt;/b&gt;&lt;br __designer:mapid=&quot;181c&quot; /&gt;
                        &lt;br __designer:mapid=&quot;181d&quot; /&gt;
                        For example, 1 day 12:00 13:00, will indicate that the service runs every 1 day 
                        at 12pm and 1pm.
                        &lt;hr style=&quot;height:1px&quot; __designer:mapid=&quot;181e&quot; /&gt;
                        &lt;b __designer:mapid=&quot;181f&quot;&gt;x week(s)&lt;/b&gt;&lt;br __designer:mapid=&quot;1820&quot; /&gt;
                        &lt;b __designer:mapid=&quot;1821&quot;&gt;x week(s) HH:MM HH:MM HH:MM... Sun Mon Tue Wed Thu Fri Sat&lt;/b&gt; (being the day 
                        of the week)&lt;br __designer:mapid=&quot;1822&quot; /&gt;
                        &lt;br __designer:mapid=&quot;1823&quot; /&gt;
                        For example, 1 week 0:00 04:00 Sat Sun, will indicate that the service runs 
                        every Saturday or Sunday at 12am and 4am.
                        &lt;hr style=&quot;height:1px&quot; __designer:mapid=&quot;1824&quot; /&gt;
                        &lt;b __designer:mapid=&quot;1825&quot;&gt;x months(s)&lt;/b&gt;&lt;br __designer:mapid=&quot;1826&quot; /&gt;
                        &lt;b __designer:mapid=&quot;1827&quot;&gt;x months(s) HH:MM HH:MM HH:MM... 1 2 3 4&lt;/b&gt; (being the day of the month)&lt;br __designer:mapid=&quot;1828&quot; /&gt;
                        &lt;br __designer:mapid=&quot;1829&quot; /&gt;
                        For example, 1 month 1:00 10:00 15 31, will indicate that the service runs every 
                        15th and last day of the month at 1am and 11am.
                        &lt;br __designer:mapid=&quot;182a&quot; /&gt;
                    "></ui:UIHint>
                </ui:UITabView>
                <ui:UITabView ID="tabLook" runat="server" Caption="Look" BorderStyle="NotSet" 
                    meta:resourcekey="tabLookResource1">
                    <ui:UIFieldTextBox runat='server' ID="textLoginTitle" PropertyName="LoginTitle" Caption="Login Title Text"
                        MaxLength="255" InternalControlWidth="95%" meta:resourcekey="textLoginTitleResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldRadioList runat="server" ID="radioHorizontalAlign" PropertyName="LoginControlsHorizontalAlignment"
                        Caption="Horizontal Alignment" Span="Half" RepeatColumns="0" meta:resourcekey="radioHorizontalAlignResource1"
                        TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Left " Value="0" meta:resourcekey="ListItemResource46"></asp:ListItem>
                            <asp:ListItem Text="Center " Value="1" meta:resourcekey="ListItemResource47"></asp:ListItem>
                            <asp:ListItem Text="Right " Value="2" meta:resourcekey="ListItemResource48"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldRadioList runat="server" ID="radioVerticalAlign" PropertyName="LoginControlsVerticalAlignment"
                        Caption="Vertical Alignment" Span="Half" RepeatColumns="0" meta:resourcekey="radioVerticalAlignResource1"
                        TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Top " Value="0" meta:resourcekey="ListItemResource49"></asp:ListItem>
                            <asp:ListItem Text="Middle " Value="1" meta:resourcekey="ListItemResource50"></asp:ListItem>
                            <asp:ListItem Text="Bottom " Value="2" meta:resourcekey="ListItemResource51"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UISeparator runat="server" ID="UISeparator9" Caption="Title Logo" meta:resourcekey="UISeparator9Resource1" />
                    <ui:UIFieldInputFile runat="server" ID="fileLoginLogo" Caption="Login Logo" meta:resourcekey="fileLoginLogoResource1">
                    </ui:UIFieldInputFile>
                    <table cellpadding='0' border='0' cellspacing='0'>
                        <tr>
                            <td style="width: 120px">
                            </td>
                            <td>
                                <ui:UIButton runat="server" ID="buttonUploadFile" Text="Upload Logo" ImageUrl="~/images/upload.png"
                                    OnClick="buttonUploadFile_Click" meta:resourcekey="buttonUploadFileResource1" />
                            </td>
                        </tr>
                    </table>
                    <ui:UIHint runat="server" ID="hintLoginLogo" 
                        meta:resourcekey="hintLoginLogoResource1" Text="You must upload an image (PNG, JPG or GIF only) with a resolution of exactly 600 pixels in width by 400 pixels in height."></ui:UIHint>
                    <ui:uiseparator runat='server' id="Uiseparator10" Caption="Home Page" meta:resourcekey="Uiseparator10Resource1" />
                    <ui:uifieldtextbox runat='server' id="textHomePageUrl" PropertyName="HomePageUrl" Caption="Home Page URL" maxlength="255" ToolTip="Specifies the URL of the home page (the page that displays the user's inbox of tasks). Leave blank to use the default home.aspx page." InternalControlWidth="95%" meta:resourcekey="textHomePageUrlResource1"></ui:uifieldtextbox>
                </ui:UITabView>
                <ui:UITabView ID="tabActiveDirectory" runat="server" Caption="Active Directory" BorderStyle="NotSet" 
                    meta:resourcekey="tabActiveDirectoryResource1">
                    <ui:UIFieldCheckBox runat="server" ID='checkIsUsingActiveDirectory' 
                        PropertyName='IsUsingActiveDirectory' Caption="Active Directory" 
                        Text="Yes, use Active Directory to authenticate users when they log on to the system." 
                        meta:resourcekey="checkIsUsingActiveDirectoryResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                <ui:UIFieldTextBox runat='server' ID="ActiveDirectoryDomain" PropertyName="ActiveDirectoryDomain" Caption="Active Directory Domain"
                        MaxLength="255" InternalControlWidth="95%" meta:resourcekey="ActiveDirectoryDomainResource1">
                    </ui:UIFieldTextBox>
                <ui:UIFieldTextBox runat='server' ID="ActiveDirectoryPath" PropertyName="ActiveDirectoryPath" Caption="Active Directory Path"
                        MaxLength="255" InternalControlWidth="95%" meta:resourcekey="ActiveDirectoryPathResource1">
                    </ui:UIFieldTextBox>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
