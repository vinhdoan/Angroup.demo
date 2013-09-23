//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Reflection;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using System.Workflow;
using System.Workflow.Activities;
using Anacle.WorkflowFramework;
using LogicLayer;

using Anacle.DataFramework;

    /// <summary>
    /// Summary description for Global
    /// </summary>
    public class Global : System.Web.HttpApplication
    {
        public Global()
        {
        }


        /// <summary>
        /// Occurs when a new ASP.NET session is started, that is,
        /// when a user logs on to the system through the log in page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Session_Start(object sender, EventArgs e)
        {
            if (Response.Cookies.Count > 0)
                foreach (string s in Response.Cookies.AllKeys)
                    if (s == System.Web.Security.FormsAuthentication.FormsCookieName ||
                        s.ToLower().Equals("asp.net_sessionid"))
                        Response.Cookies[s].HttpOnly = false;
        }


        /// <summary>
        /// Occurs when the application domain is started.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Application_Start(object sender, EventArgs e)
        {
            // Initialize the DataFramework
            //
            Anacle.DataFramework.Global.Initialize();

            // Initializes the workflow engine.
            //
            WorkflowEngine.Initialize();
            WorkflowEngine.Engine.StartWorkflowEngine();

            // Adds required assemblies and namespaces to the
            // dynamic class compiler.
            //
            /*
            DynamicClass.ImportedNamespaces.Clear();
            DynamicClass.ImportedNamespaces.Add("LogicLayer");
            DynamicClass.ImportedNamespaces.Add("Anacle.DataFramework");
            DynamicClass.ReferencedAssemblyLocations.Clear();
            DynamicClass.ReferencedAssemblyLocations.Add(Assembly.GetAssembly(typeof(TablesData)).Location);
            DynamicClass.ReferencedAssemblyLocations.Add(Assembly.GetAssembly(typeof(TablesLogic)).Location);
            */

        }


        /// <summary>
        /// Occurs when the application is ended.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Application_End(object sender, EventArgs e)
        {
            // Stops and cleans up the workflow engine.
            //
            WorkflowEngine.Engine.StopWorkflowEngine();
        }


        /// <summary>
        /// Occurs when there is an unhandled exception.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Application_Error(object sender, EventArgs e)
        {
            // Code that runs when an unhandled error occurs

            Exception ex = Server.GetLastError();
            if (ex is OutOfMemoryException)
            {
                HttpRuntime.UnloadAppDomain();
                Response.Redirect(Request.ApplicationPath + "/applogin.aspx");
                return;
            }
            if (ex.InnerException != null && ex.InnerException is OutOfMemoryException)
            {
                HttpRuntime.UnloadAppDomain();
                Response.Redirect(Request.ApplicationPath + "/applogin.aspx");
                return;
            }
            
            //// Send email to notify support
            //try
            //{
            //    Exception objErr = Server.GetLastError().GetBaseException();
            //    string err = "";
            //    err = err + DateTime.Now.ToString("dd-MMM-yyyy HH:mm:ss") + "\n";
            //    err = err + "Error in:" + Request.Url.ToString() + "\n";
            //    err = err + "Error Message:" + objErr.Message.ToString() + "\n";
            //    err = err + "Stack Trace:" + objErr.StackTrace.ToString() + "\n";

            //    System.Web.Mail.SmtpMail.Send("chinweng.yong@hein-consulting.com",
            //        "EM System Error",
            //        "Error in Application", AppSession.User.ObjectName + "\r\n" + err);
            //}
            //catch { }
        }


        /// <summary>
        /// Occurs at the beginning of every request.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="E"></param>
        void Application_BeginRequest(Object sender, EventArgs E)
        {
            Response.AddHeader("pragma", "no-cache");
        }


        /// <summary>
        /// Occurs at the end of every request.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Application_EndRequest(object sender, EventArgs e)
        {
            if (Response.Cookies.Count > 0)
            {
                foreach (string s in Response.Cookies.AllKeys)
                {
                    Response.Cookies[s].HttpOnly = false;
                }
            }
        }


        /// <summary>
        /// Authenticate the user
        /// </summary>
        /// <param name="loginName"></param>
        /// <param name="password"></param>
        protected void Authenticate(string loginName)
        {
            Session.Clear();
            Guid sessionId = Security.Logon(loginName, "", "");
            Session["SessionId"] = sessionId;
            Session["User"] = LogicLayer.OUser.GetUserByLoginName(loginName);
        }


        /// <summary>
        /// Occurs when ASP.NET acquires the current state (for example, session state) 
        /// that is associated with the current request.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="E"></param>
        void Application_AcquireRequestState(Object sender, EventArgs E)
        {
            // This automatically authenticates the super administrator user
            // into the system so that we can perform stress testing
            // using a specific user account.
            //
            if (System.Configuration.ConfigurationManager.AppSettings["LoadTesting"] == "true")
            {
                if (Request.FilePath.IndexOf("applogin.aspx") < 0 && Request.FilePath.IndexOf(".axd") < 0)
                {
                    if (HttpContext.Current.Session == null || HttpContext.Current.Session["SessionId"] == null)
                        Authenticate("sa");
                }
            }

            // Set the current users to null
            //
            Audit.UserName = null;
            Workflow.CurrentUser = null;
            
            if (
                Request.FilePath.IndexOf("adlogin.aspx") < 0 &&
                Request.FilePath.IndexOf("applogin.aspx") < 0 &&
                Request.FilePath.IndexOf("apploginreset.aspx") < 0 &&
                Request.FilePath.IndexOf("apploginlogo.aspx") < 0 &&
                Request.FilePath.IndexOf(".axd") < 0)
            {
                // then we check for session time out
                //
                if (HttpContext.Current.Session == null || 
                    HttpContext.Current.Session["SessionId"] == null)
                {
                    if (!Request.FilePath.Contains("service/") &&
                        !Request.FilePath.Contains("/appmwlogoutpopup.aspx") &&
                        !Request.FilePath.Contains("/surveyformload.aspx"))
                    {
                        Session["OriginalRequest"] = Request.RawUrl;
                        Response.Redirect(Request.ApplicationPath + "/applogin.aspx");
                    }
                }
                else
                {
                    if (AppSession.User != null)
                    {
                        Audit.UserName = AppSession.User.ObjectName;
                        Workflow.CurrentUser = AppSession.User;
                    }
                }
            }
                
        }
    }

