//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO.Ports;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;
using System.Collections;
using System.Text.RegularExpressions;

namespace Service
{
    public partial class AmosIntegrationReadMasterServiceRetail : AnacleServiceBase
    {
        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            String errorMsg = "";
            String instancename = "Amos_SG_RCS_Retail";//tessa update 08 Oct 2012
            String assetIDlist = System.Configuration.ConfigurationManager.AppSettings[instancename + "_AssetID"].ToString();//20121015 ptb
            try
            {
                Hashtable preloadedRecords = new Hashtable();
                Hashtable preloadedAssets = new Hashtable();
                Hashtable preloadedLevels = new Hashtable();

                String connAmos = System.Configuration.ConfigurationManager.AppSettings[instancename].ToString();//tessa update 08 Oct 2012
                String connLive = System.Configuration.ConfigurationManager.AppSettings["database"].ToString();

                if (connAmos == "" || connAmos == null)
                    errorMsg = appendErrorMsg(errorMsg, "Amos connection string not available");

                if (connLive == "" || connAmos == null)
                    errorMsg = appendErrorMsg(errorMsg, "Live connection string not available");

                DataSet ds = new DataSet();

                DataTable contactTable = new DataTable();
                DataTable suiteTable = new DataTable();
                DataTable orgTable = new DataTable();
                DataTable chargeTypeTable = new DataTable();
                DataTable leaseTable = new DataTable();

                DataTable contactLiveTable = new DataTable();
                DataTable suiteLiveTable = new DataTable();
                DataTable orgLiveTable = new DataTable();
                DataTable chargeTypeLiveTable = new DataTable();
                DataTable leaseLiveTable = new DataTable();

                #region Populate DataTable (Live)
                try
                {
                    ds = Connection.ExecuteQuery(connLive,
                             "Select distinct updatedon from TenantContact where updatedon is not null", null);
                    if (ds.Tables.Count > 0)
                        contactLiveTable = ds.Tables[0];

                    ds = Connection.ExecuteQuery(connLive,
                             "Select distinct updatedon from Location where updatedon is not null", null);
                    if (ds.Tables.Count > 0)
                        suiteLiveTable = ds.Tables[0];


                    ds = Connection.ExecuteQuery(connLive,
                             "Select distinct updatedon from [User] where updatedon is not null", null);
                    if (ds.Tables.Count > 0)
                        orgLiveTable = ds.Tables[0];

                    ds = Connection.ExecuteQuery(connLive,
                             "Select distinct updatedon from ChargeType where updatedon is not null", null);
                    if (ds.Tables.Count > 0)
                        chargeTypeLiveTable = ds.Tables[0];

                    ds = Connection.ExecuteQuery(connLive,
                             "Select distinct updatedon from TenantLease where updatedon is not null", null);
                    if (ds.Tables.Count > 0)
                        leaseLiveTable = ds.Tables[0];
                }
                catch (Exception e)
                {
                    errorMsg = appendErrorMsg(errorMsg, e.Message);

                    String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                    OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, "Read Master Service Error", "Reading Data From Live: " + errorMsg);
                }
                #endregion

                #region Populate DataTable (Amos)

                try
                {
                    ds = Connection.ExecuteQuery(connAmos,
                         "Select * from amos_contact_out", null);
                    if (ds.Tables.Count > 0)
                        contactTable = ds.Tables[0];
                    // where updatedon not in " + getUpdatedOnList(contactLiveTable)

                    ds = Connection.ExecuteQuery(connAmos,
                         "Select * from amos_suite_out where asset_id in " + assetIDlist, null);
                    if (ds.Tables.Count > 0)
                        suiteTable = ds.Tables[0];
                    // where updatedon not in " + getUpdatedOnList(suiteLiveTable)
                    ds = Connection.ExecuteQuery(connAmos,
                         "Select * from amos_organisation_out", null);
                    if (ds.Tables.Count > 0)
                        orgTable = ds.Tables[0];
                    // where org_updatedon not in " + getUpdatedOnList(orgLiveTable)
                    ds = Connection.ExecuteQuery(connAmos,
                         "Select * from amos_charge_type_out", null);
                    if (ds.Tables.Count > 0)
                        chargeTypeTable = ds.Tables[0];
                    // where charge_updatedon not in " + getUpdatedOnList(chargeTypeLiveTable)
                    ds = Connection.ExecuteQuery(connAmos,
                         "Select * from amos_lease_agmt_out where asset_id in " + assetIDlist, null);
                    if (ds.Tables.Count > 0)
                        leaseTable = ds.Tables[0];
                    // where updatedon not in " + getUpdatedOnList(leaseLiveTable)
                }
                catch (Exception e)
                {
                    errorMsg = appendErrorMsg(errorMsg, e.Message);

                    String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                    OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Master Service Error", "Reading Data From " + instancename + ": " + errorMsg);//tessa update 08 Oct 2012
                }
                #endregion

