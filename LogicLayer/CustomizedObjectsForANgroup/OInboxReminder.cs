using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{

    public partial class TInboxReminder : LogicLayerSchema<OInboxReminder>
    {
        public SchemaGuid UserID;
        public TUser User { get { return OneToOne<TUser>("UserID"); } }

        public TInboxReminderItem InboxReminderItems { get { return OneToMany<TInboxReminderItem>("InboxReminderID"); } }
    }
    public abstract partial class OInboxReminder : LogicLayerPersistentObject
    {
        public abstract Guid? UserID { get; set; }
        public abstract OUser User { get; set; }

        public abstract DataList<OInboxReminderItem> InboxReminderItems { get; set; }

        /// <summary>
        /// Always return as High
        /// </summary>
        public override int? TaskPriority
        {
            get
            {
                return (int)EnumTaskImportance.High;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public DateTime CurrentDate
        {
            get
            {
                return DateTime.Now;
            }
        }

        public string SystemUrl
        {
            get
            {
                return "<a href= \"" + OApplicationSetting.Current.SystemUrl + "\">here" + "</a>";
            }
        }

    }
}
