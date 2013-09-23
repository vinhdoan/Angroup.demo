using System;
using System.Data;
using LogicLayer;

namespace DataMigration.Logic
{
    public class StoreItemHandler : Migratable
    {
        public StoreItemHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public StoreItemHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                //WorkflowConfiguration c = new WorkflowConfiguration();
                //Workflow.ClearObjects();
                //Workflow.CompileWorkFlowClasses(c);
                DataTable table = GetDatasource();
                ImportStoreBinItems(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportStoreBinItems(DataTable table)
        {
            OStoreCheckIn checkIn = null;

            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string mapToColName = "NameOfStore";
                    string mapFromColName = map[mapToColName];
                    string storeName = ConvertToString(dr[mapFromColName]);
                    if (storeName == null) continue;

                    mapToColName = "BinsOfStore";
                    mapFromColName = map[mapToColName];
                    string binName = ConvertToString(dr[mapFromColName]);
                    if (null == binName) throw new Exception("Store bin name is null,the record can't be import to db.");

                    mapToColName = "StockCode";
                    mapFromColName = map[mapToColName];
                    string stockcode = ConvertToString(dr[mapFromColName]);
                    //if (null == stockcode) throw new Exception("Stockcode is null,the record can't be import to db.");

                    mapToColName = "CatalogueOfBinItem";
                    mapFromColName = map[mapToColName];
                    string fullName = ConvertToString(dr[mapFromColName]);
                    int index = fullName.IndexOf(",");
                    string ctgName = fullName.Substring(0, index);
                    string storeBinItemName = fullName.Substring(index + 1);

                    mapToColName = "UnitPrice";
                    mapFromColName = map[mapToColName];
                    string strPrice = ConvertToString(dr[mapFromColName]);
                    decimal unitPrice = null == strPrice ? (decimal)0 : decimal.Parse(strPrice);

                    mapToColName = "PhysicalQuantity";
                    mapFromColName = map[mapToColName];
                    string strQty = ConvertToString(dr[mapFromColName]);
                    decimal qty = null == strQty ? (decimal)0 : decimal.Parse(strQty);
                    OStoreBinItem binItem = CreateStoreBinItem(storeName, binName, ctgName, storeBinItemName, stockcode, unitPrice, qty);
                    checkIn = CreateStoreCheckIn(binItem.StoreBin.StoreID);
                    CreateStoreCheckInItem(binItem.StoreBinID, checkIn.ObjectID, binItem.CatalogueID, unitPrice, qty);

                    mapToColName = "ReorderThreshold";
                    mapFromColName = map[mapToColName];
                    string strThreshold = ConvertToString(dr[mapFromColName]);
                    decimal decThreshold = null == strThreshold ? (decimal)0 : decimal.Parse(strThreshold);

                    mapToColName = "ReorderDefault";
                    mapFromColName = map[mapToColName];
                    string strDefault = ConvertToString(dr[mapFromColName]);
                    decimal decDefault = null == strDefault ? (decimal)0 : decimal.Parse(strDefault);
                    CreateStoreItem(binItem.StoreBin.StoreID, binItem.CatalogueID, decThreshold, decDefault);

                    //checkIn.TriggerWorkflowEvent("SaveAsDraft");
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
            if (checkIn != null)
            {
                OStoreCheckIn ci = TablesLogic.tStoreCheckIn.Load(checkIn.ObjectID);
                ci.TriggerWorkflowEvent("SaveAsDraft");
            }
        }

        private OStoreBinItem CreateStoreBinItem(string storeName, string storeBinName, string parentCtgName, string ctgName, string stockcode, decimal unitPrice, decimal qty)
        {
            //find store bin
            OStoreBinItem item = TablesLogic.tStoreBinItem.Load(TablesLogic.tStoreBinItem.StoreBin.ObjectName == storeBinName &
                TablesLogic.tStoreBinItem.Catalogue.ObjectName == ctgName &
                TablesLogic.tStoreBinItem.StoreBin.Store.ObjectName == storeName, true, null);
            bool isNeedUpdate = false;
            if (null == item)
            {
                OStore store = StoreHandler.CreateStore(storeName, null, new string[] { storeBinName }, null);
                OStoreBin storeBin = TablesLogic.tStoreBin.Load(TablesLogic.tStoreBin.ObjectName == storeBinName
                    & TablesLogic.tStoreBin.StoreID == store.ObjectID, true, null);
                OCatalogue ctg = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.ObjectName == ctgName);
                Guid? ctgID = null;
                if (ctg != null)
                {
                    ctgID = ctg.ObjectID;
                }
                else
                {
                    ctgID = TablesLogic.tCatalogue[TablesLogic.tCatalogue.ObjectName == ctgName][0].ObjectID;
                    //ctgID = CatalogueHanlder.CreateCatalogueHierarchy(parentCtgName + "," + ctgName, 1, "", Decimal.Zero, "");
                }

                item = TablesLogic.tStoreBinItem.Create();
                item.StoreBinID = storeBin.ObjectID;
                item.CatalogueID = ctgID;
                isNeedUpdate = true;
            }

            if (isNeedUpdate || item.UnitPrice != unitPrice || item.PhysicalQuantity != qty)
            {
                item.UnitPrice = unitPrice;
                item.PhysicalQuantity = qty;
                SaveObject(item);
            }
            ActivateObject(item);
            return item;
        }

