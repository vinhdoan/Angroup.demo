using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class EquipmentMasterHandler : Migratable
    {
        public EquipmentMasterHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public EquipmentMasterHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportEquipmentHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportEquipmentHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string equipment = ConvertToString(dr[map["EquipmentName"]]);
                    string[] list = equipment.Trim(',').Split(',');
                    string parentID = "";
                    OEquipment pa = TablesLogic.tEquipment.Load(
                                    TablesLogic.tEquipment.ParentID == null &
                                    TablesLogic.tEquipment.IsDeleted == 0);

                    OEquipment e;
                    if (pa == null)
                        throw new Exception("All Equipment does not exist");
                    else
                        parentID = pa.ObjectID.ToString();
                    for (int i = 1; i < list.Length; i++)
                    {
                        string equip = list[i].Trim();
                        e = TablesLogic.tEquipment.Load(
                                                  TablesLogic.tEquipment.ObjectName == equip &
                                                  TablesLogic.tEquipment.ParentID == new Guid(parentID) &
                                                  TablesLogic.tEquipment.IsDeleted == 0);
                        //create new if it does not exist
                            if (e == null)
                            {
                                e = TablesLogic.tEquipment.Create();
                                if (parentID != null && parentID.ToString() != string.Empty)
                                    e.ParentID = new Guid(parentID);
                                e.IsPhysicalEquipment = 0;
                                e.ObjectName = equip;
                                SaveObject(e);
                                ActivateObject(e);

                            }
                        parentID = e.ObjectID.ToString();



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