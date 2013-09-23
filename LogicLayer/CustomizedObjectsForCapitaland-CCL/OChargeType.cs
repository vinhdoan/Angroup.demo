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
    public partial class TChargeType : LogicLayerSchema<OChargeType>
    {
        public SchemaString AMOSInstanceID;
    }


    /// <summary>
    /// Summary description for OACGData
    /// </summary>
    public abstract partial class OChargeType : LogicLayerPersistentObject
    {
        public abstract String AMOSInstanceID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="amosInstanceID"></param>
        /// <returns></returns>
        public static List<OChargeType> GetChargeTypesByInstanceID(String amosInstanceID)
        {
            return TablesLogic.tChargeType.LoadList(TablesLogic.tChargeType.AMOSInstanceID == amosInstanceID);
        }
    }

}
