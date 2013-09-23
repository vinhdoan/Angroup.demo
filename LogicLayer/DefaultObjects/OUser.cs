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
    [Database("#database"), Map("User")]
    [Serializable]
    public partial class TUser : LogicLayerSchema<OUser>
    {
        public SchemaString LanguageName;
        [Default("Corporate")]
        public SchemaString ThemeName;
        public SchemaGuid UserBaseID;
        public SchemaGuid SuperiorID;
        public SchemaGuid CraftID;

        [Default(0)]
        public SchemaInt IsPasswordChangeRequired;
        public SchemaDateTime PasswordLastChanged;
        [Default(0)]
        public SchemaInt LoginRetries;
        public SchemaInt IsBanned;



        public TUserPasswordHistory PasswordHistory { get { return OneToMany<TUserPasswordHistory>("UserID"); } }
        public TPosition Positions { get { return ManyToMany<TPosition>("UserPosition", "UserID", "PositionID"); } }
        public TUserBase UserBase { get { return OneToOne<TUserBase>("UserBaseID"); } }
        public TUser Superior { get { return OneToOne<TUser>("SuperiorID"); } }
        public TDashboard Dashboards { get { return ManyToMany<TDashboard>("UserDashboard", "UserID", "DashboardID"); } }
        public TUser Children { get { return OneToMany<TUser>("ParentID"); } }
    }


    /// <summary>
    /// Represents a user account in the system. Details
    /// about the user, including his/her contact details and login
    /// credentials can be found in the UserBase property, which
    /// is an OUserBase object.
    /// </summary>
    public abstract partial class OUser : LogicLayerPersistentObject, IAuditTrailEnabled, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets the language code that this user has selected 
        /// to be his/her default language when using the system. An example of 
        /// language codes are 'en-US', 'ja-JP', 'zh-CN', etc.
        /// </summary>
        public abstract string LanguageName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name of the theme this current user will
        /// see in the user interface when he or she uses the system.
        /// </summary>
        public abstract string ThemeName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the UserBase table that contains 
        /// a set of properties common for all users.
        /// </summary>
        public abstract Guid? UserBaseID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table that indicates 
        /// the superior of this current user.
        /// </summary>
        public abstract Guid? SuperiorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Craft table to indicate the 
        /// craft of this user. This must have a value if the current user has 
        /// 'Technician' as one of its roles.
        /// </summary>
        public abstract Guid? CraftID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag to indicate that the user's 
        /// password must be changed during the next login.
        /// </summary>
        public abstract int? IsPasswordChangeRequired { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date when password is last updated by user. 
        /// </summary>
        public abstract DateTime? PasswordLastChanged { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of attempted and unsuccessful logins by user.
        /// </summary>
        public abstract int? LoginRetries { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether
        /// this user has been banned from the system.
        /// <para></para>
        /// This can be set manually by the user administrator, or
        /// it can be set when this user's failed login attempts
        /// exceeds the configured maximum.
        /// </summary>
        public abstract int? IsBanned { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OPassword objects that represents the list 
        /// of passwords that this user has created before.
        /// </summary>
        public abstract DataList<OUserPasswordHistory> PasswordHistory { get; }

        /// <summary>
        /// Gets a many-to-many list of OPosition objects that represents a list of 
        /// positions that are assigned to this user
        /// </summary>
        public abstract DataList<OPosition> Positions { get; set; }

        /// <summary>
        /// Gets or sets the OUserBase object that represents an inherited record 
        /// containing a set of properties common for all users.
        /// </summary>
        public abstract OUserBase UserBase { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the superior of this
        /// current user.
        /// </summary>
        public abstract OUser Superior { get; set; }

        /// <summary>
        /// Gets a one-to-many list of ODashboard objects that represents the list 
        /// of dashboards that this user has access to.
        /// </summary>
        public abstract DataList<ODashboard> Dashboards { get; }

        public abstract DataList<OUser> Children { get; set;}

        public override void Created()
        {
            base.Created();
            UserBase = TablesLogic.tUserBase.Create();          // attach the user object
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Deactivate the UserBase object as well
        /// </summary>
        /// --------------------------------------------------------------
        public override void Deactivating()
        {
            base.Deactivating();
            UserBase.Deactivate();
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Get all available roles from the system.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<ORole> GetRoles()
        {
            return TablesLogic.tRole[Query.True];
        }

        /*
        /// --------------------------------------------------------------
        /// <summary>
        /// Returns a list of all active users in the system.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OUser> GetAllUsers()
        {
            return TablesLogic.tUser[Query.True];
        }
        */

        /// --------------------------------------------------------------
        /// <summary>
        /// Load the user object by the login name.
        /// </summary>
        /// <param name="loginName"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static OUser GetUserByLoginName(string loginName)
        {
            List<OUser> list = TablesLogic.tUser[TablesLogic.tUser.UserBase.LoginName == loginName & TablesLogic.tUser.IsDeleted == 0];

            if (list.Count > 0)
                return list[0];
            else
                return null;
        }


        /// <summary>
        /// Gets a list of users by roles.
        /// </summary>
        /// <param name="positions"></param>
        /// <returns></returns>
        [Obsolete]
        // TODO: Remove references to this.
        public static List<OUser> GetUsersByRole(string roleCode)
        {
            return
                TablesLogic.tUser.LoadList(
                TablesLogic.tUser.Positions.Role.RoleCode == roleCode);
        }


        /// <summary>
        /// Get a list of users with the specified role, and 
        /// tied to a location at or above the one specified.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="roleCode"></param>
        /// <returns></returns>
        public static List<OUser> GetUsersByRoleAndAboveLocation(OLocation location, string roleCode)
        {
            if (location != null)
            {
                string[] roleCodes = roleCode.Split(',');
                return TablesLogic.tUser.LoadList(
                    TablesLogic.tUser.Positions.Role.RoleCode.In(roleCodes) &
                    ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tUser.Positions.LocationAccess.HierarchyPath + "%"));
            }
            return null;
        }

        /// <summary>
        /// Get a list of users with the specified role, and 
        /// tied to a location at or above the one specified.
        /// If also adds the includedUser in the list, regardless
        /// of whether the user has been deleted or not.
        /// </summary>
        /// <param name="includedUser"></param>
        /// <param name="location"></param>
        /// <param name="roleCode"></param>
        /// <returns></returns>
        public static List<OUser> GetUsersByRoleAndAboveLocation(OUser includedUser, OLocation location, string roleCode)
        {
            if (location != null)
            {
                return TablesLogic.tUser.LoadList(
                    (includedUser != null ? TablesLogic.tUser.ObjectID == includedUser.ObjectID : Query.False) |
                    (TablesLogic.tUser.IsDeleted == 0 &
                    TablesLogic.tUser.Positions.Role.RoleCode == roleCode &
                    ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tUser.Positions.LocationAccess.HierarchyPath + "%")),
                    true);
            }
            return null;
        }

        /// <summary>
        /// Get a list of users with the specified role, and 
        /// tied to a location at or below the one specified.
        /// </summary>
        /// <param name="includedUser"></param>
        /// <param name="location"></param>
        /// <param name="roleCode"></param>
        /// <returns></returns>
        public static List<OUser> GetUsersByRoleAndBelowLocation(OUser includedUser, OLocation location, string roleCode)
        {
            if (location != null)
            {
                return TablesLogic.tUser.LoadList(
                    (includedUser != null ? TablesLogic.tUser.ObjectID == includedUser.ObjectID : Query.False) |
                    (TablesLogic.tUser.IsDeleted == 0 &
                    TablesLogic.tUser.Positions.Role.RoleCode == roleCode &
                    TablesLogic.tUser.Positions.LocationAccess.HierarchyPath.Like(location.HierarchyPath + "%")),
                    true);
            }
            return null;
        }

        /// <summary>
        /// Gets a list of users by their positions.
        /// </summary>
        /// <param name="positions"></param>
        /// <returns></returns>
        public static List<OUser> GetUsersByPositions(List<OPosition> positions)
        {
            return TablesLogic.tUser.LoadList(
                TablesLogic.tUser.Positions.ObjectID.In(positions));
        }


        /// <summary>
        /// Gets a list of users by their positions.
        /// </summary>
        /// <param name="positions"></param>
        /// <returns></returns>
        public static List<OUser> GetUsersByPositionsAndCraft(List<OPosition> positions, OCraft craft)
        {
            return GetUsersByPositionsAndCraft(positions, craft, null);
        }


        /// <summary>
        /// Gets a list of users by their positions.
        /// </summary>
        /// <param name="positions"></param>
        /// <returns></returns>
        public static List<OUser> GetUsersByPositionsAndCraft(List<OPosition> positions, OCraft craft, Guid? includingTechnicianId)
        {
            return TablesLogic.tUser.LoadList(
                ((craft == null ? TablesLogic.tUser.CraftID == null : TablesLogic.tUser.CraftID == craft.ObjectID) &
                TablesLogic.tUser.Positions.ObjectID.In(positions) &
                TablesLogic.tUser.IsDeleted == 0) |
                TablesLogic.tUser.ObjectID == includingTechnicianId,
                true);
        }


        /// <summary>
        /// Convert a single OUser object to a list of OUser object.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static implicit operator List<OUser>(OUser user)
        {
            List<OUser> userList = new List<OUser>();
            userList.Add(user);
            return userList;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Determines if the current user has been assigned the 
        /// specified role.
        /// </summary>
        /// <param name="roleId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public bool HasRole(string roleCode)
        {
            foreach (OPosition position in this.Positions)
                if (position.Role.RoleCode == roleCode)
                    return true;
            return false;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Looks in the database for any users with the same duplicate
        /// login name and user name. Returns true if found, false 
        /// otherwise.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        /*
        public bool IsDuplicateUser()
        {
            if (TablesLogic.tUser[
                (TablesLogic.tUser.ObjectName == this.ObjectName |
                TablesLogic.tUser.UserBase.LoginName == this.UserBase.LoginName) &
                TablesLogic.tUser.ObjectID != this.ObjectID].Count > 0)
                return true;

            return false;
        }
        */

        /// <summary>
        /// Gets a list of positions of this current user
        /// such that the roles of those positions
        /// have been granted access (regardless of read/write/view/delete)
        /// to the function of the specified objectType.
        /// </summary>
        /// <param name="objectType">The object type as defined in the OFunction</param>
        /// <returns></returns>
        public List<OPosition> GetPositionsByObjectTypeAndRoleCodes(string objectType, List<string> roleCodes)
        {
            List<OPosition> positions = new List<OPosition>();
            Hashtable hashRolesCodes = new Hashtable();

            foreach (string roleCode in OFunction.GetRoleCodes(objectType))
                hashRolesCodes[roleCode] = 1;
            if (roleCodes != null)
                foreach (string roleCode in roleCodes)
                    hashRolesCodes[roleCode] = 1;

            foreach (OPosition position in this.Positions)
            {
                if (hashRolesCodes[position.Role.RoleCode] != null)
                    positions.Add(position);
            }
            return positions;
        }


        /// <summary>
        /// Gets a list of positions of this current user
        /// such that the roles of those positions
        /// have been granted access (regardless of read/write/view/delete)
        /// to the function of the specified objectType.
        /// </summary>
        /// <param name="objectType">The object type as defined in the OFunction</param>
        /// <returns></returns>
        public List<OPosition> GetPositionsByObjectType(string objectType)
        {
            List<OPosition> positions = new List<OPosition>();
            Hashtable hashRolesCodes = new Hashtable();

            foreach (string roleCode in OFunction.GetRoleCodes(objectType))
                hashRolesCodes[roleCode] = 1;

            foreach (OPosition position in this.Positions)
            {
                if (hashRolesCodes[position.Role.RoleCode] != null)
                    positions.Add(position);
            }
            return positions;
        }


        /// <summary>
        /// Gets an array list of role codes currently
        /// associated with this user.
        /// </summary>
        /// <returns></returns>
        public ArrayList GetRoleCodes()
        {
            ArrayList roleCodes = new ArrayList();
            foreach (OPosition position in this.Positions)
                if (!roleCodes.Contains(position.Role.RoleCode))
                    roleCodes.Add(position.Role.RoleCode);
            return roleCodes;
        }


        /// <summary>
        /// A cache of the role functions loaded from the database.
        /// </summary>
        private string cachedObjectType = "";
        private List<ORoleFunction> cachedRoleFunctions = null;

        /// <summary>
        /// Checks if the user is allowed create/edit/delete/view 
        /// access to an object of the specified type.
        /// </summary>
        /// <param name="objectType"></param>
        /// <param name="access"></param>
        /// <returns></returns>
        protected bool AllowAccess(string objectType, string access)
        {
            ArrayList alRoleIds = new ArrayList();

            if (cachedObjectType != objectType || cachedRoleFunctions == null)
            {
                cachedObjectType = objectType;
                foreach (OPosition position in this.Positions)
                    alRoleIds.Add(position.Role.RoleCode);
                cachedRoleFunctions = TablesLogic.tRoleFunction.LoadList(
                    TablesLogic.tRoleFunction.Role.RoleCode.In(alRoleIds) &
                    TablesLogic.tRoleFunction.Function.ObjectTypeName == objectType);
            }

            foreach (ORoleFunction roleFunction in cachedRoleFunctions)
                if (roleFunction.Function.ObjectTypeName == objectType && ((int?)roleFunction.DataRow[access]) == 1)
                    return true;
            return false;
        }


        /// <summary>
        /// Checks if the user is allowed to create an object 
        /// of the specified type.
        /// </summary>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public bool AllowCreate(string objectType)
        {
            return AllowAccess(objectType, "AllowCreate");
        }


        /// <summary>
        /// Checks if the user is allowed to create an object 
        /// of the specified type.
        /// </summary>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public bool AllowDeleteAll(string objectType)
        {
            return AllowAccess(objectType, "AllowDeleteAll");
        }


        /// <summary>
        /// Checks if the user is allowed to create an object 
        /// of the specified type.
        /// </summary>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public bool AllowEditAll(string objectType)
        {
            return AllowAccess(objectType, "AllowEditAll");
        }


        /// <summary>
        /// Checks if the user is allowed to create an object 
        /// of the specified type.
        /// </summary>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public bool AllowViewAll(string objectType)
        {
            return AllowAccess(objectType, "AllowViewAll");
        }


        /// <summary>
        /// Increments the number of login retries. If the retries
        /// exceeds the maximum number of retries, then the user
        /// account will be banned.
        /// </summary>
        public void IncrementFailedLoginRetries()
        {
            using (Connection c = new Connection())
            {
                if (this.LoginRetries == null)
                    this.LoginRetries = 0;

                this.LoginRetries = this.LoginRetries + 1;
                if (OApplicationSetting.Current.PasswordMaximumTries != null &&
                    this.LoginRetries >= OApplicationSetting.Current.PasswordMaximumTries)
                    this.IsBanned = 1;

                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Sets the number of failed login retries to zero,
        /// and saves the user object.
        /// </summary>
        public void ClearLoginRetries()
        {
            using (Connection c = new Connection())
            {
                this.LoginRetries = 0;
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Checks if the current user's password has expired.
        /// </summary>
        /// <returns>Returns true if the password has expired,
        /// false otherwise.</returns>
        public bool HasPasswordExpired()
        {
            if (OApplicationSetting.Current.PasswordDaysToExpiry == null ||
                this.PasswordLastChanged == null)
                return false;

            int numberOfDaysToExpiry = OApplicationSetting.Current.PasswordDaysToExpiry.Value;
            if (this.PasswordLastChanged.Value.AddDays(numberOfDaysToExpiry) <= DateTime.Today)
                return true;

            return false;
        }


        /// <summary>
        /// Gets the user's current password age.
        /// </summary>
        /// <returns></returns>
        public int GetPasswordAge()
        {
            if (this.PasswordLastChanged == null)
                return 0;
            return ((TimeSpan)DateTime.Today.Subtract(this.PasswordLastChanged.Value)).Days;
        }


        /// <summary>
        /// Checks if the current user's password is old enough
        /// for the user to change.
        /// </summary>
        /// <returns></returns>
        public bool IsPasswordOldEnoughToChange()
        {
            int passwordAge = GetPasswordAge();

            if (OApplicationSetting.Current.PasswordMinimumAge != null &&
                passwordAge < Convert.ToInt32(OApplicationSetting.Current.PasswordMinimumAge))
                return false;
            return true;
        }


        /// <summary>
        /// Sets the new password of the user. This assumes
        /// </summary>
        /// <param name="newPassword"></param>
        public void SetNewPassword(string newPassword, bool savePasswordHistory)
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


        /// <summary>
        /// Resets the user's password by auto-generating the password.
        /// Also e-mails the reset password to the user.
        /// </summary>
        public void ResetPassword()
        {
            using (Connection c = new Connection())
            {
                string strNewPassword = GenerateRandomPassword();

                this.UserBase.LoginPassword = Security.HashString(strNewPassword);
                this.PasswordLastChanged = DateTime.Today;
                this.IsPasswordChangeRequired = 1;

                OUserPasswordHistory.EmailResetPassword(
                    this.ObjectName, this.UserBase.Email, strNewPassword);
                this.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// The different types of password characters.
        /// </summary>
        private static readonly string[] characters = {
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", 
            "1234567890",
            "!@#$%^&*.?"};


        /// <summary>
        /// Generates a random password.
        /// </summary>
        /// <returns></returns>
        public static string GenerateRandomPassword()
        {
            int intPasswordMinimumLength = Convert.ToInt32(OApplicationSetting.Current.PasswordMinimumLength);

            if (intPasswordMinimumLength < 6)
                intPasswordMinimumLength = 6;

            // Ensure that all characters of every type is created in the
            // password.
            //
            int[] characterType = new int[intPasswordMinimumLength];
            for (int i = 0; i < intPasswordMinimumLength / 3; i++)
            {
                characterType[i] = 1;
                characterType[i + intPasswordMinimumLength / 3] = 2;
            }
            Random r = new Random();
            for (int i = 0; i < intPasswordMinimumLength * 2; i++)
            {
                int pos1 = r.Next(intPasswordMinimumLength);
                int pos2 = r.Next(intPasswordMinimumLength);
                int temp = characterType[pos1];
                characterType[pos1] = characterType[pos2];
                characterType[pos2] = temp;
            }

            // Then create the password based on the order of
            // the character types in the caharacterType array.
            //
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < intPasswordMinimumLength; i++)
            {
                int type = characterType[i];
                char ch = characters[type][r.Next(characters[type].Length)];
                sb.Append(ch);
            }

            return sb.ToString();
        }


    }
}
