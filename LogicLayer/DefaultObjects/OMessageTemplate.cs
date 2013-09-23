//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
        public SchemaInt WhereUsed;
        public SchemaString MessageTemplateCode;
        public SchemaString ObjectTypeName;
        public SchemaString StateName;

        public SchemaInt SendEmail;
        public SchemaInt SendSms;
        public SchemaText SmsTemplate;
        public SchemaText EmailBodyTemplate;
        public SchemaText EmailSubjectTemplate;
    }


    /// <summary>
    /// Represents a message template that can be used by
    /// the application developer to create message templates
    /// for notification to users.
    /// </summary>
    [Serializable]
    public abstract partial class OMessageTemplate : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets a flag indicating where
        /// this message template is used.
        /// <list>
        ///     <item>0 - General; </item>
        ///     <item>1 - Notify Assigned Workflow Recipients; </item>
        /// </list>
        /// </summary>
        public abstract int? WhereUsed { get; set; }

        /// <summary>
        /// [Column] Gets or sets the message template code
        /// that will be used by the developer to identify
        /// this message template.
        /// </summary>
        public abstract String MessageTemplateCode { get; set; }

        /// <summary>
        /// [Column] Gets or sets the object type name that
        /// this message template applies to. 
        /// <para></para>
        /// The workflow will use the ObjectTypeName and the
        /// StateName property to decide the message template
        /// to be used to send notification to the assigned
        /// recipients of the workflow task.
        /// </summary>
        public abstract string ObjectTypeName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the state name that
        /// this message template applies to. 
        /// <para></para>
        /// The workflow will use the ObjectTypeName and the
        /// StateName property to decide the message template
        /// to be used to send notification to the assigned
        /// recipients of the workflow task.
        /// </summary>
        public abstract string StateName { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether
        /// the e-mail template is valid. If set, than an e-mail
        /// will be sent out whenever this template is used
        /// for notification.
        /// </summary>
        public abstract int? SendEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether
        /// the SMS template is valid. If set, than an SMS
        /// will be sent out whenever this template is used
        /// for notification.
        /// </summary>
        public abstract int? SendSms { get; set; }

        /// <summary>
        /// [Column] Gets or sets the template that will be
        /// used for sending the SMS.
        /// </summary>
        public abstract String SmsTemplate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the body template that will be
        /// used for sending the e-mail.
        /// </summary>
        public abstract String EmailBodyTemplate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the subject template that will be
        /// used for sending the e-mail.
        /// </summary>
        public abstract String EmailSubjectTemplate { get; set; }


        /// <summary>
        /// Gets a localized text describing where this message
        /// template is used.
        /// </summary>
        public string WhereUsedText
        {
            get
            {
                if (WhereUsed == 0)
                    return Resources.Strings.WhereUsed_General;
                else if (WhereUsed == 1)
                    return Resources.Strings.WhereUsed_NotifyAssignedWorkflowRecipients;
                return "";
            }
        }

        /// <summary>
        /// Overrides the Saving event to clear fields that do not apply
        /// to the WhereUsed property.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            if (WhereUsed == MessageTemplateUsage.General)
            {
                ObjectTypeName = "";
                StateName = "";
            }
            if (WhereUsed == MessageTemplateUsage.NotifyAssignedWorkflowRecipients)
            {
                MessageTemplateCode = "";
            }
        }

        public static void GenerateAndSendComposedEmailMessage(LogicLayerPersistentObjectBase persistentObject,
            string subjectMessageTemplate, string bodyMessageTemplate, string emailRecipients, string smsRecipients)
        {
            // Sends e-mail only if the template indicates
            // that there is an e-mail template.
            //
            Template emailSubjectTemplate = new Template(subjectMessageTemplate, true);
            emailSubjectTemplate.AddVariable("obj", persistentObject);
            emailSubjectTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
            string emailSubject = emailSubjectTemplate.Generate();

            Template emailBodyTemplate = new Template(bodyMessageTemplate, true);
            emailBodyTemplate.AddVariable("obj", persistentObject);
            emailBodyTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
            string emailBody = emailBodyTemplate.Generate();

            // send email.
            //
            OMessage.SendMail(emailRecipients, OApplicationSetting.Current.MessageEmailSender, emailSubject, emailBody, true);
        }

        /// <summary>
        /// Generates the message from the current message template
        /// and sends it out to the recipients.
        /// <para></para>
        /// You may indicate multiple recipients for e-mail and
        /// SMS by separating the receipient e-mail address and
        /// cellphone numbers with a comma (,) or a semi-color (;).
        /// </summary>
        /// <param name="persistentObject"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void GenerateAndSendMessage(LogicLayerPersistentObjectBase persistentObject,
            string emailRecipients, string smsRecipients)
        {
            if (this.SendEmail == (int)EnumApplicationGeneral.Yes)
            {
                // Sends e-mail only if the template indicates
                // that there is an e-mail template.
                //
                Template emailSubjectTemplate = new Template(this.EmailSubjectTemplate, true);
                emailSubjectTemplate.AddVariable("obj", persistentObject);
                emailSubjectTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
                string emailSubject = emailSubjectTemplate.Generate();

                Template emailBodyTemplate = new Template(this.EmailBodyTemplate, true);
                emailBodyTemplate.AddVariable("obj", persistentObject);
                emailBodyTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
                string emailBody = emailBodyTemplate.Generate();

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
                    OMessage.SendMail(emailRecipients, "", OApplicationSetting.Current.MessageEmailSender,
                        emailSubject, emailBody, true, persistentObject.TaskPriority, msgAttachments.ToArray());
                }
                else
                    OMessage.SendMail(emailRecipients, "", OApplicationSetting.Current.MessageEmailSender,
                        emailSubject, emailBody, true, persistentObject.TaskPriority);
            }

            if (this.SendSms == (int)EnumApplicationGeneral.Yes)
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
        }

        /// <summary>
        /// Generates the message from the current message template
        /// and sends it out to the recipients.
        /// <para></para>
        /// You may indicate multiple recipients for e-mail and
        /// SMS by separating the receipient e-mail address and
        /// cellphone numbers with a comma (,) or a semi-color (;).
        /// </summary>
        /// <param name="persistentObject"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void GenerateAndSendMessage(LogicLayerPersistentObjectBase persistentObject,
            string emailRecipients, string emailCCRecipients, string smsRecipients)
        {
            if (this.SendEmail == (int)EnumApplicationGeneral.Yes)
            {
                // Sends e-mail only if the template indicates
                // that there is an e-mail template.
                //
                Template emailSubjectTemplate = new Template(this.EmailSubjectTemplate, true);
                emailSubjectTemplate.AddVariable("obj", persistentObject);
                emailSubjectTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
                string emailSubject = emailSubjectTemplate.Generate();

                Template emailBodyTemplate = new Template(this.EmailBodyTemplate, true);
                emailBodyTemplate.AddVariable("obj", persistentObject);
                emailBodyTemplate.AddVariable("applicationSettings", OApplicationSetting.Current);
                string emailBody = emailBodyTemplate.Generate();

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
                    OMessage.SendMail(emailRecipients, emailCCRecipients, 
                        OApplicationSetting.Current.MessageEmailSender,
                        emailSubject, emailBody, true, 
                        (persistentObject.CurrentActivity == null ? persistentObject.TaskPriority : persistentObject.CurrentActivity.Priority), 
                        msgAttachments.ToArray());
                    
                }
                else
                    OMessage.SendMail(emailRecipients, emailCCRecipients, 
                        OApplicationSetting.Current.MessageEmailSender, emailSubject, emailBody, true,
                        (persistentObject.CurrentActivity == null ? persistentObject.TaskPriority : persistentObject.CurrentActivity.Priority));
            }

            if (this.SendSms == (int)EnumApplicationGeneral.Yes)
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
        }

        /// <summary>
        /// Gets a DataTable of general message templates' name and
        /// ID 
        /// </summary>
        /// <returns></returns>
        public static DataTable GetGeneralMessageTemplates()
        {
            return (DataTable)TablesLogic.tMessageTemplate.Select(
                TablesLogic.tMessageTemplate.ObjectID,
                TablesLogic.tMessageTemplate.ObjectName)
                .Where(
                TablesLogic.tMessageTemplate.WhereUsed == MessageTemplateUsage.General &
                TablesLogic.tMessageTemplate.IsDeleted == 0);
        }
    }


    /// <summary>
    /// Enumerates the possible usage for a message template.
    /// </summary>
    public class MessageTemplateUsage
    {
        /// <summary>
        /// The message template is used generally and usually
        /// called from the source code.
        /// </summary>
        public static int General = 0;

        /// <summary>
        /// The message template is used in a workflow to notify
        /// assigned recipients when a workflow enters a new state 
        /// and the SetStateAndAssign or SetStateAndAssignApprovers 
        /// is called.
        /// </summary>
        public static int NotifyAssignedWorkflowRecipients = 1;
    }
}
