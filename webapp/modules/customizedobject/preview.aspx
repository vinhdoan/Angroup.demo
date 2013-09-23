<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" EnableTheming="true"  %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.UIFramework" %>

<script runat="server">  
    //Rachel 13April 2007 CUstomized object 
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        if (!IsPostBack)
        {
            if (Request["ID"] != null)
            {
                string sessionKey = Security.Decrypt(Request["ID"].ToString());
                if (Session[sessionKey] != null)
                {
                    ArrayList fields = (ArrayList)Session[sessionKey];
                    OCustomizedObjectConsumer.BuildCustomizedControls(tabview, fields);                          
                    Session[sessionKey] = null;                   
                }
            }

        }
    } 
   
   
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Preview</title>
</head>
<body>
    <form id="form1" runat="server">
    <div class="div-main">
        <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource2">
                <ui:UITabView runat="server" ID="tabview" Caption="Fields" 
                   >                    
                </ui:UITabView>
                </ui:UITabStrip>   
         
    </div>
    </form>
</body>
</html>
