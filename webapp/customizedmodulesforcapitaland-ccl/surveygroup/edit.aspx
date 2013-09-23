<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OSurveyServiceLevel surveyGroup = (OSurveyServiceLevel)panel.SessionObject;

        dropSurveyChecklist.Bind(OChecklist.GetSurveyChecklist());
        
        if (surveyGroup.SurveyChecklist != null)
        {
            OChecklist CL = surveyGroup.SurveyChecklist;
            gridChecklist.DataSource = CL.ChecklistItems;
            gridChecklist.DataBind();
        }
        
        panel.ObjectPanel.BindObjectToControls(surveyGroup);
    }


    /// <summary>
    /// Saves the survey group to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OSurveyServiceLevel surveyGroup = (OSurveyServiceLevel)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(surveyGroup);

            surveyGroup.Save();
            c.Commit();
        }
    }

    protected void DefaultSurveyChecklistID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyServiceLevel surveyGroup = (OSurveyServiceLevel)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(surveyGroup);

        if (surveyGroup.SurveyChecklist != null)
        {
            OChecklist CL = surveyGroup.SurveyChecklist;
            gridChecklist.DataSource = CL.ChecklistItems;
            gridChecklist.DataBind();
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
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BeginningHtml="" BorderStyle="NotSet"
        EndingHtml="" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Survey Group" BaseTable="tSurveyServiceLevel"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Survey Group Name" 
                        ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIPanel runat="server" ID="panel_ContractGroup" BeginningHtml="" BorderStyle="NotSet"
                        EndingHtml="" meta:resourcekey="panel_ContractGroupResource1">
                        <br />
                        <%--<ui:UIFieldRadioList runat="server" ID="radioSurveyTargetType" PropertyName="SurveyTargetType"
                            Caption="Survey Target Type" Width="100%" ValidateRequiredField="True"
                            RepeatColumns="0" RepeatLayout="Flow" RepeatDirection="Vertical"
                            meta:resourcekey="SurveyTypeResource1">
                            <Items>
                                <asp:ListItem Value="0" Text="Surveys for Tenants" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Surveys for Non Contracted Vendor"></asp:ListItem>
                                <asp:ListItem Value="2" Text="Surveys for Contracted Vendor"></asp:ListItem>
                                <asp:ListItem Value="3" Text="Surveys for Other Reasons"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>--%>
                        <ui:UIFieldDropDownList runat="server" ID="dropSurveyChecklist" PropertyName="SurveyChecklistID"
                            Caption="Default Survey Checklist" ValidateRequiredField="True" 
                            OnSelectedIndexChanged="DefaultSurveyChecklistID_SelectedIndexChanged"
                            meta:resourcekey="DefaultSurveyChecklistIDResource1">
                        </ui:UIFieldDropDownList>
                        <br /><br />
                        <ui:UIGridView runat="server" ID="gridChecklist" Caption="Questions" CheckBoxColumnVisible="false" CssClass="grid-row"
                            SortExpression="StepNumber" OnRowDataBound="gridChecklist_RowDataBound" BindObjectsToRows="true" GridLines="None" BorderWidth="0px"
                            KeyName="ObjectID" meta:resourcekey="gridChecklistResource1" CaptionWidth="120px" ShowHeader="true" ShowCaption="false" EnableTheming="true"
                            Width="100%" AllowPaging="false" AllowSorting="false" Enabled="false">
                            <Columns>
                                <ui:UIGridViewBoundColumn HeaderStyle-Width="50px" ItemStyle-Width="40px" PropertyName="StepNumber" HeaderText="No.">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn ControlStyle-Width="600px" HeaderStyle-Font-Bold="true" PropertyName="ObjectName" HeaderText="Questions">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn ControlStyle-Width="410px" ItemStyle-Width="300px" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Font-Bold="true" HeaderText="Responses">
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
                        <br />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" BeginningHtml=""
                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
