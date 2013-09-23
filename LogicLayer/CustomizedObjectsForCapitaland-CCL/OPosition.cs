using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPosition: LogicLayerSchema<OPosition>
    {
        public SchemaInt AppliesToAllPurchaseTypes;

        public TCode PurchaseTypesAccess { get { return ManyToMany<TCode>("PositionPurchaseType", "PositionID", "PurchaseTypeID"); } }

        [Default(0)]
        public SchemaInt AppliesToAllDebarredVendors;

        [Default(0)]
        public SchemaInt AppliesToAllNonApprovedVendors;

    }

    public abstract partial class OPosition : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract int? AppliesToAllPurchaseTypes { get; set; }
        
        public abstract DataList<OCode> PurchaseTypesAccess { get; }

        public abstract int? AppliesToAllDebarredVendors { get; set; }

        public abstract int? AppliesToAllNonApprovedVendors { get; set; }
        
    }
}
