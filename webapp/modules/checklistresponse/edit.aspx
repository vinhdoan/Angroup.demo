<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
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
        OChecklistResponseSet checklistResponseSet = panel.SessionObject as OChecklistResponseSet;

        panel.ObjectPanel.BindObjectToControls(checklistResponseSet);
    }

    protected void panel_PreRender(object sender, EventArgs e)
    {
        OChecklistResponseSet CurrentCLRS = (OChecklistResponseSet)panel.SessionObject;
        uitabview1.Enabled = CurrentCLRS.IsDesignChangeable;
    }
    /// <summary>
    /// Validates and saves the checklist response object to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OChecklistResponseSet set = (OChecklistResponseSet)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(set);

            // Validate
            //
            if (set.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            set.Save();
            c.Commit();
        }
    }

    
    /// <summary>
    /// Populates the checklist response sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ChecklistResponse_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OChecklistResponseSet respSet = (OChecklistResponseSet)panel.SessionObject;
        OChecklistResponse resp = (OChecklistResponse)ChecklistResponse_SubPanel.SessionObject;

        ChecklistResponse_DisplayOrder.Items.Clear();
        for (int i = 0; i < respSet.ChecklistResponses.Count + 1; i++)
            ChecklistResponse_DisplayOrder.Items.Add(new ListItem((i + 1).ToString(), (i + 1).ToString()));

        if (resp.IsNew && resp.DisplayOrder == null)
            resp.DisplayOrder = ChecklistResponse_DisplayOrder.Items.Count;
        ChecklistResponse_Panel.BindObjectToControls(resp);
    }

    
    /// <summary>
    /// Updates the checklist item.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ChecklistResponse_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OChecklistResponseSet respSet = (OChecklistResponseSet)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(respSet);
        
        OChecklistResponse resp = (OChecklistResponse)ChecklistResponse_SubPanel.SessionObject;
        ChecklistResponse_SubPanel.ObjectPanel.BindControlsToObject(resp);
        

        if (resp.IsDuplicateName((OChecklistResponseSet)panel.SessionObject))
            ChecklistResponse_Name.ErrorMessage = Resources.Errors.General_NameDuplicate;

        respSet.ChecklistResponses.Add(resp);
        respSet.ReorderItems((OChecklistResponse)ChecklistResponse_SubPanel.SessionObject);

        panel.ObjectPanel.BindObjectToControls(respSet);
    }


    /// <summary>
    /// Occurs when the user removes checklist responses.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ChecklistResponse_SubPanel_Removed(object sender, EventArgs e)
    {
        OChecklistResponseSet respSet = (OChecklistResponseSet)panel.SessionObject;

        respSet.ReorderItems(null);
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
            <web:object runat="server" ID="panel" Caption="Checklist Response Set" BaseTable="tChecklistResponseSet"
                OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"
                OnPreRender="panel_PreRender"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false"></web:base>
                        <ui:UIGridView runat="server" ID="ChecklistResponses" Caption="Responses" PropertyName="ChecklistResponses"
                            SortExpression="DisplayOrder" KeyName="ObjectID" meta:resourcekey="ChecklistResponsesResource1"
                            Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="DisplayOrder" HeaderText="Display Order"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Name" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataFormatString="{0:0.00}" PropertyName="ScoreNumerator"
                                    HeaderText="Score" meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"
                                    meta:resourcekey="UIGridViewCommandResource2"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="ChecklistResponse_Panel" meta:resourcekey="ChecklistResponse_PanelResource1">
                            <web:subpanel runat="server" ID="ChecklistResponse_SubPanel" GridViewID="ChecklistResponses"
                                ObjectPanelID="ChecklistResponse_Panel" 
                                OnPopulateForm="ChecklistResponse_SubPanel_PopulateForm" 
                                OnRemoved="ChecklistResponse_SubPanel_Removed" OnValidateAndUpdate="ChecklistResponse_SubPanel_ValidateAndUpdate"></web:subpanel>
                            <ui:UIFieldDropDownList runat="server" ID="ChecklistResponse_DisplayOrder" Caption="Display Order"
                                PropertyName="DisplayOrder" ValidateRequiredField="True" ToolTip="The order in which the response should appear. Lowest appears first."
                                meta:resourcekey="ChecklistResponse_DisplayOrderResource1">
                            </ui:UIFieldDropDownList>
                            <br />
                            <br />
                            <br />
                            <ui:UIFieldTextBox ID="ChecklistResponse_Name" runat="server" Caption="Name" PropertyName="ObjectName"
                                Span="Half" ValidateRequiredField="True" ToolTip="The name of the response as displayed on screen. For example, this should be 'Yes', 'No', 'OK', 'Not OK', etc."
                                MaxLength="255" meta:resourcekey="ChecklistResponse_NameResource1" />
                            <ui:UIFieldTextBox ID="ChecklistResponse_ScoreNumerator" runat="server" Caption="Score"
                                PropertyName="ScoreNumerator" Span="Half" ToolTip="The score that should be assigned to the total when this response is selected. This should not be greater than the maximum score."
                                ValidateRequiredField="true" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                ValidationRangeType="Currency" meta:resourcekey="ChecklistResponse_ScoreNumeratorResource1" />
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
