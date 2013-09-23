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
    public partial class TStoreCheckOutItem : LogicLayerSchema<OStoreCheckOutItem>
    {
        public SchemaGuid FromWorkCostID;
        [Default(0)]
        public SchemaDecimal ReturnQuantity;

        public TWorkCost FromWorkCost { get { return OneToOne<TWorkCost>("FromWorkCostID"); } }
    }

    public abstract partial class OStoreCheckOutItem : LogicLayerPersistentObject
    {
        public abstract Guid? FromWorkCostID { get; set; }

        public abstract Decimal? ReturnQuantity { get; set; }

        public abstract OWorkCost FromWorkCost { get; set; }
    }
}