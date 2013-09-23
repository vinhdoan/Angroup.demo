using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class CraftHandler : Migratable
    {
        public CraftHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public CraftHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportCraftHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportCraftHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string CraftName = ConvertToString(dr[map["CraftName"]]);
                    string NormalRate = ConvertToString(dr[map["NormalRate"]]);
                    string OvertimeRate = ConvertToString(dr[map["OvertimeRate"]]);
                    if (CraftName == null || CraftName.ToString() == string.Empty)
                        throw new Exception("CraftName can not be left empty");
                    OCraft craft = TablesLogic.tCraft.Load(
                                    TablesLogic.tCraft.ObjectName == CraftName &
                                    TablesLogic.tCraft.IsDeleted == 0);
                    if(craft==null){
                        craft = TablesLogic.tCraft.Create();
                        craft.ObjectName = CraftName;
                        if (NormalRate != null && NormalRate.ToString() != string.Empty)
                            craft.NormalHourlyRate = Convert.ToDecimal(NormalRate);
                        else
                            throw new Exception("Normal Rate can not be left empty");
                        if (OvertimeRate != null && OvertimeRate.ToString() != string.Empty)
                            craft.OvertimeHourlyRate = Convert.ToDecimal(OvertimeRate);
                        else
                            throw new Exception("Overtime Rate can not be left empty");
                        SaveObject(craft);
                        ActivateObject(craft);
                      
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