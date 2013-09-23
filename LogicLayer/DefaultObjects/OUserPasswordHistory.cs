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
using System.Text.RegularExpressions;
using System.Text;

using Anacle.DataFramework;


/// <summary>
/// Summary description for Password
/// </summary>

namespace LogicLayer
{
    [Database("#database"), Map("Password")]
    [Serializable] public partial class TUserPasswordHistory : LogicLayerSchema<OUserPasswordHistory>
    {
        public SchemaString LoginPassword;
        public SchemaGuid UserID;

        public TUser Owner { get { return OneToOne<TUser>("UserID"); } }
    }  

    [Serializable] public abstract partial class OUserPasswordHistory : LogicLayerPersistentObject
    {
        /// <summary>
        /// Gets or sets the hashed Password string.
        /// </summary>
        public abstract string LoginPassword { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table that contains 
        /// a set of properties common for all users.
        /// </summary>
        public abstract Guid? UserID { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the superior of this
        /// current user.
        /// </summary>
        public abstract OUser Owner { get; set; }

        public void DeletePassword()
        {
            //OBase objBase = TablesLogic.tBase.Load(this.BaseID);
            //objBase.Delete();
            this.Delete();
        }


        /// <summary>
        /// Checks if the password exists in the password history
        /// table for the specified user. Returns true if it exists,
        /// false otherwise.
        /// </summary>
        /// <param name="userID"></param>
        /// <param name="hashedPassword"></param>
        /// <returns>Returns true if the password exists,
        /// false otherwise.</returns>
        public static bool DoesPasswordExist(Guid userID, string hashedPassword)
        {
            List<OUserPasswordHistory> list = TablesLogic.tUserPasswordHistory[TablesLogic.tUserPasswordHistory.UserID == userID & TablesLogic.tUserPasswordHistory.LoginPassword == hashedPassword];

            if (list.Count > 0)
                return true;
            else
                return false;
        }


        /// <summary>
        /// Adds a new password history.
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="newHashedPassword"></param>
        public static void AddPasswordHistory(Guid userId, string newHashedPassword)
        {
            using (Connection c = new Connection())
            {
                OUserPasswordHistory oPwd = TablesLogic.tUserPasswordHistory.Create();
                oPwd.LoginPassword = newHashedPassword;
                oPwd.UserID = userId;
                oPwd.Save();

                c.Commit();
            }
        }


        /// <summary>
        /// Clears password history of user conforms to the 
        /// PasswordHistoryKept.
        /// </summary>
        public static void ClearPasswordHistory(Guid userID)
        {
            List<OUserPasswordHistory> list = TablesLogic.tUserPasswordHistory[
                TablesLogic.tUserPasswordHistory.UserID == userID, 
                TablesLogic.tUserPasswordHistory.CreatedDateTime.Asc];
            if (list.Count > 0)
            {                
                int intPasswordHistoryKept = OApplicationSetting.Current.PasswordHistoryKept == null ? 0 :
                    Convert.ToInt32(OApplicationSetting.Current.PasswordHistoryKept);
                if (list.Count > intPasswordHistoryKept)
                {
                    int intPasswordToDelete = (list.Count - intPasswordHistoryKept);

                    // This physically deletes the password history
                    // from the history table.
                    //
                    using (Connection c = new Connection())
                    {
                        for (int rec = 0; rec < intPasswordToDelete; rec++)
                            ((OUserPasswordHistory)list[rec]).DeletePassword();
                        c.Commit();
                    }
                }
            }
        }

        /// <summary>
        /// Checks to ensure that the password adheres to the
        /// password complexity policy as set up in the
        /// application settings.
        /// </summary>
        /// <param name="loginPassword"></param>
        /// <returns></returns>
        public static bool ValidatePasswordCharacters(string loginPassword)
        {
            OApplicationSetting applicationSetting = OApplicationSetting.Current;

            // Any password is accepted.
            //
            if (applicationSetting.PasswordRequiredCharacters == 0)
            {
                return true;
            }

            // Alpha numeric password.
            //
            else if (applicationSetting.PasswordRequiredCharacters == 1)
            {
                return 
                    Regex.IsMatch(loginPassword, "[a-zA-Z]+") &&
                    Regex.IsMatch(loginPassword, "[0-9]+");
            }

            // Alpha numeric password with a special character
            //
            else if (applicationSetting.PasswordRequiredCharacters == 2)
            {
                return
                    Regex.IsMatch(loginPassword, "[^a-zA-Z0-9]+") &&
                    Regex.IsMatch(loginPassword, "[a-zA-Z]+") &&
                    Regex.IsMatch(loginPassword, "[0-9]+");
            }

            return true;
        }


        /// <summary>
        /// Sends an e-mail with the reset password to the user.
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="emailAddress"></param>
        /// <param name="unhashedPassword"></param>
        public static void EmailResetPassword(string userName, string emailAddress, string unhashedPassword)
        {
            OMessage.SendMail(emailAddress,
                OApplicationSetting.Current.MessageEmailSender,
                Resources.Notifications.User_ResetPasswordSubject,
                String.Format(Resources.Notifications.User_ResetPasswordBody, userName, unhashedPassword),
                false);
        }   
    }
}
