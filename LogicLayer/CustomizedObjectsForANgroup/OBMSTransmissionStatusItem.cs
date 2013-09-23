//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{

    public partial class TBMSTransmissionStatusItem : LogicLayerSchema<OBMSTransmissionStatusItem>
    {
        public SchemaGuid BMSTransmissionStatusID;
        public SchemaInt RecordNo;
        public SchemaString BMSCode;
        public SchemaDecimal ReadingValue;
        public SchemaInt IsSuccess;
   }



    public abstract partial class OBMSTransmissionStatusItem : LogicLayerPersistentObject
    {
        public abstract Guid? BMSTransmissionStatusID { get; set; }
        public abstract int? RecordNo { get; set; }
        public abstract string BMSCode { get; set; }
        public abstract decimal? ReadingValue { get; set; }
        public abstract int? IsSuccess { get; set; }
        public string IsSuccessText
        {
            get
            {
                if (this.IsSuccess == 1)
                    return "Yes";
                else
                    return "No";
            }
        }
    }
}