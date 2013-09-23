//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OVendor
    /// </summary>
    [Database("#database"), Map("Work")]
    public partial class TWork : LogicLayerSchema<OWork>
    {
        public SchemaGuid CaseID;
        public SchemaGuid CallerTypeID;
        public SchemaGuid CallerID;
        public SchemaString CallerName;
        public SchemaString CallerPhone;
        public SchemaString CallerCellPhone;
        public SchemaString CallerEmail;
        public SchemaString CallerFax;

        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        public SchemaGuid ChecklistID;
        [Size(255)]
        public SchemaInt Priority;
        [Size(255)]
        public SchemaString WorkDescription;
        public SchemaGuid TypeOfWorkID;
        public SchemaGuid TypeOfServiceID;
        public SchemaGuid TypeOfProblemID;
        public SchemaGuid SupervisorID;
        public SchemaGuid ApproverID;

        public SchemaDateTime ScheduledStartDateTime;
        public SchemaDateTime ScheduledEndDateTime;
        public SchemaDateTime ActualStartDateTime;
        public SchemaDateTime ActualEndDateTime;
        [Size(255)]
        public SchemaString ResolutionDescription;
        public SchemaGuid CauseOfProblemID;
        public SchemaGuid ResolutionID;
        public SchemaInt PercentageComplete;
        public SchemaGuid ContractID;
        [Default(0)]
        public SchemaInt IsChargedToCaller;
        public SchemaInt IsEquipmentDown;
        public SchemaDateTime EquipmentDownStartDateTime;
        public SchemaDateTime EquipmentDownEndDateTime;

        public SchemaDateTime AcknowledgementDateTime;
        public SchemaDateTime AcknowledgementDateTimeLimit;
        public SchemaDateTime ArrivalDateTime;
        public SchemaDateTime ArrivalDateTimeLimit;
        public SchemaDateTime CompletionDateTime;
        public SchemaDateTime CompletionDateTimeLimit;

        public SchemaInt SchedulerCounter;
        public SchemaGuid ScheduledWorkID;

        public SchemaGuid GeneratedByPointID;
        public SchemaGuid GeneratedByReadingID;

        public SchemaGuid GeneratedByOPCAEEventID;
        public SchemaGuid GeneratedByOPCAEEventHistoryID;

        public SchemaImage UsageSignature;
        public SchemaImage AcceptSignature;

        public TCase Case { get { return OneToOne<TCase>("CaseID"); } }

        public TCode TypeOfWork { get { return OneToOne<TCode>("TypeOfWorkID"); } }

        public TCode TypeOfService { get { return OneToOne<TCode>("TypeOfServiceID"); } }

        public TCode TypeOfProblem { get { return OneToOne<TCode>("TypeOfProblemID"); } }

        public TCode CauseOfProblem { get { return OneToOne<TCode>("CauseOfProblemID"); } }

        public TCode Resolution { get { return OneToOne<TCode>("ResolutionID"); } }

        public TCode CallerType { get { return OneToOne<TCode>("CallerTypeID"); } }

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }

        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }

        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }

        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }

        public TUser Supervisor { get { return OneToOne<TUser>("SupervisorID"); } }

        public TUser Approver { get { return OneToOne<TUser>("ApproverID"); } }

        public TWorkCost WorkCost { get { return OneToMany<TWorkCost>("WorkID"); } }

        public TWorkChecklistItem WorkChecklistItems { get { return OneToMany<TWorkChecklistItem>("WorkID"); } }

        public TWorkParameterReading WorkParameterReadings { get { return OneToMany<TWorkParameterReading>("WorkID"); } }

        public TReading WorkPointReadings { get { return OneToMany<TReading>("WorkID"); } }

        public TScheduledWork ScheduledWork { get { return OneToOne<TScheduledWork>("ScheduledWorkID"); } }

        public TWork Parent { get { return OneToOne<TWork>("ParentID"); } }

        public TWork Children { get { return OneToMany<TWork>("ParentID"); } }

        public TUser Caller { get { return OneToOne<TUser>("CallerID"); } }
    }

    /// <summary>
    /// Represents a work object, or a work instruction used to instruct an
    /// in-house team of maintenance staff or external contractors to carry
    /// out repair works and routine maintenance works.
    /// <para></para>
    /// It should be noted that all work objects are never associated with
    /// any costs outlay that the company has to bear. All costs associated
    /// with this work are indirect and are paid by other means. For example,
    /// costs of maintenance contractors are paid through upfront warranty
    /// or insurance-type of contracts; costs of in-house maintenance staff
    /// are paid through their regular salary; costs of materials are paid
    /// through purchase into stores.
    /// <para></para>
    /// Thus, costs associated with this work are considered costs of
    /// maintenance, and are not directly payable through the finance..
    /// </summary>
    public abstract partial class OWork : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled, INotificationEnabled
    {
        public abstract Guid? CaseID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates the type of caller.
        /// </summary>
        public abstract Guid? CallerTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table
        /// that indicates the user who called to request for this
        /// work.
        /// </summary>
        public abstract Guid? CallerID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name of the caller. When
        /// selected the caller in the user interface, this field
        /// gets automatically populated with the same field from
        /// the user record.
        /// </summary>
        public abstract String CallerName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact of the caller. When
        /// selected the caller in the user interface, this field
        /// gets automatically populated with the same field from
        /// the user record.
        /// </summary>
        public abstract String CallerPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact of the caller. When
        /// selected the caller in the user interface, this field
        /// gets automatically populated with the same field from
        /// the user record.
        /// </summary>
        public abstract String CallerCellPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact of the caller. When
        /// selected the caller in the user interface, this field
        /// gets automatically populated with the same field from
        /// the user record.
        /// </summary>
        public abstract String CallerEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact of the caller. When
        /// selected the caller in the user interface, this field
        /// gets automatically populated with the same field from
        /// the user record.
        /// </summary>
        public abstract String CallerFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table
        /// that indicates the location this work is associated with.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Equipment table
        /// that indicates the equipment this work is associated with.
        /// If this value is not null, then the LocationID must
        /// be the same as the equipment's LocationID at the time
        /// this work is created.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Checklist table
        /// that indicates the checklist that is attached to this work.
        /// </summary>
        public abstract Guid? ChecklistID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value to indicate the priority
        /// of this work. The higher the number, the higher the priority.
        /// </summary>
        public abstract int? Priority { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of the work.
        /// </summary>
        public abstract String WorkDescription { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates the type of work this work is classified
        /// under.
        /// <para></para>
        /// Type of work usually refers to a broad classification
        /// like corrective maintenance, preventive maintenance, etc.
        /// </summary>
        public abstract Guid? TypeOfWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates the type of service this work is
        /// classified under.
        /// <para></para>
        /// Type of service usually refers to a
        /// broad classification of nature of the problem, for
        /// example: Lighting; Electrical; Mechanical; Escalator;
        /// Lift, etc.
        /// </summary>
        public abstract Guid? TypeOfServiceID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates the type of problem this work is
        /// classified under.
        /// <para></para>
        /// Type of problem usually refers to a
        /// detailed classification of nature of the problem related
        /// to the type of service, for example, where type of service
        /// is Light, type of problem can be one of the following:
        /// Light bulb blown; Lights flickering; whereas under Lifts,
        /// the type of problem can be one of the following:
        /// Lift door jammed; lift broken down; lift buttons
        /// malfunctioning; etc.
        /// </summary>
        public abstract Guid? TypeOfProblemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table
        /// that indicates the user who will be responsible for
        /// overseeing the progress of the work, and closing it
        /// as well.
        /// </summary>
        public abstract Guid? SupervisorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table
        /// that indicates the user who will be responsible for
        /// approving the work, if the estimated cost of the work
        /// goes beyond the 'work cost limit' of the supervisor of
        /// this work.
        /// <para></para>
        /// Note that in the default Anacle.EAM the work can only
        /// be submitted for approval only if it goes into planning
        /// stage, and the total estimated cost of work exceeds the
        /// supervisor's work cost limit.
        /// </summary>
        public abstract Guid? ApproverID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time this work is
        /// scheduled to start.
        /// </summary>
        public abstract DateTime? ScheduledStartDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time this work is
        /// scheduled to end.
        /// </summary>
        public abstract DateTime? ScheduledEndDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the actual starting date/time this work.
        /// </summary>
        public abstract DateTime? ActualStartDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the actual end date/time this work.
        /// </summary>
        public abstract DateTime? ActualEndDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets a description on how the problem
        /// was resolved.
        /// </summary>
        public abstract String ResolutionDescription { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates cause of the problem this work is classified
        /// under.
        /// <para></para>
        /// The cause of problem refers to the classification of the
        /// diagnosis related to the type of problem. For example,
        /// if the type of problem as 'Lighting not working,' the
        /// cause of problem could be due to one of the following:
        /// Power Failure, Lighting Bulb Blown, Power Not Turned On.
        /// </summary>
        public abstract Guid? CauseOfProblemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that indicates the resolution to the problem this work is
        /// classified under.
        /// <para></para>
        /// The resolution refers to the classification of the
        /// action taken to fix the problem. For example,
        /// if the type of problem as 'Power Failure,' the
        /// resolution could one of the following: Reset Fuse,
        /// Reset Generator, Contacted Power Company, etc.
        /// </summary>
        public abstract Guid? ResolutionID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates how
        /// much of the work is complete (in percentage).
        /// </summary>
        public abstract int? PercentageComplete { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Contract table
        /// that indicates the contract that this work is associated with.
        /// </summary>
        public abstract Guid? ContractID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether this work
        /// should be charged to the caller. This is normally used in
        /// tenant / landlord scenarios where works to a unit
        /// may incur a charge that can be recovered from the tenant.
        /// <para></para>
        /// <list>
        ///   <item>0 - No, this work will not be charged to the caller.</item>
        ///   <item>1 - Yes, this work will be charged to the caller.</item>
        /// </list>
        /// </summary>
        public abstract int? IsChargedToCaller { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether the equipment'
        /// associated with the work was shut down or out of operation during
        /// the duration of the work. This allows us to track the down time
        /// of the equipment.
        /// <para></para>
        /// <list>
        ///   <item>0 - No, the equipment was not shut down or out of operation.</item>
        ///   <item>1 - Yes, the equipment was shut down or out of operation.</item>
        /// </list>
        /// </summary>
        public abstract int? IsEquipmentDown { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Point
        /// table that represents the breached point that generated
        /// this work.
        /// </summary>
        public abstract Guid? GeneratedByPointID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Reading
        /// table that represents the reading that breached
        /// the point that generated this work.
        /// </summary>
        public abstract Guid? GeneratedByReadingID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the OPCAEEvent
        /// table that represents the event trigger that generated this work.
        /// </summary>
        public abstract Guid? GeneratedByOPCAEEventID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the OPCAEEventHitosyr
        /// table that represents the event history that generated this work.
        /// </summary>
        public abstract Guid? GeneratedByOPCAEEventHistoryID { get; set; }

        public abstract Byte[] UsageSignature { get; set; }

        public abstract Byte[] AcceptSignature { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time the equipment that was shut
        /// down or out of operation. This is applicable only if
        /// IsEquipmentDown = 1.
        /// </summary>
        public abstract DateTime? EquipmentDownStartDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time the equipment that brought
        /// back up into operation. This is applicable only if IsEquipmentDown = 1.
        /// </summary>
        public abstract DateTime? EquipmentDownEndDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time this work was acknowledged.
        /// Note in the default Anacle.EAM, that the acknowledgement date/time
        /// can be set by a user who has access to this work during the
        /// work in progress and pending closure statuses.
        /// </summary>
        public abstract DateTime? AcknowledgementDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time this work must be acknowledged
        /// by, before the work is considered to have failed the service
        /// level limit for acknowledgement.
        /// </summary>
        public abstract DateTime? AcknowledgementDateTimeLimit { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time the contractor or in-house
        /// maintenance team arrived on-site.
        /// Note in the default Anacle.EAM, that the arrival date/time
        /// can be set by a user who has access to this work during the
        /// work in progress and pending closure statuses.
        /// </summary>
        public abstract DateTime? ArrivalDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time this work the contractor
        /// or in-house maintenance team must arrive on-site.
        /// by, before the work is considered to have failed the service
        /// level limit for arrival.
        /// </summary>
        public abstract DateTime? ArrivalDateTimeLimit { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time this work was completed.
        /// Note in the default Anacle.EAM, that the completion date/time
        /// can be set by a user who has access to this work during the
        /// work in progress and pending closure statuses.
        /// </summary>
        public abstract DateTime? CompletionDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time this work must be completed.
        /// by, before the work is considered to have failed the service
        /// level limit for completion.
        /// </summary>
        public abstract DateTime? CompletionDateTimeLimit { get; set; }

        /// <summary>
        /// Gets or sets the reference to the OCase object
        /// that represents the case this purchase order
        /// is associated with.
        /// </summary>
        public abstract OCase Case { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents the
        /// type of work this work is classified under.
        /// <para></para>
        /// Type of work usually refers to a broad classification
        /// like corrective maintenance, preventive maintenance, etc.
        /// </summary>
        public abstract OCode TypeOfWork { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents the type of service this work is
        /// classified under.
        /// <para></para>
        /// Type of service usually refers to a
        /// broad classification of nature of the problem, for
        /// example: Lighting; Electrical; Mechanical; Escalator;
        /// Lift, etc.
        /// </summary>
        public abstract OCode TypeOfService { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the type of problem this work is
        /// classified under.
        /// <para></para>
        /// Type of problem usually refers to a
        /// detailed classification of nature of the problem related
        /// to the type of service, for example, where type of service
        /// is Light, type of problem can be one of the following:
        /// Light bulb blown; Lights flickering; whereas under Lifts,
        /// the type of problem can be one of the following:
        /// Lift door jammed; lift broken down; lift buttons
        /// malfunctioning; etc.
        /// </summary>
        public abstract OCode TypeOfProblem { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the problem this work is classified
        /// under.
        /// <para></para>
        /// The cause of problem refers to the classification of the
        /// diagnosis related to the type of problem. For example,
        /// if the type of problem as 'Lighting not working,' the
        /// cause of problem could be due to one of the following:
        /// Power Failure, Lighting Bulb Blown, Power Not Turned On.
        /// </summary>
        public abstract OCode CauseOfProblem { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the resolution to the problem this work is
        /// classified under.
        /// <para></para>
        /// The resolution refers to the classification of the
        /// action taken to fix the problem. For example,
        /// if the type of problem as 'Power Failure,' the
        /// resolution could one of the following: Reset Fuse,
        /// Reset Generator, Contacted Power Company, etc.
        /// </summary>
        public abstract OCode Resolution { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents the type of the caller
        /// Caller type can be Internal or External Or Resident
        /// </summary>
        public abstract OCode CallerType { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the user who will be responsible for
        /// overseeing the progress of the work, and closing it
        /// as well.
        /// </summary>
        public abstract OUser Supervisor { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the user who will be responsible for
        /// approving the work, if the estimated cost of the work
        /// goes beyond the 'work cost limit' of the supervisor of
        /// this work.
        /// <para></para>
        /// Note that in the default Anacle.EAM the work can only
        /// be submitted for approval only if it goes into planning
        /// stage, and the total estimated cost of work exceeds the
        /// supervisor's work cost limit.
        /// </summary>
        public abstract OUser Approver { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents the location
        /// this work is associated with.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents the equipment
        /// this work is associated with.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the checklist that is attached to this work.
        /// </summary>
        public abstract OChecklist Checklist { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// the contract that this work is associated with.
        /// </summary>
        public abstract OContract Contract { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates
        /// the cycle number of this work, with reference to the
        /// scheduled work object that generated this work.
        /// <para></para>
        /// This is useful to determine the checklist to use
        /// a floating schedule where the works are generated
        /// only when the previous work is completed.
        /// </summary>
        public abstract int? SchedulerCounter { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the ? table
        /// that indicates the scheduled work that generated this
        /// work. This value is non null only if this work
        /// was generated from a scheduled work.
        /// </summary>
        public abstract Guid? ScheduledWorkID { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OWorkCost objects that represents
        /// a list of maintenance costs that this work will incur or
        /// has incurred.
        /// </summary>
        public abstract DataList<OWorkCost> WorkCost { get; }

        /// <summary>
        /// Gets a one-to-many list of OWorkChecklistItem objects that represents
        /// a list of checklist steps (either actions or inspections) that the
        /// contractor or personnel assigned to the work is expected to perform.
        /// </summary>
        public abstract DataList<OWorkChecklistItem> WorkChecklistItems { get; }

        /// <summary>
        /// Gets a one-to-many list of OWorkParameterReading objects that represents
        /// parameters readings that the contractor or personnel assigned to the
        /// work is expected to perform.
        /// </summary>
        public abstract DataList<OWorkParameterReading> WorkParameterReadings { get; }

        public abstract DataList<OReading> WorkPointReadings { get; }

        /// <summary>
        /// Gets or sets the OScheduledWork object that represents
        /// the scheduled work that generated this
        /// work. This value is non null only if this work
        /// was generated from a scheduled work.
        /// </summary>
        public abstract OScheduledWork ScheduledWork { get; set; }

        /// <summary>
        /// Gets or sets the OWork object that represents
        /// the parent work object that this current work is
        /// related to.
        /// </summary>
        public abstract OWork Parent { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OWork objects that represents
        /// a list of works that this current work is related to.
        /// </summary>
        public abstract DataList<OWork> Children { get; }

        /// <summary>
        /// Gets or sets the OUser object that represents the user
        /// the user who called to request for this
        /// work.
        /// </summary>
        public abstract OUser Caller { get; set; }

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

        /*
        public override decimal TaskAmount
        {
            get
            {
                decimal estimatedTotal = 0;
                foreach (OWorkCost workCost in this.WorkCost)
                {
                    estimatedTotal += workCost.EstimatedSubTotal != null ? (decimal)workCost.EstimatedSubTotal : 0;
                }
                return estimatedTotal;
            }
        }
        */

        // 2010.04.21
        /// <summary>
        /// Gets the type of service associated with this work.
        /// </summary>
        public override OCode TaskTypeOfService
        {
            get
            {
                return this.TypeOfService;
            }
        }

        /// <summary>
        ///
        /// </summary>
        public void AcknowledgeWork()
        {
            if (this.ArrivalDateTime != null)
                throw new Exception("Work_ArrivedBeforeAck");
            if (this.AcknowledgementDateTime != null)
                throw new Exception("Work_AlreadyAcknowledged");

            using (Connection c = new Connection())
            {
                this.AcknowledgementDateTime = DateTime.Now;
                this.Save();

                c.Commit();
            }
        }

        /// <summary>
        ///
        /// </summary>
        public void ArriveWork()
        {
            if (this.ArrivalDateTime != null)
                throw new Exception("Work_AlreadyArrived");

            using (Connection c = new Connection())
            {
                DateTime CurrentDate = DateTime.Now;
                if (this.AcknowledgementDateTime == null)
                {
                    this.AcknowledgementDateTime = CurrentDate;
                }
                if (this.ActualStartDateTime == null)
                    this.ActualStartDateTime = CurrentDate;
                this.ArrivalDateTime = CurrentDate;
                this.Save();

                c.Commit();
            }
        }

        /// <summary>
        ///
        /// </summary>
        public void CompleteWork()
        {
            if (this.CurrentActivity.ObjectName == "PendingAssignment" ||
                this.CurrentActivity.ObjectName == "PendingApproval" ||
                this.CurrentActivity.ObjectName == "Cancelled" ||
                this.CurrentActivity.ObjectName == "Draft")
                throw new Exception("Work_CannotCompleteAtThisStage");

            if (this.CurrentActivity.ObjectName == "PendingClosure" ||
                this.CurrentActivity.ObjectName == "Close")
                throw new Exception("Work_AlreadyCompleted");

            using (Connection c = new Connection())
            {
                DateTime CurrentDate = DateTime.Now;
                if (this.ActualEndDateTime == null)
                    this.ActualEndDateTime = CurrentDate;
                this.CompletionDateTime = CurrentDate;
                this.Save();
                this.TriggerWorkflowEvent("SubmitForClosure");

                c.Commit();
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get the total estimated cost.
        /// </summary>
        /// --------------------------------------------------------------
        public decimal TotalEstimatedCost
        {
            get
            {
                decimal? total = 0;
                foreach (OWorkCost workCost in this.WorkCost)
                    total += workCost.EstimatedSubTotal;
                return total == null ? 0 : total.Value;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get the total actual cost.
        /// </summary>
        /// --------------------------------------------------------------
        public decimal TotalActualCost
        {
            get
            {
                decimal? total = 0;
                foreach (OWorkCost workCost in this.WorkCost)
                    total += workCost.ActualSubTotal;
                return total == null ? 0 : total.Value;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get a comma separated list of technician names. This method
        /// is used for notification messages, to show the list of
        /// assigned technicians.
        /// </summary>
        /// --------------------------------------------------------------
        public string AssignedTechniciansNames
        {
            get
            {
                string names = "";
                foreach (OWorkCost workCost in this.WorkCost)
                    if (workCost.UserID != null)
                        names += (names == "" ? "" : ", ") + workCost.Technician.ObjectName;
                return names;
            }
        }

        /// <summary>
        /// Occurs when the work object is first created.
        /// </summary>
        public override void Created()
        {
            if (this.IsNew)
            {
                base.Created();
                this.TypeOfWorkID = OApplicationSetting.Current.DefaultTypeOfWorkID;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Called just before the object is saved.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            // this can be customized further to show location/type of service, etc at the
            // inbox of tasks
            //
            this.ObjectName = this.WorkDescription;

            // get previous work reading from database
            List<OReading> oldList = TablesLogic.tReading.LoadList(TablesLogic.tReading.WorkID == this.ObjectID);
            DataList<OReading> newList = this.WorkPointReadings;
            List<Guid> deleteList = new List<Guid>();
            foreach (OReading o in oldList)
            {
                if (newList.FindObject((Guid)o.ObjectID) == null)
                    deleteList.Add((Guid)o.ObjectID);
            }
            foreach (Guid i in deleteList)
                TablesLogic.tReading.Delete(i);

            // clean up checklist from database if it has been deleted
            List<OWorkChecklistItem> oldWorkList = TablesLogic.tWorkChecklistItem.LoadList(TablesLogic.tWorkChecklistItem.WorkID == this.ObjectID);
            DataList<OWorkChecklistItem> newWorkList = this.WorkChecklistItems;
            List<Guid> deleteWorkList = new List<Guid>();
            foreach (OWorkChecklistItem o in oldWorkList)
            {
                if (newWorkList.FindObject((Guid)o.ObjectID) == null)
                    deleteWorkList.Add((Guid)o.ObjectID);
            }
            foreach (Guid i in deleteWorkList)
                TablesLogic.tWorkChecklistItem.Delete(i);
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Clear all reservations before deleting the work.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Deactivating()
        {
            base.Deactivating();

            ClearReservations();
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Check if the work cost entered is a duplicate work cost.
        /// Returns true if so, false otherwise.
        /// </summary>
        /// <param name="workCost"></param>
        /// --------------------------------------------------------------
        public bool IsDuplicateWorkCost(OWorkCost workCost)
        {
            foreach (OWorkCost w in this.WorkCost)
            {
                if (w.ObjectID.Equals(workCost.ObjectID))
                    continue;

                if (workCost.CostType == WorkCostType.Technician && w.CostType == WorkCostType.Technician)
                {
                    if (w.CraftID.Equals(workCost.CraftID) &&
                        w.UserID.Equals(workCost.UserID))
                        return true;
                }
                else if (workCost.CostType == WorkCostType.FixedRate && w.CostType == WorkCostType.FixedRate)
                {
                    if (w.FixedRateID.Equals(workCost.FixedRateID))
                        return true;
                }
                else if (workCost.CostType == WorkCostType.AdhocRate && w.CostType == WorkCostType.AdhocRate)
                {
                    if (w.ObjectName.Equals(workCost.ObjectName))
                        return true;
                }
                else if (workCost.CostType == WorkCostType.Material && w.CostType == WorkCostType.Material)
                {
                    if (w.StoreBinID.Equals(workCost.StoreBinID) &&
                        w.CatalogueID.Equals(workCost.CatalogueID))
                        return true;
                }
            }

            return false;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Remove the existing checklist attached to this work order
        /// and update a new set of checklist items.
        /// </summary>
        /// --------------------------------------------------------------
        public void UpdateChecklist()
        {
            WorkChecklistItems.Clear();

            if (Checklist != null)
            {
                foreach (OChecklistItem checklistItem in Checklist.ChecklistItems)
                {
                    OWorkChecklistItem workChecklistItem = TablesLogic.tWorkChecklistItem.Create();

                    workChecklistItem.ObjectName = checklistItem.ObjectName;
                    workChecklistItem.StepNumber = checklistItem.StepNumber;
                    workChecklistItem.ChecklistType = checklistItem.ChecklistType;
                    workChecklistItem.ChecklistResponseSetID = checklistItem.ChecklistResponseSetID;
                    //workChecklistItem.ChecklistResponseSet = checklistItem.ChecklistResponseSet;
                    //if (checklistItem.ChecklistResponseSet != null)
                    //{
                    //    workChecklistItem.ScoreDenominator = checklistItem.ChecklistResponseSet.ScoreDenominator;

                    //    foreach (OChecklistResponse checklistResponse in checklistItem.ChecklistResponseSet.ChecklistResponses)
                    //    {
                    //        OWorkChecklistItemResponse workChecklistItemResponse = TablesLogic.tWorkChecklistItemResponse.Create();

                    //        workChecklistItemResponse.DisplayOrder = checklistResponse.DisplayOrder;
                    //        workChecklistItemResponse.ObjectName = checklistResponse.ObjectName;
                    //        workChecklistItemResponse.ScoreNumerator = checklistResponse.ScoreNumerator;
                    //        workChecklistItem.WorkChecklistItemResponse.Add(workChecklistItemResponse);
                    //    }
                    //}

                    WorkChecklistItems.Add(workChecklistItem);
                }
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Add parameters to this work order for input.
        /// </summary>
        /// <param name="idList"></param>
        /// <param name="isLocationTypeParameter"></param>
        /// --------------------------------------------------------------
        public void AddParameters(List<Guid> idList, bool isLocationTypeParameter)
        {
            foreach (Guid id in idList)
            {
                OWorkParameterReading r = TablesLogic.tWorkParameterReading.Create();

                if (isLocationTypeParameter)
                {
                    OLocationTypeParameter p = TablesLogic.tLocationTypeParameter[id];
                    r.LocationTypeParameterID = id;
                    r.ObjectName = p.ObjectName;
                    r.UnitOfMeasure = p.UnitOfMeasure;
                    r.Reading = null;
                }
                else
                {
                    OEquipmentTypeParameter p = TablesLogic.tEquipmentTypeParameter[id];
                    r.EquipmentTypeParameterID = id;
                    r.ObjectName = p.ObjectName;
                    r.UnitOfMeasure = p.UnitOfMeasure;
                    r.Reading = null;
                }

                this.WorkParameterReadings.Add(r);
            }
        }

        public void AddPointReading(List<OReading> readingList)
        {
            foreach (OReading i in readingList)
            {
                this.WorkPointReadings.Add(i);
            }
        }

        public void DeleteAllPointReading()
        {
            this.WorkPointReadings.Clear();
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Check if this work requires approval. It only requires approval if
        /// the total estimated cost of the work is greater than the authorization
        /// limit of the assigned supervisor.
        /// </summary>
        /// <returns></returns>
        ///// --------------------------------------------------------------
        //public bool RequiresApproval()
        //{
        //    return (Supervisor != null && Supervisor.WorkCostLimit < this.TotalEstimatedCost);
        //}

        /// --------------------------------------------------------------
        /// <summary>
        /// Get a data table of all the works currently attached to
        /// this scheduled work. Primarily used for Gantt chart display
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static DataTable GetWorksDataTable(ExpressionCondition cond)
        {
            // the column names are translated in the gantt chart using Resources.Strings.resx
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
                TablesLogic.tWork.CurrentActivity.ObjectName.As("Gantt_Status")
                )

                .Where(
                TablesLogic.tWork.IsDeleted == 0 &
                cond);
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get a list of helpdesk users who are eligible to
        /// pick up this work and assign to a supervisor
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public List<OUser> GetEligibleHelpdeskUsers()
        {
            /*
             * TODO: Resolve user access control later.
            return OUser.GetUse(
                this.TypeOfService, this.Location, "HELPDESK");*/
            return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Set the work's caller details to the current user's details
        /// </summary>
        /// --------------------------------------------------------------
        public void SetCallerDetailsToCurrentUser()
        {
            if (Workflow.CurrentUser != null)
            {
                this.CallerName = Workflow.CurrentUser.ObjectName;
                this.CallerPhone = Workflow.CurrentUser.UserBase.Phone;
                this.CallerCellPhone = Workflow.CurrentUser.UserBase.Cellphone;
                this.CallerEmail = Workflow.CurrentUser.UserBase.Email;
                this.CallerFax = Workflow.CurrentUser.UserBase.Fax;
                this.CallerID = Workflow.CurrentUser.ObjectID;
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get all technician users assigned to this work.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public List<OUser> GetTechnicianUsers()
        {
            List<OUser> users = new List<OUser>();
            foreach (OWorkCost cost in this.WorkCost)
            {
                if (cost.Technician != null && cost.IsDeleted == 0)
                    users.Add(cost.Technician);
            }
            return users;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Sets the acknowledgement, arrival and completion date/time
        /// limit based on the service level detail.
        /// </summary>
        /// <param name="serviceLevelDetail"></param>
        /// --------------------------------------------------------------
        public void SetServiceLevelLimits(OServiceLevelDetail serviceLevelDetail)
        {
            /*
            if (serviceLevelDetail == null)
                return;

            // kf begin: bug fix
            DateTime dt = DateTime.Now;
            if (this.CreatedDateTime != null)
                dt = this.CreatedDateTime.Value;

            if (serviceLevelDetail.AcknowledgementLimitInMinutes != null)
                this.AcknowledgementDateTimeLimit = dt.AddMinutes(
                    serviceLevelDetail.AcknowledgementLimitInMinutes.Value);
            else
                this.AcknowledgementDateTimeLimit = null;

            if (serviceLevelDetail.ArrivalLimitInMinutes != null)
                this.ArrivalDateTimeLimit = dt.AddMinutes(
                    serviceLevelDetail.ArrivalLimitInMinutes.Value);
            else
                this.ArrivalDateTimeLimit = null;

            if (serviceLevelDetail.CompletionLimitInMinutes != null)
                this.CompletionDateTimeLimit = dt.AddMinutes(
                    serviceLevelDetail.CompletionLimitInMinutes.Value);
            else
                this.CompletionDateTimeLimit = null;
            */
            /*
            if (serviceLevelDetail.AcknowledgementLimitInMinutes != null)
                this.AcknowledgementDateTimeLimit = this.CreatedOn.Value.AddMinutes(
                    serviceLevelDetail.AcknowledgementLimitInMinutes.Value);
            else
                this.AcknowledgementDateTimeLimit = null;

            if (serviceLevelDetail.ArrivalLimitInMinutes != null)
                this.ArrivalDateTimeLimit = this.CreatedOn.Value.AddMinutes(
                    serviceLevelDetail.ArrivalLimitInMinutes.Value);
            else
                this.ArrivalDateTimeLimit = null;

            if (serviceLevelDetail.CompletionLimitInMinutes != null)
                this.CompletionDateTimeLimit = this.CreatedOn.Value.AddMinutes(
                    serviceLevelDetail.CompletionLimitInMinutes.Value);
            else
                this.CompletionDateTimeLimit = null;
             */
            // kf end
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Creates a new work order if there is a scheduled work that
        /// created this work, and the scheduled work is based on
        /// floating scheduling.
        /// </summary>
        /// --------------------------------------------------------------
        public OWork CreateNewWorkOrderBasedOnSchedule()
        {
            OWork work = null;

            if (this.ScheduledWork != null && this.ScheduledWork.IsFloating == 1 &&
                this.ScheduledWork.IsDeleted == 0)
            {
                DateTime startDateTime = new DateTime(
                    this.ActualEndDateTime.Value.Year,
                    this.ActualEndDateTime.Value.Month,
                    this.ActualEndDateTime.Value.Day,
                    this.ActualEndDateTime.Value.Hour,
                    this.ActualEndDateTime.Value.Minute,
                    this.ActualEndDateTime.Value.Second);

                DateTime endDateTime = startDateTime.Add(
                    this.ActualEndDateTime.Value.Subtract(this.ActualStartDateTime.Value));

                OCalendar.ScheduleNextDate(this.ScheduledWork, ref startDateTime, ref endDateTime);

                if (this.ScheduledWork.Calendar != null)
                {
                    this.ScheduledWork.Calendar.InitializeSearchTable();
                    this.ScheduledWork.Calendar.FindNextWorkingDay(
                        this.ScheduledWork.CalendarBlockMethod == 0,
                        this.ScheduledWork.CalendarBlockMethod == 1,
                        ref startDateTime, ref endDateTime);
                }

                if ((this.ScheduledWork.IsScheduledByOccurrence == 0 && startDateTime <= this.ScheduledWork.EndDateTime.Value) ||
                    (this.ScheduledWork.IsScheduledByOccurrence == 1 && this.SchedulerCounter.Value + 1 < this.ScheduledWork.EndNumberOfOccurrences))
                {
                    // create a new work order
                    //
                    work = TablesLogic.tWork.Create();
                    work.TypeOfWorkID = this.ScheduledWork.TypeOfWorkID;
                    work.TypeOfServiceID = this.ScheduledWork.TypeOfServiceID;
                    work.TypeOfProblemID = this.ScheduledWork.TypeOfProblemID;
                    work.WorkDescription = this.ScheduledWork.WorkDescription;
                    work.Priority = this.ScheduledWork.Priority;
                    work.SupervisorID = this.ScheduledWork.SupervisorID;
                    work.ScheduledStartDateTime = startDateTime;
                    work.ScheduledEndDateTime = endDateTime;
                    work.SchedulerCounter = this.SchedulerCounter.Value + 1;
                    work.ScheduledWorkID = this.ScheduledWorkID;
                    work.LocationID = this.LocationID;
                    work.EquipmentID = this.EquipmentID;
                    work.ContractID = this.ScheduledWork.ContractID;

                    if (this.ScheduledWork.ScheduledWorkChecklist.Count > 0)
                    {
                        work.ChecklistID =
                            this.ScheduledWork.ScheduledWorkChecklist
                            [work.SchedulerCounter.Value % this.ScheduledWork.ScheduledWorkChecklist.Count].ChecklistID;
                    }

                    work.Save();
                }
            }
            return work;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get the applicable service level detail that applies to this
        /// work. The applicable service level detail is based on:
        /// - Type of Service
        /// - Location
        /// - Priority
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public OServiceLevelDetail GetApplicableServiceLevelDetail(int stepNumber)
        {
            /*
            List<OServiceLevelDetail> list = TablesLogic.tServiceLevelDetail[
                TablesLogic.tServiceLevelDetail.StepNumber == stepNumber &
                TablesLogic.tServiceLevelDetail.TypeOfServiceID == this.TypeOfServiceID &
                TablesLogic.tServiceLevelDetail.Priority == this.Priority &
                ((ExpressionDataString)this.Location.HierarchyPath)
                .Like(TablesLogic.tServiceLevelDetail.ServiceLevel.Location.HierarchyPath + "%"),
                TablesLogic.tServiceLevelDetail.ServiceLevel.Location.HierarchyPath.Length().Desc];

            if (list.Count > 0)
                return list[0];
            else*/
            return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get the number of minutes that the n-th reminder should be
        /// sent if the work is not acknowledged.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public int? GetAcknowledgementTimeLimitInMinutes(int stepNumber)
        {
            OServiceLevelDetail serviceLevelDetail = GetApplicableServiceLevelDetail(stepNumber);
            if (serviceLevelDetail != null)
                return serviceLevelDetail.AcknowledgementLimitInMinutes;
            return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get the number of minutes that the n-th reminder should be
        /// sent if the work is not arrived on-site.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public int? GetArrivalTimeLimitInMinutes(int stepNumber)
        {
            OServiceLevelDetail serviceLevelDetail = GetApplicableServiceLevelDetail(stepNumber);
            if (serviceLevelDetail != null)
                return serviceLevelDetail.ArrivalLimitInMinutes;
            return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get the number of minutes that the n-th reminder should be
        /// sent if the work is not completed.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public int? GetCompletionTimeLimitInMinutes(int stepNumber)
        {
            OServiceLevelDetail serviceLevelDetail = GetApplicableServiceLevelDetail(stepNumber);
            if (serviceLevelDetail != null)
                return serviceLevelDetail.CompletionLimitInMinutes;
            return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Add minutes to the date time and return the resulting date/time.
        /// </summary>
        /// <param name="dateTime"></param>
        /// <param name="timeInMinutes"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static DateTime? AddMinutes(DateTime dateTime, int? timeInMinutes)
        {
            if (timeInMinutes == null)
                return null;
            else
                return dateTime.AddMinutes(timeInMinutes.Value);
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Lock and unreserve all store items currently set up in the
        /// work's work cost.
        ///
        /// Once this method is called, the application should not
        /// update the work cost anymore.
        /// </summary>
        /// --------------------------------------------------------------
        public void ClearReservations()
        {
            foreach (OWorkCost workCost in this.WorkCost)
            {
                if (workCost.StoreBinID != null && workCost.CatalogueID != null)
                {
                    if (workCost.StoreBinReservation != null)
                    {
                        workCost.StoreBinReservation.BaseQuantityRequired = 0;
                        workCost.StoreBinReservation.Deactivate();
                    }
                }
            }
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// This method validates if there are sufficient store items
        /// in the store to meet the check-out requests of all work
        /// cost line items in this work order.
        ///
        /// An item can be checked-out without restrictions provided it
        /// was previously reserved (up to the quantity it was
        /// reserved). If, however, the quantity to be checked out,
        /// is more than the quantity reserved, or if there was
        /// no reservation at all, then this method checks to ensure
        /// that the store's physical balance - total reservations >=
        /// the additional items requested for check out. If the condition
        /// holds true, the check-out can proceed. If the condition
        /// is false, the workflow prevents the check-out, and throws
        /// a validation error.
        ///
        /// Rewrite another method, if the required logic is different.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ValidateSufficientStoreItems()
        {
            bool valid = true;
            foreach (OWorkCost newWorkCost in this.WorkCost)
            {
                newWorkCost.Valid = true;

                if (newWorkCost.CostType == WorkCostType.Material && newWorkCost.StoreBinID != null && newWorkCost.CatalogueID != null)
                {
                    OWorkCost oldWorkCost = TablesLogic.tWorkCost[(Guid)newWorkCost.ObjectID];
                    decimal newActualQuantity = Data.SafeConvert<decimal>(newWorkCost.ActualQuantity);
                    decimal oldActualQuantity = oldWorkCost == null ? 0.0M : Data.SafeConvert<decimal>(oldWorkCost.ActualQuantity);

                    decimal newBaseQuantity = OUnitConversion.ConvertActualToBaseQuantity((Guid)newWorkCost.Catalogue.UnitOfMeasureID,
                        (Guid)newWorkCost.UnitOfMeasureID, newActualQuantity);
                    decimal oldBaseQuantity = OUnitConversion.ConvertActualToBaseQuantity((Guid)newWorkCost.Catalogue.UnitOfMeasureID,
                        (Guid)newWorkCost.UnitOfMeasureID, oldActualQuantity);

                    if (newActualQuantity > oldActualQuantity)
                    {
                        decimal baseDifference = newBaseQuantity - oldBaseQuantity;

                        // check to make sure that there is sufficient physical quantity in the first place
                        // for the check-out to be successful
                        //
                        decimal physicalQuantity =
                            newWorkCost.StoreBin.GetTotalPhysicalQuantity((Guid)newWorkCost.CatalogueID);
                        if (baseDifference > physicalQuantity)
                        {
                            newWorkCost.Valid = false;
                            valid = false;
                            continue;
                        }

                        // check if the difference was previously reserved, if so then this item can be checked-out.
                        //
                        if (oldWorkCost != null && oldWorkCost.StoreBinReservation != null && oldWorkCost.StoreBinReservation.BaseQuantityReserved >= newBaseQuantity)
                            continue;

                        // if no reservation has been made,
                        // check the store's bin's available quantity = (physical - reserved) for this
                        // item is sufficient for the check-out.
                        //
                        decimal availableQuantity =
                            newWorkCost.StoreBin.GetTotalAvailableQuantity((Guid)newWorkCost.CatalogueID);

                        if (baseDifference <= availableQuantity)
                            continue;

                        // at this stage, all validations have failed, so we fail this item
                        //
                        newWorkCost.Valid = false;
                        valid = false;
                    }
                }
            }
            return valid;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Validate that for each work cost item that is a material,
        /// that the store bin and catalogue id must be specified.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ValidateAllStoreBinsSpecified()
        {
            foreach (OWorkCost w in WorkCost)
            {
                if (w.CostType == WorkCostType.Material)
                {
                    if (w.StoreBinID == null || w.CatalogueID == null)
                        return false;
                }
            }
            return true;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Validate that for each work cost item that is a material,
        /// that the store bin and catalogue id must be specified.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool ValidateAllTechniciansSpecified()
        {
            foreach (OWorkCost w in WorkCost)
            {
                if (w.CostType == WorkCostType.Technician)
                {
                    if (w.UserID == null)
                        return false;
                }
            }
            return true;
        }

        public Decimal? TotalChargeOut
        {
            get
            {
                if (this.IsChargedToCaller == 0)
                    return 0;
                else
                {
                    Decimal totalamount = 0;
                    foreach (OWorkCost workcost in this.WorkCost)
                    {
                        if (workcost.ChargeOut != null)
                            totalamount += workcost.ChargeOut.Value;
                    }
                    return totalamount;
                }
            }
        }

        public void NotifyPendingPlanning()
        {
            try
            {
                foreach (OUser user in this.CurrentActivity.Users)
                {
                    Resources.Notifications.Culture = new System.Globalization.CultureInfo(user.LanguageName);

                    OMessage.SendMail(
                        user.UserBase.Email,
                        OApplicationSetting.Current.MessageEmailSender,
                        "Header: WO " + this.ObjectNumber + " generated",
                        "Dear " + user.ObjectName + "<br/><br/>" +
                        "The work order WO " + this.ObjectNumber + " has been generated.<br/><br/>" +
                        "The details of the work are as follows<br/><br/>" +
                        "Work Description: " + this.WorkDescription + "<br/>" +
                        "Type of Work: " + this.TypeOfWork.ObjectName + "<br/>" +
                        "Type of Service: " + this.TypeOfService.ObjectName + "<br/>" +
                        "Type of Problem: " + this.TypeOfProblem.ObjectName + "<br/>",
                        true);

                    OMessage.SendSms(
                        user.UserBase.Cellphone,
                        DataFrameworkBinder.FormatObject(Resources.Notifications.Work_SmsNotifyPendingPlanning, this, user.ObjectName, this.ObjectNumber, this.Priority, this.WorkDescription));
                }
            }
            catch (Exception e)
            {
                e.StackTrace.ToString();
            }
        }

        public void NotifyTechnician()
        {
            foreach (OUser user in this.GetTechnicianUsers())
            {
                Resources.Notifications.Culture = new System.Globalization.CultureInfo(user.LanguageName);
                OMessage.SendSms(
                user.UserBase.Cellphone,
                DataFrameworkBinder.FormatObject(Resources.Notifications.Work_SmsNotifyExecution, this, user.ObjectName, this.ObjectNumber, this.Priority, this.WorkDescription));
            }
        }

        public void EscalationAcknowledgementStep2to5()
        {
            if (this.AcknowledgementDateTime == null)
            {
                foreach (OUser user in this.CurrentActivity.Users)
                {
                    if (user.SuperiorID != null)
                    {
                        Resources.Notifications.Culture = new System.Globalization.CultureInfo(user.Superior.LanguageName);
                        OMessage.SendMail(
                            user.Superior.UserBase.Email,
                            OApplicationSetting.Current.MessageEmailSender,
                            String.Format(Resources.Notifications.Work_EscalationAckSubject, this.ObjectNumber),
                            DataFrameworkBinder.FormatObject(Resources.Notifications.Work_EscalationAckBody, this, user.Superior.ObjectName), true);
                    }
                }
            }
        }

        public void EscalationArrivalStep2to5()
        {
            if (this.ArrivalDateTime == null)
            {
                foreach (OUser user in this.CurrentActivity.Users)
                {
                    if (user.SuperiorID != null)
                    {
                        Resources.Notifications.Culture = new System.Globalization.CultureInfo(user.Superior.LanguageName);
                        OMessage.SendMail(
                            user.Superior.UserBase.Email,
                            OApplicationSetting.Current.MessageEmailSender,
                            String.Format(Resources.Notifications.Work_EscalationArrSubject, this.ObjectNumber),
                            DataFrameworkBinder.FormatObject(Resources.Notifications.Work_EscalationArrBody, this, user.Superior.ObjectName), true);
                    }
                }
            }
        }

        public void EscalationCompletionStep2to5()
        {
            if (this.CompletionDateTime == null)
            {
                foreach (OUser user in this.CurrentActivity.Users)
                {
                    if (user.SuperiorID != null)
                    {
                        Resources.Notifications.Culture = new System.Globalization.CultureInfo(user.Superior.LanguageName);
                        OMessage.SendMail(
                        user.Superior.UserBase.Email,
                        OApplicationSetting.Current.MessageEmailSender,
                        String.Format(Resources.Notifications.Work_EscalationComSubject, this.ObjectNumber),
                        DataFrameworkBinder.FormatObject(Resources.Notifications.Work_EscalationComBody, this, user.Superior.ObjectName), true);
                    }
                }
            }
        }

        /// <summary>
        /// Occurs when the user closes the work.
        /// </summary>
        //public void CloseWork()
        //{
        //    using (Connection c = new Connection())
        //    {
        //        //check for breach of reading at final stage
        //        foreach (OReading i in this.WorkPointReadings)
        //            i.CheckForBreachOfReading(i.Point);

        //        this.ClearReservations();

        //        OWork newWork = this.CreateNewWorkOrderBasedOnSchedule();
        //        if (newWork != null)
        //        {
        //            newWork.Save();
        //            newWork.TriggerWorkflowEvent("SubmitForAssignment");
        //        }

        //        // Close related case.
        //        //
        //        if (OApplicationSetting.Current.CaseEventAfterDocumentClosedOrCancelled != "SubmitForClosure")
        //            OCase.CloseCaseWhenAllDocumentsClosedOrCancelled(this.CaseID);

        //        c.Commit();
        //    }
        //}

        /// <summary>
        /// Gets a list of assigned technicians.
        /// </summary>
        /// <returns></returns>
        public List<OUser> GetAssignedTechnicians()
        {
            List<OUser> list = new List<OUser>();
            foreach (OWorkCost workCost in this.WorkCost)
            {
                if (workCost.Technician != null)
                    list.Add(workCost.Technician);
            }
            return list;
        }

        /// <summary>
        /// Completes the work by updating the percentage
        /// progress and the work completion date/time.
        /// <para></para>
        /// This method is called by the workflow when it
        /// enters the PendingClosure state.
        /// </summary>
        public void UpdateWorkCompleteFields()
        {
            this.CompletionDateTime = DateTime.Now;
            this.PercentageComplete = 100;

            if (OApplicationSetting.Current.CaseEventAfterDocumentClosedOrCancelled == "SubmitForClosure")
                OCase.CloseCaseWhenAllDocumentsClosedOrCancelled(this.CaseID);
        }

        /// <summary>
        /// Validates that none of the store bins selected
        /// in the work cost are locked. This should only be
        /// called when the user is able to enter the actual
        /// costs of the work.
        /// </summary>
        /// <returns></returns>
        public string ValidateStoreBinsNotLocked()
        {
            List<Guid> storeBinIds = new List<Guid>();

            foreach (OWorkCost workCost in this.WorkCost)
            {
                if (workCost.CostType == WorkCostType.Material &&
                    workCost.StoreBinID != null &&
                    workCost.ActualQuantity != workCost.ActualQuantityPrevious)
                    storeBinIds.Add(workCost.StoreBinID.Value);
            }

            DataTable dt = TablesLogic.tStoreBin.Select(
                TablesLogic.tStoreBin.Store.ObjectName.As("StoreName"),
                TablesLogic.tStoreBin.ObjectName.As("StoreBinName"))
                .Where(
                TablesLogic.tStoreBin.IsLocked == 1 &
                TablesLogic.tStoreBin.ObjectID.In(storeBinIds));

            StringBuilder sb = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
                sb.Append(dr["StoreBinName"].ToString() + " (" + dr["StoreName"].ToString() + "); ");

            return sb.ToString();
        }

        /// <summary>
        /// For template
        /// </summary>
        public string ChargeToCallerText
        {
            get
            {
                if (this.IsChargedToCaller == 1)
                    return "Yes";
                else
                    return "No";
            }
        }

        public string PriorityText
        {
            get
            {
                switch (this.Priority)
                {
                    case 0:
                        return Resources.Strings.Work_Priority0;
                    case 1:
                        return Resources.Strings.Work_Priority1;
                    case 2:
                        return Resources.Strings.Work_Priority2;
                    case 3:
                        return Resources.Strings.Work_Priority3;
                    default:
                        return "";
                }
            }
        }

        public List<OActivityHistory> WorkStatusHistory
        {
            get
            {
                List<OActivityHistory> statusHistory = TablesLogic.tActivityHistory.LoadList(
                                                       TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID);
                return statusHistory;
            }
        }
    }
}