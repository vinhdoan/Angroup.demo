//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
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
    /// Summary description for OVendor
    /// </summary>
    [Database("#database"), Map("Vendor")]
    [Serializable] public partial class TVendor : LogicLayerSchema<OVendor>
    {
        public SchemaGuid CurrencyID;
        public SchemaGuid TaxCodeID;

        [Size(255)]
        public SchemaString OperatingAddressCountry;
        [Size(255)]
        public SchemaString OperatingAddressState;
        [Size(255)]
        public SchemaString OperatingAddressCity;
        [Size(1000)]
        public SchemaString OperatingAddress;
        public SchemaString OperatingCellPhone;
        public SchemaString OperatingEmail;
        public SchemaString OperatingFax;
        public SchemaString OperatingPhone;
        public SchemaString OperatingContactPerson;

        [Size(255)]
        public SchemaString BillingAddressCountry;
        [Size(255)]
        public SchemaString BillingAddressState;
        [Size(255)]
        public SchemaString BillingAddressCity;
        [Size(255)]
        public SchemaString BillingAddress;
        public SchemaString BillingCellPhone;
        public SchemaString BillingEmail;
        public SchemaString BillingFax;
        public SchemaString BillingPhone;
        public SchemaString BillingContactPerson;

        [Default(0)]
        public SchemaInt IsDebarred;
        public SchemaDateTime DebarmentStartDate;
        public SchemaDateTime DebarmentEndDate;
        [Size(255)]
        public SchemaString DebarmentReason;
        public SchemaInt DebarmentNotification1Days;
        public SchemaInt DebarmentNotification2Days;
        public SchemaInt DebarmentNotification3Days;
        public SchemaInt DebarmentNotification4Days;
        public SchemaGuid NotifyUser1ID;
        public SchemaGuid NotifyUser2ID;
        public SchemaGuid NotifyUser3ID;
        public SchemaGuid NotifyUser4ID;
        public SchemaDateTime LastNotificationDate;
        public SchemaGuid VendorClassificationID;

        public TTaxCode TaxCode { get { return OneToOne<TTaxCode>("TaxCodeID"); } }
        public TCode VendorClassification { get { return OneToOne<TCode>("VendorClassificationID"); } }
        public TCode VendorTypes { get { return ManyToMany<TCode>("VendorType", "VendorID", "VendorTypeID"); } }
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } } 
        public TUser NotifyUser1 { get { return OneToOne<TUser>("NotifyUser1ID"); } }
        public TUser NotifyUser2 { get { return OneToOne<TUser>("NotifyUser2ID"); } }
        public TUser NotifyUser3 { get { return OneToOne<TUser>("NotifyUser3ID"); } }
        public TUser NotifyUser4 { get { return OneToOne<TUser>("NotifyUser4ID"); } }
    }


    /// <summary>
    /// Represents a vendor that provides services or materials
    /// to the user's company.
    /// </summary>
    [Serializable]
    public abstract partial class OVendor : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the currency
        /// table that indicates which default currency this vendor issues
        /// its purchase orders or invoices in.
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the TaxCode
        /// table that indicates which default tax code this vendor 
        /// invoices in.
        /// </summary>
        public abstract Guid? TaxCodeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating address of this vendor.
        /// </summary>
        public abstract string OperatingAddressCountry { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating address of this vendor.
        /// </summary>
        public abstract string OperatingAddressState { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating address of this vendor.
        /// </summary>
        public abstract string OperatingAddressCity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating address of this vendor.
        /// </summary>
        public abstract string OperatingAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating contact of this vendor.
        /// </summary>
        public abstract string OperatingCellPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating contact of this vendor.
        /// </summary>
        public abstract string OperatingEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating contact of this vendor.
        /// </summary>
        public abstract string OperatingFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating contact of this vendor.
        /// </summary>
        public abstract string OperatingPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the operating contact of this vendor.
        /// </summary>
        public abstract string OperatingContactPerson { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing address of this vendor.
        /// </summary>
        public abstract string BillingAddressCountry { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing address of this vendor.
        /// </summary>
        public abstract string BillingAddressState { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing address of this vendor.
        /// </summary>
        public abstract string BillingAddressCity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing address of this 
        /// vendor.
        /// </summary>
        public abstract string BillingAddress { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing contact of this vendor.
        /// </summary>
        public abstract string BillingCellPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing contact of this vendor.
        /// </summary>
        public abstract string BillingEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing contact of this vendor.
        /// </summary>
        public abstract string BillingFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing contact of this vendor.
        /// </summary>
        public abstract string BillingPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the billing contact of this vendor.
        /// </summary>
        public abstract string BillingContactPerson { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether this 
        /// vendor has been debarred.
        /// </summary>        
        public abstract int? IsDebarred { get; set; }

        /// <summary>
        /// [Column] Gets or sets the end date from which the vendor will 
        /// be debarred.
        /// </summary>
        public abstract DateTime? DebarmentStartDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the end date until which the vendor has 
        /// been debarred.
        /// </summary>
        public abstract DateTime? DebarmentEndDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the reason this vendor has been 
        /// debarred.
        /// </summary>
        public abstract string DebarmentReason { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days before the 
        /// debarment end date to send an e-mail reminder. The user 
        /// may specify up to four periods.
        /// </summary>
        public abstract int? DebarmentNotification1Days { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days before the 
        /// debarment end date to send an e-mail reminder. The user 
        /// may specify up to four periods.
        /// </summary>
        public abstract int? DebarmentNotification2Days { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days before the 
        /// debarment end date to send an e-mail reminder. The user 
        /// may specify up to four periods.
        /// </summary>
        public abstract int? DebarmentNotification3Days { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days before the 
        /// debarment end date to send an e-mail reminder. The user 
        /// may specify up to four periods.
        /// </summary>
        public abstract int? DebarmentNotification4Days { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser1ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser2ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser3ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table.
        /// </summary>
        public abstract Guid? NotifyUser4ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the last vendor debarment
        /// notification was sent.
        /// </summary>
        public abstract DateTime? LastNotificationDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table.
        /// </summary>
        public abstract Guid? VendorClassificationID { get; set; }

        /// <summary>
        /// Gets or sets the OTaxCode object that represents
        /// the default tax code that the vendor invoices in.
        /// </summary>
        public abstract OTaxCode TaxCode { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents the vendor classification.
        /// </summary>
        public abstract OCode VendorClassification { get; set;}

        /// <summary>
        /// Gets a many-to-many list of OCode objects that represents a 
        /// list of vendor types applicable to this vendor.
        /// </summary>
        public abstract DataList<OCode> VendorTypes { get;}

        /// <summary>
        /// Gets or sets the OUser object that represents the user who 
        /// will be notified when the debarment reminder notification is 
        /// due.
        /// </summary>
        public abstract OUser NotifyUser1 { get; set;}

        /// <summary>
        /// Gets or sets the OUser object that represents the user who 
        /// will be notified when the debarment reminder notification is 
        /// due.
        /// </summary>
        public abstract OUser NotifyUser2 { get; set;}

        /// <summary>
        /// Gets or sets the OUser object that represents the user who 
        /// will be notified when the debarment reminder notification is 
        /// due.
        /// </summary>
        public abstract OUser NotifyUser3 { get; set;}

        /// <summary>
        /// Gets or sets the OUser object that represents the user who 
        /// will be notified when the debarment reminder notification is 
        /// due.
        /// </summary>
        public abstract OUser NotifyUser4 { get; set;}

        /// <summary>
        /// [One-to-one join this.CurrencyID = Currency.ObjectID]
        /// Gets or sets the default currency that this vendor
        /// issues its invoices and purchase orders in.
        /// </summary>
        public abstract OCurrency Currency { get; set; }


        /// <summary>
        /// Gets a list of all vendors.
        /// </summary>
        /// <returns></returns>
        public static List<OVendor> GetVendors()
        {
            return TablesLogic.tVendor[Query.True];
        }


        /// <summary>
        /// Gets a list of all vendors.
        /// </summary>
        /// <returns></returns>
        public static List<OVendor> GetVendors(Guid? includingVendorId)
        {
            return TablesLogic.tVendor.LoadList(
                TablesLogic.tVendor.ObjectID == includingVendorId |
                TablesLogic.tVendor.IsDeleted == 0, true);
        }


        /// <summary>
        /// Gets a list of all vendors by a date (which will
        /// filter the list of vendors based on their debarment
        /// dates).
        /// </summary>
        /// <returns></returns>
        public static List<OVendor> GetVendors(DateTime date, Guid? includingVendorId)
        {

            return TablesLogic.tVendor.LoadList(
                ((
                TablesLogic.tVendor.IsDeleted == 0 &
                (TablesLogic.tVendor.IsDebarred == 0 |
                TablesLogic.tVendor.DebarmentStartDate > date |
                TablesLogic.tVendor.DebarmentEndDate < date)) |
                TablesLogic.tVendor.ObjectID == includingVendorId),
                true,
                TablesLogic.tVendor.ObjectName.Asc);
        }


        /// <summary>
        /// This method to return past date so that the event will be triggered
        /// </summary>
        /// <param name="reminderDays"></param>
        /// <returns></returns>

        public DateTime GetDebarmentReminderDate(int? reminderDays)
        {
            if (reminderDays == null || DebarmentEndDate == null)
            {
                //return a past date so that the event will be triggered
                return DateTime.Now.AddYears(-5);
            }
            return DebarmentEndDate.Value.AddDays(-reminderDays.Value);
        }

    }

}