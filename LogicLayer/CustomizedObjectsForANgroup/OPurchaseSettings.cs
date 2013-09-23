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
    public partial class TPurchaseSettings : LogicLayerSchema<OPurchaseSettings>
    {

        public SchemaGuid BudgetGroupID;
        [Default(0)]
        public SchemaInt IsPOAllowedClosure;
        [Default(0)]
        public SchemaInt InvoiceLargerThanPO;
        public TBudgetGroup BudgetGroup { get { return OneToOne<TBudgetGroup>("BudgetGroupID"); } }
    }

    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseSettings : LogicLayerPersistentObject
    {
        public abstract Guid? BudgetGroupID { get; set; }

        /// <summary>
        /// [Column] Gets or sets whether PO can be closed if PO amount <> Invoice Amount
        /// </summary>
        public abstract int? IsPOAllowedClosure { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether the invoice can be
        /// larger than the PO amount.
        /// </summary>
        public abstract int? InvoiceLargerThanPO { get; set; }

        public abstract OBudgetGroup BudgetGroup { get; set; }


        /// <summary>
        /// Gets a translated text indicating whether PO can be closed 
        /// if PO amount <> Invoice Amount
        /// </summary>
        public string IsPOAllowedClosureText
        {
            get
            {
                if (IsPOAllowedClosure == 0)
                    return Resources.Strings.General_No;
                else if (IsPOAllowedClosure == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }


        /// <summary>
        /// Gets a translated text indicating whether PO can be closed 
        /// if PO amount <> Invoice Amount
        /// </summary>
        public string IsInvoiceLargerThanPOText
        {
            get
            {
                if (InvoiceLargerThanPO == 0)
                    return Resources.Strings.General_No;
                else if (InvoiceLargerThanPO == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }


        /// <summary>
        /// Gets the most appropriate purchase settings object and
        /// returns it to the caller.
        /// </summary>
        /// <returns></returns>
        public static OPurchaseSettings GetPurchaseSettings(OLocation location, OCode purchaseType, Guid? BudgetGroupID)
        {
            if (location != null && purchaseType != null)
            {
                return TablesLogic.tPurchaseSettings.Load(
                    location.HierarchyPath.Like(TablesLogic.tPurchaseSettings.Location.HierarchyPath + "%") &
                    TablesLogic.tPurchaseSettings.PurchaseTypeID == purchaseType.ObjectID &
                    TablesLogic.tPurchaseSettings.BudgetGroupID == BudgetGroupID,
                    TablesLogic.tPurchaseSettings.Location.HierarchyPath.Length().Desc);
            }
            else
                return null;
        }


        /// <summary>
        /// Validates to ensure that no purchase settings with the
        /// same location exists.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNoDuplicateLocation()
        {
            return TablesLogic.tPurchaseSettings.Load(
                TablesLogic.tPurchaseSettings.LocationID == this.LocationID &
                TablesLogic.tPurchaseSettings.PurchaseTypeID == this.PurchaseTypeID &
                TablesLogic.tPurchaseSettings.BudgetGroupID == this.BudgetGroupID &
                TablesLogic.tPurchaseSettings.ObjectID != this.ObjectID) == null;
        }
    }
}


