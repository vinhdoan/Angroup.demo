//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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
        public SchemaGuid DefaultAMOSWorkChargeTypeID;
        //public SchemaInt AmosChargesDescriptionType;
        public SchemaInt BudgetNotificationPolicy;

        // Used to skip Out of Office email reply from Approvers
        [Size(255)]
        public SchemaString BlockedEmailSubjectKeywords;

        public TChargeType ChargeType { get { return OneToOne<TChargeType>("DefaultAMOSWorkChargeTypeID"); } }

        //ACG
        //public SchemaGuid ACGTenancyWorksAccountID;
        //public SchemaGuid ACGTypeOfWorkFeedbackID;
        //public TAccount ACGMaintenanceRRAccounts { get { return ManyToMany<TAccount>("ApplicationSettingACGMaintenanceRRAccount", "ApplicationSettingID", "AccountID"); } }
        //public TAccount ACGMaintenanceStatutoryAccounts { get { return ManyToMany<TAccount>("ApplicationSettingACGMaintenanceStatutoryAccount", "ApplicationSettingID", "AccountID"); } }
        //public TAccount ACGMaintenanceMiscAccounts { get { return ManyToMany<TAccount>("ApplicationSettingACGMaintenanceMiscAccount", "ApplicationSettingID", "AccountID"); } }
        //public TAccount ACGTenancyWorksAccount { get { return OneToOne<TAccount>("ACGTenancyWorksAccountID"); } }
        //public TCode ACGTypeOfWorkFeedback { get { return OneToOne<TCode>("ACGTypeOfWorkFeedbackID"); } }

        //Nguyen Quoc Phuong 19-Nov-2012
        [Size(1000)]
        public SchemaString CRVVendorServiceURL;
        [Size(1000)]
        public SchemaString CRVTenderServiceURL;
        public SchemaString SystemCode;
        [Size(1000)]
        public SchemaString CRVVendorViewPageURL;
        public SchemaString CRVVendorViewPageType;
        //End Nguyen Quoc Phuong 19-Nov-2012
        [Size(1000)]
        public SchemaString CRVURL;
    }

    public abstract partial class OApplicationSetting : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract Guid? DefaultAMOSWorkChargeTypeID { get; set; }
        public abstract int? BudgetNotificationPolicy { get; set; }

        // Used to skip Out of Office email reply from Approvers
        public abstract string BlockedEmailSubjectKeywords { get; set; }

        public abstract OChargeType ChargeType { get; }

        //ACG
        //public abstract Guid? ACGTenancyWorksAccountID { get; set; }
        //public abstract Guid? ACGTypeOfWorkFeedbackID { get; set; }
        //public abstract DataList<OAccount> ACGMaintenanceRRAccounts { get; set; }
        //public abstract DataList<OAccount> ACGMaintenanceStatutoryAccounts { get; set; }
        //public abstract DataList<OAccount> ACGMaintenanceMiscAccounts { get; set; }
        //public abstract OAccount ACGTenancyWorksAccount { get; set; }
        //public abstract OCode ACGTypeOfWorkFeedback { get; set; }

        //Nguyen Quoc Phuong 19-Nov-2012
        public abstract string CRVVendorServiceURL { get; set; }
        public abstract string CRVTenderServiceURL { get; set; }
        public abstract string SystemCode { get; set; }
        public abstract string CRVVendorViewPageURL { get; set; }
        public abstract string CRVVendorViewPageType { get; set; }
        //End Nguyen Quoc Phuong 19-Nov-2012

        public abstract string CRVURL { get; set; }
    }

    public class BudgetNotificationMode
    {
        public const int Both = 0;
        public const int Total = 1;
        public const int Interval = 2;
    }

    public enum EnumApplicationGeneral
    {
        No = 0,
        Yes = 1
    }
}
