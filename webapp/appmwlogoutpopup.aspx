<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" UICulture="Auto" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["SessionId"] != null)
            Security.Logoff((Guid)Session["SessionId"]);
        Session.Clear();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >

    <head id="Head1" runat="server">
        <title>Simplism.EAM</title>
    </head>
    <body>
        <form id="form1" runat="server">
            <div style="height:55px"></div>
            <div style="text-align:center; font-weight:bold; margin-left:22px; margin-right:22px">
                You have logout the system.
                <br />
                <br />
                Please close other relevant windows if there is any.
            </div>
        </form>
    </body>
    <script type="text/javascript">
        function closeWindow()
        {
            window.close();
        }
        window.setTimeout( "closeWindow()", 1000 );
    </script>
</html>

