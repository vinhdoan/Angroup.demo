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
using LogicLayer;

/// <summary>
/// Summary description for UserTreePopulater
/// </summary>
public class UserTreePopulater : TreePopulater
{
    private string objectType;
    public UserTreePopulater(object selectedValue)
        :base(selectedValue)
    {
    }

    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalLocation"></param>
    /// <param name="selectPhysicalLocation"></param>
    public UserTreePopulater(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, string objectType)
        : base(selectedValue)
    {
        this.objectType = objectType;
    }

    /// <summary>
    /// Creates and returns the parent tree node.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string value)
    {
        OUser user = TablesLogic.tUser.Load(TablesLogic.tUser.ObjectID == new Guid(value), true);
        if (user != null)
            return CreateNode(user.ParentID);
        else
            return null;
    }

    /// <summary>
    /// Creates and returns the tree node of the location
    /// with the specified object ID.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected TreeNode CreateNode(Guid? id)
    {
        if (id != null)
        {
            OUser cs = TablesLogic.tUser.Load(TablesLogic.tUser.ObjectID == (Guid)id, true);
            if (cs != null)
            {
                return CreateTreeNode(
                    cs.ObjectName,
                    cs.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"], "OUser");
            }
        }

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
        OUser cs = TablesLogic.tUser[new Guid(value)];

        foreach (OUser childCode in cs.Children)
            treeNodes.Add(CreateTreeNode(
                childCode.ObjectName, childCode.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OUser"));

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

        OUser code = TablesLogic.tUser[(Guid)selectedValue];

        // Fixes a bug when the selectedValue yields no results,
        // an exception will be thrown.
        //
        if (code == null)
            return new List<TreeNode>();

        TreeNode treeNode = CreateTreeNode(code.ObjectName, code.ObjectID.ToString(), 
            ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OUser");

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
        foreach (OUser childCode in TablesLogic.tUser.LoadList(TablesLogic.tUser.HierarchyPath.Like(Workflow.CurrentUser.HierarchyPath+"%")))
            treeNodes.Add(CreateTreeNode(
                childCode.ObjectName, childCode.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OUser"));

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

        foreach (OUser childCode in TablesLogic.tUser[TablesLogic.tUser.ObjectName.Like("%" + value + "%")])
            treeNodes.Add(CreateTreeNode(
                childCode.ObjectName, childCode.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCaseSubject"));
        return treeNodes;
    }

}
