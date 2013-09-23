<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" UICulture="Auto" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            if (OApplicationSetting.Current.HomePageUrl != null && OApplicationSetting.Current.HomePageUrl != "")
            {
                frameBottom.Attributes["src"] = ResolveUrl(OApplicationSetting.Current.HomePageUrl);
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body topmargin="0" bottommargin="0" rightmargin="0"
    leftmargin="0" onunload="return window_onunload()">
    <form id="form1" runat="server" style="border-top: 0px; border-bottom: 0px">
    <div id="divmenu">
        <web:menu2 runat="server" ID="menu"></web:menu2>
    </div>
    <div align='center'>
    <iframe src="home.aspx" name="frameBottom" id="frameBottom" width="960px" height="800px" frameborder="0" runat='server' 
        scrolling="no"></iframe>
    </div>
    </form>
</body>

<script type="text/javascript">
    function getIFrameDocument(id) {
        var rv = null;
        var frame = document.getElementById(id);
        if (frame.contentDocument)
            rv = frame.contentDocument;
        else
            rv = document.frames[id].document;
        return rv;
    }
    function resizeFrame() {
        var theWidth, theHeight;

        var f = document.getElementById("frameBottom");
        var fd = getIFrameDocument("frameBottom");

        if (fd.body && fd.body.scrollHeight)
            theHeight = fd.body.scrollHeight;
        
        if (theHeight)
            f.height = theHeight + 'px';
        window.setTimeout("resizeFrame()", 50);
    }

    window.setTimeout("resizeFrame()", 50);

    function window_onunload() {

        if ((document && document.forms[0] && document.forms[0].__EVENTTARGET && document.forms[0].__EVENTTARGET.value != ""))
            return;

/*
        var newwindow = window.open("appmwlogoutpopup.aspx", "MainWindowLogout", "location=0,menubar=0,toolbar=0,resizable=0,width=200,height=200");
        newwindow.moveTo((screen.width / 2) - 100, (screen.height / 2) - 100);
        newwindow.focus();*/
    }

</script>

</html>
