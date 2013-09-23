<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        
        // Show IsWholeNumberUnit Checkbox If Code Type is UnitOfMeasure 
        if (CodeTypeID.SelectedItem.Text.ToString() == "UnitOfMeasure")
            IsWholeNumberUnit.Visible = true;
        else
            IsWholeNumberUnit.Visible = false;
    }
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCode code = panel.SessionObject as OCode;

        if (Request["TREEOBJID"] != null && code.IsNew && TablesLogic.tCode[Security.DecryptGuid(Request["TREEOBJID"])] != null)
            code.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);

        ParentID.PopulateTree();
        ParentID.Enabled = code.IsNew;

        populateCodeTypeID(code);

        panel.ObjectPanel.BindObjectToControls(code);
    }


    /// <summary>
    /// Populates the Code Type dropdown list.
    /// </summary>
    /// <param name="code"></param>
    protected void populateCodeTypeID(OCode code)
    {
        CodeTypeID.Items.Clear();
        if (code.Parent != null)
            CodeTypeID.Bind(code.Parent.CodeType.Children);
        else
            CodeTypeID.Bind(OCodeType.GetRootCodeTypes());

    }


    /// <summary>
    /// Constructs and returns the code tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new CodeTreePopulater(panel.SessionObject.ParentID);
    }


    /// <summary>
    /// Occurs when the user selects a node on the ParentID treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ParentID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OCode code = panel.SessionObject as OCode;
        panel.ObjectPanel.BindControlsToObject(code);
        populateCodeTypeID(code);
    }


    /// <summary>
    /// Validates and saves the code object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCode code = (OCode)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(code);

            // Validate
            //
            if (code.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (code.IsCyclicalReference())
                ParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            code.Save();
            c.Commit();
        }
    }

    protected void CodeTypeID_SelectedIndexChanged(object sender, EventArgs e)
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
            meta:resourcekey="panelMainResource2">
            <web:object runat="server" ID="panel" Caption="Code" BaseTable="tCode" OnPopulateForm="panel_PopulateForm"
                meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            OnSelectedNodeChanged="ParentID_SelectedNodeChanged" OnAcquireTreePopulater="ParentID_AcquireTreePopulater"
                            ToolTip="The code under which this code belongs." 
                            meta:resourcekey="ParentIDResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode" />
                        <ui:uifieldtextbox id="textRunningNumberCode" runat="server" caption="Running Number Code" internalcontrolwidth="95%" meta:resourcekey="textRunningNumberCodeResource1" propertyname="RunningNumberCode"></ui:uifieldtextbox>
                        <ui:UIFieldDropDownList runat="server" ID="CodeTypeID" PropertyName="CodeTypeID"
                            Caption="Code Type" ValidateRequiredField="True" ToolTip="The type of this code."
                            OnSelectedIndexChanged="CodeTypeID_SelectedIndexChanged"
                            meta:resourcekey="CodeTypeIDResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldCheckBox runat="server" ID="IsWholeNumberUnit" PropertyName="IsWholeNumberUnit"
                         Caption="Whole Number Unit" Text="Yes, this will format the unit to a whole number"
                         meta:resourcekey="IsWholeNumberUnitResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                        &nbsp; &nbsp;&nbsp;
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
