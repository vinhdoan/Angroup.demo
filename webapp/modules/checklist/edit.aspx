<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OChecklist checklist = (OChecklist)panel.SessionObject;

        if (Request["TREEOBJID"] != null)
        {
            OChecklist parent = TablesLogic.tChecklist[Security.DecryptGuid(Request["TREEOBJID"])];
            if (parent != null && parent.IsChecklist == 0)
                panel.SessionObject.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);
        }

        ParentID.PopulateTree();
        ParentID.Enabled = panel.SessionObject.IsNew;
        IsChecklist.Enabled = panel.SessionObject.IsNew;
        Type.Enabled = panel.SessionObject.IsNew;

        panel.ObjectPanel.BindObjectToControls(checklist);
    }


    /// <summary>
    /// Saves the Checklist object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OChecklist checklist = panel.SessionObject as OChecklist;
            panel.ObjectPanel.BindControlsToObject(checklist);

            int count = 0;
            if (checklist.Type.Value == 1)
            {
                foreach (OChecklistItem item in checklist.ChecklistItems)
                {
                    if (item.IsOverall == 1)
                        count++;
                }
                if (count != 1)
                    ChecklistItems.ErrorMessage = "Please select exactly one item in checklist as overall";

            }

            // 2011.03.22
            // Kim Foong
            // Added this IsValid condition, and return.
            //
            if (!panel.ObjectPanel.IsValid)
                return;

            checklist.Save();
            c.Commit();

        }
    }

    
    /// <summary>
    /// Populates the check list item sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ChecklistItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OChecklist checklist = panel.SessionObject as OChecklist;
        OChecklistItem checklistItem = ChecklistItem_SubPanel.SessionObject as OChecklistItem;
        
        ChecklistItem_StepNumber.Items.Clear();
        for (int i = 1; i <= checklist.ChecklistItems.Count + 1; i++)
            ChecklistItem_StepNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));
        if (checklistItem.IsNew && checklistItem.StepNumber == null)
            checklistItem.StepNumber = ChecklistItem_StepNumber.Items.Count;
        ChecklistItem_ChecklistResponseSetID.Bind(OChecklistResponseSet.GetAllResponseSets());

        ChecklistItem_Panel.BindObjectToControls(checklistItem);
        rb_MandatoryField.Visible = (checklist.Type == ChecklistType.Survey);
    }


    /// <summary>
    /// Adds/Updates the checklist item
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ChecklistItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OChecklist checklist = (OChecklist)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(checklist);
   
        OChecklistItem checklistItem = (OChecklistItem)ChecklistItem_SubPanel.SessionObject;
        ChecklistItem_SubPanel.ObjectPanel.BindControlsToObject(checklistItem);
        
        if (checklistItem.ChecklistType != 0)
            checklistItem.ChecklistResponseSetID = null;

        // Add the checklist item
        //
        checklist.ChecklistItems.Add(checklistItem);
        
        checklist.ReorderItem((OChecklist)panel.SessionObject);

        panel.ObjectPanel.BindObjectToControls(checklist);
    }

    
    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OChecklist CurrentCL = (OChecklist)panel.CurrentObject;
        checklistPanel.Visible = IsChecklist.SelectedIndex == 1;
        ChecklistItem_ChecklistResponseSetID.Visible = ChecklistItem_ChecklistType.SelectedIndex == 0;
        chkIsOverall.Visible = CurrentCL.Type == ChecklistType.Survey;
        chkIsOverall.Enabled = (ChecklistItem_ChecklistType.SelectedIndex == 0);
        checkHasSingleTextbox.Visible =
            (ChecklistItem_ChecklistType.SelectedValue == ChecklistItemType.Choice.ToString() ||
            ChecklistItem_ChecklistType.SelectedValue == ChecklistItemType.MultipleSelections.ToString());
        
    }

    /// <summary>
    /// Constructs and returns the check list tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new ChecklistTreePopulater(panel.SessionObject.ParentID, true, false);
    }


    /// <summary>
    /// Occurs when the user removes a checklist item from
    /// the checklist.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ChecklistItem_SubPanel_Removed(object sender, EventArgs e)
    {
        OChecklist checklist = (OChecklist)panel.SessionObject;
        checklist.ReorderItem(null);
    }

    
    /// <summary>
    /// Occurs when user clicks on the radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsChecklist_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void panel_PreRender(object sender, EventArgs e)
    {
        OChecklist CurrentCL = (OChecklist)panel.CurrentObject;
        tab_Details.Enabled = CurrentCL.IsDesignChangeable;
    }
    /// <summary>
    /// Occurs when user mades selection in the drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ChecklistItem_ChecklistType_SelectedIndexChanged(object sender, EventArgs e)
    {
    
    }

    /// <summary>
    /// Occurs when user mades selection in the drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Type_SelectedIndexChanged(object sender, EventArgs e)
    {

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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Checklist" BaseTable="tChecklist"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"
                OnPreRender="panel_PreRender"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="tab_Details" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false"></web:base>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            OnAcquireTreePopulater="ParentID_AcquireTreePopulater" ToolTip="The group under which this item belongs to."
                            meta:resourcekey="ParentIDResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode" />
                        <ui:UIFieldRadioList runat="server" ID="IsChecklist" PropertyName="IsChecklist" Caption="Checklist Type"
                            ValidateRequiredField="True" ToolTip="This indicates if this item is a grouping or an actual physical checklist."
                            meta:resourcekey="IsChecklistResource1" 
                            OnSelectedIndexChanged="IsChecklist_SelectedIndexChanged" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1">Checklist Group</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Physical Checklist</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="checklistPanel" Width="100%" 
                            meta:resourcekey="checklistPanelResource1" BorderStyle="NotSet">
                            <ui:UIFieldDropDownList runat="server" ID="Type" PropertyName="Type" Caption="Type"
                            ValidateRequiredField="True" 
                                OnSelectedIndexChanged="Type_SelectedIndexChanged" 
                                meta:resourcekey="TypeResource1">
                            <Items>
                                <asp:ListItem value="0" text="Work" />
                                <asp:ListItem value="1" text="Survey" meta:resourcekey="ListItemResource4" />
                            </Items>
                        </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox ID="Benchmark" runat="server" Caption="Benchmark Score" PropertyName="Benchmark"
                                Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                ValidationRangeType="Currency" meta:resourcekey="BenchmarkResource1" 
                                InternalControlWidth="95%" />
                            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
                            <ui:UIGridView runat="server" ID="ChecklistItems" Caption="Checklist Items" PropertyName="ChecklistItems"
                                SortExpression="StepNumber" KeyName="ObjectID" meta:resourcekey="ChecklistItemsResource1"
                                Width="100%" DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                                RowErrorColor="" style="clear:both;">
                                <PagerSettings Mode="NumericFirstLast" />
                                <commands>
                                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                        CommandName="DeleteObject" CommandText="Delete" 
                                        ConfirmText="Are you sure you wish to delete the selected items?" 
                                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                        CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                        meta:resourceKey="UIGridViewCommandResource2" />
                                </commands>
                                <Columns>
                                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                        ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewButtonColumn>
                                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                        ConfirmText="Are you sure you wish to delete this item?" 
                                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewButtonColumn>
                                    <cc1:UIGridViewBoundColumn DataField="StepNumber" HeaderText="Step" 
                                        meta:resourceKey="UIGridViewColumnResource3" PropertyName="StepNumber" 
                                        ResourceAssemblyName="" SortExpression="StepNumber">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                        meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                        ResourceAssemblyName="" SortExpression="ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ChecklistTypeString" 
                                        HeaderText="Response Expected" meta:resourceKey="UIGridViewColumnResource5" 
                                        PropertyName="ChecklistTypeString" ResourceAssemblyName="" 
                                        SortExpression="ChecklistTypeString">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ChecklistResponseSet.ObjectName" 
                                        HeaderText="Response Set" meta:resourceKey="UIGridViewColumnResource6" 
                                        PropertyName="ChecklistResponseSet.ObjectName" ResourceAssemblyName="" 
                                        SortExpression="ChecklistResponseSet.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="IsMandatoryFieldText" 
                                        HeaderText="Is Mandatory Field?" 
                                        meta:resourcekey="UIGridViewBoundColumnResource1" 
                                        PropertyName="IsMandatoryFieldText" ResourceAssemblyName="" 
                                        SortExpression="IsMandatoryFieldText">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="IsOverallText" HeaderText="Is Overall" 
                                        meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="IsOverallText" 
                                        ResourceAssemblyName="" SortExpression="IsOverallText">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="ChecklistItem_Panel" 
                                meta:resourcekey="ChecklistItem_PanelResource1" BorderStyle="NotSet">
                                <web:subpanel runat="server" ID="ChecklistItem_SubPanel" GridViewID="ChecklistItems"
                                    ObjectPanelID="ChecklistItem_Panel" OnPopulateForm="ChecklistItem_SubPanel_PopulateForm"
                                    OnValidateAndUpdate="ChecklistItem_SubPanel_ValidateAndUpdate" OnRemoved="ChecklistItem_SubPanel_Removed"></web:subpanel>
                                <ui:UIFieldDropDownList ID="ChecklistItem_StepNumber" runat="server" Caption="Step"
                                    PropertyName="StepNumber" ValidateRequiredField="True" ToolTip="The step number of this checklist item. Note: You can re-order the checklist by changing the step of the items."
                                    meta:resourcekey="ChecklistItem_StepNumberResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldTextBox ID="ChecklistResponse_Name" runat="server" Caption="Name" PropertyName="ObjectName"
                                    ValidateRequiredField="True" MaxLength="255" ToolTip="The name of the checklist item as displayed on screen. This normally indicates the question, or the step the maintenance should answer or take."
                                    meta:resourcekey="ChecklistResponse_NameResource1" 
                                    InternalControlWidth="95%" />
                                <ui:UIFieldDropDownList ID="ChecklistItem_ChecklistType" runat="server" PropertyName="ChecklistType"
                                    Caption="Expected Response" ValidateRequiredField="True" Span="Half" ToolTip="Indicates if the response should be a choice of answers, an input of remarks, or no input."
                                    meta:resourcekey="ChecklistItem_ChecklistTypeResource1" OnSelectedIndexChanged="ChecklistItem_ChecklistType_SelectedIndexChanged">
                                    <Items>
                                        <asp:ListItem Selected="True" Value="0">Multiple Choice (Only One Answer)</asp:ListItem>
                                        <asp:ListItem Value="3">Multiple Choice (Multiple Anwsers)</asp:ListItem>
                                        <asp:ListItem Value="4">Single Line Textbox</asp:ListItem>
                                        <asp:ListItem Value="1">Multiple Lines Textbox</asp:ListItem>
                                        <asp:ListItem Value="2">None</asp:ListItem>
                                    </Items>
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldCheckBox runat="server" ID="checkHasSingleTextbox" PropertyName="HasSingleTextboxField" Span="Half"
                                    Caption="With single line textbox?" Text="Yes, with the textbox display next to multiple choice"
                                    ShowCaption="false" CaptionWidth="2px">
                                </ui:UIFieldCheckBox>
                                <ui:UIFieldDropDownList ID="ChecklistItem_ChecklistResponseSetID" runat="server"
                                    Caption="Response Set" PropertyName="ChecklistResponseSetID" ValidateRequiredField="True"
                                    ToolTip="The response set that the maintenance should select from for this step."
                                    meta:resourcekey="ChecklistItem_ChecklistResponseSetIDResource1" />
                                <ui:UIFieldRadioList ID="rb_MandatoryField" RepeatColumns="0" runat="server" 
                                    Caption="Is Mandatory Field?" ValidateRequiredField="True" 
                                    PropertyName="IsMandatoryField" Width="100%" 
                                    meta:resourcekey="rb_MandatoryFieldResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem value="1" text="Yes" meta:resourcekey="ListItemResource6" />
                                    <asp:ListItem value="0" text="No" meta:resourcekey="ListItemResource7" />
                                </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldCheckBox ID="chkIsOverall" runat="server" Caption="Is Overall" 
                                    PropertyName="IsOverall" meta:resourcekey="chkIsOverallResource1" 
                                    TextAlign="Right" />
                            </ui:UIObjectPanel>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
