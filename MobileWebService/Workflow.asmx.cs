using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace Anacle.MobileWebService
{
    /// <summary>
    /// Summary description for Inbox
    /// </summary>
    [WebService(Namespace = "http://www.anacle.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class Workflow : System.Web.Services.WebService
    {
        /// <summary>
        /// Get a list of activities that are currently assigned to the logged on user.
        /// </summary>
        /// <param name="sessionKey"></param>
        /// <returns></returns>
        [WebMethod]
        public List<GetActivityData> GetActivitiesAssignedToMe(string sessionKey)
        {
            return null;
        }
    }
}
