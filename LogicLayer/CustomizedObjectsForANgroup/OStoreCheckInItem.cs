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
    public partial class TStoreCheckInItem : LogicLayerSchema<OStoreCheckInItem>
    {
        public SchemaGuid FromWorkCostID;

        public TWorkCost FromWorkCost { get { return OneToOne<TWorkCost>("FromWorkCostID"); } }
    }

    public abstract partial class OStoreCheckInItem : LogicLayerPersistentObject
    {
        public abstract Guid? FromWorkCostID { get; set; }

        public abstract OWorkCost FromWorkCost { get; set; }
    }
}