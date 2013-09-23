using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class LocationTypeHandler : Migratable
    {
        public LocationTypeHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public LocationTypeHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportLocationTypeHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportLocationTypeHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string LocType = ConvertToString(dr[map["LocationType"]]);
                    OLocationType typeParent = TablesLogic.tLocationType.Load(TablesLogic.tLocationType.ObjectName == "All Location Types" & 
                                                                              TablesLogic.tLocationType.IsDeleted==0);
                    if (typeParent != null)
                    {
                        OLocationType locationtype = TablesLogic.tLocationType.Load(TablesLogic.tLocationType.ObjectName == LocType &
                                                                                   TablesLogic.tLocationType.IsDeleted == 0);

                        if (locationtype == null)
                        {
                            locationtype = TablesLogic.tLocationType.Create();
                            locationtype.ObjectName = LocType;
                            locationtype.ParentID = typeParent.ObjectID;
                            locationtype.IsLeafType = 1;
                            SaveObject(locationtype);
                            ActivateObject(locationtype);

                        }
                   }

                    
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }


    }
}