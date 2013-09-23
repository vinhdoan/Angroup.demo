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

    public class TVendorPrequalificationVendor : LogicLayerSchema<OVendorPrequalificationVendor>
    {
        public SchemaGuid CurrencyID;
        public SchemaGuid TaxCodeID;
        public SchemaGuid VendorClassificationID;

        [Size(255)]
        public SchemaString OperatingAddressCountry;
        [Size(255)]
        public SchemaString OperatingAddressState;
        [Size(255)]
        public SchemaString OperatingAddressCity;
        [Size(255)]
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

        [Size(255)]
        public SchemaString Description;
        public SchemaGuid VendorPrequalificationID;
        [Size(255)]
        public SchemaString FinancialEvaluation;
        [Size(255)]
        public SchemaString PerformanceAppraisal;
        public SchemaInt IsRecommended;

        public SchemaInt IsInterestedParty;

        public SchemaString GSTRegistrationNumber;
        public SchemaString CompanyRegistrationNumber;

        public TCode VendorPrequalificationTypes { get { return ManyToMany<TCode>("VendorPrequalificationType", "VendorPrequalificationID", "VendorTypeID"); } }
        public TTaxCode TaxCode { get { return OneToOne<TTaxCode>("TaxCodeID"); } }
        public TCode VendorClassification { get { return OneToOne<TCode>("VendorClassificationID"); } }
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } } 

    }


 
    public abstract class OVendorPrequalificationVendor : LogicLayerPersistentObject
    {
        public abstract Guid? CurrencyID { get; set; }
        public abstract Guid? TaxCodeID { get; set; }
        public abstract Guid? VendorClassificationID { get; set; }
        public abstract int? IsInterestedParty { get; set; }

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


        public abstract string Description { get; set; }
        public abstract Guid? VendorPrequalificationID { get; set; }
        public abstract string FinancialEvaluation { get; set; }
        public abstract string PerformanceAppraisal { get; set; }
        public abstract int? IsRecommended { get; set; }

        public abstract string GSTRegistrationNumber { get; set; }
        public abstract string CompanyRegistrationNumber { get; set; }

        public abstract DataList<OCode> VendorPrequalificationTypes { get; set; }
        public abstract OTaxCode TaxCode { get; set; }
        public abstract OCode VendorClassification { get; set; }
        public abstract OCurrency Currency { get; set; }
        public string IsRecommendedText
        {
            get
            {
                if (this.IsRecommended == 1)
                    return "Yes";
                else
                    return "No";
            }
        }

    }

}
