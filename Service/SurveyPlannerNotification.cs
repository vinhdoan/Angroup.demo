//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
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

namespace Service
{
    public partial class SurveyPlannerNotification : AnacleServiceBase
    {

        /// <summary>
        /// Executes the service.
        /// </summary>
        //public override void  OnExecute()
        //{
        //    List<OSurveyPlanner> ListOfSurveyPlanner = TablesLogic.tSurveyPlanner[
        //        TablesLogic.tSurveyPlanner.CurrentActivity.ObjectName != "Draft" &
        //        TablesLogic.tSurveyPlanner.CurrentActivity.ObjectName != "Close" &
        //        TablesLogic.tSurveyPlanner.CurrentActivity.ObjectName != "Cancelled" &                
        //        TablesLogic.tSurveyPlanner.IsDeleted == 0
        //        ];

        //    foreach (OSurveyPlanner SP in ListOfSurveyPlanner)
        //    {
        //        if (SP.ValidityEnd.Value == DateTime.Today && SP.IsValidityEndNotified == null &&
        //            SP.ValidateThresholdReached() && SP.IsSurveyThresholdNotified == null)
        //        {
        //            SendThresholdValidityEndNotificationEmail(SP);
        //        }
        //        else
        //        {

        //            if (SP.ValidityEnd.Value == DateTime.Today && SP.IsValidityEndNotified == null)
        //            {
        //                // Send email to notify the creator that this survey planner has come to its validity end date
        //                //
        //                SendValidityEndNotificationEmail(SP);
        //            }

        //            if (SP.ValidateThresholdReached() && SP.IsSurveyThresholdNotified == null)
        //            {
        //                // Send email to notify the creator that this survey planner has met its threshold
        //                //
        //                SendThresholdNotificationEmail(SP);
        //            }
        //        }

        //        foreach (OSurveyReminder SR in SP.SurveyReminders)
        //        {
        //            if (SR.ReminderDate.Value == DateTime.Today && SR.EmailSentOn == null)
        //            {
        //                // Send email to notify the reminder recipients
        //                //
        //                SendReminderNotificationEmail(SP, SR);
        //            }
        //        }
        //    }
        //}

        private void SendThresholdValidityEndNotificationEmail(OSurveyPlanner SP)
        {
            //create email  
            string SystemURL = System.Configuration.ConfigurationManager.AppSettings["SystemURL"];
            string EmailSubject = String.Format(Resources.Notifications.SurveyPlanner_ThresholdValidityEndNotification_Subject, String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim());
            string EmailBody = String.Format(Resources.Notifications.SurveyPlanner_ThresholdValidityEndNotification_Body,
                SystemURL, SP.ObjectName, SP.SurveyTypeText, SP.PerformancePeriodFrom.Value.ToString("dd-MMM-yyyy"), SP.PerformancePeriodTo.Value.ToString("dd-MMM-yyyy"),
                SP.ValidityStart.Value.ToString("dd-MMM-yyyy"), SP.ValidityEnd.Value.ToString("dd-MMM-yyyy"), SP.SurveyThreshold.Value.ToString("#,##0.00"));
            string EmailRecipient = "";

            //send email
            using (Connection c = new Connection())
            {
                if (SP.Creator != null && SP.Creator.UserBase != null &&
                    SP.Creator.UserBase.Email != null && SP.Creator.UserBase.Email.Trim().Length > 0)
                {
                    EmailRecipient = SP.Creator.UserBase.Email;
                    OMessage.SendMail(EmailRecipient, OApplicationSetting.Current.MessageEmailSender, EmailSubject, EmailBody);
                    LogEvent("Survey Planner threshold validity end notification email sent out to users " + EmailRecipient + " for Survey Planner " + SP.ObjectName + "(" + String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim() + ").");
                }
                SP.IsValidityEndNotified = 1;
                SP.IsSurveyThresholdNotified = 1;
                SP.Save();
                c.Commit();
            }
        }

