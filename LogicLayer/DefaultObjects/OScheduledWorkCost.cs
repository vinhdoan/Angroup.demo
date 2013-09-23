//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    /// Summary description for OVendor
    /// </summary>
    [Database("#database"), Map("ScheduledWorkCost")]
    [Serializable] public partial class TScheduledWorkCost : LogicLayerSchema<OScheduledWorkCost>
    {
        public SchemaGuid ScheduledWorkID;
        public SchemaInt CostType;
        public SchemaGuid PartID;
        public SchemaGuid CraftID;
        public SchemaGuid UserID;
        public SchemaGuid FixedRateID;
        public SchemaGuid CatalogueID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaGuid StoreID;
        public SchemaGuid StoreBinID;
        [Size(255)]
        public SchemaString CostDescription;
        public SchemaInt EstimatedOvertime;
        public SchemaDecimal EstimatedUnitCost;
        public SchemaDecimal EstimatedCostFactor;
        public SchemaDecimal EstimatedQuantity;
        public SchemaDecimal EstimatedCostTotal;

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TScheduledWork ScheduledWork { get { return OneToOne<TScheduledWork>("ScheduledWorkID"); } }
        public TCraft Craft { get { return OneToOne<TCraft>("CraftID"); } }
        public TUser Technician { get { return OneToOne<TUser>("UserID"); } }
        public TFixedRate FixedRate { get { return OneToOne<TFixedRate>("FixedRateID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
    }


    /// <summary>
    /// Represents information about the costs of the maintenance work 
    /// that will be associated with the works created by the scheduled 
    /// work object. Each scheduled work cost record can represent one
    /// of the following types: a craft, a material from store, or
    /// an adhoc cost.
    /// </summary>
    [Serializable] public abstract partial class OScheduledWorkCost : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the ScheduledWork table 
        /// that indicates the scheduled work object that contains this record.
        /// </summary>
        public abstract Guid? ScheduledWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates the type of 
        /// cost that this record represents. 
        /// <para></para>
        /// <list>
        ///   <item>0 - Craft of a technician. The actual technician is 
        /// not specified when creating a scheduled work.</item>
        ///   <item>1 - Obsolete, not used anymore.</item>
        ///   <item>2 - Others.</item>
        ///   <item>3 - Material</item>
        /// </list>
        /// </summary>
        public abstract int? CostType { get; set; }

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract Guid? PartID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Craft table 
        /// that indicates the craft of the technicians that this
        /// cost is associated with. This is applicable only if
        /// CostType = 0.
        /// </summary>
        public abstract Guid? CraftID { get; set; }

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract Guid? UserID { get; set; }

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract Guid? FixedRateID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the unit of measure that this material
        /// will be checked out from the store as. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table 
        /// that indicates the store that the material for this cost
        /// item will be checked out from. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table 
        /// that indicates the bin that the material for this cost
        /// item will be checked out from. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract Guid? StoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table 
        /// that indicates the catalogue of the material that will be
        /// checked out. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the description of this cost item.
        /// </summary>
        public abstract String CostDescription { get; set; }


        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the technician is expected to work overtime for this
        /// scheduled work. 
        /// <para></para>
        /// <list>
        ///   <item>0 - No, technician is not expected to work overtime.</item>
        ///   <item>1 - Yes, technician is expected to work overtime.</item>
        /// </list>
        /// </summary>
        public abstract int? EstimatedOvertime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the estimated unit cost of this cost
        /// item. If CostType = 0, this represents the estimated hourly
        /// rate of technicians of the specified craft.
        /// </summary>
        public abstract Decimal? EstimatedUnitCost { get; set; }

        /// <summary>
        /// [Column] Gets or sets a cost factor applied to the cost
        /// to give the final cost.
        /// </summary>
        public abstract Decimal? EstimatedCostFactor { get; set; }


        /// <summary>
        /// [Column] Gets or sets estimated quantity required
        /// to complete maintenance of works created by this
        /// scheduled work.
        /// </summary>
        public abstract Decimal? EstimatedQuantity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the estimated total for this cost
        /// item. This can be computed by taking EstimatedUnitCost x
        /// EstimatedCostFactor x EstimatedQuantity.
        /// </summary>
        public abstract Decimal? EstimatedCostTotal { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents 
        /// the store that the material for this cost
        /// item will be checked out from. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents
        /// the bin that the material for this cost
        /// item will be checked out from. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }

        /// <summary>
        /// Gets or sets the OScheduledWork object that represents
        /// indicates the scheduled work object that contains this record.
        /// </summary>
        public abstract OScheduledWork ScheduledWork { get; set; }

        /// <summary>
        /// Gets or sets the OCraft object that represents
        /// the craft of the technicians that this
        /// cost is associated with. This is applicable only if
        /// CostType = 0.
        /// </summary>
        public abstract OCraft Craft { get; set; }

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract OUser Technician { get; set; }

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract OFixedRate FixedRate { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that represents
        /// the catalogue of the material that will be
        /// checked out. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents
        /// the unit of measure that this material
        /// will be checked out from the store as. This is applicable
        /// only if CostType = 3.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set; }


        /// <summary>
        /// Gets the estimated sub total of this cost item.
        /// This is be computed by taking EstimatedUnitCost x
        /// EstimatedCostFactor x EstimatedQuantity.
        /// </summary>
        public decimal? EstimatedSubTotal
        {
            get
            {
                return EstimatedCostTotal == null ? EstimatedUnitCost * EstimatedCostFactor * EstimatedQuantity : EstimatedCostTotal;
            }
        }

        /// <summary>
        /// Gets the localized text for the type of cost.
        /// </summary>
        public string CostTypeName
        {
            get
            {
                if (CostType == null)
                    return "";
                else if (CostType == 0)
                    return LogicLayer.Resources.Strings.CostType_Technician;
                else if (CostType == 1)
                    return LogicLayer.Resources.Strings.CostType_FixedRate;
                else if (CostType == 2)
                    return LogicLayer.Resources.Strings.CostType_AdhocRate;
                else if (CostType == 3)
                    return LogicLayer.Resources.Strings.CostType_Material;
                return "";
            }
        }


        /// <summary>
        /// Gets the name of the craft (if CostType = 0) or the
        /// name of the store (if CostType = 3).
        /// </summary>
        public string CraftStore
        {
            get
            {
                if (CostType == null)
                    return "";
                else if (CostType == WorkCostType.Technician && Craft != null)
                    return Craft.ObjectName;
                else if (CostType == WorkCostType.Material && Store != null & StoreBin != null)
                    return Store.ObjectName + " (" + StoreBin.ObjectName + ")";
                return "";
            }
        }



        //----------------------------------------------------------------
        /// <summary>
        /// Recompute the estimated and actual total. This should
        /// only be called after the cost has been updated.
        /// </summary>
        //----------------------------------------------------------------
        public void RecomputeEstimatedTotal()
        {
            if (CostType == WorkCostType.Material)
            {
                //this.EstimatedCostTotal = null;
                //this.ActualCostTotal = null;
            }
            else
            {
                this.EstimatedCostTotal =
                    this.EstimatedQuantity * this.EstimatedUnitCost * this.EstimatedCostFactor;
            }
        }
    }
}

