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
/// Summary description for LocationTypePopulater
/// </summary>
public class ChecklistTreePopulater : TreePopulater
{
    private bool selectLogicalChecklist;
    private bool selectPhysicalChecklist;
    private int? checkListType;

    public ChecklistTreePopulater(object selectedValue)
        :base(selectedValue)
    {
    }

    public ChecklistTreePopulater(object selectedValue, bool selectLogicalChecklist, bool selectPhysicalChecklist)
        : base(selectedValue)
    {
        this.selectLogicalChecklist = selectLogicalChecklist;
        this.selectPhysicalChecklist = selectPhysicalChecklist;
    }

    public ChecklistTreePopulater(object selectedValue, bool selectLogicalChecklist, bool selectPhysicalChecklist, int checkListType)
        : base(selectedValue)
    {
        this.selectLogicalChecklist = selectLogicalChecklist;
        this.selectPhysicalChecklist = selectPhysicalChecklist;
        this.checkListType = checkListType;
    }

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

    public override TreeNode MakeParentNode(string value)
    {
        try 
        {
            return CreateNode(TablesLogic.tChecklist.Load(TablesLogic.tChecklist.ObjectID == new Guid(value), true).Parent.ObjectID); 
        }
        catch 
        { 
            return null; 
        }
    }


    public override List<TreeNode> MakeChildrenNodes(string value)
    {
        return CreateChildrenNodes(new Guid(value));
    }


    public override List<TreeNode> MakeAccessibleNodes()
    {
        // (later) this must be tied to the user's access rights.
        return CreateChildrenNodes(null);
    }


    /// <summary>
    /// Creates and returns a list of tree nodes of checklists
    /// whose name matches the one passed in through
    /// the parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Search checklist groups.
        //
        List<OChecklist> checklists =
            TablesLogic.tChecklist[
            TablesLogic.tChecklist.ObjectName.Like("%" + value + "%") &
            TablesLogic.tChecklist.IsChecklist == 0];
        foreach (OChecklist checklist in checklists)
            treeNodes.Add(CreateTreeNode(
                checklist.ObjectName, checklist.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ChecklistLogical"], "OChecklist", selectLogicalChecklist));

        // Search checklists.
        //
        checklists =
            TablesLogic.tChecklist[
            TablesLogic.tChecklist.ObjectName.Like("%" + value + "%") &
            TablesLogic.tChecklist.IsChecklist == 1];
        foreach (OChecklist checklist in checklists)
            treeNodes.Add(CreateTreeNode(
                checklist.ObjectName, checklist.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ChecklistPhysical"], "OChecklist", selectPhysicalChecklist));

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns a checklist treenode.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected TreeNode CreateNode(Guid? id)
    {
        if (id != null)
        {
            OChecklist checklist = TablesLogic.tChecklist.Load(TablesLogic.tChecklist.ObjectID == (Guid)id, true);
            if (checklist != null)
                return CreateTreeNode(
                    checklist.ObjectName,
                    checklist.ObjectID.ToString(),
                    checklist.IsChecklist == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_ChecklistLogical"] :
                    ConfigurationManager.AppSettings["ImageUrl_ChecklistPhysical"], "CHECKLIST",
                    checklist.IsChecklist == 0 ? selectLogicalChecklist : selectPhysicalChecklist);
        }

        return null;
    }


    /// <summary>
    /// Creates and returns a list of children treenodes.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected List<TreeNode> CreateChildrenNodes(Guid? id)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load checklist groups.
        //
        List<OChecklist> checklists =
            TablesLogic.tChecklist[
            TablesLogic.tChecklist.ParentID == id & TablesLogic.tChecklist.IsChecklist == 0];
        foreach (OChecklist checklist in checklists)
            treeNodes.Add(CreateTreeNode(
                checklist.ObjectName, checklist.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ChecklistLogical"], "CHECKLIST", selectLogicalChecklist));
        
        // Load checklists.
        //
        checklists =
            TablesLogic.tChecklist[
            TablesLogic.tChecklist.ParentID == id & TablesLogic.tChecklist.IsChecklist == 1 &
            (this.checkListType != null ? TablesLogic.tChecklist.Type == this.checkListType : Query.True)];
        foreach (OChecklist checklist in checklists)
            treeNodes.Add(CreateTreeNode(
                checklist.ObjectName, checklist.ObjectID.ToString(),
            ConfigurationManager.AppSettings["ImageUrl_ChecklistPhysical"], "CHECKLIST", selectPhysicalChecklist));

        return treeNodes;
    }

}
