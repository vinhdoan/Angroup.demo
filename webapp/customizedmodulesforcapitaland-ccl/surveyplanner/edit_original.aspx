<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;

        this.treeExcludeLocationAccess.PopulateTree();
        this.treeIncludeLocationAccess.PopulateTree();

        string PanelMessageType = "";
        if (Request["PMT"] != null)
            PanelMessageType = Security.Decrypt(Request["PMT"]);

        if (PanelMessageType == "SAVE")
            panel.Message = Resources.Messages.General_ItemSaved;
        if (PanelMessageType == "UPDATED")
            panel.Message = Resources.Messages.SurveyPlanner_Updated;
        if (PanelMessageType == "REMINDRESPONDENT")
            panel.Message = Resources.Messages.General_ItemSaved;

        ContractID.Bind(TablesLogic.tContract.LoadList(TablesLogic.tContract.IsDeleted == 0), "ObjectNumber", "ObjectID");
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void panel_PreRender(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(CurrentSP);

        panel_NonUpdateableDetails_1.Enabled = false;
        panel_NonUpdateableDetails_2.Enabled = false;
        panel_SetupDetails_1.Enabled = false;
        panel_SetupDetails_2.Enabled = false;
        panel_UpdateableDetails.Enabled = false;
        panel_ContractButton.Visible = false;
        panel_Contracts.Visible = false;
        panel_SetupSurvey.Visible = false;
        treeIncludeLocationAccess.Visible = false;
        treeExcludeLocationAccess.Visible = false;
        gridExcludeLocationAccess.Visible = false;
        Remarks.Visible = false;

        Workflow_Validation();

        panel_Contracts.Visible = (CurrentSP.SurveyType != SurveyTargetType.SurveyOthers);
        GV_SurveyLocation.Visible = (CurrentSP.SurveyType == SurveyTargetType.SurveyContractedVendor ||
            CurrentSP.SurveyType == SurveyTargetType.SurveyOthers);
        GV_SurveyContract.Visible = (CurrentSP.SurveyType == SurveyTargetType.SurveyContractedVendorEvaluatedByMA);
        NonContractedVendor.Visible = CurrentSP.SurveyType == SurveyTargetType.SurveyOthers;
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    /// <summary>
    /// Performs validation based on workflow.
    /// </summary>
    protected void Workflow_Validation()
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(CurrentSP);

        if (objectBase.SelectedAction.Is("SaveAsDraft", "Activate") ||
            objectBase.WorkflowActionRadioList.SelectedValue == "-" ||
            objectBase.WorkflowActionRadioList.SelectedValue == "" ||
            objectBase.CurrentObjectState.Is("SURVEYPLANNER_SAVED"))
        {
            panel_NonUpdateableDetails_1.Enabled = true;
            panel_NonUpdateableDetails_2.Enabled = true;
            panel_SetupDetails_2.Enabled = (CurrentSP.Contracts.Count == 0);
            panel_SetupDetails_1.Enabled = (CurrentSP.Surveys.Count == 0);
            panel_UpdateableDetails.Enabled = true;
            treeIncludeLocationAccess.Visible = true;
            treeExcludeLocationAccess.Visible = true;
            gridExcludeLocationAccess.Visible = true;
            panel_ContractButton.Visible = (CurrentSP.SurveyType != SurveyTargetType.SurveyOthers);
            panel_SetupSurvey.Visible = true;
            GV_SurveyLocation.ValidateRequiredField = objectBase.SelectedAction == "Activate";
            GV_SurveyContract.ValidateRequiredField = objectBase.SelectedAction == "Activate";
        }

        gridExcludeLocationAccess.Visible =
            (((objectBase.CurrentObjectState == "SURVEYPLANNER_SAVED" && objectBase.SelectedAction=="Cancel"))
            || objectBase.CurrentObjectState.Is("Draft", "SURVEYPLANNER_INPROGRESS", "SURVEYPLANNER_CANCELLED", "SURVEYPLANNER_CLOSED"))
            && CurrentSP.ExcludeLocations.Count > 0;

        if (objectBase.CurrentObjectState == "SURVEYPLANNER_INPROGRESS" &&
            objectBase.SelectedAction == "RemindRespondent")
            Session["SP_SelectedState"] = "SURVEYPLANNER_REMINDRESPONDENT";

        if (objectBase.CurrentObjectState == "SURVEYPLANNER_INPROGRESS" &&
            objectBase.SelectedAction == "Update")
        {
            panel_UpdateableDetails.Enabled = true;
            Remarks.Visible = true;
            Session["SP_SelectedState"] = "SURVEYPLANNER_UPDATED";
        }
    }

    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(CurrentSP);

            OSurveyPlanner DB_SP = TablesLogic.tSurveyPlanner.Load(CurrentSP.ObjectID.Value);

            if (CurrentSP.IsNew)
                CurrentSP.CreatorID = AppSession.User.ObjectID;

            if (objectBase.CurrentObjectState == "InProgress" &&
                objectBase.SelectedAction == "Update")
            {
                CurrentSP.CreateUpdateLog(Remarks.Text);
                if (DB_SP != null)
                {
                    if (CurrentSP.ValidityEnd != DB_SP.ValidityEnd)
                        CurrentSP.IsValidityEndNotified = null;
                    if (CurrentSP.SurveyThreshold != DB_SP.SurveyThreshold)
                        CurrentSP.IsSurveyThresholdNotified = null;
                }
            }

            // Validate
            //
            Validate();

            // Save
            //            
            CurrentSP.Save();
            c.Commit();
            panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
    }

    protected void Validate()
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        if (objectBase.SelectedAction == "Activate")
        {
            if (!CurrentSP.ValidateSurveyHavingAtLeastOneRespondent())
            {
                GV_SurveyLocation.ErrorMessage = Resources.Errors.SurveyPlanner_RespondentRequire;
                GV_SurveyContract.ErrorMessage = Resources.Errors.SurveyPlanner_RespondentRequire;
            }
        }
    }


    protected TreePopulater treeIncludeLocationAccess_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "", false, false);
    }

    protected void treeIncludeLocationAccess_SelectedNodeChanged(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(CurrentSP);
        if(treeIncludeLocationAccess.SelectedValue != "")
            CurrentSP.IncludeLocations.AddGuid(new Guid(treeIncludeLocationAccess.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void gridIncludeLocationAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            foreach (Guid id in objectIds)
                CurrentSP.IncludeLocations.RemoveGuid(id);
            panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
    }

    protected TreePopulater treeExcludeLocationAccess_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "", false, false);
    }

    protected void treeExcludeLocationAccess_SelectedNodeChanged(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(CurrentSP);
        if(treeExcludeLocationAccess.SelectedValue != "")
            CurrentSP.ExcludeLocations.AddGuid(new Guid(treeExcludeLocationAccess.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void gridExcludeLocationAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(CurrentSP);
            foreach (Guid id in objectIds)
                CurrentSP.ExcludeLocations.RemoveGuid(id);
            panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
    }

    protected void gridSurveyTrade_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "DeleteObject")
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(CurrentSP);
            foreach (Guid id in objectIds)
                CurrentSP.SurveyTrades.RemoveGuid(id);
            panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
    }

    protected void subpanel_SurveyTrade_PopulateForm(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        OSurveyTrade CurrentST = (OSurveyTrade)subpanel_SurveyTrade.SessionObject;

        DisplayOrder.Items.Clear();
        for (int i = 0; i < CurrentSP.SurveyTrades.Count + 1; i++)
            DisplayOrder.Items.Add(new ListItem((i + 1).ToString(), (i + 1).ToString()));

        if (CurrentST.DisplayOrder == null)
            CurrentST.DisplayOrder = DisplayOrder.Items.Count;

        SurveyGroupID.Bind(TablesLogic.tSurveyGroup.LoadAll());

        ChecklistID.Bind(TablesLogic.tChecklist.LoadList(TablesLogic.tChecklist.IsChecklist == 1 &
                         TablesLogic.tChecklist.Type == ChecklistType.Survey));
    }

    protected void subpanel_SurveyTrade_ValidateAndUpdate(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        OSurveyTrade CurrentST = (OSurveyTrade)subpanel_SurveyTrade.SessionObject;

        LogicLayer.Global.ReorderItems(CurrentSP.SurveyTrades, CurrentST, "DisplayOrder");
    }

    protected void subpanel_SurveyTrade_Removed(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        LogicLayer.Global.ReorderItems(CurrentSP.SurveyTrades, null, "DisplayOrder");
    }

    protected void ChecklistID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyTrade CurrentST = (OSurveyTrade)subpanel_SurveyTrade.SessionObject;
        subpanel_SurveyTrade.ObjectPanel.BindControlsToObject(CurrentST);
    }

    protected void SurveyGroupID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyTrade CurrentST = (OSurveyTrade)subpanel_SurveyTrade.SessionObject;
        CurrentST.Checklist = null;
        if (SurveyGroupID.SelectedValue != "")
        {
            OSurveyGroup surveyGroup = TablesLogic.tSurveyGroup.Load(new Guid(SurveyGroupID.SelectedValue));
            if (surveyGroup != null)
                CurrentST.ChecklistID = surveyGroup.DefaultSurveyChecklistID;
        }
        subpanel_SurveyTrade.ObjectPanel.BindControlsToObject(CurrentST);
    }

    protected void btn_SetupSurvey_Click(object sender, EventArgs e)
    {
        try
        {
            panel.Message = "";
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(CurrentSP);
            CurrentSP.SetupSurveys();

            panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
        catch (Exception ex)
        {
            panel.Message = ex.Message;
        }
    }

    protected void btn_ClearSurvey_Click(object sender, EventArgs e)
    {
        try
        {
            panel.Message = "";
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(CurrentSP);
            CurrentSP.Surveys.Clear();
            GV_SurveyLocation.Bind(new List<OSurvey>());
            GV_SurveyContract.Bind(new List<OSurvey>());
            panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
        catch (Exception ex)
        {
            panel.Message = ex.Message;
        }
    }


    protected ArrayList AL = new ArrayList();
    protected int SLCounter = 0;
    protected int SCCounter = 0;

    protected void GV_SurveyLocation_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OSurvey S = (OSurvey)CurrentSP.Surveys.FindObject((Guid)GV_SurveyLocation.DataKeys[e.Row.RowIndex][0]);
            if (S != null)
                AL.Add(S);
        }
    }

    protected void SubGV_SurveyLocationResponseTos_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HyperLink hl_ChecklistForm = (HyperLink)e.Row.FindControl("hl_ChecklistForm");
            Guid id = (Guid)((GridView)sender).DataKeys[e.Row.RowIndex][0];
            OSurvey CurrentS = null;
            OSurveyResponseTo CurrentSRT = null;
            foreach (object O in AL)
            {
                OSurvey S = (OSurvey)O;
                CurrentSRT = (OSurveyResponseTo)S.SurveyResponseTos.FindObject(id);
                if (CurrentSRT != null)
                {
                    CurrentS = S;
                    break;
                }
            }

            if (hl_ChecklistForm != null && CurrentSRT != null)
            {
                hl_ChecklistForm.Text = CurrentSRT.Checklist.ObjectName;
                hl_ChecklistForm.NavigateUrl = Request.ApplicationPath + "/modules/surveyplanner/checklistformpreview.aspx?CLID=" +
                    HttpUtility.UrlEncode(Security.EncryptGuid(CurrentSRT.ChecklistID.Value)) + "&CID=" +
                    HttpUtility.UrlEncode(Security.EncryptGuid((CurrentSRT.ContractID == null ? Guid.Empty : CurrentSRT.ContractID.Value))) + "&CM=" +
                    HttpUtility.UrlEncode(Security.Encrypt((CurrentSRT.ContractMandatory == null ? "0" : CurrentSRT.ContractMandatory.Value.ToString()))) + "&EPN=" +
                    HttpUtility.UrlEncode(Security.Encrypt(CurrentSRT.EvaluatedPartyName == null ? "" : CurrentSRT.EvaluatedPartyName)) + "&CGID=" +
                    HttpUtility.UrlEncode(Security.EncryptGuid((CurrentSRT.SurveyTrade == null ? CurrentSRT.SurveyTrade.SurveyGroupID.Value : CurrentSRT.SurveyTrade.SurveyGroupID.Value)))
                    ;
                hl_ChecklistForm.Target = "AnacleEAM_ChecklistFormPreview";
            }
        }
    }


    protected void SubGV_SurveyLocationResponseFroms_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        try
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HyperLink hl_SurveyForm = (HyperLink)e.Row.FindControl("hl_SurveyForm");
                Guid id = (Guid)((GridView)sender).DataKeys[e.Row.RowIndex][0];
                OSurvey CurrentS = null;
                OSurveyResponseFrom CurrentSRF = null;
                hl_SurveyForm.Text = "Preview Survey Form";
                foreach (object O in AL)
                {
                    OSurvey S = (OSurvey)O;
                    CurrentSRF = (OSurveyResponseFrom)S.SurveyResponseFroms.FindObject(id);
                    if (CurrentSRF != null)
                    {
                        CurrentS = S;
                        break;
                    }
                }

                List<OSurveyResponseTo> list = CurrentS.SurveyResponseTos.Order(TablesLogic.tSurveyResponseTo.DisplayOrder.Asc);

                if (list != null && hl_SurveyForm != null)
                {
                    Session[CurrentS.ObjectID.Value.ToString()] = list;

                    hl_SurveyForm.NavigateUrl = Request.ApplicationPath + "/modules/surveyplanner/surveyformpreview.aspx?SID=" +
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentS.ObjectID.Value)) + "&SRFID=" +
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentSRF.ObjectID.Value))
                        ;
                    hl_SurveyForm.Target = "AnacleEAM_SurveyFormPreview";
                }


                HyperLink hl_ActualSurveyForm = (HyperLink)e.Row.FindControl("hl_ActualSurveyForm");
                OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
                if (hl_ActualSurveyForm != null && CurrentSP.IsNew == false && CurrentSP.CurrentActivity.ObjectName != "SURVEYPLANNER_SAVED" &&
                    CurrentSP.CurrentActivity.ObjectName != "SURVEYPLANNER_CANCELLED")
                {
                    hl_ActualSurveyForm.Text = "Load Survey Form";
                    hl_ActualSurveyForm.NavigateUrl = OSurveyPlanner.GenerateSurveyFormURL(CurrentSP.ObjectID.Value, CurrentSRF.SurveyRespondent.SurveyRespondentPortfolioID.Value, CurrentSRF.EmailAddress, false);//201109
                    hl_ActualSurveyForm.Target = "AnacleEAM_SurveyFormLoad";
                }
            }
        }
        catch (Exception ex)
        {
        }
    }

    protected void GV_SurveyContract_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OSurvey S = (OSurvey)CurrentSP.Surveys.FindObject((Guid)GV_SurveyLocation.DataKeys[e.Row.RowIndex][0]);
            if (S != null)
                AL.Add(S);
        }
    }

    protected void SubGV_SurveyContractResponseFroms_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        try
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HyperLink hl_SurveyForm = (HyperLink)e.Row.FindControl("hl_SurveyForm");
                Guid id = (Guid)((GridView)sender).DataKeys[e.Row.RowIndex][0];
                OSurvey CurrentS = null;
                OSurveyResponseFrom CurrentSRF = null;
                hl_SurveyForm.Text = "Preview Survey Form";
                foreach (object O in AL)
                {
                    OSurvey S = (OSurvey)O;
                    CurrentSRF = (OSurveyResponseFrom)S.SurveyResponseFroms.FindObject(id);
                    if (CurrentSRF != null)
                    {
                        CurrentS = S;
                        break;
                    }
                }

                List<OSurveyResponseTo> list = CurrentS.SurveyResponseTos.Order(TablesLogic.tSurveyResponseTo.DisplayOrder.Asc);

                if (list != null && hl_SurveyForm != null)
                {
                    Session[CurrentS.ObjectID.Value.ToString()] = list;

                    hl_SurveyForm.NavigateUrl = Request.ApplicationPath + "/modules/surveyplanner/surveyformpreview.aspx?SID=" +
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentS.ObjectID.Value)) + "&SRFID=" +
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentSRF.ObjectID.Value))
                        ;
                    hl_SurveyForm.Target = "AnacleEAM_SurveyFormPreview";
                }


                HyperLink hl_ActualSurveyForm = (HyperLink)e.Row.FindControl("hl_ActualSurveyForm");
                OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
                if (hl_ActualSurveyForm != null && CurrentSP.IsNew == false && CurrentSP.CurrentActivity.ObjectName != "SURVEYPLANNER_SAVED" &&
                    CurrentSP.CurrentActivity.ObjectName != "SURVEYPLANNER_CANCELLED")
                {
                    hl_ActualSurveyForm.Text = "Load Survey Form";
                    hl_ActualSurveyForm.NavigateUrl = OSurveyPlanner.GenerateSurveyFormURL(CurrentSP.ObjectID.Value, CurrentSRF.SurveyRespondent.SurveyRespondentPortfolioID.Value, CurrentSRF.EmailAddress, false);//201109
                    hl_ActualSurveyForm.Target = "AnacleEAM_SurveyFormLoad";
                }
            }
        }
        catch (Exception ex)
        {
        }
    }

    protected void ContractID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        CurrentSP.Contracts.AddGuid(new Guid(ContractID.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void btn_GenerateContractList_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(CurrentSP);
        if (CurrentSP.PerformancePeriodFrom != null && CurrentSP.PerformancePeriodTo != null &&
            CurrentSP.PerformancePeriodFrom <= CurrentSP.PerformancePeriodTo)
            CurrentSP.GenerateContractList();
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void btn_ClearContractList_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        CurrentSP.Contracts.Clear();
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void GV_ContractAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "DeleteObject")
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            foreach (Guid id in objectIds)
                CurrentSP.Contracts.RemoveGuid(id);
            panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
    }

    protected void GV_SurveyLocation_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "ViewDetails")
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            OSurvey S = (OSurvey)CurrentSP.Surveys.FindObject(new Guid(objectIds[0].ToString()));
            string SessionKey1 = Page.Request.Path + "_SelectedSurvey";
            string SessionKey2 = Page.Request.Path + "_SurveyPlanner";
            Session[SessionKey1] = S;
            Session[SessionKey2] = CurrentSP;
            panel.FocusWindow = false;
            Window.Open(Request.ApplicationPath + "/modules/surveyplanner/surveydetails.aspx?SK1=" +
                        HttpUtility.UrlEncode(Security.Encrypt(SessionKey1)) + "&SK2=" +
                        HttpUtility.UrlEncode(Security.Encrypt(SessionKey2)), "AnacleEAM_SurveyDetails");
        }
    }

    protected void GV_SurveyContract_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "ViewDetails")
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            OSurvey S = (OSurvey)CurrentSP.Surveys.FindObject(new Guid(objectIds[0].ToString()));
            string SessionKey1 = Page.Request.Path + "_SelectedSurvey";
            string SessionKey2 = Page.Request.Path + "_SurveyPlanner";
            Session[SessionKey1] = S;
            Session[SessionKey2] = CurrentSP;
            panel.FocusWindow = false;
            Window.Open(Request.ApplicationPath + "/modules/surveyplanner/surveydetails.aspx?SK1=" +
                        HttpUtility.UrlEncode(Security.Encrypt(SessionKey1)) + "&SK2=" +
                        HttpUtility.UrlEncode(Security.Encrypt(SessionKey2)), "AnacleEAM_SurveyDetails");
        }
    }

    protected void SurveyType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(CurrentSP);
        CurrentSP.SetupSurveyTrades();
        treeIncludeLocationAccess.SelectedValue = null;
        CurrentSP.IncludeLocations.Clear();
        treeExcludeLocationAccess.SelectedValue = null;
        CurrentSP.ExcludeLocations.Clear();
        CurrentSP.Contracts.Clear();
        CurrentSP.Surveys.Clear();
        CurrentSP.NonContractedVendor = "";
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void panel_CommitTransaction(object sender, EventArgs e)
    {
        string PanelMessageType = "SAVE";
        if (Session["SP_SelectedState"] != null && Session["SP_SelectedState"].ToString() == "SURVEYPLANNER_UPDATED")
            PanelMessageType = "UPDATED";
        if (Session["SP_SelectedState"] != null && Session["SP_SelectedState"].ToString() == "SURVEYPLANNER_REMINDRESPONDENT")
            PanelMessageType = "REMINDRESPONDENT";

        if (PanelMessageType != "")
        {
            Session["SP_SelectedState"] = "";
            Response.Redirect("edit.aspx?ID=" + HttpUtility.UrlEncode(Security.Encrypt("EDIT:" + ((OSurveyPlanner)panel.SessionObject).ObjectID))
                + "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt("SURVEYPLANNER")) + "&PMT=" + HttpUtility.UrlEncode(Security.Encrypt(PanelMessageType)), true);
        }
    }

    protected void SP_SurveyReminder_ValidateAndUpdate(object sender, EventArgs e)
    {
        OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(CurrentSP);

        OSurveyReminder reminder = (OSurveyReminder)SP_SurveyReminder.SessionObject;
        SP_SurveyReminder.ObjectPanel.BindControlsToObject(reminder);

        CurrentSP.SurveyReminders.Add(reminder);
        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:object runat="server" ID="panel" Caption="Survey Planner" BaseTable="tSurveyPlanner"
            ObjectPanelID="tabObject" OnPopulateForm="panel_PopulateForm" OnPreRender="panel_PreRender"
            meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave" OnCommitTransaction="panel_CommitTransaction">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tab_Details" runat="server" CssClass="div-form" Caption="Details"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_DetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Survey Planner Name"
                        ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIPanel runat="server" ID="panel_NonUpdateableDetails_1" BeginningHtml="" BorderStyle="NotSet"
                        EndingHtml="" meta:resourcekey="panel_NonUpdateableDetails_1Resource1">
                        <ui:UIFieldDropDownList runat="server" ID="SurveyType" PropertyName="SurveyType"
                            Caption="Survey Type" Width="100%" ValidateRequiredField="True" OnSelectedIndexChanged="SurveyType_SelectedIndexChanged"
                            meta:resourcekey="SurveyTypeResource1">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1" />
                                <asp:ListItem Value="0" Text="Surveys for Services provided by Contracted Vendors"
                                    meta:resourcekey="ListItemResource2" />
                                <asp:ListItem Value="1" Text="Surveys for Services provided by Contracted Vendors evaluated by Managing Agents"
                                    meta:resourcekey="ListItemResource3" />
                                <asp:ListItem Value="2" Text="Surveys for Other Reasons" meta:resourcekey="ListItemResource4" />
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="NonContractedVendor" PropertyName="NonContractedVendor"
                            Caption="Non Contracted Vendor" meta:resourcekey="NonContractedVendorResource">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDateTime runat="server" ID="ValidityStart" PropertyName="ValidityStart"
                            Caption="Validity Start Date" Span="Half" Width="49.5%" ImageClearUrl="~/calendar/dateclr.gif"
                            ImageUrl="~/calendar/date.gif" ValidateRequiredField="True" ValidateCompareField="True"
                            ValidationCompareControl="ValidityEnd" ValidationCompareType="Date" ValidationCompareOperator="LessThanEqual"
                            meta:resourcekey="ValidityStartResource1" />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panel_UpdateableDetails" BeginningHtml="" BorderStyle="NotSet"
                        EndingHtml="" meta:resourcekey="panel_UpdateableDetailsResource1">
                        <ui:UIFieldDateTime runat="server" ID="ValidityEnd" PropertyName="ValidityEnd" Caption="Validity End Date"
                            Span="Half" Width="49.5%" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            ValidateRequiredField="True" ValidateCompareField="True" ValidationCompareControl="ValidityStart"
                            ValidationCompareType="Date" ValidationCompareOperator="GreaterThanEqual" meta:resourcekey="ValidityEndResource1" />
                        <ui:UIFieldTextBox ID="SurveyThreshold" runat="server" Caption="Survey Threshold By Percentage"
                            PropertyName="SurveyThreshold" Width="100%" ValidateDataTypeCheck="True" ValidateRequiredField="True"
                            ValidationDataType="Currency" ValidationNumberOfDecimalPlaces="2" ValidationRangeType="Currency"
                            ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="100" InternalControlWidth="95%"
                            meta:resourcekey="SurveyThresholdResource1" />
                    </ui:UIPanel>
                    <ui:UIFieldTextBox ID="Remarks" runat="server" Caption="Update Remarks" Width="100%"
                        MaxLength="255" ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="RemarksResource1" />
                    <ui:UIPanel runat="server" ID="panel_NonUpdateableDetails_2" BeginningHtml="" BorderStyle="NotSet"
                        EndingHtml="" meta:resourcekey="panel_NonUpdateableDetails_2Resource1">
                        <ui:UIPanel runat="server" ID="panel_SetupDetails_1" BeginningHtml="" BorderStyle="NotSet"
                            EndingHtml="" meta:resourcekey="panel_SetupDetails_1Resource1">
                            <ui:UIPanel runat="server" ID="panel_SetupDetails_2" BeginningHtml="" BorderStyle="NotSet"
                                EndingHtml="" meta:resourcekey="panel_SetupDetails_2Resource1">
                                <br />
                                <ui:UIFieldDateTime runat="server" ID="PerformancePeriodFrom" PropertyName="PerformancePeriodFrom"
                                    Caption="Performance Period From" Span="Half" Width="49.5%" ImageClearUrl="~/calendar/dateclr.gif"
                                    ImageUrl="~/calendar/date.gif" ValidateRequiredField="True" ValidateCompareField="True"
                                    ValidationCompareControl="PerformancePeriodTo" ValidationCompareType="Date" ValidationCompareOperator="LessThanEqual"
                                    meta:resourcekey="PerformancePeriodFromResource1" />
                                <ui:UIFieldDateTime runat="server" ID="PerformancePeriodTo" PropertyName="PerformancePeriodTo"
                                    Caption="Performance Period To" Span="Half" Width="49.5%" ImageClearUrl="~/calendar/dateclr.gif"
                                    ImageUrl="~/calendar/date.gif" ValidateRequiredField="True" ValidateCompareField="True"
                                    ValidationCompareControl="PerformancePeriodFrom" ValidationCompareType="Date"
                                    ValidationCompareOperator="GreaterThanEqual" meta:resourcekey="PerformancePeriodToResource1" />
                                <br />
                                <br />
                                <br />
                                <ui:UIGridView runat="server" ID="gridSurveyTrade" PropertyName="SurveyTrades" Caption="List Of Trade"
                                    SortExpression="DisplayOrder" ValidateRequiredField="True" AllowPaging="False"
                                    AllowSorting="False" PageSize="100" OnAction="gridSurveyTrade_Action" DataKeyNames="ObjectID"
                                    GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridSurveyTradeResource1"
                                    RowErrorColor="" Style="clear: both;">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                                    <Commands>
                                        <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete"
                                            ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif"
                                            meta:resourceKey="UIGridViewCommandResource2" />
                                        <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="AddObject" CommandText="Add"
                                            ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource3" />
                                    </Commands>
                                    <Columns>
                                        <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                            meta:resourceKey="UIGridViewColumnResource6">
                                            <ControlStyle Width="16px" />
                                            <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewButtonColumn>
                                        <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                            ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                            <ControlStyle Width="16px" />
                                            <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewButtonColumn>
                                        <cc1:UIGridViewBoundColumn DataField="DisplayOrder" HeaderText="Display Order" meta:resourcekey="UIGridViewBoundColumnResource1"
                                            PropertyName="DisplayOrder" ResourceAssemblyName="" SortExpression="DisplayOrder">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="SurveyGroup.ObjectName" HeaderText="Survey Group"
                                            meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="SurveyGroup.ObjectName"
                                            ResourceAssemblyName="" SortExpression="SurveyGroup.ObjectName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="Checklist.ObjectName" HeaderText="Checklist"
                                            meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Checklist.ObjectName"
                                            ResourceAssemblyName="" SortExpression="Checklist.ObjectName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                    </Columns>
                                    <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                                    <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                                </ui:UIGridView>
                                <ui:UIObjectPanel runat="server" ID="panel_SurveyTrade" Width="100%" BeginningHtml=""
                                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panel_SurveyTradeResource1">
                                    <web:subpanel runat="server" ID="subpanel_SurveyTrade" GridViewID="gridSurveyTrade"
                                        ObjectPanelID="panel_SurveyTrade" OnPopulateForm="subpanel_SurveyTrade_PopulateForm"
                                        OnValidateAndUpdate="subpanel_SurveyTrade_ValidateAndUpdate" OnRemoved="subpanel_SurveyTrade_Removed">
                                    </web:subpanel>
                                    <ui:UIFieldDropDownList runat="server" ID="DisplayOrder" PropertyName="DisplayOrder"
                                        Caption="DisplayOrder" Width="100%" ValidateRequiredField="True" meta:resourcekey="DisplayOrderResource1">
                                    </ui:UIFieldDropDownList>
                                    <ui:UIFieldDropDownList runat="server" ID="SurveyGroupID" PropertyName="SurveyGroupID"
                                        Caption="Contract Group" Width="100%" ValidateRequiredField="True" OnSelectedIndexChanged="SurveyGroupID_SelectedIndexChanged"
                                        meta:resourcekey="SurveyGroupIDResource1">
                                    </ui:UIFieldDropDownList>
                                    <ui:UIFieldDropDownList runat="server" ID="ChecklistID" PropertyName="ChecklistID"
                                        Caption="Checklist" Width="100%" ValidateRequiredField="True" OnSelectedIndexChanged="ChecklistID_SelectedIndexChanged"
                                        meta:resourcekey="ChecklistIDResource1">
                                    </ui:UIFieldDropDownList>
                                    <ui:UIGridView runat="server" ID="gridChecklist" Caption="Checklist" CheckBoxColumnVisible="False"
                                        PropertyName="Checklist.ChecklistItems" SortExpression="StepNumber" PageSize="1000"
                                        BindObjectsToRows="True" Width="100%" AllowPaging="False" AllowSorting="False"
                                        PagingEnabled="false" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl=""
                                        meta:resourcekey="gridChecklistResource1" RowErrorColor="" Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                                        <Columns>
                                            <cc1:UIGridViewBoundColumn DataField="StepNumber" HeaderText="Step" meta:resourcekey="UIGridViewBoundColumnResource4"
                                                PropertyName="StepNumber" ResourceAssemblyName="" SortExpression="StepNumber">
                                                <ControlStyle Width="5%" />
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource5"
                                                PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                                <ControlStyle Width="65%" />
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="ChecklistTypeString" HeaderText="Response Expected"
                                                meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="ChecklistTypeString"
                                                ResourceAssemblyName="" SortExpression="ChecklistTypeString">
                                                <ControlStyle Width="15%" />
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="ChecklistResponseSet.ObjectName" HeaderText="Response Set"
                                                meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="ChecklistResponseSet.ObjectName"
                                                ResourceAssemblyName="" SortExpression="ChecklistResponseSet.ObjectName">
                                                <ControlStyle Width="15%" />
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                                    </ui:UIGridView>
                                </ui:UIObjectPanel>
                                <br />
                                <br />
                                <ui:UIPanel runat="server" ID="panel_Locations" BeginningHtml="" BorderStyle="NotSet"
                                    EndingHtml="" meta:resourcekey="panel_LocationsResource1">
                                    <ui:UIFieldTreeList runat="server" ID="treeIncludeLocationAccess" Caption="Location To Be Included"
                                        OnSelectedNodeChanged="treeIncludeLocationAccess_SelectedNodeChanged" OnAcquireTreePopulater="treeIncludeLocationAccess_AcquireTreePopulater"
                                        Width="100%" meta:resourcekey="treeIncludeLocationAccessResource1" ShowCheckBoxes="None"
                                        TreeValueMode="SelectedNode" />
                                    <ui:UIGridView runat="server" ID="gridIncludeLocationAccess" PropertyName="IncludeLocations"
                                        CheckBoxColumnVisible="False" AllowPaging="False" AllowSorting="False" PageSize="100"
                                        Caption="List Of Location To Be Included" ValidateRequiredField="True" OnAction="gridIncludeLocationAccess_Action"
                                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridIncludeLocationAccessResource1"
                                        RowErrorColor="" Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to exclude this item?"
                                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                                <ControlStyle Width="16px" />
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Location Path" meta:resourcekey="UIGridViewBoundColumnResource8"
                                                PropertyName="Path" ResourceAssemblyName="" SortExpression="Path">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                                    </ui:UIGridView>
                                    <ui:UIFieldTreeList runat="server" ID="treeExcludeLocationAccess" Caption="Location To Be Excluded"
                                        OnAcquireTreePopulater="treeExcludeLocationAccess_AcquireTreePopulater" meta:resourcekey="treeExcludeLocationAccessResource1"
                                        ShowCheckBoxes="None" TreeValueMode="SelectedNode" Width="100%" OnSelectedNodeChanged="treeExcludeLocationAccess_SelectedNodeChanged" />
                                    <ui:UIGridView runat="server" ID="gridExcludeLocationAccess" PropertyName="ExcludeLocations"
                                        CheckBoxColumnVisible="False" AllowPaging="False" AllowSorting="False" PageSize="100"
                                        Caption="List Of Location To Be Excluded" OnAction="gridExcludeLocationAccess_Action"
                                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridExcludeLocationAccessResource1"
                                        RowErrorColor="" Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ConfirmText="Are you sure you wish to exclude this item?"
                                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                                <ControlStyle Width="16px" />
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Location Path" meta:resourcekey="UIGridViewBoundColumnResource9"
                                                PropertyName="Path" ResourceAssemblyName="" SortExpression="Path">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                                    </ui:UIGridView>
                                </ui:UIPanel>
                                <br />
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panel_ContractButton" BeginningHtml="" BorderStyle="NotSet"
                                EndingHtml="" meta:resourcekey="panel_ContractButtonResource1">
                                <ui:UIButton runat="server" Text="Generate Contract List" ID="btn_GenerateContractList"
                                    ImageUrl="~/images/tick.gif" OnClick="btn_GenerateContractList_Click" meta:resourcekey="btn_GenerateContractListResource1" />
                                <ui:UIButton runat="server" Text="Clear Contract List" ID="btn_ClearContractList"
                                    ImageUrl="~/images/delete.gif" OnClick="btn_ClearContractList_Click" meta:resourcekey="btn_ClearContractListResource1" />
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panel_Contracts" BeginningHtml="" BorderStyle="NotSet"
                                EndingHtml="" meta:resourcekey="panel_ContractsResource1">
                                <ui:UIFieldDropDownList runat="server" ID="ContractID" Caption="Contract" Visible="False"
                                    OnSelectedIndexChanged="ContractID_SelectedIndexChanged" meta:resourcekey="ContractIDResource1"
                                    Width="100%">
                                </ui:UIFieldDropDownList>
                                <ui:UIGridView runat="server" ID="GV_ContractAccess" PropertyName="Contracts" Caption="List Of Accessible Contract"
                                    AllowPaging="False" AllowSorting="False" PageSize="100" ValidateRequiredField="True"
                                    OnAction="GV_ContractAccess_Action" DataKeyNames="ObjectID" GridLines="Both"
                                    ImageRowErrorUrl="" meta:resourcekey="GV_ContractAccessResource1" RowErrorColor=""
                                    Style="clear: both;">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                                    <Commands>
                                        <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete"
                                            ConfirmText="Are you sure you wish to exclude the selected items?" ImageUrl="~/images/delete.gif"
                                            meta:resourcekey="UIGridViewCommandResource1" />
                                    </Commands>
                                    <Columns>
                                        <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to exclude this item?"
                                            ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                            <ControlStyle Width="16px" />
                                            <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewButtonColumn>
                                        <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Contract Name" meta:resourcekey="UIGridViewBoundColumnResource10"
                                            PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="Vendor.ObjectName" HeaderText="Vendor" meta:resourcekey="UIGridViewBoundColumnResource11"
                                            PropertyName="Vendor.ObjectName" ResourceAssemblyName="" SortExpression="Vendor.ObjectName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                    </Columns>
                                    <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                                    <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                                </ui:UIGridView>
                            </ui:UIPanel>
                        </ui:UIPanel>
                        <br />
                        <br />
                        <ui:UIFieldTextBox ID="SurveyFormTitle1" runat="server" Caption="Survey Form Title 1"
                            PropertyName="SurveyFormTitle1" MaxLength="255" ValidateRequiredField="True"
                            InternalControlWidth="95%" meta:resourcekey="SurveyFormTitle1Resource1" Width="100%" />
                        <ui:UIFieldTextBox ID="SurveyFormTitle2" runat="server" Caption="Survey Form Title 2"
                            PropertyName="SurveyFormTitle2" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="SurveyFormTitle2Resource1"
                            Width="100%" />
                        <ui:UIFieldTextBox ID="SurveyFormDescription" runat="server" Caption="Survey Form Description"
                            PropertyName="SurveyFormDescription" Rows="3" TextMode="MultiLine" MaxLength="500"
                            InternalControlWidth="95%" meta:resourcekey="SurveyFormDescriptionResource1"
                            Width="100%" />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tab_Survey" Caption="Survey" CssClass="div-form"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_SurveyResource1">
                    <ui:UIPanel runat="server" ID="panel_SetupSurvey" BeginningHtml="" BorderStyle="NotSet"
                        EndingHtml="" meta:resourcekey="panel_SetupSurveyResource1">
                        <ui:UIButton runat="server" Text="Setup Survey" ID="btn_SetupSurvey" ImageUrl="~/images/tick.gif"
                            OnClick="btn_SetupSurvey_Click" meta:resourcekey="btn_SetupSurveyResource1" />
                        <ui:UIButton runat="server" Text="Clear Survey" ID="btn_ClearSurvey" ImageUrl="~/images/delete.gif"
                            OnClick="btn_ClearSurvey_Click" meta:resourcekey="btn_ClearSurveyResource1" />
                        <br />
                        <br />
                    </ui:UIPanel>
                    <ui:UIGridView runat="server" ID="GV_SurveyLocation" PropertyName="Surveys" PageSize="1000"
                        CheckBoxColumnVisible="False" BindObjectsToRows="True" AllowPaging="False" SortExpression="Location.LocationType.ObjectName,Location.Path"
                        Caption="List Of Survey Location" OnAction="GV_SurveyLocation_Action" DataKeyNames="ObjectID"
                        GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="GV_SurveyLocationResource1"
                        RowErrorColor="" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewDetails" ImageUrl="~/images/view.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource5">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.LocationType.ObjectName" HeaderText="Location Type"
                                meta:resourcekey="UIGridViewBoundColumnResource12" PropertyName="Location.LocationType.ObjectName"
                                ResourceAssemblyName="" SortExpression="Location.LocationType.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location Path" meta:resourcekey="UIGridViewBoundColumnResource13"
                                PropertyName="Location.Path" ResourceAssemblyName="" SortExpression="Location.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.ObjectName" HeaderText="Location Name"
                                meta:resourcekey="UIGridViewBoundColumnResource14" PropertyName="Location.ObjectName"
                                ResourceAssemblyName="" SortExpression="Location.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyResponseFroms.Count" HeaderText="Total No. Of Respondent"
                                meta:resourcekey="UIGridViewBoundColumnResource15" PropertyName="SurveyResponseFroms.Count"
                                ResourceAssemblyName="" SortExpression="SurveyResponseFroms.Count">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyResponseTos.Count" HeaderText="Total No. Of Evaluated Party"
                                meta:resourcekey="UIGridViewBoundColumnResource16" PropertyName="SurveyResponseTos.Count"
                                ResourceAssemblyName="" SortExpression="SurveyResponseTos.Count">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Respondent Details" meta:resourcekey="UIGridViewTemplateColumnResource3"
                                Visible="False">
                                <ItemTemplate>
                                    <cc1:UIGridView ID="SubGV_SurveyLocationResponseFroms" runat="server" AllowPaging="False"
                                        AllowSorting="False" CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both"
                                        ImageRowErrorUrl="" meta:resourcekey="SubGV_SurveyLocationResponseFromsResource1"
                                        RowErrorColor="" Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewTemplateColumn HeaderText="Actual Survey Form" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                                <ItemTemplate>
                                                    <asp:HyperLink ID="hl_ActualSurveyForm" runat="server" meta:resourcekey="hl_ActualSurveyFormResource1"></asp:HyperLink>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewTemplateColumn>
                                            <cc1:UIGridViewTemplateColumn HeaderText="Survey Form" meta:resourcekey="UIGridViewTemplateColumnResource2">
                                                <ItemTemplate>
                                                    <asp:HyperLink ID="hl_SurveyForm" runat="server" meta:resourcekey="hl_SurveyFormResource1"></asp:HyperLink>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewTemplateColumn>
                                            <cc1:UIGridViewBoundColumn DataField="SurveyRespondentPortfolio.TypeText" HeaderText="Portfolio Type"
                                                meta:resourcekey="UIGridViewBoundColumnResource17" PropertyName="SurveyRespondentPortfolio.TypeText"
                                                ResourceAssemblyName="" SortExpression="SurveyRespondentPortfolio.TypeText">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="SurveyRespondentPortfolio.SurveyRespondent.ObjectName"
                                                HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource18" PropertyName="SurveyRespondentPortfolio.SurveyRespondent.ObjectName"
                                                ResourceAssemblyName="" SortExpression="SurveyRespondentPortfolio.SurveyRespondent.ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="EmailAddress" HeaderText="Email" meta:resourcekey="UIGridViewBoundColumnResource19"
                                                PropertyName="EmailAddress" ResourceAssemblyName="" SortExpression="EmailAddress">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="SurveyRespondent.SurveyRespondentPortfolioID"
                                                HeaderText="SRPID" meta:resourcekey="UIGridViewBoundColumnResource20" PropertyName="SurveyRespondent.SurveyRespondentPortfolioID"
                                                ResourceAssemblyName="" SortExpression="SurveyRespondent.SurveyRespondentPortfolioID">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </cc1:UIGridView>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Contract Details" meta:resourcekey="UIGridViewTemplateColumnResource5"
                                Visible="False">
                                <ItemTemplate>
                                    <cc1:UIGridView ID="SubGV_SurveyLocationResponseTos" runat="server" AllowPaging="False"
                                        AllowSorting="False" CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both"
                                        ImageRowErrorUrl="" meta:resourcekey="SubGV_SurveyLocationResponseTosResource1"
                                        RowErrorColor="" SortExpression="DisplayOrder ASC, Contract.ContractStartDate ASC"
                                        Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewBoundColumn DataField="DisplayOrder" HeaderText="Display Order" meta:resourcekey="UIGridViewBoundColumnResource21"
                                                PropertyName="DisplayOrder" ResourceAssemblyName="" SortExpression="DisplayOrder">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="SurveyTrade.SurveyGroup.ObjectName" HeaderText="Trade"
                                                meta:resourcekey="UIGridViewBoundColumnResource22" PropertyName="SurveyTrade.SurveyGroup.ObjectName"
                                                ResourceAssemblyName="" SortExpression="SurveyTrade.SurveyGroup.ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewTemplateColumn HeaderText="Checklist" meta:resourcekey="UIGridViewTemplateColumnResource4">
                                                <ItemTemplate>
                                                    <asp:HyperLink ID="hl_ChecklistForm" runat="server" meta:resourcekey="hl_ChecklistFormResource1"></asp:HyperLink>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewTemplateColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Contract.ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource23"
                                                PropertyName="Contract.ObjectName" ResourceAssemblyName="" SortExpression="Contract.ObjectName"
                                                Visible="False">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="EvaluatedParty" HeaderText="Vendor" meta:resourcekey="UIGridViewBoundColumnResource24"
                                                PropertyName="EvaluatedParty" ResourceAssemblyName="" SortExpression="EvaluatedParty">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Contract.ContractStartDate" DataFormatString="{0:dd-MMM-yyyy}"
                                                HeaderText="Start Date" meta:resourcekey="UIGridViewBoundColumnResource25" PropertyName="Contract.ContractStartDate"
                                                ResourceAssemblyName="" SortExpression="Contract.ContractStartDate">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Contract.ContractEndDate" DataFormatString="{0:dd-MMM-yyyy}"
                                                HeaderText="End Date" meta:resourcekey="UIGridViewBoundColumnResource26" PropertyName="Contract.ContractEndDate"
                                                ResourceAssemblyName="" SortExpression="Contract.ContractEndDate">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </cc1:UIGridView>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                    </ui:UIGridView>
                    <ui:UIGridView runat="server" ID="GV_SurveyContract" PropertyName="Surveys" PageSize="1000"
                        CheckBoxColumnVisible="False" BindObjectsToRows="True" AllowPaging="False" SortExpression="SurveyGroup.ObjectName, EvaluatedParty"
                        Caption="List Of Survey Contract" OnAction="GV_SurveyContract_Action" DataKeyNames="ObjectID"
                        GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="GV_SurveyContractResource1"
                        RowErrorColor="" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewDetails" ImageUrl="~/images/view.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource6">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyGroup.ObjectName" HeaderText="Survey Group"
                                meta:resourcekey="UIGridViewBoundColumnResource27" PropertyName="SurveyGroup.ObjectName"
                                ResourceAssemblyName="" SortExpression="SurveyGroup.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Contract.ObjectName" HeaderText="Contract Name"
                                meta:resourcekey="UIGridViewBoundColumnResource28" PropertyName="Contract.ObjectName"
                                ResourceAssemblyName="" SortExpression="Contract.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EvaluatedParty" HeaderText="Vendor" meta:resourcekey="UIGridViewBoundColumnResource29"
                                PropertyName="EvaluatedParty" ResourceAssemblyName="" SortExpression="EvaluatedParty">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyResponseFroms.Count" HeaderText="Total No. Of Respondent"
                                meta:resourcekey="UIGridViewBoundColumnResource30" PropertyName="SurveyResponseFroms.Count"
                                ResourceAssemblyName="" SortExpression="SurveyResponseFroms.Count">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Respondent Details" meta:resourcekey="UIGridViewTemplateColumnResource8"
                                Visible="False">
                                <ItemTemplate>
                                    <cc1:UIGridView ID="SubGV_SurveyContractResponseFroms" runat="server" AllowPaging="False"
                                        AllowSorting="False" CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both"
                                        ImageRowErrorUrl="" meta:resourcekey="SubGV_SurveyContractResponseFromsResource1"
                                        RowErrorColor="" SkinID="ShortGridView" Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewTemplateColumn HeaderText="Actual Survey Form" meta:resourcekey="UIGridViewTemplateColumnResource6">
                                                <ItemTemplate>
                                                    <asp:HyperLink ID="hl_ActualSurveyForm" runat="server" meta:resourcekey="hl_ActualSurveyFormResource2"></asp:HyperLink>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewTemplateColumn>
                                            <cc1:UIGridViewTemplateColumn HeaderText="Survey Form" meta:resourcekey="UIGridViewTemplateColumnResource7">
                                                <ItemTemplate>
                                                    <asp:HyperLink ID="hl_SurveyForm" runat="server" meta:resourcekey="hl_SurveyFormResource2"></asp:HyperLink>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewTemplateColumn>
                                            <cc1:UIGridViewBoundColumn DataField="SurveyRespondentPortfolio.TypeText" HeaderText="Portfolio Type"
                                                meta:resourcekey="UIGridViewBoundColumnResource31" PropertyName="SurveyRespondentPortfolio.TypeText"
                                                ResourceAssemblyName="" SortExpression="SurveyRespondentPortfolio.TypeText">
                                                <ControlStyle Width="20%" />
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="SurveyRespondentPortfolio.SurveyRespondent.ObjectName"
                                                HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource32" PropertyName="SurveyRespondentPortfolio.SurveyRespondent.ObjectName"
                                                ResourceAssemblyName="" SortExpression="SurveyRespondentPortfolio.SurveyRespondent.ObjectName">
                                                <ControlStyle Width="30%" />
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="EmailAddress" HeaderText="Email" meta:resourcekey="UIGridViewBoundColumnResource33"
                                                PropertyName="EmailAddress" ResourceAssemblyName="" SortExpression="EmailAddress">
                                                <ControlStyle Width="30%" />
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </cc1:UIGridView>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tab_Reminder" Caption="Reminder" CssClass="div-form"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_ReminderResource1">
                    <ui:UIGridView runat="server" ID="GV_SurveyReminder" PropertyName="SurveyReminders"
                        Caption="List Of Reminder" AllowPaging="False" AllowSorting="False" PageSize="100"
                        ValidateRequiredField="false" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl=""
                        meta:resourcekey="GV_SurveyReminderResource1" RowErrorColor="" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete"
                                ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif"
                                meta:resourceKey="UIGridViewCommandResource2" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="AddObject" CommandText="Add"
                                ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource3" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourceKey="UIGridViewColumnResource6">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource7">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ReminderDate" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Reminder Date" meta:resourcekey="UIGridViewBoundColumnResource34"
                                PropertyName="ReminderDate" ResourceAssemblyName="" SortExpression="ReminderDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EmailList" HeaderText="List Of Recipient To Be Notified"
                                meta:resourcekey="UIGridViewBoundColumnResource35" PropertyName="EmailList" ResourceAssemblyName=""
                                SortExpression="EmailList">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EmailSentOn" HeaderText="Email Sent On" meta:resourcekey="UIGridViewBoundColumnResource36"
                                PropertyName="EmailSentOn" ResourceAssemblyName="" SortExpression="EmailSentOn">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="OP_SurveyReminder" Width="100%" BeginningHtml=""
                        BorderStyle="NotSet" EndingHtml="" meta:resourcekey="OP_SurveyReminderResource1">
                        <web:subpanel runat="server" ID="SP_SurveyReminder" GridViewID="GV_SurveyReminder"
                            ObjectPanelID="OP_SurveyReminder" OnValidateAndUpdate="SP_SurveyReminder_ValidateAndUpdate">
                        </web:subpanel>
                        <ui:UIFieldDateTime runat="server" ID="dt_ReminderDate" PropertyName="ReminderDate"
                            Caption="Reminder Date" Width="100%" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            ValidationCompareType="Date" ValidateRequiredField="false" meta:resourcekey="dt_ReminderDateResource1" />
                        <ui:UIFieldTextBox ID="tb_EmailList" runat="server" Caption="List Of Recipient Email Address"
                            PropertyName="EmailList" Width="100%" MaxLength="255" TextMode="MultiLine" Rows="2"
                            ToolTip="Please use ; as the separator." ValidateRequiredField="false" InternalControlWidth="95%"
                            meta:resourcekey="tb_EmailListResource1" />
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tab_Progress" Caption="Progress" CssClass="div-form"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_ProgressResource1">
                    <ui:UIGridView runat="server" ID="GV_Progress" PropertyName="SurveyProgress" KeyName="contractid"
                        CheckBoxColumnVisible="False" AllowPaging="False" AllowSorting="False" PageSize="100"
                        Caption="Progress Status" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl=""
                        meta:resourcekey="GV_ProgressResource1" RowErrorColor="" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="trade" HeaderText="Trade" meta:resourcekey="UIGridViewBoundColumnResource37"
                                PropertyName="trade" ResourceAssemblyName="" SortExpression="trade">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="contractname" HeaderText="Contract" meta:resourcekey="UIGridViewBoundColumnResource38"
                                PropertyName="contractname" ResourceAssemblyName="" SortExpression="contractname">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="contractstartdate" DataFormatString="{0:dd-MM-yyyy}"
                                HeaderText="Contract Start Date" meta:resourcekey="UIGridViewBoundColumnResource39"
                                PropertyName="contractstartdate" ResourceAssemblyName="" SortExpression="contractstartdate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="contractenddate" DataFormatString="{0:dd-MM-yyyy}"
                                HeaderText="Contract End Date" meta:resourcekey="UIGridViewBoundColumnResource40"
                                PropertyName="contractenddate" ResourceAssemblyName="" SortExpression="contractenddate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="evaluatedparty" HeaderText="Evaluated Party"
                                meta:resourcekey="UIGridViewBoundColumnResource41" PropertyName="evaluatedparty"
                                ResourceAssemblyName="" SortExpression="evaluatedparty">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="totalsurvey" HeaderText="Total No. Of Expected Reply"
                                meta:resourcekey="UIGridViewBoundColumnResource42" PropertyName="totalsurvey"
                                ResourceAssemblyName="" SortExpression="totalsurvey">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="totalreply" HeaderText="Total No. Of Actual Reply"
                                meta:resourcekey="UIGridViewBoundColumnResource43" PropertyName="totalreply"
                                ResourceAssemblyName="" SortExpression="totalreply">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="percentage" DataFormatString="{0:#,##0.00}"
                                HeaderText="Response Rate (%)" meta:resourcekey="UIGridViewBoundColumnResource44"
                                PropertyName="percentage" ResourceAssemblyName="" SortExpression="percentage">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tab_History" Caption="History" CssClass="div-form"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_HistoryResource1">
                    <ui:UIGridView runat="server" ID="GV_History" PropertyName="SurveyPlannerUpdates"
                        CheckBoxColumnVisible="False" SortExpression="CreatedOn" AllowPaging="False"
                        AllowSorting="False" PageSize="100" Caption="Survey Planner History" DataKeyNames="ObjectID"
                        GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="GV_HistoryResource1" RowErrorColor=""
                        Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="PreviousSurveyThreshold" DataFormatString="{0:#,##0.00}"
                                HeaderText="Previous Survey Threshold By Percentage" meta:resourcekey="UIGridViewBoundColumnResource45"
                                PropertyName="PreviousSurveyThreshold" ResourceAssemblyName="" SortExpression="PreviousSurveyThreshold">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="NewSurveyThreshold" DataFormatString="{0:#,##0.00}"
                                HeaderText="Updated Survey Threshold By Percentage" meta:resourcekey="UIGridViewBoundColumnResource46"
                                PropertyName="NewSurveyThreshold" ResourceAssemblyName="" SortExpression="NewSurveyThreshold">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="PreviousValidityEnd" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Previous Validity End Date" meta:resourcekey="UIGridViewBoundColumnResource47"
                                PropertyName="PreviousValidityEnd" ResourceAssemblyName="" SortExpression="PreviousValidityEnd">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="NewValidityEnd" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Extended Validity End Date" meta:resourcekey="UIGridViewBoundColumnResource48"
                                PropertyName="NewValidityEnd" ResourceAssemblyName="" SortExpression="NewValidityEnd">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Remarks" HeaderText="Remarks" meta:resourcekey="UIGridViewBoundColumnResource49"
                                PropertyName="Remarks" ResourceAssemblyName="" SortExpression="Remarks">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreatedBy" HeaderText="Performed By" meta:resourcekey="UIGridViewBoundColumnResource50"
                                PropertyName="CreatedBy" ResourceAssemblyName="" SortExpression="CreatedBy">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CreatedOn" HeaderText="Performed On" meta:resourcekey="UIGridViewBoundColumnResource51"
                                PropertyName="CreatedOn" ResourceAssemblyName="" SortExpression="CreatedOn">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tab_Memo" Caption="Memo" CssClass="div-form" BeginningHtml=""
                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_MemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tab_Attachments" Caption="Attachments" CssClass="div-form"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_AttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
