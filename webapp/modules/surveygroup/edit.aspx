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
        OSurveyGroup surveyGroup = (OSurveyGroup)panel.SessionObject;

        DefaultSurveyChecklistID.Bind(OChecklist.GetSurveyChecklist());
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
            OSurveyGroup surveyGroup = (OSurveyGroup)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(surveyGroup);

            surveyGroup.Save();
            c.Commit();
        }
    }

    protected void DefaultSurveyChecklistID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyGroup surveyGroup = (OSurveyGroup)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(surveyGroup);
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
        <web:object runat="server" ID="panel" Caption="Survey Group" BaseTable="tSurveyGroup"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" BeginningHtml="" BorderStyle="NotSet"
                    EndingHtml="" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Survey Group Name" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIPanel runat="server" ID="panel_ContractGroup" BeginningHtml="" BorderStyle="NotSet"
                        EndingHtml="" meta:resourcekey="panel_ContractGroupResource1">
                        <br />
                        <ui:UIFieldDropDownList runat="server" ID="DefaultSurveyChecklistID" PropertyName="DefaultSurveyChecklistID"
                            Caption="Default Survey Checklist" ValidateRequiredField="True" OnSelectedIndexChanged="DefaultSurveyChecklistID_SelectedIndexChanged"
                            meta:resourcekey="DefaultSurveyChecklistIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIGridView runat="server" ID="GV_Checklist" Caption="Checklist Template" CheckBoxColumnVisible="False"
                            PropertyName="Checklist.ChecklistItems" SortExpression="StepNumber" PageSize="1000"
                            BindObjectsToRows="True" Width="100%" AllowPaging="False" AllowSorting="False"
                            PagingEnabled="false" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl=""
                            meta:resourcekey="GV_ChecklistResource1" RowErrorColor="" Style="clear: both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="StepNumber" HeaderText="Step" meta:resourcekey="UIGridViewBoundColumnResource1"
                                    PropertyName="StepNumber" ResourceAssemblyName="" SortExpression="StepNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewBoundColumnResource2"
                                    PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ChecklistTypeString" HeaderText="Response Expected"
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="ChecklistTypeString"
                                    ResourceAssemblyName="" SortExpression="ChecklistTypeString">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ChecklistResponseSet.ObjectName" HeaderText="Response Set"
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="ChecklistResponseSet.ObjectName"
                                    ResourceAssemblyName="" SortExpression="ChecklistResponseSet.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                            <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                            <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                        </ui:UIGridView>
                        <br />
                        <ui:UIFieldRadioList ID="SurveyContractedVendor" RepeatColumns="0" runat="server"
                            Caption="Survey Contracted Vendor" PropertyName="SurveyContractedVendor" ValidateRequiredField="True"
                            meta:resourcekey="SurveyContractedVendorResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" Text="Yes" meta:resourcekey="ListItemResource1" />
                                <asp:ListItem Value="0" Text="No" meta:resourcekey="ListItemResource2" />
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldRadioList ID="SurveyContractedVendorEvaluatedByMA" RepeatColumns="0" runat="server"
                            Caption="Survey Contracted Vendor Evaluated By MA" PropertyName="SurveyContractedVendorEvaluatedByMA"
                            ValidateRequiredField="True" meta:resourcekey="SurveyContractedVendorEvaluatedByMAResource1"
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" Text="Yes" meta:resourcekey="ListItemResource3" />
                                <asp:ListItem Value="0" Text="No" meta:resourcekey="ListItemResource4" />
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldRadioList ID="SurveyOthers" RepeatColumns="0" runat="server" Caption="Survey for Other Reasons"
                            PropertyName="SurveyOthers" ValidateRequiredField="True" meta:resourcekey="SurveyOthersResource1"
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" Text="Yes" meta:resourcekey="ListItemResource5" />
                                <asp:ListItem Value="0" Text="No" meta:resourcekey="ListItemResource6" />
                            </Items>
                        </ui:UIFieldRadioList>
                        <br />
                        <br />
                        <br />
                        <ui:UIFieldRadioList ID="ContractMandatory" RepeatColumns="0" runat="server" Caption="Contract Mandatory"
                            PropertyName="ContractMandatory" ValidateRequiredField="True" meta:resourcekey="ContractMandatoryResource1"
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" Text="Yes" meta:resourcekey="ListItemResource7" />
                                <asp:ListItem Value="0" Text="No" meta:resourcekey="ListItemResource8" />
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTextBox ID="EvaluatedPartyName" runat="server" Caption="Evaluated Party Name"
                            PropertyName="EvaluatedPartyName" Width="100%" MaxLength="255" InternalControlWidth="95%"
                            meta:resourcekey="EvaluatedPartyNameResource1" />
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
