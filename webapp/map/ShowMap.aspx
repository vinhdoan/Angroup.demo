<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Page Language="C#" AutoEventWireup="true" Theme="Corporate" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head runat="server">
<title></title>
<link href="~/App_Themes/Corporate/dragdrop.css" type="text/css" rel="stylesheet" />
<link href="~/App_Themes/Corporate/StyleSheet.css" type="text/css" rel="stylesheet" />
<script type='text/javascript'>
    function setLocation(LocationObjectID)
    {
        if (opener && !opener.closed && opener.setTargetField) {
            opener.setTargetField(LocationObjectID);
        }
        window.close();
    }
</script>
</head>
<body style="margin:0 0 0 0">
<img id="imag" src="map.gif" width="970" height="485" border="1" usemap="#Map"><br>

<%    
    List<OLocation> AllLocations = TablesLogic.tLocation.LoadList(
        TablesLogic.tLocation.IsPhysicalLocation == 1 &
        TablesLogic.tLocation.CoordinateLeft != null &
        TablesLogic.tLocation.CoordinateRight != null &
        TablesLogic.tLocation.IsDeleted == 0);
    foreach (OLocation Location in AllLocations)
    {
        if (Location.CoordinateLeft != "" & Location.CoordinateRight !="")
        {
            Response.Write("<DIV style=\"LEFT: " + Location.CoordinateLeft + 
                "px; FLOAT: right; WIDTH: 20px; POSITION: absolute; TOP: " + 
                Location.CoordinateRight + "px\"><a href=\"javascript:setLocation('" + Security.Encrypt(Location.ObjectID.ToString()) + 
                "');\"><img src=\"mapmarker.png\" border=\"0\" alt=\"" + Location.ObjectName.ToString() + "\"></a></div>");      
        }
    }
    %>

<div align="center">
    <asp:Label runat="server" ID="labelHint">Click on the marker to select the location.</asp:Label>
</div>
<script src='../scripts/pngfix.js'></script>

</body>
</html>


