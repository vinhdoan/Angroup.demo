using System;

namespace Anacle.MobileWebService
{
    public class UserSession
    {
        public Guid? ObjectID;
        public String ObjectName;
        public String LoginName;
        public Guid? SessionKey;
        public DateTime LastAccessDateTime;
    }
}
