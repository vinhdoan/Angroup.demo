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
using System.Reflection;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPurchaseBudget : LogicLayerSchema<OPurchaseBudget>
    {
        public SchemaGuid LocationID;
        public SchemaInt AccrualDateModifiedDueToBudgetClosed;
        public TLocation Location { get { return ManyToMany<TLocation>("BudgetLocation","BudgetID","LocationID"); } }
    }


    /// <summary>
    /// Represents the budget distributions in a purchase request, request for quotation
    /// or a purchase order object.
    /// </summary>
    public abstract partial class OPurchaseBudget : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseBudget table 
        /// that indicates the source purchase budget that generated
        /// this purchase budget.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Indicates that the accrual date was modified to commit to
        /// the following year's budget because previous year budget was closed.
        /// </summary>
        public abstract int? AccrualDateModifiedDueToBudgetClosed { get; set; }

        public abstract DataList<OLocation> Location { get; }

       

    }
}
