using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class EquipmentTypeParametersHandler : Migratable
    {
        public EquipmentTypeParametersHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public EquipmentTypeParametersHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportEquipmentParametersHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportEquipmentParametersHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string eqmt = ConvertToString(dr[map["EquipmentType"]]);
                    string uom = ConvertToString(dr[map["UOM"]]);


                    String equipID = equipmentTypeID(eqmt);

                    
                    if (equipID != null && equipID.ToString()!=string.Empty)
                    {
                        OEquipmentType equip = TablesLogic.tEquipmentType.Load(
                                           TablesLogic.tEquipmentType.ObjectID==new Guid(equipID) &
                                           TablesLogic.tEquipmentType.IsDeleted == 0);
                        OCode code = TablesLogic.tCode.Load(
                                 TablesLogic.tCode.ObjectName == uom &
                                 TablesLogic.tCode.IsDeleted == 0);
                        if (equip != null && code != null)
                        {
                            string param = ConvertToString(dr[map["ParameterName"]]);
                            if (param != null && param.ToString() != string.Empty)
                            {
                                OEquipmentTypeParameter eParam = TablesLogic.tEquipmentTypeParameter.Load(
                                                             TablesLogic.tEquipmentTypeParameter.ObjectName == param &
                                                             TablesLogic.tEquipmentTypeParameter.IsDeleted == 0 &
                                                             TablesLogic.tEquipmentTypeParameter.EquipmentTypeID == equip.ObjectID &
                                                             TablesLogic.tEquipmentTypeParameter.UnitOfMeasureID == code.ObjectID);
                                if (eParam == null)
                                {
                                    eParam = TablesLogic.tEquipmentTypeParameter.Create();
                                }
                                eParam.EquipmentTypeID = equip.ObjectID;
                                eParam.UnitOfMeasureID = code.ObjectID;
                                eParam.ObjectName = param;
                                SaveObject(eParam);
                                ActivateObject(eParam);
                            }else
                                throw new Exception("Parameter Name can not be left empty");
                           
                        }
                        else
                        {
                            throw new Exception("The Equipment Type or UOM does not exists");
                        }

                    }
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }
        public static string equipmentTypeID(string eqmt)
        {
            String equipID = "";
            string[] list = eqmt.Split(',');
            string parent = "";
         

            for (int i = 0; i < list.Length; i++)
            {
                string equip = list[i].Trim();
                OEquipmentType etype;

                if (parent == null || parent.ToString() == string.Empty)
                {
                    etype = TablesLogic.tEquipmentType.Load(
                                     TablesLogic.tEquipmentType.ObjectName == equip &
                                     TablesLogic.tEquipmentType.IsDeleted == 0);
                }
                else
                {
                  
                    etype = TablesLogic.tEquipmentType.Load(
                                      TablesLogic.tEquipmentType.ObjectName == equip &
                                      TablesLogic.tEquipmentType.ParentID == new Guid(equipID) &
                                      TablesLogic.tEquipmentType.IsDeleted == 0);
                }
                if (etype == null)
                    throw new Exception(equip + " does not exist");
                else
                {
           
                    equipID = etype.ObjectID.ToString();
                }
            }
            return equipID;
        }


    }
}