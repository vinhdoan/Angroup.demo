//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPoint : LogicLayerSchema<OPoint>
    {
        public SchemaString OPCItemName;
        [Size(255)]
        public SchemaString Description;
        public SchemaGuid OPCDAServerID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaGuid PointTriggerID;
        public SchemaInt IsApplicableForLocation;
        public SchemaGuid LocationID;
        //public SchemaGuid LocationTypeParameterID;
        public SchemaGuid EquipmentID;
        //public SchemaGuid EquipmentTypeParameterID;
        [Default(0)]
        public SchemaInt CreateWorkOnBreach;
        public SchemaDecimal MinimumAcceptableReading;
        public SchemaDecimal MaximumAcceptableReading;
        public SchemaInt NumberOfBreachesToTriggerAction;
        [Default(0)]
        public SchemaInt NumberOfBreachesSoFar;
        [Default(1)]
        public SchemaInt CreateOnlyIfWorksAreCancelledOrClosed;
        public SchemaGuid TypeOfWorkID;
        public SchemaGuid TypeOfServiceID;
        public SchemaGuid TypeOfProblemID;
        public SchemaInt Priority;
        [Size(255)]
        public SchemaString WorkDescription;

        public SchemaInt IsIncreasingMeter;
        public SchemaDecimal Factor;
        public SchemaDecimal MaximumReading;
        public SchemaString Barcode;

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        //public TLocationTypeParameter LocationTypeParameter { get { return OneToOne<TLocationTypeParameter>("LocationTypeParameterID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        //public TEquipmentTypeParameter EquipmentTypeParameter { get { return OneToOne<TEquipmentTypeParameter>("EquipmentTypeParameterID"); } }
        public TOPCDAServer OPCDAServer { get { return OneToOne<TOPCDAServer>("OPCDAServerID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TPointTrigger PointTrigger { get { return OneToOne<TPointTrigger>("PointTriggerID"); } }
        public TReading Reading { get { return OneToMany<TReading>("PointID"); } }

    }


    /// <summary>
    /// Represents a condition-monitored point in which the 
    /// readings from any source can be tested against acceptable
    /// limits set up against this point. When the reading exceeds
    /// the acceptable limits, this can be set up to generate
    /// a Work object.
    /// <para></para>
    /// This point can also be associated with an OPC DA server,
    /// so that the OPC service can retrieve readings automatically
    /// from the OPC server.
    /// </summary>
    [Serializable]
    public abstract partial class OPoint : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the item name of the point in the OPC
        /// server.
        /// </summary>
        public abstract String OPCItemName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of this point.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// OPCDAServer table that represents the DA Server
        /// in which this point is associated with.
        /// </summary>
        public abstract Guid? OPCDAServerID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// UnitOfMeasure table that represents the DA Server
        /// in which this point is associated with.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// PointTrigger table that represents the DA Server
        /// in which this point is associated with.
        /// </summary>
        public abstract Guid? PointTriggerID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PointTrigger
        /// table that indicates the trigger parameters to be used
        /// to create the work when the reading is breaches acceptable
        /// limits.
        /// </summary>
        public abstract int? IsApplicableForLocation { get; set; }

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
        /// LocationTypeParameter table that represents 
        /// the parameter that this point represents.
        /// </summary>
        //public abstract Guid? LocationTypeParameterID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Equipment table that represents the equipment
        /// that this point is attached to. The point
        /// can only be attached to either a Location or
        /// an Equipment but not both.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// EquipmentTypeParameter table that represents 
        /// the parameter that this point represents.
        /// </summary>
        //public abstract Guid? EquipmentTypeParameterID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether
        /// a work will be created when the reading breaches
        /// the acceptable range.
        /// </summary>
        public abstract int? CreateWorkOnBreach { get; set; }

        /// <summary>
        /// [Column] Gets or sets the minimum value for 
        /// the range of acceptable values. If a reading
        /// from the point falls outside of the acceptable
        /// range, it is considered a breach.
        /// </summary>
        public abstract Decimal? MinimumAcceptableReading { get; set; }

        /// <summary>
        /// [Column] Gets or sets the maximum value for 
        /// the range of acceptable values. If a reading
        /// from the point falls outside of the acceptable
        /// range, it is considered a breach.
        /// </summary>
        public abstract Decimal? MaximumAcceptableReading { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of consecutive breaches before
        /// a Work will be created.
        /// </summary>
        public abstract int? NumberOfBreachesToTriggerAction { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of breaches so far.
        /// If the next reading is within the acceptable values,
        /// this value will be reset to zero.
        /// </summary>
        public abstract int? NumberOfBreachesSoFar { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates if
        /// a work should be created if existing works created by
        /// this point are cancelled or closed.
        /// </summary>
        public abstract int? CreateOnlyIfWorksAreCancelledOrClosed { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the code table
        /// that indicates the type of work of the Work that
        /// will be created if the readings breach the acceptable
        /// range.
        /// </summary>
        public abstract Guid? TypeOfWorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the code table
        /// that indicates the type of service of the Work that
        /// will be created if the readings breach the acceptable
        /// range.
        /// </summary>
        public abstract Guid? TypeOfServiceID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the code table
        /// that indicates the type of problem of the Work that
        /// will be created if the readings breach the acceptable
        /// range.
        /// </summary>
        public abstract Guid? TypeOfProblemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the code table
        /// that indicates the priority of the Work that
        /// will be created if the readings breach the acceptable
        /// range.
        /// </summary>
        public abstract int? Priority { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// the readings registered by this point always
        /// increases over time (like a water meter, electricity
        /// meter). 
        /// <para></para>
        /// <list>
        ///     <item>0 - Absolute reading for temperature 
        ///     sensors, vibration sensors, etc; </item>
        ///     <item>1 - Increasing reading for electrical meters,
        ///     water meters, etc; </item>
        /// </list>
        /// </summary>
        public abstract int? IsIncreasingMeter { get; set; }

        /// <summary>
        /// [Column] Gets or sets the factor that will be multiplied
        /// to the readings taken for this point.
        /// </summary>
        public abstract decimal? Factor { get; set; }

        /// <summary>
        /// [Column] Gets or sets the maximum reading that will
        /// this point can record.
        /// </summary>
        public abstract decimal? MaximumReading { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the code table
        /// that indicates the description of the Work that
        /// will be created if the readings breach the acceptable
        /// range.
        /// </summary>
        public abstract String WorkDescription { get; set; }


        public abstract String Barcode { get; set; }

        /// <summary>
        /// [One-to-One Join OPCPoint.LocationID = Location.ObjectID]
        /// Gets the OLocation object that represents the
        /// location this OPC point is associated with.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// [One-to-One Join OPCPoint.LocationTypeParameterID = LocationTypeParameter.ObjectID]
        /// Gets the OLocationTypeParameter object that represents the
        /// location parameter this OPC point is associated with.
        /// </summary>
        //public abstract OLocationTypeParameter LocationTypeParameter { get; set; }

        /// <summary>
        /// [One-to-One Join OPCPoint.EquipmentID = Equipment.ObjectID]
        /// Gets the OEquipment object that represents the
        /// equipment this OPC point is associated with.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }

        /// <summary>
        /// [One-to-One Join OPCPoint.EquipmentTypeParameterID = EquipmentTypeParameter.ObjectID]
        /// Gets the OEquipmentTypeParameter object that represents the
        /// equipment parameter this OPC point is associated with.
        /// </summary>
        //public abstract OEquipmentTypeParameter EquipmentTypeParameter { get; set; }

        /// <summary>
        /// [One-to-One Join OPCPoint.OPCDAServerID = OPCDAServer.ObjectID]
        /// Gets the OOPCDAServer object that represents that
        /// DA Server that this OPC point is associated with.
        /// </summary>
        public abstract OOPCDAServer OPCDAServer { get; set; }

        public abstract OCode UnitOfMeasure { get; set; }
        public abstract OPointTrigger PointTrigger { get; set; }

        /// <summary>
        /// Gets a list of OReading objects that captured by current Point        
        /// </summary>
        public abstract DataList<OReading> Reading { get; }

        /// <summary>
        /// Gets the text indicating whether this point is
        /// an increasing meter.
        /// </summary>
        public string IsIncreasingMeterText
        {
            get
            {
                if (IsIncreasingMeter == 0)
                    return Resources.Strings.Point_AbsoluteMeter;
                    //return "Absolute";
                else if (IsIncreasingMeter == 1)
                    return Resources.Strings.Point_IncreasingMeter;
                    //return "Increasing";
                return "";
            }
        }

        /// <summary>
        /// Gets the text indicating whether this point is
        /// applicable for location.
        /// </summary>
        public string IsApplicableForLocationText
        {
            get
            {
                if (IsApplicableForLocation == 0)
                    return Resources.Strings.Point_Equipment;
                else if (IsApplicableForLocation == 1)
                    return Resources.Strings.Point_Location;
                return "";
            }
        }

        /// <summary>
        /// Gets the text indicating the location/equipment path of this point 
        /// </summary>
        public string LocationOrEquipmentPath
        {
            get
            {
                if (IsApplicableForLocation == 0)
                    return this.Equipment.Path;
                else if (IsApplicableForLocation == 1)
                    return this.Location.Path;
                return "";
            }
        }

        /// <summary>
        /// Validates that there is no other point with the same name and under same location/equipment structure
        /// </summary>
        /// <returns></returns>
        public bool IsDuplicateName()
        { 
            TPoint pt = TablesLogic.tPoint;
            List<OPoint> list = pt.LoadList(
                pt.ObjectID != this.ObjectID & pt.ObjectName == this.ObjectName &
                (
                    (pt.LocationID == this.LocationID & pt.IsApplicableForLocation == 1) |
                    (pt.EquipmentID == this.EquipmentID & pt.IsApplicableForLocation == 0)
                ) &
                pt.IsActive == 1
            );
            foreach (OPoint i in list)
                return true;
            return false;            
        }

        ///// <summary>
        ///// Validates that there is no other point with the same
        ///// location and location type parameter.
        ///// </summary>
        ///// <returns></returns>
        //public bool ValidateNoDuplicateLocation()
        //{
        //    if (this.IsApplicableForLocation == 1 &&
        //        (int)TablesLogic.tPoint.Select(
        //        TablesLogic.tPoint.ObjectID.Count())
        //        .Where(
        //        TablesLogic.tPoint.LocationID == this.LocationID &
        //        TablesLogic.tPoint.LocationTypeParameter == this.LocationTypeParameter &
        //        TablesLogic.tPoint.ObjectID != this.ObjectID) > 0)
        //        return false;
        //    return true;
        //}


        ///// <summary>
        ///// Validates that there is no other point with the same
        ///// equipment and equipment type parameter.
        ///// </summary>
        ///// <returns></returns>
        //public bool ValidateNoDuplicateEquipment()
        //{
        //    if (this.IsApplicableForLocation == 0 &&
        //        (int)TablesLogic.tPoint.Select(
        //        TablesLogic.tPoint.ObjectID.Count())
        //        .Where(
        //        TablesLogic.tPoint.EquipmentID == this.EquipmentID &
        //        TablesLogic.tPoint.EquipmentTypeParameter == this.EquipmentTypeParameter &
        //        TablesLogic.tPoint.ObjectID != this.ObjectID) > 0)
        //        return false;
        //    return true;
        //}


        /// <summary>
        /// Validates that there is no other point with the 
        /// same OPC item name using the same OPC DA server.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNoDuplicateOPCItemName()
        {
            if (this.OPCDAServerID != null)
            {
                if (TablesLogic.tPoint.Select(
                    TablesLogic.tPoint.ObjectID.Count())
                    .Where(
                    TablesLogic.tPoint.IsDeleted == 0 &
                    TablesLogic.tPoint.OPCDAServerID == this.OPCDAServerID &
                    TablesLogic.tPoint.OPCItemName == this.OPCItemName &
                    TablesLogic.tPoint.ObjectID != this.ObjectID) > 0)
                    return false;
            }
            return true;
        }


        /// <summary>
        /// This method is called when an alarm matching the 
        /// conditions is raised.
        /// <para></para>
        /// You can override the implementation of this method
        /// to derive more functionality whenever the threshold
        /// is breached.
        /// </summary>
        public virtual void ThresholdBreached(OReading reading)
        {
        }


        /// <summary>
        /// Gets a list of points based on the given location
        /// or equipment.
        /// </summary>
        /// <param name="locationId"></param>
        /// <param name="equipmentId"></param>
        /// <returns></returns>
        public static DataTable GetPointsTable(Guid? locationId, Guid? equipmentId, Guid? includingPointId)
        {
            if (locationId != null)
            {
                return (DataTable)TablesLogic.tPoint.Select(
                    TablesLogic.tPoint.ObjectID,
                    TablesLogic.tPoint.ObjectName)
                    .Where(
                    (TablesLogic.tPoint.IsDeleted == 0 &
                    TablesLogic.tPoint.LocationID == locationId) |
                    TablesLogic.tPoint.ObjectID == includingPointId);
            }
            else
            {
                return (DataTable)TablesLogic.tPoint.Select(
                    TablesLogic.tPoint.ObjectID,
                    TablesLogic.tPoint.ObjectName)
                    .Where(
                    (TablesLogic.tPoint.IsDeleted == 0 &
                    TablesLogic.tPoint.EquipmentID == equipmentId) |
                    TablesLogic.tPoint.ObjectID == includingPointId);
            }
        }


        /// <summary>
        /// This method will return current reading of this point if applicable,
        /// otherwise null will be returned
        /// </summary>
        /// <returns></returns>
        public OReading LatestReading
        {
            get
            {
                // 2010.05.30
                // Kim Foong
                // Should return the latest reading, but only those
                // readings that have been deleted.
                //
                return
                    TablesLogic.tReading.Load(
                    TablesLogic.tReading.PointID == this.ObjectID,
                    TablesLogic.tReading.DateOfReading.Desc);
            }
        }

    }
}

