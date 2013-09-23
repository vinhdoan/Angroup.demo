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
/// Summary description for BudgetCategoryTreePopulater
/// </summary>
public class AccountTreePopulaterForCapitaland : TreePopulater
{
    private bool selectCategory;
    private bool selectItem;
    private Guid? budgetPeriodId;
    private Guid? purchaseTypeId;


    public AccountTreePopulaterForCapitaland(object selectedValue)
        : base(selectedValue)
    {
        selectCategory = true;
        selectItem = true;
    }

    public AccountTreePopulaterForCapitaland(object selectedValue, 
        bool selectCategory, bool selectItem)
        : base(selectedValue)
    {
        this.selectCategory = selectCategory;
        this.selectItem = selectItem;
    }


    public AccountTreePopulaterForCapitaland(object selectedValue,
        bool selectCategory, bool selectItem, Guid? budgetPeriodId)
        : base(selectedValue)
    {
        this.selectCategory = selectCategory;
        this.selectItem = selectItem;
        this.budgetPeriodId = budgetPeriodId;
    }


    public AccountTreePopulaterForCapitaland(object selectedValue,
        bool selectCategory, bool selectItem, Guid? budgetPeriodId, Guid? purchaseTypeId)
        : base(selectedValue)
    {
        this.selectCategory = selectCategory;
        this.selectItem = selectItem;
        this.budgetPeriodId = budgetPeriodId;
        this.purchaseTypeId = purchaseTypeId;
    }


    /// <summary>
    /// Constructs and returns a list of selected nodes.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeVisibleNodes()
    {
        if (selectedValue is Guid)
        {
            TreeNode treeNode = CreateNode(TablesLogic.tAccount.Load((Guid)selectedValue));

            List<TreeNode> treeNodes = new List<TreeNode>();
            treeNodes.Add(treeNode);
            return treeNodes;
        }
        else
            return null;
    }


    /// <summary>
    /// Constructs and returns the parent node.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string value)
    {
        try
        {
            return CreateNode(TablesLogic.tAccount.Load(new Guid(value)).Parent);
        }
        catch
        {
            return null;
        }
    }


    /// <summary>
    /// Creates and returns a list of children nodes.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        TBudgetPeriod bp = TablesLogic.tBudgetPeriod;
        TAccount acct = TablesLogic.tAccount;

        // Load folders
        //
        List<OAccount> accounts =
            acct.LoadList(
            acct.ParentID == new Guid(value) &

            // Filter based on purchase types.
            //
            ((acct.Type == 0) |
            (acct.AppliesToAllPurchaseTypes == 1 |
            (purchaseTypeId == null ? Query.True : acct.PurchaseTypes.ObjectID == purchaseTypeId))) &
            
            (budgetPeriodId==null ? Query.True :
            bp.Select(bp.ObjectID).
            Where(
            bp.ObjectID == budgetPeriodId &
            bp.BudgetPeriodOpeningBalances.IsActive == 1 &
            bp.BudgetPeriodOpeningBalances.Account.HierarchyPath.Like(acct.HierarchyPath+"%")).Exists()) &

            acct.IsDeleted == 0,
            acct.Type.Asc,
            acct.ObjectName.Asc);

        foreach (OAccount account in accounts)
            treeNodes.Add(CreateNode(account));

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns a list of root nodes.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeAccessibleNodes()
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        TBudgetPeriod bp = TablesLogic.tBudgetPeriod;
        TAccount acct = TablesLogic.tAccount;

        List<OAccount> accounts =
            acct.LoadList(
            acct.ParentID == null &

            // Filter based on purchase types.
            //
            ((acct.Type == 0) |
            (acct.AppliesToAllPurchaseTypes == 1 |
            (purchaseTypeId == null ? Query.True : acct.PurchaseTypes.ObjectID == purchaseTypeId))) &

            (budgetPeriodId == null ? Query.True :
            bp.Select(bp.ObjectID).
            Where(
            bp.ObjectID == budgetPeriodId &
            bp.BudgetPeriodOpeningBalances.IsActive == 1 &
            bp.BudgetPeriodOpeningBalances.Account.HierarchyPath.Like(acct.HierarchyPath + "%")).Exists())
            ,
            acct.Type.Asc,
            acct.ObjectName.Asc);

        foreach (OAccount account in accounts)
            treeNodes.Add(CreateNode(account));

        return treeNodes;
    }


    /// <summary>
    /// Searches and returns a list of treenodes for budget
    /// category.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load account groups
        //
        List<OAccount> accounts =
            OAccount.FindAccounts(value);
        foreach (OAccount account in accounts)
            treeNodes.Add(CreateNode(account));

        return treeNodes;
    }



    /// <summary>
    /// Creates a tree node from the specified OAccount
    /// object.
    /// </summary>
    /// <param name="account"></param>
    /// <returns></returns>
    protected TreeNode CreateNode(OAccount account)
    {
        if (account != null)
            return CreateTreeNode(
                account.ObjectName,
                account.ObjectID.ToString(),
                account.Type == 0 ?
                ConfigurationManager.AppSettings["ImageUrl_LocationLogical"] :
                ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"],
                "OAccount",
                account.Type == 0 ? selectCategory : selectItem);
        return null;
    }

}
