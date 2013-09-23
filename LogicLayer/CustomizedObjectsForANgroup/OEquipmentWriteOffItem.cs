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
    public partial class TEquipmentWriteOffItem: LogicLayerSchema<OEquipmentWriteOffItem>
    {
        public SchemaGuid EquipmentWriteOffID;
        public SchemaGuid EquipmentID;
        [Size(255)]
        public SchemaString ReasonForWriteOff;
        public SchemaInt OriginalEquipmentStatus;
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
    }


 
    public abstract partial class OEquipmentWriteOffItem : LogicLayerPersistentObject
    {
        public abstract Guid? EquipmentWriteOffID { get; set; }
        public abstract Guid? EquipmentID { get; set; }
        public abstract string ReasonForWriteOff { get; set; }
        public abstract int? OriginalEquipmentStatus { get; set; }
        public abstract OEquipment Equipment { get; set; }

    }
   
}
