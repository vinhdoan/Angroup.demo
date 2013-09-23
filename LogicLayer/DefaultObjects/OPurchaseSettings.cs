//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
        public SchemaGuid LocationID;
        public SchemaGuid PurchaseTypeID;

        [Default(0)]
        public SchemaInt BudgetValidationPolicy;

        [Default(0)]
        public SchemaInt MinimumNumberOfQuotationsPolicy;
        public SchemaInt MinimumNumberOfQuotations;
        public SchemaDecimal MinimumApplicableRFQAmount;

        [Default(0)]
        public SchemaInt RFQToPOPolicy;
        public SchemaDecimal MinimumApplicablePOAmount;

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TCode PurchaseType { get { return OneToOne<TCode>("PurchaseTypeID"); } }
    }

    /// <summary>
    /// Represents a purchase order object as a legal document to a
    /// vendor to purchase materials or services.
    /// </summary>
    public abstract partial class OPurchaseSettings : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table 
        /// that indicates the location where any service is to be 
        /// carried out in.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates the purchase type. The purchase types usually
        /// describes whether or not the WJ/RFQ/PO document is a Capex,
        /// or a Non-Capex purchase. 
        /// </summary>
        public abstract Guid? PurchaseTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value indicating
        /// the budget validation policy.
        /// <list>
        ///     <item>0 - Budget consumption must be equal to line items. (default) </item>
        ///     <item>1 - Budget consumption must be less than or equal to line items. </item>
        ///     <item>2 - No validation. </item>
        /// </list>
        /// </summary>
        public abstract int? BudgetValidationPolicy { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value indicating the policy
        /// of the system with respect to creating purchase orders
        /// from quotations.
        /// <para></para>
        /// <list>
        ///     <item>0 - A minimum number of quotations is not required.</item>
        ///     <item>1 - A minimum number of quotations is preferred. A warning is displayed if the minimum quotations is not satisfied.</item>
        ///     <item>2 - A minimum number of quotations is required. </item>
        /// </list>
        /// <para></para>
        /// </summary>
        public abstract int? MinimumNumberOfQuotationsPolicy { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum number of quotations
        /// required before a Purchase Order can be created from a
        /// Request for Quotation. This value must be more than
        /// or equals to 1. At the very least, there must be at
        /// least 1 quotation in a Request for Quotation before
        /// any Purchase Order can be created anyway.
        /// </summary>
        public abstract int? MinimumNumberOfQuotations { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum amount (inclusive)
        /// that will result in the minimum quotation policy taking effect.
        /// </summary>
        public abstract decimal? MinimumApplicableRFQAmount { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value indicating if a purchase order
        /// must be created from a request for quotation.
        /// <para></para>
        /// <list>
        ///     <item>0 - Not required.</item>
        ///     <item>1 - Preferred. A warning is displayed if the minimum quotations is not satisfied.</item>
        ///     <item>2 - Required. </item>
        /// </list>
        /// <para></para>
        /// </summary>
        public abstract int? RFQToPOPolicy { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum amount (inclusive)
        /// that will result in the PO policy taking effect.
        /// </summary>
        public abstract decimal? MinimumApplicablePOAmount { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents
        /// the location where any service is to be 
        /// carried out in.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that 
        /// represents the purchase type. The purchase types usually
        /// describes whether or not the WJ/RFQ/PO document is a Capex,
        /// or a Non-Capex purchase. 
        /// </summary>
        public abstract OCode PurchaseType { get; set; }

        /// <summary>
        /// Gets a translated text describing whether the 
        /// minimum number of quotations must be adhered
        /// to. 
        /// </summary>
        public string MinimumNumberOfQuotationsPolicyText
        {
            get
            {
                if (MinimumNumberOfQuotationsPolicy == PurchasePolicy.NotRequired)
                    return Resources.Strings.MinimumNumberOfQuotations_NotRequired;
                else if (MinimumNumberOfQuotationsPolicy == PurchasePolicy.Preferred)
                    return Resources.Strings.MinimumNumberOfQuotations_Preferred;
                else if (MinimumNumberOfQuotationsPolicy == PurchasePolicy.Required)
                    return Resources.Strings.MinimumNumberOfQuotations_Required;
                return "";
            }
        }


        /// <summary>
        /// Gets a translated text describing the
        /// budget validation policy.
        /// </summary>
        public string BudgetValidationPolicyText
        {
            get
            {
                if (BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetNotRequired)
                    return Resources.Strings.BudgetValidationPolicy_NotRequired;
                else if (BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionEqualsItems)
                    return Resources.Strings.BudgetValidationPolicy_BudgetConsumptionEqualsItems;
                else if (BudgetValidationPolicy == PurchaseBudgetValidationPolicy.BudgetConsumptionLessThanItems)
                    return Resources.Strings.BudgetValidationPolicy_BudgetConsumptionLessThanItems;
                return "";
            }
        }


        /// <summary>
        /// Gets a translated text describing whether the 
        /// minimum number of quotations must be adhered
        /// to. 
        /// </summary>
        public string RFQToPOPolicyText
        {
            get
            {
                if (RFQToPOPolicy == PurchasePolicy.NotRequired)
                    return Resources.Strings.MinimumNumberOfQuotations_NotRequired;
                else if (RFQToPOPolicy == PurchasePolicy.Preferred)
                    return Resources.Strings.MinimumNumberOfQuotations_Preferred;
                else if (RFQToPOPolicy == PurchasePolicy.Required)
                    return Resources.Strings.MinimumNumberOfQuotations_Required;
                return "";
            }
        }


        /// <summary>
        /// Updates several fields in the purchase settings
        /// if the minimum number of quotations rule is
        /// not required.
        /// </summary>
        public override void Saving()
        {
            base.Saving();
            if (this.MinimumNumberOfQuotationsPolicy == PurchasePolicy.NotRequired)
            {
                this.MinimumNumberOfQuotations = null;
                this.MinimumApplicableRFQAmount = null;
            }
            if (this.RFQToPOPolicy == PurchasePolicy.NotRequired)
            {
                this.MinimumApplicablePOAmount = null;
            }
        }


        /*
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
                TablesLogic.tPurchaseSettings.ObjectID != this.ObjectID) == null;
        }
        */

        /// <summary>
        /// Gets the most appropriate purchase settings object and
        /// returns it to the caller.
        /// </summary>
        /// <returns></returns>
        public static OPurchaseSettings GetPurchaseSettings(OLocation location, OCode purchaseType)
        {
            if (location != null)
            {
                if(purchaseType != null)
                    return TablesLogic.tPurchaseSettings.Load(
                        location.HierarchyPath.Like(TablesLogic.tPurchaseSettings.Location.HierarchyPath + "%") &
                        TablesLogic.tPurchaseSettings.PurchaseTypeID == purchaseType.ObjectID,
                        TablesLogic.tPurchaseSettings.Location.HierarchyPath.Length().Desc);
                else
                    return TablesLogic.tPurchaseSettings.Load(
                        location.HierarchyPath.Like(TablesLogic.tPurchaseSettings.Location.HierarchyPath + "%"),
                        TablesLogic.tPurchaseSettings.Location.HierarchyPath.Length().Desc);
            }
            else
                return null;
        }
    }


    /// <summary>
    /// Enumerates the different policies on the minimum number
    /// of quotations requirement.
    /// </summary>
    public class PurchasePolicy
    {
        /// <summary>
        /// Indicates that a minimum number of quotations
        /// is not required.
        /// </summary>
        public const int NotRequired = 0;

        /// <summary>
        /// Indicates that a minimum number of quotations
        /// is preferred.
        /// </summary>
        public const int Preferred = 1;

        /// <summary>
        /// Indicates that a minimum number of quotations
        /// is required.
        /// </summary>
        public const int Required = 2;

    }


    /// <summary>
    /// Enumerates the policies for the usage of budget.
    /// </summary>
    public class PurchaseBudgetValidationPolicy
    {
        /// <summary>
        /// Strict: Total budget items must be equal
        /// to the items' cost.
        /// </summary>
        public const int BudgetConsumptionEqualsItems = 0;

        /// <summary>
        /// Total budget items must be less than the 
        /// </summary>
        public const int BudgetConsumptionLessThanItems = 1;

        /// <summary>
        /// Budget is not required at all.
        /// </summary>
        public const int BudgetNotRequired = 2;
    }

}

