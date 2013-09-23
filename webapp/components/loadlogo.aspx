<%@ Page Language="C#" AutoEventWireup="true" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">

    
    
    protected override void OnLoad(EventArgs e)
    {
        if (Request["ID"] != null)
        {
            OCapitalandCompany company = TablesLogic.tCapitalandCompany.Load(new Guid(Request["ID"]));

            Response.BinaryWrite(company.LogoFile);
            Response.End();
        }
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>

