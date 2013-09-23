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
    [Database("#database"), Map("WorkCost")]
    public partial class TWorkCost : LogicLayerSchema<OWorkCost>
    {
        public SchemaGuid WorkID;
        public SchemaInt CostType;
        public SchemaGuid StoreID;
        public SchemaGuid StoreBinID;
        public SchemaGuid StoreBinReservationID;
        public SchemaGuid CatalogueID;
        public SchemaGuid CraftID;
        public SchemaGuid UserID;
        public SchemaGuid FixedRateID;
        public SchemaGuid PartID;
        public SchemaGuid UnitOfMeasureID;
        [Size(2000)]
        public SchemaString CostDescription;
        [Default(0)]
        public SchemaInt EstimatedOvertime;
        [Default(0)]
        public SchemaDecimal EstimatedUnitCost;
        [Default(0)]
        public SchemaDecimal EstimatedQuantity;
        [Default(0)]
        public SchemaDecimal EstimatedQuantityPrevious;
        [Default(1)]
        public SchemaDecimal EstimatedCostFactor;
        [Default(0)]
        public SchemaDecimal EstimatedCostTotal;
        [Default(0)]
        public SchemaInt ActualOvertime;
        [Default(0)]
        public SchemaDecimal ActualUnitCost;
        [Default(0)]
        public SchemaDecimal ActualQuantity;
        [Default(0)]
        public SchemaDecimal ActualQuantityPrevious;
        [Default(1)]
        public SchemaDecimal ActualCostFactor;
        [Default(0)]
        public SchemaDecimal ActualCostTotal;
        public SchemaDecimal ChargeOut;

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TStoreBinReservation StoreBinReservation { get { return OneToOne<TStoreBinReservation>("StoreBinReservationID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TCraft Craft { get { return OneToOne<TCraft>("CraftID"); } }
        public TUser Technician { get { return OneToOne<TUser>("UserID"); } }
        public TFixedRate FixedRate { get { return OneToOne<TFixedRate>("FixedRateID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }
    }


    /// <summary>
    /// Represents the maintenance cost that will be incurred or
    /// has been incurred by the work.
    /// </summary>
    public abstract partial class OWorkCost : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Work table 
        /// that indicates the work object that this cost item applies to.
        /// </summary>
        public abstract Guid? WorkID { get; set;}


        /// <summary>
        /// [Column] Gets or sets a value that indicates the type of
        /// the cost this cost item is classified under.
        /// <para></para>
        /// <list>
        ///   <item>0 - Craft and technician.</item>
        ///   <item>1 - Obsolete, not used anymore.</item>
        ///   <item>2 - Others.</item>
        ///   <item>3 - Material</item>        /// </list>
        /// </summary>
        public abstract int? CostType { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table 
        /// that indicates the store that the material will be
        /// checked out from. This is applicable only if CostType = 3.
        /// </summary>
        public abstract Guid? StoreID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table 
        /// that indicates the bin that the material will be
        /// checked out from. This is applicable only if CostType = 3.
        /// </summary>
        public abstract Guid? StoreBinID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBinReservation table 
        /// that indicates the record used to indicate the reservation
        /// of the material at the store bin. This is applicable only 
        /// if CostType = 3.
        /// </summary>
        public abstract Guid? StoreBinReservationID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table 
        /// that indicates the record used to indicate the catalogue
        /// of the material that will be used in the work.
        /// </summary>
        public abstract Guid? CatalogueID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Craft table 
        /// that indicates the craft of the technician that will 
        /// be assigned to this work. This is applicable only 
        /// if CostType = 0.
        /// </summary>
        public abstract Guid? CraftID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table 
        /// that indicates the in-house maintenance technician who
        /// will be assigned to this work. This is applicable only 
        /// if CostType = 0.
        /// </summary>
        public abstract Guid? UserID { get; set;}

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract Guid? FixedRateID { get; set;}

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract Guid? PartID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the unit of measure of this cost item.
        /// When CostType = 3 for material check-outs, this 
        /// indicates the unit that the material will be checked
        /// out of the store in.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set;}

        /// <summary>
        /// [Column] Gets or sets the description that of this cost
        /// item.
        /// </summary>
        public abstract String CostDescription { get; set;}

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the technician is expected to work overtime for this
        /// work. 
        /// <para></para>
        /// <list>
        ///   <item>0 - No, technician is not expected to work overtime.</item>
        ///   <item>1 - Yes, technician is expected to work overtime.</item>
        /// </list>
        /// </summary>
        public abstract int? EstimatedOvertime { get; set;}

        /// <summary>
        /// [Column] Gets or sets the estimated unit cost of this cost
        /// item. If CostType = 0, this represents the estimated hourly
        /// rate of technicians of the specified craft.
        /// </summary>
        public abstract Decimal? EstimatedUnitCost { get; set;}

        /// <summary>
        /// [Column] Gets or sets estimated quantity required
        /// to complete maintenance of works created by this
        /// work.
        /// </summary>
        public abstract Decimal? EstimatedQuantity { get; set;}

        /// <summary>
        /// [Column] Gets or sets the estimated quantity
        /// previously saved into the database.
        /// </summary>
        public abstract Decimal? EstimatedQuantityPrevious { get; set; }

        /// <summary>
        /// [Column] Gets or sets a cost factor applied to the cost
        /// to give the final cost.
        /// </summary>
        public abstract Decimal? EstimatedCostFactor { get; set;}

        /// <summary>
        /// [Column] Gets or sets the estimated total for this cost
        /// item. This can be computed by taking EstimatedUnitCost x
        /// EstimatedCostFactor x EstimatedQuantity.
        /// </summary>
        public abstract Decimal? EstimatedCostTotal { get; set;}

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the technician has worked overtime for this
        /// work. 
        /// <para></para>
        /// <list>
        ///   <item>0 - No, technician has not worked overtime.</item>
        ///   <item>1 - Yes, technician has worked overtime.</item>
        /// </list>
        /// </summary>
        public abstract int? ActualOvertime { get; set;}

        /// <summary>
        /// [Column] Gets or sets the actual unit cost of this cost
        /// item. If CostType = 0, this represents the actual hourly
        /// rate of technicians of the specified craft.
        /// </summary>
        public abstract Decimal? ActualUnitCost { get; set;}

        /// <summary>
        /// [Column] Gets or sets actual quantity required
        /// to complete maintenance of works created by this
        /// work.
        /// </summary>
        public abstract Decimal? ActualQuantity { get; set;}

        /// <summary>
        /// [Column] Gets or sets actual quantity previously saved.
        /// </summary>
        public abstract Decimal? ActualQuantityPrevious { get; set; }

        /// <summary>
        /// [Column] Gets or sets a cost factor applied to the cost
        /// to give the final cost.
        /// </summary>
        public abstract Decimal? ActualCostFactor { get; set;}

        /// <summary>
        /// [Column] Gets or sets the actual total for this cost
        /// item. This can be computed by taking ActualUnitCost x
        /// ActualCostFactor x ActualQuantity.
        /// </summary>
        public abstract Decimal? ActualCostTotal { get; set;}

        /// <summary>
        /// [Column] Gets or sets the amount to charge the caller
        /// for this work. This is applicable only if the Work's
        /// IsChargedToCaller = 1.
        /// </summary>
        public abstract Decimal? ChargeOut { get; set;}

        /// <summary>
        /// Gets or sets the OStore object that represents the
        /// store that the material will be checked out from.
        /// This is applicable only if CostType = 3.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the bin that the material will be
        /// checked out from. This is applicable only if CostType = 3.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBinReservation object 
        /// that represents the record used to indicate the reservation
        /// of the material at the store bin. This is applicable only 
        /// if CostType = 3.
        /// </summary>
        public abstract OStoreBinReservation StoreBinReservation { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that representsthe catalogue
        /// of the material that will be used in the work.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OCraft object that represents craft of
        /// the technician that will be assigned to this work. 
        /// This is applicable only if CostType = 0.
        /// </summary>
        public abstract OCraft Craft { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents
        /// the in-house maintenance technician who
        /// will be assigned to this work. This is applicable only 
        /// if CostType = 0.
        /// </summary>
        public abstract OUser Technician { get; set; }

        /// <summary>
        /// [Column] This is obsolete and not in use.
        /// </summary>
        [Obsolete]
        public abstract OFixedRate FixedRate { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the unit of measure of this cost item.
        /// When CostType = 3 for material check-outs, this 
        /// indicates the unit that the material will be checked
        /// out of the store in.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set; }

        public abstract OWork Work { get; set; }

        public bool Valid = true;

        /// <summary>
        /// Gets the estimated subtotal of this work.
        /// This is computed by taking EstimatedUnitCost x
        /// EstimatedCostFactor x EstimatedQuantity.
        /// </summary>
        public decimal? EstimatedSubTotal
        {
            get
            {
                return EstimatedCostTotal==null ? EstimatedUnitCost * EstimatedCostFactor * EstimatedQuantity : EstimatedCostTotal;
            }
        }


        /// <summary>
        /// Gets the actual subtotal of this work.
        /// This is computed by taking ActualUnitCost x
        /// ActualCostFactor x ActualQuantity.
        /// </summary>
        public decimal? ActualSubTotal
        {
            get
            {
                return ActualCostTotal == null ? ActualUnitCost * ActualCostFactor * ActualQuantity : ActualCostTotal;
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

        /// <summary>
        /// Gets the localized text for the type of cost.
        /// </summary>
        public string CostTypeName
        {
            get
            {
                if (CostType == null)
                    return "";
                else if (CostType == WorkCostType.Technician)
                    return LogicLayer.Resources.Strings.CostType_Technician;
                else if (CostType == WorkCostType.FixedRate)
                    return LogicLayer.Resources.Strings.CostType_FixedRate;
                else if (CostType == WorkCostType.AdhocRate)
                    return LogicLayer.Resources.Strings.CostType_AdhocRate;
                else if (CostType == WorkCostType.Material)
                    return LogicLayer.Resources.Strings.CostType_Material;
                else if (CostType == WorkCostType.TaxCode)
                    return LogicLayer.Resources.Strings.CostType_TaxCode;
                return "";
            }
        }

        /// <summary>
        /// Gets the localized text for the 'hour' if CostType = 0
        /// (craft/technician). Otherwise, gets the selected unit 
        /// of measure's name.
        /// </summary>
        public string UnitOfMeasureText
        {
            get
            {
                if (UnitOfMeasure != null)
                    return UnitOfMeasure.ObjectName;
                else if (CostType == 0)
                    return LogicLayer.Resources.Strings.UnitOfMeasureText_Hour;
                else
                    return "";
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// This object is only deactivable if it has not been saved,
        /// or if this is not a Material cost type.
        /// 
        /// Returns true if deactivable, false otherwise. The 
        /// UIGridview makes use of this field to hide and show the
        /// DeleteObject button accordingly.
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------
        public override bool IsDeactivatable()
        {
            return IsNew || CostType != WorkCostType.Material;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// This method is overriden to check-out items from the store
        /// when saving this work cost.
        /// 
        /// The application must be responsible for validating that
        /// the check-out is possible (given the physical balances in
        /// the store vs the number reserved items, etc).
        /// </summary>
        //----------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            // not happy that this should be here?
            // (then comment it or move it elsewhere)
            //
            HandlRemovedItems();
            //HandleCheckOut();
            //HandleReservation();

            this.ActualQuantityPrevious = this.ActualQuantity;
            this.EstimatedQuantityPrevious = this.EstimatedQuantity;
        }



        //----------------------------------------------------------------
        /// <summary>
        /// Handles items removed from the work cost.
        /// </summary>
        //----------------------------------------------------------------
        public void HandlRemovedItems()
        {
        }


        //----------------------------------------------------------------
        /// <summary>
        /// If this is a store item, checks if there was a change in the
        /// actual quantity. Perform check-in/out if so.
        /// 
        /// Where applicable, this method must always be called BEFORE
        /// calling HandleReservation();
        /// </summary>
        //----------------------------------------------------------------
        public void HandleCheckOut()
        {
            if (this.CostType==WorkCostType.Material && this.StoreBinID != null && this.CatalogueID != null)
            {
                OWorkCost oldWorkCost = TablesLogic.tWorkCost[(Guid)this.ObjectID];

                decimal oldActualQuantity = this.ActualQuantityPrevious != null ? (decimal)this.ActualQuantityPrevious : 0;
                decimal newActualQuantity = this.ActualQuantity != null ? (decimal)this.ActualQuantity : 0;

                decimal factor = OUnitConversion.FindConversionFactor((Guid)this.Catalogue.UnitOfMeasureID, (Guid)this.UnitOfMeasureID);

                // is there a change in actual quantity
                // perform a check-out if so.
                //
                if (newActualQuantity != oldActualQuantity)
                {
                    // if there are items already checked out,
                    // check them in first
                    //
                    List<OWorkCostCheckOutItem> workCostCheckOutItem =
                        TablesLogic.tWorkCostCheckOutItem[
                        TablesLogic.tWorkCostCheckOutItem.WorkCostID == this.ObjectID];
                    
                    if (workCostCheckOutItem.Count > 0)
                    {
                        List<StoreCheckInWorkOrderItemDetail> details = new List<StoreCheckInWorkOrderItemDetail>();

                        foreach (OWorkCostCheckOutItem checkOutItem in workCostCheckOutItem)
                        {
                            StoreCheckInWorkOrderItemDetail detail = new StoreCheckInWorkOrderItemDetail();
                            detail.StoreBinItemID = (Guid)checkOutItem.StoreBinItemID;
                            detail.BaseQuantity = (decimal)checkOutItem.Quantity;
                            details.Add(detail);
                            checkOutItem.Deactivate();
                            checkOutItem.Save();
                        }
                        this.Store.CheckInWorkOrderItems((Guid)this.WorkID, this.StoreBinReservationID, details, this.ObjectID);
                    }

                    // now check out items again...
                    //
                    if (newActualQuantity > 0)
                    {
                        List<StoreCheckOutItemDetail> details = this.Store.CheckOutWorkOrderItems(
                            (Guid)this.StoreBinID, (Guid)this.CatalogueID, newActualQuantity, (Guid)this.UnitOfMeasureID, (Guid)this.WorkID, this.ObjectID);

                        decimal totalCost = 0;
                        decimal totalCount = 0;
                        foreach (StoreCheckOutItemDetail detail in details)
                        {
                            OWorkCostCheckOutItem item = TablesLogic.tWorkCostCheckOutItem.Create();
                            item.StoreBinItemID = detail.StoreBinItemID;
                            item.WorkCostID = this.ObjectID;
                            item.UnitPrice = detail.UnitPrice;
                            item.Quantity = detail.BaseQuantity;
                            item.Save();

                            totalCost += detail.UnitPrice * detail.BaseQuantity;
                            totalCount += detail.BaseQuantity;
                        }
                        newActualQuantity = totalCount;
                        this.ActualQuantity = totalCount * factor;
                        this.ActualUnitCost = totalCost / totalCount / factor;
                        this.ActualCostTotal = totalCost;
                    }
                    else
                    {
                        this.ActualQuantity = 0;
                        this.ActualUnitCost = 0;
                        this.ActualCostTotal = 0;
                    }
                }
            }
        }


        //----------------------------------------------------------------
        /// <summary>
        /// If this is a store item, checks if there was a change in the
        /// estimated quantity. Perform reservation if so.
        /// 
        /// Where applicable, this method must always be called AFTER
        /// calling HandleCheckOut();
        /// </summary>
        //----------------------------------------------------------------
        public void HandleReservation()
        {
            if (this.CostType == WorkCostType.Material && this.StoreBinID != null && this.CatalogueID != null)
            {
                OWorkCost oldWorkCost = TablesLogic.tWorkCost[(Guid)this.ObjectID];

                Guid? oldStoreBinId = oldWorkCost != null ? oldWorkCost.StoreBinID : null;
                decimal oldActualQuantity = this.ActualQuantityPrevious != null ? (decimal)this.ActualQuantityPrevious : 0;
                decimal oldEstimatedQuantity = this.EstimatedQuantityPrevious != null ? (decimal)this.EstimatedQuantityPrevious : 0;
                decimal newActualQuantity = this.ActualQuantity != null ? (decimal)this.ActualQuantity : 0;
                decimal newEstimatedQuantity = this.EstimatedQuantity != null ? (decimal)this.EstimatedQuantity : 0;

                decimal factor = OUnitConversion.FindConversionFactor((Guid)this.Catalogue.UnitOfMeasureID, (Guid)this.UnitOfMeasureID);

                // estimate the unit cost of the items.
                //
                if (newEstimatedQuantity != oldEstimatedQuantity || oldStoreBinId == null)
                {
                    decimal estUnitCost = 0, estTotal = 0;

                    if (newEstimatedQuantity > 0)
                    {
                        this.Store.PeekItemsUnitCost(
                            (Guid)this.StoreBinID, (Guid)this.CatalogueID, newEstimatedQuantity, (Guid)this.UnitOfMeasureID,
                            out estUnitCost, out estTotal);
                    }

                    this.EstimatedUnitCost = estUnitCost / factor;
                    this.EstimatedCostTotal = estTotal;
                }

                // check if there is a change in the estimated quantity.
                // make a reservation if so.
                //
                if (newEstimatedQuantity > 0 || newEstimatedQuantity != oldEstimatedQuantity)
                {
                    OStoreBinReservation res = null;
                    if (this.StoreBinReservationID == null)
                    {
                        res = TablesLogic.tStoreBinReservation.Create();
                        res.WorkCostID = this.ObjectID;
                        this.StoreBinReservationID = res.ObjectID;
                        this.StoreBinReservation = res;
                    }
                    else
                        res = this.StoreBinReservation;

                    res.StoreBinID = this.StoreBinID;
                    res.CatalogueID = this.CatalogueID;
                    if (newEstimatedQuantity != oldEstimatedQuantity)
                        res.BaseQuantityRequired = newEstimatedQuantity / factor;
                    res.DateOfReservation = DateTime.Now;

                    OWork work = TablesLogic.tWork[(Guid)this.WorkID];
                    if (work != null)
                    {
                        res.DateOfUse =
                            work.ScheduledStartDateTime != null ? work.ScheduledStartDateTime :
                            work.ActualStartDateTime != null ? work.ActualStartDateTime : null;
                    }
                    res.BaseQuantityReserved = (newEstimatedQuantity - newActualQuantity) / factor;
                    if (res.BaseQuantityReserved < 0)
                        res.BaseQuantityReserved = 0;
                    if (res.BaseQuantityReserved > res.BaseQuantityRequired)
                        res.BaseQuantityReserved = res.BaseQuantityRequired;
                    res.Save();
                }
            }
        }



        //----------------------------------------------------------------
        /// <summary>
        /// Recompute the estimated and actual total. This should
        /// only be called after the cost has been updated.
        /// </summary>
        //----------------------------------------------------------------
        public void RecomputeEstimatedAndActualTotal()
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
                this.ActualCostTotal =
                    this.ActualQuantity * this.ActualUnitCost * this.ActualCostFactor;
            }

             //2010.11.02
             //Updated the charge-out.
            
            //this.ChargeOutUnitPrice = Round(this.ActualUnitCost * this.ActualCostFactor);
            decimal? chargeOutUnitPrice = Round(this.ActualUnitCost * this.ActualCostFactor);
            this.ChargeOut = Round(this.ActualQuantity * chargeOutUnitPrice);
        }
    }


    public class WorkCostType
    {
        public const int Technician = 0;
        public const int FixedRate = 1;
        public const int AdhocRate = 2;
        public const int Material = 3;
        public const int TaxCode = 4;
    }

}