<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Location Map</title>
<style>
<!--
.dragme{position:relative;}
-->
</style>
<script type="text/javascript" language="JavaScript1.2">
<!--

var ie=document.all;
var nn6=document.getElementById&&!document.all;

var isdrag=false;
var x,y;
var dobj;

function movemouse(e)
{
  if (isdrag)
  {
    dobj.style.left = nn6 ? tx + e.clientX - x : tx + event.clientX - x;
    dobj.style.top  = nn6 ? ty + e.clientY - y : ty + event.clientY - y;
    
    document.form1.hX.value = dobj.style.left;
    document.form1.hY.value = dobj.style.top;
    
    parent.window.document.form1.aa.value = document.form1.hX.value.replace('px','');
    parent.window.document.form1.bb.value = document.form1.hY.value.replace('px','');
    //alert(dobj.style.left);
    return false;
  }
}

function GetX()
{
    return hX.value;
}

function GetY()
{
    return hY.value;
}

function selectmouse(e) 
{
  var fobj       = nn6 ? e.target : event.srcElement;
  var topelement = nn6 ? "HTML" : "BODY";

  while (fobj.tagName != topelement && fobj.className != "dragme")
  {
    fobj = nn6 ? fobj.parentNode : fobj.parentElement;
  }

  if (fobj.className=="dragme")
  {
    isdrag = true;
    dobj = fobj;
    tx = parseInt(dobj.style.left+0);
    ty = parseInt(dobj.style.top+0);
    x = nn6 ? e.clientX : event.clientX;
    y = nn6 ? e.clientY : event.clientY;
    document.onmousemove=movemouse;
    return false;
  }
}

document.onmousedown=selectmouse;
document.onmouseup=new Function("isdrag=false");
//alert(document.form1.myDot.value);



function repositionMarker()
{
     if (parent.window.document.form1.aa.value != '' && parent.window.document.form1.bb.value != '')
     {
         document.getElementById('myDot').style.left = parent.window.document.form1.aa.value + 'px';
         document.getElementById('myDot').style.top = parent.window.document.form1.bb.value + 'px';
     }
}


//-->
</script>

</head>
<body style="margin:0 0 0 0">
<form id="form1" name="form1" action="" method="post">


<img id="imag" src="map.gif" width="970" height="485" border="1" />
<img id="myDot" src="mapmarker.png" name="myDot" class="dragme" style="position:absolute; left:0px; top:0px; width:22px; height:20px" />

<input name="hX" id="hX" type="hidden" value="<% if (Request["l"]!=null) {Response.Write(Request["l"].ToString());}%>" />
<input name="hY" id="hY" type="hidden" value="<% if (Request["t"]!=null) {Response.Write(Request["t"].ToString());}%>" />

<script type="text/javascript" language="javascript">repositionMarker();</script>
<script src='../scripts/pngfix.js'></script>
</form>
</body>
</html>