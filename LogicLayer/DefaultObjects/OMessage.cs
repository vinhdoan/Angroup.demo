//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Map("Message"), Database("#database")]
    public class TMessage : LogicLayerSchema<OMessage>
    {
        public SchemaDateTime ScheduledDateTime;
        public SchemaDateTime SentDateTime;
        [Default(0)]
        public SchemaInt IsSuccessful;
        [Default(0)]
        public SchemaInt NumberOfTries;
        public SchemaInt IsHtmlEmail;

        public SchemaString MessageType;
        public SchemaText Message;
        [Size(255)]
        public SchemaString Header;
        [Size(255)]
        public SchemaString Sender;
        [Size(255)]
        public SchemaString Recipient;
        public SchemaText ErrorMessage;
        public SchemaInt IsNotifiedOnline;
        public SchemaDateTime NotificationOnlineDateTime;
        [Default(0)]
        public SchemaInt NumberOfAttachments;

        [Size(255)]
        public SchemaString CarbonCopyRecipient;

        public SchemaInt Priority;
        // Join for attachments.
        public TMessageAttachment MessageAttachments { get { return OneToMany<TMessageAttachment>("MessageID"); } }
    }


    [Serializable]
    public abstract class OMessage : LogicLayerPersistentObject
    {
        public abstract DateTime? ScheduledDateTime { get;set; }
        public abstract DateTime? SentDateTime { get;set; }
        public abstract int? IsSuccessful { get;set; }
        public abstract int? NumberOfTries { get;set; }
        public abstract int? IsHtmlEmail { get;set; }

        public abstract String MessageType { get;set; }
        public abstract String Message { get;set; }
        public abstract String Header { get;set; }
        public abstract String Sender { get;set; }
        public abstract String Recipient { get;set; }
        public abstract String ErrorMessage { get;set; }
        public abstract int? IsNotifiedOnline { get;set; }
        public abstract DateTime? NotificationOnlineDateTime { get;set; }

        public abstract String CarbonCopyRecipient { get; set; }

        public abstract int? Priority { get; set; }

        /// <summary>
        /// Gets or sets a flag indicating whether the message has attachments
        /// </summary>
        public abstract Int32? NumberOfAttachments { get; set; }

        // 2010.09.03
        // Kim Foong
        public abstract DataList<OMessageAttachment> MessageAttachments { get; }

        /// <summary>
        /// Gets a yes/no text indicating whether the message
        /// was successfully sent out.
        /// </summary>
        public string IsSuccessfulText
        {
            get
            {
                if (this.IsSuccessful == 1)
                    return Resources.Strings.General_Yes;
                return Resources.Strings.General_No;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public string MessagePriority
        {
            get
            {
                if (this.Priority == (int)EnumMessagePriority.Low)
                    return "Low";
                else if (this.Priority == (int)EnumMessagePriority.Normal)
                    return "Normal";
                else if (this.Priority == (int)EnumMessagePriority.High)
                    return "High";
                return "Normal";
            }
        }
    

        /// <summary>
        /// Send an SMS to one or many recipients. You can indicate
        /// multiple recipients by separating the cellphone numbers
        /// in the recipients parameter with a comma or semi-colon.
        /// </summary>
        /// <param name="recipients"></param>
        /// <param name="message"></param>
        public static void SendSms(string recipients, string message)
        {
            if (recipients == null || recipients.Trim() == "")
                return;
            if (message == null || message.Trim() == "")
                return;

            using (Connection c = new Connection())
            {
                string[] recipientSplit = recipients.Split(',', ';');

                foreach (string recipient in recipientSplit)
                {
                    if (recipient.Trim() != "")
                    {
                        OMessage m = TablesLogic.tMessage.Create();

                        m.ScheduledDateTime = DateTime.Now;
                        m.MessageType = "SMS";
                        m.Message = message;
                        m.Recipient = recipient.Replace(" ", "");
                        m.Save();
                    }
                }
                c.Commit();
            }
        }
        

        /// <summary>
        /// Send an e-mail to one or many recipients in text format.
        /// You can indicate multiple recipients by separating the 
        /// e-mail addresses in the recipients parameter with a comma 
        /// or semi-colon.
        /// </summary>
        /// <param name="recipients"></param>
        /// <param name="sender"></param>
        /// <param name="subjectHeader"></param>
        /// <param name="message"></param>
        public static void SendMail(string recipients, string sender, string subjectHeader, string message)
        {
            //rachel
            SendMail(recipients, sender, subjectHeader, message, false);
        }


        /// <summary>
        /// Send an e-mail to one or many recipients in text or HTML format.
        /// You can indicate multiple recipients by separating the 
        /// e-mail addresses in the recipients parameter with a comma 
        /// or semi-colon.
        /// </summary>
        /// <param name="recipients"></param>
        /// <param name="sender"></param>
        /// <param name="subjectHeader"></param>
        /// <param name="message"></param>
        public static void SendMail(string recipients, string sender, string subjectHeader, string message, bool isHTMLBody)
        {
            if (recipients == null || recipients.Trim() == "")
                return;
            if (message == null || message.Trim() == "")
                return;
            if (sender == null || sender.Trim() == "")
                return;
            if (subjectHeader == null || subjectHeader.Trim() == "")
                return;

            using (Connection c = new Connection())
            {
                OMessage m = TablesLogic.tMessage.Create();

                m.ScheduledDateTime = DateTime.Now;
                m.MessageType = "EMAIL";
                m.Message = message;
                m.Recipient = recipients;
                m.Header = subjectHeader;
                m.Sender = sender;
                if (isHTMLBody)
                    m.IsHtmlEmail = 1;
                else
                    m.IsHtmlEmail = 0;

                m.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Send an e-mail to one or many recipients in text or HTML format.
        /// You can indicate multiple recipients by separating the 
        /// e-mail addresses in the recipients parameter with a comma 
        /// or semi-colon.
        /// </summary>
        /// <param name="recipients"></param>
        /// <param name="sender"></param>
        /// <param name="subjectHeader"></param>
        /// <param name="message"></param>
        public static void SendMail(string recipients, string ccRecipients, string sender, string subjectHeader, string message, bool isHTMLBody, int? emailPriority)
        {
            if (recipients == null || recipients.Trim() == "")
                return;
            if (message == null || message.Trim() == "")
                return;
            if (sender == null || sender.Trim() == "")
                return;
            if (subjectHeader == null || subjectHeader.Trim() == "")
                return;

            using (Connection c = new Connection())
            {
                OMessage m = TablesLogic.tMessage.Create();

                m.ScheduledDateTime = DateTime.Now;
                m.MessageType = "EMAIL";
                m.Message = message;
                m.Recipient = recipients;
                m.CarbonCopyRecipient = ccRecipients;
                m.Header = subjectHeader;
                m.Sender = sender;
                m.Priority = emailPriority;

                if (isHTMLBody)
                    m.IsHtmlEmail = 1;
                else
                    m.IsHtmlEmail = 0;

                m.Save();
                c.Commit();
            }
        }

        /// <summary>
        /// Send an e-mail to one or many recipients in text or HTML format.
        /// You can indicate multiple recipients by separating the 
        /// e-mail addresses in the recipients parameter with a comma 
        /// or semi-colon.
        /// </summary>
        /// <param name="recipients"></param>
        /// <param name="sender"></param>
        /// <param name="subjectHeader"></param>
        /// <param name="message"></param>
        public static void SendMail(string recipients, string ccRecipients, string sender, string subjectHeader, string message, bool isHTMLBody, int? emailPriority, params OMessageAttachment[] messageAttachments)
        {
            if (recipients == null || recipients.Trim() == "")
                return;
            if (message == null || message.Trim() == "")
                return;
            if (sender == null || sender.Trim() == "")
                return;
            if (subjectHeader == null || subjectHeader.Trim() == "")
                return;

            using (Connection c = new Connection())
            {
                OMessage m = TablesLogic.tMessage.Create();

                m.ScheduledDateTime = DateTime.Now;
                m.MessageType = "EMAIL";
                m.Message = message;
                m.Recipient = recipients;
                m.CarbonCopyRecipient = ccRecipients;
                m.Header = subjectHeader;
                m.Sender = sender;
                m.Priority = emailPriority;

                if (isHTMLBody)
                    m.IsHtmlEmail = 1;
                else
                    m.IsHtmlEmail = 0;

                
                // Add message attachments if specified.
                if (messageAttachments != null)
                    foreach (OMessageAttachment messageAttachment in messageAttachments)
                    {
                        m.NumberOfAttachments++;
                        m.MessageAttachments.Add(messageAttachment);
                    }

                m.Save();
                c.Commit();
            }
        }

        // 2010.09.03
        // Kim Foong
        // Added this new method to allow sending of e-mail with attachments.
        /// <summary>
        /// Send an e-mail to one or many recipients in text or HTML format.
        /// You can indicate multiple recipients by separating the 
        /// e-mail addresses in the recipients parameter with a comma 
        /// or semi-colon.
        /// </summary>
        /// <param name="recipients"></param>
        /// <param name="sender"></param>
        /// <param name="subjectHeader"></param>
        /// <param name="message"></param>
        public static void SendMail(string recipients, string sender, string subjectHeader, string message, bool isHTMLBody, params OMessageAttachment[] messageAttachments)
        {
            if (recipients == null || recipients.Trim() == "")
                return;
            if (message == null || message.Trim() == "")
                return;
            if (sender == null || sender.Trim() == "")
                return;
            if (subjectHeader == null || subjectHeader.Trim() == "")
                return;

            using (Connection c = new Connection())
            {
                OMessage m = TablesLogic.tMessage.Create();

                m.ScheduledDateTime = DateTime.Now;
                m.MessageType = "EMAIL";
                m.Message = message;
                m.Recipient = recipients;
                m.Header = subjectHeader;
                m.Sender = sender;
                if (isHTMLBody)
                    m.IsHtmlEmail = 1;
                else
                    m.IsHtmlEmail = 0;

                // 2010.09.03
                // Kim Foong
                // Add message attachments if specified.
                if (messageAttachments != null)
                    foreach (OMessageAttachment messageAttachment in messageAttachments)
                    {
                        m.NumberOfAttachments++;
                        m.MessageAttachments.Add(messageAttachment);
                    }

                m.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Deletes messages from the message history table older than 
        /// n number of days, where n is a value set up in the Application Settings.
        /// <para></para>
        /// This method is called from the application Login page.
        /// </summary>
        public static void ClearMessageHistory(DateTime lastDate)
        {
            using (Connection c = new Connection())
            {
                TablesLogic.tMessage.DeleteList(
                    TablesLogic.tMessage.CreatedDateTime < lastDate);

                // 2010.09.03
                // Clear the message attachments also.
                //
                TablesLogic.tMessageAttachment.DeleteList(
                    !TablesLogic.tMessageAttachment.MessageID.In(
                    TablesLogic.tMessage.Select(TablesLogic.tMessage.ObjectID)));

                c.Commit();
            }
        }
    }

    /// <summary>
    /// This is to indicate Importance of email Message.
    /// </summary>
    public enum EnumMessagePriority
    {
        Low = 0,
        Normal = 1,
        High = 3
    }
}
