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
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TApplicationSetting : LogicLayerSchema<OApplicationSetting>
    {
        public SchemaInt BudgetNotificationPolicy;
    }

    public abstract partial class OApplicationSetting : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract int? BudgetNotificationPolicy { get; set; }
    }

    public class BudgetNotificationMode
    { 
        public const int Both = 0;
        public const int Total = 1;
        public const int Interval = 2;
    }
}
