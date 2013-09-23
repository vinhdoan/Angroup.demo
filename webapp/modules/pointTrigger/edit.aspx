<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource1" %>

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
       
        OPointTrigger trigger = (OPointTrigger)panel.SessionObject;
         
        ParentID.PopulateTree();        
        
        // Bind the type of work/services/problem
        // drop down lists.
        //
        dropTypeOfWork.Bind(OCode.GetCodesByType("TypeOfWork", trigger.TypeOfWorkID));
        dropTypeOfService.Bind(OCode.GetCodesByParentID(trigger.TypeOfWorkID, trigger.TypeOfServiceID));
        dropTypeOfProblem.Bind(OCode.GetCodesByParentID(trigger.TypeOfServiceID, trigger.TypeOfProblemID));

        // Update the priority's text
        //
        dropPriority.Items[0].Text = Resources.Strings.Priority_0;
        dropPriority.Items[1].Text = Resources.Strings.Priority_1;
        dropPriority.Items[2].Text = Resources.Strings.Priority_2;
        dropPriority.Items[3].Text = Resources.Strings.Priority_3;

        panel.ObjectPanel.BindObjectToControls(trigger);

        panelDetail.Visible = IsLeafType.Checked;

        ParentID.Enabled = trigger.IsNew;
        IsLeafType.Enabled = trigger.IsNew;  
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
            OPointTrigger trigger = (OPointTrigger)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(trigger);

            // Validate
            //
            if (trigger.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            //
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            trigger.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Constructs the location tree view.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        OPointTrigger trigger = (OPointTrigger)panel.SessionObject;
        
        return new PointTriggerTreePopulater(trigger.ObjectID, true, false,
            Security.Decrypt(Request["TYPE"]));
       
    }

    /// <summary>
    /// Occurs when the Type of Work dropdown list is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropTypeOfWork_SelectedIndexChanged(object sender, EventArgs e)
    {
        dropTypeOfService.Items.Clear();
        if (dropTypeOfWork.SelectedValue != "")
            dropTypeOfService.Bind(OCode.GetCodesByParentID(new Guid(dropTypeOfWork.SelectedValue), null));
        dropTypeOfProblem.Items.Clear();
    }


    /// <summary>
    /// Occurs when the Type of Service dropdown list is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropTypeOfService_SelectedIndexChanged(object sender, EventArgs e)
    {
        dropTypeOfProblem.Items.Clear();
        if (dropTypeOfService.SelectedValue != "")
            dropTypeOfProblem.Bind(OCode.GetCodesByParentID(new Guid(dropTypeOfService.SelectedValue), null));
    }

    protected void IsLeafType_CheckedChanged(object sender, EventArgs e)
    {
        
        panelDetail.Visible = IsLeafType.Checked;
        
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
            <web:object runat="server" ID="panel" Caption="Trigger Template Name" BaseTable="tPointTrigger" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                    meta:resourcekey="tabObjectResource1" >
                    <ui:UITabView ID="tabDetails" runat="server"  Caption="Details" 
                        BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="Trigger Name" meta:resourcekey="objectBaseResource1" ObjectNumberVisible="false">
                        </web:base>
                       
                        <ui:UIPanel runat="server" ID="panelHierarchy" BorderStyle="NotSet" 
                            meta:resourcekey="panelHierarchyResource1">
                            <ui:UISeparator runat="server" ID="sep1" Caption="Conditions" 
                                meta:resourcekey="sep1Resource1" />
                            <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            OnAcquireTreePopulater="ParentID_AcquireTreePopulater" ValidateRequiredField="True"
                            ToolTip="The trigger or group under which this item belongs." 
                                meta:resourcekey="ParentIDResource1" ShowCheckBoxes="None" 
                                TreeValueMode="SelectedNode" /> 
                            <ui:UIFieldCheckBox runat=server ID="IsLeafType" PropertyName="IsLeafType" Caption="Trigger Template Type"            
                             Text="Yes, this is a trigger template" 
                                OnCheckedChanged="IsLeafType_CheckedChanged" 
                                meta:resourcekey="IsLeafTypeResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                         </ui:UIPanel>
                        
                        <ui:UIPanel runat="server" ID="panelDetail" Visible=False BorderStyle="NotSet" 
                            meta:resourcekey="panelDetailResource1">
                        <ui:UISeparator runat="server" ID="UISeparator1" Caption="Work Detail" 
                                meta:resourcekey="UISeparator1Resource1" />                      
                        <ui:UIFieldDropDownList runat="server" ID="dropTypeOfWork" 
                                PropertyName="TypeOfWorkID" Caption="Type of Work" ValidateRequiredField="True" 
                                OnSelectedIndexChanged="dropTypeOfWork_SelectedIndexChanged" 
                                meta:resourcekey="dropTypeOfWorkResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropTypeOfService" 
                                PropertyName="TypeOfServiceID" Caption="Type of Service" 
                                ValidateRequiredField="True"  
                                OnSelectedIndexChanged="dropTypeOfService_SelectedIndexChanged" 
                                meta:resourcekey="dropTypeOfServiceResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropTypeOfProblem" 
                                PropertyName="TypeOfProblemID" Caption="Type of Problem" 
                                ValidateRequiredField="True" meta:resourcekey="dropTypeOfProblemResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="dropPriority" PropertyName="Priority" 
                                Caption="Priority" ValidateRequiredField="True" 
                                meta:resourcekey="dropPriorityResource1">
                            <Items>
                                <asp:ListItem Text="0" Value="0" meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource2"></asp:ListItem>
                                <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource3"></asp:ListItem>
                                <asp:ListItem Text="3" Value="3" meta:resourcekey="ListItemResource4"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:uifieldtextbox runat="server" ID="textWorkDescription" 
                                PropertyName="WorkDescription" Caption="Work Description" 
                                ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" 
                                meta:resourcekey="textWorkDescriptionResource1"></ui:uifieldtextbox>
                        <ui:UIHint runat="server" ID="hintWorkDescription" 
                                meta:resourcekey="hintWorkDescriptionResource1"><asp:Table runat="server" 
                                CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell 
                                        runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" 
                                        ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                        runat="server" VerticalAlign="Top"><asp:Label runat="server"> The work description describes the problem in greater detail. To include the reading that breached the limit as part of the description, use the special tag <b>{0}</b>. <br /><br />For example, <br />&nbsp; &nbsp; The aircon temperature (<b>{0}</b> deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. <br /><br />If the reading is 9 degrees Celsius and a work is triggered, the work description will be populated with the following description: <br />&nbsp; &nbsp; The aircon temperature (9 deg Celsius) has exceed acceptable limits 10 - 25 deg Celsius. </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:UIHint>
                    </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                        meta:resourcekey="tabMemoResource1"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments"  Caption="Attachments" 
                        BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
