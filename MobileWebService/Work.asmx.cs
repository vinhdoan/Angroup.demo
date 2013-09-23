using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using LogicLayer;
using System.Data;
using Anacle.DataFramework;
using Anacle.WorkflowFramework;

namespace Anacle.MobileWebService
{
    /// <summary>
    /// Summary description for Work
    /// </summary>
    [WebService(Namespace = "http://demo.anacle.com/mobilewebservice/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class Work : System.Web.Services.WebService
    {
        //public List<GetWorkDataMobile> GetWorks(Guid sessionKey, List<Guid> objectId, bool includeSignatureData, bool includeChecklistData)
        [WebMethod]
        public List<GetWorkDataMobile> GetWorks(string loginName)
        {
            OUser user = OUser.GetUserByLoginName(loginName);
            //TO DO
            //Check SessionKey
            DataTable dt = OActivity.GetOutstandingActivitiesForInbox(user, DateTime.Now, "OWork", "PendingExecution", "%%");
            List<OWork> works = new List<OWork>();
            foreach (DataRow row in dt.Rows)
            {
                OWork w = TablesLogic.tWork[new Guid(row["AttachedObjectID"].ToString())];
                if (w != null)
                    works.Add(w);
            }

            List<GetWorkDataMobile> worksData = new List<GetWorkDataMobile>();
            foreach (OWork work in works)
            {
                GetWorkDataMobile data = new GetWorkDataMobile();
                data.ObjectID = work.ObjectID;
                data.ObjectNumber = work.ObjectNumber;
                data.ParentPath = work.Location.ParentFastPath;
                data.LocationName = String.IsNullOrEmpty(work.Location.ParentFastPath) ? work.Location.ObjectName : work.Location.ParentFastPath + " > " + work.Location.ObjectName;
                data.IsChargeable = work.IsChargedToCaller;
                data.WorkDescription = work.WorkDescription;
                data.TypeOfWorkName = work.TypeOfWork.ObjectName;
                data.TypeOfServiceName = work.TypeOfService.ObjectName;
                data.TypeOfProblemName = work.TypeOfProblem.ObjectName;
                data.ScheduledStartDateTime = work.ScheduledStartDateTime;
                data.ScheduledEndDateTime = work.ScheduledEndDateTime;
                data.ActualStartDateTime = work.ActualStartDateTime;
                data.ActualEndDateTime = work.ActualEndDateTime;
                data.ResolutionDescription = work.ResolutionDescription;
                data.PercentageComplete = work.PercentageComplete;
                data.AcknowledgementDateTime = work.AcknowledgementDateTime;
                data.ArrivalDateTime = work.ArrivalDateTime;
                data.CompletionDateTime = work.CompletionDateTime;

                data.CreatedUser = work.CreatedUser;
                data.CreatedDateTime = work.CreatedDateTime;
                data.ModifiedUser = work.ModifiedUser;
                data.ModifiedDateTime = work.ModifiedDateTime;

                data.Status = work.CurrentActivity.CurrentStateName;

                worksData.Add(data);
            }

            return worksData;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sessionKey"></param>
        /// <param name="parentId"></param>
        /// <returns></returns>
        [WebMethod]
        public List<GetObjectData> GetLocationsForSelection(Guid sessionKey, Guid? parentId)
        {
            return null;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sessionKey"></param>
        /// <param name="parentId"></param>
        /// <returns></returns>
        [WebMethod]
        public List<GetObjectData> GetEquipmentsForSelection(Guid sessionKey, Guid? parentId)
        {
            return null;
        }

        [WebMethod]
        public List<GetObjectData> GetTypeOfWorksForSelection(Guid sessionKey)
        {
            return null;
        }

        [WebMethod]
        public List<GetObjectData> GetTypeOfServicesForSelection(Guid sessionKey, Guid? typeOfWorkId)
        {
            return null;
        }

        [WebMethod]
        public List<GetObjectData> GetTypeOfProblemsForSelection(Guid sessionKey, Guid? typeOfServiceId)
        {
            return null;
        }

        [WebMethod]
        public List<GetObjectData> GetCauseOfProblemsForSelection(Guid sessionKey, Guid? typeOfProblemId)
        {
            return null;
        }

        [WebMethod]
        public List<GetObjectData> GetResolutionsForSelection(Guid sessionKey, Guid? causeOfProblemId)
        {
            return null;
        }

        [WebMethod]
        public List<GetObjectData> GetTechniciansForAssignment(Guid sessionKey, Guid? locationId, Guid? typeOfServiceId)
        {
            return null;
        }

        [WebMethod]
        public List<GetChecklistResponseSetData> GetChecklistResponseSets(Guid sessionKey)
        {
            return null;
        }

        /// <summary>
        /// Creates the work.
        /// </summary>
        /// <param name="objectID">The object ID.</param>
        /// <param name="WONumber">The WO number.</param>
        /// <param name="location">The location.</param>
        /// <param name="createdby">The createdby.</param>
        /// <param name="createddate">The createddate.</param>
        /// <param name="status">The status.</param>
        /// <param name="workdescription">The workdescription.</param>
        /// <param name="typeofwork">The typeofwork.</param>
        /// <param name="typeofservice">The typeofservice.</param>
        /// <param name="typeofproblem">The typeofproblem.</param>
        /// <param name="scheduledstart">The scheduledstart.</param>
        /// <param name="scheduledend">The scheduledend.</param>
        /// <param name="ischargeable">The ischargeable.</param>
        /// <returns></returns>
        [WebMethod]
        public string CreateWork(String objectID, String WONumber, String location, String createdby, String createddate, String status, String workdescription, String typeofwork,
            String typeofservice, String typeofproblem, String scheduledstart, String scheduledend, int ischargeable)
        {
            using (Connection c = new Connection())
            {
                LogicLayer.Workflow.CurrentUser = LogicLayer.TablesLogic.tUser.Load(TablesLogic.tUser.ObjectName == createdby);
                LogicLayer.OWork newWork = LogicLayer.TablesLogic.tWork.Create();

                newWork.ObjectNumber = WONumber;
                OLocation loc = TablesLogic.tLocation.Load(TablesLogic.tLocation.ObjectName == "6 Battery Road");
                if (loc != null)
                    newWork.LocationID = loc.ObjectID;
                newWork.WorkDescription = workdescription;

                OCode tow = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == typeofwork);
                OCode tos = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == typeofservice);
                OCode top = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == typeofproblem);

                if (tow != null)
                    newWork.TypeOfWorkID = tow.ObjectID;
                if (tos != null)
                    newWork.TypeOfWorkID = tos.ObjectID;
                if (top != null)
                    newWork.TypeOfWorkID = top.ObjectID;

                newWork.ScheduledStartDateTime = Convert.ToDateTime(scheduledstart);
                newWork.ScheduledEndDateTime = Convert.ToDateTime(scheduledend);
                newWork.IsChargedToCaller = ischargeable;

                newWork.SaveAndTransit("SaveAsDraft");
                c.Commit();
            }

            return "";
        }

        [WebMethod]
        public void UpdateWork(Guid sessionKey, GetWorkData work, bool includeSignatureData, bool includeChecklistData, string triggerEventName)
        {
        }

        [WebMethod]
        public void UpdateWorkAcknowledgement(Guid sessionKey, Guid objectId, DateTime? acknowledgementDateTime)
        {
        }

        [WebMethod]
        public void UpdateWorkArrival(Guid sessionKey, Guid objectId, DateTime? acknowledgementDateTime)
        {
        }

        [WebMethod]
        public void UpdateWorkCompletion(Guid sessionKey, Guid objectId, DateTime? completionDateTime)
        {
        }

    }
}
