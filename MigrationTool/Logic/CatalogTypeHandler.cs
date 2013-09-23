using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class CatalogTypeHandler : Migratable
    {
        public CatalogTypeHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            base.Migarate();

            DataTable dt = GetDatasource();
            Hashtable catalogs = new Hashtable();

            using (Connection c = new Connection())
            {
                List<OCatalogue> list = TablesLogic.tCatalogue.LoadList(TablesLogic.tCatalogue.IsCatalogueItem == 0);
                foreach (OCatalogue catalog in list)
                    catalogs[catalog.Path] = catalog;
            }

            foreach (DataRow dr in dt.Rows)
            {
                string catalogueType = Convert.ToString(dr[map["CatalogType"]]);

                string[] catalogueTypes = catalogueType.Split(',');

                string previousPath = "";
                string path = "";
                for (int i = 0; i < catalogueTypes.Length; i++)
                {
                    previousPath = path;
                    path += (i > 0 ? " > " : "") + catalogueTypes[i];
                    if (catalogs[path] == null)
                    {
                        using (Connection c = new Connection())
                        {
                            // Create a new catalog folder and save it.
                            //
                            OCatalogue newCatalog = TablesLogic.tCatalogue.Create();
                            newCatalog.ObjectName = catalogueTypes[i].Trim();
                            newCatalog.IsCatalogueItem = 0;

                            // Find the parent.
                            //
                            OCatalogue parentCatalog = catalogs[previousPath] as OCatalogue;
                            if (parentCatalog != null)
                                newCatalog.ParentID = parentCatalog.ObjectID;

                            newCatalog.Save();
                            catalogs[path] = newCatalog;
                            c.Commit();
                        }
                    }
                }
            }
        }
    }
}