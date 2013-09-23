<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

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
        OEquipmentWriteOff writeoff = panel.SessionObject as OEquipmentWriteOff;
        panel.ObjectPanel.BindObjectToControls(writeoff);
    }


    /// <summary>
    /// Validates and saves the tax code object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OEquipmentWriteOff writeoff = panel.SessionObject as OEquipmentWriteOff;
            panel.ObjectPanel.BindControlsToObject(writeoff);
            if (objectBase.SelectedAction == "SubmitForApproval")
            {
                foreach (OEquipmentWriteOffItem item in writeoff.EquipmentWriteOffItems)
                {
                    if (item.Equipment.Status == EquipmentStatusType.PendingWriteOff ||
                        item.Equipment.Status == EquipmentStatusType.WrittenOff)
                    {
                        panel.Message = String.Format(Resources.Errors.EquipmentWriteOff_EquipmentIsPendingWriteOff, item.Equipment.ObjectName);
                        EquipmentWriteOffItems.ErrorMessage = String.Format(Resources.Errors.EquipmentWriteOff_EquipmentIsPendingWriteOff, item.Equipment.ObjectName);
                        break;
                    }
                }
            }
            if (!panel.ObjectPanel.IsValid)
                return;
            writeoff.ObjectName = writeoff.Description;
            // Save
            //
            writeoff.Save();
            c.Commit();
        }
    }

    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        OEquipmentWriteOffItem item = EquipmentWriteOffItem_SubPanel.SessionObject as OEquipmentWriteOffItem;
        return new EquipmentTreePopulater(item.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    protected void EquipmentWriteOffItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OEquipmentWriteOffItem item = EquipmentWriteOffItem_SubPanel.SessionObject as OEquipmentWriteOffItem;
        treeEquipment.PopulateTree();
        EquipmentWriteOffItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }

    protected void EquipmentWriteOffItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OEquipmentWriteOff writeoff = panel.SessionObject as OEquipmentWriteOff;
        OEquipmentWriteOffItem item = EquipmentWriteOffItem_SubPanel.SessionObject as OEquipmentWriteOffItem;
        EquipmentWriteOffItem_SubPanel.ObjectPanel.BindControlsToObject(item);
        if (writeoff.IsEquipmentDuplicated(item.EquipmentID, item.ObjectID))
            treeEquipment.ErrorMessage = Resources.Errors.EquipmentWriteOff_DuplicateEquipment;
        writeoff.EquipmentWriteOffItems.Add(item);
        EquipmentWriteOffItem_Panel.BindObjectToControls(writeoff);
        //panel.ObjectPanel.BindObjectToControls(writeoff);
    }

    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Equipment Write-Off" BaseTable="tEquipmentWriteOff" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTextBox ID="Description" runat="server" PropertyName="Description" Caption="Description" ValidateRequiredField="True" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="DescriptionResource1"/>
                        <ui:UISeparator runat="server" Caption="Equipment Write-Off Items" meta:resourcekey="UISeparatorResource1" />
                        <ui:UIPanel runat="server" ID="EquipmentWriteOffItem_Panel" BorderStyle="NotSet" meta:resourcekey="EquipmentWriteOffItem_PanelResource1">
                        <ui:uigridview id="EquipmentWriteOffItems" runat="server" 
                                caption="Equipment Write-Off Items" datakeynames="ObjectID" gridlines="Both" 
                                keyname="ObjectID" pagingenabled="True" 
                            propertyname="EquipmentWriteOffItems" rowerrorcolor="" showfooter="True" 
                             style="clear:both;" width="100%" 
                                meta:resourcekey="EquipmentWriteOffItemsResource1" >
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="DeleteObject" commandtext="Delete" confirmtext="Are you sure you wish to delete the selected items?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1"/>
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" confirmtext="Are you sure you wish to delete this item?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                 <ui:uigridviewboundcolumn datafield="Equipment.Path" headertext="Equipment" propertyname="Equipment.Path" resourceassemblyname="" sortexpression="Equipment.Path" meta:resourcekey="UIGridViewBoundColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ReasonForWriteOff" headertext="Reason For Write-Off" propertyname="ReasonForWriteOff" resourceassemblyname="" sortexpression="ReasonForWriteOff" meta:resourcekey="UIGridViewBoundColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                               
                            </Columns>
                        </ui:uigridview>
                        <ui:uiobjectpanel id="EquipmentWriteOffItem_ObjectPanel" runat="server" borderstyle="NotSet" meta:resourcekey="EquipmentWriteOffItem_ObjectPanelResource1" >
                            <web:subpanel ID="EquipmentWriteOffItem_SubPanel" runat="server" GridViewID="EquipmentWriteOffItems" OnPopulateForm="EquipmentWriteOffItem_SubPanel_PopulateForm" OnValidateAndUpdate="EquipmentWriteOffItem_SubPanel_ValidateAndUpdate" />
                               <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" PropertyName="EquipmentID" ValidateRequiredField="True" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged" meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode"></ui:UIFieldTreeList>  
                               <ui:UIFieldTextBox runat="server" ID="txtReasonForWriteOff" Caption="Reason For Write-Off" PropertyName="ReasonForWriteOff" InternalControlWidth="95%" meta:resourcekey="txtReasonForWriteOffResource1"></ui:UIFieldTextBox>                      
                        </ui:uiobjectpanel>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
