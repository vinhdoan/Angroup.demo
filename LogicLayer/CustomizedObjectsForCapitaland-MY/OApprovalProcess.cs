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
    /// Summary description for OApprovalProcess
    /// </summary>
    public partial class TApprovalProcess : LogicLayerSchema<OApprovalProcess>
    {
        public SchemaInt UseDefaultEvents;
    }



    public abstract partial class OApprovalProcess : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract int? UseDefaultEvents { get; set; }

        public override void Saving()
        {
            base.Saving();

            LinkApprovalProcessLimits();
        }
    }
}
