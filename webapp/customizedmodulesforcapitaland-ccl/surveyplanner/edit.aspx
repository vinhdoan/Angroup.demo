﻿<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
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


        objectBase.ObjectNumberVisible = !CurrentSP.IsNew;

        //BindSurveyPlanner(CurrentSP);

        BindLocation(CurrentSP);

        panel.ObjectPanel.BindObjectToControls(CurrentSP);
    }

    protected void HideAndShowControls(OSurveyPlanner SP)
    {
        //tabPlanner.Visible = (SP.LocationID != null);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OSurveyPlanner SP = panel.SessionObject as OSurveyPlanner;
        panel.ObjectPanel.BindControlsToObject(SP);

        HideAndShowControls(SP);


        WorkflowSetting();
    }

    /// <summary>
    /// 
    /// </summary>
    protected void WorkflowSetting()
    {
        // Do hide and show here.
        //
        string state = objectBase.CurrentObjectState;
        string action = objectBase.SelectedAction;

        //panelContractedVendors.Enabled =
        //    panelEvaluatedParty.Enabled = 
        //    panelNonContractedVendors.Enabled =
        panelOtherDetails.Enabled =
        panelTitleDescription.Enabled =
        panelSurveyGroup.Enabled =
        panelRespondent.Enabled = !state.Is("InProgress");

        tabSurveys.Visible =
            tabProgress.Visible = state.Is("InProgress", "Close");

        dateValidEnd.ValidateRequiredField = action.Is("Close");

        panel.CommentTextValidateRequiredField = action.Is("Update");

        panel.ObjectPanel.Enabled = !state.Is("Close");

        ListItem i = objectBase.GetWorkflowRadioListItem("-");
        if (i != null)
            i.Enabled = state.Is("Close", "Draft");
    }

    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(CurrentSP);



            // Validate
            //
            Validate();

            // Save
            //            
            CurrentSP.Save();
            c.Commit();
            //panel.ObjectPanel.BindObjectToControls(CurrentSP);
        }
    }

    protected void Validate()
    {
        if (!panel.ObjectPanel.IsValid)
            return;
    }



    protected void subpanelSurveyGroupServiceLevel_PopulateForm(object sender, EventArgs e)
    {
        OSurveyPlannerServiceLevel serviceLevel = subpanelSurveyGroupServiceLevel.SessionObject as OSurveyPlannerServiceLevel;

        OSurveyPlanner planner = panel.SessionObject as OSurveyPlanner;

        dropServiceLeveItemNumber.Items.Clear();
        dropServiceLevelChecklist.Bind(OChecklist.GetSurveyChecklist());
        //dropSurveyGroup.Bind(OSurveyServiceLevel.GetSurveyServiceLevels());

        for (int i = 1; i <= planner.SurveyPlannerServiceLevels.Count + 1; i++)
            dropServiceLeveItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (planner.IsNew && serviceLevel.ItemNumber == null)
            serviceLevel.ItemNumber = planner.SurveyPlannerServiceLevels.Count + 1;

        subpanelSurveyGroupServiceLevel.ObjectPanel.BindObjectToControls(serviceLevel);
    }

    protected void subpanelSurveyGroupServiceLevel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OSurveyPlanner p = panel.SessionObject as OSurveyPlanner;
        panel.ObjectPanel.BindControlsToObject(p);

        OSurveyPlannerServiceLevel serviceLevel = subpanelSurveyGroupServiceLevel.SessionObject as OSurveyPlannerServiceLevel;
        subpanelSurveyGroupServiceLevel.ObjectPanel.BindControlsToObject(serviceLevel);

        p.SurveyPlannerServiceLevels.Add(serviceLevel);

        p.ReorderItems(serviceLevel);

        panel.ObjectPanel.BindObjectToControls(p);

    }

    protected void subpanelSurveyGroupServiceLevel_Removed(object sender, EventArgs e)
    {
        OSurveyPlanner sp = panel.SessionObject as OSurveyPlanner;

        sp.ReorderItems(null);

    }

    /// <summary>
    /// Bind Location controls
    /// </summary>
    /// <param name="rfq"></param>
    protected void BindLocation(OSurveyPlanner sp)
    {
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));

        //dropLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, sp.LocationID));

        //// Default Location and Employer Company
        //// if user is accessiable to 1 location.
        ////
        //if (sp.IsNew && dropLocation.Items.Count == 2)
        //{
        //    sp.LocationID = new Guid(dropLocation.Items[1].Value);
        //}
    }

    //protected void BindSurveyPlanner(OSurveyPlanner sp)
    //{
    //    if (sp.IsNew && sp.SurveyTargetType == null)
    //    {
    //        sp.SurveyTargetType = (int)EnumSurveyTargetType.Tenant;
    //    }
    //    panelEvaluatedParty.Visible = false;

    //    if (sp.SurveyTargetType == (int)EnumSurveyTargetType.Others ||
    //        sp.SurveyTargetType == (int)EnumSurveyTargetType.Tenant)
    //    {
    //        sp.ContractedVendors.Clear();
    //        sp.NonContractedVendors.Clear();
    //    }

    //    panelSurveyPeriod.Visible = 
    //        (sp.SurveyTargetType == (int)EnumSurveyTargetType.ContractedVendor ||
    //        sp.SurveyTargetType == (int)EnumSurveyTargetType.NonContractedVendor);

    //    panelContractedVendors.Visible = (sp.SurveyTargetType == (int)EnumSurveyTargetType.ContractedVendor);

    //    panelNonContractedVendors.Visible = (sp.SurveyTargetType == (int)EnumSurveyTargetType.NonContractedVendor);
    //}


    //protected void radioSurveyTargetType_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    OSurveyPlanner sp = panel.SessionObject as OSurveyPlanner;
    //    panel.ObjectPanel.BindControlsToObject(sp);
    //    BindSurveyPlanner(sp);
    //    panel.ObjectPanel.BindObjectToControls(sp);
    //}

    protected void gridRespondents_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "AddRespondent")
        {
            searchRespondent.Show();
        }
    }

    protected void searchRespondent_Selected(object sender, EventArgs e)
    {
        OSurveyPlanner sp = panel.SessionObject as OSurveyPlanner;
        panel.ObjectPanel.BindControlsToObject(sp);
        foreach (Guid id in searchRespondent.SelectedDataKeys)
        {
            OSurveyRespondentPortfolio portfolio = TablesLogic.tSurveyRespondentPortfolio[id];
            sp.SurveyPlannerRespondents.AddRange(sp.AddSurveyPlannerRespondents(portfolio));
        }
        panel.ObjectPanel.BindObjectToControls(sp);
    }

    //protected void dropSurveyGroup_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    OSurveyPlanner SP = panel.SessionObject as OSurveyPlanner;
    //    panel.ObjectPanel.BindControlsToObject(SP);

    //    OSurveyPlannerServiceLevel serviceLevel = subpanelSurveyGroupServiceLevel.SessionObject as OSurveyPlannerServiceLevel;
    //    subpanelSurveyGroupServiceLevel.ObjectPanel.BindControlsToObject(serviceLevel);

    //    if (serviceLevel.SurveyServiceLevel != null)
    //        serviceLevel.ChecklistID = serviceLevel.SurveyServiceLevel.SurveyChecklistID;

    //    subpanelSurveyGroupServiceLevel.ObjectPanel.BindObjectToControls(serviceLevel);
    //}


    protected void gridSurveys_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ViewSurvey")
        {
            Guid? id = (Guid)dataKeys[0];
            OSurvey S = TablesLogic.tSurvey.Load(id);
            Window.Open(OSurveyPlanner.GenerateSurveyFormURL(S.ObjectID.Value, S.SurveyPlannerID.Value, S.SurveyPlannerRespondent.SurveyRespondentID.Value, S.SurveyPlannerRespondent.SurveyRespondent.EmailAddress, true));//201109
        }
        if (commandName == "LoadSurvey")
        {

        }
    }

    protected void gridSurveyGroupServiceLevel_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ViewChecklist")
        {
            // preview checklist here
            OSurveyPlanner SP = panel.SessionObject as OSurveyPlanner;
            Guid id = (Guid)dataKeys[0];
            OSurveyPlannerServiceLevel SL = SP.SurveyPlannerServiceLevels.Find(id);
            OChecklist CL = SL.Checklist;

            gridChecklist.DataSource = CL.ChecklistItems;
            gridChecklist.DataBind();

            dialogChecklistPreview.Title = CL.ObjectName;

            dialogChecklistPreview.Show();

        }
    }

    protected void gridSurveys_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid id = new Guid(((GridView)sender).DataKeys[e.Row.RowIndex][0].ToString());
            OSurvey S = TablesLogic.tSurvey[id];
            HyperLink label = (HyperLink)e.Row.FindControl("labelClickSurvey");
            if (label != null)
            {
                label.Text = "Click here to take survey";
                label.Font.Bold = true;
                label.Font.Underline = true;
                label.NavigateUrl = OSurveyPlanner.GenerateSurveyFormURL(S.ObjectID.Value, S.SurveyPlannerID.Value, S.SurveyPlannerRespondent.SurveyRespondentID.Value, S.SurveyPlannerRespondent.SurveyRespondent.EmailAddress, false);
                label.Target = "AnacleEAM_SurveyFormLoad";
            }
        }
    }

    protected void subPanelNotification_PopulateForm(object sender, EventArgs e)
    {
        OSurveyPlannerNotification SR = subPanelNotification.SessionObject as OSurveyPlannerNotification;

        subPanelNotification.ObjectPanel.Enabled = (SR.IsDeactivable());

        subPanelNotification.ObjectPanel.BindObjectToControls(SR);

    }

    protected void subPanelNotification_ValidateAndUpdate(object sender, EventArgs e)
    {
        OSurveyPlanner sp = panel.SessionObject as OSurveyPlanner;
        panel.ObjectPanel.BindControlsToObject(sp);

        OSurveyPlannerNotification SR = subPanelNotification.SessionObject as OSurveyPlannerNotification;
        subPanelNotification.ObjectPanel.BindControlsToObject(SR);

        if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyThresholdReached ||
            SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyValidityEnd)
            SR.ScheduledDateTime = null;

        if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyStarted ||
            SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyNotResponded)
            SR.NotificationEmail = null;

        if (SR.SurveyEmailType != (int)EnumSurveyEmailType.SurveyThresholdReached)
            SR.SurveyThreshold = null;

        if (SR.SurveyEmailType != (int)EnumSurveyEmailType.SurveyValidityEnd)
            SR.DaysBeforeValidEnd = null;

        if (SR.ScheduledDateTime != null &&
            SR.ScheduledDateTime > sp.ValidEndDate)
        {
            dateScheduledDateTime.ErrorMessage = "Scheduled Date Time cannot be after than survey closing date.";
            return;
        }

        sp.SurveyPlannerNotifications.Add(SR);


        panel.ObjectPanel.BindObjectToControls(sp);

    }


    protected void subPanelNotification_PreRender(object sender, EventArgs e)
    {
        OSurveyPlannerNotification SR = subPanelNotification.SessionObject as OSurveyPlannerNotification;
        subPanelNotification.ObjectPanel.BindControlsToObject(SR);

        if (SR != null)
        {
            textThreshold.Visible = (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyThresholdReached);

            textDaysBeforeValidEnd.Visible = (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyValidityEnd);

            textNotificationEmail.Visible =
                (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyValidityEnd ||
                SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyThresholdReached);

            dateScheduledDateTime.Visible =
                (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyStarted ||
                SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyNotResponded);



            if (SR.SurveyEmailType == (int)EnumSurveyEmailType.SurveyValidityEnd)
                dateScheduledDateTime.DateTime = dateValidEnd.DateTime;
        }
    }

    protected void radioEmailType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void dateValidEnd_DateTimeChanged(object sender, EventArgs e)
    {

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

            OChecklistItem CLI = TablesLogic.tChecklistItem[id];

            BindSurveyChecklistItem(CLI, e);
        }
    }

    protected void BindSurveyChecklistItem(OChecklistItem SCLI, GridViewRowEventArgs e)
    {
        if (SCLI != null)
        {
            UIFieldLabel l = (UIFieldLabel)e.Row.FindControl("HiddenID");
            if (l != null)
                l.Text = SCLI.ObjectID.Value.ToString();

            if (SCLI.ChecklistType == ChecklistItemType.MultipleSelections)
            {
                UIFieldCheckboxList cbl = (UIFieldCheckboxList)e.Row.FindControl("ChecklistItem_MS_SelectedResponseID");
                if (cbl != null)
                {
                    cbl.Visible = true;
                    cbl.Bind(SCLI.ChecklistResponseSet.ChecklistResponses.Order(
                        TablesLogic.tChecklistResponse.DisplayOrder.Asc));

                    cbl.ValidateRequiredField = (SCLI.IsMandatoryField == 1);


                    if (SCLI.HasSingleTextboxField == 1)
                    {
                        UIFieldTextBox tb = (UIFieldTextBox)e.Row.FindControl("tb_SingleLineFreeText");
                        if (tb != null)
                        {
                            tb.Visible = true;
                        }
                    }

                }
            }
            else if (SCLI.ChecklistType == ChecklistItemType.Choice)
            {
                UIFieldRadioList rl = (UIFieldRadioList)e.Row.FindControl("ChecklistItem_C_SelectedResponseID");
                if (rl != null)
                {
                    rl.Visible = true;
                    rl.Bind(SCLI.ChecklistResponseSet.ChecklistResponses.Order(
                        TablesLogic.tChecklistResponse.DisplayOrder.Asc));
                    rl.ValidateRequiredField = (SCLI.IsMandatoryField == 1);

                    if (SCLI.HasSingleTextboxField == 1)
                    {
                        UIFieldTextBox tb = (UIFieldTextBox)e.Row.FindControl("tb_SingleLineFreeText");
                        if (tb != null)
                        {
                            tb.Visible = true;
                        }
                    }

                }
            }
            else if (SCLI.ChecklistType == ChecklistItemType.Remarks)
            {
                UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("tb_Remarks");
                if (t != null)
                {
                    t.Visible = true;
                    t.ValidateRequiredField = (SCLI.IsMandatoryField == 1);
                }
            }
            else if (SCLI.ChecklistType == ChecklistItemType.SingleLineFreeText)
            {
                UIFieldTextBox tb = (UIFieldTextBox)e.Row.FindControl("tb_SingleLineFreeText");
                if (tb != null)
                {
                    tb.Visible = true;
                    tb.ValidateRequiredField = (SCLI.IsMandatoryField == 1);
                }
            }
        }
    }

    protected void dialogChecklistPreview_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        dialogChecklistPreview.Hide();
    }

    protected void searchRespondent_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        //if (dropLocation.SelectedValue != "")
        //{
        //    OLocation location = TablesLogic.tLocation[new Guid(dropLocation.SelectedValue)];
        //    e.CustomCondition = TablesLogic.tSurveyRespondentPortfolio.Locations.HierarchyPath.Like(location.HierarchyPath + "%");
        //}
    }

    protected void dropLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        //if(dropLocation.SelectedValue!="")
        //{
        //    OSurveyPlanner CurrentSP = (OSurveyPlanner)panel.SessionObject;
        //    panel.ObjectPanel.BindControlsToObject(CurrentSP);
        //    OLocation loc = TablesLogic.tLocation[new Guid(dropLocation.SelectedValue)];
        //    CurrentSP.Locations.Add(loc);
        //    panel.ObjectPanel.BindObjectToControls(CurrentSP);
        //}
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
            ObjectPanelID="tabObject" ShowWorkflowActionAsButtons="true" SaveButtonsVisible="false"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" CssClass="div-form" Caption="Details"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tab_DetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameCaption="Survey Planner Name"
                        ObjectNumberValidateRequiredField="true" ObjectNumberEnabled="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIPanel runat="server" ID="panelDetails" BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelTitleDescription" BorderStyle="NotSet">
                            <%--<ui:UIFieldDropDownList runat="server" ID="dropLocation" Caption="Location"
                                OnSelectedIndexChanged="dropLocation_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIGridView runat="server" ID="gridLocations" PropertyName="Locations" OnAction="gridLocations_Action">
                            <Commands>
                                    <ui:UIGridViewCommand CommandName="DeleteObject" ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you want to remove seleted item(s)?" CommandText="Delete" />
                                </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ImageUrl="~/images/delete.gif"></ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Location" PropertyName="ObjectName" ></ui:UIGridViewBoundColumn>
                            </Columns>
                            </ui:UIGridView>--%>
                            <ui:UIFieldTextBox ID="textSurveyFormTitle1" runat="server" Caption="Survey Form Title 1"
                                PropertyName="SurveyFormTitle1" MaxLength="255" ValidateRequiredField="True"
                                Hint="Max length (255 characters)." ToolTip="Enter survey title 1, this will appear on top of survey. Max length (255 characters)."
                                InternalControlWidth="95%" meta:resourcekey="SurveyFormTitle1Resource1" Width="100%" />
                            <ui:UIFieldTextBox ID="textSurveyFormTitle2" runat="server" Caption="Survey Form Title 2"
                                PropertyName="SurveyFormTitle2" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="SurveyFormTitle2Resource1"
                                Hint="Max length (255 characters)." Width="100%" />
                            <ui:UIFieldTextBox ID="textSurveyFormDescription" runat="server" Caption="Survey Form Description"
                                PropertyName="SurveyFormDescription" Rows="3" TextMode="MultiLine" MaxLength="500"
                                Hint="Max length (1000 characters)." ToolTip="Enter survey description. Max length (1000 characters)."
                                InternalControlWidth="95%" meta:resourcekey="SurveyFormDescriptionResource1"
                                Width="100%" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelOtherDetails" BorderStyle="NotSet">
                            <%--<ui:UIFieldRadioList runat="server" ID="radioSurveyTargetType" PropertyName="SurveyTargetType"
                                Caption="Survey Target Type" Width="100%" ValidateRequiredField="True"
                                RepeatColumns="0" RepeatLayout="Flow" RepeatDirection="Vertical"
                                meta:resourcekey="SurveyTypeResource1" OnSelectedIndexChanged="radioSurveyTargetType_SelectedIndexChanged">
                                <Items>
                                    <asp:ListItem Value="0" Text="Tenant Surveys" Selected="True"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Service Surveys for Non Contracted Vendors"></asp:ListItem>
                                    <asp:ListItem Value="2" Text="Service Surveys for Contracted Vendors"></asp:ListItem>
                                    <asp:ListItem Value="3" Text="Other Surveys"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>--%>
                            <ui:UIFieldDateTime runat="server" ID="dateValidStart" PropertyName="ValidStartDate"
                                Caption="Valid From" Span="Half" Width="49.5%" ImageUrl="~/calendar/date.gif"
                                ValidateRequiredField="True" ValidateCompareField="True" ValidationCompareControl="dateValidEnd"
                                ValidationCompareType="Date" ValidationCompareOperator="LessThanEqual">
                            </ui:UIFieldDateTime>
                        </ui:UIPanel>
                        <ui:UIFieldDateTime runat="server" ID="dateValidEnd" PropertyName="ValidEndDate"
                            Caption="Valid To" Span="Half" Width="49.5%" ImageUrl="~/calendar/date.gif" ValidateRequiredField="false"
                            ValidateCompareField="True" ValidationCompareControl="dateValidStart" ValidationCompareType="Date"
                            ValidationCompareOperator="GreaterThanEqual" OnDateTimeChanged="dateValidEnd_DateTimeChanged">
                        </ui:UIFieldDateTime>
                        <%--<ui:UIPanel runat="server" ID="panelSurveyPeriod" BorderStyle="NotSet">
                            <ui:UIFieldDateTime runat="server" ID="dateSurveyFrom" PropertyName="SurveyStartDate"
                                Caption="Survey From" Span="Half" Width="49.5%" 
                                ImageUrl="~/calendar/date.gif" ValidateRequiredField="True" ValidateCompareField="True"
                                ValidationCompareControl="dateSurveyTo" ValidationCompareType="Date" ValidationCompareOperator="LessThanEqual">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="dateSurveyTo" PropertyName="SurveyEndDate"
                                Caption="Survey To" Span="Half" Width="49.5%" 
                                ImageUrl="~/calendar/date.gif" ValidateRequiredField="True" ValidateCompareField="True"
                                ValidationCompareControl="dateSurveyFrom" ValidationCompareType="Date"
                                ValidationCompareOperator="GreaterThanEqual">
                             </ui:UIFieldDateTime>
                         </ui:UIPanel>--%>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabPlanner" Caption="Survey Service Plan" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelPlanner" BorderStyle="NotSet">
                        <br />
                        <br />
                        <br />
                        <ui:UIPanel runat="server" ID="panelSurveyGroup" BorderStyle="NotSet">
                            <ui:UIGridView runat="server" ID="gridSurveyGroupServiceLevel" PropertyName="SurveyPlannerServiceLevels"
                                ValidateRequiredField="true" SortExpression="ItemNumber ASC" Caption="Service Level"
                                DataKeyNames="ObjectID" AllowPaging="false" OnAction="gridSurveyGroupServiceLevel_Action">
                                <Commands>
                                    <ui:UIGridViewCommand CommandName="DeleteObject" ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you want to remove seleted item(s)?"
                                        CommandText="Delete" />
                                    <ui:UIGridViewCommand CommandName="AddObject" ImageUrl="~/images/add.gif" CommandText="Add" />
                                </Commands>
                                <Columns>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" AlwaysEnabled="true"
                                        ImageUrl="~/images/edit.gif">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ImageUrl="~/images/delete.gif">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Number" PropertyName="ItemNumber">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Service Level Name" PropertyName="ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Survey Checklist" PropertyName="Checklist.ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewChecklist" AlwaysEnabled="true"
                                        ImageUrl="~/images/view.gif">
                                    </ui:UIGridViewButtonColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="objectPanelSurveyGroupServiceLevel" Width="100%"
                                BeginningHtml="" BorderStyle="NotSet" EndingHtml="">
                                <web:subpanel runat="server" ID="subpanelSurveyGroupServiceLevel" GridViewID="gridSurveyGroupServiceLevel"
                                    ObjectPanelID="objectPanelSurveyGroupServiceLevel" UpdatePopupVisible="true"
                                    OnPopulateForm="subpanelSurveyGroupServiceLevel_PopulateForm" OnValidateAndUpdate="subpanelSurveyGroupServiceLevel_ValidateAndUpdate"
                                    OnRemoved="subpanelSurveyGroupServiceLevel_Removed" />
                                <ui:UIFieldDropDownList runat="server" ID="dropServiceLeveItemNumber" PropertyName="ItemNumber"
                                    Caption="Item Number" Width="100%" ValidateRequiredField="True">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldTextBox ID="textServiceLevelName" runat="server" Caption="Service Level Name" ValidateRequiredField="True"
                                    PropertyName="ObjectName" MaxLength="100"
                                    Hint="Max length (100 characters)." ToolTip="Enter survey service level name"
                                    InternalControlWidth="95%" meta:resourcekey="textServiceLevelNameResource1"
                                    Width="100%" />
                                <ui:UIFieldDropDownList runat="server" ID="dropServiceLevelChecklist" PropertyName="ChecklistID"
                                    Caption="Checklist" Width="100%" ValidateRequiredField="True">
                                </ui:UIFieldDropDownList>
                            </ui:UIObjectPanel>
                        </ui:UIPanel>
                        <ui:UIDialogBox runat="server" ID="dialogChecklistPreview" Title="" DialogWidth="700px"
                            Button1AlwaysEnabled="true" Button1AutoClosesDialogBox="true" Button1CausesValidation="false"
                            Button1FontBold="true" Button1Text="Cancel" Button1CommandName="Cancel" OnButtonClicked="dialogChecklistPreview_ButtonClicked">
                            <ui:UIGridView runat="server" ID="gridChecklist" Caption="Questions" CheckBoxColumnVisible="false"
                                CssClass="grid-row" SortExpression="StepNumber" OnRowDataBound="gridChecklist_RowDataBound"
                                BindObjectsToRows="true" GridLines="None" BorderWidth="0px" KeyName="ObjectID"
                                meta:resourcekey="gridChecklistResource1" CaptionWidth="120px" ShowHeader="false"
                                ShowCaption="false" EnableTheming="true" Width="100%" AllowPaging="false" AllowSorting="false"
                                PagingEnabled="false">
                                <Columns>
                                    <ui:UIGridViewBoundColumn HeaderStyle-Width="50px" ItemStyle-Width="40px" PropertyName="StepNumber"
                                        HeaderText="No.">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn ControlStyle-Width="600px" HeaderStyle-Font-Bold="true"
                                        PropertyName="ObjectName" HeaderText="Questions">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewTemplateColumn ControlStyle-Width="410px" ItemStyle-Width="300px" HeaderStyle-Font-Bold="true"
                                        HeaderText="Responses">
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
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIDialogBox>
                        <asp:AnimationExtender ID="OpenAnimation" runat="server" TargetControlID="dialogChecklistPreview">
                            <Animations>
                                <OnClick>
                                    <Sequence>
                                       <%-- Disable the button --%>
                                        
                                       <%-- Show the flyout --%>
                                        <Parallel AnimationTarget="dialog" Duration=".3" Fps="25">
                                            <Move Horizontal="150" Vertical="-50" />
                                            <Resize Height="260" Width="280" />
                                            <Color AnimationTarget="dialog" PropertyKey="backgroundColor"
                                                    StartValue="#AAAAAA" EndValue="#FFFFFF" />
                                        </Parallel>
                                      <%-- Fade in the text --%> 
                                        <FadeIn AnimationTarget="info" Duration=".2"/>
                                      <%-- Cycle the text and border color to red and back --%>
                                        <Parallel AnimationTarget="dialog" Duration=".5">
                                            <Color PropertyKey="color"
                                                    StartValue="#666666" EndValue="#FF0000" />
                                            <Color PropertyKey="borderColor"
                                                    StartValue="#666666" EndValue="#FF0000" />
                                        </Parallel>
                                        <Parallel AnimationTarget="dialog" Duration=".5">
                                            <Color PropertyKey="color"
                                                    StartValue="#FF0000" EndValue="#666666" />
                                            <Color PropertyKey="borderColor"
                                                    StartValue="#FF0000" EndValue="#666666" />
                                            <FadeIn AnimationTarget="dialog" MaximumOpacity=".9" />
                                        </Parallel>
                                    </Sequence>
                                </OnClick>
                            </Animations>
                        </asp:AnimationExtender>
                        <br />
                        <br />
                        <br />
                        <ui:UIPanel runat="server" ID="panelRespondent" BorderStyle="NotSet">
                            <web:searchdialogbox runat='server' ID="searchRespondent" BaseTable="tSurveyRespondentPortfolio"
                                AutoSearchOnLoad="true" AllowMultipleSelection="true" ButtonAddText="Add Address Book"
                                Title="Add the Address Book" MaximumNumberOfResults="100" SearchTextBoxPropertyNames="ObjectName,SurveyRespondents.EmailAddress"
                                OnSelected="searchRespondent_Selected" OnSearched="searchRespondent_Searched">
                                <Columns>
                                    <ui:UIGridViewBoundColumn HeaderText="Name" HeaderStyle-Width="300px" PropertyName="ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="No. of contacts" HeaderStyle-Width="220px"
                                        PropertyName="SurveyRespondents.Count">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Locations" HeaderStyle-Width="210px" PropertyName="LocationsAccess">
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                            </web:searchdialogbox>
                            <ui:UIGridView runat="server" ID="gridRespondents" ValidateRequiredField="true" PropertyName="SurveyPlannerRespondents"
                                BindObjectsToRows="true" Caption="Survey's Respondents" GridLines="Both" DataKeyNames="ObjectID"
                                OnAction="gridRespondents_Action">
                                <Commands>
                                    <ui:UIGridViewCommand CommandName="DeleteObject" ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you want to remove seleted item(s)?"
                                        CommandText="Delete" />
                                    <ui:UIGridViewCommand CommandName="AddRespondent" ImageUrl="~/images/add.gif" CommandText="Add" />
                                </Commands>
                                <Columns>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ImageUrl="~/images/delete.gif">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="E-mail address" PropertyName="SurveyRespondent.EmailAddress">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Name" PropertyName="SurveyRespondent.ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="objectPanelPlannerRespondents" Width="100%"
                                BeginningHtml="" BorderStyle="NotSet" EndingHtml="">
                                <web:subpanel runat="server" ID="subPanelPlannerRespondents" GridViewID="gridRespondents"
                                    ObjectPanelID="objectPanelPlannerRespondents" />
                            </ui:UIObjectPanel>
                        </ui:UIPanel>
                        <br />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabReminder" Caption="Email Notifications" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelReminder" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridNotifications" PropertyName="SurveyPlannerNotifications"
                            Caption="Email Notifications" AllowPaging="false" ValidateRequiredField="true"
                            DataKeyNames="ObjectID">
                            <Commands>
                                <ui:UIGridViewCommand CommandName="DeleteObject" ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you want to remove seleted item(s)?"
                                    CommandText="Delete" />
                                <ui:UIGridViewCommand CommandName="AddObject" ImageUrl="~/images/add.gif" CommandText="Add" />
                            </Commands>
                            <Columns>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" AlwaysEnabled="true"
                                    ImageUrl="~/images/edit.gif">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ImageUrl="~/images/delete.gif">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Created By" PropertyName="CreatedUser">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Notification" PropertyName="SurveyEmailTypeText">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Email(s)" PropertyName="NotificationEmail"
                                    NullDisplayText="Respondents">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Threshold (%)" PropertyName="SurveyThreshold"
                                    NullDisplayText="N.A.">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Sent Date Time" PropertyName="EmailSentDateTime"
                                    DataFormatString="{0:dd-MMM-yyyy hh:mm:ss}">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="objectPanelNotification" Width="100%" BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="subPanelNotification" GridViewID="gridNotifications"
                                ObjectPanelID="objectPanelNotification" OnPopulateForm="subPanelNotification_PopulateForm"
                                OnValidateAndUpdate="subPanelNotification_ValidateAndUpdate" OnPreRender="subPanelNotification_PreRender">
                            </web:subpanel>
                            <ui:UIFieldRadioList runat="server" ID="radioEmailType" Caption="Notification Type"
                                PropertyName="SurveyEmailType" ValidateRequiredField="true" OnSelectedIndexChanged="radioEmailType_SelectedIndexChanged">
                                <Items>
                                    <asp:ListItem Value="0" Text="New / Unsent (send to everyone who has not received an email message yet)"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Not Responded (send to everyone who has received an email message, but has not responded)"></asp:ListItem>
                                    <asp:ListItem Value="2" Text="Threshold Reached (send email when survey responses collected reached threshold)"></asp:ListItem>
                                    <asp:ListItem Value="3" Text="Closing date reached (send email when survey planner reached closing date)"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIFieldDateTime runat="server" ID="dateScheduledDateTime" Caption="Scheduled Date Time"
                                PropertyName="ScheduledDateTime" ValidateRequiredField="true">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldTextBox runat="server" ID="textNotificationEmail" Caption="Recipient(s)"
                                PropertyName="NotificationEmail" ValidateRequiredField="true" Rows="2" TextMode="MultiLine"
                                Hint="Use <font color='red'><b>;</b></font> as the separator. Max length (1000 characters) E.g: john@anacle.com; peter.lim@anacle.com; . . ."
                                MaxLength="1000">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="textThreshold" Caption="Threshold (%)" Span="Half"
                                PropertyName="SurveyThreshold" ValidateRequiredField="true" Hint="Enter % threshold once reached to send email. (1% - 100%)">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="textDaysBeforeValidEnd" Caption="No. of days before valid end"
                                Span="Half" PropertyName="DaysBeforeValidEnd" Hint="Enter no. of days before valid end to send email."
                                ValidateRequiredField="true">
                            </ui:UIFieldTextBox>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabSurveys" Caption="Surveys" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelSurvey" BorderStyle="NotSet">
                        <ui:UIPanel runat="server" ID="panelGridSurveys" BorderStyle="NotSet">
                            <ui:UIGridView runat="server" ID="gridSurveys" CheckBoxColumnVisible="false" PropertyName="Surveys"
                                Caption="Surveys" AllowPaging="false" DataKeyNames="ObjectID" OnAction="gridSurveys_Action"
                                OnRowDataBound="gridSurveys_RowDataBound">
                                <Columns>
                                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewSurvey" AlwaysEnabled="true"
                                        ImageUrl="~/images/view.gif">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Name" PropertyName="SurveyPlannerRespondent.SurveyRespondent.ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="E-mail address" PropertyName="SurveyPlannerRespondent.SurveyRespondent.EmailAddress">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Last Invited" PropertyName="SurveyInvitedDateTime"
                                        DataFormatString="{0:dd-MMM-yyyy hh:mm:ss}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Responded Date Time" PropertyName="SurveyRespondedDateTime"
                                        DataFormatString="{0:dd-MMM-yyyy hh:mm:ss}">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Status" PropertyName="SurveyStatusType">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewTemplateColumn>
                                        <ItemTemplate>
                                            <asp:HyperLink runat="server" ID="labelClickSurvey"></asp:HyperLink>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>
                                </Columns>
                            </ui:UIGridView>
                        </ui:UIPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabProgress" Caption="Progress" BorderStyle="NotSet">
                    <br />
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelProgress" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridProgress" CheckBoxColumnVisible="false" PropertyName="SurveyProgress"
                            Caption="Survey Progress" AllowPaging="false" DataKeyNames="ObjectID">
                            <RowStyle Height="50px" HorizontalAlign="Center" VerticalAlign="Middle" Font-Size="Small" />
                            <Columns>
                                <ui:UIGridViewBoundColumn HeaderText="Total Surveys invited" PropertyName="TotalSurvey">
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Total Responses" PropertyName="TotalResponse">
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Last Response Date" PropertyName="LastResponseDateTime"
                                    DataFormatString="{0:dd-MMM-yyyy hh:mm:ss}">
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="% of total responses" PropertyName="TotalResponsePercentage"
                                    DataFormatString="{0:#,##0.00}%">
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabHistory" Caption="Activity History">
                    <web:ActivityHistory runat="server" ID="webHistory" />
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
