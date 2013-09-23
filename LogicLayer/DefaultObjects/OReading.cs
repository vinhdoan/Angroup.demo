//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TReading : LogicLayerSchema<OReading>
    {
        [Default(0)]
        public SchemaInt Source;
        public SchemaGuid LocationID;        
        public SchemaGuid EquipmentID;        
        public SchemaDecimal Reading;
        public SchemaDateTime DateOfReading;
        public SchemaGuid CreateOnBreachWorkID;
        public SchemaGuid WorkID;
        public SchemaGuid PointID;
        public SchemaInt IsCreatedByWork;

        public TWork CreateOnBreachWork { get { return OneToOne<TWork>("CreateOnBreachWorkID"); } }
        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }
        public TPoint Point { get { return OneToOne<TPoint>("PointID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        
    }


    /// <summary>
    /// Represents the reading for an OPC point obtained
    /// from the server, entered by a user through the work
    /// module, or entered by the user through the Point module.
    /// </summary>
    [Serializable]
    public abstract partial class OReading : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the source of this reading.
        /// <para></para>
        /// <list>
        ///     <item>0 - Entered directly through UI </item>
        ///     <item>1 - Entered from a Work </item>
        ///     <item>2 - Obtained automatically from an OPC Server </item>
        ///     <item>3 - Entered from a PDA </item>
        /// </list>
        /// </summary>
        public abstract int? Source { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Location table that represents the location
        /// that this point is attached to. The point
        /// can only be attached to either a Location or
        /// an Equipment but not both.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        
        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Equipment table that represents the equipment
        /// that this point is attached to. The point
        /// can only be attached to either a Location or
        /// an Equipment but not both.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        
        /// <summary>
        /// [Column] Gets or sets the value of reading of
        /// this OPC point.
        /// </summary>
        public abstract Decimal? Reading { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date and time the reading
        /// was taken or obtained from the OPC server.
        /// </summary>
        public abstract DateTime? DateOfReading { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// Work that was created when this reading breached 
        /// the acceptable range for this point.
        /// </summary>
        public abstract Guid? CreateOnBreachWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Work
        /// that took this reading.
        /// </summary>
        public abstract Guid? WorkID { get; set; }

        /// <summary>
        /// Gets or sets foreign key to the Point.
        /// </summary>
        public abstract Guid? PointID { get; set; }

        /// <summary>
        /// Gets or sets the Work that was created when this reading breached 
        /// the acceptable range for this point.
        /// </summary>
        public abstract OWork CreateOnBreachWork { get; set; }

        /// <summary>
        /// Gets or sets the Work that took this reading.
        /// </summary>
        public abstract OWork Work { get; set; }

        public abstract OPoint Point { get; set; }

        public abstract OLocation Location { get; set; }

        public abstract OEquipment Equipment { get; set; }
        
        public abstract int? IsCreatedByWork { get; set; }


        /// <summary>
        /// Gets the translated text of the source.
        /// </summary>
        public string SourceName
        {
            get
            {
                if (this.Source == ReadingSource.Direct)
                    return Resources.Strings.Source_Direct;
                else if (this.Source == ReadingSource.OPCServer)
                    return Resources.Strings.Source_OPCServer;
                else if (this.Source == ReadingSource.Work)
                    return Resources.Strings.Source_Work;
                else if (this.Source == ReadingSource.PDA)
                    return Resources.Strings.Source_PDA;
                return "";
            }
        }


        /// <summary>
        /// Creates a new work and transits it. 
        /// </summary>
        protected void CreateWork(OPoint point)
        {
            OWork work = TablesLogic.tWork.Create();
            if (point.LocationID != null)
            {
                work.LocationID = point.LocationID;
                work.EquipmentID = null;
            }
            else
            {
                work.LocationID = point.Equipment.LocationID;
                work.EquipmentID = point.EquipmentID;
            }

            work.GeneratedByReadingID = this.ObjectID;
            work.GeneratedByPointID = point.ObjectID;

            if (point.PointTrigger != null)
            {
                work.Priority = point.PointTrigger.Priority;
                work.TypeOfWorkID = point.PointTrigger.TypeOfWorkID;
                work.TypeOfServiceID = point.PointTrigger.TypeOfServiceID;
                work.TypeOfProblemID = point.PointTrigger.TypeOfProblemID;
                
                try
                {
                    work.WorkDescription = String.Format(point.PointTrigger.WorkDescription, this.Reading);
                }
                catch
                {
                    work.WorkDescription = point.PointTrigger.WorkDescription;
                }
            }
            else
            {
                work.Priority = point.Priority;
                work.TypeOfWorkID = point.TypeOfWorkID;
                work.TypeOfServiceID = point.TypeOfServiceID;
                work.TypeOfProblemID = point.TypeOfProblemID;
               
                try
                {
                    work.WorkDescription = String.Format(point.WorkDescription, this.Reading);
                }
                catch
                {
                    work.WorkDescription = point.WorkDescription;
                }
            }
         
            work.Save();
            work.TriggerWorkflowEvent("SaveAsDraft");                      
            
            this.CreateOnBreachWorkID = work.ObjectID;            
        }

        public override bool IsDeactivatable()
        {
            return this.CreateOnBreachWorkID == null && this.BillToAMOSStatus != 1
                && this.BillToAMOSStatus != 2 && this.BillToAMOSStatus != 4;
            // && this.Source == ReadingSource.Direct;
        }


        /// <summary>
        /// Checks if the reading has breached the OPC point's
        /// range of acceptable values. 
        /// </summary>
        /// <returns>True if there is a breach of reading, and a work
        /// has been created.</returns>
        /// <param name="point"></param>
        public bool CheckForBreachOfReading(OPoint point)
        {
            bool breached = false;
            if (point.CreateWorkOnBreach == 1)
            {
                if (this.Reading < point.MinimumAcceptableReading ||
                    this.Reading > point.MaximumAcceptableReading)
                {
                    // Raise an event that can be overriden by 
                    // a customized instance of the Anacle.EAM
                    // application.
                    //
                    point.ThresholdBreached(this);

                    if (point.NumberOfBreachesToTriggerAction != null && this.Source == ReadingSource.OPCServer)
                    {
                        // If the number of breaches to trigger action is specified,
                        // we increment the number of breaches so far, and check
                        // if we have hit the limit. If so, automatically generate
                        // a Work object.
                        //
                        if (point.NumberOfBreachesSoFar < point.NumberOfBreachesToTriggerAction)
                            point.NumberOfBreachesSoFar++;

                        if (point.NumberOfBreachesSoFar >= point.NumberOfBreachesToTriggerAction)
                        {
                            // Okay, we have exceed the limit, so we create a
                            // work when necessary.
                            //
                            point.NumberOfBreachesSoFar = 0;
                            if (point.CreateOnlyIfWorksAreCancelledOrClosed == 1)
                            {
                                // Check for the presence of works that are generated
                                // by this point and are NOT cancelled or closed.
                                //
                                TWork tWork = TablesLogic.tWork;
                                int count = tWork.Select(tWork.ObjectID.Count()).Where(
                                    tWork.GeneratedByPointID == point.ObjectID &
                                    tWork.CurrentActivity.ObjectName != "Cancelled" &
                                    tWork.CurrentActivity.ObjectName != "Close" &
                                    tWork.IsDeleted == 0);

                                if (count == 0)
                                {
                                    // There are no works that are currently, opened
                                    // so therefore we create a work.
                                    //
                                    CreateWork(point);
                                }
                            }
                            else
                            {
                                // Regardless of whether works exists in the database
                                // or not.
                                CreateWork(point);
                            }
                            breached = true;
                        }
                    }
                    else if(this.Source == ReadingSource.PDA)
                    {
                        if (point.CreateOnlyIfWorksAreCancelledOrClosed == 1)
                        {
                            // Check for the presence of works that are generated
                            // by this point and are NOT cancelled or closed.
                            //
                            TWork tWork = TablesLogic.tWork;
                            int count = tWork.Select(tWork.ObjectID.Count()).Where(
                                tWork.GeneratedByPointID == point.ObjectID &
                                tWork.CurrentActivity.ObjectName != "Cancelled" &
                                tWork.CurrentActivity.ObjectName != "Close" &
                                tWork.IsDeleted == 0);

                            if (count == 0)
                            {
                                // There are no works that are currently, opened
                                // so therefore we create a work.
                                //
                                CreateWork(point);
                            }
                        }
                        else
                        {
                            // Regardless of whether works exists in the database
                            // or not.
                            CreateWork(point);
                        }
                        breached = true;
                    }
                    else
                        point.NumberOfBreachesSoFar = 0;
                    point.Save();
                }
            }
            return breached;
        }


        /// <summary>
        /// Checks if the reading has breached the OPC point's
        /// range of acceptable values.
        /// </summary>
        /// <returns>True if there is a breach of reading, and a work
        /// has been created.</returns>
        public bool CheckForBreachOfReading()
        {
            using (Connection c = new Connection())
            {
                // First, we check if the OPC point that has the same pointID
                // KNX changed: as remove of type parameter
                OPoint opcPoint = TablesLogic.tPoint.Load(
                    TablesLogic.tPoint.ObjectID == this.PointID);
                    
                if (opcPoint == null)
                    return false;

                bool result = CheckForBreachOfReading(opcPoint);
                this.Save();
                c.Commit();

                return result;
            }
        }


        ///// <summary>
        ///// Gets the most recent readings by location and location type
        ///// parameter.
        ///// </summary>
        ///// <param name="location"></param>
        ///// <param name="locationTypeParameter"></param>
        ///// <param name="numberOfResults"></param>
        ///// <returns></returns>
        //public static DataTable GetReadingsByLocation(Guid locationId, Guid locationTypeParameterId, int numberOfResults)
        //{
        //    TReading r = TablesLogic.tReading;
        //    DataTable dt = r.SelectTop(
        //        numberOfResults,
        //        r.ObjectID,
        //        r.Reading,
        //        r.DateOfReading,
        //        r.CreateOnBreachWork.ObjectNumber.As("CreateBreachOnWork.ObjectNumber"),
        //        r.CreateOnBreachWork.CurrentActivity.ObjectName.As("CreateBreachOnWork.CurrentActivity.ObjectName"))
        //        .Where(
        //        r.LocationID == locationId &
        //        r.LocationTypeParameterID == locationTypeParameterId &
        //        r.IsDeleted == 0)
        //        .OrderBy(
        //        r.DateOfReading.Desc);

        //    while (dt.Rows.Count > numberOfResults)
        //        dt.Rows.RemoveAt(numberOfResults);
        //    return dt;
        //}

        ///// <summary>
        ///// Gets the most recent readings by location and location type
        ///// parameter.
        ///// </summary>
        ///// <param name="location"></param>
        ///// <param name="locationTypeParameter"></param>
        ///// <param name="numberOfResults"></param>
        ///// <returns></returns>
        //public static DataTable GetReadingsByEquipment(Guid equipmentId, Guid equipmentTypeParameterId, int numberOfResults)
        //{
        //    TReading r = TablesLogic.tReading;
        //    DataTable dt = r.SelectTop(
        //        numberOfResults,
        //        r.ObjectID,
        //        r.Reading,
        //        r.DateOfReading,
        //        r.CreateOnBreachWork.ObjectNumber.As("CreateBreachOnWork.ObjectNumber"),
        //        r.CreateOnBreachWork.CurrentActivity.ObjectName.As("CreateBreachOnWork.CurrentActivity.ObjectName"))
        //        .Where(
        //        r.EquipmentID == equipmentId &
        //        r.EquipmentTypeParameterID == equipmentTypeParameterId &
        //        r.IsDeleted == 0)
        //        .OrderBy(
        //        r.DateOfReading.Desc);

        //    while (dt.Rows.Count > numberOfResults)
        //        dt.Rows.RemoveAt(numberOfResults);
        //    return dt;
        //}

        /// <summary>
        /// Gets the most recent readings by Point
        /// </summary>
        /// <param name="location"></param>
        /// <param name="locationTypeParameter"></param>
        /// <param name="numberOfResults"></param>
        /// <returns></returns>
        public static DataTable GetReadingsByPoint(Guid pointId, int numberOfResults)
        {
            TReading r = TablesLogic.tReading;
            DataTable dt = r.SelectTop(
                numberOfResults,
                r.ObjectID,
                r.Reading,
                r.DateOfReading,
                r.Work.ObjectNumber.As("Work.ObjectNumber"),
                r.CreateOnBreachWork.ObjectNumber.As("CreateBreachOnWork.ObjectNumber"),
                r.CreateOnBreachWork.CurrentActivity.ObjectName.As("CreateBreachOnWork.CurrentActivity.ObjectName"))
                .Where(
                r.PointID == pointId &
                r.IsDeleted == 0)
                .OrderBy(
                r.DateOfReading.Desc);

            while (dt.Rows.Count > numberOfResults)
                dt.Rows.RemoveAt(numberOfResults);
            return dt;
        }


        /// <summary>
        /// validates that either one of the location/equipment 
        /// is specified.
        /// </summary>
        /// <returns></returns>
        public bool ValidateLocationEquipment()
        {
            if (this.LocationID != null || this.EquipmentID != null)
                return true;
            return false;
        }
    }

        
    


    /// <summary>
    /// Enumerates the different sources a reading can 
    /// be obtained from.
    /// </summary>
    public class ReadingSource
    {
        /// <summary>
        /// Indicates that the reading is entered
        /// directly through the user interface.
        /// </summary>
        public const int Direct = 0;
        
        /// <summary>
        /// Indicates that the reading is entered
        /// through a Work object.
        /// </summary>
        public const int Work = 1;

        /// <summary>
        /// Indicates that the reading is obtained
        /// automatically from an OPC server.
        /// </summary>
        public const int OPCServer = 2;

        /// <summary>
        /// Indicates that the reading is entered through PDA
        /// </summary>
        public const int PDA = 3;
    }
}

