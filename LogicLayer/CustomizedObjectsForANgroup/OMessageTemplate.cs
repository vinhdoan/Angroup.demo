//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TMessageTemplate : LogicLayerSchema<OMessageTemplate>
    {
        public SchemaInt SendEmailWithAttachments;
    }
    /// <summary>
    /// Represents a message template that can be used by
    /// the application developer to create message templates
    /// for notification to users.
    /// </summary>
    public abstract partial class OMessageTemplate : LogicLayerPersistentObject
    {
        public abstract int? SendEmailWithAttachments { get; set; }
        /// <summary>
        /// Generates the message from the current message template
        /// and sends it out to the recipients.
        /// <para></para>
        /// If sending e-mail, the subject and body is added
        /// with text that indicates the mail is a carbon-copy to
        /// the user.
        /// <para></para>
        /// You may indicate multiple recipients for e-mail by 
        /// separating the receipient e-mail address and
        /// cellphone numbers with a comma (,) or a semi-color (;).
        /// </summary>
        /// <param name="persistentObject"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void GenerateAndSendCarbonCopyMessage(LogicLayerPersistentObjectBase persistentObject,
            string emailRecipients)
        {
            if (this.SendEmail == (int)EnumApplicationGeneral.Yes)
            {
                // Sends e-mail only if the template indicates
                // that there is an e-mail template.
                //
                Template emailSubjectTemplate = new Template(this.EmailSubjectTemplate, true);
                emailSubjectTemplate.AddVariable("obj", persistentObject);
                emailSubjectTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
                string emailSubject = Resources.Strings.Message_CarbonCopySubjectPrefix + emailSubjectTemplate.Generate();

                Template emailBodyTemplate = new Template(this.EmailBodyTemplate, true);
                emailBodyTemplate.AddVariable("obj", persistentObject);
                emailBodyTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
                string emailBody = Resources.Strings.Message_CarbonCopyBodyPrefix + emailBodyTemplate.Generate();

                if (SendEmailWithAttachments == (int)EnumApplicationGeneral.Yes && 
                    persistentObject.EmailMessageAttachments != null)
                {
                    List<OMessageAttachment> msgAttachments = new List<OMessageAttachment>();
                    
                    // loop through task attachments and send email with attachment.
                    //
                    foreach (OAttachment attachment in persistentObject.EmailMessageAttachments)
                        msgAttachments.Add(OMessageAttachment.NewAttachment(attachment.Filename, attachment.FileBytes));
                    
                    // send email with attachments.
                    //
                    OMessage.SendMail(emailRecipients, OApplicationSetting.Current.MessageEmailSender,
                        emailSubject, emailBody, true, msgAttachments.ToArray());
                }
                else
                    // Send email with no attachment.
                    //
                    OMessage.SendMail(emailRecipients, OApplicationSetting.Current.MessageEmailSender,
                        emailSubject, emailBody, true);
            }
            /*
            if (this.SendSms == 1)
            {
                // Sends SMS only if the template indicates
                // that there is an SMS template.
                //
                Template smsTemplate = new Template(this.SmsTemplate, true);
                smsTemplate.AddVariable("obj", persistentObject);
                smsTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
                string sms = smsTemplate.Generate();

                OMessage.SendSms(smsRecipients, sms);
            }
             * */
        }
    }

}
