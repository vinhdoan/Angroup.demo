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
using System.Data;
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
    /// <summary>
    /// Summary description for TACGData
    /// </summary>
    [Database("#database"), Map("ChargeType")]
    [Serializable]
    public partial class TChargeType : LogicLayerSchema<OChargeType>
    {
        public SchemaInt AmosChargeID;
        public SchemaInt AmosAssetTypeID;
        public SchemaInt FromAmos;
        public SchemaDateTime updatedOn;
    }


    /// <summary>
    /// Summary description for OACGData
    /// </summary>
    public abstract partial class OChargeType : LogicLayerPersistentObject
    {
        public abstract int? AmosChargeID { get; set; }
        public abstract int? AmosAssetTypeID { get; set; }
        public abstract int? FromAmos { get; set; }
        public abstract DateTime? updatedOn { get; set; }

        public static List<OChargeType> GetChargeTypeList()
        {
            return TablesLogic.tChargeType.LoadAll();
        }
    }

}
