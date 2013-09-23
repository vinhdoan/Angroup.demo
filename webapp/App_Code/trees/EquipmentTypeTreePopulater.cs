//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
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
/// Summary description for CodeTreePopulater
/// </summary>
public class EquipmentTypeTreePopulater : TreePopulater
{
    bool showLeafNode = false;
    bool selectLeafNodeOnly = false;


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="showLeafNode"></param>
    /// <param name="selectLeafNodeOnly"></param>
    public EquipmentTypeTreePopulater(object selectedValue, bool showLeafNode, bool selectLeafNodeOnly)
        :base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = selectLeafNodeOnly;
    }


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="showLeafNode"></param>
    public EquipmentTypeTreePopulater(object selectedValue, bool showLeafNode)
        : base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = false;
    }


    /// <summary>
    /// Creates the parent node of the child, whose
    /// ID is as specified in the value parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string value)
    {
        OEquipmentType o = TablesLogic.tEquipmentType.Load(TablesLogic.tEquipmentType.ObjectID == new Guid(value), true);

        if (o != null && o.Parent != null)
            return CreateTreeNode(
                o.Parent.ObjectName, o.Parent.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OEquipmentType");
        else
            return null;
    }



    /// <summary>
    /// Creates and returns a list of tree nodes of physical equipment
    /// whose name matches the one passed in through
    /// the parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string patternToMatch)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();
        
        // Search folders
        //
        List<OEquipmentType> equipmentTypes = OEquipmentType.FindEquipmentType(false, patternToMatch);
        foreach (OEquipmentType equipmentType in equipmentTypes)
            treeNodes.Add(CreateTreeNode(
                equipmentType.ObjectName, equipmentType.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OEquipmentType", !selectLeafNodeOnly));

        // Search types.
        //
        equipmentTypes = OEquipmentType.FindEquipmentType(true, patternToMatch);
        foreach (OEquipmentType equipmentType in equipmentTypes)
            treeNodes.Add(CreateTreeNode(
                equipmentType.ObjectName, equipmentType.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OEquipmentType", true));

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns a list of children tree nodes given
    /// the parent id.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public List<TreeNode> CreateChildrenNodes(Guid? id)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        if (showLeafNode)
        {
            // Load folders
            //
            List<OEquipmentType> equipmentTypes =
                TablesLogic.tEquipmentType.LoadList(
                TablesLogic.tEquipmentType.ParentID == id &
                TablesLogic.tEquipmentType.IsLeafType == 0,
                TablesLogic.tEquipmentType.IsLeafType.Asc,
                TablesLogic.tEquipmentType.Base.ObjectName.Asc);
            foreach (OEquipmentType equipmentType in equipmentTypes)
                treeNodes.Add(CreateTreeNode(
                    equipmentType.ObjectName, equipmentType.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"],
                    "OEquipmentType",
                    selectLeafNodeOnly ? false : true));

            // Load types
            //
            equipmentTypes =
                TablesLogic.tEquipmentType.LoadList(
                TablesLogic.tEquipmentType.ParentID == id & TablesLogic.tEquipmentType.IsLeafType == 1,
                TablesLogic.tEquipmentType.IsLeafType.Asc,
                TablesLogic.tEquipmentType.Base.ObjectName.Asc);
            foreach (OEquipmentType equipmentType in equipmentTypes)
                treeNodes.Add(CreateTreeNode(
                    equipmentType.ObjectName, equipmentType.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_ObjectType"],
                    "OEquipmentType",
                    true));

        }
        else
        {
            List<OEquipmentType> equipmentTypes =
                TablesLogic.tEquipmentType.LoadList(
                TablesLogic.tEquipmentType.ParentID == id & TablesLogic.tEquipmentType.IsLeafType == 0);
            foreach (OEquipmentType equipmentType in equipmentTypes)
                treeNodes.Add(CreateTreeNode(
                    equipmentType.ObjectName, equipmentType.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"],
                    "OEquipmentType",
                    selectLeafNodeOnly ? false : true));
        }
        return treeNodes;
    }


    /// <summary>
    /// Creates children nodes.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string parentNodeValue)
    {
        return CreateChildrenNodes(new Guid(parentNodeValue));
    }


    /// <summary>
    /// Creates the selected node.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeVisibleNodes()
    {
        if (selectedValue is Guid)
        {
            OEquipmentType equipmentType = TablesLogic.tEquipmentType.Load(TablesLogic.tEquipmentType.ObjectID == (Guid)selectedValue, true);

            if (equipmentType != null && selectedValue != null)
            {
                TreeNode treeNode = CreateTreeNode(
                    equipmentType.ObjectName,
                    equipmentType.ObjectID.ToString(),
                    equipmentType.IsLeafType == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"] :
                    ConfigurationManager.AppSettings["ImageUrl_ObjectType"],
                    "OEquipmentType",
                    selectLeafNodeOnly ? equipmentType.IsLeafType == 1 : true
                    );

                List<TreeNode> treeNodes = new List<TreeNode>();
                treeNodes.Add(treeNode);
                return treeNodes;
            }
        }
        
        return null;
    }


    /// <summary>
    /// Creates the list of root nodes.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeAccessibleNodes()
    {
        return CreateChildrenNodes(null);
    }

}
