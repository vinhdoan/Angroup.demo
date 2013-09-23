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
    /// Summary description for OChecklist
    /// </summary>
    [Database("#database"), Map("ApprovalHierarchy")]
    public partial class TApprovalHierarchy : LogicLayerSchema<OApprovalHierarchy>
    {
        public TApprovalHierarchyLevel ApprovalHierarchyLevels { get { return OneToMany<TApprovalHierarchyLevel>("ApprovalHierarchyID"); } }
    }


    public abstract partial class OApprovalHierarchy : LogicLayerPersistentObject
    {
        public abstract DataList<OApprovalHierarchyLevel> ApprovalHierarchyLevels { get; }


        /// <summary>
        /// Disallow deleting if:
        /// <para></para>
        /// 1. This approval hierarchy is currently associated with an
        /// approval process.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if ((int)TablesLogic.tApprovalProcess.Select(
                TablesLogic.tApprovalProcess.ObjectID.Count())
                .Where(
                TablesLogic.tApprovalProcess.IsDeleted == 0 &
                TablesLogic.tApprovalProcess.ApprovalHierarchyID == this.ObjectID &
                TablesLogic.tApprovalProcess.ModeOfForwarding != ApprovalModeOfForwarding.None) > 0)
                return false;

            return true;
        }


        /// <summary>
        /// Overrides the saving method to:
        /// <para></para>
        /// 1. Update the approval level numbers of each of the approval hierarchy level
        ///    objects.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            UpdateApprovalLevels();
        }


        /// <summary>
        /// Gets all approval hierarchies.
        /// </summary>
        public static List<OApprovalHierarchy> GetAllApprovalHierarchies()
        {
            return TablesLogic.tApprovalHierarchy.LoadAll();
        }


        /// <summary>
        /// Sort the approval hierarchy level objects and assign
        /// a sequential running number start from 1.
        /// </summary>
        public void UpdateApprovalLevels()
        {
            if (this.ApprovalHierarchyLevels.Count > 0)
            {
                List<OApprovalHierarchyLevel> sortedApprovalHierarchyLevels =
                    this.ApprovalHierarchyLevels.Order(TablesLogic.tApprovalHierarchyLevel.ApprovalLimit.Asc);

                int i = 1;
                foreach (OApprovalHierarchyLevel approvalHierarchyLevel in sortedApprovalHierarchyLevels)
                    approvalHierarchyLevel.ApprovalLevel = i++;
            }
        }


        /// <summary>
        /// Finds the OApprovalHierarchyLevel in this object so that its ApprovalLevel = level
        /// <para></para>
        /// This method is used in the hierarchical-forwarding scenario.
        /// </summary>
        /// <param name="level">The approval hierarchy level, in the order
        /// of the approval limit. The first approval hierarchy level is
        /// 1, the second is 2, and so on.</param>
        /// <returns>Returns the OApprovalHierarchyLevel object.</returns>
        public OApprovalHierarchyLevel FindApprovalHierarchyLevelByLevel(int level)
        {
            foreach (OApprovalHierarchyLevel approvalHierarchyLevel in this.ApprovalHierarchyLevels)
                if (approvalHierarchyLevel.ApprovalLevel == level)
                    return approvalHierarchyLevel;
            return null;
        }


        /// <summary>
        /// Finds the OApprovalHierarchyLevel in this object so that its ApprovalLevel = level
        /// <para></para>
        /// This method is used in the hierarchical-forwarding scenario.
        /// </summary>
        /// <param name="level">The approval hierarchy level, in the order
        /// of the approval limit. The first approval hierarchy level is
        /// 1, the second is 2, and so on.</param>
        /// <returns>Returns the OApprovalHierarchyLevel object.</returns>
        public OApprovalHierarchyLevel FindNextApprovalHierarchyLevelWithApprovalLimitAfterLevel(int level)
        {
            int lowestLevel = int.MaxValue;
            OApprovalHierarchyLevel lowestApprovalHierarchyLevel = null;

            foreach (OApprovalHierarchyLevel approvalHierarchyLevel in this.ApprovalHierarchyLevels)
                if (approvalHierarchyLevel.ApprovalLevel > level &&
                    approvalHierarchyLevel.FinalApprovalLimit != null &&
                    approvalHierarchyLevel.ApprovalLevel.Value < lowestLevel)
                {
                    lowestLevel = approvalHierarchyLevel.ApprovalLevel.Value;
                    lowestApprovalHierarchyLevel = approvalHierarchyLevel;
                }
            return lowestApprovalHierarchyLevel;
        }


        /// <summary>
        /// Finds the OApprovalHierarchyLevel in this object so that its ApprovalLevel = level
        /// <para></para>
        /// This method is used in the hierarchical-forwarding scenario.
        /// </summary>
        /// <param name="level">The approval hierarchy level, in the order
        /// of the approval limit. The first approval hierarchy level is
        /// 1, the second is 2, and so on.</param>
        /// <returns>Returns the OApprovalHierarchyLevel object.</returns>
        public OApprovalHierarchyLevel FindNextRequiredApprovalHierarchyLevelAfterLevel(int level)
        {
            int lowestLevel = int.MaxValue;
            OApprovalHierarchyLevel lowestApprovalHierarchyLevel = null;

            foreach (OApprovalHierarchyLevel approvalHierarchyLevel in this.ApprovalHierarchyLevels)
                if (approvalHierarchyLevel.ApprovalLevel > level &&
                    approvalHierarchyLevel.FinalApprovalLimit == ApprovalLimit.RequiredApprovalLimit &&
                    approvalHierarchyLevel.ApprovalLevel.Value < lowestLevel)
                {
                    lowestLevel = approvalHierarchyLevel.ApprovalLevel.Value;
                    lowestApprovalHierarchyLevel = approvalHierarchyLevel;
                }
            return lowestApprovalHierarchyLevel;
        }

        /// <summary>
        /// Finds the approval hierarchy level such that the approval limit
        /// is greater than the specified amount, but with the lowest approval level. 
        /// <para></para>
        /// This method is used in the direct-forwarding and forward-to-all scenario.
        /// </summary>
        /// <param name="amount"></param>
        /// <returns></returns>
        public OApprovalHierarchyLevel FindApprovalHierarchyLevelByAmount(decimal amount)
        {
            OApprovalHierarchyLevel applicableApprovalHierarchyLevel = null;
            int highestApprovaLevel = 0;
            decimal lowestApprovalAmount = decimal.MaxValue;

            foreach (OApprovalHierarchyLevel hierarchyLevel in this.ApprovalHierarchyLevels)
                if (hierarchyLevel.FinalApprovalLimit >= amount && hierarchyLevel.FinalApprovalLimit < lowestApprovalAmount)
                    lowestApprovalAmount = hierarchyLevel.FinalApprovalLimit.Value;

            foreach (OApprovalHierarchyLevel hierarchyLevel in this.ApprovalHierarchyLevels)
            {
                if (hierarchyLevel.FinalApprovalLimit == lowestApprovalAmount &&
                    hierarchyLevel.ApprovalLevel > highestApprovaLevel)
                {
                    highestApprovaLevel = hierarchyLevel.ApprovalLevel.Value;
                    applicableApprovalHierarchyLevel = hierarchyLevel;
                }
            }
            return applicableApprovalHierarchyLevel;
        }


        /// <summary>
        /// Finds a list of approval hierarchy levels such that the approval level
        /// of the approval hierarchy level objects are between the specified
        /// level and the first level authorized to approve the object.
        /// <para></para>
        /// This method is used in the all-forwarding scenario.
        /// </summary>
        /// <param name="level"></param>
        /// <param name="amount"></param>
        /// <returns></returns>
        public List<OApprovalHierarchyLevel> FindApprovalHierarchyLevelsAboveApprovalLevelAndByAmount(int level, decimal amount)
        {
            List<OApprovalHierarchyLevel> approvalHierarchyLevels = new List<OApprovalHierarchyLevel>();

            OApprovalHierarchyLevel authorizedLevel = FindApprovalHierarchyLevelByAmount(amount);
            if (authorizedLevel == null)
                return approvalHierarchyLevels;

            foreach (OApprovalHierarchyLevel approvalHierarchyLevel in
                this.ApprovalHierarchyLevels.Order("FinalApprovalLimit ASC"))
            {
                if (approvalHierarchyLevel.ApprovalLevel >= level &&
                    approvalHierarchyLevel.FinalApprovalLimit != null &&
                    (approvalHierarchyLevel.ApprovalLevel <= authorizedLevel.ApprovalLevel ||
                    approvalHierarchyLevel.FinalApprovalLimit == ApprovalLimit.RequiredApprovalLimit))
                    approvalHierarchyLevels.Add(approvalHierarchyLevel);
            }
            return approvalHierarchyLevels;
        }
    }


}