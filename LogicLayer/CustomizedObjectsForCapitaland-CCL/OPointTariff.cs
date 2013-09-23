//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;

using Anacle.DataFramework;
using System.Collections;

namespace LogicLayer
{
    /// <summary>
    /// </summary>
    public partial class TPointTariff : LogicLayerSchema<OPointTariff>
    {
        public SchemaGuid TypeOfMeterID;

        public TCode TypeOfMeter { get { return OneToOne<TCode>("TypeOfMeterID"); } }
    }



    public abstract partial class OPointTariff : LogicLayerPersistentObject, IHierarchy, IAuditTrailEnabled
    {
        public abstract Guid? TypeOfMeterID { get; set; }

        public abstract OCode TypeOfMeter { get; set; }
    }
}
