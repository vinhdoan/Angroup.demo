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

    public partial class TVendor : LogicLayerSchema<OVendor>
    {
        [Default(0)]
        public SchemaInt IsApproved;

        public TVendorEvaluation VendorEvaluations { get { return OneToMany<TVendorEvaluation>("VendorID"); } }

        //Nguyen Quoc Phuong 19-Nov-2012
        [Default(0)]
        public SchemaInt IsInActive;
        [Default(0)]
        public SchemaInt IsFromCRV;
        [Size(200)]
        public SchemaString CRVOperatingAddressBlockHouseNo;
        [Size(300)]
        public SchemaString CRVOperatingAddressStreetName;
        [Size(50)]
        public SchemaString CRVOperatingAddressUnitNo;
        [Size(200)]
        public SchemaString CRVOperatingAddressBuildingname;
        public SchemaDateTime CRVLastRetrieveDateTime;
        public SchemaString CRVVendorID;
        [Size(255)]
        public SchemaString OriginatingSBU;
        [Size(255)]
        public SchemaString CRVIncCountry;
        [Size(255)]
        public SchemaString CAMPSOriginalName;
        //End Nguyen Quoc Phuong 19-Nov-2012
    }


    public abstract partial class OVendor : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// <summary>
        /// 
        /// </summary>        
        public abstract int? IsApproved {get;set;}

        /// <summary>
        /// 
        /// </summary>
        public abstract DataList<OVendorEvaluation> VendorEvaluations { get; }

        //Nguyen Quoc Phuong 19-Nov-2012
        public abstract int? IsInActive { get; set; }
        public abstract int? IsFromCRV { get; set; }
        public abstract string CRVOperatingAddressBlockHouseNo { get; set; }
        public abstract string CRVOperatingAddressStreetName { get; set; }
        public abstract string CRVOperatingAddressUnitNo { get; set; }
        public abstract string CRVOperatingAddressBuildingname { get; set; }
        public abstract DateTime? CRVLastRetrieveDateTime { get; set; }
        public abstract string CRVVendorID { get; set; }
        public abstract string OriginatingSBU { get; set; }
        public abstract string CRVIncCountry { get; set; }
        public abstract string CAMPSOriginalName { get; set; }
        //End Nguyen Quoc Phuong 19-Nov-2012

        /// <summary>
        /// 
        /// </summary>
        public string IsApprovedText
        {
            get
            {
                if (this.IsApproved == 1)
                    return Resources.Strings.General_Yes;
                else
                    return Resources.Strings.General_No;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public string IsDebarredText
        {
            get
            {
                if (this.IsDebarred == 1)
                    return Resources.Strings.General_Yes;
                else
                    return Resources.Strings.General_No;
            }
        }

        //Nguyen Quoc Phuong 19-Nov-2012
        public string IsActiveText
        {
            get
            {
                if (this.IsInActive == 0)
                    return Resources.Strings.General_Yes;
                else
                    return Resources.Strings.General_No;
            }
        }
        //End Nguyen Quoc Phuong 19-Nov-2012

        //Nguyen Quoc Phuong 14-Dec-2012
        public bool IsDuplicateCompanyRegistrationNumber()
        {
            OVendor vendor = TablesLogic.tVendor.Load(TablesLogic.tVendor.CompanyRegistrationNumber == this.CompanyRegistrationNumber &
                                     TablesLogic.tVendor.ObjectID != this.ObjectID);
            return vendor != null && !String.IsNullOrEmpty(this.CompanyRegistrationNumber);
        }
        //End Nguyen Quoc Phuong 14-Dec-2012

        //Nguyen Quoc Phuong 14-Dec-2012
        public bool? IsExistedInCRV()
        {
            if (String.IsNullOrEmpty(this.CompanyRegistrationNumber))
                return false;

            OCRVVendorService VendorService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);
            ArrayList SystemCodes = TablesLogic.tLocation.SelectDistinct(TablesLogic.tLocation.SystemCode)
                .Where(TablesLogic.tLocation.SystemCode != null);
            if (SystemCodes.Count == 0) return null;
            foreach (string SystemCode in SystemCodes)
            {
                string[] Vendors = VendorService.SearchVendor(SystemCode, this.CompanyRegistrationNumber, string.Empty);
                if (Vendors == null) return null;
                if (Vendors.Length > 0) return true;
            }
            return false;
        }
        //End Nguyen Quoc Phuong 14-Dec-2012

        /// <summary>
        /// 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public static bool AllowAccessDebarredVendors(OUser user, string objectType)
        {

            List<OPosition> positions = user.GetPositionsByObjectType(objectType);
            if (positions.Count == 0)
                return false;

            OPosition position = positions.Find((p) => p.AppliesToAllDebarredVendors == 1);
            if (position != null)
                return true;

            return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public static bool AllowAccessNonApprovedVendors(OUser user, string objectType)
        {

            List<OPosition> positions = user.GetPositionsByObjectType(objectType);
            if (positions.Count == 0)
                return false;

            OPosition position = positions.Find((p) => p.AppliesToAllNonApprovedVendors == 1);
            if (position != null)
                return true;

            return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="date"></param>
        /// <param name="includingVendorId"></param>
        /// <returns></returns>
        public static List<OVendor> GetVendors(DateTime date, Guid? includingVendorId, OUser user, string objectType)
        {
            ExpressionCondition allowDebarred = (AllowAccessDebarredVendors(user, objectType) ? Query.True : Query.False);
            ExpressionCondition allowNonApproved = (AllowAccessNonApprovedVendors(user, objectType) ? Query.True : Query.False);

            return TablesLogic.tVendor.LoadList(
                (
                    TablesLogic.tVendor.IsDeleted == 0 &
                    (
                        allowDebarred |
                        TablesLogic.tVendor.IsDebarred == 0 | 
                        TablesLogic.tVendor.DebarmentStartDate > date |
                        TablesLogic.tVendor.DebarmentEndDate < date
                    ) &
                    (
                        allowNonApproved |
                        TablesLogic.tVendor.IsApproved == 1
                    )&
                    TablesLogic.tVendor.IsInActive == 0 //Nguyen Quoc Phuong 19-Nov-2012
                ) |
                TablesLogic.tVendor.ObjectID == includingVendorId,
                true,
                TablesLogic.tVendor.ObjectName.Asc);
        }

        //CRV vendor create/update
        public static void SyncVendorInfo(string CRVVendorID, string SystemCode, DateTime ServiceStartTime, ref int updateCounter, ref int createCounter)
        {            
            OCRVVendorService CRVWebService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);
            CRVWebService.CRVVendor = CRVWebService.GetVendor(
                                            SystemCode,
                                            CRVVendorID);
            if (CRVWebService.CRVVendor == null || CRVWebService.CRVVendor.Status == CRVendorStatus.INACTIVE) return;

            OVendor Vendor = TablesLogic.tVendor.Load(TablesLogic.tVendor.CRVVendorID == CRVVendorID);
            if (Vendor != null && Vendor.CRVLastRetrieveDateTime >= ServiceStartTime) return;
            if (Vendor == null)
            {
                List<OVendor> Vendors = TablesLogic.tVendor.LoadList(TablesLogic.tVendor.CompanyRegistrationNumber == CRVWebService.CRVVendor.CompanyRegistrationNumber);
                if (Vendors.Count > 0)
                {
                    Vendor = Vendors[0];
                    updateCounter++;
                }
                else
                {
                    Vendor = TablesLogic.tVendor.Create();
                    Vendor.IsDebarred = 0;
                    createCounter++;
                }
                Vendor.CRVVendorID = CRVVendorID;
            }
            else
                updateCounter++;

            Vendor.CompanyRegistrationNumber = CRVWebService.CRVVendor.CompanyRegistrationNumber;
            Vendor.CRVIncCountry = CRVWebService.CRVVendor.IncCountry;
            Vendor.OriginatingSBU = CRVWebService.CRVVendor.SBU;
            //Vendor.CRVOperatingAddressBlockHouseNo = CRVWebService.CRVVendor.OperatingAddressBlockHouseNo;
            //Vendor.CRVOperatingAddressStreetName = CRVWebService.CRVVendor.OperatingAddressStreetName;
            //Vendor.CRVOperatingAddressUnitNo = CRVWebService.CRVVendor.OperatingAddressUnitNo;
            //Vendor.CRVOperatingAddressBuildingname = CRVWebService.CRVVendor.OperatingAddressBuildingname;
            //Vendor.OperatingAddress = (string.IsNullOrEmpty(Vendor.CRVOperatingAddressBlockHouseNo) ? string.Empty : Vendor.CRVOperatingAddressBlockHouseNo + ", ") +
            //                          (string.IsNullOrEmpty(Vendor.CRVOperatingAddressStreetName) ? string.Empty : Vendor.CRVOperatingAddressStreetName + ", ") +
            //                          (string.IsNullOrEmpty(Vendor.CRVOperatingAddressUnitNo) ? string.Empty : Vendor.CRVOperatingAddressUnitNo + ", ") +
            //                          (string.IsNullOrEmpty(Vendor.CRVOperatingAddressBuildingname) ? string.Empty : Vendor.CRVOperatingAddressBuildingname);
            //Vendor.OperatingAddressCity = CRVWebService.CRVVendor.OperatingAddressCity;
            //Vendor.OperatingAddressCountry = CRVWebService.CRVVendor.OpsCountry;
            //Vendor.OperatingAddressPostalCode = CRVWebService.CRVVendor.OperatingAddressPostalCode;
            Vendor.ObjectName = CRVWebService.CRVVendor.VendorVersion.ObjectName;
            //OCode VendorClassification = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == CRVWebService.CRVVendor.VendorVersion.CRVVendorSpecs
            //Vendor.VendorClassification

            string ConfirmVendorRetrieved = CRVWebService.ConfirmVendorRetrieved(
                                                SystemCode,
                                                CRVVendorID);
            if (ConfirmVendorRetrieved == null) return;
            if (ConfirmVendorRetrieved == Resources.Strings.NO_SUBSCRIPTION_FOUND) return;

            Vendor.CRVLastRetrieveDateTime = DateTime.ParseExact(ConfirmVendorRetrieved, "dd/MM/yyyy HH:mm:ss", null);
            Vendor.IsFromCRV = 1;
            Vendor.IsApproved = 1;
            //Vendor.IsDebarred = 0;
            if (CRVWebService.CRVVendor.Status == CRVendorStatus.UNLISTED)
                Vendor.IsInActive = 1;

            using (Connection c = new Connection())
            {
                Vendor.Save();
                c.Commit();
            }
        }
    }

}
