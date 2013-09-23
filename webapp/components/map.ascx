<%@ Control Language="C#" ClassName="map" %>

<script runat="server">
    
    string targetControlID;
    
    /// <summary>
    /// Gets or sets the ID of the treelist control that will be updated
    /// when the user selects an item in the map.
    /// </summary>
    public string TargetControlID
    {
        get
        {
            return targetControlID;
        }
        set
        {
            targetControlID = value;
        }
    }


    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            Control control = this.Parent.NamingContainer.FindControl(targetControlID);
            
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "mapscript",
            @"
function openMap() 
{
    var w = window.open('" + ResolveClientUrl("~/map/showmap.aspx") + @"',
    'color_popup',
    'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0,width=1000,height=520,left = 12,top = 130');
    w.focus();
    return false;
}

function setTargetField(value)
{
    var el = document.getElementById('" + control.ClientID + @"');
    el.value = value;
    __doPostBack('" + control.ClientID + @"', 'SEARCH_' + value);
    window.focus();
}
", true);

        }
    }

</script>


<a href="javascript:void(0)" OnClick="return openMap()"><asp:Image runat="server" imageurl="~/images/map.png" ID="image1" Visible="false" /></a>


