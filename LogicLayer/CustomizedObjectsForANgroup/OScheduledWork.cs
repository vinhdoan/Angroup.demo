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

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TScheduledWork : LogicLayerSchema<OScheduledWork>
    {

        [Default(0)]
        public SchemaInt IsCreateSingleWork;
        //public SchemaInt isAuditJob;
    }


    /// <summary>
    /// Represents a scheduled work record that contains information
    /// about how works can be routinely generated. 
    /// </summary>
    public abstract partial class OScheduledWork : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract int? IsCreateSingleWork { get; set; }
        //public abstract int? isAuditJob { get; set; }
        public void CreateWorksForKeppel(string newWorkState)
        {
            using (Connection c = new Connection())
            {
                if (this.Works.Count > 0)
                    return;

                DateTime startDateTime = this.FirstWorkStartDateTime.Value;
                DateTime endDateTime = this.FirstWorkEndDateTime.Value;

                DateTime prevDateTime = DateTime.MinValue;

                // form the staggering 
                //
                List<StaggerProperty> stagger = new List<StaggerProperty>();
                if (this.EquipmentLocation == 0)
                {
                    // equipment
                    if (this.IsStaggered == 1)
                    {
                        if (this.IsCreateSingleWork != 1)
                            // kf begin: bug fix to ignore those whose units to stagger = N/A
                            foreach (OScheduledWorkStaggeredEquipment o in this.ScheduledWorkStaggeredEquipment)
                            {
                                if (o.UnitsToStagger != null)
                                    stagger.Add(new StaggerProperty(o.EquipmentID.Value, o.Equipment.ObjectName, o.UnitsToStagger.Value));
                            }
                        // kf end
                        else
                            stagger.Add(new StaggerProperty(new Guid(), "", 0));
                    }
                    else
                    {
                        if (this.IsCreateSingleWork != 1)
                        {
                            foreach (OEquipment o in this.ScheduledWorkEquipment)
                                stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
                        }
                        else
                            stagger.Add(new StaggerProperty(new Guid(), "", 0));
                    }
                }
                else if (this.EquipmentLocation == 1)
                {
                    if (this.IsStaggered == 1)
                        // location
                        // kf begin: bug fix to ignore those whose units to stagger = N/A
                        foreach (OScheduledWorkStaggeredLocation o in this.ScheduledWorkStaggeredLocation)
                        {
                            if (o.UnitsToStagger != null)
                                stagger.Add(new StaggerProperty(o.LocationID.Value, o.Location.ObjectName, o.UnitsToStagger.Value));
                        }
                    // kf end
                    else
                        foreach (OLocation o in this.ScheduledWorkLocation)
                            stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
                }
                stagger.Sort(new StaggerPropertyComparer());


                // initialize internal search tables for the searching of working dates
                //
                if (this.Calendar != null)
                    this.Calendar.InitializeSearchTable();

                // compile a hashtable of checklists
                //
                Hashtable checklists = new Hashtable();
                foreach (OScheduledWorkChecklist ch in this.ScheduledWorkChecklist)
                    if (ch.CycleNumber != null)
                        checklists[ch.CycleNumber.Value] = ch;

                Hashtable createdWorks = new Hashtable();

                // cycle through all dates
                //
                int checklistCount = 0;
                while (true)
                {
                    DateTime workingStartDateTime = startDateTime;
                    DateTime workingEndDateTime = endDateTime;

                    // get the checklist
                    //
                    Guid? checklistId = null;
                    if (this.ScheduledWorkChecklist.Count > 0)
                    {
                        int count = checklistCount % this.ScheduledWorkChecklist.Count;
                        if (checklists[count + 1] != null)
                            checklistId = (checklists[count + 1] as OScheduledWorkChecklist).ChecklistID;
                    }

                    // create the set of works
                    //
                    foreach (StaggerProperty o in stagger)
                    {
                        OWork work = TablesLogic.tWork.Create();

                        // compute the date
                        //
                        DateTime start, end;

                        if (this.StaggerBy == 0)        // daily
                        {
                            start = workingStartDateTime.AddDays((double)o.staggerValue);
                            end = workingEndDateTime.AddDays((double)o.staggerValue);
                        }
                        else if (this.StaggerBy == 1)   // weekly
                        {
                            start = workingStartDateTime.AddDays((double)o.staggerValue * 7);
                            end = workingEndDateTime.AddDays((double)o.staggerValue * 7);
                        }
                        else if (this.StaggerBy == 2)   // monthly
                        {
                            start = workingStartDateTime.AddMonths(o.staggerValue);
                            end = workingEndDateTime.AddMonths(o.staggerValue);
                        }
                        else                            // yearly
                        {
                            start = workingStartDateTime.AddMonths(o.staggerValue * 12);
                            end = workingEndDateTime.AddMonths(o.staggerValue * 12);
                        }


                        if (this.CalendarID != null && this.CalendarBlockMethod != null)
                        {
                            if (!Calendar.FindNextWorkingDay(
                                this.CalendarBlockMethod == 0,
                                this.CalendarBlockMethod == 1,
                                ref start, ref end))
                                continue;
                        }
                        work.ScheduledStartDateTime = start;
                        work.ScheduledEndDateTime = end;

                        // once we know the date, check if a similar work
                        // with the same date/checklistid/(location or equipment)
                        // has already been created. if so, don't create this
                        // work anymore!
                        //
                        string key = start.ToString("dd-MM-yyyy hh:mm:ss") + ";" + o.staggerId + ";" + (checklistId == null ? "" : checklistId.ToString());
                        if (createdWorks[key] != null)
                            continue;
                        createdWorks[key] = 1;


                        // copy the basic work parameters over
                        //
                        work.TypeOfWorkID = this.TypeOfWorkID;
                        work.TypeOfServiceID = this.TypeOfServiceID;
                        work.TypeOfProblemID = this.TypeOfProblemID;
                        work.WorkDescription = this.WorkDescription;
                        work.Priority = this.Priority;
                        work.SupervisorID = this.SupervisorID;
                        work.SchedulerCounter = checklistCount;
                        work.ChecklistID = checklistId;

                        if (this.ContractID != null)
                            work.ContractID = this.ContractID;

                        // apply the parameters to the works
                        //
                        //if (this.EquipmentLocation == 0)
                        //{
                        //    foreach (OEquipmentTypeParameter parameter in this.ScheduledWorkEquipmentTypeParameters)
                        //    {
                        //        OWorkParameterReading reading = TablesLogic.tWorkParameterReading.Create();
                        //        reading.ObjectName = parameter.ObjectName;
                        //        reading.UnitOfMeasureID = parameter.UnitOfMeasureID;
                        //        work.WorkParameterReadings.Add(reading);
                        //    }
                        //}
                        //if (this.EquipmentLocation == 1)
                        //{
                        //    foreach (OLocationTypeParameter parameter in this.ScheduledWorkLocationTypeParameters)
                        //    {
                        //        OWorkParameterReading reading = TablesLogic.tWorkParameterReading.Create();
                        //        reading.ObjectName = parameter.ObjectName;
                        //        reading.UnitOfMeasureID = parameter.UnitOfMeasureID;
                        //        work.WorkParameterReadings.Add(reading);
                        //    }
                        //}


                        // apply the cost to the works
                        //
                        foreach (OScheduledWorkCost sCost in this.ScheduledWorkCost)
                        {
                            OWorkCost wCost = TablesLogic.tWorkCost.Create();

                            wCost.CostType = sCost.CostType;
                            wCost.CraftID = sCost.CraftID;
                            wCost.UserID = sCost.UserID;
                            wCost.StoreID = sCost.StoreID;
                            wCost.StoreBinID = sCost.StoreBinID;
                            wCost.CatalogueID = sCost.CatalogueID;
                            wCost.UnitOfMeasureID = sCost.UnitOfMeasureID;
                            wCost.ObjectName = sCost.ObjectName;
                            wCost.CostDescription = sCost.CostDescription;
                            wCost.EstimatedCostFactor = sCost.EstimatedCostFactor;
                            wCost.EstimatedOvertime = sCost.EstimatedOvertime;
                            wCost.EstimatedQuantity = sCost.EstimatedQuantity;
                            wCost.EstimatedUnitCost = sCost.EstimatedUnitCost;
                            work.WorkCost.Add(wCost);
                        }

                        if (this.EquipmentLocation == 0)
                        {
                            if (this.IsCreateSingleWork != 1)
                            {
                                work.LocationID = TablesLogic.tEquipment[o.staggerId].LocationID;
                                work.EquipmentID = o.staggerId;
                            }
                            else
                                work.LocationID = new Guid(this.LocationID.ToString());
                        }
                        else
                            work.LocationID = o.staggerId;

                        if (this.IsScheduledByOccurrence != 0 ||
                            work.ScheduledStartDateTime.Value <= this.EndDateTime.Value)
                        {
                            this.Works.Add(work);

                            work.Save();
                            work.TriggerWorkflowEvent(newWorkState);
                        }
                    }
                    prevDateTime = workingStartDateTime;

                    // figure out the next date to schedule
                    //
                    if (this.IsFloating == 0)
                    {
                        if (!OCalendar.ScheduleNextDate(this, ref startDateTime, ref endDateTime))
                            break;
                    }
                    else
                        break;

                    checklistCount++;
                    if (this.IsScheduledByOccurrence == 0 && startDateTime > this.EndDateTime.Value)
                        break;
                    if (this.IsScheduledByOccurrence == 1 && checklistCount >= this.EndNumberOfOccurrences)
                        break;
                }

                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Creates a set of works for the next cycle. This method
        /// is called by the scheduler service.
        /// </summary>
        public void CreateWorksForNextCycleForKeppel(string eventToTriggerForWork)
        {
            using (Connection c = new Connection())
            {
                DateTime startDateTime = this.SchedulerStartDateTime.Value;
                DateTime endDateTime = this.SchedulerEndDateTime.Value;

                DateTime prevDateTime = DateTime.MinValue;

                // form the staggering 
                //
                List<StaggerProperty> stagger = new List<StaggerProperty>();
                if (this.EquipmentLocation == 0)
                {
                    // equipment
                    if (this.IsStaggered == 1)
                    {
                        if (this.IsCreateSingleWork != 1)
                            // kf begin: bug fix to ignore those whose units to stagger = N/A
                            foreach (OScheduledWorkStaggeredEquipment o in this.ScheduledWorkStaggeredEquipment)
                            {
                                if (o.UnitsToStagger != null)
                                    stagger.Add(new StaggerProperty(o.EquipmentID.Value, o.Equipment.ObjectName, o.UnitsToStagger.Value));
                            }
                        // kf end
                        else
                            stagger.Add(new StaggerProperty(new Guid(), "", 0));
                    }
                    else
                    {
                        //for create single work order, all equipments in the Equipment list view 
                        //of this scheduled work will be combined in 1 work order
                        if (this.IsCreateSingleWork != 1)
                        {
                            foreach (OEquipment o in this.ScheduledWorkEquipment)
                                stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
                        }
                        else
                            stagger.Add(new StaggerProperty(new Guid(), "", 0));
                    }
                }
                else if (this.EquipmentLocation == 1)
                {
                    if (this.IsStaggered == 1)
                        // location
                        // kf begin: bug fix to ignore those whose units to stagger = N/A
                        foreach (OScheduledWorkStaggeredLocation o in this.ScheduledWorkStaggeredLocation)
                        {
                            if (o.UnitsToStagger != null)
                                stagger.Add(new StaggerProperty(o.LocationID.Value, o.Location.ObjectName, o.UnitsToStagger.Value));
                        }
                    // kf end
                    else
                        foreach (OLocation o in this.ScheduledWorkLocation)
                            stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
                }
                stagger.Sort(new StaggerPropertyComparer());


                // initialize internal search tables for the searching of working dates
                //
                if (this.Calendar != null)
                    this.Calendar.InitializeSearchTable();

                // compile a hashtable of checklists
                //
                Hashtable checklists = new Hashtable();
                foreach (OScheduledWorkChecklist ch in this.ScheduledWorkChecklist)
                    if (ch.CycleNumber != null)
                        checklists[ch.CycleNumber.Value] = ch;

                // get the checklist
                //
                Guid? checklistId = null;
                if (this.ScheduledWorkChecklist.Count > 0)
                {
                    int count = this.SchedulerChecklistCount.Value % this.ScheduledWorkChecklist.Count;
                    if (checklists[count + 1] != null)
                        checklistId = (checklists[count + 1] as OScheduledWorkChecklist).ChecklistID;
                }

                DateTime workingStartDateTime = startDateTime;
                DateTime workingEndDateTime = endDateTime;

                // create the set of works
                //
                foreach (StaggerProperty o in stagger)
                {
                    // compute the date
                    //
                    DateTime start, end;

                    if (this.StaggerBy == 0)        // daily
                    {
                        start = workingStartDateTime.AddDays((double)o.staggerValue);
                        end = workingEndDateTime.AddDays((double)o.staggerValue);
                    }
                    else if (this.StaggerBy == 1)   // weekly
                    {
                        start = workingStartDateTime.AddDays((double)o.staggerValue * 7);
                        end = workingEndDateTime.AddDays((double)o.staggerValue * 7);
                    }
                    else if (this.StaggerBy == 2)   // monthly
                    {
                        start = workingStartDateTime.AddMonths(o.staggerValue);
                        end = workingEndDateTime.AddMonths(o.staggerValue);
                    }
                    else                            // yearly
                    {
                        start = workingStartDateTime.AddMonths(o.staggerValue * 12);
                        end = workingEndDateTime.AddMonths(o.staggerValue * 12);
                    }

                    if (this.CalendarID != null && this.CalendarBlockMethod != null)
                    {
                        if (!Calendar.FindNextWorkingDay(
                            this.CalendarBlockMethod == 0,
                            this.CalendarBlockMethod == 1,
                            ref start, ref end))
                            continue;
                    }

                    // once we know the date, check if a similar work
                    // with the same date/checklistid/(location or equipment)
                    // has already been created. if so, don't create this
                    // work anymore!
                    //
                    OWork existingWork = TablesLogic.tWork.Load(
                        TablesLogic.tWork.ScheduledWorkID == this.ObjectID &
                        TablesLogic.tWork.ScheduledStartDateTime == start &
                        (TablesLogic.tWork.EquipmentID == o.staggerId |
                        TablesLogic.tWork.LocationID == o.staggerId) &
                        TablesLogic.tWork.ChecklistID == checklistId);
                    if (existingWork != null)
                        continue;

                    // copy the basic work parameters over
                    //
                    OWork work = TablesLogic.tWork.Create();

                    work.ReportedDateTime = start;
                    work.ScheduledStartDateTime = start;
                    work.ScheduledEndDateTime = end;
                    work.TypeOfWorkID = this.TypeOfWorkID;
                    work.TypeOfServiceID = this.TypeOfServiceID;
                    work.TypeOfProblemID = this.TypeOfProblemID;
                    work.WorkDescription = this.WorkDescription;
                    work.Priority = this.Priority;
                    work.SupervisorID = this.SupervisorID;
                    work.SchedulerCounter = this.SchedulerChecklistCount;
                    work.ChecklistID = checklistId;
                    //work.isAuditJob = isAuditJob;
                    if (this.ContractID != null)
                        work.ContractID = this.ContractID;

                    // apply the parameters to the works
                    //
                    //if (this.EquipmentLocation == 0)
                    //{
                    //    foreach (OEquipmentTypeParameter parameter in this.ScheduledWorkEquipmentTypeParameters)
                    //    {
                    //        OWorkParameterReading reading = TablesLogic.tWorkParameterReading.Create();
                    //        reading.ObjectName = parameter.ObjectName;
                    //        reading.UnitOfMeasureID = parameter.UnitOfMeasureID;
                    //        work.WorkParameterReadings.Add(reading);
                    //    }
                    //}
                    //if (this.EquipmentLocation == 1)
                    //{
                    //    foreach (OLocationTypeParameter parameter in this.ScheduledWorkLocationTypeParameters)
                    //    {
                    //        OWorkParameterReading reading = TablesLogic.tWorkParameterReading.Create();
                    //        reading.ObjectName = parameter.ObjectName;
                    //        reading.UnitOfMeasureID = parameter.UnitOfMeasureID;
                    //        work.WorkParameterReadings.Add(reading);
                    //    }
                    //}


                    // apply the cost to the works
                    //
                    foreach (OScheduledWorkCost sCost in this.ScheduledWorkCost)
                    {
                        OWorkCost wCost = TablesLogic.tWorkCost.Create();

                        wCost.CostType = sCost.CostType;
                        wCost.CraftID = sCost.CraftID;
                        wCost.UserID = sCost.UserID;
                        wCost.StoreID = sCost.StoreID;
                        wCost.StoreBinID = sCost.StoreBinID;
                        wCost.CatalogueID = sCost.CatalogueID;
                        wCost.UnitOfMeasureID = sCost.UnitOfMeasureID;
                        wCost.ObjectName = sCost.ObjectName;
                        wCost.CostDescription = sCost.CostDescription;
                        wCost.EstimatedCostFactor = sCost.EstimatedCostFactor;
                        wCost.EstimatedOvertime = sCost.EstimatedOvertime;
                        wCost.EstimatedQuantity = sCost.EstimatedQuantity;
                        wCost.EstimatedUnitCost = sCost.EstimatedUnitCost;
                        work.WorkCost.Add(wCost);
                    }

                    if (this.EquipmentLocation == 0)
                    {
                        if (this.IsCreateSingleWork != 1)
                        {
                            work.LocationID = TablesLogic.tEquipment[o.staggerId].LocationID;
                            work.EquipmentID = o.staggerId;
                        }
                        else
                        {
                            work.LocationID = new Guid(this.LocationID.ToString());
                            
                        }
                    }
                    else
                        work.LocationID = o.staggerId;
                    //if (isAuditJob == 1)
                        work.UpdateChecklist();

                    if (this.IsScheduledByOccurrence != 0 ||
                        work.ScheduledStartDateTime.Value <= this.EndDateTime.Value)
                    {
                        this.Works.Add(work);

                        work.Save();
                        //if (isAuditJob == 1)
                        work.TriggerWorkflowEvent("SubmitForAssignment");
                        //else
                        //    work.TriggerWorkflowEvent(eventToTriggerForWork);
                    }
                }

                // figure out the next date to schedule
                //
                if (this.IsFloating == 0)
                {
                    // If the scheduled work is a fixed schedule,
                    // then we continue to create subsequent works.
                    //
                    if (!OCalendar.ScheduleNextDate(this, ref startDateTime, ref endDateTime))
                        this.SchedulerInProgress = 0;
                }
                else
                {
                    // If the scheduled work is a floating schedule,
                    // then once we have created the first work,
                    // stop scheduling the next works.
                    //
                    this.SchedulerInProgress = 0;
                }
                this.SchedulerStartDateTime = startDateTime;
                this.SchedulerEndDateTime = endDateTime;

                this.SchedulerChecklistCount++;
                if (this.IsScheduledByOccurrence == 0 && startDateTime > this.EndDateTime.Value)
                    this.SchedulerInProgress = 0;
                if (this.IsScheduledByOccurrence == 1 && this.SchedulerChecklistCount >= this.EndNumberOfOccurrences)
                    this.SchedulerInProgress = 0;

                this.Save();
                c.Commit();
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Pretend Create all work orders, based on the scheduled work's 
        /// parameters.
        /// </summary>
        /// --------------------------------------------------------------
        public List<WorkDummy> PretendCreateWorksForKeppel()
        {
            List<WorkDummy> workList = new List<WorkDummy>();

            DateTime startDateTime = this.FirstWorkStartDateTime.Value;
            DateTime endDateTime = this.FirstWorkEndDateTime.Value;

            DateTime prevDateTime = DateTime.MinValue;

            // form the staggering 
            //
            List<StaggerProperty> stagger = new List<StaggerProperty>();
            if (this.EquipmentLocation == 0)
            {
                // equipment
                if (this.IsStaggered == 1)
                {
                    if (this.IsCreateSingleWork != 1)
                        // kf begin: bug fix to ignore those whose units to stagger = N/A
                        foreach (OScheduledWorkStaggeredEquipment o in this.ScheduledWorkStaggeredEquipment)
                        {
                            if (o.UnitsToStagger != null)
                                stagger.Add(new StaggerProperty(o.EquipmentID.Value, o.Equipment.ObjectName, o.UnitsToStagger.Value));
                        }
                    // kf end
                    else
                        stagger.Add(new StaggerProperty(new Guid(), "", 0));
                }
                else
                {
                    //for create single work order, all equipments in the Equipment list view 
                    //of this scheduled work will be combined in 1 work order
                    if (this.IsCreateSingleWork != 1)
                    {
                        foreach (OEquipment o in this.ScheduledWorkEquipment)
                            stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
                    }
                    else
                        stagger.Add(new StaggerProperty(new Guid(), "", 0));
                }
            }
            else if (this.EquipmentLocation == 1)
            {
                if (this.IsStaggered == 1)
                    // location
                    // kf begin: bug fix to ignore those whose units to stagger = N/A
                    foreach (OScheduledWorkStaggeredLocation o in this.ScheduledWorkStaggeredLocation)
                    {
                        if (o.UnitsToStagger != null)
                            stagger.Add(new StaggerProperty(o.LocationID.Value, o.Location.ObjectName, o.UnitsToStagger.Value));
                    }
                // kf end
                else
                    foreach (OLocation o in this.ScheduledWorkLocation)
                        stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
            }
            stagger.Sort(new StaggerPropertyComparer());


            // initialize internal search tables for the searching of working dates
            //
            if (this.Calendar != null)
                this.Calendar.InitializeSearchTable();

            // compile a hashtable of checklists
            //
            Hashtable checklists = new Hashtable();
            foreach (OScheduledWorkChecklist ch in this.ScheduledWorkChecklist)
                if (ch.CycleNumber != null)
                    checklists[ch.CycleNumber.Value] = ch;

            Hashtable createdWorks = new Hashtable();

            // cycle through all dates
            //
            int checklistCount = 0;
            while (true)
            {
                DateTime workingStartDateTime = startDateTime;
                DateTime workingEndDateTime = endDateTime;

                // get the checklist
                //
                Guid? checklistId = null;
                string checklistName = "";
                if (this.ScheduledWorkChecklist.Count > 0)
                {
                    int count = checklistCount % this.ScheduledWorkChecklist.Count;
                    if (checklists[count + 1] != null)
                    {
                        checklistId = (checklists[count + 1] as OScheduledWorkChecklist).ChecklistID;
                        checklistName = (checklists[count + 1] as OScheduledWorkChecklist).Checklist.ObjectName;
                    }
                }

                // create the set of works
                //
                foreach (StaggerProperty o in stagger)
                {
                    WorkDummy work = new WorkDummy();

                    // compute the date
                    //
                    DateTime start, end;

                    if (this.StaggerBy == 0)        // daily
                    {
                        start = workingStartDateTime.AddDays((double)o.staggerValue);
                        end = workingEndDateTime.AddDays((double)o.staggerValue);
                    }
                    else if (this.StaggerBy == 1)   // weekly
                    {
                        start = workingStartDateTime.AddDays((double)o.staggerValue * 7);
                        end = workingEndDateTime.AddDays((double)o.staggerValue * 7);
                    }
                    else if (this.StaggerBy == 2)   // monthly
                    {
                        start = workingStartDateTime.AddMonths(o.staggerValue);
                        end = workingEndDateTime.AddMonths(o.staggerValue);
                    }
                    else                            // yearly
                    {
                        start = workingStartDateTime.AddMonths(o.staggerValue * 12);
                        end = workingEndDateTime.AddMonths(o.staggerValue * 12);
                    }


                    if (this.CalendarID != null && this.CalendarBlockMethod != null)
                    {
                        if (!Calendar.FindNextWorkingDay(
                            this.CalendarBlockMethod == 0,
                            this.CalendarBlockMethod == 1,
                            ref start, ref end))
                            continue;
                    }
                    work.ScheduledStartDateTime = start;
                    work.ScheduledEndDateTime = end;

                    // once we know the date, check if a similar work
                    // with the same date/checklistid/(location or equipment)
                    // has already been created. if so, don't create this
                    // work anymore!
                    //
                    string key = start.ToString("dd-MM-yyyy hh:mm:ss") + ";" + o.staggerId + ";" + (checklistId == null ? "" : checklistId.ToString());
                    if (createdWorks[key] != null)
                        continue;
                    createdWorks[key] = 1;


                    // copy the basic work parameters over
                    //

                    work.Priority = this.Priority;
                    work.SchedulerCounter = checklistCount;
                    work.Checklist = checklistName;


                    if (this.EquipmentLocation == 0)
                    {
                        if (this.IsCreateSingleWork == 0)
                        {
                            work.Equipment = TablesLogic.tEquipment[o.staggerId];
                            work.Location = work.Equipment.Location;
                            
                        }
                        else
                            work.Location = this.Location;
                            
                            
                    }
                    else
                        work.Location = TablesLogic.tLocation[o.staggerId];

                    if (this.IsScheduledByOccurrence != 0 ||
                        work.ScheduledStartDateTime <= this.EndDateTime.Value)
                    {
                        workList.Add(work);
                    }
                }
                prevDateTime = workingStartDateTime;

                // figure out the next date to schedule
                //
                if (this.IsFloating == 0)
                {
                    if (!OCalendar.ScheduleNextDate(this, ref startDateTime, ref endDateTime))
                        break;
                }
                else
                    break;

                checklistCount++;
                if (this.IsScheduledByOccurrence == 0 && startDateTime > this.EndDateTime.Value)
                    break;
                if (this.IsScheduledByOccurrence == 1 && checklistCount >= this.EndNumberOfOccurrences)
                    break;
            }
            return workList;
        }
        
    }

}