                #region Process ChargeType

                foreach (DataRow dr in chargeTypeTable.Rows)
                {
                    try
                    {
                        OChargeType chargeType = null;
                        if (dr["charge_id"].ToString() != "")
                        {
                            using (Connection conn = new Connection())
                            {
                                chargeType = TablesLogic.tChargeType.Load(TablesLogic.tChargeType.AmosChargeID == dr["charge_id"].ToString() &
                                                                          TablesLogic.tChargeType.AMOSInstanceID == instancename);//tessa update 08 Oct 2012

                                if (chargeType == null)
                                    chargeType = TablesLogic.tChargeType.Create();

                                chargeType.AmosChargeID = Convert.ToInt32(dr["charge_id"].ToString());
                                chargeType.ObjectName = dr["charge_name"].ToString();
                                chargeType.AmosAssetTypeID = Convert.ToInt32(dr["asset_type_id"].ToString());
                                chargeType.updatedOn = Convert.ToDateTime(dr["charge_updatedon"]);
                                chargeType.FromAmos = 1;
                                //tessa update 08 Oct 2012 to specify instance name;
                                chargeType.AMOSInstanceID = instancename;
                                chargeType.Save();
                                conn.Commit();
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        errorMsg = appendErrorMsg(errorMsg, e.Message);

                        String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                        OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Master Service Error", "Process ChargeType: " + errorMsg);//tessa update 08 Oct 2012
                    }
                }

                #endregion

                #region Process Organisation

                for (int i = 0; i < orgTable.Rows.Count; i++)
                {
                    DataRow dr = orgTable.Rows[i];

                    // 2010.05.31
                    // Optimized by pre-loading up to 200 records
                    // at one go.
                    //
                    if (i % 200 == 0)
                    {
                        ArrayList ids = new ArrayList();
                        for (int j = 0; j < 200 && j + i < orgTable.Rows.Count; j++)
                            ids.Add(orgTable.Rows[j + i]["org_id"]);

                        List<OUser> users = TablesLogic.tUser.LoadList(
                            TablesLogic.tUser.AmosOrgID.In(ids) &
                            TablesLogic.tUser.AMOSInstanceID == instancename, true);//tessa update 08 Oct 2012
                        preloadedRecords.Clear();
                        foreach (OUser user in users)
                            preloadedRecords[user.AmosOrgID.ToString()] = user;
                    }

                    try
                    {
                        OUser user = null;
                        if (dr["org_id"].ToString() != "")
                        {
                            using (Connection conn = new Connection())
                            {
                                // 2010.05.31
                                // Optimized by loading from the preloaded records
                                // hash.
                                //user = TablesLogic.tUser.Load(TablesLogic.tUser.AmosOrgID == dr["org_id"].ToString());
                                user = preloadedRecords[dr["org_id"].ToString()] as OUser;

                                if (user == null)
                                    user = TablesLogic.tUser.Create();

                                if (user.updatedOn != null &&
                                    dr["org_updatedon"] != DBNull.Value &&
                                    CompareDateTimes(user.updatedOn.Value, Convert.ToDateTime(dr["org_updatedon"])))
                                    continue;

                                user.AmosOrgID = Convert.ToInt32(dr["org_id"].ToString());
                                user.ObjectName = dr["org_name_lc"].ToString();
                                user.updatedOn = Convert.ToDateTime(dr["org_updatedon"]);
                                user.FromAmos = 1;
                                user.isTenant = 1;
                                user.AMOSInstanceID = instancename; //tessa update 08 Oct 2012
                                user.Save();
                                conn.Commit();
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        errorMsg = appendErrorMsg(errorMsg, e.Message);

                        String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                        OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Master Service Error", "Process Organisation: " + errorMsg);//tessa update 08 Oct 2012
                    }
                }

                #endregion

                #region Process Suite

                // 2010.05.31
                // Pre-load all assets and levels.
                //
                List<OLocation> assets = TablesLogic.tLocation.LoadList(
                    TablesLogic.tLocation.AmosAssetID != null &
                    TablesLogic.tLocation.AmosLevelID == null &
                    TablesLogic.tLocation.AmosSuiteID == null &
                    TablesLogic.tLocation.AMOSInstanceID == instancename, true); //tessa update 08 Oct 2012
                List<OLocation> levels = TablesLogic.tLocation.LoadList(
                    TablesLogic.tLocation.AmosAssetID != null &
                    TablesLogic.tLocation.AmosLevelID != null &
                    TablesLogic.tLocation.AmosSuiteID == null &
                    TablesLogic.tLocation.AMOSInstanceID == instancename, true);//tessa update 08 Oct 2012
                foreach (OLocation asset in assets)
                    preloadedAssets[asset.AmosAssetID.ToString()] = asset;
                foreach (OLocation level in levels)
                    preloadedLevels[level.AmosAssetID.ToString() + "$" + level.AmosLevelID.ToString()] = level;

                for (int i = 0; i < suiteTable.Rows.Count; i++)
                {
                    DataRow dr = suiteTable.Rows[i];

                    // 2010.05.31
                    // Optimized by pre-loading up to 200 records
                    // at one go.
                    //
                    if (i % 200 == 0)
                    {
                        ExpressionCondition c = Query.False;
                        for (int j = 0; j < 200 && j + i < suiteTable.Rows.Count; j++)
                            c = c |
                                (TablesLogic.tLocation.AmosAssetID == suiteTable.Rows[j + i]["asset_id"].ToString() &
                                TablesLogic.tLocation.AmosLevelID == suiteTable.Rows[j + i]["levelid"].ToString() &
                                TablesLogic.tLocation.AmosSuiteID == suiteTable.Rows[j + i]["suite_id"].ToString() &
                                TablesLogic.tLocation.AMOSInstanceID == instancename); //tessa update 08 Oct 2012

                        List<OLocation> suites = TablesLogic.tLocation.LoadList(c, true);
                        preloadedRecords.Clear();
                        foreach (OLocation suite in suites)
                            preloadedRecords[
                                suite.AmosAssetID.ToString() + "$" +
                                suite.AmosLevelID.ToString() + "$" +
                                suite.AmosSuiteID.ToString()] = suite;
                    }


                    OLocation location = null;
                    OLocation asset = null;
                    OLocation level = null;

                    if (dr["asset_id"].ToString() != "")
                    {
                        // 2010.05.31
                        // Load the asset from the pre-loaded assets hash
                        //
                        //asset = TablesLogic.tLocation.Load(TablesLogic.tLocation.AmosAssetID == dr["asset_id"].ToString() &
                        //    TablesLogic.tLocation.AmosLevelID == null &
                        //    TablesLogic.tLocation.AmosSuiteID == null);
                        asset = preloadedAssets[dr["asset_id"].ToString()] as OLocation;

                        if (asset != null)
                        {
                            try
                            {
                                using (Connection conn = new Connection())
                                {
                                    // 2010.05.31
                                    // Load the asset from the pre-loaded assets hash
                                    //level = TablesLogic.tLocation.Load(TablesLogic.tLocation.AmosAssetID == dr["asset_id"].ToString() &
                                    //    TablesLogic.tLocation.AmosLevelID == dr["levelid"].ToString() &
                                    //    TablesLogic.tLocation.AmosSuiteID == null);
                                    level = preloadedLevels[dr["asset_id"].ToString() + "$" + dr["levelid"].ToString()] as OLocation;

                                    if (level == null)
                                    {
                                        level = TablesLogic.tLocation.Create();

                                        level.AmosAssetID = Convert.ToInt32(dr["asset_id"].ToString());
                                        level.AmosAssetTypeID = Convert.ToInt32(dr["asset_type_id"].ToString());
                                        level.AmosLevelID = dr["levelid"].ToString();
                                        level.ObjectName = dr["levelid"].ToString();
                                        level.updatedOn = Convert.ToDateTime(dr["updatedon"]);
                                        level.FromAmos = 1;
                                        level.LocationTypeID = OApplicationSetting.Current.LevelLocationTypeID;
                                        level.ParentID = asset.ObjectID;
                                        level.IsPhysicalLocation = 1;
                                        level.AMOSInstanceID = instancename; //tessa update 08 Oct 2012
                                        level.Save();
                                        preloadedLevels[dr["asset_id"].ToString() + "$" + dr["levelid"].ToString()] = level;
                                    }

                                    // 2010.05.31
                                    // Read the suite from the preloaded records hash.
                                    //
                                    //location = TablesLogic.tLocation.Load(TablesLogic.tLocation.AmosSuiteID == dr["suite_id"].ToString() &
                                    //    TablesLogic.tLocation.AmosLevelID == dr["levelid"].ToString() &
                                    //    TablesLogic.tLocation.AmosAssetID == dr["asset_id"].ToString());
                                    location = preloadedRecords[
                                        dr["asset_id"].ToString() + "$" + dr["levelid"].ToString() + "$" + dr["suite_id"].ToString()] as OLocation;

                                    if (location == null)
                                        location = TablesLogic.tLocation.Create();

                                    if (location.updatedOn == null ||
                                        dr["updatedon"] == DBNull.Value ||
                                        !CompareDateTimes(location.updatedOn.Value, Convert.ToDateTime(dr["updatedon"])))
                                    {
                                        location.IsActive = 1;
                                        location.AmosSuiteID = Convert.ToInt32(dr["suite_id"].ToString());
                                        location.AmosAssetID = Convert.ToInt32(dr["asset_id"].ToString());
                                        location.AmosAssetTypeID = Convert.ToInt32(dr["asset_type_id"].ToString());
                                        location.AmosLevelID = dr["levelid"].ToString();
                                        location.ObjectName = dr["suite_name"].ToString();
                                        location.updatedOn = Convert.ToDateTime(dr["updatedon"]);
                                        location.FromAmos = 1;
                                        location.IsActive = (dr["isactive"].ToString() == "Y" ? 1 : 0);
                                        if (dr["suite_leaseable_from"].ToString() != "")
                                            location.LeaseableFrom = Convert.ToDateTime(dr["suite_leaseable_from"].ToString());
                                        if (dr["suite_leaseable_to"].ToString() != "")
                                            location.LeaseableTo = Convert.ToDateTime(dr["suite_leaseable_to"].ToString());
                                        if (dr["leaseable_area"].ToString() != "")
                                            location.LeaseableArea = Convert.ToDecimal(dr["leaseable_area"].ToString());

                                        location.LocationTypeID = OApplicationSetting.Current.SuiteLocationTypeID;
                                        location.ParentID = level.ObjectID;
                                        location.IsPhysicalLocation = 1;
                                        location.AMOSInstanceID = instancename; //tessa update 08 Oct 2012
                                        location.Save();
                                    }
                                    conn.Commit();
                                }
                            }
                            catch (Exception e)
                            {
                                errorMsg = appendErrorMsg(errorMsg, e.Message);

                                String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                                OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Master Service Error", "Process Suite: " + errorMsg);//tessa update 08 Oct 2012
                            }
                        }
                    }
                }

                #endregion

                #region Process Contact

                for (int i = 0; i < contactTable.Rows.Count; i++)
                {
                    DataRow dr = contactTable.Rows[i];

                    // 2010.05.31
                    // Optimized by pre-loading up to 200 records
                    // at one go.
                    //
                    if (i % 200 == 0)
                    {
                        ExpressionCondition c = Query.False;
                        ArrayList orgIds = new ArrayList();
                        for (int j = 0; j < 200 && j + i < contactTable.Rows.Count; j++)
                        {
                            c = c |
                                (TablesLogic.tTenantContact.AmosContactID == contactTable.Rows[j + i]["contact_id"].ToString() &
                                //TablesLogic.tTenantContact.AmosBillAddressID == contactTable.Rows[j + i]["bill_address_id"].ToString() &
                                TablesLogic.tTenantContact.AmosOrgID == contactTable.Rows[j + i]["org_id"].ToString() &
                                TablesLogic.tTenantContact.AMOSInstanceID == instancename); //tessa update 08 Oct 2012
                            orgIds.Add(contactTable.Rows[j + i]["org_id"]);
                        }

                        List<OTenantContact> tenantContacts = TablesLogic.tTenantContact.LoadList(c, true);
                        preloadedRecords.Clear();
                        foreach (OTenantContact tenantContact in tenantContacts)
                            preloadedRecords[
                                tenantContact.AmosContactID.ToString() + "$" +
                                //tenantContact.AmosBillAddressID.ToString() + "$" +
                                tenantContact.AmosOrgID.ToString()] = tenantContact;
                        
                        List<OUser> users = TablesLogic.tUser.LoadList(
                            TablesLogic.tUser.AmosOrgID.In(orgIds) &
                            TablesLogic.tUser.AMOSInstanceID == instancename, true);//tessa update 08 Oct 2012
                        foreach (OUser user in users)
                            preloadedRecords[user.AmosOrgID.ToString()] = user;
                    }


                    OTenantContact contact = null;

                    // 2011.07.08, Kien Trung
                    // Modified: check contactname if it's empty string
                    //
                    if (dr["contact_id"].ToString().Trim() != "" && 
                        dr["contact_name"].ToString().Trim() != "")
                    {
                        try
                        {
                            using (Connection conn = new Connection())
                            {
                                // 2010.05.31
                                // Load from the preloaded records hash.
                                //
                                //contact = TablesLogic.tTenantContact.Load(
                                //    TablesLogic.tTenantContact.AmosContactID == dr["contact_id"].ToString() &
                                //    TablesLogic.tTenantContact.AmosBillAddressID == dr["bill_address_id"].ToString() &
                                //    TablesLogic.tTenantContact.AmosOrgID == dr["org_id"].ToString());
                                contact = preloadedRecords[
                                    dr["contact_id"].ToString() + "$" +
                                    //dr["bill_address_id"].ToString() + "$" +
                                    dr["org_id"].ToString()] as OTenantContact;

                                OUser user = null;
                                
                                // 2010.05.31
                                // Load from the preloaded records hash.
                                //
                                //user = TablesLogic.tUser.Load(TablesLogic.tUser.AmosOrgID == dr["org_id"].ToString());
                                user = preloadedRecords[dr["org_id"].ToString()] as OUser;

                                if (contact == null)
                                    contact = TablesLogic.tTenantContact.Create();

                                if (user != null)
                                    contact.TenantID = user.ObjectID;

                                if (contact.updatedOn == null ||
                                    dr["updatedon"] == DBNull.Value ||
                                    !CompareDateTimes(contact.updatedOn.Value, Convert.ToDateTime(dr["updatedon"])))
                                {
                                    contact.AmosOrgID = Convert.ToInt32(dr["org_id"].ToString());
                                    contact.TenantContactTypeID = OApplicationSetting.Current.TenantContactTypeID;
                                    contact.ObjectName = dr["contact_name"].ToString();
                                    contact.AmosBillAddressID = Convert.ToInt32(dr["bill_address_id"].ToString());
                                    contact.AmosContactID = Convert.ToInt32(dr["contact_id"].ToString());
                                    contact.updatedOn = Convert.ToDateTime(dr["updatedon"]);
                                    contact.AddressLine1 = dr["bill_addressline1"].ToString();
                                    contact.AddressLine2 = dr["bill_addressline2"].ToString();
                                    contact.AddressLine3 = dr["bill_addressline3"].ToString();
                                    contact.AddressLine4 = dr["bill_addressline4"].ToString();
                                    contact.Phone = dr["contact_office_no"].ToString();
                                    contact.Cellphone = dr["contact_mobile_no"].ToString();
                                    contact.Fax = dr["contact_fax"].ToString();
                                    contact.Email = dr["contact_email"].ToString();
                                    contact.FromAmos = 1;
                                    contact.AMOSInstanceID = instancename; //tessa update 08 Oct 2012
                                    contact.Save();
                                }
                                conn.Commit();
                            }
                        }
                        catch (Exception e)
                        {
                            errorMsg = appendErrorMsg(errorMsg, e.Message);

                            String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                            OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Master Service Error", "Process Contact: " + errorMsg); //tessa update 08 Oct 2012
                        }
                    }
                }

                #endregion

                #region Process Lease Agmt

                for (int i = 0; i < leaseTable.Rows.Count; i++)
                {
                    DataRow dr = leaseTable.Rows[i];

                    // 2010.05.31
                    // Optimized by pre-loading up to 200 records
                    // at one go.
                    //
                    if (i % 200 == 0)
                    {
                        ExpressionCondition c = Query.False;
                        ExpressionCondition c2 = Query.False;
                        
                        // 2011.12.14, Kien Trung
                        // Modified for CCL, add contact_id, address_id in tenant lease.
                        //
                        ExpressionCondition c3 = Query.False;

                        ArrayList orgIds = new ArrayList();
                        for (int j = 0; j < 200 && j + i < leaseTable.Rows.Count; j++)
                        {
                            c = c |
                                (TablesLogic.tTenantLease.AmosLeaseID == leaseTable.Rows[j + i]["lease_id"].ToString() &
                                TablesLogic.tTenantLease.AmosOrgID == leaseTable.Rows[j + i]["org_id"].ToString() &
                                TablesLogic.tTenantLease.AmosAssetID == leaseTable.Rows[j + i]["asset_id"].ToString() &
                                TablesLogic.tTenantLease.AmosSuiteID == leaseTable.Rows[j + i]["suite_id"].ToString() &
                                TablesLogic.tTenantLease.AMOSInstanceID == instancename);//tessa update 08 Oct 2012
                            c2 = c2 |
                                (TablesLogic.tLocation.AmosLevelID != null &
                                TablesLogic.tLocation.AmosAssetID == leaseTable.Rows[j + i]["asset_id"].ToString() &
                                TablesLogic.tLocation.AmosSuiteID == leaseTable.Rows[j + i]["suite_id"].ToString() &
                                TablesLogic.tLocation.AMOSInstanceID == instancename);//tessa update 08 Oct 2012
                            orgIds.Add(leaseTable.Rows[j + i]["org_id"]);

                            // 2011.12.14, Kien Trung
                            // Modified for CCL, add contact_id, address_id in tenant lease.
                            //
                            c3 = c3 |
                                (TablesLogic.tTenantContact.AmosContactID != null &
                                TablesLogic.tTenantContact.AmosContactID == leaseTable.Rows[j + i]["contact_id"].ToString() &
                                TablesLogic.tTenantContact.AmosOrgID == leaseTable.Rows[j + i]["org_id"].ToString() &
                                TablesLogic.tTenantContact.AmosBillAddressID == leaseTable.Rows[j + i]["address_id"].ToString() &
                                TablesLogic.tTenantContact.AMOSInstanceID == instancename);//tessa update 08 Oct 2012
                        }

                        preloadedRecords.Clear();
                        
                        List<OTenantLease> leases = TablesLogic.tTenantLease.LoadList(c, true);
                        foreach (OTenantLease l in leases)
                            preloadedRecords[
                                l.AmosLeaseID.ToString() + "$" +
                                l.AmosOrgID.ToString() + "$" +
                                l.AmosAssetID.ToString() + "$" +
                                l.AmosSuiteID.ToString()] = l;

                        List<OLocation> suites = TablesLogic.tLocation.LoadList(c2, true);
                        foreach (OLocation suite in suites)
                            preloadedRecords[
                                suite.AmosAssetID.ToString() + "$" +
                                suite.AmosSuiteID.ToString()] = suite;

                        List<OUser> tenants = TablesLogic.tUser.LoadList(
                            TablesLogic.tUser.AmosOrgID.In(orgIds) &
                            TablesLogic.tUser.AMOSInstanceID == instancename, true);//tessa update 08 Oct 2012
                        foreach (OUser tenant in tenants)
                            preloadedRecords[tenant.AmosOrgID.ToString()] = tenant;

                        // 2011.12.14, Kien Trung
                        // Modified for CCL, add contact_id, address_id in tenant lease.
                        //
                        List<OTenantContact> contacts = TablesLogic.tTenantContact.LoadList(c3, true);
                        foreach (OTenantContact contact in contacts)
                            preloadedRecords[
                                contact.AmosContactID.ToString() + "$" +
                                contact.AmosOrgID.ToString() + "$" +
                                contact.AmosBillAddressID.ToString()] = contact;
                    }

                    OTenantLease lease = null;
                    if (dr["lease_id"].ToString() != "")
                    {
                        using (Connection conn = new Connection())
                        {
                            try
                            {
                                // 2010.05.31
                                // Load from the preloaded hash
                                //
                                //lease = TablesLogic.tTenantLease.Load(TablesLogic.tTenantLease.AmosLeaseID == dr["lease_id"].ToString() &
                                //    TablesLogic.tTenantLease.AmosOrgID == dr["org_id"] &
                                //    TablesLogic.tTenantLease.AmosAssetID == dr["asset_id"] &
                                //    TablesLogic.tTenantLease.AmosSuiteID == dr["suite_id"]);
                                //
                                lease = preloadedRecords[
                                    dr["lease_id"].ToString() + "$" +
                                    dr["org_id"].ToString() + "$" +
                                    dr["asset_id"].ToString() + "$" +
                                    dr["suite_id"].ToString()] as OTenantLease;

                                OUser user = null;

                                // 2010.05.31
                                // Load from the preloaded hash
                                //
                                //user = TablesLogic.tUser.Load(TablesLogic.tUser.AmosOrgID == dr["org_id"].ToString());
                                //
                                user = preloadedRecords[dr["org_id"].ToString()] as OUser;

                                OLocation suite = null;

                                // 2010.05.31
                                // Load from the preloaded hash
                                //
                                //suite = TablesLogic.tLocation.Load(
                                //    TablesLogic.tLocation.AmosSuiteID == dr["suite_id"].ToString() &
                                //    TablesLogic.tLocation.AmosLevelID == null &
                                //    TablesLogic.tLocation.AmosAssetID == dr["asset_id"].ToString());
                                //
                                suite = preloadedRecords[
                                    dr["asset_id"].ToString() + "$" +
                                    dr["suite_id"].ToString()] as OLocation;

                                // 2011.12.14, Kien Trung
                                // Modified for CCL: 
                                // add contact_id, address_id in tenant lease.
                                //
                                OTenantContact contact = null;
                                contact = preloadedRecords[
                                    dr["contact_id"].ToString() + "$" +
                                    dr["org_id"].ToString() + "$" +
                                    dr["address_id"].ToString()] as OTenantContact;

                                if (lease == null && suite != null)
                                    lease = TablesLogic.tTenantLease.Create();
                              
                                if (lease.updatedOn == null ||
                                    dr["updatedon"] == DBNull.Value ||
                                    !CompareDateTimes(lease.updatedOn.Value, Convert.ToDateTime(dr["updatedon"])))
                                {
                                    if (user != null)
                                        lease.TenantID = user.ObjectID;
                                    if (suite != null)
                                        lease.LocationID = suite.ObjectID;
                                    if (contact != null)
                                        lease.TenantContactID = contact.ObjectID;

                                    lease.AmosOrgID = Convert.ToInt32(dr["org_id"].ToString());
                                    lease.AmosAssetID = Convert.ToInt32(dr["asset_id"].ToString());
                                    lease.AmosSuiteID = Convert.ToInt32(dr["suite_id"].ToString());
                                    lease.AmosLeaseID = Convert.ToInt32(dr["lease_id"].ToString());
                                    lease.AmosContactID = Convert.ToInt32(dr["contact_id"].ToString());
                                    lease.AmosAddressID = Convert.ToInt32(dr["address_id"].ToString());

                                    if (dr["occupied_from"].ToString() != "")
                                        lease.LeaseStartDate = Convert.ToDateTime(dr["occupied_from"].ToString());
                                    if (dr["occupied_to"].ToString() != "")
                                        lease.LeaseEndDate = Convert.ToDateTime(dr["occupied_to"].ToString());
                                    if (lease.LeaseStatus == "N" && dr["lease_status_flg"].ToString() != "N")
                                        lease.LeaseStatusChangeDate = DateTime.Now;
                                    lease.LeaseStatus = dr["lease_status_flg"].ToString();
                                    if (dr["lease_status_date"].ToString() != "")
                                        lease.LeaseStatusDate = Convert.ToDateTime(dr["lease_status_date"].ToString());
                                    lease.updatedOn = Convert.ToDateTime(dr["updatedon"]);
                                    
                                    lease.ShopName = dr["dba_lc"].ToString();
                                    if (dr["shop_id"].ToString() != "")
                                        lease.AmosShopID = Convert.ToInt32(dr["shop_id"].ToString());
                                    if (dr["actual_lease_suite_end_date"].ToString() != "")
                                        lease.ActualLeaseEndDate = Convert.ToDateTime(dr["actual_lease_suite_end_date"].ToString());
                                    lease.FromAmos = 1;
                                    lease.AMOSInstanceID = instancename; //tessa update 08 Oct 2012
                                    lease.Save();
                                }
                                conn.Commit();
                            }
                            catch (Exception e)
                            {
                                errorMsg = appendErrorMsg(errorMsg, e.Message);

                                String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                                OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Master Service Error", "Process Lease Agmt: " + errorMsg);//tessa update 08 Oct 2012
                            }
                        }
                    }
                }

                #endregion

                #region  dis-active points

                List<OLocation> bl = TablesLogic.tLocation.LoadList(TablesLogic.tLocation.LocationType.ObjectName == OApplicationSetting.Current.LocationTypeNameForBuildingActual &
                                                                    TablesLogic.tLocation.AMOSInstanceID == instancename);//tessa update 08 Oct 2012
                int?[] buildingID = new int?[bl.Count];
                for (int j = 0; j < bl.Count;j++ )
                {
                    if (bl[j].AmosAssetID != null)
                    buildingID[j] = bl[j].AmosAssetID;
                }
                for (int m = 0; m < buildingID.Length; m++)
                {
                    if (buildingID[m] == null)
                        continue;
                    List<OPoint> points = TablesLogic.tPoint.LoadList(TablesLogic.tPoint.IsActive == 1 &
                        TablesLogic.tPoint.Location.AmosAssetID == buildingID[m] & 
                        TablesLogic.tPoint.Location.AMOSInstanceID == instancename);//tessa update 08 Oct 2012
                    ArrayList leaseIDs = new ArrayList();
                    Hashtable pointLease = new Hashtable();

                    foreach (OPoint pt in points)
                    {
                        if (pt.TenantLeaseID != null)
                        {
                            leaseIDs.Add(pt.TenantLeaseID);
                            pointLease[pt.TenantLeaseID] = pt;
                        }

                    }

                    List<OTenantLease> tls = TablesLogic.tTenantLease.LoadList(TablesLogic.tTenantLease.ObjectID.In(leaseIDs) &
                                                                               TablesLogic.tTenantLease.AMOSInstanceID == instancename);//tessa update 08 Oct 2012
                    using (Connection c = new Connection())
                    {
                        DateTime readingDateTime =
                            new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
                        if (DateTime.Now.Day <= OApplicationSetting.Current.PostingEndDay)
                            readingDateTime = readingDateTime.AddMonths(-1);

                        foreach (OTenantLease tl in tls)
                        {
                            if (tl.ObjectID != null)
                            {
                                if (tl.LeaseStatus == "X" || tl.LeaseStatus == "R" || tl.LeaseStatus == "O" || tl.LeaseStatus == "T")
                                {
                                    if(tl.LeaseStatusDate.Value < readingDateTime)
                                    /*if (tl.LeaseStatusDate.Value<DateTime.Now
                                        && (tl.LeaseStatusDate.Value.Month < DateTime.Now.Month ||tl.LeaseStatusDate.Value.Year<DateTime.Now.Year)
                                        && DateTime.Now.Day > OApplicationSetting.Current.PostingEndDay)*/
                                    {
                                        OPoint p = (OPoint)pointLease[tl.ObjectID];
                                        p.IsActive = 0;
                                        p.Save();
                                    }
                                }
                                else if (tl.LeaseStatus == "N" || tl.LeaseStatus == "E")
                                {
                                   /* if (tl.LeaseEndDate.Value<DateTime.Now
                                        && (tl.LeaseEndDate.Value.Month < DateTime.Now.Month 
                                        || tl.LeaseEndDate.Value.Year<DateTime.Now.Year)
                                        && DateTime.Now.Day > OApplicationSetting.Current.PostingEndDay)*/
                                    if(tl.LeaseEndDate.Value<readingDateTime)
                                    {
                                        OPoint p = (OPoint)pointLease[tl.ObjectID];
                                        p.IsActive = 0;
                                        p.Save();
                                    }
                                }
                                else if (tl.LeaseStatus == "V")
                                {
                                    /*if (tl.LeaseStatusChangeDate.Value<DateTime.Now
                                        && (tl.LeaseStatusChangeDate.Value.Month < DateTime.Now.Month ||tl.LeaseStatusChangeDate.Value.Year<DateTime.Now.Year)
                                        && DateTime.Now.Day > OApplicationSetting.Current.PostingEndDay)*/
                                    if (tl.LeaseStatusChangeDate.Value<readingDateTime)
                                    {
                                        OPoint p = (OPoint)pointLease[tl.ObjectID];
                                        p.IsActive = 0;
                                        p.Save();
                                    }
                                }
                            }
                        }
                        c.Commit();
                    }
                }
                #endregion
            }
            catch (Exception e)
            {
                errorMsg = appendErrorMsg(errorMsg, e.Message);

                String emailAdd = OApplicationSetting.Current.EmailForAMOSFailure;
                OMessage.SendMail(emailAdd, OApplicationSetting.Current.EmailForAMOSFailure, instancename + ": " + "Read Master Service Error", errorMsg);//tessa update 08 Oct 2012
            }
        }
        public String appendErrorMsg(String errorMsg, String newError)
        {
            if (errorMsg == "")
                errorMsg = newError + "<br />";
            else
                errorMsg = errorMsg + newError + "<br />";

            return errorMsg;
        }
        public String getUpdatedOnList(DataTable dt)
        {

            String temp = "(";
            int count = 0;
            int itemCount = 0;
            foreach (DataRow dr in dt.Rows)
            {
                if (dr["UpdatedOn"].ToString() != "")
                {
                    if (count == dt.Rows.Count-1)
                        temp += "'" + Convert.ToDateTime(dr["UpdatedOn"]).ToString("yyyy-MM-dd HH:mm:ss.fff") + "')";
                    else
                        temp += "'" + Convert.ToDateTime(dr["UpdatedOn"]).ToString("yyyy-MM-dd HH:mm:ss.fff") + "',";
                    itemCount++;
                }
                count++;
            }
            if (itemCount == 0)
                return "('')";
            else
                return temp;
        }


        /// <summary>
        /// Compares 2 date/times and returns true if the difference
        /// is smaller than 10 milliseconds.
        /// </summary>
        /// <param name="dt1"></param>
        /// <param name="dt2"></param>
        /// <returns></returns>
        public bool CompareDateTimes(DateTime dt1, DateTime dt2)
        {
            TimeSpan ts = dt1.Subtract(dt2);

            if (ts.TotalMilliseconds < 10 && ts.TotalMilliseconds > -10)
                return true;
            return false;
        }
    }
}
