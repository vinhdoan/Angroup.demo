//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    [Database("#database"), Map("SurveyPlanner")]
    public partial class TSurveyPlanner : LogicLayerSchema<OSurveyPlanner>
    {
        [Size(255)]
        public SchemaString SurveyFormTitle1;
        [Size(255)]
        public SchemaString SurveyFormTitle2;
        [Size(1000)]
        public SchemaString SurveyFormDescription;
        [Size(100)]
        public SchemaString NonContractedVendor;
        //[Size(100)]
        //public SchemaString SurveyServiceLevelName;

        public SchemaGuid CreatorID;

        public SchemaInt SurveyType;
        public SchemaDateTime PerformancePeriodFrom;
        public SchemaDateTime PerformancePeriodTo;

        public SchemaDateTime ValidityStart;
        public SchemaDateTime ValidityEnd;
        public SchemaDecimal SurveyThreshold;
        public SchemaInt IsValidityEndNotified;
        public SchemaInt IsSurveyThresholdNotified;

        public TLocation IncludeLocations { get { return ManyToMany<TLocation>("SurveyPlannerIncludeLocation", "SurveyPlannerID", "LocationID"); } }
        public TLocation ExcludeLocations { get { return ManyToMany<TLocation>("SurveyPlannerExcludeLocation", "SurveyPlannerID", "LocationID"); } }
        public TLocation Locations { get { return ManyToMany<TLocation>("SurveyPlannerLocation", "SurveyPlannerID", "LocationID"); } }
        public TContract Contracts { get { return ManyToMany<TContract>("SurveyPlannerContract", "SurveyPlannerID", "ContractID"); } }

        public TUser Creator { get { return OneToOne<TUser>("CreatorID"); } }
        public TSurveyTrade SurveyTrades { get { return OneToMany<TSurveyTrade>("SurveyPlannerID"); } }
        public TSurveyReminder SurveyReminders { get { return OneToMany<TSurveyReminder>("SurveyPlannerID"); } }
        public TSurveyPlannerUpdate SurveyPlannerUpdates { get { return OneToMany<TSurveyPlannerUpdate>("SurveyPlannerID"); } }
        public TSurvey Surveys { get { return OneToMany<TSurvey>("SurveyPlannerID"); } }
    }


    public abstract partial class OSurveyPlanner : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {
        public abstract string SurveyFormTitle1 { get; set; }
        public abstract string SurveyFormTitle2 { get; set; }
        public abstract string SurveyFormDescription { get; set; }
        //public abstract string SurveyServiceLevelName { get; set; }

        public abstract string NonContractedVendor { get; set; }

        public abstract Guid? CreatorID { get; set; }     
   
        public abstract int? SurveyType { get; set; }
        public abstract DateTime? PerformancePeriodFrom { get; set; }
        public abstract DateTime? PerformancePeriodTo { get; set; }

        public abstract DateTime? ValidityStart { get; set; }
        public abstract DateTime? ValidityEnd { get; set; }
        public abstract Decimal? SurveyThreshold { get; set; }
        public abstract int? IsValidityEndNotified { get; set; }
        public abstract int? IsSurveyThresholdNotified { get; set; }

        public abstract OUser Creator { get; set; }
        public abstract DataList<OLocation> IncludeLocations { get; set; }
        public abstract DataList<OLocation> ExcludeLocations { get; set; }
        public abstract DataList<OLocation> Locations { get; set; }
        public abstract DataList<OContract> Contracts { get; set; }

        public abstract DataList<OSurveyTrade> SurveyTrades { get; set; }
        public abstract DataList<OSurveyReminder> SurveyReminders { get; set; }
        public abstract DataList<OSurveyPlannerUpdate> SurveyPlannerUpdates { get; set; }
        public abstract DataList<OSurvey> Surveys { get; set; }


        /// --------------------------------------------------------------
        /// <summary>
        /// Set the survey planner number format
        /// </summary>
        /// --------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            if (this.IsNew)
            {

                // format of the contract number can be changed per customization
                //
                //this.ObjectNumber = ORunningNumber.GenerateNextNumber("SurveyPlanner", "SPN/{2:00}{1:00}/{0:0000}", true);
            }
        }

        public void UpdateSurveyLocations()
        {
            // Temp solution by cyong
            List<OLocation> SurveyLocations = new List<OLocation>();
            DataTable dt = new DataTable();

            ArrayList TotalListOfSurveyIDs = new ArrayList();
            foreach (OLocation IncludeL in IncludeLocations)
            {
                ArrayList ListOfIncludeIDs = TablesLogic.tLocation.Select(TablesLogic.tLocation.ObjectID)
                    .Where(TablesLogic.tLocation.HierarchyPath.Like(IncludeL.HierarchyPath + "%"));
                foreach (object o in ListOfIncludeIDs)
                {
                    if (TotalListOfSurveyIDs.IndexOf(o) == -1)
                        TotalListOfSurveyIDs.Add(o);
                }
            }
            foreach (OLocation ExcludeL in ExcludeLocations)
            {
                ArrayList ListOfExcludeIDs = TablesLogic.tLocation.Select(TablesLogic.tLocation.ObjectID)
                    .Where(TablesLogic.tLocation.HierarchyPath.Like(ExcludeL.HierarchyPath + "%"));
                foreach (object o in ListOfExcludeIDs)
                {
                    int i = TotalListOfSurveyIDs.IndexOf(o);
                    if (i != -1)
                        TotalListOfSurveyIDs.RemoveAt(i);
                }
            }
            SurveyLocations = TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.ObjectID.In(TotalListOfSurveyIDs)
                , TablesLogic.tLocation.HierarchyPath.Asc);

            this.Locations.Clear();
            foreach (OLocation L in SurveyLocations)
            {
                this.Locations.Add(L);
            }
        }

        public void GenerateContractList()
        {
            this.Contracts.Clear();
            this.UpdateSurveyLocations();

            ExpressionCondition b = null;
            if (this.ExcludeLocations.Count == 0)
                b = Query.True;
            else
                b = Query.False;
            foreach (OLocation location in this.ExcludeLocations)
            {
                b = b | !TablesLogic.tContract.Locations.HierarchyPath.Like(location.HierarchyPath + "%");
            }
            ExpressionCondition c = Query.False;
            foreach (OLocation location in this.IncludeLocations)
            {
                c = c | ((ExpressionDataString)location.HierarchyPath).Like(TablesLogic.tContract.Locations.HierarchyPath + "%") |
                    TablesLogic.tContract.Locations.HierarchyPath.Like(location.HierarchyPath + "%");
            }

            ExpressionCondition d = Query.False;
            foreach (OSurveyTrade ST in this.SurveyTrades)
            {
                d = d | (TablesLogic.tContract.SurveyGroupID == ST.SurveyGroupID &
                    TablesLogic.tContract.SurveyGroup.IsDeleted == 0);
            }
            ExpressionCondition e = (TablesLogic.tContract.ContractStartDate <= this.PerformancePeriodFrom &
                                     TablesLogic.tContract.ContractEndDate >= this.PerformancePeriodFrom) |
                                    (TablesLogic.tContract.ContractStartDate <= this.PerformancePeriodTo &
                                     TablesLogic.tContract.ContractEndDate >= this.PerformancePeriodTo) |
                                    (TablesLogic.tContract.ContractStartDate >= this.PerformancePeriodFrom &
                                     TablesLogic.tContract.ContractEndDate <= this.PerformancePeriodTo);

            ExpressionCondition f = TablesLogic.tContract.SurveyGroup.IsDeleted == 0 & TablesLogic.tContract.Locations.IsDeleted == 0;

            List<OContract> list = TablesLogic.tContract[b & c & d & e & f];

            foreach (OContract C in list)
            {
                this.Contracts.Add(C);
            }
        }

        //public void SetupSurveys()
        //{
        //    this.Surveys.Clear();
        //    this.UpdateSurveyLocations();

        //    #region surveylocation
        //    if (this.SurveyType == SurveyTargetTypeClass.SurveyContractedVendor ||
        //        this.SurveyType == SurveyTargetTypeClass.SurveyOthers)
        //    {
        //        foreach (OLocation L in this.Locations)
        //        {
        //            OSurvey NewS = TablesLogic.tSurvey.Create();
        //            NewS.LocationID = L.ObjectID;
        //            NewS.ContractID = null;
        //            NewS.SurveyGroupID = null;

        //            // Get list of survey respondent portfolio that cover this location based on selected survey type and performance period
        //            //
        //            List<OSurveyRespondentPortfolio> ListOfSRP = L.GetListOfApplicableSurveyRespondentPortfolio(
        //                this.SurveyType,this.PerformancePeriodFrom, null);

        //            // Create survey response from based on list of survey respondent portfolio
        //            //
        //            foreach (OSurveyRespondentPortfolio SRP in ListOfSRP)
        //            {
        //                OSurveyResponseFrom NewSRF = TablesLogic.tSurveyResponseFrom.Create();
        //                NewSRF.SurveyPlannerID = this.ObjectID;
        //                NewSRF.SurveyRespondentPortfolioID = SRP.ObjectID;
        //                NewSRF.EmailAddress = SRP.EmailAddress;

        //                NewS.SurveyResponseFroms.Add(NewSRF);
        //            }

        //            // Get list of contract that cover this location based on selected survey trade and performance period 
        //            //
        //            List<OSurveyTrade> ListOfST = this.SurveyTrades.Order(TablesLogic.tSurveyTrade.DisplayOrder.Asc);
        //            int i = 1;
        //            foreach (OSurveyTrade ST in ListOfST)
        //            {
        //                if (ST.SurveyGroup.ContractMandatory == 1)
        //                {
        //                    List<OContract> ListOfC = L.GetListOfApplicableContractToBeSurveyed(ST.SurveyGroupID, this.PerformancePeriodFrom, null);

        //                    // Create survey response to based on list of contract
        //                    //
        //                    foreach (OContract C in ListOfC)
        //                    {
        //                        if (this.Contracts.FindObject(C.ObjectID.Value) != null)
        //                        {
        //                            OSurveyResponseTo NewSRT = TablesLogic.tSurveyResponseTo.Create();
        //                            NewSRT.SurveyPlannerID = this.ObjectID;
        //                            NewSRT.SurveyTradeID = ST.ObjectID;
        //                            NewSRT.SurveyTrade = ST;
        //                            NewSRT.ContractID = C.ObjectID;
        //                            NewSRT.ChecklistID = ST.ChecklistID;
        //                            NewSRT.DisplayOrder = i;
        //                            NewSRT.ContractMandatory = ST.SurveyGroup.ContractMandatory;
        //                            NewSRT.EvaluatedPartyName = null;

        //                            NewS.SurveyResponseTos.Add(NewSRT);
        //                            i++;
        //                        }
        //                    }

        //                    if (ListOfC.Count == 0)
        //                    {
        //                        // Should there be any warning?
        //                        //
        //                    }
        //                }
        //                else
        //                {
        //                    // Create default survey response to that does not have contract
        //                    //
        //                    OSurveyResponseTo NewSRT = TablesLogic.tSurveyResponseTo.Create();
        //                    NewSRT.SurveyPlannerID = this.ObjectID;
        //                    NewSRT.SurveyTradeID = ST.ObjectID;
        //                    NewSRT.SurveyTrade = ST;
        //                    NewSRT.ContractID = null;
        //                    NewSRT.ChecklistID = ST.ChecklistID;
        //                    NewSRT.DisplayOrder = i;
        //                    NewSRT.ContractMandatory = ST.SurveyGroup.ContractMandatory;
        //                    NewSRT.EvaluatedPartyName = ST.SurveyGroup.EvaluatedPartyName;

        //                    NewS.SurveyResponseTos.Add(NewSRT);
        //                    i++;
        //                }
        //            }

        //            this.Surveys.Add(NewS);
        //        }
        //    }
        //    #endregion
        //    #region surveycontract
        //    else if (this.SurveyType == SurveyTargetTypeClass.SurveyContractedVendorEvaluatedByMA)
        //    {
        //        List<OSurveyTrade> ListOfST = this.SurveyTrades.Order(TablesLogic.tSurveyTrade.DisplayOrder.Asc);

        //        foreach (OSurveyTrade ST in ListOfST)
        //        {
        //            if (ST.SurveyGroup.ContractMandatory != 1)
        //            {
        //                OSurvey NewS = TablesLogic.tSurvey.Create();
        //                NewS.ContractID = null;
        //                NewS.SurveyGroupID = ST.SurveyGroupID;

        //                // Get all survey respondent portfolio based on selected survey type and performance period
        //                //
        //                List<OSurveyRespondentPortfolio> ListOfSRP = OSurveyRespondentPortfolio.GetListOfSurveyRespondentPortfolio(
        //                    this.SurveyType, null, this.PerformancePeriodFrom, null);

        //                // Create survey response from based on list of survey respondent portfolio
        //                //
        //                foreach (OSurveyRespondentPortfolio SRP in ListOfSRP)
        //                {
        //                    OSurveyResponseFrom NewSRF = TablesLogic.tSurveyResponseFrom.Create();
        //                    NewSRF.SurveyPlannerID = this.ObjectID;
        //                    NewSRF.SurveyRespondentPortfolioID = SRP.ObjectID;
        //                    NewSRF.EmailAddress = SRP.EmailAddress;

        //                    NewS.SurveyResponseFroms.Add(NewSRF);
        //                }

        //                // Only one survey response to for this type of survey
        //                //
        //                OSurveyTrade CurrentST = ST;

        //                OSurveyResponseTo NewSRT = TablesLogic.tSurveyResponseTo.Create();
        //                NewSRT.SurveyPlannerID = this.ObjectID;
        //                NewSRT.SurveyTradeID = CurrentST.ObjectID;
        //                NewSRT.SurveyTrade = CurrentST;
        //                NewSRT.ContractID = null;
        //                NewSRT.ChecklistID = CurrentST.ChecklistID;
        //                NewSRT.DisplayOrder = 1;
        //                NewSRT.ContractMandatory = CurrentST.SurveyGroup.ContractMandatory; // should be 0
        //                NewSRT.EvaluatedPartyName = CurrentST.SurveyGroup.EvaluatedPartyName;

        //                NewS.SurveyResponseTos.Add(NewSRT);

        //                this.Surveys.Add(NewS);
        //            }
        //        }

        //        foreach (OContract C in this.Contracts)
        //        {
        //            OSurvey NewS = TablesLogic.tSurvey.Create();
        //            NewS.LocationID = null;
        //            NewS.ContractID = C.ObjectID;
        //            NewS.SurveyGroupID = C.SurveyGroupID;

        //            // Get list of survey respondent portfolio that cover this contract based on selected survey target type and performance period
        //            //
        //            List<OSurveyRespondentPortfolio> ListOfSRP = C.GetListOfApplicableSurveyRespondentPortfolio(
        //                this.SurveyType, this.PerformancePeriodFrom, null);

        //            // Create survey response from based on list of survey respondent portfolio
        //            //
        //            foreach (OSurveyRespondentPortfolio SRP in ListOfSRP)
        //            {
        //                OSurveyResponseFrom NewSRF = TablesLogic.tSurveyResponseFrom.Create();
        //                NewSRF.SurveyPlannerID = this.ObjectID;
        //                NewSRF.SurveyRespondentPortfolioID = SRP.ObjectID;
        //                NewSRF.EmailAddress = SRP.EmailAddress;

        //                NewS.SurveyResponseFroms.Add(NewSRF);
        //            }

        //            // Only one survey response to for this type of survey
        //            //
        //            OSurveyTrade CurrentST = null;
        //            foreach (OSurveyTrade ST in ListOfST)
        //            {
        //                if (ST.SurveyGroupID == C.SurveyGroupID)
        //                {
        //                    CurrentST = ST;
        //                    break;
        //                }
        //            }
        //            if (CurrentST == null)
        //                throw new Exception("Survey trade not found!");

        //            OSurveyResponseTo NewSRT = TablesLogic.tSurveyResponseTo.Create();
        //            NewSRT.SurveyPlannerID = this.ObjectID;
        //            NewSRT.SurveyTradeID = CurrentST.ObjectID;
        //            NewSRT.SurveyTrade = CurrentST;
        //            NewSRT.ContractID = C.ObjectID;
        //            NewSRT.ChecklistID = CurrentST.ChecklistID;
        //            NewSRT.DisplayOrder = 1;
        //            NewSRT.ContractMandatory = CurrentST.SurveyGroup.ContractMandatory; // should be 1
        //            NewSRT.EvaluatedPartyName = null;

        //            NewS.SurveyResponseTos.Add(NewSRT);

        //            this.Surveys.Add(NewS);
        //        }
        //    }
        //    #endregion
        //}

        public void SetupSurveyTrades()
        {
            this.SurveyTrades.Clear();
            if (this.SurveyType == SurveyTargetTypeClass.SurveyContractedVendor)
            {
                // Temp solution by cyong
                List<OSurveyGroup> surveyGroups = TablesLogic.tSurveyGroup.LoadList(
                    TablesLogic.tSurveyGroup.SurveyContractedVendor == 1);

                foreach (OSurveyGroup group in surveyGroups)
                {
                    OSurveyTrade NewST = TablesLogic.tSurveyTrade.Create();
                    NewST.SurveyGroupID = group.ObjectID;
                    NewST.DisplayOrder = this.SurveyTrades.Count + 1;
                    NewST.ChecklistID = group.DefaultSurveyChecklistID;
                    this.SurveyTrades.Add(NewST);
                }
            }
            
            else if (this.SurveyType == SurveyTargetTypeClass.SurveyContractedVendorEvaluatedByMA)
            {
                // Temp solution by cyong
                List<OSurveyGroup> surveyGroups = TablesLogic.tSurveyGroup.LoadList(
                    TablesLogic.tSurveyGroup.SurveyContractedVendorEvaluatedByMA == 1);
                
                foreach (OSurveyGroup group in surveyGroups)
                {
                    OSurveyTrade NewST = TablesLogic.tSurveyTrade.Create();
                    NewST.SurveyGroupID = group.ObjectID;
                    NewST.DisplayOrder = this.SurveyTrades.Count + 1;
                    NewST.ChecklistID = group.DefaultSurveyChecklistID;
                    this.SurveyTrades.Add(NewST);
                }
            }
            else if (this.SurveyType == SurveyTargetTypeClass.SurveyOthers)
            {
                // Temp solution by cyong
                List<OSurveyGroup> surveyGroups = TablesLogic.tSurveyGroup.LoadList(
                    TablesLogic.tSurveyGroup.SurveyOthers == 1);

                foreach (OSurveyGroup group in surveyGroups)
                {
                    OSurveyTrade NewST = TablesLogic.tSurveyTrade.Create();
                    NewST.SurveyGroupID = group.ObjectID;
                    NewST.DisplayOrder = this.SurveyTrades.Count + 1;
                    NewST.ChecklistID = group.DefaultSurveyChecklistID;
                    this.SurveyTrades.Add(NewST);
                }
            }
        }

        public void OnEntered_Activated()
        {
            this.Surveys.AddRange(this.SetupSurveys());
            this.Save();

            // To create actual checklistitem for respondent to reply survey
            //
            //foreach (OSurvey S in this.Surveys)
            //{
            //    List<OSurveyChecklistItem> ListOfSCLI = new List<OSurveyChecklistItem>();
            //    foreach (OSurveyResponseTo SRT in S.SurveyResponseTos)
            //    {
            //        if (SRT != null && SRT.Checklist != null)
            //        {
            //            // Construct checklist form
            //            //
            //            OChecklist CL = SRT.Checklist;
            //            foreach (OChecklistItem CLI in CL.ChecklistItems)
            //            {
            //                OSurveyChecklistItem SCLI = TablesLogic.tSurveyChecklistItem.Create();
            //                SCLI.SurveyResponseToID = SRT.ObjectID;
            //                SCLI.SurveyResponseFromID = null;
            //                SCLI.SurveyPlannerID = this.ObjectID;
            //                SCLI.SurveyID = S.ObjectID;
            //                SCLI.EvaluatedPartyID = SRT.ContractID;
            //                SCLI.EvaluatedPartyName = SRT.EvaluatedPartyName;
            //                SCLI.ChecklistID = CL.ObjectID;
            //                SCLI.ChecklistResponseSetID = CLI.ChecklistResponseSetID;
            //                SCLI.ObjectName = CLI.ObjectName;
            //                SCLI.StepNumber = CLI.StepNumber;
            //                SCLI.IsMandatoryField = CLI.IsMandatoryField;
            //                SCLI.Status = SurveyStatusType.OpenForReply;
            //                SCLI.ChecklistItemType = CLI.ChecklistType;
            //                SCLI.IsOverall = CLI.IsOverall;
                            
            //                Hashtable ht_SurveyRespondent = new Hashtable();
            //                foreach (OSurveyResponseFrom SRF in S.SurveyResponseFroms)
            //                {
            //                    if (ht_SurveyRespondent[SRF.SurveyRespondentPortfolio.SurveyRespondentID.Value] == null)
            //                    {
            //                        OSurveyChecklistItem NewSCLI = TablesLogic.tSurveyChecklistItem.Create();
            //                        NewSCLI.ShallowCopy(SCLI);
                                   
            //                        NewSCLI.SurveyRespondentID = SRF.SurveyRespondentPortfolio.SurveyRespondentID;
            //                        ListOfSCLI.Add(NewSCLI);
            //                        ht_SurveyRespondent[SRF.SurveyRespondentPortfolio.SurveyRespondentID.Value] = NewSCLI;
            //                    }
            //                }
            //            }
            //        }
            //    }
            //    S.SurveyChecklistItems.AddRange(ListOfSCLI);
            //    S.Status = SurveyStatusType.OpenForReply;
            //    S.Save();
            //}

            // Send email notify all respondents
            //
            //SendEmailToRespondent(SurveyEmailType.SurveyStarted, true);

            //transist to the SURVEYPLANNER_INPROGRESS state.
            //this.TriggerWorkflowEvent("SubmitForModification");
        }

        //public string SendEmailToRespondent(int EmailType, bool ToEveryRespondent)
        
        public void SendEmailToRespondent(int EmailType, bool ToEveryRespondent)
        {
            string URL = "";
            string EmailSubject = "";
            string EmailBody = "";
            string EmailRecipient = "";
            string EmailSender = OApplicationSetting.Current.MessageEmailSender.ToString().Trim();

            List<OSurveyResponseFrom> ListOfSRF = new List<OSurveyResponseFrom>();
            //20110908
            foreach (OSurvey S in this.Surveys)
            {
                foreach (OSurveyResponseFrom SRF in S.SurveyResponseFroms)
                {
                    if (!ListOfSRF.Exists
                            (
                                delegate(OSurveyResponseFrom match)
                                {
                                    //return match.SurveyRespondentPortfolioID == SRF.SurveyRespondentPortfolioID;
                                    return match.SurveyRespondentID == SRF.SurveyRespondentID;
                                }
                            )
                       )
                        ListOfSRF.Add(SRF);
                }
            }
            //int i = 0;
            foreach (OSurveyResponseFrom SRF in ListOfSRF)
            {
                List<OSurveyChecklistItem> ListOfSCLI = TablesLogic.tSurveyChecklistItem.LoadList(
                    TablesLogic.tSurveyChecklistItem.SurveyRespondentPortfolioID == SRF.SurveyRespondent.SurveyRespondentPortfolioID &//201109
                    TablesLogic.tSurveyChecklistItem.Status == SurveyStatusType.OpenForReply
                    );

                if (ListOfSCLI.Count > 0 || ToEveryRespondent)
                {
                    if (EmailType == SurveyEmailType.SurveyStarted)
                    {
                        URL = OSurveyPlanner.GenerateSurveyFormURL(this.ObjectID.Value, SRF.SurveyRespondent.SurveyRespondentPortfolioID.Value, SRF.EmailAddress.Trim(), false);//201109
                        EmailSubject = string.Format(Resources.Strings.SurveyPlanner_SurveyStarted_Subject,
                            String.Format((this.SurveyFormTitle1 != null ? this.SurveyFormTitle1 : "") + " " + (this.SurveyFormTitle2 != null ? this.SurveyFormTitle2 : "")).Trim(),
                            SRF.SurveyRespondent.SurveyRespondentPortfolio.ObjectName//201109
                            );
                        EmailBody = string.Format(Resources.Strings.SurveyPlanner_SurveyStarted_Body, URL, this.ValidityEnd.Value.ToString("dd-MMM-yyyy"));
                    }
                    else if (EmailType == SurveyEmailType.SurveyExtended)
                    {
                        URL = OSurveyPlanner.GenerateSurveyFormURL(this.ObjectID.Value, SRF.SurveyRespondent.SurveyRespondentPortfolioID.Value, SRF.EmailAddress.Trim(), false);//201109
                        EmailSubject = string.Format(Resources.Strings.SurveyPlanner_SurveyExtended_Subject,
                            String.Format((this.SurveyFormTitle1 != null ? this.SurveyFormTitle1 : "") + " " + (this.SurveyFormTitle2 != null ? this.SurveyFormTitle2 : "")).Trim(),
                            SRF.SurveyRespondent.SurveyRespondentPortfolio.ObjectName//201109
                            );
                        EmailBody = string.Format(Resources.Strings.SurveyPlanner_SurveyExtended_Body, this.ValidityEnd.Value.ToString("dd-MMM-yyyy"), URL, this.ValidityEnd.Value.ToString("dd-MMM-yyyy"));
                    }
                    else if (EmailType == SurveyEmailType.SurveyClosed)
                    {
                        URL = OSurveyPlanner.GenerateSurveyFormURL(this.ObjectID.Value, SRF.SurveyRespondent.SurveyRespondentPortfolioID.Value, SRF.EmailAddress.Trim(), false);//201109
                        EmailSubject = string.Format(Resources.Strings.SurveyPlanner_SurveyClosed_Subject,
                            String.Format((this.SurveyFormTitle1 != null ? this.SurveyFormTitle1 : "") + " " + (this.SurveyFormTitle2 != null ? this.SurveyFormTitle2 : "")).Trim(),
                            SRF.SurveyRespondent.SurveyRespondentPortfolio.ObjectName//201109
                            );
                        EmailBody = string.Format(Resources.Strings.SurveyPlanner_SurveyClosed_Body);
                    }
                    else if (EmailType == SurveyEmailType.RemindRespondent)
                    {
                        URL = OSurveyPlanner.GenerateSurveyFormURL(this.ObjectID.Value, SRF.SurveyRespondent.SurveyRespondentPortfolioID.Value, SRF.EmailAddress.Trim(), false);//201109
                        EmailSubject = string.Format(Resources.Strings.SurveyPlanner_RemindRespondent_Subject,
                            String.Format((this.SurveyFormTitle1 != null ? this.SurveyFormTitle1 : "") + " " + (this.SurveyFormTitle2 != null ? this.SurveyFormTitle2 : "")).Trim(),
                            SRF.SurveyRespondent.SurveyRespondentPortfolio.ObjectName//201109
                            );
                        EmailBody = string.Format(Resources.Strings.SurveyPlanner_RemindRespondent_Body, URL, this.ValidityEnd.Value.ToString("dd-MMM-yyyy"));
                    }
                    else
                        throw new Exception("Invalid survey email type!");

                    EmailRecipient = SRF.EmailAddress.Trim();
                    OMessage.SendMail(EmailRecipient, EmailSender, EmailSubject, EmailBody);
                    //i++;
                }
            }
            //return this.Surveys.Count.ToString() + " " + ListOfSRF.Count.ToString() + " " + i.ToString() + " " + EmailSender;
        }

        public void OnEntered_Updated()
        {
            //transit to the SURVEYPLANNER_INPROGRESS state.
            this.TriggerWorkflowEvent("SubmitForModification");
        }

        public void OnEntered_RemindRespondent()
        {
            // Send email notify non-respond respondents
            //
            SendEmailToRespondent(SurveyEmailType.RemindRespondent, false);
            OSurveyPlannerUpdate SPU = TablesLogic.tSurveyPlannerUpdate.Create();
            SPU.SurveyPlannerID = this.ObjectID;
            SPU.PreviousSurveyThreshold = null;
            SPU.NewSurveyThreshold = null;
            SPU.PreviousValidityEnd = null;
            SPU.NewValidityEnd = null;
            SPU.Remarks = "To remind respondents that have not replied.";
            SPU.Save();
            this.SurveyPlannerUpdates.Add(SPU);
            this.Save();
            
            //transit to the SURVEYPLANNER_INPROGRESS state.
            this.TriggerWorkflowEvent("SubmitForModification");
        }

        public void CreateUpdateLog(string Remarks)
        {
            OSurveyPlanner DB_SP = TablesLogic.tSurveyPlanner.Load(this.ObjectID.Value);

            OSurveyPlannerUpdate SPU = TablesLogic.tSurveyPlannerUpdate.Create();
            SPU.SurveyPlannerID = this.ObjectID;
            SPU.PreviousSurveyThreshold = DB_SP.SurveyThreshold;
            SPU.NewSurveyThreshold = this.SurveyThreshold;
            SPU.PreviousValidityEnd = DB_SP.ValidityEnd;
            SPU.NewValidityEnd = this.ValidityEnd;
            SPU.Remarks = Remarks;
            SPU.Save();
            this.SurveyPlannerUpdates.Add(SPU);
        }

        public static string GenerateSurveyFormURL(Guid SurveyPlannerID,
            Guid SurveyRespondentPortfolioID, string RespondentEmailAddress, bool isPreview)
        {
            string URL = OApplicationSetting.Current.SurveyURL;
            if (!isPreview)
                URL += "?SPID=" +
                    HttpUtility.UrlEncode(Security.EncryptGuid(SurveyPlannerID)) + "&SRPID=" +//201109
                    HttpUtility.UrlEncode(Security.EncryptGuid(SurveyRespondentPortfolioID)) + "&REA=" +
                    HttpUtility.UrlEncode(Security.Encrypt(RespondentEmailAddress));
            else
                URL += "?SPID=" +
                    HttpUtility.UrlEncode(Security.EncryptGuid(SurveyPlannerID)) + "&SRPID=" +//201109
                    HttpUtility.UrlEncode(Security.EncryptGuid(SurveyRespondentPortfolioID)) + "&REA=" +
                    HttpUtility.UrlEncode(Security.Encrypt(RespondentEmailAddress)) + "&Preview=" +
                    HttpUtility.UrlEncode(Security.Encrypt("1"));
            return URL;
        }

        public bool ValidateSurveyHavingAtLeastOneRespondent()
        {
            foreach (OSurvey S in this.Surveys)
            {
                if (S.SurveyResponseFroms.Count == 0)
                    return false;
            }
            return true;
        }

        //public bool ValidateThresholdReached()
        //{
        //    bool Result = false;
        //    if (this.SurveyThreshold != null && this.SurveyThreshold > 0)
        //    {
        //        Result = true;
        //        DataTable dt = this.SurveyProgress;
        //        foreach (DataRow dr in dt.Rows)
        //        {
        //            if (Math.Round((decimal)dr["percentage"], 2, MidpointRounding.AwayFromZero) < this.SurveyThreshold)
        //                Result = false;
        //        }
        //    }

        //    return Result;
        //}

