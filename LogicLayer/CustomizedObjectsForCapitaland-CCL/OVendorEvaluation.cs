//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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

    public partial class TVendorEvaluation : LogicLayerSchema<OVendorEvaluation>
    {
        public SchemaGuid VendorID;
        public SchemaGuid ContractID;
        public SchemaGuid ChecklistID;

        public SchemaString EvaluationRemarks;

        public SchemaDateTime StartDate;
        public SchemaDateTime EndDate;

        public SchemaInt IsApproved;

        public TVendor Vendor { get { return OneToOne<TVendor>("VendorID"); } }
        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }
        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }

        public SchemaDecimal TotalScore;

        public TVendorEvaluationChecklistItem VendorEvaluationChecklistItems { get { return OneToMany<TVendorEvaluationChecklistItem>("VendorEvaluationID"); } }
    }


    public abstract partial class OVendorEvaluation : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract Guid? VendorID { get; set; }
        public abstract Guid? ContractID { get; set; }
        public abstract Guid? ChecklistID { get; set; }

        public abstract string EvaluationRemarks { get; set; }
        public abstract DateTime? StartDate { get; set; }
        public abstract DateTime? EndDate { get; set; }

        public abstract int? IsApproved { get; set; }

        public abstract OVendor Vendor { get; set; }
        public abstract OContract Contract { get; set; }
        public abstract OChecklist Checklist { get; set; }

        public abstract decimal? TotalScore { get; set; }

        public abstract DataList<OVendorEvaluationChecklistItem> VendorEvaluationChecklistItems { get; }

        public override decimal TaskAmount
        {
            get
            {
                return this.Contract.ContractSum.Value;
            }
        }

        /// <summary>
        /// Gets a list of all locations applicable to this task.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in this.Contract.Locations)
                    locations.Add(location);
                return locations;
            }
        }

        public void UpdateChecklist()
        {
            this.VendorEvaluationChecklistItems.Clear();

            if (Checklist != null)
            {
                foreach (OChecklistItem checklistItem in Checklist.ChecklistItems)
                {
                    OVendorEvaluationChecklistItem vendorEvaluationChecklistItem = TablesLogic.tVendorEvaluationChecklistItem.Create();

                    vendorEvaluationChecklistItem.ObjectName = checklistItem.ObjectName;
                    vendorEvaluationChecklistItem.StepNumber = checklistItem.StepNumber;
                    vendorEvaluationChecklistItem.ChecklistType = checklistItem.ChecklistType;
                    vendorEvaluationChecklistItem.ChecklistResponseSetID = checklistItem.ChecklistResponseSetID;
                    vendorEvaluationChecklistItem.ChecklistItemID = checklistItem.ObjectID;
                    vendorEvaluationChecklistItem.IsOverall = checklistItem.IsOverall;
                    this.VendorEvaluationChecklistItems.Add(vendorEvaluationChecklistItem);
                }
            }
        }

        public void Approve()
        {
            using (Connection c = new Connection())
            {
                this.IsApproved = 1;
            }
        }

        public override void Saving()
        {
            base.Saving();
            this.TotalScore = 0M;
            foreach (OVendorEvaluationChecklistItem item in this.VendorEvaluationChecklistItems)
                this.TotalScore += item.SelectedResponse.ScoreNumerator.Value;
        }

        public override void Deactivating()
        {
            base.Deactivating();
            foreach (OVendorEvaluationChecklistItem item in this.VendorEvaluationChecklistItems)
                item.Deactivate();

        }
        
    }

}
