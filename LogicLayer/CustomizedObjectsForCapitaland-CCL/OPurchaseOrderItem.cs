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
    public partial class TPurchaseOrderItem : LogicLayerSchema<OPurchaseOrderItem>
    {
        public SchemaDecimal ChargeAmount;

        public SchemaDecimal RecoverableAmount;

        public SchemaDecimal RecoverableAmountInSelectedCurrency;
    }


    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseOrderItem : LogicLayerPersistentObject
    {
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
    }


  
}
