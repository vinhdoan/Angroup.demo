using System;
using System.Collections.Generic;

namespace Anacle.MobileWebService
{
    public class GetWorkDataMobile
    {
        //ID
        public Guid? ObjectID;     
        //InspectionNo
        public String ObjectNumber;
        //ParentPath
        public String ParentPath;
        //LocationName
        public String LocationName;
        //IsChargeable
        public int? IsChargeable;
        //WorkDescription
        public String WorkDescription;
        //TypeOfWork
        public String TypeOfWorkName;
        //TypeOfService
        public String TypeOfServiceName;
        //TypeOfProblem
        public String TypeOfProblemName;
        
        public DateTime? ScheduledStartDateTime;
        public DateTime? ScheduledEndDateTime;
        public DateTime? ActualStartDateTime;
        public DateTime? ActualEndDateTime;

        public String ResolutionDescription;
        public int? PercentageComplete;
        public DateTime? AcknowledgementDateTime;
        public DateTime? ArrivalDateTime;
        public DateTime? CompletionDateTime;

        public String CreatedUser;
        public DateTime? CreatedDateTime;
        public String ModifiedUser;
        public DateTime? ModifiedDateTime;

        public String Status;
    }
}
