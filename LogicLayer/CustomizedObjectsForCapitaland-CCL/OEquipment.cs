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
    public partial class TEquipment : LogicLayerSchema<OEquipment>
    {
        public TLocation ServingAreas { get { return ManyToMany<TLocation>("EquipmentLocation", "EquipmentID", "LocationID"); } }
      
    }

    public abstract partial class OEquipment : LogicLayerPersistentObject, IHierarchy
    {
        public abstract DataList<OLocation> ServingAreas { get; set; }
    }
    
}
