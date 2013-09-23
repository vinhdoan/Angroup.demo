//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OPurchaseOrder
    /// </summary>
    public partial class TPurchaseInvoice : LogicLayerSchema<OPurchaseInvoice>
    {
        public SchemaGuid PaymentTypeID;

        public TCode PaymentType { get { return OneToOne<TCode>("PaymentTypeID"); } }
    }

    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseInvoice : LogicLayerPersistentObject
    {
        public abstract Guid? PaymentTypeID { get; set; }

        public abstract OCode PaymentType { get; set; }

        /// <summary>
        ///
        /// </summary>
        public bool IsDuplicateInvoiceNumber
        {
            get
            {
                return !ValidateDuplicateInvoiceNumber();
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public Boolean ValidateDuplicateInvoiceNumber()
        {
            return TablesLogic.tPurchaseInvoice.Load
                (TablesLogic.tPurchaseInvoice.ObjectID != this.ObjectID &
                (TablesLogic.tPurchaseInvoice.ReferenceNumber == this.ReferenceNumber |
                TablesLogic.tPurchaseInvoice.ObjectNumber == this.ObjectNumber) &
                TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName != "Cancelled" &
                TablesLogic.tPurchaseInvoice.VendorID == this.VendorID) == null;
        }
    }
}