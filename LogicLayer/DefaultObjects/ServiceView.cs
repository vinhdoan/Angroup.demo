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
using System.ServiceProcess;
using System.Security.Principal;
using System.ComponentModel;


namespace LogicLayer
{
    /// <summary>
    /// Views all existing EAM services.
    /// </summary>
    public class ServiceView
    {       
        /// <summary>
        /// Retrieves all existing EAM services currently installed on system.
        /// </summary>
        /// <returns></returns>
        public static DataTable ViewWindowsService()
        {
            ServiceController[] services;

            DataTable serviceInfo = new DataTable();
            serviceInfo.Columns.Add("Service Name");
            serviceInfo.Columns.Add("Service Display Name");
            serviceInfo.Columns.Add("Service Status");

            try
            {
                services = ServiceController.GetServices();
                String[] nameList = GetEamServiceName();
                if(nameList != null)
                foreach (ServiceController service in services)
                {
                    if (IsEamServiceName(service.DisplayName, nameList))
                    {
                        DataRow row = serviceInfo.NewRow();
                        row["Service Name"] = service.ServiceName;
                        row["Service Display Name"] = service.DisplayName;
                        row["Service Status"] = TranslateServiceStatus(service.Status);
                        serviceInfo.Rows.Add(row);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return serviceInfo;
        }

        /// <summary>
        /// Maps the status of eam service to value specified in resources.
        /// </summary>
        /// <param name="status"></param>
        /// <returns></returns>
        public static String TranslateServiceStatus(ServiceControllerStatus status)
        {
            if (status == ServiceControllerStatus.Running)
                return Resources.Strings.EAMservice_Running;
            if (status == ServiceControllerStatus.Stopped)
                return Resources.Strings.EAMservice_Stop;
            if (status == ServiceControllerStatus.ContinuePending)
                return Resources.Strings.EAMservice_ContinuePending;
            if (status == ServiceControllerStatus.Paused)
                return Resources.Strings.EAMservice_Paused;
            if (status == ServiceControllerStatus.PausePending)
                return Resources.Strings.EAMservice_PausePending;
            if (status == ServiceControllerStatus.StartPending)
                return Resources.Strings.EAMservice_StartPending;
            if (status == ServiceControllerStatus.StopPending)
                return Resources.Strings.EAMservice_StopPending;
            return "";
        }

        /// <summary>
        /// Starts eam service specified by service name by using access right of the user impersonated by system.
        /// </summary>
        /// <param name="serviceName"></param>
        /// <param name="timeout"></param>
        /// <param name="user"></param>
        public void StartService(string serviceName, TimeSpan timeout,ImpersonateUser user)
        {
            WindowsImpersonationContext impersonateUser = StartImpersonateUser(user);

            ServiceController service = new ServiceController(serviceName);
            if (service.Status == ServiceControllerStatus.Stopped)
                try
                {
                    service.Start();

                }
                catch (Exception ex)
                {
                     throw new Exception(ex.Message);
                }

            StopImpersonateUser(impersonateUser);

            try
            {
                service.WaitForStatus(ServiceControllerStatus.Running, timeout);
            }
            catch (System.ServiceProcess.TimeoutException)
            {
                throw new Exception("service did not respond to the start command in a timely manner");
            }
        }

        /// <summary>
        /// Stops eam service specified by service name by using access right of the user impersonated by system.
        /// </summary>
        /// <param name="serviceName"></param>
        /// <param name="timeout"></param>
        /// <param name="user"></param>
        public void StopService(string serviceName, TimeSpan timeout, ImpersonateUser user)
        {
            WindowsImpersonationContext impersonateUser = StartImpersonateUser(user);

            ServiceController service = new ServiceController(serviceName);
            if (service.Status == ServiceControllerStatus.Running)
                if (service.CanStop)
                {
                    try
                    {
                        service.Stop();
                    }
                    catch (Exception ex)
                    {
                        throw new Exception(ex.Message);
                    }
                }

            //Stop impersonating the user.
            StopImpersonateUser(impersonateUser);

            try
            {
                service.WaitForStatus(ServiceControllerStatus.Running, timeout);    
            }
            catch (System.ServiceProcess.TimeoutException)
            {
                throw new Exception("service did not respond to the stop command in a timely manner");
            }
        }

        [System.Runtime.InteropServices.DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool LogonUser(String lpszUsername, String lpszDomain, String lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr logonToken);

        /// <summary>
        /// if logon user has role as administrator, return token for this user
        /// else return 0
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static bool IsAuthorizedUser(ImpersonateUser user)
        {
            bool check = false;
            IntPtr logonToken = new IntPtr(0);
            bool b = LogonUser(user.username, user.domain, user.password, user.logontype, 0, ref logonToken);
            if (b)
            {
                WindowsIdentity identity = new WindowsIdentity(logonToken);
                WindowsPrincipal principal = new WindowsPrincipal(identity);
                if (principal.IsInRole(WindowsBuiltInRole.Administrator))
                    check = true;
            }
            return check;
        }

        /// <summary>
        /// Impersonates the authorized user.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static WindowsImpersonationContext StartImpersonateUser(ImpersonateUser user)
        {
            IntPtr logonToken = new IntPtr(0);
            WindowsImpersonationContext impersonatedUser = null;

            bool b = LogonUser(user.username, user.domain, user.password, user.logontype, 0, ref logonToken);

            if (b)
            {
                try
                {
                    WindowsIdentity windowsIdentity = new WindowsIdentity(logonToken);

                    // Create a WindowsImpersonationContext object by impersonating the Windows identity.                
                    impersonatedUser = windowsIdentity.Impersonate();
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
            }
            
            return impersonatedUser;
        }

        /// <summary>
        /// Stops impersonating authorized user.
        /// </summary>
        /// <param name="user"></param>
        public static void StopImpersonateUser(WindowsImpersonationContext user)
        {
            user.Undo();
        }

        /// <summary>
        /// Retrieves eam services names specified by EAMservice key.
        /// </summary>
        /// <returns></returns>
        public static String[] GetEamServiceName()
        {
            String[] names = null;
            string name = System.Configuration.ConfigurationManager.AppSettings["EAMservice"];
            if (name != "")
                names = name.Split(';');

            return names;
        }

        /// <summary>
        /// Checks service name against the list of eam service names.
        /// </summary>
        /// <param name="name"></param>
        /// <param name="list"></param>
        /// <returns></returns>
        public static bool IsEamServiceName(String name, String[] list)
        {
            for (int i = 0; i < list.Length; i++)
            {
                if (name.Equals(list[i]))
                {
                    return true;
                    break;
                }
            }
            return false;
        }
    }

    /// <summary>
    /// Info of user to be impersonated.
    /// </summary>
    public class ImpersonateUser
    {
        public string username;
        public string password;
        public string domain;
        public int logontype;
    }
}
