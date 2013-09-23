using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class AttributeFieldHandlerValue : Migratable
    {
        public AttributeFieldHandlerValue(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public AttributeFieldHandlerValue(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportAttributeFieldHandlerValue(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportAttributeFieldHandlerValue(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string EquipmentName = ConvertToString(dr[map["EquipmentName"]]).Trim();
                    string AttributeName = ConvertToString(dr[map["AttributeName"]]).Trim();
                    string Value = ConvertToString(dr[map["Value"]]).Trim();

                    OEquipment e = TablesLogic.tEquipment.Load(
                        TablesLogic.tEquipment.ObjectName == EquipmentName);
                    string equipid = e.ObjectID.ToString();
                    if (e != null)
                    {
                        string findAttribute = "";
                        OCustomizedAttributeField custField = TablesLogic.tCustomizedAttributeField.Load(
                            TablesLogic.tCustomizedAttributeField.ControlCaption == AttributeName &
                            TablesLogic.tCustomizedAttributeField.MainObjectID == e.EquipmentTypeID);
                        if (custField != null)
                            findAttribute = custField.ObjectID.ToString();
                        OCustomizedAttributeFieldValue findValue = TablesLogic.tCustomizedAttributeFieldValue.Load(
                            TablesLogic.tCustomizedAttributeFieldValue.AttachedObjectID == new Guid(equipid) &
                            TablesLogic.tCustomizedAttributeFieldValue.ColumnName == findAttribute);

                        if (findValue == null)
                        {
                            OCustomizedAttributeFieldValue newAttributeValue = TablesLogic.tCustomizedAttributeFieldValue.Create();
                            newAttributeValue.AttachedObjectID = new Guid(equipid);
                            newAttributeValue.ColumnName = findAttribute;
                            newAttributeValue.AttachedPropertyID = e.EquipmentTypeID;
                            newAttributeValue.FieldValue = Value;
                            SaveObject(newAttributeValue);
                            ActivateObject(newAttributeValue);
                        }
                        else
                        {
                            findValue.FieldValue = Value;
                            SaveObject(findValue);
                        }
                    }
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        public static string equipmentID(string eqmt)
        {
            String equipID = "";
            string[] list = eqmt.Trim(',').Split(',');
            


            for (int i = 0; i < list.Length; i++)
            {
                string equip = list[i].Trim();
                OEquipment e;

                if (equipID == null || equipID.ToString() == string.Empty)
                {
                    e = TablesLogic.tEquipment.Load(
                                     TablesLogic.tEquipment.ObjectName == equip &
                                     TablesLogic.tEquipment.IsDeleted == 0);
                }
                else
                {
                    
                    e = TablesLogic.tEquipment.Load(
                                      TablesLogic.tEquipment.ObjectName == equip &
                                      TablesLogic.tEquipment.ParentID == new Guid(equipID) &
                                      TablesLogic.tEquipment.IsDeleted == 0);
                }
                if (e == null)
                    throw new Exception("Equipment master '" + equip + "' does not exist");
                else
                {
                    equipID = e.ObjectID.ToString();
            
                }
            }
            return equipID;
        }

        public static string locationID(string locList)
        {
            String locID = "";
            string[] list = locList.Trim(',').Split(',');



            for (int i = 0; i < list.Length; i++)
            {
                string loc= list[i].Trim();
                OLocation location;

                if (locID == null || locID.ToString() == string.Empty)
                {
                    location = TablesLogic.tLocation.Load(
                                     TablesLogic.tLocation.ObjectName == loc &
                                     TablesLogic.tLocation.IsDeleted == 0);
                }
                else
                {

                    location = TablesLogic.tLocation.Load(
                                      TablesLogic.tLocation.ObjectName == loc &
                                      TablesLogic.tLocation.ParentID == new Guid(locID) &
                                      TablesLogic.tLocation.IsDeleted == 0);
                }
                if (location == null)
                    throw new Exception("Location '" + loc + "' does not exist");
                else
                {
                    locID = location.ObjectID.ToString();

                }
            }
            return locID;
        }





    }
}