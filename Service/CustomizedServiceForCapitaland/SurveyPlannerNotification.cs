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
        public override void  OnExecute()
        {
            List<OSurveyPlanner> ListOfSurveyPlanner = TablesLogic.tSurveyPlanner[
                TablesLogic.tSurveyPlanner.CurrentActivity.ObjectName != "Draft" &
                TablesLogic.tSurveyPlanner.CurrentActivity.ObjectName != "Close" &
                TablesLogic.tSurveyPlanner.CurrentActivity.ObjectName != "Cancelled" &                
                TablesLogic.tSurveyPlanner.IsDeleted == 0
                ];
            using (Connection c = new Connection())
            {
                foreach (OSurveyPlanner SP in ListOfSurveyPlanner)
                {
                    List<OSurveyPlannerNotification> listOfSurveyReminders =
                        SP.SurveyPlannerNotifications.FindAll((sr) => 
                        sr.EmailSentDateTime == null &&
                        (sr.ScheduledDateTime == null ||
                        sr.ScheduledDateTime <= DateTime.Now));

                    foreach (OSurveyPlannerNotification SR in listOfSurveyReminders)
                    {
                        //
                        //
                        //
                        if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyStarted)
                        {
                            List<OSurvey> listOfSurveys = SP.Surveys.FindAll((s) =>
                                s.Status == (int)EnumSurveyStatusType.Open &&
                                s.SurveyInvitedDateTime == null);
                            foreach (OSurvey S in listOfSurveys)
                            {
                                S.SendSurveyEmail(SR);
                                S.SurveyInvitedDateTime = DateTime.Now;
                                S.Save();
                                SR.EmailSentDateTime = DateTime.Now;
                                SR.Save();
                            }
                            
                            c.Commit();
                        }

                        //
                        //
                        //
                        if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyNotResponded)
                        {
                            List<OSurvey> listOfSurveys = SP.Surveys.FindAll((s) =>
                                s.Status == (int)EnumSurveyStatusType.Open);
                            foreach (OSurvey S in listOfSurveys)
                            {
                                S.SendSurveyEmail(SR);
                                S.SurveyInvitedDateTime = DateTime.Now;
                                S.Save();
                                SR.EmailSentDateTime = DateTime.Now;
                                SR.Save();
                            }
                            
                            c.Commit();
                        }

                        //
                        //
                        //
                        if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyThresholdReached)
                        {
                            if (SR.SurveyThreshold != null && SR.SurveyThreshold.Value > 0 && SP.ValidateThresholdReached(SR.SurveyThreshold))
                            {
                                SP.SendEmailNotification(SR);
                                SR.EmailSentDateTime = DateTime.Now;
                                SR.Save();
                                c.Commit();
                            }
                        }

                        if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyValidityEnd)
                        {
                            if (SP.ValidEndDate != null && SP.ValidEndDate <= DateTime.Now.AddDays(SR.DaysBeforeValidEnd.Value))
                            {
                                SP.SendEmailNotification(SR);
                                SR.EmailSentDateTime = DateTime.Now;
                                SR.Save();
                                c.Commit();
                            }
                        }
                    }


                    //if (SP.ValidityEnd.Value == DateTime.Today && SP.IsValidityEndNotified == null &&
                    //    SP.ValidateThresholdReached() && SP.IsSurveyThresholdNotified == null)
                    //{
                    //    SendThresholdValidityEndNotificationEmail(SP);
                    //}
                    //else
                    //{

                    //    if (SP.ValidityEnd.Value == DateTime.Today && SP.IsValidityEndNotified == null)
                    //    {
                    //        // Send email to notify the creator that this survey planner has come to its validity end date
                    //        //
                    //        SendValidityEndNotificationEmail(SP);
                    //    }

                    //    if (SP.ValidateThresholdReached() && SP.IsSurveyThresholdNotified == null)
                    //    {
                    //        // Send email to notify the creator that this survey planner has met its threshold
                    //        //
                    //        SendThresholdNotificationEmail(SP);
                    //    }
                    //}

                    //foreach (OSurveyReminder SR in SP.SurveyReminders)
                    //{
                    //    if (SR.ReminderDate.Value == DateTime.Today && SR.EmailSentOn == null)
                    //    {
                    //        // Send email to notify the reminder recipients
                    //        //
                    //        SendReminderNotificationEmail(SP, SR);
                    //    }
                    //}
                }
            }
        }

        
        

    }
}
