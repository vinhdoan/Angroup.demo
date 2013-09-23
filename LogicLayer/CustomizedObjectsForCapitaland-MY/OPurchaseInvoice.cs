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
    /// <summary>
    /// Summary description for OPurchaseOrder
    /// </summary>
    public partial class TPurchaseInvoice : LogicLayerSchema<OPurchaseInvoice>
    {
        public SchemaGuid PurchaseInvoiceVendorItemID;
        public TPurchaseInvoiceVendorItem PurchaseInvoiceVendorItem { get { return OneToOne<TPurchaseInvoiceVendorItem>("PurchaseInvoiceVendorItemID"); } }

        
    }


    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseInvoice : LogicLayerPersistentObject
    {
        public abstract Guid? PurchaseInvoiceVendorItemID { get; set; }
        public abstract OPurchaseInvoiceVendorItem PurchaseInvoiceVendorItem { get; set; }
        


        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                return GetPurchaseInvoiceDataSetForCrystalReports(this);
            }
        }

        public DataSet GetPurchaseInvoiceDataSetForCrystalReports(OPurchaseInvoice invoice)
        {
            DataSet ds = new DataSet();

            DataTable dtApprovers = ApproversTable();
            dtApprovers.TableName = "Approvers";
            string strApprovers = "";
            foreach (Approvers approver in invoice.ApproverLists)
            {
                dtApprovers.Rows.Add(String.Format("{0} approved on {1}", approver.ApproverName,
                    approver.ApprovalDateTime != null ? 
                    approver.ApprovalDateTime.Value.ToString("dd-MMM-yyyy") + "at " + 
                    approver.ApprovalDateTime.Value.ToString("hh:mm:ss tt") : ""));
                //dtApprovers.Rows.Add(
                //approver.ApproverName,
                //approver.ApprovalLevel,
                //approver.ApprovalStatus,
                //approver.ApprovalDateTime);
            }
            //dtApprovers.Rows.Add(strApprovers, null, null, null, null);
            DataTable dtImage = PurchaseInvoiceImageTable();
            dtImage.TableName = "Image";
            //dtImage.Rows.Add(invoice.ObjectID, 
            //    invoice.PurchaseInvoiceVendorItem != null ? invoice.PurchaseInvoiceVendorItem.FileBytes : null);
            foreach (OAttachment attachment in invoice.Attachments)
                if (attachment.Filename.EndsWith(".jpg") || attachment.Filename.EndsWith(".gif") ||
                    attachment.Filename.EndsWith(".png") || attachment.Filename.EndsWith(".bmp"))
                    dtImage.Rows.Add(invoice.ObjectID, attachment.FileBytes);

            ds.Tables.Add(dtApprovers);
            ds.Tables.Add(dtImage);

            return ds;
        }

        public DataTable PurchaseInvoiceImageTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("PurchaseInvoiceID");
            dt.Columns.Add("FileBytes", typeof(byte[]));
            

            return dt;
        }

        public DataTable ApproversTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("StringApprovers", typeof(string));
            //dt.Columns.Add("ApproverName");
            //dt.Columns.Add("ApprovalLevel");
            //dt.Columns.Add("ApprovalStatus");
            //dt.Columns.Add("ApprovalDateTime");

            return dt;
        }

        public void SubmitForCancellation()
        {
            using (Connection c = new Connection())
            {
                if (this.IsApproved == 1)
                    this.IsApproved = 0;
                this.Save();
                c.Commit();

            }
        }
    }


}

