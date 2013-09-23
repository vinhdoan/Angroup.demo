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
            LoadSurveyForm();
            
        }
    }

    public void LoadSurveyForm()
    {
        if (Request["SID"] != null &&
            Request["SRID"] != null && 
            Request["REA"] != null && 
            Request["SPID"] != null)
        {
            Guid SID = Security.DecryptGuid(Request["SID"]);
            Guid SRID = Security.DecryptGuid(Request["SRID"]);
            Guid SPID = Security.DecryptGuid(Request["SPID"]);
            string emailAddress = Security.Decrypt(Request["REA"]);

            List<OSurvey> ListOfSurveys = TablesLogic.tSurvey.LoadList
                (TablesLogic.tSurvey.SurveyPlannerRespondent.SurveyRespondentID == SRID &
                TablesLogic.tSurvey.SurveyPlannerRespondent.SurveyRespondent.EmailAddress.UpperCase() == emailAddress.ToUpper() &
                TablesLogic.tSurvey.SurveyPlannerRespondent.SurveyPlannerID == SPID);

            if (ListOfSurveys.Count > 0)
            {
                OSurvey S = ListOfSurveys.Find((s) => s.ObjectID == SID);
                int CurrentIndex = ListOfSurveys.IndexOf(S);

                if (CurrentIndex != (ListOfSurveys.Count - 1))
                {
                    if (CurrentIndex == 0)
                    {
                        btn_NavigatePrevious.Enabled = false;
                    }
                    
                    btn_NavigateNext.Enabled = true;
                    lbl_CurrentIndex.Text = Convert.ToString(CurrentIndex + 1);
                }
                else if (CurrentIndex == (ListOfSurveys.Count - 1))
                {
                    btn_NavigateNext.Enabled = false;
                }

                if (ListOfSurveys.Count == 1)
                    panelNavigateButtonsTop.Visible = false;
                
                Session["ListOfSurveys"] = ListOfSurveys;
                
                lbl_IndexList.Text = " / " + Convert.ToString(ListOfSurveys.Count);
                
                OSurveyPlanner SP = S.SurveyPlanner;
                LoadSurveyForm(S, SP, emailAddress);
            }

        }
    }

    public void UpdateSurveyRespondent(OSurvey survey)
    {
        string name = survey.FilledInRespondentName;
        string contactnumber = survey.FilledInRespondentContactNumber;
        string emailaddress = survey.FilledInRespondentEmailAddress;
        string designation = survey.FilledInRespondentDesignation;
        string buildingname = "";
        string unitnumber = survey.FilledInRespondentUnitNumber;

        panelRespondentTenant.Visible = (survey.SurveyTargetType == (int)EnumSurveyTargetType.Tenant);
        
        if (name != null && name != "")
            tb_RespondentName.Text = name;
        
        if (contactnumber != null && contactnumber != "")
            tb_RespondentContactNumber.Text = contactnumber;
        
        if (emailaddress != null && emailaddress != "")
            tb_RespondentEmailAddress.Text = emailaddress;
        else
            tb_RespondentEmailAddress.Text = survey.SurveyPlannerRespondent.SurveyRespondentPortfolio.EmailAddress;//201109

        if (buildingname != null && buildingname != "")
            tb_RespondentBuildingName.Text = buildingname;

        if (designation != null && designation != "")
            tb_RespondentDesignation.Text = designation;

        if (unitnumber != null && unitnumber != "")
            tb_RespondentUnitNumber.Text = unitnumber;
        
    }
    
    public void LoadSurveyForm(OSurvey survey, OSurveyPlanner SP, string emailAddress)
    {
        Session["CurrentSurvey"] = survey;
        
        lbl_Title_1.Text = SP.SurveyFormTitle1;
        lbl_Title_2.Text = SP.SurveyFormTitle2;
        lbl_SurveyFormDescription.Text = SP.SurveyFormDescription;

        //lbl_PageMessage.Text = survey.PublicURL;
        UpdateSurveyRespondent(survey);

        if (Request["Preview"] == null)
        {

            if (survey.Status == (int)EnumSurveyStatusType.Responded)
            {
                if (lbl_PageMessage.Text == "")
                {
                    lbl_PageMessage.Text =
                        labelDialogMessage.Text = Resources.Strings.SurveyPlanner_NotEditable;
                }

            }

            if (survey.Status == (int)EnumSurveyStatusType.ClosedWithResponse ||
                survey.Status == (int)EnumSurveyStatusType.ClosedWithoutResponse)
            {
                if (lbl_PageMessage.Text == "")
                {
                    lbl_PageMessage.Text =
                        labelDialogMessage.Text = Resources.Strings.SurveyPlanner_NotEditableDueToClose;
                }
            }

            
        }

        panelSurveyForm.Enabled =
                (survey.Status == (int)EnumSurveyStatusType.Open ||
                survey.Status == (int)EnumSurveyStatusType.Saved) && Request["Preview"] == null;
        
        if (labelDialogMessage.Text != "")
            dialogMessage.Show();

        Hashtable ht_ChecklistResult = new Hashtable();
        DataTable dt0 = new DataTable();
        dt0.Columns.Add("ChecklistID");
        dt0.Columns.Add("SurveyGroupID");
        dt0.Columns.Add("VendorID");
        dt0.Columns.Add("ContractID");

        List<OSurveyChecklistItem> listSCLI = TablesLogic.tSurveyChecklistItem.LoadList
            (TablesLogic.tSurveyChecklistItem.SurveyID == survey.ObjectID);

        

        
        survey.SurveyPlanner.SurveyPlannerServiceLevels.Sort("ItemNumber", true);

        foreach (OSurveyPlannerServiceLevel level in survey.SurveyPlanner.SurveyPlannerServiceLevels)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ObjectID");
            dt.Columns.Add("ChecklistID");
            dt.Columns.Add("ChecklistItemID");
            dt.Columns.Add("SurveyID");
            dt.Columns.Add("ChecklistName");
            dt.Columns.Add("SurveyGroup");
            dt.Columns.Add("Vendor");
            dt.Columns.Add("Contract");
            dt.Columns.Add("StepNumber", typeof(int));
            dt.Columns.Add("ObjectName");
            dt.Columns.Add("ChecklistItemType");

            //if (SRT != null && SRT.Checklist != null)
            if (listSCLI.Count > 0)
            {
                // Construct checklist form
                //

                OChecklist CL = level.Checklist;
                foreach (OSurveyChecklistItem CLI in listSCLI)
                {
                    if (CLI.SurveyGroupServiceLevelID == level.ObjectID)
                    {
                        dt.Rows.Add
                            (CLI.ObjectID,
                            CL.ObjectID,
                            CLI.ChecklistItemID,
                            survey.ObjectID,
                            CL.ObjectName,
                            level.ObjectName,
                            null,
                            null,
                            CLI.StepNumber,
                            CLI.ObjectName,
                            CLI.ChecklistItemType);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    ht_ChecklistResult
                        [CL.ObjectID.Value.ToString() + "::" +
                        level.ObjectID.Value.ToString() + "::" +
                        null + "::" +
                        null] = dt;

                    dt0.Rows.Add
                        (CL.ObjectID,
                        level.ObjectID,
                        null,
                        null);
                }
            }

        }
        Session["ChecklistResult"] = ht_ChecklistResult;
        GridResult.DataSource = dt0;
        GridResult.DataBind();
        
    }


    protected void HighlightSelectedItem()
    {
        foreach (DataListItem DLI in GridResult.Items)
        {
            UIGridView GV_CheckList = (UIGridView)DLI.FindControl("gridChecklist");
            if (GV_CheckList != null && !GV_CheckList.IsContainerEnabled())
            {
                foreach (GridViewRow GVR in GV_CheckList.Rows)
                {
                    if (GVR.RowType == DataControlRowType.DataRow)
                    {
                        UIFieldCheckboxList cbl = (UIFieldCheckboxList)GVR.FindControl("ChecklistItem_MS_SelectedResponseID");
                        if (cbl != null)
                        {
                            foreach (ListItem LI in cbl.Items)
                            {
                                if (LI.Selected)
                                {
                                    LI.Attributes.CssStyle.Add("color", "red");
                                    LI.Attributes.CssStyle.Add("font-weight", "bold");
                                    
                                }
                            }
                        }

                        UIFieldRadioList rl = (UIFieldRadioList)GVR.FindControl("ChecklistItem_C_SelectedResponseID");
                        if (rl != null)
                        {
                            foreach (ListItem LI in rl.Items)
                            {
                                if (LI.Selected)
                                {
                                    LI.Attributes.CssStyle.Add("color", "red");
                                    LI.Attributes.CssStyle.Add("font-weight", "bold");
                                }
                            }

                        }
                    }
                }
            }
        }
    }
    

    protected void form1_PreRender(object sender, EventArgs e)
    {

        panelSurveyForm.Enabled = !(TablesLogic.tSurvey[((OSurvey)Session["CurrentSurvey"]).ObjectID].Status == (int)EnumSurveyStatusType.Responded ||
            TablesLogic.tSurvey[((OSurvey)Session["CurrentSurvey"]).ObjectID].Status == (int)EnumSurveyStatusType.ClosedWithResponse);
        panelButtonsBottom.Enabled =
            panelSaveButtonsTop.Enabled = panelSurveyForm.Enabled && Request["Preview"] == null;


        dialogMessage.Button1.Visible = false;
        panelMessage.Visible = (lbl_PageMessage.Text != "");

        HighlightSelectedItem();
    }



    protected void BindSurveyChecklistItem(OSurveyChecklistItem SCLI, GridViewRowEventArgs e)
    {
        if (SCLI != null)
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
                    cbl.Bind(SCLI.ChecklistResponseSet.ChecklistResponses.Order(
                        TablesLogic.tChecklistResponse.DisplayOrder.Asc));

                    cbl.ValidateRequiredField = (SCLI.IsMandatoryField == 1);
                    foreach (OChecklistResponse CR in SCLI.SelectedResponses)
                    {
                        foreach (ListItem LI in cbl.Items)
                        {
                            if (LI.Value == CR.ObjectID.Value.ToString())
                            {
                                LI.Selected = true;
                            }
                        }
                    }

                    if (SCLI.HasSingleTextboxField == 1)
                    {
                        UIFieldTextBox tb = (UIFieldTextBox)e.Row.FindControl("tb_SingleLineFreeText");
                        if (tb != null)
                        {
                            tb.Visible = true;
                            tb.Text = SCLI.Description;
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
                    rl.Bind(SCLI.ChecklistResponseSet.ChecklistResponses.Order(
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

                    if (SCLI.HasSingleTextboxField == 1)
                    {
                        UIFieldTextBox tb = (UIFieldTextBox)e.Row.FindControl("tb_SingleLineFreeText");
                        if (tb != null)
                        {
                            tb.Visible = true;
                            tb.Text = SCLI.Description;
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

    //---------------------------------------------------------------   
    // event
    //---------------------------------------------------------------
    protected void gridChecklist_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Use row index instead of DataItemIndex as datakeys 
            // is generated for the currently in view grid page, not for the whole grid
            //
            Guid id = new Guid(((GridView)sender).DataKeys[e.Row.RowIndex][0].ToString());
            
            OSurvey SV = TablesLogic.tSurvey[new Guid(((DataRowView)e.Row.DataItem)["SurveyID"].ToString())];
            
            OSurveyChecklistItem SCLI = SV.SurveyChecklistItems.Find(id);

            BindSurveyChecklistItem(SCLI, e);
        }
    }

    protected void GridResult_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            
            string ChecklistID = ((DataRowView)e.Item.DataItem)["ChecklistID"].ToString();
            string SurveyTradeID = ((DataRowView)e.Item.DataItem)["SurveyGroupID"].ToString();
            string ContractID = ((DataRowView)e.Item.DataItem)["ContractID"].ToString();
            string VendorID = ((DataRowView)e.Item.DataItem)["VendorID"].ToString();
            //string EvaluatedParty = ((DataRowView)e.Item.DataItem)["EvaluatedParty"].ToString();
            //string DisplayOrder = ((DataRowView)e.Item.DataItem)["DisplayOrder"].ToString();

            Hashtable ht_Checklist = (Hashtable)Session["ChecklistResult"];
            DataTable dt = (DataTable)ht_Checklist[ChecklistID + "::" + SurveyTradeID + "::" + VendorID + "::" + ContractID];

            if (dt != null && dt.Rows.Count > 0)
            {
                UIFieldLabel lblChecklist = ((UIFieldLabel)e.Item.FindControl("lbl_ChecklistName"));
                UIFieldLabel lblServiceLevel = ((UIFieldLabel)e.Item.FindControl("lbl_SurveyTradeName"));
                UIFieldLabel lblContract = ((UIFieldLabel)e.Item.FindControl("lbl_Contract"));
                UIFieldLabel lblVendor = ((UIFieldLabel)e.Item.FindControl("lbl_VendorName"));
                UIPanel panelContract = ((UIPanel)e.Item.FindControl("panelLabelContract"));
                
                lblChecklist.Text = (dt.Rows[0]["ChecklistName"].ToString() != "" ? dt.Rows[0]["ChecklistName"].ToString() : "N.A");
                lblServiceLevel.Text = (dt.Rows[0]["SurveyGroup"].ToString() != "" ? dt.Rows[0]["SurveyGroup"].ToString() : "N.A");
                
                lblContract.Text = (dt.Rows[0]["Contract"].ToString() != "" ? dt.Rows[0]["Contract"].ToString() : "N.A");
                lblVendor.Text = (dt.Rows[0]["Vendor"].ToString() != "" ? dt.Rows[0]["Vendor"].ToString() : "N.A");

                if (lblContract.Text == "N.A" && 
                    lblVendor.Text == "N.A")
                    panelContract.Visible = false;
                   
            }
            if (dt != null)
            {
                ((UIGridView)e.Item.FindControl("gridChecklist")).Bind(dt);
            }
        }
    }

    protected void btn_SaveSurvey_Click(object sender, EventArgs e)
    {
        lbl_PageMessage.Text = 
            labelDialogMessage.Text = SaveSurvey();
        //LoadSurveyForm((Guid)Session["CurrentSurveyID"], Security.DecryptGuid(Request["SRID"]), Security.Decrypt(Request["REA"]));
        LoadSurveyForm();
        form1_PreRender(sender, e);
        MainPanel.ClearErrorMessages();
        
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

                                SaveSurveyChecklistItems(GVR, DB_SCLI);

                                DB_SCLI.Status = (int)EnumSurveyStatusType.Saved;
                                DB_SCLI.Save();
                                
                                DB_SCLI.Survey.Status = (int)EnumSurveyStatusType.Saved;
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

    protected string ValidateSurveySubmission()
    {
        string Message = "";

        return Message;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="GVR"></param>
    /// <param name="DB_SCLI"></param>
    protected void SaveSurveyChecklistItems(GridViewRow GVR, OSurveyChecklistItem DB_SCLI)
    {
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

            // Some comments
            //
            //
            if (DB_SCLI.HasSingleTextboxField == 1)
            {
                UIFieldTextBox t = (UIFieldTextBox)GVR.FindControl("tb_Remarks");
                if (t != null)
                {
                    DB_SCLI.Description = t.Text;
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

            //
            //
            //
            if (DB_SCLI.HasSingleTextboxField == 1)
            {
                UIFieldTextBox t = (UIFieldTextBox)GVR.FindControl("tb_Remarks");
                if (t != null)
                {
                    DB_SCLI.Description = t.Text;
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
        DB_SCLI.NetworkID = Page.Request.UserHostAddress;

        DB_SCLI.Survey.SurveyRespondedDateTime = DateTime.Now;
        DB_SCLI.Survey.FilledInRespondentName = tb_RespondentName.Text.Trim();
        DB_SCLI.Survey.FilledInRespondentContactNumber = tb_RespondentContactNumber.Text.Trim();
        DB_SCLI.Survey.FilledInRespondentEmailAddress = tb_RespondentEmailAddress.Text.Trim();
        DB_SCLI.Survey.FilledInRespondentBuildingName = tb_RespondentBuildingName.Text.Trim();
        DB_SCLI.Survey.FilledInRespondentUnitNumber = tb_RespondentUnitNumber.Text.Trim();
        DB_SCLI.Survey.FilledInRespondentDesignation = tb_RespondentDesignation.Text.Trim();
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    protected string SubmitSurvey()
    {
        string Message = Resources.Strings.SurveyPlanner_SurveySubmitted;
        using (Connection c = new Connection())
        {
            try
            {
                Guid? SID = Query.Select(TablesLogic.tSurvey.ObjectID)
                .Where(
                    TablesLogic.tSurvey.SurveyPlannerID == Security.DecryptGuid(Request["SPID"]) &
                    TablesLogic.tSurvey.SurveyPlannerRespondent.SurveyRespondent.EmailAddress == Security.Decrypt(Request["REA"]) &
                    TablesLogic.tSurvey.ObjectID == ((OSurvey)Session["CurrentSurvey"]).ObjectID &
                    (TablesLogic.tSurvey.Status == (int)EnumSurveyStatusType.Responded |
                    TablesLogic.tSurvey.Status == (int)EnumSurveyStatusType.ClosedWithResponse) &
                    TablesLogic.tSurvey.IsDeleted == 0
                    );
                if (SID != null)
                    throw new Exception("The Survey has been submitted by another person.");

                
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

                                SaveSurveyChecklistItems(GVR, DB_SCLI);
                                
                                DB_SCLI.Status = (int)EnumSurveyStatusType.Responded;
                                DB_SCLI.Save();
                                DB_SCLI.Survey.Status = (int)EnumSurveyStatusType.Responded;
                                DB_SCLI.Survey.Save();
                            }
                        }
                    }
                }
                c.Commit();
            }
            catch (Exception ex)
            {
                Message = ex.Message;
            }
        }
        return Message;
    }

    protected void btn_SubmitSurvey_Click(object sender, EventArgs e)
    {

        if (!tb_RespondentEmailAddress.Text.Trim().Contains('@'))
            tb_RespondentEmailAddress.ErrorMessage = " Invalid e-mail address. Please enter a valid e-mail";
        
        if (MainPanel.IsValid)
        {   
            labelDialogMessage.Text = SubmitSurvey();
            
            OSurvey S = ((OSurvey)Session["CurrentSurvey"]);
            LoadSurveyForm(S, S.SurveyPlanner, S.SurveyPlannerRespondent.SurveyRespondentPortfolio.EmailAddress);//201109
            
            MainPanel.ClearErrorMessages();
            form1_PreRender(sender, e);
        }
        else
        {
            //MainPanel.ClearErrorMessages();
            lbl_PageMessage.Text = "You have left some responses blank, or some of your responses are invalid.";
        }
    }

    protected void btn_NavigatePrevious_Click(object sender, EventArgs e)
    {
        lbl_PageMessage.Text = "";
        List<OSurvey> ListOfSurveys = (List<OSurvey>)Session["ListOfSurveys"];
        OSurvey S = (OSurvey)Session["CurrentSurvey"];

        int CurrentIndex = ListOfSurveys.IndexOf(S);
        if (CurrentIndex != 0)
        {
            //btn_NavigatePrevious.Enabled = true;
            OSurvey NextS = ListOfSurveys[CurrentIndex - 1];
            LoadSurveyForm(NextS, NextS.SurveyPlanner, NextS.SurveyPlannerRespondent.SurveyRespondent.EmailAddress);
            lbl_CurrentIndex.Text = Convert.ToString(CurrentIndex);
            btn_NavigatePrevious.Enabled = !((CurrentIndex - 1) == 0);
            btn_NavigateNext.Enabled = ((ListOfSurveys.Count - (CurrentIndex - 1)) != 1);
        }
    }

    protected void btn_NavigateNext_Click(object sender, EventArgs e)
    {
        lbl_PageMessage.Text = "";
        List<OSurvey> ListOfSurveys = (List<OSurvey>)Session["ListOfSurveys"];
        OSurvey S = (OSurvey)Session["CurrentSurvey"];

        int CurrentIndex = ListOfSurveys.IndexOf(S);
        
        btn_NavigateNext.Enabled = (CurrentIndex != (ListOfSurveys.Count - 2));
        btn_NavigatePrevious.Enabled = ((ListOfSurveys.Count - CurrentIndex) != 1);
        if (CurrentIndex != (ListOfSurveys.Count - 1))
        {
            OSurvey NextS = ListOfSurveys[CurrentIndex + 1];
            
            if (Request["Preview"] == null)
                btn_SubmitSurvey_Click(sender, e);
            
            if (lbl_PageMessage.Text == "")
            {
                LoadSurveyForm(NextS, NextS.SurveyPlanner, NextS.SurveyPlannerRespondent.SurveyRespondent.EmailAddress);
                lbl_CurrentIndex.Text = Convert.ToString(CurrentIndex + 2);
            }
        }
    }



    protected void dialogMessage_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        dialogMessage.Hide();
        if (e.CommandName == "CloseSurvey")
        {
            Window.Close();
        }
        if (e.CommandName == "CancelSurvey")
        {
            labelDialogMessage.Text = "";
            lbl_PageMessage.Text = "";
            //OSurvey S = TablesLogic.tSurvey.Load(((OSurvey)Session["CurrentSurvey"]).ObjectID);
            //LoadSurveyForm(S, S.SurveyPlanner, S.SurveyPlannerRespondent.SurveyRespondent.EmailAddress);
            form1_PreRender(sender, e);
            //LoadSurveyForm();
            
        }
        
    }

    protected void btn_ExitSurvey_Click(object sender, EventArgs e)
    {
        Window.Close();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Survey Form</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/dragdrop.css" type="text/css" rel="stylesheet" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" type="text/css" rel="stylesheet" />
</head>
<center>
<body style="background-color: white; padding: 8px 8px 8px 8px">
    <form id="form1" runat="server" style="width: 830px" onprerender="form1_PreRender"
    onload="form1_OnLoad">
    <div style="width: 800px">
        <ui:UIObjectPanel runat="server" ID="MainPanel" Width="830px" CssClass="dialog" Style="background-color: white;
            border: none">
            <ui:UIPanel runat="server" ID="panelButtonsTop" CssClass="dialog-buttons">
                <div>
                    <div align="left">
                        <ui:UIPanel runat="server" ID="panelNavigateButtonsTop" BorderStyle="NotSet">
                            <ui:UIButton ID="btn_NavigatePrevious" runat="server" Text="Previous" Visible="true"
                                CausesValidation="false" ImageUrl="~/images/resultset_previous.gif" ConfirmText=""
                                Font-Bold="true" AlwaysEnabled="false"
                                OnClick="btn_NavigatePrevious_Click" />
                            <asp:Label runat="server" ID="lbl_CurrentIndex" ForeColor="Red" Font-Bold="true" Visible="true" />
                            <asp:Label runat="server" ID="lbl_IndexList" ForeColor="Red" Font-Bold="true" Visible="true" />
                            &nbsp;&nbsp;&nbsp;
                            <ui:UIButton ID="btn_NavigateNext" runat="server" Text="Next" Visible="true" 
                                ImageUrl="~/images/resultset_next.gif" Font-Bold="true" AlwaysEnabled="false"
                                ConfirmText="" OnClick="btn_NavigateNext_Click" CausesValidation="true" />
                            &nbsp;&nbsp;&nbsp;
                        </ui:UIPanel>
                    </div>
                    <div align="right">
                        <ui:UIPanel runat="server" ID="panelSaveButtonsTop" BorderStyle="NotSet">
                            <ui:UIButton ID="btn_SaveSurvey" runat="server" Text="Save Survey" Visible="false" Font-Bold="true"
                                ImageUrl="~/images/icon-savesmall.gif"
                                OnClick="btn_SaveSurvey_Click" />
                            <ui:UIButton ID="btn_SubmitSurvey" runat="server" Text="Done" Visible="true"
                                OnClick="btn_SubmitSurvey_Click" Font-Bold="true" ImageUrl="~/images/tick.gif" />
                            &nbsp;&nbsp;&nbsp;
                            &nbsp;&nbsp;&nbsp;
                            <ui:UIButton ID="btn_ExitSurveyTop" runat="server" Text="Exit Survey" Visible="true"
                                AlwaysEnabled="true" CausesValidation="false" OnClick="btn_ExitSurvey_Click" />  
                        </ui:UIPanel>
                    </div>
                </div>
            </ui:UIPanel>
            
            
            
            <asp:Label runat="server" ID="lbl_NumberOfPendingSubmission" ForeColor="Red" Font-Bold="true" />
            <br />
            <ui:UIPanel runat="server" ID="panelMessage" CssClass="field-errormessage">
                <asp:Label runat="server" ID="lbl_PageMessage" ForeColor="Red"/>
            </ui:UIPanel>
            <br />
            <ui:UIPanel runat="server" ID="panelSurveyForm" CssClass="dialog-main" BorderStyle="NotSet" BorderWidth="0px">
                <table border="0" cellpadding="0" cellspacing="0" width="800px">
                    <tr>
                        <td>
                            <div align="right">
                                <asp:Image runat="server" ID="imageLogo" ImageUrl="~/images/capitacommercialtrust.gif" Width="100px" Height="50px" />
                            </div>
                            <div align="left">
                                <font size="3pt" bold="true">
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
                                <ui:UIFieldLabel runat="server" ID="lbl_PremisesName" Caption="Premises Name" Visible="false" />
                                <ui:UIFieldLabel runat="server" ID="lbl_PremisesAddress" Caption="Premises Address" Visible="false" />
                                <ui:UIPanel runat="server" ID="panelSurveyFormDescription">
                                    <br />
                                    <asp:Label runat="Server" ID="lbl_SurveyFormDescription" Font-Size="Small"></asp:Label>
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
                                        <div align="left">
                                            <ui:UIPanel runat="server" ID="panelLabelService" BorderStyle="NotSet">
                                                <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_ChecklistName" Caption="Checklist"
                                                    PropertyName="" Visible="false" />
                                                <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_SurveyTradeName" Caption="Service Level"
                                                    PropertyName="" Font-Size="Small" Font-Bold="true"/>
                                            </ui:UIPanel>
                                            <ui:UIPanel runat="server" ID="panelLabelContract" BorderStyle='NotSet'>
                                                <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_Contract" Caption="Contract"
                                                    PropertyName="" Font-Size="Small" Font-Bold="true" Text="N.A" />
                                                <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_VendorName" Caption="Vendor"
                                                    PropertyName="" Font-Size="Small" Font-Bold="true" />
                                            </ui:UIPanel>
                                        </div>
                                        <br />
                                        <br />
                                        <ui:UIGridView runat="server" ID="gridChecklist" Caption="Questions" CheckBoxColumnVisible="false" CssClass="grid-row"
                                            SortExpression="StepNumber" OnRowDataBound="gridChecklist_RowDataBound" BindObjectsToRows="true" GridLines="None" BorderWidth="0px"
                                            KeyName="ObjectID" meta:resourcekey="gridChecklistResource1" CaptionWidth="120px" ShowHeader="false" ShowCaption="false" EnableTheming="true"
                                            Width="100%" AllowPaging="false" AllowSorting="false" PagingEnabled="false">
                                            <Columns>
                                                <ui:UIGridViewBoundColumn HeaderStyle-Width="50px" ItemStyle-Width="40px" PropertyName="StepNumber" HeaderText="No.">
                                                </ui:UIGridViewBoundColumn>
                                                <ui:UIGridViewBoundColumn ItemStyle-Width="630px" ItemStyle-Height="50px" HeaderStyle-Font-Bold="true" PropertyName="ObjectName" HeaderText="Questions">
                                                </ui:UIGridViewBoundColumn>
                                                <ui:UIGridViewTemplateColumn ItemStyle-Width="380px" ItemStyle-HorizontalAlign="Center" HeaderStyle-Font-Bold="true" HeaderText="Responses">
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
                                                <%--<ui:UIGridViewTemplateColumn ControlStyle-Width="250px" HeaderText="Remarks" Visible="false">
                                                    <ItemTemplate>
                                                        <ui:UIFieldLabel Visible="true" runat="server" ID="ChecklistItem_Description" CaptionWidth="1px"
                                                            PropertyName="Description" Span="full" Height="40px">
                                                        </ui:UIFieldLabel>
                                                    </ItemTemplate>
                                                </ui:UIGridViewTemplateColumn>--%>
                                            </Columns>
                                        </ui:UIGridView>
                                        <br />
                                    </div>
                                </ItemTemplate>
                            </asp:DataList>
                        </td>
                    </tr>
                </table>
                <br /><br />
                <div align="left">
                    <asp:Label runat="server" ID="labelThank" ForeColor="Black" 
                        Text="Thanks for participating and your feedback. We'd like to keep in touch with you." 
                        Font-Bold="true" />
                
                    <br /><br /><br /><br />
                
                    <ui:UIPanel runat="server" ID="panelRespondentTenant" BorderStyle="NotSet">
                        <ui:UIFieldTextBox ID="tb_RespondentBuildingName" runat="server" Caption="Name of Building"
                            Width="100%" TextMode="SingleLine" MaxLength="255" Enabled="false" ValidateRequiredField="true" />
                        <ui:UIFieldTextBox ID="tb_RespondentUnitNumber" runat="server" Caption="Unit No."
                            Width="100%" TextMode="SingleLine" MaxLength="255" ValidateRequiredField="true" />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelRespondentDetail" BorderStyle="NotSet">
                        <ui:UIFieldTextBox ID="tb_RespondentName" runat="server" Caption="Name"
                            Width="100%" TextMode="SingleLine" MaxLength="255" ValidateRequiredField="true" />
                        <ui:UIFieldTextBox ID="tb_RespondentEmailAddress" runat="server" Caption="Email Address"
                            Width="100%" TextMode="SingleLine" MaxLength="50" ValidateRequiredField="true" />
                        <ui:UIFieldTextBox ID="tb_RespondentDesignation" runat="server" Caption="Designation"
                            Width="100%" TextMode="SingleLine" MaxLength="255" ValidateRequiredField="false" />    
                        <ui:UIFieldTextBox ID="tb_RespondentContactNumber" runat="server" Caption="Contact No."
                            Width="100%" TextMode="SingleLine" MaxLength="50" ValidateRequiredField="false" />
                        <br />
                    </ui:UIPanel>
                </div>
            </ui:UIPanel>
            <ui:UIPanel runat="server" ID="panelButtonsBottom" CssClass="dialog-buttons">
                <ui:UIButton ID="btn_SaveSurveyBottom" runat="server" Text="Save Survey" Visible="false" Font-Bold="true"
                    ImageUrl="~/images/icon-savesmall.gif"
                    OnClick="btn_SaveSurvey_Click" />
                <ui:UIButton ID="btn_SubmitSurveyBottom" runat="server" Text="Done" Font-Bold="true" Visible="true"
                    OnClick="btn_SubmitSurvey_Click" ImageUrl="~/images/tick.gif" />
                &nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;
                <ui:UIButton ID="btn_ExitSurveyBottom" runat="server" Text="Exit Survey" Visible="true" 
                    CausesValidation="false"
                    AlwaysEnabled="true"
                    OnClick="btn_ExitSurvey_Click" />    
            </ui:UIPanel>
            <ui:UIDialogBox runat="server" ID="dialogMessage" 
                DialogWidth="450px" Title="Message"
                Button1AlwaysEnabled="true" Button1Text="Close Survey" Button1FontBold="true" 
                Button1AutoClosesDialogBox="true" Button1CausesValidation="false" Button1CommandName="CloseSurvey"
                Button2AlwaysEnabled="true" Button2Text="Back to Survey" Button2FontBold="true" 
                Button2AutoClosesDialogBox="true" Button2CausesValidation="false" Button2CommandName="CancelSurvey"
                OnButtonClicked="dialogMessage_ButtonClicked">
                
                <ui:UIPanel runat="server" ID="panelDialogMessage">
                    <div align="center">         
                        <asp:Label runat="server" ID="labelDialogMessage" CssClass="field-errormessage"
                            ForeColor="Red" Font-Bold="true" Font-Size="Small"/>
                    </div>
                </ui:UIPanel>
                
            </ui:UIDialogBox>
        </ui:UIObjectPanel>
    </div>
    </form>
</body>
</center>
</html>