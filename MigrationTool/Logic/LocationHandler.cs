using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class LocationHandler : Migratable
    {
        public LocationHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public LocationHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportLocationHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportLocationHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string locationName = ConvertToString(dr[map["LocationName"]]);
                    string locationType = ConvertToString(dr[map["LocationType"]]);
                    string isPhysicalLocation = ConvertToString(dr[map["IsPhysicalLocation"]]);
                    string country = ConvertToString(dr[map["Country"]]);
                    string address = ConvertToString(dr[map["Address"]]);
                    string parentID = "";
                    OLocation location;

                    if (locationName == null || locationName.Trim().Length == 0)
                        throw new Exception("Location Name is blank.");


                    if (locationType == null || locationType.Trim().Length == 0)
                        throw new Exception("Location Type is blank.");


                    string[] list = locationName.Trim(',').Split(',');
            

                    OLocationType locationtype = TablesLogic.tLocationType.Load(TablesLogic.tLocationType.ObjectName == locationType.Trim() &
                                                                                   TablesLogic.tLocationType.IsDeleted == 0);

                    if(locationtype == null)
                        throw new Exception("This Location Type does not exist");

                    string msg = "";
                    for (int i = 0; i < list.Length; i++)
                    {
                        string strLocationName = list[i].Trim();

                        if (parentID != null && parentID.ToString() != string.Empty)
                        {
                            location = TablesLogic.tLocation.Load(
                                        TablesLogic.tLocation.ObjectName == strLocationName &
                                        TablesLogic.tLocation.ParentID == new Guid(parentID) &
                                        TablesLogic.tLocation.IsDeleted == 0);
                        }
                        else
                        {
                            location = TablesLogic.tLocation.Load(
                                        TablesLogic.tLocation.ObjectName == strLocationName &
                                        TablesLogic.tLocation.ParentID == null &
                                        TablesLogic.tLocation.IsDeleted == 0);
                        }
                        if (location == null && i != list.Length - 1)
                            throw new Exception("Location '" + strLocationName + "' does not exist");
                        else if (i == list.Length - 1)
                        {
                            
                            if (location == null)
                            {
                                location = TablesLogic.tLocation.Create();
                                location.ObjectName = strLocationName;
                                if (parentID != null && parentID.ToString() != string.Empty)
                                    location.ParentID = new Guid(parentID);
                                location.LocationTypeID = locationtype.ObjectID;
                                location.IsPhysicalLocation = isPhysicalLocation.ToUpper()=="YES" ? 1 : 0;
                                location.AddressCountry = country;
                                location.Address = address;
                                SaveObject(location);
                                ActivateObject(location);
                                msg = "Created!";
                            }
                            else
                            {
                                location.LocationTypeID = locationtype.ObjectID;
                                location.IsPhysicalLocation = isPhysicalLocation.ToUpper() == "YES" ? 1 : 0;
                                location.AddressCountry = country;
                                location.Address = address;
                                SaveObject(location);
                                ActivateObject(location);
                                msg = "updated!!";
                            }

                            
                        }
                        parentID = location.ObjectID.ToString();  
                    }
                    throw new Exception(msg);

                }

                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }


    }
}