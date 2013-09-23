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
/// Summary description for EquipmentTreePopulater
/// </summary>
public class EquipmentTreePopulater : TreePopulater
{
    private bool selectLogicalEquipment;
    private bool selectPhysicalEquipment;
    private string objectType = null;
    private List<string> roleCodes = null;


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalEquipment"></param>
    /// <param name="selectPhysicalEquipment"></param>
    /// <param name="objectType"></param>
    public EquipmentTreePopulater(object selectedValue, bool selectLogicalEquipment, bool selectPhysicalEquipment, string objectType)
        : base(selectedValue)
    {
        this.selectLogicalEquipment = selectLogicalEquipment;
        this.selectPhysicalEquipment = selectPhysicalEquipment;
        this.objectType = objectType;
    }


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalEquipment"></param>
    /// <param name="selectPhysicalEquipment"></param>
    /// <param name="objectType"></param>
    public EquipmentTreePopulater(object selectedValue, bool selectLogicalEquipment, bool selectPhysicalEquipment, List<string> roleCodes)
        : base(selectedValue)
    {
        this.selectLogicalEquipment = selectLogicalEquipment;
        this.selectPhysicalEquipment = selectPhysicalEquipment;
        this.roleCodes = roleCodes;
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
    /// Creates the parent node of the child, whose
    /// ID is as specified in the value parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override TreeNode MakeParentNode(string childNodeValue)
    {
        OEquipment equipment = TablesLogic.tEquipment.Load(TablesLogic.tEquipment.ObjectID == new Guid(childNodeValue), true);
        if (equipment != null)
            return CreateNode(equipment.ParentID);
        else
            return null;
    }



    /// <summary>
    /// Creates a list of nodes accessible by the current 
    /// logged user.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeAccessibleNodes()
    {
        ArrayList equipmentIds = new ArrayList();
        if ((objectType == null || objectType == "") && roleCodes == null)
        {
            equipmentIds.Add(OEquipment.GetRootEquipment().ObjectID.Value);
        }
        else
        {
            foreach (OPosition position in AppSession.User.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
                foreach (OEquipment equipment in position.EquipmentAccess)
                    equipmentIds.Add(equipment.ObjectID.Value);
        }

        List<TreeNode> treeNodes = new List<TreeNode>();

        if (equipmentIds.Count > 0)
        {
            // Load equipment folders
            //
            List<OEquipment> equipments =
                TablesLogic.tEquipment.LoadList(
                TablesLogic.tEquipment.ObjectID.In(equipmentIds) &
                ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentCondition(AppSession.User, objectType, roleCodes)) &
                TablesLogic.tEquipment.IsPhysicalEquipment == 0
                & (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null)
                );
            foreach(OEquipment equipment in equipments)
                treeNodes.Add(CreateTreeNode(
                    equipment.ObjectName, equipment.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentLogical"],
                    "OEquipment", selectLogicalEquipment));

            // Load physical equipment.
            //
            equipments =
                TablesLogic.tEquipment.LoadList(
                TablesLogic.tEquipment.ObjectID.In(equipmentIds) &
                ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentCondition(AppSession.User, objectType, roleCodes)) &
                ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentByAreaAndStoreCondition(AppSession.User, objectType, roleCodes)) &
                TablesLogic.tEquipment.IsPhysicalEquipment == 1
                & (TablesLogic.tEquipment.Status!= EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null)
                );
            foreach(OEquipment equipment in equipments)
                treeNodes.Add(CreateTreeNode(
                    equipment.ObjectName, equipment.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentPhysical"],
                    "OEquipment", selectPhysicalEquipment));

            return treeNodes;
        }
        else
            return null;
    }


    /// <summary>
    /// Creates and returns a list of children nodes.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string parentNodeValue)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();
        Guid parentID = new Guid(parentNodeValue);

        // Load children equipment
        //
        List<OEquipment> equipments =
            TablesLogic.tEquipment.LoadList(
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentCondition(AppSession.User, objectType, roleCodes)) &
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentByAreaAndStoreCondition(AppSession.User, objectType, roleCodes)) &
            TablesLogic.tEquipment.ParentID == parentID
            & (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null),
            TablesLogic.tEquipment.IsPhysicalEquipment.Asc,
            TablesLogic.tEquipment.ObjectName.Asc);

        foreach (OEquipment equipment in equipments)
        {
            if (equipment.IsPhysicalEquipment == 0)
            {
                // Logical equipment
                //
                treeNodes.Add(CreateTreeNode(
                    equipment.ObjectName, equipment.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentLogical"],
                    "OEquipment", selectLogicalEquipment));
            }
            else
            {
                // Physical equipment
                //
                treeNodes.Add(CreateTreeNode(
                    equipment.ObjectName, equipment.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentPhysical"],
                    "OEquipment", selectPhysicalEquipment));
            }
        }

        return treeNodes;
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

        // Load equipment folders
        //
        List<OEquipment> equipments =
            TablesLogic.tEquipment.LoadList(
            (
                TablesLogic.tEquipment.ObjectName.Like("%" + patternToMatch + "%") |
                TablesLogic.tEquipment.Barcode.Like("%" + patternToMatch + "%") |
                TablesLogic.tEquipment.SerialNumber.Like("%" + patternToMatch + "%")
            ) &
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentCondition(AppSession.User, objectType, roleCodes)) &
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentByAreaAndStoreCondition(AppSession.User, objectType, roleCodes)) &
            TablesLogic.tEquipment.IsPhysicalEquipment == 1 &
            (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null),
            TablesLogic.tEquipment.ObjectName.Asc);
        foreach(OEquipment equipment in equipments)
            treeNodes.Add(CreateTreeNode(
                equipment.ObjectName, equipment.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_EquipmentPhysical"],
                "OEquipment", selectPhysicalEquipment));

        return treeNodes;
    }


    /// <summary>
    /// Creates a new tree node for a single piece of equipment.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected TreeNode CreateNode(Guid? id)
    {
        if (id != null)
        {
            OEquipment equipment = TablesLogic.tEquipment.Load(TablesLogic.tEquipment.ObjectID == (Guid)id, true);
            if (equipment != null)
                return CreateTreeNode(
                    equipment.ObjectName,
                    equipment.ObjectID.ToString(),
                    equipment.IsPhysicalEquipment == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentLogical"] :
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentPhysical"], "EQUIPMENT",
                    equipment.IsPhysicalEquipment == 0 ? selectLogicalEquipment : selectPhysicalEquipment);
        }

        return null;
    }
}
