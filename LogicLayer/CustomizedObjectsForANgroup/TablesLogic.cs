//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
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
    public partial class TablesLogic : TablesData
    {
        public static TPointTariff tPointTariff = SchemaFactory.Get<TPointTariff>();
        public static TAccountType tAccountType = SchemaFactory.Get<TAccountType>();
        public static TCapitalandCompany tCapitalandCompany = SchemaFactory.Get<TCapitalandCompany>();
        public static TTenantActivity tTenantActivity = SchemaFactory.Get<TTenantActivity>();
        public static TTenantContact tTenantContact = SchemaFactory.Get<TTenantContact>();
        public static TBudgetGroup tBudgetGroup = SchemaFactory.Get<TBudgetGroup>();
        public static TEmailLog tEmailLog = SchemaFactory.Get<TEmailLog>();
        public static TRFQBudgetReallocationFrom tRFQBudgetReallocationFrom = SchemaFactory.Get<TRFQBudgetReallocationFrom>();
        public static TRFQBudgetReallocationTo tRFQBudgetReallocationTo = SchemaFactory.Get<TRFQBudgetReallocationTo>();
        public static TRFQBudgetReallocationToPeriod tRFQBudgetReallocationToPeriod = SchemaFactory.Get<TRFQBudgetReallocationToPeriod>();
        public static TRFQBudgetReallocationFromPeriod tRFQBudgetReallocationFromPeriod = SchemaFactory.Get<TRFQBudgetReallocationFromPeriod>();
        public static TPurchaseOrderPaymentSchedule tPurchaseOrderPaymentSchedule = SchemaFactory.Get<TPurchaseOrderPaymentSchedule>();
        public static TRequestForQuotationPaymentSchedule tRequestForQuotationPaymentSchedule = SchemaFactory.Get<TRequestForQuotationPaymentSchedule>();
        public static TACGData tACGData = SchemaFactory.Get<TACGData>();
        public static TACGDataCarPark tACGDataCarpark = SchemaFactory.Get<TACGDataCarPark>();
        public static TACGDataRevenue tACGDataRevenue = SchemaFactory.Get<TACGDataRevenue>();
        public static TACGDataRevenueItem tACGDataRevenueItem = SchemaFactory.Get<TACGDataRevenueItem>();
        public static TTenantLease tTenantLease = SchemaFactory.Get<TTenantLease>();
        public static TVendorPrequalification tVendorPrequalification = SchemaFactory.Get<TVendorPrequalification>();
        public static TVendorPrequalificationVendor tVendorPrequalificationVendor = SchemaFactory.Get<TVendorPrequalificationVendor>();
        public static TChargeType tChargeType = SchemaFactory.Get<TChargeType>();
        public static TVendorContact tVendorContact = SchemaFactory.Get<TVendorContact>();
        public static TBill tBill = SchemaFactory.Get<TBill>();
        public static TBillItem tBillItem = SchemaFactory.Get<TBillItem>();
        public static TTechnicianRoster tTechnicianRoster = SchemaFactory.Get<TTechnicianRoster>();
        public static TTechnicianRosterItem tTechnicianRosterItem = SchemaFactory.Get<TTechnicianRosterItem>();
        public static TShift tShift = SchemaFactory.Get<TShift>();
        public static TAccessibleDevice tAccessibleDevice = SchemaFactory.Get<TAccessibleDevice>();
        public static TTenantLeaseHOTO tTenantLeaseHOTO = SchemaFactory.Get<TTenantLeaseHOTO>();
        public static TEquipmentReminder tEquipmentReminder = SchemaFactory.Get<TEquipmentReminder>();
        public static TLocationStockTake tLocationStockTake = SchemaFactory.Get<TLocationStockTake>();
        public static TLocationStockTakeItem tLocationStockTakeItem = SchemaFactory.Get<TLocationStockTakeItem>();
        public static TLocationStockTakeReconciliationItem tLocationStockTakeReconciliationItem = SchemaFactory.Get<TLocationStockTakeReconciliationItem>();
        public static TEquipmentWriteOff tEquipmentWriteOff = SchemaFactory.Get<TEquipmentWriteOff>();
        public static TEquipmentWriteOffItem tEquipmentWriteOffItem = SchemaFactory.Get<TEquipmentWriteOffItem>();
        public static TUserDelegatedPosition tUserDelegatedPosition = SchemaFactory.Get<TUserDelegatedPosition>();
        public static TUserPermanentPosition tUserPermanentPosition = SchemaFactory.Get<TUserPermanentPosition>();
		public static TBMSTransmissionStatus tBMSTransmissionStatus = SchemaFactory.Get<TBMSTransmissionStatus>();
        public static TBMSTransmissionStatusItem tBMSTransmissionStatusItem = SchemaFactory.Get<TBMSTransmissionStatusItem>();
        public static TRequestForQuotationItemLocation tRequestForQuotationItemLocation = SchemaFactory.Get<TRequestForQuotationItemLocation>();
        public static TUserCreation tUserCreation = SchemaFactory.Get<TUserCreation>();
        public static TUserCreationUser tUserCreationUser = SchemaFactory.Get<TUserCreationUser>();
        public static TUserUpdate tUserUpdate = SchemaFactory.Get<TUserUpdate>();
        public static TUserUpdateUser tUserUpdateUser = SchemaFactory.Get<TUserUpdateUser>();
        public static TCampaign tCampaign = SchemaFactory.Get<TCampaign>();
        public static TMeter tMeter = SchemaFactory.Get<TMeter>();
        public static TContractReminder tContractReminder = SchemaFactory.Get<TContractReminder>();
        public static TContractServiceLevelSurvey tContractServiceLevelSurvey = SchemaFactory.Get<TContractServiceLevelSurvey>();
        
        public static TInboxReminder tInboxReminder = SchemaFactory.Get<TInboxReminder>();
        public static TInboxReminderItem tInboxReminderItem = SchemaFactory.Get<TInboxReminderItem>();
        public static TInboxReminderItemState tInboxReminderItemState = SchemaFactory.Get<TInboxReminderItemState>();

        // ANGROUP tables
        public static TCustomer tCustomer = SchemaFactory.Get<TCustomer>();
        public static TCustomerAccount tCustomerAccount = SchemaFactory.Get<TCustomerAccount>();
        public static TCustomerAccountRegistration tCustomerAccountRegistration = SchemaFactory.Get<TCustomerAccountRegistration>();
        public static TTransactionHistory tTransactionHistory = SchemaFactory.Get<TTransactionHistory>();
        
   }
}

