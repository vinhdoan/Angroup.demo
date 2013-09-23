//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;


/// <summary>
/// Summary description for UserAccount
/// </summary>

namespace LogicLayer
{

    public partial class TUser : LogicLayerSchema<OUser>
    {
        //for tenant
        [Default(0)]
        public SchemaInt isTenant;
        [Size(255)]
        public SchemaString IndustryTrade;
        [Size(255)]
        public SchemaString Website;
        public SchemaString OperationHours;
        [Size(255)]
        public SchemaString Description;
        public SchemaText TenantProfile;
        public SchemaText Highlights;
        public SchemaInt FromAmos;
        public SchemaInt AmosOrgID;
        public SchemaDateTime updatedOn;

        [Default(1)]
        public SchemaInt IsActiveDirectoryUser;
        public SchemaString ActiveDirectoryDomain;
        public SchemaInt IsShowSimplifiedRFQpage;

        public SchemaDateTime LastNotificationDate;

        public TTenantContact TenantContacts { get { return OneToMany<TTenantContact>("TenantID"); } }
        public TTenantLease TenantLeases { get { return OneToMany<TTenantLease>("TenantID"); } }
        public TCraft Craft { get { return OneToOne<TCraft>("CraftID"); } }
        public TTenantActivity TenantActivities { get { return ManyToMany<TTenantActivity>("TenantTenantActivity", "TenantID", "TenantActivityID"); } }

        public SchemaGuid TenantTypeID;
        public TCode TenantType { get { return OneToOne<TCode>("TenantTypeID"); } }

        public TUserDelegatedPosition DelegatedToOthersPositions { get { return OneToMany<TUserDelegatedPosition>("DelegatedByUserID"); } }
        public TUserDelegatedPosition DelegatedByOthersPositions { get { return OneToMany<TUserDelegatedPosition>("UserID"); } }
        public TUserPermanentPosition PermanentPositions { get { return OneToMany<TUserPermanentPosition>("UserID"); } }
    }


