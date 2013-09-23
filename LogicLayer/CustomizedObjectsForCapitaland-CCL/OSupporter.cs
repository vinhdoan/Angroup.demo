using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Represents one level in the supporter hierarchy.
    /// </summary>
    public partial class TSupporter : LogicLayerSchema<OSupporter>
    {
        public SchemaGuid RFQID;
        public SchemaInt Level;
        public SchemaGuid SupporterID;
        [Default(0)]
        public SchemaInt IsApproved;

        public TRequestForQuotation RFQ { get { return OneToOne<TRequestForQuotation>("RFQID"); } }
        public TUser Supporter { get { return OneToOne<TUser>("SupporterID"); } }

    }


    /// <summary>
    /// Represents one level in the supporter hierarchy.
    /// </summary>
    public abstract partial class OSupporter : LogicLayerPersistentObject
    {
        public abstract Guid? RFQID { get; set; }
        public abstract int? Level { get; set; }
        public abstract Guid? SupporterID { get; set; }
        public abstract int? IsApproved { get; set; }

        public abstract ORequestForQuotation RFQ { get; set; }
        public abstract OUser Supporter { get; set; }

        public string SupporterName
        {
            get
            {
                return Supporter.ObjectName;
            }
        }

        public string IsApprovedText
        {
            get
            {
                switch (IsApproved)
                {
                    case (int)EnumSupportStatus.Supported:
                        return EnumSupportStatus.Supported.ToString();
                    case (int)EnumSupportStatus.Rejected:
                        return EnumSupportStatus.Rejected.ToString();
                    default:
                        return EnumSupportStatus.Pending.ToString();
                }
            }
        }
    }

    public enum EnumSupportStatus
    {
        Pending=0,
        Supported=1,
        Rejected=2
    }
}
