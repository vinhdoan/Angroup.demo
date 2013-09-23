using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"),Map("Position")]
    public partial class TPosition: LogicLayerSchema<OPosition>
    {
        public SchemaGuid RoleID;
        public SchemaInt AppliesToAllTypeOfServices;

        public TRole Role { get { return OneToOne<TRole>("RoleID"); } }

        public TLocation LocationAccess { get { return ManyToMany<TLocation>("PositionLocation", "PositionID", "LocationID"); } }
        public TEquipment EquipmentAccess { get { return ManyToMany<TEquipment>("PositionEquipment", "PositionID", "EquipmentID"); } }
        public TCode TypesOfServiceAccess { get { return ManyToMany<TCode>("PositionTypeOfService", "PositionID", "TypeOfServiceID"); } }
        public TUser Users { get { return ManyToMany<TUser>("UserPosition", "PositionID", "UserID"); } }

    }

    public abstract partial class OPosition : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// <summary>
        /// Gets or sets Foreign key to the Role table
        /// </summary>
        public abstract Guid? RoleID { get; set;}

        /// <summary>
        /// Gets or sets the value that indicates 
        /// if the assignment applies to a task of any type of service
        /// </summary>
        public abstract int? AppliesToAllTypeOfServices {get; set;}
        
        /// <summary>
        /// Gets or sets many-to-many list of OLocation objects that 
        /// represents the locations that this position is assigned to.
        /// </summary>
        public abstract DataList<OLocation> LocationAccess { get; set;}

        /// <summary>
        /// Gets or sets many-to-many list of OEquipment objects that 
        /// represents the equipments that this position is assigned to.
        /// </summary>
        public abstract DataList<OEquipment> EquipmentAccess { get; set;}

        /// <summary>
        /// Gets or sets many-to-many list of OCode objects that 
        /// represents the type of services
        /// </summary>
        public abstract DataList<OCode> TypesOfServiceAccess { get; set;}

        /// <summary>
        /// Gets or sets a many-to-many list of OUser objects that 
        /// represents the users assigned to the position
        /// </summary>
        public abstract DataList<OUser> Users {get; set;}

        /// <summary>
        /// Gets or sets the ORole object that represents
        /// the role that this position applies to
        /// </summary>
        public abstract ORole Role {get; set;}


        /// <summary>
        /// Disallow delete if:
        /// 1. The position is currently assigned a task.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            int count = TablesLogic.tActivity.Select(
                TablesLogic.tActivity.Positions.ObjectID.Count())
                .Where(
                TablesLogic.tActivity.Positions.ObjectID == this.ObjectID);

            if (count > 0)
                return false;

            return true;
        }


        /// <summary>
        /// creates a OPosition object having:
        /// - ObjectName as same as the name specified by positionName
        /// - topmost location and equipment
        /// - ApplicableToAllTypeOfServices is set to true
        /// </summary>
        /// <param name="positionName"></param>
        /// <returns></returns>
        public static OPosition CreatePosition(string positionName, Guid? roleId)
        {
            if (positionName == "")
                positionName = "Default";

            OPosition position = TablesLogic.tPosition.Create();

            position.ObjectName = positionName;

            // 2010.07.21
            // Kim Foong
            // Bug fix to add in the role's ID.
            //
            position.RoleID = roleId;
            position.AppliesToAllTypeOfServices = 1;
            position.LocationAccess.Add(OLocation.GetRootLocation());
            position.EquipmentAccess.Add(OEquipment.GetRootEquipment());

            position.Save();

            return position;
        }

        /// <summary>
        /// Returns list of all active positions in the system
        /// </summary>
        /// <returns></returns>
        public static List<OPosition> GetAllPositions()
        {
            return TablesLogic.tPosition[Query.True];
        }

        /// <summary>
        /// Gets a list of positions associtated with the specified roleNameCode
        /// </summary>
        /// <param name="roleCodeName"></param>
        /// <returns></returns>
        public static List<OPosition> GetPositionsByRoleCode(params string[] roleNameCode)
        {
            return TablesLogic.tPosition.LoadList(TablesLogic.tPosition.Role.RoleCode.In(roleNameCode));
        }

        /// <summary>
        /// Gets a list of positions associated with the specified user and 
        /// roleNameCode
        /// </summary>
        /// <param name="user"></param>
        /// <param name="roleNameCode"></param>
        /// <returns></returns>
        public static List<OPosition> GetPositionsByUserByRoleCode(OUser user, params string[] roleNameCode)
        {
            if(user!=null)
                return TablesLogic.tPosition.LoadList(
                    TablesLogic.tPosition.Users.ObjectID == user.ObjectID &
                    TablesLogic.tPosition.Role.RoleCode.In(roleNameCode));
            else
                return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get positions by type of service, location and the role code
        /// </summary>
        /// <param name="typeOfService"></param>
        /// <param name="location"></param>
        /// <param name="roleNameCode"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OPosition> GetPositionsByTypeOfServiceAndLocation(OCode typeOfService, OLocation location, string roleNameCode)
        {
            if (location != null && typeOfService != null)
            {
                return TablesLogic.tPosition[
                    ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tPosition.LocationAccess.HierarchyPath + "%") &
                    TablesLogic.tPosition.TypesOfServiceAccess.ObjectID == typeOfService.ObjectID &
                    TablesLogic.tPosition.Role.RoleCode == roleNameCode];
            }
            else
                return null;
        }
        

        /// --------------------------------------------------------------
        /// <summary>
        /// Get positions by role code and assigned location
        /// </summary>
        /// <param name="roleNameCode"></param>
        /// <param name="location"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OPosition> GetPositionsByRoleAndLocation(string roleNameCode, OLocation location)
        {
            if (location != null)
                return TablesLogic.tPosition[
                    ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tPosition.LocationAccess.HierarchyPath + "%") &
                    TablesLogic.tPosition.Role.RoleCode == roleNameCode];
            else
                return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get all positions by craft and location.
        /// </summary>
        /// <param name="craft"></param>
        /// <param name="location"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OPosition> GetPositionsByCraftAndLocation(OCraft craft, OLocation location)
        {
            if (location != null && craft != null)
            {
                return TablesLogic.tPosition[
                    ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tPosition.LocationAccess.HierarchyPath + "%") &
                    TablesLogic.tPosition.Users.CraftID == craft.ObjectID];
            }
            else
                return null;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get a list of positions by type of service, location and the role name.
        /// </summary>
        /// <param name="craft"></param>
        /// <param name="typeOfService"></param>
        /// <param name="location"></param>
        /// <param name="roleNameCode"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OPosition> GetPositionsByTypeOfServiceLocationAndRole(OCode typeOfService, OLocation location, string roleNameCode)
        {
            if (typeOfService != null && location != null)
            {
                return TablesLogic.tPosition[
                    ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tPosition.LocationAccess.HierarchyPath + "%") &
                    (TablesLogic.tPosition.AppliesToAllTypeOfServices == 1 |
                    TablesLogic.tPosition.TypesOfServiceAccess.ObjectID == typeOfService.ObjectID) &
                    TablesLogic.tPosition.Role.RoleCode == roleNameCode];
            }
            else
                return null;
        }


        /// <summary>
        /// Gets a list of positions by roles and persistent object.
        /// </summary>
        /// <param name="roles"></param>
        /// <param name="logicLayerPersistentObject"></param>
        /// <returns></returns>
        public static List<OPosition> GetPositionsByRoleCodesAndObject(LogicLayerPersistentObjectBase logicLayerPersistentObject, params string[] roleCodes)
        {
            ArrayList roleCodesList = new ArrayList();
            if (roleCodes != null)
                foreach (string roleCode in roleCodes)
                    roleCodesList.Add(roleCode.Trim());

            List<OLocation> taskLocations = logicLayerPersistentObject.TaskLocations;
            List<OEquipment> taskEquipments = logicLayerPersistentObject.TaskEquipments;

            TPosition p = TablesLogic.tPosition;
            TPosition p1 = new TPosition();

            ExpressionCondition conditionLocation = Query.True;
            if (taskLocations != null)
                foreach (OLocation taskLocation in taskLocations)
                    if (taskLocation != null)
                        conditionLocation &= p1.Select(p1.ObjectID).Where(p.ObjectID == p1.ObjectID &
                            taskLocation.HierarchyPath.Like(p1.LocationAccess.HierarchyPath + "%")).Exists();

            ExpressionCondition conditionEquipment = Query.True;
            if (taskEquipments != null)
                foreach (OEquipment taskEquipment in taskEquipments)
                    if (taskEquipment != null)
                        conditionEquipment &= p1.Select(p1.ObjectID).Where(p.ObjectID == p1.ObjectID &
                            taskEquipment.HierarchyPath.Like(p1.EquipmentAccess.HierarchyPath + "%")).Exists();

            return TablesLogic.tPosition.LoadList(
                TablesLogic.tPosition.Role.RoleCode.In(roleCodesList) &
                conditionLocation &
                conditionEquipment &

                // 2010.04.23
                // Fixes a bug that failed to check the AppliesToAllTypeOfServices
                // flag when selecting positions to assign to the
                // workflow.
                //
                (logicLayerPersistentObject.TaskTypeOfService == null ? Query.True :
                (TablesLogic.tPosition.AppliesToAllTypeOfServices == 1 |
                TablesLogic.tPosition.TypesOfServiceAccess.ObjectID == logicLayerPersistentObject.TaskTypeOfService.ObjectID)));
        }


        /// <summary>
        /// Gets a list of positions that are assigned to
        /// or below the specified list of locations.
        /// </summary>
        /// <param name="locations"></param>
        /// <returns></returns>
        public static List<OPosition> GetPositionsAtOrBelowLocations(List<OLocation> locations)
        {
            ExpressionCondition cond = Query.False;
            TPosition p = TablesLogic.tPosition;
            TPosition p1 = new TPosition();

            foreach (OLocation location in locations)
                cond = cond | p1.LocationAccess.HierarchyPath.Like(location.HierarchyPath+"%");

            return p.LoadList(
                p1.Select(p1.LocationAccess.ObjectID.Count()).Where(p1.ObjectID == p.ObjectID) ==
                p1.Select(p1.LocationAccess.ObjectID.Count()).Where(p1.ObjectID == p.ObjectID & cond), 
                p.ObjectName.Asc
                );
        }

        /// <summary>
        /// Gets a list of positions that are assigned to
        /// or below the specified list of locations, and the
        /// position's roles belong to the specified list of roles.
        /// </summary>
        /// <param name="locations"></param>
        /// <returns></returns>
        public static List<OPosition> GetPositionsAtOrBelowLocations(List<OLocation> locations, List<ORole> assignableRoles)
        {
            ExpressionCondition cond = Query.False;
            TPosition p = TablesLogic.tPosition;
            TPosition p1 = new TPosition();

            foreach (OLocation location in locations)
                cond = cond | p1.LocationAccess.HierarchyPath.Like(location.HierarchyPath + "%");

            return p.LoadList(
                p.RoleID.In(assignableRoles) &
                p1.Select(p1.LocationAccess.ObjectID.Count()).Where(p1.ObjectID == p.ObjectID) ==
                p1.Select(p1.LocationAccess.ObjectID.Count()).Where(p1.ObjectID == p.ObjectID & cond),
                p.ObjectName.Asc
                );
        }



        public static List<OPosition> ToPositionList(DataList<OPosition> positions)
        {
            List<OPosition> list = new List<OPosition>();
            foreach (OPosition position in positions)
                list.Add(position);
            return list;
        }
    }
}
