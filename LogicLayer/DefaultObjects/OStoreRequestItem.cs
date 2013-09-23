//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
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
    /// </summary>
    [Database("#database"), Map("StoreRequestItem")]
    [Serializable]
    public partial class TStoreRequestItem : LogicLayerSchema<OStoreRequestItem>
    {
        public SchemaGuid StoreRequestID;
        public SchemaGuid CatalogueID;
        public SchemaGuid StoreBinID;
        public SchemaGuid StoreBinReservationID;
        public SchemaDecimal BaseQuantityReserved;
        public SchemaDecimal BaseQuantityReturned; 
        public SchemaDecimal EstimatedUnitCost;
        public SchemaDecimal ActualUnitCost;
        public SchemaGuid ActualUnitOfMeasureReservedID;
        public SchemaDecimal ActualQuantityReserved;
        public SchemaGuid ActualUnitOfMeasureReturnedID;
        public SchemaDecimal ActualQuantityReturned;
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TStoreRequest StoreRequest { get { return OneToOne<TStoreRequest>("StoreRequestID"); } }
        public TStoreBinReservation StoreBinReservation { get { return OneToOne<TStoreBinReservation>("StoreBinReservationID"); } }        
        public TCode ActualUnitOfMeasureReserved { get { return OneToOne<TCode>("ActualUnitOfMeasureReservedID"); } }
        public TCode ActualUnitOfMeasureReturned { get { return OneToOne<TCode>("ActualUnitOfMeasureReturnedID"); } }
        public TStoreRequestItemCheckOut StoreRequestItemCheckOuts { get { return OneToMany<TStoreRequestItemCheckOut>("StoreRequestItemID"); } }
    }


    /// <summary>
    /// </summary>
    [Serializable]
    public abstract class OStoreRequestItem : LogicLayerPersistentObject
    {
        public abstract Guid? StoreRequestID { get; set; }
        public abstract Guid? CatalogueID { get; set; }
        public abstract Guid? StoreBinID { get; set; }
        public abstract Guid? StoreBinReservationID { get; set; }
        public abstract decimal? BaseQuantityReserved { get; set; }
        public abstract decimal? BaseQuantityReturned { get; set; }
        public abstract decimal? EstimatedUnitCost { get; set; }
        public abstract decimal? ActualUnitCost { get; set; }
        public abstract Guid? ActualUnitOfMeasureReservedID { get; set; }
        public abstract decimal? ActualQuantityReserved { get; set; }
        public abstract Guid? ActualUnitOfMeasureReturnedID { get; set; }
        public abstract decimal? ActualQuantityReturned { get; set; }
        public abstract OCatalogue Catalogue { get; set; }
        public abstract OStoreBin StoreBin { get; set; }
        public abstract OStoreRequest StoreRequest { get; set; }
        public abstract OStoreBinReservation StoreBinReservation { get; set; }
        public abstract OCode ActualUnitOfMeasureReserved { get; set; }
        public abstract OCode ActualUnitOfMeasureReturned { get; set; }
        public abstract DataList<OStoreRequestItemCheckOut> StoreRequestItemCheckOuts { get; set; }

        public bool Valid = true;

        /// <summary>
        /// Gets a text to be displayed on screen for an example of the conversion of units.
        /// </summary>
        public string ConversionTextReserve
        {
            get
            {
                if (CatalogueID != null && ActualUnitOfMeasureReservedID != null)
                {
                    decimal conversionFactor = OUnitConversion.FindConversionFactor((Guid)Catalogue.UnitOfMeasureID, (Guid)ActualUnitOfMeasureReservedID);

                    if (conversionFactor > 0 && (Guid)Catalogue.UnitOfMeasureID != (Guid)ActualUnitOfMeasureReservedID)
                        return
                            "1 " + Catalogue.UnitOfMeasure.ObjectName + " = " + conversionFactor + " " + ActualUnitOfMeasureReserved.ObjectName + "; " +
                            "1 " + ActualUnitOfMeasureReserved.ObjectName + " = " + 1 / conversionFactor + " " + Catalogue.UnitOfMeasure.ObjectName + "; " +
                            "";
                }
                return "";
            }
        }

        /// <summary>
        /// Gets a text to be displayed on screen for an example of the conversion of units.
        /// </summary>
        public string ConversionTextReturn
        {
            get
            {
                if (CatalogueID != null && ActualUnitOfMeasureReturnedID != null)
                {
                    decimal conversionFactor = OUnitConversion.FindConversionFactor((Guid)Catalogue.UnitOfMeasureID, (Guid)ActualUnitOfMeasureReturnedID);

                    if (conversionFactor > 0 && (Guid)Catalogue.UnitOfMeasureID != (Guid)ActualUnitOfMeasureReturnedID)
                        return
                            "1 " + Catalogue.UnitOfMeasure.ObjectName + " = " + conversionFactor + " " + ActualUnitOfMeasureReturned.ObjectName + "; " +
                            "1 " + ActualUnitOfMeasureReturned.ObjectName + " = " + 1 / conversionFactor + " " + Catalogue.UnitOfMeasure.ObjectName + "; " +
                            "";
                }
                return "";
            }
        }

        /// <summary>
        /// Gets the sub-total as the unit price multiplied
        /// by the quantity. 
        /// </summary>
        public decimal? SubTotal
        {
            get
            {                
                return this.EstimatedUnitCost * this.BaseQuantityReserved;                
            }
        }

        /// <summary>
        /// Gets the sub-total as the unit price multiplied
        /// by the quantity. 
        /// </summary>
        public decimal? SubTotalActual
        {
            get
            {
                if (BaseQuantityReturned == null || BaseQuantityReturned == 0)
                    return this.ActualUnitCost * this.BaseQuantityReserved;
                else
                    return this.ActualUnitCost * (this.BaseQuantityReserved - this.BaseQuantityReturned);
            }
        }

        public decimal? BaseQuantityUsed
        {
            get
            {
                if (ActualQuantityReturned == null || ActualQuantityReturned == 0)
                    return this.BaseQuantityReserved;
                else
                    return (this.BaseQuantityReserved - this.BaseQuantityReturned);
            }
        }

        public decimal? UnitCost
        {
            get
            {
                if (ActualQuantityReturned == null || ActualQuantityReturned == 0)
                    return this.EstimatedUnitCost;
                else
                    return this.ActualUnitCost;
            }
        }

        public void ComputeBaseQuantityReserved()
        {
            decimal conversionFactor = OUnitConversion.FindConversionFactor((Guid)Catalogue.UnitOfMeasureID, (Guid)ActualUnitOfMeasureReservedID);
            if (conversionFactor <= 0)
                this.BaseQuantityReserved = null;
            else
                this.BaseQuantityReserved = (decimal)this.ActualQuantityReserved / conversionFactor;
        }

        public void ComputeBaseQuantityReturned()
        {
            if (this.ActualQuantityReturned != null)
            {
                decimal conversionFactor = OUnitConversion.FindConversionFactor((Guid)Catalogue.UnitOfMeasureID, (Guid)ActualUnitOfMeasureReturnedID);
                if (conversionFactor <= 0)
                    this.BaseQuantityReturned = null;
                else
                    this.BaseQuantityReturned = this.ActualQuantityReturned / conversionFactor;
            }
            
        }

        /// <summary>
        /// Computes the estimated unit cost of the check out items.
        /// </summary>
        public void ComputeEstimatedUnitCost()
        {
            decimal estimatedUnitCost = 0;
            decimal estimatedTotalCost = 0;


            this.StoreBin.Store.PeekItemsUnitCost(
                this.StoreBinID.Value,
                this.CatalogueID.Value,
                this.ActualQuantityReserved.Value,
                this.ActualUnitOfMeasureReservedID.Value,
                out estimatedUnitCost,
                out estimatedTotalCost);

            this.EstimatedUnitCost = estimatedUnitCost;
        }
        
       
        public void HandleReservation()
        {
            if ( this.StoreBinID != null && this.CatalogueID != null)
            {
                
                decimal ActualQuantity = this.ActualQuantityReserved != null ? (decimal)this.ActualQuantityReserved : 0;

                decimal factor = OUnitConversion.FindConversionFactor((Guid)this.Catalogue.UnitOfMeasureID, (Guid)this.ActualUnitOfMeasureReservedID);
                
                // estimate the unit cost of the items.
                //                
                decimal estUnitCost = 0, estTotal = 0;

                if (ActualQuantity > 0)
                {
                    this.StoreBin.Store.PeekItemsUnitCost(
                        (Guid)this.StoreBinID, (Guid)this.CatalogueID, ActualQuantity, (Guid)this.ActualUnitOfMeasureReservedID,
                        out estUnitCost, out estTotal);
                }

                this.EstimatedUnitCost = estUnitCost;
                //this.EstimatedCostTotal = estTotal;
                ComputeBaseQuantityReserved();

                OStoreBinReservation res = TablesLogic.tStoreBinReservation.Create();
                res.StoreRequestItemID = this.ObjectID;
                this.StoreBinReservationID = res.ObjectID;
                this.StoreBinReservation = res;
                res.StoreBinID = this.StoreBinID;
                res.CatalogueID = this.CatalogueID;                
                res.BaseQuantityReserved = ActualQuantity / factor;
                res.DateOfReservation = DateTime.Now;
                res.Save();
            }
        }

        public override void Deactivating()
        {
            base.Deactivating();
            CancelReservation();
            foreach (OStoreRequestItemCheckOut Item in this.StoreRequestItemCheckOuts)
            {
                Item.Deactivate();
            }
        }

        public void CancelReservation()
        {
            if (this.StoreBinReservation != null)            
            {
                this.StoreBinReservation.BaseQuantityReserved = 0;
                this.StoreBinReservation.Deactivate();
            }
        }

        public void HandleCheckOut()
        {
            if (this.StoreBinID != null && this.CatalogueID != null)
            {
                decimal ActualQuantity = this.ActualQuantityReserved != null ? (decimal)this.ActualQuantityReserved : 0;

                decimal factor = OUnitConversion.FindConversionFactor((Guid)this.Catalogue.UnitOfMeasureID, (Guid)this.ActualUnitOfMeasureReservedID);

                if (ActualQuantity > 0)
                {
                    
                    List<StoreCheckOutItemDetail> details = this.StoreBin.Store.CheckOutStoreRequestItems(
                              (Guid)this.StoreBinID, (Guid)this.CatalogueID, ActualQuantity, (Guid)this.ActualUnitOfMeasureReservedID,
                              (int)this.StoreRequest.DestinationType, this.StoreRequest.UserID, this.ObjectID);

                    decimal totalCost = 0;
                    decimal totalCount = 0;
                    foreach (StoreCheckOutItemDetail detail in details)
                    {
                        OStoreRequestItemCheckOut item = TablesLogic.tStoreRequestItemCheckOut.Create();
                        item.StoreBinItemID = detail.StoreBinItemID;
                        item.StoreRequestItemID = this.ObjectID;
                        item.UnitPrice = detail.UnitPrice;
                        item.Quantity = detail.BaseQuantity;
                        item.Save();

                        totalCost += detail.UnitPrice * detail.BaseQuantity;
                        totalCount += detail.BaseQuantity;
                    }
                    ActualQuantity = totalCount;
                    ActualUnitCost = totalCost / totalCount; 
                    this.ActualQuantityReserved = totalCount * factor;
                }
                else
                {
                    this.ActualQuantityReserved = 0;
                    //this.ActualUnitCost = 0;
                    //this.ActualCostTotal = 0;
                }
            }
            CancelReservation();
           
        }

        public void HandleReturn()
        {
            if (this.StoreBinID != null && this.CatalogueID != null)
            {                
                
                // is there a return in actual quantity
                // perform a check-in-out if so.
                //
                if (ActualQuantityReturned > 0)
                {
                    decimal factor = OUnitConversion.FindConversionFactor((Guid)this.Catalogue.UnitOfMeasureID, (Guid)this.ActualUnitOfMeasureReservedID);
                    decimal factorReturn = OUnitConversion.FindConversionFactor((Guid)this.Catalogue.UnitOfMeasureID, (Guid)this.ActualUnitOfMeasureReturnedID);

                    // if there are items already checked out,
                    // check them in first
                    //
                    List<OStoreRequestItemCheckOut> StoreRequestItemCheckOut =
                        TablesLogic.tStoreRequestItemCheckOut[
                        TablesLogic.tStoreRequestItemCheckOut.StoreRequestItemID == this.ObjectID];

                    if (StoreRequestItemCheckOut.Count > 0)
                    {
                        List<StoreCheckInWorkOrderItemDetail> details = new List<StoreCheckInWorkOrderItemDetail>();

                        foreach (OStoreRequestItemCheckOut checkOutItem in StoreRequestItemCheckOut)
                        {
                            StoreCheckInWorkOrderItemDetail detail = new StoreCheckInWorkOrderItemDetail();
                            detail.StoreBinItemID = (Guid)checkOutItem.StoreBinItemID;
                            detail.BaseQuantity = (decimal)checkOutItem.Quantity;
                            details.Add(detail);
                            checkOutItem.Deactivate();
                            checkOutItem.Save();
                        }
                        this.StoreBin.Store.CheckInStoreRequestItems((int)this.StoreRequest.DestinationType, this.StoreRequest.UserID, this.StoreBinReservationID, details, this.ObjectID);
                    }

                    // now check out items again...
                    //
                    ComputeBaseQuantityReturned();
                    decimal baseQuantityUsed = (decimal)this.BaseQuantityReserved - (decimal)this.BaseQuantityReturned;
                    if (baseQuantityUsed > 0)
                    {
                        List<StoreCheckOutItemDetail> details = this.StoreBin.Store.CheckOutStoreRequestItems(
                            (Guid)this.StoreBinID, (Guid)this.CatalogueID, baseQuantityUsed, (Guid)this.Catalogue.UnitOfMeasureID,
                            (int)this.StoreRequest.DestinationType, this.StoreRequest.UserID, this.ObjectID);

                        decimal totalCost = 0;
                        decimal totalCount = 0;
                        foreach (StoreCheckOutItemDetail detail in details)
                        {
                            OStoreRequestItemCheckOut item = TablesLogic.tStoreRequestItemCheckOut.Create();
                            item.StoreBinItemID = detail.StoreBinItemID;
                            item.StoreRequestItemID = this.ObjectID;
                            item.UnitPrice = detail.UnitPrice;
                            item.Quantity = detail.BaseQuantity;
                            item.Save();

                            totalCost += detail.UnitPrice * detail.BaseQuantity;
                            totalCount += detail.BaseQuantity;
                        }
                        ActualUnitCost = totalCost / totalCount;
                    }
                }               
            }
        }

        public override void Saving()
        {
            base.Saving();
            //if (StoreRequest.IsReturned == 1)
            //    HandleReturn();
            //else if (StoreRequest.IsCheckedOuted == 1)
            //    HandleCheckOut();
            //else if (StoreRequest.IsReserved == 1)
            //    HandleReservation();
        }

    }
    
}
