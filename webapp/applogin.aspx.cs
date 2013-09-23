using System;
using System.Globalization;
using System.Threading;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Data;
using System.Drawing;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.Design;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Collections;
using System.DirectoryServices;
using System.IO;

using Anacle.DataFramework;
using LogicLayer;
using Anacle.UIFramework;

/// <summary>
/// Summary description for applogin
/// </summary>
public partial class applogin : System.Web.UI.Page
{
    public applogin()
    {
        //
        // TODO: Add constructor logic here
        //
    }


    // KF BEGIN 2005.05.07
    /// ------------------------------------------------------------------
    /// <summary>
    /// Clear session.
    /// </summary>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        //Session.Clear();
        string[] arr = { "OriginalRequest" };
        ClearSession(arr);
    }
    // KF END

    /// ------------------------------------------------------------------
    /// <summary>
    /// Initialize the page culture.
    /// </summary>
    /// ------------------------------------------------------------------
    protected override void InitializeCulture()
    {
        string cultureName = System.Configuration.ConfigurationManager.AppSettings["LoginPage_UICulture"];
        if (cultureName == null)
            cultureName = "en-US";

        Thread.CurrentThread.CurrentCulture = new CultureInfo(cultureName);
        Thread.CurrentThread.CurrentUICulture = new CultureInfo(cultureName);

        this.Culture = Thread.CurrentThread.CurrentCulture.Name;
        this.UICulture = Thread.CurrentThread.CurrentUICulture.Name;
        
        Resources.Errors.Culture = Thread.CurrentThread.CurrentCulture;
        Resources.Messages.Culture = Thread.CurrentThread.CurrentCulture;
        Resources.Notifications.Culture = Thread.CurrentThread.CurrentCulture;
        Resources.Objects.Culture = Thread.CurrentThread.CurrentCulture;
        Resources.Roles.Culture = Thread.CurrentThread.CurrentCulture;
        Resources.Strings.Culture = Thread.CurrentThread.CurrentCulture;
        Resources.WorkflowEvents.Culture = Thread.CurrentThread.CurrentCulture;
        Resources.WorkflowStates.Culture = Thread.CurrentThread.CurrentCulture;

        LogicLayer.Global.SetCulture(Thread.CurrentThread.CurrentCulture);
        Anacle.UIFramework.Global.SetCulture(Thread.CurrentThread.CurrentCulture);

        base.InitializeCulture();
    }


    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            // Create a try catch block to prevent failure, in 
            // case the application settings object has new fields
            // has been changed, but the database have not yet
            // been updated.
            //
            try
            {
                OApplicationSetting applicationSetting = OApplicationSetting.Current;
                login.TitleText = applicationSetting.LoginTitle;
                tableLoginCell.Style["background-image"] = "url('apploginlogo.aspx?ID=" + applicationSetting.VersionNumber + "')";

                if (applicationSetting.LoginControlsHorizontalAlignment == 0)
                    tableLoginCell.Align = "left";
                else if (applicationSetting.LoginControlsHorizontalAlignment == 1)
                    tableLoginCell.Align = "center";
                else if (applicationSetting.LoginControlsHorizontalAlignment == 2)
                    tableLoginCell.Align = "right";

                if (applicationSetting.LoginControlsVerticalAlignment == 0)
                    tableLoginCell.VAlign = "top";
                else if (applicationSetting.LoginControlsVerticalAlignment == 1)
                    tableLoginCell.VAlign = "middle";
                else if (applicationSetting.LoginControlsVerticalAlignment == 2)
                    tableLoginCell.VAlign = "bottom";
            }
            catch(Exception ex)
            {
                login.Visible = false;
                panelSchemaError.Visible = true;
                labelSchemaErrorException.Text = ex.Message;
            }

            panelSql.Visible = Page.Request.Url.AbsoluteUri.StartsWith("http://localhost");
            labelLicense.ForeColor = Color.Empty;
            labelLicense.Font.Bold = false;
            try
            {
                if (Request["LICENSEERROR"] == "1")
                {
                    labelLicense.Text = "";
                    labelLicense.ForeColor = Color.Red;
                    labelLicense.Font.Bold = true;

                    login.Enabled = false;
                }
                else
                {
                    labelLicense.Text = String.Format(Resources.Messages.License_LicensedTo, 
                        "Simplism");
                    if ( !String.IsNullOrEmpty(UIPageBase.GetLicenseExpiryDate())) 
                        labelLicense.Text = labelLicense.Text + " Licence expiry date is " + Convert.ToDateTime(UIPageBase.GetLicenseExpiryDate()).ToString("dd-MMM-yyyy");
                }
            }
            catch
            {
                labelLicense.Text = String.Format(Resources.Messages.License_NotLicensed);
            }

            // See if the user is trying to log on through single sign-on
            // Windows Authentication from the browser side.
            //
            if (ConfigurationManager.AppSettings["AuthenticateWithWindowsLogon"].ToLower() == "true")
            {
                bool authenticated = false;
                if (Request.ServerVariables["LOGON_USER"] != "")
                    authenticated = Authenticate(Request.ServerVariables["LOGON_USER"], null);

                if (!authenticated)
                {
                    login.Visible = false;
                    if (Request.ServerVariables["LOGON_USER"] == "")
                    {
                        panelNoAccessNotLoggedOn.Visible = true;
                    }
                    else
                    {
                        panelNoAccess.Visible = true;
                        labelUserLoginName.Text = Request.ServerVariables["LOGON_USER"];
                    }
                }
                else
                {
                    Login1_LoggedIn(this, e);
                }
            }

            // thevinh begin: load the cookie
            //
            if (Request.Cookies["myCookie"] != null)
            {
                HttpCookie cookie = Request.Cookies.Get("myCookie");
                string userName = cookie.Values["Email"].ToString();
                string password = cookie.Values["Pass"].ToString();
                if (Authenticate(userName, password))
                    Login1_LoggedIn(this, new EventArgs());
            }
            this.Title = "Simplism";
            // the end;
        }
    }

    protected void Login1_Authenticate(object sender, AuthenticateEventArgs e)
    {
        e.Authenticated = Authenticate(login.UserName, login.Password);
    }

    //--------------------------------------------------------------------
    /// <summary>
    /// If user is active directory try to authenticate user from active directory.
    /// </summary>
    /// <param name="OUser"></param>
    //--------------------------------------------------------------------

    protected bool IsActiveDirectory(OUser user)
    {
        DirectoryEntry entry = null;
        if (user.ActiveDirectoryDomain != null && user.ActiveDirectoryDomain != string.Empty)
        {
            entry = new DirectoryEntry(OApplicationSetting.Current.ActiveDirectoryPath,
                                                      user.ActiveDirectoryDomain + "\\" + login.UserName,
                                                         login.Password);
        }
        else
        {
            entry = new DirectoryEntry(OApplicationSetting.Current.ActiveDirectoryPath,
                                                      OApplicationSetting.Current.ActiveDirectoryDomain + "\\" + login.UserName,
                                                         login.Password);
        }

        Object obj = entry.NativeObject;

        DirectorySearcher search = new DirectorySearcher(entry);

        search.Filter = "(SAMAccountName=" + login.UserName + ")";
        search.PropertiesToLoad.Add("cn");
        SearchResult result = search.FindOne();

        if (null == result)
            return false;
        return true;
    }

    //--------------------------------------------------------------------
    /// <summary>
    /// Authenticate the user
    /// </summary>
    /// <param name="loginName"></param>
    /// <param name="password"></param>
    //--------------------------------------------------------------------
    protected bool Authenticate(string loginName, string password)
    {
        //always initialize the failuretext back to the original value
        // 
        login.FailureText = this.GetLocalResourceObject("loginResource1.FailureText").ToString();

        bool auth = false;
        OUser user = null;
        try
        {
            //Session.Clear();
            string[] arr = { "OriginalRequest" };
            ClearSession(arr);
            user = OUser.GetUserByLoginName(loginName);

            if (user != null)
            {
                // If the user is banned, do not proceed.
                //
                if (user.IsBanned == 1)
                {
                    login.FailureText = Resources.Errors.User_AccountBanned;
                    return false;
                }

                //Session.Clear();                
                ClearSession(arr);
                Guid sessionId;
                if ((user.IsActiveDirectoryUser == 1 && OApplicationSetting.Current.IsUsingActiveDirectory == 1) || password == null)
                    sessionId = Security.Logon(loginName, Page.Request.UserHostAddress, Page.Request.ApplicationPath);
                else
                    sessionId = Security.Logon(loginName, password, Page.Request.UserHostAddress, Page.Request.ApplicationPath);
                Session["SessionId"] = sessionId;
                Session["User"] = user;

                auth = true;

                //call method to check if user is authenticate in active domain
                if (user.IsActiveDirectoryUser == 1 && OApplicationSetting.Current.IsUsingActiveDirectory == 1)
                {
                    try
                    {
                        return IsActiveDirectory(user);
                    }
                    catch (Exception ex)
                    {
                        login.FailureText = ex.Message;
                        auth = false;
                    }
                }

            }
        }            
        catch (LoginInvalidException)
        {
            auth = false;

            //if password supplied is wrong, update number of retries
            if (user != null)
                user.IncrementFailedLoginRetries();
        }

        if (auth)
        {
            //if successful login and login retries > 0, reset number of retries
            user.ClearLoginRetries();

            // touch all the resource files to load them up
            //
            System.Globalization.CultureInfo ci;
            ci = Resources.Errors.Culture;
            ci = Resources.Messages.Culture;
            ci = Resources.Notifications.Culture;
            ci = Resources.Objects.Culture;
            ci = Resources.Roles.Culture;
            ci = Resources.Strings.Culture;
            ci = Resources.WorkflowEvents.Culture;
            ci = Resources.WorkflowStates.Culture;

            // touch one of the logic layer tables to force ASP.NET to load
            // all objects in TablesLogic up.
            //
            TUser tUser = TablesLogic.tUser;

            // 2010.11.24
            // Li Shan
            // clean temp chart directory
            CleanTempChart();
        }
        return auth;
    }

    public static DateTime LastCacheRemovalDate
    {
        get
        {
            if (HttpContext.Current.Application["LastCacheRemovalDate"] == null)
                HttpContext.Current.Application["LastCacheRemovalDate"] = DateTime.MinValue;
            return (DateTime)HttpContext.Current.Application["LastCacheRemovalDate"];
        }
        set
        {
            HttpContext.Current.Application["LastCacheRemovalDate"] = value;
        }

    }

    protected void Login1_LoggedIn(object sender, EventArgs e)
    {
        // Clear old items in cache if necessary
        //
        if (((TimeSpan)DateTime.Now.Subtract(LastCacheRemovalDate)).TotalDays > 1)
        {
            // Remove cache items.
            //
            DiskCache.RemoveOldItems();
            LastCacheRemovalDate = DateTime.Now;

            // Clear messages and log in histories.
            //
            OApplicationSetting applicationSetting = OApplicationSetting.Current;
            OSessionAudit.ClearLoginHistory(DateTime.Now.AddDays(-applicationSetting.NumberOfDaysToKeepLoginHistory.Value));
            OMessage.ClearMessageHistory(DateTime.Now.AddDays(-applicationSetting.NumberOfDaysToKeepMessageHistory.Value));
            OBackgroundServiceLog.ClearLogHistory(DateTime.Now.AddDays(-applicationSetting.NumberOfDaysToKeepBackgroundServiceLog.Value));
            OAttachment.ClearRemovedAttachments();
        }


        // Checks if the user's password has expired or
        // a change in the password is required. If so,
        // redirect to the update password page.
        //
        OUser user = Session["User"] as OUser;
        if (ConfigurationManager.AppSettings["AuthenticateWithWindowsLogon"].ToLower() != "true" && 
            (user.HasPasswordExpired() || user.IsPasswordChangeRequired == 1))
        {
            Response.Redirect("apploginupdate.aspx", true);
        }
        else
        {
            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(login.UserName, true, 20);

            HttpCookie cookie = new HttpCookie(
                FormsAuthentication.FormsCookieName,
                FormsAuthentication.Encrypt(ticket));
            Response.Cookies.Add(cookie);

            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "CHINAOPS")
                Response.Redirect("apptop2.aspx");
            else
            {
                String requestURL = "";
                //if (Session["OriginalRequest"] != null)
                //    requestURL = Session["OriginalRequest"].ToString();
                //if (String.IsNullOrEmpty(requestURL) || requestURL.Contains("apptop.aspx"))
                    Response.Redirect("apptop.aspx");
                //else
                //    Response.Redirect(requestURL);
            }
        }
    }

    
    protected void buttonGenerateScript_Click(object sender, EventArgs e)
    {
        if (panelSql.Visible)
        {
            Response.AddHeader("content-disposition", "attachment; filename=database.sql");
            Response.Write(DatabaseSetup.GenerateSetupSQL(typeof(TablesLogic)));
            Response.End();
        }
    }


    protected void buttonGenerateScriptAuditTrail_Click(object sender, EventArgs e)
    {
        if (panelSql.Visible)
        {
            Response.AddHeader("content-disposition", "attachment; filename=database.sql");
            Response.Write(DatabaseSetup.GenerateSetupSQL(typeof(TablesAuditTrail)));
            Response.End();
        }
    }

    // 2010.11.24
    // Li Shan
    /// <summary>
    /// Cleans the temporary chart folder.
    /// </summary>
    private void CleanTempChart()
    {
        string chartDirPath = Page.Request.PhysicalApplicationPath + "temp\\charts";        
        try
        {
            DirectoryInfo chartDir = new DirectoryInfo(chartDirPath);

            if (chartDir != null)
            {
                FileInfo[] fileList = chartDir.GetFiles();

                if (fileList != null && fileList.Length > 0)
                    foreach (FileInfo f in fileList)
                    {
                        if (f.CreationTime < DateTime.Now.AddHours(-24))
                            f.Delete();
                    }
            }
        }
        catch
        {
        }

        //20120307 PTB
        //Clean temp folder as well
        string tempDirPath = Page.Request.PhysicalApplicationPath + "temp";
        try
        {
            DirectoryInfo chartDir = new DirectoryInfo(tempDirPath);

            if (chartDir != null)
            {
                FileInfo[] fileList = chartDir.GetFiles();

                if (fileList != null && fileList.Length > 0)
                    foreach (FileInfo f in fileList)
                    {
                        if (f.CreationTime < DateTime.Now.AddHours(-24))
                            f.Delete();
                    }
            }
        }
        catch
        {
        }
    }

    /// <summary>
    /// Clear Session while retaining the excluding keys
    /// </summary>
    /// <param name="excludingkey"></param>
    private void ClearSession(string[] excludingkey)
    {
        Hashtable hashtbl = new Hashtable();
        foreach (string str in excludingkey)
            hashtbl[str] = Session[str];
        Session.Clear();
        foreach (DictionaryEntry entry in hashtbl)
            Session[entry.Key.ToString()] = entry.Value != null ? entry.Value.ToString() : null;
    }
}
