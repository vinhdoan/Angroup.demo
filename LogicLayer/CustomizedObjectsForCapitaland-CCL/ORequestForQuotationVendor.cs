//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TRequestForQuotationVendor : LogicLayerSchema<ORequestForQuotationVendor>
    {
        //public SchemaDateTime CRVAwardedDate;//Nguyen Quoc Phuong 28-Nov-2012
    }


    /// <summary>
    /// Represents a physical quotation from vendor indicating
    /// terms of the quotation and a collection of the quote
    /// of each line item in the original request for quotation.
    /// </summary>
    public abstract partial class ORequestForQuotationVendor : LogicLayerPersistentObject
    {
        //public abstract DateTime? CRVAwardedDate { get; set; }//Nguyen Quoc Phuong 28-Nov-2012

        //Nguyen Quoc Phuong 29-Nov-2012
        //For CRV, take the earliest awarded date of all of the awarded items
        public DateTime? CRVAwardedDate(ORequestForQuotation rfq)
        {
            DateTime? EarliestAwardedDate = null;
            foreach (ORequestForQuotationItem rfqitem in rfq.RequestForQuotationItems)
                if (rfqitem.AwardedVendorID == this.VendorID && EarliestAwardedDate == null)
                    EarliestAwardedDate = rfqitem.AwardedDate;
                else if (rfqitem.AwardedVendorID == this.VendorID && rfqitem.AwardedDate.Value > EarliestAwardedDate.Value)
                    EarliestAwardedDate = rfqitem.AwardedDate;
            return EarliestAwardedDate;
        }
        //End Nguyen Quoc Phuong 29-Nov-2012
        /// <summary>
        /// 
        /// </summary>
        /// <param name="item"></param>
        public void UpdateSingleItemRecoverable(ORequestForQuotationVendorItem item)
        {
            OCurrency baseCurrency = OApplicationSetting.Current.BaseCurrency;
            item.RecoverableAmountInSelectedCurrency = Round(item.RecoverableAmountInSelectedCurrency);

            if (item.CurrencyID == baseCurrency.ObjectID)
                item.RecoverableAmount = item.RecoverableAmountInSelectedCurrency;
            else
                item.RecoverableAmount = Round(item.RecoverableAmountInSelectedCurrency * this.ForeignToBaseExchangeRate);

        }

        /// <summary>
        /// 
        /// </summary>
        public void UpdateItemsRecoverable()
        {
            foreach (ORequestForQuotationVendorItem poItem in this.RequestForQuotationVendorItems)
            {
                poItem.CurrencyID = this.CurrencyID;
                UpdateSingleItemRecoverable(poItem);
            }
        }

        public static List<string> CreateRFQVendorFromCRVTender(string CRVSerialNumber, ORequestForQuotation rfq)
        {
            OCRVTenderService CRVTenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            OCRVVendorService CRVVendorService = new OCRVVendorService(OApplicationSetting.Current.CRVVendorServiceURL);

            string SystemCode = rfq.SystemCode;
            if (string.IsNullOrEmpty(SystemCode))
                return null;


            CRVTenderService.CRVTender = CRVTenderService.GetFullTenderInfo(
                                            SystemCode,
                                            CRVSerialNumber);
            if (CRVTenderService.CRVTender == null) return null;

            List<string> CRVVendorIDs = new List<string>();
            for (int i = 0; i < CRVTenderService.CRVTender.CRVTenderVendors.Length; i++)
            {
                if (!string.IsNullOrEmpty(CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID)
                    //&& CRVVendorService.IsVendorSubscribed(
                    //    SystemCode,
                    //    CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID) == true
                  )
                {
                    //Remove the withdrawn vendor
                    ORequestForQuotationVendor rfqVendor = rfq.RequestForQuotationVendors.Find(lf => lf.Vendor.CRVVendorID.Trim() == CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID.Trim());
                    if (rfqVendor != null && (CRVTenderService.CRVTender.CRVTenderVendors[i].Status == (int)EnumCRVTenderAwardVendorStatus.WITHDRAWN
                        || rfqVendor.Vendor.IsDebarred == 1))
                        rfq.RequestForQuotationVendors.RemoveObject(rfqVendor);
                    //Only add non withdrawn vendors
                    else if (CRVTenderService.CRVTender.CRVTenderVendors[i].Status != (int)EnumCRVTenderAwardVendorStatus.WITHDRAWN)
                        CRVVendorIDs.Add(CRVTenderService.CRVTender.CRVTenderVendors[i].CRVVendorID.Trim());
                }
            }
            List<OVendor> Vendors = TablesLogic.tVendor.LoadList(TablesLogic.tVendor.CRVVendorID.In(CRVVendorIDs.ToArray()));
            
            List<string> CRVVendorIDNotFoundInCAMPS = new List<string>();
            foreach (string CRVVendorID in CRVVendorIDs)
            {
                if (Vendors.Find(a => a.CRVVendorID == CRVVendorID) == null)
                {
                    string temp = CRVVendorID;
                    CRVVendorIDNotFoundInCAMPS.Add(temp);
                }
            }

            for (int i = 0; i < Vendors.Count; i++)
            {
                if (Vendors[i].IsDebarred == 0)
                    if (rfq.RequestForQuotationVendors.Find(a => a.VendorID == Vendors[i].ObjectID) == null)
                    {
                        ORequestForQuotationVendor rfqVendor = TablesLogic.tRequestForQuotationVendor.Create();
                        rfqVendor.RequestForQuotationID = rfq.ObjectID;
                        rfqVendor.RequestForQuotation = rfq;
                        rfqVendor.VendorID = Vendors[i].ObjectID;
                        rfqVendor.UpdateExchangeRate();
                        rfq.CreateRequestForQuotationVendorItems(rfqVendor);
                        rfq.RequestForQuotationVendors.Add(rfqVendor);
                    }
            }

            return CRVVendorIDNotFoundInCAMPS;
        }

    }
}
