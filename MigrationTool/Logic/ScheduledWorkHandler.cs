using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class ScheduledWorkHandler : Migratable
    {
        public ScheduledWorkHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public ScheduledWorkHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportScheduledWorkHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportScheduledWorkHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    //map all variables to excel columns
                    string EquipmentList = ConvertToString(dr[map["EquipmentList"]]);
                    string WorkDescription = ConvertToString(dr[map["WorkDescription"]]);
                    string Location = ConvertToString(dr[map["Location"]]);
                    string IsEqptOrLoc = ConvertToString(dr[map["IsEquipmentTypeOrLocation"]]);
                    string EquipmentType = ConvertToString(dr[map["EquipmentType"]]);
                    string TypeOfWork = ConvertToString(dr[map["TypeOfWork"]]);
                    string TypeOfService = ConvertToString(dr[map["TypeOfService"]]);
                    string TypeOfProblem = ConvertToString(dr[map["TypeOfProblem"]]);
                    string Priority = ConvertToString(dr[map["Priority"]]);
                    string FirstWorkStartDateTime = ConvertToString(dr[map["FirstWorkStartDateTime"]]);
                    string FirstWorkEndDateTime = ConvertToString(dr[map["FirstWorkEndDateTime"]]);
                    string IsFloating = ConvertToString(dr[map["IsFloating"]]);
                    string FrequencyInterval = ConvertToString(dr[map["IntervalFrequency"]]);
                    string FrequencyCount = ConvertToString(dr[map["Interval"]]);
                    string ScheduleType = ConvertToString(dr[map["ScheduleType"]]);
                    string WeekOfMonth = ConvertToString(dr[map["WeekOfMonth"]]);
                    string DayOfWeek = ConvertToString(dr[map["DayOfWeek"]]);
                    string EndDateOfSchedule = ConvertToString(dr[map["EndDateOfPreventiveSchedule"]]);
                    
                    
                    
                    //string LocationList = ConvertToString(dr[map["LocationList"]]);

                    //string Checklist = ConvertToString(dr[map["ChecklistName"]]);
                    //string workHours = ConvertToString(dr[map["WorkHour"]]);
                    //string Equipment = ConvertToString(dr[map["Equipment"]]);
                    //string EquipmentLocation = ConvertToString(dr[map["EquipmentLocation"]]);

                    //string LocationType = ConvertToString(dr[map["LocationType"]]);
                    //string IsStaggered = ConvertToString(dr[map["IsStaggered"]]);
                    //string StaggerBy = ConvertToString(dr[map["StaggerBy"]]);

                    //string IsAllFixedWorksCreatedAtOnce = ConvertToString(dr[map["IsAllFixedWorksCreatedAtOnce"]]);


                    //validating fields
                    OCode TypeOfWorkID = GetTypeOfWorkID(TypeOfWork);
                    OCode TypeOfServiceID = GetTypeOfServiceID(TypeOfService);
                    OCode TypeOfProblemID = GetTypeOfProblemID(TypeOfProblem);
                    OLocation LocationID = locationID(Location);
                    //OUser SupervisorID;
                    //OChecklist ChecklistID;

                    int PriorityInt = 0;
                    int FrequencyInt = 0;
                    int FrequencyC = 0;
                    int isFloat = 0;
                    int MonthType = 0;
                    int MonthTypeWeekNumber = 0;
                    int MonthTypeDay = 0;
                    //string[] list = null;
                    //string parentID = "";

                    if (Priority == null || Priority.Trim().Length == 0)
                        throw new Exception("Priority cannot be blank.");
                    else
                        PriorityInt = Convert.ToInt16(Priority);

                    if (FrequencyInterval != "")
                    {
                        if (FrequencyInterval.Contains("Day"))
                            FrequencyInt = 0;
                        else if (FrequencyInterval.Contains("Week"))
                            FrequencyInt = 1;
                        else if (FrequencyInterval.Contains("Month"))
                            FrequencyInt = 2;
                        else if (FrequencyInterval.Contains("Year"))
                            FrequencyInt = 3;
                    }
                    else
                        throw new Exception("Frequency Interval does not exists");

                    if (FrequencyCount != "")
                        FrequencyC = Convert.ToInt16(FrequencyCount);
                    else
                        throw new Exception("Frequency Count does not exists");

                    if (IsFloating != null && IsFloating.Trim().Length != 0)
                    {
                        if (IsFloating == "Fixed")
                            isFloat = 0;
                        else
                            isFloat = 1;
                    }
                    else
                        throw new Exception("Is Floating is Blank.");

                    /// for every x weeek
                    if (ScheduleType.ToLower().Contains("specific w/d") & FrequencyInt == 1)
                    {
                        MonthType = 1;
                        if (DayOfWeek.ToLower().Contains("monday"))
                            MonthTypeDay = 1;
                        else if (DayOfWeek.ToLower().Contains("tuesday"))
                            MonthTypeDay = 2;
                        else if (DayOfWeek.ToLower().Contains("wednesday"))
                            MonthTypeDay = 3;
                        else if (DayOfWeek.ToLower().Contains("thursday"))
                            MonthTypeDay = 4;
                        else if (DayOfWeek.ToLower().Contains("friday"))
                            MonthTypeDay = 5;
                        else if (DayOfWeek.ToLower().Contains("saturday"))
                            MonthTypeDay = 6;
                        else if (DayOfWeek.ToLower().Contains("sunday"))
                            MonthTypeDay = 0;
                    }


                    /// for every month
                    if (ScheduleType.ToLower().Contains("specific w/d") & FrequencyInt == 2)
                    {
                        MonthType = 1;

                        if (WeekOfMonth.ToLower().Contains("1st week"))
                            MonthTypeWeekNumber = 1;
                        else if (WeekOfMonth.ToLower().Contains("2nd week"))
                            MonthTypeWeekNumber = 2;
                        else if (WeekOfMonth.ToLower().Contains("3rd week"))
                            MonthTypeWeekNumber = 3;
                        else if (WeekOfMonth.ToLower().Contains("4th week"))
                            MonthTypeWeekNumber = 4;
                        else if (WeekOfMonth.ToLower().Contains("last week"))
                            MonthTypeWeekNumber = 5;

                        if (DayOfWeek.ToLower().Contains("monday"))
                            MonthTypeDay = 1;
                        else if (DayOfWeek.ToLower().Contains("tuesday"))
                            MonthTypeDay = 2;
                        else if (DayOfWeek.ToLower().Contains("wednesday"))
                            MonthTypeDay = 3;
                        else if (DayOfWeek.ToLower().Contains("thursday"))
                            MonthTypeDay = 4;
                        else if (DayOfWeek.ToLower().Contains("friday"))
                            MonthTypeDay = 5;
                        else if (DayOfWeek.ToLower().Contains("saturday"))
                            MonthTypeDay = 6;
                        else if (DayOfWeek.ToLower().Contains("sunday"))
                            MonthTypeDay = 0;
                    }

                    if (LocationID == null)
                        throw new Exception("Location does not exist");


                    string equipTypeID = EquipmentTypeParametersHandler.equipmentTypeID(EquipmentType);
                    OEquipmentType EquipmentTypeID = TablesLogic.tEquipmentType.Load(
                                           TablesLogic.tEquipmentType.ObjectID == new Guid(equipTypeID) &
                                           TablesLogic.tEquipmentType.IsDeleted == 0);
                    if (EquipmentTypeID == null)
                        throw new Exception("Equipment type " + EquipmentTypeID + " does not exist.");

                   
                   
                    //assign variables to object
                    OScheduledWork s;
                    s = TablesLogic.tScheduledWork.Create();
                    s.WorkDescription = WorkDescription;
                    s.TypeOfWork = TypeOfWorkID;
                    s.TypeOfService = TypeOfServiceID;
                    s.TypeOfProblem = TypeOfProblemID;
                    s.Priority = PriorityInt;
                    s.IsFloating = isFloat;
                    s.FrequencyInterval = FrequencyInt;
                    s.FrequencyCount = FrequencyC;
                    s.MonthType = MonthType;
                    s.MonthTypeWeekNumber = MonthTypeWeekNumber;
                    s.MonthTypeDay = MonthTypeDay;
                    s.IsScheduledByOccurrence = 0;
                    s.IsAllFixedWorksCreatedAtOnce = 1;
                    s.IsStaggered = 0;
                    s.Location = LocationID;
                    //s.Supervisor = SupervisorID;
                    s.EquipmentType = EquipmentTypeID;
                    s.Priority = PriorityInt;

                    if (EndDateOfSchedule != null && EndDateOfSchedule.Trim() != string.Empty)
                    {
                        if (EndDateOfSchedule.Contains(":")) s.EndDateTime = Convert.ToDateTime(EndDateOfSchedule);
                        else s.EndDateTime = Convert.ToDateTime(EndDateOfSchedule.Trim() + " 00:00");
                    }
                    else
                        throw new Exception("End Date of Schedule is blank.");



                    if (FirstWorkStartDateTime != null && FirstWorkStartDateTime.Trim() != string.Empty)
                    {
                        if (FirstWorkStartDateTime.Contains(":")) s.FirstWorkStartDateTime = Convert.ToDateTime(FirstWorkStartDateTime);
                        else s.FirstWorkStartDateTime = Convert.ToDateTime(FirstWorkStartDateTime.Trim() + " 00:00");
                    }
                    else
                        throw new Exception("First work start date is blank.");


                    if (FirstWorkEndDateTime != null && FirstWorkEndDateTime.Trim() != string.Empty)
                    {
                        if (FirstWorkEndDateTime.Contains(":")) s.FirstWorkEndDateTime = Convert.ToDateTime(FirstWorkEndDateTime);
                        else s.FirstWorkEndDateTime = Convert.ToDateTime(FirstWorkEndDateTime.Trim() + " 00:00");
                    }
                    else
                        throw new Exception("First Work End Date is blank.");

                    if (IsEqptOrLoc == "E")
                    {
                        //added erroroutput to check if schedule work location is lower then equipment location.
                        string erroroutput = "";

                        string[] eqptlist = new String[100];
                        eqptlist =   EquipmentList.Trim(',').Split(',');
                        foreach (string a in eqptlist)
                        {
                            if (a.Trim().Length == 0)
                                continue;

                            //eqpt below is NOT accurate, 
                            //since it is not based on hierarchyPath
                            //anyone use code below should REVISE!!!
                            OEquipment eqpt = TablesLogic.tEquipment.Load(
                                            TablesLogic.tEquipment.ObjectName == a.Trim() &
                                            TablesLogic.tEquipment.EquipmentTypeID == s.EquipmentTypeID &
                                            TablesLogic.tEquipment.Location.HierarchyPath.Like(LocationID.HierarchyPath + "%") &
                                            TablesLogic.tEquipment.IsDeleted == 0
                                            );

                            if (eqpt == null)
                                throw new Exception("Equipment " + a + " does not exist.");

                            if (eqpt.IsPhysicalEquipment != 1)
                                erroroutput += "Equipment " + eqpt.ObjectName + " is not a physical equipment.\n";
                            else if (eqpt.IsPhysicalEquipment == 1 && eqpt.Location == null)
                                erroroutput += "Equipment " + eqpt.ObjectName + " has no location.\n";
                            else if (eqpt.IsPhysicalEquipment == 1 && !eqpt.Location.HierarchyPath.StartsWith(s.Location.HierarchyPath))
                                erroroutput += "Equipment " + eqpt.ObjectName + " cannot be found in the Scheduled Work's Location.\n";
                            if (erroroutput != "")
                                throw new Exception(erroroutput);


                            s.ScheduledWorkEquipment.Add(eqpt);
                        }
                        

                        s.EquipmentLocation = 0;
                        //s.IsCreateSingleWork = 0;
                    }
                    else
                        throw new Exception("Location List is not handled");
                 
                    //if (Checklist != null && Checklist.Trim().Length != 0)
                    //{
                    //    list = Checklist.Trim(',').Split(',');
                    //    for (int i = 0; i < list.Length; i++)
                    //    {
                    //        string strChecklistName = list[i].Trim();
                    //        if (parentID != null && parentID.ToString() != string.Empty)
                    //        {
                    //            ChecklistID = TablesLogic.tChecklist.Load(
                    //                            TablesLogic.tChecklist.ObjectName == strChecklistName &
                    //                            TablesLogic.tChecklist.ParentID == new Guid(parentID) &
                    //                            TablesLogic.tChecklist.IsDeleted == 0);
                    //        }
                    //        else
                    //        {
                    //            ChecklistID = TablesLogic.tChecklist.Load(
                    //                            TablesLogic.tChecklist.ObjectName == strChecklistName &
                    //                            TablesLogic.tChecklist.ParentID == null &
                    //                            TablesLogic.tChecklist.IsDeleted == 0);
                    //        }

                    //        if (i == list.Length - 1)
                    //        {
                    //            if (ChecklistID == null)
                    //                throw new Exception("Checklist " + strChecklistName + " not exsit");
                    //            else
                    //            {
                    //                OScheduledWorkChecklist ScheduleWorkChecklistID = TablesLogic.tScheduledWorkChecklist.Create();
                    //                ScheduleWorkChecklistID.Checklist = ChecklistID;
                    //                ScheduleWorkChecklistID.ScheduledWork = s;
                    //                ScheduleWorkChecklistID.CycleNumber = 1;

                    //                s.ScheduledWorkChecklist.Add(ScheduleWorkChecklistID);
                    //            }
                    //        }
                    //        parentID = ChecklistID.ObjectID.ToString();
                    //    }
                    //}


                    // This is for work cost handler.
                    // implement later, now, just hardcode to add technician.
                    //OScheduledWorkCost ScheduleWorkCostID = TablesLogic.tScheduledWorkCost.Create();
                    //ScheduleWorkCostID.CostType = 0;
                    //ScheduleWorkCostID.ScheduledWork = s;
                    //ScheduleWorkCostID.EstimatedCostFactor = 1;
                    //ScheduleWorkCostID.EstimatedOvertime = 0;
                    //if (workHours != null && workHours.Trim().Length != 0)
                    //    ScheduleWorkCostID.EstimatedQuantity = Convert.ToInt16(FrequencyCount);
                    //else
                    //    ScheduleWorkCostID.EstimatedQuantity = 8;
                    //s.ScheduledWorkCost.Add(ScheduleWorkCostID);
                   

                    //if (LocationType != null)
                    //{
                    //    throw new Exception("Location Type is not handled");
                    //    //Guid LocationTypeID = locationTypeID(LocationType);
                    //    //s.LocationTypeID = LocationTypeID;
                    //}

                    
                    //if (location != null)
                    //{
                        
                    //    s.LocationID = location.ObjectID;

                    //    DataTable dtPriority = location.GetPriorityList();

                    //    if (dtPriority == null || dtPriority.Rows.Count == 0)
                    //        throw new Exception("Location " + location.ObjectName + "has no priority defined.");

                    //    bool found = false;
                    //    foreach (DataRow r in dtPriority.Rows)
                    //    {
                    //        if (r["PriorityName"].ToString().Trim() == Priority.Trim())
                    //        {
                    //            s.Priority = int.Parse(r["PriorityValue"].ToString());
                    //            found = true;
                    //            break;
                    //        }
                    //    }
                    //    if (!found)
                    //        throw new Exception("Priority " + Priority + " does not exist in the scheduled work location.");
                    //}
                    
                    
                    

                    
                    

                    //saving and activating object
                    SaveObject(s);
                    ActivateObject(s);
                    
                    //transit object to trigger workflow created status
                    s.TriggerWorkflowEvent("Start");
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        //Methods to verify fields
        //public static string GetMMDDYYYYHHMM(String date)
        //{
        //    string validDate = "";
        //    string[] a = date.Split('/');
        //    validDate = a[1] + "/" + a[0] + "/" + a[2];
        //    return validDate;
        //}

        public static Guid GetSupervisorID(string Supervisor)
        {
            OUser e;

            e = TablesLogic.tUser.Load(
                             TablesLogic.tUser.ObjectName.Like(Supervisor) &
                             TablesLogic.tUser.IsDeleted == 0);


            if (e == null)
                throw new Exception("Supervisor '" + Supervisor + "' does not exist");
            else
            {
                return (Guid)e.ObjectID;

            }
        }

        public static OCode GetTypeOfWorkID(string TypeOfWork)
        {
                OCode e;

                    e = TablesLogic.tCode.Load(
                                     TablesLogic.tCode.CodeType.ObjectName == "TypeOfWork" &
                                     TablesLogic.tCode.ObjectName == TypeOfWork &
                                     TablesLogic.tCode.IsDeleted == 0);
                
              
                if (e == null)
                    throw new Exception("TypeOfWork '" + TypeOfWork + "' does not exist");
                else
                {
                    return e;
                }
        }

        public static OCode GetTypeOfServiceID(string TypeOfService)
        {

            OCode e;

            e = TablesLogic.tCode.Load(
                             TablesLogic.tCode.CodeType.ObjectName == "TypeOfService" &
                             TablesLogic.tCode.ObjectName == TypeOfService &
                             TablesLogic.tCode.IsDeleted == 0);


            if (e == null)
                throw new Exception("TypeOfService '" + TypeOfService + "' does not exist");
            else

                return e;

        }

        public static OCode GetTypeOfProblemID(string TypeOfProblem)
        {

            OCode e;

            e = TablesLogic.tCode.Load(
                             TablesLogic.tCode.CodeType.ObjectName == "TypeOfProblem" &
                             TablesLogic.tCode.ObjectName == TypeOfProblem &
                             TablesLogic.tCode.IsDeleted == 0);


            if (e == null)
                throw new Exception("TypeOfProblem '" + TypeOfProblem + "' does not exist");
            else
            {
                return e;

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

        public static string getLocationID(string locList)
        {
            String locID = "";
            string[] list = locList.Trim(',').Split(',');


            OLocation root = TablesLogic.tLocation.Load(
                                     TablesLogic.tLocation.ObjectName == "All Locations" &
                                     TablesLogic.tLocation.ParentID == null &
                                     TablesLogic.tLocation.IsDeleted == 0);

            locID = root.ObjectID.Value.ToString().Trim();

            for (int i = 0; i < list.Length; i++)
            {
                string loc = list[i].Trim();
                OLocation location = null;

                if (locID == null || locID.ToString() == string.Empty)
                {
                    location = TablesLogic.tLocation.Load(
                                     TablesLogic.tLocation.ObjectName == loc &
                                     TablesLogic.tLocation.ParentID == null &
                                     TablesLogic.tLocation.IsDeleted == 0);
                }
                else
                {
                    //15th March 2010, Diana, add if else clause to prevent code searching for all locations' parent
                    if (loc != "All Locations")
                    {

                        location = TablesLogic.tLocation.Load(
                                          TablesLogic.tLocation.ObjectName == loc &
                                          TablesLogic.tLocation.ParentID == new Guid(locID) &
                                          TablesLogic.tLocation.IsDeleted == 0);
                    }
                    else
                    {
                        location = root;
                    }
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

        public static OLocation locationID(string locList)
        {
            string[] list = locList.Trim(',').Split(',');
            OLocation location = null;

            for (int i = 0; i < list.Length; i++)
            {
                string loc = list[i].Trim();
                

                location = TablesLogic.tLocation.Load(
                                     TablesLogic.tLocation.ObjectName == loc &
                                     (location == null? 
                                     TablesLogic.tLocation.ParentID == null :
                                     TablesLogic.tLocation.ParentID == location.ObjectID
                                     ));
               
                if (location == null)
                    throw new Exception("Location '" + loc + "' does not exist");
            }
            return location;
        }

    }
}