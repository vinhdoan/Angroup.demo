<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OVendorEvaluation eval = (OVendorEvaluation)panel.SessionObject;
        treeChecklist.PopulateTree();
        dropVendor.Bind(OVendor.GetVendors(DateTime.Today, eval.VendorID));
        dropContract.Bind(OContract.GetContractsByVendor(eval, eval.ContractID), "ContractNumberWithContractName", "ObjectID");
        
        panel.ObjectPanel.BindObjectToControls(eval);
    }

    

    protected override void OnPreRender(EventArgs e)
    {
        OVendorEvaluation eval = (OVendorEvaluation)panel.SessionObject;        
        base.OnPreRender(e);

        if (objectBase.GetWorkflowRadioListItem("Cancel") != null)
            objectBase.GetWorkflowRadioListItem("Cancel").Enabled = false;

        panelDetails.Enabled = objectBase.CurrentObjectState.Is("Draft", "Start");
        
        if (eval.IsApproved == 1)
            panel.DisablePage();

        //foreach (ListItem item in OverallAssessment.Items)
        //{
        //    if(item.Selected)
        //        item.Attributes.CssStyle.Add("color", "blue");
        //    else
        //        item.Attributes.CssStyle.Add("color", "black");
        //}

        if (!gridChecklistItem.IsContainerEnabled())
        {
            foreach (GridViewRow gvr in gridChecklistItem.Rows)
            {
                UIFieldRadioList r = (UIFieldRadioList)gvr.FindControl("ChecklistItem_SelectedResponseID");
                if (r != null)
                {
                    foreach (ListItem LI in r.Items)
                    {
                        if (LI.Selected)
                        {
                            LI.Attributes.CssStyle.Add("color", "blue");
                            if (LI.Text.Is("Very Poor", "Poor"))
                                LI.Attributes.CssStyle.Add("color", "red");
                            else if (LI.Text.Is("N.A."))
                                LI.Attributes.CssStyle.Add("color", "green");
                            else
                                LI.Attributes.CssStyle.Add("color", "blue");
                            LI.Attributes.CssStyle.Add("font-weight", "bold");
                        }
                        
                    }
                }
            }
        }
    }
    
    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using(Connection c = new Connection())
        {
            OVendorEvaluation eval = (OVendorEvaluation)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(eval);

            //decimal? totalScore = null;
            //decimal count = 0;
            //foreach (OVendorEvaluationChecklistItem item in eval.VendorEvaluationChecklistItems)
            //{
            //    count += 1;
                
            //    if (item.SelectedResponse != null && item.SelectedResponse.ScoreNumerator != null)
            //        totalScore = IsNull(totalScore, 0) + item.SelectedResponse.ScoreNumerator.Value;
            //}

            //if (totalScore != null)
            //    eval.OverallAssessment = (int)Math.Round((totalScore.Value / count), MidpointRounding.AwayFromZero);
            

            if (!panel.ObjectPanel.IsValid)
                return;

            //if (eval.IsNew)
            //    eval.CreatedUserID = AppSession.User.ObjectID;
            
            eval.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Constructs and returns the check list tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Checklist_AcquireTreePopulater(object sender)
    {
        OVendorEvaluation eval = panel.SessionObject as OVendorEvaluation;
        return new ChecklistTreePopulater(eval.ChecklistID, false, true, ChecklistType.Work);
    }

    /// <summary>
    /// Occurs when user selects a check list in the check list tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Checklist_SelectedNodeChanged(object sender, EventArgs e)
    {
        // update the checklist
        //
        OVendorEvaluation eval = (OVendorEvaluation)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(eval);
        eval.UpdateChecklist();
        panel.ObjectPanel.BindObjectToControls(eval);
    }

    protected void gridChecklistItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid id = (Guid)gridChecklistItem.DataKeys[e.Row.DataItemIndex][0];
            OVendorEvaluation eval = (OVendorEvaluation)panel.SessionObject;
            OVendorEvaluationChecklistItem item = (OVendorEvaluationChecklistItem)eval.VendorEvaluationChecklistItems.FindObject(id);
            
            if (item != null)
            {
                if (item.ChecklistType == ChecklistItemType.Choice)
                {
                    UIFieldRadioList r = (UIFieldRadioList)e.Row.FindControl("ChecklistItem_SelectedResponseID");
                    if (r != null)
                    {
                        r.Visible = true;
                        if (item.ChecklistResponseSet != null)
                        {
                            r.Bind(item.ChecklistResponseSet.ChecklistResponses.Order(
                                TablesLogic.tChecklistResponse.DisplayOrder.Asc));

                            foreach (ListItem LI in r.Items)
                            {
                                if (new Guid(LI.Value) == item.SelectedResponseID)
                                {
                                    LI.Selected = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                if (item.ChecklistType == ChecklistItemType.Remarks)
                {
                    UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("ChecklistItem_Description");
                    if (t != null)
                    {
                        t.Visible = true;
                        t.Text = item.Description;
                    }
                }
            }
        }
    }


    protected void treeChecklist_SelectedNodeChanged(object sender, EventArgs e)
    {
        OVendorEvaluation eval = panel.SessionObject as OVendorEvaluation;
        panel.ObjectPanel.BindControlsToObject(eval);
        if (treeChecklist.SelectedValue != "")
        {
            eval.ChecklistID = new Guid(treeChecklist.SelectedValue);
            eval.UpdateChecklist();
        }
        panel.ObjectPanel.BindObjectToControls(eval);
        
    }

    protected void dropVendor_SelectedIndexChanged(object sender, EventArgs e)
    {

        OVendorEvaluation eval = panel.SessionObject as OVendorEvaluation;
        panel.ObjectPanel.BindControlsToObject(eval);
        if (dropVendor.SelectedValue != "")
            dropContract.Bind(OContract.GetContractsByVendor(eval, eval.ContractID), "ContractNumberWithContractName", "ObjectID");

        panel.ObjectPanel.BindObjectToControls(eval);            
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Vendor Evaluation" BaseTable="tVendorEvaluation" 
                ShowWorkflowActionAsButtons="true" SaveButtonsVisible="false"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" >
                    <ui:UITabView ID="tabDetails" runat="server"  Caption="Details">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false"
                            ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1">
                        </web:base>
                            
                        <ui:UIPanel ID="panelDetails" runat="server">
                        <ui:UIFieldDateTime runat='server' ID="dateStart" Caption="Start" ValidateRequiredField="true" PropertyName="StartDate" SelectMonthYear="true" Span="Half"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat='server' ID="dateEnd" Caption="End" ValidateRequiredField="true" PropertyName="EndDate" SelectMonthYear="true" Span="Half"></ui:UIFieldDateTime>
                        <ui:UIFieldSearchableDropDownList ID="dropVendor" runat="server" Caption="Vendor"
                            PropertyName="VendorID" Span="Full" ValidateRequiredField="true" OnSelectedIndexChanged="dropVendor_SelectedIndexChanged">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldSearchableDropDownList runat="server" ID="dropContract" Caption="Contract"
                            PropertyName="ContractID" ValidateRequiredField="true">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="textEvaluationRemarks" PropertyName="EvaluationRemarks" Caption="Evaluation Description" TextMode="MultiLine" Rows="4"></ui:UIFieldTextBox>
                        
                        <ui:UIFieldTreeList runat="server" ID="treeChecklist" Caption="Checklist" 
                            PropertyName="ChecklistID" 
                            OnAcquireTreePopulater="Checklist_AcquireTreePopulater" 
                            meta:resourcekey="ChecklistResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode" OnSelectedNodeChanged="treeChecklist_SelectedNodeChanged" />
                    <br />
                    <ui:UIGridView runat="server" ID="gridChecklistItem" Caption="Checklist" 
                        CheckBoxColumnVisible="False" PropertyName="VendorEvaluationChecklistItems" 
                        SortExpression="StepNumber" OnRowDataBound="gridChecklistItem_RowDataBound" 
                        BindObjectsToRows="True" KeyName="ObjectID"
                        meta:resourcekey="gridChecklistResource1" Width="100%" DataKeyNames="ObjectID" 
                        GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewBoundColumn DataField="StepNumber" HeaderText="No." PropertyName="StepNumber" 
                                ResourceAssemblyName="" SortExpression="StepNumber">
                                <HeaderStyle HorizontalAlign="Left" Width="50"/>
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Description" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" Width="40%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Evaluation" HeaderStyle-Font-Bold="true">
                                <ItemTemplate>
                                    <ui:UIFieldRadioList ID="ChecklistItem_SelectedResponseID" runat="server" RepeatLayout="Flow" ShowCaption="false" FieldLayout="Flow" 
                                        CaptionWidth="1px" meta:resourceKey="SelectedResponseIDResource1" PropertyName="SelectedResponseID"
                                        RepeatColumns="0" TextAlign="Right" Visible="False" ValidateRequiredField="true">
                                    </ui:UIFieldRadioList>
                                    <ui:UIFieldTextBox ID="ChecklistItem_Description" runat="server" PropertyName="Description"
                                        CaptionWidth="1px" InternalControlWidth="95%" MaxLength="255" 
                                        meta:resourcekey="ChecklistItem_DescriptionResource1" Visible="False">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <br />
                    <br />
                    </ui:UIPanel>                    
                    
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Status History" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview1Resource2">
                        <web:ActivityHistory runat="server" ID="ActivityHistory" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments"  Caption="Attachments">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
