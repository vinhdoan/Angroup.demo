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

using LogicLayer;

/// <summary>
/// Summary description for LocationTypePopulater
/// </summary>
public class CodeTreePopulater : TreePopulater
{
    public CodeTreePopulater(object selectedValue)
        :base(selectedValue)
    {
    }


    /// <summary>
    /// Creates and returns the parent tree node.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string value)
    {
        OCode code = TablesLogic.tCode[new Guid(value)];

        if (code != null && code.Parent != null)
            return CreateTreeNode(
                code.Parent.ObjectName,
                code.Parent.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCode");
        else
            return null;
    }


    /// <summary>
    /// Creates and returns a list of children nodes.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();
        OCode code = TablesLogic.tCode[new Guid(value)];

        foreach (OCode childCode in code.Children)
            treeNodes.Add(CreateTreeNode(
                childCode.ObjectName, childCode.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCode"));

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns the selected node.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeVisibleNodes()
    {
        if (!(selectedValue is Guid))
            return null;

        OCode code = TablesLogic.tCode[(Guid)selectedValue];

        // 2010.05.10
        // Kim Foong
        // Fixes a bug when the selectedValue yields no results,
        // an exception will be thrown.
        //
        if (code == null)
            return new List<TreeNode>();

        TreeNode treeNode = CreateTreeNode(code.ObjectName, code.ObjectID.ToString(), 
            ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCode");

        List<TreeNode> treeNodes = new List<TreeNode>();
        treeNodes.Add(treeNode);
        return treeNodes;
    }


    /// <summary>
    /// Creates and returns the root nodes.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeAccessibleNodes()
    {
        List<TreeNode> treeNodes = new List<TreeNode>();
        foreach (OCode childCode in OCode.GetRootCodes())
            treeNodes.Add(CreateTreeNode(
                childCode.ObjectName, childCode.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCode"));

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns a list of tree nodes representing
    /// the codes that match the search criteria.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        foreach (OCode childCode in OCode.FindCodes(value))
            treeNodes.Add(CreateTreeNode(
                childCode.ObjectName, childCode.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCode"));

        return treeNodes;
    }

}
