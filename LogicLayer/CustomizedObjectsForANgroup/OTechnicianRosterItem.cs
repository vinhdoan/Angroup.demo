//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.Sql;
using System.Data.SqlClient;
using Anacle.DataFramework;

namespace LogicLayer
{

    public class TTechnicianRosterItem : LogicLayerSchema<OTechnicianRosterItem>
    {
        public SchemaGuid ShiftID;
        public SchemaGuid TechnicianRosterID;
        public SchemaInt Day;
        //public SchemaInt AssignmentType;
        [Default(0)]
        public SchemaInt CurrentAssignedIndex;
        //public SchemaGuid Technician1ID;
        //public SchemaGuid Technician2ID;
        //public SchemaGuid Technician3ID;
        //public SchemaGuid Technician4ID;
        public SchemaDateTime ShiftStartDateTime;
        public SchemaDateTime ShiftEndDateTime;
        public TShift Shift { get { return OneToOne<TShift>("ShiftID"); } }
        //public TUser Technician1 { get { return OneToOne<TUser>("Technician1ID"); } }
        //public TUser Technician2 { get { return OneToOne<TUser>("Technician2ID"); } }
        //public TUser Technician3 { get { return OneToOne<TUser>("Technician3ID"); } }
        //public TUser Technician4 { get { return OneToOne<TUser>("Technician4ID"); } }
        public TTechnicianRoster TechnicianRoster { get { return OneToOne<TTechnicianRoster>("TechnicianRosterID"); } }
        public TUser Technicians { get { return ManyToMany<TUser>("TechnicianRosterItemTechnician", "TechnicianRosterItemID", "UserID"); } }
    }
    public abstract class OTechnicianRosterItem : LogicLayerPersistentObject
    {
        public abstract Guid? ShiftID { get; set; }
        public abstract Guid? TechnicianRosterID { get; set; }
        public abstract int? Day { get; set; }
        //public abstract int? AssignmentType { get; set; }
        public abstract int? CurrentAssignedIndex { get; set; }
        //public abstract Guid? Technician1ID { get; set; }
        //public abstract Guid? Technician2ID { get; set; }
        //public abstract Guid? Technician3ID { get; set; }
        //public abstract Guid? Technician4ID { get; set; }
        public abstract DateTime? ShiftStartDateTime { get; set; }
        public abstract DateTime? ShiftEndDateTime { get; set; }
        public abstract OShift Shift { get; set; }
        //public abstract OUser Technician1 { get; set; }
        //public abstract OUser Technician2 { get; set; }
        //public abstract OUser Technician3 { get; set; }
        //public abstract OUser Technician4 { get; set; }
        public abstract OTechnicianRoster TechnicianRoster { get; set; }
        public abstract DataList<OUser> Technicians {get;set;}


        /// <summary>
        /// Returns a name of users.
        /// </summary>
        public string Names
        {
            get
            {
                string names = "";
                foreach (OUser user in Technicians)
                    names += (names == "" ? "" : ", ") + user.ObjectName;
                return names;
            }
        }


