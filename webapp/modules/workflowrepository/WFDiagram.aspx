<%@ Page Language="C#" Inherits="PageBase" %>

<%@ Import Namespace="System.Xml" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        ReadWorkFlow();
    }

    protected void ReadWorkFlow()
    {

        OWorkflowRepositoryVersion wf = null;
        int workflowVersionNumber = Int32.Parse(Security.Decrypt(Request["WFVER"]));
        //if (workflowVersionNumber > 0)
        //{
        //    wf = OWorkflowRepository.GetWorkflowVersion(Security.Decrypt(Request["OBJTYPE"]), workflowVersionNumber);
        //}
        //else
        {
            wf = OWorkflowRepository.GetLatestWorkflowVersion(Security.Decrypt(Request["OBJTYPE"]));
        }

        XmlDocument layout = new XmlDocument();
        XmlDocument xoml = new XmlDocument();

        //load .layout file
        if (wf.LayoutFile != null)
        {
            byte[] encodedString = Encoding.UTF8.GetBytes(wf.LayoutFile);
            System.IO.MemoryStream ms = new System.IO.MemoryStream(encodedString);
            ms.Flush();
            ms.Position = 0;

            layout.Load(ms);
        }
        else
        {
            Response.Write(".layout file not found.");
        }

        //load .xoml file
        if (wf.WorkflowFile != null)
        {
            byte[] encodedString = Encoding.UTF8.GetBytes(wf.WorkflowFile);
            System.IO.MemoryStream ms = new System.IO.MemoryStream(encodedString);
            ms.Flush();
            ms.Position = 0;

            xoml.Load(ms);
        }
        else
        {
            Response.Write(".xoml file not found.");
        }

        //Drawing the state boxes
        XmlNodeList StateDesigners = layout.GetElementsByTagName("StateDesigner");

        foreach (XmlNode StateDesigner in StateDesigners)
        { //<StateDesigner>
            string[] loc = StateDesigner.Attributes["Location"].Value.ToString().Split(',');
            string[] size = StateDesigner.Attributes["Size"].Value.ToString().Split(',');
            string stateName = StateDesigner.Attributes["Name"].Value.ToString();

            string cssclass = "";

            if (stateName == Security.Decrypt(Request["OBJSTATUS"]))
                cssclass = "stateBox-current";
            else
                cssclass = "stateBox";

            Response.Write("<div class='" + cssclass + "' style='left:" + loc[0] + "px;top:" + loc[1] + "px;width:" + size[0] + "px;height:" + size[1] + "px;' onmouseover=mouseover('" + stateName + "') onmouseout=mouseout('" + stateName + "')>");
            string translatedStateName = Resources.WorkflowStates.ResourceManager.GetString(stateName);
            Response.Write(translatedStateName == null ? stateName : translatedStateName);


            //Drawing all the actions within the state boxes.
            XmlNodeList StateActivities = xoml.GetElementsByTagName("StateActivity");

            foreach (XmlNode StateActivity in StateActivities)
            { //<StateActivity>
                if (StateActivity.Attributes["x:Name"].Value.ToString() == stateName)
                { //Output the description
                    if (stateName != "Start" && StateActivity.Attributes["Description"] != null)
                    {
                        string text = StateActivity.Attributes["Description"].Value.ToString();

                        int maxlength = (Int32.Parse(size[0]) - 10) / 2;

                        if (maxlength > text.Length)
                            maxlength = text.Length;


                        string trimtext = text.Substring(0, maxlength);
                        Response.Write("<div>" + trimtext + "</div>");
                    }
                    Response.Write("</div>");


                    foreach (XmlNode EventDrivenActivity in StateActivity)
                    {
                        //<EventDrivenActivity>    
                        foreach (XmlNode HandleExternalEventActivity in EventDrivenActivity)
                        {
                            if (HandleExternalEventActivity.Attributes["EventName"] != null)
                            { //<HandleExternalEventActivity>

                                XmlNode parentnode = HandleExternalEventActivity.ParentNode;
                                XmlNodeList EventDrivenDesigners = layout.GetElementsByTagName("EventDrivenDesigner");
                                string[] locAction = null;
                                //string[] sizeAction = null;

                                foreach (XmlNode EventDrivenDesigner in EventDrivenDesigners)
                                {
                                    //Get position of event box from layout file
                                    if (EventDrivenDesigner.Attributes["Name"].Value.ToString() == parentnode.Attributes["x:Name"].Value.ToString())
                                    {
                                        locAction = EventDrivenDesigner.Attributes["Location"].Value.ToString().Split(',');
                                        //sizeAction = EventDrivenDesigner.Attributes["Size"].Value.ToString().Split(',');
                                        break;
                                    }
                                }

                                string actionName = HandleExternalEventActivity.Attributes["EventName"].Value.ToString();
                                string translatedActionName = Resources.WorkflowEvents.ResourceManager.GetString(actionName);

                                Response.Write("<div class='actionBox' style='left:" + locAction[0] + "px;top:" + locAction[1] + "px;width:" + (Int32.Parse(size[0]) - 30) + "px;height:" + "15px" + "' onmouseover=mouseover('" + stateName + "^" + parentnode.Attributes["x:Name"].Value.ToString() + "') onmouseout=mouseout('" + stateName + "^" + parentnode.Attributes["x:Name"].Value.ToString() + "');>");
                                Response.Write(translatedActionName == null ? actionName : translatedActionName);
                                Response.Write("</div>");

                            }
                        }
                    }
                    break;
                }
            }
        }

        //Drawing the Connector Lines
        XmlNodeList itemlist = layout.GetElementsByTagName("StateMachineWorkflowDesigner.DesignerConnectors");

        foreach (XmlNode item in itemlist)
        { //<StateMachineWorkflowDesigner.DesignerConnectors>
            foreach (XmlNode data in item)
            { //<StateDesignerConnector>

                string SourceStateName = data.Attributes["SourceStateName"].Value.ToString();
                //string TargetStateName = data.Attributes["TargetStateName"].Value.ToString();
                string EventHandlerName = data.Attributes["EventHandlerName"].Value.ToString();

                foreach (XmlNode pts in data)
                { //<StateDesignerConnector.Segments>
                    string strarray = "drawConnector(new Array(";
                    bool first = true;
                    XmlNode lastNode = null;
                    foreach (XmlNode pt in pts)
                    { //<ns0:Point>
                        lastNode = pt;
                        if (first)
                        {
                            strarray += "new jsPoint(" + (Int32.Parse(pt.Attributes["X"].Value) - 20).ToString() + "," + pt.Attributes["Y"].Value.ToString() + "),";
                            first = false;
                        }
                        else
                            strarray += "new jsPoint(" + pt.Attributes["X"].Value.ToString() + "," + pt.Attributes["Y"].Value.ToString() + "),";
                    }

                    strarray = strarray.TrimEnd(',');
                    strarray += "),'" + SourceStateName + "^" + EventHandlerName + "');";

                    strarray += "drawArrowHeadDown(new jsPoint(" + lastNode.Attributes["X"].Value.ToString() + "," + lastNode.Attributes["Y"].Value.ToString() + "),'" + SourceStateName + "^" + EventHandlerName + "');";

                    Window.WriteJavascript(strarray);


                }
            }
        }
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script type="text/javascript" src="../../scripts/jsDraw2D.js"></script>

    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />

    <script type="text/javaScript">
        function drawConnector(pts, divid) {
            //Create jsGraphics object
            var gr = new jsGraphics(document.getElementById("canvas"));

            //Create jsColor object
            var col = new jsColor("red");

            //Create jsPen object
            var pen = new jsPen(col, 2);

            //draw a connecting line
            gr.drawPolyline(pen, pts, divid);
        }

        function drawArrowHeadDown(pt, divid) {
            //Create jsGraphics object
            var gr = new jsGraphics(document.getElementById("canvas"));

            //Create jsColor object
            var col = new jsColor("red");

            //Create jsPen object
            //var pen = new jsPen(col, 2);

            var pts = new Array(new jsPoint(pt.x, pt.y), new jsPoint(pt.x - 4, pt.y - 4), new jsPoint(pt.x + 4, pt.y - 4));

            gr.fillPolygon(col, pts, divid);

        }

        //mouseover event - to highlight the line
        function mouseover(divid) {
            var likemode = divid.indexOf("^");

            var divs = document.getElementsByTagName("div");

            for (var i = 0; i < divs.length; i++) {
                if (divs[i].getAttribute("name") != null) {
                    divs[i].style.zIndex = 2;
                }
            }

            if (likemode > -1) {
                for (var i = 0; i < divs.length; i++) {
                    if (divs[i].getAttribute("name") == divid) {
                        divs[i].style.zIndex = 3;
                        divs[i].style.backgroundColor = 'black';
                    }
                }
            }
            else {
                for (var i = 0; i < divs.length; i++) {
                    if (divs[i].getAttribute("name") != null) {
                        var pos = divs[i].getAttribute("name").indexOf(divid);
                        if (pos != -1 && divs[i].getAttribute("name").indexOf("^") > pos) {
                            divs[i].style.zIndex = 3;
                            divs[i].style.backgroundColor = 'black';
                        }
                    }
                }

            }
        }

        function mouseout(divid) {
            var likemode = divid.indexOf("^");

            var divs = document.getElementsByTagName("div");
            if (likemode > -1) {
                for (var i = 0; i < divs.length; i++) {
                    if (divs[i].getAttribute("name") == divid) {
                        divs[i].style.zIndex = 2;
                        divs[i].style.backgroundColor = 'red';
                    }
                }
            }
            else {
                for (var i = 0; i < divs.length; i++) {
                    if (divs[i].getAttribute("name") != null) {
                        var pos = divs[i].getAttribute("name").indexOf(divid);
                        if (pos != -1 && divs[i].getAttribute("name").indexOf("^") > pos) {
                            divs[i].style.zIndex = 2;
                            divs[i].style.backgroundColor = 'red';
                        }
                    }
                }
            }
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div id="canvas">
    </div>
    </form>
</body>
</html>
