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
using System.Data;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPurchaseOrder : LogicLayerSchema<OPurchaseOrder>
    {
        
    }


    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseOrder : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                return GetPurchaseOrderDataSetForCrystalReports(this);
            }
        }
    }
}
