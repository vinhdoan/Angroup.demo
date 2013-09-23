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
using Anacle.DataFramework;

/// <summary>
/// Summary description for LocationTypePopulater
/// </summary>
public class FixedRateTreePopulater : TreePopulater
{
    private bool selectGroup;
    private bool selectRate;
    private Guid? contractID;

    public FixedRateTreePopulater(object selectedValue)
        :base(selectedValue)
    {
    }

    public FixedRateTreePopulater(object selectedValue, 
        bool selectGroup, bool selectRate)
        : base(selectedValue)
    {
        this.selectGroup = selectGroup;
        this.selectRate = selectRate;
    }

    public FixedRateTreePopulater(object selectedValue, Guid contractID)
        : base(selectedValue)
    {
        this.selectGroup = false;
        this.selectRate = true;
        this.contractID = contractID;
    }
    public FixedRateTreePopulater(object selectedValue, Guid contractID, bool selectAll)
        : base(selectedValue)
    {
        this.selectGroup = selectAll;
        this.selectRate = true;
        this.contractID = contractID;
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
            return CreateNode(TablesLogic.tFixedRate.Load(TablesLogic.tFixedRate.ObjectID == new Guid(value), true).Parent.ObjectID);
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
        if (contractID != null)
        {
            // if a contract is specified, and the contract has a purchasing agreement,
            // make sure that we show only items specified under the purchasing agreement.
            //
            OContract contract = TablesLogic.tContract[contractID];
            if (contract.ProvidePricingAgreement == 1)
            {
                DataList<OContractPriceService> list = contract.ContractPriceServices;
                List<TreeNode> nodes = new List<TreeNode>();

                foreach (OContractPriceService m in list)
                {
                    OFixedRate f = TablesLogic.tFixedRate[m.FixedRateID];
                    if (f != null)
                        nodes.Add(CreateTreeNode(
                            f.ObjectName, 
                            f.ObjectID.ToString(),
                            f.IsFixedRate == 0 ?
                            ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"] :
                            ConfigurationManager.AppSettings["ImageUrl_ObjectType"], 
                            "OFixedRate",
                            selectRate ? f.IsFixedRate == 1 : false));
                }
                return nodes;
            }
            return null;
        }
        else
            return CreateChildrenNodes(null);
    }



    /// <summary>
    /// Searches and returns a list of nodes that match
    /// the search criteria.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load groups
        //
        List<OFixedRate> serviceCatalogs = 
            OFixedRate.FindFixedRate(false, value);
        foreach(OFixedRate serviceCatalog in serviceCatalogs)
            treeNodes.Add(CreateTreeNode(
                serviceCatalog.ObjectName, serviceCatalog.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_FixedRateLogical"], "OFixedRate", selectGroup));

        // Load items
        //
        serviceCatalogs =
            OFixedRate.FindFixedRate(true, value);
        foreach(OFixedRate serviceCatalog in serviceCatalogs)
            treeNodes.Add(CreateTreeNode(
                serviceCatalog.ObjectName, serviceCatalog.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_FixedRatePhysical"], "OFixedRate", selectRate));

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns a single treenode.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected TreeNode CreateNode(Guid? id)
    {
        if (id != null)
        {
            OFixedRate serviceCatalog = TablesLogic.tFixedRate.Load(TablesLogic.tFixedRate.ObjectID == (Guid)id, true);
            if (serviceCatalog != null)
                return CreateTreeNode(
                    serviceCatalog.ObjectName,
                    serviceCatalog.ObjectID.ToString(),
                    serviceCatalog.IsFixedRate == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_FixedRateLogical"] :
                    ConfigurationManager.AppSettings["ImageUrl_FixedRatePhysical"], 
                    "OFixedRate",
                    serviceCatalog.IsFixedRate == 0 ? 
                    selectGroup : selectRate
                    );
        }

        return null;
    }


    /// <summary>
    /// Creates and returns a list of children nodes.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected List<TreeNode> CreateChildrenNodes(Guid? id)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load groups
        //
        List<OFixedRate> serviceCatalogs = 
            TablesLogic.tFixedRate[
            TablesLogic.tFixedRate.ParentID == id & TablesLogic.tFixedRate.IsFixedRate == 0];
        foreach (OFixedRate serviceCatalog in serviceCatalogs)
            treeNodes.Add(CreateTreeNode(
                serviceCatalog.ObjectName, serviceCatalog.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_FixedRateLogical"], "OFixedRate", selectGroup));

        // Load items
        //
        serviceCatalogs =
            TablesLogic.tFixedRate[
            TablesLogic.tFixedRate.ParentID == id & TablesLogic.tFixedRate.IsFixedRate == 1];
        foreach (OFixedRate serviceCatalog in serviceCatalogs)
            treeNodes.Add(CreateTreeNode(
                serviceCatalog.ObjectName, serviceCatalog.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_FixedRatePhysical"], "OFixedRate", selectRate));
        
        return treeNodes;
    }

}