    /// <summary>
    /// Represents a user account in the system. Details
    /// about the user, including his/her contact details and login
    /// credentials can be found in the UserBase property, which
    /// is an OUserBase object.
    /// </summary>
    public abstract partial class OUser : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column]Gets or sets a flag to indicate that the user is tenant
        /// </summary>
        public abstract int? isTenant { get; set; }
        public abstract String IndustryTrade { get; set; }
        public abstract String Website { get; set; }
        public abstract String OperationHours { get; set; }
        public abstract String Description { get; set; }
        public abstract String TenantProfile { get; set; }
        public abstract String Highlights { get; set; }
        public abstract int? FromAmos { get; set; }
        public abstract int? AmosOrgID { get; set; }
        public abstract DateTime? updatedOn { get; set; }

        public abstract int? IsActiveDirectoryUser { get; set; }
        public abstract String ActiveDirectoryDomain { get; set; }
        public abstract int? IsShowSimplifiedRFQpage { get; set; }

        public abstract DateTime? LastNotificationDate { get; set; }

        public abstract DataList<OTenantContact> TenantContacts { get; set; }
        public abstract DataList<OTenantLease> TenantLeases { get; set; }
        public abstract OCraft Craft { get; }
        public abstract DataList<OTenantActivity> TenantActivities { get; set; }
        public abstract Guid? TenantTypeID { get; set; }
        public abstract OCode TenantType { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OUserTemporaryPosition objects that represents a list of 
        /// positions that are assigned to this user
        /// </summary>
        public abstract DataList<OUserDelegatedPosition> DelegatedToOthersPositions { get; set; }
        public abstract DataList<OUserDelegatedPosition> DelegatedByOthersPositions { get; set; }

        public abstract DataList<OUserPermanentPosition> PermanentPositions { get; set; }


        /// <summary>
        /// Returns a list of positions assigned to the users in text form.
        /// </summary>
        public string AssignedPositionNames
        {
            get
            {
                string names = "";
                foreach (OPosition position in this.Positions)
                    names += (names == "" ? "" : ", ") + position.ObjectName;
                return names;
            }
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Returns a list of all active users in the system.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OUser> GetAllUsers()
        {
            return TablesLogic.tUser.LoadList(TablesLogic.tUser.isTenant == 0);
        }

        public List<OLocation> GetAllAccessibleLocation(string locationTypeName, string objectType)
        {
            // 2010.05.28
            // Kim Foong
            // Loading from a huge location table by first finding out the LocationTypeID
            // is much faster.
            //
            Guid? locationTypeId = TablesLogic.tLocationType.Select(TablesLogic.tLocationType.ObjectID).Where(TablesLogic.tLocationType.ObjectName == locationTypeName);

            ExpressionCondition locCondition = Query.False;
            ExpressionCondition locationTypeCondition = (locationTypeName == null || locationTypeName.Trim().Length == 0) ?
                Query.True : TablesLogic.tLocation.LocationTypeID == locationTypeId;
            List<ColumnOrder> columnsOrders = new List<ColumnOrder>();
            columnsOrders.Add(TablesLogic.tLocation.Parent.ObjectName.Asc);
            columnsOrders.Add(TablesLogic.tLocation.ObjectName.Asc);

            foreach (OPosition position in this.GetPositionsByObjectType(objectType))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%");
            }

            return TablesLogic.tLocation.LoadList(locCondition & locationTypeCondition, columnsOrders.ToArray());
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="objectType"></param>
        /// <param name="includingBudgetGroupId"></param>
        /// <returns></returns>
        public List<OBudgetGroup> GetAllAccessibleBudgetGroup(string objectType, Guid? includingBudgetGroupId)
        {
            List<OPosition> positions = this.GetPositionsByObjectType(objectType);
            
            return TablesLogic.tBudgetGroup.LoadList(
                TablesLogic.tBudgetGroup.IsDeleted == 0 &
                (TablesLogic.tBudgetGroup.Positions.ObjectID.In(positions) |
                TablesLogic.tBudgetGroup.ObjectID == includingBudgetGroupId),
                true,
                TablesLogic.tBudgetGroup.ObjectName.Asc
                );
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="includedUser"></param>
        /// <param name="locations"></param>
        /// <param name="roleCode"></param>
        /// <returns></returns>
        public static List<OUser> GetUsersByRoleAndAboveLocation(OUser includedUser, List<OLocation> locations, string roleCode)
        {
            if (locations != null && locations.Count > 0)
            {
                ExpressionCondition cond = Query.True;
                foreach (OLocation location in locations)
                    cond = cond & location.HierarchyPath.Like(TablesLogic.tUser.Positions.LocationAccess.HierarchyPath + "%");


                return TablesLogic.tUser.LoadList(
                    (includedUser != null ? TablesLogic.tUser.ObjectID == includedUser.ObjectID : Query.False) |
                    (TablesLogic.tUser.IsDeleted == 0 &
                    TablesLogic.tUser.Positions.Role.RoleCode == roleCode &
                    cond),
                    true);
            }
            return null;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="email"></param>
        /// <returns></returns>
        public static List<OUser> GetUserByEmail(string email)
        {
            return TablesLogic.tUser.Load
                (TablesLogic.tUser.UserBase.Email == email
                & TablesLogic.tUser.IsDeleted == 0);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="activity"></param>
        /// <returns></returns>
        public bool IsApprovalUser(OActivity activity)
        {

            foreach (OUser approvalUser in activity.Users)
            {
                if (approvalUser.ObjectID == this.ObjectID)
                    return true;
            }
            foreach (OPosition position in activity.Positions)
            {
                foreach (OPosition userPosition in this.Positions)
                {
                    if (userPosition.ObjectID == position.ObjectID)
                        return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="tenantID"></param>
        /// <returns></returns>
        public static DataTable TenantActivityList(Guid? tenantID)
        {
            DataTable dt = Query.Select(TablesLogic.tTenantActivity.ObjectID,
                                        TablesLogic.tTenantActivity.ActivityType.ObjectName.As("ActivityType"),
                                        TablesLogic.tTenantActivity.DateTimeOfActivity,
                                        TablesLogic.tTenantActivity.NameOfStaff,
                                        TablesLogic.tTenantActivity.Agenda)
                                 .Where(TablesLogic.tTenantActivity.Tenants.ObjectID == tenantID &
                                        TablesLogic.tTenantActivity.IsDeleted == 0)
                                 .OrderBy(TablesLogic.tTenantActivity.DateTimeOfActivity.Asc);
            return dt;

        }
        public static DataTable CaseList(Guid? tenantID)
        {
            return Query.Select(TablesLogic.tCase.ObjectID,
                                TablesLogic.tCase.ObjectNumber,
                                TablesLogic.tCase.ProblemDescription,
                                TablesLogic.tCase.CurrentActivity.ObjectName.As("CaseStatus"),
                                TablesLogic.tCase.Works.ObjectNumber.As("WorkNumber"),
                                TablesLogic.tCase.Works.TypeOfWork.ObjectName.As("TypeOfWork"),
                                TablesLogic.tCase.Works.TypeOfService.ObjectName.As("TypeOfService"),
                                TablesLogic.tCase.Works.TypeOfProblem.ObjectName.As("TypeOfProblem"),
                                TablesLogic.tCase.Works.WorkDescription,
                                TablesLogic.tCase.Works.Activities.ObjectName.As("WorkStatus"))
                         .Where(TablesLogic.tCase.IsDeleted == 0 &
                                TablesLogic.tCase.Works.IsDeleted == 0 &
                                TablesLogic.tCase.RequestorID == tenantID)
                         .OrderBy(TablesLogic.tCase.ObjectNumber.Asc);
        }
        /// --------------------------------------------------------------
        /// <summary>
        /// Looks in the database for any users with the same duplicate
        /// user email. Returns true if found, false 
        /// otherwise.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool IsDuplicateUserEmail()
        {
            if (TablesLogic.tUser[
                TablesLogic.tUser.UserBase.Email == this.UserBase.Email &
                TablesLogic.tUser.ObjectID != this.ObjectID].Count > 0)
                return true;

            return false;
        }
        public override bool IsDeactivable()
        {
            if (this.FromAmos == 1)
                return false;

            return true;
        }
        public static List<OUser> GetTenantList(Guid? TenantID)
        {
            List<OUser> tenantList = TablesLogic.tUser.LoadList(TablesLogic.tUser.AmosOrgID != null);

            OUser tenant = TablesLogic.tUser.Load(TenantID);
            if (tenant != null)
                tenantList.Add(tenant);

            return tenantList;
        }

        public List<OPoint> GetPointListForReminder
        {
            get
            {
                List<OPoint> pointList = TablesLogic.tPoint.LoadList(TablesLogic.tPoint.IsActive == 1 &
                    TablesLogic.tPoint.ReadingDay == DateTime.Today.Day &
                    (TablesLogic.tPoint.ReminderUser1ID == this.ObjectID |
                    TablesLogic.tPoint.ReminderUser2ID == this.ObjectID |
                    TablesLogic.tPoint.ReminderUser3ID == this.ObjectID |
                    TablesLogic.tPoint.ReminderUser4ID == this.ObjectID), null);

                return pointList;
            }
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Returns a list of all non-tenant users in the system.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OUser> GetAllNonTenantUsers()
        {
            return TablesLogic.tUser[TablesLogic.tUser.isTenant == 0];
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Returns a list of all non-tenant users in the system,
        /// except the specified user ID.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OUser> GetAllNonTenantUsersExceptSpecified(Guid? userId)
        {
            return TablesLogic.tUser[
                TablesLogic.tUser.isTenant == 0 & 
                TablesLogic.tUser.ObjectID != userId];
        }



        /// <summary>
        /// Gets a list of case requestors, or tenants. 
        /// <para></para>
        /// For tenants, we first search all tenants in the specified
        /// location through their leases (lease status must be 'N'). 
        /// <para></para>
        /// If no tenants are found, then we show the full list of tenants.
        /// </summary>
        /// <param name="positions"></param>
        /// <returns></returns>
        public static List<OUser> GetCaseRequestorsOrTenants(OLocation location)
        {
            List<OPosition> positions = OPosition.GetPositionsByRoleAndLocation("CASEREQUESTOR", location);

            if (location != null)
            {
                List<OUser> tenants = TablesLogic.tUser.LoadList(
                    TablesLogic.tUser.TenantLeases.LocationID == location.ObjectID &
                    TablesLogic.tUser.TenantLeases.LeaseStatus == "N");

                return TablesLogic.tUser.LoadList(
                    TablesLogic.tUser.Positions.ObjectID.In(positions) |
                    (tenants.Count > 0 ?
                    TablesLogic.tUser.ObjectID.In(tenants) :
                    TablesLogic.tUser.isTenant == 1));
            }
            else
                return null;
        }

        public string IsActiveDirectoryUserText
        {
            get
            {
                return this.IsActiveDirectoryUser == 1 ? Resources.Strings.General_Yes : Resources.Strings.General_No;
            }
        }


        /*
        // 2010.07.08
        // Kim Foong
        // Position Delegation.
        /// <summary>
        /// Gets a list of valid positions applicable to this user
        /// including those delegated to this user by other users.
        /// </summary>
        public List<OPosition> ValidPositions
        {
            get
            {
                List<OPosition> positions = new List<OPosition>();

                foreach (OPosition p in this.Positions)
                    positions.Add(p);
                DateTime now = DateTime.Now;
                foreach (OUserTemporaryPosition p in this.TemporaryPositions)
                    if ((p.StartDate == null || p.StartDate.Value <= now) &&
                        (p.EndDate == null || now <= p.EndDate.Value))
                        positions.Add(p.Position);
                return positions;
            }
        }
        */

        /// <summary>
        /// This method automatically activates the current position
        /// of the user based on the permanent position list and the
        /// temporary positions list. 
        /// <para>
        /// </para>
        /// It automatically inserts records directly into the UserPosition
        /// table using SQL.
        /// </summary>
        public void ActivateAndSaveCurrentPositions()
        {
            List<Guid> ids = new List<Guid>();
            ids.Add(this.ObjectID.Value);
            OUser.ActivateAndSaveCurrentPositions(ids);

            /*
            Hashtable newPositions = new Hashtable();
            foreach (OUserPermanentPosition permPosition in this.PermanentPositions)
            {
                if ((permPosition.StartDate == null ||
                    permPosition.StartDate <= DateTime.Now) &&
                    (permPosition.EndDate == null ||
                    DateTime.Now <= permPosition.EndDate))
                    newPositions[permPosition.ObjectID.Value] = 1;
            }

            foreach (OUserDelegatedPosition tempPosition in this.DelegatedByOthersPositions)
            {
                if ((tempPosition.StartDate == null ||
                    tempPosition.StartDate <= DateTime.Now) &&
                    (tempPosition.EndDate == null ||
                    DateTime.Now <= tempPosition.EndDate))
                    newPositions[tempPosition.ObjectID.Value] = 1;
            }

            using (Connection c = new Connection())
            {
                // These updates will not be written into
                // the audit trail table.
                //
                Connection.ExecuteNonQuery("#database",
                    "DELETE FROM UserPosition WHERE UserID = @UserID",
                    Anacle.DataFramework.Parameter.Create("UserID", this.ObjectID.Value));

                foreach (Guid newPositionID in newPositions.Keys)
                {
                    Connection.ExecuteNonQuery("#database",
                        "INSERT INTO UserPosition (UserID, PositionID) VALUES (@UserID, @PositionID)",
                        Anacle.DataFramework.Parameter.Create("PositionID", newPositionID),
                        Anacle.DataFramework.Parameter.Create("UserID", this.ObjectID.Value));
                }
                c.Commit();
            }*/


        }
         


        /// <summary>
        /// This method automatically activates the current position
        /// of the user based on the permanent position list and the
        /// temporary positions list. 
        /// <para>
        /// </para>
        /// It automatically inserts records directly into the UserPosition
        /// table using SQL.
        /// </summary>
        /// <param name="userIds"></param>
        public static void ActivateAndSaveCurrentPositions(List<Guid> userIds)
        {
            using (Connection c = new Connection())
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("null");
                foreach (Guid id in userIds)
                {
                    sb.Append(",'" + id + "'");
                }
                string userIdList = "(" + sb.ToString() + ")";

                // These updates will not be written into
                // the audit trail table.
                //
                Connection.ExecuteNonQuery("#database",
                    "DELETE FROM UserPosition WHERE UserID IN " + userIdList);

                // This method simply re-constructs the UserPosition
                // table for the given user IDs.
                //
                Connection.ExecuteNonQuery("#database",
                    "INSERT INTO UserPosition (UserID, PositionID) " +
                    "SELECT UserID, PositionID FROM ( " +
                    "    SELECT UserID, PositionID FROM UserPermanentPosition WHERE IsDeleted = 0 AND UserID IS NOT NULL AND PositionID IS NOT NULL AND (StartDate IS NULL OR StartDate <= getdate()) AND (EndDate IS NULL OR EndDate >= getdate()) AND UserID IN " + userIdList + " " +
                    "    UNION " +
                    "    SELECT UserID, PositionID FROM UserDelegatedPosition WHERE IsDeleted = 0 AND UserID IS NOT NULL AND PositionID IS NOT NULL AND (StartDate IS NULL OR StartDate <= getdate()) AND (EndDate IS NULL OR EndDate >= getdate()) AND UserID IN " + userIdList + " AND DelegatedByUserID IS NOT NULL " +
                    ") t ");

                c.Commit();
            }
        }

        /// <summary>
        /// Sets the new password of the user. This assumes
        /// </summary>
        /// <param name="newPassword"></param>
        public void SetNewPasswordForCapitaLand(string newPassword, bool savePasswordHistory)
        {
            using (Connection c = new Connection())
            {
                this.UserBase.LoginPassword = Security.HashString(newPassword);
                this.PasswordLastChanged = DateTime.Today;
                this.IsPasswordChangeRequired = this.IsNew ? 1 : 0;
                this.Save();

                // If the password must be saved as a history, then save it.
                // Usually the saving of password histories is required when
                // the user or the administrator updates the password manually.
                //
                // However, when the user or administrator chooses to
                // reset the password by auto-generating a new password,
                // then this password history should NOT be saved.
                //
                if (savePasswordHistory)
                {
                    OUserPasswordHistory.AddPasswordHistory(
                        this.ObjectID.Value, this.UserBase.LoginPassword);
                    OUserPasswordHistory.ClearPasswordHistory(this.ObjectID.Value);
                }

                c.Commit();
            }
        }


        // 2010.07.10
        // Kim Foong
        public override void Saved()
        {
            base.Saved();

            if (this.isTenant == 0)
            {
                List<Guid> userIdList = new List<Guid>();

                // Deactivate the permanent position records removed
                // from this user.
                //
                List<OUserPermanentPosition> ps = TablesLogic.tUserPermanentPosition.LoadList(
                    TablesLogic.tUserPermanentPosition.UserID == null |
                    TablesLogic.tUserPermanentPosition.PositionID == null);
                foreach (OUserPermanentPosition p in ps)
                {
                    p.UserID = null;
                    p.PositionID = null;
                    p.Deactivate();
                }

                // Deactivate the delegate position records removed
                // from this user.
                //
                List<OUserDelegatedPosition> removedDelegatedPositions = TablesLogic.tUserDelegatedPosition.LoadList(
                    TablesLogic.tUserDelegatedPosition.DelegatedByUserID == null |
                    TablesLogic.tUserDelegatedPosition.UserID == null |
                    TablesLogic.tUserDelegatedPosition.PositionID == null);
                foreach (OUserDelegatedPosition removedDelegatedPosition in removedDelegatedPositions)
                {
                    if (removedDelegatedPosition.UserID != null)
                        userIdList.Add(removedDelegatedPosition.UserID.Value);

                    removedDelegatedPosition.PositionID = null;
                    removedDelegatedPosition.UserID = null;
                    removedDelegatedPosition.DelegatedByUserID = null;
                    removedDelegatedPosition.Deactivate();
                }

                // Get the list of all users in the delegate list.
                //
                foreach (OUserDelegatedPosition p in this.DelegatedToOthersPositions)
                    if (p.UserID != null)
                        userIdList.Add(p.UserID.Value);

                foreach (OUserDelegatedPosition p in this.DelegatedByOthersPositions)
                    if (p.UserID != null)
                        userIdList.Add(p.UserID.Value);

                userIdList.Add(this.ObjectID.Value);
                OUser.ActivateAndSaveCurrentPositions(userIdList);
            }
        }

        // 2010.07.10
        // Kim Foong
        /// <summary>
        /// Overrides the Deactivated method to deactivate invalid OUserPermanentPosition
        /// objects.
        /// </summary>
        public override void Deactivated()
        {
            base.Deactivated();
            using (Connection c = new Connection())
            {
                List<Guid> userIdList = new List<Guid>();
                List<OUserPermanentPosition> ps = TablesLogic.tUserPermanentPosition.LoadList(
                    TablesLogic.tUserPermanentPosition.UserID == this.ObjectID);
                foreach (OUserPermanentPosition p in ps)
                {
                    if (p.UserID != null)
                        userIdList.Add(p.UserID.Value);
                    p.UserID = null;
                    p.PositionID = null;
                    p.Deactivate();
                }


                // Deactivate the delegate position records removed
                // from this user.
                //
                List<OUserDelegatedPosition> removedDelegatedPositions = TablesLogic.tUserDelegatedPosition.LoadList(
                    TablesLogic.tUserDelegatedPosition.DelegatedByUserID == this.ObjectID |
                    TablesLogic.tUserDelegatedPosition.UserID == this.ObjectID);
                foreach (OUserDelegatedPosition removedDelegatedPosition in removedDelegatedPositions)
                {
                    if (removedDelegatedPosition.UserID != null)
                        userIdList.Add(removedDelegatedPosition.UserID.Value);

                    removedDelegatedPosition.PositionID = null;
                    removedDelegatedPosition.UserID = null;
                    removedDelegatedPosition.DelegatedByUserID = null;
                    removedDelegatedPosition.Deactivate();
                }


                // Get the list of all users in the delegate list.
                //
                foreach (OUserDelegatedPosition p in this.DelegatedToOthersPositions)
                    if (p.UserID != null)
                        userIdList.Add(p.UserID.Value);

                userIdList.Add(this.ObjectID.Value);

                OUser.ActivateAndSaveCurrentPositions(userIdList);

                c.Commit();
            }
        }

        public bool IsDuplicateUser()
        {
            if (TablesLogic.tUser[
                (TablesLogic.tUser.ObjectName == this.ObjectName |
                TablesLogic.tUser.UserBase.LoginName == this.UserBase.LoginName) &
                (TablesLogic.tUser.isTenant == null | TablesLogic.tUser.isTenant == 0) &
                TablesLogic.tUser.ObjectID != this.ObjectID].Count > 0)
                return true;

            return false;
        }

    }
}
