<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

<%@ Import Namespace="System.Data" %>
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
        OApprovalProcess approvalProcess = panel.SessionObject as OApprovalProcess;

        if (!IsPostBack)
        {
            dropObjectTypeName.Bind(OWorkflowRepository.GetAllWorkflowRepositories(), "ObjectTypeName", "ObjectTypeName", true);
            foreach (ListItem item in dropObjectTypeName.Items)
            {
                string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
                if (translatedText != null && translatedText != "")
                    item.Text = translatedText;
            }
            
            
            treeLocation.PopulateTree();
            treeEquipment.PopulateTree();
            dropApprovalHierarchy.Bind(OApprovalHierarchy.GetAllApprovalHierarchies());
            listTransactionTypes.Bind(OCode.GetCodesByTypeOrderByParentPathAsDataTable("PurchaseType"), "Path", "ObjectID");
            gridApprovalHierarchy.Columns[1].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridApprovalHierarchy.Columns[2].HeaderText += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }

        approvalProcess.LinkApprovalProcessLimits();
        panelMain.BindObjectToControls(approvalProcess);
    }


    /// <summary>
    /// Validates and saves the approval process.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        
        using (Connection c = new Connection())
        {
            
            OApprovalProcess approvalProcess = panel.SessionObject as OApprovalProcess;
            panel.ObjectPanel.BindControlsToObject(approvalProcess);

            OApprovalProcessLimit approvalProcesslimit = panel.SessionObject as OApprovalProcessLimit;

            if (!approvalProcess.CheckApprovalLimitValue(approvalProcess))
            {
                gridApprovalHierarchy.ErrorMessage = Resources.Errors.ApprovalProcess_Limits;
            }
            if (!approvalProcess.ValidateNonDefaultApprovalProcessLimits())
            {
                this.gridApprovalHierarchy.ErrorMessage = Resources.Errors.ApprovalProcess_LimitsOutOfOrder;
            }
            
            if (!panel.ObjectPanel.IsValid)
                return;
            
            // Clear unwanted data.
            //
            if (approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.None)
                approvalProcess.ApprovalHierarchyID = null;
            
            approvalProcess.Save();
            c.Commit();
        }
    }


    protected void ShowHideGridViewRowColumns(GridViewRow row)
    {
        if (row != null)
        {
            row.Cells[2].Visible = checkUseDefaultLimits.Checked;
            row.Cells[3].Visible = !checkUseDefaultLimits.Checked;
        }
    }

    /// <summary>
    /// Hides/shows elements
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OApprovalProcess approvalProcess = panel.SessionObject as OApprovalProcess;

        // Show the approval hierarchy dropdown list only if the mode of forwarding is not
        // None.
        //
        panelApprovalHierarchy.Visible = radioModeOfForwarding.SelectedValue != ApprovalModeOfForwarding.None.ToString();
        dropObjectTypeName.Enabled = approvalProcess.IsNew;

        ShowHideGridViewRowColumns(gridApprovalHierarchy.HeaderRow);
        foreach (GridViewRow row in gridApprovalHierarchy.Rows)
            ShowHideGridViewRowColumns(row);

        gridApprovalHierarchy.Columns[4].Visible =
        gridApprovalHierarchy.Columns[6].Visible =
            radioModeOfForwarding.SelectedValue == ApprovalModeOfForwarding.Direct.ToString() ||
            radioModeOfForwarding.SelectedValue == ApprovalModeOfForwarding.Hierarchical.ToString() ||
            radioModeOfForwarding.SelectedValue == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping.ToString();

        checkAppliesToAllTransactionTypes.Visible =
            (dropObjectTypeName.SelectedValue == "OPurchaseOrder" ||
            dropObjectTypeName.SelectedValue == "ORequestForQuotation" ||
            dropObjectTypeName.SelectedValue == "OPurchaseRequest");
        
        listTransactionTypes.Visible =
            !checkAppliesToAllTransactionTypes.Checked &&
            (dropObjectTypeName.SelectedValue == "OPurchaseOrder" ||
            dropObjectTypeName.SelectedValue == "ORequestForQuotation" ||
            dropObjectTypeName.SelectedValue == "OPurchaseRequest");

    }


    /// <summary>
    /// Constructs and returns a location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OApprovalProcess approvalProcess = panel.SessionObject as OApprovalProcess;
        return new LocationTreePopulaterForCapitaland(approvalProcess.LocationID, true, true
            , Security.Decrypt(Request["TYPE"]),false,false);
    }


    /// <summary>
    /// Constructs and returns a equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        OApprovalProcess approvalProcess = panel.SessionObject as OApprovalProcess;
        return new EquipmentTreePopulater(approvalProcess.EquipmentID, true, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropApprovalHierarchy_SelectedIndexChanged(object sender, EventArgs e)
    {
        OApprovalProcess approvalProcess = panel.SessionObject as OApprovalProcess;
        panel.ObjectPanel.BindControlsToObject(approvalProcess);
        approvalProcess.LinkApprovalProcessLimits();
        panel.ObjectPanel.BindObjectToControls(approvalProcess);
    }


    /// <summary>
    /// Occurs when the user selects a different mode of forwarding.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioModeOfForwarding_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the checkbox for default timings is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkUseDefaultLimits_CheckedChanged(object sender, EventArgs e)
    {

    }



    /// <summary>
    /// Occurs when the object type changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropObjectTypeName_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropObjectTypeName.SelectedValue != "OPurchaseOrder" &&
            dropObjectTypeName.SelectedValue != "ORequestForQuotation" &&
            dropObjectTypeName.SelectedValue != "OPurchaseRequest")
        {
            foreach (ListItem item in listTransactionTypes.Items)
                item.Selected = false;
        }
    }


    /// <summary>
    /// Occurs when the applies to all transaction types change.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkAppliesToAllTransactionTypes_CheckedChanged(object sender, EventArgs e)
    {
        foreach (ListItem item in listTransactionTypes.Items)
            item.Selected = false;
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Approval Process" BaseTable="tApprovalProcess"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false" ></web:base>
                    <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" PropertyName="Description" MaxLength="255"
                        ValidateRequiredField="True" InternalControlWidth="95%" meta:resourcekey="textDescriptionResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat='server' ID="dropObjectTypeName" PropertyName="ObjectTypeName"
                        Caption="Object Type Name" ValidateRequiredField="True" meta:resourcekey="dropObjectTypeNameResource1" OnSelectedIndexChanged="dropObjectTypeName_SelectedIndexChanged">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                        PropertyName="LocationID" ValidateRequiredField="True"  meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater"
                        PropertyName="EquipmentID" ValidateRequiredField="True"  meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:uifieldtextbox runat='server' id="textFleeCondition" PropertyName="FLEECondition" CAption="Applicable Condition" MaxLength="500" InternalControlWidth="95%" meta:resourcekey="textFleeConditionResource1">
                    </ui:uifieldtextbox>
                    <ui:uifieldcheckbox runat='server' id="checkAppliesToAllTransactionTypes" PropertyName="AppliesToAllTransactionTypes" Caption="All Transaction Types" Text="Yes, this Approval Process applies to all Transaction Types" OnCheckedChanged="checkAppliesToAllTransactionTypes_CheckedChanged" meta:resourcekey="checkAppliesToAllTransactionTypesResource1" TextAlign="Right"></ui:uifieldcheckbox>
                    <ui:uifieldlistbox runat="server" id="listTransactionTypes" Caption="Transaction Types" PropertyName="TransactionTypes" ValidaterequiredField="True" meta:resourcekey="listTransactionTypesResource1"></ui:uifieldlistbox>
                    <ui:UIFieldRadioList runat="server" ID="radioModeOfForwarding" Caption="Mode of Forwarding"
                        PropertyName="ModeOfForwarding" ValidateRequiredField="True" OnSelectedIndexChanged="radioModeOfForwarding_SelectedIndexChanged" meta:resourcekey="radioModeOfForwardingResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="None: No approval is required."></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Direct: The object will be routed immediately to the a user/role authorized to approve the object."></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" Text="Hierarchical: The object will be first routed to first user/role in the approval hierarchy, until it reaches a user/role authorized to approve the object."></asp:ListItem>
                            <asp:ListItem Value="4" meta:resourcekey="ListItemResource5" Text="Hierarchical with Skipping: Same as Hierarchical, except when a rejected task is re-submitted for approval, it starts at the same level that rejected the task." ></asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource4" Text="All: The object will be routed to all users/roles from the first to the one authorized to approve the object."></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIPanel runat="server" ID="panelApprovalHierarchy" BorderStyle="NotSet" meta:resourcekey="panelApprovalHierarchyResource1">
                        <ui:UISeparator runat="server" ID="sep1" Caption="Approval Hierarchy" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropApprovalHierarchy" ValidateRequiredField="True"
                            PropertyName="ApprovalHierarchyID" Caption="Approval Hierarchy" OnSelectedIndexChanged="dropApprovalHierarchy_SelectedIndexChanged" meta:resourcekey="dropApprovalHierarchyResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldCheckBox runat="server" ID="checkUseDefaultLimits" PropertyName="UseDefaultLimits" Caption="Use Default Limits" Text="Yes, use default approval limits specified in the selected Approval Hierarchy above." OnCheckedChanged="checkUseDefaultLimits_CheckedChanged" meta:resourcekey="checkUseDefaultLimitsResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                        
                        <br />
                        <ui:UIGridView runat="server" ID="gridApprovalHierarchy" 
                            PropertyName="ApprovalHierarchy.ApprovalHierarchyLevels" CheckBoxColumnVisible="False"
                            SortExpression="ApprovalLevel ASC" BindObjectsToRows="True" 
                            DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridApprovalHierarchyResource1" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="ApprovalLevel" HeaderText="Approval Level" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ApprovalLevel" ResourceAssemblyName="" SortExpression="ApprovalLevel">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="100px" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ApprovalLimit" DataFormatString="{0:#,##0.00}" HeaderText="Approval Limit" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="ApprovalLimit" ResourceAssemblyName="" SortExpression="ApprovalLimit">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="110px" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Approval Limit" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textApprovalLimit" runat="server" Caption="Approval Limit" FieldLayout="Flow" InternalControlWidth="80px" meta:resourcekey="textApprovalLimitResource1" PropertyName="TempApprovalProcessLimit.ApprovalLimit" ShowCaption="False">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" Width="110px" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserNames" HeaderText="Users" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="UserNames" ResourceAssemblyName="" SortExpression="UserNames">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PositionNames" HeaderText="Positions" 
                                    PropertyName="PositionNames" 
                                    ResourceAssemblyName="" SortExpression="PositionNames" meta:resourcekey="UIGridViewBoundColumnResource7" >
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CarbonCopyPositionNames" HeaderText="Copy to Positions" 
                                    PropertyName="CarbonCopyPositionNames" 
                                    ResourceAssemblyName="" SortExpression="CarbonCopyPositionNames" 
                                    meta:resourcekey="UIGridViewBoundColumnResource8" >
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="SecretaryPositionNames" HeaderText="Secretary Users" PropertyName="SecretaryPositionNames" ResourceAssemblyName="" SortExpression="SecretaryPositionNames" meta:resourcekey="UIGridViewBoundColumnResource5">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="RoleNames" HeaderText="Roles" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="RoleNames" ResourceAssemblyName="" SortExpression="RoleNames">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn HeaderText="Approvals Required" PropertyName="NumberOfApprovalsRequired" ResourceAssemblyName="" SortExpression="RoleNames" DataField="NumberOfApprovalsRequired" meta:resourcekey="UIGridViewBoundColumnResource6">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIHint runat="server" ID="hintApprovalLimit" Text="You can force the <b>last approvers</b> in an approval hierarchy to approve the task by using 999,999,999,999 (12-nines) as the approval limit, regardless of the task amount."></ui:UIHint>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1">
                    <web:memo runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments" BorderStyle="NotSet" meta:resourcekey="uitabview2Resource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
