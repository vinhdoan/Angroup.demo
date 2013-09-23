//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
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
using LogicLayer;

/// <summary>
/// Summary description for PointTriggerTreePopulater
/// </summary>
public class PointTriggerTreePopulater : TreePopulater
{
    private bool selectLogicalPointTrigger;
    private bool selectPhysicalPointTrigger;
    private string objectType;


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalPointTrigger"></param>
    /// <param name="selectPhysicalPointTrigger"></param>
    public PointTriggerTreePopulater(object selectedValue, bool selectLogicalPointTrigger, bool selectPhysicalPointTrigger, string objectType)
        : base(selectedValue)
    {
        this.selectLogicalPointTrigger = selectLogicalPointTrigger;
        this.selectPhysicalPointTrigger = selectPhysicalPointTrigger;
        this.objectType = objectType;
    }


    /// <summary>
    /// Creates the node whose ID is the one specified in 
    /// selectedValue.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeVisibleNodes()
    {
        if (selectedValue is Guid)
        {
            TreeNode treeNode = CreateNode((Guid)selectedValue);
            List<TreeNode> treeNodes = new List<TreeNode>();
            treeNodes.Add(treeNode);
            return treeNodes;
        }
        else
            return null;
    }


    /// <summary>
    /// Creates a list of all root nodes.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeAccessibleNodes()
    {
        return CreateChildrenNodes(null);
    }

    /// <summary>
    /// Creates the parent node of the child, whose
    /// ID is as specified in the value parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string childNodeValue)
    {
        OPointTrigger trigger = TablesLogic.tPointTrigger.Load(TablesLogic.tPointTrigger.ObjectID == new Guid(childNodeValue), true);
        if (trigger != null)
            return CreateNode(trigger.ParentID);
        else
            return null;
    }


    


    /// <summary>
    /// Creates and returns a list of children nodes whose
    /// parent ID is specified in the <c>value</c> parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string parentNodeValue)
    {
        return CreateChildrenNodes(new Guid(parentNodeValue));
    }

    public List<TreeNode> CreateChildrenNodes(Guid? id)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();
        
        // Load children triggers.
        //
        List<OPointTrigger> triggers =
            TablesLogic.tPointTrigger.LoadList(
            TablesLogic.tPointTrigger.ParentID == id,
            TablesLogic.tPointTrigger.IsLeafType.Asc,
            TablesLogic.tPointTrigger.ObjectName.Asc);

        foreach (OPointTrigger trigger in triggers)
        {
            if (trigger.IsLeafType == 0)
            {
                // Logical triggers
                //
                treeNodes.Add(CreateTreeNode(
                    trigger.ObjectName, trigger.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_PointTriggerLogical"],
                    "OPointTrigger",
                    selectLogicalPointTrigger));
            }
            else
            {
                // Physical triggers
                //
                treeNodes.Add(CreateTreeNode(
                    trigger.ObjectName, trigger.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_PointTriggerPhysical"],
                    "OPointTrigger",
                    selectPhysicalPointTrigger));
            }
        }
        return treeNodes;
    }


    /// <summary>
    /// Creates and returns a list of tree nodes of physical triggers
    /// whose name matches the one passed in through
    /// the parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string patternToMatch)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load triggers.
        //
        List<OPointTrigger> triggers =
            TablesLogic.tPointTrigger.LoadList(
            TablesLogic.tPointTrigger.ObjectName.Like("%" + patternToMatch + "%") &
            TablesLogic.tPointTrigger.IsLeafType == 1,
            TablesLogic.tPointTrigger.ObjectName.Asc);
        foreach (OPointTrigger trigger in triggers)
            treeNodes.Add(CreateTreeNode(
                trigger.ObjectName, trigger.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_PointTriggerPhysical"],
                "OPointTrigger", selectPhysicalPointTrigger));

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns the tree node of the trigger
    /// with the specified object ID.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected TreeNode CreateNode(Guid? id)
    {
        if (id != null)
        {
            OPointTrigger trigger = TablesLogic.tPointTrigger.Load(TablesLogic.tPointTrigger.ObjectID == (Guid)id, true);
            if (trigger != null)
            {
                return CreateTreeNode(
                    trigger.ObjectName,
                    trigger.ObjectID.ToString(),
                    trigger.IsLeafType == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_PointTriggerLogical"] :
                    ConfigurationManager.AppSettings["ImageUrl_PointTriggerPhysical"], "OPointTrigger",
                    trigger.IsLeafType == 0 ? selectLogicalPointTrigger : selectPhysicalPointTrigger);
            }
        }

        return null;
    }


}
