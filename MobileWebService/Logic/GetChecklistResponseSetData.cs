using System;
using System.Collections.Generic;

namespace Anacle.MobileWebService
{
    public class GetChecklistResponseSetData
    {
        public Guid? ObjectID;
        public String ObjectName;

        public List<GetChecklistResponseData> ChecklistResponses;
    }
}

