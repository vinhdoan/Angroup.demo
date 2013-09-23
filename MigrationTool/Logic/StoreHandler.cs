using System;
using System.Data;

using LogicLayer;

namespace DataMigration.Logic
{
    public class StoreHandler : Migratable
    {
        public StoreHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public StoreHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        #region Migratable 成员

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportStores(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportStores(DataTable storeTable)
        {
            int count = 0;
            foreach (DataRow dr in storeTable.Rows)
            {
                try
                {
                    count++;
                    string mapToColName = "NameOfStore";
                    string mapFromColName = map[mapToColName];
                    string storeName = ConvertToString(dr[mapFromColName]);
                    if (storeName == null) continue;

                    mapToColName = "NameOfLocation";
                    mapFromColName = map[mapToColName];
                    string locationName = ConvertToString(dr[mapFromColName]);

                    mapToColName = "BinsOfStore";
                    mapFromColName = map[mapToColName];
                    string binStr = ConvertToString(dr[mapFromColName]);
                    string[] bins = null;
                    if (null != binStr) bins = binStr.Split(',');
                    OStore store = CreateStore(storeName, locationName, bins, null);
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        public static OStore CreateStore(string storeName, string locationName, string[] bins, string[] storeBinDescription)
        {
            OLocation location = null;
            if (null != locationName)
            {
                location = TablesLogic.tLocation.Load(TablesLogic.tLocation.ObjectName == locationName, true, null);
            }
            OStore store = null;
            if (null != location)
            {
                store = TablesLogic.tStore.Load(TablesLogic.tStore.ObjectName == storeName & TablesLogic.tStore.Location.ObjectID == location.ObjectID, true, null);
            }
            else
            {
                store = TablesLogic.tStore.Load(TablesLogic.tStore.ObjectName == storeName, true, null);
            }
            if (null == store)//create new store
            {
                store = TablesLogic.tStore.Create();
                store.ObjectName = storeName;
                store.LocationID = location == null ? null : location.ObjectID;
                SaveObject(store);
            }
            AddStoreBins(store.ObjectID, bins, storeBinDescription);
            ActivateObject(store);
            return store;
        }

        private static void AddStoreBins(Guid? storeID, string[] bins, string[] descriptions)
        {
            if (null == bins) return;
            int i = 0;
            foreach (string binName in bins)
            {
                OStoreBin storeBin = TablesLogic.tStoreBin.Load(TablesLogic.tStoreBin.ObjectName == binName & TablesLogic.tStoreBin.StoreID == storeID, true, null);
                if (null == storeBin)//create new store bin
                {
                    storeBin = TablesLogic.tStoreBin.Create();
                    storeBin.IsLocked = 0;
                    storeBin.ObjectName = binName;
                    storeBin.StoreID = storeID;
                    storeBin.Description = descriptions[i];
                    SaveObject(storeBin);
                }
                ActivateObject(storeBin);
                i++;
            }
        }

        #endregion Migratable 成员
    }
}