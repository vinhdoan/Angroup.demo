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
using System.Data.Sql;
using System.Data.SqlClient;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

using Anacle.DataFramework;
using LogicLayer;
using System.Collections;


namespace Service
{
    public partial class MessageService : AnacleServiceBase
    {
        /// ================================================================
        /// <summary>
        /// This is called on a regular interval, depending on the interval
        /// set in the configuration file.
        /// </summary>
        /// ================================================================
        public override void OnExecute()
        {
            HandleMessages();
        }



        /// ================================================================
        /// <summary>
        /// Send an SMS message through the COM port.
        /// </summary>
        /// <param name="message"></param>
        /// ================================================================
        public bool ReceiveSMSMessage(out string sender, out string message)
        {
            sender = "";
            message = "";
            //return false;
            return SmsCommunication.Receive(out sender, out message);
        }



        /// ================================================================
        /// <summary>
        /// Send an SMS message through the COM port.
        /// </summary>
        /// <param name="message"></param>
        /// ================================================================
        public void SendSMSMessage(string recipient, string message)
        {
            if (OApplicationSetting.Current.SMSSendType == (int)EnumSMSSendType.SMSDirectToModem)
            {
                if (OApplicationSetting.Current.MessageSmsComPort.Trim() == "")
                {
                    LogEvent("SMS not sent as the COM Port is not configured");
                    return;
                }
                SmsCommunication.Send(recipient, message);
            }
            else if (OApplicationSetting.Current.SMSSendType == (int)EnumSMSSendType.SMSRelayWSURL && 
                OApplicationSetting.Current.SMSRelayWSURL.Trim() != "")
            {
                // Instead of sending it directly to the modem on a serial
                // port, we send it over a HTTP URL (via querystring).
                // 
                // The receiving web page can then implement its own
                // way of sending the SMS out to the recipient.
                //
                WebRequest webRequest = HttpWebRequest.Create(
                    String.Format(
                    OApplicationSetting.Current.SMSRelayWSURL,
                    HttpUtility.UrlEncode(recipient),
                    HttpUtility.UrlEncode(message)));
                webRequest.Timeout = 30000;
                WebResponse webResponse = webRequest.GetResponse();
                webResponse.Close();

            }
            else if (OApplicationSetting.Current.SMSSendType == (int)EnumSMSSendType.SMSRelayVisualGSM)
            {
                using (SqlConnection c = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["VisualGSM"].ToString()))
                {
                    c.Open();
                    using (SqlTransaction t = c.BeginTransaction())
                    {
                        ExecuteNonQuery(c, t,
                            "INSERT INTO LOGLOG (DESTINATION,CONTENT) VALUES ('" + recipient + "','" + message + "')");
                        t.Commit();
                    }
                    c.Close();
                }
            }
            else if (OApplicationSetting.Current.SMSSendType == (int)EnumSMSSendType.SMSDirectToModem)
            {
                Process p = new Process();
                string output = "";

                // Redirect the output stream of the child process. 
                p.StartInfo.UseShellExecute = false;
                p.StartInfo.RedirectStandardOutput = true;
                p.StartInfo.Arguments = String.Format(OApplicationSetting.Current.SMSCommandLineArguments, recipient, "\"" + message.Replace("\"", "'") + "\"");
                p.StartInfo.FileName = OApplicationSetting.Current.SMSCommandLinePath;
                p.StartInfo.WorkingDirectory = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
                p.Start();

                p.WaitForExit(10000);

                int kye = 0;
                while (kye < 5)
                {
                    string currentOutput = p.StandardOutput.ReadLine();
                    output += currentOutput + "\n"; ;
                    kye++;

                    if (currentOutput == "")
                        break;
                    if (currentOutput.Contains("TASKCOMPLETE"))
                        break;
                }

                // Free resources associated with process.
                p.Close();

                // If the SMS was not reported to be sent
                // successfully by the command line app,
                // we throw an error.
                //
                if (!output.Contains("SENDSUCCESS"))
                    throw new Exception(output);
            }
        }

        /// ================================================================
        /// <summary>
        /// Rachel. Send an email through the SMTP server, using text format
        /// </summary>
        /// <param name="message"></param>
        /// ================================================================
        public void SendEmailMessage(string senderEmail, string recipientEmail, string header, string message)
        {
            SendEmailMessage(senderEmail, recipientEmail, header, message, false, null);
        }

