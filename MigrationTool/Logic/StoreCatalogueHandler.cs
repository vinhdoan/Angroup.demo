using System;
using System.Collections.Generic;
using System.Data;
using LogicLayer;

namespace DataMigration.Logic
{
    //Li Shan: this handler is created to insert missing store catalogue for store bin item.
    //NOTE: the file should NOT be used for normal data migration!!!!

    public class StoreCatalogueHandler : Migratable
    {
        int i = 0;

        public StoreCatalogueHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        {
        }

        public StoreCatalogueHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        #region Migratable

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportStoreCatalog(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportStoreCatalog(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string StoreName = ConvertToString(dr[map["StoreName"]]);
                    string StockCode = ConvertToString(dr[map["StockCode"]]);

                    if (StoreName == null)
                        throw new Exception("This Store Name does not exist.");

                    if (StockCode == null)
                        throw new Exception("This Store Code does not exist.");

                    if (StoreName != null)
                    {
                        OStore store = TablesLogic.tStore.Load(TablesLogic.tStore.ObjectName == StoreName &
                                                                  TablesLogic.tStore.IsDeleted == 0);

                        if (store != null)
                        {
                            OCatalogue catalog = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.StockCode == StockCode &
                                                                             TablesLogic.tCatalogue.IsCatalogueItem == 1 &
                                                                             TablesLogic.tCatalogue.IsDeleted == 0);

                            List<OCatalogue> catalogList = TablesLogic.tCatalogue.LoadList(TablesLogic.tCatalogue.StockCode == StockCode &
                                                                             TablesLogic.tCatalogue.IsCatalogueItem == 1 &
                                                                             TablesLogic.tCatalogue.IsDeleted == 0);

                            if (catalogList == null)
                                throw new Exception("No such stock code.");

                            if (catalogList != null)
                            {
                                int catCount = 0;
                                foreach (OCatalogue cat in catalogList)
                                {
                                    if (cat.IsDeleted == 0)
                                        catCount++;
                                }

                                if (catCount > 1)
                                    throw new Exception("This Stock code has multiple Live records.");
                            }

                            if (catalog == null)
                                throw new Exception("This catalogue does not exist.");

                            OStoreItem storeItem = TablesLogic.tStoreItem.Load(TablesLogic.tStoreItem.StoreID == store.ObjectID &
                                                                               TablesLogic.tStoreItem.Catalogue.StockCode == StockCode &
                                                                               TablesLogic.tStoreItem.CatalogueID == catalog.ObjectID &
                                                                               TablesLogic.tStoreItem.IsDeleted == 0);

                            OStoreItem CurrentStoreItem = TablesLogic.tStoreItem.Load(TablesLogic.tStoreItem.StoreID == store.ObjectID &
                                                                               TablesLogic.tStoreItem.Catalogue.StockCode == StockCode &
                                                                               TablesLogic.tStoreItem.CatalogueID != catalog.ObjectID &
                                                                               TablesLogic.tStoreItem.Catalogue.IsDeleted == 1 &
                                                                               TablesLogic.tStoreItem.IsDeleted == 0);

                            if (storeItem == null && CurrentStoreItem != null)
                            {
                                CurrentStoreItem.CatalogueID = catalog.ObjectID;
                                SaveObject(CurrentStoreItem);
                                ActivateObject(CurrentStoreItem);
                            }

                            if (storeItem == null && CurrentStoreItem == null)
                            {
                                storeItem = TablesLogic.tStoreItem.Create();

                                storeItem.CatalogueID = catalog.ObjectID;
                                storeItem.StoreID = store.ObjectID;
                                storeItem.CostingType = 0;
                                storeItem.ItemType = 0;
                                storeItem.ReorderDefault = 0;
                                storeItem.ReorderThreshold = 0;

                                SaveObject(storeItem);
                                ActivateObject(storeItem);
                            }
                        }
                        else
                        {
                            throw new Exception("This Store does not exist.");
                        }
                    }
                    else
                    {
                        throw new Exception("This Store Name does not exist.");
                    }
                }

                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        #endregion Migratable
    }
}