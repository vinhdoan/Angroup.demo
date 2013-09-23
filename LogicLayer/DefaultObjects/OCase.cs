//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OVendor
    /// </summary>
    [Database("#database"), Map("Case")]
    [Serializable]
    public partial class TCase : LogicLayerSchema<OCase>
    {
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;        
        public SchemaGuid RequestorID;
        public SchemaGuid RequestorType;
        public SchemaString RequestorName;
        public SchemaString RequestorCellPhone;
        public SchemaString RequestorFax;
        public SchemaString RequestorEmail;
        public SchemaString RequestorPhone;
        [Size(255)]
        public SchemaInt Priority;
        [Size(255)]
        public SchemaString ProblemDescription;
        [Default(1)]
        public SchemaInt IsAutoClose;
        public SchemaDateTime ReportedDateTime;
        public SchemaDateTime CompletionDateTime;

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        public TWork Works { get { return OneToMany<TWork>("CaseID"); } }
        public TRequestForQuotation RequestForQuotations { get { return OneToMany<TRequestForQuotation>("CaseID"); } }
        public TPurchaseOrder PurchaseOrders { get { return OneToMany<TPurchaseOrder>("CaseID"); } }
        public TUser Requestor { get { return OneToOne<TUser>("RequestorID");} }
    }


    [Serializable]
    public abstract partial class OCase : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the location table.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the equipment table.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the user table.
        /// </summary>
        public abstract Guid? RequestorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor type.
        /// </summary>
        public abstract Guid? RequestorType { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the requestor name.
        /// </summary>
        public abstract String RequestorName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor cell phone.
        /// </summary>
        public abstract String RequestorCellPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor fax number.
        /// </summary>
        public abstract String RequestorFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor email address.
        /// </summary>
        public abstract String RequestorEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor phone number.
        /// </summary>
        public abstract String RequestorPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the priority of this case object.
        /// </summary>
        public abstract int? Priority { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description for this case.
        /// </summary>
        public abstract String ProblemDescription { get; set; }

        /// <summary>
        /// [Column] Gets or sets the flag that indicates whether
        /// this case should automatically transit to "Close" status
        /// when all objects: OWork, ORequestForQuotation, OPurchaseOrder
        /// are at status "Close" or "Cancelled".
        /// </summary>
        public abstract int? IsAutoClose { get;set; }

        /// <summary>
        /// [Column] Gets or sets the date/time that this case
        /// was reported by the user.
        /// </summary>
        public abstract DateTime? ReportedDateTime { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date/time that this case
        /// was completed and closed.
        /// </summary>
        public abstract DateTime? CompletionDateTime { get; set; }

        /// <summary>
        /// Gets or sets the location associated with this case.
        /// </summary>
        public abstract OLocation Location { get; set;}

        /// <summary>
        /// Gets or sets the equipment associated with this case.
        /// </summary>
        public abstract OEquipment Equipment { get;set;}

        /// <summary>
        /// Gets a one-to-many list of OWork objects that represents the list 
        /// of works associated with this case.
        /// </summary>
        public abstract DataList<OWork> Works { get; }

        /// <summary>
        /// Gets a one-to-many list of ORequestForQuotation objects that represents the list 
        /// of request for quotations associated with this case.
        /// </summary>
        public abstract DataList<ORequestForQuotation> RequestForQuotations { get; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseOrder objects that represents the list 
        /// of purchase orders associated with this case.
        /// </summary>
        public abstract DataList<OPurchaseOrder> PurchaseOrders { get; }


        public abstract OUser Requestor { get; set; }
        /// <summary>
        /// Gets the location associated with this Case.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();
                if (this.Location != null)
                    locations.Add(this.Location);
                return locations;
            }
        }

        /// <summary>
        /// Gets the location associated with this Case.
        /// </summary>
        public override List<OEquipment> TaskEquipments
        {
            get
            {
                List<OEquipment> equipments = new List<OEquipment>();
                if (this.Equipment != null)
                    equipments.Add(this.Equipment);
                return equipments;
            }
        }

        /// <summary>
        /// Called just before the object is saved.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            // this can be customized further to show location/type of service, etc at the
            // inbox of tasks
            //
            this.ObjectName = this.ProblemDescription;
        }


        /// <summary>
        /// Create the related Works/RFQs/POs.
        /// </summary>
        public override void Saved()
        {
            base.Saved();
            SaveRelatedDocumentsAsDraft();
        }


        /// <summary>
        /// Creates the related documents such as works, RFQs and POs.
        /// </summary>
        public void SaveRelatedDocumentsAsDraft()
        {
            using (Connection c = new Connection())
            {
                foreach (OWork work in this.Works)
                {
                    if (work.CurrentActivity.ObjectName == "Start" && work.EventToTrigger != null)
                    {
                        string eventToTrigger = work.EventToTrigger;
                        work.EventToTrigger = null;
                        work.SaveAndTransit(eventToTrigger);
                    }
                }

                foreach (ORequestForQuotation requestForQuotation in this.RequestForQuotations)
                {
                    if (requestForQuotation.CurrentActivity.ObjectName == "Start")
                    {
                        requestForQuotation.DateEnd = requestForQuotation.DateRequired;
                        requestForQuotation.TriggerWorkflowEvent("SaveAsDraft");
                        requestForQuotation.Save();
                    }
                }

                foreach (OPurchaseOrder purchaseOrder in this.PurchaseOrders)
                {
                    if (purchaseOrder.CurrentActivity.ObjectName == "Start")
                    {
                        purchaseOrder.DateEnd = purchaseOrder.DateRequired;
                        purchaseOrder.TriggerWorkflowEvent("SaveAsDraft");
                        purchaseOrder.Save();
                    }
                }

                c.Commit();
            }
        }


        /// <summary>
        /// Validates that the case with the specified ID is not
        /// closed or cancelled, or that the case does not exist.
        /// </summary>
        /// <returns></returns>
        public static bool ValidateCaseNotClosedOrCancelled(Guid? caseId)
        {
            TCase c = TablesLogic.tCase;

            string status =
                c.Select(c.CurrentActivity.ObjectName)
                .Where(c.ObjectID == caseId & c.IsDeleted == 0);

            if (status != null && status.Is("Close", "Cancelled"))
                return false;
            return true;
        }


        /// <summary>
        /// Validates to ensure that all documents are closed
        /// or cancelled. Returns true if so, false otherwise.
        /// </summary>
        /// <returns>
        /// </returns>
        public bool ValidateAllDocumentsClosedOrCancelled()
        {
            TWork work = TablesLogic.tWork;
            TPurchaseOrder po = TablesLogic.tPurchaseOrder;
            TRequestForQuotation rfq = TablesLogic.tRequestForQuotation;

            // Load all current statuses of all documents
            // related to the specified case
            //
            DataTable dt1 = work.Select(work.ObjectID, work.CurrentActivity.ObjectName).Where(work.CaseID == this.ObjectID);
            DataTable dt2 = po.Select(po.ObjectID, po.CurrentActivity.ObjectName).Where(po.CaseID == this.ObjectID);
            DataTable dt3 = rfq.Select(rfq.ObjectID, rfq.CurrentActivity.ObjectName).Where(rfq.CaseID == this.ObjectID);

            foreach (DataRow dr in dt2.Rows)
                dt1.Rows.Add(dr[0], dr[1]);
            foreach (DataRow dr in dt3.Rows)
                dt1.Rows.Add(dr[0], dr[1]);

            // Determine whether all documents related
            // to this case has been closed or cancelled.
            //
            bool allClosedAndCancelled = true;
            foreach (DataRow dr in dt1.Rows)
            {
                string status = "";
                if (dr[1] != DBNull.Value)
                    status = (string)dr[1];

                if (OApplicationSetting.Current.CaseEventAfterDocumentClosedOrCancelled == "SubmitForClosure")
                {
                    if (status != "PendingClosure" && status != "Close" && status != "Cancelled")
                    {
                        allClosedAndCancelled = false;
                        break;
                    }
                }
                else
                {
                    if (status != "Close" && status != "Cancelled")
                    {
                        allClosedAndCancelled = false;
                        break;
                    }
                }
            }
            return allClosedAndCancelled;
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="caseId"></param>
        public static void CloseCaseWhenAllDocumentsClosedOrCancelled(Guid? caseId)
        {
            if (caseId == null)
                return;

            // Don't bother search for related documents, if
            // the user has indicated not to auto-close
            // the case when all related documents are
            // closed/cancelled.
            //
            OCase caseToClose = TablesLogic.tCase.Load(caseId);
            if (caseToClose.IsAutoClose != 1)
                return;

            //Get the target of TriggerWorkflowEvent from applicationsetting.
            //
            string s = OApplicationSetting.Current.CaseEventAfterDocumentClosedOrCancelled;

            // Close the case only if all works, RFQs, POs have
            // been closed or cancelled.
            //
            bool allClosedAndCancelled = caseToClose.ValidateAllDocumentsClosedOrCancelled();
            if (allClosedAndCancelled)
            {
                using (Connection c = new Connection())
                {
                    if (s == null)
                        caseToClose.TriggerWorkflowEvent("Close");
                    else
                        caseToClose.TriggerWorkflowEvent(s);
                    caseToClose.Save();
                    c.Commit();
                }
            }
        }


        /// <summary>
        /// Gets a list of all cases accessible by the user.
        /// </summary>
        /// <param name="user"></param>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public static DataTable GetAccessibleOpenCases(OUser user, string objectType, Guid? includingCaseId)
        {
            // Gets the list of all accessible locations / equipment.
            //
            ArrayList locationIds = new ArrayList();
            ArrayList equipmentIds = new ArrayList();
            foreach (OPosition position in user.GetPositionsByObjectType(objectType))
            {
                foreach (OLocation location in position.LocationAccess)
                    locationIds.Add(location.ObjectID.Value);
                foreach (OEquipment equipment in position.EquipmentAccess)
                    equipmentIds.Add(equipment.ObjectID.Value);
            }

            // Get all the hierarchy paths of all
            // accessible locations.
            //
            TLocation loc = TablesLogic.tLocation;
            TEquipment eqpt = TablesLogic.tEquipment;
            DataTable locHierarchyPaths = loc.Select(loc.HierarchyPath).Where(loc.IsDeleted == 0 & loc.ObjectID.In(locationIds));
            DataTable eqptHierarchyPaths = eqpt.Select(eqpt.HierarchyPath).Where(eqpt.IsDeleted == 0 & eqpt.ObjectID.In(equipmentIds));

            // Construct the condition to include only
            // locations accessible by the specified
            // user.
            //
            TCase c = TablesLogic.tCase;
            ExpressionCondition locCond = Query.False;
            ExpressionCondition eqptCond = Query.False;
            foreach (DataRow dr in locHierarchyPaths.Rows)
                locCond = locCond | c.Location.HierarchyPath.Like((string)dr[0] + "%");
            foreach (DataRow dr in eqptHierarchyPaths.Rows)
                eqptCond = eqptCond | c.Equipment.HierarchyPath.Like((string)dr[0] + "%");

            // Query the DB and return the result.
            //
            return c.Select(
                c.ObjectID,
                (c.ObjectNumber + ": " + c.ProblemDescription).As("Case"))
                .Where(
                (locCond &
                (c.EquipmentID == null | eqptCond) &
                c.IsDeleted == 0 &
                c.CurrentActivity.ObjectName != "Cancelled" &
                c.CurrentActivity.ObjectName != "Close") |
                c.ObjectID == includingCaseId)
                .OrderBy(
                c.ObjectNumber.Asc);
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get the Requestor history based on the Requestor ID for the past
        /// month.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public DataTable RequestorHistoryForOneMonth
        {
            get
            {
                if (this.RequestorID != null)
                {
                    return TablesLogic.tCase.Select(
                        TablesLogic.tCase.ObjectID,
                        TablesLogic.tCase.RequestorName,
                        TablesLogic.tCase.ObjectNumber,
                        TablesLogic.tCase.ProblemDescription,
                        TablesLogic.tCase.Priority,
                        TablesLogic.tCase.Equipment.ObjectName.As("Equipment"),
                        TablesLogic.tCase.Location.ObjectName.As("Location"),
                        TablesLogic.tCase.CurrentActivity.ObjectName.As("StatusName"),
                        TablesLogic.tCase.CreatedDateTime)
                        .Where(
                        TablesLogic.tCase.RequestorID == this.RequestorID &
                        TablesLogic.tCase.CreatedDateTime >= DateTime.Now.AddMonths(-1));
                }
                return null;
            }
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get the location history based on the location ID for the past
        /// month.
        /// </summary>
        /// --------------------------------------------------------------
        public DataTable LocationHistoryForOneMonth
        {
            get
            {
                return TablesLogic.tCase.Select(
                    TablesLogic.tCase.ObjectID,
                    TablesLogic.tCase.RequestorName,
                    TablesLogic.tCase.ObjectNumber,
                    TablesLogic.tCase.ProblemDescription,
                    TablesLogic.tCase.Priority,
                    TablesLogic.tCase.Equipment.ObjectName.As("Equipment"),
                    TablesLogic.tCase.Location.ObjectName.As("Location"),
                    TablesLogic.tCase.CurrentActivity.ObjectName.As("StatusName"),
                    TablesLogic.tCase.CreatedDateTime)
                    .Where(
                    TablesLogic.tCase.LocationID == this.LocationID &
                    TablesLogic.tCase.CreatedDateTime >= DateTime.Now.AddMonths(-1));
            }
        }
    }
}

