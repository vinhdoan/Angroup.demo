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
    /// Summary description for OVendor
    /// </summary>
    public partial class TWorkCost : LogicLayerSchema<OWorkCost>
    {
        //2011.11.09, ptb
        public SchemaGuid TaxCodeID;

        public TTaxCode TaxCode { get { return OneToOne<TTaxCode>("TaxCodeID"); } }

        public SchemaDecimal TaxAmount;
        public SchemaInt DisplayOrder;
        [Default(0)]
        public SchemaInt IsReserve;
    }

    /// <summary>
    /// Represents the maintenance cost that will be incurred or
    /// has been incurred by the work.
    /// </summary>
    public abstract partial class OWorkCost : LogicLayerPersistentObject
    {
        //2011.11.09, ptb
        public abstract Guid? TaxCodeID { get; set; }

        public abstract OTaxCode TaxCode { get; }

        public abstract Decimal? TaxAmount { get; set; }

        public abstract int? DisplayOrder { get; set; }

        public abstract int? IsReserve { get; set; }
    }
}