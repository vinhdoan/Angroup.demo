using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{

    public class TInboxReminderItemState : LogicLayerSchema<OInboxReminderItemState>
    {
        public SchemaGuid InboxReminderItemID;
        public TInboxReminderItem InboxReminderItem { get { return OneToOne<TInboxReminderItem>("InboxReminderItemID"); } }

        [Size(255)]
        public SchemaString StateName;
        public SchemaInt ItemCount;
    }
    public abstract partial class OInboxReminderItemState : LogicLayerPersistentObject
    {
        public abstract Guid? InboxReminderItemID { get; set; }
        public abstract OInboxReminderItem InboxReminderItem { get; set; }

        // State name uses objectname, though not stated here
        public abstract String StateName { get; set; }
        public abstract int? ItemCount { get; set; }
    }
}
