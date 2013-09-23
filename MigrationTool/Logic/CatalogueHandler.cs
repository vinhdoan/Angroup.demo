using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;

using Anacle.DataFramework;
using LogicLayer;
using DataMigration.Infrastructure;

namespace DataMigration.Logic
{
    public class CatalogueHanlder : Migratable
    {
        public CatalogueHanlder(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        {
            catalogueGroupList = new Dictionary<string, Guid?>();
            //UnitOfMeasureList = new Dictionary<string, Guid?>();
        }

        public CatalogueHanlder(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }


        private static IDictionary<string, Guid?> catalogueGroupList = new Dictionary<string, Guid?>();

        private static IDictionary<string, Guid?> UnitOfMeasureList = new Dictionary<string, Guid?>();

        //private const string UnitOfMeasureTypeName = "UnitOfMeasure";

        private static OCodeType UnitOfMeasureType = null;

        private static OCode unitOfMeasureRoot = null;

        Hashtable catalogTypes = new Hashtable();
        Hashtable unitOfMeasures = new Hashtable();

        public override void Migarate()
        {
            DataTable dt = GetDatasource();

            using (Connection c = new Connection())
            {
                List<OCatalogue> list = TablesLogic.tCatalogue.LoadList(TablesLogic.tCatalogue.IsCatalogueItem == 0);
                foreach (OCatalogue catalog in list)
                    catalogTypes[catalog.Path] = catalog;
            }


            foreach (DataRow row in dt.Rows)
            {
                ImportCatalogue(row);
            }

            LogHelper.LogDataImport(mapfrom, dt, Map.Values);
        }

        #region UnitOfMeasure
        /// <summary>
        /// Get UnitOfMeasure by name,if it isn't exist,create it.
        /// </summary>
        /// <param name="unit"></param>
        /// <returns></returns>
        private static OCode GetUnitOfMeasure(string unit)
        {
            OCode code = null;
            //retrive from cache
            Guid? id = null;

            if (UnitOfMeasureList.ContainsKey(unit))
                id = UnitOfMeasureList[unit];

            if (id != null)
            {
                code = TablesLogic.tCode[id];
            }

            //if it isn't in cahce,load it from db
            if (code == null)
            {
                code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == unit, true, null);

                //if it can be load from db
                if (code != null)
                {
                    ActivateObject(code);
                }
                //if it can't be load from db,create it
                else
                {
                    code = CreateUnitOfMeasure(unit);
                }
            }

            //To improve performance,add it to a list
            if (!UnitOfMeasureList.ContainsKey(unit))
                UnitOfMeasureList.Add(unit, code.ObjectID);


            return code;
        }


        private static OCode CreateUnitOfMeasure(string unit)
        {
            if (UnitOfMeasureType == null)
            {
                UnitOfMeasureType = TablesLogic.tCodeType.Load(TablesLogic.tCodeType.ObjectName == Strings.UnitOfMeasureTypeName, true, null);
                if (UnitOfMeasureType != null)
                {
                    ActivateObject(UnitOfMeasureType);
                }
                else
                {
                    throw new ApplicationException(String.Format("CodeType '{0}' doesn't exist.", Strings.UnitOfMeasureTypeName));
                }
            }
            if (unitOfMeasureRoot == null)
            {
                unitOfMeasureRoot = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == Strings.UnitOfMeasureRootName, true, null);
            }

            if (String.IsNullOrEmpty(unit))
            {
                throw new ApplicationException("UnitOfMeasure required.");
            }
            OCode code = TablesLogic.tCode.Create();

            code.ObjectName = unit;
            code.CodeTypeID = UnitOfMeasureType.ObjectID;
            code.ParentID = unitOfMeasureRoot.ObjectID;


            SaveObject(code);

            return code;
        }
        #endregion

