//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO.Ports;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;
using System.Collections;
using System.Text.RegularExpressions;

namespace Service
{
    public partial class ReadEmailService : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            List<OEmailLog> emailList = Email.ReadEmail();
            foreach (OEmailLog email in emailList)
            {
                List<OUser> userList = OUser.GetUserByEmail(email.FromRecipient);
                OUser user = null;
                if (userList.Count == 0)
                {
                    email.UpdateEmailLog(false, "Recipient not found.");
                    //email.SendMessage("EmailApproval_UserNotFound", email.FromRecipient, null);
                }
                if (userList[0] == null)
                {
                    email.UpdateEmailLog(false, "Recipient not found.");
                    //email.SendMessage("EmailApproval_UserNotFound", email.FromRecipient, null);
                }
                else if (userList.Count > 1)
                {
                    email.UpdateEmailLog(false, "Recipient found more than 1.");
                    //email.SendMessage("EmailApproval_MoreThanOneUserFound", email.FromRecipient, null);
                }
                else
                {
                    user = userList[0];

                    String subject = email.Subject.Trim();

                    // Skip auto reply emails from Approvers (such as Out of Office)
                    OApplicationSetting appSettings = OApplicationSetting.Current;
                    if (!String.IsNullOrEmpty(appSettings.BlockedEmailSubjectKeywords))
                    {
                        bool skipThisEmail = false;

                        String[] blockedKeywordsList = appSettings.BlockedEmailSubjectKeywords.Trim().Split(';');
                        foreach (string blockedKeyword in blockedKeywordsList)
                        {
                            if (subject.Contains(blockedKeyword.Trim()))
                                skipThisEmail = true;
                        }

                        // Skip the email if its subject contains blocked keywords
                        if (skipThisEmail) continue;
                    }

                    String body = email.EmailBody.Trim();
                    subject = subject.Replace("RE:", "");
                    subject = subject.Replace("FW:", "");
                    subject = subject.Replace("Re:", "");
                    subject = subject.Replace("Fw:", "");
                    String p = "";
                    String Approve = "";
                    String Comment = "";
                    if (OApplicationSetting.Current.EmailServerType == (int)EnumReceiveEmailServerType.POP3)
                    {
                        body = Regex.Replace(body, "0A", "\n");
                        p = @"^[\s]*(?<Approve>[A|a|R|r])[\s]+(?<Comment>.*)[\s|\S|\w|\W|.]*";
                        Match m = Regex.Match(body, p);
                        Approve = m.Groups["Approve"].ToString();
                        Comment = m.Groups["Comment"].ToString();
                    }
                    else if (OApplicationSetting.Current.EmailServerType == (int)EnumReceiveEmailServerType.MicrosoftExchangeServer2007)
                    {

                        body = Regex.Replace(body, "</p>", "\n");
                        body = Regex.Replace(body, "<br>", "\n");
                        body = Regex.Replace(body, "<br/>", "\n");
                        body = Regex.Replace(body, "&nbsp;", " ");
                        body = Regex.Replace(body, @"(<style(.|\n)*?>(.|\n)*?</style>)|(<(.|\n)*?>)", string.Empty);
                        body = body.Replace("&nbsp;", "");

                        string[] bodySplit = body.Split(Environment.NewLine.ToCharArray());
                        
                        if (bodySplit.Length > 0)
                        {
                            int firstNonEmptyLine = 0;
                            for (int i = 0; i < bodySplit.Length; i++)
                                if (bodySplit[i].Trim() != "")
                                {
                                    firstNonEmptyLine = i;
                                    break;
                                }

                            string[] lineSplit = bodySplit[firstNonEmptyLine].Trim().Split(' ');
                            Approve = lineSplit[0];
                            if (Approve.ToUpper() != "A" && Approve.ToUpper() != "R")
                                Approve = "";
                            for (int i = 1; i < lineSplit.Length; i++)
                            {
                                Comment += lineSplit[i] + " ";
                            }
                        }
                    }

                    string[] delimStr = new string[] { " " };
                    string[] subjectList = subject.Trim().Split(delimStr, StringSplitOptions.None);

                    if (subjectList.Length > 0 && (Approve != "" || (Approve.ToUpper() == "A" || Approve.ToUpper() == "R")))
                    {
                        List<OActivity> activityList = TablesLogic.tActivity.LoadList
                            (TablesLogic.tActivity.TaskNumber == subjectList[0].Trim() &
                            (TablesLogic.tActivity.ObjectName.Like("PendingApproval%") |
                            TablesLogic.tActivity.ObjectName.Like("PendingCancel%")) & 
                            TablesLogic.tActivity.IsDeleted == 0);
                        if (activityList.Count > 1)
                        {
                            email.UpdateEmailLog(false, "Activity found more than 1.");
                            email.SendMessage("EmailApproval_MoreThanOneActivityFound", user.UserBase.Email, user.UserBase.Cellphone);
                        }
                        else if (activityList.Count == 0)
                        {
                            email.UpdateEmailLog(false, "Activity not found");
                            email.SendMessage("EmailApproval_ActivityNotFound", user.UserBase.Email, user.UserBase.Cellphone);
                        }
                        else
                        {
                            try
                            {
                                Type type = typeof(TablesLogic).Assembly.GetType("LogicLayer." + activityList[0].ObjectTypeName);
                                if (type != null)
                                {
                                    if (user.IsApprovalUser(activityList[0]))
                                    {
                                        LogicLayerPersistentObject obj = PersistentObject.LoadObject(type, activityList[0].AttachedObjectID.Value) as LogicLayerPersistentObject;
                                        if (obj.CurrentActivity.ObjectName.StartsWith("PendingApproval") ||
                                            obj.CurrentActivity.ObjectName.StartsWith("PendingCancel"))
                                        {
                                            using (Connection c = new Connection())
                                            {
                                                Audit.UserName = user.ObjectName;
                                                Workflow.CurrentUser = user;
                                                obj.CurrentActivity.TriggeringEventName = (Approve.ToUpper() == "A" ? "Approve" : "Reject");
                                                obj.CurrentActivity.TaskCurrentComments = Comment;
                                                obj.Save();
                                                obj.TriggerWorkflowEvent((Approve.ToUpper() == "A" ? "Approve" : "Reject"));
                                                obj.Save();
                                                c.Commit();
                                            }
                                            if (Approve.ToUpper() == "A")
                                            {
                                                email.UpdateEmailLog(true, "Approved Successfully");
                                                email.SendMessage("EmailApproval_Approved", user.UserBase.Email, user.UserBase.Cellphone);
                                            }
                                            else
                                            {
                                                email.UpdateEmailLog(true, "Rejected Successfully");
                                                email.SendMessage("EmailApproval_Rejected", user.UserBase.Email, user.UserBase.Cellphone);
                                            }
                                        }
                                        else
                                        {
                                            email.UpdateEmailLog(false, "Object not in PendingApproval state.");
                                            email.SendMessage("EmailApproval_NotInApprovalState", user.UserBase.Email, user.UserBase.Cellphone);
                                        }
                                    }
                                    else
                                    {
                                        email.UpdateEmailLog(false, "User not in approval list.");
                                        email.SendMessage("EmailApproval_UserNotInApprovalList", user.UserBase.Email, user.UserBase.Cellphone);
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                // 2010.12.28
                                // Kim Foong
                                // Gets the innermost exception.
                                // 
                                Exception currentEx = ex;
                                while (true)
                                {
                                    if (currentEx.InnerException == null)
                                        break;
                                    currentEx = currentEx.InnerException;
                                }

                                //email.UpdateEmailLog(false, ex.ToString());
                                email.UpdateEmailLog(false, currentEx.ToString());
                                email.SendMessage("EmailApproval_ErrorOccurred", user.UserBase.Email, user.UserBase.Cellphone);
                            }
                        }
                    }
                    else
                    {
                        email.UpdateEmailLog(false, "Email format not match.");
                        email.SendMessage("EmailApproval_EmailFormatNotMatch", user.UserBase.Email, user.UserBase.Cellphone);
                    }
                }
            }
        }
    }

}
