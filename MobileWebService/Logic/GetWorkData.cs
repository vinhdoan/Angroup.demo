using System;
using System.Collections.Generic;

namespace Anacle.MobileWebService
{
    public class GetWorkData
    {
        public Guid? ObjectID;
        public Guid? LocationID;
        public String LocationName;
        public Guid? EquipmentID;
        public String EquipmentName;
        public String ObjectNumber;
        public int? VersionNumber;

        public String WorkDescription;
        public Guid? TypeOfWorkID;
        public String TypeOfWorkName;
        public Guid? TypeOfServiceID;
        public String TypeOfServiceName;
        public Guid? TypeOfProblemID;
        public String TypeOfProblemName;
        public Guid? CauseOfProblemID;
        public String CauseOfProblemName;
        public Guid? ResolutionID;
        public String ResolutionName;

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

        public List<GetWorkChecklistItemData> WorkChecklistItems;
    }
}
