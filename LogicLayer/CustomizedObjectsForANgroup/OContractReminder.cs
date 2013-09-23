//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TContractReminder : LogicLayerSchema<OContractReminder>
    {

        public SchemaGuid ReminderTypeID;
        public SchemaDateTime ReminderDate;
        public SchemaString ReminderDescription;
        [Default(0)]
        public SchemaInt IsReminderSent;
        public SchemaGuid ContractID;
        public TCode ReminderType { get { return OneToOne<TCode>("ReminderTypeID"); } }
        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }
    }



    public abstract partial class OContractReminder : LogicLayerPersistentObject
    {
        public abstract Guid? ReminderTypeID { get; set; }
        public abstract DateTime? ReminderDate { get; set; }
        public abstract string ReminderDescription { get; set; }
        public abstract int? IsReminderSent { get; set; }
        public abstract Guid? ContractID { get; set; }
        public abstract OCode ReminderType { get; set; }
        public abstract OContract Contract { get; set; }
    }
}
