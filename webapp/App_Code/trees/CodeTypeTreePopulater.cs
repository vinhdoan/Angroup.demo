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
/// Summary description for CodeTreePopulater
/// </summary>
public class CodeTypeTreePopulater : TreePopulater
{
    public CodeTypeTreePopulater(object selectedValue)
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
        OCodeType codeType = TablesLogic.tCodeType[new Guid(value)];

        if (codeType != null && codeType.Parent != null)
            return CreateTreeNode(
                codeType.Parent.ObjectName,
                codeType.Parent.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCodeType");
        else
            return null;
    }


    /// <summary>
    /// Creates and returns the children tree nodes.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();
        OCodeType codeType = TablesLogic.tCodeType[new Guid(value)];

        foreach (OCodeType childCodeType in codeType.Children)
            treeNodes.Add(CreateTreeNode(
                childCodeType.ObjectName, childCodeType.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCodeType"));

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

        OCodeType codeType = TablesLogic.tCodeType[(Guid)selectedValue];

        // 2010.05.10
        // Kim Foong
        // Fixes a bug when the selectedValue yields no results,
        // an exception will be thrown.
        //
        if (codeType == null)
            return new List<TreeNode>();

        TreeNode treeNode = CreateTreeNode(
            codeType.ObjectName, codeType.ObjectID.ToString(),
            ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCodeType");

        List<TreeNode> treeNodes = new List<TreeNode>();
        treeNodes.Add(treeNode);
        return treeNodes;
    }


    /// <summary>
    /// Creates and returns the list of root nodes.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeAccessibleNodes()
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        foreach (OCodeType codeType in OCodeType.GetRootCodeTypes())
            treeNodes.Add(CreateTreeNode(
                codeType.ObjectName, codeType.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCodeType"));

        return treeNodes;
    }


    /// <summary>
    /// Searchs and returns a list of tree nodes representing
    /// the code types that match the search criteria.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        foreach (OCodeType codeType in OCodeType.FindCodeTypes(value))
            treeNodes.Add(CreateTreeNode(
                codeType.ObjectName, codeType.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCodeType"));

        return treeNodes;
    }

}
