<%@ Page Language="C#" MaintainScrollPositionOnPostback="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="pragma" content="no-cache" />

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
    <head>
        <TITLE></TITLE>
        <meta name="GENERATOR" content="Microsoft Visual Studio .NET 7.1">
        <meta name="ProgId" content="VisualStudio.HTML">
        <meta name="Originator" content="Microsoft Visual Studio .NET 7.1">
    </head>
    <frameset cols="220,*"  frameborder="1" framespacing="6" bordercolor="#0080C0" >
        <frame src="tree.aspx?" id="frameLeft" name="frameLeft" frameborder="0" bordercolor="#0080C0" >
        <frame src="search.aspx?vid=<%= Request["vid"] %>&tid=<%= Request["tid"] %>" id="frameRight" name="frameRight" frameborder="0" scroll="yes" scrolling="yes">
    </frameset>
</html>