        /// ================================================================
        /// <summary>
        /// Send an email through the SMTP server, using HTML format
        /// </summary>
        /// <param name="message"></param>
        /// ================================================================
        public void SendEmailMessage(string senderEmail, string recipientEmails, string header, string message, 
            bool isHTMLBody, List<OMessageAttachment> messageAttachments)
        {
            
            if (applicationSetting.MessageSmtpServer == "")
            {
                LogEvent("Email not sent as the SMTP server is not configured");
                return;
            }

            SmtpClient c = new SmtpClient(applicationSetting.MessageSmtpServer, applicationSetting.MessageSmtpPort.Value);

            if (applicationSetting.MessageSmtpRequiresAuthentication == (int)EnumApplicationGeneral.Yes)
            {
                //Rachel Bug fix. Set password, and username
                NetworkCredential credential = new NetworkCredential();
                credential.Password = Security.Decrypt(applicationSetting.MessageSmtpServerPassword);
                credential.UserName = applicationSetting.MessageSmtpServerUserName;
                c.Credentials = credential;
            }
            
            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(senderEmail, "");
            foreach (object rep in GetListOfEmailAddress(recipientEmails))
                mail.To.Add(new MailAddress(rep.ToString(), ""));

            // FIX: 2011.05.30, Kim Foong, replaces the special dash character with the standard "-" character.
            // This prevents the .Net mail component from convert to UTF-8 encoding unnecessarily.
            //mail.Subject = header;
            mail.Subject = header.Replace("?", "-");
            mail.Body = message;
            mail.IsBodyHtml = isHTMLBody;

            // 2010.09.03
            // Kim Foong
            // Sends e-mail attachments
            //
            if (messageAttachments != null)
            {
                foreach (OMessageAttachment messageAttachment in messageAttachments)
                {
                    System.IO.MemoryStream ms = new System.IO.MemoryStream(messageAttachment.FileBytes);
                    ms.Position = 0;
                    Attachment attachment = new Attachment(ms, messageAttachment.Filename);
                    mail.Attachments.Add(attachment);
                }
            }

            c.Send(mail);
        }

        /// ================================================================
        /// <summary>
        /// Send an email through the SMTP server, using HTML format
        /// 2011.10.14, Kien Trung
        /// Added Carbon Copy recipients and Priority
        /// </summary>
        /// <param name="message"></param>
        /// ================================================================
        public void SendEmailMessage(string senderEmail, string recipientEmails, string ccRecipientEmails, string header, string message,
            bool isHTMLBody, int? emailPriority, List<OMessageAttachment> messageAttachments)
        {

            if (applicationSetting.MessageSmtpServer == "")
            {
                LogEvent("Email not sent as the SMTP server is not configured");
                return;
            }

            SmtpClient c = new SmtpClient(applicationSetting.MessageSmtpServer, applicationSetting.MessageSmtpPort.Value);

            if (applicationSetting.MessageSmtpRequiresAuthentication == (int)EnumApplicationGeneral.Yes)
            {
                //Rachel Bug fix. Set password, and username
                NetworkCredential credential = new NetworkCredential();
                credential.Password = Security.Decrypt(applicationSetting.MessageSmtpServerPassword);
                credential.UserName = applicationSetting.MessageSmtpServerUserName;
                c.Credentials = credential;
            }

            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(senderEmail, "");
            foreach (object rep in GetListOfEmailAddress(recipientEmails))
                mail.To.Add(new MailAddress(rep.ToString(), ""));

            if (ccRecipientEmails != null)
                foreach (object ccRep in GetListOfEmailAddress(ccRecipientEmails))
                    mail.CC.Add(new MailAddress(ccRep.ToString(), ""));

            // FIX: 2011.05.30, Kim Foong, replaces the special dash character with the standard "-" character.
            // This prevents the .Net mail component from convert to UTF-8 encoding unnecessarily.
            //mail.Subject = header;
            mail.Subject = header.Replace("?", "-");
            mail.Body = message;
            mail.IsBodyHtml = isHTMLBody;

            // NEW: 2011.10.14, Kien Trung
            // Added priority to email.
            //
            switch (emailPriority)
            {
                case (int)EnumMessagePriority.Low:
                    mail.Priority = MailPriority.Low;
                    break;
                case (int)EnumMessagePriority.High:
                    mail.Priority = MailPriority.High;
                    break;
                default:
                    mail.Priority = MailPriority.Normal;
                    break;
            }

            // 2010.09.03
            // Kim Foong
            // Sends e-mail attachments
            //
            if (messageAttachments != null)
            {
                foreach (OMessageAttachment messageAttachment in messageAttachments)
                {
                    System.IO.MemoryStream ms = new System.IO.MemoryStream(messageAttachment.FileBytes);
                    ms.Position = 0;
                    Attachment attachment = new Attachment(ms, messageAttachment.Filename);
                    mail.Attachments.Add(attachment);
                }
            }

            c.Send(mail);
        }

