//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    [Database("#database"), Map("ScheduledWork")]
    public partial class TScheduledWork : LogicLayerSchema<OScheduledWork>
    {
        public SchemaGuid EquipmentID;
        public SchemaGuid LocationID;
        public SchemaGuid ContractID;

        [Size(255)]
        public SchemaString WorkDescription;
        public SchemaGuid TypeOfWorkID;
        public SchemaGuid TypeOfServiceID;
        public SchemaGuid TypeOfProblemID;
        [Default(0)]
        public SchemaInt Priority;
        public SchemaInt EquipmentLocation;
        public SchemaGuid EquipmentTypeID;
        public SchemaGuid LocationTypeID;
        public SchemaInt IsStaggered;
        public SchemaInt StaggerBy;
        public SchemaGuid SupervisorID;

        public SchemaDateTime FirstWorkStartDateTime;
        public SchemaDateTime FirstWorkEndDateTime;
        public SchemaInt FrequencyCount;
        [Default(2)]
        public SchemaInt FrequencyInterval;
        [Default(0)]
        public SchemaInt IsFloating;
        [Default(0)]
        public SchemaInt WeekType;
        public SchemaInt WeekTypeDay0;
        public SchemaInt WeekTypeDay1;
        public SchemaInt WeekTypeDay2;
        public SchemaInt WeekTypeDay3;
        public SchemaInt WeekTypeDay4;
        public SchemaInt WeekTypeDay5;
        public SchemaInt WeekTypeDay6;
        [Default(0)]
        public SchemaInt MonthType;
        public SchemaInt MonthTypeWeekNumber;
        public SchemaInt MonthTypeDay;
        [Default(0)]
        public SchemaInt IsScheduledByOccurrence;
        public SchemaDateTime EndDateTime;
        [Default(10)]
        public SchemaInt EndNumberOfOccurrences;
        public SchemaGuid CalendarID;
        [Default(0)]
        public SchemaInt CalendarBlockMethod;

        public SchemaInt SchedulerInProgress;
        public SchemaInt SchedulerChecklistCount;
        public SchemaDateTime SchedulerStartDateTime;
        public SchemaDateTime SchedulerEndDateTime;

        public SchemaInt IsCreated;
        public SchemaInt IsCancelled;
        [Default(0)]
        public SchemaInt IsAllFixedWorksCreatedAtOnce;
        [Default(7)]
        public SchemaInt NumberOfDaysInAdvanceToCreateFixedWorks;

        public TEquipmentType EquipmentType { get { return OneToOne<TEquipmentType>("EquipmentTypeID"); } }
        public TLocationType LocationType { get { return OneToOne<TLocationType>("LocationTypeID"); } }
        public TWork Works { get { return OneToMany<TWork>("ScheduledWorkID"); } }

        public TUser Supervisor { get { return OneToOne<TUser>("SupervisorID"); } }
        public TCode TypeOfWork { get { return OneToOne<TCode>("TypeOfWorkID"); } }
        public TCode TypeOfService { get { return OneToOne<TCode>("TypeOfServiceID"); } }
        public TCode TypeOfProblem { get { return OneToOne<TCode>("TypeOfProblemID"); } }

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }

        public TScheduledWorkStaggeredEquipment ScheduledWorkStaggeredEquipment { get { return OneToMany<TScheduledWorkStaggeredEquipment>("ScheduledWorkID"); } }
        public TScheduledWorkStaggeredLocation ScheduledWorkStaggeredLocation { get { return OneToMany<TScheduledWorkStaggeredLocation>("ScheduledWorkID"); } }
        public TScheduledWorkCost ScheduledWorkCost { get { return OneToMany<TScheduledWorkCost>("ScheduledWorkID"); } }
        public TScheduledWorkChecklist ScheduledWorkChecklist { get { return OneToMany<TScheduledWorkChecklist>("ScheduledWorkID"); } }

        //public TEquipmentTypeParameter ScheduledWorkEquipmentTypeParameters { get { return ManyToMany<TEquipmentTypeParameter>("ScheduledWorkEquipmentTypeParameter", "ScheduledWorkID", "EquipmentTypeParameterID"); } }
        //public TLocationTypeParameter ScheduledWorkLocationTypeParameters { get { return ManyToMany<TLocationTypeParameter>("ScheduledWorkLocationTypeParameter", "ScheduledWorkID", "LocationTypeParameterID"); } }

        public TEquipment ScheduledWorkEquipment { get { return ManyToMany<TEquipment>("ScheduledWorkEquipment", "ScheduledWorkID", "EquipmentID"); } }
        public TLocation ScheduledWorkLocation { get { return ManyToMany<TLocation>("ScheduledWorkLocation", "ScheduledWorkID", "LocationID"); } }

        public TCalendar Calendar { get { return OneToOne<TCalendar>("CalendarID"); } }

    }


    /// <summary>
    /// Represents a scheduled work record that contains information
    /// about how works can be routinely generated. 
    /// </summary>
    public abstract partial class OScheduledWork : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Equipment table 
        /// that indicates the top-level equipment that works generated
        /// by this scheduled work will be based on. This does not indicate
        /// the equipment associated with the generated works. 
        /// The ScheduledWorkEquipment / ScheduledWorkStaggeredEquipment
        /// is the property that will indicate those equipment.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table 
        /// that indicates the top-level equipment that works generated
        /// by this scheduled work will be based on. This does not indicate
        /// the location associated with the generated works. 
        /// The ScheduledWorkLocation / ScheduledWorkStaggeredLocation
        /// is the property that will indicate those location.
        /// </summary>
        public abstract Guid? LocationID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Contract table 
        /// that indicates the term contract that can be used to 
        /// generate scheduled works.
        /// </summary>
        public abstract Guid? ContractID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the description of the generated
        /// works.
        /// </summary>
        public abstract String WorkDescription { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the type of work of this scheduled work.
        /// </summary>
        public abstract Guid? TypeOfWorkID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the type of service of this scheduled work.
        /// </summary>
        public abstract Guid? TypeOfServiceID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the type of problem of this scheduled work.
        /// </summary>
        public abstract Guid? TypeOfProblemID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the priority of the generated works. 
        /// </summary>
        public abstract int? Priority { get; set; }


        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// works generated from this schedule work object are for
        /// equipment or for locations.
        /// <para></para>
        /// <list>
        ///   <item>0 - Generate works for equipment</item>
        ///   <item>1 - Generate works for location</item>
        /// </list>
        /// </summary>
        public abstract int? EquipmentLocation { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the EquipmentType table 
        /// that indicates the type of equipment to generate works for.
        /// This is applicable if EquipmentLocation = 0.
        /// </summary>
        public abstract Guid? EquipmentTypeID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the LocationType table 
        /// that indicates the type of location to generate works for.
        /// This is applicable if EquipmentLocation = 1.
        /// </summary>
        public abstract Guid? LocationTypeID { get; set; }


        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the works generated for the same cycle is staggered
        /// (or spread apart so they do not all fall on the same day).
        /// <para></para>
        /// <list>
        ///   <item>0 - All works for the same cycle are scheduled on the same day.</item>
        ///   <item>1 - Works for the same cycle are staggered, and the staggering
        /// is specified in ScheduledWorkStaggeredEquipment/ScheduledWorkStaggeredLocation.</item>
        /// </list>
        /// </summary>
        public abstract int? IsStaggered { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit to stagger the works by.
        /// <para></para>
        /// <list>
        ///   <item>0 - Daily</item>
        ///   <item>1 - Weekly</item>
        ///   <item>2 - Monthly</item>
        ///   <item>3 - Yearly</item>
        /// </list>
        /// </summary>
        public abstract int? StaggerBy { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table 
        /// that indicates who the supervisor is for the generated
        /// works.
        /// </summary>
        public abstract Guid? SupervisorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the starting date/time of the
        /// first work.
        /// </summary>
        public abstract DateTime? FirstWorkStartDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the end date/time of the
        /// first work.
        /// </summary>
        public abstract DateTime? FirstWorkEndDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets how often the works should be repeated.
        /// This only specifies a value, and must be used together with
        /// FrequencyInterval to determine the number of 
        /// days/weeks/months/years.
        /// </summary>
        public abstract int? FrequencyCount { get; set; }

        /// <summary>
        /// [Column] Gets or sets unit (day/week/month/year) 
        /// the works should be repeated. This must be used together with
        /// FrequencyCount to determine the number of 
        /// days/weeks/months/years.  The default is months.
        /// <para></para>
        /// <list>
        ///   <item>0 - Day(s)</item>
        ///   <item>1 - Week(s)</item>
        ///   <item>2 - Month(s)</item>
        ///   <item>3 - Year(s)</item>
        /// </list>
        /// </summary>
        public abstract int? FrequencyInterval { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether
        /// the works generated is based on a floating schedule,
        /// or based on a fixed schedule.
        /// <para></para>
        /// <list>
        ///   <item>0 - Fixed schedule: all works are created
        /// based on a fixed date.</item>
        ///   <item>1 - Floating schedule: the next work is
        /// created after the previous is completed, and the
        /// next work's start date/time is based on the previous'
        /// completion date/time. Car servicing is an example
        /// of a floating schedule.</item>
        /// </list>
        /// </summary>
        public abstract int? IsFloating { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates how a weekly works
        /// are scheduled for subsequent works. This is applicable
        /// only if FrequencyInterval = 1 (weekly).
        /// <para></para>
        /// <list>
        ///   <item>0 - Same day as the day of the first work's start</item>
        ///   <item>1 - Specific days of the week as specified in the WeekTypeDay0 
        /// values.</item>
        /// </list>
        /// </summary>
        public abstract int? WeekType { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the next work can be scheduled on a Sunday.
        /// This is applicable only if FrequencyInterval = 1 (weekly)
        /// and WeekType = 1 (specific days of the week).
        /// </summary>
        public abstract int? WeekTypeDay0 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the next work can be scheduled on a Monday.
        /// This is applicable only if FrequencyInterval = 1 (weekly)
        /// and WeekType = 1 (specific days of the week).
        /// </summary>
        public abstract int? WeekTypeDay1 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the next work can be scheduled on a Tuesday.
        /// This is applicable only if FrequencyInterval = 1 (weekly)
        /// and WeekType = 1 (specific days of the week).
        /// </summary>
        public abstract int? WeekTypeDay2 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the next work can be scheduled on a Wednesday.
        /// This is applicable only if FrequencyInterval = 1 (weekly)
        /// and WeekType = 1 (specific days of the week).
        /// </summary>
        public abstract int? WeekTypeDay3 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the next work can be scheduled on a Thursday.
        /// This is applicable only if FrequencyInterval = 1 (weekly)
        /// and WeekType = 1 (specific days of the week).
        /// </summary>
        public abstract int? WeekTypeDay4 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the next work can be scheduled on a Friday.
        /// This is applicable only if FrequencyInterval = 1 (weekly)
        /// and WeekType = 1 (specific days of the week).
        /// </summary>
        public abstract int? WeekTypeDay5 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the next work can be scheduled on a Saturday.
        /// This is applicable only if FrequencyInterval = 1 (weekly)
        /// and WeekType = 1 (specific days of the week).
        /// </summary>
        public abstract int? WeekTypeDay6 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value to indicate how monthly works
        /// are scheduled for subsequent works. This is applicable
        /// only if FrequencyInterval = 2 (monthly).
        /// <para></para>
        /// <list>
        ///   <item>0 - Same date (as the date of the first work) every month</item>
        ///   <item>1 - Based on specific week/day of the month, as defined by the
        /// MonthTypeWeekNumber/MonthTypeDay values.</item>
        /// </list>
        /// </summary>
        public abstract int? MonthType { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates the week
        /// number to generate subsequent works for the monthly
        /// scheduling.  This is applicable only if 
        /// FrequencyInterval = 2 (monthly) and 
        /// MonthType = 1 (specific week/day)
        /// <para></para>
        /// <list>
        ///   <item>1 - First week of the month</item>
        ///   <item>2 - Second week of the month</item>
        ///   <item>3 - Third week of the month</item>
        ///   <item>4 - Fourth week of the month</item>
        ///   <item>5 - Last week of the month</item>
        /// </list>
        /// </summary>
        public abstract int? MonthTypeWeekNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates the
        /// day of the week to generate subsequent works for 
        /// monthly scheduling.
        /// <para></para>
        /// <list>
        ///   <item>0 - Sunday</item>
        ///   <item>1 - Monday</item>
        ///   <item>2 - Tuesday</item>
        ///   <item>3 - Wednesday</item>
        ///   <item>4 - Thursday</item>
        ///   <item>5 - Friday</item>
        ///   <item>6 - Saturday</item>
        /// </list>
        /// </summary>
        public abstract int? MonthTypeDay { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates 
        /// how the scheduling will end.
        /// <para></para>
        /// <list>
        ///   <item>0 - End when date of work reaches a specified end date</item>
        ///   <item>1 - End after a total number of cycles have been generated.</item>
        /// </list>
        /// </summary>
        public abstract int? IsScheduledByOccurrence { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time that works should
        /// not exceed. This is applicable only if IsScheduledByOccurrence = 0.
        /// </summary>
        public abstract DateTime? EndDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of occurrences / cycles of works
        /// that should be created. This is applicable only if 
        /// IsScheduledByOccurrence = 0.
        /// </summary>
        public abstract int? EndNumberOfOccurrences { get; set; }


        /// <summary>
        /// [Column] Gets or sets the foreign key to the Calendar table 
        /// that indicates the calendar that will be used to identify
        /// blocked dates (holidays, non-working days) during the
        /// scheduling of the work.
        /// </summary>
        public abstract Guid? CalendarID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates how
        /// to treat works that fall into the block dates specified
        /// by the calendar of this scheduled work.
        /// <para></para>
        /// <list>
        ///   <item>0 - Cancel work if there the work falls on a blocked date.</item>
        ///   <item>1 - Move work forward by one calendar day. (The scheduler will keep moving the work forward by 1 day until it is a non-blocked date)</item>
        ///   <item>2 - Move work backward by one calendar day. (The scheduler will keep moving the work backward by 1 day until it is a non-blocked date)</item>
        /// </list>
        /// </summary>
        public abstract int? CalendarBlockMethod { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates if this
        /// scheduled work is still generating work orders.
        /// </summary>
        public abstract int? SchedulerInProgress { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates the current
        /// scheduler checklist count. This value also indicates
        /// the number of cycles of works created so far.
        /// </summary>
        public abstract int? SchedulerChecklistCount { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates the next
        /// cycle's start date/time.
        /// </summary>
        public abstract DateTime? SchedulerStartDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates the next
        /// cycle's end date/time.
        /// </summary>
        public abstract DateTime? SchedulerEndDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether
        /// or not this Scheduled Work has entered the Created
        /// state.
        /// </summary>
        public abstract int? IsCreated { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether
        /// or not this Scheduled Work has entered the Cancelled
        /// state.
        /// </summary>
        public abstract int? IsCancelled { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether
        /// this Scheduled Work will create all fixed works at
        /// once.
        /// </summary>
        public abstract int? IsAllFixedWorksCreatedAtOnce { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of days to create
        /// the next cycle of works in advance, where the starting
        /// date of each cycle is the date the works are scheduled
        /// to start (if there is no staggering).
        /// <para></para>
        /// Note that works that are staggered from the start of a 
        /// cycle date will also be created, as long as they belong
        /// to the same cycle, even if they are scheduled
        /// to start later in time because of the staggering.
        /// </summary>
        public abstract int? NumberOfDaysInAdvanceToCreateFixedWorks { get; set; }

        /// <summary>
        /// Gets or sets the OEquipmentType object that represents the
        /// type of equipment that the works created by this scheduled
        /// work will be associated with. This is applicable only if
        /// EquipmentLocation = 0.
        /// </summary>
        public abstract OEquipmentType EquipmentType { get; set; }

        /// <summary>
        /// Gets or sets the OLocationType object that represents the
        /// type of location that the works created by this scheduled
        /// work will be associated with.
        /// </summary>
        public abstract OLocationType LocationType { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the supervisor
        /// who will be assigned to the works created by this scheduled
        /// work.
        /// </summary>
        public abstract OUser Supervisor { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents the type of
        /// work that the works created by this scheduled work will
        /// be associated with.
        /// </summary>
        public abstract OCode TypeOfWork { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents the type of
        /// service that the works created by this scheduled work will
        /// be associated with.
        /// </summary>
        public abstract OCode TypeOfService { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents the type of
        /// problem that the works created by this scheduled work will
        /// be associated with.
        /// </summary>
        public abstract OCode TypeOfProblem { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents the location
        /// that the works created by this scheduled work will
        /// be associated with.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets or sets the OEquipment object that represents the equipment
        /// that the works created by this scheduled work will
        /// be associated with. This is applicable only if
        /// EquipmentLocation = 0.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OWork objects that represents the
        /// list of works created by this scheduled work.
        /// </summary>
        public abstract DataList<OWork> Works { get; set; }

        /// <summary>
        /// Gets or sets the OContract object that represents the term
        /// contract that the works created by this scheduled work 
        /// will be associated with.
        /// </summary>
        public abstract OContract Contract { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OScheduledWorkStaggeredEquipment objects 
        /// that represents information about how the works for the equipment
        /// will be staggered. This is applicable only if EquipmentLocation = 0
        /// and if IsStaggered = 1.
        /// </summary>
        public abstract DataList<OScheduledWorkStaggeredEquipment> ScheduledWorkStaggeredEquipment { get; }

        /// <summary>
        /// Gets a one-to-many list of OScheduledWorkStaggeredLocation objects 
        /// that represents information about how the works for the location
        /// will be staggered. This is applicable only if IsStaggered = 1;
        /// </summary>
        public abstract DataList<OScheduledWorkStaggeredLocation> ScheduledWorkStaggeredLocation { get; }

        /// <summary>
        /// Gets a one-to-many list of ScheduledWorkCost objects 
        /// that represents cost that the works created by this scheduled work
        /// will be associated with.
        /// </summary>
        public abstract DataList<OScheduledWorkCost> ScheduledWorkCost { get; }

        /// <summary>
        /// Gets a one-to-many list of ScheduledWorkCost objects 
        /// that represents information about the sequencing of checklists
        /// that the works created by this scheduled will be associated
        /// with.
        /// </summary>
        public abstract DataList<OScheduledWorkChecklist> ScheduledWorkChecklist { get; }

        ///// <summary>
        ///// Gets a one-to-many list of OEquipmentTypeParameter objects that
        ///// represents the equipment type parameters that the works
        ///// created by this scheduled work will be associated with.
        ///// </summary>
        //public abstract DataList<OEquipmentTypeParameter> ScheduledWorkEquipmentTypeParameters { get; }

        ///// <summary>
        ///// Gets a one-to-many list of OLocationTypeParameter objects that
        ///// represents the location type parameters that the works
        ///// created by this scheduled work will be associated with.
        ///// </summary>
        //public abstract DataList<OLocationTypeParameter> ScheduledWorkLocationTypeParameters { get; }

        /// <summary>
        /// Gets a one-to-many list of OEquipment objects that represents
        /// the list of equipment that the works created by this 
        /// scheduled work will be associated with. This is applicable
        /// only if IsStaggered = 0.
        /// </summary>
        public abstract DataList<OEquipment> ScheduledWorkEquipment { get; }

        /// <summary>
        /// Gets a one-to-many list of OLocation objects that represents
        /// the list of location that the works created by this 
        /// scheduled work will be associated with. This is applicable
        /// only if IsStaggered = 0.
        /// </summary>
        public abstract DataList<OLocation> ScheduledWorkLocation { get; }

        /// <summary>
        /// Gets or sets the OCalendar object that represents
        /// the calendar that will be used to identify
        /// blocked dates (holidays, non-working days) during the
        /// scheduling of the work.
        /// </summary>
        public abstract OCalendar Calendar { get; set; }


        /// <summary>
        /// Gets the location associated with this scheduled work.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> taskLocations = new List<OLocation>();
                if (this.Location != null)
                    taskLocations.Add(this.Location);
                return taskLocations;
            }
        }


        /// <summary>
        /// Gets the equipment associated with this scheduled work.
        /// </summary>
        public override List<OEquipment> TaskEquipments
        {
            get
            {
                List<OEquipment> taskEquipments = new List<OEquipment>();
                if (this.Equipment != null)
                    taskEquipments.Add(this.Equipment);
                return taskEquipments;
            }
        }


        /// <summary>
        /// Gets the task amount associated with this scheduled work.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                decimal estimatedTotal = 0;
                foreach (OScheduledWorkCost workCost in this.ScheduledWorkCost)
                {
                    estimatedTotal += workCost.EstimatedSubTotal != null ? (decimal)workCost.EstimatedSubTotal : 0;
                }
                return estimatedTotal;
            }
        }



        // 2010.04.21
        /// <summary>
        /// Gets the type of service associated with this scheduled work.
        /// </summary>
        public override OCode TaskTypeOfService
        {
            get
            {
                return this.TypeOfService;
            }
        }


        /// <summary>
        /// Initializes the number of days to create fixed
        /// works.
        /// </summary>
        public override void Created()
        {
            base.Created();

            if (this.IsNew)
            {
                this.NumberOfDaysInAdvanceToCreateFixedWorks = OApplicationSetting.Current.DefaultNumberOfDaysInAdvanceToCreateFixedWorks;
                this.TypeOfWorkID = OApplicationSetting.Current.DefaultScheduledWorkTypeOfWorkID;
            }
        }


        /// <summary>
        /// Occurs before the object is saved into the database.
        /// </summary>
        public override void Saving()
        {
            base.Saving();
            this.ObjectName = this.WorkDescription;
        }

        
        /// <summary>
        /// Check if the work cost entered is a duplicate work cost.
        /// Returns true if so, false otherwise.
        /// </summary>
        /// <param name="workCost"></param>
        public bool IsDuplicateWorkCost(OScheduledWorkCost scheduledWorkCost)
        {
            foreach (OScheduledWorkCost w in this.ScheduledWorkCost)
            {
                if (w.ObjectID.Equals(scheduledWorkCost.ObjectID))
                    continue;

                if (scheduledWorkCost.CostType == WorkCostType.Technician && w.CostType == WorkCostType.Technician)
                {
                    if (w.UserID.Equals(scheduledWorkCost.UserID))
                        return true;
                }
                if (scheduledWorkCost.CostType == WorkCostType.FixedRate && w.CostType == WorkCostType.FixedRate)
                {
                    if (w.FixedRateID.Equals(scheduledWorkCost.FixedRateID))
                        return true;
                }
                else if (scheduledWorkCost.CostType == WorkCostType.AdhocRate && w.CostType == WorkCostType.AdhocRate)
                {
                    if (w.ObjectName.Equals(scheduledWorkCost.ObjectName))
                        return true;
                }
                else if (scheduledWorkCost.CostType == WorkCostType.Material && w.CostType == WorkCostType.Material)
                {
                    if (w.StoreBinID==null && scheduledWorkCost.StoreBinID==null &&
                        w.StoreID == null && scheduledWorkCost.StoreID == null &&
                        w.CatalogueID.Equals(scheduledWorkCost.CatalogueID))
                        return true;

                    if (w.StoreBinID == null && scheduledWorkCost.StoreBinID == null &&
                        w.StoreID != null && w.StoreID.Equals(scheduledWorkCost.StoreID) &&
                        w.CatalogueID.Equals(scheduledWorkCost.CatalogueID))
                        return true;

                    if (w.StoreBinID != null && w.StoreBinID.Equals(scheduledWorkCost.StoreBinID) &&
                        w.StoreID != null && w.StoreID.Equals(scheduledWorkCost.StoreID) &&
                        w.CatalogueID.Equals(scheduledWorkCost.CatalogueID))
                        return true;
                }
            }

            return false;
        }


        /// <summary>
        /// When deactivating or cancelling this schedule, deactivate
        /// all works below it as well. 
        /// 
        /// Note that only works without an actual end date (completion
        /// date) will be deactivated.
        /// </summary>
        public override void Deactivating()
        {
            base.Deactivating();

            DeactivateAllWorks();
        }


        /// <summary>
        /// Reorders the cycle numbers for the checklist items.
        /// </summary>
        /// <param name="obj"></param>
        public void ReorderChecklistSequence(PersistentObject obj)
        {
            Global.ReorderItems(ScheduledWorkChecklist, obj, "CycleNumber");
        }


        /// <summary>
        /// Deactivates and cancels all works attached to this scheduled 
        /// work.
        /// </summary>
        public void DeactivateAllWorks()
        {
            foreach (OWork work in this.Works)
            {
                if (work.ActualEndDateTime == null)
                    work.Deactivate();
            }
        }


        /// <summary>
        /// Cancels the scheduled work and deactivates all works.
        /// </summary>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                if (this.IsCancelled != 1)
                {
                    this.IsCancelled = 1;
                    this.SchedulerInProgress = 0;
                    this.DeactivateAllWorks();
                    this.Save();
                }

                c.Commit();
            }
        }


        /// <summary>
        /// Creates a list of staggered equipment and location.
        /// 
        /// Any previous list will be cleared.
        /// </summary>
        public void CreateStaggeredEquipmentLocation()
        {
            List<OEquipment> equipmentList = null;
            List<OLocation> locationList = null;

            this.ScheduledWorkStaggeredEquipment.Clear();
            this.ScheduledWorkStaggeredLocation.Clear();

            if (this.EquipmentLocation == 0)
            {
                // schedule for equipment
                //
                if (this.Equipment != null)
                    equipmentList = this.Equipment.GetEquipmentByEquipmentType(this.EquipmentType);
                else if (this.Location != null)
                    equipmentList = this.Location.GetEquipmentByEquipmentType(this.EquipmentType);
            }
            else if (this.EquipmentLocation == 1)
            {
                // schedule for location
                //
                if (this.Location != null)
                    locationList = this.Location.GetLocationByLocationType(this.LocationType);
            }

            if (equipmentList != null)
            {
                foreach (OEquipment equipment in equipmentList)
                {
                    OScheduledWorkStaggeredEquipment s = TablesLogic.tScheduledWorStaggeredEquipment.Create();
                    s.Equipment = equipment;
                    s.UnitsToStagger = null;
                    this.ScheduledWorkStaggeredEquipment.Add(s);
                }
            }

            if (locationList != null)
            {
                foreach (OLocation location in locationList)
                {
                    OScheduledWorkStaggeredLocation s = TablesLogic.tScheduledWorkStaggeredLocation.Create();
                    s.Location = location;
                    s.UnitsToStagger = null;
                    this.ScheduledWorkStaggeredLocation.Add(s);
                }
            }

        }


        /// <summary>
        /// Sets up the scheduled work so that the scheduler service
        /// can create the works for the next cycle.
        /// </summary>
        public void CreateWorksBySchedulerService()
        {
            using (Connection c = new Connection())
            {
                if (this.IsCreated != 1)
                {
                    this.IsCreated = 1;
                    this.SchedulerInProgress = 1;
                    this.SchedulerStartDateTime = this.FirstWorkStartDateTime;
                    this.SchedulerEndDateTime = this.FirstWorkEndDateTime;
                    this.SchedulerChecklistCount = 0;

                    this.Save();
                }
                c.Commit();
            }
        }


        /// <summary>
        /// Creates a set of works for the next cycle. This method
        /// is called by the scheduler service.
        /// </summary>
        public void CreateWorksForNextCycle(string eventToTriggerForWork)
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
                        // kf begin: bug fix to ignore those whose units to stagger = N/A
                        foreach (OScheduledWorkStaggeredEquipment o in this.ScheduledWorkStaggeredEquipment)
                        {
                            if (o.UnitsToStagger != null)
                                stagger.Add(new StaggerProperty(o.EquipmentID.Value, o.Equipment.ObjectName, o.UnitsToStagger.Value));
                        }
                    // kf end
                    else
                        foreach (OEquipment o in this.ScheduledWorkEquipment)
                            stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
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
                    work.NotifyWorkTechnician = 1;

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
                        work.LocationID = TablesLogic.tEquipment[o.staggerId].LocationID;
                        work.EquipmentID = o.staggerId;
                    }
                    else
                        work.LocationID = o.staggerId;

                    if (this.IsScheduledByOccurrence != 0 ||
                        work.ScheduledStartDateTime.Value <= this.EndDateTime.Value)
                    {
                        this.Works.Add(work);

                        work.Save();
                        work.TriggerWorkflowEvent(eventToTriggerForWork);
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
        /// Create all work orders, based on the scheduled work's 
        /// parameters.
        /// </summary>
        /// --------------------------------------------------------------
        public void CreateWorks(string newWorkState)
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
                        // kf begin: bug fix to ignore those whose units to stagger = N/A
                        foreach (OScheduledWorkStaggeredEquipment o in this.ScheduledWorkStaggeredEquipment)
                        {
                            if( o.UnitsToStagger!=null )
                                stagger.Add(new StaggerProperty(o.EquipmentID.Value, o.Equipment.ObjectName, o.UnitsToStagger.Value));
                        }
                        // kf end
                    else
                        foreach (OEquipment o in this.ScheduledWorkEquipment)
                            stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
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
                            work.LocationID = TablesLogic.tEquipment[o.staggerId].LocationID;
                            work.EquipmentID = o.staggerId;
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

        /// --------------------------------------------------------------
        /// <summary>
        /// Pretend Create all work orders, based on the scheduled work's 
        /// parameters.
        /// </summary>
        /// --------------------------------------------------------------
        public List<WorkDummy> PretendCreateWorks()
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
                    // kf begin: bug fix to ignore those whose units to stagger = N/A
                    foreach (OScheduledWorkStaggeredEquipment o in this.ScheduledWorkStaggeredEquipment)
                    {
                        if (o.UnitsToStagger != null)
                            stagger.Add(new StaggerProperty(o.EquipmentID.Value, o.Equipment.ObjectName, o.UnitsToStagger.Value));
                    }
                // kf end
                else
                    foreach (OEquipment o in this.ScheduledWorkEquipment)
                        stagger.Add(new StaggerProperty(o.ObjectID.Value, o.ObjectName, 0));
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

            // Compile a hashtable of locations and equipment
            //
            Hashtable hashLocationPath = new Hashtable();
            Hashtable hashEquipmentPath = new Hashtable();
            List<Guid> ids = new List<Guid>();
            IEnumerable locationsOrEquipment = null;
            foreach (StaggerProperty o in stagger)
                ids.Add(o.staggerId);
            if (this.EquipmentLocation == 0)
                locationsOrEquipment = TablesLogic.tEquipment.LoadList(TablesLogic.tEquipment.ObjectID.In(ids));
            else
                locationsOrEquipment = TablesLogic.tLocation.LoadList(TablesLogic.tLocation.ObjectID.In(ids));
            foreach (PersistentObject obj in locationsOrEquipment)
            {
                if(obj is OLocation)
                    hashLocationPath[obj.ObjectID.Value] = ((OLocation)obj).Path;
                if (obj is OEquipment)
                {
                    hashEquipmentPath[obj.ObjectID.Value] = ((OEquipment)obj).Path;
                    hashLocationPath[obj.ObjectID.Value] = ((OEquipment)obj).Location.Path;
                }
            }

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
                string checklistName="";
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
                        //work.Equipment= TablesLogic.tEquipment[o.staggerId];
                        work.EquipmentPath = hashEquipmentPath[o.staggerId] as string;
                        work.LocationPath = hashLocationPath[o.staggerId] as string;
                    }
                    else
                    {
                        //work.Location = TablesLogic.tLocation[o.staggerId];
                        work.EquipmentPath = "";
                        work.LocationPath = hashLocationPath[o.staggerId] as string;
                    }

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


        /// --------------------------------------------------------------
        /// <summary>
        /// Get a data table of all the works currently attached to
        /// this scheduled work.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public DataTable GetWorksDataTable()
        {
            // the column names are translated in the gantt chart using strings.resx
            //
            return (DataTable)Query.Select(
                TablesLogic.tWork.ObjectNumber.As("Gantt_WorkNumber"),
                TablesLogic.tWork.ScheduledStartDateTime.As("Gantt_ScheduledStartDateTime"),
                TablesLogic.tWork.ScheduledEndDateTime.As("Gantt_ScheduledEndDateTime"),
                TablesLogic.tWork.Priority.As("Gantt_Priority"),
                TablesLogic.tWork.TypeOfWork.ObjectName.As("Gantt_TypeOfWork"),
                TablesLogic.tWork.TypeOfService.ObjectName.As("Gantt_TypeOfService"),
                TablesLogic.tWork.TypeOfProblem.ObjectName.As("Gantt_TypeOfProblem"),
                TablesLogic.tWork.Location.ObjectName.As("Gantt_Location"),
                TablesLogic.tWork.Equipment.ObjectName.As("Gantt_Equipment"),
                TablesLogic.tWork.Checklist.ObjectName.As("Gantt_ChecklistName"),
                TablesLogic.tWork.PercentageComplete.As("Gantt_PercentageComplete"),
                TablesLogic.tWork.WorkDescription.As("Gantt_WorkDescription"),
                TablesLogic.tWork.Contract.ObjectName.As("Gantt_Contract"),
                TablesLogic.tWork.Contract.Vendor.ObjectName.As("Gantt_Vendor"),
                TablesLogic.tWork.CurrentActivity.ObjectName.As("Gantt_Status"))

                .Where(
                TablesLogic.tWork.ScheduledWorkID == this.ObjectID.Value &
                TablesLogic.tWork.IsDeleted == 0);

        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Validates that at least one stagger equipment is selected.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ValidateStaggerEquipmentSelected()
        {
            if (this.IsStaggered != 1 || this.EquipmentLocation != 0)
                return true;

            foreach (OScheduledWorkStaggeredEquipment o in ScheduledWorkStaggeredEquipment)
                if (o.UnitsToStagger != null)
                    return true;
            return false;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Validates that at least one stagger location is selected.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ValidateStaggerLocationSelected()
        {
            if (this.IsStaggered != 1 || this.EquipmentLocation != 1)
                return true;

            foreach (OScheduledWorkStaggeredLocation o in ScheduledWorkStaggeredLocation)
                if (o.UnitsToStagger != null)
                    return true;
            return false;
        }
    }


    /// --------------------------------------------------------------
    /// <summary>
    /// For stagger sorting.
    /// </summary>
    /// --------------------------------------------------------------
    public class StaggerProperty
    {
        public Guid staggerId;
        public string staggerName;
        public int staggerValue;

        public StaggerProperty(Guid id, string n, int v)
        {
            staggerId = id;
            staggerName = n;
            staggerValue = v;
        }
    }


    /// --------------------------------------------------------------
    /// <summary>
    /// Comparator class that implements the sorting.
    /// </summary>
    /// --------------------------------------------------------------
    public class StaggerPropertyComparer : IComparer<StaggerProperty>
    {

        public int Compare(StaggerProperty x, StaggerProperty y)
        {
            if (x.staggerValue - y.staggerValue != 0)
                return x.staggerValue - y.staggerValue;
            else
                return x.staggerName.CompareTo(y.staggerName);
        }
    }

    public class WorkDummy
    {
        public OLocation Location { get; set; }
        public OEquipment Equipment { get; set; }

        public string LocationPath { get; set; }
        public string EquipmentPath { get; set; }
        
        public string Checklist { get; set; }
        public int? Priority { get; set; }
        public string WorkDescription { get; set; }

        public int? SchedulerCounter { get; set; }

        public DateTime ScheduledStartDateTime { get; set; }
        public DateTime ScheduledEndDateTime { get; set; }

        public Guid? ScheduledWorkID { get; set; }        
        
    }

}


