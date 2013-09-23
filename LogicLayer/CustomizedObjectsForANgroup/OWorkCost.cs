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
        public SchemaGuid KeyID;
        [Default(0)]
        public SchemaInt IsCheckOut;
    }

    /// <summary>
    /// Represents the maintenance cost that will be incurred or
    /// has been incurred by the work.
    /// </summary>
    public abstract partial class OWorkCost : LogicLayerPersistentObject
    {
        public abstract Guid? KeyID { get; set; }

        public abstract int? IsCheckOut { get; set; }

        public override void Saving2()
        {
            if (this.KeyID == null)
                this.KeyID = this.ObjectID;
            base.Saving2();
        }

        public override bool IsRemovable()
        {
            OStoreCheckOut scoi = TablesLogic.tStoreCheckOut.Load(TablesLogic.tStoreCheckOut.StoreCheckOutItems.FromWorkCostID == this.ObjectID);
            return (scoi == null);
        }
    }
}