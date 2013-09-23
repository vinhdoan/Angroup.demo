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
    [Database("#database"), Map("RequestForQuotationPaymentSchedule")]
    public class TRequestForQuotationPaymentSchedule : LogicLayerSchema<ORequestForQuotationPaymentSchedule>
    {
        public SchemaDecimal PercentageToPay;
        public SchemaDecimal AmountToPay;
        public SchemaDateTime DateOfPayment;
        public SchemaString Description;
        public SchemaGuid RequestForQuotationID;
        
    }



    public abstract class ORequestForQuotationPaymentSchedule : LogicLayerPersistentObject
    {

        public abstract decimal? PercentageToPay { get; set; }
        public abstract decimal? AmountToPay { get; set; }
        public abstract DateTime? DateOfPayment { get; set; }
        public abstract String Description { get; set; }
        public abstract Guid? RequestForQuotationID { get; set; }

    }
    
}

