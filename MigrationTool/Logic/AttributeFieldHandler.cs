using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class AttributeFieldHandler : Migratable
    {
        public AttributeFieldHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public AttributeFieldHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportAttributeFieldHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportAttributeFieldHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string EquipmentType = ConvertToString(dr[map["EquipmentType"]]).Trim();
                    string AttributeName = ConvertToString(dr[map["AttributeName"]]).Trim();
                    string Type = ConvertToString(dr[map["Type"]]).Trim();

                    string equipTypeID = EquipmentTypeParametersHandler.equipmentTypeID(EquipmentType);
                    OEquipmentType equipType = TablesLogic.tEquipmentType.Load(
                        TablesLogic.tEquipmentType.ObjectID == new Guid(equipTypeID) &
                        TablesLogic.tEquipmentType.IsDeleted == 0
                        );

                    OCustomizedAttributeField custAttr = TablesLogic.tCustomizedAttributeField.Load(
                        TablesLogic.tCustomizedAttributeField.ControlCaption == AttributeName &
                        TablesLogic.tCustomizedAttributeField.MainObjectID == equipType.ObjectID);
                    List<OCustomizedAttributeField> getCountAttributes =
                        TablesLogic.tCustomizedAttributeField.LoadList(
                        TablesLogic.tCustomizedAttributeField.MainObjectID == equipType.ObjectID);
                    if (custAttr == null)
                    {
                        OCustomizedAttributeField newCustAttr = TablesLogic.tCustomizedAttributeField.Create();
                        newCustAttr.AttachedObjectName = "tEquipment";
                        newCustAttr.AttachedPropertyName = "EquipmentTypeID";
                        newCustAttr.TabViewID = "attributeTabView";
                        newCustAttr.ColumnName = newCustAttr.ObjectID.Value.ToString();
                        newCustAttr.ControlCaption = AttributeName;
                        newCustAttr.MainObjectID = equipType.ObjectID;
                        newCustAttr.ControlType = "TextBox";
                        newCustAttr.ControlSpan = "Half";
                        newCustAttr.IsActive = 1;
                        newCustAttr.ValidateRequiredField = 0;
                        newCustAttr.DataType = Type;
                        newCustAttr.DisplayOrder = getCountAttributes.Count > 0 ? getCountAttributes.Count + 1 : 1;
                        SaveObject(newCustAttr);
                        ActivateObject(newCustAttr);
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