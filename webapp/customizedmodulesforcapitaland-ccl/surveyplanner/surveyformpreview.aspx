<%@ Page Language="C#" AutoEventWireup="true" Inherits="PageBase" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected void form1_OnLoad(object sender, EventArgs e)
    {
        if (Request["SID"] != null)
        {
            Guid SID = Security.DecryptGuid(Request["SID"]);
            OSurvey survey = TablesLogic.tSurvey.Load(SID);
            
            //Guid SRFID = Security.DecryptGuid(Request["SRFID"]);
            //List<OSurveyResponseTo> list = (List<OSurveyResponseTo>)Session[SID.ToString()];

            OSurveyPlanner SP = (OSurveyPlanner)Session["::SessionObject::"];
            lbl_Title_1.Text = SP.SurveyFormTitle1;
            lbl_Title_2.Text = SP.SurveyFormTitle2;
            lbl_SurveyFormDescription.Text = SP.SurveyFormDescription;

            Hashtable ht_ChecklistResult = new Hashtable();
            DataTable dt0 = new DataTable();
            dt0.Columns.Add("ChecklistID");
            dt0.Columns.Add("SurveyTradeID");
            dt0.Columns.Add("EvaluatedParty");

            //foreach (OSurveyResponseTo SRT in list)
            foreach (OSurveyGroupServiceLevel level in survey.SurveyGroupServiceLevels)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("ObjectID");
                dt.Columns.Add("ChecklistID");
                dt.Columns.Add("SurveyID");
                dt.Columns.Add("ChecklistName");
                dt.Columns.Add("SurveyTradeName");
                dt.Columns.Add("EvaluatedParty");
                dt.Columns.Add("StepNumber", typeof(int));
                dt.Columns.Add("ObjectName");
                dt.Columns.Add("ChecklistItemType");

                //if (SRT != null && SRT.Checklist != null)
                if (survey.SurveyChecklistItems.Count > 0)
                {
                    // Construct checklist form
                    //
                    //OChecklist CL = SRT.Checklist;
                    OChecklist CL = level.Checklist;
                    //List<OSurveyChecklistItem> ListOfSCLI = new List<OSurveyChecklistItem>();

                    //foreach (OChecklistItem CLI in CL.ChecklistItems)
                    foreach (OSurveyChecklistItem CLI in survey.SurveyChecklistItems)
                    {
                        if (CLI.SurveyGroupServiceLevelID == level.ObjectID)
                        {
                            dt.Rows.Add(
                                CLI.ObjectID,
                                CL.ObjectID,
                                survey.ObjectID,
                                CL.ObjectName,
                                level.SurveyGroup.ObjectName,
                                level.SurveyGroup.ObjectName,
                                CLI.StepNumber,
                                CLI.ObjectName,
                                CLI.ChecklistItemType
                                );
                        }
                    }
                    
                    if (dt.Rows.Count > 0)
                    {

                        ht_ChecklistResult[CL.ObjectID.Value.ToString() + "::" + level.ObjectID.Value.ToString() + "::" + level.SurveyGroup.ObjectName] = dt;
                        dt0.Rows.Add(CL.ObjectID,
                            level.ObjectID,
                            level.SurveyGroup.ObjectName
                            );
                    }
                }

            }
            Session["ChecklistResult"] = ht_ChecklistResult;
            GridResult.DataSource = dt0;
            GridResult.DataBind();
        }
    }

    protected void gridChecklist_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
            Guid id = new Guid(((GridView)sender).DataKeys[e.Row.RowIndex][0].ToString());
            //OChecklist CL = TablesLogic.tChecklist[new Guid(((DataRowView)e.Row.DataItem)["ChecklistID"].ToString())];
            OSurvey CL = TablesLogic.tSurvey[new Guid(((DataRowView)e.Row.DataItem)["SurveyID"].ToString())];
            OSurveyChecklistItem item = (OSurveyChecklistItem)CL.SurveyChecklistItems.FindObject(id);

            if (item != null)
            {
                if (item.ChecklistItemType == ChecklistItemType.MultipleSelections)
                {
                    UIFieldCheckboxList cbl = (UIFieldCheckboxList)e.Row.FindControl("ChecklistItem_MS_SelectedResponseID");
                    if (cbl != null)
                    {
                        cbl.Visible = true;
                        cbl.Bind(item.ChecklistResponseSet.ChecklistResponses.Order(
                            TablesLogic.tChecklistResponse.DisplayOrder.Asc));
                        cbl.ValidateRequiredField = (item.IsMandatoryField == 1);
                    }
                }
                else if (item.ChecklistItemType == ChecklistItemType.Choice)
                {
                    UIFieldRadioList rl = (UIFieldRadioList)e.Row.FindControl("ChecklistItem_C_SelectedResponseID");
                    if (rl != null)
                    {
                        rl.Visible = true;
                        rl.Bind(item.ChecklistResponseSet.ChecklistResponses.Order(
                            TablesLogic.tChecklistResponse.DisplayOrder.Asc));
                        rl.ValidateRequiredField = (item.IsMandatoryField == 1);
                    }
                }
                else if (item.ChecklistItemType == ChecklistItemType.Remarks)
                {
                    UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("tb_Remarks");
                    if (t != null)
                    {
                        t.Visible = true;
                        t.ValidateRequiredField = (item.IsMandatoryField == 1);
                    }
                }
                else if (item.ChecklistItemType == ChecklistItemType.SingleLineFreeText)
                {
                    UIFieldTextBox tb = (UIFieldTextBox)e.Row.FindControl("tb_SingleLineFreeText");
                    if (tb != null)
                    {
                        tb.Visible = true;
                        tb.ValidateRequiredField = (item.IsMandatoryField == 1);
                    }
                }
            }
        }
    }

    protected void GridResult_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            string ChecklistID = ((DataRowView)e.Item.DataItem)["ChecklistID"].ToString();
            string SurveyTradeID = ((DataRowView)e.Item.DataItem)["SurveyTradeID"].ToString();
            string EvaluatedParty = ((DataRowView)e.Item.DataItem)["EvaluatedParty"].ToString();

            Hashtable ht_Checklist = (Hashtable)Session["ChecklistResult"];
            DataTable dt = (DataTable)ht_Checklist[ChecklistID + "::" + SurveyTradeID + "::" + EvaluatedParty];

            UIFieldLabel labelChecklistName = ((UIFieldLabel)e.Item.FindControl("lbl_ChecklistName"));
            UIFieldLabel labelServiceLevel = ((UIFieldLabel)e.Item.FindControl("lbl_SurveyTradeName"));
            UIFieldLabel labelVendor = ((UIFieldLabel)e.Item.FindControl("lbl_VendorName"));
            
            
            labelChecklistName.Text = (dt != null && dt.Rows.Count > 0 ? dt.Rows[0]["ChecklistName"].ToString() : "");
            labelServiceLevel.Text = (dt != null && dt.Rows.Count > 0 ? dt.Rows[0]["SurveyTradeName"].ToString() : "");
            labelVendor.Text = EvaluatedParty;
            ((UIGridView)e.Item.FindControl("gridChecklist")).Bind(dt);
        }
    }

    protected void Page_LoadComplete(object sender, EventArgs e)
    {
        Session["ChecklistResult"] = null;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Survey Form Preview</title>
</head>
<body style="background-color: white; padding: 8px 8px 8px 8px">
    <form id="form1" runat="server" onload="form1_OnLoad" style="width: 793px">
    <div style="width: 793px">
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
                                <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_ChecklistName" Caption="Checklist"
                                    PropertyName="ObjectName" />
                                <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_SurveyTradeName" Caption="Service Level"
                                    PropertyName="" />
                                <ui:UIFieldLabel runat="server" Span="Full" ID="lbl_VendorName" Caption="Evaluated Party"
                                    PropertyName="" />
                                <ui:UIGridView runat="server" ID="gridChecklist" Caption="Checklist" CheckBoxColumnVisible="false"
                                    PropertyName="ChecklistItems" SortExpression="StepNumber" OnRowDataBound="gridChecklist_RowDataBound"
                                    BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="gridChecklistResource1"
                                    CaptionWidth="120px" Width="100%" AllowPaging="false" AllowSorting="false" PagingEnabled="false">
                                    <Columns>
                                        <ui:UIGridViewBoundColumn ControlStyle-Width="30px" PropertyName="StepNumber" HeaderText="Step">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn ControlStyle-Width="300px" PropertyName="ObjectName" HeaderText="Description">
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewTemplateColumn ControlStyle-Width="460px" HeaderText="Answer">
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
                                            </ItemTemplate>
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewTemplateColumn ControlStyle-Width="250px" HeaderText="Remarks" Visible="false">
                                            <ItemTemplate>
                                                <ui:UIFieldLabel Visible="true" runat="server" ID="ChecklistItem_Description" CaptionWidth="1px"
                                                    Span="full" Height="40px">
                                                </ui:UIFieldLabel>
                                            </ItemTemplate>
                                        </ui:UIGridViewTemplateColumn>
                                    </Columns>
                                </ui:UIGridView>
                                <br />
                            </ItemTemplate>
                        </asp:DataList>
                    </td>
                </tr>
            </table>
        </ui:UIPanel>
    </div>
    </form>
</body>
</html>
