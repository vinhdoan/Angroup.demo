using System;
using System.Collections.Generic;

namespace Anacle.MobileWebService
{
    public class UpdateWorkData
    {
        public Guid? ObjectID;
        public Guid? LocationID;
        public Guid? EquipmentID;
        public int? VersionNumber;

        public String WorkDescription;
        public Guid? TypeOfWorkID;
        public Guid? TypeOfServiceID;
        public Guid? TypeOfProblemID;
        public Guid? CauseOfProblemID;
        public Guid? ResolutionID;

        public DateTime? ScheduledStartDateTime;
        public DateTime? ScheduledEndDateTime;
        public DateTime? ActualStartDateTime;
        public DateTime? ActualEndDateTime;
        public String ResolutionDescription;
        public int? PercentageComplete;
        public DateTime? AcknowledgementDateTime;
        public DateTime? ArrivalDateTime;
        public DateTime? CompletionDateTime;

        public int? NotifyWorkSupervisor;
        public int? NotifyWorkTechnician;

        public Byte[] UsageSignature;
        public Byte[] AcceptSignature;

        public List<UpdateWorkChecklistItemData> WorkChecklistItems;
    }
}
