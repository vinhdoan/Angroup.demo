<%@ Page Language="C#" AutoEventWireup="true" CodeFile="loadlogo.aspx.cs" Inherits="modules_keppelPRBatchOrder_OrderPDF" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">

    
    
    protected override void OnLoad(EventArgs e)
    {
        if (Request["CompanyID"] != null)
        {
            OCapitalandCompany company = TablesLogic.tCapitalandCompany.Load(new Guid(Request["CompanyID"]));

            Response.BinaryWrite(company.LogoFile);
            Response.End();
        }
        if (Session["Logo"] != null)
        {
            byte[] logo = (byte[])Session["Logo"];

            Response.BinaryWrite(logo);
            Response.End();
        }
    }

    protected override void OnUnload(EventArgs e)
    {
        base.OnUnload(e);

      
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

