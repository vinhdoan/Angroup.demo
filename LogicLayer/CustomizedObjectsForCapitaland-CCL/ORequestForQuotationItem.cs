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
    public partial class TRequestForQuotationItem : LogicLayerSchema<ORequestForQuotationItem>
    {
        public TPurchaseOrderItem PurchaseOrderItems { get { return OneToMany<TPurchaseOrderItem>("RequestForQuotationItemID"); } }
        
        public SchemaDecimal ChargeAmount;
        
        public SchemaDecimal RecoverableAmount;

        public SchemaDecimal RecoverableAmountInSelectedCurrency;

        public SchemaGuid WorkID;

        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }

        public SchemaGuid WorkCostID;
        
        public TWorkCost WorkCost { get { return OneToOne<TWorkCost>("WorkCostID"); } }

        public SchemaDateTime AwardedDate;//Nguyen Quoc Phuong 29-Nov-2012

    }


    /// <summary>
    /// Represents 
    /// </summary>
    public abstract partial class ORequestForQuotationItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// 
        /// </summary>
        public abstract DataList<OPurchaseOrderItem> PurchaseOrderItems { get; }
        
        /// <summary>
        /// 
        /// </summary>
        public abstract decimal? ChargeAmount { get; set; }
        
        /// <summary>
        /// 
        /// </summary>
        public abstract decimal? RecoverableAmount { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract decimal? RecoverableAmountInSelectedCurrency { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? WorkID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract OWork Work { get; set; }
        
        /// <summary>
        /// 
        /// </summary>
        public abstract Guid? WorkCostID { get; set; }
        
        /// <summary>
        /// 
        /// </summary>
        public abstract OWorkCost WorkCost { get; }

        public abstract DateTime? AwardedDate { get; set; }//Nguyen Quoc Phuong 29-Nov-2012
        /// <summary>
        /// Temp property OrderQuantity to store quantity order
        /// enter from the user.
        /// </summary>
        public decimal? OrderQuantity;

        public decimal? QuantityOrdered
        {
            get
            {
                decimal? quantityOrdered = 0M;
                if (this.PurchaseOrderItems.Count > 0)
                {
                    foreach (OPurchaseOrderItem item in this.PurchaseOrderItems)
                    {
                        if (item.PurchaseOrder.CurrentActivity.ObjectName != "Cancelled")
                            quantityOrdered += item.QuantityOrdered.Value;
                    }
                }
                return quantityOrdered;
            }
        }
        /// <summary>
        /// Gets the work number
        /// that this request for quotation item was copied from.
        /// </summary>
        public string CopiedFromWorkObjectNumber
        {
            get
            {
                if (WorkCost != null && WorkCost.Work != null)
                    return WorkCost.Work.ObjectNumber;
                return "";
            }
        }
        
    }
}
