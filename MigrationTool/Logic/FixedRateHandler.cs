using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class FixedRateHandler:Migratable
    {
        public FixedRateHandler(string mapFrom, string mapTo)
            : base(mapFrom, mapTo)
        { }

        public FixedRateHandler(string mapFrom, string mapTo, string sourceFile)
            : base(mapFrom, mapTo, sourceFile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportFixedRateHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportFixedRateHandler(DataTable table)
        {
            foreach(DataRow dr in table.Rows)
            {
                try
                {
                    string name = Convert.ToString(dr[Map["FixedRateGroup"]]);
                    if (name != null)
                    {
                        string[] group = name.Split(',');
                        string parentID = "";
                        for (int i = 0; i < group.Length; i++)
                        {
                            
                            string groupItem = group[i].Trim();
                            OFixedRate rate = null;

                            if (parentID != null && parentID.ToString() != string.Empty)
                                rate = TablesLogic.tFixedRate.Load(
                                    TablesLogic.tFixedRate.ObjectName == groupItem &
                                    TablesLogic.tFixedRate.ParentID == new Guid(parentID) &
                                    TablesLogic.tFixedRate.IsDeleted == 0);
                            else
                                rate = TablesLogic.tFixedRate.Load(
                                    TablesLogic.tFixedRate.ObjectName == groupItem &
                                    TablesLogic.tFixedRate.IsDeleted == 0);
                            if (rate != null)
                                parentID = rate.ObjectID.ToString();

                            if (rate == null)
                            {
                                rate = TablesLogic.tFixedRate.Create();
                                rate.ObjectName = groupItem;
                                rate.IsFixedRate = 0;
                                rate.ParentID = new Guid(parentID);
                                SaveObject(rate);
                                ActivateObject(rate);
                            }
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