        public static List<OTechnicianRosterItem> GetTechnicianRosterItems(Guid? locationID, DateTime? datetime, string AssigmentMode)
        {
            List<OTechnicianRosterItem> techRosterITems = new List<OTechnicianRosterItem>();
            if (locationID != null && datetime != null)
            {
                OLocation location = TablesLogic.tLocation.Load(locationID);

                // 2010.07.29
                // Bug fix
                // If the location is deleted, return an empty list.
                //
                if (location == null)
                    return techRosterITems;

                ArrayList techRosterIDs = Query.Select(TablesLogic.tTechnicianRoster.ObjectID)
                                          .Where(TablesLogic.tTechnicianRoster.Year == datetime.Value.Year &
                                                 TablesLogic.tTechnicianRoster.Month == datetime.Value.Month &
                                                 ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tTechnicianRoster.Location.HierarchyPath + "%"))
                                          .OrderBy(TablesLogic.tTechnicianRoster.Location.HierarchyPath.Desc);
                DateTime d = new DateTime(datetime.Value.Year, datetime.Value.Month, datetime.Value.Day, datetime.Value.Hour, datetime.Value.Minute, datetime.Value.Second);
                if (techRosterIDs.Count > 0)
                {
                    techRosterITems = TablesLogic.tTechnicianRosterItem[TablesLogic.tTechnicianRosterItem.ShiftStartDateTime <= d &
                                                                        TablesLogic.tTechnicianRosterItem.ShiftEndDateTime > d &
                                                                        TablesLogic.tTechnicianRosterItem.TechnicianRosterID == techRosterIDs[0]];
                }
            }
            return techRosterITems;
        }
        public static List<OUser> GetTechnicians(OWork work, List<OTechnicianRosterItem> techRosterItems)
        {

            List<OUser> technicians = new List<OUser>();
            if (work.AssignmentMode != null)
            { 
                if (work.AssignmentMode == 0 && work.Location != null)
                {
                    technicians = OUser.GetUsersByRoleAndAboveLocation(work.Location, "WORKTECHNICIAN");
                }
                else if (work.AssignmentMode != 0 && work.LocationID != null && work.ScheduledStartDateTime != null && techRosterItems != null && techRosterItems.Count > 0)
                {
                    //String ul = "";
                    //List<OTechnicianRosterItem> items = OTechnicianRosterItem.GetTechnicianRosterItems(work.LocationID, work.ScheduledStartDateTime.Value);
                    ArrayList techIDs = new ArrayList();
                    foreach (OTechnicianRosterItem item in techRosterItems)
                    {
                        
                        //if (item.Technician1 != null && !techIDs.Contains(item.Technician1ID))
                        //{
                        //    techIDs.Add(item.Technician1ID);
                        //    if (ul != "")
                        //        ul = ul + ",'" + item.Technician1ID.ToString() + "'";
                        //    else
                        //        ul = "'" + item.Technician1ID.ToString() + "'";
                        //}
                        //if (item.Technician2 != null && !techIDs.Contains(item.Technician2ID))
                        //{
                        //    techIDs.Add(item.Technician2ID);
                        //    if (ul != "")
                        //        ul = ul + ",'" + item.Technician2ID.ToString() + "'";
                        //    else
                        //        ul = "'" + item.Technician2ID.ToString() + "'";
                        //}
                        //if (item.Technician3 != null && !techIDs.Contains(item.Technician3ID))
                        //{
                        //    techIDs.Add(item.Technician3ID);
                        //    if (ul != "")
                        //        ul = ul + ",'" + item.Technician3ID.ToString() + "'";
                        //    else
                        //        ul = "'" + item.Technician3ID.ToString() + "'";
                        //}
                        //if (item.Technician4 != null && !techIDs.Contains(item.Technician4ID))
                        //{
                        //    techIDs.Add(item.Technician4ID);
                        //    if (ul != "")
                        //        ul = ul + ",'" + item.Technician4ID.ToString() + "'";
                        //    else
                        //        ul = "'" + item.Technician4ID.ToString() + "'";
                        //}
                        foreach (OUser u in item.Technicians)
                        {
                            if (!techIDs.Contains(u.ObjectID))
                            {
                                techIDs.Add(u.ObjectID);
                                //if (ul != "")
                                //    ul = ul + ",'" + u.ObjectID + "'";
                                //else
                                //    ul = "'" + u.ObjectID + "'";
                            }
                        }
                    }
                    if (work.AssignmentMode == 1 | work.AssignmentMode == 2)
                    {
                        technicians = TablesLogic.tUser.LoadList(TablesLogic.tUser.ObjectID.In(techIDs));
                    }
                    else
                    {
                        DateTime date = work.ScheduledStartDateTime.Value.AddDays(-1);
                        DateTime startDateTime = work.ScheduledStartDateTime.Value;

                        TUser u = TablesLogic.tUser;
                        TWorkCost wc = TablesLogic.tWorkCost;
                        DataTable users =
                            u.Select(u.ObjectID,
                                wc.Select(
                                    wc.ObjectID.Count())
                                .Where(
                                    wc.Work.IsDeleted == 0 &
                                    wc.UserID == u.ObjectID &
                                    wc.Work.ScheduledStartDateTime >= date).As("Count"))
                            .Where(
                                u.ObjectID.In(techIDs)
                                );

                        // Look for the smallest count.
                        //
                        int minIndex = -1;
                        int minCount = int.MaxValue;
                        for (int i = 0; i < users.Rows.Count; i++)
                            if ((int)users.Rows[i]["Count"] < minCount)
                            {
                                minIndex = i;
                                minCount = (int)users.Rows[i]["Count"];
                            }

                        if (minIndex != -1)
                            technicians = TablesLogic.tUser.Load((Guid)users.Rows[minIndex]["ObjectID"]);
                    }
                }
            }
            return technicians;
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="t"></param>
        /// <param name="item"></param>
        /// <returns></returns>
        public static TemporaryTechnicianRosterItem validateSameTechnicianwithDifferentShift(List<TemporaryTechnicianRosterItem> t, OTechnicianRosterItem item)
        {
            foreach (TemporaryTechnicianRosterItem temp in t)
            {

                switch (item.Day)
                {
                    case 1:
                        if (temp.Day1 == null || temp.Day1 == "")
                            return temp;
                        break;
                    case 2:
                        if (temp.Day2 == null || temp.Day2 == "")
                            return temp;
                        break;
                    case 3:
                        if (temp.Day3 == null || temp.Day3 == "")
                            return temp;
                        break;
                    case 4:
                        if (temp.Day4 == null || temp.Day4 == "")
                            return temp;
                        break;
                    case 5:
                        if (temp.Day5 == null || temp.Day5 == "")
                            return temp;
                        break;
                    case 6:
                        if (temp.Day6 == null || temp.Day6 == "")
                            return temp;
                        break;
                    case 7:
                        if (temp.Day7 == null || temp.Day7 == "")
                            return temp;
                        break;
                    case 8:
                        if (temp.Day8 == null || temp.Day8 == "")
                            return temp;
                        break;
                    case 9:
                        if (temp.Day9 == null || temp.Day9 == "")
                            return temp;
                        break;
                    case 10:
                        if (temp.Day10 == null || temp.Day10 == "")
                            return temp;
                        break;
                    case 11:
                        if (temp.Day11 == null || temp.Day11 == "")
                            return temp;
                        break;
                    case 12:
                        if (temp.Day12 == null || temp.Day12 == "")
                            return temp;
                        break;
                    case 13:
                        if (temp.Day13 == null || temp.Day13 == "")
                            return temp;
                        break;
                    case 14:
                        if (temp.Day14 == null || temp.Day14 == "")
                            return temp;
                        break;
                    case 15:
                        if (temp.Day15 == null || temp.Day15 == "")
                            return temp;
                        break;
                    case 16:
                        if (temp.Day16 == null || temp.Day16 == "")
                            return temp;
                        break;
                    case 17:
                        if (temp.Day17 == null || temp.Day17 == "")
                            return temp;
                        break;
                    case 18:
                        if (temp.Day18 == null || temp.Day18 == "")
                            return temp;
                        break;
                    case 19:
                        if (temp.Day19 == null || temp.Day19 == "")
                            return temp;
                        break;
                    case 20:
                        if (temp.Day20 == null || temp.Day20 == "")
                            return temp;
                        break;
                    case 21:
                        if (temp.Day21 == null || temp.Day21 == "")
                            return temp;
                        break;
                    case 22:
                        if (temp.Day22 == null || temp.Day22 == "")
                            return temp;
                        break;
                    case 23:
                        if (temp.Day23 == null || temp.Day23 == "")
                            return temp;
                        break;
                    case 24:
                        if (temp.Day24 == null || temp.Day24 == "")
                            return temp;
                        break;
                    case 25:
                        if (temp.Day25 == null || temp.Day25 == "")
                            return temp;
                        break;
                    case 26:
                        if (temp.Day26 == null || temp.Day26 == "")
                            return temp;
                        break;
                    case 27:
                        if (temp.Day27 == null || temp.Day27 == "")
                            return temp;
                        break;
                    case 28:
                        if (temp.Day28 == null || temp.Day28 == "")
                            return temp;
                        break;
                    case 29:
                        if (temp.Day29 == null || temp.Day29 == "")
                            return temp;
                        break;
                    case 30:
                        if (temp.Day30 == null || temp.Day30 == "")
                            return temp;
                        break;
                    case 31:
                        if (temp.Day31 == null || temp.Day31 == "")
                            return temp;
                        break;

                }
            }
            return null;

        }
    }

    public class TemporaryTechnicianRosterItem
    {
        public Guid TechID;
        public String Name;
        public String Day1;
        public String Day2;
        public String Day3;
        public String Day4;
        public String Day5;
        public String Day6;
        public String Day7;
        public String Day8;
        public String Day9;
        public String Day10;
        public String Day11;
        public String Day12;
        public String Day13;
        public String Day14;
        public String Day15;
        public String Day16;
        public String Day17;
        public String Day18;
        public String Day19;
        public String Day20;
        public String Day21;
        public String Day22;
        public String Day23;
        public String Day24;
        public String Day25;
        public String Day26;
        public String Day27;
        public String Day28;
        public String Day29;
        public String Day30;
        public String Day31;
    }

}
