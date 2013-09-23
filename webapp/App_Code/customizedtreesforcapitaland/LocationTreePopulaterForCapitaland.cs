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
public class LocationTreePopulaterForCapitaland : TreePopulater
{

    private bool includeInactiveLocation;
    private bool fromLocationSearch;
    private bool selectLogicalLocation;
    private bool selectPhysicalLocation;
    private string objectType;
    private List<string> roleCodes = null;


    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="selectedValue"></param>
    /// <param name="selectLogicalLocation"></param>
    /// <param name="selectPhysicalLocation"></param>
    public LocationTreePopulaterForCapitaland(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, string objectType, bool includeInactiveLocation, bool fromLocationSearch)
        : base(selectedValue)
    {
        this.includeInactiveLocation = includeInactiveLocation;
        this.fromLocationSearch = fromLocationSearch;
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
    public LocationTreePopulaterForCapitaland(object selectedValue, bool selectLogicalLocation, bool selectPhysicalLocation, List<string> roleCodes, bool includeInactiveLocation, bool fromLocationSearch)
        : base(selectedValue)
    {
        this.includeInactiveLocation = includeInactiveLocation;
        this.fromLocationSearch = fromLocationSearch;
        this.selectLogicalLocation = selectLogicalLocation;
        this.selectPhysicalLocation = selectPhysicalLocation;
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
            OLocation location = TablesLogic.tLocation.Load((Guid)selectedValue);

            String physicalImage = ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"];
            String logicalImage = ConfigurationManager.AppSettings["ImageUrl_LocationLogical"];

            if (location.IsActive == 0)
            {
                physicalImage = "~/images/cross.png";
                logicalImage = "~/images/cross.png";
            }

            List<TreeNode> treeNodes = new List<TreeNode>();
            if (location.IsPhysicalLocation == 0)
            {
                // Logical locations
                //
                treeNodes.Add(CreateTreeNode(
                    location.ObjectName, location.ObjectID.ToString(),
                    logicalImage,
                    "OLocation",
                    (location.IsActive == 1)));
            }
            else
            {
                // Physical locations
                //
                treeNodes.Add(CreateTreeNode(
                    location.ObjectName, location.ObjectID.ToString(),
                    physicalImage,
                    "OLocation",
                    (location.IsActive == 1)));
            }
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
        OLocation location = TablesLogic.tLocation.Load(new Guid(childNodeValue));
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
                String physicalImage = ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"];
                String logicalImage = ConfigurationManager.AppSettings["ImageUrl_LocationLogical"];

                if (location.IsActive == 0)
                {
                    physicalImage = "~/images/cross.png";
                    logicalImage = "~/images/cross.png";
                }

                if (location.IsPhysicalLocation == 0)
                {
                    // Logical locations
                    //
                    treeNodes.Add(CreateTreeNode(
                        location.ObjectName, location.ObjectID.ToString(),
                        logicalImage,
                        "OLocation",
                        (fromLocationSearch || (location.IsActive == 1)) && selectLogicalLocation));
                }
                else
                {
                    // Physical locations
                    //
                    treeNodes.Add(CreateTreeNode(
                        location.ObjectName, location.ObjectID.ToString(),
                        physicalImage,
                        "OLocation",
                        (fromLocationSearch || (location.IsActive == 1)) && selectPhysicalLocation));
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
        List<OLocation> locations = null;
        
        if(!this.includeInactiveLocation)
            locations = TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ParentID == id &
                TablesLogic.tLocation.IsActive==1,
                TablesLogic.tLocation.IsPhysicalLocation.Asc,
                TablesLogic.tLocation.ObjectName.Asc);
        else
            locations = TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ParentID == id,
                TablesLogic.tLocation.IsPhysicalLocation.Asc,
                TablesLogic.tLocation.ObjectName.Asc);

        foreach (OLocation location in locations)
        {
            String physicalImage = ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"];
            String logicalImage = ConfigurationManager.AppSettings["ImageUrl_LocationLogical"];

            if (location.IsActive == 0)
            {
                physicalImage = "~/images/cross.png";
                logicalImage = "~/images/cross.png";
            }
            if (location.IsPhysicalLocation == 0)
            {
                // Logical locations
                //
                treeNodes.Add(CreateTreeNode(
                    location.ObjectName, location.ObjectID.ToString(),
                    logicalImage,
                    "OLocation",
                    (fromLocationSearch || (location.IsActive == 1)) && selectLogicalLocation));
            }
            else
            {
                // Physical locations
                //
                treeNodes.Add(CreateTreeNode(
                    location.ObjectName, location.ObjectID.ToString(),
                    physicalImage,
                    "OLocation",
                    (fromLocationSearch || (location.IsActive == 1)) && selectPhysicalLocation));
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
        List<OLocation> locations =
            TablesLogic.tLocation.LoadList(
            TablesLogic.tLocation.ObjectName.Like("%" + patternToMatch + "%") &
            ((objectType == null || objectType == "") && roleCodes == null ? Query.True : TablesLogic.tLocation.GetAccessibleLocationCondition(AppSession.User, objectType, roleCodes)) &
            TablesLogic.tLocation.IsPhysicalLocation == 1,
            TablesLogic.tLocation.ObjectName.Asc);
        foreach (OLocation location in locations)
        {
            String physicalImage = ConfigurationManager.AppSettings["ImageUrl_LocationPhysical"];

            if (location.IsActive == 0)
                physicalImage = "~/images/cross.png";

            treeNodes.Add(CreateTreeNode(
                location.ObjectName, location.ObjectID.ToString(),
                physicalImage,
                "OLocation", (fromLocationSearch || (location.IsActive == 1))));
        }
        
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
            OLocation location = TablesLogic.tLocation[(Guid)id];
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
