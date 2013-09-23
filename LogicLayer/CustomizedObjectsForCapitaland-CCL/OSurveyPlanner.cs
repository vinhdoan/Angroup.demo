//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Odbc;
using System.Data.Common;
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
    /// Summary description for OSurveyPlanner
    /// </summary>
    public partial class TSurveyPlanner : LogicLayerSchema<OSurveyPlanner>
    {
        public SchemaDateTime ValidStartDate;
        public SchemaDateTime ValidEndDate;

        public SchemaDateTime SurveyStartDate;

        public SchemaDateTime SurveyEndDate;

        public SchemaInt SurveyTargetType;

        public SchemaInt IsValidEndNotified;

        [Default(0)]
        public SchemaInt IsSingleCheklistSurvey;

        public TSurveyPlannerRespondent SurveyPlannerRespondents { get { return OneToMany<TSurveyPlannerRespondent>("SurveyPlannerID"); } }

        public TSurveyPlannerNotification SurveyPlannerNotifications { get { return OneToMany<TSurveyPlannerNotification>("SurveyPlannerID"); } }

        public TSurveyPlannerAccess SurveyPlannerAccess { get { return OneToMany<TSurveyPlannerAccess>("SurveyPlannerID"); } }

        public TSurveyPlannerServiceLevel SurveyPlannerServiceLevels { get { return OneToMany<TSurveyPlannerServiceLevel>("SurveyPlannerID"); } }
    }


    public abstract partial class OSurveyPlanner : LogicLayerPersistentObject, IWorkflowEnabled
    {
        public abstract DateTime? ValidStartDate { get; set; }

        public abstract DateTime? ValidEndDate { get; set; }

        public abstract int? SurveyTargetType { get; set; }

        public abstract int? IsValidEndNotified { get; set; }

        public abstract int? IsSingleCheklistSurvey { get; set; }

        public abstract DataList<OSurveyPlannerRespondent> SurveyPlannerRespondents { get; }

        public abstract DataList<OSurveyPlannerServiceLevel> SurveyPlannerServiceLevels { get; }

        public abstract DataList<OSurveyPlannerNotification> SurveyPlannerNotifications { get; }

        public abstract DataList<OSurveyPlannerAccess> SurveyPlannerAccess { get; }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="spr"></param>
        /// <returns></returns>
        public OSurvey CreateNewSurvey(OSurveyPlannerRespondent spr)
        {
            OSurvey newSurvey = TablesLogic.tSurvey.Create();
            newSurvey.SurveyPlannerID = this.ObjectID;
            newSurvey.SurveyPlannerRespondentID = spr.ObjectID;
            newSurvey.SurveyTargetType = this.SurveyTargetType;
            newSurvey.Status = (int)EnumSurveyStatusType.Open;
            return newSurvey;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="srp"></param>
        /// <returns></returns>
        public List<OSurveyPlannerRespondent> AddSurveyPlannerRespondents(OSurveyRespondentPortfolio srp)
        {
            List<OSurveyPlannerRespondent> listSurveyPlannerRespondents = new List<OSurveyPlannerRespondent>();

            foreach (OSurveyRespondent sr in srp.SurveyRespondents)
            {
                OSurveyPlannerRespondent respondent = this.SurveyPlannerRespondents.Find((spr) =>
                    spr.SurveyRespondentPortfolioID == srp.ObjectID &&
                    spr.SurveyRespondentID == sr.ObjectID);
                if (respondent == null)
                {
                    OSurveyPlannerRespondent newRespondent = TablesLogic.tSurveyPlannerRespondent.Create();
                    newRespondent.SurveyRespondentID = sr.ObjectID;
                    newRespondent.SurveyRespondentPortfolioID = srp.ObjectID;
                    listSurveyPlannerRespondents.Add(newRespondent);
                }
            }

            return listSurveyPlannerRespondents;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public List<OSurvey> SetupSurveys()
        {
            List<OSurvey> listSurveys = new List<OSurvey>();



            foreach (OSurveyPlannerRespondent spr in this.SurveyPlannerRespondents)
            {
                if (this.Surveys.Find((s) =>
                    //s.SurveyRespondentPortfolioID == spr.SurveyRespondentPortfolioID &&
                    s.SurveyPlannerID == this.ObjectID &&
                    s.SurveyPlannerRespondentID == spr.ObjectID) == null)
                {

                    if (this.IsSingleCheklistSurvey == 1)
                    {
                        foreach (OSurveyPlannerServiceLevel level in this.SurveyPlannerServiceLevels)
                        {
                            OSurvey newSurvey = CreateNewSurvey(spr);
                            //newSurvey.EvaluatedParty = level.SurveyGroup.ObjectName;
                            //newSurvey.LocationID = this.LocationID;
                            //newSurvey.SurveyGroupServiceLevels.Add(level);
                            newSurvey.UpdateSurveyChecklistItem();
                            listSurveys.Add(newSurvey);
                        }
                    }
                    else
                    {
                        OSurvey newSurvey = CreateNewSurvey(spr);
                        //newSurvey.EvaluatedParty = this.SurveyGroupServiceLevels[0].SurveyGroup.ObjectName;
                        //PTB
                        //newSurvey.LocationID = this.LocationID;
                        //newSurvey.SurveyGroupServiceLevels.AddRange(this.SurveyGroupServiceLevels.FindAll((a) => a.ObjectID != null));

                        newSurvey.UpdateSurveyChecklistItem();
                        listSurveys.Add(newSurvey);
                    }
                }

            }


            return listSurveys;
        }

        public static string GenerateSurveyFormURL(Guid SurveyID, Guid SurveyPlannerID,
            Guid SurveyRespondentID, string RespondentEmailAddress, bool isPreview)//201109
        {
            string URL = OApplicationSetting.Current.SurveyURL;
            if (!isPreview)
                URL += 
                    "?SPID=" + HttpUtility.UrlEncode(Security.EncryptGuid(SurveyPlannerID)) +
                    "&SRID=" + HttpUtility.UrlEncode(Security.EncryptGuid(SurveyRespondentID)) + 
                    "&REA=" + HttpUtility.UrlEncode(Security.Encrypt(RespondentEmailAddress)) + 
                    "&SID=" + HttpUtility.UrlEncode(Security.EncryptGuid(SurveyID));
            else
                URL += 
                    "?SPID=" + HttpUtility.UrlEncode(Security.EncryptGuid(SurveyPlannerID)) +
                    "&SRID=" + HttpUtility.UrlEncode(Security.EncryptGuid(SurveyRespondentID)) + 
                    "&REA=" + HttpUtility.UrlEncode(Security.Encrypt(RespondentEmailAddress)) + 
                    "&SID=" + HttpUtility.UrlEncode(Security.EncryptGuid(SurveyID)) + 
                    "&Preview=" + HttpUtility.UrlEncode(Security.Encrypt("1"));

            return URL;
        }

        public DataTable SurveyProgress
        {
            get
            {
                DataTable dt = new DataTable();

                dt.Columns.Add("ObjectID");
                dt.Columns.Add("TotalSurvey");
                dt.Columns.Add("TotalResponse");
                dt.Columns.Add("LastResponseDateTime");
                dt.Columns.Add("TotalResponsePercentage");

                int totalSurveys = this.Surveys.Count;

                List<OSurvey> completedSurveys = this.Surveys.FindAll((s) =>
                    s.Status == (int)EnumSurveyStatusType.Responded ||
                    s.Status == (int)EnumSurveyStatusType.ClosedWithResponse);
                int totalResponses = completedSurveys.Count;

                DateTime? lastResponseDateTime = null;

                if (this.Surveys.Count > 0)
                {
                    lastResponseDateTime = this.Surveys.Order(TablesLogic.tSurvey.SurveyRespondedDateTime.Desc)[0].SurveyRespondedDateTime;
                    //lastResponseDateTime = this.Surveys[0].SurveyRespondedDateTime;
                }

                decimal totalPercentage = 0M;
                if (totalSurveys > 0)
                    totalPercentage = Round((decimal)totalResponses / (decimal)totalSurveys * 100);

                dt.Rows.Add(Guid.NewGuid(), totalSurveys, totalResponses, lastResponseDateTime, totalPercentage);

                return dt;

            }
        }

        public string SurveyTargetTypeText
        {
            get
            {
                return TranslateSurveyTargetType(this.SurveyTargetType);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public string TranslateSurveyTargetType(int? target)
        {
            switch (target)
            {
                case (int)EnumSurveyTargetType.Tenant:
                    return "Tenant Surveys";
                    break;
                case (int)EnumSurveyTargetType.ContractedVendor:
                    return "Surveys for contracted vendors";
                    break;
                case (int)EnumSurveyTargetType.NonContractedVendor:
                    return "Surveys for non contracted vendors";
                    break;
                case (int)EnumSurveyTargetType.Others:
                    return "Surveys for other reasons";
                    break;
                default:
                    return "Error";
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public bool ValidateThresholdReached(decimal? suveyThreshold)
        {
            //bool Result = false;
            bool Result = false;
            DataTable dt = this.SurveyProgress;
            foreach (DataRow dr in dt.Rows)
            {
                if (Math.Round((decimal)dr["TotalResponsePercentage"], 2, MidpointRounding.AwayFromZero) >= suveyThreshold)
                    Result = true;
            }


            return Result;
        }

        /// --------------------------------------------------------------
        /// <summary>
        /// Re-order the list of items in the checklist response set.
        /// </summary>
        /// <param name="i"></param>
        /// --------------------------------------------------------------
        public void ReorderItems(OSurveyPlannerServiceLevel p)
        {
            Global.ReorderItems(SurveyPlannerServiceLevels, p, "ItemNumber");
        }

        /// <summary>
        /// 
        /// </summary>
        public void Close()
        {
            foreach (OSurvey S in this.Surveys)
            {
                if (S.Status == (int)EnumSurveyStatusType.Open)
                    S.Status = (int)EnumSurveyStatusType.ClosedWithoutResponse;

                if (S.Status == (int)EnumSurveyStatusType.Responded)
                    S.Status = (int)EnumSurveyStatusType.ClosedWithResponse;

                S.Save();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public void InProgress()
        {
            //this.SurveyPlannerRespondents.AddRange(this.SetupSurveyRespondents());
            //this.Save();
            this.Surveys.AddRange(this.SetupSurveys());
            this.Save();
        }

        public void SendEmailNotification(OSurveyPlannerNotification SR)
        {
            if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyThresholdReached)
            {
                SendMessage("SurveyPlanner_SurveyThresholdReached", SR.NotificationEmail, "");
            }

            if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyValidityEnd)
            {
                SendMessage("SurveyPlanner_SurveyValidEndReached", SR.NotificationEmail, "");
            }
        }


    }

    /// <summary>
    /// 
    /// </summary>
    public enum EnumSurveyTargetType
    {
        Tenant = 0,
        NonContractedVendor = 1,
        ContractedVendor = 2,
        Others = 3
    }
}


