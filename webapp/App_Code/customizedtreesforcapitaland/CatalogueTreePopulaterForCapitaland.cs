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
public class CatalogueTreePopulater : TreePopulater
{
    bool showLeafNode = false;
    bool selectLeafNodeOnly = false;
    //represent the store id that the item resides in. if it is null, then all item will be displayed, if it is not null, then only item of the store will be displayed
    Guid? storeID;
    Guid? contractID;
    bool showNonEquipmentTypeCatalogues = true;
    bool showEquipmentTypeCatalogues = false;
    List<OStore> list;

    public CatalogueTreePopulater(object selectedValue, bool showLeafNode, bool selectLeafNodeOnly,
        bool showNonEquipmentTypeCatalogues, bool showEquipmentTypeCatalogues, List<OStore> list)
        : base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = selectLeafNodeOnly;
        this.showNonEquipmentTypeCatalogues = showNonEquipmentTypeCatalogues;
        this.showEquipmentTypeCatalogues = showEquipmentTypeCatalogues;
        this.list = list;
    }

    public CatalogueTreePopulater(object selectedValue, bool showLeafNode, bool selectLeafNodeOnly)
        : base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = selectLeafNodeOnly;
        storeID = null;
    }

    public CatalogueTreePopulater(object selectedValue, bool showLeafNode, bool selectLeafNodeOnly,
        bool showNonEquipmentTypeCatalogues, bool showEquipmentTypeCatalogues)
        : base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = selectLeafNodeOnly;
        this.showNonEquipmentTypeCatalogues = showNonEquipmentTypeCatalogues;
        this.showEquipmentTypeCatalogues = showEquipmentTypeCatalogues;
        storeID = null;
    }

    public CatalogueTreePopulater(object selectedValue, Guid storeID, bool showLeafNode, bool selectLeafNodeOnly)
        : base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = selectLeafNodeOnly;
        this.storeID = storeID;
    }


    public CatalogueTreePopulater(object selectedValue, Guid contractID)
        : base(selectedValue)
    {
        this.showLeafNode = true;
        this.selectLeafNodeOnly = true;
        this.contractID = contractID;
    }


    public CatalogueTreePopulater(object selectedValue, Guid? storeID, Guid? contractID, bool showLeafNode, bool selectLeafNodeOnly, bool showNonEquipmentTypeCatalogues, bool showEquipmentTypeCatalogues)
        : base(selectedValue)
    {
        this.showLeafNode = true;
        this.selectLeafNodeOnly = true;
        this.contractID = contractID;
        this.storeID = storeID;
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = selectLeafNodeOnly;
        this.showNonEquipmentTypeCatalogues = showNonEquipmentTypeCatalogues;
        this.showEquipmentTypeCatalogues = showEquipmentTypeCatalogues;
    }


    public CatalogueTreePopulater(object selectedValue, bool showLeafNode)
        : base(selectedValue)
    {
        this.showLeafNode = showLeafNode;
        this.selectLeafNodeOnly = false;
    }


    /// <summary>
    /// Creates and returns the parent tree node.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string value)
    {
        OCatalogue o = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.ObjectID == new Guid(value), false);

        if (o != null && o.Parent != null)
            return CreateTreeNode(
                o.Parent.ObjectName, o.Parent.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OCatalogue");
        else
            return null;
    }


    /// <summary>
    /// Searches and returns the tree nodes.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string value)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load catalog folders
        //
        List<OCatalogue> inventoryCatalogs =
            OCatalogue.FindCatalogue(false, value, 
            showNonEquipmentTypeCatalogues, showEquipmentTypeCatalogues);
        foreach (OCatalogue inventoryCatalog in inventoryCatalogs)
            treeNodes.Add(CreateTreeNode(
                inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
            ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OCatalogue", !selectLeafNodeOnly));

        // Load catalog items
        //
        inventoryCatalogs =
            OCatalogue.FindCatalogue(true, value, 
            showNonEquipmentTypeCatalogues, showEquipmentTypeCatalogues);
        foreach (OCatalogue inventoryCatalog in inventoryCatalogs)
            treeNodes.Add(CreateTreeNode(
                inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCatalogue", true));

        return treeNodes;
    }


    public List<TreeNode> LoadChildrenNodes(Guid? id)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        if (showLeafNode)
        {
            // Load catalog folders
            //
            List<OCatalogue> inventoryCatalogs =
                TablesLogic.tCatalogue[
                (
                (showNonEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 0 : Query.False) |
                (showEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 1 : Query.False)
                ) &

                TablesLogic.tCatalogue.ParentID == id & TablesLogic.tCatalogue.IsCatalogueItem == 0,
                TablesLogic.tCatalogue.IsCatalogueItem.Asc,
                TablesLogic.tCatalogue.ObjectName.Asc];

            foreach (OCatalogue inventoryCatalog in inventoryCatalogs)
            {
                if (list != null)
                {
                    Boolean CatalogueHasStoreID = false;
                    foreach (OStore s in inventoryCatalog.Store)
                        foreach (OStore s2 in list)
                            if (s.ObjectID == s2.ObjectID)
                            {
                                CatalogueHasStoreID = true;
                                break;
                            }
                    if (inventoryCatalog.IsSharedAcrossAllStores == 1 || CatalogueHasStoreID == true)
                        treeNodes.Add(CreateTreeNode(
                            inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
                            ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OCatalogue",
                            selectLeafNodeOnly ? false : true));
                }
                else
                treeNodes.Add(CreateTreeNode(
                    inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OCatalogue",
                    selectLeafNodeOnly ? false : true));
            }
            // Load catalog items
            //
            inventoryCatalogs =
                TablesLogic.tCatalogue[
                (
                (showNonEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 0 : Query.False) |
                (showEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 1 : Query.False)
                ) &

                TablesLogic.tCatalogue.ParentID == id & TablesLogic.tCatalogue.IsCatalogueItem == 1,
                TablesLogic.tCatalogue.IsCatalogueItem.Asc,
                TablesLogic.tCatalogue.Base.ObjectName.Asc];
            foreach (OCatalogue inventoryCatalog in inventoryCatalogs)
            {
                if (list != null)
                {
                    Boolean CatalogueHasStoreID = false;
                    foreach (OStore s in inventoryCatalog.Store)
                        foreach (OStore s2 in list)
                            if (s.ObjectID == s2.ObjectID)
                            {
                                CatalogueHasStoreID = true;
                                break;
                            }
                    if (inventoryCatalog.IsSharedAcrossAllStores == 1 || CatalogueHasStoreID == true)
                        treeNodes.Add(CreateTreeNode(
                            inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
                            ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCatalogue", true));
                }
                else
                    treeNodes.Add(CreateTreeNode(
                            inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
                            ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCatalogue", true));
            }
        }
        else
        {
            List<OCatalogue> inventoryCatalogs =
                TablesLogic.tCatalogue[
                (
                (showNonEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 0 : Query.False) |
                (showEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 1 : Query.False)
                ) &

                TablesLogic.tCatalogue.ParentID == id & TablesLogic.tCatalogue.IsCatalogueItem == 0];
            foreach (OCatalogue inventoryCatalog in inventoryCatalogs)
            {
                if (list != null)
                {
                    Boolean CatalogueHasStoreID = false;
                    foreach (OStore s in inventoryCatalog.Store)
                        foreach (OStore s2 in list)
                            if (s.ObjectID == s2.ObjectID)
                            {
                                CatalogueHasStoreID = true;
                                break;
                            }
                    if ((CatalogueHasStoreID == true || inventoryCatalog.IsSharedAcrossAllStores == 1 ))
                        treeNodes.Add(CreateTreeNode(
                            inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
                                ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OCatalogue"));
                }
                else
                    treeNodes.Add(CreateTreeNode(
                            inventoryCatalog.ObjectName, inventoryCatalog.ObjectID.ToString(),
                                ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"], "OCatalogue"));
            }
        }

        return treeNodes;
    }


    /// <summary>
    /// Creates and returns a list of children nodes.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string value)
    {
        return LoadChildrenNodes(new Guid(value));
    }


    /// <summary>
    /// Creates and returns the selected node.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeVisibleNodes()
    {
        if (selectedValue != null && selectedValue is Guid)
        {
            OCatalogue catalogue = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.ObjectID == (Guid)selectedValue, true);

            if (catalogue != null)
            {
                TreeNode treeNode = CreateTreeNode(
                    catalogue.ObjectName,
                    catalogue.ObjectID.ToString(),
                    catalogue.IsCatalogueItem == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"] :
                    ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCatalogue",
                    selectLeafNodeOnly ? catalogue.IsCatalogueItem == 1 : true
                    );
                List<TreeNode> treeNodes = new List<TreeNode>();
                treeNodes.Add(treeNode);
                return treeNodes;
            }
        }

        return null;
    }


    /// <summary>
    /// Creates a list of root nodes.
    /// </summary>
    /// <returns></returns>
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
                DataList<OContractPriceMaterial> list = contract.ContractPriceMaterials;
                List<TreeNode> nodes = new List<TreeNode>();

                foreach (OContractPriceMaterial m in list)
                {
                    OCatalogue c = TablesLogic.tCatalogue[(Guid)m.CatalogueID];
                    if (c != null)
                        nodes.Add(CreateTreeNode(
                            c.ObjectName,
                            c.ObjectID.ToString(), 
                            c.IsCatalogueItem == 0 ?
                            ConfigurationManager.AppSettings["ImageUrl_ObjectGroup"] :
                            ConfigurationManager.AppSettings["ImageUrl_ObjectType"], "OCatalogue",
                            selectLeafNodeOnly ? c.IsCatalogueItem == 1 : false));
                }
                return nodes;
            }
            return null;
        }
        else
            return LoadChildrenNodes(null);
    }

}
