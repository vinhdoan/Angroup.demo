//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections.Generic;
using System.Configuration;
using System.Reflection;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Contains all the declarations to instantiate the Schema classes.
    /// </summary>
    [Serializable] public partial class TablesLogic : TablesData
    {
        // Base objects
        //
        public static TAttachment tAttachment = SchemaFactory.Get<TAttachment>();
        public static TMemo tMemo = SchemaFactory.Get<TMemo>();
        public static TActivity tActivity = SchemaFactory.Get<TActivity>();
        public static TActivityHistory tActivityHistory = SchemaFactory.Get<TActivityHistory>();
        public static TMessage tMessage = SchemaFactory.Get<TMessage>();
        public static TMessageAttachment tMessageAttachment = SchemaFactory.Get<TMessageAttachment>();
        public static TCustomizedAttributeField tCustomizedAttributeField = SchemaFactory.Get<TCustomizedAttributeField>();


        // Administrative Centre
        //
        public static TAttachmentType tAttachmentType = SchemaFactory.Get<TAttachmentType>(); 
        public static TAnnouncement tAnnouncement = SchemaFactory.Get<TAnnouncement>();
        public static TApplicationSetting tApplicationSetting = SchemaFactory.Get<TApplicationSetting>();
        public static TApplicationSettingService tApplicationSettingService = SchemaFactory.Get<TApplicationSettingService>();
        public static TApplicationSettingSmsKeywordHandler tApplicationSettingSmsKeywordHandler = SchemaFactory.Get<TApplicationSettingSmsKeywordHandler>();
        public static TUser tUser = SchemaFactory.Get<TUser>();
        public static TUserWebPartsPersonalization tUserWebPartsPersonalization = SchemaFactory.Get<TUserWebPartsPersonalization>();
        public static TCodeType tCodeType = SchemaFactory.Get<TCodeType>();
        public static TCode tCode = SchemaFactory.Get<TCode>();
        public static TChecklistResponse tChecklistResponse = SchemaFactory.Get<TChecklistResponse>();
        public static TChecklistResponseSet tChecklistResponseSet = SchemaFactory.Get<TChecklistResponseSet>();
        public static TCalendar tCalendar = SchemaFactory.Get<TCalendar>();
        public static TCalendarHoliday tCalendarHoliday = SchemaFactory.Get<TCalendarHoliday>();
        public static TCraft tCraft = SchemaFactory.Get<TCraft>();
        public static TServiceLevel tServiceLevel = SchemaFactory.Get<TServiceLevel>();
        public static TServiceLevelDetail tServiceLevelDetail = SchemaFactory.Get<TServiceLevelDetail>();
        public static TRole tRole = SchemaFactory.Get<TRole>();
        public static TApprovalHierarchy tApprovalHierarchy = SchemaFactory.Get<TApprovalHierarchy>();
        public static TApprovalHierarchyLevel tApprovalHierarchyLevel = SchemaFactory.Get<TApprovalHierarchyLevel>();
        public static TApprovalProcess tApprovalProcess = SchemaFactory.Get<TApprovalProcess>();
        public static TApprovalProcessLimit tApprovalProcessLimit = SchemaFactory.Get<TApprovalProcessLimit>();
        public static TNotification tNotification = SchemaFactory.Get<TNotification>();
        public static TNotificationMilestones tNotificationMilestones = SchemaFactory.Get<TNotificationMilestones>();
        public static TNotificationHierarchy tNotificationHierarchy = SchemaFactory.Get<TNotificationHierarchy>();
        public static TNotificationHierarchyLevel tNotificationHierarchyLevel = SchemaFactory.Get<TNotificationHierarchyLevel>();
        public static TNotificationProcess tNotificationProcess = SchemaFactory.Get<TNotificationProcess>();
        public static TNotificationProcessTiming tNotificationProcessTiming = SchemaFactory.Get<TNotificationProcessTiming>();
        public static TMessageTemplate tMessageTemplate = SchemaFactory.Get<TMessageTemplate>();
        public static TLanguage tLanguage = SchemaFactory.Get<TLanguage>();
        public static TFunction tFunction = SchemaFactory.Get<TFunction>();
        public static TReportColumnMapping tReportColumnMapping = SchemaFactory.Get<TReportColumnMapping>();
        public static TRoleFunction tRoleFunction = SchemaFactory.Get<TRoleFunction>();

        public static TPosition tPosition = SchemaFactory.Get<TPosition>();
        public static TUserPasswordHistory tUserPasswordHistory = SchemaFactory.Get<TUserPasswordHistory>();

        public static TCustomizedRecordObject tCustomizedRecordObject = SchemaFactory.Get<TCustomizedRecordObject>();
        public static TCustomizedRecordField tCustomizedRecordField = SchemaFactory.Get<TCustomizedRecordField>();
        public static TCustomizedRecordFieldValue tCustomizedRecordFieldValue = SchemaFactory.Get<TCustomizedRecordFieldValue>();
        public static TCustomizedAttributeFieldValue tCustomizedAttributeFieldValue = SchemaFactory.Get<TCustomizedAttributeFieldValue>();        

        // Asset Centre
        //
        public static TLocationTypeParameter tLocationTypeParameter = SchemaFactory.Get<TLocationTypeParameter>();
        public static TLocationTypeUtility tLocationTypeUtility = SchemaFactory.Get<TLocationTypeUtility>();
        public static TLocationType tLocationType = SchemaFactory.Get<TLocationType>();
        public static TLocation tLocation = SchemaFactory.Get<TLocation>();
        public static TEquipmentTypeSpare tEquipmentTypeSpare = SchemaFactory.Get<TEquipmentTypeSpare>();
        public static TEquipmentTypeParameter tEquipmentTypeParameter = SchemaFactory.Get<TEquipmentTypeParameter>();
        public static TEquipmentType tEquipmentType = SchemaFactory.Get<TEquipmentType>();
        public static TEquipment tEquipment = SchemaFactory.Get<TEquipment>();
        public static TChecklist tChecklist = SchemaFactory.Get<TChecklist>();
        public static TChecklistItem tChecklistItem = SchemaFactory.Get<TChecklistItem>();
        public static TOPCAEEvent tOPCAEEvent = SchemaFactory.Get<TOPCAEEvent>();
        public static TOPCAEEventHistory tOPCAEEventHistory = SchemaFactory.Get<TOPCAEEventHistory>();
        public static TOPCAEServer tOPCAEServer = SchemaFactory.Get<TOPCAEServer>();
        public static TOPCDAServer tOPCDAServer = SchemaFactory.Get<TOPCDAServer>();
        public static TPoint tPoint = SchemaFactory.Get<TPoint>();
        public static TReading tReading = SchemaFactory.Get<TReading>();
        public static TPointTrigger tPointTrigger = SchemaFactory.Get<TPointTrigger>();
        public static TLocationTypePoint tLocationTypePoint = SchemaFactory.Get<TLocationTypePoint>();
        public static TEquipmentTypePoint tEquipmentTypePoint = SchemaFactory.Get<TEquipmentTypePoint>();

        // Budget Centre
        //
        public static TAccount tAccount = SchemaFactory.Get<TAccount>();
        public static TBudget tBudget = SchemaFactory.Get<TBudget>();
        public static TBudgetTransactionLog tBudgetTransactionLog = SchemaFactory.Get<TBudgetTransactionLog>();
        public static TBudgetVariationLog tBudgetVariationLog = SchemaFactory.Get<TBudgetVariationLog>();
        public static TBudgetPeriod tBudgetPeriod = SchemaFactory.Get<TBudgetPeriod>();
        public static TBudgetPeriodOpeningBalance tBudgetPeriodOpeningBalance = SchemaFactory.Get<TBudgetPeriodOpeningBalance>();
        public static TBudgetReallocationFrom tBudgetReallocationFrom = SchemaFactory.Get<TBudgetReallocationFrom>();   
        public static TBudgetReallocation tBudgetReallocation = SchemaFactory.Get<TBudgetReallocation>();
        public static TBudgetReallocationTo tBudgetReallocationTo = SchemaFactory.Get<TBudgetReallocationTo>();
        public static TBudgetAdjustment tBudgetAdjustment = SchemaFactory.Get<TBudgetAdjustment>();
        public static TBudgetAdjustmentDetail tBudgetAdjustmentDetail = SchemaFactory.Get<TBudgetAdjustmentDetail>();
        

        // Vendor Centre
        //
        public static TVendor tVendor = SchemaFactory.Get<TVendor>();
        public static TContract tContract = SchemaFactory.Get<TContract>();
        public static TContractPriceMaterial tContractPriceMaterials = SchemaFactory.Get<TContractPriceMaterial>();
        public static TContractPriceService tContractPriceServices = SchemaFactory.Get<TContractPriceService>();
        public static TFixedRate tFixedRate = SchemaFactory.Get<TFixedRate>();

        // Work centre
        //
        public static TWork tWork = SchemaFactory.Get<TWork>();
        public static TWorkCost tWorkCost = SchemaFactory.Get<TWorkCost>();
        public static TWorkCostCheckOutItem tWorkCostCheckOutItem = SchemaFactory.Get<TWorkCostCheckOutItem>();
        public static TWorkChecklistItem tWorkChecklistItem = SchemaFactory.Get<TWorkChecklistItem>();
        public static TWorkChecklistItemResponse tWorkChecklistItemResponse = SchemaFactory.Get<TWorkChecklistItemResponse>();
        public static TWorkParameterReading tWorkParameterReading = SchemaFactory.Get<TWorkParameterReading>();
        public static TScheduledWork tScheduledWork = SchemaFactory.Get<TScheduledWork>();
        public static TScheduledWorkStaggeredEquipment tScheduledWorStaggeredEquipment = SchemaFactory.Get<TScheduledWorkStaggeredEquipment>();
        public static TScheduledWorkStaggeredLocation tScheduledWorkStaggeredLocation = SchemaFactory.Get<TScheduledWorkStaggeredLocation>();
        public static TScheduledWorkChecklist tScheduledWorkChecklist = SchemaFactory.Get<TScheduledWorkChecklist>();
        public static TScheduledWorkCost tScheduledWorkCost = SchemaFactory.Get<TScheduledWorkCost>();
        public static TCase tCase = SchemaFactory.Get<TCase>();

        // Analysis Centre
        //
        public static TDashboard tDashboard = SchemaFactory.Get<TDashboard>();
        public static TDashboardField tDashboardField = SchemaFactory.Get<TDashboardField>();
        public static TReport tReport = SchemaFactory.Get<TReport>();
        public static TReportField tReportField = SchemaFactory.Get<TReportField>();
        public static TReportTemplate tReportTemplate = SchemaFactory.Get<TReportTemplate>();
        public static TReportDataSet tReportDataSet = SchemaFactory.Get<TReportDataSet>();

        // Materials Centre
        //
        public static TCatalogue tCatalogue = SchemaFactory.Get<TCatalogue>();
        public static TStore tStore = SchemaFactory.Get<TStore>();
        public static TStoreBin tStoreBin = SchemaFactory.Get<TStoreBin>();
        public static TStoreBinItem tStoreBinItem = SchemaFactory.Get<TStoreBinItem>();
        public static TStoreBinReservation tStoreBinReservation = SchemaFactory.Get<TStoreBinReservation>();
        public static TStoreAdjust tStoreAdjust = SchemaFactory.Get<TStoreAdjust>();
        public static TStoreAdjustItem tStoreAdjustItem = SchemaFactory.Get<TStoreAdjustItem>();
        public static TStoreCheckIn tStoreCheckIn = SchemaFactory.Get<TStoreCheckIn>();
        public static TStoreCheckInItem tStoreCheckInItem = SchemaFactory.Get<TStoreCheckInItem>();
        public static TStoreCheckOutItem tStoreCheckOutItem = SchemaFactory.Get<TStoreCheckOutItem>();
        public static TStoreCheckOut tStoreCheckOut = SchemaFactory.Get<TStoreCheckOut>();
        public static TStoreItem tStoreItem = SchemaFactory.Get<TStoreItem>();
        public static TStoreItemTransaction tStoreItemTransaction = SchemaFactory.Get<TStoreItemTransaction>();
        public static TStoreTransfer tStoreTransfer = SchemaFactory.Get<TStoreTransfer>();
        public static TStoreTransferItem tStoreTransferItem = SchemaFactory.Get<TStoreTransferItem>();
        public static TUnitConversion tUnitConversion = SchemaFactory.Get<TUnitConversion>();
        public static TUnitConversionTo tUnitConversionTo = SchemaFactory.Get<TUnitConversionTo>();
        public static TStoreRequest tStoreRequest = SchemaFactory.Get<TStoreRequest>();
        public static TStoreRequestItem tStoreRequestItem = SchemaFactory.Get<TStoreRequestItem>();
        public static TStoreRequestItemCheckOut tStoreRequestItemCheckOut = SchemaFactory.Get<TStoreRequestItemCheckOut>();

        // Procurement Centre
        //
        public static TPurchaseSettings tPurchaseSettings = SchemaFactory.Get<TPurchaseSettings>();
        public static TCurrency tCurrency = SchemaFactory.Get<TCurrency>();
        public static TCurrencyExchangeRate tCurrencyExchangeRate = SchemaFactory.Get<TCurrencyExchangeRate>();
        public static TTaxCode tTaxCode = SchemaFactory.Get<TTaxCode>();
        public static TPurchaseBudget tPurchaseBudget = SchemaFactory.Get<TPurchaseBudget>();
        public static TPurchaseBudgetSummary tPurchaseBudgetSummary = SchemaFactory.Get<TPurchaseBudgetSummary>();
        public static TPurchaseRequest tPurchaseRequest = SchemaFactory.Get<TPurchaseRequest>();
        public static TPurchaseRequestItem tPurchaseRequestItem = SchemaFactory.Get<TPurchaseRequestItem>();
        public static TRequestForQuotation tRequestForQuotation = SchemaFactory.Get<TRequestForQuotation>();
        public static TRequestForQuotationItem tRequestForQuotationItem = SchemaFactory.Get<TRequestForQuotationItem>();
        public static TRequestForQuotationVendor tRequestForQuotationVendor = SchemaFactory.Get<TRequestForQuotationVendor>();
        public static TRequestForQuotationVendorItem tRequestForQuotationVendorItem = SchemaFactory.Get<TRequestForQuotationVendorItem>();
        public static TPurchaseOrder tPurchaseOrder = SchemaFactory.Get<TPurchaseOrder>();
        public static TPurchaseOrderItem tPurchaseOrderItem = SchemaFactory.Get<TPurchaseOrderItem>();
        public static TPurchaseOrderReceipt tPurchaseOrderReceipt = SchemaFactory.Get<TPurchaseOrderReceipt>();
        public static TPurchaseOrderReceiptItem tPurchaseOrderReceiptItem = SchemaFactory.Get<TPurchaseOrderReceiptItem>();
        public static TPurchaseInvoice tPurchaseInvoice = SchemaFactory.Get<TPurchaseInvoice>();
        public static TOperatingUnit tOperatingUnit = SchemaFactory.Get<TOperatingUnit>();

        //Utility
        public static TUtility tUtility = SchemaFactory.Get<TUtility>();
        public static TUtilityValue tUtilityValue = SchemaFactory.Get<TUtilityValue>();
        public static TDocumentTemplate tDocumentTemplate = SchemaFactory.Get<TDocumentTemplate>();

        //Report Migration
        public static TReportDataSetMigrate tReportDataSetMigrate = SchemaFactory.Get<TReportDataSetMigrate>();
        public static TReportFieldMigrate tReportFieldMigrate = SchemaFactory.Get<TReportFieldMigrate>();
        public static TReportTemplateMigrate tReportTemplateMigrate = SchemaFactory.Get<TReportTemplateMigrate>();
        public static TReportMigrate tReportMigrate = SchemaFactory.Get<TReportMigrate>();
        public static TRoleMigrate tRoleMigrate = SchemaFactory.Get<TRoleMigrate>();        

        // Running number generator
        //
        public static TRunningNumber tRunningNumber = SchemaFactory.Get<TRunningNumber>();
        public static TRunningNumberGenerator tRunningNumberGenerator = SchemaFactory.Get<TRunningNumberGenerator>();

        // Performance Survey
        //
        public static TSurveyGroup tSurveyGroup = SchemaFactory.Get<TSurveyGroup>();
        public static TSurveyPlanner tSurveyPlanner = SchemaFactory.Get<TSurveyPlanner>();
        public static TSurveyRespondent tSurveyRespondent = SchemaFactory.Get<TSurveyRespondent>();
        public static TSurveyRespondentPortfolio tSurveyRespondentPortfolio = SchemaFactory.Get<TSurveyRespondentPortfolio>();
        public static TSurvey tSurvey = SchemaFactory.Get<TSurvey>();
        public static TSurveyChecklistItem tSurveyChecklistItem = SchemaFactory.Get<TSurveyChecklistItem>();
        public static TSurveyTrade tSurveyTrade = SchemaFactory.Get<TSurveyTrade>();
        public static TSurveyResponseFrom tSurveyResponseFrom = SchemaFactory.Get<TSurveyResponseFrom>();
        public static TSurveyResponseTo tSurveyResponseTo = SchemaFactory.Get<TSurveyResponseTo>();
        public static TSurveyPlannerUpdate tSurveyPlannerUpdate = SchemaFactory.Get<TSurveyPlannerUpdate>();
        public static TSurveyReminder tSurveyReminder = SchemaFactory.Get<TSurveyReminder>();

        //StoreStockTake
        //
        public static TStoreStockTake tStoreStockTake = SchemaFactory.Get<TStoreStockTake>();
        public static TStoreStockTakeBinItem tStoreStockTakeBinItem = SchemaFactory.Get<TStoreStockTakeBinItem>();

        //Background Service
        //
        public static TBackgroundServiceLog tBackgroundServiceLog = SchemaFactory.Get<TBackgroundServiceLog>();
        public static TBackgroundServiceRun tBackgroundServiceRun = SchemaFactory.Get<TBackgroundServiceRun>();
    }
}

