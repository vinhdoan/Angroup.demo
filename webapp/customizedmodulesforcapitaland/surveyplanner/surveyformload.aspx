<%@ Page Language="C#" AutoEventWireup="true" Inherits="PageBase" Culture="auto"
    meta:resourcekey="PageResource1" UICulture="auto" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    protected void form1_OnLoad(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request["SPID"] != null && Request["SRID"] != null && Request["REA"] != null)
            {
                Guid SPID = Security.DecryptGuid(Request["SPID"]);
                OSurveyPlanner SP = TablesLogic.tSurveyPlanner.Load(SPID);
                Guid SRID = Security.DecryptGuid(Request["SRID"]);
                string RespondentEmailAddress = Security.Decrypt(Request["REA"]);

                ArrayList AL_SurveyID = Query.SelectDistinct(TablesLogic.tSurvey.ObjectID)
                    .Where(TablesLogic.tSurvey.SurveyPlannerID == SPID &
                    TablesLogic.tSurvey.SurveyResponseFroms.SurveyRespondentPortfolio.SurveyRespondentID == SRID &
                    TablesLogic.tSurvey.SurveyResponseFroms.EmailAddress == RespondentEmailAddress &
                    TablesLogic.tSurvey.IsDeleted == 0 &
                    TablesLogic.tSurvey.SurveyResponseFroms.IsDeleted == 0);

                Session["CurrentSurveyList"] = AL_SurveyID;

                if (AL_SurveyID != null && AL_SurveyID.Count > 0)
                    LoadSurveyForm((Guid)AL_SurveyID[0], SRID, RespondentEmailAddress);

            }
        }
    }

    protected void UpdateRespondentDetails()
    {
        Guid SurveyRespondentID = Security.DecryptGuid(Request["SRID"]);
        Guid SurveyID = (Guid)Session["CurrentSurveyID"];
        string RespondentEmailAddress = Security.Decrypt(Request["REA"]);

        List<OSurveyChecklistItem> ListOfSCLI = TablesLogic.tSurveyChecklistItem.LoadList(
           TablesLogic.tSurveyChecklistItem.SurveyID == SurveyID &
           TablesLogic.tSurveyChecklistItem.SurveyRespondentID == SurveyRespondentID &
           TablesLogic.tSurveyChecklistItem.SurveyRespondent.SurveyRespondentPortfolios.EmailAddress.UpperCase() == RespondentEmailAddress.ToUpper()
           ,
           TablesLogic.tSurveyChecklistItem.SurveyID.Asc,
           TablesLogic.tSurveyChecklistItem.SurveyResponseTo.DisplayOrder.Asc,
           TablesLogic.tSurveyChecklistItem.StepNumber.Asc
           );

        string name = ((OSurveyChecklistItem)ListOfSCLI[0]).FilledInRespondentName;
        string contactnumber = ((OSurveyChecklistItem)ListOfSCLI[0]).FilledInRespondentContactNumber;
        string emailaddress = ((OSurveyChecklistItem)ListOfSCLI[0]).FilledInRespondentEmailAddress;
        if (name != null && name != "")
            tb_RespondentName.Text = name;
        else
            tb_RespondentName.Text = tb_DefaultRespondentName.Text;

        if (contactnumber != null && contactnumber != "")
            tb_RespondentContactNumber.Text = contactnumber;
        else
            tb_RespondentContactNumber.Text = tb_DefaultRespondentContactNumber.Text;

        if (emailaddress != null && emailaddress != "")
            tb_RespondentEmailAddress.Text = emailaddress;
        else
            tb_RespondentEmailAddress.Text = tb_DefaultRespondentEmailAddress.Text;
    }

    protected void form1_PreRender(object sender, EventArgs e)
    {
        Guid SRID = Security.DecryptGuid(Request["SRID"]);
        ArrayList AL_SurveyID = (ArrayList)Session["CurrentSurveyList"];
        Guid CurrentSurveyID = (Guid)Session["CurrentSurveyID"];
        string RespondentEmailAddress = Security.Decrypt(Request["REA"]);

        panelDefaultRespondentDetails.Visible = (AL_SurveyID.Count > 1);

        int CurrentIndex = AL_SurveyID.IndexOf(CurrentSurveyID);
        btn_NavigatePrevious.Enabled = (CurrentIndex != 0);
        btn_NavigateNext.Enabled = (CurrentIndex != (AL_SurveyID.Count - 1));
        btn_SaveSurvey.Enabled = panelSurveyForm.Enabled;
        btn_SubmitSurvey.Enabled = panelSurveyForm.Enabled;
        panelMessage.Visible = (lbl_PageMessage.Text != "");
        lbl_CurrentIndex.Text = Convert.ToString(CurrentIndex + 1);
        lbl_IndexList.Text = " / " + Convert.ToString(AL_SurveyID.Count);

        int PendingSubmissionCount = 0;
        foreach (object O in AL_SurveyID)
        {
            List<OSurveyChecklistItem> ListOfSCLIByOthers = TablesLogic.tSurveyChecklistItem.LoadList(
                TablesLogic.tSurveyChecklistItem.SurveyID == (Guid)O &
                TablesLogic.tSurveyChecklistItem.SurveyRespondentID == SRID &
                TablesLogic.tSurveyChecklistItem.Status == SurveyStatusType.ValidWithReply
                );
            if (ListOfSCLIByOthers.Count == 0)
                PendingSubmissionCount++;
        }
        lbl_NumberOfPendingSubmission.Text = PendingSubmissionCount.ToString() + " Pending Submission";

        if (btn_SaveSurvey.Enabled || btn_SubmitSurvey.Enabled)
        {
            btn_NavigateNext.ConfirmText = btn_NavigatePrevious.ConfirmText = Resources.Messages.SurveyPlanner_SwitchSurvey;
        }
        else
        {
            btn_NavigateNext.ConfirmText = btn_NavigatePrevious.ConfirmText = "";
        }
    }

    public void LoadSurveyForm(Guid SurveyID, Guid SurveyRespondentID, string RespondentEmailAddress)
    {
        bool IsModifiable = true;
        List<OSurveyChecklistItem> ListOfSCLIByOthers = TablesLogic.tSurveyChecklistItem.LoadList(
            TablesLogic.tSurveyChecklistItem.SurveyID == SurveyID &
            TablesLogic.tSurveyChecklistItem.SurveyRespondentID == SurveyRespondentID &
            TablesLogic.tSurveyChecklistItem.Status == SurveyStatusType.ValidWithReply
            );

        List<OSurveyChecklistItem> ListOfSCLI = TablesLogic.tSurveyChecklistItem.LoadList(
            TablesLogic.tSurveyChecklistItem.SurveyID == SurveyID &
            TablesLogic.tSurveyChecklistItem.SurveyRespondentID == SurveyRespondentID &
            TablesLogic.tSurveyChecklistItem.SurveyRespondent.SurveyRespondentPortfolios.EmailAddress.UpperCase() == RespondentEmailAddress.ToUpper()
            ,
            TablesLogic.tSurveyChecklistItem.SurveyID.Asc,
            TablesLogic.tSurveyChecklistItem.SurveyResponseTo.DisplayOrder.Asc,
            TablesLogic.tSurveyChecklistItem.StepNumber.Asc
            );

        if (ListOfSCLIByOthers.Count > 0)
        {
            if (lbl_PageMessage.Text == "")
                lbl_PageMessage.Text = Resources.Strings.SurveyPlanner_NotEditable;
        }

        if (ListOfSCLI != null && ListOfSCLI.Count > 0 &&
            ((OSurveyChecklistItem)ListOfSCLI[0]).SurveyPlanner.CurrentActivity.ObjectName == "Close")
        {
            if (lbl_PageMessage.Text == "")
                lbl_PageMessage.Text = Resources.Strings.SurveyPlanner_NotEditableDueToClose;
        }

        panelSurveyForm.Enabled = (ListOfSCLIByOthers.Count == 0);
        if (ListOfSCLI != null && ListOfSCLI.Count > 0)
        {
            if (((OSurveyChecklistItem)ListOfSCLI[0]).SurveyPlanner.SurveyType == SurveyTargetType.SurveyContractedVendorEvaluatedByMA)
            {
                lbl_PremisesName.Visible = lbl_PremisesAddress.Visible = false;
                lbl_PremisesName.Text = lbl_PremisesAddress.Text = "";
            }
            else
            {
                lbl_PremisesName.Visible = lbl_PremisesAddress.Visible = true;
                OLocation L = ((OSurveyChecklistItem)ListOfSCLI[0]).Survey.Location;
                lbl_PremisesName.Text = (L == null ? "N.A." : L.ObjectName);
                lbl_PremisesAddress.Text = (L == null ? "N.A." : string.Format((L.Address == null ? "" : L.Address)).Trim());
            }

            string name = ((OSurveyChecklistItem)ListOfSCLI[0]).FilledInRespondentName;
            string contactnumber = ((OSurveyChecklistItem)ListOfSCLI[0]).FilledInRespondentContactNumber;
            string emailaddress = ((OSurveyChecklistItem)ListOfSCLI[0]).FilledInRespondentEmailAddress;
            if (name != null && name != "")
                tb_RespondentName.Text = name;
            else
                tb_RespondentName.Text = tb_DefaultRespondentName.Text;

            if (contactnumber != null && contactnumber != "")
                tb_RespondentContactNumber.Text = contactnumber;
            else
                tb_RespondentContactNumber.Text = tb_DefaultRespondentContactNumber.Text;

            if (emailaddress != null && emailaddress != "")
                tb_RespondentEmailAddress.Text = emailaddress;
            else
                tb_RespondentEmailAddress.Text = tb_DefaultRespondentEmailAddress.Text;
        }
        else
            lbl_PageMessage.Text = Resources.Errors.SurveyPlanner_UnableLoadForm;

        Hashtable ht_ChecklistResult = new Hashtable();
        DataTable dt1 = new DataTable();
        dt1.Columns.Add("SurveyID");
        dt1.Columns.Add("ChecklistID");
        dt1.Columns.Add("SurveyTradeID");
        dt1.Columns.Add("ContractID");
        dt1.Columns.Add("EvaluatedParty");
        dt1.Columns.Add("DisplayOrder");

        DataTable dt0 = new DataTable();
        dt0.Columns.Add("ObjectID");
        dt0.Columns.Add("ChecklistID");
        dt0.Columns.Add("ChecklistName");
        dt0.Columns.Add("SurveyTradeName");
        dt0.Columns.Add("EvaluatedParty");
        dt0.Columns.Add("StepNumber", typeof(int));
        dt0.Columns.Add("ObjectName");
        dt0.Columns.Add("ChecklistItemType");

        if (ListOfSCLI != null && ListOfSCLI.Count > 0)
        {
            string CurrentCLGroupKey = "";
            Guid? CurrentSurveyID = null;
            Guid? CurrentChecklistID = null;
            Guid? CurrentSurveyTradeID = null;
            Guid? CurrentContractID = null;
            string CurrentEvaluatedParty = "";
            string CurrentDisplayOrder = "";

            DataTable dt = dt0.Clone();
            foreach (OSurveyChecklistItem SCLI in ListOfSCLI)
            {
                string CLGroupKey = SCLI.SurveyID.Value.ToString() + "::" +
                    SCLI.ChecklistID.Value.ToString() + "::" +
                    SCLI.SurveyResponseTo.SurveyTradeID.Value.ToString() + "::" +
                    (SCLI.SurveyResponseTo.Contract != null ? SCLI.SurveyResponseTo.ContractID.Value : Guid.Empty) + "::" +
                    (SCLI.SurveyResponseTo.Contract != null && SCLI.SurveyResponseTo.Contract.Vendor != null ?
                        SCLI.SurveyResponseTo.Contract.Vendor.ObjectName : SCLI.SurveyResponseTo.EvaluatedPartyName) + "::" +
                    SCLI.SurveyResponseTo.DisplayOrder.Value.ToString();

                if (CurrentCLGroupKey == CLGroupKey)
                {
                    dt.Rows.Add(
                        SCLI.ObjectID,
                        SCLI.ChecklistID,
                        SCLI.Checklist.ObjectName,
                        SCLI.SurveyResponseTo.SurveyTrade.SurveyGroup.ObjectName,
                        (SCLI.SurveyResponseTo.Contract != null && SCLI.SurveyResponseTo.Contract.Vendor != null ?
                            SCLI.SurveyResponseTo.Contract.Vendor.ObjectName : SCLI.SurveyResponseTo.EvaluatedPartyName),
                        SCLI.StepNumber,
                        SCLI.ObjectName,
                        SCLI.ChecklistItemType
                        );
                }
                else
                {
                    if (dt.Rows.Count > 0)
                    {
                        dt.TableName = CurrentDisplayOrder;
                        ht_ChecklistResult.Add(CurrentCLGroupKey, dt);
                        dt1.Rows.Add(CurrentSurveyID.Value, CurrentChecklistID.Value, CurrentSurveyTradeID.Value, CurrentContractID.Value, CurrentEvaluatedParty, CurrentDisplayOrder);
                    }
                    CurrentCLGroupKey = CLGroupKey;
                    dt = dt0.Clone();
                    dt.Rows.Add(
                        SCLI.ObjectID,
                        SCLI.ChecklistID,
                        SCLI.Checklist.ObjectName,
                        SCLI.SurveyResponseTo.SurveyTrade.SurveyGroup.ObjectName,
                        (SCLI.SurveyResponseTo.Contract != null && SCLI.SurveyResponseTo.Contract.Vendor != null ?
                            SCLI.SurveyResponseTo.Contract.Vendor.ObjectName : SCLI.SurveyResponseTo.EvaluatedPartyName),
                        SCLI.StepNumber,
                        SCLI.ObjectName,
                        SCLI.ChecklistItemType
                        );
                }

                CurrentSurveyID = SCLI.SurveyID;
                CurrentChecklistID = SCLI.ChecklistID;
                CurrentSurveyTradeID = SCLI.SurveyResponseTo.SurveyTradeID;
                CurrentContractID = (SCLI.SurveyResponseTo.Contract != null ? SCLI.SurveyResponseTo.ContractID.Value : Guid.Empty);
                CurrentEvaluatedParty = (SCLI.SurveyResponseTo.Contract != null && SCLI.SurveyResponseTo.Contract.Vendor != null ?
                    SCLI.SurveyResponseTo.Contract.Vendor.ObjectName : SCLI.SurveyResponseTo.EvaluatedPartyName);
                CurrentDisplayOrder = SCLI.SurveyResponseTo.DisplayOrder.Value.ToString();
            }
            if (dt.Rows.Count > 0)
            {
                dt.TableName = CurrentDisplayOrder;
                ht_ChecklistResult.Add(CurrentCLGroupKey, dt);
                dt1.Rows.Add(CurrentSurveyID.Value, CurrentChecklistID.Value, CurrentSurveyTradeID.Value, CurrentContractID.Value, CurrentEvaluatedParty, CurrentDisplayOrder);
            }

            Session["CurrentSurveyID"] = CurrentSurveyID.Value;
            Session["ChecklistResult"] = ht_ChecklistResult;
            GridResult.DataSource = dt1;
            GridResult.DataBind();
        }
        Session["ChecklistResult"] = null;
    }




    //---------------------------------------------------------------   
    // event
    //---------------------------------------------------------------
    protected void gridChecklist_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
            Guid id = new Guid(((GridView)sender).DataKeys[e.Row.RowIndex][0].ToString());
            OChecklist CL = TablesLogic.tChecklist[new Guid(((DataRowView)e.Row.DataItem)["ChecklistID"].ToString())];
            OSurveyChecklistItem SCLI = TablesLogic.tSurveyChecklistItem.Load(id);

            OChecklistItem item = null;
            foreach (OChecklistItem CLI in CL.ChecklistItems)
            {
                if (CLI.ObjectName == SCLI.ObjectName && CLI.ChecklistType == SCLI.ChecklistItemType)
                {
                    item = CLI;
                    break;
                }
            }

            if (item != null)
            {
                UIFieldLabel l = (UIFieldLabel)e.Row.FindControl("HiddenID");
                if (l != null)
                    l.Text = SCLI.ObjectID.Value.ToString();

                if (SCLI.ChecklistItemType == ChecklistItemType.MultipleSelections)
                {
                    UIFieldCheckboxList cbl = (UIFieldCheckboxList)e.Row.FindControl("ChecklistItem_MS_SelectedResponseID");
                    if (cbl != null)
                    {
                        cbl.Visible = true;
                        cbl.Bind(item.ChecklistResponseSet.ChecklistResponses.Order(
                            TablesLogic.tChecklistResponse.DisplayOrder.Asc));

                        cbl.ValidateRequiredField = (SCLI.IsMandatoryField == 1);

                        foreach (OChecklistResponse CR in SCLI.SelectedResponses)
                        {
                            foreach (ListItem LI in cbl.Items)
                            {
                                if (LI.Value == CR.ObjectID.Value.ToString())
                                {
                                    LI.Selected = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                else if (SCLI.ChecklistItemType == ChecklistItemType.Choice)
                {
                    UIFieldRadioList rl = (UIFieldRadioList)e.Row.FindControl("ChecklistItem_C_SelectedResponseID");
                    if (rl != null)
                    {
                        rl.Visible = true;
                        rl.Bind(item.ChecklistResponseSet.ChecklistResponses.Order(
                            TablesLogic.tChecklistResponse.DisplayOrder.Asc));
                        rl.ValidateRequiredField = (SCLI.IsMandatoryField == 1);

                        foreach (OChecklistResponse CR in SCLI.SelectedResponses)
                        {
                            foreach (ListItem LI in rl.Items)
                            {
                                if (LI.Value == CR.ObjectID.Value.ToString())
                                {
                                    LI.Selected = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                else if (SCLI.ChecklistItemType == ChecklistItemType.Remarks)
                {
                    UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("tb_Remarks");
                    if (t != null)
                    {
                        t.Visible = true;
                        t.Text = SCLI.Description;
                        t.ValidateRequiredField = (SCLI.IsMandatoryField == 1);
                    }
                }
                else if (SCLI.ChecklistItemType == ChecklistItemType.SingleLineFreeText)
                {
                    UIFieldTextBox tb = (UIFieldTextBox)e.Row.FindControl("tb_SingleLineFreeText");
                    if (tb != null)
                    {
                        tb.Visible = true;
                        tb.Text = SCLI.Description;
                        tb.ValidateRequiredField = (SCLI.IsMandatoryField == 1);
                    }
                }
            }
        }
    }

    protected void GridResult_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            string SurveyID = ((DataRowView)e.Item.DataItem)["SurveyID"].ToString();
            string ChecklistID = ((DataRowView)e.Item.DataItem)["ChecklistID"].ToString();
            string SurveyTradeID = ((DataRowView)e.Item.DataItem)["SurveyTradeID"].ToString();
            string ContractID = ((DataRowView)e.Item.DataItem)["ContractID"].ToString();
            string EvaluatedParty = ((DataRowView)e.Item.DataItem)["EvaluatedParty"].ToString();
            string DisplayOrder = ((DataRowView)e.Item.DataItem)["DisplayOrder"].ToString();

            Hashtable ht_Checklist = (Hashtable)Session["ChecklistResult"];
            DataTable dt = (DataTable)ht_Checklist[SurveyID + "::" + ChecklistID + "::" + SurveyTradeID + "::" + ContractID + "::" + EvaluatedParty + "::" + DisplayOrder];

            ((UIFieldLabel)e.Item.FindControl("lbl_ChecklistName")).Text = (dt != null && dt.Rows.Count > 0 ? dt.Rows[0]["ChecklistName"].ToString() : "");
            ((UIFieldLabel)e.Item.FindControl("lbl_SurveyTradeName")).Text = (dt != null && dt.Rows.Count > 0 ? dt.Rows[0]["SurveyTradeName"].ToString() : "");
            ((UIFieldLabel)e.Item.FindControl("lbl_VendorName")).Text = EvaluatedParty;
            if (dt != null)
            {
                ((UIGridView)e.Item.FindControl("gridChecklist")).Bind(dt);
            }
        }
    }

    protected void btn_SaveSurvey_Click(object sender, EventArgs e)
    {
        lbl_PageMessage.Text = SaveSurvey();
        LoadSurveyForm((Guid)Session["CurrentSurveyID"], Security.DecryptGuid(Request["SRID"]), Security.Decrypt(Request["REA"]));
        form1_PreRender(sender, e);
    }

    protected string SaveSurvey()
    {
        string Message = Resources.Strings.SurveyPlanner_SurveySaved;
        using (Connection c = new Connection())
        {
            try
            {
                foreach (DataListItem DLI in GridResult.Items)
                {
                    UIGridView GV_CheckList = (UIGridView)DLI.FindControl("gridChecklist");
                    if (GV_CheckList != null)
                    {
                        foreach (GridViewRow GVR in GV_CheckList.Rows)
                        {
                            if (GVR.RowType == DataControlRowType.DataRow)
                            {
                                UIFieldLabel l = (UIFieldLabel)GVR.FindControl("HiddenID");
                                Guid SurveyChecklistItemID = new Guid(l.Text);
                                OSurveyChecklistItem DB_SCLI = TablesLogic.tSurveyChecklistItem.Load(SurveyChecklistItemID);

                                if (DB_SCLI == null)
                                    throw new Exception("Survey checklist item not found!");

                                int SurveyChecklistItemType = DB_SCLI.ChecklistItemType.Value;

                                if (SurveyChecklistItemType == ChecklistItemType.MultipleSelections)
                                {
                                    UIFieldCheckboxList cbl = (UIFieldCheckboxList)GVR.FindControl("ChecklistItem_MS_SelectedResponseID");
                                    if (cbl != null)
                                    {
                                        DB_SCLI.SelectedResponses.Clear();
                                        foreach (ListItem LI in cbl.Items)
                                        {
                                            if (LI.Selected == true)
                                                DB_SCLI.SelectedResponses.AddGuid(new Guid(LI.Value.ToString()));
                                        }
                                    }
                                }
                                else if (SurveyChecklistItemType == ChecklistItemType.Choice)
                                {
                                    UIFieldRadioList rl = (UIFieldRadioList)GVR.FindControl("ChecklistItem_C_SelectedResponseID");
                                    if (rl != null)
                                    {
                                        DB_SCLI.SelectedResponses.Clear();
                                        foreach (ListItem LI in rl.Items)
                                        {
                                            if (LI.Selected == true)
                                                DB_SCLI.SelectedResponses.AddGuid(new Guid(LI.Value.ToString()));
                                        }
                                    }
                                }
                                else if (SurveyChecklistItemType == ChecklistItemType.Remarks)
                                {
                                    UIFieldTextBox t = (UIFieldTextBox)GVR.FindControl("tb_Remarks");
                                    if (t != null)
                                    {
                                        DB_SCLI.Description = t.Text;
                                    }
                                }
                                else if (SurveyChecklistItemType == ChecklistItemType.SingleLineFreeText)
                                {
                                    UIFieldTextBox tb = (UIFieldTextBox)GVR.FindControl("tb_SingleLineFreeText");
                                    if (tb != null)
                                    {
                                        DB_SCLI.Description = tb.Text;
                                    }
                                }

                                DB_SCLI.FilledInRespondentName = tb_RespondentName.Text.Trim();
                                DB_SCLI.FilledInRespondentContactNumber = tb_RespondentContactNumber.Text.Trim();
                                DB_SCLI.FilledInRespondentEmailAddress = tb_RespondentEmailAddress.Text.Trim();

                                DB_SCLI.Save();
                            }
                        }
                    }
                }
                c.Commit();
            }
            catch (Exception ex)
            {
                Message = ex.Message + "<br>" + ex.StackTrace;
            }
        }
        return Message;
    }

    protected string ValidateSurveySubmission()
    {
        string Message = "";

        return Message;
    }

    protected string SubmitSurvey()
    {
        string Message = Resources.Strings.SurveyPlanner_SurveySubmitted;
        using (Connection c = new Connection())
        {
            try
            {
                Guid? SRFID = Query.Select(TablesLogic.tSurveyResponseFrom.ObjectID)
                .Where(
                    TablesLogic.tSurveyResponseFrom.SurveyPlannerID == Security.DecryptGuid(Request["SPID"]) &
                    TablesLogic.tSurveyResponseFrom.EmailAddress == Security.Decrypt(Request["REA"]) &
                    TablesLogic.tSurveyResponseFrom.SurveyID == (Guid)Session["CurrentSurveyID"]
                    );
                if (SRFID == null)
                    throw new Exception("SurveyResponseFrom not found!");

                foreach (DataListItem DLI in GridResult.Items)
                {
                    UIGridView GV_CheckList = (UIGridView)DLI.FindControl("gridChecklist");
                    if (GV_CheckList != null)
                    {
                        foreach (GridViewRow GVR in GV_CheckList.Rows)
                        {
                            if (GVR.RowType == DataControlRowType.DataRow)
                            {
                                UIFieldLabel l = (UIFieldLabel)GVR.FindControl("HiddenID");
                                Guid SurveyChecklistItemID = new Guid(l.Text);
                                OSurveyChecklistItem DB_SCLI = TablesLogic.tSurveyChecklistItem.Load(SurveyChecklistItemID);

                                if (DB_SCLI == null)
                                    throw new Exception("Survey checklist item not found!");

                                int SurveyChecklistItemType = DB_SCLI.ChecklistItemType.Value;

                                if (SurveyChecklistItemType == ChecklistItemType.MultipleSelections)
                                {
                                    UIFieldCheckboxList cbl = (UIFieldCheckboxList)GVR.FindControl("ChecklistItem_MS_SelectedResponseID");
                                    if (cbl != null)
                                    {
                                        DB_SCLI.SelectedResponses.Clear();
                                        foreach (ListItem LI in cbl.Items)
                                        {
                                            if (LI.Selected == true)
                                                DB_SCLI.SelectedResponses.AddGuid(new Guid(LI.Value.ToString()));
                                        }
                                    }
                                }
                                else if (SurveyChecklistItemType == ChecklistItemType.Choice)
                                {
                                    UIFieldRadioList rl = (UIFieldRadioList)GVR.FindControl("ChecklistItem_C_SelectedResponseID");
                                    if (rl != null)
                                    {
                                        DB_SCLI.SelectedResponses.Clear();
                                        foreach (ListItem LI in rl.Items)
                                        {
                                            if (LI.Selected == true)
                                                DB_SCLI.SelectedResponses.AddGuid(new Guid(LI.Value.ToString()));
                                        }
                                    }
                                }
                                else if (SurveyChecklistItemType == ChecklistItemType.Remarks)
                                {
                                    UIFieldTextBox t = (UIFieldTextBox)GVR.FindControl("tb_Remarks");
                                    if (t != null)
                                    {
                                        DB_SCLI.Description = t.Text;
                                    }
                                }
                                else if (SurveyChecklistItemType == ChecklistItemType.SingleLineFreeText)
                                {
                                    UIFieldTextBox tb = (UIFieldTextBox)GVR.FindControl("tb_SingleLineFreeText");
                                    if (tb != null)
                                    {
                                        DB_SCLI.Description = tb.Text;
                                    }
                                }

                                DB_SCLI.FilledInRespondentName = tb_RespondentName.Text.Trim();
                                DB_SCLI.FilledInRespondentContactNumber = tb_RespondentContactNumber.Text.Trim();
                                DB_SCLI.FilledInRespondentEmailAddress = tb_RespondentEmailAddress.Text.Trim();

                                DB_SCLI.SurveyResponseFromID = SRFID;
                                DB_SCLI.Status = SurveyStatusType.ValidWithReply;
                                DB_SCLI.Survey.Status = SurveyStatusType.ValidWithReply;
                                DB_SCLI.Save();
                                DB_SCLI.Survey.Status = SurveyStatusType.ValidWithReply;
                                DB_SCLI.Survey.Save();
                            }
                        }
                    }
                }
                c.Commit();
            }
            catch (Exception ex)
            {
                Message = ex.Message + "<br>" + ex.StackTrace;
            }
        }
        return Message;
    }

    protected void btn_SubmitSurvey_Click(object sender, EventArgs e)
    {
        lbl_PageMessage.Text = ValidateSurveySubmission();
        if (MainPanel.IsValid)
        {
            lbl_PageMessage.Text = SubmitSurvey();
            LoadSurveyForm((Guid)Session["CurrentSurveyID"], Security.DecryptGuid(Request["SRID"]), Security.Decrypt(Request["REA"]));
            MainPanel.ClearErrorMessages();
            form1_PreRender(sender, e);
        }
    }

    protected void btn_NavigatePrevious_Click(object sender, EventArgs e)
    {
        lbl_PageMessage.Text = "";
        ArrayList AL_SurveyID = (ArrayList)Session["CurrentSurveyList"];
        Guid CurrentSurveyID = (Guid)Session["CurrentSurveyID"];
        int CurrentIndex = AL_SurveyID.IndexOf(CurrentSurveyID);
        if (CurrentIndex != 0)
            LoadSurveyForm((Guid)AL_SurveyID[CurrentIndex - 1], Security.DecryptGuid(Request["SRID"]), Security.Decrypt(Request["REA"]));
    }

    protected void btn_NavigateNext_Click(object sender, EventArgs e)
    {
        lbl_PageMessage.Text = "";
        ArrayList AL_SurveyID = (ArrayList)Session["CurrentSurveyList"];
        Guid CurrentSurveyID = (Guid)Session["CurrentSurveyID"];
        int CurrentIndex = AL_SurveyID.IndexOf(CurrentSurveyID);
        if (CurrentIndex != (AL_SurveyID.Count - 1))
            LoadSurveyForm((Guid)AL_SurveyID[CurrentIndex + 1], Security.DecryptGuid(Request["SRID"]), Security.Decrypt(Request["REA"]));
    }

    protected void tb_DefaultRespondentName_ControlChange(object sender, EventArgs e)
    {
        UpdateRespondentDetails();
    }

    protected void tb_DefaultRespondentEmailAddress_ControlChange(object sender, EventArgs e)
    {
        UpdateRespondentDetails();
    }

    protected void tb_DefaultRespondentContactNumber_ControlChange(object sender, EventArgs e)
    {
        UpdateRespondentDetails();
    }  


   
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Survey Form</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Classy/dragdrop.css" type="text/css" rel="stylesheet" />
    <link href="../../App_Themes/Classy/StyleSheet.css" type="text/css" rel="stylesheet" />
</head>
<body style="background-color: white; padding: 8px 8px 8px 8px">
    <form id="form1" runat="server" style="width: 793px" onprerender="form1_PreRender"
    onload="form1_OnLoad">
    <div style="width: 793px">
        <ui:UIObjectPanel runat="server" ID="MainPanel" Width="100%" Style="background-color: white;
            border: none">
            <ui:UIGridView runat="server" ID="gv" Caption="gv" CheckBoxColumnVisible="false"
                PropertyName="" SortExpression="StepNumber" Visible="false" BindObjectsToRows="True"
                KeyName="ObjectID" meta:resourcekey="gridChecklistResource1" CaptionWidth="120px"
                Width="100%" AllowPaging="false" AllowSorting="false" PagingEnabled="false">
                <Columns>
                    <ui:UIGridViewBoundColumn PropertyName="SurveyID" HeaderText="SurveyID">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ObjectID" HeaderText="ObjectID">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="DisplayOrder" HeaderText="DisplayOrder">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ChecklistID" HeaderText="ChecklistID">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ChecklistName" HeaderText="ChecklistName">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="SurveyTradeName" HeaderText="SurveyTradeName">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="EvaluatedParty" HeaderText="EvaluatedParty">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="StepNumber" HeaderText="StepNumber">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="ObjectName">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ChecklistItemType" HeaderText="ChecklistItemType">
                    </ui:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
            <ui:UIButton ID="btn_SaveSurvey" runat="server" Text="Save Survey" Visible="true"
                ImageUrl="~/images/icon-savesmall.gif" ConfirmText="Are you sure you want to save the survey?"
                OnClick="btn_SaveSurvey_Click" />
            <ui:UIButton ID="btn_SubmitSurvey" runat="server" Text="Submit Survey" Visible="true"
                ImageUrl="~/images/tick.gif" ConfirmText="Are you sure you want to submit the survey?"
                OnClick="btn_SubmitSurvey_Click" />
            <ui:UIButton ID="btn_NavigatePrevious" runat="server" Text="Previous" Visible="true"
                CausesValidation="false" ImageUrl="~/images/resultset_previous.gif" ConfirmText=""
                OnClick="btn_NavigatePrevious_Click" />
            <asp:Label runat="server" ID="lbl_CurrentIndex" ForeColor="Red" Font-Bold="true" />
            <asp:Label runat="server" ID="lbl_IndexList" ForeColor="Red" Font-Bold="true" />
            &nbsp;&nbsp;&nbsp;
            <ui:UIButton ID="btn_NavigateNext" runat="server" Text="Next" Visible="true" ImageUrl="~/images/resultset_next.gif"
                ConfirmText="" OnClick="btn_NavigateNext_Click" CausesValidation="false" />
            &nbsp;&nbsp;&nbsp;
            <asp:Label runat="server" ID="lbl_NumberOfPendingSubmission" ForeColor="Red" Font-Bold="true" />
            <br />
            <br />
            <asp:Panel runat="server" ID="panelMessage" CssClass="object-message">
                <asp:Label runat="server" ID="lbl_PageMessage" ForeColor="Red" Font-Bold="true" />
            </asp:Panel>
            <br />
            <ui:UIPanel runat="server" ID="panelDefaultRespondentDetails">
                <ui:UIFieldTextBox ID="tb_DefaultRespondentName" runat="server" Caption="Default Respondent Name"
                    Width="100%" TextMode="SingleLine" MaxLength="255" ValidateRequiredField="false"
                    OnControlChange="tb_DefaultRespondentName_ControlChange" />
                <ui:UIFieldTextBox ID="tb_DefaultRespondentContactNumber" runat="server" Caption="Default Respondent Contact No."
                    Width="100%" TextMode="SingleLine" MaxLength="50" ValidateRequiredField="false"
                    OnControlChange="tb_DefaultRespondentContactNumber_ControlChange" />
                <ui:UIFieldTextBox ID="tb_DefaultRespondentEmailAddress" runat="server" Caption="Default Respondent Email Address"
                    Width="100%" TextMode="SingleLine" MaxLength="50" ValidateRequiredField="false"
                    OnControlChange="tb_DefaultRespondentEmailAddress_ControlChange" />
                <br />
                <br />
                <br />
            </ui:UIPanel>
            <ui:UIPanel runat="server" ID="panelSurveyForm" BorderStyle="Solid" BorderWidth="1px">
                <table border="0" cellpadding="3" cellspacing="0" width="793px">
                    <tr>
                        <td>
                            <div align="center">
                                <font size="3pt">
                                    <asp:Label runat="Server" ID="lbl_Title_1"></asp:Label>
                                </font>
                                <br />
                                <br />
                                <font size="4pt" bold="true">
                                    <asp:Label runat="Server" ID="lbl_Title_2"></asp:Label>
                                </font>
                                <br />
                                <br />
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div align="left">
                                <ui:UIFieldTextBox ID="tb_RespondentName" runat="server" Caption="Respondent Name"
                                    Width="100%" TextMode="SingleLine" MaxLength="255" ValidateRequiredField="true" />
                                <ui:UIFieldTextBox ID="tb_RespondentContactNumber" runat="server" Caption="Respondent Contact No."
                                    Width="100%" TextMode="SingleLine" MaxLength="50" ValidateRequiredField="true" />
                                <ui:UIFieldTextBox ID="tb_RespondentEmailAddress" runat="server" Caption="Respondent Email Address"
                                    Width="100%" TextMode="SingleLine" MaxLength="50" ValidateRequiredField="true" />
                                <br />
                                <br />
                                <ui:UIFieldLabel runat="server" ID="lbl_PremisesName" Caption="Premises Name" />
                                <ui:UIFieldLabel runat="server" ID="lbl_PremisesAddress" Caption="Premises Address" />
                                <ui:UIPanel runat="server" ID="panelSurveyFormDescription">
                                    <br />
                                    <br />
                                    <asp:Label runat="Server" ID="lbl_SurveyFormDescription"></asp:Label>
                                </ui:UIPanel>
                                <br />
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:DataList ID="GridResult" runat="server" OnItemDataBound="GridResult_ItemDataBound"
                                ShowFooter="false" ShowHeader="false" Width="100%">
                                <ItemTemplate>
                                    <br />
                                    <div style="clear: both">
                                        <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_ChecklistName" Caption="Checklist"
                                            PropertyName="" Visible="false" />
                                        <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_SurveyTradeName" Caption="Survey Trade"
                                            PropertyName="" Visible="false" />
                                        <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_VendorName" Caption="Evaluated Party"
                                            PropertyName="" />
                                        <ui:UIGridView runat="server" ID="gridChecklist" Caption="Checklist" CheckBoxColumnVisible="false"
                                            SortExpression="StepNumber" OnRowDataBound="gridChecklist_RowDataBound" BindObjectsToRows="true"
                                            KeyName="ObjectID" meta:resourcekey="gridChecklistResource1" CaptionWidth="120px"
                                            Width="100%" AllowPaging="false" AllowSorting="false" PagingEnabled="false">
                                            <Columns>
                                                <ui:UIGridViewBoundColumn ControlStyle-Width="30px" PropertyName="StepNumber" HeaderText="Step">
                                                </ui:UIGridViewBoundColumn>
                                                <ui:UIGridViewBoundColumn ControlStyle-Width="200px" PropertyName="ObjectName" HeaderText="Description">
                                                </ui:UIGridViewBoundColumn>
                                                <ui:UIGridViewTemplateColumn ControlStyle-Width="560px" HeaderText="Answer">
                                                    <ItemTemplate>
                                                        <ui:UIFieldCheckboxList ID="ChecklistItem_MS_SelectedResponseID" runat="server" CaptionWidth="1px"
                                                            RepeatColumns="0" Width="100%" Visible="false">
                                                        </ui:UIFieldCheckboxList>
                                                        <ui:UIFieldRadioList ID="ChecklistItem_C_SelectedResponseID" runat="server" CaptionWidth="1px"
                                                            RepeatColumns="0" Width="100%" Visible="false">
                                                        </ui:UIFieldRadioList>
                                                        <ui:UIFieldTextBox ID="tb_Remarks" runat="server" CaptionWidth="1px" Width="100%"
                                                            TextMode="MultiLine" Rows="3" MaxLength="500" Visible="false" />
                                                        <ui:UIFieldTextBox ID="tb_SingleLineFreeText" runat="server" CaptionWidth="1px" Width="100%"
                                                            TextMode="SingleLine" MaxLength="50" Visible="false" />
                                                        <ui:UIFieldLabel ID="HiddenID" runat="server" CaptionWidth="1px" PropertyName=""
                                                            Visible="false">
                                                        </ui:UIFieldLabel>
                                                    </ItemTemplate>
                                                </ui:UIGridViewTemplateColumn>
                                                <ui:UIGridViewTemplateColumn ControlStyle-Width="250px" HeaderText="Remarks" Visible="false">
                                                    <ItemTemplate>
                                                        <ui:UIFieldLabel Visible="true" runat="server" ID="ChecklistItem_Description" CaptionWidth="1px"
                                                            PropertyName="Description" Span="full" Height="40px">
                                                        </ui:UIFieldLabel>
                                                    </ItemTemplate>
                                                </ui:UIGridViewTemplateColumn>
                                            </Columns>
                                        </ui:UIGridView>
                                        <br />
                                    </div>
                                </ItemTemplate>
                            </asp:DataList>
                        </td>
                    </tr>
                </table>
            </ui:UIPanel>
        </ui:UIObjectPanel>
    </div>
    </form>
</body>
</html>
