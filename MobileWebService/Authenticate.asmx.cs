using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

using Anacle.DataFramework;
using LogicLayer;

namespace Anacle.MobileWebService
{
    /// <summary>
    /// Summary description for Authenticate
    /// </summary>
    [WebService(Namespace = "http://demo.anacle.com/mobilewebservice/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class Authenticate : System.Web.Services.WebService
    {
        /// <summary>
        /// Logs the user on to the web service.
        /// </summary>
        /// <param name="applicationkey"></param>
        /// <param name="loginName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        [WebMethod]
        public GetUserData LogOn(string applicationkey, string loginName, string password)
        {
            try
            {
                Guid sessionId = Security.Logon(loginName, password, Context.Request.UserHostAddress, Context.Request.ApplicationPath);
                OUser user = OUser.GetUserByLoginName(loginName);

                GetUserData userData = new GetUserData();
                userData.ObjectName = user.ObjectName;
                userData.LoginName = user.UserBase.LoginName;
                userData.SessionKey = sessionId;

                UserSession userSession = new UserSession();
                userSession.ObjectID = user.ObjectID;
                userSession.ObjectName = user.ObjectName;
                userSession.LoginName = user.UserBase.LoginName;
                userSession.SessionKey = sessionId;
                userSession.LastAccessDateTime = DateTime.Now;

                Application[sessionId.ToString()] = userSession;

                return userData;
            }
            catch (LoginInvalidException ex)
            {
                throw new Exception(ex.Message);
            }
        }


        /// <summary>
        /// Logs the user on to the web service.
        /// </summary>
        /// <param name="applicationkey"></param>
        /// <param name="loginName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        [WebMethod]
        public List<GetUserData> LogOn2(string applicationkey, string loginName, string password)
        {
            try
            {
                Guid sessionId = Security.Logon(loginName, password, Context.Request.UserHostAddress, Context.Request.ApplicationPath);
                OUser user = OUser.GetUserByLoginName(loginName);

                GetUserData userData = new GetUserData();
                userData.ObjectName = user.ObjectName;
                userData.LoginName = user.UserBase.LoginName;
                userData.SessionKey = sessionId;

                UserSession userSession = new UserSession();
                userSession.ObjectID = user.ObjectID;
                userSession.ObjectName = user.ObjectName;
                userSession.LoginName = user.UserBase.LoginName;
                userSession.SessionKey = sessionId;
                userSession.LastAccessDateTime = DateTime.Now;

                Application[sessionId.ToString()] = userSession;

                List<GetUserData> list = new List<GetUserData>();
                list.Add(userData);

                GetUserData userData2 = new GetUserData();
                userData2.ObjectName = user.ObjectName + "2";
                userData2.LoginName = user.UserBase.LoginName + "2";
                userData2.SessionKey = sessionId;
                list.Add(userData2);

                return list;
            }
            catch (LoginInvalidException ex)
            {
                throw new Exception(ex.Message);
            }
        }


        /// <summary>
        /// Logs the user off from the web service.
        /// </summary>
        /// <param name="applicationkey"></param>
        /// <param name="loginName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        [WebMethod]
        public void LogOff(Guid sessionKey)
        {
            Security.Logoff(sessionKey);
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="displayName"></param>
        /// <param name="accountName"></param>
        /// <param name="sessionKey"></param>
        /// <returns></returns>
        [WebMethod]
        public bool CheckSession(String displayName, String accountName, Guid sessionKey)
        {
            UserSession userSession = (UserSession)Application[sessionKey.ToString()];
            if (userSession == null)
                return false;
            else if (userSession.LoginName == accountName && userSession.ObjectName == displayName && userSession.LastAccessDateTime.AddMinutes(10) >= DateTime.Now)
            {
                userSession.LastAccessDateTime = DateTime.Now;
                return true;
            }
            else
            {
                userSession = null;
                return false;
            }
        }
    }
}
