using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class EquipmentTypeHandler : Migratable
    {
        public EquipmentTypeHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public EquipmentTypeHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportEquipmentTypeHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportEquipmentTypeHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string equipment = ConvertToString(dr[map["EquipmentTypeName"]]);
                    string physical = ConvertToString(dr[map["PhysicalType"]]);
                    string[] list = equipment.Trim(',').Split(',');
                    string parentID="";
                    OEquipmentType etype;
         
                    for (int i = 0; i < list.Length; i++) {
                        string equip = list[i].Trim();
                        if (parentID != null && parentID.ToString()!=string.Empty)
                        {
                            etype = TablesLogic.tEquipmentType.Load(
                                                  TablesLogic.tEquipmentType.ObjectName == equip &
                                                  TablesLogic.tEquipmentType.ParentID==new Guid(parentID) &
                                                  TablesLogic.tEquipmentType.IsDeleted == 0);
                        }
                        else {
                            etype = TablesLogic.tEquipmentType.Load(
                                             TablesLogic.tEquipmentType.ObjectName == equip &
                                             TablesLogic.tEquipmentType.IsDeleted == 0);
                        }
                        if (etype == null)
                        {
                            //create if it's not in database
                            etype = TablesLogic.tEquipmentType.Create();

                            if (parentID != null && parentID.ToString() != string.Empty)
                                etype.ParentID = new Guid(parentID);
                            if (physical.ToUpper() == "YES" || physical.ToUpper() == "Y")
                                etype.IsLeafType = 1;
                            else if (physical.ToUpper() == "NO" || physical.ToUpper() == "N")
                                etype.IsLeafType = 0;
                            else
                                throw new Exception("Invalid Physical Type");
                            etype.ObjectName = equip;
                            SaveObject(etype);
                            ActivateObject(etype);
                        }
                        parentID = etype.ObjectID.ToString();
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