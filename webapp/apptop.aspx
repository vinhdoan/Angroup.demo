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
    <title>Simplism</title>
</head>
<body style="overflow: hidden" scroll="no" topmargin="0" bottommargin="0" rightmargin="0"
    leftmargin="0" onunload="return window_onunload()">
    <form id="form1" runat="server" style="border-top: 0px; border-bottom: 0px">
    <div id="divmenu">
        <web:menu runat="server" ID="menu"></web:menu>
    </div>
    <iframe src="home.aspx" name="frameBottom" id="frameBottom" width="100%" frameborder="0" runat='server' 
        scrolling="yes"></iframe>
    </form>
</body>

<script type="text/javascript">
    function resizeFrame() {
        var theWidth, theHeight;

        if (window.innerHeight) {
            theHeight = window.innerHeight;
        }
        else if (document.documentElement && document.documentElement.clientHeight) {
            theHeight = document.documentElement.clientHeight;
        }
        else if (document.body) {
            theHeight = document.body.clientHeight;
        }

        var f = document.getElementById("frameBottom");
        var d = document.getElementById("divmenu");

        f.height = theHeight - d.offsetHeight;
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
