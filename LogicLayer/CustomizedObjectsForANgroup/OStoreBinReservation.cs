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
    public partial class TStoreBinReservation : LogicLayerSchema<OStoreBinReservation>
    {
        public SchemaGuid StoreTransferItemID;
    }

    public abstract partial class OStoreBinReservation : LogicLayerPersistentObject
    {
        public abstract Guid? StoreTransferItemID { get; set; }
    }
}