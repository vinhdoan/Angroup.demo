<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Drawing" %>

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
        dropBaseCurrency.Bind(OCurrency.GetAllCurrencies());
        dropEquipmentUnitOfMeasure.Bind(OCode.GetCodesByType("UnitOfMeasure", applicationSetting.EquipmentUnitOfMeasureID));
        dropDefaultTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", null));
        dropDefaultScheduledWorkTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", null));

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

    protected void btnDecode_Click(object sender, EventArgs e)
    {
        if (String.IsNullOrEmpty(tbDecode.Text))
        {
            try
            {
                Dictionary<string, string> parameters = new Dictionary<string, string>();
                string s = tbDecode.Text;

                System.Security.Cryptography.SymmetricAlgorithm CommonCodec = System.Security.Cryptography.SymmetricAlgorithm.Create("RC2");
                //IV and Keys for v6.0
                //
                CommonCodec.IV = new byte[] { 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77 };
                CommonCodec.Key = new byte[] { 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff };
                byte[] b = new byte[s.Length / 2];
                for (int i = 0; i < b.Length; i++)
                {
                    int j = i * i;
                    b[i] = (byte)((Int32.Parse(s.Substring(i * 2, 2), System.Globalization.NumberStyles.HexNumber) - j) % 256);
                }

                System.IO.MemoryStream memoryStream = new System.IO.MemoryStream();
                System.Security.Cryptography.CryptoStream encStream = new System.Security.Cryptography.CryptoStream(memoryStream,
                    CommonCodec.CreateDecryptor(), System.Security.Cryptography.CryptoStreamMode.Write);
                encStream.Write(b, 0, b.Length);
                encStream.Close();
                string licenseString = Encoding.Unicode.GetString(memoryStream.ToArray());             
                string[] licenseParameters = licenseString.Split('&');
                foreach (string licenseParameter in licenseParameters)
                {
                    string[] pv = licenseParameter.Split('=');
                    if (pv.Length > 1)
                        parameters[pv[0]] = HttpUtility.UrlDecode(pv[1]);
                }                
                tbEncode.Text = parameters["C"];
            }
            catch (Exception ex)
            {
            }
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
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BeginningHtml="" BorderStyle="NotSet"
        EndingHtml="" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Application Settings" BaseTable="tApplicationSetting"
            CloseWindowButtonVisible="false" DeleteButtonVisible="false" SaveAndCloseButtonVisible="false"
            SaveAndNewButtonVisible="false" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabApplication" runat="server" Caption="Application" BeginningHtml=""
                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tabApplicationResource1">
                    <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberVisible="false" />
                    <ui:UISeparator runat="server" ID="sep1" Caption="Password Policy" meta:resourcekey="sep1Resource1" />
                    <ui:UIFieldRadioList runat="server" ID="radioPasswordRequiredCharacters" PropertyName="PasswordRequiredCharacters"
                        CaptionWidth="180px" Caption="Password Complexity" ValidateRequiredField="True"
                        meta:resourcekey="radioPasswordRequiredCharactersResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource1">No restriction</asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Must contain at least one alphabet, and one numeric character</asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource3">Must contain at least one alphabet, one numeric character and one special character (eg. ~ ! @ # $ % etc)</asp:ListItem>
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
                    <ui:UISeparator runat="server" ID="UISeparator6" Caption="Work" meta:resourcekey="UISeparator6Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="dropDefaultTypeOfWork" PropertyName="DefaultTypeOfWorkID"
                        Caption="Default Type of Work" Span="Full" CaptionWidth="210px" meta:resourcekey="dropDefaultTypeOfWorkResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="dropDefaultScheduledWorkTypeOfWork" PropertyName="DefaultScheduledWorkTypeOfWorkID"
                        Caption="Default Type of Work (Scheduled Work)" Span="Full" CaptionWidth="210px"
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
                    <ui:UISeparator runat="server" ID="UISeparator7" Caption="Performance Survey URL"
                        meta:resourcekey="UISeparator7Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="SurveyURL" PropertyName="SurveyURL" Caption="Survey URL"
                        InternalControlWidth="95%" MaxLength="255" meta:resourcekey="SurveyURLResource1">
                    </ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView ID="tabInventory" runat="server" Caption="Inventory" BeginningHtml=""
                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tabInventoryResource1">
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
                <ui:UITabView runat="server" ID="tabMessage" Caption="Messages" BeginningHtml=""
                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tabMessageResource1">
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
                    <ui:UIPanel runat="server" ID="panelEmail" BeginningHtml="" BorderStyle="NotSet"
                        EndingHtml="" meta:resourcekey="panelEmailResource1">
                        <ui:UIFieldTextBox runat="server" ID="textMessageEmailSender" Caption="Email Sender"
                            PropertyName="MessageEmailSender" Span="Half" ValidateRequiredField="true" meta:resourcekey="textMessageEmailSenderResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpServer" Caption="SMTP Server"
                            PropertyName="MessageSmtpServer" ValidateRequiredField="True" InternalControlWidth="95%"
                            meta:resourcekey="textMessageSmtpServerResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpPort" Caption="SMTP Port" PropertyName="MessageSmtpPort"
                            ValidateRequiredField="True" ValidateDataTypeCheck="True" ValidationDataType="Integer"
                            InternalControlWidth="95%" meta:resourcekey="textMessageSmtpPortResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpServerUserName" Caption="User Name"
                            PropertyName="MessageSmtpServerUserName" InternalControlWidth="95%" meta:resourcekey="textMessageSmtpServerUserNameResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmtpServerPassword" Caption="Password"
                            PropertyName="MessageSmtpServerPassword" TextMode="Password" InternalControlWidth="95%"
                            meta:resourcekey="textMessageSmtpServerPasswordResource1">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" ID="UISeparator4" Caption="SMS" meta:resourcekey="UISeparator4Resource1" />
                    <ui:UIFieldCheckBox runat="server" ID="checkEnableSMS" Caption="SMS" PropertyName="EnableSms"
                        Text="Enable sending of SMSes" OnCheckedChanged="checkEnableSMS_CheckedChanged"
                        meta:resourcekey="checkEnableSMSResource1" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldRadioList runat="server" ID="SMSSendType" Caption="SMS Sent" PropertyName="SMSSendType"
                        OnSelectedIndexChanged="SMSSendType_SelectedIndexChanged" meta:resourcekey="SMSSendTypeResource1">
                        <Items>
                            <asp:ListItem Text="Direct to modem in this server" Value="0" Selected="True" meta:resourcekey="ListItemResource52" />
                            <asp:ListItem Text="Relay to another web service" Value="1" meta:resourcekey="ListItemResource53" />
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldTextBox runat="server" ID="SMSRelayWSURL" Caption="SMS Relay WS URL" PropertyName="SMSRelayWSURL"
                        Visible="false" ValidateRequiredField="true" MaxLength="255" meta:resourcekey="SMSRelayWSURLResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIPanel runat="server" ID="panelSMS" BeginningHtml="" BorderStyle="NotSet" EndingHtml=""
                        meta:resourcekey="panelSMSResource1">
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsLocalNumberDigits" PropertyName="MessageSmsLocalNumberDigits"
                            Caption="Number of Digits for Local Numbers" Span="Full" ValidateRequiredField="True"
                            CaptionWidth="180px" meta:resourcekey="textMessageSmsLocalNumberDigitsResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMessageSmsComPort" PropertyName="MessageSmsComPort"
                            Caption="COM Port" Span="Half" ValidateRequiredField="True" meta:resourcekey="dropMessageSmsComPortResource1">
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
                            OnAction="gridSmsKeywordHandlers_Action" DataKeyNames="ObjectID" GridLines="Both"
                            ImageRowErrorUrl="" meta:resourcekey="gridSmsKeywordHandlersResource1" RowErrorColor=""
                            Style="clear: both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="AddRow" CommandText="Add"
                                    ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="RemoveObject" CommandText="Remove Selected"
                                    ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif"
                                    meta:resourcekey="UIGridViewCommandResource2" />
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
                        <ui:UIObjectPanel runat="server" ID="panelSmsKeywordHandlers" BeginningHtml="" BorderStyle="NotSet"
                            EndingHtml="" meta:resourcekey="panelSmsKeywordHandlersResource1">
                            <web:subpanel runat="server" ID="subpanelSmsKeywordHandlers" GridViewID="gridSmsKeywordHandlers" />
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabServices" Caption="Background Services" BeginningHtml=""
                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tabServicesResource1">
                    <ui:UIGridView runat="server" ID="gridServices" PropertyName="ApplicationSettingServices"
                        Caption="Services Settings" BindObjectsToRows="True" OnAction="gridServices_Action"
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridServicesResource1"
                        RowErrorColor="" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Commands>
                            <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="AddRow" CommandText="Add"
                                ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource3" />
                            <ui:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete Selected"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource4" />
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
                                    <ui:UIFieldTextBox ID="textTimerInterval" runat="server" Caption="Timer Interval"
                                        FieldLayout="Flow" InternalControlWidth="400px" meta:resourcekey="textTimerIntervalResource1"
                                        PropertyName="TimerInterval" ShowCaption="False" ValidateRequiredField="True">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="panelApplicationSettingService" BeginningHtml=""
                        BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panelApplicationSettingServiceResource1">
                        <web:subpanel runat="server" ID="subpanelApplicationSettingService" GridViewID="gridServices" />
                    </ui:UIObjectPanel>
                    <ui:UIHint runat="server" ID="hintServiceTiming">
                        The timing for the services must be specified in one of the following formats:<br />
                        <br />
                        <b>x sec(onds)</b><br />
                        <br />
                        For example, 5 sec, or 5 seconds will indicate that the service runs every 5 seconds.
                        <hr style='height:1px' />
                        <b>x min(utes)</b><br />
                        <br />
                        For example, 5 min, or 5 minutes will indicate that the service runs every 5 minutes.
                        <hr style='height:1px' />
                        <b>x day(s)</b><br />
                        <b>x day(s) HH:MM HH:MM HH:MM...</b><br />
                        <br />
                        For example, 1 day 12:00 13:00, will indicate that the service runs every 1 day at 12pm and 1pm.
                        <hr style='height:1px' />
                        <b>x week(s)</b><br />
                        <b>x week(s) HH:MM HH:MM HH:MM... Sun Mon Tue Wed Thu Fri Sat</b> (being the day of the week)<br />
                        <br />
                        For example, 1 week 0:00 04:00 Sat Sun, will indicate that the service runs every Saturday or Sunday at 12am and 4am.
                        <hr style='height:1px' />
                        <b>x months(s)</b><br />
                        <b>x months(s) HH:MM HH:MM HH:MM... 1 2 3 4</b> (being the day of the month)<br />
                        <br />
                        For example, 1 month 1:00 10:00 15 31, will indicate that the service runs every 15th and last day of the month at 1am and 11am.
                        <br />
                    </ui:UIHint>
                </ui:UITabView>
                <ui:UITabView ID="tabLook" runat="server" Caption="Look" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="tabLookResource1">
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
                    <ui:UIHint runat="server" ID="hintLoginLogo" meta:resourcekey="hintLoginLogoResource1"
                        Text="You must upload an image (PNG, JPG or GIF only) with a resolution of exactly 600 pixels in width by 400 pixels in height.">
                    </ui:UIHint>
                    <ui:UISeparator runat='server' ID="Uiseparator8" Caption="Home Page" />
                    <ui:UIFieldTextBox runat='server' ID="textHomePageUrl" PropertyName="HomePageUrl"
                        Caption="Home Page URL" Span="full" MaxLength="255" ToolTip="Specifies the URL of the home page (the page that displays the user's inbox of tasks). Leave blank to use the default home.aspx page.">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox runat="server" ID="tbDecode" Caption="Encode String" MaxLength="1000">
                    </ui:UIFieldTextBox>
                    <ui:UIButton runat="server" ID="btnDecode" Text="Encode" OnClick="btnDecode_Click" />
                    <ui:UIFieldTextBox runat="server" ID="tbEncode" Caption="Encoded">
                    </ui:UIFieldTextBox>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