        private OStoreItem CreateStoreItem(Guid? storeID, Guid? catalogueID, decimal thresholdNum, decimal defaultNum)
        {
            OStoreItem storeItem = TablesLogic.tStoreItem.Load(TablesLogic.tStoreItem.StoreID == storeID & TablesLogic.tStoreItem.CatalogueID == catalogueID, true, null);
            if (storeItem == null)
            {
                storeItem = TablesLogic.tStoreItem.Create();
                storeItem.StoreID = storeID;
                storeItem.CatalogueID = catalogueID;
            }
            ActivateObject(storeItem);
            storeItem.ReorderDefault = defaultNum;
            storeItem.ReorderThreshold = thresholdNum;
            SaveObject(storeItem);
            return storeItem;
        }

        private OStoreCheckIn CreateStoreCheckIn(Guid? storeID)
        {
            OStoreCheckIn checkIn = TablesLogic.tStoreCheckIn.Load(
                TablesLogic.tStoreCheckIn.ObjectName == "Opening Balance" &
                TablesLogic.tStoreCheckIn.StoreID == storeID, true, null);
            if (null == checkIn)
            {
                checkIn = TablesLogic.tStoreCheckIn.Create();
                checkIn.ObjectName = "Opening Balance";
                checkIn.StoreID = storeID;
                SaveObject(checkIn);
            }
            ActivateObject(checkIn);
            return checkIn;
        }

        private OStoreCheckInItem CreateStoreCheckInItem(Guid? storeBinId, Guid? storeCheckInId, Guid? ctgID, decimal unitPrice, decimal qty)
        {
            OStoreCheckInItem item = TablesLogic.tStoreCheckInItem.Load(TablesLogic.tStoreCheckInItem.StoreCheckInID == storeCheckInId
                & TablesLogic.tStoreCheckInItem.StoreBinID == storeBinId
                & TablesLogic.tStoreCheckInItem.CatalogueID == ctgID, true, null);

            if (null == item)
            {
                item = TablesLogic.tStoreCheckInItem.Create();
                item.StoreBinID = storeBinId;
                item.StoreCheckInID = storeCheckInId;
                item.CatalogueID = ctgID;
                item.UnitPrice = unitPrice;
                item.Quantity = qty;
                SaveObject(item);
            }
            if (item.UnitPrice != unitPrice || item.Quantity != qty)
            {
                item.UnitPrice = unitPrice;
                item.Quantity = qty;
                SaveObject(item);
            }
            ActivateObject(item);
            return item;
        }
    }
}