        private void ImportCatalogue(DataRow row)
        {
            try
            {
                string name = ConvertToString(row[Map["CatalogueItemName"]]);
                string catalogueType = ConvertToString(row[Map["CatalogueItemType"]]);
                string unitOfMeasure = ConvertToString(row[Map["UnitOfMeasure"]]);
                string inventoryCatalogType = ConvertToString(row[Map["InventoryCatalogType"]]);
                decimal sellingPrice = Decimal.Zero;
                try
                {
                    if (!String.IsNullOrEmpty(row[Map["SellingPrice"]].ToString()))
                        sellingPrice = Convert.ToDecimal(row[Map["SellingPrice"]]);
                }
                catch { }
                string stockCode = ConvertToString(row[Map["StockCode"]]);

                if (name == null && catalogueType == null && unitOfMeasure == null && stockCode == null)
                {
                    return;
                }

                CreateCatalogueHierarchy(catalogueType, name, unitOfMeasure, sellingPrice, stockCode, inventoryCatalogType);
            }
            catch (Exception ex)
            {
                row[Migratable.ERROR_MSG_COL] = ex.Message;
            }
        }

        public static Guid? CreateCatalogueHierarchy(string catalogueType, string name, string unitOfMeasure, decimal sellingPrice, string StockCode, string inventoryCatalogType)
        {
            string[] folders = catalogueType.Split(',');
            Guid? parentid = null;
            for (int i = 0; i < folders.Length; i++)
            {
                string path = "";
                for (int j = 0; j <= i; j++)
                    path += "," + folders[j];
                parentid = GetCatalogue(parentid, folders[i], 0, unitOfMeasure, sellingPrice, StockCode, inventoryCatalogType);
            }
            parentid = GetCatalogue(parentid, name, 1, unitOfMeasure, sellingPrice, StockCode, inventoryCatalogType);
            return parentid;
        }

        private static Guid? GetCatalogue(Guid? parentid, string name, int type, string unitOfMeasure, decimal sellingPrice, string StockCode, string inventoryCatalogType)
        {

            OCatalogue o;

            string item = name;

            OCode measure = null;
            if (unitOfMeasure != null && unitOfMeasure.Trim() != String.Empty)
            {
                measure = GetUnitOfMeasure(unitOfMeasure);
            }

            //***********************
            // Assumption that items under the same parent has unique names.
            //***********************
            if (type == 1)
                o = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.StockCode != "" & TablesLogic.tCatalogue.ParentID == parentid & TablesLogic.tCatalogue.ObjectName == item, true, null);
            //    o = TablesLogic.tCatalogue.Load(
            //        TablesLogic.tCatalogue.IsCatalogueItem==type &
            //        TablesLogic.tCatalogue.StockCode == StockCode, true, null);
            else o = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.ParentID == parentid & TablesLogic.tCatalogue.ObjectName == item, true, null);
            // End Assumption

            if (o == null)
            {
                o = CreateCatalogue(item, parentid, type, measure, sellingPrice, StockCode, inventoryCatalogType);
            }
            else if (o != null)
            {
                if (o.IsDeleted == 1)
                    ActivateObject(o);
                o.IsCatalogueItem = type;
                o.ObjectName = item;
                if (StockCode != "") o.StockCode = StockCode;
                o.ParentID = parentid;
                o.UnitOfMeasure = measure;
                o.InventoryCatalogType =
                    inventoryCatalogType.ToUpper() == "CONSUMABLE" ? InventoryCatalogType.Consumable :
                    InventoryCatalogType.NonConsumable;
            }
            SaveObject(o);

            if (!catalogueGroupList.ContainsKey(name))
            {
                catalogueGroupList.Add(name, o.ObjectID);
            }

            return o.ObjectID;
        }


        private static OCatalogue CreateCatalogue(string catalogueName, Guid? parentId, int type, OCode unitOfMeasure, decimal sellingPrice, string stockCode, string inventoryCatalogType)
        {
            OCatalogue catalogue = TablesLogic.tCatalogue.Create();

            catalogue.ObjectName = catalogueName;
            //if (type == 0)
            //{
            catalogue.ParentID = parentId;
            //}
            catalogue.IsCatalogueItem = type;
            catalogue.UnitOfMeasureID = unitOfMeasure == null ? null : unitOfMeasure.ObjectID;
            catalogue.UnitPrice = sellingPrice;
            catalogue.StockCode = stockCode;
            catalogue.InventoryCatalogType =
                inventoryCatalogType.ToUpper() == "CONSUMABLE" ? InventoryCatalogType.Consumable :
                InventoryCatalogType.NonConsumable;

            SaveObject(catalogue);

            if (type == 0)
            {
                if (!catalogueGroupList.ContainsKey(catalogueName))
                {
                    catalogueGroupList.Add(catalogueName, catalogue.ObjectID);
                }
            }
            return catalogue;
        }
    }
}
