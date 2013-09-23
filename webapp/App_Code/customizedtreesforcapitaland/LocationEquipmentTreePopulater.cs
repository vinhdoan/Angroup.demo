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
/// Summary description for LocationTreePopulater
/// </summary>
public class LocationEquipmentTreePopulaterForCapitaland : TreePopulater
{
    private bool selectLogicalLocation;
    private bool selectPhysicalLocation;
    private bool selectPhysicalEquipment;
    private string objectType = null;
    private List<string> roleCodes = null;


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="updateRightPanel"></param>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalLocation"></param>
    /// <param name="selectPhysicalLocation"></param>
    /// <param name="selectPhysicalEquipment"></param>
    /// <param name="roleCodes"></param>
    public LocationEquipmentTreePopulaterForCapitaland(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, bool selectPhysicalEquipment, string objectType)
        : base(selectedValue)
    {
        this.selectLogicalLocation = selectLogicalLocation;
        this.selectPhysicalLocation = selectPhysicalLocation;
        this.selectPhysicalEquipment = selectPhysicalEquipment;
        this.objectType = objectType;
    }


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="updateRightPanel"></param>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalLocation"></param>
    /// <param name="selectPhysicalLocation"></param>
    /// <param name="selectPhysicalEquipment"></param>
    /// <param name="roleCodes"></param>
    public LocationEquipmentTreePopulaterForCapitaland(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, bool selectPhysicalEquipment, List<string> roleCodes)
        : base(selectedValue)
    {
        this.selectLogicalLocation = selectLogicalLocation;
        this.selectPhysicalLocation = selectPhysicalLocation;
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



    public override TreeNode MakeParentNode(string childNodeValue)
    {
        try
        {
            // If this node is a special folder that contains
            // equipment in a location, create the 
            //
            if (childNodeValue.StartsWith(">"))
            {
                return CreateNode(new Guid(childNodeValue.Substring(1)));
            }

            // If the node is an equipment, then create a folder
            // named "Equipment" as its parent. The value of
            // the folder should be the Object ID of the 
            // location prefixed with a ">" character.
            //
            OEquipment eqp = TablesLogic.tEquipment[new Guid(childNodeValue)];
            if (eqp != null)
                return CreateTreeNode(
                    Resources.Objects.OEquipment,
                    ">" + eqp.LocationID.Value.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentLogical"], "", false);

            // If this is neither an equipment or a special folder,
            // then treat it as if it's a location, and return
            // the parent of the location.
            //
            OLocation location = TablesLogic.tLocation.Load(
                TablesLogic.tLocation.Children.ObjectID == new Guid(childNodeValue), true);
            return CreateTreeNode(
                    location.ObjectName,
                    location.ObjectID.ToString(),
                    location.IsPhysicalLocation == 1 ?
                    ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"] :
                    ConfigurationManager.AppSettings["ImageUrl_LocationLogical"], "OLocation");

            return null;
        }
        catch { return null; }
    }


    /// <summary>
    /// Creates children nodes.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string parentNodeValue)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        if (parentNodeValue.StartsWith(">"))
        {
            Guid id = new Guid(parentNodeValue.Substring(1));

            // Load equipment under selected area
            //
            List<OEquipment> equipments = 
                TablesLogic.tEquipment.LoadList(
                TablesLogic.tEquipment.GetAccessibleEquipmentByAreaCondition(AppSession.User, objectType, roleCodes) &
                TablesLogic.tEquipment.LocationID == id &
                TablesLogic.tEquipment.IsPhysicalEquipment == 1 &
                (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff  | TablesLogic.tEquipment.Status == null));
            foreach (OEquipment equipment in equipments)
                treeNodes.Add(CreateTreeNode(
                    equipment.ObjectName, equipment.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentPhysical"],
                    "OEquipment",
                    selectPhysicalEquipment));
        }
        else
        {
            Guid id = new Guid(parentNodeValue);

            // Create a new empty Equipment folder
            //
            List<OEquipment> equipmentList = TablesLogic.tEquipment[
                GetAccessibleEquipmentByEquipmentCondition(objectType, roleCodes) &
                TablesLogic.tEquipment.LocationID == id & TablesLogic.tEquipment.IsPhysicalEquipment == 1 &
                (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null)];

            if (equipmentList.Count > 0)
            {
                treeNodes.Add(CreateTreeNode(Resources.Objects.OEquipment, ">" + id.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentLogical"], "", false));
            }

            // Load children location folders
            //
            List<OLocation> locations = 
                TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ParentID == id &
                TablesLogic.tLocation.IsPhysicalLocation == 0 &
                TablesLogic.tLocation.IsActive == 1);
            foreach (OLocation location in locations)
                treeNodes.Add(CreateTreeNode(
                    location.ObjectName, location.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_LocationLogical"],
                    "OLocation",
                    selectLogicalLocation));

            // Load children physical locations 
            //
            locations = 
                TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ParentID == id &
                TablesLogic.tLocation.IsPhysicalLocation == 1 &
                TablesLogic.tLocation.IsActive == 1);
            foreach (OLocation location in locations)
                treeNodes.Add(CreateTreeNode(
                    location.ObjectName, location.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"],
                    "OLocation",
                    selectPhysicalLocation));
        }
        return treeNodes;
    }


    /// <summary>
    /// Creates a list of nodes accessible by the current 
    /// logged user.
    /// </summary>
    /// <returns></returns>
    public override List<TreeNode> MakeAccessibleNodes()
    {
        ArrayList locationIds = new ArrayList();
        if ((objectType == null || objectType == "") && roleCodes == null)
            locationIds.Add(OLocation.GetRootLocation().ObjectID.Value);
        else
        {
            foreach (OPosition position in AppSession.User.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
                foreach (OLocation location in position.LocationAccess)
                    locationIds.Add(location.ObjectID.Value);
        }


        if (locationIds.Count > 0)
        {
            List<TreeNode> treeNodes = new List<TreeNode>();

            // Load location folders.
            //
            List<OLocation> locations =
                TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ObjectID.In(locationIds),
                TablesLogic.tLocation.IsPhysicalLocation.Asc,
                TablesLogic.tLocation.ObjectName.Asc);

            foreach (OLocation location in locations)
            {
                if (location.IsPhysicalLocation == 0)
                {
                    // Logical locations
                    //
                    treeNodes.Add(CreateTreeNode(
                        location.ObjectName, location.ObjectID.ToString(),
                        ConfigurationManager.AppSettings["ImageUrl_LocationLogical"],
                        "OLocation",
                        selectLogicalLocation));
                }
                else
                {
                    // Physical locations
                    //
                    treeNodes.Add(CreateTreeNode(
                        location.ObjectName, location.ObjectID.ToString(),
                        ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"],
                        "OLocation",
                        selectPhysicalLocation));
                }
            }

            return treeNodes;
        }
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

        // Load children location folders
        //
        List<OLocation> locations =
            TablesLogic.tLocation.LoadList(
            TablesLogic.tLocation.ObjectName.Like("%" + patternToMatch + "%") &
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tLocation.GetAccessibleLocationCondition(AppSession.User, objectType, roleCodes)) &
            TablesLogic.tLocation.IsPhysicalLocation == 1);
        foreach (OLocation location in locations)
            treeNodes.Add(CreateTreeNode(
                location.ObjectName, location.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"],
                "OLocation", selectPhysicalLocation));

        // Load children physical locations 
        //
        List<OEquipment> equipments = 
            TablesLogic.tEquipment.LoadList(
            TablesLogic.tEquipment.ObjectName.Like("%" + patternToMatch + "%") &
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentCondition(AppSession.User, objectType, roleCodes)) &
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tEquipment.GetAccessibleEquipmentByAreaCondition(AppSession.User, objectType, roleCodes)) &
            TablesLogic.tEquipment.IsPhysicalEquipment == 1 &
            (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null));
        foreach (OEquipment equipment in equipments)
            treeNodes.Add(CreateTreeNode(
                equipment.ObjectName, equipment.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_EquipmentPhysical"],
                "OEquipment", selectPhysicalEquipment));

        return treeNodes;
    }

    
    /// <summary>
    /// Creates a tree node based on the object ID specified
    /// in the <c>id</c> parameter.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    protected TreeNode CreateNode(Guid? id)
    {
        if (id != null)
        {
            OLocation location = TablesLogic.tLocation.Load(TablesLogic.tLocation.ObjectID == (Guid)id, true);
            if (location != null)
                return CreateTreeNode(
                    location.ObjectName,
                    location.ObjectID.ToString(),
                    location.IsPhysicalLocation == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_LocationLogical"] :
                    ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"], "OLocation", 
                    location.IsPhysicalLocation == 0 ? selectLogicalLocation : selectPhysicalLocation);

            OEquipment equipment = TablesLogic.tEquipment.Load(TablesLogic.tEquipment.ObjectID == (Guid)id, true);
            if (equipment != null)
                return CreateTreeNode(
                    equipment.ObjectName,
                    equipment.ObjectID.ToString(),
                    ConfigurationManager.AppSettings["ImageUrl_EquipmentPhysical"], "OEquipment",
                    selectPhysicalEquipment);
        }

        return null;
    }


    public ExpressionCondition GetAccessibleEquipmentByEquipmentCondition(string objectType, List<string> roleCodes)
    {
        List<OEquipment> equipments = new List<OEquipment>();
        if ((objectType == null || objectType == "") && roleCodes == null)
            equipments.Add(OEquipment.GetRootEquipment());
        else
        {
            foreach (OPosition position in AppSession.User.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
                foreach (OEquipment equipment in position.EquipmentAccess)
                    equipments.Add(equipment);
        }

        ExpressionCondition c = Query.False;
        foreach (OEquipment o in equipments)
            c = c | TablesLogic.tEquipment.HierarchyPath.Like(o.HierarchyPath + "%");
        return c;
    }
}
