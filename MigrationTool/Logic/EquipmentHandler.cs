using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class EquipmentHandler : Migratable
    {
        public EquipmentHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public EquipmentHandler(string mapfrom, string mapto, string sourcefile)
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
                    string EquipName = ConvertToString(dr[map["Equipment Name (unique identifier)"]]);
                    string EquipSystem = ConvertToString(dr[map["EquipmentSystem"]]);
                    string EquipType = ConvertToString(dr[map["EquipmentType"]]);
                    string parent = ConvertToString(dr[map["Parent"]]);
                    string Location = ConvertToString(dr[map["Location"]]);
                    string SerialNo = ConvertToString(dr[map["Serial Number"]]);
                    string BarCode = ConvertToString(dr[map["BarCode"]]);
                    string DateOfMan = ConvertToString(dr[map["DateOfManufacture"]]);
                    string DateOfOwnership = ConvertToString(dr[map["DateOfOwnership"]]);
                    string PriceAtOwnership = ConvertToString(dr[map["Price at Ownership ($)"]]);
                    string Warranty = ConvertToString(dr[map["WarrantyExpiry"]]);
                    string ModelNo = ConvertToString(dr[map["Model No."]]);
                    string LifeSpane = ConvertToString(dr[map["Life Span (Years)"]]);
                    string Manufacturer = ConvertToString(dr[map["Manufacturer"]]);

                    
                        string equipID = equipmentID(EquipSystem);
                        string equipTypeID = EquipmentTypeParametersHandler.equipmentTypeID(EquipType);
                        string locID = locationID(Location);
                        OEquipment e = TablesLogic.tEquipment.Load(
                                        TablesLogic.tEquipment.ObjectID == new Guid(equipID) &
                                        TablesLogic.tEquipment.IsDeleted == 0);
                        OEquipmentType etype = TablesLogic.tEquipmentType.Load(
                                               TablesLogic.tEquipmentType.ObjectID == new Guid(equipTypeID) &
                                               TablesLogic.tEquipmentType.IsDeleted==0);
                        string parentID = "";
                        if (parent != null && parent.Trim().ToString() != string.Empty)
                        {
                            OEquipment pa = TablesLogic.tEquipment.Load(
                                    TablesLogic.tEquipment.ObjectName == parent &
                                    TablesLogic.tEquipment.IsDeleted == 0);
                            if (pa != null)
                                parentID = pa.ObjectID.ToString();
                            else
                                throw new Exception("Parent of equipment '" + parent + "' does not exist");

                        }
                        else
                        {
                            parentID = equipID;
                        }    


                        OEquipment equip = TablesLogic.tEquipment.Load(
                                        TablesLogic.tEquipment.ObjectName == EquipName &
                                        TablesLogic.tEquipment.ParentID==new Guid(parentID) &
                                        TablesLogic.tEquipment.IsDeleted == 0);
                        OLocation location =TablesLogic.tLocation.Load(
                                     TablesLogic.tLocation.ObjectID == new Guid(locID) &
                                     TablesLogic.tLocation.IsDeleted == 0);
                        if (e != null && etype != null && location != null) {
                            //create new if it does not exist
                            if (equip == null)
                            {
                                equip = TablesLogic.tEquipment.Create();
                                equip.ParentID = new Guid(parentID);
                            }
                            equip.ObjectName = EquipName;
                            equip.IsPhysicalEquipment = 1;
                            equip.LocationID = location.ObjectID;
                            equip.EquipmentTypeID = etype.ObjectID;
                            equip.SerialNumber = SerialNo;
                            equip.Barcode = BarCode;
                            equip.Vendor = Manufacturer;
                            if(DateOfMan !=null && DateOfMan.Trim()!= string.Empty)
                                equip.DateOfManufacture = Convert.ToDateTime(DateOfMan);
                            if (DateOfOwnership != null && DateOfOwnership.ToString() != string.Empty)
                                equip.DateOfOwnership = Convert.ToDateTime(DateOfOwnership);
                            if (PriceAtOwnership != null && PriceAtOwnership.ToString() != string.Empty)
                                equip.PriceAtOwnership = Convert.ToDecimal(PriceAtOwnership);
                            if (Warranty != null && Warranty.ToString() != string.Empty)
                                equip.WarrantyExpiryDate = Convert.ToDateTime(Warranty);
                            equip.ModelNumber = ModelNo;
                            if (LifeSpane != null && LifeSpane.ToString() != string.Empty)
                                equip.LifeSpan=Convert.ToInt16(LifeSpane);
                            SaveObject(equip);
                            ActivateObject(equip);
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