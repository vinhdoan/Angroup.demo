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
        OEquipmentType EquipmentType = panel.SessionObject as OEquipmentType;

        if (Request["TREEOBJID"] != null && TablesLogic.tEquipmentType[Security.DecryptGuid(Request["TREEOBJID"])] != null)
        {
            EquipmentType.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);

            if (EquipmentType.Parent != null && EquipmentType.Parent.IsLeafType == 1)
                EquipmentType.ParentID = null;
        }

        ParentID.PopulateTree();
        ParentID.Enabled = EquipmentType.IsNew;

        panel.ObjectPanel.BindObjectToControls(EquipmentType);
    }
    

    /// <summary>
    /// Validates and saves the equipment type object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OEquipmentType equipmentType = (OEquipmentType)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(equipmentType);

        // Validate
        //
        if (equipmentType.IsDuplicateName())
            objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
        if (equipmentType.IsCyclicalReference())
            ParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;

        if (!panel.ObjectPanel.IsValid)
            return;

        equipmentType.IsLeafType = 1;

        // Save
        //
        equipmentType.Save();
        
        // Pass the value back to the parent.
        //
        PersistentObject persistentObject = Session["::SessionObject::"] as PersistentObject;
        if (persistentObject is OCatalogue)
        {
            ((OCatalogue)persistentObject).EquipmentTypeID = equipmentType.ObjectID;
            Window.Opener.ClickUIButton("buttonSelectEquipmentType");
        }
    }

    /// <summary>
    /// Constructs and returns the equipment type tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new EquipmentTypeTreePopulater(panel.SessionObject.ParentID, false);
    }


</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Equipment Type" BaseTable="tEquipmentType"
                SaveAndCloseButtonVisible="true" SaveAndNewButtonVisible="false" SaveButtonVisible="false"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false"></web:base>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            OnAcquireTreePopulater="ParentID_AcquireTreePopulater" ToolTip="The group or equipment type under which this belongs to."
                            meta:resourcekey="ParentIDResource1" />
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
