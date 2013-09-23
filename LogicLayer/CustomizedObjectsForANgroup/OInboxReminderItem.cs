using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{

    public class TInboxReminderItem : LogicLayerSchema<OInboxReminderItem>
    {
        public SchemaGuid InboxReminderID;
        public TInboxReminder InboxReminder { get { return OneToOne<TInboxReminder>("InboxReminderID"); } }
        public TInboxReminderItemState InboxReminderItemStates { get { return OneToMany<TInboxReminderItemState>("InboxReminderItemID"); } }
    }
    public abstract partial class OInboxReminderItem : LogicLayerPersistentObject
    {
        public abstract Guid? InboxReminderID { get; set; }
        public abstract OInboxReminder InboxReminder { get; set; }
        public abstract DataList<OInboxReminderItemState> InboxReminderItemStates { get; set; }

        public int TransactionCount
        {
            get
            {
                int transactionCount = 0;

                foreach (OInboxReminderItemState state in InboxReminderItemStates)
                    transactionCount += state.ItemCount.Value;

                return transactionCount;

            }
        }

    }
}
