using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;
using System.Threading;

using Anacle.DataFramework;
using LogicLayer;
using Anacle.WorkflowFramework;

namespace Service
{
    public class Common
    {
        /// <summary>
        /// Logs a message into the background service log
        /// </summary>
        /// <param name="logMessage"></param>
        public static void LogEvent(string logMessage, String serviceName)
        {
            LogEvent(logMessage, BackgroundLogMessageType.Information, serviceName);
        }

        /// <summary>
        /// Logs a message into the background service log
        /// </summary>
        /// <param name="logMessage"></param>
        public static void LogEvent(string logMessage, BackgroundLogMessageType messageType, String serviceName)
        {
            int retries = 100;

            do
            {
                try
                {
                    using (TransactionScope t = new TransactionScope(TransactionScopeOption.Suppress))
                    {
                        using (Connection c = new Connection())
                        {
                            OBackgroundServiceLog log = TablesLogic.tBackgroundServiceLog.Create();
                            log.ServiceName = GlobalService.ServiceName + ": " + serviceName;
                            log.MessageType = (int)messageType;
                            log.Message = logMessage;
                            log.Save();
                            c.Commit();
                            return;
                        }
                    }
                }
                catch (Exception e)
                {
                    //ensure that this method does not throw any kind of exception.
                    if (retries <= 0) throw e;
                    else Thread.Sleep(1000); //wait for 1 second before retrying
                }
            } while (retries-- > 0);

        }

        /// <summary>
        /// Logs an exception into the background service log.
        /// </summary>
        /// <param name="exception"></param>
        public static void LogException(string logMessage, Exception exception, String serviceName)
        {
            Exception currentException = exception;
            StringBuilder sb = new StringBuilder();
            sb.Append("Unhandled exception:\n\n");
            while (currentException != null)
            {
                sb.Append(currentException.Message + "\n" + currentException.StackTrace + "\n\n");
                currentException = currentException.InnerException;
            }
            LogEvent(logMessage + "\n\n" + sb.ToString(), BackgroundLogMessageType.Error, serviceName);
            SendEmailOnError(logMessage + "\n\n" + sb.ToString(), null);

        }

        /// <summary>
        /// Send an email directly thru SMTP when there is an error.
        /// </summary>
        /// <param name="exception"></param>
        public static void SendEmailOnError(String message, String serviceName)
        {
            bool sendemail = true;

            //if (serviceName != null && serviceName != "")
            //{
            //    OBackgroundServiceRun bsr = TablesLogic.tBackgroundServiceRun.Load(TablesLogic.tBackgroundServiceRun.ServiceName == serviceName);

            //    if (bsr != null)
            //    {
            //        if (bsr.SentEmailDateTime.Value.Date < DateTime.Today)
            //        {
            //            using (Connection c = new Connection())
            //            {
            //                bsr.SentEmailDateTime = DateTime.Now;
            //                bsr.Save();
            //                c.Commit();
            //            }
            //        }
            //        else
            //            sendemail = false;
            //    }
            //}

            if (sendemail)
            {
                //send email to admin
                OApplicationSetting applicationSetting = OApplicationSetting.Current;
                MessageService ms = new MessageService();
                string sender = applicationSetting.MessageEmailSender;
                string recipient = applicationSetting.BackgroundServiceAdminEmail;
                string subject = String.Format(Resources.Notifications.BackgroundService_FailureEmail_Subject, serviceName);
                string body = String.Format(Resources.Notifications.BackgroundService_FailureEmail_Body, serviceName, message);

                try
                {
                    OMessage.SendMail("thaibinh.pham@anacle.com;malcolm.lau@capitaland.com", sender, subject, body);

                    using (Connection c = new Connection())
                    {
                        OMessage m = TablesLogic.tMessage.Create();

                        m.ScheduledDateTime = DateTime.Now;
                        m.MessageType = "EMAIL";
                        m.Message = body;
                        m.Recipient = recipient;
                        m.Header = subject;
                        m.Sender = sender;
                        m.IsHtmlEmail = 0;
                        m.NumberOfTries = 1;
                        m.IsSuccessful = 1;
                        m.ErrorMessage = "Sent E-mail successfully";
                        m.SentDateTime = DateTime.Now;

                        m.Save();
                        c.Commit();
                    }
                }
                catch (Exception e)
                {
                    using (Connection c = new Connection())
                    {
                        OMessage m = TablesLogic.tMessage.Create();

                        m.ScheduledDateTime = DateTime.Now;
                        m.MessageType = "EMAIL";
                        m.Message = body;
                        m.Recipient = recipient;
                        m.Header = subject;
                        m.Sender = sender;
                        m.IsHtmlEmail = 0;
                        m.NumberOfTries = 1;
                        m.IsSuccessful = 0;
                        m.ErrorMessage = e.ToString();
                        m.SentDateTime = DateTime.Now;

                        m.Save();
                        c.Commit();
                    }
                }

            }
        }
    }
}
