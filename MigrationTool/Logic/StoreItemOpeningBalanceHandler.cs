using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class StoreItemOpeningBalanceHandler : Migratable
    {
        public StoreItemOpeningBalanceHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public StoreItemOpeningBalanceHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }


        public override void Migarate()
        {
            try
            {
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
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    Guid? storeId = ConvertToGuidByObjectName(dr, "Store Name", true, TablesLogic.tStore);
                    Guid? catalogId = ConvertToGuidByHierarchicalPath(dr, "Catalog Path", true, ',', TablesLogic.tCatalogue);
                    Guid? binId = ConvertToGuidByObject(
                        TablesLogic.tStoreBin.Load(
                        TablesLogic.tStoreBin.ObjectName == ConvertToString(dr, "Bin Name", true) &
                        TablesLogic.tStoreBin.StoreID == storeId));
                    decimal? unitPrice = ConvertToDecimal(dr, "Unit Price", true);
                    decimal? actualQuantity = ConvertToDecimal(dr, "Actual Quantity", true);
                    DateTime? dateOfDelivery = ConvertToDateTime(dr, "Date of Delivery", false);
                    DateTime? expiryDate = ConvertToDateTime(dr, "Expiry Date", false);

                    if (binId == null)
                        throw new Exception("Unable to find bin");

                    OStoreCheckIn checkIn = CreateStoreCheckIn(storeId);
                    CreateStoreCheckInItem(binId, checkIn.ObjectID, catalogId, unitPrice, actualQuantity, expiryDate);

                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        private OStoreCheckIn CreateStoreCheckIn(Guid? storeID)
        {
            OStoreCheckIn checkIn = TablesLogic.tStoreCheckIn.Load(
                TablesLogic.tStoreCheckIn.ObjectName == "Opening Balance" &
                TablesLogic.tStoreCheckIn.StoreID == storeID, null);
            if (null == checkIn)
            {
                checkIn = TablesLogic.tStoreCheckIn.Create();
                checkIn.ObjectName = "Opening Balance";
                checkIn.StoreID = storeID;
                SaveObject(checkIn);
                checkIn.TriggerWorkflowEvent("SaveAsDraft");
            }
            return checkIn;
        }

        private OStoreCheckInItem CreateStoreCheckInItem(Guid? storeBinId, Guid? storeCheckInId, Guid? ctgID, decimal? unitPrice, decimal? qty, DateTime? expiryDate)
        {
            OStoreCheckInItem item = TablesLogic.tStoreCheckInItem.Load(
                TablesLogic.tStoreCheckInItem.StoreCheckInID == storeCheckInId
                & TablesLogic.tStoreCheckInItem.StoreBinID == storeBinId
                & TablesLogic.tStoreCheckInItem.CatalogueID == ctgID, null);

            if (null == item)
            {
                item = TablesLogic.tStoreCheckInItem.Create();
                item.StoreBinID = storeBinId;
                item.StoreCheckInID = storeCheckInId;
                item.CatalogueID = ctgID;
            }
            item.UnitPrice = unitPrice;
            item.Quantity = qty;
            item.ExpiryDate = expiryDate;
            SaveObject(item);
            return item;
        }

    }
}
