<%@ Control Language="C#" ClassName="objectAttribute" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register src="~/components/objectCustomized.ascx" tagPrefix="web2" tagName="customizedObject" %>
<%@ Register src="~/components/objectPanel.ascx" tagPrefix="web2" tagName="object" %>

<script runat="server">
  //Rachel 13April 2007. Customized object
    private string attachedObjectName;
    [Localizable(false), Browsable(true)]   
    public string AttachedObjectName
    {
        get
        {     
            return attachedObjectName;
        }
        set            
        {
            if(value=="" || value.Trim()=="")
                throw new Exception("Error encountered while trying to build customized object control. AttachedObjectName properties has not been specified");            
            //validate to make sure the object type is a correct object type in the system. 
            SchemaBase baseTable = (SchemaBase)UIBinder.GetValue(typeof(TablesLogic), value, true);
            if (baseTable == null)                
                throw new Exception("Error encountered while trying to build customized object control. No object with ID " + value.ToString() + " found. Please specify new object ID");
            this.attachedObjectName= value;
        }
    }

    private string tabViewID;
    [Localizable(false), Browsable(true)]   
    public string TabViewID
    {
        get
        {
            return tabViewID;                        
        }
        set
        {
            if (tabViewID == "")
                throw new Exception("Error encountered while trying to build customized object control. TabViewPosition must be in integer format");
            else
                tabViewID = value;
          
            
        }
        
    }
    private string attachedPropertyName;
    [Localizable(false), Browsable(true)]
    public string AttachedPropertyName
    {
        get
        {
            return attachedPropertyName;
        }
        set
        {
            if (value == null || value.Trim() == "")
                throw new Exception("Error encountered while trying to build customized object control. AttachedPropertyName properties has not been specified");
            //test to make sure the attached property is correct in the main object
            SchemaBase baseTable = (SchemaBase)UIBinder.GetValue(typeof(TablesLogic), AttachedObjectName, true);
            object column = UIBinder.GetValue(baseTable, value, false);
            if (column == null || !(column is ExpressionData))
                throw new Exception("Error encountered while trying to build customized object control. No property name " + value + " found on table schema " + AttachedObjectName);
            attachedPropertyName = value;
        }
    }
    // hunts for the objectPanel.ascx control and finds the PersistentObject
    //
    protected objectPanel getPanel(Control c)
    {
        if (c.GetType() == typeof(objectPanel))
            return (objectPanel)c;
        foreach (Control child in c.Controls)
        {
            objectPanel o = getPanel(child);
            if (o != null)
                return o;
        }
        return null;
    }

    protected void customizedObject_FieldUpdating(object sender, EventArgs e)
    {
        PersistentObject obj = customizedObject.SessionObject;
        OCustomizedAttributeField field = (OCustomizedAttributeField)obj;
        field.AttachedObjectName = this.AttachedObjectName;
        field.AttachedPropertyName = this.AttachedPropertyName;
        field.TabViewID = this.TabViewID.Trim();
        field.MainObjectID = getPanel(Page).SessionObject.ObjectID;
        field.IsVisible = 1;
    }
    
    
</script>

  <web2:customizedObject id="customizedObject" runat="server" GridViewPropertyName="CustomizedAttributeFields" OnFieldUpdating="customizedObject_FieldUpdating"    />  
  