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
    protected void form_OnLoad(object sender, EventArgs e)
    {
        if (Request["CLID"] != null)
        {
            lbl_Date.ControlValue = string.Format("{0:dd-MMM-yyyy}", DateTime.Today);
            OChecklist CL = TablesLogic.tChecklist[Security.DecryptGuid(Request["CLID"])];
            OContract C = TablesLogic.tContract[Security.DecryptGuid(Request["CID"])];
            int ContractMandatory = Convert.ToInt32(Security.Decrypt(Request["CM"]));
            string EvaluatedPayeeName = Security.Decrypt(Request["EPN"]);
            OCode CG = TablesLogic.tCode[Security.DecryptGuid(Request["CGID"])];

            if (CL != null)
            {
                // Construct survey checklist form
                //
                List<OSurveyChecklistItem> ListOfSCLI = new List<OSurveyChecklistItem>();
                List<OChecklistItem> ListOfCLI = CL.ChecklistItems.Order(TablesLogic.tChecklistItem.StepNumber.Asc);

                foreach (OChecklistItem CLI in ListOfCLI)
                {
                    OSurveyChecklistItem SCLI = TablesLogic.tSurveyChecklistItem.Create();
                    SCLI.ObjectName = CLI.ObjectName;
                    SCLI.StepNumber = CLI.StepNumber;
                    SCLI.ChecklistItemType = CLI.ChecklistType;
                    SCLI.IsOverall = CLI.IsOverall;
                    ListOfSCLI.Add(SCLI);
                }

                if (ContractMandatory == 1)
                {
                    if (C == null)
                        throw new Exception("Selected contract not found!");

                    lbl_VendorName.Text = (C.Vendor != null ? C.Vendor.ObjectName : "Vendor not found!");
                }
                else
                {
                    lbl_VendorName.Text = EvaluatedPayeeName;
                }

                lbl_SurveyTradeName.Text = (CG != null ? CG.ObjectName : "Survey Trade not found!");

                CheckListPanel.BindObjectToControls(CL);
            }
        }
    }

    protected void gridChecklist_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
            Guid id = new Guid(gridChecklist.DataKeys[e.Row.RowIndex][0].ToString());
            OChecklist CL = TablesLogic.tChecklist[Security.DecryptGuid(Request["CLID"])];
            OChecklistItem item = (OChecklistItem)CL.ChecklistItems.FindObject(id);

            if (item != null)
            {
                if (item.ChecklistType == ChecklistItemType.MultipleSelections)
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
                else if (item.ChecklistType == ChecklistItemType.Choice)
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
                else if (item.ChecklistType == ChecklistItemType.Remarks)
                {
                    UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("tb_Remarks");
                    if (t != null)
                    {
                        t.Visible = true;
                        t.ValidateRequiredField = (item.IsMandatoryField == 1);
                    }
                }
                else if (item.ChecklistType == ChecklistItemType.SingleLineFreeText)
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Checklist Form Preview</title>
</head>
<body style="background-color: white; padding: 8px 8px 8px 8px">
    <form id="form1" runat="server" onload="form_OnLoad">
    <div style="width: 793px">
        <ui:UIObjectPanel runat="server" ID="CheckListPanel" Width="100%" Style="background-color: white;
            border: none" BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="CheckListPanelResource1">
            <br />
            <table border="0" cellpadding="3" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <ui:UIFieldLabel runat="server" ID="lbl_Date" Caption="Date" Span="Half" DataFormatString=""
                            meta:resourcekey="lbl_DateResource1" />
                        <ui:UIFieldLabel runat="server" ID="lbl_ChecklistName" Caption="Checklist Name" PropertyName="ObjectName"
                            DataFormatString="" meta:resourcekey="lbl_ChecklistNameResource1" />
                        <ui:UIFieldLabel runat="server" ID="lbl_SurveyTradeName" Caption="Survey Trade Name"
                            DataFormatString="" meta:resourcekey="lbl_SurveyTradeNameResource1" />
                        <ui:UIFieldLabel runat="server" ID="lbl_VendorName" Caption="Vendor Name" DataFormatString=""
                            meta:resourcekey="lbl_VendorNameResource1" />
                    </td>
                </tr>
            </table>
            <br />
            <ui:UIGridView runat="server" ID="gridChecklist" Caption="Checklist" CheckBoxColumnVisible="False"
                PropertyName="ChecklistItems" SortExpression="StepNumber" OnRowDataBound="gridChecklist_RowDataBound"
                Width="100%" AllowPaging="False" AllowSorting="False" PagingEnabled="false" BindObjectsToRows="True"
                DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridChecklistResource1"
                RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Columns>
                    <cc1:UIGridViewBoundColumn DataField="StepNumber" HeaderText="Step" meta:resourceKey="UIGridViewColumnResource18"
                        PropertyName="StepNumber" ResourceAssemblyName="" SortExpression="StepNumber">
                        <ControlStyle Width="30px" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource1"
                        PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                        <ControlStyle Width="200px" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewTemplateColumn HeaderText="Answer" meta:resourcekey="UIGridViewTemplateColumnResource1">
                        <ItemTemplate>
                            <cc1:UIFieldCheckboxList ID="ChecklistItem_MS_SelectedResponseID" runat="server"
                                CaptionWidth="1px" meta:resourcekey="ChecklistItem_MS_SelectedResponseIDResource1"
                                RepeatColumns="0" TextAlign="Right" Visible="False" Width="100%">
                            </cc1:UIFieldCheckboxList>
                            <cc1:UIFieldRadioList ID="ChecklistItem_C_SelectedResponseID" runat="server" CaptionWidth="1px"
                                meta:resourcekey="ChecklistItem_C_SelectedResponseIDResource1" RepeatColumns="0"
                                TextAlign="Right" Visible="False" Width="100%">
                            </cc1:UIFieldRadioList>
                            <cc1:UIFieldTextBox ID="tb_Remarks" runat="server" CaptionWidth="1px" InternalControlWidth="95%"
                                MaxLength="500" meta:resourcekey="tb_RemarksResource1" Rows="3" TextMode="MultiLine"
                                Visible="False" Width="100%">
                            </cc1:UIFieldTextBox>
                            <cc1:UIFieldTextBox ID="tb_SingleLineFreeText" runat="server" CaptionWidth="1px"
                                InternalControlWidth="95%" meta:resourcekey="tb_SingleLineFreeTextResource1"
                                Visible="False" Width="100%">
                            </cc1:UIFieldTextBox>
                        </ItemTemplate>
                        <ControlStyle Width="560px" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewTemplateColumn>
                    <cc1:UIGridViewTemplateColumn HeaderText="Remarks" meta:resourcekey="UIGridViewTemplateColumnResource2"
                        Visible="False">
                        <ItemTemplate>
                            <cc1:UIFieldLabel ID="ChecklistItem_Description" runat="server" CaptionWidth="1px"
                                DataFormatString="" Height="40px" meta:resourcekey="ChecklistItem_DescriptionResource1">
                            </cc1:UIFieldLabel>
                        </ItemTemplate>
                        <ControlStyle Width="250px" />
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewTemplateColumn>
                </Columns>
            </ui:UIGridView>
            <br />
        </ui:UIObjectPanel>
        <br />
        <br />
    </div>
    </form>
</body>
</html>
