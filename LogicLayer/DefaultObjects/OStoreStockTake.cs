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

using Anacle.DataFramework; //DataFramework

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStoreStockTake
    /// </summary>
    [Database("#database"), Map("StoreStockTake")]
    public partial class TStoreStockTake : LogicLayerSchema<OStoreStockTake>
    {
        public SchemaGuid StoreAdjustID;
        public SchemaGuid StoreID;
        
        public SchemaDateTime StoreStockTakeStartDateTime;
        public SchemaDateTime StoreStockTakeEndDateTime;

        public TStoreAdjust StoreAdjust { get { return OneToOne<TStoreAdjust>("StoreAdjustID"); } }
        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TStoreBin StoreBins { get { return ManyToMany<TStoreBin>("StoreStockTakeBin", "StoreStockTakeID", "StoreBinID"); } }
        public TStoreStockTakeBinItem StoreStockTakeBinItems { get { return OneToMany<TStoreStockTakeBinItem>("StoreStockTakeID"); } }
    }


    public abstract partial class OStoreStockTake : LogicLayerPersistentObject, IWorkflowEnabled, IAutoGenerateRunningNumber//WorkflowPersistentObject
    {
        public abstract Guid? StoreAdjustID { get; set; }
        public abstract Guid? StoreID { get; set; }

        public abstract DateTime? StoreStockTakeStartDateTime { get; set; }
        public abstract DateTime? StoreStockTakeEndDateTime { get; set; }

        public abstract OStoreAdjust StoreAdjust { get; }
        public abstract OStore Store { get;}
        public abstract DataList<OStoreBin> StoreBins { get; set; }
        public abstract DataList<OStoreStockTakeBinItem> StoreStockTakeBinItems { get; set; }

        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();

                if (this.Store != null)
                    locations.Add(this.Store.Location);

                return locations;
            }
        }

        public override void Saving()
        {
            base.Saving();

            //if (this.IsNew)
            //{
            //    Connection.ExecuteQuery("#database", "select * from [StoreStockTake] with (tablock, holdlock)"); 
            //    // format of the WO number can be changed per customization
            //    //
            //    //int count = (TablesLogic.tStoreStockTake[TablesLogic.tStoreStockTake.ObjectNumber.Like("PD-" + DateTime.Now.ToString("yyyyMMdd") + "%"), true]).Count;
            //    //this.ObjectNumber = "PD-" + DateTime.Now.ToString("yyyyMMdd") + "-" + (count + 1).ToString("000");
            //}
        }

        public void LockRelatedStoreBins()
        {
            using (Connection c = new Connection())
            {
                foreach (OStoreBin storebin in StoreBins)
                {
                    if (storebin.IsLocked == 1)
                        throw new Exception(storebin.ObjectName + " Bin already locked.");
                    storebin.IsLocked = 1;
                }

                c.Commit();
            }
        }

        public void UnlockRelatedStoreBins()
        {
            using (Connection c = new Connection())
            {
                foreach (OStoreBin storebin in StoreBins)
                {
                    storebin.IsLocked = 0;
                }

                c.Commit();
            }
        }


        /// <summary>
        /// Starts the stock take.
        /// </summary>
        public void StartStockStake()
        {
            using (Connection c = new Connection())
            {
                this.LockRelatedStoreBins();
                this.StoreStockTakeStartDateTime = System.DateTime.Now;
                this.PopulateStoreStockTakeBinItems();
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Closes the stock take.
        /// </summary>
        public void CloseStockStake()
        {
            using (Connection c = new Connection())
            {
                this.StoreStockTakeEndDateTime = System.DateTime.Now;
                this.UnlockRelatedStoreBins();
                this.Save();
                c.Commit();
            }
        }
        
        public List<OStoreStockTakeBinItem> GetStoreStockTakeItemsNeedingAdjustment()
        {
            return TablesLogic.tStoreStockTakeBinItem[
                TablesLogic.tStoreStockTakeBinItem.StoreStockTakeID == this.ObjectID &
                TablesLogic.tStoreStockTakeBinItem.PhysicalQuantity != TablesLogic.tStoreStockTakeBinItem.ObservedQuantity];
        }
        
        public void PopulateStoreStockTakeBinItems()
        {
            foreach (OStoreBin bin in StoreBins)
            {
                foreach (DataRow row in bin.StoreBinItemsConsolidated.Rows)
                {
                    OCatalogue item = TablesLogic.tCatalogue[new Guid(row["ObjectID"].ToString())];
                    if (item != null)
                    {
                        OStoreStockTakeBinItem StoreStockTakeBinItem = TablesLogic.tStoreStockTakeBinItem.Create();
                        StoreStockTakeBinItem.StoreBinItemID = new Guid(row["StoreBinItemID"].ToString());
                        StoreStockTakeBinItem.StoreBinID = bin.ObjectID;
                        StoreStockTakeBinItem.StoreStockTakeID = this.ObjectID;
                        StoreStockTakeBinItem.ObservedQuantity = StoreStockTakeBinItem.PhysicalQuantity = Convert.ToDecimal(row["PhysicalQuantity"]);
                        StoreStockTakeBinItem.CatalogueID = item.ObjectID;
                        StoreStockTakeBinItem.Save();
                        StoreStockTakeBinItems.Add(StoreStockTakeBinItem);

                        //OStoreBinItem binItem = TablesLogic.tStoreBinItem[Safe.ToGuid(row["StoreBinItemID"])];
                        //if (binItem == null) continue;
                        //OStoreStockTakeBinItem StoreStockTakeBinItem = TablesLogic.tStoreStockTakeBinItem.Create();
                        //StoreStockTakeBinItem.StoreStockTakeID = this.ObjectID;
                        //StoreStockTakeBinItem.StoreBinItemID = binItem.ObjectID;
                        //StoreStockTakeBinItem.Save();
                        //StoreStockTakeBinItems.Add(StoreStockTakeBinItem);
                    }
                    }

                //StoreStockTakeBinItems.AddRange(bin.StoreBinItems.StoreBinItems);
            }
        }
        
        //public static DataTable[] GetStoreStockTakeBinItemsGroupByBin(Guid StoreID)
        //{
        //    DataTable[] itemsGroupByBin = null;

        //    OStore s = TablesLogic.tStore[StoreID];

        //    if (s != null)
        //    {
        //        int i=0;
        //        itemsGroupByBin = new DataTable[s.StoreBins.Count];
        //        foreach (OStoreBin bin in s.StoreBins)
        //        {
        //            DataTable table = new DataTable();
        //            table = (DataTable)Query.Select(TablesLogic.tStoreBinItem.ObjectID,
        //                          TablesLogic.tStoreBinItem.PhysicalQuantity.As("AvailableQty"),
        //                          TablesLogic.tStoreBinItem.StoreBin.ObjectName.As("BinName"),
        //                          TablesLogic.tStoreBinItem.Catalogue.IsCatalogueItem,
        //                          TablesLogic.tStoreBinItem.Catalogue.ObjectName.As("Catalogue"),
        //                          TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure")
        //                 )
        //                 .Where(TablesLogic.tStoreBinItem.StoreBin.Store.ObjectID == StoreID)
        //                 .GroupBy(TablesLogic.tStoreBinItem.ObjectID,
        //                          TablesLogic.tStoreBinItem.StoreBin.ObjectName,
        //                          TablesLogic.tStoreBinItem.Catalogue.IsCatalogueItem,
        //                          TablesLogic.tStoreBinItem.Catalogue.ObjectName,
        //                          TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName,
        //                          TablesLogic.tStoreBinItem.PhysicalQuantity

        //                 );
        //            table.TableName = bin.ObjectName;
        //            itemsGroupByBin[i]=table ;
        //            i++;
        //        }
        //    }
        //    return itemsGroupByBin;
        //}

        public static DataTable GetStoreStockTakeBinItems(Guid StoreID)
        {
            DataTable itemsGroupByBin = null;

            //OStore s = TablesLogic.tStore[StoreID];

            //if (s != null)
            //{
                //int i = 0;
                //itemsGroupByBin = new DataTable[s.StoreBins.Count];
                //foreach (OStoreBin bin in s.StoreBins)
                //{
                itemsGroupByBin = (DataTable)Query.Select(TablesLogic.tStoreBinItem.ObjectID,
                                  TablesLogic.tStoreBinItem.PhysicalQuantity.As("AvailableQty"),
                                  TablesLogic.tStoreBinItem.StoreBin.ObjectName.As("BinName"),
                                  TablesLogic.tStoreBinItem.Catalogue.IsCatalogueItem,
                                  TablesLogic.tStoreBinItem.Catalogue.ObjectName.As("Catalogue"),
                                  TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure")
                         )
                         .Where(TablesLogic.tStoreBinItem.StoreBin.Store.ObjectID == StoreID)
                         .OrderBy(TablesLogic.tStoreBinItem.StoreBin.ObjectID.Asc,TablesLogic.tStoreBinItem.Catalogue.ObjectID.Asc);
                         //.GroupBy(TablesLogic.tStoreBinItem.ObjectID,
                         //         TablesLogic.tStoreBinItem.StoreBin.ObjectName,
                         //         TablesLogic.tStoreBinItem.Catalogue.IsCatalogueItem,
                         //         TablesLogic.tStoreBinItem.Catalogue.ObjectName,
                         //         TablesLogic.tStoreBinItem.Catalogue.UnitOfMeasure.ObjectName,
                         //         TablesLogic.tStoreBinItem.PhysicalQuantity

                         //);
                //itemsGroupByBin.TableName = bin.ObjectName;
                //    itemsGroupByBin[i] = table;
                //    i++;
                //}
            //}
            return itemsGroupByBin;
        }

        //public static DataTable GetStoreStockTakeBinItemsById(Guid id)
        //{
        //    DataTable items = null;

        //    //OStore s = TablesLogic.tStore[StoreID];

        //    items = (DataTable)Query.Select(TablesLogic.tStoreStockTakeBinItem.ObservedQuantity.As("ObservedQuantity"),
        //                          TablesLogic.tStoreStockTakeBinItem.StoreBinItem.PhysicalQuantity.As("AvailableQty"),
        //                          TablesLogic.tStoreStockTakeBinItem.StoreBinItem.StoreBin.ObjectName.As("BinName"),
        //                          TablesLogic.tStoreStockTakeBinItem.StoreBinItem.Catalogue.IsCatalogueItem,
        //                          TablesLogic.tStoreStockTakeBinItem.StoreBinItem.Catalogue.ObjectName.As("Catalogue"),
        //                          TablesLogic.tStoreStockTakeBinItem.StoreBinItem.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
        //                          TablesLogic.tStoreStockTakeBinItem.StoreBinItem.ObjectID
        //                 )
        //                 .Where(TablesLogic.tStoreStockTakeBinItem.StoreStockTakeBin.StoreStockTakeID == id)
        //                 .OrderBy(TablesLogic.tStoreStockTakeBinItem.StoreBinItem.StoreBin.ObjectID.Asc, TablesLogic.tStoreStockTakeBinItem.StoreBinItem.Catalogue.ObjectID.Asc);
        //    return items;
        //}

        public static void CreateStoreStockTakeItems(Guid? storeID)
        { 
            
        }

        public OUser GetCreatedBy()
        {
            return TablesLogic.tUser.Load(TablesLogic.tUser.IsDeleted == 0
                & TablesLogic.tUser.ObjectName == this.Base.CreatedUser);
        }

        /// <summary>
        /// 
        /// </summary>
        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                DataSet ds = new DataSet();
                DataSet dsTemp = new DataSet();
                DataTable dt = GetStockTakeDetails(this.ObjectID);
                dsTemp = dt.DataSet;
                dsTemp.Tables.Remove(dt);

                dt.TableName = "StoreStockTake";
                ds.Tables.Add(dt);
                return ds;
            }
        }

        protected DataTable GetStockTakeDetails(Guid? Id)
        {
            DataTable dt = new DataTable();

            dt = TablesLogic.tStoreStockTake.Select(
                TablesLogic.tStoreStockTake.ObjectID.As("StoreStockTakeID"),
                TablesLogic.tStoreStockTake.ObjectNumber.As("StoreStockTakeNumber"),
                TablesLogic.tStoreStockTake.Store.ObjectName.As("StoreName"),
                TablesLogic.tStoreStockTake.StoreStockTakeStartDateTime,
                TablesLogic.tStoreStockTake.StoreStockTakeEndDateTime,
                TablesLogic.tStoreStockTake.StoreStockTakeBinItems.StoreBinItem.StoreBin.ObjectName.As("BinName"),
                this.StoreStockBinsText.As("BinNames"),
                TablesLogic.tStoreStockTake.StoreStockTakeBinItems.StoreBinItem.Catalogue.ObjectName.As("CatalogueName"),
                TablesLogic.tStoreStockTake.StoreStockTakeBinItems.StoreBinItem.Catalogue.StockCode.As("StockCode"),
                TablesLogic.tStoreStockTake.StoreStockTakeBinItems.StoreBinItem.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                TablesLogic.tStoreStockTake.StoreStockTakeBinItems.PhysicalQuantity,
                TablesLogic.tStoreStockTake.StoreStockTakeBinItems.ObservedQuantity)
                .Where(TablesLogic.tStoreStockTake.ObjectID == Id &
                TablesLogic.tStoreStockTake.IsDeleted == 0)
                .OrderBy(TablesLogic.tStoreStockTake.StoreStockTakeBinItems.StoreBinItem.StoreBin.ObjectName.Asc,
                TablesLogic.tStoreStockTake.StoreStockTakeBinItems.StoreBinItem.Catalogue.StockCode.Asc);
            return dt;
        }

        public string StoreStockBinsText
        {
            get
            {
                string names = "";
                int count = 1;
                foreach (OStoreBin bin in this.StoreBins)
                {
                    names += bin.ObjectName + (count != this.StoreBins.Count ? ", " : "");
                    count++;
                }

                return names;
            }
        }

        public DataTable GetStockTakeFormData()
        {
            DataSet dts = Connection.ExecuteQuery("#database",
                @"
select  
	sst.objectnumber storestocktakenumber,
	s.ObjectName storename,
	sst.StoreStockTakeStartDateTime,
	sst.StoreStockTakeEndDateTime,
	sb.ObjectName binname,
	c.ObjectName Cataloguename,
	c.stockcode,
	c.IsCatalogueItem,
	code.objectname UnitOfMeasure,
	--sbi.PhysicalQuantity,
	sstbi.PhysicalQuantity,
	sstbi.ObservedQuantity
from 
	storestocktake sst
	left join store s on sst.storeid=s.objectid and s.isdeleted=0
	left join StoreStockTakeBinItem  sstbi on sstbi.storestocktakeid=sst.objectid
	left join StoreBinItem sbi on sbi.objectid=sstbi.StoreBinItemid
	left join StoreBin sb on sstbi.StoreBinid=sb.objectid
	left join Catalogue c on c.objectid=sbi.CatalogueID
	left join code code on c.UnitOfMeasureid=code.objectid
where 
	sst.objectid='" + this.ObjectID + @"' 
order by sb.objectname, c.stockcode"
                );

            if (!(dts.Tables.Count > 0))
                dts.Tables.Add();

            dts.Tables[0].TableName = "StoreStockTake";
            dts.Tables[0].Columns.Add("names");


            DataSet dts2 = Connection.ExecuteQuery("#database",
@"
declare   @s   nvarchar(4000) 

select @s=coalesce(@s+', ', '') + m.objectname  from (select c.objectname as ObjectName from storestocktake a
left join storestocktakebin b on b.storestocktakeid=a.objectid
left join storebin c on c.objectid=b.storebinid
where a.objectid='" + this.ObjectID + @"') m 
select @s name"
);
            String names = "";
            if (dts.Tables.Count > 0)
            {
                names = dts2.Tables[0].Rows[0]["name"].ToString();
            }
            foreach (DataRow dr in dts.Tables[0].Rows)
            {
                dr["names"] = names;
            }
            return dts.Tables[0];
        }


        /// <summary>
        /// Validates and checks to ensure that none of the 
        /// store bins are locked.
        /// <para></para>
        /// Returns a list of store bins that are currently
        /// locked.
        /// </summary>
        /// <returns></returns>
        public string ValidateStoreBinsNotLocked()
        {
            List<Guid> storeBinIds = new List<Guid>();
            foreach(OStoreBin bin in this.StoreBins)
                storeBinIds.Add(bin.ObjectID.Value);

            return OStore.ValidateStoreBinsNotLocked(storeBinIds);
        }


        /// <summary>
        /// Creates a new store adjustment based on the 
        /// store take result. 
        /// <para></para>
        /// </summary>
        /// <returns></returns>
        public OStoreAdjust CreateStoreAdjustment()
        {
            using (Connection c = new Connection())
            {
                OStoreAdjust adjust = TablesLogic.tStoreAdjust.Create();

                List<OStoreStockTakeBinItem> variationItems = new List<OStoreStockTakeBinItem>();

                // First we find out which are the store stock
                // take bin items such that the observed quantity
                // is not the physical quantity value.
                //
                foreach (OStoreStockTakeBinItem item in this.StoreStockTakeBinItems)
                    if (item.ObservedQuantity.Value != item.PhysicalQuantity.Value)
                        variationItems.Add(item);

                // Then we load all StoreItem records from the store
                // that we just stock taked and store them all in a
                // hash table.
                //
                List<Guid> catalogIds = new List<Guid>();
                foreach (OStoreStockTakeBinItem item in variationItems)
                    catalogIds.Add(item.CatalogueID.Value);
                List<OStoreItem> storeItems = TablesLogic.tStoreItem.LoadList(
                    TablesLogic.tStoreItem.CatalogueID.In(catalogIds) &
                    TablesLogic.tStoreItem.StoreID == this.StoreID);
                Hashtable hashStoreItems = new Hashtable();
                foreach (OStoreItem storeItem in storeItems)
                    hashStoreItems[storeItem.CatalogueID.Value] = storeItem;

                // Create adjustment records for each item in the
                // stock take.
                // 
                foreach (OStoreStockTakeBinItem item in variationItems)
                {
                    decimal adjustmentQuantity = item.ObservedQuantity.Value - item.PhysicalQuantity.Value;

                    ColumnOrder order = TablesLogic.tStoreBinItem.BatchDate.Desc;
                    OStoreItem storeItem = hashStoreItems[item.CatalogueID.Value] as OStoreItem;
                    if (storeItem != null && storeItem.CostingType == StoreItemCostingType.FIFO)
                        order = TablesLogic.tStoreBinItem.BatchDate.Asc;

                    List<OStoreBinItem> storeBinItems = TablesLogic.tStoreBinItem.LoadList(
                        TablesLogic.tStoreBinItem.StoreBinID == item.StoreBinID &
                        TablesLogic.tStoreBinItem.CatalogueID == item.CatalogueID &
                        TablesLogic.tStoreBinItem.PhysicalQuantity > 0, order);

                    /// Used to adjust upwards
                    ///
                    OStoreBinItem binItem = null;
                    if (storeBinItems == null)
                    {
                        binItem = TablesLogic.tStoreBinItem.Create();
                        binItem.CatalogueID = item.CatalogueID;
                        binItem.BatchDate = DateTime.Now;
                        binItem.PhysicalQuantity = 0;
                        binItem.UnitPrice = 0;

                        item.StoreBin.StoreBinItems.Add(binItem);

                        decimal batchAdjustmentQuantity = binItem.PhysicalQuantity.Value;
                        if (batchAdjustmentQuantity + adjustmentQuantity >= 0)
                            batchAdjustmentQuantity = adjustmentQuantity;
                        else
                            batchAdjustmentQuantity = -batchAdjustmentQuantity;

                        OStoreAdjustItem adjustItem = TablesLogic.tStoreAdjustItem.Create();
                        adjustItem.StoreBinID = item.StoreBinID;
                        adjustItem.StoreBinItemID = binItem.ObjectID;
                        adjustItem.AdjustUp = (batchAdjustmentQuantity >= Decimal.Zero ? 1 : 0);
                        adjustItem.Quantity = Math.Abs(batchAdjustmentQuantity);
                        adjustItem.CatalogueID = item.CatalogueID;

                        adjust.StoreAdjustItems.Add(adjustItem);

                        adjustmentQuantity -= batchAdjustmentQuantity;
                        if (adjustmentQuantity == 0)
                            break;
                    }

                    foreach (OStoreBinItem storeBinItem in storeBinItems)
                    {
                        decimal batchAdjustmentQuantity = storeBinItem.PhysicalQuantity.Value;
                        if (batchAdjustmentQuantity + adjustmentQuantity >= 0)
                            batchAdjustmentQuantity = adjustmentQuantity;
                        else
                            batchAdjustmentQuantity = -batchAdjustmentQuantity;

                        OStoreAdjustItem adjustItem = TablesLogic.tStoreAdjustItem.Create();
                        adjustItem.StoreBinID = item.StoreBinID;
                        adjustItem.StoreBinItemID = storeBinItem.ObjectID;
                        adjustItem.AdjustUp = (batchAdjustmentQuantity >= Decimal.Zero ? 1 : 0);
                        adjustItem.Quantity = Math.Abs(batchAdjustmentQuantity);
                        adjustItem.CatalogueID = item.CatalogueID;

                        adjust.StoreAdjustItems.Add(adjustItem);

                        adjustmentQuantity -= batchAdjustmentQuantity;
                        if (adjustmentQuantity == 0)
                            break;
                    }

                    // If there are not enough items in the batch to adjust,  
                    // we have to throw an exception with an error. 
                    // (Normally this should NOT happen since the bins
                    // are locked).
                    // 
                    if (adjustmentQuantity != 0)
                    {
                        throw new Exception("Unable to generate stock adjustment, as there is insufficient quantity.");
                    }
                }

                this.StoreAdjustID = adjust.ObjectID;
                this.Save();

                // Set other parameters in the adjustment
                // object.
                //
                adjust.Description = String.Format(
                    Resources.Strings.StockTake_AutoGeneratedAdjustment, this.ObjectNumber);
                adjust.StoreID = this.StoreID;
                adjust.StoreStockTakeID = this.ObjectID;
                adjust.Save();
                adjust.TriggerWorkflowEvent("SaveAsDraft");
                adjust.Save();
                
                c.Commit();

                return adjust;
            }
        }
    }
}

