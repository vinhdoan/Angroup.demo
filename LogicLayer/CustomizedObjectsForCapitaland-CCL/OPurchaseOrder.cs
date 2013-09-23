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
using System.Data;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPurchaseOrder : LogicLayerSchema<OPurchaseOrder>
    {
        [Default(0)]
        public SchemaInt IsRecoverable;

        public SchemaInt IsCharged;

        public SchemaString DeliverToAddress;
        public SchemaString DeliverToPerson;
        [Default(0)]
        public SchemaInt IsDeliverToOther;


        //Nguyen Quoc Phuong 5-Dec-2012
        [Default((int)EnumCRVTenderPOSyncError.SUCCEED)]
        public SchemaInt CRVSyncError;
        [Default(0)]
        public SchemaInt CRVSyncErrorNoOfTries;
        //End Nguyen Quoc Phuong 5-Dec-2012
    }


    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseOrder : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract string DeliverToAddress { get; set; }
        public abstract string DeliverToPerson { get; set; }
        public abstract int? IsDeliverToOther { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract int? IsRecoverable { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract int? IsCharged { get; set; }

        //Nguyen Quoc Phuong 5-Dec-2012
        public abstract int? CRVSyncError { get; set; }
        public abstract int? CRVSyncErrorNoOfTries { get; set; }
        //End Nguyen Quoc Phuong 5-Dec-2012


        public string ValidateRFQToPOPolicyRequired()
        {
            if (this.ValidateRFQToPOPolicy() == -1)
                return Resources.Strings.PurchaseOrder_RFQToPOPreferred;
            else if (this.ValidateRFQToPOPolicy() == 0)
                return Resources.Strings.PurchaseOrder_RFQToPORequired;
            else 
                return "";
        }

        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                return GetPurchaseOrderDataSetForCrystalReports(this);
            }
        }

        /// <summary>
        /// Gets the total awarded amount in selected currency.
        /// </summary>
        //Nguyen Quoc Phuong 4-Dec-2012
        public decimal TaskAmountInSelectedCurrency
        {
            get
            {
                decimal? taskAmount = 0;

                foreach (OPurchaseOrderItem poItem in this.PurchaseOrderItems)
                    taskAmount += Round(poItem.UnitPriceInSelectedCurrency * poItem.QuantityOrdered);

                if (taskAmount != null)
                    return taskAmount.Value;

                return 0;
            }
        }
        //End Nguyen Quoc Phuong 4-Dec-2012

        //Nguyen Quoc Phuong 4-Dec-2012
        public int? CreateCRVGProcurementContract()
        {
            OCRVTenderService TenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            TenderService.GProcurementContract = new CRVTenderService.GProcurementContract();

            TenderService.GProcurementContract.ContractRefNo = this.ObjectNumber;
            TenderService.GProcurementContract.AwardedAmount = this.TaskAmount;
            TenderService.GProcurementContract.StartDate = string.Format("{0:dd/MM/yyyy}", this.DateOfOrder.Value);
            TenderService.GProcurementContract.EndDate = string.Format("{0:dd/MM/yyyy}", this.DateEnd.Value);
            TenderService.GProcurementContract.ContractStatus = (int)EnumCRVGProcurementContractStatus.ONGOING;
            TenderService.GProcurementContract.CRVVendorID = this.Vendor.CRVVendorID;
            TenderService.GProcurementContract.VendorBRN = this.Vendor.CompanyRegistrationNumber;
            TenderService.GProcurementContract.IsTermContract = this.IsTermContract;

            //string CRVSerialNumber = this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.CRVSerialNumber;
            //if (this.Location == null || string.IsNullOrEmpty(this.Location.GetSystemCode())) return null;
            //return TenderService.CreateGroupProcurementContract(this.Location.GetSystemCode(), CRVSerialNumber, TenderService.GProcurementContract);
            if (string.IsNullOrEmpty(this.CRVSerialNumber) || string.IsNullOrEmpty(this.SystemCode)) return null;
            return TenderService.CreateGroupProcurementContract(SystemCode, CRVSerialNumber, TenderService.GProcurementContract);
        }
        //End Nguyen Quoc Phuong 4-Dec-2012

        //Nguyen Quoc Phuong 4-Dec-2012
        public int? UpdateCRVGProcurementContract()
        {
            OCRVTenderService TenderService = new OCRVTenderService(OApplicationSetting.Current.CRVTenderServiceURL);
            TenderService.GProcurementContract = new CRVTenderService.GProcurementContract();

            TenderService.GProcurementContract.ContractRefNo = this.ObjectNumber;
            TenderService.GProcurementContract.AwardedAmount = this.TaskAmount;
            TenderService.GProcurementContract.StartDate = string.Format("{0:dd/MM/yyyy}", this.DateOfOrder.Value);
            TenderService.GProcurementContract.EndDate = string.Format("{0:dd/MM/yyyy}", this.DateEnd.Value);
            int? ContractStatus = (int)EnumCRVGProcurementContractStatus.ONGOING;
            if (this.CurrentActivity.ObjectName.Is("Cancelled", "CancelledAndRevised")) ContractStatus = (int)EnumCRVGProcurementContractStatus.CANCELLED;
            else if (this.CurrentActivity.ObjectName.Is("Close")) ContractStatus = (int)EnumCRVGProcurementContractStatus.COMPLETED;
            TenderService.GProcurementContract.ContractStatus = ContractStatus;
            TenderService.GProcurementContract.CRVVendorID = this.Vendor.CRVVendorID;
            TenderService.GProcurementContract.VendorBRN = this.Vendor.CompanyRegistrationNumber;
            TenderService.GProcurementContract.IsTermContract = this.IsTermContract;

            //string CRVSerialNumber = this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.CRVSerialNumber;
            //if (this.Location == null || string.IsNullOrEmpty(this.Location.GetSystemCode())) return null;
            //return TenderService.UpdateGroupProcurementContract(this.Location.GetSystemCode(), CRVSerialNumber, TenderService.GProcurementContract);
            if(string.IsNullOrEmpty(this.CRVSerialNumber) || string.IsNullOrEmpty(this.SystemCode)) return null;
            return TenderService.UpdateGroupProcurementContract(SystemCode, CRVSerialNumber, TenderService.GProcurementContract);
        }
        //End Nguyen Quoc Phuong 4-Dec-2012

        //Nguyen Quoc Phuong 13-Dec-2012
        public string CRVSerialNumber
        {
            get
            {
                string CRVSerialNumber = string.Empty;
                if (this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.GroupRequestForQuotation != null)
                    CRVSerialNumber = this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.GroupRequestForQuotation.CRVSerialNumber;
                else
                    CRVSerialNumber = this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.CRVSerialNumber;
                return CRVSerialNumber;
            }
        }
        //End Nguyen Quoc Phuong 13-Dec-2012

        //Nguyen Quoc Phuong 17-Dec-2012
        public string SystemCode
        {
            get
            {
                string SystemCode;
                if (this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.GroupRequestForQuotation != null)
                    SystemCode = this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.GroupRequestForQuotation.Location.GetSystemCode();
                else
                    SystemCode = this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.Location.GetSystemCode();
                return SystemCode;
            }
        }
        //End Nguyen Quoc Phuong 17-Dec-2012

        //Nguyen Quoc Phuong 17-Dec-2012
        public bool IsSyncCRV
        {
            get
            {
                if (this.PurchaseOrderItems.Count > 0 && this.PurchaseOrderItems[0].RequestForQuotationItem != null)
                    if (this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.GroupRequestForQuotation != null)
                        return this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.GroupRequestForQuotation.isSyncCRV && !String.IsNullOrEmpty(this.CRVSerialNumber);
                    else return this.PurchaseOrderItems[0].RequestForQuotationItem.RequestForQuotation.isSyncCRV && !String.IsNullOrEmpty(this.CRVSerialNumber);
                else
                    return false;
            }
        }
        //End Nguyen Quoc Phuong 17-Dec-2012
    }

    public enum EnumCRVTenderPOSyncError
    {
        SUCCEED = 0,
        CREATE = 1,
        UPDATE = 2
    }
  
}
