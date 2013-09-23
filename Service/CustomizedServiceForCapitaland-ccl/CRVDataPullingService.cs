//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO.Ports;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;
using System.Collections;
using System.Data.Sql;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;


namespace Service
{
    /// <summary>
    /// Nguyen Quoc Phuong 19-Nov-2012
    /// </summary>
    public partial class CRVDataPullingService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            DateTime ServiceStartTime = System.DateTime.Now;
            int updateCounter = 0;
            int createCounter = 0;
            OCRVVendorService CRVWebService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);

            ArrayList SystemCodes = TablesLogic.tLocation.SelectDistinct(TablesLogic.tLocation.SystemCode)
                .Where(TablesLogic.tLocation.SystemCode != null);
            foreach (string SystemCode in SystemCodes)
            {

                //ArrayList VendorBizRegList = TablesLogic.tVendor.SelectDistinct(TablesLogic.tVendor.CompanyRegistrationNumber)
                //                                .Where(TablesLogic.tVendor.IsDeleted == 0 &
                //                                       TablesLogic.tVendor.IsInActive == 0 & 
                //                                       TablesLogic.tVendor.IsDebarred == 0 &
                //                                       TablesLogic.tVendor.CompanyRegistrationNumber != string.Empty &
                //                                       TablesLogic.tVendor.CompanyRegistrationNumber != null);
                //SubscribedVendors(VendorBizRegList.ToArray(), SystemCode);
                //SyncVendorClassification(SystemCode);//Under-Construction
                //SyncVendorTradeType(SystemCode);//Under-Construction
                string[] OutdatedAndNewVendorList = CRVWebService.GetOutdatedAndNewVendorList(SystemCode);                
                if (OutdatedAndNewVendorList != null)
                    for (int i = 0; i < OutdatedAndNewVendorList.Length; i++)       
                        OVendor.SyncVendorInfo(OutdatedAndNewVendorList[i], SystemCode, ServiceStartTime, ref updateCounter, ref createCounter);                
            }

            LogEvent(String.Format("{0} vendor(s) updated. {1} vendor(s) created.", updateCounter, createCounter), BackgroundLogMessageType.Information);
        }

        public void SyncVendorClassification(string SystemCode)
        {
            OCRVVendorService CRVWebService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);
            CRVWebService.Codes = CRVWebService.GetVendorClassificationCodes(SystemCode);
            if (CRVWebService.Codes == null) return;

            OCode Parent = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == "VendorClassification" &
                                                  TablesLogic.tCode.CodeType.ObjectName == "VendorRelated");
            OCode CodeType = TablesLogic.tCode.Load(TablesLogic.tCode.CodeType.ObjectName == "VendorClassification");
            if (Parent == null) return;
            for (int i = 0; i < CRVWebService.Codes.Length; i++)
            {
                OCode VendorClassification = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == CRVWebService.Codes[i].ObjectName.Trim() &
                                                            TablesLogic.tCode.CodeTypeID == CodeType.ObjectID &
                                                            TablesLogic.tCode.ParentID == Parent.ObjectID);
                if (VendorClassification == null)
                {
                    VendorClassification = TablesLogic.tCode.Create();
                    VendorClassification.ParentID = Parent.ObjectID;
                    VendorClassification.CodeTypeID = CodeType.ObjectID;
                    VendorClassification.ObjectName = CRVWebService.Codes[i].ObjectName.Trim();
                    using (Connection c = new Connection())
                    {
                        VendorClassification.Save();
                        c.Commit();
                    }
                }
            }
        }

        public void SyncVendorTradeType(string SystemCode)
        {
            OCRVVendorService CRVWebService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);
            CRVWebService.Codes = CRVWebService.GetVendorTypeCodes(SystemCode);
            if (CRVWebService.Codes == null) return;

            OCode Parent = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == "VendorType" &
                                                  TablesLogic.tCode.CodeType.ObjectName == "VendorRelated");
            OCode CodeType = TablesLogic.tCode.Load(TablesLogic.tCode.CodeType.ObjectName == "VendorType");
            if (Parent == null) return;
            for (int i = 0; i < CRVWebService.Codes.Length; i++)
            {
                OCode VendorType = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == CRVWebService.Codes[i].ObjectName.Trim() &
                                                            TablesLogic.tCode.CodeTypeID == CodeType.ObjectID &
                                                            TablesLogic.tCode.ParentID == Parent.ObjectID);
                if (VendorType == null)
                {
                    VendorType = TablesLogic.tCode.Create();
                    VendorType.ParentID = Parent.ObjectID;
                    VendorType.CodeTypeID = CodeType.ObjectID;
                    VendorType.ObjectName = CRVWebService.Codes[i].ObjectName.Trim();
                    using (Connection c = new Connection())
                    {
                        VendorType.Save();
                        c.Commit();
                    }
                }
            }
        }

        //Move the method to logiclayer
        //public void SyncVendorInfo(string CRVVendorID, string SystemCode, DateTime ServiceStartTime, int updateCounter, int createCounter)
        //{
        //    OCRVVendorService CRVWebService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);
        //    CRVWebService.CRVVendor = CRVWebService.GetVendor(
        //                                    SystemCode,
        //                                    CRVVendorID);
        //    if (CRVWebService.CRVVendor == null || CRVWebService.CRVVendor.Status == CRVendorStatus.INACTIVE) return;
            
        //    OVendor Vendor = TablesLogic.tVendor.Load(TablesLogic.tVendor.CRVVendorID == CRVVendorID);
        //    if (Vendor != null && Vendor.CRVLastRetrieveDateTime >= ServiceStartTime) return;
        //    if (Vendor == null)
        //    {
        //        List<OVendor> Vendors = TablesLogic.tVendor.LoadList(TablesLogic.tVendor.CompanyRegistrationNumber == CRVWebService.CRVVendor.CompanyRegistrationNumber);
        //        if (Vendors.Count > 0)
        //        {
        //            Vendor = Vendors[0];
        //            updateCounter++;
        //        }
        //        else
        //        {
        //            Vendor = TablesLogic.tVendor.Create();
        //            createCounter++;
        //        }
        //        Vendor.CRVVendorID = CRVVendorID;
        //    }

        //    Vendor.CompanyRegistrationNumber = CRVWebService.CRVVendor.CompanyRegistrationNumber;
        //    Vendor.CRVIncCountry = CRVWebService.CRVVendor.IncCountry;
        //    Vendor.OriginatingSBU = CRVWebService.CRVVendor.SBU;
        //    Vendor.CRVOperatingAddressBlockHouseNo = CRVWebService.CRVVendor.OperatingAddressBlockHouseNo;
        //    Vendor.CRVOperatingAddressStreetName = CRVWebService.CRVVendor.OperatingAddressStreetName;
        //    Vendor.CRVOperatingAddressUnitNo = CRVWebService.CRVVendor.OperatingAddressUnitNo;
        //    Vendor.CRVOperatingAddressBuildingname = CRVWebService.CRVVendor.OperatingAddressBuildingname;
        //    Vendor.OperatingAddress = (string.IsNullOrEmpty(Vendor.CRVOperatingAddressBlockHouseNo) ? string.Empty : Vendor.CRVOperatingAddressBlockHouseNo + ", ") +
        //                              (string.IsNullOrEmpty(Vendor.CRVOperatingAddressStreetName) ? string.Empty : Vendor.CRVOperatingAddressStreetName + ", ") +
        //                              (string.IsNullOrEmpty(Vendor.CRVOperatingAddressUnitNo) ? string.Empty : Vendor.CRVOperatingAddressUnitNo + ", ") +
        //                              (string.IsNullOrEmpty(Vendor.CRVOperatingAddressBuildingname) ? string.Empty : Vendor.CRVOperatingAddressBuildingname);
        //    Vendor.OperatingAddressCity = CRVWebService.CRVVendor.OperatingAddressCity;
        //    Vendor.OperatingAddressCountry = CRVWebService.CRVVendor.OpsCountry;
        //    Vendor.OperatingAddressPostalCode = CRVWebService.CRVVendor.OperatingAddressPostalCode;
        //    Vendor.ObjectName = CRVWebService.CRVVendor.VendorVersion.ObjectName;
        //    //OCode VendorClassification = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == CRVWebService.CRVVendor.VendorVersion.CRVVendorSpecs
        //    //Vendor.VendorClassification

        //    string ConfirmVendorRetrieved = CRVWebService.ConfirmVendorRetrieved(
        //                                        SystemCode,
        //                                        CRVVendorID);
        //    if (ConfirmVendorRetrieved == null) return;
        //    if (ConfirmVendorRetrieved == Resources.Strings.NO_SUBSCRIPTION_FOUND) return;

        //    Vendor.CRVLastRetrieveDateTime = DateTime.ParseExact(ConfirmVendorRetrieved, "dd/MM/yyyy HH:mm:ss", null);
        //    Vendor.IsFromCRV = 1;
        //    Vendor.IsApproved = 1;
        //    Vendor.IsDebarred = 0;
        //    if (CRVWebService.CRVVendor.Status == CRVendorStatus.UNLISTED)
        //        Vendor.IsInActive = 1;

        //    using (Connection c = new Connection())
        //    {
        //        Vendor.Save();
        //        c.Commit();
        //    }
        //}

        /// <summary>
        /// For testing Only
        /// </summary>
        public void UnsubscribedVendors(string[] OutdatedAndNewVendorList, string SystemCode)
        {
        }

        ///// <summary>
        ///// For testing Only
        ///// </summary>
        //public void SubscribedVendors(object[] VendorBizRegList, string SystemCode)
        //{
        //    OCRVVendorService CRVWebService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);
        //    foreach(string VendorBizReg in VendorBizRegList)
        //    {
        //        int? result = CRVWebService.SubscribeVendor(
        //                        SystemCode,
        //                        VendorBizReg,
        //                        "Singapore");
        //    }
        //}
    }
}