        /// <summary>
        /// Rachel. Generate a list of emails address. the string include a list of email addresses 
        /// separated by semi-colons (;) or by commas (,)
        /// </summary>
        /// <param name="emails"></param>
        /// <returns></returns>
        public ArrayList GetListOfEmailAddress(string emails)
        {
            ArrayList emailList = new ArrayList();   
            try
            {
                string[] email = emails.Split(';', ',');
                for (int i = 0; i < email.Length; i++)
                {
                    if(email[i].Trim()!="")
                        emailList.Add(email[i].Trim());
                }
            }
            catch
            {
                emailList.Add(emails);                
            }
            return emailList;
        }


        /// ================================================================
        /// <summary>
        /// Handle and sends out messages (SMS and e-mails)
        /// </summary>
        /// ================================================================
        public void HandleMessages()
        {
            List<OMessage> messages = null;
            using (Connection c = new Connection())
            {
                // send email/SMS
                //
                messages = TablesLogic.tMessage[
                    TablesLogic.tMessage.IsSuccessful == 0 &
                    TablesLogic.tMessage.ScheduledDateTime <= DateTime.Now &
                    TablesLogic.tMessage.NumberOfTries < applicationSetting.MessageNumberOfTries];
            }

            foreach (OMessage message in messages)
            {
                
                message.NumberOfTries = (message.NumberOfTries == null ? 0 : message.NumberOfTries.Value) + 1;
                try
                {
                    using (Connection c = new Connection())
                    {
                        message.SentDateTime = DateTime.Now;
                        message.Save();
                        c.Commit();
                    }

                    if (message.MessageType == "EMAIL")
                    {
                        if (applicationSetting.EnableEmail == (int)EnumApplicationGeneral.Yes)
                        {
                            LogEvent("Sending email to :" + message.Recipient);

                            // 2010.09.03
                            // Kim Foong
                            // Modified to search and send attachments
                            //
                            List<OMessageAttachment> messageAttachments = null;
                            if (message.NumberOfAttachments != null && message.NumberOfAttachments > 0)
                                messageAttachments = TablesLogic.tMessageAttachment.LoadList(
                                    TablesLogic.tMessageAttachment.MessageID == message.ObjectID);

                            // 2011.10.14, Kien Trung
                            // Modified to send email with priority and cc recipients.
                            // 
                            //SendEmailMessage(message.Sender, message.Recipient, message.Header, message.Message, (message.IsHtmlEmail == 1 ? true : false), messageAttachments);
                            SendEmailMessage(message.Sender, message.Recipient, message.CarbonCopyRecipient, 
                                message.Header, message.Message, 
                                (message.IsHtmlEmail == (int)EnumApplicationGeneral.Yes ? true : false), 
                                message.Priority, messageAttachments);

                            LogEvent("Sent E-mail successfully.");
                            message.ErrorMessage = "Sent E-mail successfully";
                        }
                        else
                            message.ErrorMessage = "E-mail not sent because it is not enabled in the application settings.";
                    }

                    if (message.MessageType == "SMS")
                    {
                        if (applicationSetting.EnableSms == 1)
                        {
                            LogEvent("Sending SMS '" + message.Message + "' to :" + message.Recipient);
                            SendSMSMessage(message.Recipient, message.Message);
                            LogEvent("Sent SMS successfully.");
                            message.ErrorMessage = "Sent SMS successfully";
                        }
                        else
                            message.ErrorMessage = "SMS not sent because it is not enabled in the application settings.";
                    }

                    message.IsSuccessful = 1;
                    message.SentDateTime = DateTime.Now;
                }
                catch (Exception ex)
                {
                    message.ErrorMessage = ex.Message;
                    if (ex.InnerException != null)
                        message.ErrorMessage += "; " + ex.InnerException.Message;
                    LogEvent("Send message failed. " + ex.Message);
                }

                using (Connection c = new Connection())
                {
                    message.Save();
                    c.Commit();
                }
            }

            // receive SMS
            // 
            if (applicationSetting.EnableSms == 1 && applicationSetting.SMSSendType == 0)
            {
                try
                {
                    while (true)
                    {
                        LogEvent("Service Receiving SMS executing...");
                        string sender = "";
                        string messageBody = "";
                        if (ReceiveSMSMessage(out sender, out messageBody))
                        {
                            using (Connection c = new Connection())
                            {
                                bool keywordHandled = false;
                                OMessage message = TablesLogic.tMessage.Create();

                                message.Sender = sender;
                                message.NumberOfTries = 3;
                                message.ScheduledDateTime = DateTime.Now;
                                message.SentDateTime = DateTime.Now;
                                message.Message = messageBody;
                                message.MessageType = "SMSIN";
                                message.IsSuccessful = 0;

                                try
                                {
                                    string keyword = messageBody.Split(' ')[0];
                                    string mainBody = "";
                                    if (messageBody.Length - keyword.Length > 0)
                                        mainBody = messageBody.Substring(keyword.Length, messageBody.Length - keyword.Length);

                                    foreach (OApplicationSettingSmsKeywordHandler handler in
                                        applicationSetting.ApplicationSettingSmsKeywordHandlers)
                                    {
                                        string[] handlerKeywords = handler.Keywords.Split(',');
                                        ServicePointManager.ServerCertificateValidationCallback = TrustAllCertificates;

                                        for (int i = 0; i < handlerKeywords.Length; i++)
                                            if (handlerKeywords[i].ToUpper() == keyword.ToUpper())
                                            {
                                                // call the web service
                                                //
                                                WebRequest wr = WebRequest.Create(
                                                    String.Format(handler.HandlerUrl,
                                                        HttpUtility.UrlEncode(sender),
                                                        HttpUtility.UrlEncode(keyword.ToUpper()),
                                                        HttpUtility.UrlEncode(mainBody)));
                                                
                                                wr.Credentials = CredentialCache.DefaultCredentials;

                                                LogEvent("Activating web service: " + wr.RequestUri.AbsoluteUri + ".");
                                                WebResponse wresp = wr.GetResponse();
                                                byte[] buffer = new byte[wresp.ContentLength];

                                                wresp.GetResponseStream().Read(buffer, 0, (int)wresp.ContentLength);
                                                string response = ASCIIEncoding.UTF8.GetString(buffer);

                                                message.IsSuccessful = 1;
                                                LogEvent("Activated web service successfully.");
                                                keywordHandled = true;
                                            }
                                    }

                                    if (!keywordHandled)
                                        SendSMSMessage(sender, Resources.Errors.SMSKeywordInvalid);
                                }
                                catch (Exception ex)
                                {
                                    LogEvent("Activate web service failed. " + ex.Message);
                                }
                                message.Save();

                                c.Commit();
                            }
                        }
                        else
                            break;
                    }
                }
                catch (Exception ex)
                {
                    LogEvent("Receive SMS failed. " + ex.Message);
                }
            }
        }

        /// <summary>
        /// Method to trust all certificates
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="certificate"></param>
        /// <param name="chain"></param>
        /// <param name="errors"></param>
        /// <returns></returns>
        private static bool TrustAllCertificates(Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
        {
            // trust any certificate
            return true;
        }


        public SqlParameter ParameterCreate(string parameterName, int size, object value)
        {
            SqlParameter p = new SqlParameter();
            p.Size = size;
            p.ParameterName = parameterName;
            p.Value = value;
            return p;
        }


        public void ExecuteNonQuery(SqlConnection c, SqlTransaction t, string commandText, params SqlParameter[] parameters)
        {
            SqlCommand cmd = c.CreateCommand();

            cmd.Transaction = t;
            cmd.CommandText = commandText;
            if (parameters != null)
                cmd.Parameters.AddRange(parameters);
            cmd.ExecuteNonQuery();
        }

    }
}