//        public DataTable SurveyProgress
//        {
//            get
//            {
//                DataTable dt = new DataTable();

//                DbParameter surveyPlannerID = Connection.GetProviderFactory().CreateParameter();
//                surveyPlannerID.ParameterName = "SPID";
//                surveyPlannerID.Value = this.ObjectID.Value;

//                DataSet dts = Connection.ExecuteQuery("#database",
//                    @"
//                    select 
//                    *, 
//	                    cast(case when result.totalsurvey = 0
//		                    then 0
//		                    else 100*cast(result.totalreply as decimal(19,2))/cast(result.totalsurvey as decimal(19,2))
//	                        end as decimal(19,2))
//                    as percentage
//                    from
//                    (
//	                    select distinct
//                        t5.displayorder,
//	                    t2.evaluatedpartyname,
//	                    t2.contractid as objectid,
//                        t3.contractstartdate,
//                        t3.contractenddate,
//                            t3.objectnumber
//                        as contractnumber,
//                            t3.objectname
//                        as contractname,
//                        t3.contractreferencenumber as contractreferencenumber,
//		                    t6.objectname 
//	                    as trade,
//		                    case when t3.objectid is null
//			                    then t2.evaluatedpartyname
//			                    else t4.objectname
//		                    end
//	                    as evaluatedparty,
//		                    (
//		                    select 
//		                    count (distinct cast(c.surveyid as nvarchar(255)) + cast(c.surveyrespondentid as nvarchar(255)))
//		                    from 
//		                    surveychecklistitem c
//		                    left join surveyresponseto d on (c.surveyresponsetoid = d.objectid and d.isdeleted = 0)
//		                    where
//		                    --(d.contractid = t2.contractid or d.evaluatedpartyname = t2.evaluatedpartyname)
//		                    ((d.contractid is not null and d.contractid = t2.contractid) or (d.contractid is null and d.surveytradeid = t2.surveytradeid))--d.evaluatedpartyname = t2.evaluatedpartyname and 
//		                    and c.surveyplannerid = t1.surveyplannerid
//		                    )
//	                    as totalsurvey,
//		                    (
//		                    select
//		                    count(distinct cast(a.surveyid as nvarchar(255)) + cast(a.surveyrespondentid as nvarchar(255))) 
//		                    from 
//		                    surveychecklistitem a
//		                    left join surveyresponseto b on (a.surveyresponsetoid = b.objectid and b.isdeleted = 0)
//		                    where 
//		                    --(b.contractid = t2.contractid or b.evaluatedpartyname = t2.evaluatedpartyname)
//		                    ((b.contractid is not null and b.contractid = t2.contractid) or (b.contractid is null and b.surveytradeid = t2.surveytradeid))--b.evaluatedpartyname = t2.evaluatedpartyname and 
//		                    and a.surveyplannerid = t1.surveyplannerid
//		                    and a.status = 1
//		                    )
//	                    as totalreply
//	                    from 
//	                    [surveychecklistitem] t1
//	                    left join [surveyresponseto] t2 on (t1.surveyresponsetoid = t2.objectid and t2.isdeleted = 0)
//	                    left join [contract] t3 on (t2.contractid = t3.objectid and t3.isdeleted = 0)
//	                    left join [vendor] t4 on (t3.vendorid = t4.objectid and t4.isdeleted = 0)
//	                    left join [surveytrade] t5 on (t2.surveytradeid = t5.objectid and t5.isdeleted = 0)	
//	                    left join [surveygroup] t6 on (t5.surveygroupid = t6.objectid and t6.isdeleted = 0)
//	                    where 
//	                    t1.isdeleted = 0
//	                    and t1.surveyplannerid = @SPID
//                    ) result
//                    order by result.displayorder asc, result.evaluatedparty asc, result.contractstartdate asc
//                    ",
//                     surveyPlannerID
//                     );

//                if (dts.Tables.Count > 0)
//                    dt = dts.Tables[0];

//                return dt;
//            }
//        }

        /// <summary>
        /// Translate survey type to string.
        /// </summary>
        public string SurveyTypeText
        {
            get
            {
                string SurveyTypeText = Resources.Strings.SurveyPortfolio_Error;
                if (SurveyType == 0)
                    SurveyTypeText = Resources.Strings.SurveyPortfolio_ContractedVendor;
                if (SurveyType == 1)
                    SurveyTypeText = Resources.Strings.SurveyPortfolio_ContractedVendorByMA;
                if (SurveyType == 2)
                    SurveyTypeText = Resources.Strings.SurveyPortfolio_OtherReasons;

                return SurveyTypeText;
            }
        }


    }

}


