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
 
    public class TVendorPrequalification : LogicLayerSchema<OVendorPrequalification>
    {
        [Size(255)]
        public SchemaString Remarks;
        public SchemaText Background;
        public SchemaText Scope;
        public SchemaText Justification;
        public SchemaDecimal EstimatedContractSum;
        [Size(255)]
        public SchemaString Subject;
        [Size(255)]
        public SchemaString Purpose;
        public SchemaText Evaluation;
        public TVendorPrequalificationVendor VendorPrequalificationVendors { get { return OneToMany<TVendorPrequalificationVendor>("VendorPrequalificationID"); } }
    }


    public abstract class OVendorPrequalification : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract string Remarks { get; set; }
        public abstract String Background { get; set; }
        public abstract String Scope { get; set; }
        public abstract String Justification { get; set; }
        public abstract decimal? EstimatedContractSum { get; set; }
        public abstract string Subject { get; set; }
        public abstract string Purpose { get; set; }
        public abstract String Evaluation { get; set; }

        public abstract DataList<OVendorPrequalificationVendor> VendorPrequalificationVendors {get;set;}
        public void ApproveForCapitaland()
        {
            using (Connection c = new Connection())
            {
                foreach (OVendorPrequalificationVendor vpVendor in this.VendorPrequalificationVendors)
                {
                    if (vpVendor.IsRecommended == 1)
                    {
                        OVendor vendor = TablesLogic.tVendor.Create();
                        vendor.ObjectName = vpVendor.ObjectName;
                        vendor.TaxCodeID = vpVendor.TaxCodeID;
                        vendor.CurrencyID = vpVendor.CurrencyID;
                        vendor.VendorClassificationID = vpVendor.VendorClassificationID;
                        vendor.GSTRegistrationNumber = vpVendor.GSTRegistrationNumber;
                        vendor.CompanyRegistrationNumber = vpVendor.CompanyRegistrationNumber;
                        foreach (OCode vtype in vpVendor.VendorPrequalificationTypes)
                        {
                            vendor.VendorTypes.Add(vtype);
                        }
                        vendor.OperatingAddress = vpVendor.OperatingAddress;
                        vendor.OperatingAddressCity = vpVendor.OperatingAddressCity;
                        vendor.OperatingAddressCountry = vpVendor.OperatingAddressCountry;
                        vendor.OperatingAddressState = vpVendor.OperatingAddressState;
                        vendor.OperatingCellPhone = vpVendor.OperatingCellPhone;
                        vendor.OperatingContactPerson = vpVendor.OperatingContactPerson;
                        vendor.OperatingEmail = vpVendor.OperatingEmail;
                        vendor.OperatingFax = vpVendor.OperatingFax;
                        vendor.OperatingPhone = vpVendor.OperatingPhone;
                        vendor.BillingAddress = vpVendor.BillingAddress;
                        vendor.BillingAddressCity = vpVendor.BillingAddressCity;
                        vendor.BillingAddressCountry = vpVendor.BillingAddressCountry;
                        vendor.BillingAddressState = vpVendor.BillingAddressState;
                        vendor.BillingCellPhone = vpVendor.BillingCellPhone;
                        vendor.BillingContactPerson = vpVendor.BillingContactPerson;
                        vendor.BillingEmail = vpVendor.BillingEmail;
                        vendor.BillingFax = vpVendor.BillingFax;
                        vendor.BillingPhone = vpVendor.BillingPhone;

                        // 2010.08.25
                        // Kim Foong
                        // Added this flag to ensure that the vendor will
                        // appear in the dropdown list in the RFQ page.
                        //
                        vendor.IsDebarred = 0;
                        vendor.Save();
                    }
                }
                this.Save();
                c.Commit();
            }
        }
       public override decimal TaskAmount
       {
          get 
          {
              if (this.EstimatedContractSum == null)
                  return 0;
              else
                return this.EstimatedContractSum.Value; 
          }
       }
       public int NumberOfReccommendedVendors
       {
           get
           {
               int i = 0;
               foreach (OVendorPrequalificationVendor vpVendor in this.VendorPrequalificationVendors)
               {
                   if (vpVendor.IsRecommended == 1)
                       i++;
               }
               return i;
           }
       }
       //public List<Approvers> ApproverList
       //{
       //    get
       //    {
       //        return this.ApproverLists;
       //    }
       //}
       public DateTime SubmitForApprovalDate
       {
           get
           {

               string currentStatus = this.CurrentActivity.CurrentStateName;
               if (currentStatus == "Awarded" || currentStatus == "Close" || currentStatus == "PendingApproval")
               {

                   return Query.Select(TablesLogic.tActivityHistory.ModifiedDateTime.Max())
                               .Where(TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                                                         TablesLogic.tActivityHistory.TriggeringEventName == "SubmitForApproval");

               }
               else
                   return DateTime.Now;
           }
       }
    }
    
}
