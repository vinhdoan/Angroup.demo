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
public class LocationTreePopulater : TreePopulater
{
    private bool selectLogicalLocation;
    private bool selectPhysicalLocation;
    private string objectType;
    private List<string> roleCodes = null;
    private List<Guid> locationList;


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalLocation"></param>
    /// <param name="selectPhysicalLocation"></param>
    public LocationTreePopulater(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, string objectType)
        : base(selectedValue)
    {
        this.selectLogicalLocation = selectLogicalLocation;
        this.selectPhysicalLocation = selectPhysicalLocation;
        this.objectType = objectType;
    }


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalLocation"></param>
    /// <param name="selectPhysicalLocation"></param>
    public LocationTreePopulater(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, List<string> roleCodes)
        : base(selectedValue)
    {
        this.selectLogicalLocation = selectLogicalLocation;
        this.selectPhysicalLocation = selectPhysicalLocation;
        this.roleCodes = roleCodes;
    }


    /// <summary>
    /// Constructor.
    /// locationList will restrict that only those tree nodes belong to or under the locationList will be shown.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalLocation"></param>
    /// <param name="selectPhysicalLocation"></param>
    public LocationTreePopulater(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, string objectType, List<Guid> locationList)
        : base(selectedValue)
    {
        this.selectLogicalLocation = selectLogicalLocation;
        this.selectPhysicalLocation = selectPhysicalLocation;
        this.objectType = objectType;
        this.locationList = locationList;
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
        OLocation location = TablesLogic.tLocation.Load(TablesLogic.tLocation.ObjectID == new Guid(childNodeValue), true);
        if (location != null)
            return CreateNode(location.ParentID);
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
        ArrayList locationIds = new ArrayList();

        if (locationList != null && locationList.Count > 0)
        {
            locationIds.AddRange(locationList);
        }
        else
        {
            if ((objectType == null || objectType == "") && roleCodes == null)
                locationIds.Add(OLocation.GetRootLocation().ObjectID.Value);
            else
            {
                foreach (OPosition position in AppSession.User.GetPositionsByObjectTypeAndRoleCodes(objectType, roleCodes))
                    foreach (OLocation location in position.LocationAccess)
                        locationIds.Add(location.ObjectID.Value);
            }
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
    /// Creates and returns a list of children nodes whose
    /// parent ID is specified in the <c>value</c> parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> MakeChildrenNodes(string parentNodeValue)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();
        Guid id = new Guid(parentNodeValue);

        // Load children locations.
        //
        List<OLocation> locations =
            TablesLogic.tLocation.LoadList(
            TablesLogic.tLocation.ParentID == id,
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


    /// <summary>
    /// Creates and returns a list of tree nodes of physical locations
    /// whose name matches the one passed in through
    /// the parameter.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public override List<TreeNode> SearchNodes(string patternToMatch)
    {
        List<TreeNode> treeNodes = new List<TreeNode>();

        // Load locations.
        //
        List<OLocation> locations = new List<OLocation>();
        if (locationList != null && locationList.Count > 0)
        {
            locations.AddRange(TablesLogic.tLocation.LoadList(TablesLogic.tLocation.ObjectID.In(locationList)));
        }
        else
        {
            locations =
                TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ObjectName.Like("%" + patternToMatch + "%") &
                ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tLocation.GetAccessibleLocationCondition(AppSession.User, objectType, roleCodes)) &
                TablesLogic.tLocation.IsPhysicalLocation == 1,
                TablesLogic.tLocation.ObjectName.Asc);
        }

        foreach (OLocation location in locations)
            treeNodes.Add(CreateTreeNode(
                location.ObjectName, location.ObjectID.ToString(),
                ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"],
                "OLocation", selectPhysicalLocation));
        
        return treeNodes;
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
            OLocation location = TablesLogic.tLocation.Load(TablesLogic.tLocation.ObjectID == (Guid)id, true);
            if (location != null)
            {
                return CreateTreeNode(
                    location.ObjectName,
                    location.ObjectID.ToString(),
                    location.IsPhysicalLocation == 0 ?
                    ConfigurationManager.AppSettings["ImageUrl_LocationLogical"] :
                    ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"], "OLocation",
                    location.IsPhysicalLocation == 0 ? selectLogicalLocation : selectPhysicalLocation);
            }
        }

        return null;
    }


}
