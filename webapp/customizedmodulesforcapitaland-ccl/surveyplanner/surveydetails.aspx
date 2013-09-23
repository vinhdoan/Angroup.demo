<%@ Page Language="C#" AutoEventWireup="true" Inherits="PageBase" Culture="auto"
    meta:resourcekey="PageResource1" UICulture="auto" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    OSurvey S = null;
    OSurveyPlanner SP = null;

    protected void form1_OnLoad(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request["SK1"] != null && Request["SK2"] != null)
            {
                S = (OSurvey)Session[Security.Decrypt(Request["SK1"])];
                SP = (OSurveyPlanner)Session[Security.Decrypt(Request["SK2"])];
                SubGV_SurveyLocationResponseTos.Visible = (SP.SurveyType != SurveyTargetType.SurveyContractedVendorEvaluatedByMA);

                MainPanel.BindObjectToControls(S);
            }
        }
    }

    protected void SubGV_SurveyLocationResponseTos_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HyperLink hl_ChecklistForm = (HyperLink)e.Row.FindControl("hl_ChecklistForm");
            Guid id = (Guid)((GridView)sender).DataKeys[e.Row.RowIndex][0];
            OSurvey CurrentS = S;
            OSurveyResponseTo CurrentSRT = (OSurveyResponseTo)S.SurveyResponseTos.FindObject(id);

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
                OSurvey CurrentS = S;
                OSurveyResponseFrom CurrentSRF = (OSurveyResponseFrom)S.SurveyResponseFroms.FindObject(id);
                hl_SurveyForm.Text = "Preview Survey Form";

                List<OSurveyResponseTo> list = CurrentS.SurveyResponseTos.Order(TablesLogic.tSurveyResponseTo.DisplayOrder.Asc);

                if (list != null && hl_SurveyForm != null)
                {
                    Session[CurrentS.ObjectID.Value.ToString()] = list;

                    hl_SurveyForm.NavigateUrl = Request.ApplicationPath + "/modules/surveyplanner/surveyformpreview.aspx?SID=" +
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentS.ObjectID.Value)) + "&SRFID=" +
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentSRF.ObjectID.Value));
                    hl_SurveyForm.Target = "AnacleEAM_SurveyFormPreview";
                }

                HyperLink hl_ActualSurveyForm = (HyperLink)e.Row.FindControl("hl_ActualSurveyForm");
                OSurveyPlanner CurrentSP = SP;
                if (hl_ActualSurveyForm != null && CurrentSP.IsNew == false && CurrentSP.CurrentActivity != null &&
                    CurrentSP.CurrentActivity.ObjectName != "Draft" &&
                    CurrentSP.CurrentActivity.ObjectName != "Cancel")
                {
                    hl_ActualSurveyForm.Text = "Load Survey Form";
                    hl_ActualSurveyForm.NavigateUrl = Request.ApplicationPath + "/modules/surveyplanner/surveyformload.aspx?SPID=" +
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentSP.ObjectID.Value)) + "&SRPID=" +//201109
                        HttpUtility.UrlEncode(Security.EncryptGuid(CurrentSRF.SurveyRespondent.SurveyRespondentPortfolioID.Value)) + "&REA=" +//201109
                        HttpUtility.UrlEncode(Security.Encrypt(CurrentSRF.EmailAddress));

                    //hl_ActualSurveyForm.NavigateUrl = OSurveyPlanner.GenerateSurveyFormURL(CurrentSP.ObjectID.Value, CurrentSRF.SurveyRespondentPortfolio.SurveyRespondentID.Value, CurrentSRF.EmailAddress);
                    hl_ActualSurveyForm.Target = "AnacleEAM_SurveyFormLoad";
                }
            }
        }
        catch (Exception ex)
        {
        }
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Survey Details</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Classy/dragdrop.css" type="text/css" rel="stylesheet" />
    <link href="../../App_Themes/Classy/StyleSheet.css" type="text/css" rel="stylesheet" />
