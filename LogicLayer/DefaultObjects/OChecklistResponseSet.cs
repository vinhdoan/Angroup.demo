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

/// <summary>
/// Summary description for OChecklistResponseSet
/// </summary>

namespace LogicLayer
{
    [Database("#database"), Map("ChecklistResponseSet")]
    [Serializable] public partial class TChecklistResponseSet : LogicLayerSchema<OChecklistResponseSet>
    {
        public SchemaDecimal ScoreDenominator;

        public TChecklistResponse ChecklistResponses { get { return OneToMany<TChecklistResponse>("ChecklistResponseSetID"); } }
    }


    /// <summary>
    /// Represents a single choice in a collection of responses.
    /// For example, "Yes" may be a response in a response set
    /// of "Yes/No/Unknown".
    /// </summary>
    [Serializable]
    public abstract partial class OChecklistResponseSet : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the maximum score that can be
        /// attained for this response set.
        /// </summary>
        public abstract decimal? ScoreDenominator { get; set; }

        /// <summary>
        /// Gets a list of ChecklistResponse objects associated with this ChecklistResponseSet
        /// </summary>
        public abstract DataList<OChecklistResponse> ChecklistResponses { get; }


        /// <summary>
        /// Disallows delete if:
        /// 1. There is at least one checklist that uses this response.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (TablesLogic.tChecklist.LoadList(
                TablesLogic.tChecklist.ChecklistItems.ChecklistResponseSetID == this.ObjectID).Count > 0)
                return false;

            return base.IsDeactivatable();
        }


        public static List<OChecklistResponseSet> GetAllResponseSets()
        {
            return TablesLogic.tChecklistResponseSet[Query.True];
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Automatically compute the maximum score.
        /// </summary>
        /// --------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            decimal maxScore = 0;
            foreach (OChecklistResponse checklistResponse in ChecklistResponses)
            {
                if (checklistResponse.ScoreNumerator != null)
                    if ((decimal)checklistResponse.ScoreNumerator > maxScore)
                        maxScore = (decimal)checklistResponse.ScoreNumerator;
            }
            ScoreDenominator = maxScore;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Re-order the list of items in the checklist response set.
        /// </summary>
        /// <param name="i"></param>
        /// --------------------------------------------------------------
        public void ReorderItems(OChecklistResponse p)
        {
            // kf begin: consolidate the reorder function into a global method.
            /*
            Hashtable h = new Hashtable();
            int max = 0;
            foreach (OChecklistResponse o in ChecklistResponses)
            {
                // kf bug fix
                if (o != null && p != null && o.ObjectID == p.ObjectID)
                    o.DisplayOrder = o.DisplayOrder * 2 - 1;
                else
                    o.DisplayOrder = o.DisplayOrder * 2;

                if (o.DisplayOrder == null)
                    o.DisplayOrder = max + 2;

                h[o.DisplayOrder.Value] = o;
                if (o.DisplayOrder.Value > max)
                    max = o.DisplayOrder.Value;
            }

            int c = 1;
            for (int i = 0; i <= max; i++)
                if (h[i] != null)
                    ((OChecklistResponse)h[i]).DisplayOrder = c++;
             */
            Global.ReorderItems(ChecklistResponses, p, "DisplayOrder");
            // kf end;
        }

        /// <summary>
        /// check if checklist changeable
        /// </summary>
        public bool IsDesignChangeable
        {
            get
            {
                bool IsDesignChangeable = true;
                int Count = (int)TablesLogic.tChecklist.Select(TablesLogic.tChecklist.ObjectID.Count())
                                .Where(TablesLogic.tChecklist.ChecklistItems.ChecklistResponseSetID == this.ObjectID &
                                       TablesLogic.tChecklist.Type == ChecklistType.Survey &
                                       TablesLogic.tChecklist.IsDeleted == 0 &
                                       TablesLogic.tChecklist.ChecklistItems.IsDeleted == 0);
                if (Count > 0)
                    IsDesignChangeable = false;

                return IsDesignChangeable;
            }
        }

    }

}

