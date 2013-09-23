<%@ Page Language="C#" MaintainScrollPositionOnPostback="false"  Inherits="PageBase"%>

<script runat="server">
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
    <head runat="server">
        <TITLE></TITLE>
        <meta name="GENERATOR" content="Microsoft Visual Studio .NET 7.1"/>
        <meta name="ProgId" content="VisualStudio.HTML"/>
        <meta name="Originator" content="Microsoft Visual Studio .NET 7.1"/>
    </head>
    <frameset cols="*"  frameborder="1" framespacing="6" bordercolor="#0080C0" >
        <frame src="../../report/view/search.aspx?ID=<%= HttpUtility.UrlEncode(Request["ID"]) %>" id="frameBottom" name="frameBottom" frameborder="0" scrolling="yes">
    </frameset>
</html>
