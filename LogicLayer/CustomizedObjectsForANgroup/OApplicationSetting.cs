//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TApplicationSetting : LogicLayerSchema<OApplicationSetting>
    {
        public SchemaDateTime WorkStartTime;
        public SchemaDateTime WorkEndTime;
        public SchemaString CaseEventAfterDocumentClosedOrCancelled;
        public SchemaString SMSCommandLinePath;
        public SchemaString SMSCommandLineArguments;

        public SchemaInt EnableReceiveEmail;
        public SchemaInt EmailServerType;
        [Size(255)]
        public SchemaString EmailServer;
        public SchemaString EmailUserName;
        public SchemaString EmailPassword;
        public SchemaInt EmailPort;

        public SchemaInt EnableAllBuildingForGWJ;
        public SchemaInt IsWJDateDefaulted;
        public SchemaInt DefaultRequiredCount;
        public SchemaInt DefaultRequiredUnit;
        public SchemaInt DefaultEndCount;
        public SchemaInt DefaultEndUnit;

        public SchemaInt DefaultBudgetSpendingPolicy;
        public SchemaInt DefaultBudgetDeductionPolicy;
        public SchemaInt IsUserEmailCompulsory;
        public SchemaInt IsAutoInsertPrequalifiedVendors;

        public SchemaGuid AssetLocationTypeID;
        public SchemaGuid LevelLocationTypeID;
        public SchemaGuid SuiteLocationTypeID;
        public SchemaGuid DefaultChargeTypeID;
        public SchemaGuid DefaultMeterTypeID;
        public SchemaGuid DefaultUnitOfMeasureID;
        public SchemaGuid TenantContactTypeID;
        public SchemaInt PostingStartDay;
        public SchemaInt PostingEndDay;
        public SchemaString EmailForAMOSFailure;
        [Size(100)]
        public SchemaString EmailForEquipmentWriteOff;

        public SchemaGuid GeneralDefaultUnitOfMeasureID;
        public SchemaInt AllowChangeOfExchangeRate;

        [Size(255)]
        public SchemaString SystemUrl;

        [Size(255)]
        public SchemaString EmailExchangeWebServiceUrl;
        public SchemaString EmailDomain;
        public SchemaString LocationTypeNameForBuilding;
        public SchemaString POReportRPTFileName;
        public SchemaInt AllowPerLineItemTaxInPO;
        public SchemaInt AllowChangeOfPOAmount;
        public SchemaInt AllowInvoiceToUseCurrentYearBudgetIfPreviousIsClosed;

        public SchemaGuid FromStoreID;

        public TStore FromStore { get { return OneToOne<TStore>("FromStoreID"); } }
    }

    public abstract partial class OApplicationSetting : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract DateTime? WorkStartTime { get; set; }

        public abstract DateTime? WorkEndTime { get; set; }

        public abstract string CaseEventAfterDocumentClosedOrCancelled { get; set; }

        public abstract string SMSCommandLinePath { get; set; }

        public abstract string SMSCommandLineArguments { get; set; }

        public abstract int? EnableReceiveEmail { get; set; }

        public abstract int? EmailServerType { get; set; }

        public abstract String EmailServer { get; set; }

        public abstract String EmailUserName { get; set; }

        public abstract String EmailPassword { get; set; }

        public abstract int? EmailPort { get; set; }

        public abstract int? EnableAllBuildingForGWJ { get; set; }

        public abstract int? IsWJDateDefaulted { get; set; }

        public abstract int? DefaultRequiredCount { get; set; }

        public abstract int? DefaultRequiredUnit { get; set; }

        public abstract int? DefaultEndCount { get; set; }

        public abstract int? DefaultEndUnit { get; set; }

        public abstract int? IsUserEmailCompulsory { get; set; }

        public abstract int? IsAutoInsertPrequalifiedVendors { get; set; }

        public abstract Guid? AssetLocationTypeID { get; set; }

        public abstract Guid? LevelLocationTypeID { get; set; }

        public abstract Guid? SuiteLocationTypeID { get; set; }

        public abstract Guid? DefaultChargeTypeID { get; set; }

        public abstract Guid? DefaultMeterTypeID { get; set; }

        public abstract Guid? DefaultUnitOfMeasureID { get; set; }

        public abstract Guid? TenantContactTypeID { get; set; }

        public abstract int? PostingStartDay { get; set; }

        public abstract int? PostingEndDay { get; set; }

        public abstract String EmailForAMOSFailure { get; set; }

        public abstract String EmailForEquipmentWriteOff { get; set; }

        public abstract int? AllowChangeOfExchangeRate { get; set; }

        public abstract Guid? GeneralDefaultUnitOfMeasureID { get; set; }

        public abstract String SystemUrl { get; set; }

        public abstract String POReportRPTFileName { get; set; }

        public abstract String EmailExchangeWebServiceUrl { get; set; }

        public abstract String EmailDomain { get; set; }

        public abstract String LocationTypeNameForBuilding { get; set; }

        public abstract int? AllowPerLineItemTaxInPO { get; set; }

        public abstract int? AllowChangeOfPOAmount { get; set; }

        public abstract int? AllowInvoiceToUseCurrentYearBudgetIfPreviousIsClosed { get; set; }

        public abstract Guid? FromStoreID { get; set; }

        public abstract OStore FromStore { get; set; }

        /// <summary>
        /// [Column] Gets or sets the future budget spending policy.
        /// <list>
        ///     <item>0 - Disallow spending from budget periods that have not been created. </item>
        ///     <item>1 - Allow spending from budget periods that have not been created. </item>
        /// </list>
        /// </summary>
        public abstract int? DefaultBudgetSpendingPolicy { get; set; }

        /// <summary>
        /// [Column] Gets or sets at which point in time the budget is deducted.
        /// <list>
        ///     <item>0 - Deducted at the point of submission of any purchase object. </item>
        ///     <item>1 - Deducted at the point of approval of any purchase object. </item>
        /// </list>
        /// </summary>
        public abstract int? DefaultBudgetDeductionPolicy { get; set; }

        /// <summary>
        ///
        /// </summary>
        public String LocationTypeNameForBuildingActual
        {
            get
            {
                if (this.LocationTypeNameForBuilding == null || this.LocationTypeNameForBuilding == string.Empty)
                    return "Building";
                else
                    return LocationTypeNameForBuilding;
            }
        }
    }

    /// <summary>
    ///
    /// </summary>
    public enum EnumReceiveEmailServerType
    {
        POP3 = 0,
        MicrosoftExchangeServer2007 = 1
    }

    /// <summary>
    ///
    /// </summary>
    public enum EnumRequestForQuotationDefaultDateUnit
    {
        Day = 0,
        Week = 1,
        Month = 2,
        Year = 3
    }
}