        private void SendValidityEndNotificationEmail(OSurveyPlanner SP)
        {
            //create email  
            string SystemURL = System.Configuration.ConfigurationManager.AppSettings["SystemURL"];
            string EmailSubject = String.Format(Resources.Notifications.SurveyPlanner_ValidityEndNotification_Subject, String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim());
            string EmailBody = String.Format(Resources.Notifications.SurveyPlanner_ValidityEndNotification_Body,
                SystemURL, SP.ObjectName, SP.SurveyTypeText, SP.PerformancePeriodFrom.Value.ToString("dd-MMM-yyyy"), SP.PerformancePeriodTo.Value.ToString("dd-MMM-yyyy"),
                SP.ValidityStart.Value.ToString("dd-MMM-yyyy"), SP.ValidityEnd.Value.ToString("dd-MMM-yyyy"), SP.SurveyThreshold.Value.ToString("#,##0.00"));
            string EmailRecipient = "";

            //send email
            using (Connection c = new Connection())
            {
                if (SP.Creator != null && SP.Creator.UserBase != null &&
                    SP.Creator.UserBase.Email != null && SP.Creator.UserBase.Email.Trim().Length > 0)
                {
                    EmailRecipient = SP.Creator.UserBase.Email;
                    OMessage.SendMail(EmailRecipient, OApplicationSetting.Current.MessageEmailSender, EmailSubject, EmailBody);
                    LogEvent("Survey Planner validity end notification email sent out to users " + EmailRecipient + " for Survey Planner " + SP.ObjectName + "(" + String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim() + ").");
                }
                SP.IsValidityEndNotified = 1;
                SP.Save();
                c.Commit();
            }
        }

        private void SendThresholdNotificationEmail(OSurveyPlanner SP)
        {
            //create email  
            string SystemURL = System.Configuration.ConfigurationManager.AppSettings["SystemURL"];
            string EmailSubject = String.Format(Resources.Notifications.SurveyPlanner_ThresholdNotification_Subject, String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim());
            string EmailBody = String.Format(Resources.Notifications.SurveyPlanner_ThresholdNotification_Body,
                SystemURL, SP.ObjectName, SP.SurveyTypeText, SP.PerformancePeriodFrom.Value.ToString("dd-MMM-yyyy"), SP.PerformancePeriodTo.Value.ToString("dd-MMM-yyyy"),
                SP.ValidityStart.Value.ToString("dd-MMM-yyyy"), SP.ValidityEnd.Value.ToString("dd-MMM-yyyy"), SP.SurveyThreshold.Value.ToString("#,##0.00"));

            string EmailRecipient = "";

            //send email
            using (Connection c = new Connection())
            {
                if (SP.Creator != null && SP.Creator.UserBase != null &&
                    SP.Creator.UserBase.Email != null && SP.Creator.UserBase.Email.Trim().Length > 0)
                {
                    EmailRecipient = SP.Creator.UserBase.Email;
                    OMessage.SendMail(EmailRecipient, OApplicationSetting.Current.MessageEmailSender, EmailSubject, EmailBody);
                    LogEvent("Survey Planner threshold notification email sent out to users " + EmailRecipient + " for Survey Planner " + SP.ObjectName + "(" + String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim() + ").");
                }
                SP.IsSurveyThresholdNotified = 1;
                SP.Save();
                c.Commit();
            }
        }

        private void SendReminderNotificationEmail(OSurveyPlanner SP, OSurveyReminder SR)
        {
            //create email  
            string SystemURL = System.Configuration.ConfigurationManager.AppSettings["SystemURL"];
            string EmailSubject = String.Format(Resources.Notifications.SurveyPlanner_ThresholdNotification_Subject, String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim());
            string EmailBody = String.Format(Resources.Notifications.SurveyPlanner_ThresholdNotification_Body,
                SystemURL, SP.ObjectName, SP.SurveyTypeText, SP.PerformancePeriodFrom.Value.ToString("dd-MMM-yyyy"), SP.PerformancePeriodTo.Value.ToString("dd-MMM-yyyy"),
                SP.ValidityStart.Value.ToString("dd-MMM-yyyy"), SP.ValidityEnd.Value.ToString("dd-MMM-yyyy"), SP.SurveyThreshold.Value.ToString("#,##0.00"));

            string EmailRecipient = "";

            //send email
            using (Connection c = new Connection())
            {
                if (SP.Creator != null && SP.Creator.UserBase != null &&
                    SP.Creator.UserBase.Email != null && SP.Creator.UserBase.Email.Trim().Length > 0)
                {
                    EmailRecipient = SR.EmailList;
                    OMessage.SendMail(EmailRecipient, OApplicationSetting.Current.MessageEmailSender, EmailSubject, EmailBody);
                    LogEvent("Survey Planner reminder notification email sent out to users " + EmailRecipient + " for Survey Planner " + SP.ObjectName + "(" + String.Format((SP.SurveyFormTitle1 != null ? SP.SurveyFormTitle1 : "") + " " + (SP.SurveyFormTitle2 != null ? SP.SurveyFormTitle2 : "")).Trim() + ").");
                    SR.EmailSentOn = DateTime.Now;
                    SR.Save();
                }

                SP.Save();
                c.Commit();
            }
        }
        

    }
}
