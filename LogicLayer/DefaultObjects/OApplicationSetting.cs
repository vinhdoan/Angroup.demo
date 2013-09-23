//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TApplicationSetting : LogicLayerSchema<OApplicationSetting>
    {
        // Login
        //
        [Default(1)]
        public SchemaInt LoginControlsHorizontalAlignment;
        [Default(1)]
        public SchemaInt LoginControlsVerticalAlignment;
        [Size(255)]
        public SchemaString LoginTitle;
        public SchemaImage LoginLogo;
        [Size(255)]
        public SchemaString HomePageUrl;

        // Admin Center
        //
        public SchemaInt PasswordMinimumLength;
        [Default(0)]
        public SchemaInt PasswordRequiredCharacters;
        public SchemaInt PasswordMaximumTries;        
        public SchemaInt PasswordDaysToExpiry;
        public SchemaInt PasswordMinimumAge;
        public SchemaInt PasswordHistoryKept;
        public SchemaInt NumberOfDaysToKeepMessageHistory;
        public SchemaInt NumberOfDaysToKeepLoginHistory;
        public SchemaInt NumberOfDaysToKeepBackgroundServiceLog;

        // Asset Center
        //
        
        // Inventory Center
        //
        public SchemaGuid EquipmentUnitOfMeasureID;
        public SchemaInt InventoryDefaultCostingType;

        // Procurement Center
        //
        public SchemaGuid BaseCurrencyID;

        // Work Center
        //
        public SchemaInt DefaultNumberOfDaysInAdvanceToCreateFixedWorks;
        public SchemaGuid DefaultTypeOfWorkID;
        public SchemaGuid DefaultScheduledWorkTypeOfWorkID;

        // Message
        //
        [Default(1)]
        public SchemaInt EnableEmail;
        [Default(1)]
        public SchemaInt EnableSms;
        [Default(0)]
        public SchemaInt SMSSendType;
        [Size(255)]
        public SchemaString SMSRelayWSURL;
        [Default(3)]
        public SchemaInt MessageNumberOfTries;

        public SchemaString MessageSmtpServer;
        [Default(25)]
        public SchemaInt MessageSmtpPort;
        public SchemaInt MessageSmtpRequiresAuthentication;
        public SchemaString MessageSmtpServerUserName;
        public SchemaString MessageSmtpServerPassword;

        [Size(10)]
        public SchemaString MessageSmsComPort;
        [Default(9600)]
        public SchemaInt MessageSmsBaudRate;
        [Default("None"), Size(20)]
        public SchemaString MessageSmsParity;
        public SchemaInt MessageSmsDataBits;
        [Default("One"), Size(20)]
        public SchemaString MessageSmsStopBits;
        [Default("None"), Size(30)]
        public SchemaString MessageSmsHandshake;

        [Default(8)]
        public SchemaInt MessageSmsLocalNumberDigits;
        [Default("ATZ;ATE0;AT+CMGF=1")]
        public SchemaString MessageSmsInitCommands;
        [Default("AT+CMGS={0}")]
        public SchemaString MessageSmsSendCommands;
        [Default("AT+CMGR={0}")]
        public SchemaString MessageSmsReceiveCommands;
        [Default("AT+CMGD={0}")]
        public SchemaString MessageSmsDeleteCommands;
        [Default("AT+CSMP=17,167,0,0")]
        public SchemaString MessageSmsInitASCIICommand;
        [Default("AT+CSMP=17,167,0,8")]
        public SchemaString MessageSmsInitUCS2Command;
        [Default("\\r"), Size(5)]
        public SchemaString MessageSmsNewLine;
        [Default("c:\\log\\smslog-{0:yyyyMMdd}.txt")]
        public SchemaString MessageSmsLogFilePath;
        [Default("sender_eam@anacle.com"), Size(50)]
        public SchemaString MessageEmailSender;
        
        //Active directory
        public SchemaInt IsUsingActiveDirectory;
        [Size(255)]
        public SchemaString ActiveDirectoryDomain;
        [Size(255)]
        public SchemaString ActiveDirectoryPath;

        //Service Center: Performance Survey
        //
        [Default("http://???/???/modules/surveyplanner/surveyformload.aspx"), Size(255)]
        public SchemaString SurveyURL;

        //Background Service
        //
        public SchemaString BackgroundServiceAdminEmail;

        public TCurrency BaseCurrency { get { return OneToOne<TCurrency>("BaseCurrencyID"); } }

        public TApplicationSettingService ApplicationSettingServices { get { return OneToMany<TApplicationSettingService>("ApplicationSettingID"); } }
        public TApplicationSettingSmsKeywordHandler ApplicationSettingSmsKeywordHandlers { get { return OneToMany<TApplicationSettingSmsKeywordHandler>("ApplicationSettingID"); } }

        //Excel Reader Web Service
        //
        [ Size(255)]
        public SchemaString ExcelReaderWebServiceURL;
        [Default(0)]
        public SchemaInt ExcelReaderUseWebService;
    }

    public abstract partial class OApplicationSetting : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the horizontal alignment of the
        /// login controls.
        /// <list>
        ///     <item>0 - Left </item>
        ///     <item>1 - Center </item>
        ///     <item>2 - Right </item>
        /// </list>
        /// </summary>
        public abstract int? LoginControlsHorizontalAlignment { get; set; }

        /// <summary>
        /// [Column] Gets or sets the horizontal alignment of the
        /// login controls.
        /// <list>
        ///     <item>0 - Top </item>
        ///     <item>1 - Middle </item>
        ///     <item>2 - Bottom </item>
        /// </list>
        /// </summary>
        public abstract int? LoginControlsVerticalAlignment { get; set; }

        /// <summary>
        /// Gets or sets a short title text to be displayed above
        /// the login controls.
        /// </summary>
        public abstract string LoginTitle { get; set; }

        /// <summary>
        /// Gets or sets the login logo image binary.
        /// </summary>
        public abstract byte[] LoginLogo { get; set; }

        /// <summary>
        /// Gets or sets the URL to the home page (the page that
        /// displays the inbox of tasks).
        /// </summary>
        public abstract string HomePageUrl { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum length for the password.
        /// </summary>
        public abstract int? PasswordMinimumLength { get; set; }

        /// <summary>
        /// [Column] Gets or sets the password type:
        /// 0: password contains alphabet only. This setting is default.
        /// 1: password contains both alphabet and number.
        /// </summary>
        public abstract int? PasswordRequiredCharacters { get; set;}

        /// <summary>
        /// [Column] Gets or sets the maximum number of attempted logins.
        /// </summary>
        public abstract int? PasswordMaximumTries { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days to pass before user is required to update password. 
        /// Set to 0 to disable expiry check
        /// </summary>
        public abstract int? PasswordDaysToExpiry { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days to pass before user can update password again.
        /// </summary>
        public abstract int? PasswordMinimumAge { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of passwords in history to ensure difference from current password.
        /// </summary>
        public abstract int? PasswordHistoryKept { get; set; }

        /// <summary>
        /// [Column Gets or sets the number of days to keep the message history
        /// before removing them. The message history is deleted whenever the
        /// a user logs on to the system.
        /// </summary>
        public abstract int? NumberOfDaysToKeepMessageHistory { get; set; }
        
        /// <summary>
        /// [Column Gets or sets the number of days to keep the login history
        /// before removing them. The login history is deleted whenever the
        /// a user logs on to the system.
        /// </summary>
        public abstract int? NumberOfDaysToKeepLoginHistory { get; set; }

        /// <summary>
        /// [Column Gets or sets the number of days to keep the background 
        /// service log before removing them. 
        /// </summary>
        public abstract int? NumberOfDaysToKeepBackgroundServiceLog { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key of the
        /// base currency used by this instance of the system.
        /// </summary>
        public abstract Guid? BaseCurrencyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default number of days
        /// in advance to create fixed works.
        /// </summary>
        public abstract int? DefaultNumberOfDaysInAdvanceToCreateFixedWorks { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code
        /// table that represents the default type of work
        /// that will be assigned to a Work object when it
        /// is first created.
        /// </summary>
        public abstract Guid? DefaultTypeOfWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code
        /// table that represents the default type of work
        /// that will be assigned to a Scheduled Work object when it
        /// is first created.
        /// </summary>
        public abstract Guid? DefaultScheduledWorkTypeOfWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit of measure used
        /// for identifying the default unit of measure
        /// for equipment catalogs in the Inventory Center. 
        /// </summary>
        public abstract Guid? EquipmentUnitOfMeasureID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default costing type, 
        /// or the accounting method of an item of this catalogue in this store
        /// when an item is first checked in to the store.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 / StoreItemCostingType.FIFO: First-in-first-out </item>
        /// 		<item>1 / StoreItemCostingType.LIFO: Last-in-first-out</item>
        /// 		<item>3 / StoreItemCostingType.StandardCosting: Standard costing</item>
        /// 		<item>4 / StoreItemCostingType.AverageCosting: Average costing</item>
        /// 	</list>
        /// </summary>
        public abstract int? InventoryDefaultCostingType { get; set; }

        /// <summary>
        /// [Columnn] Gets or sets a flag that indicates 
        /// whether e-mails will be sent out.
        /// </summary>
        public abstract int? EnableEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates
        /// whether SMSes will be sent out.
        /// </summary>
        public abstract int? EnableSms { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates
        /// whether SMSes are direct from modem (0) 
        /// or relay to a web service (1).
        /// </summary>
        public abstract int? SMSSendType { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates
        /// SMSRelayWSURL that sms will send to
        /// </summary>
        public abstract String SMSRelayWSURL { get; set; }

        /// <summary>
        /// [Column] Gets or sets the total number of tries
        /// the message service will try to send a failed
        /// message before giving up.
        /// </summary>
        public abstract int? MessageNumberOfTries { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMTP server address.
        /// </summary>
        public abstract string MessageSmtpServer { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMTP port.
        /// </summary>
        public abstract int? MessageSmtpPort { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether the SMTP 
        /// server requires authentication before allow us to send e-mail
        /// through it.
        /// </summary>
        public abstract int? MessageSmtpRequiresAuthentication { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMTP server user
        /// name used for server authentication.
        /// </summary>
        public abstract String MessageSmtpServerUserName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMTP server password
        /// used for server authentication.
        /// </summary>
        public abstract String MessageSmtpServerPassword { get; set; }

        /// <summary>
        /// [Column] Gets or sets the COM port in which the
        /// SMS modem is connected to.
        /// </summary>
        public abstract String MessageSmsComPort { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMS baud rate that
        /// the SMS modem will be communicating at.
        /// </summary>
        public abstract int? MessageSmsBaudRate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the parity per byte 
        /// of information transferred.
        /// </summary>
        public abstract String MessageSmsParity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of data bits
        /// in each byte of information transferred.
        /// </summary>
        public abstract int? MessageSmsDataBits { get; set; }

        /// <summary>
        /// [Column] Gets or sets the stop bits per byte
        /// of information transferred.
        /// </summary>
        public abstract String MessageSmsStopBits { get; set; }

        /// <summary>
        /// [Column] Gets or sets the handshaking protocol.
        /// </summary>
        public abstract String MessageSmsHandshake { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of digits for
        /// local numbers. When trying to send SMSes where the
        /// number of digits is not the same as this value, 
        /// the system will add a '+' sign to indicate that
        /// it is an overseas number.
        /// </summary>
        public abstract int? MessageSmsLocalNumberDigits { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMS modem initialization
        /// AT commands, each separated by a semi-colon.
        /// </summary>
        public abstract String MessageSmsInitCommands { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMS modem AT command to
        /// send a message to a recipient through the {0} placeholder.
        /// </summary>
        public abstract String MessageSmsSendCommands { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMS modem AT command
        /// to read a message in the SIM card memory at an index 
        /// specified through the {0} placeholder.
        /// </summary>
        public abstract String MessageSmsReceiveCommands { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMS modem AT command
        /// to remove a read message in the SIM card memory at
        /// an index specified through the {0} placeholder.
        /// </summary>
        public abstract String MessageSmsDeleteCommands { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMS modem AT command
        /// to set the modem's mode to send ASCII messages.
        /// </summary>
        public abstract String MessageSmsInitASCIICommand { get; set; }

        /// <summary>
        /// [Column] Gets or sets the SMS modem AT command
        /// to set the modem's mode to send UCS (Unicode) messages.
        /// </summary>
        public abstract String MessageSmsInitUCS2Command { get; set; }

        /// <summary>
        /// [Column] Gets or sets the string representing the
        /// new line character sent to/from the modem.
        /// </summary>
        public abstract String MessageSmsNewLine { get; set; }

        /// <summary>
        /// [Column] Gets or sets the log file path for SMS.
        /// </summary>
        public abstract String MessageSmsLogFilePath { get; set; }

        /// <summary>
        /// [Column] Gets or sets the e-mail address of the sender
        /// for all e-mails sent out by the Anacle.EAM system.
        /// </summary>
        public abstract String MessageEmailSender { get; set; }

        /// <summary>
        /// [Column] Gets or sets the url for performance survey.
        /// </summary>
        public abstract String SurveyURL { get; set; }

        /// <summary>
        /// Gets the base currency used by this instance of the system.
        /// </summary>
        public abstract OCurrency BaseCurrency { get; }

        /// <summary>
        /// Gets a list of OApplicationSettingService objects
        /// that represent that list of services applicable
        /// for this application.
        /// </summary>
        public abstract DataList<OApplicationSettingService> ApplicationSettingServices { get; }

        /// <summary>
        /// Gets a list of OApplicationSettingSmsKeywordHandler objects
        /// that represent the SMS keyword handlers applicable for
        /// this application.
        /// </summary>
        public abstract DataList<OApplicationSettingSmsKeywordHandler> ApplicationSettingSmsKeywordHandlers { get; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating that the system
        /// will use Active Directory to authenticate users when they
        /// log in.
        /// </summary>
        public abstract Int32? IsUsingActiveDirectory { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name for the Active Directory Domain
        /// </summary>
        public abstract String ActiveDirectoryDomain { get; set; }

        /// <summary>
        /// [Column] Gets or sets the LDAP path for the Active Directory Domain
        /// </summary>
        public abstract String ActiveDirectoryPath { get; set; }

        /// <summary>
        /// [Column] Gets or sets Background Service Administrator Email
        /// </summary>
        public abstract String BackgroundServiceAdminEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets ExcelReaderWebService URL
        /// </summary>
        public abstract String ExcelReaderWebServiceURL { get; set; }
        /// <summary>
        /// [Column] Indicate whether to use excel web service 
        /// </summary>
        public abstract int? ExcelReaderUseWebService { get; set; }

        private static OApplicationSetting current = null;

        /// <summary>
        /// Loads the current application settings from the 
        /// database.
        /// </summary>
        public static OApplicationSetting Current
        {
            get
            {
                if (current == null)
                {
                    using (Connection c = new Connection())
                    {
                        // Loads the application setting object
                        // with a lock on the ApplicationSetting
                        // table so that no other thread can select
                        // from the table at the same time.
                        //
                        c.SetLockMode(LockMode.UpdateLock);
                        current = TablesLogic.tApplicationSetting.Load(Query.True);
                        c.SetLockMode(LockMode.Default);

                        if (current == null)
                        {
                            current = TablesLogic.tApplicationSetting.Create();
                            current.Save();
                        }
                        c.Commit();
                    }
                }
                return current;
            }
        }


        /// <summary>
        /// Overrides the saved method for this application domain
        /// to reflect the new settings immediately.
        /// <para></para>
        /// Application domains that this object was not saved in
        /// will not use the new settings until the application is
        /// restarted. For example, services and web applications in
        /// a server farm must be restarted manually in order for
        /// the new settings to take effect.
        /// </summary>
        public override void Saved()
        {
            base.Saved();

            current = TablesLogic.tApplicationSetting.Load(Query.True);

            //Remove the background services
            List<OApplicationSettingService> applicationSettingServices = 
                TablesLogic.tApplicationSettingService.LoadList(TablesLogic.tApplicationSettingService.ApplicationSettingID == null);
            foreach (OApplicationSettingService applicationSettingService in applicationSettingServices)
            {
                OBackgroundServiceRun bsr = applicationSettingService.BackgroundServiceRun;

                if (bsr != null)
                    bsr.Deactivate();
            }
        }


        Hashtable services = null;


        /// <summary>
        /// Gets a flag indicating whether the service
        /// of the specified name is enabled.
        /// </summary>
        /// <param name="serviceName"></param>
        /// <returns></returns>
        public bool IsServiceEnabled(string serviceName)
        {
            if (services == null)
            {
                services = new Hashtable();
                foreach (OApplicationSettingService service in this.ApplicationSettingServices)
                    services[service.ServiceName] = service;
            }

            OApplicationSettingService appService = services[serviceName] as OApplicationSettingService;
            if (appService != null)
                return appService.IsEnabled == (int)EnumApplicationGeneral.Yes;
            return false;
        }


        /// <summary>
        /// Gets the timer interval of the specified service.
        /// </summary>
        /// <param name="serviceName"></param>
        /// <returns></returns>
        public string GetServiceTimerInterval(string serviceName)
        {
            if (services == null)
            {
                services = new Hashtable();
                foreach (OApplicationSettingService service in this.ApplicationSettingServices)
                    services[service.ServiceName] = service;
            }

            OApplicationSettingService appService = services[serviceName] as OApplicationSettingService;
            if (appService != null)
                return appService.TimerInterval;
            return "5 minutes";
        }
    }

    /// <summary>
    /// Enum for SMS Send Type
    /// </summary>
    public enum EnumSMSSendType
    {
        SMSDirectToModem = 0,
        SMSRelayWSURL = 1,
        SMSRelayVisualGSM = 2
    }
}
