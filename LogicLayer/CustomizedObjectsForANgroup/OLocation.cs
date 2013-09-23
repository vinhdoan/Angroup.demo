//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OLocationType
    /// </summary>

    public partial class TLocation : LogicLayerSchema<OLocation>
    {
        public SchemaGuid BuildingOwnerID;
        public SchemaGuid BuildingTrustID;
        public SchemaGuid BuildingManagementID;

        public TCapitalandCompany BuildingOwner { get { return OneToOne<TCapitalandCompany>("BuildingOwnerID"); } }
        public TCapitalandCompany BuildingTrust { get { return OneToOne<TCapitalandCompany>("BuildingTrustID"); } }
        public TCapitalandCompany BuildingManagement { get { return OneToOne<TCapitalandCompany>("BuildingManagementID"); } }
        public TCampaign CampaignsForLocations { get { return ManyToMany<TCampaign>("CampaignLocation", "LocationID", "CampaignID"); } }
        //public SchemaString EmailForInventoryDisposal;
        public SchemaString EmailForSAPFMSBudget;

        [Default(0)]
        public SchemaInt FromAmos;
        public SchemaInt AmosAssetID;
        public SchemaInt AmosSuiteID;
        public SchemaString AmosLevelID;
        public SchemaInt AmosAssetTypeID;
        [Default(1)]
        public SchemaInt IsActive;
        public SchemaDateTime LeaseableFrom;
        public SchemaDateTime LeaseableTo;
        public SchemaDecimal LeaseableArea;
        public SchemaDateTime updatedOn;

        public TTenantLease TenantLeases { get { return OneToMany<TTenantLease>("LocationID"); } }

        public SchemaGuid DefaultLOASignatoryID;
        public SchemaString IworkflowProjectSN;
    }

    public abstract partial class OLocation : LogicLayerPersistentObject, IHierarchy
    {
        public abstract Guid? BuildingOwnerID { get; set; }
        public abstract Guid? BuildingTrustID { get; set; }
        public abstract Guid? BuildingManagementID { get; set; }

        public abstract OCapitalandCompany BuildingOwner { get; set; }
        public abstract OCapitalandCompany BuildingTrust { get; set; }
        public abstract OCapitalandCompany BuildingManagement { get; set; }

        //public abstract string EmailForInventoryDisposal { get; set; }
        public abstract string EmailForSAPFMSBudget { get; set; }

        public abstract int? FromAmos { get; set; }
        public abstract int? AmosAssetID { get; set; }
        public abstract int? AmosSuiteID { get; set; }
        public abstract String AmosLevelID { get; set; }
        public abstract String IworkflowProjectSN { get; set; }
        public abstract int? AmosAssetTypeID { get; set; }
        public abstract int? IsActive { get; set; }
        public abstract DateTime? LeaseableFrom { get; set; }
        public abstract DateTime? LeaseableTo { get; set; }
        public abstract Decimal? LeaseableArea { get; set; }
        public abstract DateTime? updatedOn { get; set; }

        public abstract DataList<OTenantLease> TenantLeases { get; set; }
        public abstract DataList<OCampaign> CampaignsForLocations { get; }
        public abstract Guid? DefaultLOASignatoryID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public String IsActiveText
        {
            get
            {
                if (IsActive == 1)
                    return "Yes";
                else if (IsActive == 0)
                    return "No";
                else
                    return "";
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public String FromAmosText
        {
            get
            {
                if (FromAmos == 1)
                    return "Yes";
                else if (FromAmos == 0)
                    return "No";
                else
                    return "";
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivable()
        {
            if (this.FromAmos == 1)
                return false;
            else if (TablesLogic.tPoint.LoadList(
                TablesLogic.tPoint.LocationID == this.ObjectID).Count > 0)
                return false;

            return true;
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Returns the parent's name concatenated with this object's 
        /// name.
        /// </summary>
        //---------------------------------------------------------------
        public string ParentPath
        {
            get
            {
                if (Parent != null)
                    return Parent.ObjectName + " > " + this.ObjectName;
                else
                    return this.ObjectName;
            }
        }

        public static List<OLocation> GetLocationByTypeAndBelowOrAboveLocation(string typeName, bool includeInactiveLocation, OLocation location, Guid? currLocationId)
        {
            Guid? locationTypeId = TablesLogic.tLocationType.Select
                (TablesLogic.tLocationType.ObjectID)
                .Where(TablesLogic.tLocationType.ObjectName == typeName & 
                TablesLogic.tLocationType.IsDeleted == 0);
            ExpressionCondition c = null;
            c = (location.HierarchyPath.Like(TablesLogic.tLocation.HierarchyPath + "%") | TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%"));

            return TablesLogic.tLocation.LoadList(
                (c &
                TablesLogic.tLocation.LocationTypeID == locationTypeId &
                TablesLogic.tLocation.IsDeleted == 0 &
                (includeInactiveLocation == true ? Query.True : TablesLogic.tLocation.IsActive == 1))
                | TablesLogic.tLocation.ObjectID == currLocationId);
        }

        /// <summary>
        /// Get all Location by type.
        /// </summary>
        /// <param name="typeName"></param>
        /// <param name="currentLocID"></param>
        /// <param name="includeInactiveLocation"></param>
        /// <param name="positions"></param>
        /// <returns></returns>
        public static List<OLocation> GetLocationsByType(string typeName, bool includeInactiveLocation, List<OPosition> positions, Guid? currentLocID)
        {
            // 2010.05.28
            // Kim Foong
            // Loading from a huge location table by first finding out the LocationTypeID
            // is much faster.
            //
            // 2011.03.22
            // Kim Foong
            // Fixed to include IsDeleted = 0 as a condition.
            //
            Guid? locationTypeId = TablesLogic.tLocationType.Select(TablesLogic.tLocationType.ObjectID).Where(TablesLogic.tLocationType.ObjectName == typeName & TablesLogic.tLocationType.IsDeleted == 0);
            List<OLocation> locations = new List<OLocation>();
            ArrayList locIDs = new ArrayList();

            ExpressionCondition c = Query.False;

            foreach (OPosition po in positions)
                foreach (OLocation location in po.LocationAccess)
                    c = c | TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%");

            return TablesLogic.tLocation.LoadList(
                (c &
                TablesLogic.tLocation.LocationTypeID == locationTypeId &
                TablesLogic.tLocation.IsDeleted == 0 &
                (includeInactiveLocation == true ? Query.True : TablesLogic.tLocation.IsActive == 1))
                | TablesLogic.tLocation.ObjectID == currentLocID );

            //return TablesLogic.tLocation.LoadList(
            //    TablesLogic.tLocation.LocationType.ObjectName == typeName &
            //    TablesLogic.tLocation.IsDeleted == 0 &
            //     (includeInactiveLocation == true ? Query.True : TablesLogic.tLocation.IsActive == 1) &
            //      TablesLogic.tLocation.ObjectID.In(locationIds), true);
        }


        public static List<OLocation> GetLocationsByType(string typeName, Guid? includingLocationId)
        {
            // 2010.05.28
            // Kim Foong
            // Loading from a huge location table by first finding out the LocationTypeID
            // is much faster.
            //
            Guid? locationTypeId = TablesLogic.tLocationType.Select(TablesLogic.tLocationType.ObjectID).Where(TablesLogic.tLocationType.ObjectName == typeName);
            return TablesLogic.tLocation.LoadList(
                (TablesLogic.tLocation.LocationTypeID == locationTypeId &
                TablesLogic.tLocation.IsDeleted == 0) |
                TablesLogic.tLocation.ObjectID == includingLocationId);
       }
        //---------------------------------------------------------------
        /// <summary>
        /// Get a list of equipment under the current location that are of
        /// a specified type
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public List<OEquipment> GetEquipmentByEquipmentType(OEquipmentType type)
        {
            Guid? typeId = null;
            if (type != null)
                typeId = type.ObjectID;

            return TablesLogic.tEquipment[
                TablesLogic.tEquipment.IsPhysicalEquipment == 1 &
                TablesLogic.tEquipment.Location.HierarchyPath.Like(this.HierarchyPath + "%") &
                TablesLogic.tEquipment.EquipmentTypeID == typeId &
                (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null)];
        }


        public static List<OCampaign> GetCampaignsContainsInLocations(List<OLocation> locs)
        {
            List<OCampaign> campaigns = new List<OCampaign>();
            Hashtable match = new Hashtable();
            foreach (OLocation ol in locs)
            {
                foreach (OCampaign oca in ol.CampaignsForLocations)
                {
                    match[oca.ObjectID] = 0;
                }
            }
            foreach (OLocation ol in locs)
            {
                foreach (OCampaign oca in ol.CampaignsForLocations)
                {
                    match[oca.ObjectID] =(int) match[oca.ObjectID]+1;
                }
            }
            foreach(DictionaryEntry de in match)
            {
                if ((int)de.Value == locs.Count)
                {
                    Guid camID = new Guid();
                    camID =(Guid) de.Key;
                    OCampaign cam = LogicLayer.TablesLogic.tCampaign.Create();
                    cam = LogicLayer.TablesLogic.tCampaign.Load(camID);
                    campaigns.Add(cam);
                }
            }
            return campaigns;
            //List<OCampaign> newlist=new List<OCampaign>();
           
            //foreach(OLocation lication in locs)
            //{ 
            //    int i=0;
            //    OCampaign eee;
            //    foreach(OCampaign c in lication.CampaignsForLocations)
            //    {   
                  
            //      foreach(OCampaign c1 in lication.CampaignsForLocations)
            //        {
            //         if(c1.ObjectID==c.ObjectID)
            //            { 
            //              i++;
            //              eee = c1;
            //            }
            //         }
            //     } 
            //}
            // if(i== list.count) 
            // { 
            //     newlist.add(eee);
            // }

            }

        }
    }
