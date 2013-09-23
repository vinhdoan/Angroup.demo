<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

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
        OCodeType codeType = (OCodeType)panel.SessionObject;

        if (Request["TREEOBJID"] != null && TablesLogic.tCodeType[Security.DecryptGuid(Request["TREEOBJID"])] != null)
            codeType.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);

        ParentID.PopulateTree();
        ParentID.Enabled = codeType.IsNew;

        if (codeType.IsSystemCode == null)
            codeType.IsSystemCode = 0;
        objectBase.ObjectName.Enabled = (codeType.IsSystemCode == 0);

        panel.ObjectPanel.BindObjectToControls(panel.SessionObject);
    }


    /// <summary>
    /// Constructs and returns the code type tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new CodeTypeTreePopulater(panel.SessionObject.ParentID);
    }


    /// <summary>
    /// Validates and saves the code type into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCodeType codeType = (OCodeType)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(codeType);

            // Validate
            //
            if (codeType.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (codeType.IsCyclicalReference())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.Code_CyclicalReference;

            // Save
            //
            codeType.Save();
            c.Commit();
        }
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
            <web:object runat="server" ID="panel" Caption="CodeType" BaseTable="tCodeType" 
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            OnAcquireTreePopulater="ParentID_AcquireTreePopulater" ToolTip="The code type under which this one belongs to."
                            meta:resourcekey="ParentIDResource1">
                            <SelectedNodeStyle BorderStyle="Solid" BorderWidth="1px" BorderColor="Blue"></SelectedNodeStyle>
                        </ui:UIFieldTreeList>
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