</head>
<body style="background-color: white; padding: 8px 8px 8px 8px">
    <form id="form1" runat="server" onload="form1_OnLoad" style="width: 99%">
    <div style="width: 100%">
        <ui:UIObjectPanel runat="server" ID="MainPanel" Width="100%" Style="background-color: white;
            border: none" BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="MainPanelResource1">
            <ui:UIGridView runat="server" ID="SubGV_SurveyLocationResponseFroms" AllowPaging="False"
                PropertyName="SurveyResponseFroms" CheckBoxColumnVisible="False" Caption="Respondent Details"
                AllowSorting="False" OnRowDataBound="SubGV_SurveyLocationResponseFroms_RowDataBound"
                DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="SubGV_SurveyLocationResponseFromsResource1"
                RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Columns>
                    <cc1:UIGridViewTemplateColumn HeaderText="Actual Survey Form" meta:resourcekey="UIGridViewTemplateColumnResource1">
                        <ItemTemplate>
                            <asp:HyperLink ID="hl_ActualSurveyForm" runat="server" meta:resourcekey="hl_ActualSurveyFormResource1"></asp:HyperLink>
                        </ItemTemplate>
                        <ControlStyle Width="10%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewTemplateColumn>
                    <cc1:UIGridViewTemplateColumn HeaderText="Survey Form" meta:resourcekey="UIGridViewTemplateColumnResource2">
                        <ItemTemplate>
                            <asp:HyperLink ID="hl_SurveyForm" runat="server" meta:resourcekey="hl_SurveyFormResource1"></asp:HyperLink>
                        </ItemTemplate>
                        <ControlStyle Width="10%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewTemplateColumn>
                    <cc1:UIGridViewBoundColumn DataField="SurveyRespondentPortfolio.SurveyTypeText" HeaderText="Portfolio Type"
                        meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="SurveyRespondentPortfolio.SurveyTypeText"
                        ResourceAssemblyName="" SortExpression="SurveyRespondentPortfolio.SurveyTypeText">
                        <ControlStyle Width="20%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="SurveyRespondentPortfolio.SurveyRespondent.ObjectName"
                        HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="SurveyRespondentPortfolio.SurveyRespondent.ObjectName"
                        ResourceAssemblyName="" SortExpression="SurveyRespondentPortfolio.SurveyRespondent.ObjectName">
                        <ControlStyle Width="30%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="EmailAddress" HeaderText="Email" meta:resourcekey="UIGridViewBoundColumnResource3"
                        PropertyName="EmailAddress" ResourceAssemblyName="" SortExpression="EmailAddress">
                        <ControlStyle Width="30%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="SurveyRespondent.SurveyRespondentPortfolioID"
                        HeaderText="SRPID" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="SurveyRespondent.SurveyRespondentPortfolioID"
                        ResourceAssemblyName="" SortExpression="SurveyRespondent.SurveyRespondentPortfolioID">
                        <ControlStyle Width="30%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
            <br />
            <ui:UIGridView runat="server" ID="SubGV_SurveyLocationResponseTos" AllowPaging="False"
                Caption="Evaluated Party Details" PropertyName="SurveyResponseTos" CheckBoxColumnVisible="False"
                AllowSorting="False" SortExpression="DisplayOrder ASC, Contract.ContractStartDate ASC"
                OnRowDataBound="SubGV_SurveyLocationResponseTos_RowDataBound" DataKeyNames="ObjectID"
                GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="SubGV_SurveyLocationResponseTosResource1"
                RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Columns>
                    <cc1:UIGridViewBoundColumn DataField="DisplayOrder" HeaderText="Display Order" meta:resourcekey="UIGridViewBoundColumnResource5"
                        PropertyName="DisplayOrder" ResourceAssemblyName="" SortExpression="DisplayOrder">
                        <ControlStyle Width="1%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="SurveyTrade.SurveyGroup.ObjectName" HeaderText="Trade"
                        meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="SurveyTrade.SurveyGroup.ObjectName"
                        ResourceAssemblyName="" SortExpression="SurveyTrade.SurveyGroup.ObjectName">
                        <ControlStyle Width="1%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewTemplateColumn HeaderText="Checklist" meta:resourcekey="UIGridViewTemplateColumnResource3">
                        <ItemTemplate>
                            <asp:HyperLink ID="hl_ChecklistForm" runat="server" meta:resourcekey="hl_ChecklistFormResource1"></asp:HyperLink>
                        </ItemTemplate>
                        <ControlStyle Width="23%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewTemplateColumn>
                    <cc1:UIGridViewBoundColumn DataField="Contract.ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource7"
                        PropertyName="Contract.ObjectName" ResourceAssemblyName="" SortExpression="Contract.ObjectName">
                        <ControlStyle Width="15%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="EvaluatedParty" HeaderText="Vendor" meta:resourcekey="UIGridViewBoundColumnResource8"
                        PropertyName="EvaluatedParty" ResourceAssemblyName="" SortExpression="EvaluatedParty">
                        <ControlStyle Width="15%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Contract.ContractStartDate" DataFormatString="{0:dd-MMM-yyyy}"
                        HeaderText="Start Date" meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="Contract.ContractStartDate"
                        ResourceAssemblyName="" SortExpression="Contract.ContractStartDate">
                        <ControlStyle Width="15%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Contract.ContractEndDate" DataFormatString="{0:dd-MMM-yyyy}"
                        HeaderText="End Date" meta:resourcekey="UIGridViewBoundColumnResource10" PropertyName="Contract.ContractEndDate"
                        ResourceAssemblyName="" SortExpression="Contract.ContractEndDate">
                        <ControlStyle Width="15%" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
        </ui:UIObjectPanel>
    </div>
    </form>
</body>
</html>
