//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
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
    /// <summary>
    /// Summary description for OLocationType
    /// </summary>
    [Database("#database"), Map("Location")]
    [Serializable] public partial class TLocation : LogicLayerSchema<OLocation>
    {
        public SchemaString RunningNumberCode;
        public SchemaGuid LocationTypeID;
        public SchemaInt IsPhysicalLocation;
        public SchemaInt LifeSpan;
        public SchemaDateTime DateOfOwnership;
        public SchemaDecimal PriceAtOwnership;
        public SchemaDecimal GrossFloorArea;
        public SchemaDecimal NetLettableArea;

        [Size(255)]
        public SchemaString AddressCountry;
        [Size(255)]
        public SchemaString AddressState;
        [Size(255)]
        public SchemaString AddressCity;
        [Size(255)]
        public SchemaString Address;

        public SchemaString CoordinateLeft;
        public SchemaString CoordinateRight;

        public TLocation Children { get { return OneToMany<TLocation>("ParentID"); } }
        public TLocation Parent { get { return OneToOne<TLocation>("ParentID"); } }

        public TEquipment Equipment { get { return OneToMany<TEquipment>("LocationID"); } }
        public TLocationType LocationType { get { return OneToOne<TLocationType>("LocationTypeID"); } }
        public TPoint Point { get { return OneToMany<TPoint>("LocationID"); } }
        public TReading Reading { get { return OneToMany<TReading>("LocationID"); } }
        public TOPCAEEvent OPCAEEvents { get { return OneToMany<TOPCAEEvent>("LocationID"); } }


        /// <summary>
        /// Generates a condition that filters the location by the
        /// list of accessible location based on the the user's
        /// role name code.
        /// </summary>
        /// <returns></returns>
        public ExpressionCondition GetAccessibleLocationCondition(OUser user, string objectType, List<string> roleCodes)
        {
            ExpressionCondition c = Query.False;

            foreach (OPosition position in user.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
            {
                foreach (OLocation location in position.LocationAccess)
                    c = c | this.HierarchyPath.Like(location.HierarchyPath + "%");
            }
            return c;
        }

    }



    /// <summary>
    /// Represents a location or a folder of locations. 
    /// The location is a hierarchical structure that may
    /// contain the top level location and its break down of
    /// sub locations. For example, a building as a top level
    /// property may be broken down into levels, and each
    /// level may then be broken down further into rooms and units.
    /// </summary>
    public abstract partial class OLocation : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets the running number prefix
        /// of this location.
        /// </summary>
        public abstract string RunningNumberCode { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to
        /// the LocationType table.
        /// </summary>
        public abstract Guid? LocationTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether
        /// this is a folder or a physical location.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 ?Folder</item>
        /// 		<item>1 ?Physical Location</item>
        /// 	</list>
        /// </summary>
        public abstract int? IsPhysicalLocation { get; set; }

        /// <summary>
        /// [Column] Gets or sets the lifespan of the location in
        /// number of years. This is applicable only if
        /// IsPhysicalLocation = 1.
        /// </summary>
        public abstract int? LifeSpan { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the property was 
        /// acquired. This is applicable only if IsPhysicalLocation = 1.
        /// </summary>
        public abstract DateTime? DateOfOwnership { get; set; }

        /// <summary>
        /// [Column] Gets or sets the price of the property when 
        /// it was acquired. This is applicable only if 
        /// IsPhysicalLocation = 1.
        /// </summary>
        public abstract decimal? PriceAtOwnership { get; set; }

        /// <summary>
        /// [Column] Gets or sets the gross floor area of the location
        /// in square meters. This is applicable only
        /// if IsPhysicalLocation = 1.
        /// </summary>
        public abstract decimal? GrossFloorArea { get; set; }

        /// <summary>
        /// [Column] Gets or sets the net lettable area of the
        /// location in square meters. This is applicable only if
        /// IsPhysicalLocation = 1.
        /// </summary>
        public abstract decimal? NetLettableArea { get; set; }

        /// <summary>
        /// [Column] Gets or sets the address of the location.
        /// </summary>
        public abstract string AddressCountry { get; set; }

        /// <summary>
        /// [Column] Gets or sets the address of the location.
        /// </summary>
        public abstract string AddressState { get; set; }

        /// <summary>
        /// [Column] Gets or sets the address of the location.
        /// </summary>
        public abstract string AddressCity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the address of the location.
        /// </summary>
        public abstract string Address { get; set; }

        /// <summary>
        /// [Column] Gets or sets the left-coordinate of the
        /// location on the map.
        /// </summary>
        public abstract string CoordinateLeft { get; set; }

        /// <summary>
        /// [Column] Gets or sets the top-coordinate of the
        /// location on the map.
        /// </summary>
        public abstract string CoordinateRight { get; set; }


        /// <summary>
        /// Gets a list of OLocation objects representing the locations
        /// below this current one.
        /// </summary>
        public abstract DataList<OLocation> Children { get; }

        /// <summary>
        /// Gets or sets the parent location of this current location.
        /// </summary>
        public abstract OLocation Parent { get; }

        /// <summary>
        /// Gets a list of OEquipment objects that exist in this 
        /// current location.
        /// </summary>
        public abstract DataList<OEquipment> Equipment { get; }

        /// <summary>
        /// Gets a list of OPoint objects that exist in this 
        /// current location.
        /// </summary>
        public abstract DataList<OPoint> Point { get; }

        /// <summary>
        /// Gets a list of OPoint objects that exist in this 
        /// current location.
        /// </summary>
        public abstract DataList<OReading> Reading { get; }

        /// <summary>
        /// Gets or sets the OLocationType object representing 
        /// the type of this current location.
        /// </summary>
        public abstract OLocationType LocationType { get; }

        /// <summary>
        /// Gets or sets the OOPCAEEvent object representing 
        /// the type of this current location.
        /// </summary>
        public abstract DataList<OOPCAEEvent> OPCAEEvents { get; }

        /// <summary>
        /// Gets the path of the location by executing a database
        /// query against the database.
        /// </summary>
        public string FastPath
        {
            get
            {
                DataSet ds = Connection.ExecuteQuery("#database",
                    " select " +
                    " isnull(la.objectname + ' > ', '') + " +
                    " isnull(l9.objectname + ' > ', '') + " +
                    " isnull(l8.objectname + ' > ', '') + " +
                    " isnull(l7.objectname + ' > ', '') + " +
                    " isnull(l6.objectname + ' > ', '') + " +
                    " isnull(l5.objectname + ' > ', '') + " +
                    " isnull(l4.objectname + ' > ', '') + " +
                    " isnull(l3.objectname + ' > ', '') + " +
                    " isnull(l2.objectname + ' > ', '') + " +
                    " l1.objectname " +
                    " from location l1 " +
                    " left join location l2 on l1.parentid = l2.objectid " +
                    " left join location l3 on l2.parentid = l3.objectid " +
                    " left join location l4 on l3.parentid = l4.objectid " +
                    " left join location l5 on l4.parentid = l5.objectid " +
                    " left join location l6 on l5.parentid = l6.objectid " +
                    " left join location l7 on l6.parentid = l7.objectid " +
                    " left join location l8 on l7.parentid = l8.objectid " +
                    " left join location l9 on l8.parentid = l9.objectid " +
                    " left join location la on l9.parentid = la.objectid " +
                    " where l1.objectid = @ObjectID ",
                    Anacle.DataFramework.Parameter.Create("ObjectID", this.ObjectID.Value));

                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0
                    && ds.Tables[0].Rows[0][0] != DBNull.Value)
                    return (string)ds.Tables[0].Rows[0][0];
                else
                    return "";
            }
        }

        /// <summary>
        /// Disallow delete if:
        /// 1. There is at least one equipment tied to this location,
        /// 2. There is at least one work tied to this location.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (TablesLogic.tEquipment.LoadList(
                TablesLogic.tEquipment.LocationID == this.ObjectID).Count > 0)
                return false;

            if (TablesLogic.tWork.LoadList(
                TablesLogic.tWork.LocationID == this.ObjectID).Count > 0)
                return false;

            return base.IsDeactivatable();
        }



        /// <summary>
        /// Removes the attached store (as an issue location).
        /// </summary>
        public override void Deactivating()
        {
            base.Deactivating();

            OStore store = OStore.GetIssueLocation(this.ObjectID.Value);
            if (store != null)
                store.Deactivate();
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Tests if the object's parent is a cyclical reference back
        /// to itself.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public bool IsCyclicalReference()
        {
            OLocation location = this;
            while (true)
            {
                location = location.Parent;
                if (location == null)
                    return false;
                if (location.ObjectID == this.ObjectID)
                    return true;
            }
        }

        /// <summary>
        /// Validates that there is no other point with the same name and under here
        /// </summary>
        /// <returns></returns>
        public bool IsDuplicatePoint(OPoint pt)
        {
            foreach (OPoint i in this.Point)
                if (i.ObjectName == pt.ObjectName)
                    return true;
            return false;
        }

        /// <summary>
        /// Overrides the Saving method to automatically create
        /// a new Store (StoreType = Issue Location).
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            if (this.IsPhysicalLocation == 1)
            {
                OStore store = OStore.GetIssueLocation(this.ObjectID.Value);
                if (store == null)
                    store = TablesLogic.tStore.Create();
                store.LocationID = this.ObjectID;
                store.StoreType = StoreType.IssueLocation;
                store.ObjectName = this.ObjectName;
                store.Save();
            }
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get root location.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static OLocation GetRootLocation()
        {
            OLocation location = TablesLogic.tLocation.Load(
                TablesLogic.tLocation.ParentID == null);
            if (location != null)
                return location;
            else
                return null;
        }


        //---------------------------------------------------------------
        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OLocation> FindLocation(bool isPhysicalLocation, string value)
        {
            return TablesLogic.tLocation[
                TablesLogic.tLocation.IsPhysicalLocation == (isPhysicalLocation ? 1 : 0) &
                TablesLogic.tLocation.ObjectName.Like("%" + value + "%")];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get a list of locations under the current location by a specified
        /// location type
        /// </summary>
        /// <param name="?"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public List<OLocation> GetLocationByLocationType(OLocationType type)
        {
            Guid? typeId = null;
            if (type != null)
                typeId = type.ObjectID;

            return TablesLogic.tLocation[
                TablesLogic.tLocation.IsPhysicalLocation==1 &
                TablesLogic.tLocation.HierarchyPath.Like(this.HierarchyPath + "%") &
                TablesLogic.tLocation.LocationTypeID == typeId];
        }


        

        //---------------------------------------------------------------
        /// <summary>
        /// Get a distinct list of equipment types under the current 
        /// location.
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public List<OEquipmentType> GetEquipmentTypes()
        {
            return TablesLogic.tEquipmentType[
                TablesLogic.tEquipmentType.Equipment.IsPhysicalEquipment==1 &
                TablesLogic.tEquipmentType.Equipment.Location.HierarchyPath.Like(this.HierarchyPath + "%")];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get a distinct list of location types under the current 
        /// location.
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public List<OLocationType> GetLocationTypes()
        {
            return TablesLogic.tLocationType[
                TablesLogic.tLocationType.Location.IsPhysicalLocation == 1 &
                TablesLogic.tLocationType.Location.HierarchyPath.Like(this.HierarchyPath + "%")];
        }
        //201109
        /// <summary>
        /// 
        /// </summary>
        /// <param name="SurveyTargetType"></param>
        /// <param name="ExpiryDateAfterInclusive"></param>
        /// <param name="ExpiryDateBeforeExclusive"></param>
        /// <returns></returns>
        //public List<OSurveyRespondentPortfolio> GetListOfApplicableSurveyRespondentPortfolio(int? SurveyTargetType,
        //    DateTime? ExpiryDateAfterInclusive, DateTime? ExpiryDateBeforeExclusive)
        //{
        //    List<OSurveyRespondentPortfolio> list = new List<OSurveyRespondentPortfolio>();

        //    list = TablesLogic.tSurveyRespondentPortfolio.LoadList(
        //        ((ExpressionDataString)this.HierarchyPath).Like(TablesLogic.tSurveyRespondentPortfolio.Locations.HierarchyPath + "%") &
        //        //TablesLogic.tSurveyRespondentPortfolio.SurveyRespondent != null &
        //        (ExpiryDateAfterInclusive == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.ExpiryDate == null | TablesLogic.tSurveyRespondentPortfolio.ExpiryDate >= ExpiryDateAfterInclusive) &
        //        (ExpiryDateBeforeExclusive == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.ExpiryDate == null | TablesLogic.tSurveyRespondentPortfolio.ExpiryDate < ExpiryDateBeforeExclusive) &
        //        (SurveyTargetType == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.SurveyType == SurveyTargetType)
        //        , TablesLogic.tSurveyRespondentPortfolio.ObjectName.Asc);

        //    return list;
        //}

        /// <summary>
        /// 
        /// </summary>
        /// <param name="SurveyGroupID"></param>
        /// <param name="PerformancePeriodFromInclusive"></param>
        /// <param name="PerformancePeriodToExclusive"></param>
        /// <returns></returns>
        public List<OContract> GetListOfApplicableContractToBeSurveyed(Guid? SurveyGroupID,
            DateTime? PerformancePeriodFromInclusive, DateTime? PerformancePeriodToExclusive)
        {
            List<OContract> list = new List<OContract>();

            list = TablesLogic.tContract.LoadList(
                ((ExpressionDataString)this.HierarchyPath).Like(TablesLogic.tContract.Locations.HierarchyPath + "%") &
                (PerformancePeriodFromInclusive == null ? Query.True : TablesLogic.tContract.ContractEndDate >= PerformancePeriodFromInclusive) &
                (PerformancePeriodToExclusive == null ? Query.True : TablesLogic.tContract.ContractStartDate < PerformancePeriodToExclusive) &
                (SurveyGroupID == null ? Query.True : TablesLogic.tContract.SurveyGroupID == SurveyGroupID)
                , TablesLogic.tContract.ContractEndDate.Asc);

            return list;
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Get latest reading  under the current location.
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public DataTable GetPointsAndReadings()
        {
            
            DataTable dt = new DataTable();
            TPoint p = TablesLogic.tPoint;
            TReading r = TablesLogic.tReading;
            dt =
                p.Select(                
                    p.ObjectID,
                    p.ObjectName,
                    p.Description,
                    p.Location.ObjectName.As("Location"),
                    p.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                    r.SelectTop(1, r.Reading)
                    .Where(r.PointID == p.ObjectID )
                    .OrderBy(r.DateOfReading.Desc).As("Reading"),
                    r.SelectTop(1, r.DateOfReading)
                    .Where(r.PointID == p.ObjectID)
                    .OrderBy(r.DateOfReading.Desc).As("DateOfReading")
                )
                .Where
                (p.LocationID == (this.ObjectID) &
                p.IsDeleted == 0);
          
            return dt;
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get latest OPC AE Event  under the current location.
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public DataTable GetOPCAEEvent()
        {

            DataTable temp = new DataTable();
            DataTable dt = new DataTable();
            TOPCAEEventHistory h = TablesLogic.tOPCAEEventHistory;
            TOPCAEEvent e = TablesLogic.tOPCAEEvent;
                       
            // Get all point/OPCAEEvent under current location
            List<OOPCAEEvent> list = e.LoadList(e.LocationID == this.ObjectID);

            // loop through all point and get latest reading
            foreach (OOPCAEEvent i in list)
            {
                temp = e.SelectTop(1,
                    e.ObjectID,
                    e.ObjectName.As("Source"),
                    e.OPCAEEventHistory.ConditionName,
                    e.OPCAEEventHistory.SubConditionName,
                    e.OPCAEEventHistory.Severity,
                    e.OPCAEEventHistory.DateOfEvent)
                    .Where(e.ObjectID == i.ObjectID)
                    .OrderBy(e.OPCAEEventHistory.DateOfEvent.Desc);                              
                
                dt.Merge(temp);
            }           
     
            return dt;
        }

        /// <summary>
        /// Extract LocationID from location hierachy string
        /// </summary>
        /// <param name="path"></param>
        /// <returns>Guid</returns>
        public static Guid GetLocationByPath(String path)
        {
            String[] strList = path.Split('>');
            for (int i = 0; i < strList.Length; i++)
                strList[i] = strList[i].Trim();
            int locLevel = strList.Length - 1;

            List<OLocation> locList = TablesLogic.tLocation.LoadList(TablesLogic.tLocation.ObjectName == strList[locLevel]);
            if (locList.Count == 1)
                return (Guid)locList[0].ObjectID;
            else
            {
                foreach (OLocation loc in locList)
                    if (IsLocationInList(loc, strList, locLevel))
                        return (Guid)loc.ObjectID;
                return Guid.Empty;
            }            
        }

        /// <summary>
        /// Check if the location in the hierachy string
        /// </summary>
        /// <param name="loc"></param>
        /// <param name="strList"></param>
        /// <param name="locLevel"></param>
        /// <returns>Boolean</returns>
        private static Boolean IsLocationInList(OLocation loc, String[] strList, int locLevel)
        {
            // recersive call to check if the location name is in the list, start from bottom level
            // locLevel 0 is the top level of location tree
            if (locLevel == 0)
                return loc.ObjectName == strList[locLevel];
            if (loc.Parent.ObjectName != strList[locLevel - 1])
                return false;
            else            
                return IsLocationInList(loc.Parent, strList, locLevel - 1);           
        }


        /// <summary>
        /// Automatically create and add points
        /// based on the point templates set up in the
        /// location type.
        /// </summary>
        public int CreatePoints()
        {
            int count = 0;
            DataList<OLocationTypePoint> ltp = this.LocationType.LocationTypePoints;

            foreach (OLocationTypePoint i in ltp)
            {
                OPoint pt = TablesLogic.tPoint.Create();
                pt.ObjectName = i.ObjectName;
                pt.IsApplicableForLocation = 1;
                pt.UnitOfMeasureID = i.UnitOfMeasureID;
                pt.IsIncreasingMeter = i.IsIncreasingMeter;
                pt.MaximumReading = i.MaximumReading;
                pt.Factor = i.Factor;
                pt.CreateWorkOnBreach = i.CreateWorkOnBreach;
                pt.NumberOfBreachesToTriggerAction = i.NumberOfBreachesToTriggerAction;
                pt.PointTriggerID = i.PointTriggerID;
                pt.MinimumAcceptableReading = i.MinimumAcceptableReading;
                pt.MaximumAcceptableReading = i.MaximumAcceptableReading;
                pt.TypeOfWorkID = i.TypeOfWorkID;
                pt.TypeOfServiceID = i.TypeOfServiceID;
                pt.TypeOfProblemID = i.TypeOfProblemID;
                pt.Priority = i.Priority;
                pt.WorkDescription = i.WorkDescription;
                if (!this.IsDuplicatePoint(pt))
                {
                    this.Point.Add(pt);
                    count++;
                }
            }
            return count;
        }

        public string ParentFastPath
        {
            get
            {
                DataSet ds = Connection.ExecuteQuery("#database",
                    " select " +
                    " isnull(la.objectname + ' > ', '') + " +
                    " isnull(l9.objectname + ' > ', '') + " +
                    " isnull(l8.objectname + ' > ', '') + " +
                    " isnull(l7.objectname + ' > ', '') + " +
                    " isnull(l6.objectname + ' > ', '') + " +
                    " isnull(l5.objectname + ' > ', '') + " +
                    " isnull(l4.objectname + ' > ', '') + " +
                    " isnull(l3.objectname + ' > ', '') + " +
                    " isnull(l2.objectname, '')" +
                    " from location l1 " +
                    " left join location l2 on l1.parentid = l2.objectid " +
                    " left join location l3 on l2.parentid = l3.objectid " +
                    " left join location l4 on l3.parentid = l4.objectid " +
                    " left join location l5 on l4.parentid = l5.objectid " +
                    " left join location l6 on l5.parentid = l6.objectid " +
                    " left join location l7 on l6.parentid = l7.objectid " +
                    " left join location l8 on l7.parentid = l8.objectid " +
                    " left join location l9 on l8.parentid = l9.objectid " +
                    " left join location la on l9.parentid = la.objectid " +
                    " where l1.objectid = @ObjectID",
                    Anacle.DataFramework.Parameter.Create("ObjectID", this.ObjectID.Value));

                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0
                    && ds.Tables[0].Rows[0][0] != DBNull.Value)
                    return ((string)ds.Tables[0].Rows[0][0]).Replace("All Locations > ", "");
                else
                    return "";
            }
        }
    }
}