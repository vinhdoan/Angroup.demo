using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    public class TNotificationProcess : LogicLayerSchema<ONotificationProcess>
    {
        public SchemaGuid TypeOfWorkID;
        public SchemaGuid TypeOfServiceID;
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        [Size(255)]
        public SchemaString Description;
        public SchemaInt IsApplicableToPriority0;
        public SchemaInt IsApplicableToPriority1;
        public SchemaInt IsApplicableToPriority2;
        public SchemaInt IsApplicableToPriority3;
        public SchemaGuid NotificationHierarchyID;
        public SchemaGuid NotificationMilestonesID;
        [Default(1)]
        public SchemaInt NotificationLevelAsLimit;
        [Default(1)]
        public SchemaInt UseDefaultTimings;
        public SchemaGuid MessageTemplate1ID;
        public SchemaGuid MessageTemplate2ID;
        public SchemaGuid MessageTemplate3ID;
        public SchemaGuid MessageTemplate4ID;

        public TNotificationHierarchy NotificationHierarchy { get { return OneToOne<TNotificationHierarchy>("NotificationHierarchyID"); } }
        public TNotificationMilestones NotificationMilestones { get { return OneToOne<TNotificationMilestones>("NotificationMilestonesID"); } }
        public TNotificationProcessTiming NotificationProcessTimings { get { return OneToMany<TNotificationProcessTiming>("NotificationProcessID"); } }
        public TCode TypeOfWork { get { return OneToOne<TCode>("TypeOfWorkID"); } }
        public TCode TypeOfService { get { return OneToOne<TCode>("TypeOfServiceID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
    }


    /// <summary>
    /// Represents an Notification process specific to a persistent object
    /// type and a state within its workflow. This Notification process
    /// specifies Notification hierarchies applicable to the persistent object
    /// depending on the location/equipment specified in the persistent
    /// object.
    /// </summary>
    public abstract class ONotificationProcess : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Code table that represents the Type Of Work
        /// this Notification process applies to if this process is for Work object.
        /// </summary>
        public abstract Guid? TypeOfWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Code table that represents the Type Of Service
        /// this Notification process applies to if this process is for Work object.
        /// </summary>
        public abstract Guid? TypeOfServiceID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Location table that represents the location
        /// this Notification process applies to.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Equipment table that represents the equipment
        /// this Notification process applies to.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of
        /// this Notification process detail.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating if this
        /// notification process is applicable to tasks
        /// of priority 0.
        /// </summary>
        public abstract int? IsApplicableToPriority0 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating if this
        /// notification process is applicable to tasks
        /// of priority 0.
        /// </summary>
        public abstract int? IsApplicableToPriority1 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating if this
        /// notification process is applicable to tasks
        /// of priority 0.
        /// </summary>
        public abstract int? IsApplicableToPriority2 { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating if this
        /// notification process is applicable to tasks
        /// of priority 0.
        /// </summary>
        public abstract int? IsApplicableToPriority3 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Foreign key to the NotificationHierarchy table.
        /// This is compulsory when the ModeOfNotification = 1
        /// </summary>
        public abstract Guid? NotificationHierarchyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Foreign key to the NotificationMilestones table.
        /// This is compulsory when the ModeOfNotification = 1
        /// </summary>
        public abstract Guid? NotificationMilestonesID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the notification level will be used
        /// as the service level limit.
        /// </summary>
        public abstract int? NotificationLevelAsLimit { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether or not to use
        /// the default timings specified in the notification hierarchy.
        /// </summary>
        public abstract int? UseDefaultTimings { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the MessageTemplate 
        /// table that indicates the message template to be used
        /// when sending notification for milestone 1.
        /// </summary>
        public abstract Guid? MessageTemplate1ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the MessageTemplate 
        /// table that indicates the message template to be used
        /// when sending notification for milestone 2.
        /// </summary>
        public abstract Guid? MessageTemplate2ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the MessageTemplate 
        /// table that indicates the message template to be used
        /// when sending notification for milestone 3.
        /// </summary>
        public abstract Guid? MessageTemplate3ID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the MessageTemplate 
        /// table that indicates the message template to be used
        /// when sending notification for milestone 4.
        /// </summary>
        public abstract Guid? MessageTemplate4ID { get; set; }

        /// <summary>
        /// Gets or sets the ONotificationHierarchy object representing
        /// the hierarchy of users/roles and their Notification limits
        /// that will be used for approving objects.
        /// </summary>
        public abstract ONotificationHierarchy NotificationHierarchy { get; set; }

        /// <summary>
        /// Gets or sets the ONotificationMilestones object representing
        /// the milestones applicable to this notification process.
        /// </summary>
        public abstract ONotificationMilestones NotificationMilestones { get; set; }

        /// <summary>
        /// Gets a reference to the list of notification process timings.
        /// </summary>
        public abstract DataList<ONotificationProcessTiming> NotificationProcessTimings { get; }

        /// <summary>
        /// Gets or sets the OCode object representing the
        /// Type Of Work to which this Notification process applies.
        /// </summary>
        public abstract OCode TypeOfWork { get; set; }

        /// <summary>
        /// Gets or sets the OCode object representing the
        /// Type Of Service to which this Notification process applies.
        /// </summary>
        public abstract OCode TypeOfService { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object representing the
        /// location to which this Notification process applies.
        /// </summary>
        public abstract OLocation Location { get; set; }


        /// <summary>
        /// Gets or sets the OEquipment object representing the
        /// equipment to which this Notification process applies.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }


        /// <summary>
        /// Returns a list of all active Notification processes in the system.
        /// </summary>
        /// <returns></returns>
        public static List<ONotificationProcess> GetAllNotificationProcesses()
        {
            return TablesLogic.tNotificationProcess[TablesLogic.tNotificationProcess.IsDeleted == 0];
        }

        

        /// <summary>
        /// Gets a list of Notification process details object by the
        /// specified Notification process code and applicable to the 
        /// persistent object.
        /// </summary>
        /// <param name="logicLayerPersistentObject"></param>
        /// <returns></returns>
        public static List<ONotificationProcess> GetNotificationProcesses(
            LogicLayerPersistentObjectBase logicLayerPersistentObject)
        {
            List<OLocation> taskLocations = logicLayerPersistentObject.TaskLocations;
            List<OEquipment> taskEquipments = logicLayerPersistentObject.TaskEquipments;

            // Construct the condition to look for the Notification process
            // detail that covers all locations/equipment of the task.
            //
            TNotificationProcess d1 = new TNotificationProcess();

            // 2010.05.19
            // Kim Foong
            // Moved this out to the top.
            //
            TNotificationProcess n = TablesLogic.tNotificationProcess;

            ExpressionCondition conditionLocation = Query.True;
            if (taskLocations != null)
                foreach (OLocation taskLocation in taskLocations)
                    if (taskLocation != null)
                        // 2010.05.19
                        // Kim Foong
                        // Fixed to ensure that d1.ObjectID matches n.ObjectID
                        //conditionLocation &= d1.Select(d1.ObjectID).Where(taskLocation.HierarchyPath.Like(d1.Location.HierarchyPath + "%")).Exists();
                        conditionLocation &= d1.Select(d1.ObjectID).Where(taskLocation.HierarchyPath.Like(d1.Location.HierarchyPath + "%") & d1.ObjectID == n.ObjectID).Exists();

            ExpressionCondition conditionEquipment = Query.True;
            if (taskEquipments != null)
                foreach (OEquipment taskEquipment in taskEquipments)
                    if (taskEquipment != null)
                        // 2010.05.19
                        // Kim Foong
                        // Fixed to ensure that d1.ObjectID matches n.ObjectID
                        //conditionEquipment &= d1.Select(d1.ObjectID).Where(taskEquipment.HierarchyPath.Like(d1.Equipment.HierarchyPath + "%")).Exists();
                        conditionEquipment &= d1.Select(d1.ObjectID).Where(taskEquipment.HierarchyPath.Like(d1.Equipment.HierarchyPath + "%") & d1.ObjectID == n.ObjectID).Exists();

            if (logicLayerPersistentObject is OWork)
            {
                OWork W = (OWork)logicLayerPersistentObject;
                ExpressionCondition conditionTypeOfWork = TablesLogic.tNotificationProcess.TypeOfWorkID == null |
                    TablesLogic.tNotificationProcess.TypeOfWorkID == W.TypeOfWorkID;

                ExpressionCondition conditionTypeOfService = TablesLogic.tNotificationProcess.TypeOfServiceID == null |
                    TablesLogic.tNotificationProcess.TypeOfServiceID == W.TypeOfServiceID;

                // query and returns the result.
                //
                //TNotificationProcess n = TablesLogic.tNotificationProcess;
                return n.LoadList(
                    (n.NotificationMilestones.States == "*" |
                    ("," + n.NotificationMilestones.States + ",").Like("%," + logicLayerPersistentObject.CurrentActivity.ObjectName + ",%")) &
                    n.NotificationMilestones.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (logicLayerPersistentObject.CurrentActivity.Priority == 0 ? n.IsApplicableToPriority0 == 1 :
                    logicLayerPersistentObject.CurrentActivity.Priority == 1 ? n.IsApplicableToPriority1 == 1 :
                    logicLayerPersistentObject.CurrentActivity.Priority == 2 ? n.IsApplicableToPriority2 == 1 :
                    logicLayerPersistentObject.CurrentActivity.Priority == 3 ? n.IsApplicableToPriority3 == 1 :
                    Query.True) &
                    conditionLocation &
                    conditionEquipment &
                    conditionTypeOfWork &
                    conditionTypeOfService,
                    n.Location.HierarchyPath.Length().Desc,
                    n.Equipment.HierarchyPath.Length().Desc,
                    n.TypeOfService.ObjectName.Length().Desc,
                    n.TypeOfWork.ObjectName.Length().Desc,
                    n.Description.Asc
                    );
            }
            else
            {
                // query and returns the result.
                //
                //TNotificationProcess n = TablesLogic.tNotificationProcess;
                return n.LoadList(
                    (n.NotificationMilestones.States == "*" |
                    ("," + n.NotificationMilestones.States + ",").Like("%," + logicLayerPersistentObject.CurrentActivity.ObjectName + ",%")) &
                    n.NotificationMilestones.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (logicLayerPersistentObject.CurrentActivity.Priority == 0 ? n.IsApplicableToPriority0 == 1 :
                    logicLayerPersistentObject.CurrentActivity.Priority == 1 ? n.IsApplicableToPriority1 == 1 :
                    logicLayerPersistentObject.CurrentActivity.Priority == 2 ? n.IsApplicableToPriority2 == 1 :
                    logicLayerPersistentObject.CurrentActivity.Priority == 3 ? n.IsApplicableToPriority3 == 1 :
                    Query.True) &
                    conditionLocation &
                    conditionEquipment,
                    n.Location.HierarchyPath.Length().Desc,
                    n.Equipment.HierarchyPath.Length().Desc,
                    n.Description.Asc
                    );
            }
        }


        /// <summary>
        /// Links the notification process timings to the notification
        /// hierarchy levels.
        /// </summary>
        public void LinkNotificationProcessTimings()
        {
            if (this.NotificationHierarchy != null)
            {
                foreach (ONotificationHierarchyLevel notificationHierarchyLevel in
                    this.NotificationHierarchy.NotificationHierarchyLevels)
                {
                    // look for the notification process timing
                    // with the same notification level.
                    //
                    ONotificationProcessTiming timing = this.NotificationProcessTimings.Find(p => p.NotificationLevel == notificationHierarchyLevel.NotificationLevel);
                    if(timing==null)
                    {
                        timing = TablesLogic.tNotificationProcessTiming.Create();
                        timing.NotificationLevel = notificationHierarchyLevel.NotificationLevel;
                        this.NotificationProcessTimings.Add(timing);
                    }
                    notificationHierarchyLevel.TempNotificationProcessingTiming = timing;
                }
            }
        }


        /// <summary>
        /// Validates that if the non-default timings are
        /// used, that all process timings are in 
        /// increasing order, with no gaps in between.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNonDefaultNotificationProcessTimings()
        {
            if (this.UseDefaultTimings == 0)
            {
                List<ONotificationProcessTiming> timings = new List<ONotificationProcessTiming>();
                foreach (ONotificationProcessTiming timing in this.NotificationProcessTimings)
                    timings.Add(timing);
                timings.Sort("NotificationLevel ASC");

                // 2010.06.03
                // Kim Foong
                // Bug fix: if the notification hierarchy has less levels
                // than before, we need to ensure that we do not validate
                // the order for the extra levels in the non-default 
                // notification process timings.
                //
                //for (int i = 0; i < timings.Count - 1; i++)
                for (int i = 0; i < timings.Count - 1 && i < this.NotificationHierarchy.NotificationHierarchyLevels.Count - 1; i++)
                {
                    if (timings[i].NotificationTimeInMinutes1 != null &&
                        timings[i + 1].NotificationTimeInMinutes1 != null &&
                        timings[i].NotificationTimeInMinutes1 >= timings[i + 1].NotificationTimeInMinutes1)
                        return false;
                    if (timings[i].NotificationTimeInMinutes2 != null &&
                        timings[i + 1].NotificationTimeInMinutes2 != null &&
                        timings[i].NotificationTimeInMinutes2 >= timings[i + 1].NotificationTimeInMinutes2)
                        return false;
                    if (timings[i].NotificationTimeInMinutes3 != null &&
                        timings[i + 1].NotificationTimeInMinutes3 != null &&
                        timings[i].NotificationTimeInMinutes3 >= timings[i + 1].NotificationTimeInMinutes3)
                        return false;
                    if (timings[i].NotificationTimeInMinutes4 != null &&
                        timings[i + 1].NotificationTimeInMinutes4 != null &&
                        timings[i].NotificationTimeInMinutes4 >= timings[i + 1].NotificationTimeInMinutes4)
                        return false;
                }
            }
            return true;
        }


        /// <summary>
        /// Gets the notification process timing by hierarchy level.
        /// </summary>
        /// <param name="hierarchyLevel"></param>
        /// <returns></returns>
        public ONotificationProcessTiming FindNotificationProcessTimingByLevel(int level)
        {
            foreach (ONotificationProcessTiming notificationProcessTiming in this.NotificationProcessTimings)
                if (notificationProcessTiming.NotificationLevel == level)
                    return notificationProcessTiming;
            return null;
        }



        /// <summary>
        /// Get the next notification date based on a reference field on the specified
        /// object and the notification time in minutes.
        /// </summary>
        /// <param name="referenceField"></param>
        /// <param name="notificationTimeInMinutes"></param>
        /// <returns></returns>
        public DateTime? GetNextNotificationDateTime(
            LogicLayerPersistentObjectBase obj,
            object referenceField,
            object notificationTimeInMinutes)
        {
            if (notificationTimeInMinutes == null || notificationTimeInMinutes == DBNull.Value)
                return null;

            object referenceFieldValue = DataFrameworkBinder.GetValue(obj, (string)referenceField, false);
            DateTime? referenceDateTime = referenceFieldValue as DateTime?;

            if (referenceDateTime == null)
                return null;
            return referenceDateTime.Value.AddMinutes((int)notificationTimeInMinutes);
        }



        /// <summary>
        /// Gets the next notification date time.
        /// </summary>
        /// <returns></returns>
        public void GetNextNotificationDateTime(LogicLayerPersistentObjectBase obj, 
            DateTime? lastNotificationDateTime, // 2010.05.13 Kim Foong - added to pass in the last notification date/time
            ref DateTime? nextNotificationDateTime, ref int? milestoneNumber, ref int? notificationLevel)
        {
            DateTime now = DateTime.Now;
            nextNotificationDateTime = DateTime.MaxValue;

            ONotificationMilestones milestones = this.NotificationMilestones;

            if (this.UseDefaultTimings == 0)
            {
                foreach (ONotificationProcessTiming o in this.NotificationProcessTimings)
                {
                    for (int i = 1; i <= 4; i++)
                    {
                        DateTime? nextTiming = GetNextNotificationDateTime(obj,
                            milestones.DataRow["ReferenceField" + i],
                            o.DataRow["NotificationTimeInMinutes" + i]);

                        // 2010.05.13 
                        // Kim Foong 
                        // Instead of using nextTiming > now, we use nextTiming >= lastNotificationDateTime
                        // so as to ensure we do not miss any notifications (in times of heavy load).
                        // 
                        if (nextTiming < nextNotificationDateTime && (lastNotificationDateTime== null || nextTiming > lastNotificationDateTime))
                        {
                            nextNotificationDateTime = nextTiming;
                            milestoneNumber = i;
                            notificationLevel = o.NotificationLevel.Value;
                        }
                    }
                }
            }
            else
            {
                foreach (ONotificationHierarchyLevel o in this.NotificationHierarchy.NotificationHierarchyLevels)
                {
                    for (int i = 1; i <= 4; i++)
                    {
                        DateTime? nextTiming = GetNextNotificationDateTime(obj,
                            milestones.DataRow["ReferenceField" + i],
                            o.DataRow["NotificationTimeInMinutes" + i]);

                        // 2010.05.13 
                        // Kim Foong 
                        // Instead of using nextTiming > now, we use nextTiming >= lastNotificationDateTime
                        // so as to ensure we do not miss any notifications (in times of heavy load).
                        // 
                        if (nextTiming < nextNotificationDateTime && (lastNotificationDateTime == null || nextTiming > lastNotificationDateTime))
                        {
                            nextNotificationDateTime = nextTiming;
                            milestoneNumber = i;
                            notificationLevel = o.NotificationLevel.Value;
                        }
                    }
                }
            }

            if (nextNotificationDateTime == DateTime.MaxValue)
                nextNotificationDateTime = null;

        }
    }


}
