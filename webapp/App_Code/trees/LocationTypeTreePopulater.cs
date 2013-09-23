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
public class LocationTypePopulater : TreePopulater
{
    bool showLeafNode = false;
    bool selectLeafNodeOnly = false;


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="showLeafNode"></param>
    /// <param name="selectLeafNodeOnly"></param>
    public LocationTypePopulater(object selectedValue, bool showLeafNode, bool selectLeafNodeOnly)
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
    public LocationTypePopulater(object selectedValue, bool showLeafNode)
        : base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = false;
    }


    /// <summary>
    /// Creates the parent node given the child node's value.
    /// </summary>
    /// <param name="childNodeValue"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string childNodeValue)
    {
        OLocationType o = TablesLogic.tLocationType.Load(TablesLogic.tLocationType.ObjectID == new Guid(childNodeValue), true);

        if (o != null && o.Parent != null)
            return CreateTreeNode(
                o.Parent.ObjectName, o.Parent.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OLocationType");
        else
            return null;
    }


    /// <summary>
    /// Create children nodes given the parent ID.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public List<TreeNode> CreateChildrenNodes(Guid? id)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        if (showLeafNode)
        {
            // Load and create the treenodes for the folders
            //
            List<OLocationType> locationTypes =
                TablesLogic.tLocationType.LoadList(
                TablesLogic.tLocationType.ParentID == id & 
                TablesLogic.tLocationType.IsLeafType == 0,
                TablesLogic.tLocationType.IsLeafType.Asc,
                TablesLogic.tLocationType.Base.ObjectName.Asc);
            foreach(OLocationType locationType in locationTypes)
                treeNodes.Add(CreateTreeNode(
                    locationType.ObjectName, 
                    locationType.ObjectID.ToString(), 
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"],
                    "OLocationType",
                    selectLeafNodeOnly ? false : true));

            // Load and create the treenodes for the types.
            //
            locationTypes =
                TablesLogic.tLocationType.LoadList(
                TablesLogic.tLocationType.ParentID == id & 
                TablesLogic.tLocationType.IsLeafType == 1,
                TablesLogic.tLocationType.IsLeafType.Asc,
                TablesLogic.tLocationType.Base.ObjectName.Asc);
            foreach(OLocationType locationType in locationTypes)
                treeNodes.Add(CreateTreeNode(
                    locationType.ObjectName, 
                    locationType.ObjectID.ToString(), 
                    ConfigurationManager.AppSettings["ImageUrl_ObjectType"],
                    "OLocationType",
                    true));

        }
        else
        {
            List<OLocationType> locationTypes =
                TablesLogic.tLocationType.LoadList(
                TablesLogic.tLocationType.ParentID == id & 
                TablesLogic.tLocationType.IsLeafType == 0);
            foreach(OLocationType locationType in locationTypes)
                treeNodes.Add(CreateTreeNode(
                    locationType.ObjectName, 
                    locationType.ObjectID.ToString(), 
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"],
                    "OLocationType",
                    selectLeafNodeOnly ? false : true));
        }

        return treeNodes;
    }


    /// <summary>
    /// Create the children nodes given the parent node's value.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string value)
    {
        return CreateChildrenNodes(new Guid(value));
    }


    /// <summary>
    /// Create the selected node.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeVisibleNodes()
    {
        if (selectedValue is Guid)
        {
            OLocationType locationType = TablesLogic.tLocationType.Load(TablesLogic.tLocationType.ObjectID == (Guid)selectedValue, true);

            if (locationType != null)
            {
                TreeNode treeNode = CreateTreeNode(
                    locationType.ObjectName,
                    locationType.ObjectID.ToString(),
                    locationType.IsLeafType == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"] :
                    ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OLocationType",
                    selectLeafNodeOnly ? locationType.IsLeafType == 1 : true
                    );

                List<TreeNode> treeNodes = new List<TreeNode>();
                treeNodes.Add(treeNode);
                return treeNodes;

            }
        }
        
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
    /// Creates a list of tree nodes representing
    /// the location types whose names match
    /// the specified string.
    /// </summary>
    /// <param name="patternToMatch"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string patternToMatch)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load location type folders.
        //
        List<OLocationType> locationTypes =            
            OLocationType.FindLocationType(false, patternToMatch);
        foreach (OLocationType locationType in locationTypes)
            treeNodes.Add(CreateTreeNode(
                locationType.ObjectName, locationType.ObjectID.ToString(), 
                ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], 
                "OLocationType",
                selectLeafNodeOnly ? false : true));

        // Load and create the treenodes for the types.
        //
        locationTypes =
            OLocationType.FindLocationType(true, patternToMatch);
        foreach (OLocationType locationType in locationTypes)
            treeNodes.Add(CreateTreeNode(
                locationType.ObjectName, locationType.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], 
                "OLocationType", 
                true));

        return treeNodes;
    }

}
