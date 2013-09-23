<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCustomizedRecordObject customizedRecordObject = panel.SessionObject as OCustomizedRecordObject;

        this.objectType.Bind(GetCustomizableObjects(customizedRecordObject), "ObjectTypeName", "ObjectID", true);
        foreach (ListItem item in objectType.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }

        panel.ObjectPanel.BindObjectToControls(customizedRecordObject);
    }


    /// <summary>
    /// populate object type name with a list of object with customizable attribute and the one that has not be customized - except the currently edited object
    /// </summary>
    /// <returns></returns>
    protected DataTable GetCustomizableObjects(PersistentObject currentRecord)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ObjectID", typeof(string));
        dt.Columns.Add("ObjectTypeName", typeof(string));
        List<OFunction> listFunctions = OFunction.GetAllFunction();
        foreach (OFunction func in listFunctions)
        {
            if (func.IsCustomizable == 1)
            {
                //Eliminate those object record that has been customized. 
                List<OCustomizedRecordObject> record = TablesLogic.tCustomizedRecordObject[TablesLogic.tCustomizedRecordObject.AttachedObjectName == func.ObjectTypeName];
                //for edit case, accept the currently edit object type
                if ((currentRecord != null && !currentRecord.IsNew) || record == null || record.Count == 0)
                {
                    DataRow row = dt.NewRow();
                    row["ObjectID"] = func.ObjectTypeName;
                    //
                    row["ObjectTypeName"] = func.FunctionName;
                    dt.Rows.Add(row);
                }
            }
        }

        return dt;
    }


    /// <summary>
    /// Validates and saves the customized object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCustomizedRecordObject cusObject = panel.SessionObject as OCustomizedRecordObject;
            panel.ObjectPanel.BindControlsToObject(cusObject);

            // Additional processing
            //
            List<OFunction> listFunctions = OFunction.GetAllFunction();
            foreach (OFunction func in listFunctions)
            {
                if (func.ObjectTypeName == cusObject.AttachedObjectName)
                    cusObject.TranslateObjectName = func.FunctionName;
            }

            // Save
            //
            cusObject.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Populates the sub-panel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ObjectFields_FieldPopulate(object sender, EventArgs e)
    {
        OCustomizedRecordField field = (OCustomizedRecordField)ObjectFields.SessionObject;
        ObjectFields.ObjectPanel.BindObjectToControls(field);
    }

        
    /// <summary>
    /// Updates the object fields.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ObjectFields_ValidateAndUpdate(object sender, EventArgs e)
    {
        OCustomizedRecordObject obj = panel.SessionObject as OCustomizedRecordObject;
        panel.ObjectPanel.BindControlsToObject(obj);
        
        OCustomizedRecordField field = (OCustomizedRecordField)ObjectFields.SessionObject;

        if (field.IsNew)
            field.RecordObjectID = panel.SessionObject.ObjectID;

        obj.CustomizedRecordFields.Add(field);
        panel.ObjectPanel.BindObjectToControls(obj);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OCustomizedRecordObject record = (OCustomizedRecordObject)panel.SessionObject;
        
        if (!record.IsNew)
            this.objectType.Enabled = false;
        else
            this.objectType.Enabled = true;
    }

    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="~/App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" BaseTable="tCustomizedRecordObject" Caption="Customized Object"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"/>
            <div class="div-main">
                <ui:UITabStrip ID="tabObject" runat="server" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="tabView1" runat="server" Caption="Details" 
                        meta:resourcekey="tabView1Resource1" BorderStyle="NotSet">
                        <web:base ObjectNumberVisible="false" ID="objectBase" runat="server" ObjectNameVisible="false" />
                        <ui:UIFieldDropDownList runat="server" ID="objectType" Caption="Object Type Name" Span="Half"
                            PropertyName="AttachedObjectName" ToolTip="The object type to be customized."
                            ValidateRequiredField="True" meta:resourcekey="objectTypeResource1">
                        </ui:UIFieldDropDownList>
                        <br />
                        <br />
                        <ui:UIFieldTextBox runat="server" ID="TabViewPosition" Caption="Tab View Position"
                            Span="Half" PropertyName="TabViewPosition" ToolTip="The position of the tab view for these customized fields at the object's edit page. 1 for being the first tab from the left. Leave this empty if the tab view is to be inserted last"
                            ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidationRangeMin="1"
                            meta:resourcekey="TabViewPositionResource1" InternalControlWidth="95%" />
                    </ui:UITabView>
                    <ui:UITabView ID="tabView2" runat="server" Caption="Fields" 
                        meta:resourcekey="tabView2Resource1" BorderStyle="NotSet">
                        <web:customized GridViewPropertyName="CustomizedRecordFields" ID="ObjectFields" OnFieldUpdate="ObjectFields_ValidateAndUpdate"
                            runat="server" ValidateGridFieldsRequired="true" OnFieldPopulate="ObjectFields_FieldPopulate"></web:customized>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
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
